# Technical Project Summary

## Project

**Aurevia ERP Operations & BI Dashboard Case Study**

## Summary

This project is a technical and analytical case study that demonstrates how ERP operational data can be transformed into a validated Power BI dashboard.

The project includes ERP process simulation, SQL Server database design, SQL validation, reporting view creation, Power BI dashboard development, DAX measure creation, and source-to-report reconciliation.

---

## Technical Workflow

```text
ERP Process Simulation
        ↓
SQL Server Database Design
        ↓
SQL-Based Synthetic Data Load
        ↓
SQL Data Quality Validation
        ↓
SQL Reporting Views
        ↓
Power BI Dashboard Development
        ↓
DAX Measures
        ↓
Source-to-Report Reconciliation
        ↓
Business Insights
```

---

## ERP Layer

The ERP process was simulated using Odoo.

Main ERP flows:

- Customer master data
- Supplier master data
- Product and service catalog
- Purchase order
- Inventory receipt
- Sales order
- Delivery
- Invoice
- Payment

ERP evidence is stored under:

```text
02_erp_odoo_screenshots
```

---

## SQL Server Layer

The SQL Server database includes core operational tables:

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

SQL files are stored under:

```text
04_sql_database
```

Main SQL files:

```text
create_tables.sql
seed_synthetic_data.sql
powerbi_reporting_views.sql
data_quality_validation_queries.sql
data_quality_summary.sql
business_analysis_queries.sql
```

---

## Data Volume

| Table | Count |
|---|---:|
| Customers | 150 |
| Suppliers | 10 |
| Products | 82 |
| Warehouses | 3 |
| Purchase Orders | 800 |
| Purchase Order Lines | 2,392 |
| Sales Orders | 3,000 |
| Sales Order Lines | 8,918 |
| Stock Movements | 10,881 |
| Invoices | 3,000 |
| Payments | 2,731 |
| Date Dimension | 546 |

---

## SQL Validation

SQL validation checks included:

| Validation Area | Result |
|---|---|
| Invalid product price | PASS |
| Service stock movement | PASS |
| Invalid stock movement sign | PASS |
| Invoice mismatch | PASS |
| Overpaid invoice | PASS |
| Products below reorder level | 4 |
| Negative stock products | 4 |
| Collection rate | 77.27% |
| Gross margin | 45.59% |
| Delayed purchase orders | 679 |

---

## SQL Reporting Views

Power BI used SQL reporting views as the data source layer.

| View | Purpose |
|---|---|
| `vw_ExecutiveKPI` | Executive KPI summary |
| `vw_MonthlySalesPerformance` | Monthly sales and profit trend |
| `vw_CustomerSegmentPerformance` | Segment performance |
| `vw_ProductCategoryProfitability` | Product category profitability |
| `vw_InventoryRisk` | Stock and reorder risk |
| `vw_ReceivablesAging` | Invoice aging and collection |
| `vw_SupplierPerformance` | Supplier delay and purchase metrics |
| `vw_SalesChannelPerformance` | Channel performance |

---

## Power BI Layer

The final Power BI report file is stored under:

```text
06_powerbi_dashboard
```

File:

```text
Aurevia_ERP_Operations_BI_Dashboard_FINAL_RECOVERED.pbix
```

Dashboard pages:

1. Executive Overview
2. Sales Analysis
3. Product Profitability
4. Inventory Risk
5. Receivables Collection
6. Supplier Performance

---

## DAX Measures

Key DAX measures included:

- Total Revenue
- Gross Profit
- Gross Margin %
- Receivables Collection Rate %
- Products Monitored
- Products Below Reorder Level
- Negative Stock Products
- Total Reorder Shortage
- Supplier Delay Rate %
- Average Delay Days

Detailed DAX documentation is stored under:

```text
06_powerbi_dashboard/powerbi_technical_documentation/DAX_Measure_Catalog.md
```

---

## Power BI Validation

Power BI validation focused on:

- Correct SQL view usage
- Correct aggregation behavior
- DAX measure accuracy
- KPI reconciliation
- Visual-level business relevance
- Table readability
- Final screenshot quality

Key reconciled values:

| KPI | Final Value |
|---|---:|
| Total Revenue | 420.6M |
| Gross Profit | 191.8M |
| Gross Margin % | 45.6% |
| Collection Rate % | 77.3% |
| Open Balance | 95.6M |
| Products Below Reorder Level | 4 |
| Negative Stock Products | 4 |
| Delayed Purchase Orders | 679 |
| Supplier Delay Rate % | 84.9% |

---

## QA Documentation

QA documentation is stored under:

```text
07_uat_go_live_docs
```

Included files:

```text
QA_Test_Strategy.md
SQL_Data_Quality_Test_Cases.md
PowerBI_Reconciliation_Test_Cases.md
UAT_Go_Live_Checklist.md
```

QA focus areas:

- SQL data load validation
- SQL data quality checks
- SQL reporting view validation
- Power BI source-to-report reconciliation
- UAT readiness review

---

## Issue & Change Tracking

Issue and change request documentation is stored under:

```text
08_issue_request_log
```

Included files:

```text
Issue_Log.md
Change_Request_Log.md
```

Tracked areas:

- Environment recovery
- PBIX recovery
- SQL backup packaging
- Power BI aggregation issues
- KPI naming corrections
- Visual replacement decisions
- Documentation accuracy corrections

---

## Final Deliverables

| Deliverable | Location |
|---|---|
| ERP screenshots | `02_erp_odoo_screenshots` |
| SQL scripts | `04_sql_database` |
| SQL backup | `04_sql_database/backups` |
| Power BI file | `06_powerbi_dashboard` |
| Dashboard screenshots | `06_powerbi_dashboard/power bi ekran görüntüleri` |
| Power BI technical documentation | `06_powerbi_dashboard/powerbi_technical_documentation` |
| QA documentation | `07_uat_go_live_docs` |
| Issue and change logs | `08_issue_request_log` |
| README case study | Project root |

---

## Technical Skills Demonstrated

This project demonstrates:

- ERP process understanding
- SQL Server database design
- SQL scripting
- SQL-based synthetic data creation
- Data quality validation
- Reporting view creation
- Power BI dashboard development
- DAX measure creation
- KPI reconciliation
- BI testing and QA documentation
- Business insight communication
- Project packaging and documentation