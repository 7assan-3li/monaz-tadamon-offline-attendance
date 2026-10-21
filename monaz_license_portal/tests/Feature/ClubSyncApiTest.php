<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\DispatchedSession;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ClubSyncApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_register_new_club_device(): void
    {
        $response = $this->postJson('/api/sync/device/register', [
            'device_id' => 'TD-TEST-MSTR-01',
            'device_name' => 'جهاز الإدارة العامة',
            'role' => 'master_admin',
            'club_name' => 'نادي تضامن حضرموت الرياضي',
            'primary_color_hex' => '#0F48A2',
        ]);

        $response->assertStatus(200);
        $response->assertJson([
            'status' => 'success',
            'device' => [
                'device_id' => 'TD-TEST-MSTR-01',
                'device_name' => 'جهاز الإدارة العامة',
                'role' => 'master_admin',
            ],
        ]);

        $this->assertDatabaseHas('club_devices', [
            'device_id' => 'TD-TEST-MSTR-01',
            'role' => 'master_admin',
        ]);

        $this->assertDatabaseHas('club_profiles', [
            'club_name' => 'نادي تضامن حضرموت الرياضي',
        ]);
    }

    public function test_can_push_and_pull_master_data(): void
    {
        $pushPayload = [
            'source_device_id' => 'TD-TEST-MSTR-01',
            'version_timestamp' => 1700000000,
            'club_profile' => [
                'club_name' => 'نادي تضامن حضرموت الرياضي',
                'season' => '2026/2027',
                'primary_color_hex' => '#0F48A2',
                'admin_name' => 'خالد بن محفوظ',
            ],
            'teams' => [
                ['id' => 'team_1', 'name' => 'الفريق الأول', 'age_category' => 'الدرجة الأولى'],
                ['id' => 'team_2', 'name' => 'فريق الشباب', 'age_category' => 'تحت 19 سنة'],
            ],
            'players' => [
                ['id' => 'p_1', 'name' => 'أحمد علي باحاج', 'jersey_number' => 10, 'team_id' => 'team_1'],
                ['id' => 'p_2', 'name' => 'سالم محمد العمودي', 'jersey_number' => 7, 'team_id' => 'team_1'],
            ],
        ];

        // 1. Push
        $pushResponse = $this->postJson('/api/sync/master-data/push', $pushPayload);
        $pushResponse->assertStatus(201);
        $pushResponse->assertJson([
            'status' => 'success',
            'version_timestamp' => 1700000000,
        ]);

        // 2. Pull
        $pullResponse = $this->getJson('/api/sync/master-data/pull');
        $pullResponse->assertStatus(200);
        $pullResponse->assertJsonPath('data.club_profile.club_name', 'نادي تضامن حضرموت الرياضي');
        $pullResponse->assertJsonPath('data.club_profile.primary_color_hex', '#0F48A2');
        $pullResponse->assertJsonCount(2, 'data.teams');
        $pullResponse->assertJsonCount(2, 'data.players');
        $pullResponse->assertJsonPath('data.players.0.name', 'أحمد علي باحاج');
    }

    public function test_can_approve_dispatched_session(): void
    {
        $session = DispatchedSession::create([
            'session_uuid' => 'sess-test-999',
            'team_id' => 'team_1',
            'session_date' => now(),
            'source_device_id' => 'TD-FLDD-002',
            'payload' => [
                'session_uuid' => 'sess-test-999',
                'team_id' => 'team_1',
                'session_date' => now()->toDateString(),
                'absentees' => [],
            ],
            'status' => 'pending',
        ]);

        $response = $this->postJson('/api/sync/sessions/sess-test-999/approve', [
            'approver_device_id' => 'TD-MSTR-001',
        ]);

        $response->assertStatus(200);
        $response->assertJson([
            'status' => 'success',
            'session_uuid' => 'sess-test-999',
            'status_code' => 'approved',
        ]);

        $this->assertDatabaseHas('dispatched_sessions', [
            'session_uuid' => 'sess-test-999',
            'status' => 'approved',
        ]);
    }
}
