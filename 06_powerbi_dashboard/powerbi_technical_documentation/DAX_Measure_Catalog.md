# DAX Measure Catalog

## Project

**Aurevia ERP Operations & BI Dashboard Case Study**

## Purpose

This document lists the Power BI DAX measures and calculated KPI logic used in the Aurevia ERP Operations & BI Dashboard.

The purpose of this catalog is to document how dashboard KPI values were calculated, formatted, and validated against SQL reporting views.

---

## Measure Summary

| Measure / KPI | Main Page Usage | Source View |
|---|---|---|
| Total Revenue | Executive Overview, Sales Analysis, Product Profitability | `vw_MonthlySalesPerformance`, `vw_ProductCategoryProfitability` |
| Gross Profit | Executive Overview, Sales Analysis, Product Profitability | `vw_MonthlySalesPerformance`, `vw_ProductCategoryProfitability` |
| Gross Margin % | Executive Overview, Sales Analysis, Product Profitability | DAX calculation |
| Receivables Collection Rate % | Receivables Collection | `vw_ReceivablesAging` |
| Products Monitored | Inventory Risk | `vw_InventoryRisk` |
| Products Below Reorder Level | Inventory Risk | `vw_InventoryRisk` |
| Negative Stock Products | Inventory Risk | `vw_InventoryRisk` |
| Total Reorder Shortage | Inventory Risk | `vw_InventoryRisk` |
| Total Reorder Shortage Label | Inventory Risk | DAX formatting measure |
| Supplier Delay Rate % | Supplier Performance | `vw_SupplierPerformance` |

---

## Core Financial Measures

### Total Revenue

```DAX
Total Revenue =
SUM('vw_MonthlySalesPerformance'[TotalRevenue])
```

Used for:

- Executive revenue KPI
- Sales trend analysis
- Overall business performance monitoring

Validation note:

The final dashboard value reconciled to approximately **420.6M** total revenue.

---

### Total Cost

```DAX
Total Cost =
SUM('vw_MonthlySalesPerformance'[TotalCost])
```

Used for:

- Gross profit calculation
- Margin calculation

---

### Gross Profit

```DAX
Gross Profit =
SUM('vw_MonthlySalesPerformance'[GrossProfit])
```

Alternative logic:

```DAX
Gross Profit =
[Total Revenue] - [Total Cost]
```

Used for:

- Executive KPI
- Sales trend chart
- Product profitability analysis

Validation note:

The final dashboard value reconciled to approximately **191.8M** gross profit.

---

### Gross Margin %

```DAX
Gross Margin % =
DIVIDE(
    [Gross Profit],
    [Total Revenue]
)
```

Formatting:

```text
Percentage
1 decimal place
```

Validation note:

The final dashboard value reconciled to approximately **45.6%**.

---

## Receivables Measures

### Total Invoice Amount

```DAX
Total Invoice Amount =
SUM('vw_ReceivablesAging'[TotalInvoiceAmount])
```

Used for:

- Receivables Collection KPI card
- Collection rate calculation

---

### Total Paid Amount

```DAX
Total Paid Amount =
SUM('vw_ReceivablesAging'[TotalPaidAmount])
```

Used for:

- Receivables Collection KPI card
- Collection rate calculation

---

### Open Balance

```DAX
Open Balance =
SUM('vw_ReceivablesAging'[OpenBalance])
```

Used for:

- Receivables Collection KPI card
- Aging bucket analysis

Validation note:

The final dashboard value reconciled to approximately **95.6M** open balance.

---

### Receivables Collection Rate %

```DAX
Receivables Collection Rate % =
DIVIDE(
    SUM('vw_ReceivablesAging'[TotalPaidAmount]),
    SUM('vw_ReceivablesAging'[TotalInvoiceAmount])
)
```

Formatting:

```text
Percentage
1 decimal place
```

Validation note:

The final dashboard value reconciled to approximately **77.3%**.

---

## Inventory Risk Measures

### Products Monitored

```DAX
Products Monitored =
DISTINCTCOUNT('vw_InventoryRisk'[ProductCode])
```

Used for:

- Inventory Risk KPI card
- Stock Risk Status Overview donut chart

Validation note:

