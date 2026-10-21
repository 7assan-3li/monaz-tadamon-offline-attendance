<?php

declare(strict_types=1);

namespace App\Actions;

use App\Models\ClubDevice;
use App\Models\ClubProfile;
use Illuminate\Support\Str;

class RegisterClubDeviceAction
{
    /**
     * @param array{
     *     device_id: string,
     *     device_name: string,
     *     role: string,
     *     club_name?: string|null,
     *     season?: string|null,
     *     primary_color_hex?: string|null
     * } $data
     */
    public function execute(array $data): ClubDevice
    {
        $clubName = $data['club_name'] ?? 'نادي تضامن حضرموت الرياضي';
        $season = $data['season'] ?? '2026/2027';
        $primaryColor = $data['primary_color_hex'] ?? '#0F48A2';

        // Find or create the default club profile
        $club = ClubProfile::firstOrCreate(
            ['club_name' => $clubName],
            [
                'id' => (string) Str::uuid(),
                'season' => $season,
                'primary_color_hex' => $primaryColor,
            ]
        );

        return ClubDevice::updateOrCreate(
            ['device_id' => $data['device_id']],
            [
                'id' => (string) Str::uuid(),
                'club_id' => $club->id,
                'device_name' => $data['device_name'],
                'role' => $data['role'],
                'is_active' => true,
                'last_sync_at' => now(),
            ]
        );
    }
}
