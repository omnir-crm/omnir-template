# Project Overview - Omnir CRM

## Purpose

Omnir CRM is a containerized vTiger CRM 8.x development environment designed for custom CRM development and module customization. It provides a consistent PHP 8.1/MySQL 5.7 stack for all developers regardless of their local operating system.

## Technology Summary

| Layer | Technology |
|-------|------------|
| **Language** | PHP 8.1 |
| **Database** | MySQL 5.7 |
| **Web Server** | Apache 2.4 |
| **Framework** | vTiger CRM 8.4.0 |
| **Template Engine** | Smarty 4.3+ |
| **Containerization** | Docker |

## Architecture Type

**Monolith / Module-based MVC**

- Single deployable application
- Self-contained module system for CRM entities
- Custom class autoloader with inheritance fallback
- REST-like API via single webservice endpoint

## Key Characteristics

| Aspect | Description |
|--------|-------------|
| **Repository Type** | Monolith |
| **Project Type** | Backend (PHP web application) |
| **Entry Points** | index.php (Web), webservice.php (API), vtigercron.php (Cron) |
| **Module Count** | 30+ CRM modules |
| **Database Tables** | 200+ tables |

## Quick Links

| Document | Description |
|----------|-------------|
| [Architecture](./architecture.md) | System architecture and design patterns |
| [Source Tree](./source-tree-analysis.md) | Directory structure and file organization |
| [API Contracts](./api-contracts.md) | REST API documentation |
| [Data Models](./data-models.md) | Database schema and entity relationships |
| [Development Guide](./development-guide.md) | Setup and development workflow |

## Getting Started

```bash
# Clone repository
git clone https://github.com/omnir-crm/omnir-template.git
cd omnir-template

# Start environment
docker-compose up -d --build

# Access CRM
open http://localhost:8080
```

## CRM Modules

Core modules included:
- **Sales:** Accounts, Contacts, Leads, Potentials
- **Support:** HelpDesk (Tickets)
- **Inventory:** Products, Quotes, Invoice, Sales Order, Purchase Order
- **Activity:** Calendar, Events
- **Marketing:** Campaigns
- **Documents:** Document management
- **Reports:** Reporting engine
- **Settings:** System configuration

## Customization Points

1. **New Modules** - Add to `modules/` directory
2. **Custom Fields** - Via Settings UI or database
3. **Workflows** - Visual workflow builder
4. **API Extensions** - `include/Webservices/Custom/`
5. **UI Themes** - `layouts/v7/skins/`
