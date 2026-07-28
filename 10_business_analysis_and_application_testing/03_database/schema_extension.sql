-- ============================================================
-- Aurevia ERP Application Control and Testing Case
-- Database Schema Extension
-- Microsoft SQL Server
-- ============================================================

USE AureviaERPBI;
GO

SET XACT_ABORT ON;
GO

-- ============================================================
-- 1. Extend Existing Master and Transaction Tables
-- ============================================================

IF COL_LENGTH('dbo.Warehouses', 'IsSalesEligible') IS NULL
BEGIN
    ALTER TABLE dbo.Warehouses
    ADD IsSalesEligible BIT NOT NULL
        CONSTRAINT DF_Warehouses_IsSalesEligible DEFAULT 1;
END;
GO

IF COL_LENGTH('dbo.Products', 'IsBatchTracked') IS NULL
BEGIN
    ALTER TABLE dbo.Products
    ADD IsBatchTracked BIT NOT NULL
        CONSTRAINT DF_Products_IsBatchTracked DEFAULT 1;
END;
GO

IF COL_LENGTH('dbo.Customers', 'MinimumShelfLifeDays') IS NULL
BEGIN
    ALTER TABLE dbo.Customers
    ADD MinimumShelfLifeDays INT NOT NULL
        CONSTRAINT DF_Customers_MinimumShelfLifeDays DEFAULT 0;
END;
GO

IF COL_LENGTH('dbo.SalesOrders', 'CreatedByUserID') IS NULL
BEGIN
    ALTER TABLE dbo.SalesOrders
    ADD CreatedByUserID INT NULL;
END;
GO

IF COL_LENGTH('dbo.SalesOrders', 'ApprovedByUserID') IS NULL
BEGIN
    ALTER TABLE dbo.SalesOrders
    ADD ApprovedByUserID INT NULL;
END;
GO

IF COL_LENGTH('dbo.SalesOrders', 'FinanceApprovalStatus') IS NULL
BEGIN
    ALTER TABLE dbo.SalesOrders
    ADD FinanceApprovalStatus NVARCHAR(30) NOT NULL
        CONSTRAINT DF_SalesOrders_FinanceApprovalStatus
        DEFAULT 'NOT_REQUIRED';
END;
GO

IF COL_LENGTH('dbo.SalesOrders', 'CancellationDate') IS NULL
BEGIN
    ALTER TABLE dbo.SalesOrders
    ADD CancellationDate DATETIME2 NULL;
END;
GO

IF COL_LENGTH('dbo.SalesOrderLines', 'BatchID') IS NULL
BEGIN
    ALTER TABLE dbo.SalesOrderLines
    ADD BatchID INT NULL;
END;
GO

-- ============================================================
-- 2. Application Users
-- ============================================================

