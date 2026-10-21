FROM php:8.2-fpm-alpine

# Set working directory
WORKDIR /var/www/html

# Install system dependencies & build tools
RUN apk add --no-cache \
    nginx \
    supervisor \
    curl \
    sqlite-dev \
    libsodium-dev \
    libpng-dev \
    libzip-dev \
    zip \
    unzip

# Install PHP extensions
RUN docker-php-ext-install \
    pdo \
    pdo_sqlite \
    pdo_mysql \
    bcmath \
    sodium \
    opcache

# Install Composer
COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

# Copy application source code
COPY monaz_license_portal /var/www/html

# Copy downloadable releases and offline tool into container build context
COPY releases /var/www/releases
COPY "بوابة_توليد_كود_التفعيل.html" /var/www/

# Configure Nginx and Supervisor
COPY docker/nginx.conf /etc/nginx/http.d/default.conf
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh

# Strip CRLF line endings from entrypoint and set permissions
RUN sed -i 's/\r$//' /usr/local/bin/entrypoint.sh \
    && chmod +x /usr/local/bin/entrypoint.sh

# Install production PHP dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Create download directory and pre-seed APK and offline HTML tool
RUN mkdir -p /var/www/html/public/downloads \
    && if [ -f /var/www/releases/MONAZ-Tadamon-Attendance-1.0.0+1.apk ]; then \
         cp /var/www/releases/MONAZ-Tadamon-Attendance-1.0.0+1.apk /var/www/html/public/downloads/MONAZ-Tadamon-Attendance.apk; \
       fi \
    && if [ -f /var/www/بوابة_توليد_كود_التفعيل.html ]; then \
         cp /var/www/بوابة_توليد_كود_التفعيل.html /var/www/html/public/downloads/بوابة_توليد_كود_التفعيل.html; \
       fi

# Set proper permissions for runtime
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
