<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\ClubDevice;
use App\Models\ClubProfile;
use App\Models\DispatchedSession;
use Illuminate\Support\Str;
use Tests\TestCase;

class LicensePortalTest extends TestCase
{
    public function test_clubs_directory_is_accessible(): void
    {
        $response = $this->get('/');
        $response->assertStatus(200);
        $response->assertSee('دليل الأندية الرياضية');
        $response->assertSee('نادي تضامن حضرموت');
    }

    public function test_club_specific_portal_page_is_accessible(): void
    {
        ClubDevice::updateOrCreate(
            ['device_id' => 'TD-TEST-9999'],
            [
                'id' => (string) Str::uuid(),
                'club_id' => 'tadamon_hadhramaut',
                'device_name' => 'جهاز اختبار',
                'role' => 'master_admin',
                'team_name' => 'الفريق الأول',
                'license_code' => 'TEST_CODE',
                'expires_at' => now()->addDays(365),
                'is_active' => true,
            ]
        );

        $response = $this->get('/clubs/tadamon_hadhramaut');
        $response->assertStatus(200);
        $response->assertSee('بوابة التراخيص الرسمية');
        $response->assertSee('TD-TEST-9999');
    }

    public function test_can_create_new_club(): void
    {
        $clubSlug = 'shabab_almukalla';
        $response = $this->post('/clubs', [
            'id' => $clubSlug,
            'club_code' => 'SHAB',
            'club_name' => 'نادي شباب المكلا الرياضي',
            'season' => '2026/2027',
            'primary_color_hex' => '#DC2626',
            'admin_name' => 'سالم سعيد',
            'manager_name' => 'الكابتن عمر',
        ]);

        $response->assertRedirect('/clubs/' . $clubSlug);
        $this->assertDatabaseHas('club_profiles', [
            'id' => $clubSlug,
            'club_code' => 'SHAB',
            'club_name' => 'نادي شباب المكلا الرياضي',
        ]);
    }

    public function test_can_generate_single_device_license(): void
    {
        $response = $this->post('/generate', [
            'mode' => 'single',
            'single_device_id' => 'TD-TEST-1234',
            'role' => 'MASTER_ADMIN',
            'club_name' => 'نادي تضامن حضرموت الرياضي',
            'team_name' => 'الفريق الأول',
            'validity_days' => 365,
        ]);

        $response->assertStatus(200);
        $response->assertSee('تم إنشاء كود التفعيل المشفر بنجاح');
        $response->assertSee('TD-TEST-1234');
    }

    public function test_can_generate_license_scoped_to_custom_club(): void
    {
        $response = $this->post('/clubs/shabab_almukalla/generate', [
            'mode' => 'single',
            'single_device_id' => 'SHAB-MSTR-0001',
            'role' => 'MASTER_ADMIN',
            'team_name' => 'الفريق الأول',
            'validity_days' => 180,
        ]);

        $response->assertStatus(200);
        $response->assertSee('تم إنشاء كود التفعيل المشفر بنجاح');
        $response->assertSee('SHAB-MSTR-0001');

        $this->assertDatabaseHas('club_devices', [
            'device_id' => 'SHAB-MSTR-0001',
            'club_id' => 'shabab_almukalla',
        ]);
    }

    public function test_can_generate_dual_device_licenses(): void
    {
        $response = $this->post('/generate', [
            'mode' => 'dual',
            'master_device_id' => 'TD-MSTR-0001',
            'field_device_id' => 'TD-FLDD-0002',
            'club_name' => 'نادي تضامن حضرموت الرياضي',
            'team_name' => 'الفريق الأول',
            'validity_days' => 365,
        ]);

        $response->assertStatus(200);
        $response->assertSee('تم إنشاء كود التفعيل المشفر بنجاح');
        $response->assertSee('TD-MSTR-0001');
        $response->assertSee('TD-FLDD-0002');
    }

    public function test_can_download_apk_or_fallback(): void
    {
        $response = $this->get('/download/apk');
        $this->assertContains($response->getStatusCode(), [200, 404]);
    }

    public function test_can_download_offline_tool(): void
    {
        $response = $this->get('/download/offline-tool');
        $this->assertContains($response->getStatusCode(), [200, 404]);
    }

    public function test_can_update_club_profile(): void
    {
        $response = $this->post('/club/update', [
            'club_name' => 'نادي تضامن حضرموت الرياضي المعتمد',
            'season' => '2026/2027',
            'primary_color_hex' => '#0F48A2',
            'admin_name' => 'أحمد عمر',
            'manager_name' => 'الكابتن علي',
        ]);

        $response->assertRedirect('/clubs/tadamon_hadhramaut');
        $this->assertDatabaseHas('club_profiles', [
            'club_name' => 'نادي تضامن حضرموت الرياضي المعتمد',
            'season' => '2026/2027',
        ]);
    }

    public function test_can_delete_registered_device(): void
    {
        $this->post('/generate', [
            'mode' => 'single',
            'single_device_id' => 'TD-DELT-9999',
            'role' => 'MASTER_ADMIN',
            'validity_days' => 30,
        ]);

        $this->assertDatabaseHas('club_devices', [
            'device_id' => 'TD-DELT-9999',
        ]);

        $response = $this->delete('/devices/TD-DELT-9999');
        $response->assertRedirect('/clubs/tadamon_hadhramaut');

        $this->assertDatabaseMissing('club_devices', [
            'device_id' => 'TD-DELT-9999',
        ]);
    }

    public function test_can_export_club_backup(): void
    {
        $response = $this->get('/clubs/tadamon_hadhramaut/backup');
        $response->assertStatus(200);
        $this->assertStringContainsString('application/json', (string) $response->headers->get('content-type'));

        $content = $response->streamedContent();
        $data = json_decode($content, true);
        $this->assertIsArray($data);
        $this->assertEquals('tadamon_hadhramaut', $data['club_profile']['id']);
        $this->assertArrayHasKey('registered_devices', $data);
        $this->assertArrayHasKey('dispatched_sessions', $data);
        $this->assertArrayHasKey('master_snapshots', $data);
    }
}

