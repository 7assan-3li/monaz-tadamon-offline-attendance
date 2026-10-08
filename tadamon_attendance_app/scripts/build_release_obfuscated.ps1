# PowerShell Script for building Production Obfuscated Release APK for Hadhramaut Tadamon Club
# MONAZ - Strict Offline Security & Obfuscation

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " MONAZ Offline Attendance App - Production Release Build " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

$AppDir = Split-Path -Parent $PSScriptRoot
Set-Location $AppDir

$SymbolsDir = Join-Path $AppDir "build\app\outputs\symbols"
if (-not (Test-Path $SymbolsDir)) {
    New-Item -ItemType Directory -Path $SymbolsDir -Force | Out-Null
}

$DartDefinesFile = Join-Path $AppDir ".dart-defines.local.json"

if (-not (Test-Path $DartDefinesFile)) {
    Write-Warning "Warning: .dart-defines.local.json not found. Building without defines..."
    flutter build apk --release --obfuscate "--split-debug-info=$SymbolsDir"
} else {
    Write-Host "Building release APK with obfuscation and security defines..." -ForegroundColor Green
    flutter build apk --release --obfuscate "--split-debug-info=$SymbolsDir" "--dart-define-from-file=$DartDefinesFile"
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host " Build succeeded! Production APK generated: " -ForegroundColor Green
    Write-Host " build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor White
    Write-Host " Debug symbols: $SymbolsDir" -ForegroundColor White
    Write-Host "==========================================================" -ForegroundColor Green
} else {
    Write-Host "Build failed. Check errors above." -ForegroundColor Red
}
