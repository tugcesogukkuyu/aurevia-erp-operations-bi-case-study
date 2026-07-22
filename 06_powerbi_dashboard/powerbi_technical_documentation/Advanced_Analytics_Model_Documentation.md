# Advanced Analytics Model Documentation

## Project

**Aurevia ERP Operations & BI Dashboard**

## Purpose

This document describes the advanced analytics layer added to the Aurevia ERP Operations & BI Dashboard project.

The extension introduces two additional decision-support pages:

| Page | Purpose |
|---|---|
| 07 - Sales Operations Command Center | Management cockpit for sales, profitability, receivables, product contribution, and operational alerts |
| 08 - Customer Portfolio Action Model | Python K-Means based customer segmentation model for growth, collection risk, and profitability actions |

The purpose of this extension is to move the project beyond static operational reporting and demonstrate how SQL, Python, Power BI, and DAX can be combined to support management-level decision-making.

---

## Business Problem

The original Power BI report provides operational visibility across sales, product profitability, inventory, receivables, and supplier performance.

The advanced analytics extension addresses a more specific management problem:

```text
Management needs to identify which customer groups can support revenue growth
without increasing collection risk and profitability risk.
```

This requires more than a standard sales dashboard. The solution needs to combine:

- current sales performance
- customer value ranking
- receivables exposure
- product category contribution
- operational alerts
- customer portfolio segmentation
- action-oriented customer prioritization

---

## Advanced Analytics Architecture

```text
SQL Server transactional and reporting data
        ↓
SQL reporting views for Page 07 and Page 08
        ↓
Python feature engineering
        ↓
Python K-Means customer segmentation
        ↓
Customer segmentation output table / CSV
        ↓
Power BI data model
        ↓
DAX measures and conditional formatting
        ↓
Management cockpit and customer action model
```

---

## SQL Layer

The advanced analytics extension is supported by the SQL file:

```text
04_sql_database/advanced_analytics_reporting_queries.sql
```

This file creates the SQL views and table contract required for the two new Power BI pages.

### Page 07 SQL Objects

| SQL Object | Purpose |
|---|---|
| `vw_Page07_MonthlySalesCommandTrend` | Monthly revenue and gross profit trend |
| `vw_Page07_ProductCategoryRevenueRanking` | Product category revenue and profitability ranking |
| `vw_Page07_ReceivablesOpenBalanceRisk` | Open balance and receivables aging summary |
| `vw_Page07_OperationalAlerts` | Inventory, supplier, and operational alert output |
| `vw_CustomerRevenuePerformance` | Customer-level commercial performance layer |
| `vw_Page07_TopCustomersByRevenue` | Top customer ranking by revenue |
| `vw_Page07_TopOverdueCustomerExposure` | Customer-level overdue receivables exposure |

### Page 08 SQL Objects

| SQL Object | Purpose |
|---|---|
| `vw_Page08_CustomerSegmentationInput` | Customer-level feature dataset for Python K-Means |
| `dbo.CustomerSegmentationOutput` | SQL target table for Python segmentation output |
| `vw_Page08_CustomerClusterProfile` | Segment-level output for heatmap and portfolio summary |
| `vw_Page08_CustomerPriorityList` | Customer-level action and priority table |
| `vw_Page08_ChannelClusterMatrix` | Sales channel and customer cluster matrix |
| `vw_Page08_ActionOutputSummary` | Compact action output for management |

---

## Python Layer

Python is used for customer segmentation and reporting automation.

Python files are stored under:

```text
05_synthetic_data/advanced_analytics
```

| File | Purpose |
|---|---|
| `customer_segmentation_kmeans.py` | Builds the customer segmentation model |
| `sales_reporting_automation.py` | Exports SQL reporting outputs to Excel |
| `requirements.txt` | Python dependency list |
| `README_advanced_analytics.md` | Documents the Python extension |

---

## Python Libraries

