<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Actions\ApproveDispatchedSessionAction;
use App\Actions\GetClubMasterDataAction;
use App\Actions\PushClubMasterDataAction;
use App\Actions\RegisterClubDeviceAction;
use App\Http\Controllers\Controller;
use App\Http\Requests\PushMasterDataRequest;
use App\Http\Requests\RegisterDeviceRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ClubSyncController extends Controller
{
    public function registerDevice(RegisterDeviceRequest $request, RegisterClubDeviceAction $action): JsonResponse
    {
        $device = $action->execute($request->validated());

        return response()->json([
            'status' => 'success',
            'message' => 'تم تسجيل الجهاز وربطه بالنادي بنجاح.',
            'device' => [
                'device_id' => $device->device_id,
                'device_name' => $device->device_name,
                'role' => $device->role,
                'club_id' => $device->club_id,
            ],
        ], 200);
    }

    public function pushMasterData(PushMasterDataRequest $request, PushClubMasterDataAction $action): JsonResponse
    {
        $snapshot = $action->execute($request->validated());

        return response()->json([
            'status' => 'success',
            'message' => 'تم حفظ ومزامنة بيانات النادي واللاعبين في السحابة بنجاح.',
            'version_timestamp' => $snapshot->version_timestamp,
        ], 201);
    }

    public function pullMasterData(Request $request, GetClubMasterDataAction $action): JsonResponse
    {
        $clubId = $request->query('club_id');
        $data = $action->execute(is_string($clubId) ? $clubId : null);

        return response()->json([
            'status' => 'success',
            'data' => $data,
        ], 200);
    }

    public function approveSession(string $uuid, Request $request, ApproveDispatchedSessionAction $action): JsonResponse
    {
        $approverDeviceId = (string) $request->input('approver_device_id', 'master_admin');
        $session = $action->execute($uuid, $approverDeviceId);

        return response()->json([
            'status' => 'success',
            'message' => 'تم اعتماد الحصة التدريبية رسمياً في السحابة.',
            'session_uuid' => $session->session_uuid,
            'status_code' => $session->status,
        ], 200);
    }
}
