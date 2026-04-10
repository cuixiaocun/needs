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
        Schema::create('farmer_settlements', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('farmer_id')->comment('农户ID');
            $table->date('settlement_date')->comment('结算日期');
            $table->decimal('total_amount', 12, 2)->default(0)->comment('结算总金额');
            $table->enum('status', ['pending', 'completed'])->default('pending')->comment('结算状态');
            $table->text('settlement_notes')->nullable()->comment('结算备注');
            $table->timestamps();

            $table->foreign('farmer_id')->references('id')->on('users')->onDelete('cascade');
            $table->index(['farmer_id', 'settlement_date']);
            $table->index(['status']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('farmer_settlements');
    }
};