| Library | Usage |
|---|---|
| `pandas` | SQL/CSV input handling, feature preparation, output generation |
| `numpy` | Numeric handling and calculation support |
| `scikit-learn` | Machine learning library used for K-Means clustering |
| `StandardScaler` | Standardizes model features before clustering |
| `KMeans` | Groups customers into four behavioral/customer value clusters |
| `silhouette_score` | Technical validation metric retained in model output and documentation |
| `SQLAlchemy` | SQL Server connection layer |
| `pyodbc` | SQL Server driver integration |
| `joblib` | Saves model and scaler artifacts |
| `openpyxl` | Creates Excel reporting outputs |
| `pathlib` | File path management |
| `logging` | Pipeline execution traceability |

---

## Customer Segmentation Model

### Model Type

```text
Python K-Means Clustering
```

### Business Objective

The model is designed to answer:

```text
Which customer groups can support revenue growth without increasing collection
risk and profitability risk?
```

The output is not used as an academic machine learning demonstration. It is used to convert customer behavior into commercial and financial action groups.

---

## Model Input

The model input comes from:

```text
vw_Page08_CustomerSegmentationInput
```

Expected input grain:

```text
One row per customer
```

### Feature Set

| Feature | Business Meaning |
|---|---|
| `TotalRevenue` | Customer revenue contribution |
| `GrossMarginPercent` | Profitability quality |
| `AvgMonthlyOrderFrequency` | Order regularity |
| `CollectionRate` | Payment / collection quality |
| `OpenBalanceRatio` | Receivables exposure relative to revenue |
| `ProductCategoryDiversity` | Product basket diversity |

---

## Feature Engineering Logic

The model uses features that reflect both sales opportunity and financial risk.

| Dimension | Feature | Reason |
|---|---|---|
| Sales Value | `TotalRevenue` | Identifies commercially important customers |
| Profitability | `GrossMarginPercent` | Separates high-revenue but low-margin customers from profitable customers |
| Buying Behavior | `AvgMonthlyOrderFrequency` | Captures regularity of customer demand |
| Collection Quality | `CollectionRate` | Measures payment reliability |
| Receivables Risk | `OpenBalanceRatio` | Identifies customers where sales exposure may create cash risk |
| Commercial Depth | `ProductCategoryDiversity` | Measures cross-sell and product basket depth |

---

## Model Processing Steps

```text
Load customer feature dataset
        ↓
Validate required columns
        ↓
Clean and prepare numeric features
        ↓
Scale numeric features with StandardScaler
        ↓
Run K-Means clustering with K=4
        ↓
Assign numeric ClusterID
        ↓
Convert ClusterID into business-readable labels
        ↓
Calculate customer priority score
        ↓
Export customer-level and cluster-level outputs
        ↓
Optionally write segmentation output back to SQL Server
```

---

## Why K-Means

K-Means is appropriate for this project because the business need is to group customers by similar commercial and financial behavior without predefined labels.

The model does not require prior manual classification. Instead, it groups customers based on patterns across revenue, margin, ordering frequency, collection quality, open balance risk, and product diversity.

This is suitable for portfolio segmentation where management needs to classify customers into action groups.

---

## Why K=4

The segmentation uses four clusters because the business action model requires four operational categories:

| Cluster | Management Action |
|---|---|
| Strategic Value Customers | Protect and grow |
| Growth Potential Customers | Develop and cross-sell |
| Collection Risk Customers | Collect first and monitor credit |
| Low Contribution Customers | Use low-touch service model |

This structure keeps the output interpretable for sales, finance, and management teams.

---

## Cluster Labels

### 1. Strategic Value Customers

High revenue, strong margin, good collection quality, low open balance risk, and regular order behavior.

Management action:

```text
Protect / Retain / Upsell
```

### 2. Growth Potential Customers

Healthy commercial profile with room for expansion through product diversity, upsell, or cross-sell.

Management action:

```text
Grow / Cross-sell
```

### 3. Collection Risk Customers

Customers with revenue contribution but elevated open balance exposure and weaker collection rate.

Management action:

```text
Collect First / Monitor Credit
```

### 4. Low Contribution Customers

Customers with lower revenue contribution, lower strategic value, and limited manual sales priority.

Management action:

```text
Low-Touch Service
```

---

## Customer Priority Score

The customer priority score is used to support the action table on Page 08.

The score combines:

