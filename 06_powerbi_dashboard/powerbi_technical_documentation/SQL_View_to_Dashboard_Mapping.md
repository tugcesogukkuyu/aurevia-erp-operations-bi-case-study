# SQL View to Power BI Dashboard Mapping

## Project

**Aurevia ERP Operations & BI Dashboard Case Study**

## Purpose

This document maps SQL reporting views to Power BI dashboard pages, KPI cards, visuals, and tables.

The purpose is to show the source-to-report relationship between the SQL Server reporting layer and the final Power BI dashboard.

---

## Reporting Views

| SQL View | Purpose |
|---|---|
| `vw_ExecutiveKPI` | High-level executive KPIs |
| `vw_MonthlySalesPerformance` | Monthly revenue and gross profit trend |
| `vw_CustomerSegmentPerformance` | Revenue and profit by customer segment |
| `vw_ProductCategoryProfitability` | Product category revenue, profit, margin, and quantity |
| `vw_InventoryRisk` | Stock level, reorder gap, and risk status |
| `vw_ReceivablesAging` | Invoice amount, payment amount, open balance, and aging buckets |
| `vw_SupplierPerformance` | Purchase amount, purchase order count, delay count, and delay rate |
| `vw_SalesChannelPerformance` | Revenue and sales performance by channel |

---

## Page-Level Mapping

| Power BI Page | SQL Source View(s) | Main Usage |
|---|---|---|
| Executive Overview | `vw_ExecutiveKPI`, `vw_MonthlySalesPerformance`, `vw_ReceivablesAging`, `vw_InventoryRisk`, `vw_SupplierPerformance` | Executive KPI summary |
| Sales Analysis | `vw_MonthlySalesPerformance`, `vw_SalesChannelPerformance`, `vw_CustomerSegmentPerformance` | Sales trend, channel, and segment analysis |
| Product Profitability | `vw_ProductCategoryProfitability` | Category-level profitability analysis |
| Inventory Risk | `vw_InventoryRisk` | Inventory shortage and stock risk monitoring |
| Receivables Collection | `vw_ReceivablesAging` | Collection rate and aging analysis |
| Supplier Performance | `vw_SupplierPerformance` | Supplier purchase and delay analysis |

---

## Executive Overview Mapping

| Dashboard Element | Source View | Field / Logic |
|---|---|---|
| Total Revenue | `vw_MonthlySalesPerformance` | Sum of TotalRevenue |
| Gross Profit | `vw_MonthlySalesPerformance` | Sum of GrossProfit |
| Gross Margin % | DAX | Gross Profit / Total Revenue |
| Collection Rate % | `vw_ReceivablesAging` | TotalPaidAmount / TotalInvoiceAmount |
| Open Balance | `vw_ReceivablesAging` | Sum of OpenBalance |
| Products Below Reorder Level | `vw_InventoryRisk` | Product risk count |
| Delayed Purchase Order Count | `vw_SupplierPerformance` | Sum of DelayedPurchaseOrderCount |
| Monthly Revenue & Gross Profit Trend | `vw_MonthlySalesPerformance` | Month, TotalRevenue, GrossProfit |

---

## Sales Analysis Mapping

| Dashboard Element | Source View | Field / Logic |
|---|---|---|
| Total Revenue KPI | `vw_MonthlySalesPerformance` | TotalRevenue |
| Gross Profit KPI | `vw_MonthlySalesPerformance` | GrossProfit |
| Gross Margin % KPI | DAX | Gross Profit / Total Revenue |
| Sales Order Count KPI | `vw_MonthlySalesPerformance` | SalesOrderCount |
| Monthly Trend | `vw_MonthlySalesPerformance` | Month, TotalRevenue, GrossProfit |
| Revenue by Sales Channel | `vw_SalesChannelPerformance` | SalesChannel, TotalRevenue |
| Revenue & Gross Profit by Customer Segment | `vw_CustomerSegmentPerformance` | CustomerSegment, TotalRevenue, GrossProfit |

---

## Product Profitability Mapping

