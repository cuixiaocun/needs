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
        Schema::create('emergency_dispatch_logs', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('order_id')->comment('订单ID');
            $table->unsignedBigInteger('farmer_id')->comment('原农户ID');
            $table->unsignedBigInteger('agent_id')->nullable()->comment('代理人ID');
            $table->enum('status', ['pending', 'confirmed', 'dispatched', 'completed'])->default('pending')->comment('状态');
            $table->decimal('amount', 12, 2)->comment('订单金额');
            $table->decimal('fee', 12, 2)->default(0)->comment('调货费用');
            $table->timestamp('dispatch_time')->nullable()->comment('调货时间');
            $table->timestamps();

            $table->index(['order_id']);
            $table->index(['farmer_id']);
            $table->index(['status']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('emergency_dispatch_logs');
    }
};
