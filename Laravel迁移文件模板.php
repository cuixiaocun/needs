<?php

/**
 * Laravel 迁移文件模板
 * 将以下代码复制到对应的迁移文件中
 * 位置: database/migrations/
 */

// ====================================================
// 表 1: 农户保证金账户
// ====================================================

// database/migrations/2024_04_10_create_farmer_deposits_table.php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('farmer_deposits', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('farmer_id')->unique()->comment('农户 ID');
            $table->decimal('total_deposit', 12, 2)->default(0)->comment('充值总额');
            $table->decimal('available', 12, 2)->default(0)->comment('可用余额');
            $table->decimal('frozen', 12, 2)->default(0)->comment('已冻结（订单占用）');
            $table->decimal('deducted', 12, 2)->default(0)->comment('已扣除（违约）');
            $table->decimal('leverage_amount', 15, 2)->default(0)->comment('10倍杠杆可用额度');
            $table->timestamps();

            $table->foreign('farmer_id')->references('id')->on('users')->onDelete('cascade');
            $table->index('created_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('farmer_deposits');
    }
};

// ====================================================
// 表 2: 保证金流水
// ====================================================

// database/migrations/2024_04_10_create_farmer_deposit_logs_table.php
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('farmer_deposit_logs', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('farmer_id')->comment('农户 ID');
            $table->enum('type', ['充值', '冻结', '解冻', '扣除', '提现'])->comment('流水类型');
            $table->decimal('amount', 12, 2)->comment('流水金额');
            $table->unsignedBigInteger('order_id')->nullable()->comment('关联订单 ID');
            $table->string('reason')->nullable()->comment('原因说明');
            $table->decimal('balance_before', 12, 2)->nullable()->comment('交易前余额');
            $table->decimal('balance_after', 12, 2)->nullable()->comment('交易后余额');
            $table->timestamps();

            $table->foreign('farmer_id')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('order_id')->references('id')->on('orders')->onDelete('set null');
            $table->index('farmer_id');
            $table->index('order_id');
            $table->index('created_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('farmer_deposit_logs');
    }
};

// ====================================================
// 表 3: 紧急调货日志
// ====================================================

// database/migrations/2024_04_10_create_emergency_dispatch_logs_table.php
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('emergency_dispatch_logs', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('original_order_id')->comment('原订单 ID');
            $table->unsignedBigInteger('original_farmer_id')->comment('原农户 ID');
            $table->unsignedBigInteger('buyer_id')->comment('买家 ID');
            $table->string('cancel_reason')->nullable()->comment('取消原因');

            // 买家选择
            $table->enum('buyer_choice', ['按原时间', '顺延次日', '直接退款'])->comment('买家选择');

            // 第一段：代理人呼叫
            $table->timestamp('stage_1_start_time')->nullable()->comment('第一段开始时间');
            $table->unsignedBigInteger('stage_1_agent_id')->nullable()->comment('接单代理人 ID');
            $table->timestamp('stage_1_end_time')->nullable()->comment('第一段结束时间');
            $table->enum('stage_1_result', ['成功', '失败', ''])->default('')->comment('第一段结果');

            // 第二段：AI 调货
            $table->enum('stage_2_ai_result', ['成功', '失败', ''])->default('')->comment('第二段 AI 结果');

            // 替代订单信息
            $table->unsignedBigInteger('replacement_order_id')->nullable()->comment('替代订单 ID');
            $table->unsignedBigInteger('replacement_farmer_id')->nullable()->comment('替代农户 ID');

            // 最终状态
            $table->enum('final_status', ['进行中', '已完成', '已退款', '自动取消'])->default('进行中')->comment('最终状态');

            $table->timestamps();

            $table->foreign('original_order_id')->references('id')->on('orders')->onDelete('cascade');
            $table->foreign('original_farmer_id')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('buyer_id')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('replacement_order_id')->references('id')->on('orders')->onDelete('set null');
            $table->foreign('stage_1_agent_id')->references('id')->on('users')->onDelete('set null');

            $table->index('original_order_id');
            $table->index('final_status');
            $table->index('created_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('emergency_dispatch_logs');
    }
};

