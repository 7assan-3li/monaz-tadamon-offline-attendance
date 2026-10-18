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
    public function execute(?string $teamId = null): Collection
    {
        $query = DispatchedSession::query()->orderByDesc('session_date');

        if ($teamId !== null && $teamId !== '') {
            $query->where('team_id', $teamId);
        }

        return $query->limit(50)->get();
    }
}