The final dashboard value reconciled to **78** monitored stockable products.

---

### Products Below Reorder Level

```DAX
Products Below Reorder Level =
CALCULATE(
    DISTINCTCOUNT('vw_InventoryRisk'[ProductCode]),
    FILTER(
        'vw_InventoryRisk',
        'vw_InventoryRisk'[CurrentStockOnHand] < 'vw_InventoryRisk'[ReorderLevel]
    )
)
```

Used for:

- Inventory Risk KPI card
- Executive Overview operational risk KPI

Validation note:

The final dashboard value reconciled to **4** products below reorder level.

---

### Negative Stock Products

```DAX
Negative Stock Products =
CALCULATE(
    DISTINCTCOUNT('vw_InventoryRisk'[ProductCode]),
    'vw_InventoryRisk'[CurrentStockOnHand] < 0
)
```

Used for:

- Inventory Risk KPI card
- Inventory action table filtering

Validation note:

The final dashboard value reconciled to **4** negative stock products.

---

### Total Reorder Shortage

```DAX
Total Reorder Shortage =
CALCULATE(
    SUM('vw_InventoryRisk'[ReorderGap]),
    'vw_InventoryRisk'[StockRiskStatus] = "NEGATIVE STOCK"
)
```

Used for:

- Inventory Risk KPI card
- Reorder shortage monitoring

Validation note:

The final dashboard value reconciled to **1,855** total reorder shortage.

---

### Total Reorder Shortage Label

```DAX
Total Reorder Shortage Label =
FORMAT(
    [Total Reorder Shortage],
    "#,0"
)
```

Used for:

- Displaying reorder shortage as a clean non-rounded KPI label

Reason:

Power BI display units sometimes rounded the value to `2K`. A label measure was created to show the exact value as `1,855`.

---

## Supplier Performance Measures

### Purchase Order Count

```DAX
Purchase Order Count =
SUM('vw_SupplierPerformance'[PurchaseOrderCount])
```

Validation note:

The final dashboard value reconciled to **800** purchase orders.

---

### Delayed Purchase Order Count

```DAX
Delayed Purchase Order Count =
SUM('vw_SupplierPerformance'[DelayedPurchaseOrderCount])
```

Validation note:

The final dashboard value reconciled to **679** delayed purchase orders.

---

### Supplier Delay Rate %

```DAX
Supplier Delay Rate % =
DIVIDE(
    SUM('vw_SupplierPerformance'[DelayedPurchaseOrderCount]),
    SUM('vw_SupplierPerformance'[PurchaseOrderCount])
)
```

Formatting:

```text
Percentage
1 decimal place
```

Validation note:

The final dashboard value reconciled to approximately **84.9%**.

---

### Average Delay Days

```DAX
Average Delay Days =
AVERAGE('vw_SupplierPerformance'[AverageDelayDays])
```

Used for:

- Supplier Performance KPI card
- Supplier delay monitoring

Validation note:

The final dashboard value reconciled to approximately **2.53 days**.

---

## Product Profitability Measures

### Product Count

```DAX
Product Count =
SUM('vw_ProductCategoryProfitability'[ProductCount])
```

Used for:

- Product Profitability KPI card

Validation note:

The final dashboard value reconciled to **82** products.

---

### Category Gross Margin %

```DAX
Category Gross Margin % =
AVERAGE('vw_ProductCategoryProfitability'[GrossMarginPercent])
```

Used for:

- Gross Profit & Margin by Product Category visual

Reason:

Category-level margin percentage should not be summed. The percentage was used as an average or measure-based value depending on the visual context.

---

## Measure Design Notes

| Topic | Decision |
|---|---|
| Division logic | `DIVIDE()` was used instead of `/` to avoid divide-by-zero errors |
| Percentage KPIs | Formatted as percentage with 1 decimal place |
| Revenue KPIs | Display units were reviewed for readability |
| Inventory shortage | Exact display was handled with a label measure |
| Count metrics | Distinct count was used where product-level uniqueness mattered |
| Aggregation control | Raw numeric fields were checked to avoid accidental `Count` aggregation |

---

## Final Status

DAX measures were validated against SQL reporting views and reviewed in the final Power BI dashboard.