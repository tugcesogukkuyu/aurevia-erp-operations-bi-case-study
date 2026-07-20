-- =====================================================
-- Aurevia ERP Operations & BI Dashboard Case Study
-- Synthetic ERP Data Seed Script
-- Database: AureviaERPBI
-- =====================================================

USE AureviaERPBI;
GO

-- =====================================================
-- 0. Clear existing data
-- =====================================================

DELETE FROM Payments;
DELETE FROM Invoices;
DELETE FROM StockMovements;
DELETE FROM SalesOrderLines;
DELETE FROM SalesOrders;
DELETE FROM PurchaseOrderLines;
DELETE FROM PurchaseOrders;
DELETE FROM Products;
DELETE FROM Suppliers;
DELETE FROM Customers;
DELETE FROM Warehouses;
DELETE FROM DateDim;
GO

DBCC CHECKIDENT ('Payments', RESEED, 0);
DBCC CHECKIDENT ('Invoices', RESEED, 0);
DBCC CHECKIDENT ('StockMovements', RESEED, 0);
DBCC CHECKIDENT ('SalesOrderLines', RESEED, 0);
DBCC CHECKIDENT ('SalesOrders', RESEED, 0);
DBCC CHECKIDENT ('PurchaseOrderLines', RESEED, 0);
DBCC CHECKIDENT ('PurchaseOrders', RESEED, 0);
DBCC CHECKIDENT ('Products', RESEED, 0);
DBCC CHECKIDENT ('Suppliers', RESEED, 0);
DBCC CHECKIDENT ('Customers', RESEED, 0);
DBCC CHECKIDENT ('Warehouses', RESEED, 0);
GO

-- =====================================================
-- 1. Date Dimension
-- =====================================================

DECLARE @StartDate DATE = '2025-01-01';
DECLARE @EndDate DATE = '2026-06-30';
DECLARE @CurrentDate DATE = @StartDate;

WHILE @CurrentDate <= @EndDate
BEGIN
INSERT INTO DateDim (
DateKey,
FullDate,
Year,
Quarter,
MonthNumber,
MonthName,
YearMonth,
DayOfMonth,
WeekdayName
)
VALUES (
CONVERT(INT, FORMAT(@CurrentDate, 'yyyyMMdd')),
@CurrentDate,
YEAR(@CurrentDate),
DATEPART(QUARTER, @CurrentDate),
MONTH(@CurrentDate),
DATENAME(MONTH, @CurrentDate),
FORMAT(@CurrentDate, 'yyyy-MM'),
DAY(@CurrentDate),
DATENAME(WEEKDAY, @CurrentDate)
);


SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);


END;
GO

-- =====================================================
-- 2. Warehouses
-- =====================================================

INSERT INTO Warehouses (WarehouseCode, WarehouseName, City, Purpose)
VALUES
('WH-001', 'Main Warehouse', 'İzmir', 'Main inventory location'),
('WH-002', 'Istanbul Transfer Warehouse', 'İstanbul', 'Regional transfer and distribution'),
('WH-003', 'Antalya Seasonal Warehouse', 'Antalya', 'Seasonal hotel and resort demand');
GO

-- =====================================================
-- 3. Suppliers
-- =====================================================

INSERT INTO Suppliers (SupplierCode, SupplierName, SupplierCategory, City, Country, PaymentTerm, CreatedDate)
VALUES
('SUP-001', 'Botanica Oils Ltd.', 'Massage Oils', 'İzmir', 'Türkiye', 'Net 30', '2025-01-01'),
('SUP-002', 'Natural Essence Co.', 'Aromatherapy', 'İstanbul', 'Türkiye', 'Net 30', '2025-01-01'),
('SUP-003', 'Ege Textile Supply', 'Spa Textile', 'Denizli', 'Türkiye', 'Net 45', '2025-01-01'),
('SUP-004', 'Dermalab Cosmetics', 'Skincare', 'İstanbul', 'Türkiye', 'Net 45', '2025-01-01'),
('SUP-005', 'HammamPro Supplies', 'Hammam Products', 'Bursa', 'Türkiye', 'Net 30', '2025-01-01'),
('SUP-006', 'Velinor Packaging', 'Consumables', 'İzmir', 'Türkiye', 'Net 30', '2025-01-01'),
('SUP-007', 'Aurelia Premium Kits', 'Premium Wellness Kits', 'Muğla', 'Türkiye', 'Net 45', '2025-01-01'),
('SUP-008', 'Wellpack Materials', 'Packaging', 'Kocaeli', 'Türkiye', 'Net 30', '2025-01-01'),
('SUP-009', 'Academy Wellness Supply', 'Training Materials', 'Ankara', 'Türkiye', 'Net 30', '2025-01-01'),
('SUP-010', 'Global Wellness Source', 'General Wellness Supply', 'İstanbul', 'Türkiye', 'Net 60', '2025-01-01');
GO

