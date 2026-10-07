<?php

namespace App\Data;

use DateTimeImmutable;

final readonly class GenerateClubDualLicenseData
{
    public function __construct(
        public string $clubName,
        public ?string $teamName,
        public string $packageType,
        public DateTimeImmutable $activatedAt,
        public DateTimeImmutable $expiresAt,
        public string $masterDeviceId,
        public string $fieldDeviceId,
    ) {}
}
