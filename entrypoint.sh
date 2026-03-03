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

# Generate config.inc.php from environment variables if it doesn't exist
if [ ! -f "$APP_DIR/config.inc.php" ] && [ -n "$VT_DB_HOST" ]; then
    echo "Generating config.inc.php from environment variables..."
    APP_KEY=$(head -c 32 /dev/urandom | md5sum | head -c 32)
    cat > "$APP_DIR/config.inc.php" <<EOCFG
<?php
error_reporting(E_WARNING & ~E_NOTICE & ~E_DEPRECATED & E_ERROR & ~E_STRICT);

include('vtigerversion.php');

ini_set('memory_limit','512M');

\$CALENDAR_DISPLAY = 'true';
\$USE_RTE = 'true';

\$HELPDESK_SUPPORT_EMAIL_ID = '${VT_SUPPORT_EMAIL:-support@example.com}';
\$HELPDESK_SUPPORT_NAME = '${VT_SUPPORT_NAME:-Support}';
\$HELPDESK_SUPPORT_EMAIL_REPLY_ID = \$HELPDESK_SUPPORT_EMAIL_ID;

\$dbconfig['db_server'] = '${VT_DB_HOST}';
\$dbconfig['db_port'] = ':${VT_DB_PORT:-3306}';
\$dbconfig['db_username'] = '${VT_DB_USER}';
\$dbconfig['db_password'] = '${VT_DB_PASSWORD}';
\$dbconfig['db_name'] = '${VT_DB_NAME}';
\$dbconfig['db_type'] = 'mysqli';
\$dbconfig['db_status'] = 'true';
\$dbconfig['db_hostname'] = \$dbconfig['db_server'].\$dbconfig['db_port'];
\$dbconfig['log_sql'] = false;

\$dbconfigoption['persistent'] = true;
\$dbconfigoption['autofree'] = false;
\$dbconfigoption['debug'] = 0;
\$dbconfigoption['seqname_format'] = '%s_seq';
\$dbconfigoption['portability'] = 0;
\$dbconfigoption['ssl'] = false;

\$host_name = \$dbconfig['db_hostname'];

\$site_URL = '${VT_SITE_URL:-http://localhost:8080/}';
\$PORTAL_URL = \$site_URL.'/customerportal';
\$root_directory = '${APP_DIR}/';
\$cache_dir = 'cache/';
\$tmp_dir = 'cache/images/';
\$import_dir = 'cache/import/';
\$upload_dir = 'cache/upload/';
\$upload_maxsize = 3145728;

\$allow_exports = 'all';

\$upload_badext = array('php', 'php3', 'php4', 'php5', 'pl', 'cgi', 'py', 'asp', 'cfm', 'js', 'vbs', 'html', 'htm', 'exe', 'bin', 'bat', 'sh', 'dll', 'phps', 'phtml', 'xhtml', 'rb', 'msi', 'jsp', 'shtml', 'sth', 'shtm', 'htaccess', 'phar');

\$list_max_entries_per_page = '20';
\$history_max_viewed = '5';
\$default_action = 'index';
\$default_theme = 'softed';
\$default_user_name = '';
\$default_password = '';
\$create_default_user = false;
\$currency_name = 'USA, Dollars';
\$default_charset = 'UTF-8';
\$default_language = 'en_us';
\$display_empty_home_blocks = false;
\$disable_stats_tracking = false;
\$application_unique_key = '${APP_KEY}';
\$listview_max_textlength = 40;
\$php_max_execution_time = 0;
\$default_timezone = 'UTC';

if(isset(\$default_timezone) && function_exists('date_default_timezone_set')) {
    @date_default_timezone_set(\$default_timezone);
}

\$default_layout = 'v7';
\$maxListFieldsSelectionSize = 15;

include_once 'config.security.php';
?>
EOCFG
    chown www-data:www-data "$APP_DIR/config.inc.php"
    echo "config.inc.php generated successfully"
fi

# Update site_URL if VT_SITE_URL is set and config.inc.php already exists
if [ -n "$VT_SITE_URL" ] && [ -f "$APP_DIR/config.inc.php" ]; then
    sed -i "s|\\\$site_URL = .*|\\\$site_URL = '${VT_SITE_URL}';|g" "$APP_DIR/config.inc.php"
    echo "Updated site_URL to $VT_SITE_URL"
fi

# Ensure writable directories exist with correct ownership
mkdir -p "$APP_DIR/storage" "$APP_DIR/logs" "$APP_DIR/cache" \
         "$APP_DIR/cache/images" "$APP_DIR/cache/import" "$APP_DIR/cache/upload" \
         "$APP_DIR/test/templates_c" "$APP_DIR/test/logo" \
         "$APP_DIR/user_privileges"
chown -R www-data:www-data "$APP_DIR/storage" "$APP_DIR/logs" "$APP_DIR/cache" \
                           "$APP_DIR/test" "$APP_DIR/user_privileges" 2>/dev/null || true

exec "$@"
