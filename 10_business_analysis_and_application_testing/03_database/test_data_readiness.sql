-- ============================================================
-- Aurevia ERP Application Control and Testing Case
-- TEST / UAT Data Readiness Validation
-- Microsoft SQL Server
-- ============================================================

USE AureviaERPBI;
GO

SET NOCOUNT ON;
GO

IF OBJECT_ID('tempdb..#TestDataReadiness') IS NOT NULL
BEGIN
    DROP TABLE #TestDataReadiness;
END;
GO

CREATE TABLE #TestDataReadiness (
    CheckID NVARCHAR(30) NOT NULL PRIMARY KEY,
    ScenarioCode NVARCHAR(60) NOT NULL,
    Requirement NVARCHAR(300) NOT NULL,
    ExpectedResult NVARCHAR(300) NOT NULL,
    ActualResult NVARCHAR(500) NOT NULL,
    ReadinessStatus NVARCHAR(10) NOT NULL
);
GO

-- ============================================================
-- 1. User and Role Readiness
-- ============================================================

INSERT INTO #TestDataReadiness (
    CheckID,
    ScenarioCode,
    Requirement,
    ExpectedResult,
    ActualResult,
    ReadinessStatus
)
SELECT
    'TDR-001',
    'AUTHORIZED_SALES_APPROVAL',
    'An active Sales Manager user must exist.',
    'At least 1 active user with SALES_MANAGER role',
    CONCAT(COUNT(*), ' matching user(s)'),
    CASE
        WHEN COUNT(*) >= 1 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM dbo.ApplicationUsers AS u
INNER JOIN dbo.UserRoles AS ur
    ON ur.UserID = u.UserID
INNER JOIN dbo.Roles AS r
    ON r.RoleID = ur.RoleID
WHERE u.IsActive = 1
  AND r.RoleCode = 'SALES_MANAGER';
GO

INSERT INTO #TestDataReadiness (
    CheckID,
    ScenarioCode,
    Requirement,
    ExpectedResult,
    ActualResult,
    ReadinessStatus
)
SELECT
    'TDR-002',
    'UNAUTHORIZED_SALES_APPROVAL',
    'An active standard Sales User must exist.',
    'At least 1 active user with SALES_USER role',
    CONCAT(COUNT(*), ' matching user(s)'),
    CASE
        WHEN COUNT(*) >= 1 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM dbo.ApplicationUsers AS u
INNER JOIN dbo.UserRoles AS ur
    ON ur.UserID = u.UserID
INNER JOIN dbo.Roles AS r
    ON r.RoleID = ur.RoleID
WHERE u.IsActive = 1
  AND r.RoleCode = 'SALES_USER';
GO

INSERT INTO #TestDataReadiness (
    CheckID,
    ScenarioCode,
    Requirement,
    ExpectedResult,
    ActualResult,
    ReadinessStatus
)
SELECT
    'TDR-003',
    'FINANCE_EXCEPTION_APPROVAL',
    'An active Finance User must exist.',
    'At least 1 active user with FINANCE_USER role',
    CONCAT(COUNT(*), ' matching user(s)'),
    CASE
        WHEN COUNT(*) >= 1 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM dbo.ApplicationUsers AS u
INNER JOIN dbo.UserRoles AS ur
    ON ur.UserID = u.UserID
INNER JOIN dbo.Roles AS r
    ON r.RoleID = ur.RoleID
WHERE u.IsActive = 1
  AND r.RoleCode = 'FINANCE_USER';
GO

INSERT INTO #TestDataReadiness (
    CheckID,
    ScenarioCode,
    Requirement,
    ExpectedResult,
    ActualResult,
    ReadinessStatus
)
SELECT
    'TDR-004',
    'GOODS_RECEIPT_EXCEPTION_APPROVAL',
    'An active Warehouse Manager must exist.',
    'At least 1 active user with WAREHOUSE_MANAGER role',
    CONCAT(COUNT(*), ' matching user(s)'),
    CASE
        WHEN COUNT(*) >= 1 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM dbo.ApplicationUsers AS u
INNER JOIN dbo.UserRoles AS ur
    ON ur.UserID = u.UserID
INNER JOIN dbo.Roles AS r
    ON r.RoleID = ur.RoleID
WHERE u.IsActive = 1
  AND r.RoleCode = 'WAREHOUSE_MANAGER';
GO

-- ============================================================
-- 2. Batch Readiness
-- ============================================================

