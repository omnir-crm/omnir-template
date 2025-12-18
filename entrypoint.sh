#!/bin/bash
set -e

# Check if vTiger is already extracted, if not, extract the tar file
if [ ! -f /var/www/html/index.php ]; then
    echo "Extracting vTiger source from /tmp/vtiger.tar..."
    if [ -f /tmp/vtiger.tar ]; then
        tar -xvf /tmp/vtiger.tar -C /var/www/html/ --strip-components=1
        chown -R www-data:www-data /var/www/html/
        echo "Extraction complete."
    else
        echo "Error: /tmp/vtiger.tar not found. Check your docker-compose volumes."
        exit 1
    fi
fi

exec "$@"