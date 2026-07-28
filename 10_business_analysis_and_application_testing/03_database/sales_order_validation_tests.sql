-- ============================================================
-- Aurevia ERP Application Control and Testing Case
-- Sales Order Validation Test Scenarios
-- Microsoft SQL Server
-- ============================================================

USE AureviaERPBI;
GO

SET NOCOUNT ON;
GO

-- ============================================================
-- TC-SO-001
-- Valid order: authorized user, valid warehouse, released batch,
-- sufficient shelf life, sufficient stock, sufficient credit
-- Expected result: APPROVED
-- ============================================================

EXEC dbo.usp_ValidateSalesOrder
    @UserCode = 'USR-SALESMGR-01',
    @CustomerCode = 'CUST-002',
    @ProductCode = 'PRD-001',
    @BatchNumber = 'BATCH-REL-001',
    @WarehouseCode = 'WH-001',
    @RequestedQuantity = 100,
    @OrderAmount = 50000,
    @FinanceApprovalStatus = 'NOT_REQUIRED';
GO

-- ============================================================
-- TC-SO-002
-- Unauthorized user attempts approval
-- Expected result: REJECTED
-- Expected failed check: APPROVAL_ROLE
-- ============================================================

EXEC dbo.usp_ValidateSalesOrder
    @UserCode = 'USR-SALES-01',
    @CustomerCode = 'CUST-002',
    @ProductCode = 'PRD-001',
    @BatchNumber = 'BATCH-REL-001',
    @WarehouseCode = 'WH-001',
    @RequestedQuantity = 100,
    @OrderAmount = 50000,
    @FinanceApprovalStatus = 'NOT_REQUIRED';
GO

-- ============================================================
-- TC-SO-003
-- Quality-blocked batch selected
-- Expected result: REJECTED
-- Expected failed check: BATCH_QUALITY_STATUS
-- ============================================================

EXEC dbo.usp_ValidateSalesOrder
    @UserCode = 'USR-SALESMGR-01',
    @CustomerCode = 'CUST-002',
    @ProductCode = 'PRD-001',
    @BatchNumber = 'BATCH-BLOCK-001',
    @WarehouseCode = 'WH-001',
    @RequestedQuantity = 100,
    @OrderAmount = 50000,
    @FinanceApprovalStatus = 'NOT_REQUIRED';
GO

-- ============================================================
-- TC-SO-004
-- Batch does not meet customer minimum shelf-life requirement
-- Expected result: REJECTED
-- Expected failed check: SHELF_LIFE_REQUIREMENT
-- ============================================================

EXEC dbo.usp_ValidateSalesOrder
    @UserCode = 'USR-SALESMGR-01',
    @CustomerCode = 'CUST-001',
    @ProductCode = 'PRD-001',
    @BatchNumber = 'BATCH-SHORT-001',
    @WarehouseCode = 'WH-001',
    @RequestedQuantity = 100,
    @OrderAmount = 10000,
    @FinanceApprovalStatus = 'NOT_REQUIRED';
GO

-- ============================================================
-- TC-SO-005
-- Requested quantity exceeds available stock
-- Available stock for BATCH-REL-001 / WH-001 = 300
-- Expected result: REJECTED
-- Expected failed check: AVAILABLE_STOCK
-- ============================================================

EXEC dbo.usp_ValidateSalesOrder
    @UserCode = 'USR-SALESMGR-01',
    @CustomerCode = 'CUST-002',
    @ProductCode = 'PRD-001',
    @BatchNumber = 'BATCH-REL-001',
    @WarehouseCode = 'WH-001',
    @RequestedQuantity = 350,
    @OrderAmount = 50000,
    @FinanceApprovalStatus = 'NOT_REQUIRED';
GO

-- ============================================================
-- TC-SO-006
-- Stock exists in a warehouse that is not eligible for sales
-- Expected result: REJECTED
-- Expected failed check: WAREHOUSE_SALES_ELIGIBILITY
-- ============================================================

EXEC dbo.usp_ValidateSalesOrder
    @UserCode = 'USR-SALESMGR-01',
    @CustomerCode = 'CUST-002',
    @ProductCode = 'PRD-001',
    @BatchNumber = 'BATCH-REL-001',
    @WarehouseCode = 'WH-003',
    @RequestedQuantity = 100,
    @OrderAmount = 50000,
    @FinanceApprovalStatus = 'NOT_REQUIRED';
GO

-- ============================================================
-- TC-SO-007
-- Order exceeds remaining credit and finance approval is pending
-- CUST-001 remaining credit = 15000
-- Expected result: PENDING_FINANCE_APPROVAL
-- ============================================================

EXEC dbo.usp_ValidateSalesOrder
    @UserCode = 'USR-SALESMGR-01',
    @CustomerCode = 'CUST-001',
    @ProductCode = 'PRD-001',
    @BatchNumber = 'BATCH-REL-001',
    @WarehouseCode = 'WH-001',
    @RequestedQuantity = 100,
    @OrderAmount = 20000,
    @FinanceApprovalStatus = 'PENDING';
GO

-- ============================================================
-- TC-SO-008
-- Order exceeds remaining credit but finance approved exception
-- Expected result: APPROVED
-- ============================================================

EXEC dbo.usp_ValidateSalesOrder
    @UserCode = 'USR-SALESMGR-01',
    @CustomerCode = 'CUST-001',
    @ProductCode = 'PRD-001',
    @BatchNumber = 'BATCH-REL-001',
    @WarehouseCode = 'WH-001',
    @RequestedQuantity = 100,
    @OrderAmount = 20000,
    @FinanceApprovalStatus = 'APPROVED';
GO

-- ============================================================
-- TC-SO-009
-- Rejected batch selected
-- Expected result: REJECTED
-- Expected failed check: BATCH_QUALITY_STATUS
-- ============================================================

EXEC dbo.usp_ValidateSalesOrder
    @UserCode = 'USR-SALESMGR-01',
    @CustomerCode = 'CUST-002',
    @ProductCode = 'PRD-001',
    @BatchNumber = 'BATCH-REJ-001',
    @WarehouseCode = 'WH-001',
    @RequestedQuantity = 100,
    @OrderAmount = 50000,
    @FinanceApprovalStatus = 'NOT_REQUIRED';
GO

-- ============================================================
-- TC-SO-010
-- Batch does not exist for selected product
-- Expected result: REJECTED
-- Expected failed checks:
-- BATCH_EXISTS
-- BATCH_QUALITY_STATUS
-- SHELF_LIFE_REQUIREMENT
-- INVENTORY_BALANCE_EXISTS
-- AVAILABLE_STOCK
-- ============================================================

EXEC dbo.usp_ValidateSalesOrder
    @UserCode = 'USR-SALESMGR-01',
    @CustomerCode = 'CUST-002',
    @ProductCode = 'PRD-001',
    @BatchNumber = 'BATCH-MISSING-001',
    @WarehouseCode = 'WH-001',
    @RequestedQuantity = 100,
    @OrderAmount = 50000,
    @FinanceApprovalStatus = 'NOT_REQUIRED';
GO