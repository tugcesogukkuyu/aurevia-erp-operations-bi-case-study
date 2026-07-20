USE AureviaERPBI;
GO

-- =====================================================
-- Aurevia ERP Operations & BI Dashboard Case Study
-- Professional Business Analysis Queries
-- =====================================================

-- =====================================================
-- 1. Monthly Revenue, Cost, Gross Profit and Margin
-- =====================================================

SELECT
    FORMAT(so.OrderDate, 'yyyy-MM') AS [YearMonth],
    COUNT(DISTINCT so.SalesOrderID) AS [SalesOrderCount],
    SUM(sol.RevenueAmount) AS [TotalRevenue],
    SUM(sol.CostAmount) AS [TotalCost],
    SUM(sol.GrossProfitAmount) AS [GrossProfit],
    CAST(
        SUM(sol.GrossProfitAmount) * 100.0 / NULLIF(SUM(sol.RevenueAmount), 0)
        AS DECIMAL(10,2)
    ) AS [GrossMarginPercent]
FROM SalesOrders so
INNER JOIN SalesOrderLines sol
    ON so.SalesOrderID = sol.SalesOrderID
GROUP BY FORMAT(so.OrderDate, 'yyyy-MM')
ORDER BY [YearMonth];
GO

-- =====================================================
-- 2. Revenue and Margin by Customer Segment
-- =====================================================

SELECT
    c.CustomerSegment,
    COUNT(DISTINCT c.CustomerID) AS [CustomerCount],
    COUNT(DISTINCT so.SalesOrderID) AS [SalesOrderCount],
    SUM(sol.RevenueAmount) AS [TotalRevenue],
    SUM(sol.GrossProfitAmount) AS [GrossProfit],
    CAST(
        SUM(sol.GrossProfitAmount) * 100.0 / NULLIF(SUM(sol.RevenueAmount), 0)
        AS DECIMAL(10,2)
    ) AS [GrossMarginPercent],
    CAST(
        SUM(sol.RevenueAmount) / NULLIF(COUNT(DISTINCT so.SalesOrderID), 0)
        AS DECIMAL(18,2)
    ) AS [AverageOrderValue]
FROM Customers c
INNER JOIN SalesOrders so
    ON c.CustomerID = so.CustomerID
INNER JOIN SalesOrderLines sol
    ON so.SalesOrderID = sol.SalesOrderID
GROUP BY c.CustomerSegment
ORDER BY [TotalRevenue] DESC;
GO

-- =====================================================
-- 3. Top 15 Customers by Revenue and Open Balance
-- =====================================================

SELECT TOP 15
    c.CustomerCode,
    c.CustomerName,
    c.CustomerSegment,
    c.City,
    SUM(sol.RevenueAmount) AS [TotalRevenue],
    SUM(sol.GrossProfitAmount) AS [GrossProfit],
    SUM(i.InvoiceAmount) AS [TotalInvoiceAmount],
    SUM(ISNULL(p.TotalPaidAmount, 0)) AS [TotalPaidAmount],
    SUM(i.InvoiceAmount - ISNULL(p.TotalPaidAmount, 0)) AS [OpenBalance]
FROM Customers c
INNER JOIN SalesOrders so
    ON c.CustomerID = so.CustomerID
INNER JOIN SalesOrderLines sol
    ON so.SalesOrderID = sol.SalesOrderID
INNER JOIN Invoices i
    ON so.SalesOrderID = i.SalesOrderID
LEFT JOIN (
    SELECT
        InvoiceID,
        SUM(PaymentAmount) AS TotalPaidAmount
    FROM Payments
    GROUP BY InvoiceID
) p
    ON i.InvoiceID = p.InvoiceID
GROUP BY
    c.CustomerCode,
    c.CustomerName,
    c.CustomerSegment,
    c.City
ORDER BY [TotalRevenue] DESC;
GO

-- =====================================================
-- 4. Product Category Profitability
-- =====================================================

