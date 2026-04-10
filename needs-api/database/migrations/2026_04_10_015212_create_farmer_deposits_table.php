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
        Schema::create('farmer_deposits', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('farmer_id')->unique()->comment('农户ID');
            $table->decimal('total_deposit', 12, 2)->default(0)->comment('充值总额');
            $table->decimal('available', 12, 2)->default(0)->comment('可用余额');
            $table->decimal('frozen', 12, 2)->default(0)->comment('已冻结');
            $table->decimal('deducted', 12, 2)->default(0)->comment('已扣除');
            $table->decimal('leverage_amount', 15, 2)->default(0)->comment('10倍杠杆额度');
            $table->timestamps();

            $table->foreign('farmer_id')->references('id')->on('users')->onDelete('cascade');
            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('farmer_deposits');
    }
};
