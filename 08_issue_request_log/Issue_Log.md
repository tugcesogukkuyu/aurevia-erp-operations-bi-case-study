# Issue Log

## Project

**Aurevia ERP Operations & BI Dashboard Case Study**

## Purpose

This document records the main issues identified during the ERP, SQL, Power BI, QA, and project packaging phases.

The purpose is to show how technical and reporting issues were tracked, analyzed, resolved, and validated during the project.

---

## Issue Summary

| Issue ID | Category | Issue | Impact | Status |
|---|---|---|---|---|
| ISS-001 | ERP Access | Odoo trial/free access became unavailable after ERP screenshots were captured | ERP could not be reopened for new screenshots | Closed |
| ISS-002 | Power BI Environment | Original Windows/Parallels environment became unavailable | Power BI file access risk | Closed |
| ISS-003 | File Recovery | PBIX files had to be recovered from Parallels disk | Risk of losing dashboard versions | Closed |
| ISS-004 | Power BI Setup | Power BI Desktop was not initially available in the new Windows VM | Dashboard could not be edited | Closed |
| ISS-005 | SQL Backup Packaging | Final ZIP initially did not include `.pbix`, `.bak`, or `.sql` files | Incomplete project backup risk | Closed |
| ISS-006 | Power BI Aggregation | Numeric fields defaulted to Count instead of Sum | KPI and chart values could be incorrect | Closed |
| ISS-007 | Percentage Aggregation | Percentage fields risked being summed incorrectly | Margin and delay rate could be misleading | Closed |
| ISS-008 | Inventory Logic | Reorder shortage sign logic needed review | Inventory shortage KPI could be wrong | Closed |
| ISS-009 | KPI Formatting | Total reorder shortage was rounded to 2K | Exact operational value was hidden | Closed |
| ISS-010 | Receivables View Limitation | Customer-level fields were not available in receivables view | Customer-level receivables visual could not be built | Closed |
| ISS-011 | KPI Naming | Invoice Count was initially at risk of being named Open Invoice Count | Business meaning could be misleading | Closed |
| ISS-012 | Supplier Visual Selection | Scatter/combo chart did not clearly explain supplier delay issue | Visual clarity risk | Closed |
| ISS-013 | Table Readability | Supplier action table was too dense | Operational review usability issue | Closed |
| ISS-014 | Screenshot Quality | Power BI interface elements could appear in screenshots | Portfolio presentation quality risk | Closed |
| ISS-015 | Python Documentation | Python was mentioned before confirming Python files existed | Documentation accuracy risk | Closed |

---

## Detailed Issues

### ISS-001 — Odoo Access Became Unavailable

| Field | Detail |
|---|---|
| Category | ERP Access |
| Issue | Odoo access became unavailable after the ERP simulation phase. |
| Impact | New ERP screenshots could not be captured later. |
| Root Cause | Odoo free/trial access limitations. |
| Resolution | Existing ERP screenshots and documented workflow were preserved and used as project evidence. |
| Validation | ERP screenshots remained available under `02_erp_odoo_screenshots`. |
| Status | Closed |

---

### ISS-002 — Original Windows/Parallels Environment Became Unavailable

| Field | Detail |
|---|---|
| Category | Environment |
| Issue | The original Windows environment used for Power BI became unavailable. |
| Impact | There was a risk of losing access to the Power BI dashboard file. |
| Root Cause | Parallels trial/license limitation. |
| Resolution | A new Windows VM environment was prepared using UTM. |
| Validation | Power BI Desktop was installed and the final PBIX file was reopened successfully. |
| Status | Closed |

---

### ISS-003 — PBIX File Recovery Required

| Field | Detail |
|---|---|
| Category | File Recovery |
| Issue | Multiple Power BI dashboard versions had to be recovered from the previous Windows disk. |
| Impact | Risk of losing dashboard development history. |
| Root Cause | PBIX files were stored inside the previous Windows environment. |
| Resolution | PBIX versions were recovered and stored under `06_powerbi_dashboard/recovered_from_parallels`. |
| Validation | Final recovered PBIX file was saved as `Aurevia_ERP_Operations_BI_Dashboard_FINAL_RECOVERED.pbix`. |
| Status | Closed |

---

### ISS-004 — Power BI Desktop Not Available in New VM

| Field | Detail |
|---|---|
| Category | Power BI Setup |
| Issue | Power BI Desktop was not installed in the new UTM Windows environment. |
| Impact | Dashboard editing could not continue until Power BI was installed. |
| Root Cause | New Windows VM did not include Power BI Desktop by default. |
| Resolution | Power BI Desktop was installed through Microsoft Store. |
| Validation | The final PBIX file opened successfully in Power BI Desktop. |
| Status | Closed |

---

### ISS-005 — Initial Final ZIP Was Incomplete

| Field | Detail |
|---|---|
| Category | Project Packaging |
| Issue | The first final ZIP only included the details folder and screenshots, but not the main project folder. |
| Impact | Critical files such as PBIX, SQL scripts, and SQL backup were missing from the ZIP. |
| Root Cause | Wrong folder was selected for the ZIP command. |
| Resolution | A complete ZIP was created including both the main project folder and the details folder. |
| Validation | ZIP contents were checked using `unzip -l` and confirmed to include `.pbix`, `.bak`, and `.sql` files. |
| Status | Closed |

---

### ISS-006 — Numeric Fields Defaulted to Count

