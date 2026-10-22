<?php

use App\Http\Controllers\ClubManagementController;
use App\Http\Controllers\LicensePortalController;
use Illuminate\Support\Facades\Route;

// 1. دليل واستعراض الأندية الرياضية (Multi-Club Hub)
Route::get('/', [ClubManagementController::class, 'index'])->name('license.index');
Route::get('/clubs', [ClubManagementController::class, 'index'])->name('clubs.index');
Route::post('/clubs', [ClubManagementController::class, 'store'])->name('clubs.store');

// 2. إدارة وتراخيص نادي مخصص (Per-Club Workspace)
Route::get('/clubs/{id}', [LicensePortalController::class, 'showClub'])->name('clubs.show');
Route::post('/clubs/{id}/update', [LicensePortalController::class, 'updateClub'])->name('clubs.update');
Route::post('/clubs/{id}/generate', [LicensePortalController::class, 'generate'])->name('clubs.generate');
Route::delete('/clubs/{id}/devices/{deviceId}', [LicensePortalController::class, 'deleteDevice'])->name('clubs.devices.delete');

// 3. تصدير وتحميل النسخة الاحتياطية المستقلة للنادي (Dedicated Club Backup)
Route::get('/clubs/{id}/backup', [ClubManagementController::class, 'exportBackup'])->name('clubs.backup.export');

// 4. المسارات المتوافقة مع الروابط السابقة (Legacy Backward Compatibility)
Route::post('/generate', [LicensePortalController::class, 'generate'])->name('license.generate');
Route::post('/club/update', [LicensePortalController::class, 'updateClub'])->name('club.update');
Route::delete('/devices/{id}', [LicensePortalController::class, 'deleteDevice'])->name('devices.delete');

// 5. روابط تنزيل الموارد الرسمية المعتمدة
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
