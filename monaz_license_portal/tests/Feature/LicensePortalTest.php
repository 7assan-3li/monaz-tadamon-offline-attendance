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
}