-- =====================================================
-- 4. Customers
-- =====================================================

INSERT INTO Customers (CustomerCode, CustomerName, CustomerSegment, City, Country, PaymentTerm, SalesChannel, CreatedDate)
VALUES
('CUST-001', 'Lunara Hotel & Spa', 'Hotel & Resort', 'İzmir', 'Türkiye', 'Net 30', 'B2B Direct', '2025-01-01'),
('CUST-002', 'Velora Wellness Resort', 'Hotel & Resort', 'Muğla', 'Türkiye', 'Net 45', 'B2B Direct', '2025-01-01'),
('CUST-003', 'Serene Touch Spa', 'Spa Center', 'İstanbul', 'Türkiye', 'Net 30', 'Website Lead', '2025-01-01'),
('CUST-004', 'Mira Beauty Studio', 'Beauty Salon', 'Ankara', 'Türkiye', 'Net 15', 'Sales Representative', '2025-01-01'),
('CUST-005', 'Dermaline Clinic', 'Clinic', 'İzmir', 'Türkiye', 'Net 30', 'B2B Direct', '2025-01-01'),
('CUST-006', 'Elara Spa Lounge', 'Spa Center', 'Antalya', 'Türkiye', 'Net 30', 'Website Lead', '2025-01-01'),
('CUST-007', 'Nova Esthetic Center', 'Clinic', 'Bursa', 'Türkiye', 'Net 45', 'Sales Representative', '2025-01-01'),
('CUST-008', 'Aura Beauty House', 'Beauty Salon', 'İstanbul', 'Türkiye', 'Net 15', 'Website Lead', '2025-01-01'),
('CUST-009', 'Maris Wellness Hotel', 'Hotel & Resort', 'Aydın', 'Türkiye', 'Net 30', 'B2B Direct', '2025-01-01'),
('CUST-010', 'Ege Wellness Distribution', 'Distributor / Reseller', 'İzmir', 'Türkiye', 'Net 60', 'Distributor', '2025-01-01');

DECLARE @CustomerCounter INT = 11;

WHILE @CustomerCounter <= 150
BEGIN
DECLARE @Segment NVARCHAR(50);
DECLARE @City NVARCHAR(50);
DECLARE @PaymentTerm NVARCHAR(20);
DECLARE @SalesChannel NVARCHAR(50);


SET @Segment =
    CASE ABS(CHECKSUM(NEWID())) % 6
        WHEN 0 THEN 'Hotel & Resort'
        WHEN 1 THEN 'Spa Center'
        WHEN 2 THEN 'Beauty Salon'
        WHEN 3 THEN 'Clinic'
        WHEN 4 THEN 'Premium Individual'
        ELSE 'Distributor / Reseller'
    END;

SET @City =
    CASE ABS(CHECKSUM(NEWID())) % 10
        WHEN 0 THEN 'İzmir'
        WHEN 1 THEN 'İstanbul'
        WHEN 2 THEN 'Ankara'
        WHEN 3 THEN 'Antalya'
        WHEN 4 THEN 'Muğla'
        WHEN 5 THEN 'Bursa'
        WHEN 6 THEN 'Aydın'
        WHEN 7 THEN 'Denizli'
        WHEN 8 THEN 'Kocaeli'
        ELSE 'Eskişehir'
    END;

SET @PaymentTerm =
    CASE ABS(CHECKSUM(NEWID())) % 5
        WHEN 0 THEN 'Immediate'
        WHEN 1 THEN 'Net 15'
        WHEN 2 THEN 'Net 30'
        WHEN 3 THEN 'Net 45'
        ELSE 'Net 60'
    END;

