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
            $table->string('logistics_id')->nullable()->after('notes')->comment('物流单号');
        });

        Schema::table('users', function (Blueprint $table) {
            $table->integer('credit_score')->default(100)->after('role')->comment('信用评分');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropColumn('logistics_id');
        });

        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('credit_score');
        });
    }
};
