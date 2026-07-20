USE AureviaERPBI;
GO

-- =====================================================
-- Aurevia ERP Operations & BI Dashboard Case Study
-- Executive Data Quality Summary
-- =====================================================

SELECT
    'Invalid Product Price Count' AS [Metric],
    CAST(COUNT(*) AS NVARCHAR(100)) AS [Value],
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'CHECK' END AS [Status]
FROM Products
WHERE IsStockTracked = 1
  AND SalesPrice <= UnitCost

UNION ALL

SELECT
    'Service Stock Movement Count',
    CAST(COUNT(*) AS NVARCHAR(100)),
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'CHECK' END
FROM StockMovements sm
INNER JOIN Products p
    ON sm.ProductID = p.ProductID
WHERE p.IsStockTracked = 0

UNION ALL

SELECT
    'Invalid Stock Movement Sign Count',
    CAST(COUNT(*) AS NVARCHAR(100)),
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'CHECK' END
FROM StockMovements
WHERE
    (MovementType = 'Stock Receipt' AND Quantity <= 0)
    OR
    (MovementType = 'Stock Out' AND Quantity >= 0)

UNION ALL

SELECT
    'Invoice Amount Mismatch Count',
    CAST(COUNT(*) AS NVARCHAR(100)),
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'CHECK' END
FROM Invoices i
INNER JOIN (
    SELECT
        SalesOrderID,
        SUM(RevenueAmount) AS SalesOrderRevenue
    FROM SalesOrderLines
    GROUP BY SalesOrderID
) sol
    ON i.SalesOrderID = sol.SalesOrderID
WHERE ABS(i.InvoiceAmount - sol.SalesOrderRevenue) > 1

UNION ALL

SELECT
    'Overpaid Invoice Count',
    CAST(COUNT(*) AS NVARCHAR(100)),
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'CHECK' END
FROM Invoices i
INNER JOIN (
    SELECT
        InvoiceID,
        SUM(PaymentAmount) AS TotalPaidAmount
    FROM Payments
    GROUP BY InvoiceID
) p
    ON i.InvoiceID = p.InvoiceID
WHERE p.TotalPaidAmount > i.InvoiceAmount

UNION ALL

SELECT
    'Products Below Reorder Level',
    CAST(COUNT(*) AS NVARCHAR(100)),
    CASE WHEN COUNT(*) > 0 THEN 'BUSINESS RISK IDENTIFIED' ELSE 'PASS' END
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
WHERE CurrentStockOnHand < ReorderLevel

UNION ALL

SELECT
    'Negative Stock Product Count',
    CAST(COUNT(*) AS NVARCHAR(100)),
    CASE WHEN COUNT(*) > 0 THEN 'BUSINESS RISK IDENTIFIED' ELSE 'PASS' END
FROM (
    SELECT
        p.ProductID,
        ISNULL(SUM(sm.Quantity), 0) AS CurrentStockOnHand
    FROM Products p
    LEFT JOIN StockMovements sm
        ON p.ProductID = sm.ProductID
    WHERE p.IsStockTracked = 1
    GROUP BY p.ProductID
) stock_summary
WHERE CurrentStockOnHand < 0

UNION ALL

SELECT
    'Collection Rate Percent',
    CAST(
        CAST(
            SUM(ISNULL(p.TotalPaidAmount, 0)) * 100.0 / NULLIF(SUM(i.InvoiceAmount), 0)
            AS DECIMAL(10,2)
        ) AS NVARCHAR(100)
    ),
    'KPI'
FROM Invoices i
LEFT JOIN (
    SELECT
        InvoiceID,
        SUM(PaymentAmount) AS TotalPaidAmount
    FROM Payments
    GROUP BY InvoiceID
) p
    ON i.InvoiceID = p.InvoiceID

UNION ALL

SELECT
    'Gross Margin Percent',
    CAST(
        CAST(
            SUM(GrossProfitAmount) * 100.0 / NULLIF(SUM(RevenueAmount), 0)
            AS DECIMAL(10,2)
        ) AS NVARCHAR(100)
    ),
    'KPI'
FROM SalesOrderLines

UNION ALL

SELECT
    'Total Revenue',
    CAST(CAST(SUM(RevenueAmount) AS DECIMAL(18,2)) AS NVARCHAR(100)),
    'KPI'
FROM SalesOrderLines

UNION ALL

SELECT
    'Open Balance',
    CAST(
        CAST(
            SUM(i.InvoiceAmount - ISNULL(p.TotalPaidAmount, 0))
            AS DECIMAL(18,2)
        ) AS NVARCHAR(100)
    ),
    'KPI'
FROM Invoices i
LEFT JOIN (
    SELECT
        InvoiceID,
        SUM(PaymentAmount) AS TotalPaidAmount
    FROM Payments
    GROUP BY InvoiceID
) p
    ON i.InvoiceID = p.InvoiceID

UNION ALL

SELECT
    'Overdue Invoice Count',
    CAST(COUNT(*) AS NVARCHAR(100)),
    CASE WHEN COUNT(*) > 0 THEN 'BUSINESS RISK IDENTIFIED' ELSE 'PASS' END
FROM Invoices
WHERE InvoiceStatus = 'Overdue'

UNION ALL

SELECT
    'Delayed Purchase Order Count',
    CAST(COUNT(*) AS NVARCHAR(100)),
    CASE WHEN COUNT(*) > 0 THEN 'BUSINESS RISK IDENTIFIED' ELSE 'PASS' END
FROM PurchaseOrders
WHERE ActualDeliveryDate > ExpectedDeliveryDate;
GO