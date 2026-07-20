# Power BI Dashboard Design Plan

## Aurevia ERP Operations & BI Dashboard Case Study

## 1. Purpose

This document defines the Power BI dashboard design plan for the Aurevia ERP Operations & BI Dashboard Case Study.

The purpose of the dashboard is to convert ERP transaction data into management-level business insights.

The dashboard will focus on:

* Sales performance
* Revenue and profitability
* Customer segment analysis
* Product category performance
* Inventory risk
* Supplier delivery performance
* Invoice and payment tracking
* Receivables and collection risk

This dashboard is designed as the main professional output of the project.

Odoo ERP screenshots are used only as supporting evidence of hands-on ERP workflow execution.

The core professional value comes from SQL Server data modeling, synthetic ERP transaction data, Power BI reporting, KPI design, UAT / Go-Live documentation and issue analysis.

---

## 2. Data Source

Primary data source:

```text
SQL Server Database: AureviaERPBI
Server: localhost,1434
```

Main tables:

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

---

## 3. Planned Dashboard Pages

The Power BI report will include six main pages.

| Page No | Dashboard Page                     | Purpose                                                       |
| ------: | ---------------------------------- | ------------------------------------------------------------- |
|       1 | Executive Overview                 | High-level management KPIs                                    |
|       2 | Sales Analysis                     | Revenue, orders, customer segments and sales channels         |
|       3 | Product & Profitability Analysis   | Product category revenue, cost and gross margin               |
|       4 | Inventory Risk Dashboard           | Stock movement, reorder risk and negative stock               |
|       5 | Receivables & Collection Dashboard | Invoice aging, open balance and collection rate               |
|       6 | Supplier Performance Dashboard     | Supplier delay rate, purchase volume and delivery reliability |

---

## 4. Page 1 — Executive Overview

### Business Question

How is the business performing overall?

### KPIs

* Total Revenue
* Total Cost
* Gross Profit
* Gross Margin %
* Sales Order Count
* Active Customer Count
* Collection Rate %
* Open Balance
* Overdue Invoice Count
* Products Below Reorder Level
* Delayed Purchase Order Count

### Visuals

* KPI cards
* Monthly revenue trend line chart
* Revenue vs gross profit chart
* Collection rate card
* Open balance card
* Business risk summary table

### Business Value

This page gives management a quick overview of financial performance, revenue growth, profitability, collection health and operational risks.

---

## 5. Page 2 — Sales Analysis

### Business Question

Which customers, segments and sales channels generate the most revenue?

### KPIs

* Total Revenue
* Sales Order Count
* Average Order Value
* Revenue by Customer Segment
* Revenue by Sales Channel
* Top Customers by Revenue

### Visuals

* Monthly revenue trend
* Revenue by customer segment bar chart
* Sales channel performance chart
* Top 15 customers table
* Average order value by segment

### Business Value

This page helps identify high-value customer groups, strong sales channels and revenue concentration risk.

---

## 6. Page 3 — Product & Profitability Analysis

### Business Question

Which product categories are most profitable?

### KPIs

* Revenue by Product Category
* Cost by Product Category
* Gross Profit by Product Category
* Gross Margin %
* Quantity Sold
* Top Product Categories

### Visuals

* Product category revenue chart
* Product category gross margin chart
* Revenue vs cost comparison
* Quantity sold by category
* Product profitability table

### Business Value

This page supports product strategy, pricing decisions and category-level profitability analysis.

---

## 7. Page 4 — Inventory Risk Dashboard

### Business Question

Which products create stock risk?

### KPIs

* Current Stock On Hand
* Products Below Reorder Level
* Negative Stock Product Count
* Stock-In Quantity
* Stock-Out Quantity
* Reorder Gap

### Visuals

* Products below reorder level table
* Negative stock products table
* Stock movement trend
* Stock-in vs stock-out chart
* Inventory risk status chart

### Business Value

This page helps detect procurement planning issues, stock control problems and products requiring urgent replenishment.

---

## 8. Page 5 — Receivables & Collection Dashboard

### Business Question

How healthy is the company’s cash collection process?

### KPIs

* Total Invoice Amount
* Total Paid Amount
* Open Balance
* Collection Rate %
* Overdue Invoice Count
* Overdue Amount
* Aging Bucket Distribution

### Visuals

* Invoice aging table
* Open balance by customer segment
* Collection rate by customer segment
* Paid vs open amount chart
* Overdue invoice summary

### Business Value

This page supports finance teams by identifying overdue invoices, collection risk and customer segments with high receivables exposure.

---

## 9. Page 6 — Supplier Performance Dashboard

### Business Question

Which suppliers create delivery risk?

### KPIs

* Purchase Order Count
* Delayed Purchase Order Count
* Delay Rate %
* Average Delay Days
* Total Purchase Amount
* Supplier Category

### Visuals

* Supplier delay rate chart
* Delayed purchase order count by supplier
* Purchase amount by supplier
* Supplier performance table
* Average delay days by supplier

### Business Value

This page helps procurement teams monitor supplier reliability and identify vendors that may affect stock availability.

---

## 10. Planned DAX Measures

The following DAX measures will be created in Power BI:

```text
Total Revenue
Total Cost
Gross Profit
Gross Margin %
Sales Order Count
Active Customer Count
Average Order Value
Total Invoice Amount
Total Paid Amount
Open Balance
Collection Rate %
Overdue Invoice Count
Products Below Reorder Level
Negative Stock Product Count
Delayed Purchase Order Count
Supplier Delay Rate %
```

---

## 11. Data Model Approach

The Power BI model will follow a star-schema-inspired structure.

Fact tables:

* SalesOrderLines
* PurchaseOrderLines
* StockMovements
* Invoices
* Payments

Dimension tables:

* Customers
* Suppliers
* Products
* Warehouses
* DateDim

Main relationship logic:

* Customers connect to SalesOrders and Invoices
* SalesOrders connect to SalesOrderLines
* Products connect to SalesOrderLines, PurchaseOrderLines and StockMovements
* Suppliers connect to PurchaseOrders
* PurchaseOrders connect to PurchaseOrderLines
* Warehouses connect to SalesOrders, PurchaseOrders and StockMovements
* DateDim supports time-based reporting

---

## 12. Professional Positioning

This dashboard will be positioned as the main analytical output of the project.

It demonstrates:

* ERP data understanding
* SQL Server relational data modeling
* Business KPI design
* Power BI dashboard planning
* Operational risk analysis
* Financial reporting logic
* Management-level decision support

The dashboard is designed to show that the project goes beyond basic ERP portal usage and focuses on real business analysis and reporting value.
