# Development Guide - Omnir CRM (vTiger 8.x)

## Prerequisites

### Required Software
- **Docker Desktop** - [Download](https://www.docker.com/products/docker-desktop/)
- **Git** - [Download](https://git-scm.com/)
- **Code Editor** - VS Code recommended with PHP extensions

### System Requirements
- **Memory:** Minimum 4GB RAM (8GB recommended)
- **Disk:** Minimum 5GB free space
- **OS:** Windows, macOS, or Linux

## Environment Setup

### 1. Clone the Repository

```bash
git clone https://github.com/omnir-crm/omnir-template.git
cd omnir-template
```

### 2. Windows Line Endings Fix

**Critical for Windows users:**
```bash
git config core.autocrlf false
```

Ensure `entrypoint.sh` uses LF line endings (not CRLF).

### 3. Start the Environment

```bash
docker-compose up -d --build
```

This will:
1. Build the PHP 8.1/Apache container
2. Start the MySQL 5.7 database container
3. Seed the database from `vtiger_base_setup.sql`

### 4. Access the Application

| Service | URL | Port |
|---------|-----|------|
| CRM Web UI | http://localhost:8080 | 8080 |
| MySQL Database | localhost | 3306 |

## Database Configuration

### Initial Setup Credentials

During the vTiger setup wizard, use these credentials:

| Field | Value |
|-------|-------|
| Database Type | MySQL |
| Host Name | `db` |
| User Name | `vtiger_user` |
| Password | `vtiger_password` |
| Database Name | `vtiger_crm` |
| Root User | `root` |
| Root Password | `root_password` |

### Direct Database Access

```bash
# Connect to MySQL container
docker exec -it omnir_crm_db mysql -u vtiger_user -p vtiger_crm
# Password: vtiger_password
```

## Development Workflow

### Code Structure

When creating or modifying functionality:

1. **Models** - Business logic and data access
   - Location: `modules/{Module}/models/`
   - Base class: `Vtiger_Record_Model`

2. **Views** - UI controllers
   - Location: `modules/{Module}/views/`
   - Base class: `Vtiger_View_Controller`

3. **Actions** - Form handlers and operations
   - Location: `modules/{Module}/actions/`
   - Base class: `Vtiger_Action_Controller`

4. **Templates** - Smarty template files
   - Location: `layouts/v7/modules/{Module}/`
   - Extension: `.tpl`

### Class Naming Convention

```
{ModuleName}_{ComponentName}_{Type}

Examples:
- Accounts_Detail_View
- Contacts_Record_Model
- Leads_Save_Action
```

### File Path Mapping

```
Accounts_Detail_View → modules/Accounts/views/Detail.php
Contacts_Record_Model → modules/Contacts/models/Record.php
```

## Creating a New Module

### 1. Copy Module Template

```bash
cp -r vtlib/ModuleDir/v7 modules/NewModule
```

### 2. Rename Files

```
modules/NewModule/
├── ModuleFile.php → NewModule.php
├── ModuleFileAjax.php → NewModuleAjax.php
└── ModuleFile.js → NewModule.js
```

### 3. Update Class Definition

In `NewModule.php`:
```php
class NewModule extends CRMEntity {
    var $table_name = "vtiger_newmodule";
    var $table_index = 'newmoduleid';
    var $tab_name = Array('vtiger_crmentity', 'vtiger_newmodule');
    var $tab_name_index = Array(
        'vtiger_crmentity' => 'crmid',
        'vtiger_newmodule' => 'newmoduleid'
    );
    // ... configure fields
}
```

### 4. Register Module

Use the vTiger module installer or SQL scripts.

## Local Development Overrides

### Config Override File

Create `config_override.php` for local settings:

```php
<?php
// Development mode settings
$DEVELOPMENT_MODE = true;
$root_directory = dirname(__FILE__) . '/';
```

### Performance Settings

In `config.performance.php`:
```php
$PERFORMANCE_CONFIG = array(
    'CACHING_DISABLED' => true,  // Disable caching for development
    'LOG_SQL_QUERIES' => true,   // Log all SQL queries
);
```

## Build Process

This is a PHP application - no build step required.

### Composer Dependencies

```bash
# Install dependencies (inside container)
docker exec -it omnir_crm_app composer install

# Update dependencies
docker exec -it omnir_crm_app composer update
```

### Clear Cache

```bash
# Clear Smarty template cache
rm -rf layouts/v7/templates_c/*

# Clear other caches
rm -rf test/templates_c/*
```

## Testing

### Manual Testing

1. Access the CRM at http://localhost:8080
2. Login with admin credentials
3. Navigate to the module under test

### Database Testing

```bash
# Run a test query
docker exec -it omnir_crm_db mysql -u vtiger_user -pvtiger_password vtiger_crm -e "SELECT * FROM vtiger_users LIMIT 1;"
```

## Debugging

### PHP Errors

Errors are displayed in the browser when `display_errors` is enabled (see Dockerfile).

### Log Files

```bash
# View Apache error logs
docker logs omnir_crm_app

# View application logs
docker exec -it omnir_crm_app tail -f /var/www/html/logs/vtiger.log
```

### Enable SQL Logging

In `config.performance.php`:
```php
$PERFORMANCE_CONFIG['LOG_SQL_QUERIES'] = true;
```

## Common Commands

```bash
# Start environment
docker-compose up -d

# Stop environment
docker-compose down

# Rebuild containers
docker-compose up -d --build

# View logs
docker-compose logs -f

# Shell into PHP container
docker exec -it omnir_crm_app bash

# Shell into MySQL container
docker exec -it omnir_crm_db bash
```

## Troubleshooting

### Issue: Entrypoint script fails

**Cause:** Windows CRLF line endings
**Solution:**
```bash
git config core.autocrlf false
# Re-clone or convert entrypoint.sh to LF
```

### Issue: Cannot connect to database

**Cause:** Container not ready
**Solution:** Wait for MySQL container to fully initialize (check logs)

### Issue: Permission denied on files

**Cause:** Docker volume permissions
**Solution:**
```bash
docker exec -it omnir_crm_app chown -R www-data:www-data /var/www/html
```

### Issue: Memory exhaustion

**Cause:** PHP memory limit
**Solution:** Already set to 512M in Dockerfile. Increase if needed:
```bash
docker exec -it omnir_crm_app sed -i 's/memory_limit = 512M/memory_limit = 1024M/' /usr/local/etc/php/conf.d/vtiger-php.ini
```

## IDE Configuration

### VS Code Extensions

- PHP Intelephense
- PHP Debug
- Docker
- Smarty Template Language

### PHPStorm

Configure path mappings:
- Local: `./` → Container: `/var/www/html`

## Code Style

vTiger follows these conventions:
- Tabs for indentation (not spaces)
- CamelCase for class names
- snake_case for database columns
- PascalCase for PHP methods
