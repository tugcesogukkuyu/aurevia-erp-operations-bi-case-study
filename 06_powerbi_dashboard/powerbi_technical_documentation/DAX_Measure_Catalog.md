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

---

# Advanced Analytics DAX Measures

## Purpose

This section documents the additional DAX measures used for the advanced Power BI pages:

| Page | Page Name |
|---|---|
| 07 | Sales Operations Command Center |
| 08 | Customer Portfolio Action Model |

These measures support the management cockpit, customer portfolio segmentation, collection-risk monitoring, and action-oriented customer prioritization logic.

---

## Page 07 - Sales Operations Command Center

### Total Revenue

```DAX
Total Revenue =
SUM ( vw_Page07_MonthlySalesCommandTrend[TotalRevenue] )
```

Purpose:

```text
Calculates total sales revenue for the selected reporting period.
```

Used in:

```text
Sales Operations Command Center KPI strip
Revenue and Gross Profit Trend
Action Queue
```

---

### Gross Profit

```DAX
Gross Profit =
SUM ( vw_Page07_MonthlySalesCommandTrend[GrossProfit] )
```

Purpose:

```text
Calculates total gross profit for the selected reporting period.
```

Used in:

```text
Sales Operations Command Center KPI strip
Revenue and Gross Profit Trend
```

---

### Gross Margin %

```DAX
Gross Margin % =
DIVIDE (
    [Gross Profit],
    [Total Revenue]
)
```

Purpose:

```text
Calculates gross margin percentage by dividing gross profit by total revenue.
```

Used in:

```text
Sales Operations Command Center KPI strip
Product category profitability tooltip
Management profitability monitoring
```

Format:

```text
Percentage, 1 decimal place
```

---

### Open Balance

```DAX
Open Balance =
SUM ( vw_Page07_ReceivablesOpenBalanceRisk[OpenBalance] )
```

Purpose:

```text
Calculates total unpaid invoice balance.
```

Used in:

```text
Sales Operations Command Center KPI strip
Receivables / Open Balance Risk
Action Queue
```

---

### Collection Rate

```DAX
Collection Rate =
DIVIDE (
    SUM ( Invoices[PaidAmount] ),
    SUM ( Invoices[InvoiceAmount] )
)
```

Purpose:

```text
Measures how much of the invoiced amount has been collected.
```

Business definition:

```text
Collection Rate = Total Paid Amount / Total Invoice Amount
```

Used in:

```text
Sales Operations Command Center KPI strip
Customer Portfolio Action Model model summary strip
```

Format:

```text
Percentage, 1 decimal place
```

---

### Product Category Revenue

```DAX
Product Category Revenue =
SUM ( vw_Page07_ProductCategoryRevenueRanking[TotalRevenue] )
```

Purpose:

```text
Calculates revenue by product category.
```

Used in:

```text
Top Product Categories visual
```

---

### Product Category Gross Profit

```DAX
Product Category Gross Profit =
SUM ( vw_Page07_ProductCategoryRevenueRanking[GrossProfit] )
```

Purpose:

```text
Calculates gross profit by product category.
```

Used in:

```text
Product category profitability tooltip
```

---

### Product Category Gross Margin %

```DAX
Product Category Gross Margin % =
DIVIDE (
    [Product Category Gross Profit],
    [Product Category Revenue]
)
```

Purpose:

```text
Calculates gross margin percentage by product category.
```

Used in:

```text
Product category ranking tooltip
Product profitability review
```

---

### Top Customer Revenue

```DAX
Top Customer Revenue =
SUM ( vw_Page07_TopCustomersByRevenue[TotalRevenue] )
```

Purpose:

```text
Calculates revenue generated by customers displayed in the top customer ranking.
```

Used in:

```text
Top Customers by Revenue visual
```

---

### Customer Revenue Share %

