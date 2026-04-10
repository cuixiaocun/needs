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
        Schema::create('settlement_items', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('settlement_id')->comment('结算记录ID');
            $table->unsignedBigInteger('order_id')->comment('订单ID');
            $table->decimal('order_amount', 12, 2)->comment('订单金额');
            $table->decimal('deductions', 12, 2)->default(0)->comment('扣款金额');
            $table->decimal('net_amount', 12, 2)->comment('净金额');
            $table->timestamps();

            $table->foreign('settlement_id')->references('id')->on('farmer_settlements')->onDelete('cascade');
            $table->index(['order_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('settlement_items');
    }
};
