# SQL Server Execution Notes

This document records the SQL Server setup and table creation validation for the Aurevia ERP Operations & BI Dashboard Case Study.

## 1. SQL Server Environment

A separate SQL Server Docker container was created for this project in order to keep previous project databases untouched.

## 2. Connection Information

| Field           | Value                                   |
| --------------- | --------------------------------------- |
| SQL Server Host | localhost                               |
| SQL Server Port | 1434                                    |
| Database Name   | AureviaERPBI                            |
| SQL User        | sa                                      |
| Tool            | Visual Studio Code with MSSQL extension |

## 3. Table Creation Script

The database and tables were created using the following script:

```text
04_sql_database/create_tables.sql
```

## 4. Created Database

```text
AureviaERPBI
```

## 5. Created Tables

The following tables were successfully created and validated:

* Customers
* Suppliers
* Products
* Warehouses
* PurchaseOrders
* PurchaseOrderLines
* SalesOrders
* SalesOrderLines
* StockMovements
* Invoices
* Payments
* DateDim

## 6. Validation Query

The table creation was validated with the following SQL query:

```sql
USE AureviaERPBI;
GO

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
```

## 7. Result

The validation query returned all expected base tables successfully.

This confirms that the SQL Server relational data model was created and is ready for synthetic ERP data insertion.
