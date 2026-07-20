# Power BI Report Build Log

## Project

**Aurevia ERP Operations & BI Dashboard Case Study**

## Purpose

This document records the Power BI report build process, page-level design decisions, field selections, visual choices, and issues resolved during development.

The goal is to show that the dashboard was manually built and validated in Power BI Desktop using SQL reporting views and DAX measures.

---

## Report File

```text
Aurevia_ERP_Operations_BI_Dashboard_FINAL_RECOVERED.pbix
```

Location:

```text
06_powerbi_dashboard
```

---

## Report Pages

| Page No | Page Name | Status |
|---:|---|---|
| 1 | Executive Overview | Completed |
| 2 | Sales Analysis | Completed |
| 3 | Product Profitability | Completed |
| 4 | Inventory Risk | Completed |
| 5 | Receivables Collection | Completed |
| 6 | Supplier Performance | Completed |

---

## Global Design Settings

| Area | Design Decision |
|---|---|
| Canvas background | Light executive dashboard background |
| KPI card style | Consistent layout, white card background, border, shadow |
| Header | Same corporate header structure across pages |
| Reporting period | Jan 2025 – Jun 2026 |
| Visual titles | Business-oriented and left aligned |
| Tables | Formatted for operational review |
| Color approach | Consistent corporate blue and neutral tones |
| Dashboard purpose | Executive and operational decision support |

---

## Page 1 — Executive Overview

### Objective

Provide a high-level management summary of financial performance, collection efficiency, inventory risk, and supplier delivery performance.

### KPI Cards

| KPI | Source / Logic |
|---|---|
| Total Revenue | Total revenue from sales reporting view |
| Gross Profit | Revenue minus cost |
| Gross Margin % | Gross Profit / Total Revenue |
| Collection Rate % | Paid Amount / Invoice Amount |
| Open Balance | Invoice Amount - Paid Amount |
| Overdue Invoice Count | Receivables aging logic |
| Products Below Reorder Level | Inventory risk logic |
| Delayed Purchase Order Count | Supplier performance logic |

### Visuals

| Visual | Visual Type | Business Purpose |
|---|---|---|
| Monthly Revenue & Gross Profit Trend | Line and clustered column chart | Monitor sales and profitability trend |
| Open Balance by Aging Bucket | Donut / aging visual | Review receivables exposure |

### Build Notes

- KPI cards were placed in a clean executive layout.
- Financial KPIs were formatted with display units for readability.
- Percentage KPIs were formatted with one decimal place.
- Risk KPIs were included to connect financial and operational performance.

---

## Page 2 — Sales Analysis

### Objective

Analyze sales performance by month, sales channel, and customer segment.

### KPI Cards

| KPI | Source / Logic |
|---|---|
| Total Revenue | `vw_MonthlySalesPerformance` |
| Gross Profit | `vw_MonthlySalesPerformance` |
| Gross Margin % | DAX measure |
| Sales Order Count | Sales reporting view |

### Visuals

| Visual | Visual Type | Source |
|---|---|---|
| Monthly Revenue & Gross Profit Trend | Line and clustered column chart | `vw_MonthlySalesPerformance` |
| Revenue by Sales Channel | Bar / column chart | `vw_SalesChannelPerformance` |
| Revenue & Gross Profit by Customer Segment | Clustered chart | `vw_CustomerSegmentPerformance` |

### Build Notes

- Unnecessary duplicate visuals were avoided.
- The page was designed to answer channel and segment performance questions.
- Revenue and profit were shown together where business comparison was needed.

---

## Page 3 — Product Profitability

### Objective

Analyze category-level revenue, gross profit, margin, and product contribution.

### KPI Cards

| KPI | Source / Logic |
|---|---|
| Total Revenue | Product profitability view |
| Gross Profit | Product profitability view |
| Gross Margin % | DAX / calculated margin |
| Product Count | Product count from category view |

### Visuals

| Visual | Visual Type | Fields |
|---|---|---|
| Gross Profit & Margin by Product Category | Line and clustered column chart | ProductCategory, GrossProfit, GrossMarginPercent |
| Profit Contribution by Product Category | Treemap | ProductCategory, GrossProfit |
| Category Profitability Detail | Table | Revenue, Gross Profit, Margin, Quantity, Product Count |
| Key Insights | Text box | Business interpretation |

### Build Notes

- Scatter chart idea was rejected because it did not clearly answer the business question.
- Category profitability was shown with both value and margin context.
- A business insight box was added to make the page more executive-friendly.

