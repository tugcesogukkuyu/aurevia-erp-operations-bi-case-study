# Technical Project Summary

## Project

**Aurevia ERP Operations & BI Dashboard**

## Summary

Aurevia ERP Operations & BI Dashboard is an end-to-end portfolio case study that demonstrates how ERP operational data can be simulated, stored in SQL Server, validated with SQL, analyzed in Power BI, and extended with Python-based customer segmentation.

The project was created for a fictional professional wellness supply company named Aurevia Professional Supply.

---

## Business Domain

Aurevia sells professional spa, wellness, hammam, skincare, aromatherapy, textile, consumable, and service-related products to B2B customers.

The reporting model focuses on:

- sales performance
- product profitability
- inventory risk
- receivables collection
- supplier delivery performance
- customer portfolio prioritization

---

## Technology Stack

| Layer | Technology |
|---|---|
| ERP Simulation | Odoo Community |
| Database | SQL Server 2022 |
| Data Generation | Python |
| BI Reporting | Power BI |
| BI Calculations | DAX |
| Advanced Analytics | Python, pandas, scikit-learn |
| Model Type | K-Means clustering |
| Documentation | Markdown |
| Version Control | Git / GitHub |

---

## ERP Simulation

The ERP simulation includes:

- customer master data
- supplier master data
- product master data
- purchase order flow
- stock receipt flow
- sales order flow
- delivery flow
- invoice flow
- payment flow

The purpose of the ERP simulation is to show how business transactions generate the operational data used in BI reporting.

---

## SQL Server Database

### Database

```text
AureviaERPBI
```

### Main Tables

| Table | Purpose |
|---|---|
| Customers | Customer master data |
| Suppliers | Supplier master data |
| Products | Product and service master data |
| Warehouses | Warehouse dimension |
| PurchaseOrders | Purchase order headers |
| PurchaseOrderLines | Purchase order line details |
| SalesOrders | Sales order headers |
| SalesOrderLines | Sales order line details |
| StockMovements | Inventory movement transactions |
| Invoices | Customer invoice records |
| Payments | Customer payment records |
| DateDim | Date dimension |

### Row Counts

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

## Confirmed Project KPIs

| KPI | Value |
|---|---:|
| Total Revenue | 420.6M |
| Gross Profit | 191.8M |
| Gross Margin % | 45.6% |
| Open Balance | 95.6M / 96M |
| Collection Rate | 77.3% |
| Products Below Reorder Level | 4 |
| Negative Stock Products | 4 |
| Delayed Purchase Orders | 679 |

---

## SQL Files

| File | Purpose |
|---|---|
| `create_tables.sql` | Creates the SQL Server relational schema |
| `seed_synthetic_data.sql` | Inserts synthetic ERP data |
| `powerbi_reporting_views.sql` | Creates reporting views for the original Power BI dashboard |
| `data_quality_validation_queries.sql` | Validates data quality rules |
| `data_quality_summary.sql` | Summarizes validation results |
| `business_analysis_queries.sql` | Provides business analysis SQL queries |
| `advanced_analytics_reporting_queries.sql` | Adds SQL views for Page 07 and Page 08 advanced analytics |

---

## Power BI Dashboard

### Final Dashboard Pages

| Page | Page Name | Layer |
|---|---|---|
| 01 | Executive Overview | Operational reporting |
| 02 | Sales Analysis | Operational reporting |
| 03 | Product Profitability | Operational reporting |
| 04 | Inventory Risk | Operational reporting |
| 05 | Receivables Collection | Operational reporting |
| 06 | Supplier Performance | Operational reporting |
| 07 | Sales Operations Command Center | Management cockpit |
| 08 | Customer Portfolio Action Model | Advanced analytics decision layer |

---

## Page 07 - Sales Operations Command Center

### Purpose

Page 07 is an ERP-style management cockpit.

It consolidates sales, profitability, receivables, product contribution, and operational alerts into one screen.

### Main Components

- total revenue
- gross profit
- gross margin
- open balance
- collection rate
- monthly revenue and gross profit trend
- top customers by revenue
- product category revenue ranking
- receivables and aging risk
- operational alerts
- action queue

### SQL Sources

| SQL Object | Purpose |
|---|---|
| `vw_Page07_MonthlySalesCommandTrend` | Monthly sales and gross profit trend |
| `vw_Page07_TopCustomersByRevenue` | Top customer ranking |
| `vw_Page07_ProductCategoryRevenueRanking` | Product category ranking |
| `vw_Page07_ReceivablesOpenBalanceRisk` | Receivables aging and open balance risk |
| `vw_Page07_OperationalAlerts` | Operational alert output |
| `vw_Page07_TopOverdueCustomerExposure` | Top overdue customer exposure |

---

## Page 08 - Customer Portfolio Action Model

### Purpose

Page 08 converts customer-level sales, profitability, and collection behavior into customer action groups.