SET @SalesChannel =
    CASE ABS(CHECKSUM(NEWID())) % 5
        WHEN 0 THEN 'B2B Direct'
        WHEN 1 THEN 'Website Lead'
        WHEN 2 THEN 'Sales Representative'
        WHEN 3 THEN 'Distributor'
        ELSE 'Repeat Order'
    END;

INSERT INTO Customers (
    CustomerCode,
    CustomerName,
    CustomerSegment,
    City,
    Country,
    PaymentTerm,
    SalesChannel,
    CreatedDate
)
VALUES (
    'CUST-' + RIGHT('000' + CAST(@CustomerCounter AS NVARCHAR(10)), 3),
    'Aurevia Customer ' + CAST(@CustomerCounter AS NVARCHAR(10)),
    @Segment,
    @City,
    'Türkiye',
    @PaymentTerm,
    @SalesChannel,
    DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 180, '2025-01-01')
);

SET @CustomerCounter = @CustomerCounter + 1;


END;
GO

-- =====================================================
-- 5. Products and Services
-- =====================================================

INSERT INTO Products (ProductCode, ProductName, ProductCategory, ProductType, UnitCost, SalesPrice, ReorderLevel, IsStockTracked)
VALUES
('PRD-001', 'Aurevia Lavender Massage Oil 500 ml', 'Massage Oils', 'Physical Product', 180, 320, 50, 1),
('PRD-002', 'Aurevia Relax Massage Oil 500 ml', 'Massage Oils', 'Physical Product', 190, 340, 50, 1),
('PRD-003', 'Deep Tissue Massage Oil 1 L', 'Massage Oils', 'Physical Product', 310, 560, 30, 1),
('PRD-004', 'Aromatherapy Essential Oil Set', 'Aromatherapy Products', 'Physical Product', 420, 780, 25, 1),
('PRD-005', 'Premium Diffuser Set', 'Aromatherapy Products', 'Physical Product', 350, 690, 20, 1),
('PRD-006', 'Hammam Ritual Kit Standard', 'Hammam & Ritual Kits', 'Physical Product', 260, 480, 40, 1),
('PRD-007', 'Hammam Ritual Kit Premium', 'Hammam & Ritual Kits', 'Physical Product', 430, 790, 30, 1),
('PRD-008', 'Spa Towel Set', 'Spa Textile', 'Physical Product', 220, 410, 60, 1),
('PRD-009', 'Premium Bathrobe', 'Spa Textile', 'Physical Product', 390, 720, 35, 1),
('PRD-010', 'Disposable Slipper Pack', 'Spa Consumables', 'Physical Product', 90, 180, 100, 1),
('PRD-011', 'Facial Care Professional Kit', 'Skincare Products', 'Physical Product', 520, 980, 25, 1),
('PRD-012', 'Anti-Aging Facial Serum 30 ml', 'Skincare Products', 'Physical Product', 280, 590, 40, 1),
('PRD-013', 'VIP Spa Experience Kit', 'Premium Wellness Kits', 'Physical Product', 760, 1450, 15, 1),
('PRD-014', 'Bridal Hammam Package Kit', 'Premium Wellness Kits', 'Physical Product', 690, 1290, 15, 1),
('SRV-001', 'Spa Staff Product Training', 'Service', 'Service', 0, 3500, 0, 0),
('SRV-002', 'Wellness Operations Consulting', 'Service', 'Service', 0, 5500, 0, 0);

DECLARE @ProductCounter INT = 15;

WHILE @ProductCounter <= 78
BEGIN
DECLARE @ProductCategory NVARCHAR(80);
DECLARE @ProductCost DECIMAL(18,2);
DECLARE @ProductPrice DECIMAL(18,2);
DECLARE @ReorderLevel INT;


SET @ProductCategory =
    CASE ABS(CHECKSUM(NEWID())) % 7
        WHEN 0 THEN 'Massage Oils'
        WHEN 1 THEN 'Aromatherapy Products'
        WHEN 2 THEN 'Hammam & Ritual Kits'
        WHEN 3 THEN 'Spa Textile'
        WHEN 4 THEN 'Skincare Products'
        WHEN 5 THEN 'Spa Consumables'
        ELSE 'Premium Wellness Kits'
    END;

