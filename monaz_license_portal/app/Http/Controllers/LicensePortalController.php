<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Services\Ed25519SignerService;
use DateTimeImmutable;
use Illuminate\Http\Request;
use Illuminate\View\View;
use InvalidArgumentException;
use RuntimeException;

class LicensePortalController extends Controller
{
    public function __construct(private readonly Ed25519SignerService $signer) {}

    public function index(): View
    {
        return view('license_portal');
    }

    public function generate(Request $request): View
    {
        $validated = $request->validate([
            'mode' => 'required|in:single,dual',
            'role' => 'nullable|in:MASTER_ADMIN,FIELD_ATTENDANCE',
            'master_device_id' => 'required_if:mode,dual|nullable|regex:/^TD-[A-Z0-9]{4}-[A-Z0-9]{4}$/',
            'field_device_id' => 'required_if:mode,dual|nullable|regex:/^TD-[A-Z0-9]{4}-[A-Z0-9]{4}$/',
            'single_device_id' => 'required_if:mode,single|nullable|regex:/^TD-[A-Z0-9]{4}-[A-Z0-9]{4}$/',
            'club_name' => 'nullable|string|max:100',
            'team_name' => 'nullable|string|max:100',
            'validity_days' => 'nullable|integer|min:1|max:1095',
        ]);

        $privateKey = config('licensing.ed25519_private_key');
        if (!is_string($privateKey) || $privateKey === '') {
            $privateKey = env('LARAVEL_ED25519_PRIVATE_KEY');
        }
        if (!is_string($privateKey) || $privateKey === '') {
            $privateKey = 'S2uCyfUYmJSLOHfMEyA6fl1YoD/ybvC32RjF11zTnDbH2h79kpqDnqFfhPXP3+Bd49ipL8Lyw+CO1eUlp/E4VQ==';
        }

        $clubName = $validated['club_name'] ?: 'نادي تضامن حضرموت الرياضي';
        $teamName = $validated['team_name'] ?: 'الفريق الأول';
        $validityDays = (int) ($validated['validity_days'] ?? 365);
        $activatedAt = (new DateTimeImmutable('now'))->modify('-1 day');
        $expiresAt = (new DateTimeImmutable('now'))->modify("+{$validityDays} days");

        $results = [];

        if ($validated['mode'] === 'dual') {
            $masterId = strtoupper(trim((string)$validated['master_device_id']));
            $fieldId = strtoupper(trim((string)$validated['field_device_id']));

            if ($masterId === $fieldId) {
                return view('license_portal', [
                    'error' => 'بصمة جهاز الإدارة يجب أن تختلف عن بصمة جهاز الميدان.',
                ]);
            }

            $pairingSecret = $this->base64UrlEncode(random_bytes(32));

            $masterPayload = [
                'activated_at' => $activatedAt->format('Y-m-d\TH:i:s\Z'),
                'club_name' => $clubName,
                'device_id' => $masterId,
                'expires_at' => $expiresAt->format('Y-m-d\TH:i:s\Z'),
                'local_pairing_secret' => $pairingSecret,
                'package_type' => 'SEASON',
                'paired_device_id' => $fieldId,
                'role' => 'MASTER_ADMIN',
                'team_name' => $teamName,
            ];

            $fieldPayload = [
                'activated_at' => $activatedAt->format('Y-m-d\TH:i:s\Z'),
                'club_name' => $clubName,
                'device_id' => $fieldId,
                'expires_at' => $expiresAt->format('Y-m-d\TH:i:s\Z'),
                'local_pairing_secret' => $pairingSecret,
                'package_type' => 'SEASON',
                'paired_device_id' => $masterId,
                'role' => 'FIELD_ATTENDANCE',
                'team_name' => $teamName,
            ];

            $results['master'] = $this->issueLicense($masterPayload, $privateKey);
            $results['field'] = $this->issueLicense($fieldPayload, $privateKey);
        } else {
            $deviceId = strtoupper(trim((string)$validated['single_device_id']));
            $role = $validated['role'] ?? 'MASTER_ADMIN';
            $pairingSecret = $this->base64UrlEncode(random_bytes(32));

            $payload = [
                'activated_at' => $activatedAt->format('Y-m-d\TH:i:s\Z'),
                'club_name' => $clubName,
                'device_id' => $deviceId,
                'expires_at' => $expiresAt->format('Y-m-d\TH:i:s\Z'),
                'local_pairing_secret' => $pairingSecret,
                'package_type' => 'SEASON',
                'role' => $role,
                'team_name' => $teamName,
            ];

            $results['single'] = $this->issueLicense($payload, $privateKey);
        }

        return view('license_portal', [
            'results' => $results,
            'success' => 'تم إنشاء كود التفعيل المشفر بنجاح عبر خوارزمية Ed25519.',
            'formData' => $validated,
        ]);
    }

    private function issueLicense(array $payload, string $privateKey): array
    {
        $signed = $this->signer->sign($payload, $privateKey);
        $envelope = json_encode([
            'payload' => $payload,
            'signature' => $signed['signature'],
        ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR);

        return [
            'code' => $this->base64UrlEncode($envelope),
            'payload' => $payload,
            'signature' => $signed['signature'],
        ];
    }

    private function base64UrlEncode(string $value): string
    {
        return rtrim(strtr(base64_encode($value), '+/', '-_'), '=');
    }
}
