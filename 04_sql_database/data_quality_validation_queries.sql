USE AureviaERPBI;
GO

-- =====================================================
-- Aurevia ERP Operations & BI Dashboard Case Study
-- Data Quality & Business Validation Queries
-- =====================================================

-- =====================================================
-- 1. Row Count Validation
-- =====================================================

SELECT 'Customers' AS [TableName], COUNT(*) AS [RowCount] FROM Customers
UNION ALL
SELECT 'Suppliers' AS [TableName], COUNT(*) AS [RowCount] FROM Suppliers
UNION ALL
SELECT 'Products' AS [TableName], COUNT(*) AS [RowCount] FROM Products
UNION ALL
SELECT 'Warehouses' AS [TableName], COUNT(*) AS [RowCount] FROM Warehouses
UNION ALL
SELECT 'PurchaseOrders' AS [TableName], COUNT(*) AS [RowCount] FROM PurchaseOrders
UNION ALL
SELECT 'PurchaseOrderLines' AS [TableName], COUNT(*) AS [RowCount] FROM PurchaseOrderLines
UNION ALL
SELECT 'SalesOrders' AS [TableName], COUNT(*) AS [RowCount] FROM SalesOrders
UNION ALL
SELECT 'SalesOrderLines' AS [TableName], COUNT(*) AS [RowCount] FROM SalesOrderLines
UNION ALL
SELECT 'StockMovements' AS [TableName], COUNT(*) AS [RowCount] FROM StockMovements
UNION ALL
SELECT 'Invoices' AS [TableName], COUNT(*) AS [RowCount] FROM Invoices
UNION ALL
SELECT 'Payments' AS [TableName], COUNT(*) AS [RowCount] FROM Payments
UNION ALL
SELECT 'DateDim' AS [TableName], COUNT(*) AS [RowCount] FROM DateDim;
GO

-- =====================================================
-- 2. Date Range Validation
-- =====================================================

SELECT
    MIN(FullDate) AS [StartDate],
    MAX(FullDate) AS [EndDate],
    COUNT(*) AS [DateRecordCount]
FROM DateDim;
GO

-- =====================================================
-- 3. Product Price Validation
-- Physical products must have sales price greater than unit cost
-- =====================================================

SELECT
    COUNT(*) AS [InvalidProductPriceCount]
FROM Products
WHERE IsStockTracked = 1
  AND SalesPrice <= UnitCost;
GO

-- =====================================================
-- 4. Service Inventory Validation
-- Services must not generate stock movements
-- =====================================================

SELECT
    COUNT(*) AS [ServiceStockMovementCount]
FROM StockMovements sm
INNER JOIN Products p
    ON sm.ProductID = p.ProductID
WHERE p.IsStockTracked = 0;
GO

-- =====================================================
-- 5. Stock Movement Sign Validation
-- Stock Receipt must be positive
-- Stock Out must be negative
-- =====================================================

SELECT
    COUNT(*) AS [InvalidStockMovementSignCount]
FROM StockMovements
WHERE
    (MovementType = 'Stock Receipt' AND Quantity <= 0)
    OR
    (MovementType = 'Stock Out' AND Quantity >= 0);
GO

-- =====================================================
-- 6. Invoice Amount Validation
-- Invoice amount must match sales order line revenue
-- =====================================================

SELECT
    COUNT(*) AS [InvoiceAmountMismatchCount]
FROM Invoices i
INNER JOIN (
    SELECT
        SalesOrderID,
        SUM(RevenueAmount) AS SalesOrderRevenue
    FROM SalesOrderLines
    GROUP BY SalesOrderID
) sol
    ON i.SalesOrderID = sol.SalesOrderID
WHERE ABS(i.InvoiceAmount - sol.SalesOrderRevenue) > 1;
GO

-- =====================================================
-- 7. Payment Amount Validation
-- Total payment amount should not exceed invoice amount
-- =====================================================

SELECT
    COUNT(*) AS [OverpaidInvoiceCount]
FROM Invoices i
INNER JOIN (
    SELECT
        InvoiceID,
        SUM(PaymentAmount) AS TotalPaidAmount
    FROM Payments
    GROUP BY InvoiceID
) p
    ON i.InvoiceID = p.InvoiceID
WHERE p.TotalPaidAmount > i.InvoiceAmount;
GO

-- =====================================================
-- 8. Invoice Status Distribution
-- =====================================================

SELECT
    InvoiceStatus,
    COUNT(*) AS [InvoiceCount],
    SUM(InvoiceAmount) AS [TotalInvoiceAmount]
FROM Invoices
GROUP BY InvoiceStatus
ORDER BY [InvoiceCount] DESC;
GO

-- =====================================================
-- 9. Payment Collection Summary
-- =====================================================

SELECT
    SUM(i.InvoiceAmount) AS [TotalInvoiceAmount],
    SUM(ISNULL(p.TotalPaidAmount, 0)) AS [TotalPaidAmount],
    SUM(i.InvoiceAmount - ISNULL(p.TotalPaidAmount, 0)) AS [OpenBalance],
    CAST(
        SUM(ISNULL(p.TotalPaidAmount, 0)) * 100.0 / NULLIF(SUM(i.InvoiceAmount), 0)
        AS DECIMAL(10,2)
    ) AS [CollectionRatePercent]