SET @ProductCost = 80 + (ABS(CHECKSUM(NEWID())) % 900);
SET @ProductPrice = @ProductCost * (1.45 + ((ABS(CHECKSUM(NEWID())) % 80) / 100.0));
SET @ReorderLevel = 10 + (ABS(CHECKSUM(NEWID())) % 90);

INSERT INTO Products (
    ProductCode,
    ProductName,
    ProductCategory,
    ProductType,
    UnitCost,
    SalesPrice,
    ReorderLevel,
    IsStockTracked
)
VALUES (
    'PRD-' + RIGHT('000' + CAST(@ProductCounter AS NVARCHAR(10)), 3),
    'Aurevia Product ' + CAST(@ProductCounter AS NVARCHAR(10)),
    @ProductCategory,
    'Physical Product',
    @ProductCost,
    @ProductPrice,
    @ReorderLevel,
    1
);

SET @ProductCounter = @ProductCounter + 1;


END;

INSERT INTO Products (ProductCode, ProductName, ProductCategory, ProductType, UnitCost, SalesPrice, ReorderLevel, IsStockTracked)
VALUES
('SRV-003', 'Spa Sales Team Training', 'Training & Consulting', 'Service', 0, 4200, 0, 0),
('SRV-004', 'Inventory Process Consulting', 'Training & Consulting', 'Service', 0, 6200, 0, 0);
GO

-- =====================================================
-- 6. Purchase Orders and Purchase Order Lines
-- =====================================================

DECLARE @POCounter INT = 1;

WHILE @POCounter <= 800
BEGIN
DECLARE @SupplierID INT;
DECLARE @WarehouseID INT;
DECLARE @PODate DATE;
DECLARE @ExpectedDate DATE;
DECLARE @ActualDate DATE;
DECLARE @POLineCount INT;
DECLARE @POLineCounter INT = 1;
DECLARE @PurchaseOrderID INT;


SELECT TOP 1 @SupplierID = SupplierID FROM Suppliers ORDER BY NEWID();
SELECT TOP 1 @WarehouseID = WarehouseID FROM Warehouses ORDER BY NEWID();

SET @PODate = DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 545, '2025-01-01');
SET @ExpectedDate = DATEADD(DAY, 3 + (ABS(CHECKSUM(NEWID())) % 12), @PODate);
SET @ActualDate = DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 6, @ExpectedDate);
SET @POLineCount = 2 + (ABS(CHECKSUM(NEWID())) % 3);

INSERT INTO PurchaseOrders (
    PurchaseOrderCode,
    SupplierID,
    OrderDate,
    ExpectedDeliveryDate,
    ActualDeliveryDate,
    PurchaseOrderStatus,
    WarehouseID
)
VALUES (
    'PO-' + RIGHT('000000' + CAST(@POCounter AS NVARCHAR(10)), 6),
    @SupplierID,
    @PODate,
    @ExpectedDate,
    @ActualDate,
    'Received',
    @WarehouseID
);

SET @PurchaseOrderID = SCOPE_IDENTITY();

WHILE @POLineCounter <= @POLineCount
BEGIN
    DECLARE @POProductID INT;
    DECLARE @POQuantity INT;
    DECLARE @POUnitCost DECIMAL(18,2);
    DECLARE @MovementCodeIn NVARCHAR(30);

    SELECT TOP 1
        @POProductID = ProductID,
        @POUnitCost = UnitCost
    FROM Products
    WHERE IsStockTracked = 1
    ORDER BY NEWID();

    SET @POQuantity = 50 + (ABS(CHECKSUM(NEWID())) % 450);

    INSERT INTO PurchaseOrderLines (
        PurchaseOrderID,
        ProductID,
        Quantity,
        UnitCost
    )
    VALUES (
        @PurchaseOrderID,
        @POProductID,
        @POQuantity,
        @POUnitCost
    );

    SET @MovementCodeIn = 'SM-IN-' + RIGHT('000000' + CAST(@POCounter AS NVARCHAR(10)), 6) + '-' + CAST(@POLineCounter AS NVARCHAR(10));

    INSERT INTO StockMovements (
        MovementCode,
        ProductID,
        WarehouseID,
        MovementDate,
        MovementType,
        Quantity,
        RelatedDocumentType,
        RelatedDocumentCode
    )
    VALUES (
        @MovementCodeIn,
        @POProductID,
        @WarehouseID,
        @ActualDate,
        'Stock Receipt',
        @POQuantity,
        'Purchase Order',
        'PO-' + RIGHT('000000' + CAST(@POCounter AS NVARCHAR(10)), 6)
    );

    SET @POLineCounter = @POLineCounter + 1;
