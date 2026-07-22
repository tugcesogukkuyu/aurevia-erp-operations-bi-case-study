# Advanced Analytics QA Test Cases

## Project

**Aurevia ERP Operations & BI Dashboard**

## Purpose

This document defines the QA and reconciliation test cases for the advanced analytics extension added to the Aurevia ERP Operations & BI Dashboard project.

The advanced analytics extension supports:

| Page | Page Name |
|---|---|
| 07 | Sales Operations Command Center |
| 08 | Customer Portfolio Action Model |

The purpose of these tests is to verify that the SQL reporting layer, Python segmentation output, and Power BI advanced pages are complete, internally consistent, and aligned with the confirmed Aurevia project totals.

---

## Scope

This QA document covers:

- SQL view validation
- customer-level input completeness
- Python K-Means output validation
- Power BI reconciliation checks
- segment total validation
- management action output validation
- reporting period consistency
- data quality checks for Page 07 and Page 08

---

## Confirmed Project Control Totals

The advanced analytics pages must reconcile to the following confirmed project values:

| Metric | Expected Value |
|---|---:|
| Reporting Start Date | 2025-01-01 |
| Reporting End Date | 2026-06-30 |
| Customer Count | 150 |
| Total Revenue | 420.6M |
| Gross Profit | 191.8M |
| Gross Margin % | 45.6% |
| Open Balance | 95.6M / 96M |
| Collection Rate | 77.3% |
| Products Below Reorder Level | 4 |
| Negative Stock Products | 4 |
| Delayed Purchase Orders | 679 |
| Customer Segment Count | 4 |

---

# Section 01 - SQL Reporting Layer Validation

## QA-ADV-001 - Advanced SQL File Exists

### Objective

Verify that the advanced analytics SQL file exists in the SQL documentation layer.

### File

```text
04_sql_database/advanced_analytics_reporting_queries.sql
```

### Expected Result

The file exists and includes SQL objects for:

- Page 07 Sales Operations Command Center
- Page 08 Customer Portfolio Action Model
- Customer-level feature dataset
- Python output table contract
- Validation queries

### Status

```text
PASS
```

---

## QA-ADV-002 - Page 07 Monthly Trend View Exists

### SQL Object

```text
vw_Page07_MonthlySalesCommandTrend
```

### Test Query

```sql
SELECT
    COUNT(*) AS RowCount,
    MIN(YearMonth) AS MinYearMonth,
    MAX(YearMonth) AS MaxYearMonth,
    ROUND(SUM(TotalRevenue), 2) AS TotalRevenue,
    ROUND(SUM(GrossProfit), 2) AS GrossProfit
FROM vw_Page07_MonthlySalesCommandTrend;
```

### Expected Result

| Check | Expected |
|---|---:|
| RowCount | 18 |
| MinYearMonth | 2025-01 |
| MaxYearMonth | 2026-06 |
| TotalRevenue | Approximately 420.6M |
| GrossProfit | Approximately 191.8M |

### Notes

Minor rounding differences are acceptable if caused by decimal precision.

---

## QA-ADV-003 - Page 07 Product Category Revenue View Exists

### SQL Object

```text
vw_Page07_ProductCategoryRevenueRanking
```

### Test Query

```sql
SELECT
    COUNT(*) AS CategoryCount,
    ROUND(SUM(TotalRevenue), 2) AS TotalRevenue,
    ROUND(SUM(GrossProfit), 2) AS GrossProfit
FROM vw_Page07_ProductCategoryRevenueRanking;
```

### Expected Result

| Check | Expected |
|---|---:|
| CategoryCount | Greater than 0 |
| TotalRevenue | Approximately 420.6M |
| GrossProfit | Approximately 191.8M |

---

## QA-ADV-004 - Page 07 Receivables Risk View Reconciles

### SQL Object

```text
vw_Page07_ReceivablesOpenBalanceRisk
```

### Test Query

```sql
SELECT
    COUNT(*) AS AgingBucketCount,
    ROUND(SUM(OpenBalance), 2) AS OpenBalance
FROM vw_Page07_ReceivablesOpenBalanceRisk;
```

### Expected Result

