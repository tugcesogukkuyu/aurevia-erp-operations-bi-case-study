# Change Request Log

## Project

**Aurevia ERP Operations & BI Dashboard Case Study**

## Purpose

This document records the main change requests and design decisions made during the project.

The goal is to show how dashboard requirements, visuals, calculations, documentation, and packaging decisions evolved during development.

---

## Change Request Summary

| CR ID | Area | Change Request | Reason | Status |
|---|---|---|---|---|
| CR-001 | Dashboard Scope | Expand report into multiple analytical pages | Needed executive and operational coverage | Completed |
| CR-002 | Sales Page | Avoid unnecessary duplicate visuals | Keep page business-focused | Completed |
| CR-003 | Product Page | Replace low-value scatter visual | Scatter did not answer business question clearly | Completed |
| CR-004 | Inventory Page | Add action-oriented inventory table | Needed operational follow-up view | Completed |
| CR-005 | Receivables Page | Use aging bucket analysis instead of customer view | Customer fields not available in view | Completed |
| CR-006 | Supplier Page | Replace complex visual with action table | Table better supported supplier follow-up | Completed |
| CR-007 | KPI Logic | Add DAX measures for ratios and filtered counts | Needed correct Power BI calculations | Completed |
| CR-008 | Formatting | Standardize dashboard layout and visual style | Needed portfolio-level presentation quality | Completed |
| CR-009 | Screenshots | Capture final dashboard pages without Power BI UI | Needed clean portfolio visuals | Completed |
| CR-010 | Documentation | Add technical Power BI documentation | Needed DAX and build evidence | Completed |
| CR-011 | QA Docs | Replace generic UAT text with technical QA documentation | Needed stronger data validation evidence | Completed |
| CR-012 | Backup | Create complete final project ZIP | Needed full recovery package | Completed |

---

## Detailed Change Requests

### CR-001 — Expand Dashboard into Multiple Analytical Pages

| Field | Detail |
|---|---|
| Request | Build the dashboard as a multi-page report instead of a single page. |
| Reason | The project needed to cover sales, inventory, receivables, product profitability, and supplier performance separately. |
| Final Decision | A 6-page Power BI report was created. |
| Status | Completed |

Final pages:

1. Executive Overview  
2. Sales Analysis  
3. Product Profitability  
4. Inventory Risk  
5. Receivables Collection  
6. Supplier Performance  

---

### CR-002 — Avoid Duplicate Visuals on Sales Analysis Page

| Field | Detail |
|---|---|
| Request | Do not add visuals only for variety. |
| Reason | Duplicate or low-value charts weaken dashboard quality. |
| Final Decision | Sales page was limited to revenue trend, channel performance, and customer segment performance. |
| Status | Completed |

---

### CR-003 — Replace Product Profitability Scatter Visual

| Field | Detail |
|---|---|
| Request | Remove scatter chart from Product Profitability page. |
| Reason | The scatter chart did not clearly explain the business question. |
| Final Decision | A treemap and category detail table were used instead. |
| Status | Completed |

Final visuals:

- Gross Profit & Margin by Product Category
- Profit Contribution by Product Category
- Category Profitability Detail
- Key Insights

---

### CR-004 — Add Inventory Risk Action Table

| Field | Detail |
|---|---|
| Request | Add a table showing products requiring action. |
| Reason | Inventory risk should be operationally actionable, not only visual. |
| Final Decision | Inventory Risk Action Table was added and filtered for risk products. |
| Status | Completed |

Included fields:

- Product Code
- Product Name
- Product Category
- Current Stock
- Reorder Level
- Reorder Shortage
- Risk Status

---

### CR-005 — Use Aging Bucket Analysis on Receivables Page

| Field | Detail |
|---|---|
| Request | Build receivables analysis based on available source fields. |
| Reason | Customer-level fields were not available in `vw_ReceivablesAging`. |
| Final Decision | Aging bucket analysis and aging detail table were used. |
| Status | Completed |

Final visuals:

- Open Balance by Aging Bucket
- Invoice Count by Aging Bucket
- Receivables Aging Detail
- Key Insights

---

### CR-006 — Replace Supplier Complex Visual with Action Table

| Field | Detail |
|---|---|
| Request | Replace supplier scatter/combo visual with a clearer business component. |
| Reason | Supplier delay follow-up required tabular comparison. |
| Final Decision | Supplier Delay Action Table was added. |
| Status | Completed |

Included fields:

- Supplier
- PO Count
- Delayed PO
- Delay Rate
- Avg Delay Days

---

### CR-007 — Add DAX Measures for Correct KPI Logic

| Field | Detail |
|---|---|
| Request | Create DAX measures for ratios, counts, and filtered calculations. |
| Reason | Raw field aggregation was not enough for correct KPI logic. |
| Final Decision | DAX measures were created and documented. |
| Status | Completed |

Examples:

- Gross Margin %
- Receivables Collection Rate %
- Supplier Delay Rate %
- Products Monitored
- Negative Stock Products
- Total Reorder Shortage
- Total Reorder Shortage Label

---

### CR-008 — Standardize Dashboard Formatting

| Field | Detail |
|---|---|
| Request | Make pages visually consistent and portfolio-ready. |
| Reason | Dashboard should look like a professional BI report, not a draft. |
| Final Decision | Consistent card style, titles, colors, spacing, borders, and shadows were applied. |
| Status | Completed |

---

### CR-009 — Capture Clean Dashboard Screenshots

| Field | Detail |
|---|---|
| Request | Export or capture final screenshots for each dashboard page. |
| Reason | README, LinkedIn, and portfolio presentation need clean visuals. |
| Final Decision | Six final screenshots were captured without Power BI side panels or tabs. |
| Status | Completed |

Final screenshots:

- Executive Overview
- Sales Analysis
- Product Profitability
- Inventory Risk
- Receivables Collection
- Supplier Performance

---

### CR-010 — Add Power BI Technical Documentation

| Field | Detail |
|---|---|
| Request | Document DAX measures, build process, page structure, and source mapping. |
| Reason | Screenshots alone do not prove Power BI development work. |
| Final Decision | Technical documentation folder was added under `06_powerbi_dashboard`. |
| Status | Completed |

Files added:

- `DAX_Measure_Catalog.md`
- `PowerBI_Report_Build_Log.md`
- `PowerBI_Page_Blueprint.md`
- `SQL_View_to_Dashboard_Mapping.md`
- `PowerBI_Field_Aggregation_Notes.md`

---

### CR-011 — Improve QA Documentation

| Field | Detail |
|---|---|
| Request | Replace generic UAT text with technical QA and reconciliation documentation. |
| Reason | The project needed stronger evidence of data validation and BI testing. |
| Final Decision | QA documentation was restructured under `07_uat_go_live_docs`. |
| Status | Completed |

Files added:

- `QA_Test_Strategy.md`
- `SQL_Data_Quality_Test_Cases.md`
- `PowerBI_Reconciliation_Test_Cases.md`
- `UAT_Go_Live_Checklist.md`

---

### CR-012 — Create Complete Final Project Backup

| Field | Detail |
|---|---|
| Request | Create a complete final project ZIP package. |
| Reason | Previous package did not include all critical files. |
| Final Decision | Complete final ZIP was created and verified. |
| Status | Completed |

Verified files:

- Final PBIX file
- SQL backup `.bak`
- SQL scripts
- Power BI screenshots
- Documentation files

---

## Final Change Request Status

All change requests were completed.

The final project reflects both technical development and iterative business/reporting decisions.