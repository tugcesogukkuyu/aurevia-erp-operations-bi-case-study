# Aurevia ERP Control API

## Overview

The Aurevia ERP Control API exposes database-backed validation services for two ERP transaction flows:

- Sales order approval
- Goods receipt validation

The API does not duplicate business rules in JavaScript. Core transaction controls remain in Microsoft SQL Server stored procedures, while the Node.js layer handles request validation, database access, response mapping and HTTP delivery.

This design provides a clear separation between:

- ERP business rules
- Database transaction controls
- API contracts
- Client applications
- Automated API tests

---

## Architecture

```text
ERP Client / Postman
        |
        v
Express Routes
        |
        v
Controllers
        |
        v
Services
        |
        v
MSSQL Stored Procedures
        |
        v
AureviaERPBI
```

### Technical Components

| Layer | Technology | Responsibility |
|---|---|---|
| API runtime | Node.js, Express | HTTP routing and application lifecycle |
| Controller layer | JavaScript | Input validation and HTTP response handling |
| Service layer | JavaScript, `mssql` | Stored procedure execution and result mapping |
| Business-rule layer | SQL Server stored procedures | ERP validation decisions |
| Database | Microsoft SQL Server | Transactional and master data |
| API testing | Postman | Contract and business-response validation |

---

## Design Decisions

### Business rules remain in SQL Server

The validation logic is implemented in:

```text
dbo.usp_ValidateSalesOrder
dbo.usp_ValidateGoodsReceipt
```

This prevents rule duplication between the API and database layers.

The API is responsible for:

- validating request shape
- converting request values to SQL types
- executing stored procedures
- mapping SQL result sets to JSON
- returning consistent HTTP responses

### Validation endpoints are decision services

The current endpoints evaluate transactions but do not commit business transactions.

They return one of the supported business decisions:

```text
APPROVED
REJECTED
PENDING_FINANCE_APPROVAL
PENDING_EXCEPTION_APPROVAL
```

This allows an ERP client to decide whether to:

- continue transaction processing
- block the transaction
- request finance approval
- request warehouse exception approval

### Parameterized database calls

All stored procedure inputs are passed through parameterized `mssql` requests.

This avoids dynamic SQL construction in the API layer and preserves SQL type definitions.

### Connection pooling

The API uses a shared SQL Server connection pool configured in:

```text
src/config/database.js
```

The pool is reused across requests and closed during application shutdown.

### Environment-based configuration

Database credentials and runtime settings are loaded from `.env`.

The repository includes:

```text
.env.example
```

The actual `.env` file is excluded from version control.

---

## Project Structure

```text
05_api/
├── postman/
│   └── Aurevia_ERP_Control_API.postman_collection.json
├── src/
│   ├── config/
│   │   └── database.js
│   ├── controllers/
│   │   ├── goodsReceiptController.js
│   │   └── salesOrderController.js
│   ├── routes/
│   │   ├── goodsReceiptRoutes.js
│   │   └── salesOrderRoutes.js
│   ├── services/
│   │   ├── goodsReceiptService.js
│   │   └── salesOrderService.js
│   └── server.js
├── .env.example
├── .gitignore
├── package-lock.json
└── package.json
```

---

## Runtime Configuration

Create `.env` from `.env.example`.

```env
PORT=3000

DB_SERVER=localhost
DB_PORT=1434
DB_DATABASE=AureviaERPBI
DB_USER=sa
DB_PASSWORD=your_sql_server_password

DB_ENCRYPT=false
DB_TRUST_SERVER_CERTIFICATE=true
```

Install dependencies:

```bash
npm install
```

Start the API:

```bash
npm run dev
```

Production-style start:

```bash
npm start
```

---

## Endpoints

### Health Check

```http
GET /health
```

Validates:

- API availability
- SQL Server connectivity
- active database name

Example response:

```json
{
  "status": "ok",
  "service": "aurevia-erp-control-api",
  "database": {
    "connected": true,
    "name": "AureviaERPBI",
    "checkedAt": "2026-07-28T18:06:35.610Z"
  }
}
```