INSERT INTO #TestDataReadiness (
    CheckID,
    ScenarioCode,
    Requirement,
    ExpectedResult,
    ActualResult,
    ReadinessStatus
)
SELECT
    'TDR-005',
    'VALID_BATCH_APPROVAL',
    'A released batch with sufficient remaining shelf life must exist.',
    'BATCH-REL-001 must be RELEASED and have at least 20 remaining days',
    CASE
        WHEN COUNT(*) = 0 THEN 'No matching batch'
        ELSE CONCAT(
            MAX(b.BatchNumber),
            ' / ',
            MAX(b.QualityStatus),
            ' / ',
            MAX(
                DATEDIFF(
                    DAY,
                    CAST(GETDATE() AS DATE),
                    b.ExpirationDate
                )
            ),
            ' day(s)'
        )
    END,
    CASE
        WHEN COUNT(*) >= 1 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM dbo.ProductBatches AS b
INNER JOIN dbo.Products AS p
    ON p.ProductID = b.ProductID
WHERE b.BatchNumber = 'BATCH-REL-001'
  AND p.ProductCode = 'PRD-001'
  AND b.QualityStatus = 'RELEASED'
  AND DATEDIFF(
        DAY,
        CAST(GETDATE() AS DATE),
        b.ExpirationDate
      ) >= 20;
GO

INSERT INTO #TestDataReadiness (
    CheckID,
    ScenarioCode,
    Requirement,
    ExpectedResult,
    ActualResult,
    ReadinessStatus
)
SELECT
    'TDR-006',
    'QUALITY_BLOCKED_BATCH',
    'A quality-blocked batch must exist.',
    'BATCH-BLOCK-001 with QUALITY_BLOCKED status',
    CASE
        WHEN COUNT(*) = 0 THEN 'No matching batch'
        ELSE CONCAT(
            MAX(b.BatchNumber),
            ' / ',
            MAX(b.QualityStatus)
        )
    END,
    CASE
        WHEN COUNT(*) >= 1 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM dbo.ProductBatches AS b
INNER JOIN dbo.Products AS p
    ON p.ProductID = b.ProductID
WHERE b.BatchNumber = 'BATCH-BLOCK-001'
  AND p.ProductCode = 'PRD-001'
  AND b.QualityStatus = 'QUALITY_BLOCKED';
GO

INSERT INTO #TestDataReadiness (
    CheckID,
    ScenarioCode,
    Requirement,
    ExpectedResult,
    ActualResult,
    ReadinessStatus
)
SELECT
    'TDR-007',
    'SHORT_SHELF_LIFE_BATCH',
    'A released batch below the customer shelf-life requirement must exist.',
    'BATCH-SHORT-001 must have fewer than 20 remaining days',
    CASE
        WHEN COUNT(*) = 0 THEN 'No matching short shelf-life batch'
        ELSE CONCAT(
            MAX(b.BatchNumber),
            ' / ',
            MAX(b.QualityStatus),
            ' / ',
            MAX(
                DATEDIFF(
                    DAY,
                    CAST(GETDATE() AS DATE),
                    b.ExpirationDate
                )
            ),
            ' day(s)'
        )
    END,
    CASE
        WHEN COUNT(*) >= 1 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM dbo.ProductBatches AS b
INNER JOIN dbo.Products AS p
    ON p.ProductID = b.ProductID
WHERE b.BatchNumber = 'BATCH-SHORT-001'
  AND p.ProductCode = 'PRD-001'
  AND b.QualityStatus = 'RELEASED'
  AND DATEDIFF(
        DAY,
        CAST(GETDATE() AS DATE),
        b.ExpirationDate
      ) < 20;
GO

INSERT INTO #TestDataReadiness (
    CheckID,
    ScenarioCode,
    Requirement,
    ExpectedResult,
    ActualResult,
    ReadinessStatus
)
SELECT
    'TDR-008',
    'REJECTED_BATCH',
    'A rejected batch must exist.',
    'BATCH-REJ-001 with REJECTED status',
    CASE
        WHEN COUNT(*) = 0 THEN 'No matching rejected batch'
        ELSE CONCAT(
            MAX(b.BatchNumber),
            ' / ',
            MAX(b.QualityStatus)
        )
    END,
    CASE
        WHEN COUNT(*) >= 1 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM dbo.ProductBatches AS b
INNER JOIN dbo.Products AS p
    ON p.ProductID = b.ProductID
WHERE b.BatchNumber = 'BATCH-REJ-001'
  AND p.ProductCode = 'PRD-001'
  AND b.QualityStatus = 'REJECTED';
GO

-- ============================================================
-- 3. Inventory and Warehouse Readiness
-- ============================================================

