<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Services\CancelOrderService;
use Illuminate\Http\Request;

class CancelController extends Controller
{
    protected $cancelService;

    public function __construct(CancelOrderService $cancelService)
    {
        $this->cancelService = $cancelService;
    }

    /**
     * 查看订单取消状态
     */
    public function status(Request $request, $orderId)
    {
        try {
            $order = Order::findOrFail($orderId);

            // 验证权限
            if ($order->farmer_id !== $request->user()->id && $order->buyer_id !== $request->user()->id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized',
                ], 403);
            }

            $status = $this->cancelService->getCancelStatus($order);

            return response()->json([
                'success' => true,
                'data' => $status,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * 农户取消订单
     */
    public function cancelByFarmer(Request $request, $orderId)
    {
        $validated = $request->validate([
            'reason' => 'nullable|string|max:500',
        ]);

        try {
            $order = Order::findOrFail($orderId);

            // 验证权限
            if ($order->farmer_id !== $request->user()->id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized',
                ], 403);
            }

            // 验证订单状态
            if (!in_array($order->status, ['pending', 'confirmed'])) {
                return response()->json([
                    'success' => false,
                    'error' => '该状态订单不可取消',
                ], 422);
            }

            $result = $this->cancelService->cancelByFarmer(
                $order,
                $validated['reason'] ?? ''
            );

            if ($result['success']) {
                return response()->json($result);
            } else {
                return response()->json($result, 422);
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * 买家取消订单
     */
    public function cancelByBuyer(Request $request, $orderId)
    {
        $validated = $request->validate([
            'reason' => 'nullable|string|max:500',
        ]);

        try {
            $order = Order::findOrFail($orderId);

            // 验证权限
            if ($order->buyer_id !== $request->user()->id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized',
                ], 403);
            }

            // 验证订单状态
            if (!in_array($order->status, ['pending', 'confirmed'])) {
                return response()->json([
                    'success' => false,
                    'error' => '该状态订单不可取消',
                ], 422);
            }

            $result = $this->cancelService->cancelByBuyer(
                $order,
                $validated['reason'] ?? ''
            );

            if ($result['success']) {
                return response()->json($result);
            } else {
                return response()->json($result, 422);
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}