---

### Sales Order Validation

```http
POST /api/sales-orders/validate
Content-Type: application/json
```

Request:

```json
{
  "userCode": "USR-SALESMGR-01",
  "customerCode": "CUST-002",
  "productCode": "PRD-001",
  "batchNumber": "BATCH-REL-001",
  "warehouseCode": "WH-001",
  "requestedQuantity": 100,
  "orderAmount": 50000,
  "financeApprovalStatus": "NOT_REQUIRED"
}
```

Stored procedure:

```text
dbo.usp_ValidateSalesOrder
```

Validated controls:

- application-user status
- approval-role authorization
- customer and product existence
- batch tracking
- warehouse sales eligibility
- batch quality status
- customer shelf-life requirement
- inventory balance
- available stock
- customer credit block
- projected credit exposure
- finance exception status

Example response summary:

```json
{
  "status": "success",
  "data": {
    "validationStatus": "APPROVED",
    "validationMessage": "Sales order validation completed successfully.",
    "totals": {
      "totalChecks": 16,
      "passedChecks": 16,
      "failedChecks": 0
    }
  }
}
```

---

### Goods Receipt Validation

```http
POST /api/goods-receipts/validate
Content-Type: application/json
```

Request:

```json
{
  "userCode": "USR-WH-01",
  "purchaseOrderCode": "PO-UAT-000001",
  "productCode": "PRD-010",
  "warehouseCode": "WH-001",
  "batchNumber": "BATCH-GR-001",
  "deliveredQuantity": 1000,
  "acceptedQuantity": 850,
  "rejectedQuantity": 50,
  "damagedQuantity": 20,
  "qualityBlockedQuantity": 80,
  "allowedVariancePercentage": 5,
  "varianceReasonCode": null,
  "exceptionApprovalStatus": "NOT_REQUIRED"
}
```

Stored procedure:

```text
dbo.usp_ValidateGoodsReceipt
```

Validated controls:

- application-user status
- warehouse-role authorization
- purchase-order status
- purchase-order line
- warehouse consistency
- batch and product relationship
- delivered quantity
- quantity reconciliation
- delivery variance
- variance reason
- exception approval
- available-stock classification
- quality-block separation

Example response summary:

```json
{
  "status": "success",
  "data": {
    "validationStatus": "APPROVED",
    "validationMessage": "Goods receipt validation completed successfully.",
    "totals": {
      "totalChecks": 16,
      "passedChecks": 16,
      "failedChecks": 0
    }
  }
}
```

---

## HTTP Behavior

| Condition | HTTP Status |
|---|---:|
| Valid request and completed business validation | 200 |
| Missing or invalid request fields | 400 |
| Stored procedure input error | 400 |
| Database unavailable | 503 for health check |
| Unexpected application error | 500 |
| Unknown route | 404 |

A business result such as `REJECTED` is returned with HTTP `200` because the request was processed successfully and the rejection is a valid ERP decision, not a transport or application failure.

---

## Postman Validation

Collection:

```text
postman/Aurevia_ERP_Control_API.postman_collection.json
```

The collection contains seven requests:

- Health check
- Approved sales order
- Unauthorized sales approval
- Pending finance approval
- Approved goods receipt
- Pending receipt exception
- Invalid quantity breakdown

Execution result:

```text
Requests: 7
Passed: 7
Failed: 0
```

The automated tests verify:

- HTTP response status
- database availability
- business-decision status
- failed validation codes
- finance and warehouse approval routing
- quality-blocked quantity separation

---

## Current Scope

Implemented:

- SQL Server connection pooling
- environment-based configuration
- health endpoint
- sales order validation endpoint
- goods receipt validation endpoint
- structured validation responses
- request validation
- graceful shutdown
- Postman collection with automated assertions

Not implemented in this API scope:

- authentication
- token-based authorization
- transaction creation
- stock reservation writes
- goods receipt posting
- audit-log writes
- deployment configuration

These controls are intentionally outside the current validation-service scope.