END;

SET @POCounter = @POCounter + 1;


END;
GO

-- =====================================================
-- 7. Sales Orders, Sales Lines, Stock-Outs, Invoices and Payments
-- =====================================================

DECLARE @SOCounter INT = 1;

WHILE @SOCounter <= 3000
BEGIN
DECLARE @CustomerID INT;
DECLARE @SODate DATE;
DECLARE @DeliveryDate DATE;
DECLARE @SOWarehouseID INT;
DECLARE @SOPaymentTerm NVARCHAR(20);
DECLARE @SOSalesChannel NVARCHAR(50);
DECLARE @SalesOrderID INT;
DECLARE @SOLineCount INT;
DECLARE @SOLineCounter INT = 1;
DECLARE @InvoiceID INT;
DECLARE @InvoiceAmount DECIMAL(18,2);
DECLARE @InvoiceDate DATE;
DECLARE @DueDate DATE;
DECLARE @PaymentTermDays INT;
DECLARE @PaymentScenario INT;
DECLARE @InvoiceStatus NVARCHAR(30);
DECLARE @PaymentAmount DECIMAL(18,2);
DECLARE @PaymentDate DATE;


SELECT TOP 1
    @CustomerID = CustomerID,
    @SOPaymentTerm = PaymentTerm,
    @SOSalesChannel = SalesChannel
FROM Customers
ORDER BY NEWID();

SELECT TOP 1 @SOWarehouseID = WarehouseID FROM Warehouses ORDER BY NEWID();

SET @SODate = DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 545, '2025-01-01');
SET @DeliveryDate = DATEADD(DAY, 1 + (ABS(CHECKSUM(NEWID())) % 7), @SODate);
SET @SOLineCount = 2 + (ABS(CHECKSUM(NEWID())) % 3);

INSERT INTO SalesOrders (
    SalesOrderCode,
    CustomerID,
    OrderDate,
    DeliveryDate,
    SalesOrderStatus,
    PaymentTerm,
    SalesChannel,
    WarehouseID
)
VALUES (
    'SO-' + RIGHT('000000' + CAST(@SOCounter AS NVARCHAR(10)), 6),
    @CustomerID,
    @SODate,
    @DeliveryDate,
    'Delivered',
    @SOPaymentTerm,
    @SOSalesChannel,
    @SOWarehouseID
);

SET @SalesOrderID = SCOPE_IDENTITY();

WHILE @SOLineCounter <= @SOLineCount
BEGIN
    DECLARE @SOProductID INT;
    DECLARE @SOQuantity INT;
    DECLARE @SOUnitCost DECIMAL(18,2);
    DECLARE @SOUnitPrice DECIMAL(18,2);
    DECLARE @IsStockTracked BIT;
    DECLARE @MovementCodeOut NVARCHAR(30);

    SELECT TOP 1
        @SOProductID = ProductID,
        @SOUnitCost = UnitCost,
        @SOUnitPrice = SalesPrice,
        @IsStockTracked = IsStockTracked
    FROM Products
    ORDER BY NEWID();

    IF @IsStockTracked = 1
        SET @SOQuantity = 5 + (ABS(CHECKSUM(NEWID())) % 95);
    ELSE
        SET @SOQuantity = 1;

    INSERT INTO SalesOrderLines (
        SalesOrderID,
        ProductID,
        Quantity,
        UnitSalesPrice,
        UnitCost
    )
    VALUES (
        @SalesOrderID,
        @SOProductID,
        @SOQuantity,
        @SOUnitPrice,
        @SOUnitCost
    );

    IF @IsStockTracked = 1
    BEGIN
        SET @MovementCodeOut = 'SM-OUT-' + RIGHT('000000' + CAST(@SOCounter AS NVARCHAR(10)), 6) + '-' + CAST(@SOLineCounter AS NVARCHAR(10));

        INSERT INTO StockMovements (
            MovementCode,
            ProductID,
            WarehouseID,
            MovementDate,
            MovementType,
            Quantity,
            RelatedDocumentType,
            RelatedDocumentCode
        )
        VALUES (
            @MovementCodeOut,
            @SOProductID,
            @SOWarehouseID,
            @DeliveryDate,
            'Stock Out',
            -1 * @SOQuantity,
            'Sales Order',
            'SO-' + RIGHT('000000' + CAST(@SOCounter AS NVARCHAR(10)), 6)
        );
    END;

    SET @SOLineCounter = @SOLineCounter + 1;
