<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SessionSyncApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_dispatch_session_via_cloud_api(): void
    {
        $payload = [
            'session_uuid' => 'sess-test-cloud-101',
            'team_id' => 'team-first',
            'session_date' => '2026-10-19 16:30:00',
            'source_device_id' => 'TD-FLD1-3302',
            'absentees' => [
                ['playerId' => 'player-1', 'status' => 'excused'],
            ],
            'signature' => 'valid-ed25519-sig-proof',
        ];

        $response = $this->postJson('/api/sync/dispatch', $payload);

        $response->assertStatus(201)
            ->assertJson([
                'status' => 'success',
                'session_uuid' => 'sess-test-cloud-101',
            ]);

        $this->assertDatabaseHas('dispatched_sessions', [
            'session_uuid' => 'sess-test-cloud-101',
            'team_id' => 'team-first',
            'source_device_id' => 'TD-FLD1-3302',
        ]);
    }

    public function test_can_list_dispatched_sessions(): void
    {
        $payload = [
            'session_uuid' => 'sess-test-cloud-102',
            'team_id' => 'team-youth',
            'session_date' => '2026-10-19 17:00:00',
            'source_device_id' => 'TD-FLD1-3302',
            'absentees' => [],
            'signature' => null,
        ];

        $this->postJson('/api/sync/dispatch', $payload);

        $response = $this->getJson('/api/sync/sessions?team_id=team-youth');

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'count' => 1,
            ]);
    }

    public function test_sessions_are_strictly_isolated_between_clubs(): void
    {
        // 1. Dispatch session for Tadamon
        $this->postJson('/api/sync/dispatch', [
            'session_uuid' => 'sess-tdmn-001',
            'club_id' => 'tadamon_hadhramaut',
            'team_id' => 'team-first',
            'session_date' => '2026-10-22 10:00:00',
            'source_device_id' => 'TD-MSTR-0001',
            'absentees' => [],
        ]);

        // 2. Dispatch session for Shabab
        $this->postJson('/api/sync/dispatch', [
            'session_uuid' => 'sess-shab-001',
            'club_id' => 'shabab_almukalla',
            'team_id' => 'team-first',
            'session_date' => '2026-10-22 10:00:00',
            'source_device_id' => 'SHAB-MSTR-0001',
            'absentees' => [],
        ]);

        // 3. Query Tadamon only
        $resTadamon = $this->getJson('/api/sync/sessions?club_id=tadamon_hadhramaut');
        $resTadamon->assertStatus(200);
        $this->assertEquals(1, $resTadamon->json('count'));
        $this->assertEquals('sess-tdmn-001', $resTadamon->json('sessions.0.session_uuid'));

        // 4. Query Shabab only
        $resShabab = $this->getJson('/api/sync/sessions?club_id=shabab_almukalla');
        $resShabab->assertStatus(200);
        $this->assertEquals(1, $resShabab->json('count'));
        $this->assertEquals('sess-shab-001', $resShabab->json('sessions.0.session_uuid'));
    }
}