| Check | Expected |
|---|---:|
| AgingBucketCount | Greater than 0 |
| OpenBalance | Approximately 95.6M |

---

## QA-ADV-005 - Page 07 Operational Alerts Reconcile

### SQL Object

```text
vw_Page07_OperationalAlerts
```

### Test Query

```sql
SELECT
    AlertType,
    AlertValue,
    AlertSeverity,
    OwnerArea
FROM vw_Page07_OperationalAlerts
ORDER BY AlertType;
```

### Expected Result

| AlertType | Expected Value |
|---|---:|
| Products Below Reorder Level | 4 |
| Negative Stock Products | 4 |
| Delayed Purchase Orders | 679 |
| High-Risk Categories | Greater than 0 |

---

## QA-ADV-006 - Customer Revenue Performance View Exists

### SQL Object

```text
vw_CustomerRevenuePerformance
```

### Test Query

```sql
SELECT
    COUNT(DISTINCT CustomerID) AS CustomerCount,
    ROUND(SUM(TotalRevenue), 2) AS TotalRevenue,
    ROUND(SUM(GrossProfit), 2) AS GrossProfit,
    ROUND(SUM(OpenBalance), 2) AS OpenBalance
FROM vw_CustomerRevenuePerformance;
```

### Expected Result

| Check | Expected |
|---|---:|
| CustomerCount | 150 |
| TotalRevenue | Approximately 420.6M |
| GrossProfit | Approximately 191.8M |
| OpenBalance | Approximately 95.6M |

---

# Section 02 - Python Segmentation Input Validation

## QA-ADV-007 - Page 08 Segmentation Input View Exists

### SQL Object

```text
vw_Page08_CustomerSegmentationInput
```

### Test Query

```sql
SELECT TOP 10
    CustomerID,
    CustomerName,
    CustomerSegment,
    Region,
    SalesChannel,
    TotalRevenue,
    GrossProfit,
    GrossMarginPercent,
    SalesOrderCount,
    AvgMonthlyOrderFrequency,
    CollectionRate,
    OpenBalance,
    OpenBalanceRatio,
    ProductCategoryDiversity
FROM vw_Page08_CustomerSegmentationInput;
```

### Expected Result

The view returns customer-level records with all required model input features.

Required columns:

| Column |
|---|
| CustomerID |
| CustomerName |
| CustomerSegment |
| Region |
| SalesChannel |
| TotalRevenue |
| GrossProfit |
| GrossMarginPercent |
| SalesOrderCount |
| AvgMonthlyOrderFrequency |
| CollectionRate |
| OpenBalance |
| OpenBalanceRatio |
| ProductCategoryDiversity |

---

## QA-ADV-008 - Segmentation Input Row Count

### Test Query

```sql
SELECT
    COUNT(*) AS RowCount,
    COUNT(DISTINCT CustomerID) AS CustomerCount
FROM vw_Page08_CustomerSegmentationInput;
```

### Expected Result

| Check | Expected |
|---|---:|
| RowCount | 150 |
| CustomerCount | 150 |

### Business Rule

The Python segmentation model expects one row per customer.

---

## QA-ADV-009 - Segmentation Input Null Check

### Test Query

```sql
SELECT
    SUM(CASE WHEN TotalRevenue IS NULL THEN 1 ELSE 0 END) AS NullTotalRevenue,
    SUM(CASE WHEN GrossMarginPercent IS NULL THEN 1 ELSE 0 END) AS NullGrossMargin,
    SUM(CASE WHEN SalesOrderCount IS NULL THEN 1 ELSE 0 END) AS NullSalesOrderCount,
    SUM(CASE WHEN CollectionRate IS NULL THEN 1 ELSE 0 END) AS NullCollectionRate,
    SUM(CASE WHEN OpenBalanceRatio IS NULL THEN 1 ELSE 0 END) AS NullOpenBalanceRatio,
    SUM(CASE WHEN ProductCategoryDiversity IS NULL THEN 1 ELSE 0 END) AS NullProductDiversity
FROM vw_Page08_CustomerSegmentationInput;
```

### Expected Result

All returned values should be:

```text
0
```

