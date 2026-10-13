@echo off
chcp 65001 > nul
echo ========================================================
echo  تثبيت وتشغيل أحدث نسخة لنظام تحضير نادي تضامن حضرموت
echo ========================================================

set ADB="C:\Users\HICOM\AppData\Local\Android\Sdk\platform-tools\adb.exe"
set APK="releases\MONAZ-Tadamon-Attendance-1.0.0+1.apk"

echo بانتظار اتصال المحاكي أو الهاتف...
%ADB% wait-for-device

echo جاري تثبيت حزمة التطبيق الرسمية v1.0.0...
%ADB% install -r %APK%

echo جاري تشغيل التطبيق...
%ADB% shell monkey -p com.monaz.tadamon.tadamon_attendance_app -c android.intent.category.LAUNCHER 1

echo ========================================================
echo  تم تشغيل التطبيق بنجاح!
echo ========================================================
pause
