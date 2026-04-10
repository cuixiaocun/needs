<?php

namespace App\Services;

use App\Models\Order;
use App\Models\User;
use App\Models\FarmerDeposit;
use App\Models\FarmerDepositLog;
use App\Jobs\DispatchJob;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

/**
 * 取消订单服务
 *
 * 规则：
 * 1. 取货前 5 小时内可取消 → 扣信用分、冻结保证金
 * 2. 农户主动取消 → 触发紧急调货流程
 * 3. 买家取消 → 农户自动解冻保证金
 */
class CancelOrderService
{
    /**
     * 农户取消订单
     */
    public function cancelByFarmer(Order $order, $reason = '')
    {
        try {
            // 检查是否在可取消时间范围内
            if (!$this->canCancel($order)) {
                return [
                    'success' => false,
                    'error' => '订单已过取消时间（取货前 5 小时内）',
                ];
            }

            DB::beginTransaction();

            // 更新订单状态
            $order->update([
                'status' => 'cancelled',
                'notes' => "农户取消: {$reason}",
            ]);

            // 扣除信用分
            $farmer = User::find($order->farmer_id);
            $farmer->credit_score = max(0, $farmer->credit_score - 20);
            $farmer->save();

            // 冻结保证金
            $this->freezeDeposit($order->farmer_id, $order->total_amount);

            // 触发紧急调货
            dispatch(new DispatchJob())->delay(now()->addMinutes(5));

            // 记录日志
            FarmerDepositLog::create([
                'farmer_id' => $order->farmer_id,
                'type' => 'freeze',
                'amount' => $order->total_amount,
                'reason' => "订单取消冻结 - #{$order->id}",
                'order_id' => $order->id,
            ]);

            Log::info('农户取消订单', [
                'order_id' => $order->id,
                'farmer_id' => $order->farmer_id,
                'reason' => $reason,
            ]);

            DB::commit();

            return [
                'success' => true,
                'message' => '订单已取消，保证金已冻结，等待紧急调货处理',
                'credit_score' => $farmer->credit_score,
            ];
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('取消订单失败', ['error' => $e->getMessage()]);
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * 买家取消订单
     */
    public function cancelByBuyer(Order $order, $reason = '')
    {
        try {
            DB::beginTransaction();

            $order->update([
                'status' => 'cancelled',
                'notes' => "买家取消: {$reason}",
            ]);

            // 如果农户已确认，解冻保证金
            if ($order->farmer_id && $order->status === 'confirmed') {
                $this->unfreezeDeposit($order->farmer_id, $order->total_amount);

                FarmerDepositLog::create([
                    'farmer_id' => $order->farmer_id,
                    'type' => 'unfreeze',
                    'amount' => $order->total_amount,
                    'reason' => "买家取消订单解冻 - #{$order->id}",
                    'order_id' => $order->id,
                ]);
            }

            Log::info('买家取消订单', [
                'order_id' => $order->id,
                'buyer_id' => $order->buyer_id,
                'reason' => $reason,
            ]);

            DB::commit();

            return [
                'success' => true,
                'message' => '订单已取消',
            ];
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('取消订单失败', ['error' => $e->getMessage()]);
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * 管理员取消订单（处理异常情况）
     */
    public function cancelByAdmin(Order $order, $reason, $compensation = 0)
    {
        try {
            DB::beginTransaction();

            $order->update([
                'status' => 'cancelled',
                'notes' => "管理员取消: {$reason}",
            ]);

            // 解冻农户保证金
            if ($order->farmer_id) {
                $this->unfreezeDeposit($order->farmer_id, $order->total_amount);
            }

            // 如果有赔偿，从系统账户扣除
            if ($compensation > 0) {
                Log::warning('管理员赔偿', [
                    'order_id' => $order->id,
                    'compensation' => $compensation,
                ]);
            }

            Log::info('管理员取消订单', [
                'order_id' => $order->id,
                'reason' => $reason,
            ]);

            DB::commit();

            return [
                'success' => true,
                'message' => '订单已取消',
            ];
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('取消订单失败', ['error' => $e->getMessage()]);
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * 检查订单是否可取消
     *
     * 取消条件：预计交货时间 - 当前时间 >= 5 小时
     */
    public function canCancel(Order $order)
    {
        if (!$order->scheduled_delivery_time) {
            return true; // 没有设置交货时间可直接取消
        }

        $hoursUntilDelivery = now()->diffInHours($order->scheduled_delivery_time);
        return $hoursUntilDelivery >= 5;
    }

    /**
     * 获取订单可取消状态
     */
    public function getCancelStatus(Order $order)
    {
        if (!$order->scheduled_delivery_time) {
            return [
                'can_cancel' => true,
                'hours_until_locked' => null,
                'reason' => '无指定交货时间，随时可取消',
            ];
        }

        $hoursUntilDelivery = now()->diffInHours($order->scheduled_delivery_time);
        $canCancel = $hoursUntilDelivery >= 5;

        return [
            'can_cancel' => $canCancel,
            'hours_until_locked' => max(0, 5 - $hoursUntilDelivery),
            'reason' => $canCancel
                ? '可取消（距离交货 5 小时以上）'
                : sprintf('不可取消（还有 %.1f 小时即将锁定）', 5 - $hoursUntilDelivery),
        ];
    }

    /**
     * 冻结保证金
     */
    protected function freezeDeposit($farmerId, $amount)
    {
        $deposit = FarmerDeposit::where('farmer_id', $farmerId)->first();

        if ($deposit) {
            $freezeAmount = min($amount, $deposit->available);
            $deposit->update([
                'frozen' => $deposit->frozen + $freezeAmount,
                'available' => $deposit->available - $freezeAmount,
            ]);
        }
    }

    /**
     * 解冻保证金
     */
    protected function unfreezeDeposit($farmerId, $amount)
    {
        $deposit = FarmerDeposit::where('farmer_id', $farmerId)->first();

        if ($deposit && $deposit->frozen > 0) {
            $unfreezeAmount = min($amount, $deposit->frozen);
            $deposit->update([
                'frozen' => $deposit->frozen - $unfreezeAmount,
                'available' => $deposit->available + $unfreezeAmount,
            ]);
        }
    }
}
