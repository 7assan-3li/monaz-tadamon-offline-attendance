<?php

use App\Http\Controllers\LicensePortalController;
use Illuminate\Support\Facades\Route;

Route::get('/', [LicensePortalController::class, 'index'])->name('license.index');
Route::post('/generate', [LicensePortalController::class, 'generate'])->name('license.generate');
Route::post('/club/update', [LicensePortalController::class, 'updateClub'])->name('club.update');
Route::delete('/devices/{id}', [LicensePortalController::class, 'deleteDevice'])->name('devices.delete');

Route::get('/download/apk', function () {
    $candidates = [
        public_path('downloads/MONAZ-Tadamon-Attendance.apk'),
        base_path('../releases/MONAZ-Tadamon-Attendance-1.0.0+1.apk'),
        base_path('releases/MONAZ-Tadamon-Attendance-1.0.0+1.apk'),
    ];

    foreach ($candidates as $path) {
        if (file_exists($path)) {
            return response()->download($path, 'MONAZ-Tadamon-Attendance.apk', [
                'Content-Type' => 'application/vnd.android.package-archive',
            ]);
        }
    }

    abort(404, 'ملف تطبيق الأندرويد غير متوفر حالياً.');
})->name('download.apk');

Route::get('/download/offline-tool', function () {
    $candidates = [
        public_path('downloads/بوابة_توليد_كود_التفعيل.html'),
        base_path('../بوابة_توليد_كود_التفعيل.html'),
        base_path('بوابة_توليد_كود_التفعيل.html'),
    ];

    foreach ($candidates as $path) {
        if (file_exists($path)) {
            return response()->download($path, 'بوابة_توليد_كود_التفعيل.html', [
                'Content-Type' => 'text/html; charset=utf-8',
            ]);
        }
    }

    abort(404, 'أداة التفعيل المستقلة غير متوفرة حالياً.');
})->name('download.offline_tool');
