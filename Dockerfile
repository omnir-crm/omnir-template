FROM php:8.1-apache-bullseye

# The --allow-releaseinfo-change flag fixes the Exit Code 100 on older Debian bases
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
    && rm -rf /var/lib/apt/lists/*

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

# Add the vTiger specific PHP configurations to fix the red warnings
RUN { \
    echo 'display_errors = Off'; \
    echo 'file_uploads = On'; \
    echo 'post_max_size = 256M'; \
    echo 'upload_max_filesize = 256M'; \
    echo 'memory_limit = 512M'; \
    echo 'max_execution_time = 300'; \
    echo 'date.timezone = UTC'; \
    } > /usr/local/etc/php/conf.d/vtiger-php.ini

RUN a2enmod rewrite