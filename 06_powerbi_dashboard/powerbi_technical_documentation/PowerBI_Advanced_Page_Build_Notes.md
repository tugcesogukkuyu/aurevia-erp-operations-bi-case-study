# Power BI Advanced Page Build Notes

## Project

**Aurevia ERP Operations & BI Dashboard**

## Purpose

This document defines the Power BI build logic for the two advanced pages added to the Aurevia ERP Operations & BI Dashboard project.

Advanced pages:

| Page | Page Name |
|---|---|
| 07 | Sales Operations Command Center |
| 08 | Customer Portfolio Action Model |

The goal is to document how the pages would be built in Power BI using SQL reporting views, Python segmentation outputs, Power BI visuals, slicers, DAX measures, and conditional formatting.

---

## Page 07 - Sales Operations Command Center

### Business Purpose

This page acts as an ERP-style management home screen.

It provides a single-screen operational view of:

- sales performance
- profitability
- customer value
- product category contribution
- receivables exposure
- operational alerts

---

## Page 07 Data Sources

| Report Component | SQL Source |
|---|---|
| KPI strip | `vw_Page07_MonthlySalesCommandTrend`, `vw_Page07_ReceivablesOpenBalanceRisk` |
| Revenue and gross profit trend | `vw_Page07_MonthlySalesCommandTrend` |
| Top customers panel | `vw_Page07_TopCustomersByRevenue` |
| Product category ranking | `vw_Page07_ProductCategoryRevenueRanking` |
| Receivables risk cards | `vw_Page07_ReceivablesOpenBalanceRisk` |
| Operational alerts | `vw_Page07_OperationalAlerts` |
| Top overdue exposure | `vw_Page07_TopOverdueCustomerExposure` |

---

## Page 07 Layout

### Left Slicer Panel

Power BI components:

| Component | Usage |
|---|---|
| Shape / Rectangle | Creates the vertical slicer panel background |
| Slicer | Date Range |
| Slicer | Region |
| Slicer | Sales Channel |
| Slicer | Product Category |
| Slicer | Customer Segment |

Slicers:

```text
Date Range
Region
Sales Channel
Product Category
Customer Segment
```

Purpose:

```text
Allows management to filter the page by reporting period, region, channel,
product category, and customer segment.
```

---

### Top KPI Strip

Visual type:

```text
Card / New Card visual
```

Cards:

| KPI | Source / Logic |
|---|---|
| Total Revenue | Sum of `TotalRevenue` |
| Gross Profit | Sum of `GrossProfit` |
| Gross Margin % | Gross Profit / Total Revenue |
| Open Balance | Sum of `OpenBalance` |
| Collection Rate | Total Paid Amount / Total Invoice Amount |

Design decision:

```text
Cards are compact and aligned as a status strip rather than oversized tiles.
```

---

### Revenue and Gross Profit Trend

Visual type:

```text
Line and clustered column chart
```

Fields:

| Field Well | Field |
|---|---|
| X-axis | `YearMonth` |
| Column y-axis | `TotalRevenue` |
| Line y-axis | `GrossProfit` |

Source:

```text
vw_Page07_MonthlySalesCommandTrend
```

Purpose:

```text
Shows revenue and gross profit movement across Jan 2025 - Jun 2026.
```

---

### Top Customers by Revenue

Visual type:

```text
Clustered bar chart or table/bar hybrid
```

Source:

```text
vw_Page07_TopCustomersByRevenue
```

Fields:

| Field | Usage |
|---|---|
| `CustomerName` | Category |
| `TotalRevenue` | Value |
| `RevenueSharePercent` | Tooltip / secondary value |
| `CustomerSegment` | Tooltip |
| `OpenBalance` | Tooltip |

Purpose:

```text
Identifies the highest-value customers by revenue contribution.
```

---

### Product Category Revenue Ranking

Visual type:

```text
Clustered bar chart
```

Source:

```text
vw_Page07_ProductCategoryRevenueRanking
```

Fields:

| Field | Usage |
|---|---|
| `ProductCategory` | Axis |
| `TotalRevenue` | Value |
| `GrossProfit` | Tooltip |
| `GrossMarginPercent` | Tooltip |

Purpose:

