<?php

declare(strict_types=1);

namespace App\Actions;

use App\Models\DispatchedSession;

class ApproveDispatchedSessionAction
{
    public function execute(string $sessionUuid, string $approverDeviceId): DispatchedSession
    {
        $session = DispatchedSession::where('session_uuid', $sessionUuid)->firstOrFail();

        $session->update([
            'status' => 'approved',
        ]);

        return $session;
    }
}
