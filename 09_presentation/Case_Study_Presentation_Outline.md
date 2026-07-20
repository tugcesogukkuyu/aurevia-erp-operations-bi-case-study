# Case Study Presentation Outline

## Project

**Aurevia ERP Operations & BI Dashboard Case Study**

## Presentation Purpose

This outline is prepared to present the project as an end-to-end ERP operations and business intelligence case study.

The presentation focuses on:

- ERP process understanding
- SQL Server database design
- SQL-based synthetic data preparation
- SQL data quality validation
- Power BI dashboard development
- DAX measure creation
- Source-to-report reconciliation
- Business insight generation

---

## Slide 1 — Project Title

### Title

**Aurevia ERP Operations & BI Dashboard Case Study**

### Subtitle

End-to-end ERP process simulation, SQL Server reporting layer, and Power BI dashboard development.

### Key Message

This project demonstrates how ERP operational transactions can be transformed into decision-ready business intelligence dashboards.

---

## Slide 2 — Business Scenario

### Content

Aurevia Professional Supply is a fictional wellness and professional supply company.

The company sells products and services to:

- Hotels
- Wellness centers
- Clinics
- Spa businesses
- Corporate customers

### Business Need

The company needs to monitor:

- Sales performance
- Product profitability
- Inventory risk
- Receivables collection
- Supplier delivery delays

### Key Message

The project simulates a realistic ERP reporting need across sales, inventory, finance, and purchasing operations.

---

## Slide 3 — ERP Workflow

### Content

The ERP process was simulated through Odoo.

Main workflow:

1. Customer creation
2. Supplier creation
3. Product and service catalog creation
4. Purchase order creation
5. Inventory receipt
6. Sales order creation
7. Delivery process
8. Invoice generation
9. Payment registration
10. Reporting review

### Key Message

The reporting solution was built with an understanding of the full ERP transaction lifecycle.

---

## Slide 4 — SQL Server Data Model

### Content

A SQL Server database was created to represent ERP operational data.

Core tables:

- Customers
- Suppliers
- Products
- Warehouses
- Purchase Orders
- Sales Orders
- Stock Movements
- Invoices
- Payments
- Date Dimension

### Key Message

The project includes a relational database layer, not only dashboard visuals.

---

## Slide 5 — Dataset Volume

### Content

| Area | Volume |
|---|---:|
| Customers | 150 |
| Suppliers | 10 |
| Products | 82 |
| Purchase Orders | 800 |
| Sales Orders | 3,000 |
| Sales Order Lines | 8,918 |
| Stock Movements | 10,881 |
| Invoices | 3,000 |
| Payments | 2,731 |

### Key Message

The dataset is large enough to simulate realistic ERP reporting and BI analysis.

---

## Slide 6 — SQL Validation Layer

### Content

SQL validation checks were performed before dashboard development.

Examples:

- Invalid product price check
- Service stock movement check
- Stock movement sign check
- Invoice reconciliation
- Overpaid invoice check
- Negative stock detection
- Reorder level monitoring
- Collection rate validation
- Gross margin validation
- Supplier delay detection

### Key Message

The report was built on validated data, not only imported data.

---

## Slide 7 — Reporting Views

### Content

Power BI was connected to SQL reporting views.

Main views:

- `vw_ExecutiveKPI`
- `vw_MonthlySalesPerformance`
- `vw_CustomerSegmentPerformance`
- `vw_ProductCategoryProfitability`
- `vw_InventoryRisk`
- `vw_ReceivablesAging`
- `vw_SupplierPerformance`
- `vw_SalesChannelPerformance`

### Key Message

SQL views were used as a reporting layer between raw ERP tables and Power BI visuals.

---

## Slide 8 — Power BI Dashboard Structure

### Content

The Power BI report includes 6 pages:

1. Executive Overview
2. Sales Analysis
3. Product Profitability
4. Inventory Risk
5. Receivables Collection
6. Supplier Performance

### Key Message

Each page was designed around a specific business question.

---

## Slide 9 — Executive Overview

### Content

