<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Services\DeepseekService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

/**
 * AI 对话控制器
 * 处理紧急调货时的 AI 协商对话
 */
class AiChatController extends Controller
{
    private DeepseekService $deepseekService;

    public function __construct(DeepseekService $deepseekService)
    {
        $this->deepseekService = $deepseekService;
    }

    /**
     * 与 AI 对话
     *
     * POST /api/ai/chat
     *
     * 请求体：
     * {
     *     "order_id": 123,
     *     "message": "你好，我需要调货",
     *     "history": [
     *         {"role": "assistant", "content": "..."},
     *         {"role": "user", "content": "..."}
     *     ]
     * }
     *
     * 响应：
     * {
     *     "success": true,
     *     "data": {
     *         "order_id": 123,
     *         "reply": "AI 的回复内容"
     *     }
     * }
     */
    public function chat(Request $request)
    {
        try {
            // 验证请求
            $validated = $request->validate([
                'order_id' => 'required|integer|exists:orders,id',
                'message' => 'required|string|max:500',
                'history' => 'nullable|array|max:20'
            ]);

            // 验证订单所有权（确保用户只能访问自己的订单）
            $order = Order::findOrFail($validated['order_id']);
            $user = auth()->user();

            // 买家或农户都可以与 AI 对话
            if (
                $order->buyer_id !== $user->id &&
                $order->farmer_id !== $user->id
            ) {
                return response()->json([
                    'success' => false,
                    'message' => '无权访问此订单'
                ], 403);
            }

            Log::info('AI Chat Request', [
                'user_id' => $user->id,
                'order_id' => $validated['order_id'],
                'message_length' => strlen($validated['message'])
            ]);

            // 构建消息列表
            $messages = [];

            // 添加历史消息
            if (!empty($validated['history'])) {
                foreach ($validated['history'] as $msg) {
                    if (isset($msg['role']) && isset($msg['content'])) {
                        $messages[] = [
                            'role' => $msg['role'],
                            'content' => $msg['content']
                        ];
                    }
                }
            }

            // 添加当前消息
            $messages[] = [
                'role' => 'user',
                'content' => $validated['message']
            ];

            // 调用 Deepseek AI
            $reply = $this->deepseekService->chat($messages);

            Log::info('AI Chat Response', [
                'order_id' => $validated['order_id'],
                'reply_length' => strlen($reply)
            ]);

            return response()->json([
                'success' => true,
                'data' => [
                    'order_id' => $validated['order_id'],
                    'reply' => $reply,
                    'timestamp' => now()->toIso8601String()
                ]
            ]);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => '请求参数错误',
                'errors' => $e->errors()
            ], 422);

        } catch (\Exception $e) {
            Log::error('AI Chat Error', [
                'message' => $e->getMessage(),
                'order_id' => $validated['order_id'] ?? null
            ]);

            return response()->json([
                'success' => false,
                'message' => 'AI 服务暂时不可用，请稍后重试'
            ], 500);
        }
    }

    /**
     * 获取 AI 调货状态
     *
     * GET /api/ai/status/{orderId}
     *
     * 响应：
     * {
     *     "success": true,
     *     "data": {
     *         "order_id": 123,
     *         "status": "pending|success|failed",
     *         "message": "调货状态说明"
     *     }
     * }
     */
    public function getStatus(Request $request, $orderId)
    {
        try {
            $order = Order::findOrFail($orderId);
            $user = auth()->user();

            // 验证权限
            if (
                $order->buyer_id !== $user->id &&
                $order->farmer_id !== $user->id
            ) {
                return response()->json([
                    'success' => false,
                    'message' => '无权访问此订单'
                ], 403);
            }

            // 检查订单状态
            $status = 'pending';
            $message = '平台正在处理...';

            if ($order->status === 'completed') {
                $status = 'success';
                $message = '订单已完成';
            } elseif ($order->status === 'cancelled') {
                $status = 'failed';
                $message = '订单已取消，将进行退款';
            }

            return response()->json([
                'success' => true,
                'data' => [
                    'order_id' => $orderId,
                    'status' => $status,
                    'message' => $message,
                    'order_status' => $order->status
                ]
            ]);

        } catch (\Exception $e) {
            Log::error('Get AI Status Error', [
                'message' => $e->getMessage(),
                'order_id' => $orderId
            ]);

            return response()->json([
                'success' => false,
                'message' => '获取状态失败'
            ], 500);
        }
    }
}
