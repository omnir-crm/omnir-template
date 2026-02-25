#!/bin/bash
set -e

# Ensure writable directories exist with correct ownership
if [ -d /var/www/html ]; then
    mkdir -p /var/www/html/storage /var/www/html/logs /var/www/html/test/templates_c /var/www/html/test/logo
    chown -R www-data:www-data /var/www/html/storage /var/www/html/logs /var/www/html/test 2>/dev/null || true
fi

exec "$@"
