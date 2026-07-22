# Case Study Presentation Outline

## Project

**Aurevia ERP Operations & BI Dashboard**

## Presentation Purpose

This presentation explains the Aurevia ERP Operations & BI Dashboard as an end-to-end portfolio case study.

The project demonstrates how ERP transactions can be simulated, modeled in SQL Server, validated with SQL, analyzed in Power BI, and extended with Python-based customer segmentation for management decision support.

---

## 1. Project Overview

### Key Message

Aurevia is a fictional professional wellness supply company created for this ERP, SQL, Power BI, and analytics case study.

The project simulates a real business reporting environment where operational data is created, stored, validated, analyzed, and converted into management dashboards.

### What the Project Covers

- ERP process simulation
- relational SQL Server database design
- synthetic business data generation
- SQL validation and reporting views
- Power BI dashboard design
- DAX-based KPI calculation
- Python-based customer segmentation
- automated reporting output
- QA and UAT documentation
- management-facing decision support

---

## 2. Business Scenario

### Company

**Aurevia Professional Supply**

### Business Model

Aurevia sells professional spa, wellness, hammam, aromatherapy, skincare, textile, and service-related products to B2B customers.

### Customer Types

- hotels and resorts
- spa and wellness centers
- beauty and professional clinics
- distributors and resellers
- retail partners
- corporate clients

### Operational Areas

The project focuses on:

- sales performance
- product profitability
- inventory risk
- receivables collection
- supplier delivery performance
- customer portfolio prioritization

---

## 3. ERP Process Simulation

### Purpose

The ERP process was simulated to show how operational transactions are created before they become reporting data.

### ERP Flow

- customer setup
- supplier setup
- product setup
- purchase order creation
- stock receipt
- sales order creation
- delivery
- invoice creation
- payment registration

### Business Value

This demonstrates how ERP workflows create the source data used in downstream SQL and Power BI reporting.

---

## 4. SQL Server Data Model

### Purpose

SQL Server was used as the relational database layer of the project.

### Main Tables

- Customers
- Suppliers
- Products
- Warehouses
- PurchaseOrders
- PurchaseOrderLines
- SalesOrders
- SalesOrderLines
- StockMovements
- Invoices
- Payments
- DateDim

### Confirmed Row Volumes

| Table | Row Count |
|---|---:|
| Customers | 150 |
| Suppliers | 10 |
| Products | 82 |
| Warehouses | 3 |
| PurchaseOrders | 800 |
| PurchaseOrderLines | 2,392 |
| SalesOrders | 3,000 |
| SalesOrderLines | 8,918 |
| StockMovements | 10,881 |
| Invoices | 3,000 |
| Payments | 2,731 |
| DateDim | 546 |

---

## 5. Data Quality and Validation

### Purpose

SQL validation queries were written to confirm that the synthetic ERP dataset is internally consistent.

### Validation Areas

- invalid product price checks
- service product stock movement checks
- stock movement sign checks
- invoice and sales order reconciliation
- overpaid invoice checks
- inventory risk checks
- collection performance checks
- supplier delay checks

### Confirmed Validation Results

| Check | Result |
|---|---:|
| Invalid product price records | 0 |
| Service stock movement errors | 0 |
| Invalid stock sign records | 0 |
| Invoice mismatch records | 0 |
| Overpaid invoices | 0 |
| Products below reorder level | 4 |
| Negative stock products | 4 |
| Collection rate | 77.3% |
| Gross margin | 45.6% |
| Delayed purchase orders | 679 |

---

## 6. Original Power BI Dashboard Scope

### Original 6 Pages

| Page | Page Name | Purpose |
|---|---|---|
| 01 | Executive Overview | Management summary of revenue, profit, collection, and risk |
| 02 | Sales Analysis | Sales trend, channel, customer, and regional performance |
| 03 | Product Profitability | Product category revenue, margin, and profitability review |
| 04 | Inventory Risk | Stock level, reorder, negative stock, and warehouse risk |
| 05 | Receivables Collection | Invoice, payment, open balance, and overdue monitoring |
| 06 | Supplier Performance | Purchase order, supplier delay, and procurement performance |

### Key Message

The original Power BI dashboard provides the operational reporting layer of the project.

---

## 7. Advanced Analytics Extension

### Why the Extension Was Added

After the operational dashboard was completed, the project was extended with an advanced analytics layer.

The purpose was not to add unnecessary pages, but to add a focused management decision layer.

