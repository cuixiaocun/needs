<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Services\MatchingService;
use Illuminate\Http\Request;

class MatchingController extends Controller
{
    protected $matchingService;

    public function __construct(MatchingService $matchingService)
    {
        $this->matchingService = $matchingService;
    }

    /**
     * 获取订单的推荐匹配列表
     */
    public function getRecommendations(Request $request, $orderId)
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

            $recommendations = $this->matchingService->getRecommendations($order, 5);

            return response()->json([
                'success' => true,
                'data' => $recommendations,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * 手动匹配两个订单
     */
    public function match(Request $request)
    {
        $validated = $request->validate([
            'buyer_order_id' => 'required|exists:orders,id',
            'farmer_order_id' => 'required|exists:orders,id',
        ]);

        try {
            $buyerOrder = Order::findOrFail($validated['buyer_order_id']);
            $farmerOrder = Order::findOrFail($validated['farmer_order_id']);

            // 验证权限（至少有一个是当前用户）
            $userId = $request->user()->id;
            if ($buyerOrder->buyer_id !== $userId && $buyerOrder->farmer_id !== $userId &&
                $farmerOrder->buyer_id !== $userId && $farmerOrder->farmer_id !== $userId) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized',
                ], 403);
            }

            $result = $this->matchingService->manualMatch($buyerOrder, $farmerOrder);

            if ($result['success']) {
                return response()->json([
                    'success' => true,
                    'message' => $result['message'],
                ]);
            } else {
                return response()->json([
                    'success' => false,
                    'error' => $result['error'],
                ], 422);
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * 尝试自动撮合订单
     */
    public function autoMatch(Request $request, $orderId)
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

            // 先尝试精确匹配
            $match = $this->matchingService->exactMatch($order);

            if ($match) {
                return response()->json([
                    'success' => true,
                    'type' => 'exact_match',
                    'matched_order' => $match,
                    'message' => '订单已自动撮合',
                ]);
            }

            // 再尝试模糊匹配（返回候选列表）
            $candidates = $this->matchingService->fuzzyMatch($order, 5);

            if ($candidates->isNotEmpty()) {
                return response()->json([
                    'success' => true,
                    'type' => 'fuzzy_match',
                    'candidates' => $candidates,
                    'message' => '找到可能的匹配订单',
                ]);
            } else {
                return response()->json([
                    'success' => false,
                    'message' => '暂未找到匹配订单',
                ]);
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}
