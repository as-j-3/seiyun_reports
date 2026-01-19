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
        Schema::create('reports', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');
            $table->unsignedBigInteger('area_id');
            $table->text('description')->nullable(); // وصف البلاغ
            $table->string('image')->nullable(); // صورة البلاغ
            $table->enum('status', ['قيد الانتظار','قيد المعالجة','تم الحل'])->default('قيد الانتظار');
            $table->enum('report_type', ['كنس','رفع','لوائح غير لائقة']);
            $table->decimal('lat' ,10, 8);
            $table->decimal('lng',11,8);
            $table->timestamps();
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('area_id')->references('id')->on('areas')->onDelete('cascade');


        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('reports');
    }
};
