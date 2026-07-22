/*
===============================================================================
Aurevia ERP Operations & BI Dashboard
Advanced Analytics Reporting Queries

Purpose:
This SQL file extends the existing Aurevia ERP BI reporting layer for the two
advanced portfolio pages added after the original 6-page Power BI report.

New pages supported:
07 - Sales Operations Command Center
08 - Customer Portfolio Action Model

Technical scope:
- SQL reporting queries for management command center
- Customer-level analytical feature view for Python K-Means segmentation
- Power BI-ready summary views
- Operational alert output
- Reconciliation queries for validation

Reporting period:
2025-01-01 to 2026-06-30

Confirmed project KPIs:
- Total Revenue: 420.6M
- Gross Profit: 191.8M
- Gross Margin: 45.6%
- Open Balance: 95.6M / 96M
- Collection Rate: 77.3%
- Products Below Reorder Level: 4
- Negative Stock Products: 4
- Delayed Purchase Orders: 679
===============================================================================
*/

USE AureviaERPBI;
GO

/*
===============================================================================
SECTION 01
PAGE 07 - SALES OPERATIONS COMMAND CENTER
===============================================================================
*/


/*
-------------------------------------------------------------------------------
01.01 Monthly Revenue and Gross Profit Trend

Power BI page:
07 - Sales Operations Command Center

Visual:
Revenue and Gross Profit Trend

Purpose:
Provides the month-by-month revenue and gross profit trend for the management
command center.

Expected visual:
- X-axis: YearMonth
- Column: TotalRevenue
- Line: GrossProfit

Source:
vw_MonthlySalesPerformance
-------------------------------------------------------------------------------
*/

CREATE OR ALTER VIEW vw_Page07_MonthlySalesCommandTrend AS
SELECT
    YearMonth,
    ROUND(SUM(TotalRevenue), 2) AS TotalRevenue,
    ROUND(SUM(GrossProfit), 2) AS GrossProfit,
    ROUND(
        SUM(GrossProfit) / NULLIF(SUM(TotalRevenue), 0),
        4
    ) AS GrossMarginPercent
FROM vw_MonthlySalesPerformance
WHERE YearMonth BETWEEN '2025-01' AND '2026-06'
GROUP BY
    YearMonth;
GO


/*
-------------------------------------------------------------------------------
01.02 Product Category Revenue Ranking

Power BI page:
07 - Sales Operations Command Center

Visual:
Top Product Categories by Revenue

Purpose:
Shows which product categories generate the highest revenue.

Source:
vw_ProductCategoryProfitability
-------------------------------------------------------------------------------
*/

CREATE OR ALTER VIEW vw_Page07_ProductCategoryRevenueRanking AS
SELECT
    ProductCategory,
    ROUND(SUM(TotalRevenue), 2) AS TotalRevenue,
    ROUND(SUM(GrossProfit), 2) AS GrossProfit,
    ROUND(
        SUM(GrossProfit) / NULLIF(SUM(TotalRevenue), 0),
        4
    ) AS GrossMarginPercent,
    SUM(TotalQuantitySold) AS TotalQuantitySold,
    SUM(ProductCount) AS ProductCount
FROM vw_ProductCategoryProfitability
GROUP BY
    ProductCategory;
GO


/*
-------------------------------------------------------------------------------
01.03 Receivables / Open Balance Risk Summary

Power BI page:
07 - Sales Operations Command Center

Visual:
Receivables / Open Balance Risk

Purpose:
Summarizes open balance by aging bucket for finance and management review.

Source:
vw_ReceivablesAging
-------------------------------------------------------------------------------
*/

CREATE OR ALTER VIEW vw_Page07_ReceivablesOpenBalanceRisk AS
SELECT
    AgingBucket,
    AgingSortOrder,
    ROUND(SUM(OpenBalance), 2) AS OpenBalance,
    SUM(InvoiceCount) AS InvoiceCount,
    ROUND(
        SUM(OpenBalance) * 100.0 /
        NULLIF((SELECT SUM(OpenBalance) FROM vw_ReceivablesAging), 0),
        2
    ) AS OpenBalanceSharePercent
FROM vw_ReceivablesAging
GROUP BY
    AgingBucket,
    AgingSortOrder;
GO


/*
-------------------------------------------------------------------------------
01.04 Operational Alerts Summary

Power BI page:
07 - Sales Operations Command Center

Visual:
Operational Alerts

Purpose:
Creates a compact alert output for management monitoring.

Source:
vw_InventoryRisk
vw_SupplierPerformance
vw_ReceivablesAging
-------------------------------------------------------------------------------
*/

