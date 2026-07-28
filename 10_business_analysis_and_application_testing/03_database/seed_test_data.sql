-- ============================================================
-- Aurevia ERP Application Control and Testing Case
-- Controlled TEST / UAT Data Seed
-- Microsoft SQL Server
-- ============================================================

USE AureviaERPBI;
GO

SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;
GO

-- ============================================================
-- 1. Resolve Existing Master Data
-- ============================================================

DECLARE @ProductID INT;
DECLARE @SecondaryProductID INT;
DECLARE @CustomerID INT;
DECLARE @SecondaryCustomerID INT;
DECLARE @SupplierID INT;
DECLARE @WarehouseID INT;
DECLARE @IneligibleWarehouseID INT;

SELECT @ProductID = ProductID
FROM dbo.Products
WHERE ProductCode = 'PRD-001';

SELECT @SecondaryProductID = ProductID
FROM dbo.Products
WHERE ProductCode = 'PRD-010';

SELECT @CustomerID = CustomerID
FROM dbo.Customers
WHERE CustomerCode = 'CUST-001';

SELECT @SecondaryCustomerID = CustomerID
FROM dbo.Customers
WHERE CustomerCode = 'CUST-002';

SELECT @SupplierID = SupplierID
FROM dbo.Suppliers
WHERE SupplierCode = 'SUP-001';

SELECT @WarehouseID = WarehouseID
FROM dbo.Warehouses
WHERE WarehouseCode = 'WH-001';

SELECT @IneligibleWarehouseID = WarehouseID
FROM dbo.Warehouses
WHERE WarehouseCode = 'WH-003';

IF @ProductID IS NULL
    THROW 50001, 'Required product PRD-001 was not found.', 1;

IF @SecondaryProductID IS NULL
    THROW 50002, 'Required product PRD-010 was not found.', 1;

IF @CustomerID IS NULL
    THROW 50003, 'Required customer CUST-001 was not found.', 1;

IF @SecondaryCustomerID IS NULL
    THROW 50004, 'Required customer CUST-002 was not found.', 1;

IF @SupplierID IS NULL
    THROW 50005, 'Required supplier SUP-001 was not found.', 1;

IF @WarehouseID IS NULL
    THROW 50006, 'Required warehouse WH-001 was not found.', 1;

IF @IneligibleWarehouseID IS NULL
    THROW 50007, 'Required warehouse WH-003 was not found.', 1;
GO

-- ============================================================
-- 2. Configure Existing Master Data for Test Scenarios
-- ============================================================

UPDATE dbo.Warehouses
SET IsSalesEligible = 1
WHERE WarehouseCode IN ('WH-001', 'WH-002');

UPDATE dbo.Warehouses
SET IsSalesEligible = 0
WHERE WarehouseCode = 'WH-003';

UPDATE dbo.Products
SET IsBatchTracked = 1
WHERE ProductCode IN ('PRD-001', 'PRD-010');

UPDATE dbo.Customers
SET MinimumShelfLifeDays = 20
WHERE CustomerCode = 'CUST-001';

UPDATE dbo.Customers
SET MinimumShelfLifeDays = 10
WHERE CustomerCode = 'CUST-002';
GO

-- ============================================================
-- 3. Application Users
-- ============================================================

