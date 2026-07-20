
-- =====================================================
-- Aurevia ERP Operations & BI Dashboard Case Study
-- SQL Server Table Creation Script
-- =====================================================

IF DB_ID('AureviaERPBI') IS NULL
BEGIN
    CREATE DATABASE AureviaERPBI;
END;
GO

USE AureviaERPBI;
GO

-- Drop tables if they already exist
DROP TABLE IF EXISTS Payments;
DROP TABLE IF EXISTS Invoices;
DROP TABLE IF EXISTS StockMovements;
DROP TABLE IF EXISTS SalesOrderLines;
DROP TABLE IF EXISTS SalesOrders;
DROP TABLE IF EXISTS PurchaseOrderLines;
DROP TABLE IF EXISTS PurchaseOrders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Suppliers;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Warehouses;
DROP TABLE IF EXISTS DateDim;
GO

-- =====================================================
-- 1. Customers
-- =====================================================

CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerCode NVARCHAR(20) NOT NULL UNIQUE,
    CustomerName NVARCHAR(150) NOT NULL,
    CustomerSegment NVARCHAR(50) NOT NULL,
    City NVARCHAR(50) NOT NULL,
    Country NVARCHAR(50) NOT NULL DEFAULT 'Türkiye',
    PaymentTerm NVARCHAR(20) NOT NULL,
    SalesChannel NVARCHAR(50) NOT NULL,
    CreatedDate DATE NOT NULL
);
GO

-- =====================================================
-- 2. Suppliers
-- =====================================================

CREATE TABLE Suppliers (
    SupplierID INT IDENTITY(1,1) PRIMARY KEY,
    SupplierCode NVARCHAR(20) NOT NULL UNIQUE,
    SupplierName NVARCHAR(150) NOT NULL,
    SupplierCategory NVARCHAR(80) NOT NULL,
    City NVARCHAR(50) NOT NULL,
    Country NVARCHAR(50) NOT NULL DEFAULT 'Türkiye',
    PaymentTerm NVARCHAR(20) NOT NULL,
    CreatedDate DATE NOT NULL
);
GO

-- =====================================================
-- 3. Products
-- =====================================================

CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductCode NVARCHAR(20) NOT NULL UNIQUE,
    ProductName NVARCHAR(150) NOT NULL,
    ProductCategory NVARCHAR(80) NOT NULL,
    ProductType NVARCHAR(30) NOT NULL,
    UnitCost DECIMAL(18,2) NOT NULL,
    SalesPrice DECIMAL(18,2) NOT NULL,
    ReorderLevel INT NOT NULL,
    IsStockTracked BIT NOT NULL
);
GO

-- =====================================================
-- 4. Warehouses
-- =====================================================

CREATE TABLE Warehouses (
    WarehouseID INT IDENTITY(1,1) PRIMARY KEY,
    WarehouseCode NVARCHAR(20) NOT NULL UNIQUE,
    WarehouseName NVARCHAR(100) NOT NULL,
    City NVARCHAR(50) NOT NULL,
    Purpose NVARCHAR(150) NOT NULL
);
GO

-- =====================================================
-- 5. Purchase Orders
-- =====================================================

CREATE TABLE PurchaseOrders (
    PurchaseOrderID INT IDENTITY(1,1) PRIMARY KEY,
    PurchaseOrderCode NVARCHAR(30) NOT NULL UNIQUE,
    SupplierID INT NOT NULL,
    OrderDate DATE NOT NULL,
    ExpectedDeliveryDate DATE NOT NULL,
    ActualDeliveryDate DATE NULL,
    PurchaseOrderStatus NVARCHAR(30) NOT NULL,
    WarehouseID INT NOT NULL,

    CONSTRAINT FK_PurchaseOrders_Suppliers
        FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID),

    CONSTRAINT FK_PurchaseOrders_Warehouses
        FOREIGN KEY (WarehouseID) REFERENCES Warehouses(WarehouseID)
);
GO

-- =====================================================
-- 6. Purchase Order Lines
-- =====================================================