```text
Shows which product categories generate the largest revenue contribution.
```

---

### Receivables / Open Balance Risk

Visual type:

```text
Matrix, card panel, or table with conditional formatting
```

Source:

```text
vw_Page07_ReceivablesOpenBalanceRisk
```

Fields:

| Field | Usage |
|---|---|
| `AgingBucket` | Row / category |
| `OpenBalance` | Value |
| `OpenBalanceSharePercent` | Secondary value |
| `InvoiceCount` | Tooltip / detail |

Purpose:

```text
Shows where open balance exposure is concentrated by aging bucket.
```

Formatting:

```text
Current / Not Due: neutral
1-30 Days: yellow
31-60 Days: orange
61-90 Days: dark orange
90+ Days: red
```

---

### Operational Alerts

Visual type:

```text
Small card group / matrix with conditional formatting
```

Source:

```text
vw_Page07_OperationalAlerts
```

Fields:

| Field | Usage |
|---|---|
| `AlertType` | Alert label |
| `AlertValue` | Main number |
| `AlertSeverity` | Conditional formatting |
| `OwnerArea` | Tooltip / supporting label |

Purpose:

```text
Highlights inventory, procurement, and operational risks requiring management attention.
```

---

### Action Queue

Visual type:

```text
Small card group
```

Example actions:

| Action | Source |
|---|---|
| Highest Revenue Customer | `vw_Page07_TopCustomersByRevenue` |
| Top Overdue Customer Segment | `vw_Page07_TopOverdueCustomerExposure` |
| Top Revenue Category | `vw_Page07_ProductCategoryRevenueRanking` |
| Critical Operational Alert | `vw_Page07_OperationalAlerts` |

Purpose:

```text
Converts operational monitoring into a compact management priority view.
```

---

## Page 08 - Customer Portfolio Action Model

### Business Purpose

This page supports customer portfolio decisions using Python K-Means segmentation.

It answers:

```text
Which customer groups can support revenue growth without increasing collection
risk and profitability risk?
```

---

## Page 08 Data Sources

| Report Component | Source |
|---|---|
| Model summary cards | `dbo.CustomerSegmentationOutput` |
| Cluster profile heatmap | `vw_Page08_CustomerClusterProfile` |
| Customer priority list | `vw_Page08_CustomerPriorityList` |
| Channel x customer segment matrix | `vw_Page08_ChannelClusterMatrix` |
| Portfolio risk and growth summary | `vw_Page08_CustomerClusterProfile` |
| Action output cards | `vw_Page08_ActionOutputSummary` |

---

## Page 08 Layout

### Left Slicer Panel

Power BI components:

| Component | Usage |
|---|---|
| Shape / Rectangle | Creates the slicer panel background |
| Slicer | Date Range |
| Slicer | Region |
| Slicer | Sales Channel |
| Slicer | Customer Segment |
| Slicer | Collection Risk Level |
| Slicer | Gross Margin Band |

Purpose:

```text
Allows management and analysts to filter segmentation outputs by portfolio context.
```

---

### Top Model Summary Strip

Visual type:

```text
Card / New Card visual
```

Cards:

| Card | Source / Logic |
|---|---|
| Customer Count | Distinct count of `CustomerID` |
| Segment Count | Distinct count of `ClusterLabel` |
| Strategic Value Revenue | Revenue where ClusterLabel = Strategic Value Customers |
| Collection Risk Exposure | Open balance where ClusterLabel = Collection Risk Customers |
| Average Collection Rate | Total Paid Amount / Total Invoice Amount |

Purpose:

```text
Provides a compact summary of the customer portfolio segmentation output.
```

Design decision:

```text
Model quality metrics such as Silhouette Score are not displayed on this page.
They remain in technical documentation and model output files.
```

---

### Cluster Profile Heatmap

Visual type:

```text
Matrix visual with conditional formatting
```

Source:

```text
vw_Page08_CustomerClusterProfile
```

Rows:

```text
ClusterLabel
```

Values:

```text
RevenueSharePercent
GrossMarginPercent
CollectionRatePercent
OpenBalanceSharePercent
AvgMonthlyOrderFrequency
AvgProductCategoryDiversity
```

Purpose:

```text
Shows how customer groups differ across revenue, profitability, collection,
receivables exposure, order frequency, and product diversity.
```

Conditional formatting:

| Metric | Preferred Formatting |
|---|---|
| Revenue Share | Higher value = stronger blue |
| Gross Margin % | Higher value = stronger green |
| Collection Rate | Higher value = stronger green |
| Open Balance Share | Higher value = stronger orange/red |
| Order Frequency | Higher value = stronger blue |
| Product Diversity | Higher value = stronger blue/green |

---

### Customer Priority List

Visual type:

```text
Table visual
```

Source:

```text
vw_Page08_CustomerPriorityList
```

Fields:

| Field | Purpose |
|---|---|
| `CustomerName` | Customer identification |
| `ClusterLabel` | Business segment |
| `TotalRevenue` | Commercial value |
| `GrossMarginPercent` | Profitability |
| `CollectionRatePercent` | Collection quality |
| `OpenBalance` | Receivables exposure |
| `RecommendedAction` | Business action |
| `CustomerPriorityScore` | Ranking logic |

Purpose:

```text
Ranks customers by business value and risk so sales and finance teams can
prioritize action.
```

Conditional formatting:

| Cluster | Color Logic |
|---|---|
| Strategic Value Customers | Blue / green |
| Growth Potential Customers | Blue |
| Collection Risk Customers | Orange / red |
| Low Contribution Customers | Gray |

---

### Channel x Customer Segment Matrix

Visual type:

```text
Matrix visual with conditional formatting
```

Source:

```text
vw_Page08_ChannelClusterMatrix
```

Rows:

```text
SalesChannel
```

Columns:

```text
ClusterLabel
```

Values:

```text
ChannelRevenueSharePercent
```

Purpose:

```text
Shows which sales channels generate strategic customers and which channels
carry higher collection-risk exposure.
```

---

### Portfolio Risk & Growth Summary

Visual type:

```text
Bar chart / small multiples / compact comparison panel
```

Source:

```text
vw_Page08_CustomerClusterProfile
```

Metrics:

| Metric | Purpose |
|---|---|
| Revenue Share | Shows growth value by cluster |
| Open Balance Share | Shows receivables exposure by cluster |
| Collection Rate | Shows collection health by cluster |

Purpose:

```text
Compares growth potential and financial exposure across customer segments.
```

---

### Action Output

Visual type:

```text
Small card group
```

Source:

```text
vw_Page08_ActionOutputSummary
```

Cards:

| Action | Target Group |
|---|---|
| Protect | Strategic Value Customers |
| Grow | Growth Potential Customers |
| Collect First | Collection Risk Customers |
| Low-Touch Service | Low Contribution Customers |

Purpose:

```text
Converts segmentation output into management action categories.
```

---

## Power BI Features Used

| Power BI Feature | Usage |
|---|---|
| Power Query | Load SQL views and Python output tables |
| Data Model Relationships | Connect customer segmentation output to customer and sales context |
| Slicers | Filter pages by date, region, channel, category, segment, and risk level |
| Card / New Card | Display KPI and model summary values |
| Line and Clustered Column Chart | Revenue and gross profit trend |
| Clustered Bar Chart | Customer and product category ranking |
| Matrix Visual | Heatmap-style cluster profile and channel matrix |
| Table Visual | Customer action and priority list |
| Conditional Formatting | Risk, value, action, and segment highlighting |
| DAX Measures | KPI calculations, ratios, segment summaries, ranking logic |
| Refresh | Enables updated reporting when SQL/Python outputs are refreshed |

---

## Page-Level Design Decision

The advanced pages are intentionally limited to two additional pages.

Reason:

```text
The goal is not to add more charts, but to add a clear business decision layer.
```

The first new page provides a refreshable management operations cockpit.  
The second new page provides a Python-supported customer portfolio action model.

Together, they extend the original operational report without turning the project into a cluttered multi-page visual demo.

---

## Final Positioning

The advanced Power BI extension demonstrates how the Aurevia reporting solution can support:

- management monitoring
- refreshable sales operations reporting
- customer portfolio segmentation
- sales and collection prioritization
- SQL-to-Python-to-Power BI workflow
- applied machine learning for business action