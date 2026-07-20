# SQL Data Quality Test Cases

## Project

**Aurevia ERP Operations & BI Dashboard Case Study**

## Purpose

This document lists the SQL-based data quality test cases used to validate the ERP dataset before Power BI reporting.

The goal is to confirm that the SQL Server database contains consistent, reportable, and business-rule-compliant data.

---

## Dataset Load Summary

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

## Test Case Summary

| Test ID | Test Area | Validation Logic | Expected Result | Actual Result | Status |
|---|---|---|---:|---:|---|
| DQ-001 | Product Price Validation | Product unit price should not be zero or negative | 0 invalid record | 0 | PASS |
| DQ-002 | Service Product Stock Movement | Service products should not create stock movements | 0 invalid record | 0 | PASS |
| DQ-003 | Stock Movement Sign Check | IN movements should be positive and OUT movements should be negative | 0 invalid record | 0 | PASS |
| DQ-004 | Invoice Reconciliation | Invoice total should match related sales order amount | 0 mismatch | 0 | PASS |
| DQ-005 | Overpaid Invoice Check | Paid amount should not exceed invoice amount | 0 overpaid invoice | 0 | PASS |
| DQ-006 | Reorder Level Monitoring | Products below reorder level should be identified | Risk products listed | 4 | PASS |
| DQ-007 | Negative Stock Monitoring | Products with negative stock should be identified | Risk products listed | 4 | PASS |
| DQ-008 | Collection Rate Validation | Paid amount / invoice amount should produce valid collection rate | Valid percentage | 77.27% | PASS |
| DQ-009 | Gross Margin Validation | Revenue and cost should produce valid gross margin | Valid percentage | 45.59% | PASS |
| DQ-010 | Supplier Delay Detection | Delayed purchase orders should be identified | Delayed POs listed | 679 | PASS |

---

## Detailed Test Cases

### DQ-001 — Product Price Validation

| Field | Detail |
|---|---|
| Objective | Detect products with invalid unit price |
| Business Rule | Product prices must be greater than zero |
| Expected Result | No invalid product price records |
| Actual Result | 0 |
| Status | PASS |

---

### DQ-002 — Service Product Stock Movement Check

| Field | Detail |
|---|---|
| Objective | Ensure service products do not generate stock movements |
| Business Rule | Only physical stockable products should create inventory movements |
| Expected Result | 0 service stock movement records |
| Actual Result | 0 |
| Status | PASS |

---

### DQ-003 — Stock Movement Sign Check

| Field | Detail |
|---|---|
| Objective | Validate stock movement quantity direction |
| Business Rule | Inventory receipt movements should be positive; delivery movements should be negative |
| Expected Result | 0 invalid stock sign records |
| Actual Result | 0 |
| Status | PASS |

---

### DQ-004 — Invoice Reconciliation

| Field | Detail |
|---|---|
| Objective | Compare invoice totals against related sales order totals |
| Business Rule | Invoice amount should reconcile with the sales order amount |
| Expected Result | 0 mismatched invoice records |
| Actual Result | 0 |
| Status | PASS |

---

### DQ-005 — Overpaid Invoice Check

| Field | Detail |
|---|---|
| Objective | Detect invoices where payment exceeds invoice amount |
| Business Rule | Total paid amount cannot be greater than total invoice amount |
| Expected Result | 0 overpaid invoices |
| Actual Result | 0 |
| Status | PASS |

---

### DQ-006 — Reorder Level Monitoring

| Field | Detail |
|---|---|
| Objective | Identify products below reorder level |
| Business Rule | Products below reorder level should be flagged for replenishment |
| Expected Result | Risk products should be identified |
| Actual Result | 4 products below reorder level |
| Status | PASS |

---

### DQ-007 — Negative Stock Monitoring

| Field | Detail |
|---|---|
| Objective | Identify products with negative stock |
| Business Rule | Negative stock should be flagged as an inventory risk |
| Expected Result | Negative stock products should be identified |
| Actual Result | 4 negative stock products |
| Status | PASS |

---

### DQ-008 — Collection Rate Validation

| Field | Detail |
|---|---|
| Objective | Validate collection performance calculation |
| Formula | Total Paid Amount / Total Invoice Amount |
| Expected Result | Valid collection percentage |
| Actual Result | 77.27% |
| Status | PASS |

---

### DQ-009 — Gross Margin Validation

| Field | Detail |
|---|---|
| Objective | Validate profitability calculation |
| Formula | Gross Profit / Total Revenue |
| Expected Result | Valid gross margin percentage |
| Actual Result | 45.59% |
| Status | PASS |

---

### DQ-010 — Supplier Delay Detection

| Field | Detail |
|---|---|
| Objective | Identify delayed purchase orders |
| Business Rule | Purchase orders delivered after expected delivery date should be flagged as delayed |
| Expected Result | Delayed purchase orders should be identified |
| Actual Result | 679 delayed purchase orders |
| Status | PASS |

---

## Key Validation Results

| Metric | Result |
|---|---:|
| Total Revenue | 420,614,142.43 |
| Gross Margin | 45.59% |
| Collection Rate | 77.27% |
| Open Balance | 95,623,848.03 |
| Overdue Invoices | 248 |
| Products Below Reorder Level | 4 |
| Negative Stock Products | 4 |
| Delayed Purchase Orders | 679 |

---

## Result

The SQL data quality validation process confirmed that the dataset was suitable for Power BI reporting.

Critical financial, inventory, receivables, and supplier performance metrics were validated before dashboard development.