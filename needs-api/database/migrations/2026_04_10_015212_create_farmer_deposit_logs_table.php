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
        Schema::create('farmer_deposit_logs', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('farmer_id')->comment('农户ID');
            $table->enum('type', ['charge', 'deduct', 'freeze', 'unfreeze'])->comment('操作类型');
            $table->decimal('amount', 12, 2)->comment('金额');
            $table->string('reason')->nullable()->comment('原因');
            $table->unsignedBigInteger('order_id')->nullable()->comment('相关订单ID');
            $table->timestamps();

            $table->foreign('farmer_id')->references('id')->on('users')->onDelete('cascade');
            $table->index(['farmer_id', 'created_at']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('farmer_deposit_logs');
    }
};