INSERT INTO #TestDataReadiness (
    CheckID,
    ScenarioCode,
    Requirement,
    ExpectedResult,
    ActualResult,
    ReadinessStatus
)
SELECT
    'TDR-009',
    'INSUFFICIENT_AVAILABLE_STOCK',
    'Inventory must contain physical and reserved quantities.',
    'Physical 500, reserved 200, available 300',
    CASE
        WHEN COUNT(*) = 0 THEN 'No matching inventory balance'
        ELSE CONCAT(
            'Physical=',
            MAX(i.PhysicalQuantity),
            ', Reserved=',
            MAX(i.ReservedQuantity),
            ', Available=',
            MAX(i.AvailableQuantity)
        )
    END,
    CASE
        WHEN COUNT(*) >= 1 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM dbo.InventoryBalances AS i
INNER JOIN dbo.ProductBatches AS b
    ON b.BatchID = i.BatchID
INNER JOIN dbo.Products AS p
    ON p.ProductID = i.ProductID
INNER JOIN dbo.Warehouses AS w
    ON w.WarehouseID = i.WarehouseID
WHERE b.BatchNumber = 'BATCH-REL-001'
  AND p.ProductCode = 'PRD-001'
  AND w.WarehouseCode = 'WH-001'
  AND i.PhysicalQuantity = 500
  AND i.ReservedQuantity = 200
  AND i.AvailableQuantity = 300;
GO

INSERT INTO #TestDataReadiness (
    CheckID,
    ScenarioCode,
    Requirement,
    ExpectedResult,
    ActualResult,
    ReadinessStatus
)
SELECT
    'TDR-010',
    'INELIGIBLE_WAREHOUSE',
    'Inventory must exist in a warehouse that is not sales eligible.',
    'WH-003 with IsSalesEligible = 0 and available stock',
    CASE
        WHEN COUNT(*) = 0 THEN 'No matching warehouse inventory'
        ELSE CONCAT(
            MAX(w.WarehouseCode),
            ' / Eligible=',
            MAX(CAST(w.IsSalesEligible AS INT)),
            ' / Available=',
            MAX(i.AvailableQuantity)
        )
    END,
    CASE
        WHEN COUNT(*) >= 1 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM dbo.InventoryBalances AS i
INNER JOIN dbo.ProductBatches AS b
    ON b.BatchID = i.BatchID
INNER JOIN dbo.Products AS p
    ON p.ProductID = i.ProductID
INNER JOIN dbo.Warehouses AS w
    ON w.WarehouseID = i.WarehouseID
WHERE b.BatchNumber = 'BATCH-REL-001'
  AND p.ProductCode = 'PRD-001'
  AND w.WarehouseCode = 'WH-003'
  AND w.IsSalesEligible = 0
  AND i.AvailableQuantity > 0;
GO

-- ============================================================
-- 4. Customer Credit Readiness
-- ============================================================

INSERT INTO #TestDataReadiness (
    CheckID,
    ScenarioCode,
    Requirement,
    ExpectedResult,
    ActualResult,
    ReadinessStatus
)
SELECT
    'TDR-011',
    'CREDIT_LIMIT_EXCEPTION',
    'A customer close to the credit limit must exist.',
    'CUST-001: limit 100000, exposure 85000, remaining 15000',
    CASE
        WHEN COUNT(*) = 0 THEN 'No matching credit profile'
        ELSE CONCAT(
            MAX(c.CustomerCode),
            ' / Limit=',
            MAX(cp.CreditLimit),
            ' / Exposure=',
            MAX(cp.CurrentExposure),
            ' / Remaining=',
            MAX(cp.CreditLimit - cp.CurrentExposure)
        )
    END,
    CASE
        WHEN COUNT(*) >= 1 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM dbo.CustomerCreditProfiles AS cp
INNER JOIN dbo.Customers AS c
    ON c.CustomerID = cp.CustomerID
WHERE c.CustomerCode = 'CUST-001'
  AND cp.CreditLimit = 100000
  AND cp.CurrentExposure = 85000
  AND cp.IsCreditBlocked = 0;
GO

INSERT INTO #TestDataReadiness (
    CheckID,
    ScenarioCode,
    Requirement,
    ExpectedResult,
    ActualResult,
    ReadinessStatus
)
SELECT
    'TDR-012',
    'STANDARD_CREDIT_APPROVAL',
    'A customer with sufficient remaining credit must exist.',
    'CUST-002 with remaining credit above 100000',
    CASE
        WHEN COUNT(*) = 0 THEN 'No matching standard credit profile'
        ELSE CONCAT(
            MAX(c.CustomerCode),
            ' / Remaining=',
            MAX(cp.CreditLimit - cp.CurrentExposure)
        )
    END,
    CASE
        WHEN COUNT(*) >= 1 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM dbo.CustomerCreditProfiles AS cp
INNER JOIN dbo.Customers AS c
    ON c.CustomerID = cp.CustomerID
WHERE c.CustomerCode = 'CUST-002'
  AND cp.CreditLimit - cp.CurrentExposure > 100000
  AND cp.IsCreditBlocked = 0;
