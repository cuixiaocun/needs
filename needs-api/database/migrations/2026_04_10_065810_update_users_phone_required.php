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
        Schema::table('users', function (Blueprint $table) {
            // 将 email 改为可选
            $table->string('email')->nullable()->change();
            // 将 phone 改为非空且唯一
            $table->string('phone')->unique()->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // 恢复 email 为必填
            $table->string('email')->nullable(false)->change();
            // 恢复 phone 为可选
            $table->string('phone')->nullable()->change();
            $table->dropUnique(['phone']);
        });
    }
};