```DAX
Customer Revenue Share % =
DIVIDE (
    SUM ( vw_Page07_TopCustomersByRevenue[TotalRevenue] ),
    CALCULATE (
        SUM ( vw_Page07_TopCustomersByRevenue[TotalRevenue] ),
        ALL ( vw_Page07_TopCustomersByRevenue )
    )
)
```

Purpose:

```text
Shows each top customer's revenue contribution compared with the visible customer ranking.
```

Used in:

```text
Top Customers by Revenue table or bar chart
```

---

### Receivables Aging Open Balance

```DAX
Receivables Aging Open Balance =
SUM ( vw_Page07_ReceivablesOpenBalanceRisk[OpenBalance] )
```

Purpose:

```text
Calculates open balance by aging bucket.
```

Used in:

```text
Receivables / Open Balance Risk cards
```

---

### Open Balance Share %

```DAX
Open Balance Share % =
DIVIDE (
    SUM ( vw_Page07_ReceivablesOpenBalanceRisk[OpenBalance] ),
    CALCULATE (
        SUM ( vw_Page07_ReceivablesOpenBalanceRisk[OpenBalance] ),
        ALL ( vw_Page07_ReceivablesOpenBalanceRisk )
    )
)
```

Purpose:

```text
Shows each aging bucket's share of total open balance.
```

Used in:

```text
Receivables / Open Balance Risk visual
```

---

### Products Below Reorder Level

```DAX
Products Below Reorder Level =
CALCULATE (
    SUM ( vw_Page07_OperationalAlerts[AlertValue] ),
    vw_Page07_OperationalAlerts[AlertType] = "Products Below Reorder Level"
)
```

Purpose:

```text
Counts products where current stock is below reorder level.
```

Used in:

```text
Operational Alerts card
```

Expected project value:

```text
4
```

---

### Negative Stock Products

```DAX
Negative Stock Products =
CALCULATE (
    SUM ( vw_Page07_OperationalAlerts[AlertValue] ),
    vw_Page07_OperationalAlerts[AlertType] = "Negative Stock Products"
)
```

Purpose:

```text
Counts products with negative stock.
```

Used in:

```text
Operational Alerts card
```

Expected project value:

```text
4
```

---

### Delayed Purchase Orders

```DAX
Delayed Purchase Orders =
CALCULATE (
    SUM ( vw_Page07_OperationalAlerts[AlertValue] ),
    vw_Page07_OperationalAlerts[AlertType] = "Delayed Purchase Orders"
)
```

Purpose:

```text
Counts delayed purchase orders from supplier performance output.
```

Used in:

```text
Operational Alerts card
```

Expected project value:

```text
679
```

---

### High-Risk Categories

```DAX
High-Risk Categories =
CALCULATE (
    SUM ( vw_Page07_OperationalAlerts[AlertValue] ),
    vw_Page07_OperationalAlerts[AlertType] = "High-Risk Categories"
)
```

Purpose:

```text
Counts product categories affected by negative stock or below-reorder conditions.
```

Used in:

```text
Operational Alerts card
```

---

## Page 08 - Customer Portfolio Action Model

### Customer Count

```DAX
Customer Count =
DISTINCTCOUNT ( CustomerSegmentationOutput[CustomerID] )
```

Purpose:

```text
Counts customers included in the segmentation model output.
```

Used in:

```text
Customer Portfolio Action Model summary strip
```

Expected project value:

```text
150
```

---

### Segment Count

```DAX
Segment Count =
DISTINCTCOUNT ( CustomerSegmentationOutput[ClusterLabel] )
```

Purpose:

```text
Counts business-readable customer segments generated by the Python K-Means model.
```

Used in:

```text
Customer Portfolio Action Model summary strip
```

Expected project value:

```text
4
```

---

### Segment Revenue

```DAX
Segment Revenue =
SUM ( CustomerSegmentationOutput[TotalRevenue] )
```

Purpose:

```text
Calculates revenue by customer segment or selected portfolio context.
```

Used in:

```text
Cluster Profile Heatmap
Portfolio Risk & Growth Summary
Action Output
```