| Dashboard Element | Source View | Field / Logic |
|---|---|---|
| Total Revenue KPI | `vw_ProductCategoryProfitability` | TotalRevenue |
| Gross Profit KPI | `vw_ProductCategoryProfitability` | GrossProfit |
| Gross Margin % KPI | DAX / GrossMarginPercent |
| Product Count KPI | `vw_ProductCategoryProfitability` | ProductCount |
| Gross Profit & Margin by Product Category | `vw_ProductCategoryProfitability` | ProductCategory, GrossProfit, GrossMarginPercent |
| Profit Contribution by Product Category | `vw_ProductCategoryProfitability` | ProductCategory, GrossProfit |
| Category Profitability Detail | `vw_ProductCategoryProfitability` | ProductCategory, Revenue, Profit, Margin, Quantity, Product Count |

---

## Inventory Risk Mapping

| Dashboard Element | Source View | Field / Logic |
|---|---|---|
| Products Monitored KPI | `vw_InventoryRisk` | Distinct ProductCode |
| Products Below Reorder Level KPI | `vw_InventoryRisk` | CurrentStockOnHand < ReorderLevel |
| Total Reorder Shortage KPI | `vw_InventoryRisk` | Sum of ReorderGap for negative stock products |
| Negative Stock Products KPI | `vw_InventoryRisk` | CurrentStockOnHand < 0 |
| Stock Risk Status Overview | `vw_InventoryRisk` | StockRiskStatus, Products Monitored |
| Reorder Shortage by Product | `vw_InventoryRisk` | ProductName, ReorderGap |
| Inventory Risk Action Table | `vw_InventoryRisk` | ProductCode, ProductName, ProductCategory, CurrentStockOnHand, ReorderLevel, ReorderGap, StockRiskStatus |

---

## Receivables Collection Mapping

| Dashboard Element | Source View | Field / Logic |
|---|---|---|
| Total Invoice Amount KPI | `vw_ReceivablesAging` | Sum of TotalInvoiceAmount |
| Total Paid Amount KPI | `vw_ReceivablesAging` | Sum of TotalPaidAmount |
| Open Balance KPI | `vw_ReceivablesAging` | Sum of OpenBalance |
| Collection Rate KPI | DAX | TotalPaidAmount / TotalInvoiceAmount |
| Invoice Count KPI | `vw_ReceivablesAging` | Sum of InvoiceCount |
| Open Balance by Aging Bucket | `vw_ReceivablesAging` | AgingBucket, OpenBalance |
| Invoice Count by Aging Bucket | `vw_ReceivablesAging` | AgingBucket, InvoiceCount |
| Receivables Aging Detail | `vw_ReceivablesAging` | AgingBucket, TotalInvoiceAmount, TotalPaidAmount, OpenBalance, InvoiceCount |

---

## Supplier Performance Mapping

| Dashboard Element | Source View | Field / Logic |
|---|---|---|
| Total Purchase Amount KPI | `vw_SupplierPerformance` | Sum of TotalPurchaseAmount |
| Purchase Order Count KPI | `vw_SupplierPerformance` | Sum of PurchaseOrderCount |
| Delayed Purchase Order Count KPI | `vw_SupplierPerformance` | Sum of DelayedPurchaseOrderCount |
| Average Delay Days KPI | `vw_SupplierPerformance` | Average of AverageDelayDays |
| Supplier Delay Rate % KPI | DAX | DelayedPurchaseOrderCount / PurchaseOrderCount |
| Total Purchase Amount by Supplier | `vw_SupplierPerformance` | SupplierName, TotalPurchaseAmount |
| Supplier Delay Action Table | `vw_SupplierPerformance` | SupplierName, PurchaseOrderCount, DelayedPurchaseOrderCount, Delay Rate, AverageDelayDays |

---

## Source-to-Report Validation Notes

| Validation Area | Control |
|---|---|
| KPI totals | Compared against SQL view totals |
| Percentage calculations | Rebuilt with DAX and checked against source logic |
| Inventory risk counts | Reconciled against `vw_InventoryRisk` |
| Receivables values | Reconciled against aging view |
| Supplier delays | Reconciled against supplier performance view |
| Aggregation behavior | Reviewed in Power BI field well |

---

## Final Status

All Power BI pages were mapped to SQL reporting views and validated through source-to-report reconciliation.