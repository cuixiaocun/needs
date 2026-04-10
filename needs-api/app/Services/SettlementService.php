<?php

namespace App\Services;

use App\Models\User;
use App\Models\Order;
use App\Models\FarmerSettlement;
use App\Models\SettlementItem;
use App\Models\FarmerDepositLog;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

/**
 * 农户结算服务
 *
 * 每周一凌晨 00:05 执行：
 * 1. 统计上周所有已完成的订单
 * 2. 计算保证金扣款
 * 3. 生成结算记录
 * 4. 记录结算日志
 */
class SettlementService
{
    /**
     * 执行周期性结算
     */
    public function executeWeeklySettlement()
    {
        try {
            Log::info('开始执行周期性结算');

            DB::beginTransaction();

            // 获取所有农户
            $farmers = User::where('role', 'farmer')->get();

            foreach ($farmers as $farmer) {
                $this->settleForFarmer($farmer);
            }

            DB::commit();
            Log::info('周期性结算完成');

            return true;
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('周期性结算失败', ['error' => $e->getMessage()]);
            return false;
        }
    }

    /**
     * 为单个农户执行结算
     */
    protected function settleForFarmer(User $farmer)
    {
        // 上周开始和结束日期
        $startDate = Carbon::now()->subWeek()->startOfWeek();
        $endDate = Carbon::now()->startOfWeek()->subSecond();

        // 获取上周已完成的订单
        $completedOrders = Order::where('farmer_id', $farmer->id)
            ->where('status', 'completed')
            ->whereBetween('created_at', [$startDate, $endDate])
            ->get();

        if ($completedOrders->isEmpty()) {
            Log::info("农户 {$farmer->id} 本周无完成订单");
            return;
        }

        // 计算结算金额
        $totalAmount = 0;
        $items = [];

        foreach ($completedOrders as $order) {
            // 计算扣款（根据取消规则和违约情况）
            $deductions = $this->calculateDeductions($order);
            $netAmount = $order->total_amount - $deductions;

            $totalAmount += $netAmount;
            $items[] = [
                'order_id' => $order->id,
                'order_amount' => $order->total_amount,
                'deductions' => $deductions,
                'net_amount' => $netAmount,
            ];
        }

        // 创建结算记录
        $settlement = FarmerSettlement::create([
            'farmer_id' => $farmer->id,
            'settlement_date' => $startDate->toDateString(),
            'total_amount' => $totalAmount,
            'status' => 'pending',
            'settlement_notes' => "周期性结算 {$completedOrders->count()} 个订单",
        ]);

        // 创建结算项目
        foreach ($items as $item) {
            SettlementItem::create(array_merge(['settlement_id' => $settlement->id], $item));
        }

        // 记录日志
        FarmerDepositLog::create([
            'farmer_id' => $farmer->id,
            'type' => 'deduct',
            'amount' => $totalAmount,
            'reason' => "周期性结算",
            'order_id' => null,
        ]);

        Log::info("农户 {$farmer->id} 结算完成", [
            'settlement_id' => $settlement->id,
            'total_amount' => $totalAmount,
            'order_count' => $completedOrders->count(),
        ]);
    }

    /**
     * 计算订单扣款
     *
     * 扣款规则：
     * 1. 未按时交货：扣除订单金额的 10%
     * 2. 质量问题：扣除订单金额的 5-20%
     * 3. 取消订单（取货前 5h 内）：扣信用，需保证金赔偿差价
     */
    protected function calculateDeductions(Order $order)
    {
        $deductions = 0;

        // 检查是否有逾期
        if ($order->scheduled_delivery_time && $order->scheduled_delivery_time < $order->updated_at) {
            $deductions += $order->total_amount * 0.1; // 扣 10%
        }

        // 检查是否有质量问题（通过 MarketReceivingRecord）
        $receivingRecord = $order->receivingRecord ?? null;
        if ($receivingRecord) {
            if ($receivingRecord->quality_check === 'partial') {
                $deductions += $order->total_amount * 0.05; // 扣 5%
            } elseif ($receivingRecord->quality_check === 'fail') {
                $deductions += $order->total_amount * 0.2; // 扣 20%
            }
        }

        return min($deductions, $order->total_amount); // 扣款不超过订单金额
    }

    /**
     * 查询农户结算历史
     */
    public function getFarmerSettlements($farmerId, $limit = 10)
    {
        return FarmerSettlement::where('farmer_id', $farmerId)
            ->with('items')
            ->orderBy('settlement_date', 'desc')
            ->paginate($limit);
    }

    /**
     * 获取结算详情
     */
    public function getSettlementDetail($settlementId)
    {
        return FarmerSettlement::with(['items', 'items.order'])
            ->findOrFail($settlementId);
    }
}