IF NOT EXISTS (
    SELECT 1
    FROM dbo.ApplicationUsers
    WHERE UserCode = 'USR-SALES-01'
)
BEGIN
    INSERT INTO dbo.ApplicationUsers (
        UserCode,
        FullName,
        Email,
        Department
    )
    VALUES (
        'USR-SALES-01',
        'Elif Kaya',
        'elif.kaya@aurevia-demo.local',
        'Sales Operations'
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.ApplicationUsers
    WHERE UserCode = 'USR-SALESMGR-01'
)
BEGIN
    INSERT INTO dbo.ApplicationUsers (
        UserCode,
        FullName,
        Email,
        Department
    )
    VALUES (
        'USR-SALESMGR-01',
        'Mert Demir',
        'mert.demir@aurevia-demo.local',
        'Sales Management'
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.ApplicationUsers
    WHERE UserCode = 'USR-FIN-01'
)
BEGIN
    INSERT INTO dbo.ApplicationUsers (
        UserCode,
        FullName,
        Email,
        Department
    )
    VALUES (
        'USR-FIN-01',
        'Selin Arslan',
        'selin.arslan@aurevia-demo.local',
        'Finance'
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.ApplicationUsers
    WHERE UserCode = 'USR-QUALITY-01'
)
BEGIN
    INSERT INTO dbo.ApplicationUsers (
        UserCode,
        FullName,
        Email,
        Department
    )
    VALUES (
        'USR-QUALITY-01',
        'Bora Yılmaz',
        'bora.yilmaz@aurevia-demo.local',
        'Quality Control'
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.ApplicationUsers
    WHERE UserCode = 'USR-WH-01'
)
BEGIN
    INSERT INTO dbo.ApplicationUsers (
        UserCode,
        FullName,
        Email,
        Department
    )
    VALUES (
        'USR-WH-01',
        'Derya Şahin',
        'derya.sahin@aurevia-demo.local',
        'Warehouse Operations'
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.ApplicationUsers
    WHERE UserCode = 'USR-WHMGR-01'
)
BEGIN
    INSERT INTO dbo.ApplicationUsers (
        UserCode,
        FullName,
        Email,
        Department
    )
    VALUES (
        'USR-WHMGR-01',
        'Onur Çelik',
        'onur.celik@aurevia-demo.local',
        'Warehouse Management'
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.ApplicationUsers
    WHERE UserCode = 'USR-PURCH-01'
)
BEGIN
    INSERT INTO dbo.ApplicationUsers (
        UserCode,
        FullName,
        Email,
        Department
    )
    VALUES (
        'USR-PURCH-01',
        'Ece Koç',
        'ece.koc@aurevia-demo.local',
        'Purchasing'
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.ApplicationUsers
    WHERE UserCode = 'USR-ADMIN-01'
)
BEGIN
    INSERT INTO dbo.ApplicationUsers (
        UserCode,
        FullName,
        Email,
        Department
    )
    VALUES (
        'USR-ADMIN-01',
        'Aurevia Test Admin',
        'admin@aurevia-demo.local',
        'Business Applications'
    );
END;
GO

-- ============================================================
-- 4. Roles
-- ============================================================

IF NOT EXISTS (
    SELECT 1
    FROM dbo.Roles
    WHERE RoleCode = 'SALES_USER'
)
BEGIN
    INSERT INTO dbo.Roles (
        RoleCode,
        RoleName,
        Description
    )
    VALUES (
        'SALES_USER',
        'Sales User',
        'Creates and edits sales orders.'
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.Roles
    WHERE RoleCode = 'SALES_MANAGER'
)
BEGIN
    INSERT INTO dbo.Roles (
        RoleCode,
        RoleName,
        Description
    )
    VALUES (
        'SALES_MANAGER',
        'Sales Manager',
        'Approves standard sales orders.'
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.Roles
    WHERE RoleCode = 'FINANCE_USER'
)
BEGIN
    INSERT INTO dbo.Roles (
        RoleCode,
        RoleName,
        Description
    )
    VALUES (
        'FINANCE_USER',
        'Finance User',
        'Approves customer credit exceptions.'
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.Roles
    WHERE RoleCode = 'QUALITY_USER'
)
BEGIN
    INSERT INTO dbo.Roles (
        RoleCode,
        RoleName,
        Description
    )
    VALUES (
        'QUALITY_USER',
        'Quality User',
        'Manages batch quality status.'
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.Roles
    WHERE RoleCode = 'WAREHOUSE_USER'
)
BEGIN
    INSERT INTO dbo.Roles (
        RoleCode,
        RoleName,
        Description
    )
    VALUES (
        'WAREHOUSE_USER',
        'Warehouse User',
        'Records warehouse transactions.'
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.Roles
    WHERE RoleCode = 'WAREHOUSE_MANAGER'
)
BEGIN
    INSERT INTO dbo.Roles (
        RoleCode,
        RoleName,
        Description
    )
    VALUES (
        'WAREHOUSE_MANAGER',
        'Warehouse Manager',
        'Approves warehouse exceptions and reversals.'
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.Roles
    WHERE RoleCode = 'PURCHASING_USER'
)
BEGIN
    INSERT INTO dbo.Roles (
        RoleCode,
        RoleName,
        Description
    )
    VALUES (
        'PURCHASING_USER',
        'Purchasing User',
        'Manages purchase orders and supplier processes.'
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.Roles
    WHERE RoleCode = 'ADMIN'
)
BEGIN
    INSERT INTO dbo.Roles (
        RoleCode,
        RoleName,
        Description
    )
    VALUES (
        'ADMIN',
        'System Administrator',
        'Full access for application testing.'
    );
