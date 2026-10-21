<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('club_devices', function (Blueprint $table) {
            if (!Schema::hasColumn('club_devices', 'team_name')) {
                $table->string('team_name')->nullable()->after('role');
            }
            if (!Schema::hasColumn('club_devices', 'license_code')) {
                $table->text('license_code')->nullable()->after('team_name');
            }
            if (!Schema::hasColumn('club_devices', 'expires_at')) {
                $table->timestamp('expires_at')->nullable()->after('license_code');
            }
        });
    }

    public function down(): void
    {
        Schema::table('club_devices', function (Blueprint $table) {
            $table->dropColumn(['team_name', 'license_code', 'expires_at']);
        });
    }
};
