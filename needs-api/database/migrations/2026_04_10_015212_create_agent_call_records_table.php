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
        Schema::create('agent_call_records', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('order_id')->comment('订单ID');
            $table->unsignedBigInteger('agent_id')->comment('代理人ID');
            $table->unsignedBigInteger('farmer_id')->comment('农户ID');
            $table->timestamp('call_start')->nullable()->comment('呼叫开始时间');
            $table->integer('call_duration')->default(0)->comment('通话时长（秒）');
            $table->enum('result', ['success', 'failed'])->comment('结果');
            $table->text('notes')->nullable()->comment('备注');
            $table->timestamps();

            $table->index(['agent_id', 'created_at']);
            $table->index(['farmer_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('agent_call_records');
    }
};
