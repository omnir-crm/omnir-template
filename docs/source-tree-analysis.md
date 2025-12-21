# Source Tree Analysis - Omnir CRM (vTiger 8.x)

## Project Root Structure

```
omnir-template/
├── .claude/                   # Claude Code configuration
├── _bmad/                     # BMAD workflow configuration
├── config.php                 # [ENTRY] Main application configuration
├── config.db.php              # Database connection template
├── config.performance.php     # Performance tuning settings
├── config.security.php        # Security settings (CSRF, etc.)
├── config_override.dev.php    # Local development overrides
├── composer.json              # PHP dependencies
├── composer.lock              # Locked dependency versions
├── cron/                      # Scheduled task handlers
├── data/                      # Core entity classes
├── docker-compose.yml         # Docker service definitions
├── Dockerfile                 # Container build instructions
├── entrypoint.sh              # Container startup script
├── include/                   # Core libraries and utilities
├── includes/                  # Autoloader and main components
├── kcfinder/                  # File manager component
├── languages/                 # Localization files
├── layouts/                   # UI templates (Smarty)
├── libraries/                 # Third-party PHP libraries
├── license/                   # License files
├── migrate/                   # Database migration scripts
├── modules/                   # [CRITICAL] CRM module implementations
├── oauth2callback/            # OAuth callback handlers
├── pkg/                       # Package distribution files
├── resources/                 # Static resources (fonts, etc.)
├── schema/                    # Database schema definitions
├── vendor/                    # Composer dependencies
├── vtlib/                     # vTiger core library
├── webservice.php             # [ENTRY] REST API endpoint
├── index.php                  # [ENTRY] Web application entry
├── vtigercron.php             # [ENTRY] Cron job runner
└── vtiger_base_setup.sql      # Initial database seed
```

## Critical Directories

### modules/ - CRM Entity Modules

**Purpose:** Contains all CRM entity implementations following MVC pattern.

```
modules/
├── Accounts/                  # Company/Organization management
│   ├── Accounts.php          # Main entity class (table definitions)
│   ├── actions/              # Controller actions (Save, Delete, etc.)
│   ├── models/               # Data models (Record, Module, ListView)
│   └── views/                # View controllers (Detail, Edit, List)
├── Contacts/                  # Contact person management
├── Leads/                     # Lead management and conversion
├── Potentials/                # Opportunity/Deal tracking
├── HelpDesk/                  # Support ticket system
├── Calendar/                  # Task scheduling
├── Events/                    # Event scheduling
├── Products/                  # Product catalog
├── Invoice/                   # Invoice generation
├── Quotes/                    # Quote management
├── SalesOrder/                # Sales order processing
├── PurchaseOrder/             # Purchase order management
├── Documents/                 # Document/file management
├── Campaigns/                 # Marketing campaign tracking
├── Emails/                    # Email integration
├── Users/                     # User management
├── Settings/                  # System configuration (sub-modules)
├── Vtiger/                    # [FALLBACK] Base module implementations
│   ├── CRMEntity.php         # Base entity class
│   ├── actions/              # Default action handlers
│   ├── models/               # Base model classes
│   ├── views/                # Default view handlers
│   ├── handlers/             # Event handlers
│   ├── helpers/              # Utility helpers
│   └── uitypes/              # UI field type handlers
├── com_vtiger_workflow/       # Workflow automation engine
├── Install/                   # Installation wizard
├── Migration/                 # Version upgrade handlers
└── Reports/                   # Reporting module
```

### include/ - Core Libraries

**Purpose:** Core application libraries and utilities.

```
include/
├── database/
│   └── PearDatabase.php      # [CRITICAL] Database abstraction layer
├── ListView/
│   ├── ListViewController.php # List view rendering
│   └── ListViewSession.php   # Session state for list views
├── QueryGenerator/
│   ├── QueryGenerator.php    # SQL query builder
│   └── EnhancedQueryGenerator.php
├── Webservices/               # [CRITICAL] REST API implementation
│   ├── AuthToken.php         # Challenge-response auth
│   ├── Create.php            # Record creation
│   ├── Retrieve.php          # Record retrieval
│   ├── Update.php            # Record updates
│   ├── Delete.php            # Record deletion
│   ├── Query.php             # VTQL query execution
│   ├── Login.php             # API authentication
│   ├── OperationManager.php  # [CORE] API routing
│   ├── SessionManager.php    # API session handling
│   └── Custom/               # Custom API extensions
├── fields/                    # Field type handlers
├── events/                    # Event system
├── Zend/                      # Zend library (JSON, OAuth)
└── utils/                     # Utility functions
```

