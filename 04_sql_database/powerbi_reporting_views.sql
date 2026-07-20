USE AureviaERPBI;
GO

-- =====================================================
-- Aurevia ERP Operations & BI Dashboard Case Study
-- Power BI Reporting Views
-- =====================================================

-- =====================================================
-- 1. Executive KPI View
-- =====================================================

CREATE OR ALTER VIEW dbo.vw_ExecutiveKPI AS
WITH SalesSummary AS (
    SELECT
        SUM(sol.RevenueAmount) AS TotalRevenue,
        SUM(sol.CostAmount) AS TotalCost,
        SUM(sol.GrossProfitAmount) AS GrossProfit,
        COUNT(DISTINCT so.SalesOrderID) AS SalesOrderCount,
        COUNT(DISTINCT so.CustomerID) AS ActiveCustomerCount
    FROM SalesOrders so
    INNER JOIN SalesOrderLines sol
        ON so.SalesOrderID = sol.SalesOrderID
),
InvoiceSummary AS (
    SELECT
        SUM(i.InvoiceAmount) AS TotalInvoiceAmount,
        SUM(ISNULL(p.TotalPaidAmount, 0)) AS TotalPaidAmount,
        SUM(i.InvoiceAmount - ISNULL(p.TotalPaidAmount, 0)) AS OpenBalance,
        COUNT(CASE WHEN i.InvoiceStatus = 'Overdue' THEN 1 END) AS OverdueInvoiceCount
    FROM Invoices i
    LEFT JOIN (
        SELECT
            InvoiceID,
            SUM(PaymentAmount) AS TotalPaidAmount
        FROM Payments
        GROUP BY InvoiceID
    ) p
        ON i.InvoiceID = p.InvoiceID
),
InventoryRisk AS (
    SELECT
        SUM(CASE WHEN CurrentStockOnHand < ReorderLevel THEN 1 ELSE 0 END) AS ProductsBelowReorderLevel,
        SUM(CASE WHEN CurrentStockOnHand < 0 THEN 1 ELSE 0 END) AS NegativeStockProductCount
    FROM (
        SELECT
            p.ProductID,
            p.ReorderLevel,
            ISNULL(SUM(sm.Quantity), 0) AS CurrentStockOnHand
        FROM Products p
        LEFT JOIN StockMovements sm
            ON p.ProductID = sm.ProductID
        WHERE p.IsStockTracked = 1
        GROUP BY
            p.ProductID,
            p.ReorderLevel
    ) stock_summary
),
SupplierRisk AS (
    SELECT
        COUNT(*) AS DelayedPurchaseOrderCount
    FROM PurchaseOrders
    WHERE ActualDeliveryDate > ExpectedDeliveryDate
)
SELECT
    CAST(s.TotalRevenue AS DECIMAL(18,2)) AS TotalRevenue,
    CAST(s.TotalCost AS DECIMAL(18,2)) AS TotalCost,
    CAST(s.GrossProfit AS DECIMAL(18,2)) AS GrossProfit,
    CAST(s.GrossProfit * 100.0 / NULLIF(s.TotalRevenue, 0) AS DECIMAL(10,2)) AS GrossMarginPercent,
    s.SalesOrderCount,
    s.ActiveCustomerCount,
    CAST(i.TotalInvoiceAmount AS DECIMAL(18,2)) AS TotalInvoiceAmount,
    CAST(i.TotalPaidAmount AS DECIMAL(18,2)) AS TotalPaidAmount,
    CAST(i.OpenBalance AS DECIMAL(18,2)) AS OpenBalance,
    CAST(i.TotalPaidAmount * 100.0 / NULLIF(i.TotalInvoiceAmount, 0) AS DECIMAL(10,2)) AS CollectionRatePercent,
    i.OverdueInvoiceCount,
    ir.ProductsBelowReorderLevel,
    ir.NegativeStockProductCount,
    sr.DelayedPurchaseOrderCount
FROM SalesSummary s
CROSS JOIN InvoiceSummary i
CROSS JOIN InventoryRisk ir
CROSS JOIN SupplierRisk sr;
GO

-- =====================================================
-- 2. Monthly Sales Performance View
-- =====================================================

