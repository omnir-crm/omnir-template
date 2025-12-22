# Using PHP 8.3 with Apache - Vtiger 8.x supports PHP 8.x
FROM php:8.3-apache

# 1. Install system dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libicu-dev \
    libxml2-dev \
    libc-client-dev \
    libkrb5-dev \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# 2. Configure and install PHP extensions
# Vtiger requires imap, gd, mysqli, zip, and intl
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j$(nproc) \
    mysqli \
    gd \
    zip \
    intl \
    xml \
    soap \
    imap \
    bcmath

# 3. Set recommended PHP settings for Vtiger
RUN { \
    echo 'display_errors = Off'; \
    echo 'max_execution_time = 600'; \
    echo 'max_input_vars = 10000'; \
    echo 'memory_limit = 512M'; \
    echo 'post_max_size = 100M'; \
    echo 'upload_max_filesize = 100M'; \
    echo 'date.timezone = UTC'; \
    } > /usr/local/etc/php/conf.d/vtiger-optimizations.ini

# 4. Enable Apache rewrite module
RUN a2enmod rewrite

WORKDIR /var/www/html

# The 'command' in docker-compose will handle the extraction and start apache