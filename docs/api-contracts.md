# API Contracts - Omnir CRM (vTiger 8.x)

## Overview

Omnir CRM provides a REST-like JSON API via the webservice endpoint. All API operations are handled through a single entry point: `webservice.php`.

## API Configuration

| Property | Value |
|----------|-------|
| Base URL | `http://localhost:8080/webservice.php` |
| API Version | 0.22 |
| Format | JSON |
| Authentication | Session-based with access key |

## Entry Point

**File:** [webservice.php](../webservice.php)

All requests are routed to `webservice.php` which:
1. Parses the `operation` parameter from the request
2. Validates session via `SessionManager`
3. Routes to the appropriate handler via `OperationManager`
4. Returns JSON response with `success` and `result` or `error` fields

## Response Format

### Success Response
```json
{
  "success": true,
  "result": { /* operation-specific data */ }
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Error description"
  }
}
```

## Available Operations

Operations are registered in the `vtiger_ws_operation` database table. Each operation has:
- Handler path (PHP file)
- Handler method (function name)
- Pre-login flag (whether auth is required)
- Type (GET/POST)

### Authentication Operations

| Operation | File | Pre-Login | Description |
|-----------|------|-----------|-------------|
| `login` | [Login.php](../include/Webservices/Login.php) | Yes | Authenticate and get session |
| `logout` | [Logout.php](../include/Webservices/Logout.php) | No | End current session |
| `extendsession` | [ExtendSession.php](../include/Webservices/ExtendSession.php) | Yes | Extend existing session |

### CRUD Operations

| Operation | File | Description |
|-----------|------|-------------|
| `create` | [Create.php](../include/Webservices/Create.php) | Create a new record |
| `retrieve` | [Retrieve.php](../include/Webservices/Retrieve.php) | Get a single record by ID |
| `update` | [Update.php](../include/Webservices/Update.php) | Update an existing record |
| `revise` | [Revise.php](../include/Webservices/Revise.php) | Partial update of a record |
| `delete` | [Delete.php](../include/Webservices/Delete.php) | Delete a record |

### Query Operations

| Operation | File | Description |
|-----------|------|-------------|
| `query` | [Query.php](../include/Webservices/Query.php) | Execute VTQL query |
| `query_related` | [QueryRelated.php](../include/Webservices/QueryRelated.php) | Query related records |

### Metadata Operations

| Operation | File | Description |
|-----------|------|-------------|
| `listtypes` | [ModuleTypes.php](../include/Webservices/ModuleTypes.php) | List available modules |
| `describe` | [DescribeObject.php](../include/Webservices/DescribeObject.php) | Get module schema/fields |
| `getchallenge` | [AuthToken.php](../include/Webservices/AuthToken.php) | Get auth challenge token |

### Relationship Operations

| Operation | File | Description |
|-----------|------|-------------|
| `retrieve_related` | [RetrieveRelated.php](../include/Webservices/RetrieveRelated.php) | Get related records |
| `add_related` | [AddRelated.php](../include/Webservices/AddRelated.php) | Add a relationship |

### Conversion Operations

| Operation | File | Description |
|-----------|------|-------------|
| `convertlead` | [ConvertLead.php](../include/Webservices/ConvertLead.php) | Convert Lead to Contact/Account |
| `convertpotential` | [ConvertPotential.php](../include/Webservices/ConvertPotential.php) | Convert Potential to Quote/Order |

## VTQL Query Language

The API supports VTQL (VTiger Query Language) for querying records:

```sql
SELECT field1, field2 FROM ModuleName WHERE condition LIMIT offset, count;
```

### Query Parser Files
- [VTQL_Lexer.php](../include/Webservices/VTQL_Lexer.php) - Tokenizer
- [VTQL_Parser.php](../include/Webservices/VTQL_Parser.php) - Parser

## Authentication Flow

1. **Get Challenge Token**
   ```
   POST /webservice.php
   operation=getchallenge&username=admin
   ```

2. **Login with Access Key**
   ```
   POST /webservice.php
   operation=login&username=admin&accessKey=<md5(token+accesskey)>
   ```

3. **Use Session for Subsequent Requests**
   ```
   POST /webservice.php
   operation=listtypes&sessionName=<sessionId>
   ```

## Entity ID Format

All entity IDs in the API are prefixed with the module's webservice ID:
- Format: `{webserviceObjectId}x{recordId}`
- Example: `4x123` (Accounts module ID 4, record ID 123)

## Key Implementation Files

| File | Purpose |
|------|---------|
| [OperationManager.php](../include/Webservices/OperationManager.php) | Routes operations to handlers |
| [SessionManager.php](../include/Webservices/SessionManager.php) | Manages API sessions |
| [WebserviceEntityOperation.php](../include/Webservices/WebserviceEntityOperation.php) | Base entity operations |
| [VtigerModuleOperation.php](../include/Webservices/VtigerModuleOperation.php) | Module-specific operations |
| [DataTransform.php](../include/Webservices/DataTransform.php) | Data transformation utilities |
| [Utils.php](../include/Webservices/Utils.php) | Helper functions |

## Error Codes

Defined in [WebServiceErrorCode.php](../include/Webservices/WebServiceErrorCode.php):

| Code | Description |
|------|-------------|
| `AUTHENTICATION_REQUIRED` | Session not provided or invalid |
| `INVALID_USER` | User credentials are invalid |
| `INVALID_OPERATION` | Requested operation doesn't exist |
| `PERMISSION_DENIED` | User lacks permission for this operation |
| `RECORD_NOT_FOUND` | Requested record doesn't exist |
| `DUPLICATE_RECORD` | Record with same unique field exists |
| `INTERNAL_ERROR` | Server-side error occurred |

## Security Considerations

- API uses session-based authentication (not token-based)
- Access keys are stored in user profile
- CSRF protection via `csrf-magic` library
- All operations check user permissions before execution

## Custom API Extensions

Custom operations can be added in:
- [include/Webservices/Custom/](../include/Webservices/Custom/) - Custom API handlers

Existing custom handlers:
- `ChangePassword.php` - Password change operation
- `DeleteUser.php` - User deletion
- `VtigerCompanyDetails.php` - Company info retrieval
