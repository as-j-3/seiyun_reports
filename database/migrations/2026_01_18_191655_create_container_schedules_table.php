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
        Schema::create('container_schedules', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('container_id');
            $table->enum('collection_day', [
                'daily',        // يوميًا
                'alternate',    // يوم بعد يوم
                'sunday',
                'monday',
                'tuesday',
                'wednesday',
                'thursday',
                'friday',
                'saturday'
            ]);
            $table->time('start_time');
            $table->integer('transfer_count')->default(1); // معدل النقل (كم مرة باليوم)
            $table->timestamps();

            $table->foreign('container_id')->references('id')->on('containers_locations')->onDelete('cascade');

        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('container_schedules');
    }
};
