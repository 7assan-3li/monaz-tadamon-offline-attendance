<?php

declare(strict_types=1);

namespace App\Actions;

use App\Models\DispatchedSession;
use DateTimeImmutable;

class StoreDispatchedSessionAction
{
    /**
     * @param array<string, mixed> $data
     */
    public function execute(array $data): DispatchedSession
    {
        return DispatchedSession::updateOrCreate(
            ['session_uuid' => $data['session_uuid']],
            [
                'team_id' => $data['team_id'],
                'session_date' => new DateTimeImmutable($data['session_date']),
                'source_device_id' => $data['source_device_id'],
                'payload' => $data,
                'signature' => $data['signature'] ?? null,
                'status' => 'pending',
            ]
        );
    }
}