// ====================================================
// 表 4: 代理人呼叫记录
// ====================================================

// database/migrations/2024_04_10_create_agent_call_records_table.php
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('agent_call_records', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('dispatch_log_id')->comment('紧急调货 ID');
            $table->unsignedBigInteger('agent_id')->comment('代理人 ID');
            $table->unsignedBigInteger('farmer_id')->comment('农户 ID');
            $table->string('farmer_phone')->nullable()->comment('农户电话');

            // 呼叫信息
            $table->timestamp('called_at')->nullable()->comment('拨打时间');
            $table->integer('call_duration')->default(0)->comment('通话时长（秒）');
            $table->enum('status', ['接通', '未接', '拒接', '其他'])->default('未接')->comment('呼叫状态');
            $table->integer('ringing_duration')->default(0)->comment('响铃时长（秒）');

            $table->timestamps();

            $table->foreign('dispatch_log_id')->references('id')->on('emergency_dispatch_logs')->onDelete('cascade');
            $table->foreign('agent_id')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('farmer_id')->references('id')->on('users')->onDelete('cascade');

            $table->index('dispatch_log_id');
            $table->index('agent_id');
            $table->index('farmer_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('agent_call_records');
    }
};

// ====================================================
// 表 5: 市场收货记录
// ====================================================

// database/migrations/2024_04_10_create_market_receiving_records_table.php
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('market_receiving_records', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('order_id')->comment('订单 ID');
            $table->unsignedBigInteger('farmer_id')->comment('农户 ID');
            $table->unsignedBigInteger('worker_id')->comment('市场工作人员 ID');

            // 时间信息
            $table->timestamp('received_at')->useCurrent()->comment('收货时间');

            // 重量信息
            $table->integer('reported_weight')->comment('农户报告重量（KG）');
            $table->integer('actual_weight')->comment('实际过磅重量（KG）');
            $table->decimal('weight_variance', 5, 2)->nullable()->comment('重量差异百分比');

            // 等级信息
            $table->enum('reported_grade', ['特级', '一级', '二级'])->nullable()->comment('农户自报等级');
            $table->enum('actual_grade', ['特级', '一级', '二级'])->nullable()->comment('工作人员判定等级');

            // 收货结果
            $table->enum('result', ['符合', '降级', '拒收'])->comment('收货结果');
            $table->integer('downgrade_level')->nullable()->comment('降级档次数（如 1 = 一级→二级）');

            // 证据
            $table->json('photos')->nullable()->comment('3 张照片 URL');
            $table->text('remarks')->nullable()->comment('备注');

            $table->timestamps();

            $table->foreign('order_id')->references('id')->on('orders')->onDelete('cascade');
            $table->foreign('farmer_id')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('worker_id')->references('id')->on('users')->onDelete('set null');

            $table->index('order_id');
            $table->index('farmer_id');
            $table->index('worker_id');
            $table->index('result');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('market_receiving_records');
    }
};

// ====================================================
// 表 6: 市场出货记录
// ====================================================

// database/migrations/2024_04_10_create_market_dispatch_records_table.php
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('market_dispatch_records', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('order_id')->comment('订单 ID');
            $table->unsignedBigInteger('buyer_id')->comment('买家 ID');

            // 出货类型
            $table->enum('dispatch_type', ['自提', '代运'])->comment('交付方式');

            // 自提信息
            $table->string('pickup_code')->nullable()->comment('4 位提货码');
            $table->timestamp('self_pickup_at')->nullable()->comment('自提时间');
            $table->unsignedBigInteger('pickup_worker_id')->nullable()->comment('核验工作人员 ID');

            // 代运信息
            $table->string('hauling_order_id')->nullable()->comment('货拉拉订单号');
            $table->enum('hauling_status', ['待接单', '已接单', '已取货', '运输中', '已送达', '已取消'])->default('待接单')->comment('代运状态');
            $table->string('hauling_driver_phone')->nullable()->comment('司机电话');
            $table->timestamp('signed_at')->nullable()->comment('签收时间');

            $table->timestamps();

            $table->foreign('order_id')->references('id')->on('orders')->onDelete('cascade');
            $table->foreign('buyer_id')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('pickup_worker_id')->references('id')->on('users')->onDelete('set null');

            $table->index('order_id');
            $table->index('buyer_id');
            $table->index('dispatch_type');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('market_dispatch_records');
    }
};