END;
GO

-- ============================================================
-- 5. Assign User Roles
-- ============================================================

INSERT INTO dbo.UserRoles (
    UserID,
    RoleID
)
SELECT
    u.UserID,
    r.RoleID
FROM dbo.ApplicationUsers AS u
INNER JOIN dbo.Roles AS r
    ON (
        u.UserCode = 'USR-SALES-01'
        AND r.RoleCode = 'SALES_USER'
    )
    OR (
        u.UserCode = 'USR-SALESMGR-01'
        AND r.RoleCode = 'SALES_MANAGER'
    )
    OR (
        u.UserCode = 'USR-FIN-01'
        AND r.RoleCode = 'FINANCE_USER'
    )
    OR (
        u.UserCode = 'USR-QUALITY-01'
        AND r.RoleCode = 'QUALITY_USER'
    )
    OR (
        u.UserCode = 'USR-WH-01'
        AND r.RoleCode = 'WAREHOUSE_USER'
    )
    OR (
        u.UserCode = 'USR-WHMGR-01'
        AND r.RoleCode = 'WAREHOUSE_MANAGER'
    )
    OR (
        u.UserCode = 'USR-PURCH-01'
        AND r.RoleCode = 'PURCHASING_USER'
    )
    OR (
        u.UserCode = 'USR-ADMIN-01'
        AND r.RoleCode = 'ADMIN'
    )
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.UserRoles AS ur
    WHERE ur.UserID = u.UserID
      AND ur.RoleID = r.RoleID
);
GO

-- ============================================================
-- 6. Product Batch Test Data
-- ============================================================

DECLARE @ProductID INT;
DECLARE @SecondaryProductID INT;

SELECT @ProductID = ProductID
FROM dbo.Products
WHERE ProductCode = 'PRD-001';

SELECT @SecondaryProductID = ProductID
FROM dbo.Products
WHERE ProductCode = 'PRD-010';