---

### Segment Gross Profit

```DAX
Segment Gross Profit =
SUM ( CustomerSegmentationOutput[GrossProfit] )
```

Purpose:

```text
Calculates gross profit by customer segment.
```

Used in:

```text
Cluster Profile Heatmap
Portfolio Risk & Growth Summary
```

---

### Segment Gross Margin %

```DAX
Segment Gross Margin % =
DIVIDE (
    [Segment Gross Profit],
    [Segment Revenue]
)
```

Purpose:

```text
Calculates profitability quality by customer segment.
```

Used in:

```text
Cluster Profile Heatmap
Portfolio Risk & Growth Summary
```

---

### Segment Open Balance

```DAX
Segment Open Balance =
SUM ( CustomerSegmentationOutput[OpenBalance] )
```

Purpose:

```text
Calculates open balance exposure by customer segment.
```

Used in:

```text
Cluster Profile Heatmap
Portfolio Risk & Growth Summary
Action Output
```

---

### Segment Revenue Share %

```DAX
Segment Revenue Share % =
DIVIDE (
    [Segment Revenue],
    CALCULATE (
        [Segment Revenue],
        ALL ( CustomerSegmentationOutput[ClusterLabel] )
    )
)
```

Purpose:

```text
Shows each customer segment's share of total revenue.
```

Used in:

```text
Cluster Profile Heatmap
Portfolio Risk & Growth Summary
```

Expected Page 08 values:

| Cluster | Revenue Share |
|---|---:|
| Strategic Value Customers | 42.9% |
| Growth Potential Customers | 28.5% |
| Collection Risk Customers | 21.0% |
| Low Contribution Customers | 7.6% |

---

### Segment Open Balance Share %

```DAX
Segment Open Balance Share % =
DIVIDE (
    [Segment Open Balance],
    CALCULATE (
        [Segment Open Balance],
        ALL ( CustomerSegmentationOutput[ClusterLabel] )
    )
)
```

Purpose:

```text
Shows each customer segment's share of total open balance exposure.
```

Used in:

```text
Cluster Profile Heatmap
Portfolio Risk & Growth Summary
```

Expected Page 08 values:

| Cluster | Open Balance Share |
|---|---:|
| Strategic Value Customers | 14.9% |
| Growth Potential Customers | 19.5% |
| Collection Risk Customers | 54.8% |
| Low Contribution Customers | 10.8% |

---

### Segment Collection Rate %

```DAX
Segment Collection Rate % =
AVERAGE ( CustomerSegmentationOutput[CollectionRate] )
```

Purpose:

```text
Shows average collection quality by customer segment.
```

Used in:

```text
Cluster Profile Heatmap
Portfolio Risk & Growth Summary
```

Important note:

```text
Segment Collection Rate % is a segment-level average from the segmentation output.
Overall Collection Rate is calculated separately as Total Paid Amount / Total Invoice Amount.
Therefore, the segment average values do not need to mathematically average back to the overall 77.3% KPI.
```

---

### Strategic Value Revenue

```DAX
Strategic Value Revenue =
CALCULATE (
    [Segment Revenue],
    CustomerSegmentationOutput[ClusterLabel] = "Strategic Value Customers"
)
```

Purpose:

```text
Calculates revenue generated by Strategic Value Customers.
```

Used in:

```text
Customer Portfolio Action Model summary strip
Action Output
```

Expected Page 08 value:

```text
180.5M
```

---

### Growth Potential Revenue

```DAX
Growth Potential Revenue =
CALCULATE (
    [Segment Revenue],
    CustomerSegmentationOutput[ClusterLabel] = "Growth Potential Customers"
)
```

Purpose:

```text
Calculates revenue generated by Growth Potential Customers.
```

Used in:

```text
Action Output
```

Expected Page 08 value:

```text
119.7M
```

---

### Collection Risk Exposure