CREATE OR ALTER VIEW dbo.vw_MonthlySalesPerformance AS
SELECT
    dd.Year,
    dd.Quarter,
    dd.MonthNumber,
    dd.YearMonth,
    COUNT(DISTINCT so.SalesOrderID) AS SalesOrderCount,
    SUM(sol.Quantity) AS TotalQuantitySold,
    CAST(SUM(sol.RevenueAmount) AS DECIMAL(18,2)) AS TotalRevenue,
    CAST(SUM(sol.CostAmount) AS DECIMAL(18,2)) AS TotalCost,
    CAST(SUM(sol.GrossProfitAmount) AS DECIMAL(18,2)) AS GrossProfit,
    CAST(
        SUM(sol.GrossProfitAmount) * 100.0 / NULLIF(SUM(sol.RevenueAmount), 0)
        AS DECIMAL(10,2)
    ) AS GrossMarginPercent
FROM SalesOrders so
INNER JOIN SalesOrderLines sol
    ON so.SalesOrderID = sol.SalesOrderID
INNER JOIN DateDim dd
    ON so.OrderDate = dd.FullDate
GROUP BY
    dd.Year,
    dd.Quarter,
    dd.MonthNumber,
    dd.YearMonth;
GO

-- =====================================================
-- 3. Customer Segment Performance View
-- =====================================================

CREATE OR ALTER VIEW dbo.vw_CustomerSegmentPerformance AS
WITH SalesBySegment AS (
    SELECT
        c.CustomerSegment,
        COUNT(DISTINCT c.CustomerID) AS CustomerCount,
        COUNT(DISTINCT so.SalesOrderID) AS SalesOrderCount,
        SUM(sol.RevenueAmount) AS TotalRevenue,
        SUM(sol.CostAmount) AS TotalCost,
        SUM(sol.GrossProfitAmount) AS GrossProfit
    FROM Customers c
    INNER JOIN SalesOrders so
        ON c.CustomerID = so.CustomerID
    INNER JOIN SalesOrderLines sol
        ON so.SalesOrderID = sol.SalesOrderID
    GROUP BY c.CustomerSegment
),
InvoiceBySegment AS (
    SELECT
        c.CustomerSegment,
        SUM(i.InvoiceAmount) AS TotalInvoiceAmount,
        SUM(ISNULL(p.TotalPaidAmount, 0)) AS TotalPaidAmount,
        SUM(i.InvoiceAmount - ISNULL(p.TotalPaidAmount, 0)) AS OpenBalance
    FROM Customers c
    INNER JOIN Invoices i
        ON c.CustomerID = i.CustomerID
    LEFT JOIN (
        SELECT
            InvoiceID,
            SUM(PaymentAmount) AS TotalPaidAmount
        FROM Payments
        GROUP BY InvoiceID
    ) p
        ON i.InvoiceID = p.InvoiceID
    GROUP BY c.CustomerSegment
)
SELECT
    s.CustomerSegment,
    s.CustomerCount,
    s.SalesOrderCount,
    CAST(s.TotalRevenue AS DECIMAL(18,2)) AS TotalRevenue,
    CAST(s.TotalCost AS DECIMAL(18,2)) AS TotalCost,
    CAST(s.GrossProfit AS DECIMAL(18,2)) AS GrossProfit,
    CAST(s.GrossProfit * 100.0 / NULLIF(s.TotalRevenue, 0) AS DECIMAL(10,2)) AS GrossMarginPercent,
    CAST(s.TotalRevenue / NULLIF(s.SalesOrderCount, 0) AS DECIMAL(18,2)) AS AverageOrderValue,
    CAST(i.TotalInvoiceAmount AS DECIMAL(18,2)) AS TotalInvoiceAmount,
    CAST(i.TotalPaidAmount AS DECIMAL(18,2)) AS TotalPaidAmount,
    CAST(i.OpenBalance AS DECIMAL(18,2)) AS OpenBalance,
    CAST(i.TotalPaidAmount * 100.0 / NULLIF(i.TotalInvoiceAmount, 0) AS DECIMAL(10,2)) AS CollectionRatePercent
FROM SalesBySegment s
LEFT JOIN InvoiceBySegment i
    ON s.CustomerSegment = i.CustomerSegment;
GO

-- =====================================================
-- 4. Product Category Profitability View
-- =====================================================

