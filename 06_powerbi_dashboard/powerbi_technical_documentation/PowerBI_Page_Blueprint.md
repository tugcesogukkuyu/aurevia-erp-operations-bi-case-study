# Power BI Page Blueprint

## Project

**Aurevia ERP Operations & BI Dashboard Case Study**

## Purpose

This document defines the structure of each Power BI report page.

It documents the business question, KPI cards, visuals, source views, fields, and validation notes for every dashboard page.

---

## Page 1 — Executive Overview

### Business Question

How is the company performing overall across revenue, profitability, receivables, inventory risk, and supplier delays?

### KPI Cards

| KPI | Calculation / Source |
|---|---|
| Total Revenue | Sum of revenue |
| Gross Profit | Revenue minus cost |
| Gross Margin % | Gross Profit / Total Revenue |
| Collection Rate % | Total Paid Amount / Total Invoice Amount |
| Open Balance | Invoice Amount - Paid Amount |
| Overdue Invoice Count | Receivables aging logic |
| Products Below Reorder Level | Inventory risk logic |
| Delayed Purchase Order Count | Supplier delay logic |

### Visuals

| Visual | Type | Purpose |
|---|---|---|
| Monthly Revenue & Gross Profit Trend | Line and clustered column chart | Compare revenue and profit trend |
| Open Balance by Aging Bucket | Aging visual / donut | Show receivables exposure |

### Source Views

- `vw_ExecutiveKPI`
- `vw_MonthlySalesPerformance`
- `vw_ReceivablesAging`
- `vw_InventoryRisk`
- `vw_SupplierPerformance`

### Validation Notes

- Financial totals reconciled against SQL source values.
- Percentage KPIs formatted with one decimal place.
- Operational risk KPIs were checked against inventory and supplier views.

---

## Page 2 — Sales Analysis

### Business Question

Which months, sales channels, and customer segments drive revenue and gross profit?

### KPI Cards

| KPI | Calculation / Source |
|---|---|
| Total Revenue | Sum of TotalRevenue |
| Gross Profit | Sum of GrossProfit |
| Gross Margin % | Gross Profit / Total Revenue |
| Sales Order Count | Sum / count of sales orders |

### Visuals

| Visual | Type | Fields |
|---|---|---|
| Monthly Revenue & Gross Profit Trend | Line and clustered column chart | Month, TotalRevenue, GrossProfit |
| Revenue by Sales Channel | Bar / column chart | SalesChannel, TotalRevenue |
| Revenue & Gross Profit by Customer Segment | Clustered chart | CustomerSegment, TotalRevenue, GrossProfit |

### Source Views

- `vw_MonthlySalesPerformance`
- `vw_SalesChannelPerformance`
- `vw_CustomerSegmentPerformance`

### Validation Notes

- Revenue and profit fields were aggregated using `Toplam`.
- Visual selection was limited to business-relevant comparisons.
- Duplicate visual structures were avoided.

---

## Page 3 — Product Profitability

### Business Question

Which product categories generate the highest gross profit and which categories provide stronger margin performance?

### KPI Cards

| KPI | Calculation / Source |
|---|---|
| Total Revenue | Sum of category revenue |
| Gross Profit | Sum of category gross profit |
| Gross Margin % | Gross Profit / Total Revenue |
| Product Count | Sum of product count |

### Visuals

| Visual | Type | Fields |
|---|---|---|
| Gross Profit & Margin by Product Category | Line and clustered column chart | ProductCategory, GrossProfit, GrossMarginPercent |
| Profit Contribution by Product Category | Treemap | ProductCategory, GrossProfit |
| Category Profitability Detail | Table | ProductCategory, Revenue, Gross Profit, Margin, Quantity, Product Count |
| Key Insights | Text box | Business interpretation |

### Source View

- `vw_ProductCategoryProfitability`

### Validation Notes

- GrossProfit was aggregated using `Toplam`.
- GrossMarginPercent was not summed; it was handled as average / measure logic.
- Treemap was used to show relative profit contribution.
- Scatter visual was rejected because it did not communicate the business question clearly.

