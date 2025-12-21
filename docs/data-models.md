# Data Models - Omnir CRM (vTiger 8.x)

## Overview

Omnir CRM uses MySQL 5.7 as its database backend. The schema follows vTiger CRM's module-based architecture where each CRM entity has its own set of tables.

## Database Configuration

| Property | Value |
|----------|-------|
| Database Type | MySQL 5.7 |
| Default Database | `vtiger_crm` |
| Character Set | UTF-8 |
| Engine | InnoDB |
| Schema File | [vtiger_base_setup.sql](../vtiger_base_setup.sql) |

## Entity Table Architecture

Each CRM module follows a standard table pattern:

```
vtiger_crmentity         - Base entity table (shared by all modules)
vtiger_{module}          - Module-specific data table
vtiger_{module}scf       - Custom fields for the module
vtiger_{module}billads   - Billing address (if applicable)
vtiger_{module}shipads   - Shipping address (if applicable)
```

## Core Tables

### vtiger_crmentity (Base Entity Table)

All CRM records share this base table for common fields.

| Column | Type | Description |
|--------|------|-------------|
| crmid | INT | Primary key (shared across all modules) |
| smcreatorid | INT | Creator user ID |
| smownerid | INT | Owner user ID |
| modifiedby | INT | Last modifier user ID |
| setype | VARCHAR | Module name (e.g., "Accounts") |
| description | TEXT | Record description |
| createdtime | DATETIME | Creation timestamp |
| modifiedtime | DATETIME | Last modification timestamp |
| deleted | TINYINT | Soft delete flag |
| presence | INT | Visibility flag |
| label | VARCHAR | Record label/name |

### vtiger_users

| Column | Type | Description |
|--------|------|-------------|
| id | INT | User ID |
| user_name | VARCHAR | Login username |
| user_password | VARCHAR | Hashed password |
| first_name | VARCHAR | First name |
| last_name | VARCHAR | Last name |
| email1 | VARCHAR | Primary email |
| status | VARCHAR | Active/Inactive |
| is_admin | VARCHAR | Admin flag |
| accesskey | VARCHAR | API access key |
| time_zone | VARCHAR | User timezone |
| date_format | VARCHAR | Preferred date format |

## CRM Module Tables

### Accounts (vtiger_account)

| Column | Type | Description |
|--------|------|-------------|
| accountid | INT | Primary key (FK to crmentity) |
| accountname | VARCHAR | Company name |
| account_type | VARCHAR | Account type |
| industry | VARCHAR | Industry sector |
| annualrevenue | DECIMAL | Annual revenue |
| phone | VARCHAR | Phone number |
| email1 | VARCHAR | Primary email |
| website | VARCHAR | Website URL |

Related tables:
- `vtiger_accountbillads` - Billing address
- `vtiger_accountshipads` - Shipping address
- `vtiger_accountscf` - Custom fields

### Contacts (vtiger_contactdetails)

| Column | Type | Description |
|--------|------|-------------|
| contactid | INT | Primary key |
| firstname | VARCHAR | First name |
| lastname | VARCHAR | Last name |
| email | VARCHAR | Email address |
| phone | VARCHAR | Phone number |
| mobile | VARCHAR | Mobile number |
| accountid | INT | FK to Accounts |
| title | VARCHAR | Job title |
| department | VARCHAR | Department |
| portal | TINYINT | Customer portal access |

### Leads (vtiger_leaddetails)

| Column | Type | Description |
|--------|------|-------------|
| leadid | INT | Primary key |
| firstname | VARCHAR | First name |
| lastname | VARCHAR | Last name |
| email | VARCHAR | Email |
| company | VARCHAR | Company name |
| leadsource | VARCHAR | Lead source |
| leadstatus | VARCHAR | Lead status |
| industry | VARCHAR | Industry |
| annualrevenue | DECIMAL | Annual revenue |

### Potentials/Opportunities (vtiger_potential)

| Column | Type | Description |
|--------|------|-------------|
| potentialid | INT | Primary key |
| potentialname | VARCHAR | Opportunity name |
| related_to | INT | FK to Account/Contact |
| sales_stage | VARCHAR | Sales stage |
| amount | DECIMAL | Deal amount |
| closingdate | DATE | Expected close date |
| probability | DECIMAL | Win probability |

### HelpDesk/Tickets (vtiger_troubletickets)

