# Architecture Documentation - Omnir CRM (vTiger 8.x)

## Executive Summary

Omnir CRM is a containerized vTiger CRM 8.x deployment tailored for custom CRM development and module customization. It provides a PHP 8.1/MySQL 5.7 stack wrapped in Docker for consistent development environments across teams.

## Technology Stack

| Category | Technology | Version | Purpose |
|----------|------------|---------|---------|
| Language | PHP | 8.1+ | Server-side application |
| Framework | vTiger CRM | 8.4.0 | CRM platform with custom MVC |
| Web Server | Apache | 2.4 | HTTP server with mod_rewrite |
| Database | MySQL | 5.7 | Relational data storage |
| Template Engine | Smarty | 4.3+ | View rendering |
| Containerization | Docker | - | Environment isolation |
| Package Manager | Composer | - | PHP dependency management |

### Key Dependencies

| Package | Purpose |
|---------|---------|
| smarty/smarty | Template engine for views |
| tecnickcom/tcpdf | PDF document generation |
| phpmailer/phpmailer | Email sending |
| monolog/monolog | Application logging |
| league/oauth2-client | OAuth2 authentication |
| guzzlehttp/guzzle | HTTP client for integrations |

## Architecture Pattern

**Module-based MVC with Custom Autoloader**

The application follows a module-centric MVC architecture where:
- Each CRM entity (Accounts, Contacts, etc.) is a self-contained module
- Modules follow a consistent internal structure (models, views, actions)
- A custom autoloader (`Vtiger_Loader`) maps class names to file paths
- Inheritance fallback allows core functionality to be overridden per-module

```
┌──────────────────────────────────────────────────────────────┐
│                      Entry Points                             │
│  index.php (Web UI)  │  webservice.php (API)  │  cron.php    │
└──────────────────────┼───────────────────────┼───────────────┘
                       │                       │
                       ▼                       ▼
┌──────────────────────────────────────────────────────────────┐
│                   Request Routing                             │
│            Vtiger_Loader (Class Autoloading)                  │
└──────────────────────────────────────────────────────────────┘
                       │
        ┌──────────────┼──────────────┐
        ▼              ▼              ▼
┌────────────┐  ┌────────────┐  ┌────────────┐
│   Views    │  │  Actions   │  │   Models   │
│  (*.View)  │  │ (*.Action) │  │  (*Model)  │
└─────┬──────┘  └─────┬──────┘  └─────┬──────┘
      │               │               │
      ▼               ▼               ▼
┌──────────────────────────────────────────────────────────────┐
│                   Core Framework                              │
│   CRMEntity  │  PearDatabase  │  Vtiger Library (vtlib/)     │
└──────────────────────────────────────────────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────────────────────┐
│                     Data Layer                                │
│                   MySQL Database                              │
│        (vtiger_crmentity, module tables, custom fields)       │
└──────────────────────────────────────────────────────────────┘
```

## Module Architecture

Each module follows this standard structure:

```
modules/{ModuleName}/
├── {ModuleName}.php      # Entity class (table definitions, field mappings)
├── {ModuleName}Ajax.php  # AJAX request handlers
├── actions/              # POST request handlers (Save, Delete, etc.)
│   ├── Save.php
│   └── Delete.php
├── models/               # Business logic and data access
│   ├── Record.php        # Single record operations
│   ├── Module.php        # Module-level operations
│   └── ListView.php      # List view configuration
└── views/                # GET request handlers (UI rendering)
    ├── Detail.php        # Record detail view
    ├── Edit.php          # Record edit form
    └── List.php          # Record list view
```

### Component Resolution Chain

1. **Module-specific:** `modules/{Module}/{type}/{Component}.php`
2. **Parent module:** (for submodules) `modules/{Parent}/{type}/{Component}.php`
3. **Fallback:** `modules/Vtiger/{type}/{Component}.php`

## Data Architecture

### Entity Model

All CRM entities share a common base table and module-specific tables:

```sql
-- Common base (all entities)
vtiger_crmentity (crmid, smownerid, setype, created_time, ...)

-- Module-specific data
vtiger_{module} ({module}id, field1, field2, ...)

-- Custom fields
vtiger_{module}scf ({module}id, cf_XXX, ...)

-- Address data (optional)
vtiger_{module}billads, vtiger_{module}shipads
```

