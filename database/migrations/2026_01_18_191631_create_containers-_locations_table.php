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
        Schema::create('containers_locations', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('area_id');
            $table->string('location_name'); 
            $table->string('name_street');
            $table->enum('classification', ['رئيسي', 'ثانوي']); // التصنيف (رئيسي/ثانوي)
            $table->decimal('lat' ,10, 8);
            $table->decimal('lng',11,8);
            $table->timestamps();

            $table->foreign('area_id')->references('id')->on('areas')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('containers-_locations');
    }
};