### Added Pages

| Page | Page Name | Purpose |
|---|---|---|
| 07 | Sales Operations Command Center | ERP-style management cockpit for sales, profitability, receivables, product contribution, and operational alerts |
| 08 | Customer Portfolio Action Model | Python K-Means based customer segmentation model for sales growth and collection-risk decisions |

---

## 8. Page 07 - Sales Operations Command Center

### Business Purpose

This page provides a single management screen for monitoring current operational performance.

### Main Components

- total revenue
- gross profit
- gross margin
- open balance
- collection rate
- monthly revenue and gross profit trend
- top customers by revenue
- product category revenue ranking
- receivables and open balance risk
- operational alerts
- action queue

### Business Value

The page gives management one ERP-style cockpit to monitor sales, profitability, receivables, and operational exceptions without switching between multiple report pages.

---

## 9. Page 08 - Customer Portfolio Action Model

### Business Purpose

This page answers the following management question:

```text
Which customer groups can support revenue growth without increasing collection
risk and profitability risk?
```

### Analytical Method

Python-based K-Means customer segmentation.

### Model Features

- total revenue
- gross margin percentage
- sales order count / order frequency
- collection rate
- open balance ratio
- product category diversity

### Customer Clusters

| Cluster | Business Meaning | Recommended Action |
|---|---|---|
| Strategic Value Customers | High revenue, strong margin, good collection quality | Protect / Retain / Upsell |
| Growth Potential Customers | Healthy profile with room for expansion | Grow / Cross-sell |
| Collection Risk Customers | Revenue exists but collection and open balance risk are high | Collect First / Monitor Credit |
| Low Contribution Customers | Lower contribution and lower strategic priority | Low-Touch Service |

### Business Value

The page converts customer-level sales, profitability, and receivables behavior into sales and collection action priorities.

---

## 10. Python Advanced Analytics Layer

### Purpose

Python was added to support customer segmentation and automated reporting.

### Python Files

| File | Purpose |
|---|---|
| `customer_segmentation_kmeans.py` | Builds the K-Means customer segmentation model |
| `sales_reporting_automation.py` | Exports SQL reporting outputs to Excel |
| `requirements.txt` | Defines Python dependencies |
| `README_advanced_analytics.md` | Documents the advanced analytics layer |

### Python Libraries

- pandas
- numpy
- scikit-learn
- StandardScaler
- KMeans
- silhouette_score
- SQLAlchemy
- pyodbc
- joblib
- openpyxl
- pathlib
- logging

---

## 11. Technical Architecture

### End-to-End Flow

```text
ERP process simulation
        ↓
SQL Server relational data model
        ↓
Synthetic ERP data generation
        ↓
SQL validation and reporting views
        ↓
Power BI operational dashboard
        ↓
Python customer segmentation
        ↓
Power BI advanced decision pages
        ↓
QA and UAT documentation
```

### Architecture Value

The project demonstrates how business operations, data modeling, reporting, analytics, and decision support can be connected in one portfolio case study.

---

## 12. QA and UAT Documentation

### Purpose

QA documentation was created to show how outputs should be validated and reconciled.

### QA Areas

- SQL view validation
- customer-level feature dataset validation
- Python output row count checks
- customer count reconciliation
- total revenue reconciliation
- open balance reconciliation
- Power BI visual alignment
- DAX measure documentation
- screenshot existence checks

### Key QA File

```text
07_uat_go_live_docs/Advanced_Analytics_QA_Test_Cases.md
```

---

## 13. Final Dashboard Scope

| Page | Page Name |
|---|---|
| 01 | Executive Overview |
| 02 | Sales Analysis |
| 03 | Product Profitability |
| 04 | Inventory Risk |
| 05 | Receivables Collection |
| 06 | Supplier Performance |
| 07 | Sales Operations Command Center |
| 08 | Customer Portfolio Action Model |

### Positioning

The first six pages represent the operational reporting layer.

The final two pages represent the advanced management and customer portfolio decision layer.

---

## 14. Final Project Positioning

This project can be presented as:

```text
An end-to-end ERP operations and BI case study combining SQL Server, Power BI,
DAX, Python, and applied customer analytics for management decision support.
```

### Skills Demonstrated

- business process understanding
- ERP transaction flow analysis
- SQL Server database modeling
- synthetic data generation
- SQL validation
- Power BI report design
- DAX measure documentation
- Python analytics
- customer segmentation
- QA / UAT documentation
- management reporting design