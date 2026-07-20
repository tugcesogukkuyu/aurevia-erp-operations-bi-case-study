# Business Analysis SQL Notes

This document explains the professional business analysis queries created for the Aurevia ERP Operations & BI Dashboard Case Study.

## 1. Purpose

The purpose of the business analysis SQL layer is to convert the synthetic ERP dataset into meaningful operational and financial insights before building the Power BI dashboard.

This step demonstrates that the project is not limited to basic ERP screen usage.

The SQL analysis layer focuses on interpreting ERP transaction data across sales, profitability, inventory, receivables, supplier performance and customer segmentation.

## 2. SQL Script

The business analysis queries are stored in:

```text
04_sql_database/business_analysis_queries.sql
```

## 3. Analysis Areas Covered

The SQL analysis script includes the following business analysis areas:

| No | Analysis Area                                  | Business Purpose                                           |
| -: | ---------------------------------------------- | ---------------------------------------------------------- |
|  1 | Monthly Revenue, Cost, Gross Profit and Margin | Track revenue and profitability trends over time           |
|  2 | Revenue and Margin by Customer Segment         | Understand which customer segments create the most value   |
|  3 | Top Customers by Revenue and Open Balance      | Identify key customers and receivables exposure            |
|  4 | Product Category Profitability                 | Analyze category-level revenue, cost and margin            |
|  5 | Inventory Risk Detail                          | Detect products below reorder level or with negative stock |
|  6 | Invoice Aging and Receivables Risk             | Analyze overdue invoices and open balance risk             |
|  7 | Supplier Delivery Performance                  | Evaluate supplier delay rate and delivery reliability      |
|  8 | Sales Channel Performance                      | Compare revenue and margin across sales channels           |
|  9 | Open Balance by Customer Segment               | Understand collection risk by customer group               |
| 10 | Executive KPI Summary                          | Provide high-level management KPIs                         |

## 4. Dashboard Mapping

These SQL queries will be used as the analytical foundation for the Power BI dashboard.

Planned Power BI pages:

### Executive Overview

Based on:

* Executive KPI Summary
* Monthly Revenue, Cost, Gross Profit and Margin
* Collection Rate
* Open Balance
* Gross Margin

### Sales Analysis

Based on:

* Monthly revenue trend
* Customer segment revenue
* Sales channel performance
* Top customers by revenue

### Product & Profitability Analysis

Based on:

* Product category profitability
* Revenue by product category
* Gross margin by product category

### Inventory Risk Dashboard

Based on:

* Inventory risk detail
* Products below reorder level
* Negative stock products
* Warehouse-based stock movement analysis

### Receivables & Collection Dashboard

Based on:

* Invoice aging
* Open balance
* Overdue invoices
* Collection rate by customer segment

### Supplier Performance Dashboard

Based on:

* Supplier delivery performance
* Delayed purchase orders
* Supplier delay rate
* Purchase amount by supplier

## 5. Professional Relevance

This step strengthens the project by showing that the SQL Server dataset is not only populated, but also analyzed from a business perspective.

The queries simulate the type of analysis expected in ERP, business analysis, reporting and Power BI roles.

The analysis analysis, reporting and Power BI roles.

The analysis layer supports:

* ERP data interpretation
* KPI design
* Financial and operational reporting
* Inventory risk analysis
* Receivables monitoring
* Supplier performance tracking
* Management-level decision support

## 6. Portfolio Positioning

The Odoo ERP screenshots are used only as supporting evidence of hands-on ERP workflow execution.

The main professional value of the project comes from:

* SQL Server relational data model
* Synthetic ERP transaction dataset
* Data quality validation
* Business analysis queries
* Power BI dashboard design
* UAT / Go-Live documentation
* Issue and user request analysis

This makes the project suitable for presenting ERP process understanding, SQL analysis capability, business intelligence reporting and operational problem-solving skills together.