```DAX
Collection Risk Exposure =
CALCULATE (
    [Segment Open Balance],
    CustomerSegmentationOutput[ClusterLabel] = "Collection Risk Customers"
)
```

Purpose:

```text
Calculates open balance exposure of Collection Risk Customers.
```

Used in:

```text
Customer Portfolio Action Model summary strip
Action Output
```

Expected Page 08 value:

```text
52.4M
```

---

### Low Contribution Customer Count

```DAX
Low Contribution Customer Count =
CALCULATE (
    DISTINCTCOUNT ( CustomerSegmentationOutput[CustomerID] ),
    CustomerSegmentationOutput[ClusterLabel] = "Low Contribution Customers"
)
```

Purpose:

```text
Counts customers assigned to the Low Contribution Customers segment.
```

Used in:

```text
Action Output
```

Expected Page 08 value:

```text
35
```

---

### Customer Priority Score

```DAX
Customer Priority Score =
MAX ( CustomerSegmentationOutput[CustomerPriorityScore] )
```

Purpose:

```text
Displays the Python-generated customer priority score in the customer priority list.
```

Used in:

```text
Customer Priority List
```

---

### Customer Priority Rank

```DAX
Customer Priority Rank =
RANKX (
    ALLSELECTED ( CustomerSegmentationOutput[CustomerName] ),
    [Customer Priority Score],
    ,
    DESC,
    Dense
)
```

Purpose:

```text
Ranks customers by Python-generated priority score within the current filter context.
```

Used in:

```text
Customer Priority List
```

---

### Channel Revenue

```DAX
Channel Revenue =
SUM ( vw_Page08_ChannelClusterMatrix[TotalRevenue] )
```

Purpose:

```text
Calculates revenue by sales channel and customer cluster.
```

Used in:

```text
Channel x Customer Segment Matrix
```

---

### Channel Revenue Share %

```DAX
Channel Revenue Share % =
DIVIDE (
    SUM ( vw_Page08_ChannelClusterMatrix[TotalRevenue] ),
    CALCULATE (
        SUM ( vw_Page08_ChannelClusterMatrix[TotalRevenue] ),
        ALLEXCEPT (
            vw_Page08_ChannelClusterMatrix,
            vw_Page08_ChannelClusterMatrix[SalesChannel]
        )
    )
)
```

Purpose:

```text
Shows how each sales channel's revenue is distributed across customer clusters.
```

Used in:

```text
Channel x Customer Segment Matrix
```

---

## Advanced Analytics Measure Notes

### Collection Rate Logic

There are two collection-related calculations in the advanced pages.

| Measure | Definition | Usage |
|---|---|---|
| Overall Collection Rate | Total Paid Amount / Total Invoice Amount | Management KPI |
| Segment Collection Rate % | Average customer-level collection rate inside each segment | Segment comparison |

This distinction is important because segment averages do not need to reconcile mathematically to the overall collection KPI.

---

### Python Output Measures

Some values on Page 08 are not calculated directly in DAX.

They are generated by Python and then displayed in Power BI:

| Python Output | Power BI Usage |
|---|---|
| `ClusterID` | Technical cluster reference |
| `ClusterLabel` | Business-readable segment label |
| `RecommendedAction` | Customer action guidance |
| `CustomerPriorityScore` | Customer ranking and prioritization |
| `ModelRunID` | Technical traceability |
| `ModelRunDate` | Refresh and run tracking |

---

### Management-Facing Design Rule

Technical model diagnostics such as Silhouette Score are not displayed as Power BI KPIs.

They are retained in:

```text
05_synthetic_data/advanced_analytics/outputs/model_run_log.csv
06_powerbi_dashboard/powerbi_technical_documentation/Advanced_Analytics_Model_Documentation.md
07_uat_go_live_docs/Advanced_Analytics_QA_Test_Cases.md
```

Reason:

```text
The Power BI page is designed for sales, finance, and management decisions.
Machine learning diagnostics belong in the technical documentation layer.
```

---