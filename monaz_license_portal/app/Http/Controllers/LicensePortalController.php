<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Models\ClubDevice;
use App\Models\ClubProfile;
use App\Services\Ed25519SignerService;
use DateTimeImmutable;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\View\View;

class LicensePortalController extends Controller
{
    public function __construct(private readonly Ed25519SignerService $signer) {}

    public function index(): \Symfony\Component\HttpFoundation\Response
    {
        $club = $this->resolveClub('tadamon_hadhramaut');
        return $this->renderClubPortal($club);
    }

    public function showClub(string $id): \Symfony\Component\HttpFoundation\Response
    {
        $club = $this->resolveClub($id);
        return $this->renderClubPortal($club);
    }

    public function updateClub(Request $request, ?string $id = null): RedirectResponse
    {
        $validated = $request->validate([
            'club_name' => 'required|string|max:120',
            'club_code' => 'nullable|string|max:10|regex:/^[A-Z0-9]+$/',
            'season' => 'required|string|max:50',
            'primary_color_hex' => 'required|string|regex:/^#[a-fA-F0-9]{6}$/',
            'admin_name' => 'nullable|string|max:100',
            'manager_name' => 'nullable|string|max:100',
            'logo' => 'nullable|image|mimes:png,jpg,jpeg,svg,webp|max:2048',
        ]);

        $club = $this->resolveClub($id ?? 'tadamon_hadhramaut');
        $club->club_name = trim($validated['club_name']);
        if (!empty($validated['club_code'])) {
            $club->club_code = strtoupper(trim($validated['club_code']));
        }
        $club->season = trim($validated['season']);
        $club->primary_color_hex = strtoupper($validated['primary_color_hex']);
        $club->admin_name = $validated['admin_name'] ? trim($validated['admin_name']) : null;
        $club->manager_name = $validated['manager_name'] ? trim($validated['manager_name']) : null;

        if ($request->hasFile('logo')) {
            $file = $request->file('logo');
            $code = $club->club_code ?: 'club';
            $filename = 'club_' . strtolower((string) $code) . '_' . time() . '.' . $file->getClientOriginalExtension();
            $destination = public_path('uploads/logos');
            if (!is_dir($destination)) {
                mkdir($destination, 0755, true);
            }
            $file->move($destination, $filename);
            $club->logo_url = '/uploads/logos/' . $filename;
        }

        $club->save();

        return redirect()->route('clubs.show', $club->id)->with('success', 'تم حفظ وتحديث هوية النادي بنجاح.');
    }

