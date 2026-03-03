FROM php:8.1-apache-bullseye

# 1. Install system dependencies
RUN apt-get update --allow-releaseinfo-change && \
    apt-get install -y --no-install-recommends \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libicu-dev \
    libzip-dev \
    libonig-dev \
    libxml2-dev \
    libc-client-dev \
    libkrb5-dev \
    libcurl4-openssl-dev \
    unzip \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 2. Configure and install required PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j$(nproc) \
    mysqli \
    pdo_mysql \
    gd \
    zip \
    bcmath \
    intl \
    mbstring \
    curl \
    imap \
    && docker-php-ext-enable opcache

# 3. Enable Apache rewrite and allow .htaccess overrides
RUN a2enmod rewrite \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf \
    && sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

# 4. PHP settings for vTiger
RUN { \
    echo 'file_uploads = On'; \
    echo 'post_max_size = 256M'; \
    echo 'upload_max_filesize = 256M'; \
    echo 'memory_limit = 512M'; \
    echo 'max_execution_time = 600'; \
    echo 'max_input_time = 600'; \
    echo 'display_errors = On'; \
    echo 'error_reporting = E_ALL'; \
    echo 'short_open_tag = On'; \
    echo 'log_errors = On'; \
    } > /usr/local/etc/php/conf.d/vtiger-php.ini

WORKDIR /var/www/html

# 5. Copy application files into the image
COPY . /var/www/html/

# 6. Rename htaccess.txt to .htaccess for Apache
RUN if [ -f htaccess.txt ] && [ ! -f .htaccess ]; then cp htaccess.txt .htaccess; fi

# 7. Install composer dependencies
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --no-interaction --optimize-autoloader 2>/dev/null || true

# 8. Ensure proper ownership and writable directories for Apache
RUN mkdir -p storage logs cache test/templates_c test/logo user_privileges \
    && chown -R www-data:www-data /var/www/html

# 9. Entrypoint handles runtime setup (permissions, composer, site_URL)
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 80
CMD ["apache2-foreground"]
