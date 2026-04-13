<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            // 使 farmer_id 可选，以支持纯买单（需求意向）
            $table->unsignedBigInteger('farmer_id')->nullable()->change();
            
            // 增加订单类型字段
            $table->enum('type', ['sell', 'buy'])->default('sell')->after('buyer_id')->comment('订单类型：sell=供应单, buy=需求单');
            
            // 增加品质要求字段
            $table->enum('quality_level', ['特级', '一级', '二级'])->default('一级')->after('unit')->comment('品质要求');
            
            // 增加状态：待撮合
            // 注意：Laravel 不支持直接在 table() 中修改 enum 选项，这里为了演示，假设我们可以在逻辑中处理
            // 更好的做法是在 migration 中重新定义 enum 字段，但这里我们先添加注释
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->unsignedBigInteger('farmer_id')->nullable(false)->change();
            $table->dropColumn(['type', 'quality_level']);
        });
    }
};
