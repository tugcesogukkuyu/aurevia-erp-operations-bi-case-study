# Dashboard Demo Talking Points

## Project

**Aurevia ERP Operations & BI Dashboard Case Study**

## Purpose

This document provides short talking points for presenting the Power BI dashboard during an interview, portfolio review, or project walkthrough.

---

## Opening Summary

This project simulates an ERP-based reporting scenario for a fictional wellness and professional supply company.

I first modeled the ERP business process, then created a SQL Server database, loaded synthetic ERP transaction data, validated the data with SQL, created reporting views, and finally built a 6-page Power BI dashboard.

The dashboard focuses on sales, product profitability, inventory risk, receivables collection, and supplier performance.

---

## Page 1 — Executive Overview

### How to Present

This is the management summary page.

It combines financial KPIs and operational risk indicators in one view.

### Points to Mention

- Total revenue is around 420.6M.
- Gross margin is around 45.6%.
- Collection rate is around 77.3%.
- Open receivables balance is around 95.6M.
- Inventory and supplier risk indicators are also included.
- This page is designed for a quick executive-level review.

### Strong Sentence

The goal of this page is not only to show revenue, but also to connect financial performance with operational risks such as inventory shortages and supplier delays.

---

## Page 2 — Sales Analysis

### How to Present

This page focuses on sales performance by time, channel, and customer segment.

### Points to Mention

- Monthly revenue and gross profit are shown together.
- Sales channel analysis helps compare channel contribution.
- Customer segment analysis shows which segments generate stronger revenue and profit.
- Duplicate visuals were avoided to keep the page focused.

### Strong Sentence

I designed this page to answer where the revenue comes from and which customer or channel groups contribute most to profitability.

---

## Page 3 — Product Profitability

### How to Present

This page analyzes product category performance.

### Points to Mention

- Category-level gross profit and margin are shown together.
- A treemap shows profit contribution by category.
- The detail table allows a more operational review of revenue, profit, margin, quantity, and product count.
- Margin percentages were not summed; aggregation was controlled.

### Strong Sentence

This page separates high-volume profit contribution from percentage margin performance, which is important for commercial decision-making.

---

## Page 4 — Inventory Risk

### How to Present

This page identifies products that require stock follow-up.

### Points to Mention

- 78 products are monitored.
- 4 products are below reorder level.
- 4 products have negative stock risk.
- Total reorder shortage was validated as 1,855.
- The action table focuses on products that require operational attention.

### Strong Sentence

This page is designed as an operational risk screen, not just a stock summary.

---

## Page 5 — Receivables Collection

### How to Present

This page focuses on invoice collection and aging risk.

### Points to Mention

- Total invoice amount, paid amount, open balance, and collection rate are shown.
- Collection rate is around 77.3%.
- Open balance is around 95.6M.
- Aging bucket analysis helps prioritize collection follow-up.
- Customer-level receivables were not used because the source view was aging-bucket based.

### Strong Sentence

This page helps finance teams understand not only how much is open, but also where the collection workload is concentrated by aging bucket.

---

## Page 6 — Supplier Performance

### How to Present

This page analyzes supplier purchasing volume and delay performance.

### Points to Mention

- Total purchase amount is around 333.5M.
- 800 purchase orders were analyzed.
- 679 purchase orders were delayed.
- Supplier delay rate is around 84.9%.
- A supplier action table was used instead of a complex visual because it supports follow-up better.

### Strong Sentence

This page turns supplier delay data into an actionable follow-up list for purchasing and operations teams.

---

## DAX & Measure Talking Points

### Measures Created

- Gross Margin %
- Receivables Collection Rate %
- Supplier Delay Rate %
- Products Monitored
- Products Below Reorder Level
- Negative Stock Products
- Total Reorder Shortage
- Total Reorder Shortage Label

### Strong Sentence

I used DAX measures for ratio-based KPIs and filtered calculations because raw field aggregation would not be sufficient for accurate business reporting.

---

## SQL Talking Points

### SQL Work Completed

- Created SQL Server database tables
- Loaded synthetic ERP data through SQL scripts
- Created reporting views for Power BI
- Wrote validation queries
- Checked business rule consistency
- Created SQL backup file

### Strong Sentence

Power BI was not built directly on raw assumptions; it was built on SQL reporting views and validated business logic.

---

## QA Talking Points

### QA Work Completed

- SQL data quality validation
- KPI reconciliation
- Source-to-report validation
- Aggregation behavior review
- Visual usability review
- Final screenshot and packaging control

### Strong Sentence

The dashboard values were checked against SQL source outputs, so the report is not only visually complete but also technically validated.

---

## Closing Summary

This project demonstrates an end-to-end BI workflow:

```text
ERP process simulation
→ SQL Server database
→ SQL validation
→ SQL reporting views
→ Power BI dashboard
→ DAX measures
→ Source-to-report reconciliation
→ Business insights
```

### Final Sentence

The main value of this project is that it connects business process understanding with SQL, Power BI, DAX, QA validation, and executive reporting.