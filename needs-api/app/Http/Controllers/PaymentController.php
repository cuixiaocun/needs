<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Integrations\AlipayIntegration;
use App\Integrations\HuolalaIntegration;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class PaymentController extends Controller
{
    /**
     * 创建支付宝支付链接
     */
    public function createAlipayment(Request $request)
    {
        $validated = $request->validate([
            'order_id' => 'required|exists:orders,id',
        ]);

        try {
            $order = Order::findOrFail($validated['order_id']);

            // 验证订单权限
            if ($order->buyer_id !== $request->user()->id && $order->farmer_id !== $request->user()->id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized',
                ], 403);
            }

            $alipay = new AlipayIntegration();

            $result = $alipay->createPagePayment(
                $order->id,
                $order->total_amount,
                "农产品订单 #{$order->id}",
                route('payment.alipay.return'),
                route('payment.alipay.notify')
            );

            if ($result['success']) {
                Log::info('支付宝支付链接创建成功', ['order_id' => $order->id]);
                return response()->json([
                    'success' => true,
                    'payment_url' => $result['payment_url'],
                ]);
            } else {
                return response()->json([
                    'success' => false,
                    'error' => $result['error'],
                ], 500);
            }
        } catch (\Exception $e) {
            Log::error('支付宝支付链接创建异常', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * 支付宝回调处理
     */
    public function alipayNotify(Request $request)
    {
        try {
            $alipay = new AlipayIntegration();

            if (!$alipay->verifyNotify($request->all())) {
                Log::warning('支付宝回调签名验证失败');
                return 'FAIL';
            }

            $orderId = $request->input('out_trade_no');
            $tradeStatus = $request->input('trade_status');

            $order = Order::find($orderId);
            if (!$order) {
                Log::warning('支付宝回调：订单不存在', ['order_id' => $orderId]);
                return 'FAIL';
            }

            // 处理订单状态
            if ($tradeStatus === 'TRADE_SUCCESS' || $tradeStatus === 'TRADE_FINISHED') {
                $order->update(['status' => 'confirmed']);
                Log::info('订单支付成功', ['order_id' => $orderId, 'trade_no' => $request->input('trade_no')]);
                return 'success';
            }

            return 'success';
        } catch (\Exception $e) {
            Log::error('支付宝回调处理异常', ['error' => $e->getMessage()]);
            return 'FAIL';
        }
    }

    /**
     * 获取货拉拉运费预估
     */
    public function estimateShipping(Request $request)
    {
        $validated = $request->validate([
            'from' => 'required|array', // ['lng' => 120.1, 'lat' => 30.2]
            'to' => 'required|array',
            'weight' => 'required|numeric|min:0',
            'volume' => 'nullable|numeric|min:0',
        ]);

        try {
            $huolala = new HuolalaIntegration();

            $result = $huolala->estimatePrice(
                $validated['from'],
                $validated['to'],
                $validated['weight'],
                $validated['volume'] ?? 1
            );

            if ($result['success']) {
                return response()->json([
                    'success' => true,
                    'data' => $result['data'],
                ]);
            } else {
                return response()->json([
                    'success' => false,
                    'error' => $result['error'],
                ], 500);
            }
        } catch (\Exception $e) {
            Log::error('运费预估异常', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * 创建货拉拉运输订单
     */
    public function createShippingOrder(Request $request)
    {
        $validated = $request->validate([
            'order_id' => 'required|exists:orders,id',
            'from' => 'required|array',
            'to' => 'required|array',
            'weight' => 'required|numeric|min:0',
            'volume' => 'nullable|numeric|min:0',
            'remark' => 'nullable|string',
        ]);

        try {
            $order = Order::findOrFail($validated['order_id']);

            $huolala = new HuolalaIntegration();

            $result = $huolala->createOrder(
                $order->id,
                $validated['from'],
                $validated['to'],
                [['name' => $order->product_name, 'quantity' => $order->quantity]],
                $validated['weight'],
                $validated['volume'] ?? 1,
                $validated['remark'] ?? ''
            );

            if ($result['success']) {
                // 保存物流 ID
                $order->update(['logistics_id' => $result['logistics_id']]);
                Log::info('货拉拉订单创建成功', ['order_id' => $order->id, 'logistics_id' => $result['logistics_id']]);

                return response()->json([
                    'success' => true,
                    'logistics_id' => $result['logistics_id'],
                    'data' => $result['data'],
                ]);
            } else {
                return response()->json([
                    'success' => false,
                    'error' => $result['error'],
                ], 500);
            }
        } catch (\Exception $e) {
            Log::error('货拉拉订单创建异常', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}