// ====================================================
// 表 7: 农户结算单
// ====================================================

// database/migrations/2024_04_10_create_farmer_settlements_table.php
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('farmer_settlements', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('farmer_id')->comment('农户 ID');
            $table->date('settlement_date')->comment('结算周期（本周一）');

            // 订单汇总
            $table->integer('total_orders')->comment('该周订单数');
            $table->decimal('total_revenue', 15, 2)->comment('总收入');
            $table->decimal('total_deductions', 15, 2)->default(0)->comment('总扣款');
            $table->decimal('net_amount', 15, 2)->comment('实付金额');

            // 结算状态
            $table->enum('status', ['待结算', '已支付', '已驳回'])->default('待结算')->comment('结算状态');

            // 支付信息
            $table->enum('payment_method', ['支付宝', '微信', '银行转账', '其他'])->nullable()->comment('支付方式');
            $table->string('payment_account')->nullable()->comment('收款账户');
            $table->timestamp('paid_at')->nullable()->comment('支付时间');
            $table->string('transaction_id')->nullable()->comment('支付宝/微信交易号');

            $table->text('remark')->nullable()->comment('备注');

            $table->timestamps();

            $table->foreign('farmer_id')->references('id')->on('users')->onDelete('cascade');
            $table->unique(['farmer_id', 'settlement_date']);
            $table->index('status');
            $table->index('settlement_date');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('farmer_settlements');
    }
};

// ====================================================
// 表 8: 结算单明细
// ====================================================

// database/migrations/2024_04_10_create_settlement_items_table.php
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('settlement_items', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('settlement_id')->comment('结算单 ID');
            $table->unsignedBigInteger('order_id')->comment('订单 ID');

            // 金额信息
            $table->decimal('order_amount', 15, 2)->nullable()->comment('订单金额');

            // 扣款类型
            $table->enum('deduction_type', ['降级差价', '损耗', '保证金扣除', '其他'])->nullable()->comment('扣款类型');
            $table->decimal('deduction_amount', 12, 2)->nullable()->comment('扣款金额');

            $table->decimal('final_amount', 15, 2)->nullable()->comment('最终金额');

            $table->timestamps();

            $table->foreign('settlement_id')->references('id')->on('farmer_settlements')->onDelete('cascade');
            $table->foreign('order_id')->references('id')->on('orders')->onDelete('cascade');

            $table->index('settlement_id');
            $table->index('order_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('settlement_items');
    }
};

// ====================================================
// 订单表扩展字段（修改现有 orders 表）
// ====================================================

// database/migrations/2024_04_10_extend_orders_table.php
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->enum('dispatch_type', ['自提', '代运'])->nullable()->comment('交付方式');
            $table->unsignedBigInteger('emergency_dispatch_id')->nullable()->comment('紧急调货 ID');
            $table->unsignedBigInteger('market_dispatch_id')->nullable()->comment('市场出货记录 ID');
            $table->timestamp('farmer_settled_at')->nullable()->comment('农户结算时间');

            $table->foreign('emergency_dispatch_id')->references('id')->on('emergency_dispatch_logs')->onDelete('set null');
            $table->foreign('market_dispatch_id')->references('id')->on('market_dispatch_records')->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropForeign(['emergency_dispatch_id']);
            $table->dropForeign(['market_dispatch_id']);
            $table->dropColumn(['dispatch_type', 'emergency_dispatch_id', 'market_dispatch_id', 'farmer_settled_at']);
        });
    }
};

// ====================================================
// 使用说明
// ====================================================

/*
1. 复制以上代码到对应的迁移文件中

2. 执行迁移：
   php artisan migrate

3. 验证表创建：
   php artisan tinker
   >>> Schema::getTables()  // 应该看到 8 个新表

4. 查看表结构：
   mysql> DESCRIBE farmer_deposits;
*/
