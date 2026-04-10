<?php

namespace App\Console;

use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Console\Kernel as ConsoleKernel;
use App\Jobs\SettlementJob;
use App\Jobs\DispatchJob;

class Kernel extends ConsoleKernel
{
    /**
     * Define the application's command schedule.
     */
    protected function schedule(Schedule $schedule): void
    {
        // 每周一凌晨 00:05 执行周期性结算
        $schedule->job(new SettlementJob())
            ->weekly()
            ->mondays()
            ->at('00:05')
            ->name('settlement-weekly')
            ->withoutOverlapping()
            ->onFailure(function () {
                \Log::error('SettlementJob 定时任务执行失败');
            });

        // 每小时执行一次紧急调货超时处理
        $schedule->job(new DispatchJob())
            ->hourly()
            ->name('dispatch-timeout-check')
            ->withoutOverlapping()
            ->onFailure(function () {
                \Log::error('DispatchJob 定时任务执行失败');
            });

        // 每 5 分钟检查一次待发送的通知（可选）
        // $schedule->job(new ProcessNotificationsJob())
        //     ->everyFiveMinutes()
        //     ->name('process-notifications');

        // 每天凌晨 02:00 清理过期的临时数据
        $schedule->call(function () {
            \Log::info('执行每日数据清理');
            // 实现清理逻辑
        })
            ->dailyAt('02:00')
            ->name('cleanup-task');
    }

    /**
     * Register the commands for the application.
     */
    protected function commands(): void
    {
        $this->load(__DIR__.'/Commands');

        require base_path('routes/console.php');
    }
}