### includes/ - Loader System

**Purpose:** Application bootstrapping and class autoloading.

```
includes/
├── Loader.php                 # [CRITICAL] Vtiger_Loader class autoloader
├── main/
│   └── WebUI.php             # Web UI initialization
└── runtime/                   # Runtime helpers
```

### layouts/ - UI Templates

**Purpose:** Smarty template files for UI rendering.

```
layouts/
├── v7/                        # Version 7 layout (current)
│   ├── modules/              # Module-specific templates
│   │   ├── Vtiger/           # Base templates (inherited by all)
│   │   ├── Accounts/         # Account-specific views
│   │   ├── Contacts/         # Contact-specific views
│   │   └── ...               # Other modules
│   ├── lib/                  # Frontend libraries
│   │   ├── jquery/           # jQuery plugins
│   │   ├── bootstrap/        # Bootstrap CSS/JS
│   │   ├── select2/          # Select2 dropdowns
│   │   └── ...               # Other libraries
│   └── skins/                # CSS themes and fonts
└── vlayout/                   # Legacy layout (deprecated)
```

### vtlib/ - vTiger Core Library

**Purpose:** Core vTiger framework classes.

```
vtlib/
├── Vtiger/
│   ├── Module.php            # Module installation/management
│   ├── Block.php             # Field block management
│   ├── Field.php             # Field creation/management
│   ├── Link.php              # UI link management
│   ├── Event.php             # Event handling
│   ├── Functions.php         # Utility functions
│   ├── PackageExport.php     # Module export
│   └── PackageImport.php     # Module import
└── ModuleDir/                 # Module template directory
    └── v7/                   # v7 module template
```

### data/ - Entity Classes

**Purpose:** Core CRM entity implementations.

```
data/
├── CRMEntity.php             # [CRITICAL] Base entity class
├── Tracker.php               # Activity tracking
└── VTEntityDelta.php         # Change tracking for workflows
```

### cron/ - Scheduled Tasks

**Purpose:** Background job handlers.

```
cron/
├── send_mail.php             # Email queue processor
├── intimateTaskStatus.php    # Task notification sender
├── modules/                  # Module-specific cron jobs
└── language/                 # Cron email templates
```

### vendor/ - Composer Dependencies

**Purpose:** Third-party PHP libraries managed by Composer.

Key packages:
- `smarty/smarty` - Template engine
- `tecnickcom/tcpdf` - PDF generation
- `phpmailer/phpmailer` - Email handling
- `monolog/monolog` - Logging
- `league/oauth2-client` - OAuth authentication
- `guzzlehttp/guzzle` - HTTP client

## Entry Points

| File | Purpose | Access |
|------|---------|--------|
| `index.php` | Web UI entry point | Browser |
| `webservice.php` | REST API endpoint | API clients |
| `vtigercron.php` | Cron job runner | Command line/scheduler |
| `forgotPassword.php` | Password reset | Browser |
| `public.php` | Public portal access | Browser |

## Class Loading Convention

The `Vtiger_Loader` autoloader maps class names to file paths:

```
Class Name: Accounts_Detail_View
File Path:  modules/Accounts/views/Detail.php

Class Name: Contacts_Save_Action
File Path:  modules/Contacts/actions/Save.php

Class Name: Vtiger_Record_Model
File Path:  modules/Vtiger/models/Record.php
```

## Component Resolution Chain

When looking for a component, the loader checks:
1. Module-specific: `modules/{Module}/{type}/{Component}.php`
2. Parent module (if submodule): `modules/{Parent}/{type}/{Component}.php`
3. Fallback: `modules/Vtiger/{type}/{Component}.php`

## Docker Architecture

```
┌─────────────────────────────────────┐
│           Docker Host               │
├─────────────────────────────────────┤
│  ┌─────────────────────────────┐   │
│  │    vtiger (omnir_crm_app)   │   │
│  │    PHP 8.1 + Apache         │   │
│  │    Port: 8080 → 80          │   │
│  └─────────────┬───────────────┘   │
│                │                    │
│                ▼                    │
│  ┌─────────────────────────────┐   │
│  │    db (omnir_crm_db)        │   │
│  │    MySQL 5.7                │   │
│  │    Port: 3306               │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

## File Counts by Directory

| Directory | File Count | Purpose |
|-----------|------------|---------|
| modules/ | 3000+ | CRM modules |
| include/ | 200+ | Core libraries |
| layouts/v7/ | 1000+ | UI templates |
| libraries/ | 500+ | Third-party libs |
| vendor/ | 2000+ | Composer packages |