SELECT
    p.ProductCategory,
    COUNT(DISTINCT p.ProductID) AS [ProductCount],
    SUM(sol.Quantity) AS [TotalQuantitySold],
    SUM(sol.RevenueAmount) AS [TotalRevenue],
    SUM(sol.CostAmount) AS [TotalCost],
    SUM(sol.GrossProfitAmount) AS [GrossProfit],
    CAST(
        SUM(sol.GrossProfitAmount) * 100.0 / NULLIF(SUM(sol.RevenueAmount), 0)
        AS DECIMAL(10,2)
    ) AS [GrossMarginPercent]
FROM Products p
INNER JOIN SalesOrderLines sol
    ON p.ProductID = sol.ProductID
GROUP BY p.ProductCategory
ORDER BY [TotalRevenue] DESC;
GO

-- =====================================================
-- 5. Inventory Risk Detail
-- Products below reorder level or negative stock
-- =====================================================

SELECT
    p.ProductCode,
    p.ProductName,
    p.ProductCategory,
    p.ReorderLevel,
    ISNULL(SUM(sm.Quantity), 0) AS [CurrentStockOnHand],
    CASE
        WHEN ISNULL(SUM(sm.Quantity), 0) < 0 THEN 'NEGATIVE STOCK'
        WHEN ISNULL(SUM(sm.Quantity), 0) < p.ReorderLevel THEN 'BELOW REORDER LEVEL'
        ELSE 'HEALTHY STOCK'
    END AS [StockRiskStatus],
    p.ReorderLevel - ISNULL(SUM(sm.Quantity), 0) AS [ReorderGap]
FROM Products p
LEFT JOIN StockMovements sm
    ON p.ProductID = sm.ProductID
WHERE p.IsStockTracked = 1
GROUP BY
    p.ProductCode,
    p.ProductName,
    p.ProductCategory,
    p.ReorderLevel
HAVING ISNULL(SUM(sm.Quantity), 0) < p.ReorderLevel
ORDER BY [CurrentStockOnHand] ASC;
GO

-- =====================================================
-- 6. Invoice Aging and Receivables Risk
-- Reference date: 2026-06-30
-- =====================================================

SELECT
    CASE
        WHEN i.InvoiceStatus = 'Paid' THEN 'Paid'
        WHEN DATEDIFF(DAY, i.DueDate, '2026-06-30') <= 0 THEN 'Not Due'
        WHEN DATEDIFF(DAY, i.DueDate, '2026-06-30') BETWEEN 1 AND 30 THEN '1-30 Days Overdue'
        WHEN DATEDIFF(DAY, i.DueDate, '2026-06-30') BETWEEN 31 AND 60 THEN '31-60 Days Overdue'
        WHEN DATEDIFF(DAY, i.DueDate, '2026-06-30') BETWEEN 61 AND 90 THEN '61-90 Days Overdue'
        ELSE '90+ Days Overdue'
    END AS [AgingBucket],
    COUNT(i.InvoiceID) AS [InvoiceCount],
    SUM(i.InvoiceAmount) AS [TotalInvoiceAmount],
    SUM(ISNULL(p.TotalPaidAmount, 0)) AS [TotalPaidAmount],
    SUM(i.InvoiceAmount - ISNULL(p.TotalPaidAmount, 0)) AS [OpenBalance]
FROM Invoices i
LEFT JOIN (
    SELECT
        InvoiceID,
        SUM(PaymentAmount) AS TotalPaidAmount
    FROM Payments
    GROUP BY InvoiceID
) p
    ON i.InvoiceID = p.InvoiceID
GROUP BY
    CASE
        WHEN i.InvoiceStatus = 'Paid' THEN 'Paid'
        WHEN DATEDIFF(DAY, i.DueDate, '2026-06-30') <= 0 THEN 'Not Due'
        WHEN DATEDIFF(DAY, i.DueDate, '2026-06-30') BETWEEN 1 AND 30 THEN '1-30 Days Overdue'
        WHEN DATEDIFF(DAY, i.DueDate, '2026-06-30') BETWEEN 31 AND 60 THEN '31-60 Days Overdue'
        WHEN DATEDIFF(DAY, i.DueDate, '2026-06-30') BETWEEN 61 AND 90 THEN '61-90 Days Overdue'
        ELSE '90+ Days Overdue'
    END
