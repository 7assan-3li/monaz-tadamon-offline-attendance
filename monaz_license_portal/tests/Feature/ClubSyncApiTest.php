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

    public function test_master_data_is_strictly_isolated_between_clubs(): void
    {
        // 1. Club A (Tadamon) pushes snapshot
        $this->postJson('/api/sync/master-data/push', [
            'club_id' => 'tadamon_hadhramaut',
            'source_device_id' => 'TD-TEST-MSTR-01',
            'version_timestamp' => 1700000001,
            'club_profile' => [
                'club_name' => 'نادي تضامن حضرموت',
            ],
            'teams' => [['id' => 'tdmn_t1', 'name' => 'تضامن فريق 1']],
            'players' => [['id' => 'tdmn_p1', 'name' => 'لاعب تضامن']],
        ])->assertStatus(201);

        // 2. Club B (Shabab) pushes snapshot
        $this->postJson('/api/sync/master-data/push', [
            'club_id' => 'shabab_almukalla',
            'source_device_id' => 'SHAB-TEST-MSTR-01',
            'version_timestamp' => 1700000002,
            'club_profile' => [
                'club_name' => 'نادي شباب المكلا',
            ],
            'teams' => [['id' => 'shab_t1', 'name' => 'شباب فريق 1']],
            'players' => [['id' => 'shab_p1', 'name' => 'لاعب شباب']],
        ])->assertStatus(201);

        // 3. Pull for Tadamon
        $pullTadamon = $this->getJson('/api/sync/master-data/pull?club_id=tadamon_hadhramaut');
        $pullTadamon->assertStatus(200);
        $pullTadamon->assertJsonPath('data.club_profile.club_name', 'نادي تضامن حضرموت');
        $pullTadamon->assertJsonPath('data.players.0.name', 'لاعب تضامن');

        // 4. Pull for Shabab
        $pullShabab = $this->getJson('/api/sync/master-data/pull?club_id=shabab_almukalla');
        $pullShabab->assertStatus(200);
        $pullShabab->assertJsonPath('data.club_profile.club_name', 'نادي شباب المكلا');
        $pullShabab->assertJsonPath('data.players.0.name', 'لاعب شباب');
    }
}

