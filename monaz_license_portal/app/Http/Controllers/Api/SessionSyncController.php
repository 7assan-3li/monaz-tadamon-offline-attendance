<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Actions\GetClubSessionsAction;
use App\Actions\StoreDispatchedSessionAction;
use App\Http\Controllers\Controller;
use App\Http\Requests\DispatchSessionRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SessionSyncController extends Controller
{
    public function dispatch(DispatchSessionRequest $request, StoreDispatchedSessionAction $action): JsonResponse
    {
        $session = $action->execute($request->validated());

        return response()->json([
            'status' => 'success',
            'session_uuid' => $session->session_uuid,
            'message' => 'تم استلام وتوثيق كشف التمرين في السحابة بنجاح.',
        ], 201);
    }

    public function index(Request $request, GetClubSessionsAction $action): JsonResponse
    {
        $teamId = $request->query('team_id');
        $sessions = $action->execute(is_string($teamId) ? $teamId : null);

        return response()->json([
            'status' => 'success',
            'count' => $sessions->count(),
            'sessions' => $sessions->map(fn ($s) => $s->payload),
        ]);
    }
}