---

## Page 4 — Inventory Risk

### Business Question

Which products create inventory risk due to negative stock, reorder shortage, or low stock levels?

### KPI Cards

| KPI | Calculation / Source |
|---|---|
| Products Monitored | Distinct count of ProductCode |
| Products Below Reorder Level | CurrentStockOnHand < ReorderLevel |
| Total Reorder Shortage | Sum of ReorderGap for negative stock products |
| Negative Stock Products | CurrentStockOnHand < 0 |

### Visuals

| Visual | Type | Fields |
|---|---|---|
| Stock Risk Status Overview | Donut chart | StockRiskStatus, Products Monitored |
| Reorder Shortage by Product | Clustered bar chart | ProductName, ReorderGap |
| Inventory Risk Action Table | Table | ProductCode, ProductName, ProductCategory, CurrentStockOnHand, ReorderLevel, ReorderGap, StockRiskStatus |

### Source View

- `vw_InventoryRisk`

### Validation Notes

- Risk status values reconciled as Healthy Stock and Negative Stock.
- Negative stock product count reconciled to 4.
- Total reorder shortage reconciled to 1,855.
- Exact value display was handled with a DAX label measure.

---

## Page 5 — Receivables Collection

### Business Question

How much invoiced revenue has been collected, how much remains open, and where is the receivables aging risk?

### KPI Cards

| KPI | Calculation / Source |
|---|---|
| Total Invoice Amount | Sum of TotalInvoiceAmount |
| Total Paid Amount | Sum of TotalPaidAmount |
| Open Balance | Sum of OpenBalance |
| Collection Rate | Total Paid Amount / Total Invoice Amount |
| Invoice Count | Sum of InvoiceCount |

### Visuals

| Visual | Type | Fields |
|---|---|---|
| Open Balance by Aging Bucket | Clustered bar chart | AgingBucket, OpenBalance |
| Invoice Count by Aging Bucket | Clustered column chart | AgingBucket, InvoiceCount |
| Receivables Aging Detail | Table | AgingBucket, TotalInvoiceAmount, TotalPaidAmount, OpenBalance, InvoiceCount, Collection Rate |
| Key Insights | Text box | Business interpretation |

### Source View

- `vw_ReceivablesAging`

### Validation Notes

- Collection rate reconciled to 77.3%.
- Open balance reconciled to approximately 95.6M.
- Invoice count reconciled to 3,000.
- KPI title was corrected to avoid misrepresenting total invoice count as open invoice count.

---

## Page 6 — Supplier Performance

### Business Question

Which suppliers have the highest purchase volume and which suppliers create delivery delay risk?

### KPI Cards

| KPI | Calculation / Source |
|---|---|
| Total Purchase Amount | Sum of TotalPurchaseAmount |
| Purchase Order Count | Sum of PurchaseOrderCount |
| Delayed Purchase Order Count | Sum of DelayedPurchaseOrderCount |
| Average Delay Days | Average of AverageDelayDays |
| Supplier Delay Rate % | Delayed PO Count / Purchase Order Count |

### Visuals

| Visual | Type | Fields |
|---|---|---|
| Total Purchase Amount by Supplier | Clustered bar chart | SupplierName, TotalPurchaseAmount |
| Supplier Delay Action Table | Table | SupplierName, PurchaseOrderCount, DelayedPurchaseOrderCount, Supplier Delay Rate %, AverageDelayDays |
| Key Insights | Text box | Business interpretation |

### Source View

- `vw_SupplierPerformance`

### Validation Notes

- Purchase order count reconciled to 800.
- Delayed purchase order count reconciled to 679.
- Supplier delay rate reconciled to 84.9%.
- Table was selected over scatter/combo alternatives because it better supported operational follow-up.

---

## Final Page Blueprint Status

| Page | Blueprint Status |
|---|---|
| Executive Overview | Completed |
| Sales Analysis | Completed |
| Product Profitability | Completed |
| Inventory Risk | Completed |
| Receivables Collection | Completed |
| Supplier Performance | Completed |