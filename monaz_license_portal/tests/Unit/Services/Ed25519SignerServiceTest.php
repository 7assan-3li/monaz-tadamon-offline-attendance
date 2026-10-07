<?php

namespace Tests\Unit\Services;

use App\Services\Ed25519SignerService;
use PHPUnit\Framework\TestCase;

final class Ed25519SignerServiceTest extends TestCase
{
    public function test_it_signs_deterministic_canonical_json_and_rejects_tampering(): void
    {
        $service = new Ed25519SignerService;
        $keys = $service->generateKeyPair();
        $firstPayload = [
            'role' => 'MASTER_ADMIN',
            'club_name' => 'نادي تضامن حضرموت الرياضي',
            'nested' => ['z' => 2, 'a' => 1],
            'teams' => ['الفريق الأول', 'الشباب'],
        ];
        $samePayloadWithDifferentKeyOrder = [
            'teams' => ['الفريق الأول', 'الشباب'],
            'nested' => ['a' => 1, 'z' => 2],
            'club_name' => 'نادي تضامن حضرموت الرياضي',
            'role' => 'MASTER_ADMIN',
        ];

        $firstSignature = $service->sign($firstPayload, $keys['private_key']);
        $secondSignature = $service->sign(
            $samePayloadWithDifferentKeyOrder,
            $keys['private_key'],
        );

        self::assertSame(
            $firstSignature['canonical_payload'],
            $secondSignature['canonical_payload'],
        );
        self::assertSame($firstSignature['signature'], $secondSignature['signature']);
        self::assertTrue($service->verify(
            $firstPayload,
            $firstSignature['signature'],
            $keys['public_key'],
        ));

        $firstPayload['role'] = 'FIELD_ATTENDANCE';

        self::assertFalse($service->verify(
            $firstPayload,
            $firstSignature['signature'],
            $keys['public_key'],
        ));
    }
}