### Notes

If nulls exist, Python should either reject the input or fill missing numeric values using the documented median-imputation logic.

---

## QA-ADV-010 - Segmentation Input Revenue Reconciliation

### Test Query

```sql
SELECT
    ROUND(SUM(TotalRevenue), 2) AS TotalRevenue,
    ROUND(SUM(GrossProfit), 2) AS GrossProfit,
    ROUND(SUM(OpenBalance), 2) AS OpenBalance
FROM vw_Page08_CustomerSegmentationInput;
```

### Expected Result

| Metric | Expected |
|---|---:|
| TotalRevenue | Approximately 420.6M |
| GrossProfit | Approximately 191.8M |
| OpenBalance | Approximately 95.6M |

---

# Section 03 - Python Output Validation

## QA-ADV-011 - Python Script Exists

### File

```text
05_synthetic_data/advanced_analytics/customer_segmentation_kmeans.py
```

### Expected Result

The file exists and includes logic for:

- SQL or CSV input loading
- schema validation
- feature preparation
- StandardScaler
- K-Means with K=4
- business cluster labeling
- customer priority scoring
- CSV output writing
- optional SQL writeback

---

## QA-ADV-012 - Python Requirements File Exists

### File

```text
05_synthetic_data/advanced_analytics/requirements.txt
```

### Expected Result

The file exists and includes:

```text
pandas
numpy
scikit-learn
SQLAlchemy
pyodbc
joblib
openpyxl
python-dotenv
```

---

## QA-ADV-013 - Python Output Files Created

### Output Folder

```text
05_synthetic_data/advanced_analytics/outputs
```

### Expected Output Files

| File | Purpose |
|---|---|
| `customer_segments.csv` | Customer-level segmentation output |
| `customer_cluster_profile.csv` | Cluster-level KPI profile |
| `sales_priority_actions.csv` | Action card output |
| `model_run_log.csv` | Model execution metadata |

### Expected Result

The files are created after running:

```bash
python customer_segmentation_kmeans.py
```

---

## QA-ADV-014 - Customer Segmentation Output Row Count

### File

```text
outputs/customer_segments.csv
```

### Validation Logic

```python
import pandas as pd

df = pd.read_csv("outputs/customer_segments.csv")

assert df["CustomerID"].nunique() == 150
assert len(df) == 150
assert df["ClusterLabel"].nunique() == 4
```

### Expected Result

| Check | Expected |
|---|---:|
| Customer Count | 150 |
| Row Count | 150 |
| Segment Count | 4 |

---

## QA-ADV-015 - Customer Segmentation Output Required Columns

### File

```text
outputs/customer_segments.csv
```

### Required Columns

| Column |
|---|
| CustomerID |
| CustomerName |
| CustomerSegment |
| Region |
| SalesChannel |
| TotalRevenue |
| GrossProfit |
| GrossMarginPercent |
| SalesOrderCount |
| AvgMonthlyOrderFrequency |
| CollectionRate |
| OpenBalance |
| OpenBalanceRatio |
| ProductCategoryDiversity |
| ClusterID |
| ClusterLabel |
| RecommendedAction |
| CustomerPriorityScore |
| ModelRunID |
| ModelRunDate |

### Expected Result

All required columns are present.

---

## QA-ADV-016 - Cluster Labels Are Valid

### Validation Logic

```python
expected_clusters = {
    "Strategic Value Customers",
    "Growth Potential Customers",
    "Collection Risk Customers",
    "Low Contribution Customers",
}

actual_clusters = set(df["ClusterLabel"].unique())

assert actual_clusters == expected_clusters
```

### Expected Result

Exactly four expected business-readable cluster labels exist.

---

## QA-ADV-017 - Python Output Revenue Reconciliation

### Validation Logic

```python
import pandas as pd

df = pd.read_csv("outputs/customer_segments.csv")

total_revenue = round(df["TotalRevenue"].sum(), 2)
open_balance = round(df["OpenBalance"].sum(), 2)

assert abs(total_revenue - 420600000) < 1000000
assert abs(open_balance - 95600000) < 1000000
```

### Expected Result