CREATE OR ALTER VIEW dbo.vw_ProductCategoryProfitability AS
SELECT
    p.ProductCategory,
    COUNT(DISTINCT p.ProductID) AS ProductCount,
    SUM(sol.Quantity) AS TotalQuantitySold,
    CAST(SUM(sol.RevenueAmount) AS DECIMAL(18,2)) AS TotalRevenue,
    CAST(SUM(sol.CostAmount) AS DECIMAL(18,2)) AS TotalCost,
    CAST(SUM(sol.GrossProfitAmount) AS DECIMAL(18,2)) AS GrossProfit,
    CAST(
        SUM(sol.GrossProfitAmount) * 100.0 / NULLIF(SUM(sol.RevenueAmount), 0)
        AS DECIMAL(10,2)
    ) AS GrossMarginPercent
FROM Products p
INNER JOIN SalesOrderLines sol
    ON p.ProductID = sol.ProductID
GROUP BY p.ProductCategory;
GO

-- =====================================================
-- 5. Inventory Risk View
-- =====================================================

CREATE OR ALTER VIEW dbo.vw_InventoryRisk AS
WITH StockSummary AS (
    SELECT
        p.ProductID,
        p.ProductCode,
        p.ProductName,
        p.ProductCategory,
        p.ReorderLevel,
        ISNULL(SUM(sm.Quantity), 0) AS CurrentStockOnHand
    FROM Products p
    LEFT JOIN StockMovements sm
        ON p.ProductID = sm.ProductID
    WHERE p.IsStockTracked = 1
    GROUP BY
        p.ProductID,
        p.ProductCode,
        p.ProductName,
        p.ProductCategory,
        p.ReorderLevel
)
SELECT
    ProductCode,
    ProductName,
    ProductCategory,
    ReorderLevel,
    CurrentStockOnHand,
    ReorderLevel - CurrentStockOnHand AS ReorderGap,
    CASE
        WHEN CurrentStockOnHand < 0 THEN 'NEGATIVE STOCK'
        WHEN CurrentStockOnHand < ReorderLevel THEN 'BELOW REORDER LEVEL'
        ELSE 'HEALTHY STOCK'
    END AS StockRiskStatus
FROM StockSummary;
GO

-- =====================================================
-- 6. Receivables Aging View
-- Reference date: 2026-06-30
-- =====================================================

CREATE OR ALTER VIEW dbo.vw_ReceivablesAging AS
WITH InvoicePayment AS (
    SELECT
        i.InvoiceID,
        i.InvoiceCode,
        i.CustomerID,
        i.InvoiceDate,
        i.DueDate,
        i.InvoiceAmount,
        i.InvoiceStatus,
        ISNULL(p.TotalPaidAmount, 0) AS TotalPaidAmount,
        i.InvoiceAmount - ISNULL(p.TotalPaidAmount, 0) AS OpenBalance
    FROM Invoices i
    LEFT JOIN (
        SELECT
            InvoiceID,
            SUM(PaymentAmount) AS TotalPaidAmount
        FROM Payments
        GROUP BY InvoiceID
    ) p
        ON i.InvoiceID = p.InvoiceID
),
Aging AS (
    SELECT
        CASE
            WHEN InvoiceStatus = 'Paid' THEN 'Paid'
            WHEN DATEDIFF(DAY, DueDate, '2026-06-30') <= 0 THEN 'Not Due'
            WHEN DATEDIFF(DAY, DueDate, '2026-06-30') BETWEEN 1 AND 30 THEN '1-30 Days Overdue'
            WHEN DATEDIFF(DAY, DueDate, '2026-06-30') BETWEEN 31 AND 60 THEN '31-60 Days Overdue'
            WHEN DATEDIFF(DAY, DueDate, '2026-06-30') BETWEEN 61 AND 90 THEN '61-90 Days Overdue'
            ELSE '90+ Days Overdue'
        END AS AgingBucket,
        CASE
            WHEN InvoiceStatus = 'Paid' THEN 0
            WHEN DATEDIFF(DAY, DueDate, '2026-06-30') <= 0 THEN 1
            WHEN DATEDIFF(DAY, DueDate, '2026-06-30') BETWEEN 1 AND 30 THEN 2
            WHEN DATEDIFF(DAY, DueDate, '2026-06-30') BETWEEN 31 AND 60 THEN 3
            WHEN DATEDIFF(DAY, DueDate, '2026-06-30') BETWEEN 61 AND 90 THEN 4
            ELSE 5
        END AS AgingSortOrder,
        InvoiceAmount,
        TotalPaidAmount,
        OpenBalance
    FROM InvoicePayment
)
SELECT
    AgingBucket,
    AgingSortOrder,
    COUNT(*) AS InvoiceCount,
    CAST(SUM(InvoiceAmount) AS DECIMAL(18,2)) AS TotalInvoiceAmount,
    CAST(SUM(TotalPaidAmount) AS DECIMAL(18,2)) AS TotalPaidAmount,
    CAST(SUM(OpenBalance) AS DECIMAL(18,2)) AS OpenBalance