CREATE OR ALTER VIEW vw_Page07_OperationalAlerts AS
SELECT
    'Products Below Reorder Level' AS AlertType,
    COUNT(DISTINCT ProductCode) AS AlertValue,
    'High' AS AlertSeverity,
    'Inventory' AS OwnerArea
FROM vw_InventoryRisk
WHERE CurrentStockOnHand < ReorderLevel

UNION ALL

SELECT
    'Negative Stock Products' AS AlertType,
    COUNT(DISTINCT ProductCode) AS AlertValue,
    'High' AS AlertSeverity,
    'Inventory' AS OwnerArea
FROM vw_InventoryRisk
WHERE CurrentStockOnHand < 0

UNION ALL

SELECT
    'Delayed Purchase Orders' AS AlertType,
    SUM(DelayedPurchaseOrderCount) AS AlertValue,
    'Medium' AS AlertSeverity,
    'Procurement' AS OwnerArea
FROM vw_SupplierPerformance

UNION ALL

SELECT
    'High-Risk Categories' AS AlertType,
    COUNT(DISTINCT ProductCategory) AS AlertValue,
    'Medium' AS AlertSeverity,
    'Operations' AS OwnerArea
FROM vw_InventoryRisk
WHERE StockRiskStatus IN ('NEGATIVE STOCK', 'BELOW REORDER');
GO


/*
===============================================================================
SECTION 02
CUSTOMER-LEVEL REPORTING LAYER
===============================================================================
*/


/*
-------------------------------------------------------------------------------
02.01 Customer Revenue Performance View

Power BI pages:
07 - Sales Operations Command Center
08 - Customer Portfolio Action Model

Purpose:
Creates a customer-level commercial performance layer.

Used for:
- Top Customers by Revenue
- Customer segmentation input
- Customer action prioritization
- Sales channel / customer segment analysis

Business logic:
Customer performance is calculated at customer level using:
- revenue
- gross profit
- gross margin
- sales order count
- sales channel
- customer segment
-------------------------------------------------------------------------------
*/

CREATE OR ALTER VIEW vw_CustomerRevenuePerformance AS
WITH CustomerSales AS (
    SELECT
        c.CustomerID,
        c.CustomerName,
        c.CustomerSegment,
        c.Region,
        so.SalesChannel,
        COUNT(DISTINCT so.SalesOrderID) AS SalesOrderCount,
        SUM(sol.LineTotal) AS TotalRevenue,
        SUM(sol.Quantity * p.UnitCost) AS TotalCost,
        SUM(sol.LineTotal - (sol.Quantity * p.UnitCost)) AS GrossProfit,
        COUNT(DISTINCT p.ProductCategory) AS ProductCategoryDiversity
    FROM SalesOrders so
    INNER JOIN SalesOrderLines sol
        ON so.SalesOrderID = sol.SalesOrderID
    INNER JOIN Customers c
        ON so.CustomerID = c.CustomerID
    INNER JOIN Products p
        ON sol.ProductID = p.ProductID
    WHERE so.OrderDate >= '2025-01-01'
      AND so.OrderDate <= '2026-06-30'
    GROUP BY
        c.CustomerID,
        c.CustomerName,
        c.CustomerSegment,
        c.Region,
        so.SalesChannel
),
CustomerReceivables AS (
    SELECT
        CustomerID,
        SUM(InvoiceAmount) AS TotalInvoiceAmount,
        SUM(PaidAmount) AS TotalPaidAmount,
        SUM(InvoiceAmount - PaidAmount) AS OpenBalance,
        COUNT(DISTINCT InvoiceID) AS InvoiceCount
    FROM Invoices
    WHERE InvoiceDate >= '2025-01-01'
      AND InvoiceDate <= '2026-06-30'
    GROUP BY
        CustomerID
)
SELECT
    cs.CustomerID,
    cs.CustomerName,
    cs.CustomerSegment,
    cs.Region,
    cs.SalesChannel,
    cs.SalesOrderCount,
    ROUND(cs.TotalRevenue, 2) AS TotalRevenue,
    ROUND(cs.TotalCost, 2) AS TotalCost,
    ROUND(cs.GrossProfit, 2) AS GrossProfit,
    ROUND(
        cs.GrossProfit / NULLIF(cs.TotalRevenue, 0),
        4
    ) AS GrossMarginPercent,
    ISNULL(cr.TotalInvoiceAmount, 0) AS TotalInvoiceAmount,
    ISNULL(cr.TotalPaidAmount, 0) AS TotalPaidAmount,
    ISNULL(cr.OpenBalance, 0) AS OpenBalance,
    ROUND(
        ISNULL(cr.TotalPaidAmount, 0) /
        NULLIF(ISNULL(cr.TotalInvoiceAmount, 0), 0),
        4
    ) AS CollectionRate,
    ROUND(
        ISNULL(cr.OpenBalance, 0) /
        NULLIF(cs.TotalRevenue, 0),
        4
    ) AS OpenBalanceRatio,
    cs.ProductCategoryDiversity,
    ROUND(
        cs.SalesOrderCount / 18.0,
        2
    ) AS AvgMonthlyOrderFrequency
