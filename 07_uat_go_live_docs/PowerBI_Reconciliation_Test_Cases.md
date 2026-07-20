# Power BI Reconciliation Test Cases

## Project

**Aurevia ERP Operations & BI Dashboard Case Study**

## Purpose

This document validates that Power BI dashboard metrics match the SQL reporting layer.

The objective is to confirm that dashboard KPI cards, charts, and tables are consistent with the SQL Server source views.

---

## Reconciliation Method

Power BI values were compared against SQL reporting view outputs.

The validation focused on:

- KPI cards
- DAX measures
- aggregation behavior
- chart values
- table totals
- source-to-report consistency

---

## Source Views Used

| Power BI Area | SQL Source View |
|---|---|
| Executive KPIs | `vw_ExecutiveKPI` |
| Monthly Sales Trend | `vw_MonthlySalesPerformance` |
| Customer Segment Analysis | `vw_CustomerSegmentPerformance` |
| Product Profitability | `vw_ProductCategoryProfitability` |
| Inventory Risk | `vw_InventoryRisk` |
| Receivables Aging | `vw_ReceivablesAging` |
| Supplier Performance | `vw_SupplierPerformance` |
| Sales Channel Analysis | `vw_SalesChannelPerformance` |

---

## KPI Reconciliation Test Cases

| Test ID | Dashboard Page | KPI / Visual | Source Logic | Expected Result | Power BI Result | Status |
|---|---|---|---|---:|---:|---|
| BI-001 | Executive Overview | Total Revenue | Sum of total revenue from sales reporting view | 420.6M | 421M | PASS |
| BI-002 | Executive Overview | Gross Profit | Total revenue minus total cost | 191.8M | 192M | PASS |
| BI-003 | Executive Overview | Gross Margin % | Gross profit / total revenue | 45.6% | 45.6% | PASS |
| BI-004 | Executive Overview | Collection Rate % | Total paid amount / total invoice amount | 77.3% | 77.3% | PASS |
| BI-005 | Executive Overview | Open Balance | Total invoice amount minus total paid amount | 95.6M | 96M | PASS |
| BI-006 | Executive Overview | Products Below Reorder Level | Count of products below reorder level | 4 | 4 | PASS |
| BI-007 | Executive Overview | Delayed Purchase Orders | Count of delayed purchase orders | 679 | 679 | PASS |
| BI-008 | Sales Analysis | Sales Order Count | Count of sales orders | 3,000 | 3K | PASS |
| BI-009 | Receivables Collection | Invoice Count | Sum of invoice count | 3,000 | 3K | PASS |
| BI-010 | Supplier Performance | Purchase Order Count | Sum of purchase order count | 800 | 800 | PASS |
| BI-011 | Supplier Performance | Supplier Delay Rate % | Delayed PO count / total PO count | 84.9% | 84.9% | PASS |
| BI-012 | Inventory Risk | Negative Stock Products | Count of products with negative stock | 4 | 4 | PASS |

---

## DAX Measure Validation

### Gross Margin %

```DAX
Gross Margin % =
DIVIDE(
    [Gross Profit],
    [Total Revenue]
)
```

Validation:

| Expected | Result |
|---:|---:|
| 45.6% | 45.6% |

Status: **PASS**

---

### Receivables Collection Rate %

```DAX
Receivables Collection Rate % =
DIVIDE(
    SUM('vw_ReceivablesAging'[TotalPaidAmount]),
    SUM('vw_ReceivablesAging'[TotalInvoiceAmount])
)
```

Validation:

| Expected | Result |
|---:|---:|
| 77.3% | 77.3% |

Status: **PASS**

---

### Supplier Delay Rate %

```DAX
Supplier Delay Rate % =
DIVIDE(
    SUM('vw_SupplierPerformance'[DelayedPurchaseOrderCount]),
    SUM('vw_SupplierPerformance'[PurchaseOrderCount])
)
```

Validation:

| Expected | Result |
|---:|---:|
| 84.9% | 84.9% |

Status: **PASS**

---

### Products Monitored

```DAX
Products Monitored =
DISTINCTCOUNT('vw_InventoryRisk'[ProductCode])
```

Validation:

| Expected | Result |
|---:|---:|
| 78 | 78 |

Status: **PASS**

---

### Negative Stock Products

```DAX
Negative Stock Products =
CALCULATE(
    DISTINCTCOUNT('vw_InventoryRisk'[ProductCode]),
    'vw_InventoryRisk'[CurrentStockOnHand] < 0
)
```

Validation:

| Expected | Result |
|---:|---:|
| 4 | 4 |

Status: **PASS**

---

## Visual-Level Reconciliation

| Test ID | Page | Visual | Validation |
|---|---|---|---|
| V-001 | Sales Analysis | Monthly Revenue & Gross Profit Trend | Monthly revenue and gross profit values matched SQL monthly sales view |
| V-002 | Sales Analysis | Revenue by Sales Channel | Sales channel totals matched `vw_SalesChannelPerformance` |
| V-003 | Product Profitability | Gross Profit & Margin by Product Category | Category totals matched product profitability view |
| V-004 | Inventory Risk | Stock Risk Status Overview | Risk status counts matched inventory risk view |
| V-005 | Inventory Risk | Reorder Shortage by Product | Negative stock products were correctly filtered |
| V-006 | Receivables Collection | Open Balance by Aging Bucket | Aging bucket values matched receivables aging view |
| V-007 | Supplier Performance | Total Purchase Amount by Supplier | Supplier purchase totals matched supplier performance view |
| V-008 | Supplier Performance | Supplier Delay Action Table | Delayed PO counts and delay rates matched supplier source view |

---

## Aggregation Issues Checked

During dashboard validation, the following Power BI aggregation risks were reviewed:

| Risk | Resolution |
|---|---|
| Numeric fields displayed as count instead of sum | Aggregation changed to `Toplam` |
| Percentage fields summed incorrectly | Percentage measures or `Ortalama` aggregation used |
| KPI labels showing rounded values | Display units and formatting reviewed |
| Inventory risk measures returning wrong sign | Reorder shortage logic corrected |
| Table columns too wide or unreadable | Table grid formatting adjusted |
| Duplicate or low-value visuals | Replaced with business-focused visuals |

---

## Final Result

The Power BI dashboard passed source-to-report reconciliation.

The final report values were validated against SQL reporting views and reviewed for business consistency.