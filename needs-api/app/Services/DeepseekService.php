<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * Deepseek AI 服务
 * 用于紧急调货时的 AI 对话
 */
class DeepseekService
{
    private string $apiKey;
    private string $baseUrl;
    private string $model = 'deepseek-chat';

    // AI 系统 Prompt
    private const SYSTEM_PROMPT = <<<'PROMPT'
你是"需求"农产品批发平台的 AI 调货助手。

背景信息：
- 平台连接农户和买家，农户在市场接收货物后统一发货
- 农户支付保证金，可享受10倍杠杆额度
- 农户可在取货前5小时内申请取消，违约扣保证金和信用

当前情况：农户申请取消订单，代理人无法及时联系。你需要帮助解决此紧急情况。

你的职责：
1. 安抚买家情绪，说明平台正在处理此事
2. 向买家解释可能的解决方案
3. 询问买家是否接受顺延（最多1次，平台补贴10%）
4. 如果无法调货，说明将退款（包括平台5%赔付）
5. 所有金额和决策最终由平台系统执行，你只负责沟通

重要约束：
- 使用简体中文，语气专业友善简洁
- 不要承诺具体金额，只说明流程
- 不要代表平台做决策，所有决策由系统执行
- 若用户询问非农业产品相关的问题，礼貌拒绝
PROMPT;

    public function __construct()
    {
        $this->apiKey = config('services.deepseek.api_key');
        $this->baseUrl = config('services.deepseek.base_url');

        if (!$this->apiKey) {
            throw new \Exception('Deepseek API Key not configured');
        }
    }

    /**
     * 发送消息给 AI，获取回复
     *
     * @param array $messages 消息历史，格式：[['role' => 'user'|'assistant', 'content' => 'xxx'], ...]
     * @return string AI 的回复文本
     * @throws \Exception
     */
    public function chat(array $messages): string
    {
        try {
            // 构建完整的消息列表
            $fullMessages = [
                [
                    'role' => 'system',
                    'content' => self::SYSTEM_PROMPT
                ]
            ];

            // 添加历史消息
            foreach ($messages as $message) {
                $fullMessages[] = [
                    'role' => $message['role'] ?? 'user',
                    'content' => $message['content'] ?? ''
                ];
            }

            Log::info('Deepseek API Request', [
                'messages_count' => count($messages),
                'model' => $this->model
            ]);

            // 调用 Deepseek API
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
                'Content-Type' => 'application/json'
            ])->post(
                $this->baseUrl . '/chat/completions',
                [
                    'model' => $this->model,
                    'messages' => $fullMessages,
                    'temperature' => 0.7,
                    'max_tokens' => 1000,
                    'top_p' => 0.95,
                    'frequency_penalty' => 0,
                    'presence_penalty' => 0
                ]
            );

            if (!$response->successful()) {
                Log::error('Deepseek API Error', [
                    'status' => $response->status(),
                    'body' => $response->body()
                ]);

                throw new \Exception('Deepseek API 返回错误：' . $response->status());
            }

            $data = $response->json();

            // 提取 AI 回复
            if (isset($data['choices'][0]['message']['content'])) {
                $reply = $data['choices'][0]['message']['content'];
                Log::info('Deepseek API Success', [
                    'reply_length' => strlen($reply)
                ]);

                return $reply;
            }

            throw new \Exception('无法解析 Deepseek API 响应');

        } catch (\Exception $e) {
            Log::error('Deepseek Service Error', [
                'message' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            throw $e;
        }
    }

    /**
     * 快速生成 AI 初始消息（用于开启对话）
     * 根据订单信息生成个性化的开场白
     *
     * @param array $orderInfo 订单信息
     * @return string AI 的初始消息
     */
    public function generateInitialMessage(array $orderInfo): string
    {
        $prompt = sprintf(
            '农户取消了订单 #%d（产品：%s，数量：%d），代理人无法联系。请生成一条简短的（50字以内）开场白来安抚买家，说明平台正在处理。',
            $orderInfo['id'] ?? 'N/A',
            $orderInfo['product'] ?? '未知',
            $orderInfo['quantity'] ?? 0
        );

        return $this->chat([
            ['role' => 'user', 'content' => $prompt]
        ]);
    }
}