| Factor | Business Logic |
|---|---|
| Revenue | Higher revenue increases priority |
| Open Balance | Higher open balance increases finance follow-up priority |
| Collection Risk | Lower collection rate increases risk priority |
| Cluster Label | Strategic and risk clusters receive higher action weights |

This allows the report to rank customers not only by revenue, but by commercial value and financial exposure together.

---

## Model Outputs

The Python pipeline creates four main output files:

| Output | Purpose |
|---|---|
| `customer_segments.csv` | Customer-level segmentation output |
| `customer_cluster_profile.csv` | Segment-level profile used in the heatmap and summary visuals |
| `sales_priority_actions.csv` | Action card output for management |
| `model_run_log.csv` | Model execution metadata |

Optional SQL output:

```text
dbo.CustomerSegmentationOutput
```

---

## Page 07 - Sales Operations Command Center

### Purpose

Page 07 acts as an ERP-style management cockpit.

It is designed to provide a single-screen operational view of:

- current sales performance
- profitability
- customer value
- product category contribution
- receivables exposure
- operational alerts

### Data Sources

| Dashboard Area | SQL Source |
|---|---|
| KPI strip | `vw_Page07_MonthlySalesCommandTrend`, `vw_Page07_ReceivablesOpenBalanceRisk` |
| Revenue and gross profit trend | `vw_Page07_MonthlySalesCommandTrend` |
| Top customers | `vw_Page07_TopCustomersByRevenue` |
| Product category ranking | `vw_Page07_ProductCategoryRevenueRanking` |
| Receivables risk | `vw_Page07_ReceivablesOpenBalanceRisk` |
| Operational alerts | `vw_Page07_OperationalAlerts` |
| Top overdue exposure | `vw_Page07_TopOverdueCustomerExposure` |

### Business Value

Page 07 allows management to monitor updated sales, profitability, receivables, and operational risk from one ERP-style reporting screen.

The page is designed to work as a refreshable report fed by SQL Server and Power BI.

---

## Page 08 - Customer Portfolio Action Model

### Purpose

Page 08 converts customer segmentation output into sales and collection actions.

It answers:

```text
Which customer groups should be protected, grown, monitored, or managed with a
low-touch service model?
```

### Data Sources

| Dashboard Area | Source |
|---|---|
| Model summary cards | `dbo.CustomerSegmentationOutput` / Python output |
| Cluster profile heatmap | `vw_Page08_CustomerClusterProfile` |
| Customer priority list | `vw_Page08_CustomerPriorityList` |
| Channel x customer segment matrix | `vw_Page08_ChannelClusterMatrix` |
| Portfolio risk and growth summary | `vw_Page08_CustomerClusterProfile` |
| Action output cards | `vw_Page08_ActionOutputSummary` |

### Business Value

Page 08 allows management and sales leadership to:

- identify strategic customers
- find growth-potential customers
- control collection-risk customers before increasing sales exposure
- reduce manual prioritization bias
- align sales actions with collection and profitability risk

---

## Management vs Technical Metrics

Technical model metrics such as `Silhouette Score` are retained in model output and documentation, but they are not displayed on the management-facing Power BI page.

Reason:

```text
Management-facing screens should prioritize business actions.
Technical model quality metrics belong in model documentation and QA validation.
```

This keeps the dashboard focused on operational decision-making while preserving technical evidence for review.

---

## Reconciliation Targets

The advanced analytics extension must reconcile to the existing Aurevia project totals.

| Metric | Expected Value |
|---|---:|
| Customer Count | 150 |
| Segment Count | 4 |
| Total Revenue | 420.6M |
| Open Balance | 95.6M |
| Collection Rate | 77.3% |

These checks are validated in:

```text
07_uat_go_live_docs/Advanced_Analytics_QA_Test_Cases.md
```

---

## Final Technical Positioning

The advanced analytics layer demonstrates:

- SQL-based reporting layer design
- customer-level feature engineering
- Python K-Means segmentation
- model output persistence
- Power BI action-oriented reporting
- DAX-based KPI calculation
- management-facing decision support
- automated sales reporting output

The extension positions the project as a combined ERP reporting, business intelligence, and applied machine learning portfolio case study.