END;

SELECT @InvoiceAmount = SUM(RevenueAmount)
FROM SalesOrderLines
WHERE SalesOrderID = @SalesOrderID;

SET @InvoiceDate = @DeliveryDate;

SET @PaymentTermDays =
    CASE @SOPaymentTerm
        WHEN 'Immediate' THEN 0
        WHEN 'Net 15' THEN 15
        WHEN 'Net 30' THEN 30
        WHEN 'Net 45' THEN 45
        WHEN 'Net 60' THEN 60
        ELSE 30
    END;

SET @DueDate = DATEADD(DAY, @PaymentTermDays, @InvoiceDate);
SET @PaymentScenario = ABS(CHECKSUM(NEWID())) % 100;

IF @PaymentScenario < 65
    SET @InvoiceStatus = 'Paid';
ELSE IF @PaymentScenario < 90
    SET @InvoiceStatus = 'Partial';
ELSE IF @DueDate < '2026-06-30'
    SET @InvoiceStatus = 'Overdue';
ELSE
    SET @InvoiceStatus = 'Open';

INSERT INTO Invoices (
    InvoiceCode,
    SalesOrderID,
    CustomerID,
    InvoiceDate,
    DueDate,
    InvoiceAmount,
    InvoiceStatus
)
VALUES (
    'INV-' + RIGHT('000000' + CAST(@SOCounter AS NVARCHAR(10)), 6),
    @SalesOrderID,
    @CustomerID,
    @InvoiceDate,
    @DueDate,
    @InvoiceAmount,
    @InvoiceStatus
);

SET @InvoiceID = SCOPE_IDENTITY();

IF @InvoiceStatus = 'Paid'
BEGIN
    SET @PaymentAmount = @InvoiceAmount;
    SET @PaymentDate = DATEADD(DAY, ABS(CHECKSUM(NEWID())) % (@PaymentTermDays + 10 + 1), @InvoiceDate);

    INSERT INTO Payments (
        PaymentCode,
        InvoiceID,
        CustomerID,
        PaymentDate,
        PaymentAmount,
        PaymentStatus,
        PaymentMethod
    )
    VALUES (
        'PAY-' + RIGHT('000000' + CAST(@SOCounter AS NVARCHAR(10)), 6),
        @InvoiceID,
        @CustomerID,
        @PaymentDate,
        @PaymentAmount,
        'Paid',
        'Bank Transfer'
    );
END
ELSE IF @InvoiceStatus = 'Partial'
BEGIN
    SET @PaymentAmount = @InvoiceAmount * (0.25 + ((ABS(CHECKSUM(NEWID())) % 50) / 100.0));
    SET @PaymentDate = DATEADD(DAY, ABS(CHECKSUM(NEWID())) % (@PaymentTermDays + 20 + 1), @InvoiceDate);

    INSERT INTO Payments (
        PaymentCode,
        InvoiceID,
        CustomerID,
        PaymentDate,
        PaymentAmount,
        PaymentStatus,
        PaymentMethod
    )
    VALUES (
        'PAY-' + RIGHT('000000' + CAST(@SOCounter AS NVARCHAR(10)), 6),
        @InvoiceID,
        @CustomerID,
        @PaymentDate,
        @PaymentAmount,
        'Partial',
        'Bank Transfer'
    );
END;

SET @SOCounter = @SOCounter + 1;


END;
GO

-- =====================================================
-- 8. Validation Queries
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

PRINT 'Synthetic ERP dataset inserted successfully.';
GO