FROM CustomerSales cs
LEFT JOIN CustomerReceivables cr
    ON cs.CustomerID = cr.CustomerID;
GO


/*
-------------------------------------------------------------------------------
02.02 Page 07 Top Customers by Revenue

Power BI page:
07 - Sales Operations Command Center

Visual:
Top Customers by Revenue

Purpose:
Ranks customers by revenue contribution.

Source:
vw_CustomerRevenuePerformance
-------------------------------------------------------------------------------
*/

CREATE OR ALTER VIEW vw_Page07_TopCustomersByRevenue AS
WITH RankedCustomers AS (
    SELECT
        CustomerName,
        CustomerSegment,
        Region,
        SalesChannel,
        SUM(TotalRevenue) AS TotalRevenue,
        SUM(GrossProfit) AS GrossProfit,
        SUM(OpenBalance) AS OpenBalance,
        ROW_NUMBER() OVER (
            ORDER BY SUM(TotalRevenue) DESC
        ) AS RevenueRank
    FROM vw_CustomerRevenuePerformance
    GROUP BY
        CustomerName,
        CustomerSegment,
        Region,
        SalesChannel
),
TotalRevenueValue AS (
    SELECT
        SUM(TotalRevenue) AS GrandTotalRevenue
    FROM vw_CustomerRevenuePerformance
)
SELECT
    rc.RevenueRank,
    rc.CustomerName,
    rc.CustomerSegment,
    rc.Region,
    rc.SalesChannel,
    ROUND(rc.TotalRevenue, 2) AS TotalRevenue,
    ROUND(rc.GrossProfit, 2) AS GrossProfit,
    ROUND(rc.OpenBalance, 2) AS OpenBalance,
    ROUND(
        rc.TotalRevenue * 100.0 /
        NULLIF(tr.GrandTotalRevenue, 0),
        2
    ) AS RevenueSharePercent
FROM RankedCustomers rc
CROSS JOIN TotalRevenueValue tr
WHERE rc.RevenueRank <= 10;
GO


/*
-------------------------------------------------------------------------------
02.03 Top Overdue Customer Exposure

Power BI page:
07 - Sales Operations Command Center

Visual:
Top Overdue Exposure

Purpose:
Identifies customer-level overdue exposure for finance follow-up.

Business logic:
Invoices are considered overdue if open balance exists and due date is before
the reporting as-of date.
-------------------------------------------------------------------------------
*/

CREATE OR ALTER VIEW vw_Page07_TopOverdueCustomerExposure AS
WITH OverdueInvoices AS (
    SELECT
        c.CustomerID,
        c.CustomerName,
        c.CustomerSegment,
        i.InvoiceID,
        i.DueDate,
        DATEDIFF(DAY, i.DueDate, '2026-06-30') AS DaysOverdue,
        i.InvoiceAmount,
        i.PaidAmount,
        i.InvoiceAmount - i.PaidAmount AS OpenBalance
    FROM Invoices i
    INNER JOIN Customers c
        ON i.CustomerID = c.CustomerID
    WHERE i.DueDate < '2026-06-30'
      AND i.InvoiceAmount > i.PaidAmount
),
CustomerOverdue AS (
    SELECT
        CustomerName,
        CustomerSegment,
        SUM(OpenBalance) AS OpenBalance,
        MAX(DaysOverdue) AS MaxDaysOverdue
    FROM OverdueInvoices
    GROUP BY
        CustomerName,
        CustomerSegment
)
SELECT TOP 10
    CustomerName,
    CustomerSegment,
    ROUND(OpenBalance, 2) AS OpenBalance,
    MaxDaysOverdue
