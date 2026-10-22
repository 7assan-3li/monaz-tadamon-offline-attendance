<?php

declare(strict_types=1);

namespace App\Actions;

use App\Models\DispatchedSession;
use Illuminate\Database\Eloquent\Collection;

class GetClubSessionsAction
{
    /**
     * @return Collection<int, DispatchedSession>
     */
    public function execute(?string $teamId = null, ?string $clubId = null): Collection
    {
        $query = DispatchedSession::query()->orderByDesc('session_date');

        if ($clubId !== null && $clubId !== '') {
            $query->where('club_id', $clubId);
        }

        if ($teamId !== null && $teamId !== '') {
            $query->where('team_id', $teamId);
        }

        return $query->limit(50)->get();
    }
}
