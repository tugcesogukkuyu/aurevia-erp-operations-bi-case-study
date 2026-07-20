# Aurevia ERP Operations & BI Dashboard

End-to-end ERP Operations & Business Intelligence case study built with **Odoo ERP workflow simulation, Microsoft SQL Server, SQL validation, Power BI Desktop, and DAX**.

This project demonstrates how ERP-style operational transactions can be modeled, validated, transformed into a reporting layer, and reconciled with a Power BI dashboard.

---

## 1. Project Scope

**Aurevia Professional Supply** is a fictional professional supply company operating in the wellness, spa, hammam, skincare, textile, and service supply domain.

The project covers the following operational areas:

| Area | Scope |
|---|---|
| Sales | Sales order performance, revenue, gross profit |
| Product Profitability | Category-level revenue, margin, quantity, contribution |
| Inventory | Stock level, reorder shortage, negative stock risk |
| Receivables | Invoice amount, paid amount, open balance, aging buckets |
| Supplier Performance | Purchase volume, delayed purchase orders, delay rate |
| Executive Reporting | Consolidated KPI and operational risk overview |

---

## 2. Technical Architecture

```text
Odoo ERP Process Simulation
        ↓
SQL Server Relational Model
        ↓
SQL-Based Synthetic ERP Data Load
        ↓
SQL Data Quality Validation
        ↓
SQL Reporting Views
        ↓
Power BI Data Model
        ↓
DAX Measures
        ↓
Power BI Dashboard
        ↓
Source-to-Report Reconciliation
```

---

## 3. Tools & Technologies

| Tool / Technology | Usage |
|---|---|
| Odoo ERP | ERP workflow simulation and process evidence |
| Microsoft SQL Server | Relational ERP-style database |
| SQL Server Docker Container | Local SQL Server environment |
| Azure Data Studio | SQL development and validation |
| SQL | Table creation, data loading, reporting views, validation queries |
| Power BI Desktop | Dashboard development |
| DAX | KPI, ratio, filtered count, and formatting measures |
| VS Code | SQL and markdown documentation management |
| Windows VM on MacBook | Power BI Desktop execution environment |

---

## 4. Database Model

The SQL Server database was modeled around ERP-style operational entities.

Core tables:

| Table | Purpose |
|---|---|
| `Customers` | Customer master data |
| `Suppliers` | Supplier master data |
| `Products` | Product and service catalog |
| `Warehouses` | Warehouse master data |
| `PurchaseOrders` | Purchase order headers |
| `PurchaseOrderLines` | Purchase order details |
| `SalesOrders` | Sales order headers |
| `SalesOrderLines` | Sales order details |
| `StockMovements` | Inventory movement records |
| `Invoices` | Customer invoice records |
| `Payments` | Payment records |
| `DateDim` | Reporting date dimension |

---

## 5. Dataset Volume

Reporting period:

```text
January 2025 – June 2026
```

Dataset size:

| Table | Record Count |
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

## 6. SQL Assets

SQL files are stored under:

```text
04_sql_database
```

| File | Description |
|---|---|
| `create_tables.sql` | Creates relational ERP-style database tables |
| `seed_synthetic_data.sql` | Loads synthetic ERP transaction data |
| `powerbi_reporting_views.sql` | Creates reporting views for Power BI |
| `data_quality_validation_queries.sql` | Contains SQL validation queries |
| `data_quality_summary.sql` | Summarizes validation outputs |
| `business_analysis_queries.sql` | Contains analytical SQL queries |

Recommended SQL review order:

```text
1. create_tables.sql
2. seed_synthetic_data.sql
3. data_quality_validation_queries.sql
4. powerbi_reporting_views.sql
5. business_analysis_queries.sql
```

---

## 7. SQL Reporting Views

Power BI consumes SQL reporting views instead of raw transactional tables.

| SQL View | Purpose |
|---|---|
| `vw_ExecutiveKPI` | Executive-level KPI summary |
| `vw_MonthlySalesPerformance` | Monthly revenue, cost, and gross profit trend |
| `vw_CustomerSegmentPerformance` | Revenue and profit by customer segment |
| `vw_ProductCategoryProfitability` | Category-level profitability analysis |
| `vw_InventoryRisk` | Stock, reorder, and inventory risk analysis |
| `vw_ReceivablesAging` | Invoice aging, payment, and open balance analysis |
| `vw_SupplierPerformance` | Purchase volume and supplier delay analysis |
| `vw_SalesChannelPerformance` | Sales channel performance analysis |

---

## 8. SQL Data Quality Validation

SQL validation queries were used before Power BI development.

Validation scope:

| Test Area | Expected Control |
|---|---|
| Product price validation | No zero or negative unit prices |
| Service stock movement check | Service products should not create stock movements |
| Stock movement sign validation | IN / OUT movement signs should be consistent |
| Invoice reconciliation | Invoice amount should match related sales order amount |
| Overpaid invoice check | Paid amount should not exceed invoice amount |
| Reorder level monitoring | Products below reorder level should be identified |
| Negative stock monitoring | Negative stock products should be flagged |
| Collection rate validation | Paid amount / invoice amount should produce valid ratio |
| Gross margin validation | Revenue and cost should produce valid margin |
| Supplier delay detection | Delayed purchase orders should be identified |

Key validation results:

| Metric / Check | Result |
|---|---:|
| Invalid Product Price Records | 0 |
| Invalid Service Stock Movements | 0 |
| Invalid Stock Movement Signs | 0 |
| Invoice Mismatches | 0 |
| Overpaid Invoices | 0 |
| Products Below Reorder Level | 4 |
| Negative Stock Products | 4 |
| Collection Rate | 77.27% |
| Gross Margin | 45.59% |
| Delayed Purchase Orders | 679 |

Detailed validation documentation:

```text
07_uat_go_live_docs/SQL_Data_Quality_Test_Cases.md
```

---

## 9. Power BI Dashboard

Power BI assets are stored under:

```text
06_powerbi_dashboard
```

Final report file:

```text
Aurevia_ERP_Operations_BI_Dashboard_FINAL_RECOVERED.pbix
```

Dashboard screenshots:

```text
06_powerbi_dashboard/power_bi_ekran_goruntuleri
```

Dashboard pages:

| Page | Purpose |
|---|---|
| Executive Overview | Consolidated financial and operational KPI review |
| Sales Analysis | Revenue, gross profit, channel, and segment performance |
| Product Profitability | Category-level profit, margin, and contribution analysis |
| Inventory Risk | Negative stock, reorder shortage, and stock risk monitoring |
| Receivables Collection | Invoice collection, open balance, and aging analysis |
| Supplier Performance | Purchase volume, delayed PO count, and supplier delay rate |

---

## 10. DAX Measures

Power BI DAX documentation is stored under:

```text
06_powerbi_dashboard/powerbi_technical_documentation/DAX_Measure_Catalog.md
```

Representative DAX measures:

### Gross Margin %

```DAX
Gross Margin % =
DIVIDE(
    [Gross Profit],
    [Total Revenue]
)
```

### Receivables Collection Rate %

```DAX
Receivables Collection Rate % =
DIVIDE(
    SUM('vw_ReceivablesAging'[TotalPaidAmount]),
    SUM('vw_ReceivablesAging'[TotalInvoiceAmount])
)
```

### Supplier Delay Rate %

```DAX
Supplier Delay Rate % =
DIVIDE(
    SUM('vw_SupplierPerformance'[DelayedPurchaseOrderCount]),
    SUM('vw_SupplierPerformance'[PurchaseOrderCount])
)
```

### Products Monitored

```DAX
Products Monitored =
DISTINCTCOUNT('vw_InventoryRisk'[ProductCode])
```

### Negative Stock Products

```DAX
Negative Stock Products =
CALCULATE(
    DISTINCTCOUNT('vw_InventoryRisk'[ProductCode]),
    'vw_InventoryRisk'[CurrentStockOnHand] < 0
)
```

### Total Reorder Shortage

```DAX
Total Reorder Shortage =
CALCULATE(
    SUM('vw_InventoryRisk'[ReorderGap]),
    'vw_InventoryRisk'[StockRiskStatus] = "NEGATIVE STOCK"
)
```

### Total Reorder Shortage Label

```DAX
Total Reorder Shortage Label =
FORMAT(
    [Total Reorder Shortage],
    "#,0"
)
```

---

## 11. Source-to-Report Reconciliation

Power BI KPIs were reconciled against SQL reporting view outputs.

| KPI | Reconciled Value |
|---|---:|
| Total Revenue | ~420.6M |
| Gross Profit | ~191.8M |
| Gross Margin % | ~45.6% |
| Collection Rate % | ~77.3% |
| Open Balance | ~95.6M |
| Products Below Reorder Level | 4 |
| Negative Stock Products | 4 |
| Delayed Purchase Orders | 679 |
| Supplier Delay Rate % | ~84.9% |

Reconciliation documentation:

```text
07_uat_go_live_docs/PowerBI_Reconciliation_Test_Cases.md
06_powerbi_dashboard/powerbi_technical_documentation/SQL_View_to_Dashboard_Mapping.md
```

---

## 12. Power BI Technical Documentation

Technical Power BI documentation is stored under:

```text
06_powerbi_dashboard/powerbi_technical_documentation
```

