<?php

namespace Tests\Unit\Actions;

use App\Actions\GenerateClubDualLicenseAction;
use App\Data\GenerateClubDualLicenseData;
use App\Services\Ed25519SignerService;
use DateTimeImmutable;
use Illuminate\Support\Facades\Config;
use Tests\TestCase;

final class GenerateClubDualLicenseActionTest extends TestCase
{
    public function test_it_issues_verified_paired_master_and_field_licenses(): void
    {
        $signer = new Ed25519SignerService;
        $keys = $signer->generateKeyPair();
        Config::set('licensing.ed25519_private_key', $keys['private_key']);

        $licenses = (new GenerateClubDualLicenseAction($signer))->execute(
            new GenerateClubDualLicenseData(
                clubName: 'نادي تضامن حضرموت الرياضي',
                teamName: 'الفريق الأول',
                packageType: 'SEASON',
                activatedAt: new DateTimeImmutable('2026-10-07T00:00:00Z'),
                expiresAt: new DateTimeImmutable('2027-06-30T23:59:59Z'),
                masterDeviceId: 'TD-MST1-8419',
                fieldDeviceId: 'TD-FLD1-3302',
            ),
        );

        self::assertSame('MASTER_ADMIN', $licenses['master']['payload']['role']);
        self::assertSame('FIELD_ATTENDANCE', $licenses['field']['payload']['role']);
        self::assertSame(
            $licenses['master']['payload']['local_pairing_secret'],
            $licenses['field']['payload']['local_pairing_secret'],
        );
        self::assertSame('TD-FLD1-3302', $licenses['master']['payload']['paired_device_id']);
        self::assertSame('TD-MST1-8419', $licenses['field']['payload']['paired_device_id']);

        foreach ($licenses as $license) {
            self::assertTrue($signer->verify(
                $license['payload'],
                $license['signature'],
                $keys['public_key'],
            ));

            $activationCode = strtr($license['activation_code'], '-_', '+/');
            $activationCode .= str_repeat('=', (4 - strlen($activationCode) % 4) % 4);
            $envelope = json_decode(
                base64_decode($activationCode, true),
                true,
                flags: JSON_THROW_ON_ERROR,
            );

            self::assertSame($license['payload'], $envelope['payload']);
            self::assertSame($license['signature'], $envelope['signature']);
        }
    }
}
