# Synthetic ERP Data Seed Execution Notes

This document records the execution result of the synthetic ERP data seed script for the Aurevia ERP Operations & BI Dashboard Case Study.

## 1. Purpose

The purpose of this step was to populate the SQL Server database with a realistic synthetic ERP dataset.

The Odoo ERP layer demonstrates hands-on operational workflow execution.

The SQL Server synthetic data layer extends this workflow into a larger dataset suitable for professional Power BI reporting, KPI analysis, process monitoring and business decision support.

## 2. Script Executed

The synthetic ERP dataset was generated using the following SQL script:

```text
04_sql_database/seed_synthetic_data.sql
```

## 3. Database

```text
AureviaERPBI
```

## 4. Execution Result

The seed script was executed successfully.

The following row counts were generated:

| Table              | Row Count |
| ------------------ | --------: |
| Customers          |       150 |
| Suppliers          |        10 |
| Products           |        82 |
| Warehouses         |         3 |
| PurchaseOrders     |       800 |
| PurchaseOrderLines |     2,392 |
| SalesOrders        |     3,000 |
| SalesOrderLines    |     8,918 |
| StockMovements     |    10,881 |
| Invoices           |     3,000 |
| Payments           |     2,731 |
| DateDim            |       546 |

## 5. Business Interpretation

The generated dataset simulates an ERP-based B2B wellness supply business across an 18-month operational period.

The data includes customer master records, supplier master records, product and service records, warehouse locations, purchase orders, sales orders, stock movements, invoices and payments.

This dataset enables professional-level analysis across the following areas:

* Sales performance
* Revenue trend analysis
* Customer segment performance
* Product and category profitability
* Inventory movement analysis
* Stock risk monitoring
* Supplier purchasing analysis
* Invoice and payment tracking
* Collection performance
* Overdue receivables analysis

## 6. Portfolio Relevance

This step is one of the core professional layers of the project.

It demonstrates that the project is not limited to basic ERP screen usage.

Instead, it shows the ability to model ERP processes as relational data, generate realistic transaction volume, prepare data for business intelligence reporting and support decision-making through SQL Server and Power BI.