It answers:

```text
Which customer groups can support revenue growth without increasing collection
risk and profitability risk?
```

### Analytical Method

```text
Python K-Means customer segmentation
```

### Model Features

| Feature | Meaning |
|---|---|
| TotalRevenue | Customer revenue contribution |
| GrossMarginPercent | Profitability quality |
| AvgMonthlyOrderFrequency | Order regularity |
| CollectionRate | Payment quality |
| OpenBalanceRatio | Receivables exposure relative to revenue |
| ProductCategoryDiversity | Product basket diversity |

### Customer Clusters

| Cluster | Action |
|---|---|
| Strategic Value Customers | Protect / Retain / Upsell |
| Growth Potential Customers | Grow / Cross-sell |
| Collection Risk Customers | Collect First / Monitor Credit |
| Low Contribution Customers | Low-Touch Service |

### SQL and Python Sources

| Object / File | Purpose |
|---|---|
| `vw_Page08_CustomerSegmentationInput` | SQL feature input for Python |
| `customer_segmentation_kmeans.py` | Python K-Means segmentation script |
| `dbo.CustomerSegmentationOutput` | SQL writeback table for segmentation output |
| `vw_Page08_CustomerClusterProfile` | Segment profile for Power BI |
| `vw_Page08_CustomerPriorityList` | Customer priority output |
| `vw_Page08_ChannelClusterMatrix` | Channel and cluster matrix |
| `vw_Page08_ActionOutputSummary` | Action card output |

---

## Advanced Analytics Python Layer

### Folder

```text
05_synthetic_data/advanced_analytics
```

### Files

| File | Purpose |
|---|---|
| `customer_segmentation_kmeans.py` | Creates customer segmentation output |
| `sales_reporting_automation.py` | Exports SQL reporting outputs into Excel |
| `requirements.txt` | Python dependency list |
| `README_advanced_analytics.md` | Advanced analytics documentation |

### Outputs

| Output | Purpose |
|---|---|
| `customer_segments.csv` | Customer-level segmentation output |
| `customer_cluster_profile.csv` | Cluster-level KPI summary |
| `sales_priority_actions.csv` | Management action output |
| `model_run_log.csv` | Model execution metadata |

---

## Advanced Analytics Flow

```text
SQL Server reporting views
        ↓
Customer-level feature dataset
        ↓
Python data preparation
        ↓
StandardScaler
        ↓
K-Means clustering with K=4
        ↓
Business-readable cluster labels
        ↓
Customer priority score
        ↓
CSV output and optional SQL writeback
        ↓
Power BI Customer Portfolio Action Model
```

---

## DAX Documentation

DAX measures are documented in:

```text
06_powerbi_dashboard/powerbi_technical_documentation/DAX_Measure_Catalog.md
```

Advanced DAX measure areas include:

- total revenue
- gross profit
- gross margin percentage
- open balance
- collection rate
- operational alert values
- segment revenue
- segment revenue share
- segment open balance share
- strategic value revenue
- collection risk exposure
- customer priority rank
- channel revenue share

---

## QA and UAT Documentation

QA and UAT files are stored in:

```text
07_uat_go_live_docs
```

Key files:

| File | Purpose |
|---|---|
| `QA_Test_Strategy.md` | General testing strategy |
| `SQL_Data_Quality_Test_Cases.md` | SQL data quality tests |
| `PowerBI_Reconciliation_Test_Cases.md` | Power BI reconciliation checks |
| `UAT_Go_Live_Checklist.md` | Go-live style checklist |
| `Advanced_Analytics_QA_Test_Cases.md` | Advanced SQL, Python, and Power BI validation tests |

---

## Technical Documentation

Power BI and advanced analytics documentation is stored in:

```text
06_powerbi_dashboard/powerbi_technical_documentation
```

Key files:

| File | Purpose |
|---|---|
| `DAX_Measure_Catalog.md` | DAX measure definitions |
| `PowerBI_Report_Build_Log.md` | Report build notes |
| `PowerBI_Page_Blueprint.md` | Page structure documentation |
| `SQL_View_to_Dashboard_Mapping.md` | SQL view and dashboard mapping |
| `PowerBI_Field_Aggregation_Notes.md` | Aggregation and field usage notes |
| `Advanced_Analytics_Model_Documentation.md` | SQL + Python + K-Means model documentation |
| `PowerBI_Advanced_Page_Build_Notes.md` | Page 07 and Page 08 Power BI build logic |

---

## Final Technical Positioning

This project demonstrates:

- ERP process understanding
- SQL Server schema design
- synthetic transactional data generation
- SQL validation
- Power BI dashboard development
- DAX measure documentation
- Python-based customer segmentation
- customer priority scoring
- automated reporting output
- QA / UAT documentation
- business decision support

The final result is a portfolio-ready case study that connects ERP operations, data engineering, business intelligence, and applied analytics.