CREATE TABLE PurchaseOrderLines (
    PurchaseOrderLineID INT IDENTITY(1,1) PRIMARY KEY,
    PurchaseOrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitCost DECIMAL(18,2) NOT NULL,
    LineAmount AS (Quantity * UnitCost) PERSISTED,

    CONSTRAINT FK_PurchaseOrderLines_PurchaseOrders
        FOREIGN KEY (PurchaseOrderID) REFERENCES PurchaseOrders(PurchaseOrderID),

    CONSTRAINT FK_PurchaseOrderLines_Products
        FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO

-- =====================================================
-- 7. Sales Orders
-- =====================================================

CREATE TABLE SalesOrders (
    SalesOrderID INT IDENTITY(1,1) PRIMARY KEY,
    SalesOrderCode NVARCHAR(30) NOT NULL UNIQUE,
    CustomerID INT NOT NULL,
    OrderDate DATE NOT NULL,
    DeliveryDate DATE NULL,
    SalesOrderStatus NVARCHAR(30) NOT NULL,
    PaymentTerm NVARCHAR(20) NOT NULL,
    SalesChannel NVARCHAR(50) NOT NULL,
    WarehouseID INT NOT NULL,

    CONSTRAINT FK_SalesOrders_Customers
        FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),

    CONSTRAINT FK_SalesOrders_Warehouses
        FOREIGN KEY (WarehouseID) REFERENCES Warehouses(WarehouseID)
);
GO

-- =====================================================
-- 8. Sales Order Lines
-- =====================================================

CREATE TABLE SalesOrderLines (
    SalesOrderLineID INT IDENTITY(1,1) PRIMARY KEY,
    SalesOrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitSalesPrice DECIMAL(18,2) NOT NULL,
    UnitCost DECIMAL(18,2) NOT NULL,
    RevenueAmount AS (Quantity * UnitSalesPrice) PERSISTED,
    CostAmount AS (Quantity * UnitCost) PERSISTED,
    GrossProfitAmount AS ((Quantity * UnitSalesPrice) - (Quantity * UnitCost)) PERSISTED,

    CONSTRAINT FK_SalesOrderLines_SalesOrders
        FOREIGN KEY (SalesOrderID) REFERENCES SalesOrders(SalesOrderID),

    CONSTRAINT FK_SalesOrderLines_Products
        FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO

-- =====================================================
-- 9. Stock Movements
-- =====================================================

CREATE TABLE StockMovements (
    StockMovementID INT IDENTITY(1,1) PRIMARY KEY,
    MovementCode NVARCHAR(30) NOT NULL UNIQUE,
    ProductID INT NOT NULL,
    WarehouseID INT NOT NULL,
    MovementDate DATE NOT NULL,
    MovementType NVARCHAR(30) NOT NULL,
    Quantity INT NOT NULL,
    RelatedDocumentType NVARCHAR(50) NOT NULL,
    RelatedDocumentCode NVARCHAR(30) NOT NULL,

    CONSTRAINT FK_StockMovements_Products
        FOREIGN KEY (ProductID) REFERENCES Products(ProductID),

    CONSTRAINT FK_StockMovements_Warehouses
        FOREIGN KEY (WarehouseID) REFERENCES Warehouses(WarehouseID)
);
GO

-- =====================================================
-- 10. Invoices
-- =====================================================

CREATE TABLE Invoices (
    InvoiceID INT IDENTITY(1,1) PRIMARY KEY,
    InvoiceCode NVARCHAR(30) NOT NULL UNIQUE,
    SalesOrderID INT NOT NULL,
    CustomerID INT NOT NULL,
    InvoiceDate DATE NOT NULL,
    DueDate DATE NOT NULL,
    InvoiceAmount DECIMAL(18,2) NOT NULL,
    InvoiceStatus NVARCHAR(30) NOT NULL,

    CONSTRAINT FK_Invoices_SalesOrders
        FOREIGN KEY (SalesOrderID) REFERENCES SalesOrders(SalesOrderID),

    CONSTRAINT FK_Invoices_Customers
        FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);
GO

-- =====================================================
-- 11. Payments
-- =====================================================

CREATE TABLE Payments (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    PaymentCode NVARCHAR(30) NOT NULL UNIQUE,
    InvoiceID INT NOT NULL,
    CustomerID INT NOT NULL,
    PaymentDate DATE NULL,
    PaymentAmount DECIMAL(18,2) NOT NULL,
    PaymentStatus NVARCHAR(30) NOT NULL,
    PaymentMethod NVARCHAR(50) NOT NULL,

    CONSTRAINT FK_Payments_Invoices
        FOREIGN KEY (InvoiceID) REFERENCES Invoices(InvoiceID),

    CONSTRAINT FK_Payments_Customers
        FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);
GO

-- =====================================================
-- 12. Date Dimension
-- =====================================================

CREATE TABLE DateDim (
    DateKey INT PRIMARY KEY,
    FullDate DATE NOT NULL,
    Year INT NOT NULL,
    Quarter INT NOT NULL,
    MonthNumber INT NOT NULL,
    MonthName NVARCHAR(20) NOT NULL,
    YearMonth NVARCHAR(10) NOT NULL,
    DayOfMonth INT NOT NULL,
    WeekdayName NVARCHAR(20) NOT NULL
);
GO

PRINT 'AureviaERPBI database and tables created successfully.';





