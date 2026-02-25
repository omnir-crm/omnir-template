FROM php:8.1-apache-bullseye

# 1. Update and install only the bare essentials
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
    && rm -rf /var/lib/apt/lists/*

# 2. Configure and install required PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j$(nproc) \
    mysqli \
    gd \
    zip \
    bcmath \
    intl \
    mbstring \
    curl \
    imap \
    && docker-php-ext-enable opcache

# 3. Enable Apache's rewrite module and allow .htaccess overrides
RUN a2enmod rewrite
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

# 4. Set PHP limits and development settings
RUN { \
    echo 'file_uploads = On'; \
    echo 'post_max_size = 256M'; \
    echo 'upload_max_filesize = 256M'; \
    echo 'memory_limit = 512M'; \
    echo 'max_execution_time = 300'; \
    echo 'display_errors = On'; \
    echo 'error_reporting = E_ALL'; \
    } > /usr/local/etc/php/conf.d/vtiger-php.ini

WORKDIR /var/www/html

# 5. Copy application files into the image
COPY . /var/www/html/

# 6. Install composer dependencies
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --no-interaction --optimize-autoloader 2>/dev/null || true

# 7. Ensure proper ownership and writable directories for Apache
RUN chown -R www-data:www-data /var/www/html
RUN mkdir -p storage logs test/templates_c test/logo \
    && chown -R www-data:www-data storage logs test

# 8. Entrypoint configuration
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 80
CMD ["apache2-foreground"]
