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
        Schema::create('market_receiving_records', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('order_id')->comment('订单ID');
            $table->unsignedBigInteger('market_worker_id')->comment('市场工作人员ID');
            $table->decimal('received_quantity', 10, 2)->comment('收货数量');
            $table->enum('quality_check', ['pass', 'partial', 'fail'])->default('pass')->comment('质量检查');
            $table->text('notes')->nullable()->comment('备注');
            $table->timestamps();

            $table->index(['order_id']);
            $table->index(['market_worker_id', 'created_at']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('market_receiving_records');
    }
};