ORDER BY [OpenBalance] DESC;
GO

-- =====================================================
-- 7. Supplier Delivery Performance
-- =====================================================

SELECT
    s.SupplierCode,
    s.SupplierName,
    s.SupplierCategory,
    COUNT(po.PurchaseOrderID) AS [PurchaseOrderCount],
    SUM(CASE WHEN po.ActualDeliveryDate > po.ExpectedDeliveryDate THEN 1 ELSE 0 END) AS [DelayedPurchaseOrderCount],
    CAST(
        SUM(CASE WHEN po.ActualDeliveryDate > po.ExpectedDeliveryDate THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(po.PurchaseOrderID), 0)
        AS DECIMAL(10,2)
    ) AS [DelayRatePercent],
    AVG(DATEDIFF(DAY, po.ExpectedDeliveryDate, po.ActualDeliveryDate)) AS [AverageDelayDays],
    SUM(pol.LineAmount) AS [TotalPurchaseAmount]
FROM Suppliers s
INNER JOIN PurchaseOrders po
    ON s.SupplierID = po.SupplierID
INNER JOIN PurchaseOrderLines pol
    ON po.PurchaseOrderID = pol.PurchaseOrderID
GROUP BY
    s.SupplierCode,
    s.SupplierName,
    s.SupplierCategory
ORDER BY [DelayRatePercent] DESC;
GO

-- =====================================================
-- 8. Sales Channel Performance
-- =====================================================

SELECT
    so.SalesChannel,
    COUNT(DISTINCT so.SalesOrderID) AS [SalesOrderCount],
    SUM(sol.RevenueAmount) AS [TotalRevenue],
    SUM(sol.GrossProfitAmount) AS [GrossProfit],
    CAST(
        SUM(sol.GrossProfitAmount) * 100.0 / NULLIF(SUM(sol.RevenueAmount), 0)
        AS DECIMAL(10,2)
    ) AS [GrossMarginPercent],
    CAST(
        SUM(sol.RevenueAmount) / NULLIF(COUNT(DISTINCT so.SalesOrderID), 0)
        AS DECIMAL(18,2)
    ) AS [AverageOrderValue]
FROM SalesOrders so
INNER JOIN SalesOrderLines sol
    ON so.SalesOrderID = sol.SalesOrderID
GROUP BY so.SalesChannel
ORDER BY [TotalRevenue] DESC;
GO

-- =====================================================
-- 9. Open Balance by Customer Segment
-- =====================================================

SELECT
    c.CustomerSegment,
    COUNT(DISTINCT c.CustomerID) AS [CustomerCount],
    COUNT(i.InvoiceID) AS [InvoiceCount],
    SUM(i.InvoiceAmount) AS [TotalInvoiceAmount],
    SUM(ISNULL(p.TotalPaidAmount, 0)) AS [TotalPaidAmount],
    SUM(i.InvoiceAmount - ISNULL(p.TotalPaidAmount, 0)) AS [OpenBalance],
    CAST(
        SUM(ISNULL(p.TotalPaidAmount, 0)) * 100.0 / NULLIF(SUM(i.InvoiceAmount), 0)
        AS DECIMAL(10,2)
    ) AS [CollectionRatePercent]
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
ORDER BY [OpenBalance] DESC;
GO

-- =====================================================
-- 10. Executive KPI Summary
-- =====================================================

SELECT
    SUM(sol.RevenueAmount) AS [TotalRevenue],
    SUM(sol.CostAmount) AS [TotalCost],
    SUM(sol.GrossProfitAmount) AS [GrossProfit],
    CAST(
        SUM(sol.GrossProfitAmount) * 100.0 / NULLIF(SUM(sol.RevenueAmount), 0)
        AS DECIMAL(10,2)
    ) AS [GrossMarginPercent],
    COUNT(DISTINCT so.SalesOrderID) AS [SalesOrderCount],
    COUNT(DISTINCT so.CustomerID) AS [ActiveCustomerCount]
FROM SalesOrders so
INNER JOIN SalesOrderLines sol
    ON so.SalesOrderID = sol.SalesOrderID;
GO