---

## Page 4 — Inventory Risk

### Objective

Identify products with stock shortages, negative stock, and reorder risk.

### KPI Cards

| KPI | Source / Logic |
|---|---|
| Products Monitored | Distinct count of ProductCode |
| Products Below Reorder Level | CurrentStockOnHand < ReorderLevel |
| Total Reorder Shortage | Sum of ReorderGap for negative stock products |
| Negative Stock Products | CurrentStockOnHand < 0 |

### Visuals

| Visual | Visual Type | Fields |
|---|---|---|
| Stock Risk Status Overview | Donut chart | StockRiskStatus, Products Monitored |
| Reorder Shortage by Product | Bar chart | ProductName, ReorderGap |
| Inventory Risk Action Table | Table | ProductCode, ProductName, Category, Stock, Reorder, Shortage, Status |

### Build Notes

- Inventory shortage logic was reviewed carefully because sign direction matters.
- Exact reorder shortage value was formatted with a label measure to avoid unwanted rounding.
- The table was filtered to show risk products requiring action.

### Issue Resolved

| Issue | Resolution |
|---|---|
| Reorder shortage displayed as rounded value | Created `Total Reorder Shortage Label` measure |
| Inventory risk calculation sign confusion | Validated against `StockRiskStatus` and ReorderGap logic |
| Table needed operational readability | Renamed columns and adjusted formatting |

---

## Page 5 — Receivables Collection

### Objective

Monitor invoice collection, open balance, and aging risk.

### KPI Cards

| KPI | Source / Logic |
|---|---|
| Total Invoice Amount | Sum of TotalInvoiceAmount |
| Total Paid Amount | Sum of TotalPaidAmount |
| Open Balance | Sum of OpenBalance |
| Collection Rate | Paid Amount / Invoice Amount |
| Invoice Count | Sum of InvoiceCount |

### Visuals

| Visual | Visual Type | Fields |
|---|---|---|
| Open Balance by Aging Bucket | Clustered bar chart | AgingBucket, OpenBalance |
| Invoice Count by Aging Bucket | Clustered column chart | AgingBucket, InvoiceCount |
| Receivables Aging Detail | Table | AgingBucket, Invoice, Paid, Open, Count, Collection Rate |
| Key Insights | Text box | Business interpretation |

### Build Notes

- Customer-level receivables visual was not used because the available reporting view was aging-bucket based.
- The KPI title was corrected from Open Invoice Count to Invoice Count because the value represented total invoice count.
- Aging bucket analysis was used to separate value risk from volume workload.

---

## Page 6 — Supplier Performance

### Objective

Analyze supplier purchase volume and delivery delay performance.

### KPI Cards

| KPI | Source / Logic |
|---|---|
| Total Purchase Amount | Sum of TotalPurchaseAmount |
| Purchase Order Count | Sum of PurchaseOrderCount |
| Delayed Purchase Order Count | Sum of DelayedPurchaseOrderCount |
| Average Delay Days | Average of AverageDelayDays |
| Supplier Delay Rate % | Delayed PO / Total PO |

### Visuals

| Visual | Visual Type | Fields |
|---|---|---|
| Total Purchase Amount by Supplier | Bar chart | SupplierName, TotalPurchaseAmount |
| Key Insights | Text box | Business interpretation |
| Supplier Delay Action Table | Table | Supplier, PO Count, Delayed PO, Delay Rate, Avg Delay Days |

### Build Notes

- Scatter and combo chart alternatives were tested but rejected because they were not clear enough.
- A supplier action table was used to support operational follow-up.
- Table column names were renamed for readability.
- Table grid text size and padding were adjusted.

---

## Report Build Issues & Fixes

| Issue | Page | Resolution |
|---|---|---|
| Numeric fields defaulted to Count | Multiple pages | Aggregation changed to `Toplam` |
| Percent values risked incorrect summing | Product / Supplier pages | Measures or `Ortalama` aggregation used |
| Reorder shortage rounded to 2K | Inventory Risk | Label measure created |
| Wrong KPI title risk | Receivables Collection | Corrected title to Invoice Count |
| Low-value visuals | Product / Supplier pages | Replaced with business-focused visuals |
| Table readability issue | Supplier Performance | Adjusted grid text size and row padding |
| Power BI side panels visible in screenshots | Final export | Screenshots captured from report canvas only |

---

## Final Status

The Power BI report was manually built, reviewed page by page, reconciled against SQL source views, and exported as final dashboard screenshots.