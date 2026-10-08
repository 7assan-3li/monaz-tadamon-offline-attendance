<?php

declare(strict_types=1);

use App\Actions\GenerateClubDualLicenseAction;
use App\Data\GenerateClubDualLicenseData;
use Illuminate\Contracts\Console\Kernel;

require dirname(__DIR__).'/vendor/autoload.php';

$masterDeviceId = $argv[1] ?? '';
$fieldDeviceId = $argv[2] ?? '';
if (preg_match('/^TD-[A-Z0-9]{4}-[A-Z0-9]{4}$/', $masterDeviceId) !== 1
    || preg_match('/^TD-[A-Z0-9]{4}-[A-Z0-9]{4}$/', $fieldDeviceId) !== 1) {
    fwrite(STDERR, "Pass valid master and field device identifiers.\n");
    exit(1);
}

$app = require dirname(__DIR__).'/bootstrap/app.php';
$app->make(Kernel::class)->bootstrap();

$licenses = $app->make(GenerateClubDualLicenseAction::class)->execute(
    new GenerateClubDualLicenseData(
        clubName: 'نادي تضامن حضرموت الرياضي',
        teamName: 'الفريق الأول',
        packageType: 'SEASON',
        activatedAt: new DateTimeImmutable('today midnight UTC'),
        expiresAt: new DateTimeImmutable('+1 year 23:59:59 UTC'),
        masterDeviceId: $masterDeviceId,
        fieldDeviceId: $fieldDeviceId,
    ),
);

$outputPath = dirname(dirname(__DIR__)).'/tadamon_attendance_app/.activation-code.local';
file_put_contents($outputPath, $licenses['master']['activation_code']);

$jsonPath = dirname(dirname(__DIR__)).'/tadamon_attendance_app/.activation-codes.json';
file_put_contents($jsonPath, json_encode([
    'master' => $licenses['master']['activation_code'],
    'field' => $licenses['field']['activation_code'],
], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));

echo "Activation codes generated successfully for Master and Field devices.\n";