| Metric | Expected |
|---|---:|
| Total Revenue | Approximately 420.6M |
| Open Balance | Approximately 95.6M |

### Notes

A tolerance is allowed because the project uses rounded display values.

---

## QA-ADV-018 - Model Run Log Created

### File

```text
outputs/model_run_log.csv
```

### Expected Columns

| Column |
|---|
| ModelRunID |
| ModelRunDate |
| ModelType |
| KValue |
| FeatureCount |
| FeatureColumns |
| SilhouetteScore |
| CustomerCount |
| TotalRevenue |
| OpenBalance |

### Expected Result

The model run log exists and provides technical traceability.

---

# Section 04 - SQL Writeback Validation

## QA-ADV-019 - Customer Segmentation SQL Output Table Exists

### SQL Object

```text
dbo.CustomerSegmentationOutput
```

### Test Query

```sql
SELECT
    COUNT(*) AS RowCount,
    COUNT(DISTINCT CustomerID) AS CustomerCount,
    COUNT(DISTINCT ClusterLabel) AS SegmentCount,
    ROUND(SUM(TotalRevenue), 2) AS TotalRevenue,
    ROUND(SUM(OpenBalance), 2) AS OpenBalance
FROM dbo.CustomerSegmentationOutput;
```

### Expected Result

| Check | Expected |
|---|---:|
| RowCount | 150 |
| CustomerCount | 150 |
| SegmentCount | 4 |
| TotalRevenue | Approximately 420.6M |
| OpenBalance | Approximately 95.6M |

---

## QA-ADV-020 - Customer Cluster Profile View Reconciles

### SQL Object

```text
vw_Page08_CustomerClusterProfile
```

### Test Query

```sql
SELECT
    ClusterLabel,
    CustomerCount,
    TotalRevenue,
    RevenueSharePercent,
    OpenBalance,
    OpenBalanceSharePercent,
    GrossMarginPercent,
    CollectionRatePercent
FROM vw_Page08_CustomerClusterProfile
ORDER BY
    CASE ClusterLabel
        WHEN 'Strategic Value Customers' THEN 1
        WHEN 'Growth Potential Customers' THEN 2
        WHEN 'Collection Risk Customers' THEN 3
        WHEN 'Low Contribution Customers' THEN 4
        ELSE 99
    END;
```

### Expected Result

The output contains four cluster labels and reconciles to:

| Metric | Expected |
|---|---:|
| Customer Count Total | 150 |
| Revenue Total | Approximately 420.6M |
| Open Balance Total | Approximately 95.6M |
| Segment Count | 4 |

---

## QA-ADV-021 - Action Output Summary Exists

### SQL Object

```text
vw_Page08_ActionOutputSummary
```

### Test Query

```sql
SELECT
    ActionType,
    TargetGroup,
    FinancialValue,
    ValueType
FROM vw_Page08_ActionOutputSummary;
```

### Expected Result

| ActionType | TargetGroup |
|---|---|
| Protect | Strategic Value Customers |
| Grow | Growth Potential Customers |
| Collect First | Collection Risk Customers |
| Low-Touch Service | Low Contribution Customers |

---

# Section 05 - Power BI Page Validation

## QA-ADV-022 - Page 07 Screenshot Exists

### Expected File

```text
06_powerbi_dashboard/power_bi_ekran_goruntuleri/07_sales_operations_command_center.png
```

### Expected Result

The screenshot exists and shows:

- Sales Operations Command Center page title
- Jan 2025 – Jun 2026 reporting period
- KPI strip
- revenue and gross profit trend
- top customers
- product category revenue ranking
- receivables / open balance risk
- operational alerts
- action queue

---

## QA-ADV-023 - Page 08 Screenshot Exists

### Expected File

```text
06_powerbi_dashboard/power_bi_ekran_goruntuleri/08_customer_portfolio_action_model.png
```

### Expected Result

The screenshot exists and shows:

- Customer Portfolio Action Model page title
- Jan 2025 – Jun 2026 reporting period
- customer count
- segment count
- cluster profile heatmap
- customer priority list
- channel x customer segment matrix
- portfolio risk and growth summary
- action output cards

