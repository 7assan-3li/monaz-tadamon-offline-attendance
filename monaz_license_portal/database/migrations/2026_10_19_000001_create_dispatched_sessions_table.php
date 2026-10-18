<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('dispatched_sessions', function (Blueprint $table) {
            $table->string('session_uuid')->primary();
            $table->string('team_id');
            $table->dateTime('session_date');
            $table->string('source_device_id');
            $table->json('payload');
            $table->string('signature')->nullable();
            $table->string('status')->default('pending');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('dispatched_sessions');
    }
};