FROM Invoices i
LEFT JOIN (
    SELECT
        InvoiceID,
        SUM(PaymentAmount) AS TotalPaidAmount
    FROM Payments
    GROUP BY InvoiceID
) p
    ON i.InvoiceID = p.InvoiceID;
GO

-- =====================================================
-- 10. Sales Revenue, Cost and Gross Profit Summary
-- =====================================================

SELECT
    SUM(RevenueAmount) AS [TotalRevenue],
    SUM(CostAmount) AS [TotalCost],
    SUM(GrossProfitAmount) AS [GrossProfit],
    CAST(
        SUM(GrossProfitAmount) * 100.0 / NULLIF(SUM(RevenueAmount), 0)
        AS DECIMAL(10,2)
    ) AS [GrossMarginPercent]
FROM SalesOrderLines;
GO

-- =====================================================
-- 11. Revenue by Customer Segment
-- =====================================================

SELECT
    c.CustomerSegment,
    SUM(sol.RevenueAmount) AS [TotalRevenue],
    SUM(sol.GrossProfitAmount) AS [GrossProfit],
    CAST(
        SUM(sol.GrossProfitAmount) * 100.0 / NULLIF(SUM(sol.RevenueAmount), 0)
        AS DECIMAL(10,2)
    ) AS [GrossMarginPercent],
    COUNT(DISTINCT so.SalesOrderID) AS [SalesOrderCount]
FROM SalesOrderLines sol
INNER JOIN SalesOrders so
    ON sol.SalesOrderID = so.SalesOrderID
INNER JOIN Customers c
    ON so.CustomerID = c.CustomerID
GROUP BY c.CustomerSegment
ORDER BY [TotalRevenue] DESC;
GO

-- =====================================================
-- 12. Revenue by Product Category
-- =====================================================

SELECT
    p.ProductCategory,
    SUM(sol.RevenueAmount) AS [TotalRevenue],
    SUM(sol.CostAmount) AS [TotalCost],
    SUM(sol.GrossProfitAmount) AS [GrossProfit],
    CAST(
        SUM(sol.GrossProfitAmount) * 100.0 / NULLIF(SUM(sol.RevenueAmount), 0)
        AS DECIMAL(10,2)
    ) AS [GrossMarginPercent]
FROM SalesOrderLines sol
INNER JOIN Products p
    ON sol.ProductID = p.ProductID
GROUP BY p.ProductCategory
ORDER BY [TotalRevenue] DESC;
GO

-- =====================================================
-- 13. Current Stock On Hand by Product
-- =====================================================

SELECT TOP 20
    p.ProductCode,
    p.ProductName,
    p.ProductCategory,
    p.ReorderLevel,
    SUM(sm.Quantity) AS [CurrentStockOnHand],
    CASE
        WHEN SUM(sm.Quantity) < p.ReorderLevel THEN 'Below Reorder Level'
        ELSE 'Healthy Stock'
    END AS [StockStatus]
FROM StockMovements sm
INNER JOIN Products p
    ON sm.ProductID = p.ProductID
WHERE p.IsStockTracked = 1
GROUP BY
    p.ProductCode,
    p.ProductName,
    p.ProductCategory,
    p.ReorderLevel
ORDER BY [CurrentStockOnHand] ASC;
GO

-- =====================================================
-- 14. Products Below Reorder Level
-- =====================================================

SELECT
    COUNT(*) AS [ProductsBelowReorderLevel]
FROM (
    SELECT
        p.ProductID,
        p.ReorderLevel,
        SUM(sm.Quantity) AS CurrentStockOnHand
    FROM Products p
    LEFT JOIN StockMovements sm
        ON p.ProductID = sm.ProductID
    WHERE p.IsStockTracked = 1
    GROUP BY
        p.ProductID,
        p.ReorderLevel
) stock_summary
WHERE CurrentStockOnHand < ReorderLevel;
GO

-- =====================================================
-- 15. Supplier Delivery Delay Analysis
-- =====================================================

SELECT
    s.SupplierName,
    COUNT(po.PurchaseOrderID) AS [PurchaseOrderCount],
    SUM(
        CASE
            WHEN po.ActualDeliveryDate > po.ExpectedDeliveryDate THEN 1
            ELSE 0
        END
    ) AS [DelayedPurchaseOrderCount],
    CAST(
        SUM(
            CASE
                WHEN po.ActualDeliveryDate > po.ExpectedDeliveryDate THEN 1
                ELSE 0
            END
        ) * 100.0 / NULLIF(COUNT(po.PurchaseOrderID), 0)
        AS DECIMAL(10,2)
    ) AS [DelayRatePercent],
    AVG(DATEDIFF(DAY, po.ExpectedDeliveryDate, po.ActualDeliveryDate)) AS [AverageDelayDays]
FROM PurchaseOrders po
INNER JOIN Suppliers s
    ON po.SupplierID = s.SupplierID
GROUP BY s.SupplierName
ORDER BY [DelayRatePercent] DESC;
GO