FROM CustomerOverdue
ORDER BY
    OpenBalance DESC;
GO


/*
===============================================================================
SECTION 03
PAGE 08 - CUSTOMER PORTFOLIO ACTION MODEL
===============================================================================
*/


/*
-------------------------------------------------------------------------------
03.01 Customer Segmentation Input Dataset

Power BI page:
08 - Customer Portfolio Action Model

Python input:
customer_segmentation_input.csv

Purpose:
Creates the analytical feature set used by the Python K-Means model.

Features:
- TotalRevenue
- GrossMarginPercent
- SalesOrderCount / order frequency
- CollectionRate
- OpenBalanceRatio
- ProductCategoryDiversity

This view is exported or read by Python before K-Means segmentation.
-------------------------------------------------------------------------------
*/

CREATE OR ALTER VIEW vw_Page08_CustomerSegmentationInput AS
SELECT
    CustomerID,
    CustomerName,
    CustomerSegment,
    Region,
    SalesChannel,
    ROUND(TotalRevenue, 2) AS TotalRevenue,
    ROUND(GrossProfit, 2) AS GrossProfit,
    ROUND(GrossMarginPercent, 4) AS GrossMarginPercent,
    SalesOrderCount,
    ROUND(AvgMonthlyOrderFrequency, 2) AS AvgMonthlyOrderFrequency,
    ROUND(CollectionRate, 4) AS CollectionRate,
    ROUND(OpenBalance, 2) AS OpenBalance,
    ROUND(OpenBalanceRatio, 4) AS OpenBalanceRatio,
    ProductCategoryDiversity
FROM vw_CustomerRevenuePerformance;
GO


/*
-------------------------------------------------------------------------------
03.02 Python Output Table Contract

Power BI page:
08 - Customer Portfolio Action Model

Purpose:
Defines the SQL-side target table structure for customer-level K-Means outputs.

Python will generate:
- ClusterID
- ClusterLabel
- RecommendedAction
- CustomerPriorityScore

Power BI consumes this table after the Python output is loaded.
-------------------------------------------------------------------------------
*/