---

## QA-ADV-024 - Page 08 Segment Totals Reconcile

### Expected Page 08 Values

| Segment | Customers | Revenue | Open Balance |
|---|---:|---:|---:|
| Strategic Value Customers | 32 | 180.5M | 14.2M |
| Growth Potential Customers | 45 | 119.7M | 18.6M |
| Collection Risk Customers | 38 | 88.2M | 52.4M |
| Low Contribution Customers | 35 | 32.2M | 10.4M |
| Total | 150 | 420.6M | 95.6M |

### Expected Result

The visible Page 08 segment values reconcile to the confirmed project totals.

---

## QA-ADV-025 - Page 08 Management Design Rule

### Objective

Verify that the Customer Portfolio Action Model page remains management-facing and not overly technical.

### Expected Result

The page should not display:

- Silhouette Score as a KPI
- cluster stability chart
- elbow method chart
- academic model diagnostic chart
- long executive insight paragraph
- unrelated decorative visuals
- company logo

The page should display:

- customer segment outputs
- business-readable cluster labels
- customer action list
- revenue and collection-risk comparison
- action output cards

---

# Section 06 - Documentation Validation

## QA-ADV-026 - Advanced Analytics README Exists

### Expected File

```text
05_synthetic_data/advanced_analytics/README_advanced_analytics.md
```

### Expected Result

The file exists and explains:

- business purpose
- Python model flow
- technology stack
- SQL dependencies
- Power BI integration
- output files
- execution modes

---

## QA-ADV-027 - Advanced Analytics Model Documentation Exists

### Expected File

```text
06_powerbi_dashboard/powerbi_technical_documentation/Advanced_Analytics_Model_Documentation.md
```

### Expected Result

The file exists and documents:

- SQL layer
- Python layer
- feature engineering logic
- K-Means model design
- cluster labels
- customer priority score
- model outputs
- Page 07 and Page 08 purpose

---

## QA-ADV-028 - Power BI Advanced Page Build Notes Exist

### Expected File

```text
06_powerbi_dashboard/powerbi_technical_documentation/PowerBI_Advanced_Page_Build_Notes.md
```

### Expected Result

The file exists and documents:

- Power BI page components
- visual types
- SQL sources
- slicers
- matrix and heatmap logic
- DAX usage
- conditional formatting
- management-facing design decisions

---

## QA-ADV-029 - DAX Catalog Updated

### Expected File

```text
06_powerbi_dashboard/powerbi_technical_documentation/DAX_Measure_Catalog.md
```

### Expected Result

The file includes a section named:

```text
Advanced Analytics DAX Measures
```

The section documents Page 07 and Page 08 measures.

---

# Section 07 - Final QA Summary

## Advanced Analytics QA Summary

| Area | Expected Status |
|---|---|
| SQL reporting views | PASS |
| Customer-level feature dataset | PASS |
| Python K-Means script | PASS |
| Python output files | PASS after execution |
| SQL writeback table | PASS after execution |
| Power BI Page 07 screenshot | PASS |
| Power BI Page 08 screenshot | PASS |
| DAX catalog update | PASS |
| Technical documentation | PASS |
| QA documentation | PASS |

---

## Known Notes

The screenshots for Page 07 and Page 08 are portfolio mockups that represent how the Power BI pages would be structured.

The technical documentation explains how the same outputs would be produced from SQL views, Python scripts, and Power BI visuals in an implemented reporting environment.

The final project should not claim that the screenshots are direct exports from an executed Power BI model unless the PBIX file is rebuilt with the same advanced analytics outputs.

---

## Final QA Position

The advanced analytics extension is considered complete when:

- the SQL file exists and contains the advanced reporting views
- the Python folder exists with scripts and dependency file
- the Power BI documentation files exist
- the DAX catalog is updated
- the QA file is added
- Page 07 and Page 08 screenshots are stored in the dashboard screenshots folder
- README and presentation files are updated
- GitHub release folder is refreshed and pushed

At that point, the Aurevia ERP Operations & BI Dashboard can be presented as an ERP reporting and applied analytics portfolio case study using SQL Server, Python, Power BI, and DAX.