IF OBJECT_ID('dbo.ApplicationUsers', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ApplicationUsers (
        UserID INT IDENTITY(1,1) PRIMARY KEY,
        UserCode NVARCHAR(30) NOT NULL UNIQUE,
        FullName NVARCHAR(120) NOT NULL,
        Email NVARCHAR(150) NOT NULL UNIQUE,
        Department NVARCHAR(80) NOT NULL,

        IsActive BIT NOT NULL
            CONSTRAINT DF_ApplicationUsers_IsActive DEFAULT 1,

        CreatedAt DATETIME2 NOT NULL
            CONSTRAINT DF_ApplicationUsers_CreatedAt
            DEFAULT SYSUTCDATETIME()
    );
END;
GO

-- ============================================================
-- 3. Roles
-- ============================================================

IF OBJECT_ID('dbo.Roles', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Roles (
        RoleID INT IDENTITY(1,1) PRIMARY KEY,
        RoleCode NVARCHAR(40) NOT NULL UNIQUE,
        RoleName NVARCHAR(100) NOT NULL,
        Description NVARCHAR(250) NULL
    );
END;
GO

-- ============================================================
-- 4. User Roles
-- ============================================================

IF OBJECT_ID('dbo.UserRoles', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.UserRoles (
        UserRoleID INT IDENTITY(1,1) PRIMARY KEY,
        UserID INT NOT NULL,
        RoleID INT NOT NULL,

        AssignedAt DATETIME2 NOT NULL
            CONSTRAINT DF_UserRoles_AssignedAt
            DEFAULT SYSUTCDATETIME(),

        CONSTRAINT UQ_UserRoles_User_Role
            UNIQUE (UserID, RoleID),

        CONSTRAINT FK_UserRoles_Users
            FOREIGN KEY (UserID)
            REFERENCES dbo.ApplicationUsers(UserID),

        CONSTRAINT FK_UserRoles_Roles
            FOREIGN KEY (RoleID)
            REFERENCES dbo.Roles(RoleID)
    );
END;
GO

-- ============================================================
-- 5. Product Batches
-- ============================================================

IF OBJECT_ID('dbo.ProductBatches', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ProductBatches (
        BatchID INT IDENTITY(1,1) PRIMARY KEY,
        BatchNumber NVARCHAR(50) NOT NULL,
        ProductID INT NOT NULL,
        ProductionDate DATE NOT NULL,
        ExpirationDate DATE NOT NULL,
        QualityStatus NVARCHAR(30) NOT NULL,

        CreatedAt DATETIME2 NOT NULL
            CONSTRAINT DF_ProductBatches_CreatedAt
            DEFAULT SYSUTCDATETIME(),

        CONSTRAINT UQ_ProductBatches_Product_Batch
            UNIQUE (ProductID, BatchNumber),

        CONSTRAINT CK_ProductBatches_QualityStatus
            CHECK (
                QualityStatus IN (
                    'RELEASED',
                    'QUALITY_BLOCKED',
                    'REJECTED',
                    'EXPIRED'
                )
            ),

        CONSTRAINT CK_ProductBatches_Dates
            CHECK (ExpirationDate > ProductionDate),

        CONSTRAINT FK_ProductBatches_Products
            FOREIGN KEY (ProductID)
            REFERENCES dbo.Products(ProductID)
    );
END;
GO

-- ============================================================
-- 6. Inventory Balances
-- ============================================================

IF OBJECT_ID('dbo.InventoryBalances', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.InventoryBalances (
        InventoryBalanceID INT IDENTITY(1,1) PRIMARY KEY,
        ProductID INT NOT NULL,
        BatchID INT NOT NULL,
        WarehouseID INT NOT NULL,
        PhysicalQuantity DECIMAL(18,3) NOT NULL,

        ReservedQuantity DECIMAL(18,3) NOT NULL
            CONSTRAINT DF_InventoryBalances_ReservedQuantity
            DEFAULT 0,

        AvailableQuantity AS
            (PhysicalQuantity - ReservedQuantity) PERSISTED,

        LastUpdatedAt DATETIME2 NOT NULL
            CONSTRAINT DF_InventoryBalances_LastUpdatedAt
            DEFAULT SYSUTCDATETIME(),

        CONSTRAINT UQ_InventoryBalances_Product_Batch_Warehouse
            UNIQUE (ProductID, BatchID, WarehouseID),

        CONSTRAINT CK_InventoryBalances_PhysicalQuantity
            CHECK (PhysicalQuantity >= 0),

        CONSTRAINT CK_InventoryBalances_ReservedQuantity
            CHECK (
                ReservedQuantity >= 0
                AND ReservedQuantity <= PhysicalQuantity
            ),

        CONSTRAINT FK_InventoryBalances_Products
            FOREIGN KEY (ProductID)
            REFERENCES dbo.Products(ProductID),

        CONSTRAINT FK_InventoryBalances_Batches
            FOREIGN KEY (BatchID)
            REFERENCES dbo.ProductBatches(BatchID),

        CONSTRAINT FK_InventoryBalances_Warehouses
            FOREIGN KEY (WarehouseID)
            REFERENCES dbo.Warehouses(WarehouseID)
    );
END;
GO

-- ============================================================
-- 7. Customer Credit Profiles
-- ============================================================

IF OBJECT_ID('dbo.CustomerCreditProfiles', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.CustomerCreditProfiles (
        CustomerCreditProfileID INT IDENTITY(1,1) PRIMARY KEY,
        CustomerID INT NOT NULL UNIQUE,
        CreditLimit DECIMAL(18,2) NOT NULL,

        CurrentExposure DECIMAL(18,2) NOT NULL
            CONSTRAINT DF_CustomerCreditProfiles_CurrentExposure
            DEFAULT 0,

        IsCreditBlocked BIT NOT NULL
            CONSTRAINT DF_CustomerCreditProfiles_IsCreditBlocked
            DEFAULT 0,

        LastReviewedAt DATETIME2 NULL,

        CONSTRAINT CK_CustomerCreditProfiles_CreditLimit
            CHECK (CreditLimit >= 0),

        CONSTRAINT CK_CustomerCreditProfiles_CurrentExposure
            CHECK (CurrentExposure >= 0),

        CONSTRAINT FK_CustomerCreditProfiles_Customers
            FOREIGN KEY (CustomerID)
            REFERENCES dbo.Customers(CustomerID)
    );
END;
GO

-- ============================================================
-- 8. Sales Order Approvals
-- ============================================================

IF OBJECT_ID('dbo.SalesOrderApprovals', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SalesOrderApprovals (
        SalesOrderApprovalID INT IDENTITY(1,1) PRIMARY KEY,
        SalesOrderID INT NOT NULL,
        ApprovalType NVARCHAR(40) NOT NULL,
        ApprovalStatus NVARCHAR(30) NOT NULL,
        RequestedByUserID INT NOT NULL,
        DecisionByUserID INT NULL,

        RequestedAt DATETIME2 NOT NULL
            CONSTRAINT DF_SalesOrderApprovals_RequestedAt
            DEFAULT SYSUTCDATETIME(),

        DecisionAt DATETIME2 NULL,
        DecisionNote NVARCHAR(500) NULL,

        CONSTRAINT CK_SalesOrderApprovals_Type
            CHECK (
                ApprovalType IN (
                    'SALES_ORDER',
                    'CREDIT_EXCEPTION'
                )
            ),

        CONSTRAINT CK_SalesOrderApprovals_Status
            CHECK (
                ApprovalStatus IN (
                    'PENDING',
                    'APPROVED',
                    'REJECTED'
                )
            ),

        CONSTRAINT FK_SalesOrderApprovals_SalesOrders
            FOREIGN KEY (SalesOrderID)
            REFERENCES dbo.SalesOrders(SalesOrderID),

        CONSTRAINT FK_SalesOrderApprovals_RequestedBy
            FOREIGN KEY (RequestedByUserID)
            REFERENCES dbo.ApplicationUsers(UserID),

        CONSTRAINT FK_SalesOrderApprovals_DecisionBy
            FOREIGN KEY (DecisionByUserID)
            REFERENCES dbo.ApplicationUsers(UserID)
    );
END;
GO

-- ============================================================
-- 9. Stock Reservations
-- ============================================================

IF OBJECT_ID('dbo.StockReservations', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.StockReservations (
        ReservationID INT IDENTITY(1,1) PRIMARY KEY,
        SalesOrderID INT NOT NULL,
        SalesOrderLineID INT NOT NULL,
        ProductID INT NOT NULL,
        BatchID INT NOT NULL,
        WarehouseID INT NOT NULL,
        ReservedQuantity DECIMAL(18,3) NOT NULL,
        ReservationStatus NVARCHAR(20) NOT NULL,
        CreatedByUserID INT NOT NULL,

        CreatedAt DATETIME2 NOT NULL
            CONSTRAINT DF_StockReservations_CreatedAt
            DEFAULT SYSUTCDATETIME(),

        ReleasedAt DATETIME2 NULL,

        CONSTRAINT CK_StockReservations_Quantity
            CHECK (ReservedQuantity > 0),

        CONSTRAINT CK_StockReservations_Status
            CHECK (
                ReservationStatus IN (
                    'ACTIVE',
                    'RELEASED',
                    'CONSUMED'
                )
            ),

        CONSTRAINT FK_StockReservations_SalesOrders
            FOREIGN KEY (SalesOrderID)
            REFERENCES dbo.SalesOrders(SalesOrderID),

        CONSTRAINT FK_StockReservations_SalesOrderLines
            FOREIGN KEY (SalesOrderLineID)
            REFERENCES dbo.SalesOrderLines(SalesOrderLineID),

        CONSTRAINT FK_StockReservations_Products
            FOREIGN KEY (ProductID)
            REFERENCES dbo.Products(ProductID),

        CONSTRAINT FK_StockReservations_Batches
            FOREIGN KEY (BatchID)
            REFERENCES dbo.ProductBatches(BatchID),

        CONSTRAINT FK_StockReservations_Warehouses
            FOREIGN KEY (WarehouseID)
            REFERENCES dbo.Warehouses(WarehouseID),

        CONSTRAINT FK_StockReservations_CreatedBy
            FOREIGN KEY (CreatedByUserID)
            REFERENCES dbo.ApplicationUsers(UserID)
    );
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'UX_StockReservations_ActiveOrderLine'
      AND object_id = OBJECT_ID('dbo.StockReservations')
)
BEGIN
    CREATE UNIQUE INDEX UX_StockReservations_ActiveOrderLine
    ON dbo.StockReservations (SalesOrderLineID)
    WHERE ReservationStatus = 'ACTIVE';
END;
GO

-- ============================================================
-- 10. Goods Receipts
-- ============================================================

IF OBJECT_ID('dbo.GoodsReceipts', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.GoodsReceipts (
        GoodsReceiptID INT IDENTITY(1,1) PRIMARY KEY,
        GoodsReceiptCode NVARCHAR(30) NOT NULL UNIQUE,
        PurchaseOrderID INT NOT NULL,
        SupplierID INT NOT NULL,
        WarehouseID INT NOT NULL,
        ReceiptStatus NVARCHAR(30) NOT NULL,
        DeliveredAt DATETIME2 NOT NULL,
        CreatedByUserID INT NOT NULL,
        ApprovedByUserID INT NULL,
        CompletedAt DATETIME2 NULL,
        ReversedAt DATETIME2 NULL,

        CONSTRAINT CK_GoodsReceipts_Status
            CHECK (
                ReceiptStatus IN (
                    'DRAFT',
                    'PENDING_APPROVAL',
                    'COMPLETED',
                    'REJECTED',
                    'REVERSED'
                )
            ),

        CONSTRAINT FK_GoodsReceipts_PurchaseOrders
            FOREIGN KEY (PurchaseOrderID)
            REFERENCES dbo.PurchaseOrders(PurchaseOrderID),

        CONSTRAINT FK_GoodsReceipts_Suppliers
            FOREIGN KEY (SupplierID)
            REFERENCES dbo.Suppliers(SupplierID),

        CONSTRAINT FK_GoodsReceipts_Warehouses
            FOREIGN KEY (WarehouseID)
            REFERENCES dbo.Warehouses(WarehouseID),

        CONSTRAINT FK_GoodsReceipts_CreatedBy
            FOREIGN KEY (CreatedByUserID)
            REFERENCES dbo.ApplicationUsers(UserID),

        CONSTRAINT FK_GoodsReceipts_ApprovedBy
            FOREIGN KEY (ApprovedByUserID)
            REFERENCES dbo.ApplicationUsers(UserID)
    );
END;
GO

-- ============================================================
-- 11. Goods Receipt Lines
-- ============================================================

IF OBJECT_ID('dbo.GoodsReceiptLines', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.GoodsReceiptLines (
        GoodsReceiptLineID INT IDENTITY(1,1) PRIMARY KEY,
        GoodsReceiptID INT NOT NULL,
        PurchaseOrderLineID INT NOT NULL,
        ProductID INT NOT NULL,
        BatchID INT NULL,

        OrderedQuantity DECIMAL(18,3) NOT NULL,
        DeliveredQuantity DECIMAL(18,3) NOT NULL,
        AcceptedQuantity DECIMAL(18,3) NOT NULL,
        RejectedQuantity DECIMAL(18,3) NOT NULL,
        DamagedQuantity DECIMAL(18,3) NOT NULL,
        QualityBlockedQuantity DECIMAL(18,3) NOT NULL,

        VarianceQuantity AS
            (DeliveredQuantity - OrderedQuantity) PERSISTED,

        VariancePercentage AS (
            CASE
                WHEN OrderedQuantity = 0 THEN 0
                ELSE
                    (
                        (DeliveredQuantity - OrderedQuantity)
                        / OrderedQuantity
                    ) * 100
            END
        ) PERSISTED,

        VarianceReasonCode NVARCHAR(50) NULL,

        CONSTRAINT CK_GoodsReceiptLines_Quantities
            CHECK (
                OrderedQuantity > 0
                AND DeliveredQuantity >= 0
                AND AcceptedQuantity >= 0
                AND RejectedQuantity >= 0
                AND DamagedQuantity >= 0
                AND QualityBlockedQuantity >= 0
            ),

        CONSTRAINT CK_GoodsReceiptLines_Breakdown
            CHECK (
                DeliveredQuantity =
                    AcceptedQuantity
                    + RejectedQuantity
                    + DamagedQuantity
                    + QualityBlockedQuantity
            ),

        CONSTRAINT FK_GoodsReceiptLines_GoodsReceipts
            FOREIGN KEY (GoodsReceiptID)
            REFERENCES dbo.GoodsReceipts(GoodsReceiptID),

        CONSTRAINT FK_GoodsReceiptLines_PurchaseOrderLines
            FOREIGN KEY (PurchaseOrderLineID)
            REFERENCES dbo.PurchaseOrderLines(PurchaseOrderLineID),

        CONSTRAINT FK_GoodsReceiptLines_Products
            FOREIGN KEY (ProductID)
            REFERENCES dbo.Products(ProductID),

        CONSTRAINT FK_GoodsReceiptLines_Batches
            FOREIGN KEY (BatchID)
            REFERENCES dbo.ProductBatches(BatchID)
    );
END;
GO

-- ============================================================
-- 12. Goods Receipt Approvals
-- ============================================================

IF OBJECT_ID('dbo.GoodsReceiptApprovals', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.GoodsReceiptApprovals (
        GoodsReceiptApprovalID INT IDENTITY(1,1) PRIMARY KEY,
        GoodsReceiptID INT NOT NULL,
        ApprovalType NVARCHAR(40) NOT NULL,
        ApprovalStatus NVARCHAR(30) NOT NULL,
        RequestedByUserID INT NOT NULL,
        DecisionByUserID INT NULL,

        RequestedAt DATETIME2 NOT NULL
            CONSTRAINT DF_GoodsReceiptApprovals_RequestedAt
            DEFAULT SYSUTCDATETIME(),

        DecisionAt DATETIME2 NULL,
        DecisionNote NVARCHAR(500) NULL,

        CONSTRAINT CK_GoodsReceiptApprovals_Type
            CHECK (
                ApprovalType IN (
                    'QUANTITY_VARIANCE',
                    'OPEN_QUANTITY_EXCEPTION'
                )
            ),

        CONSTRAINT CK_GoodsReceiptApprovals_Status
            CHECK (
                ApprovalStatus IN (
                    'PENDING',
                    'APPROVED',
                    'REJECTED'
                )
            ),

        CONSTRAINT FK_GoodsReceiptApprovals_GoodsReceipts
            FOREIGN KEY (GoodsReceiptID)
            REFERENCES dbo.GoodsReceipts(GoodsReceiptID),

        CONSTRAINT FK_GoodsReceiptApprovals_RequestedBy
            FOREIGN KEY (RequestedByUserID)
            REFERENCES dbo.ApplicationUsers(UserID),

        CONSTRAINT FK_GoodsReceiptApprovals_DecisionBy
            FOREIGN KEY (DecisionByUserID)
            REFERENCES dbo.ApplicationUsers(UserID)
    );
END;
GO

-- ============================================================
-- 13. Goods Receipt Inventory Movements
-- ============================================================

IF OBJECT_ID('dbo.GoodsReceiptInventoryMovements', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.GoodsReceiptInventoryMovements (
        ReceiptMovementID INT IDENTITY(1,1) PRIMARY KEY,
        GoodsReceiptLineID INT NOT NULL,
        ProductID INT NOT NULL,
        BatchID INT NULL,
        WarehouseID INT NOT NULL,
        MovementType NVARCHAR(30) NOT NULL,
        Quantity DECIMAL(18,3) NOT NULL,

        CreatedAt DATETIME2 NOT NULL
            CONSTRAINT DF_GoodsReceiptInventoryMovements_CreatedAt
            DEFAULT SYSUTCDATETIME(),

        CONSTRAINT CK_GoodsReceiptInventoryMovements_Type
            CHECK (
                MovementType IN (
                    'AVAILABLE_IN',
                    'QUALITY_BLOCK_IN',
                    'REJECTED_OUT',
                    'DAMAGED_OUT',
                    'REVERSAL'
                )
            ),

        CONSTRAINT CK_GoodsReceiptInventoryMovements_Quantity
            CHECK (Quantity > 0),

        CONSTRAINT FK_GoodsReceiptInventoryMovements_Lines
            FOREIGN KEY (GoodsReceiptLineID)
            REFERENCES dbo.GoodsReceiptLines(GoodsReceiptLineID),

        CONSTRAINT FK_GoodsReceiptInventoryMovements_Products
            FOREIGN KEY (ProductID)
            REFERENCES dbo.Products(ProductID),

        CONSTRAINT FK_GoodsReceiptInventoryMovements_Batches
            FOREIGN KEY (BatchID)
            REFERENCES dbo.ProductBatches(BatchID),

        CONSTRAINT FK_GoodsReceiptInventoryMovements_Warehouses
            FOREIGN KEY (WarehouseID)
            REFERENCES dbo.Warehouses(WarehouseID)
    );
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'UX_GoodsReceiptMovement_Line_Type'
      AND object_id =
          OBJECT_ID('dbo.GoodsReceiptInventoryMovements')
)
BEGIN
    CREATE UNIQUE INDEX UX_GoodsReceiptMovement_Line_Type
    ON dbo.GoodsReceiptInventoryMovements (
        GoodsReceiptLineID,
        MovementType
    );
END;
GO

-- ============================================================
-- 14. Supplier Performance
-- ============================================================

IF OBJECT_ID('dbo.SupplierPerformance', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SupplierPerformance (
        SupplierPerformanceID INT IDENTITY(1,1) PRIMARY KEY,
        SupplierID INT NOT NULL,
        GoodsReceiptID INT NOT NULL,
        OrderedQuantity DECIMAL(18,3) NOT NULL,
        DeliveredQuantity DECIMAL(18,3) NOT NULL,
        AcceptedQuantity DECIMAL(18,3) NOT NULL,
        RejectedQuantity DECIMAL(18,3) NOT NULL,
        DeliveryVariancePercentage DECIMAL(9,4) NOT NULL,
        AcceptanceRatePercentage DECIMAL(9,4) NOT NULL,

        CalculatedAt DATETIME2 NOT NULL
            CONSTRAINT DF_SupplierPerformance_CalculatedAt
            DEFAULT SYSUTCDATETIME(),

        CONSTRAINT UQ_SupplierPerformance_Receipt
            UNIQUE (GoodsReceiptID),

        CONSTRAINT FK_SupplierPerformance_Suppliers
            FOREIGN KEY (SupplierID)
            REFERENCES dbo.Suppliers(SupplierID),

        CONSTRAINT FK_SupplierPerformance_GoodsReceipts
            FOREIGN KEY (GoodsReceiptID)
            REFERENCES dbo.GoodsReceipts(GoodsReceiptID)
    );
END;
GO

-- ============================================================
-- 15. Audit Logs
-- ============================================================

IF OBJECT_ID('dbo.AuditLogs', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.AuditLogs (
        AuditLogID BIGINT IDENTITY(1,1) PRIMARY KEY,
        UserID INT NULL,
        EntityType NVARCHAR(50) NOT NULL,
        EntityID INT NOT NULL,
        ActionType NVARCHAR(50) NOT NULL,
        OldValue NVARCHAR(MAX) NULL,
        NewValue NVARCHAR(MAX) NULL,

        CorrelationID UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT DF_AuditLogs_CorrelationID
            DEFAULT NEWID(),

        CreatedAt DATETIME2 NOT NULL
            CONSTRAINT DF_AuditLogs_CreatedAt
            DEFAULT SYSUTCDATETIME(),

        CONSTRAINT FK_AuditLogs_Users
            FOREIGN KEY (UserID)
            REFERENCES dbo.ApplicationUsers(UserID)
    );
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_AuditLogs_Entity'
      AND object_id = OBJECT_ID('dbo.AuditLogs')
)
BEGIN
    CREATE INDEX IX_AuditLogs_Entity
    ON dbo.AuditLogs (
        EntityType,
        EntityID,
        CreatedAt
    );
END;
GO

-- ============================================================
-- 16. Add Foreign Keys to Existing Tables
-- ============================================================

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_SalesOrders_CreatedByUser'
)
BEGIN
    ALTER TABLE dbo.SalesOrders
    ADD CONSTRAINT FK_SalesOrders_CreatedByUser
        FOREIGN KEY (CreatedByUserID)
        REFERENCES dbo.ApplicationUsers(UserID);
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_SalesOrders_ApprovedByUser'
)
BEGIN
    ALTER TABLE dbo.SalesOrders
    ADD CONSTRAINT FK_SalesOrders_ApprovedByUser
        FOREIGN KEY (ApprovedByUserID)
        REFERENCES dbo.ApplicationUsers(UserID);
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_SalesOrderLines_Batches'
)
BEGIN
    ALTER TABLE dbo.SalesOrderLines
    ADD CONSTRAINT FK_SalesOrderLines_Batches
        FOREIGN KEY (BatchID)
        REFERENCES dbo.ProductBatches(BatchID);
END;
GO

-- ============================================================
-- 17. Supporting Indexes
-- ============================================================

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_ProductBatches_Product_Status_Expiration'
      AND object_id = OBJECT_ID('dbo.ProductBatches')
)
BEGIN
    CREATE INDEX IX_ProductBatches_Product_Status_Expiration
    ON dbo.ProductBatches (
        ProductID,
        QualityStatus,
        ExpirationDate
    );
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_InventoryBalances_Availability'
      AND object_id = OBJECT_ID('dbo.InventoryBalances')
)
BEGIN
    CREATE INDEX IX_InventoryBalances_Availability
    ON dbo.InventoryBalances (
        ProductID,
        WarehouseID,
        BatchID
    )
    INCLUDE (
        PhysicalQuantity,
        ReservedQuantity,
        AvailableQuantity
    );
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_StockReservations_Order_Status'
      AND object_id = OBJECT_ID('dbo.StockReservations')
)
BEGIN
    CREATE INDEX IX_StockReservations_Order_Status
    ON dbo.StockReservations (
        SalesOrderID,
        ReservationStatus
    );
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_GoodsReceipts_PO_Status'
      AND object_id = OBJECT_ID('dbo.GoodsReceipts')
)
BEGIN
    CREATE INDEX IX_GoodsReceipts_PO_Status
    ON dbo.GoodsReceipts (
        PurchaseOrderID,
        ReceiptStatus
    );
END;
GO

-- ============================================================
-- 18. Schema Verification
-- ============================================================

SELECT
    t.name AS TableName,
    COUNT(c.column_id) AS ColumnCount
FROM sys.tables AS t
INNER JOIN sys.columns AS c
    ON c.object_id = t.object_id
WHERE t.name IN (
    'ApplicationUsers',
    'Roles',
    'UserRoles',
    'ProductBatches',
    'InventoryBalances',
    'CustomerCreditProfiles',
    'SalesOrderApprovals',
    'StockReservations',
    'GoodsReceipts',
    'GoodsReceiptLines',
    'GoodsReceiptApprovals',
    'GoodsReceiptInventoryMovements',
    'SupplierPerformance',
    'AuditLogs'
)
GROUP BY t.name
ORDER BY t.name;
GO