GO

-- ============================================================
-- 5. Goods Receipt Readiness
-- ============================================================

INSERT INTO #TestDataReadiness (
    CheckID,
    ScenarioCode,
    Requirement,
    ExpectedResult,
    ActualResult,
    ReadinessStatus
)
SELECT
    'TDR-013',
    'GOODS_RECEIPT_VARIANCE',
    'An open purchase order with a 1000-unit line must exist.',
    'PO-UAT-000001 with a 1000-unit PRD-010 line',
    CASE
        WHEN COUNT(*) = 0 THEN 'No matching purchase order'
        ELSE CONCAT(
            MAX(po.PurchaseOrderCode),
            ' / Status=',
            MAX(po.PurchaseOrderStatus),
            ' / Quantity=',
            MAX(pol.Quantity)
        )
    END,
    CASE
        WHEN COUNT(*) >= 1 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM dbo.PurchaseOrders AS po
INNER JOIN dbo.PurchaseOrderLines AS pol
    ON pol.PurchaseOrderID = po.PurchaseOrderID
INNER JOIN dbo.Products AS p
    ON p.ProductID = pol.ProductID
WHERE po.PurchaseOrderCode = 'PO-UAT-000001'
  AND p.ProductCode = 'PRD-010'
  AND pol.Quantity = 1000;
GO

INSERT INTO #TestDataReadiness (
    CheckID,
    ScenarioCode,
    Requirement,
    ExpectedResult,
    ActualResult,
    ReadinessStatus
)
SELECT
    'TDR-014',
    'GOODS_RECEIPT_BATCH',
    'A traceable product batch must exist for goods receipt testing.',
    'BATCH-GR-001 must exist for PRD-010',
    CASE
        WHEN COUNT(*) = 0 THEN 'No matching goods receipt batch'
        ELSE CONCAT(
            MAX(p.ProductCode),
            ' / ',
            MAX(b.BatchNumber),
            ' / ',
            MAX(b.QualityStatus)
        )
    END,
    CASE
        WHEN COUNT(*) >= 1 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM dbo.ProductBatches AS b
INNER JOIN dbo.Products AS p
    ON p.ProductID = b.ProductID
WHERE b.BatchNumber = 'BATCH-GR-001'
  AND p.ProductCode = 'PRD-010';
GO

-- ============================================================
-- 6. Controlled Missing Data Detection
-- ============================================================

INSERT INTO #TestDataReadiness (
    CheckID,
    ScenarioCode,
    Requirement,
    ExpectedResult,
    ActualResult,
    ReadinessStatus
)
SELECT
    'TDR-015',
    'MISSING_DATA_DETECTION',
    'The readiness control must detect a missing required batch.',
    'BATCH-MISSING-001 must be reported as missing',
    CASE
        WHEN COUNT(*) = 0
        THEN 'BATCH-MISSING-001 was not found'
        ELSE 'Unexpected batch found'
    END,
    CASE
        WHEN COUNT(*) = 0 THEN 'FAIL'
        ELSE 'PASS'
    END
FROM dbo.ProductBatches
WHERE BatchNumber = 'BATCH-MISSING-001';
GO

-- ============================================================
-- 7. Detailed Readiness Results
-- ============================================================

SELECT
    CheckID,
    ScenarioCode,
    Requirement,
    ExpectedResult,
    ActualResult,
    ReadinessStatus
FROM #TestDataReadiness
ORDER BY CheckID;
GO

-- ============================================================
-- 8. Readiness Summary
-- ============================================================

SELECT
    COUNT(*) AS TotalChecks,
    SUM(
        CASE
            WHEN ReadinessStatus = 'PASS' THEN 1
            ELSE 0
        END
    ) AS PassedChecks,
    SUM(
        CASE
            WHEN ReadinessStatus = 'FAIL' THEN 1
            ELSE 0
        END
    ) AS FailedChecks,
    CAST(
        100.0
        * SUM(
            CASE
                WHEN ReadinessStatus = 'PASS' THEN 1
                ELSE 0
            END
        )
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)
    ) AS ReadinessPercentage
FROM #TestDataReadiness;
GO

-- ============================================================
-- 9. Required Action List
-- ============================================================

SELECT
    CheckID,
    ScenarioCode,
    Requirement,
    ActualResult,
    CASE
        WHEN ScenarioCode = 'MISSING_DATA_DETECTION'
        THEN
            'Create or request the missing batch before executing the related UAT scenario.'
        ELSE
            'Review and correct the TEST/UAT prerequisite.'
    END AS RequiredAction
FROM #TestDataReadiness
WHERE ReadinessStatus = 'FAIL'
ORDER BY CheckID;
GO

DROP TABLE #TestDataReadiness;
GO