Key KPIs:

- Total Revenue
- Gross Profit
- Gross Margin %
- Collection Rate %
- Open Balance
- Products Below Reorder Level
- Delayed Purchase Order Count

### Key Message

The page gives management a quick overview of financial performance and operational risk.

---

## Slide 10 — Sales Analysis

### Content

Analysis areas:

- Monthly revenue and gross profit trend
- Revenue by sales channel
- Revenue and gross profit by customer segment

### Key Message

The page helps identify which channels and customer segments drive business performance.

---

## Slide 11 — Product Profitability

### Content

Analysis areas:

- Gross profit by product category
- Gross margin by product category
- Profit contribution
- Category-level profitability detail

### Key Message

The page helps compare categories by both profitability volume and margin strength.

---

## Slide 12 — Inventory Risk

### Content

Analysis areas:

- Products monitored
- Products below reorder level
- Total reorder shortage
- Negative stock products
- Stock risk status
- Inventory action table

### Key Message

The page turns inventory data into operational replenishment and risk follow-up actions.

---

## Slide 13 — Receivables Collection

### Content

Analysis areas:

- Total invoice amount
- Total paid amount
- Open balance
- Collection rate
- Aging bucket analysis
- Receivables detail table

### Key Message

The page helps finance teams monitor collection performance and aging risk.

---

## Slide 14 — Supplier Performance

### Content

Analysis areas:

- Total purchase amount
- Purchase order count
- Delayed purchase order count
- Average delay days
- Supplier delay rate
- Supplier delay action table

### Key Message

The page identifies supplier delivery issues and supports purchasing follow-up.

---

## Slide 15 — DAX & Power BI Logic

### Content

DAX measures were created for:

- Gross Margin %
- Receivables Collection Rate %
- Supplier Delay Rate %
- Products Monitored
- Negative Stock Products
- Total Reorder Shortage
- Total Reorder Shortage Label

### Key Message

The report includes Power BI measure logic, not only drag-and-drop visuals.

---

## Slide 16 — Source-to-Report Reconciliation

### Content

Power BI KPI values were checked against SQL reporting views.

Examples:

| KPI | Result |
|---|---:|
| Total Revenue | 420.6M |
| Gross Margin % | 45.6% |
| Collection Rate % | 77.3% |
| Negative Stock Products | 4 |
| Delayed Purchase Orders | 679 |
| Supplier Delay Rate % | 84.9% |

### Key Message

The final dashboard was reconciled against source SQL outputs.

---

## Slide 17 — Key Business Insights

### Content

Main findings:

- Revenue reached approximately 420.6M.
- Gross margin was approximately 45.6%.
- Collection rate was approximately 77.3%.
- Open receivables balance was approximately 95.6M.
- 4 products had negative stock risk.
- 679 out of 800 purchase orders were delayed.
- Supplier delay rate was approximately 84.9%.

### Key Message

The dashboard highlights both financial performance and operational risk.

---

## Slide 18 — Tools & Technologies

### Content

- Odoo ERP
- SQL Server
- SQL Server Docker Container
- Azure Data Studio
- SQL
- Power BI Desktop
- DAX
- VS Code
- Windows VM on MacBook

### Key Message

The project combines ERP process knowledge, SQL, Power BI, DAX, QA, and business analysis.

---

## Slide 19 — Project Deliverables

### Content

Final deliverables:

- ERP screenshots
- SQL scripts
- SQL validation queries
- SQL reporting views
- SQL backup file
- Power BI PBIX file
- Dashboard screenshots
- QA documentation
- Power BI technical documentation
- README case study

### Key Message

The project is documented as a complete portfolio case study package.

---

## Slide 20 — Final Summary

### Content

This project demonstrates the ability to:

- Understand ERP processes
- Build SQL Server reporting structures
- Validate business data with SQL
- Create Power BI dashboards
- Write DAX measures
- Reconcile dashboard values with source data
- Communicate business insights clearly

### Key Message

Aurevia is an end-to-end ERP operations and BI dashboard case study built for portfolio demonstration.