FROM Aging
GROUP BY
    AgingBucket,
    AgingSortOrder;
GO

-- =====================================================
-- 7. Supplier Performance View
-- =====================================================

CREATE OR ALTER VIEW dbo.vw_SupplierPerformance AS
WITH POBase AS (
    SELECT
        po.PurchaseOrderID,
        po.SupplierID,
        po.ExpectedDeliveryDate,
        po.ActualDeliveryDate,
        CASE
            WHEN po.ActualDeliveryDate > po.ExpectedDeliveryDate THEN 1
            ELSE 0
        END AS IsDelayed,
        DATEDIFF(DAY, po.ExpectedDeliveryDate, po.ActualDeliveryDate) AS DelayDays
    FROM PurchaseOrders po
),
PurchaseAmount AS (
    SELECT
        po.SupplierID,
        SUM(pol.LineAmount) AS TotalPurchaseAmount
    FROM PurchaseOrders po
    INNER JOIN PurchaseOrderLines pol
        ON po.PurchaseOrderID = pol.PurchaseOrderID
    GROUP BY po.SupplierID
)
SELECT
    s.SupplierCode,
    s.SupplierName,
    s.SupplierCategory,
    COUNT(pob.PurchaseOrderID) AS PurchaseOrderCount,
    SUM(pob.IsDelayed) AS DelayedPurchaseOrderCount,
    CAST(
        SUM(pob.IsDelayed) * 100.0 / NULLIF(COUNT(pob.PurchaseOrderID), 0)
        AS DECIMAL(10,2)
    ) AS DelayRatePercent,
    CAST(AVG(CAST(pob.DelayDays AS DECIMAL(10,2))) AS DECIMAL(10,2)) AS AverageDelayDays,
    CAST(pa.TotalPurchaseAmount AS DECIMAL(18,2)) AS TotalPurchaseAmount
FROM Suppliers s
INNER JOIN POBase pob
    ON s.SupplierID = pob.SupplierID
LEFT JOIN PurchaseAmount pa
    ON s.SupplierID = pa.SupplierID
GROUP BY
    s.SupplierCode,
    s.SupplierName,
    s.SupplierCategory,
    pa.TotalPurchaseAmount;
GO

-- =====================================================
-- 8. Sales Channel Performance View
-- =====================================================

CREATE OR ALTER VIEW dbo.vw_SalesChannelPerformance AS
SELECT
    so.SalesChannel,
    COUNT(DISTINCT so.SalesOrderID) AS SalesOrderCount,
    SUM(sol.Quantity) AS TotalQuantitySold,
    CAST(SUM(sol.RevenueAmount) AS DECIMAL(18,2)) AS TotalRevenue,
    CAST(SUM(sol.CostAmount) AS DECIMAL(18,2)) AS TotalCost,
    CAST(SUM(sol.GrossProfitAmount) AS DECIMAL(18,2)) AS GrossProfit,
    CAST(
        SUM(sol.GrossProfitAmount) * 100.0 / NULLIF(SUM(sol.RevenueAmount), 0)
        AS DECIMAL(10,2)
    ) AS GrossMarginPercent,
    CAST(
        SUM(sol.RevenueAmount) / NULLIF(COUNT(DISTINCT so.SalesOrderID), 0)
        AS DECIMAL(18,2)
    ) AS AverageOrderValue
FROM SalesOrders so
INNER JOIN SalesOrderLines sol
    ON so.SalesOrderID = sol.SalesOrderID
GROUP BY so.SalesChannel;
GO

-- =====================================================
-- 9. View Validation
-- =====================================================

SELECT
    name AS ViewName
FROM sys.views
WHERE name LIKE 'vw_%'
ORDER BY name;
GO

SELECT TOP 10 *
FROM dbo.vw_ExecutiveKPI;
GO

PRINT 'Power BI reporting views created successfully.';
GO