    public function generate(Request $request, ?string $id = null): View
    {
        $validated = $request->validate([
            'mode' => 'required|in:single,dual',
            'device_name' => 'nullable|string|max:100',
            'role' => 'nullable|in:MASTER_ADMIN,FIELD_ATTENDANCE',
            'master_device_id' => 'required_if:mode,dual|nullable|regex:/^[A-Z0-9]{2,6}-[A-Z0-9]{4}-[A-Z0-9]{4}$/',
            'field_device_id' => 'required_if:mode,dual|nullable|regex:/^[A-Z0-9]{2,6}-[A-Z0-9]{4}-[A-Z0-9]{4}$/',
            'single_device_id' => 'required_if:mode,single|nullable|regex:/^[A-Z0-9]{2,6}-[A-Z0-9]{4}-[A-Z0-9]{4}$/',
            'team_name' => 'nullable|string|max:100',
            'validity_days' => 'nullable|integer|min:1|max:1095',
        ]);

        $club = $this->resolveClub($id ?? 'tadamon_hadhramaut');
        $allClubs = ClubProfile::where('is_active', true)->orderBy('club_name')->get();

        $privateKey = config('licensing.ed25519_private_key');
        if (!is_string($privateKey) || $privateKey === '') {
            $privateKey = env('LARAVEL_ED25519_PRIVATE_KEY');
        }
        if (!is_string($privateKey) || $privateKey === '') {
            $privateKey = 'S2uCyfUYmJSLOHfMEyA6fl1YoD/ybvC32RjF11zTnDbH2h79kpqDnqFfhPXP3+Bd49ipL8Lyw+CO1eUlp/E4VQ==';
        }

        $clubName = $club->club_name;
        $clubCode = $club->club_code ?: 'CLUB';
        $teamName = !empty($validated['team_name']) ? (string) $validated['team_name'] : 'الفريق الأول';
        $validityDays = (int) ($validated['validity_days'] ?? 365);
        $activatedAt = (new DateTimeImmutable('now'))->modify('-1 day');
        $expiresAt = (new DateTimeImmutable('now'))->modify("+{$validityDays} days");

        $results = [];

        if ($validated['mode'] === 'dual') {
            $masterId = strtoupper(trim((string) $validated['master_device_id']));
            $fieldId = strtoupper(trim((string) $validated['field_device_id']));

            if ($masterId === $fieldId) {
                return view('license_portal', [
                    'club' => $club,
                    'allClubs' => $allClubs,
                    'devices' => ClubDevice::where('club_id', $club->id)->orderBy('created_at', 'desc')->get(),
                    'error' => 'بصمة جهاز الإدارة يجب أن تختلف عن بصمة جهاز الميدان.',
                ]);
            }

            $pairingSecret = $this->base64UrlEncode(random_bytes(32));

            $masterPayload = [
                'activated_at' => $activatedAt->format('Y-m-d\TH:i:s\Z'),
                'club_id' => $club->id,
                'club_code' => $clubCode,
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
                'club_id' => $club->id,
                'club_code' => $clubCode,
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

            // Register in database under this club
            ClubDevice::updateOrCreate(
                ['device_id' => $masterId],
                [
                    'id' => (string) Str::uuid(),
                    'club_id' => $club->id,
                    'device_name' => 'جهاز الإدارة العامة (' . $clubName . ')',
                    'role' => 'master_admin',
                    'team_name' => $teamName,
                    'license_code' => $results['master']['code'],
                    'expires_at' => $expiresAt->format('Y-m-d H:i:s'),
                    'is_active' => true,
                ]
            );

            ClubDevice::updateOrCreate(
                ['device_id' => $fieldId],
                [
                    'id' => (string) Str::uuid(),
                    'club_id' => $club->id,
                    'device_name' => 'جهاز المحضر الميداني (' . $teamName . ')',
                    'role' => 'field_scout',
                    'team_name' => $teamName,
                    'license_code' => $results['field']['code'],
                    'expires_at' => $expiresAt->format('Y-m-d H:i:s'),
                    'is_active' => true,
                ]
            );
        } else {
            $deviceId = strtoupper(trim((string) $validated['single_device_id']));
            $role = $validated['role'] ?? 'MASTER_ADMIN';
            $deviceName = !empty($validated['device_name'])
                ? trim($validated['device_name'])
                : ($role === 'MASTER_ADMIN' ? 'جهاز الإدارة الرئيسية' : 'جهاز المحضر الميداني (' . $teamName . ')');
            $pairingSecret = $this->base64UrlEncode(random_bytes(32));

            $payload = [
                'activated_at' => $activatedAt->format('Y-m-d\TH:i:s\Z'),
                'club_id' => $club->id,
                'club_code' => $clubCode,
                'club_name' => $clubName,
                'device_id' => $deviceId,
                'expires_at' => $expiresAt->format('Y-m-d\TH:i:s\Z'),
                'local_pairing_secret' => $pairingSecret,
                'package_type' => 'SEASON',
                'role' => $role,
                'team_name' => $teamName,
            ];

            $results['single'] = $this->issueLicense($payload, $privateKey);

            ClubDevice::updateOrCreate(
                ['device_id' => $deviceId],
                [
                    'id' => (string) Str::uuid(),
                    'club_id' => $club->id,
                    'device_name' => $deviceName,
                    'role' => $role === 'MASTER_ADMIN' ? 'master_admin' : 'field_scout',
                    'team_name' => $teamName,
                    'license_code' => $results['single']['code'],
                    'expires_at' => $expiresAt->format('Y-m-d H:i:s'),
                    'is_active' => true,
                ]
            );
        }

        $devices = ClubDevice::where('club_id', $club->id)
            ->orderBy('created_at', 'desc')
            ->get();

        return view('license_portal', [
            'club' => $club,
            'allClubs' => $allClubs,
            'devices' => $devices,
            'results' => $results,
            'success' => 'تم إنشاء كود التفعيل المشفر بنجاح وإدراجه في سجل أجهزة النادي.',
            'formData' => $validated,
        ]);
    }

    public function deleteDevice(Request $request, string $clubId, ?string $deviceId = null): RedirectResponse
    {
        $targetDeviceId = $deviceId ?: $clubId;
        $device = ClubDevice::where(function ($q) use ($targetDeviceId) {
            $q->where('id', $targetDeviceId)->orWhere('device_id', $targetDeviceId);
        })->first();

        $targetClubId = $device?->club_id ?: ($deviceId ? $clubId : 'tadamon_hadhramaut');

        if ($device) {
            $device->delete();
            return redirect()->route('clubs.show', $targetClubId)->with('success', 'تم حذف الجهاز من سجل النادي بنجاح.');
        }

        return redirect()->route('clubs.show', $targetClubId)->with('error', 'تعذر العثور على الجهاز المطلوب حذفه.');
    }

    private function renderClubPortal(ClubProfile $club): \Symfony\Component\HttpFoundation\Response
    {
        try {
            $devices = ClubDevice::where('club_id', $club->id)
                ->orderBy('created_at', 'desc')
                ->get();

            $allClubs = ClubProfile::where('is_active', true)
                ->orderBy('club_name')
                ->get();

            return response(view('license_portal', [
                'club' => $club,
                'devices' => $devices,
                'allClubs' => $allClubs,
            ]));
        } catch (\Throwable $e) {
            \Illuminate\Support\Facades\Log::error('License portal render error: ' . $e->getMessage() . "\n" . $e->getTraceAsString());
            return response(
                '<div style="direction:rtl;font-family:sans-serif;padding:30px;background:#0d1a30;color:#f1f5f9;border-radius:12px;margin:20px;">' .
                '<h2 style="color:#f87171;">تنبيه تشخيصي للبوابة</h2>' .
                '<p><strong>رسالة الخطأ:</strong> ' . htmlspecialchars($e->getMessage()) . '</p>' .
                '<p><strong>الملف:</strong> ' . htmlspecialchars($e->getFile()) . ':' . $e->getLine() . '</p>' .
                '<pre style="direction:ltr;background:#060c18;padding:15px;border-radius:8px;overflow:auto;font-size:12px;color:#cbd5e1;">' . htmlspecialchars($e->getTraceAsString()) . '</pre>' .
                '</div>',
                200
            );
        }
    }

    private function resolveClub(string $id): ClubProfile
    {
        if (!\Illuminate\Support\Facades\Schema::hasTable('club_profiles') || !\Illuminate\Support\Facades\Schema::hasTable('club_devices')) {
            \Illuminate\Support\Facades\Artisan::call('migrate', ['--force' => true]);
        }

        $club = ClubProfile::where('id', $id)
            ->orWhere('club_code', strtoupper($id))
            ->first();

        if ($club) {
            return $club;
        }

        // If not found and asking for default, create it
        if ($id === 'tadamon_hadhramaut' || $id === 'TDMN') {
            return ClubProfile::firstOrCreate(
                ['id' => 'tadamon_hadhramaut'],
                [
                    'club_code' => 'TDMN',
                    'club_name' => 'نادي تضامن حضرموت الرياضي',
                    'season' => '2026/2027',
                    'primary_color_hex' => '#0F48A2',
                    'admin_name' => 'إداري الفريق المعتمد',
                    'manager_name' => 'المدير الفني المعتمد',
                    'is_active' => true,
                ]
            );
        }

        // Fallback to first available or default
        return ClubProfile::first() ?? ClubProfile::create([
            'id' => 'tadamon_hadhramaut',
            'club_code' => 'TDMN',
            'club_name' => 'نادي تضامن حضرموت الرياضي',
            'season' => '2026/2027',
            'primary_color_hex' => '#0F48A2',
            'is_active' => true,
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
