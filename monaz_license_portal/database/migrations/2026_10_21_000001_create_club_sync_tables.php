<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('club_profiles', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('club_name');
            $table->string('season')->default('2026/2027');
            $table->string('admin_name')->nullable();
            $table->string('manager_name')->nullable();
            $table->string('primary_color_hex')->default('#0F48A2');
            $table->string('logo_url')->nullable();
            $table->timestamps();
        });

        Schema::create('club_devices', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('club_id')->nullable();
            $table->string('device_id')->unique();
            $table->string('device_name');
            $table->string('role')->default('field_scout'); // master_admin or field_scout
            $table->boolean('is_active')->default(true);
            $table->timestamp('last_sync_at')->nullable();
            $table->timestamps();
        });

        Schema::create('club_master_snapshots', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('club_id');
            $table->string('source_device_id');
            $table->bigInteger('version_timestamp');
            $table->json('teams_payload');
            $table->json('players_payload');
            $table->json('settings_payload')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('club_master_snapshots');
        Schema::dropIfExists('club_devices');
        Schema::dropIfExists('club_profiles');
    }
};
