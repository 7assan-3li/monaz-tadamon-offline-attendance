<?php

use App\Http\Controllers\LicensePortalController;
use Illuminate\Support\Facades\Route;

Route::get('/', [LicensePortalController::class, 'index'])->name('license.index');
Route::post('/generate', [LicensePortalController::class, 'generate'])->name('license.generate');
