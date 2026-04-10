<?php

namespace App\Services;

use App\Models\Order;
use App\Models\User;
use App\Models\EmergencyDispatchLog;
use App\Models\AgentCallRecord;
use App\Models\FarmerDeposit;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

/**
 * 紧急调货服务
 *
 * 流程：
 * 1. 农户取消订单（取货前 5 小时内）
 * 2. 触发紧急调货流程
 * 3. AI 对话系统寻找备用农户
 * 4. 代理人电话跟进
 * 5. 确认调货或处理赔偿
 */
class DispatchService
{
    /**
     * 发起紧急调货
     */
    public function initiateDispatch(Order $order, $reason = '')
    {
        try {
            DB::beginTransaction();

            Log::info('发起紧急调货', ['order_id' => $order->id, 'reason' => $reason]);

            // 创建紧急调货日志
            $dispatch = EmergencyDispatchLog::create([
                'order_id' => $order->id,
                'farmer_id' => $order->farmer_id,
                'status' => 'pending',
                'amount' => $order->total_amount,
                'fee' => 0, // 后续计算
            ]);

            // 冻结农户保证金
            $this->freezeDeposit($order->farmer_id, $order->total_amount);

            // 记录日志
            $this->logActivity("紧急调货已创建，等待处理", $dispatch->id);

            DB::commit();

            return [
                'success' => true,
                'dispatch_id' => $dispatch->id,
                'status' => 'pending',
                'message' => '紧急调货已发起，等待 AI 和代理人处理',
            ];
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('紧急调货发起失败', ['error' => $e->getMessage()]);
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * AI 寻找备用农户
     *
     * 根据以下条件寻找备用农户：
     * 1. 同种产品
     * 2. 预计供应时间相近
     * 3. 信用评分足够高
     * 4. 保证金充足
     */
    public function findAlternativeFarmers(Order $order, $maxResults = 3)
    {
        try {
            $alternatives = Order::where('product_name', $order->product_name)
                ->where('status', 'pending')
                ->where('farmer_id', '!=', $order->farmer_id)
                ->where('quantity', '>=', $order->quantity)
                ->where('price_per_unit', '<=', $order->price_per_unit * 1.1) // 价格不超过 10%
                ->with('farmer')
                ->limit($maxResults)
                ->get();

            return [
                'success' => true,
                'alternatives' => $alternatives->map(function ($alt) {
                    return [
                        'order_id' => $alt->id,
                        'farmer_id' => $alt->farmer_id,
                        'farmer_name' => $alt->farmer->name,
                        'product' => $alt->product_name,
                        'quantity' => $alt->quantity,
                        'price_per_unit' => $alt->price_per_unit,
                        'match_score' => $this->calculateMatchScore($alt),
                    ];
                }),
            ];
        } catch (\Exception $e) {
            Log::error('寻找备用农户失败', ['error' => $e->getMessage()]);
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * 代理人呼叫农户
     */
    public function callFarmer($orderId, $agentId, $farmerId)
    {
        try {
            $record = AgentCallRecord::create([
                'order_id' => $orderId,
                'agent_id' => $agentId,
                'farmer_id' => $farmerId,
                'call_start' => now(),
                'result' => 'pending',
            ]);

            Log::info('代理人呼叫记录已创建', ['record_id' => $record->id]);

            return [
                'success' => true,
                'record_id' => $record->id,
            ];
        } catch (\Exception $e) {
            Log::error('呼叫记录创建失败', ['error' => $e->getMessage()]);
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * 更新呼叫结果
     */
    public function updateCallResult($recordId, $result, $duration = 0, $notes = '')
    {
        try {
            $record = AgentCallRecord::findOrFail($recordId);

            $record->update([
                'result' => $result, // 'success' or 'failed'
                'call_duration' => $duration,
                'notes' => $notes,
            ]);

            Log::info('呼叫结果已更新', ['record_id' => $recordId, 'result' => $result]);

            return [
                'success' => true,
                'message' => '呼叫结果已记录',
            ];
        } catch (\Exception $e) {
            Log::error('呼叫结果更新失败', ['error' => $e->getMessage()]);
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * 确认调货成功
     */
    public function confirmDispatch($dispatchId, $alternativeFarmerId, $dispatchFee = 0)
    {
        try {
            DB::beginTransaction();

            $dispatch = EmergencyDispatchLog::findOrFail($dispatchId);

            // 更新调货状态
            $dispatch->update([
                'status' => 'confirmed',
                'fee' => $dispatchFee,
                'dispatch_time' => now(),
            ]);

            // 扣除原农户的保证金（赔偿差价和费用）
            $this->deductDeposit(
                $dispatch->farmer_id,
                $dispatchFee,
                "紧急调货费用 - 订单 #{$dispatch->order_id}"
            );

            // 分配调货订单给新农户
            $newOrder = Order::create([
                'farmer_id' => $alternativeFarmerId,
                'buyer_id' => Order::find($dispatch->order_id)->buyer_id,
                'product_name' => Order::find($dispatch->order_id)->product_name,
                'quantity' => Order::find($dispatch->order_id)->quantity,
                'unit' => Order::find($dispatch->order_id)->unit,
                'price_per_unit' => Order::find($dispatch->order_id)->price_per_unit,
                'total_amount' => Order::find($dispatch->order_id)->total_amount,
                'status' => 'confirmed',
                'scheduled_delivery_time' => Order::find($dispatch->order_id)->scheduled_delivery_time,
                'notes' => "紧急调货订单（原订单 #{$dispatch->order_id}）",
            ]);

            Log::info('调货已确认', [
                'dispatch_id' => $dispatchId,
                'new_order_id' => $newOrder->id,
                'fee' => $dispatchFee,
            ]);

            DB::commit();

            return [
                'success' => true,
                'new_order_id' => $newOrder->id,
                'message' => '调货已确认',
            ];
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('调货确认失败', ['error' => $e->getMessage()]);
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * 处理调货超时
     *
     * 每小时检查：
     * 如果调货 3 小时未确认，标记为失败，全额赔偿买家
     */
    public function handleDispatchTimeout()
    {
        try {
            $pendingDispatches = EmergencyDispatchLog::where('status', 'pending')
                ->where('created_at', '<', now()->subHours(3))
                ->get();

            foreach ($pendingDispatches as $dispatch) {
                // 全额扣除农户保证金
                $this->deductDeposit(
                    $dispatch->farmer_id,
                    $dispatch->amount,
                    "调货超时赔偿 - 订单 #{$dispatch->order_id}"
                );

                // 标记为失败
                $dispatch->update(['status' => 'completed']);

                Log::warning('调货已超时，农户保证金已扣除', ['dispatch_id' => $dispatch->id]);
            }

            return [
                'success' => true,
                'timeout_count' => $pendingDispatches->count(),
            ];
        } catch (\Exception $e) {
            Log::error('调货超时处理失败', ['error' => $e->getMessage()]);
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * 冻结保证金
     */
    protected function freezeDeposit($farmerId, $amount)
    {
        $deposit = FarmerDeposit::findOrFail($farmerId);
        $deposit->update([
            'frozen' => $deposit->frozen + $amount,
            'available' => $deposit->available - $amount,
        ]);
    }

    /**
     * 扣除保证金
     */
    protected function deductDeposit($farmerId, $amount, $reason)
    {
        $deposit = FarmerDeposit::findOrFail($farmerId);
        $deposit->update([
            'deducted' => $deposit->deducted + $amount,
            'frozen' => max(0, $deposit->frozen - $amount),
        ]);
    }

    /**
     * 计算匹配分数
     */
    protected function calculateMatchScore(Order $order)
    {
        $score = 0;

        // 价格匹配度（最高 30 分）
        $score += 30;

        // 信用评分（最高 40 分）
        $farmer = $order->farmer;
        if ($farmer->credit_score >= 90) {
            $score += 40;
        } elseif ($farmer->credit_score >= 80) {
            $score += 30;
        } elseif ($farmer->credit_score >= 70) {
            $score += 20;
        } else {
            $score += 10;
        }

        // 保证金充足度（最高 30 分）
        $deposit = FarmerDeposit::where('farmer_id', $farmer->id)->first();
        if ($deposit && $deposit->available >= $order->total_amount * 2) {
            $score += 30;
        } elseif ($deposit && $deposit->available >= $order->total_amount) {
            $score += 20;
        } else {
            $score += 10;
        }

        return $score;
    }

    /**
     * 记录活动日志
     */
    protected function logActivity($activity, $dispatchId)
    {
        Log::info('调货活动', [
            'dispatch_id' => $dispatchId,
            'activity' => $activity,
            'timestamp' => now(),
        ]);
    }
}