### Key Relationships

- **One-to-Many:** Account → Contacts, Account → Potentials
- **Many-to-Many:** via `vtiger_crmentityrel` junction table
- **Parent-Child:** via `parentid` references in entity tables

## API Design

### REST-like Webservice API

**Endpoint:** `/webservice.php`

All operations are routed through a single endpoint with operation-based dispatch:

```
POST /webservice.php
Content-Type: application/x-www-form-urlencoded

operation=retrieve&sessionName=xxx&id=4x123
```

**Response Format:**
```json
{
  "success": true,
  "result": { ... }
}
```

### API Operations

| Category | Operations |
|----------|-----------|
| Authentication | login, logout, getchallenge, extendsession |
| CRUD | create, retrieve, update, revise, delete |
| Query | query, query_related |
| Metadata | listtypes, describe |
| Relations | retrieve_related, add_related |

## Deployment Architecture

### Docker Setup

```yaml
services:
  vtiger:
    build: .                  # PHP 8.1 + Apache
    container_name: omnir_crm_app
    ports: ["8080:80"]
    volumes:
      - ./vtiger-data:/var/www/html
    depends_on: [db]

  db:
    image: mysql:5.7
    container_name: omnir_crm_db
    volumes:
      - ./db-data:/var/lib/mysql
      - ./vtiger_base_setup.sql:/docker-entrypoint-initdb.d/setup.sql
```

### Container Configuration

| Setting | Value |
|---------|-------|
| PHP Memory Limit | 512MB |
| Max Execution Time | 300s |
| Upload Limit | 256MB |
| Apache mod_rewrite | Enabled |

## Security Architecture

### Authentication

- **Web UI:** Session-based with CSRF protection via `csrf-magic` library
- **API:** Challenge-response authentication with session tokens
- **Passwords:** Hashed storage (bcrypt)

### Authorization

- Role-based access control (RBAC)
- Module-level permissions
- Field-level permissions via profiles
- Sharing rules for record access

### Security Headers

Configured in `config.security.php`:
- CSRF token validation
- XSS protection headers
- Session security settings

## Integration Points

### External Integrations

| Integration | Method | Files |
|-------------|--------|-------|
| Email (SMTP) | PHPMailer | `cron/send_mail.php` |
| Google OAuth | OAuth2 | `include/Zend/Oauth/`, `oauth2callback/` |
| PDF Generation | TCPDF | `include/InventoryPDFController.php` |

### Extension Points

1. **Custom Modules:** Add to `modules/` directory
2. **Custom Fields:** Database-driven, managed via Settings
3. **Workflows:** `com_vtiger_workflow` module
4. **Custom API:** Add to `include/Webservices/Custom/`
5. **Custom Events:** Event handler system in `include/events/`

## Testing Strategy

### Current State

- No automated test suite included
- Manual testing via browser
- Database queries for verification

### Recommended Approach

1. **Unit Tests:** PHPUnit for model logic
2. **Integration Tests:** API endpoint testing
3. **E2E Tests:** Selenium/Playwright for UI flows

## Performance Considerations

### Caching

- Smarty template caching (`templates_c/`)
- Database query caching (configurable)
- Module metadata caching

### Optimization Points

- Index-heavy database design
- Lazy loading of module metadata
- AJAX-based UI updates

## Source Tree Reference

See [source-tree-analysis.md](./source-tree-analysis.md) for detailed directory structure.

## Key Files Quick Reference

| Purpose | File |
|---------|------|
| Main config | [config.php](../config.php) |
| DB config | [config.db.php](../config.db.php) |
| Class autoloader | [includes/Loader.php](../includes/Loader.php) |
| Base entity class | [data/CRMEntity.php](../data/CRMEntity.php) |
| Database layer | [include/database/PearDatabase.php](../include/database/PearDatabase.php) |
| API entry | [webservice.php](../webservice.php) |
| API router | [include/Webservices/OperationManager.php](../include/Webservices/OperationManager.php) |
