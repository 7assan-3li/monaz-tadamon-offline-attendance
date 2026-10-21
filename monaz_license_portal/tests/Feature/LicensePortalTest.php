<?php

declare(strict_types=1);

namespace Tests\Feature;

use Tests\TestCase;

class LicensePortalTest extends TestCase
{
    public function test_license_portal_page_is_accessible(): void
    {
        $response = $this->get('/');
        $response->assertStatus(200);
        $response->assertSee('بوابة التراخيص الرسمية');
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

        $response->assertRedirect('/');
        $this->assertDatabaseHas('club_profiles', [
            'club_name' => 'نادي تضامن حضرموت الرياضي المعتمد',
            'season' => '2026/2027',
        ]);
    }

    public function test_can_delete_registered_device(): void
    {
        // First generate
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
        $response->assertRedirect('/');

        $this->assertDatabaseMissing('club_devices', [
            'device_id' => 'TD-DELT-9999',
        ]);
    }
}
