<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Models\ClubProfile;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\View\View;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ClubManagementController extends Controller
{
    public function index(): View
    {
        $this->ensureDefaultClubExists();

        $clubs = ClubProfile::withCount('devices')
            ->orderBy('created_at', 'asc')
            ->get();

        return view('clubs_index', [
            'clubs' => $clubs,
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'id' => 'nullable|string|max:50|regex:/^[a-z0-9_]+$/|unique:club_profiles,id',
            'club_name' => 'required|string|max:120',
            'club_code' => 'required|string|max:10|regex:/^[A-Z0-9]+$/|unique:club_profiles,club_code',
            'season' => 'required|string|max:50',
            'primary_color_hex' => 'required|string|regex:/^#[a-fA-F0-9]{6}$/',
            'admin_name' => 'nullable|string|max:100',
            'manager_name' => 'nullable|string|max:100',
            'logo' => 'nullable|image|mimes:png,jpg,jpeg,svg,webp|max:2048',
        ]);

        $code = strtoupper(trim($validated['club_code']));
        $preferredId = !empty($validated['id']) ? strtolower(trim($validated['id'])) : Str::slug($code, '_');

        // Ensure unique slug ID
        $candidateId = $preferredId;
        $counter = 1;
        while (ClubProfile::where('id', $candidateId)->exists()) {
            $candidateId = $preferredId . '_' . $counter;
            $counter++;
        }

        $logoUrl = null;
        if ($request->hasFile('logo')) {
            $file = $request->file('logo');
            $filename = 'club_' . strtolower($code) . '_' . time() . '.' . $file->getClientOriginalExtension();
            $destination = public_path('uploads/logos');
            if (!is_dir($destination)) {
                mkdir($destination, 0755, true);
            }
            $file->move($destination, $filename);
            $logoUrl = '/uploads/logos/' . $filename;
        }

        $club = ClubProfile::create([
            'id' => $candidateId,
            'club_code' => $code,
            'club_name' => trim($validated['club_name']),
            'season' => trim($validated['season']),
            'primary_color_hex' => strtoupper($validated['primary_color_hex']),
            'admin_name' => $validated['admin_name'] ? trim($validated['admin_name']) : null,
            'manager_name' => $validated['manager_name'] ? trim($validated['manager_name']) : null,
            'logo_url' => $logoUrl,
            'is_active' => true,
        ]);

        return redirect()->route('clubs.show', $club->id)->with('success', 'تم إنشاء وتسجيل النادي الرياضي بنجاح!');
    }

    public function exportBackup(string $id): StreamedResponse
    {
        $club = ClubProfile::with(['devices', 'snapshots', 'dispatchedSessions'])
            ->where('id', $id)
            ->orWhere('club_code', strtoupper($id))
            ->firstOrFail();

        $backupData = [
            'metadata' => [
                'system' => 'MONAZ Offline Attendance Platform (Multi-Tenant Hub)',
                'club_id' => $club->id,
                'club_code' => $club->club_code,
                'club_name' => $club->club_name,
                'season' => $club->season,
                'exported_at' => now()->toIso8601String(),
                'export_version' => '1.0.0',
            ],
            'club_profile' => $club->only([
                'id', 'club_code', 'club_name', 'season', 'admin_name', 'manager_name',
                'primary_color_hex', 'logo_url', 'is_active', 'created_at', 'updated_at'
            ]),
            'registered_devices' => $club->devices->toArray(),
            'master_snapshots' => $club->snapshots->toArray(),
            'dispatched_sessions' => $club->dispatchedSessions->toArray(),
        ];

        $code = $club->club_code ?: 'CLUB';
        $safeSeason = str_replace('/', '-', (string) $club->season);
        $filename = "backup_{$code}_{$safeSeason}_" . date('Ymd_His') . ".json";

        return response()->streamDownload(function () use ($backupData) {
            echo json_encode($backupData, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        }, $filename, [
            'Content-Type' => 'application/json; charset=utf-8',
        ]);
    }

    private function ensureDefaultClubExists(): void
    {
        ClubProfile::firstOrCreate(
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
}
