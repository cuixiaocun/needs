<?php

namespace App\Jobs;

use App\Services\DispatchService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\Log;

/**
 * 紧急调货处理任务
 *
 * 每小时执行一次，检查：
 * 1. 是否有超时的调货（3 小时未确认）
 * 2. 处理超时订单的赔偿逻辑
 */
class DispatchJob implements ShouldQueue
{
    use Queueable;

    public $tries = 3;
    public $maxExceptions = 1;
    public $timeout = 300;

    /**
     * Create a new job instance.
     */
    public function __construct()
    {
        $this->onQueue('default');
    }

    /**
     * Execute the job.
     */
    public function handle(DispatchService $dispatchService): void
    {
        Log::info('DispatchJob 开始执行');

        try {
            $result = $dispatchService->handleDispatchTimeout();

            if ($result['success']) {
                Log::info('DispatchJob 执行成功', $result);
            } else {
                Log::warning('DispatchJob 执行失败', $result);
                $this->fail(new \Exception($result['error']));
            }
        } catch (\Exception $e) {
            Log::error('DispatchJob 异常', ['error' => $e->getMessage()]);
            $this->fail($e);
        }
    }

    /**
     * 处理失败
     */
    public function failed(\Throwable $exception)
    {
        Log::error('DispatchJob 最终失败', [
            'error' => $exception->getMessage(),
            'trace' => $exception->getTraceAsString(),
        ]);
    }
}
