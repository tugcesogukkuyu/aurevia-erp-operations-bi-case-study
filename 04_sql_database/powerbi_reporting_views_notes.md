# Power BI Reporting Views Notes

This document explains the SQL Server reporting view layer created for the Aurevia ERP Operations & BI Dashboard Case Study.

## 1. Purpose

The purpose of the reporting view layer is to prepare the synthetic ERP dataset for Power BI reporting.

Instead of connecting Power BI directly to raw transactional ERP tables, reporting views were created in SQL Server to provide clean, business-ready analytical outputs.

This approach makes the project more realistic and closer to professional reporting workflows.

## 2. SQL Script

The reporting views were created using the following script:

```text
04_sql_database/powerbi_reporting_views.sql
```

## 3. Created Views

The following SQL Server views were created:

| View Name                       | Purpose                                                                 |
| ------------------------------- | ----------------------------------------------------------------------- |
| vw_ExecutiveKPI                 | Provides high-level management KPIs                                     |
| vw_MonthlySalesPerformance      | Provides monthly revenue, cost, gross profit and margin trends          |
| vw_CustomerSegmentPerformance   | Analyzes revenue, margin and collection performance by customer segment |
| vw_ProductCategoryProfitability | Analyzes revenue, cost and margin by product category                   |
| vw_InventoryRisk                | Identifies products below reorder level and negative stock risk         |
| vw_ReceivablesAging             | Provides invoice aging, open balance and collection risk analysis       |
| vw_SupplierPerformance          | Measures supplier delay rate, average delay days and purchase volume    |
| vw_SalesChannelPerformance      | Compares revenue, margin and average order value by sales channel       |

## 4. Professional Reporting Logic

The reporting view layer supports the Power BI dashboard by preparing business-ready datasets for each dashboard page.

### Executive Overview

Main source:

```text
vw_ExecutiveKPI
```

Supports:

* Total revenue
* Total cost
* Gross profit
* Gross margin %
* Sales order count
* Active customer count
* Collection rate %
* Open balance
* Overdue invoice count
* Inventory risk count
* Supplier delay risk count

### Sales Analysis

Main sources:

```text
vw_MonthlySalesPerformance
vw_CustomerSegmentPerformance
vw_SalesChannelPerformance
```

Supports:

* Monthly sales trend
* Revenue by customer segment
* Revenue by sales channel
* Average order value
* Gross margin by segment and channel

### Product & Profitability Analysis

Main source:

```text
vw_ProductCategoryProfitability
```

Supports:

* Revenue by product category
* Cost by product category
* Gross profit by product category
* Gross margin by product category
* Quantity sold by category

### Inventory Risk Dashboard

Main source:

```text
vw_InventoryRisk
```

Supports:

* Current stock on hand
* Reorder level
* Reorder gap
* Products below reorder level
* Negative stock products
* Stock risk status

### Receivables & Collection Dashboard

Main source:

```text
vw_ReceivablesAging
```

Supports:

* Invoice aging buckets
* Total invoice amount
* Paid amount
* Open balance
* Overdue receivables
* Collection risk

### Supplier Performance Dashboard

Main source:

```text
vw_SupplierPerformance
```

Supports:

* Purchase order count
* Delayed purchase order count
* Delay rate %
* Average delay days
* Total purchase amount
* Supplier reliability analysis

## 5. Why Views Were Used

SQL views were used for the following reasons:

* To separate reporting logic from raw ERP transaction tables
* To make Power BI model building cleaner
* To prepare business-ready datasets
* To reduce complexity inside Power BI
* To simulate a professional BI reporting architecture
* To make the project more suitable for ERP, business analysis and reporting roles

## 6. Portfolio Relevance

This step is one of the main professional layers of the project.

It shows that the project is not limited to basic ERP portal usage.

The project now includes:

* ERP workflow execution evidence
* SQL Server relational data model
* Large synthetic ERP transaction dataset
* Data quality validation
* Business analysis SQL queries
* SQL reporting view layer
* Power BI-ready analytical structure

This creates a stronger foundation for Power BI dashboard development and final portfolio presentation.
