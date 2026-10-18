<?php

use App\Http\Controllers\Api\SessionSyncController;
use Illuminate\Support\Facades\Route;

Route::prefix('sync')->group(function () {
    Route::post('/dispatch', [SessionSyncController::class, 'dispatch'])->name('sync.dispatch');
    Route::get('/sessions', [SessionSyncController::class, 'index'])->name('sync.sessions');
});
