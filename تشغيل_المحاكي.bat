@echo off
chcp 65001 > nul
echo ========================================================
echo  تشغيل محاكي الأندرويد لنادي تضامن حضرموت (Pixel_6a)
echo ========================================================
echo جاري فتح نافذة المحاكي على سطح المكتب...

start "" "C:\Users\HICOM\AppData\Local\Android\Sdk\emulator\emulator.exe" -avd Pixel_6a

echo تم إطلاق المحاكي. النافذة ستظهر الآن على شاشتك.
pause
