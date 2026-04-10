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
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('farmer_id')->comment('农户ID');
            $table->unsignedBigInteger('buyer_id')->nullable()->comment('买家ID');
            $table->string('product_name')->comment('产品名称');
            $table->decimal('quantity', 10, 2)->comment('订单数量');
            $table->string('unit')->comment('计量单位');
            $table->decimal('price_per_unit', 10, 2)->comment('单价');
            $table->decimal('total_amount', 12, 2)->comment('订单总金额');
            $table->enum('status', ['pending', 'confirmed', 'receiving', 'received', 'dispatched', 'completed', 'cancelled'])->default('pending')->comment('订单状态');
            $table->timestamp('scheduled_delivery_time')->nullable()->comment('预计交货时间');
            $table->text('notes')->nullable()->comment('备注');
            $table->timestamps();

            $table->foreign('farmer_id')->references('id')->on('users')->onDelete('cascade');
            $table->index(['status']);
            $table->index(['farmer_id']);
            $table->index(['buyer_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};