| Column | Type | Description |
|--------|------|-------------|
| ticketid | INT | Primary key |
| title | VARCHAR | Ticket title |
| status | VARCHAR | Ticket status |
| priority | VARCHAR | Priority level |
| parent_id | INT | Related Account |
| contact_id | INT | Related Contact |
| solution | TEXT | Resolution notes |

## Inventory Module Tables

### Products (vtiger_products)

| Column | Type | Description |
|--------|------|-------------|
| productid | INT | Primary key |
| productname | VARCHAR | Product name |
| productcode | VARCHAR | SKU/Product code |
| unit_price | DECIMAL | Unit price |
| qtyinstock | INT | Quantity in stock |
| discontinued | TINYINT | Active/Discontinued |

### Invoice (vtiger_invoice)

| Column | Type | Description |
|--------|------|-------------|
| invoiceid | INT | Primary key |
| subject | VARCHAR | Invoice subject |
| invoicestatus | VARCHAR | Status |
| invoicedate | DATE | Invoice date |
| accountid | INT | FK to Account |
| contactid | INT | FK to Contact |
| subtotal | DECIMAL | Subtotal amount |
| total | DECIMAL | Total amount |
| taxtype | VARCHAR | Tax calculation type |

### Quote, SalesOrder, PurchaseOrder

Similar structure to Invoice with order-specific fields.

## Workflow Tables

### com_vtiger_workflows

| Column | Type | Description |
|--------|------|-------------|
| workflow_id | INT | Primary key |
| module_name | VARCHAR | Target module |
| summary | VARCHAR | Workflow name |
| test | TEXT | Condition JSON |
| execution_condition | INT | When to execute |
| status | TINYINT | Active/Inactive |

### com_vtiger_workflowtasks

| Column | Type | Description |
|--------|------|-------------|
| task_id | INT | Primary key |
| workflow_id | INT | FK to workflow |
| summary | VARCHAR | Task name |
| task | TEXT | Task config (serialized) |

## Webservice Tables

### vtiger_ws_operation

Defines available API operations.

| Column | Type | Description |
|--------|------|-------------|
| operationid | INT | Primary key |
| name | VARCHAR | Operation name |
| handler_path | VARCHAR | Handler file path |
| handler_method | VARCHAR | PHP function name |
| type | VARCHAR | GET/POST |
| prelogin | INT | Pre-auth allowed |

### vtiger_ws_entity

Maps modules to webservice entities.

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Webservice entity ID |
| name | VARCHAR | Module name |
| handler_path | VARCHAR | Handler file |
| handler_class | VARCHAR | Handler class |

## Custom Field Tables

Each module has a `*scf` table for custom fields:
- `vtiger_accountscf`
- `vtiger_contactscf`
- `vtiger_leadscf`
- etc.

Custom fields are defined in:
- `vtiger_field` - Field definitions
- `vtiger_customview` - Custom list views
- `vtiger_cvcolumnlist` - View columns

## Relationship Tables

### vtiger_crmentityrel

Generic many-to-many relationship table.

| Column | Type | Description |
|--------|------|-------------|
| crmid | INT | Source entity ID |
| module | VARCHAR | Source module |
| relcrmid | INT | Related entity ID |
| relmodule | VARCHAR | Related module |

### Module-Specific Relations

- `vtiger_seproductsrel` - Products to entities
- `vtiger_seactivityrel` - Activities to entities
- `vtiger_senotesrel` - Notes/Documents to entities
- `vtiger_campaignaccountrel` - Campaigns to Accounts

## Picklist/Dropdown Tables

| Table | Purpose |
|-------|---------|
| vtiger_picklist | Picklist definitions |
| vtiger_role2picklist | Role-based picklist access |
| `vtiger_{fieldname}` | Individual picklist values |

## Schema Definition File

**File:** [schema/DatabaseSchema.xml](../schema/DatabaseSchema.xml)

Contains XML schema definition for database structure used during installation/migration.

## Database Access Layer

**File:** [include/database/PearDatabase.php](../include/database/PearDatabase.php)

The `PearDatabase` class provides database abstraction:
- `pquery()` - Parameterized query
- `query()` - Direct query execution
- `num_rows()` - Get row count
- `query_result_rowdata()` - Fetch row as array

## Query Generator

**Directory:** [include/QueryGenerator/](../include/QueryGenerator/)

- `QueryGenerator.php` - Builds complex queries for list views
- `EnhancedQueryGenerator.php` - Extended query capabilities

## Migration

**Directory:** [migrate/](../migrate/)

Contains database migration scripts for version upgrades.