IF OBJECT_ID('dbo.CustomerSegmentationOutput', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.CustomerSegmentationOutput (
        CustomerID INT NOT NULL,
        CustomerName NVARCHAR(255) NOT NULL,
        CustomerSegment NVARCHAR(100) NULL,
        Region NVARCHAR(100) NULL,
        SalesChannel NVARCHAR(100) NULL,
        TotalRevenue DECIMAL(18, 2) NOT NULL,
        GrossProfit DECIMAL(18, 2) NOT NULL,
        GrossMarginPercent DECIMAL(10, 4) NOT NULL,
        SalesOrderCount INT NOT NULL,
        AvgMonthlyOrderFrequency DECIMAL(10, 2) NULL,
        CollectionRate DECIMAL(10, 4) NULL,
        OpenBalance DECIMAL(18, 2) NULL,
        OpenBalanceRatio DECIMAL(10, 4) NULL,
        ProductCategoryDiversity INT NULL,
        ClusterID INT NOT NULL,
        ClusterLabel NVARCHAR(100) NOT NULL,
        RecommendedAction NVARCHAR(100) NOT NULL,
        CustomerPriorityScore DECIMAL(10, 4) NULL,
        ModelRunID NVARCHAR(100) NOT NULL,
        ModelRunDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END;
GO


/*
-------------------------------------------------------------------------------
03.03 Customer Cluster Profile View

Power BI page:
08 - Customer Portfolio Action Model

Visual:
Cluster Profile Heatmap
Portfolio Risk & Growth Summary

Purpose:
Aggregates Python K-Means customer segmentation outputs by cluster.

Power BI visuals:
- cluster profile heatmap
- revenue share by cluster
- open balance exposure by cluster
- collection rate by cluster
-------------------------------------------------------------------------------
*/

CREATE OR ALTER VIEW vw_Page08_CustomerClusterProfile AS
WITH ClusterBase AS (
    SELECT
        ClusterLabel,
        COUNT(DISTINCT CustomerID) AS CustomerCount,
        SUM(TotalRevenue) AS TotalRevenue,
        SUM(GrossProfit) AS GrossProfit,
        SUM(OpenBalance) AS OpenBalance,
        AVG(GrossMarginPercent) AS AvgGrossMarginPercent,
        AVG(CollectionRate) AS AvgCollectionRate,
        AVG(AvgMonthlyOrderFrequency) AS AvgMonthlyOrderFrequency,
        AVG(ProductCategoryDiversity * 1.0) AS AvgProductCategoryDiversity
    FROM dbo.CustomerSegmentationOutput
    GROUP BY
        ClusterLabel
),
Totals AS (
    SELECT
        SUM(TotalRevenue) AS GrandTotalRevenue,
        SUM(OpenBalance) AS GrandOpenBalance
    FROM dbo.CustomerSegmentationOutput
)
SELECT
    cb.ClusterLabel,
    cb.CustomerCount,
    ROUND(cb.TotalRevenue, 2) AS TotalRevenue,
    ROUND(
        cb.TotalRevenue * 100.0 /
        NULLIF(t.GrandTotalRevenue, 0),
        2
    ) AS RevenueSharePercent,
    ROUND(cb.GrossProfit, 2) AS GrossProfit,
    ROUND(cb.AvgGrossMarginPercent * 100.0, 2) AS GrossMarginPercent,
    ROUND(cb.OpenBalance, 2) AS OpenBalance,
    ROUND(
        cb.OpenBalance * 100.0 /
        NULLIF(t.GrandOpenBalance, 0),
        2
    ) AS OpenBalanceSharePercent,
    ROUND(cb.AvgCollectionRate * 100.0, 2) AS CollectionRatePercent,
    ROUND(cb.AvgMonthlyOrderFrequency, 2) AS AvgMonthlyOrderFrequency,
    ROUND(cb.AvgProductCategoryDiversity, 2) AS AvgProductCategoryDiversity
FROM ClusterBase cb
CROSS JOIN Totals t;
GO


/*
-------------------------------------------------------------------------------
03.04 Customer Priority List

Power BI page:
08 - Customer Portfolio Action Model

Visual:
Customer Priority List

Purpose:
Creates action-oriented customer output for sales and finance teams.

The ranking favors:
- high revenue
- high open balance risk
- low collection rate
- strategic cluster labels
-------------------------------------------------------------------------------
*/

CREATE OR ALTER VIEW vw_Page08_CustomerPriorityList AS
SELECT TOP 25
    CustomerName,
    CustomerSegment,
    Region,
    SalesChannel,
    ClusterLabel,
    ROUND(TotalRevenue, 2) AS TotalRevenue,
    ROUND(GrossMarginPercent * 100.0, 2) AS GrossMarginPercent,
    ROUND(CollectionRate * 100.0, 2) AS CollectionRatePercent,
    ROUND(OpenBalance, 2) AS OpenBalance,
    RecommendedAction,
    ROUND(CustomerPriorityScore, 4) AS CustomerPriorityScore
FROM dbo.CustomerSegmentationOutput
ORDER BY
    CustomerPriorityScore DESC,
    TotalRevenue DESC;
GO


/*
-------------------------------------------------------------------------------
03.05 Channel x Customer Segment Matrix

Power BI page:
08 - Customer Portfolio Action Model

Visual:
Channel x Customer Segment Matrix

Purpose:
Shows which sales channels bring strategic customers and which channels are
more exposed to collection-risk customer groups.
-------------------------------------------------------------------------------
*/

CREATE OR ALTER VIEW vw_Page08_ChannelClusterMatrix AS
WITH ChannelCluster AS (
    SELECT
        SalesChannel,
        ClusterLabel,
        COUNT(DISTINCT CustomerID) AS CustomerCount,
        SUM(TotalRevenue) AS TotalRevenue
    FROM dbo.CustomerSegmentationOutput
    GROUP BY
        SalesChannel,
        ClusterLabel
),
ChannelTotals AS (
    SELECT
        SalesChannel,
        SUM(TotalRevenue) AS ChannelRevenue
    FROM dbo.CustomerSegmentationOutput
    GROUP BY
        SalesChannel
)
SELECT
    cc.SalesChannel,
    cc.ClusterLabel,
    cc.CustomerCount,
    ROUND(cc.TotalRevenue, 2) AS TotalRevenue,
    ROUND(
        cc.TotalRevenue * 100.0 /
        NULLIF(ct.ChannelRevenue, 0),
        2
    ) AS ChannelRevenueSharePercent
FROM ChannelCluster cc
INNER JOIN ChannelTotals ct
    ON cc.SalesChannel = ct.SalesChannel;
GO


/*
-------------------------------------------------------------------------------
03.06 Action Output Summary

Power BI page:
08 - Customer Portfolio Action Model

Visual:
Action Output

Purpose:
Creates compact action cards for management.
-------------------------------------------------------------------------------
*/

CREATE OR ALTER VIEW vw_Page08_ActionOutputSummary AS
SELECT
    'Protect' AS ActionType,
    'Strategic Value Customers' AS TargetGroup,
    ROUND(SUM(TotalRevenue), 2) AS FinancialValue,
    'Revenue' AS ValueType
FROM dbo.CustomerSegmentationOutput
WHERE ClusterLabel = 'Strategic Value Customers'

UNION ALL

SELECT
    'Grow' AS ActionType,
    'Growth Potential Customers' AS TargetGroup,
    ROUND(SUM(TotalRevenue), 2) AS FinancialValue,
    'Revenue' AS ValueType
FROM dbo.CustomerSegmentationOutput
WHERE ClusterLabel = 'Growth Potential Customers'

UNION ALL

SELECT
    'Collect First' AS ActionType,
    'Collection Risk Customers' AS TargetGroup,
    ROUND(SUM(OpenBalance), 2) AS FinancialValue,
    'Open Balance' AS ValueType
FROM dbo.CustomerSegmentationOutput
WHERE ClusterLabel = 'Collection Risk Customers'

UNION ALL

SELECT
    'Low-Touch Service' AS ActionType,
    'Low Contribution Customers' AS TargetGroup,
    COUNT(DISTINCT CustomerID) AS FinancialValue,
    'Customer Count' AS ValueType
FROM dbo.CustomerSegmentationOutput
WHERE ClusterLabel = 'Low Contribution Customers';
GO


/*
===============================================================================
SECTION 04
VALIDATION QUERIES
===============================================================================
*/


/*
-------------------------------------------------------------------------------
04.01 Page 07 KPI Reconciliation

Purpose:
Checks whether Page 07 source views reconcile to confirmed project totals.
-------------------------------------------------------------------------------
*/

SELECT
    'Page07 Monthly Trend - Total Revenue' AS CheckName,
    ROUND(SUM(TotalRevenue), 2) AS CheckValue
FROM vw_Page07_MonthlySalesCommandTrend

UNION ALL

SELECT
    'Page07 Monthly Trend - Gross Profit' AS CheckName,
    ROUND(SUM(GrossProfit), 2) AS CheckValue
FROM vw_Page07_MonthlySalesCommandTrend

UNION ALL

SELECT
    'Page07 Product Category - Total Revenue' AS CheckName,
    ROUND(SUM(TotalRevenue), 2) AS CheckValue
FROM vw_Page07_ProductCategoryRevenueRanking

UNION ALL

SELECT
    'Page07 Receivables - Open Balance' AS CheckName,
    ROUND(SUM(OpenBalance), 2) AS CheckValue
FROM vw_Page07_ReceivablesOpenBalanceRisk;
GO


/*
-------------------------------------------------------------------------------
04.02 Page 08 Python Output Reconciliation

Purpose:
Checks whether Python segmentation output reconciles to the confirmed customer
portfolio totals.

Expected:
- Customer Count: 150
- Total Revenue: 420.6M
- Open Balance: 95.6M
-------------------------------------------------------------------------------
*/

SELECT
    COUNT(DISTINCT CustomerID) AS CustomerCount,
    ROUND(SUM(TotalRevenue), 2) AS TotalRevenue,
    ROUND(SUM(OpenBalance), 2) AS OpenBalance,
    COUNT(DISTINCT ClusterLabel) AS SegmentCount
FROM dbo.CustomerSegmentationOutput;
GO


/*
-------------------------------------------------------------------------------
04.03 Cluster Profile Reconciliation

Purpose:
Validates that the customer cluster profile is complete and action-ready.
-------------------------------------------------------------------------------
*/

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
GO


/*
-------------------------------------------------------------------------------
04.04 Operational Alerts Validation

Purpose:
Returns the current operational alert values used in Page 07.
-------------------------------------------------------------------------------
*/

SELECT
    AlertType,
    AlertValue,
    AlertSeverity,
    OwnerArea
FROM vw_Page07_OperationalAlerts
ORDER BY
    CASE AlertSeverity
        WHEN 'High' THEN 1
        WHEN 'Medium' THEN 2
        WHEN 'Low' THEN 3
        ELSE 99
    END,
    AlertType;
GO


/*
===============================================================================
END OF FILE
===============================================================================
*/