<?php

use App\Http\Controllers\Api\ClubSyncController;
use App\Http\Controllers\Api\SessionSyncController;
use Illuminate\Support\Facades\Route;

Route::prefix('sync')->group(function () {
    // Session Dispatch & Review (Field & Master)
    Route::post('/dispatch', [SessionSyncController::class, 'dispatch'])->name('sync.dispatch');
    Route::get('/sessions', [SessionSyncController::class, 'index'])->name('sync.sessions');
    Route::post('/sessions/{uuid}/approve', [ClubSyncController::class, 'approveSession'])->name('sync.sessions.approve');

    // Club & Device Management
    Route::post('/device/register', [ClubSyncController::class, 'registerDevice'])->name('sync.device.register');

    // Master Reference Data (Teams, Players, Profile)
    Route::post('/master-data/push', [ClubSyncController::class, 'pushMasterData'])->name('sync.master.push');
    Route::get('/master-data/pull', [ClubSyncController::class, 'pullMasterData'])->name('sync.master.pull');
});
