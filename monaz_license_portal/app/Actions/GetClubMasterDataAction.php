<?php

declare(strict_types=1);

namespace App\Actions;

use App\Models\ClubMasterSnapshot;
use App\Models\ClubProfile;

class GetClubMasterDataAction
{
    /**
     * @return array<string, mixed>|null
     */
    public function execute(?string $clubId = null): ?array
    {
        $query = ClubMasterSnapshot::latest('version_timestamp');

        if ($clubId !== null) {
            $query->where('club_id', $clubId);
        }

        /** @var ClubMasterSnapshot|null $snapshot */
        $snapshot = $query->first();

        if ($snapshot === null) {
            // Fallback to empty default
            $club = ClubProfile::first();
            return [
                'club_profile' => [
                    'club_name' => $club->club_name ?? 'نادي تضامن حضرموت الرياضي',
                    'season' => $club->season ?? '2026/2027',
                    'primary_color_hex' => $club->primary_color_hex ?? '#0F48A2',
                    'logo_url' => $club->logo_url ?? null,
                ],
                'version_timestamp' => 0,
                'teams' => [],
                'players' => [],
            ];
        }

        $club = $snapshot->club ?? ClubProfile::find($snapshot->club_id);

        return [
            'club_profile' => array_merge([
                'club_name' => $club->club_name ?? 'نادي تضامن حضرموت الرياضي',
                'season' => $club->season ?? '2026/2027',
                'primary_color_hex' => $club->primary_color_hex ?? '#0F48A2',
                'logo_url' => $club->logo_url ?? null,
            ], $snapshot->settings_payload ?? []),
            'version_timestamp' => $snapshot->version_timestamp,
            'source_device_id' => $snapshot->source_device_id,
            'teams' => $snapshot->teams_payload,
            'players' => $snapshot->players_payload,
        ];
    }
}