IF NOT EXISTS (
    SELECT 1
    FROM dbo.ProductBatches
    WHERE ProductID = @ProductID
      AND BatchNumber = 'BATCH-REL-001'
)
BEGIN
    INSERT INTO dbo.ProductBatches (
        BatchNumber,
        ProductID,
        ProductionDate,
        ExpirationDate,
        QualityStatus
    )
    VALUES (
        'BATCH-REL-001',
        @ProductID,
        DATEADD(DAY, -10, CAST(GETDATE() AS DATE)),
        DATEADD(DAY, 60, CAST(GETDATE() AS DATE)),
        'RELEASED'
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.ProductBatches
    WHERE ProductID = @ProductID
      AND BatchNumber = 'BATCH-BLOCK-001'
)
BEGIN
    INSERT INTO dbo.ProductBatches (
        BatchNumber,
        ProductID,
        ProductionDate,
        ExpirationDate,
        QualityStatus
    )
    VALUES (
        'BATCH-BLOCK-001',
        @ProductID,
        DATEADD(DAY, -8, CAST(GETDATE() AS DATE)),
        DATEADD(DAY, 50, CAST(GETDATE() AS DATE)),
        'QUALITY_BLOCKED'
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.ProductBatches
    WHERE ProductID = @ProductID
      AND BatchNumber = 'BATCH-SHORT-001'
)
BEGIN
    INSERT INTO dbo.ProductBatches (
        BatchNumber,
        ProductID,
        ProductionDate,
        ExpirationDate,
        QualityStatus
    )
    VALUES (
        'BATCH-SHORT-001',
        @ProductID,
        DATEADD(DAY, -20, CAST(GETDATE() AS DATE)),
        DATEADD(DAY, 12, CAST(GETDATE() AS DATE)),
        'RELEASED'
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.ProductBatches
    WHERE ProductID = @ProductID
      AND BatchNumber = 'BATCH-REJ-001'
)
BEGIN
    INSERT INTO dbo.ProductBatches (
        BatchNumber,
        ProductID,
        ProductionDate,
        ExpirationDate,
        QualityStatus
    )
    VALUES (
        'BATCH-REJ-001',
        @ProductID,
        DATEADD(DAY, -15, CAST(GETDATE() AS DATE)),
        DATEADD(DAY, 45, CAST(GETDATE() AS DATE)),
        'REJECTED'
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.ProductBatches
    WHERE ProductID = @SecondaryProductID
      AND BatchNumber = 'BATCH-GR-001'
)
BEGIN
    INSERT INTO dbo.ProductBatches (
        BatchNumber,
        ProductID,
        ProductionDate,
        ExpirationDate,
        QualityStatus
    )
    VALUES (
        'BATCH-GR-001',
        @SecondaryProductID,
        CAST(GETDATE() AS DATE),
        DATEADD(DAY, 180, CAST(GETDATE() AS DATE)),
        'RELEASED'
    );
END;
GO

-- ============================================================
-- 7. Inventory Balance Test Data
-- ============================================================

DECLARE @ProductID INT;
DECLARE @WarehouseID INT;
DECLARE @IneligibleWarehouseID INT;
DECLARE @ReleasedBatchID INT;
DECLARE @BlockedBatchID INT;
DECLARE @ShortBatchID INT;
DECLARE @RejectedBatchID INT;

SELECT @ProductID = ProductID
FROM dbo.Products
WHERE ProductCode = 'PRD-001';

SELECT @WarehouseID = WarehouseID
FROM dbo.Warehouses
WHERE WarehouseCode = 'WH-001';

SELECT @IneligibleWarehouseID = WarehouseID
FROM dbo.Warehouses
WHERE WarehouseCode = 'WH-003';

SELECT @ReleasedBatchID = BatchID
FROM dbo.ProductBatches
WHERE ProductID = @ProductID
  AND BatchNumber = 'BATCH-REL-001';

SELECT @BlockedBatchID = BatchID
FROM dbo.ProductBatches
WHERE ProductID = @ProductID
  AND BatchNumber = 'BATCH-BLOCK-001';

SELECT @ShortBatchID = BatchID
FROM dbo.ProductBatches
WHERE ProductID = @ProductID
  AND BatchNumber = 'BATCH-SHORT-001';

SELECT @RejectedBatchID = BatchID
FROM dbo.ProductBatches
WHERE ProductID = @ProductID
  AND BatchNumber = 'BATCH-REJ-001';

