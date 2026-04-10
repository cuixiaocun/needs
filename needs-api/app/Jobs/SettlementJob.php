<?php

namespace App\Jobs;

use App\Services\SettlementService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\Log;

/**
 * 周期性结算任务
 *
 * 每周一凌晨 00:05 执行
 * 统计上周已完成订单，计算保证金扣款，生成结算记录
 */
class SettlementJob implements ShouldQueue
{
    use Queueable;

    public $tries = 3;           // 失败重试次数
    public $maxExceptions = 1;   // 最多异常次数
    public $timeout = 600;       // 超时时间（秒）

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
    public function handle(SettlementService $settlementService): void
    {
        Log::info('SettlementJob 开始执行');

        try {
            $result = $settlementService->executeWeeklySettlement();

            if ($result) {
                Log::info('SettlementJob 执行成功');
            } else {
                Log::warning('SettlementJob 执行失败');
                $this->fail(new \Exception('周期性结算执行失败'));
            }
        } catch (\Exception $e) {
            Log::error('SettlementJob 异常', ['error' => $e->getMessage()]);
            $this->fail($e);
        }
    }

    /**
     * 处理失败
     */
    public function failed(\Throwable $exception)
    {
        Log::error('SettlementJob 最终失败', [
            'error' => $exception->getMessage(),
            'trace' => $exception->getTraceAsString(),
        ]);
    }
}
