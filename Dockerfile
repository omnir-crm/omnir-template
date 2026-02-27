FROM php:8.1-apache

# Install required Vtiger 8.4 PHP extensions
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    libicu-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd mysqli pdo_mysql zip intl

# Enable Apache rewrite for Vtiger URL handling
RUN a2enmod rewrite

# Set Recommended PHP Settings
RUN echo "memory_limit = 256M" > /usr/local/etc/php/conf.d/vtiger.ini \
    && echo "max_execution_time = 600" >> /usr/local/etc/php/conf.d/vtiger.ini \
    && echo "error_reporting = E_WARNING & ~E_NOTICE & ~E_DEPRECATED & ~E_STRICT" >> /usr/local/etc/php/conf.d/vtiger.ini \
    && echo "display_errors = Off" >> /usr/local/etc/php/conf.d/vtiger.ini \
    && echo "short_open_tag = On" >> /usr/local/etc/php/conf.d/vtiger.ini \
    && echo "log_errors = On" >> /usr/local/etc/php/conf.d/vtiger.ini