| Field | Detail |
|---|---|
| Category | Power BI Aggregation |
| Issue | Some numeric fields were automatically summarized as Count. |
| Impact | Revenue, cost, profit, invoice, and purchase values could display incorrect results. |
| Root Cause | Power BI default aggregation behavior. |
| Resolution | Aggregation was manually changed to `Toplam` where total amount logic was required. |
| Validation | KPI cards and visuals were reviewed against SQL source values. |
| Status | Closed |

---

### ISS-007 — Percentage Fields Risked Incorrect Aggregation

| Field | Detail |
|---|---|
| Category | Power BI Aggregation |
| Issue | Percentage fields such as margin and delay rate could be incorrectly summed. |
| Impact | Gross margin and supplier delay rate could become misleading. |
| Root Cause | Percentage fields require ratio logic, not simple summation. |
| Resolution | DAX measures or average aggregation were used depending on the visual. |
| Validation | Gross Margin %, Collection Rate %, and Supplier Delay Rate % were reconciled. |
| Status | Closed |

---

### ISS-008 — Inventory Reorder Shortage Logic Needed Review

| Field | Detail |
|---|---|
| Category | Business Logic |
| Issue | Reorder shortage calculation needed careful review due to sign direction and risk status logic. |
| Impact | Inventory Risk KPI could show an incorrect shortage value. |
| Root Cause | Reorder gap and negative stock logic required filtering by risk status. |
| Resolution | Total reorder shortage was calculated using ReorderGap filtered by `StockRiskStatus = "NEGATIVE STOCK"`. |
| Validation | Final value reconciled to 1,855. |
| Status | Closed |

---

### ISS-009 — Reorder Shortage Rounded in KPI Card

| Field | Detail |
|---|---|
| Category | Power BI Formatting |
| Issue | Total reorder shortage was displayed as 2K instead of exact value. |
| Impact | Operational precision was reduced. |
| Root Cause | Power BI display units rounded the KPI value. |
| Resolution | A formatted DAX label measure was created. |
| Validation | KPI displayed exact value as 1,855. |
| Status | Closed |

---

### ISS-010 — Customer-Level Receivables Fields Not Available

| Field | Detail |
|---|---|
| Category | Data Model Limitation |
| Issue | The receivables aging view did not contain customer-level fields. |
| Impact | Customer-level receivables visual could not be built from the available view. |
| Root Cause | `vw_ReceivablesAging` was designed at aging bucket level. |
| Resolution | Dashboard used aging bucket analysis instead of customer-level receivables analysis. |
| Validation | Receivables page remained aligned with available source data. |
| Status | Closed |

---

### ISS-011 — Invoice Count KPI Naming Risk

| Field | Detail |
|---|---|
| Category | Business Meaning |
| Issue | Invoice Count was initially at risk of being interpreted as Open Invoice Count. |
| Impact | KPI could mislead business users. |
| Root Cause | Field represented total invoice count, not only open invoices. |
| Resolution | KPI title was corrected to Invoice Count. |
| Validation | Dashboard title matched source field meaning. |
| Status | Closed |

---

### ISS-012 — Supplier Visual Did Not Communicate Clearly

| Field | Detail |
|---|---|
| Category | Visual Design |
| Issue | Scatter/combo chart alternatives did not clearly explain supplier delay issue. |
| Impact | Supplier page could become visually complex without business value. |
| Root Cause | Visual type did not match the operational follow-up question. |
| Resolution | Supplier Delay Action Table was used instead. |
| Validation | Final page clearly showed supplier purchase volume and delay metrics. |
| Status | Closed |

---

### ISS-013 — Supplier Table Readability Issue

| Field | Detail |
|---|---|
| Category | Report Usability |
| Issue | Supplier action table was dense and difficult to read. |
| Impact | Operational review usability was reduced. |
| Root Cause | Multiple metrics were displayed in a limited visual area. |
| Resolution | Table was moved to a wider area and grid formatting was adjusted. |
| Validation | Column names, text size, and row padding were reviewed. |
| Status | Closed |

---

### ISS-014 — Screenshot Quality Risk

| Field | Detail |
|---|---|
| Category | Portfolio Presentation |
| Issue | Power BI interface elements such as page tabs and side panels could appear in screenshots. |
| Impact | Screenshots could look like work-in-progress instead of final portfolio visuals. |
| Root Cause | Screenshot capture area included Power BI UI elements. |
| Resolution | Screenshots were captured from the dashboard canvas only. |
| Validation | Final screenshots were saved under `06_powerbi_dashboard/power bi ekran görüntüleri`. |
| Status | Closed |

---

### ISS-015 — Python Documentation Accuracy Risk

| Field | Detail |
|---|---|
| Category | Documentation Accuracy |
| Issue | Python was initially mentioned as a project tool before verifying Python files existed in the project folder. |
| Impact | Documentation could overstate the technical stack. |
| Root Cause | Python was discussed during planning, but no `.py` or `.ipynb` file existed in the final Aurevia project folder. |
| Resolution | Python references were removed from final README and QA documentation. |
| Validation | Documentation now states SQL-based synthetic data creation and loading. |
| Status | Closed |

---

## Final Issue Log Status

All identified issues were reviewed, resolved, and closed.

The final project package includes the corrected Power BI dashboard, SQL scripts, SQL backup, dashboard screenshots, QA documentation, and technical documentation.