<?php

namespace App\Jobs;

use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\Log;

/**
 * 推送通知任务
 *
 * 用于发送以下通知：
 * 1. 订单确认通知
 * 2. 订单完成通知
 * 3. 支付成功通知
 * 4. 紧急调货通知
 * 5. 保证金扣款通知
 */
class NotificationJob implements ShouldQueue
{
    use Queueable;

    public $tries = 3;
    public $maxExceptions = 1;
    public $timeout = 60;

    protected $userId;
    protected $type;
    protected $data;

    /**
     * Create a new job instance.
     */
    public function __construct($userId, $type, $data = [])
    {
        $this->userId = $userId;
        $this->type = $type;
        $this->data = $data;
        $this->onQueue('notifications');
    }

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        Log::info('NotificationJob 开始执行', [
            'user_id' => $this->userId,
            'type' => $this->type,
        ]);

        try {
            // 根据通知类型发送不同的通知
            match ($this->type) {
                'order_confirmed' => $this->sendOrderConfirmed(),
                'order_completed' => $this->sendOrderCompleted(),
                'payment_success' => $this->sendPaymentSuccess(),
                'dispatch_initiated' => $this->sendDispatchInitiated(),
                'deposit_deducted' => $this->sendDepositDeducted(),
                default => Log::warning('未知的通知类型', ['type' => $this->type]),
            };

            Log::info('NotificationJob 执行成功');
        } catch (\Exception $e) {
            Log::error('NotificationJob 异常', ['error' => $e->getMessage()]);
            $this->fail($e);
        }
    }

    /**
     * 订单已确认通知
     */
    protected function sendOrderConfirmed()
    {
        Log::info('发送订单确认通知', [
            'user_id' => $this->userId,
            'order_id' => $this->data['order_id'] ?? null,
        ]);
        // TODO: 集成推送服务（极光推送等）
    }

    /**
     * 订单已完成通知
     */
    protected function sendOrderCompleted()
    {
        Log::info('发送订单完成通知', [
            'user_id' => $this->userId,
            'order_id' => $this->data['order_id'] ?? null,
        ]);
    }

    /**
     * 支付成功通知
     */
    protected function sendPaymentSuccess()
    {
        Log::info('发送支付成功通知', [
            'user_id' => $this->userId,
            'order_id' => $this->data['order_id'] ?? null,
        ]);
    }

    /**
     * 紧急调货通知
     */
    protected function sendDispatchInitiated()
    {
        Log::info('发送紧急调货通知', [
            'user_id' => $this->userId,
            'dispatch_id' => $this->data['dispatch_id'] ?? null,
        ]);
    }

    /**
     * 保证金扣款通知
     */
    protected function sendDepositDeducted()
    {
        Log::info('发送保证金扣款通知', [
            'user_id' => $this->userId,
            'amount' => $this->data['amount'] ?? 0,
            'reason' => $this->data['reason'] ?? '',
        ]);
    }

    /**
     * 处理失败
     */
    public function failed(\Throwable $exception)
    {
        Log::error('NotificationJob 最终失败', [
            'user_id' => $this->userId,
            'type' => $this->type,
            'error' => $exception->getMessage(),
        ]);
    }
}
