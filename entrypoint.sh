#!/bin/bash
set -e

APP_DIR=/var/www/html

# Rename htaccess.txt if .htaccess is missing (volume mount overrides build-time copy)
if [ ! -f "$APP_DIR/.htaccess" ] && [ -f "$APP_DIR/htaccess.txt" ]; then
    cp "$APP_DIR/htaccess.txt" "$APP_DIR/.htaccess"
    echo "Created .htaccess from htaccess.txt"
fi

# Install composer dependencies if missing (volume mount may override vendor/)
if [ -f "$APP_DIR/composer.json" ] && [ ! -f "$APP_DIR/vendor/autoload.php" ]; then
    echo "Installing composer dependencies..."
    composer install --no-dev --no-interaction --working-dir="$APP_DIR" 2>/dev/null || true
fi

# Update site_URL if VT_SITE_URL is set and config.inc.php exists
if [ -n "$VT_SITE_URL" ] && [ -f "$APP_DIR/config.inc.php" ]; then
    sed -i "s|\\\$site_URL = .*|\\\$site_URL = '${VT_SITE_URL}';|g" "$APP_DIR/config.inc.php"
    echo "Updated site_URL to $VT_SITE_URL"
fi

# Ensure writable directories exist with correct ownership
mkdir -p "$APP_DIR/storage" "$APP_DIR/logs" "$APP_DIR/cache" \
         "$APP_DIR/test/templates_c" "$APP_DIR/test/logo" \
         "$APP_DIR/user_privileges"
chown -R www-data:www-data "$APP_DIR/storage" "$APP_DIR/logs" "$APP_DIR/cache" \
                           "$APP_DIR/test" "$APP_DIR/user_privileges" 2>/dev/null || true

exec "$@"
