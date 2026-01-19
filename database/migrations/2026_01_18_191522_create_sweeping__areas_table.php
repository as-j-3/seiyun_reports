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
        Schema::create('sweeping_areas', function (Blueprint $table) {
            $table->id();
            $table->string('square_name'); // اسم المربع
            $table->unsignedBigInteger('area_id'); // ربط بالمنطقة
            $table->string('name_start_street');
            $table->string('name_end_street');
            $table->decimal('start_lat', 10, 8);
            $table->decimal('start_lng', 11, 8); 
            $table->decimal('end_lat', 10, 8);   
            $table->decimal('end_lng', 11, 8);  
            $table->timestamps();
        
            $table->foreign('area_id')->references('id')->on('areas')->onDelete('cascade');
        
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('sweeping__areas');
    }
};