IF NOT EXISTS (
    SELECT 1
    FROM dbo.InventoryBalances
    WHERE ProductID = @ProductID
      AND BatchID = @ReleasedBatchID
      AND WarehouseID = @WarehouseID
)
BEGIN
    INSERT INTO dbo.InventoryBalances (
        ProductID,
        BatchID,
        WarehouseID,
        PhysicalQuantity,
        ReservedQuantity
    )
    VALUES (
        @ProductID,
        @ReleasedBatchID,
        @WarehouseID,
        500,
        200
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.InventoryBalances
    WHERE ProductID = @ProductID
      AND BatchID = @BlockedBatchID
      AND WarehouseID = @WarehouseID
)
BEGIN
    INSERT INTO dbo.InventoryBalances (
        ProductID,
        BatchID,
        WarehouseID,
        PhysicalQuantity,
        ReservedQuantity
    )
    VALUES (
        @ProductID,
        @BlockedBatchID,
        @WarehouseID,
        500,
        0
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.InventoryBalances
    WHERE ProductID = @ProductID
      AND BatchID = @ShortBatchID
      AND WarehouseID = @WarehouseID
)
BEGIN
    INSERT INTO dbo.InventoryBalances (
        ProductID,
        BatchID,
        WarehouseID,
        PhysicalQuantity,
        ReservedQuantity
    )
    VALUES (
        @ProductID,
        @ShortBatchID,
        @WarehouseID,
        400,
        0
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.InventoryBalances
    WHERE ProductID = @ProductID
      AND BatchID = @RejectedBatchID
      AND WarehouseID = @WarehouseID
)
BEGIN
    INSERT INTO dbo.InventoryBalances (
        ProductID,
        BatchID,
        WarehouseID,
        PhysicalQuantity,
        ReservedQuantity
    )
    VALUES (
        @ProductID,
        @RejectedBatchID,
        @WarehouseID,
        300,
        0
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.InventoryBalances
    WHERE ProductID = @ProductID
      AND BatchID = @ReleasedBatchID
      AND WarehouseID = @IneligibleWarehouseID
)
BEGIN
    INSERT INTO dbo.InventoryBalances (
        ProductID,
        BatchID,
        WarehouseID,
        PhysicalQuantity,
        ReservedQuantity
    )
    VALUES (
        @ProductID,
        @ReleasedBatchID,
        @IneligibleWarehouseID,
        250,
        0
    );
END;
GO

-- ============================================================
-- 8. Customer Credit Test Data
-- ============================================================

DECLARE @CustomerID INT;
DECLARE @SecondaryCustomerID INT;

SELECT @CustomerID = CustomerID
FROM dbo.Customers
WHERE CustomerCode = 'CUST-001';

SELECT @SecondaryCustomerID = CustomerID
FROM dbo.Customers
WHERE CustomerCode = 'CUST-002';

IF NOT EXISTS (
    SELECT 1
    FROM dbo.CustomerCreditProfiles
    WHERE CustomerID = @CustomerID
)
BEGIN
    INSERT INTO dbo.CustomerCreditProfiles (
        CustomerID,
        CreditLimit,
        CurrentExposure,
        IsCreditBlocked,
        LastReviewedAt
    )
    VALUES (
        @CustomerID,
        100000,
        85000,
        0,
        SYSUTCDATETIME()
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.CustomerCreditProfiles
    WHERE CustomerID = @SecondaryCustomerID
)
BEGIN
    INSERT INTO dbo.CustomerCreditProfiles (
        CustomerID,
        CreditLimit,
        CurrentExposure,
        IsCreditBlocked,
        LastReviewedAt
    )
    VALUES (
        @SecondaryCustomerID,
        250000,
        50000,
        0,
        SYSUTCDATETIME()
    );
END;
GO

-- ============================================================
-- 9. Purchase Order for Goods Receipt Test
-- ============================================================

DECLARE @SupplierID INT;
DECLARE @WarehouseID INT;
DECLARE @SecondaryProductID INT;
DECLARE @PurchaseOrderID INT;

SELECT @SupplierID = SupplierID
FROM dbo.Suppliers
WHERE SupplierCode = 'SUP-001';

SELECT @WarehouseID = WarehouseID
FROM dbo.Warehouses
WHERE WarehouseCode = 'WH-001';

SELECT @SecondaryProductID = ProductID
FROM dbo.Products
WHERE ProductCode = 'PRD-010';

