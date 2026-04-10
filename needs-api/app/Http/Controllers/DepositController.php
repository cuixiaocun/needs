<?php

namespace App\Http\Controllers;

use App\Models\FarmerDeposit;
use App\Models\FarmerDepositLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

/**
 * 保证金管理控制器
 */
class DepositController extends Controller
{
    /**
     * 获取农户保证金信息
     */
    public function show(Request $request)
    {
        try {
            $deposit = FarmerDeposit::where('farmer_id', $request->user()->id)
                ->firstOrFail();

            return response()->json([
                'success' => true,
                'data' => [
                    'total_deposit' => $deposit->total_deposit,
                    'available' => $deposit->available,
                    'frozen' => $deposit->frozen,
                    'deducted' => $deposit->deducted,
                    'leverage_amount' => $deposit->leverage_amount,
                    'can_leverage' => $deposit->available * 10,
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * 充值保证金
     */
    public function recharge(Request $request)
    {
        $validated = $request->validate([
            'amount' => 'required|numeric|min:100|max:1000000',
        ]);

        try {
            DB::beginTransaction();

            $deposit = FarmerDeposit::where('farmer_id', $request->user()->id)
                ->lockForUpdate()
                ->first();

            if (!$deposit) {
                $deposit = FarmerDeposit::create([
                    'farmer_id' => $request->user()->id,
                    'total_deposit' => $validated['amount'],
                    'available' => $validated['amount'],
                ]);
            } else {
                $deposit->total_deposit += $validated['amount'];
                $deposit->available += $validated['amount'];
                $deposit->save();
            }

            // 计算 10 倍杠杆
            $leverage = min($validated['amount'] * 10, 3000); // AI 限额 3000 元
            $deposit->leverage_amount += $leverage;
            $deposit->save();

            // 记录日志
            FarmerDepositLog::create([
                'farmer_id' => $request->user()->id,
                'type' => 'charge',
                'amount' => $validated['amount'],
                'reason' => '充值保证金',
            ]);

            Log::info('农户充值成功', [
                'farmer_id' => $request->user()->id,
                'amount' => $validated['amount'],
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => '充值成功',
                'new_balance' => $deposit->available,
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('充值失败', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * 提现保证金
     */
    public function withdraw(Request $request)
    {
        $validated = $request->validate([
            'amount' => 'required|numeric|min:100|max:1000000',
        ]);

        try {
            DB::beginTransaction();

            $deposit = FarmerDeposit::where('farmer_id', $request->user()->id)
                ->lockForUpdate()
                ->firstOrFail();

            if ($deposit->available < $validated['amount']) {
                throw new \Exception('可用余额不足');
            }

            $deposit->available -= $validated['amount'];
            $deposit->total_deposit -= $validated['amount'];
            $deposit->save();

            // 记录日志
            FarmerDepositLog::create([
                'farmer_id' => $request->user()->id,
                'type' => 'charge',
                'amount' => -$validated['amount'],
                'reason' => '提现保证金',
            ]);

            Log::info('农户提现成功', [
                'farmer_id' => $request->user()->id,
                'amount' => $validated['amount'],
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => '提现申请已提交，请稍候',
                'new_balance' => $deposit->available,
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('提现失败', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 422);
        }
    }

    /**
     * 查看保证金日志
     */
    public function logs(Request $request)
    {
        try {
            $logs = FarmerDepositLog::where('farmer_id', $request->user()->id)
                ->orderBy('created_at', 'desc')
                ->paginate(20);

            return response()->json([
                'success' => true,
                'data' => $logs,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}
