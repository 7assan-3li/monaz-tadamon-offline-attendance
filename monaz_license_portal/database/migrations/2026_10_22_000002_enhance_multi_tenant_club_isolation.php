<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 1. Enhance club_profiles with club_code and is_active
        Schema::table('club_profiles', function (Blueprint $table) {
            if (!Schema::hasColumn('club_profiles', 'club_code')) {
                $table->string('club_code', 10)->nullable()->after('id');
            }
            if (!Schema::hasColumn('club_profiles', 'is_active')) {
                $table->boolean('is_active')->default(true)->after('logo_url');
            }
        });

        // Ensure default club has a club_code
        DB::table('club_profiles')
            ->where('id', 'tadamon_hadhramaut')
            ->whereNull('club_code')
            ->update(['club_code' => 'TDMN']);

        // 2. Enhance dispatched_sessions with club_id for strict isolation
        Schema::table('dispatched_sessions', function (Blueprint $table) {
            if (!Schema::hasColumn('dispatched_sessions', 'club_id')) {
                $table->string('club_id', 50)->nullable()->after('session_uuid');
            }
        });

        // Backfill any existing sessions without club_id to tadamon_hadhramaut
        DB::table('dispatched_sessions')
            ->whereNull('club_id')
            ->update(['club_id' => 'tadamon_hadhramaut']);
    }

    public function down(): void
    {
        Schema::table('dispatched_sessions', function (Blueprint $table) {
            if (Schema::hasColumn('dispatched_sessions', 'club_id')) {
                $table->dropColumn('club_id');
            }
        });

        Schema::table('club_profiles', function (Blueprint $table) {
            if (Schema::hasColumn('club_profiles', 'club_code')) {
                $table->dropColumn('club_code');
            }
            if (Schema::hasColumn('club_profiles', 'is_active')) {
                $table->dropColumn('is_active');
            }
        });
    }
};