IF NOT EXISTS (
    SELECT 1
    FROM dbo.PurchaseOrders
    WHERE PurchaseOrderCode = 'PO-UAT-000001'
)
BEGIN
    INSERT INTO dbo.PurchaseOrders (
        PurchaseOrderCode,
        SupplierID,
        OrderDate,
        ExpectedDeliveryDate,
        ActualDeliveryDate,
        PurchaseOrderStatus,
        WarehouseID
    )
    VALUES (
        'PO-UAT-000001',
        @SupplierID,
        DATEADD(DAY, -7, CAST(GETDATE() AS DATE)),
        CAST(GETDATE() AS DATE),
        CAST(GETDATE() AS DATE),
        'Open',
        @WarehouseID
    );
END;

SELECT @PurchaseOrderID = PurchaseOrderID
FROM dbo.PurchaseOrders
WHERE PurchaseOrderCode = 'PO-UAT-000001';

IF NOT EXISTS (
    SELECT 1
    FROM dbo.PurchaseOrderLines
    WHERE PurchaseOrderID = @PurchaseOrderID
      AND ProductID = @SecondaryProductID
)
BEGIN
    INSERT INTO dbo.PurchaseOrderLines (
        PurchaseOrderID,
        ProductID,
        Quantity,
        UnitCost
    )
    SELECT
        @PurchaseOrderID,
        @SecondaryProductID,
        1000,
        UnitCost
    FROM dbo.Products
    WHERE ProductID = @SecondaryProductID;
END;
GO

-- ============================================================
-- 10. Seed Verification
-- ============================================================

SELECT
    u.UserCode,
    u.FullName,
    r.RoleCode
FROM dbo.ApplicationUsers AS u
INNER JOIN dbo.UserRoles AS ur
    ON ur.UserID = u.UserID
INNER JOIN dbo.Roles AS r
    ON r.RoleID = ur.RoleID
WHERE u.UserCode LIKE 'USR-%'
ORDER BY u.UserCode;
GO

SELECT
    p.ProductCode,
    b.BatchNumber,
    b.QualityStatus,
    b.ExpirationDate,
    w.WarehouseCode,
    w.IsSalesEligible,
    i.PhysicalQuantity,
    i.ReservedQuantity,
    i.AvailableQuantity
FROM dbo.InventoryBalances AS i
INNER JOIN dbo.Products AS p
    ON p.ProductID = i.ProductID
INNER JOIN dbo.ProductBatches AS b
    ON b.BatchID = i.BatchID
INNER JOIN dbo.Warehouses AS w
    ON w.WarehouseID = i.WarehouseID
WHERE b.BatchNumber LIKE 'BATCH-%'
ORDER BY b.BatchNumber, w.WarehouseCode;
GO

SELECT
    c.CustomerCode,
    c.CustomerName,
    c.MinimumShelfLifeDays,
    cp.CreditLimit,
    cp.CurrentExposure,
    cp.CreditLimit - cp.CurrentExposure
        AS RemainingCreditLimit
FROM dbo.CustomerCreditProfiles AS cp
INNER JOIN dbo.Customers AS c
    ON c.CustomerID = cp.CustomerID
WHERE c.CustomerCode IN ('CUST-001', 'CUST-002')
ORDER BY c.CustomerCode;
GO

SELECT
    po.PurchaseOrderCode,
    s.SupplierCode,
    p.ProductCode,
    pol.Quantity AS OrderedQuantity,
    po.PurchaseOrderStatus,
    w.WarehouseCode
FROM dbo.PurchaseOrders AS po
INNER JOIN dbo.PurchaseOrderLines AS pol
    ON pol.PurchaseOrderID = po.PurchaseOrderID
INNER JOIN dbo.Suppliers AS s
    ON s.SupplierID = po.SupplierID
INNER JOIN dbo.Products AS p
    ON p.ProductID = pol.ProductID
INNER JOIN dbo.Warehouses AS w
    ON w.WarehouseID = po.WarehouseID
WHERE po.PurchaseOrderCode = 'PO-UAT-000001';
GO

COMMIT TRANSACTION;
GO