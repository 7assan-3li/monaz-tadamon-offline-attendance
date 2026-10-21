#!/bin/sh
set -e

cd /var/www/html

# Ensure storage and database folders exist
mkdir -p /var/www/html/database \
         /var/www/html/storage/framework/cache/data \
         /var/www/html/storage/framework/sessions \
         /var/www/html/storage/framework/views \
         /var/www/html/storage/logs \
         /var/www/html/public/downloads

# Ensure SQLite file exists
if [ ! -f /var/www/html/database/database.sqlite ]; then
    touch /var/www/html/database/database.sqlite
fi

# Ensure .env exists if missing
if [ ! -f /var/www/html/.env ]; then
    cp /var/www/html/.env.example /var/www/html/.env
fi

# Link or copy bundled releases if not yet present in downloads
if [ -f /var/www/releases/MONAZ-Tadamon-Attendance-1.0.0+1.apk ] && [ ! -f /var/www/html/public/downloads/MONAZ-Tadamon-Attendance.apk ]; then
    cp /var/www/releases/MONAZ-Tadamon-Attendance-1.0.0+1.apk /var/www/html/public/downloads/MONAZ-Tadamon-Attendance.apk
fi

if [ -f /var/www/بوابة_توليد_كود_التفعيل.html ] && [ ! -f /var/www/html/public/downloads/بوابة_توليد_كود_التفعيل.html ]; then
    cp /var/www/بوابة_توليد_كود_التفعيل.html /var/www/html/public/downloads/بوابة_توليد_كود_التفعيل.html
fi

# Synchronize latest migration files into database volume
mkdir -p /var/www/html/database/migrations
if [ -d /var/www/migrations_backup ]; then
    cp -f /var/www/migrations_backup/* /var/www/html/database/migrations/ 2>/dev/null || true
fi

# Set proper ownership and permissions
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/database /var/www/html/public/downloads
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/database

# Generate app key if not set
if [ -z "$APP_KEY" ] || [ "$APP_KEY" = "" ]; then
    php artisan key:generate --force
fi

# Run database migrations
php artisan migrate --force

# Production optimizations
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "=========================================================="
echo "  MONAZ Tadamon Attendance Portal & Sync API Started!    "
echo "  Architecture: Isolated Docker Multi-Tenant               "
echo "=========================================================="

exec "$@"
