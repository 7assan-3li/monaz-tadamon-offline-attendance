<?php

declare(strict_types=1);

namespace App\Actions;

use App\Models\ClubMasterSnapshot;
use App\Models\ClubProfile;
use Illuminate\Support\Str;

class PushClubMasterDataAction
{
    /**
     * @param array{
     *     source_device_id: string,
     *     version_timestamp?: int|null,
     *     club_profile?: array<string, mixed>|null,
     *     teams: array<int, mixed>,
     *     players: array<int, mixed>
     * } $data
     */
    public function execute(array $data): ClubMasterSnapshot
    {
        $profileData = $data['club_profile'] ?? [];
        $clubName = $profileData['club_name'] ?? 'نادي تضامن حضرموت الرياضي';

        $club = ClubProfile::firstOrCreate(
            ['club_name' => $clubName],
            [
                'id' => (string) Str::uuid(),
                'season' => $profileData['season'] ?? '2026/2027',
                'primary_color_hex' => $profileData['primary_color_hex'] ?? '#0F48A2',
            ]
        );

        // Update profile if new settings were passed
        if (!empty($profileData)) {
            $club->update(array_filter([
                'season' => $profileData['season'] ?? null,
                'admin_name' => $profileData['admin_name'] ?? null,
                'manager_name' => $profileData['manager_name'] ?? null,
                'primary_color_hex' => $profileData['primary_color_hex'] ?? null,
                'logo_url' => $profileData['logo_url'] ?? null,
            ]));
        }

        $version = $data['version_timestamp'] ?? (int) (microtime(true) * 1000);

        return ClubMasterSnapshot::create([
            'id' => (string) Str::uuid(),
            'club_id' => $club->id,
            'source_device_id' => $data['source_device_id'],
            'version_timestamp' => $version,
            'teams_payload' => $data['teams'],
            'players_payload' => $data['players'],
            'settings_payload' => $profileData,
        ]);
    }
}