| File | Description |
|---|---|
| `DAX_Measure_Catalog.md` | DAX measure definitions and KPI logic |
| `PowerBI_Report_Build_Log.md` | Page-level build decisions and resolved issues |
| `PowerBI_Page_Blueprint.md` | Dashboard page structure, visuals, fields, and business questions |
| `SQL_View_to_Dashboard_Mapping.md` | SQL view to Power BI page and visual mapping |
| `PowerBI_Field_Aggregation_Notes.md` | Aggregation, formatting, and modeling decisions |

---

## 13. QA Documentation

QA documentation is stored under:

```text
07_uat_go_live_docs
```

| File | Description |
|---|---|
| `QA_Test_Strategy.md` | SQL and Power BI validation strategy |
| `SQL_Data_Quality_Test_Cases.md` | SQL data quality test cases and results |
| `PowerBI_Reconciliation_Test_Cases.md` | KPI reconciliation test cases |
| `UAT_Go_Live_Checklist.md` | Final readiness checklist |

QA coverage:

- SQL data load validation
- SQL data quality validation
- SQL business rule validation
- SQL reporting view validation
- Power BI KPI validation
- Source-to-report reconciliation
- Aggregation behavior review
- Dashboard usability review

---

## 14. Issue and Change Tracking

Issue and change logs are stored under:

```text
08_issue_request_log
```

| File | Description |
|---|---|
| `Issue_Log.md` | Tracks technical, reporting, environment, packaging, and documentation issues |
| `Change_Request_Log.md` | Tracks dashboard and documentation changes during development |

Tracked examples:

- Power BI environment recovery
- PBIX file recovery
- Final package validation
- Power BI aggregation corrections
- KPI naming corrections
- Inventory calculation correction
- Visual replacement decisions
- Documentation corrections

---

## 15. Presentation Documentation

Presentation support files are stored under:

```text
09_presentation
```

| File | Description |
|---|---|
| `Case_Study_Presentation_Outline.md` | Structured project presentation outline |
| `Dashboard_Demo_Talking_Points.md` | Dashboard walkthrough notes |
| `Technical_Project_Summary.md` | Technical project architecture and deliverable summary |

---

## 16. Repository Structure

```text
aurevia-erp-operations-bi-case-study
│
├── 01_project_brief
│
├── 02_erp_odoo_screenshots
│
├── 03_process_flows
│
├── 04_sql_database
│   ├── create_tables.sql
│   ├── seed_synthetic_data.sql
│   ├── powerbi_reporting_views.sql
│   ├── data_quality_validation_queries.sql
│   ├── data_quality_summary.sql
│   ├── business_analysis_queries.sql
│
├── 05_synthetic_data
│
├── 06_powerbi_dashboard
│   ├── Aurevia_ERP_Operations_BI_Dashboard_FINAL_RECOVERED.pbix
│   ├── power_bi_ekran_goruntuleri
│   └── powerbi_technical_documentation
│       ├── DAX_Measure_Catalog.md
│       ├── PowerBI_Report_Build_Log.md
│       ├── PowerBI_Page_Blueprint.md
│       ├── SQL_View_to_Dashboard_Mapping.md
│       └── PowerBI_Field_Aggregation_Notes.md
│
├── 07_uat_go_live_docs
│   ├── QA_Test_Strategy.md
│   ├── SQL_Data_Quality_Test_Cases.md
│   ├── PowerBI_Reconciliation_Test_Cases.md
│   └── UAT_Go_Live_Checklist.md
│
├── 08_issue_request_log
│   ├── Issue_Log.md
│   └── Change_Request_Log.md
│
├── 09_presentation
│   ├── Case_Study_Presentation_Outline.md
│   ├── Dashboard_Demo_Talking_Points.md
│   └── Technical_Project_Summary.md
│
└── README.md
```

---

## 17. Review Path

Recommended review order:

```text
1. README.md
2. 04_sql_database/create_tables.sql
3. 04_sql_database/seed_synthetic_data.sql
4. 04_sql_database/data_quality_validation_queries.sql
5. 04_sql_database/powerbi_reporting_views.sql
6. 06_powerbi_dashboard/powerbi_technical_documentation/DAX_Measure_Catalog.md
7. 07_uat_go_live_docs/PowerBI_Reconciliation_Test_Cases.md
8. 06_powerbi_dashboard/power_bi_ekran_goruntuleri
```

---

## 18. Technical Skills Demonstrated

- ERP process understanding
- SQL Server relational database modeling
- SQL scripting
- SQL-based synthetic ERP data loading
- SQL data quality validation
- Business rule validation
- SQL reporting view creation
- Power BI dashboard development
- DAX measure creation
- KPI design and reconciliation
- Source-to-report validation
- Power BI aggregation control
- BI QA documentation
- Issue and change tracking
- Executive and operational reporting

---

## 19. Disclaimer

This project uses fictional company data and synthetic ERP transactions.

No real customer, supplier, financial, or company data is included.

The project was created as a professional portfolio case study.