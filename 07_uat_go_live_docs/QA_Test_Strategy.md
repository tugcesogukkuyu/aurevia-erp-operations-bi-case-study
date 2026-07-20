# QA Test Strategy

## Project

**Aurevia ERP Operations & BI Dashboard Case Study**

## Objective

The objective of this QA process is to validate that the synthetic ERP dataset was created, loaded, transformed, and reported correctly across the SQL Server and Power BI layers.

The validation focuses on four main areas:

1. SQL Server data load consistency
2. SQL data quality and business rule validation
3. SQL reporting view validation
4. Power BI KPI and dashboard reconciliation

---

## Test Scope

| Layer | Scope | Validation Method |
|---|---|---|
| SQL Data Load | Synthetic ERP transaction data | Row count checks and table-level review |
| SQL Database | Tables, relationships, business rules | SQL validation queries |
| Reporting Views | BI-ready SQL views | SQL aggregation checks |
| Power BI | KPI cards, charts, tables | Source-to-report reconciliation |
| UAT | Dashboard usability and business readability | Manual business review |

---

## Test Tools

| Tool | Usage |
|---|---|
| SQL Server | Data storage and relational model |
| Azure Data Studio | SQL execution, validation queries, result checks |
| Power BI Desktop | Dashboard development and KPI validation |
| DAX | KPI measure calculations |
| VS Code | Project documentation and SQL file management |
| Manual Review | Visual layout, page logic, business question validation |

---

## QA Approach

The QA process was structured as a source-to-report validation flow.

```text
SQL Seed Scripts
        ↓
SQL Server Tables
        ↓
SQL Data Quality Checks
        ↓
SQL Reporting Views
        ↓
Power BI Data Model
        ↓
DAX Measures & Visuals
        ↓
Dashboard Business Review
```

---

## Validation Layers

### 1. SQL Data Load Validation

The synthetic ERP dataset was loaded into SQL Server using structured SQL scripts.

Validated areas:

- Customers
- Suppliers
- Products
- Warehouses
- Purchase orders
- Purchase order lines
- Sales orders
- Sales order lines
- Stock movements
- Invoices
- Payments
- Date dimension

The goal was to confirm that the database contained enough realistic transactional data for ERP and BI reporting scenarios.

---

### 2. SQL Data Quality Validation

SQL validation queries were used to detect data quality issues and business rule violations.

Examples:

- Products with invalid prices
- Service products with stock movements
- Invalid stock movement signs
- Invoice amount mismatches
- Overpaid invoices
- Negative stock products
- Products below reorder level
- Supplier delivery delays

---

### 3. Reporting View Validation

Reporting views were created for Power BI consumption.

Each view was checked to confirm that it returned aggregated and business-ready data.

Validated views:

- `vw_ExecutiveKPI`
- `vw_MonthlySalesPerformance`
- `vw_CustomerSegmentPerformance`
- `vw_ProductCategoryProfitability`
- `vw_InventoryRisk`
- `vw_ReceivablesAging`
- `vw_SupplierPerformance`
- `vw_SalesChannelPerformance`

---

### 4. Power BI Reconciliation

Power BI KPI values were compared against SQL source values.

The purpose was to verify that:

- Power BI visuals used the correct reporting views
- DAX measures matched SQL logic
- Aggregations were not accidentally counted instead of summed
- Percentage calculations were not incorrectly aggregated
- KPI values were consistent with source data
- Dashboard pages answered the intended business questions

---

## Acceptance Criteria

| Area | Acceptance Criteria |
|---|---|
| Data Load | Core ERP tables are populated successfully |
| Data Quality | Critical validation checks return expected results |
| SQL Views | Reporting views return complete and usable BI datasets |
| Power BI KPIs | KPI values match SQL source calculations |
| Visuals | Charts and tables answer defined business questions |
| Final Package | PBIX, SQL scripts, screenshots, and documentation are stored in the project folder |

---

## Final QA Status

| Area | Status |
|---|---|
| SQL Data Load | Passed |
| SQL Data Quality Validation | Passed |
| Reporting Views | Passed |
| Power BI Reconciliation | Passed |
| Dashboard Visual Review | Passed |
| Final Project Packaging | Passed |

---

## Notes

This QA process was designed for a portfolio case study using synthetic ERP data.

The test approach reflects real business intelligence project practices such as:

- SQL-based data quality validation
- source-to-report reconciliation
- KPI validation
- report usability review
- go-live readiness control