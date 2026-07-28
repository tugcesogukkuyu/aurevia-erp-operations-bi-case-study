-- ============================================================
-- Aurevia ERP Application Control and Testing Case
-- Goods Receipt Validation Test Scenarios
-- Microsoft SQL Server
-- ============================================================

USE AureviaERPBI;
GO

SET NOCOUNT ON;
GO

-- ============================================================
-- TC-GR-001
-- Exact delivery with fully accepted quantity
-- Expected result: APPROVED
-- ============================================================

EXEC dbo.usp_ValidateGoodsReceipt
    @UserCode = 'USR-WH-01',
    @PurchaseOrderCode = 'PO-UAT-000001',
    @ProductCode = 'PRD-010',
    @WarehouseCode = 'WH-001',
    @BatchNumber = 'BATCH-GR-001',
    @DeliveredQuantity = 1000,
    @AcceptedQuantity = 1000,
    @RejectedQuantity = 0,
    @DamagedQuantity = 0,
    @QualityBlockedQuantity = 0,
    @AllowedVariancePercentage = 5,
    @VarianceReasonCode = NULL,
    @ExceptionApprovalStatus = 'NOT_REQUIRED';
GO

-- ============================================================
-- TC-GR-002
-- Delivery is 4% above the ordered quantity
-- Variance remains within the permitted 5% tolerance
-- Expected result: APPROVED
-- ============================================================

EXEC dbo.usp_ValidateGoodsReceipt
    @UserCode = 'USR-WH-01',
    @PurchaseOrderCode = 'PO-UAT-000001',
    @ProductCode = 'PRD-010',
    @WarehouseCode = 'WH-001',
    @BatchNumber = 'BATCH-GR-001',
    @DeliveredQuantity = 1040,
    @AcceptedQuantity = 1040,
    @RejectedQuantity = 0,
    @DamagedQuantity = 0,
    @QualityBlockedQuantity = 0,
    @AllowedVariancePercentage = 5,
    @VarianceReasonCode = 'SUPPLIER_OVER_DELIVERY',
    @ExceptionApprovalStatus = 'NOT_REQUIRED';
GO

-- ============================================================
-- TC-GR-003
-- Delivery is 10% above the ordered quantity
-- Exception approval has not yet been completed
-- Expected result: PENDING_EXCEPTION_APPROVAL
-- ============================================================

EXEC dbo.usp_ValidateGoodsReceipt
    @UserCode = 'USR-WH-01',
    @PurchaseOrderCode = 'PO-UAT-000001',
    @ProductCode = 'PRD-010',
    @WarehouseCode = 'WH-001',
    @BatchNumber = 'BATCH-GR-001',
    @DeliveredQuantity = 1100,
    @AcceptedQuantity = 1100,
    @RejectedQuantity = 0,
    @DamagedQuantity = 0,
    @QualityBlockedQuantity = 0,
    @AllowedVariancePercentage = 5,
    @VarianceReasonCode = 'SUPPLIER_OVER_DELIVERY',
    @ExceptionApprovalStatus = 'PENDING';
GO

-- ============================================================
-- TC-GR-004
-- Delivery is 10% above the ordered quantity
-- Warehouse manager approved the exception
-- Expected result: APPROVED
-- ============================================================

EXEC dbo.usp_ValidateGoodsReceipt
    @UserCode = 'USR-WHMGR-01',
    @PurchaseOrderCode = 'PO-UAT-000001',
    @ProductCode = 'PRD-010',
    @WarehouseCode = 'WH-001',
    @BatchNumber = 'BATCH-GR-001',
    @DeliveredQuantity = 1100,
    @AcceptedQuantity = 1100,
    @RejectedQuantity = 0,
    @DamagedQuantity = 0,
    @QualityBlockedQuantity = 0,
    @AllowedVariancePercentage = 5,
    @VarianceReasonCode = 'SUPPLIER_OVER_DELIVERY',
    @ExceptionApprovalStatus = 'APPROVED';
GO

-- ============================================================
-- TC-GR-005
-- Delivery variance exists but no reason code was provided
-- Expected result: REJECTED
-- Expected failed check: VARIANCE_REASON
-- ============================================================

EXEC dbo.usp_ValidateGoodsReceipt
    @UserCode = 'USR-WH-01',
    @PurchaseOrderCode = 'PO-UAT-000001',
    @ProductCode = 'PRD-010',
    @WarehouseCode = 'WH-001',
    @BatchNumber = 'BATCH-GR-001',
    @DeliveredQuantity = 1040,
    @AcceptedQuantity = 1040,
    @RejectedQuantity = 0,
    @DamagedQuantity = 0,
    @QualityBlockedQuantity = 0,
    @AllowedVariancePercentage = 5,
    @VarianceReasonCode = NULL,
    @ExceptionApprovalStatus = 'NOT_REQUIRED';
GO

-- ============================================================
-- TC-GR-006
-- Quantity classification does not equal delivered quantity
-- Breakdown total: 950
-- Delivered quantity: 1000
-- Expected result: REJECTED
-- Expected failed check: QUANTITY_BREAKDOWN
-- ============================================================

EXEC dbo.usp_ValidateGoodsReceipt
    @UserCode = 'USR-WH-01',
    @PurchaseOrderCode = 'PO-UAT-000001',
    @ProductCode = 'PRD-010',
    @WarehouseCode = 'WH-001',
    @BatchNumber = 'BATCH-GR-001',
    @DeliveredQuantity = 1000,
    @AcceptedQuantity = 900,
    @RejectedQuantity = 20,
    @DamagedQuantity = 10,
    @QualityBlockedQuantity = 20,
    @AllowedVariancePercentage = 5,
    @VarianceReasonCode = NULL,
    @ExceptionApprovalStatus = 'NOT_REQUIRED';
GO

-- ============================================================
-- TC-GR-007
-- Received quantity contains quality-blocked products
-- Only accepted quantity may enter available inventory
-- Expected result: APPROVED
-- ============================================================

EXEC dbo.usp_ValidateGoodsReceipt
    @UserCode = 'USR-WH-01',
    @PurchaseOrderCode = 'PO-UAT-000001',
    @ProductCode = 'PRD-010',
    @WarehouseCode = 'WH-001',
    @BatchNumber = 'BATCH-GR-001',
    @DeliveredQuantity = 1000,
    @AcceptedQuantity = 850,
    @RejectedQuantity = 50,
    @DamagedQuantity = 20,
    @QualityBlockedQuantity = 80,
    @AllowedVariancePercentage = 5,
    @VarianceReasonCode = NULL,
    @ExceptionApprovalStatus = 'NOT_REQUIRED';
GO

-- ============================================================
-- TC-GR-008
-- Unauthorized sales user attempts to record goods receipt
-- Expected result: REJECTED
-- Expected failed check: WAREHOUSE_ROLE
-- ============================================================

EXEC dbo.usp_ValidateGoodsReceipt
    @UserCode = 'USR-SALES-01',
    @PurchaseOrderCode = 'PO-UAT-000001',
    @ProductCode = 'PRD-010',
    @WarehouseCode = 'WH-001',
    @BatchNumber = 'BATCH-GR-001',
    @DeliveredQuantity = 1000,
    @AcceptedQuantity = 1000,
    @RejectedQuantity = 0,
    @DamagedQuantity = 0,
    @QualityBlockedQuantity = 0,
    @AllowedVariancePercentage = 5,
    @VarianceReasonCode = NULL,
    @ExceptionApprovalStatus = 'NOT_REQUIRED';
GO

-- ============================================================
-- TC-GR-009
-- Selected warehouse does not match purchase order warehouse
-- Expected result: REJECTED
-- Expected failed check: PURCHASE_ORDER_WAREHOUSE
-- ============================================================

EXEC dbo.usp_ValidateGoodsReceipt
    @UserCode = 'USR-WH-01',
    @PurchaseOrderCode = 'PO-UAT-000001',
    @ProductCode = 'PRD-010',
    @WarehouseCode = 'WH-003',
    @BatchNumber = 'BATCH-GR-001',
    @DeliveredQuantity = 1000,
    @AcceptedQuantity = 1000,
    @RejectedQuantity = 0,
    @DamagedQuantity = 0,
    @QualityBlockedQuantity = 0,
    @AllowedVariancePercentage = 5,
    @VarianceReasonCode = NULL,
    @ExceptionApprovalStatus = 'NOT_REQUIRED';
GO

-- ============================================================
-- TC-GR-010
-- Batch does not exist for the selected product
-- Expected result: REJECTED
-- Expected failed check: BATCH_EXISTS
-- ============================================================

EXEC dbo.usp_ValidateGoodsReceipt
    @UserCode = 'USR-WH-01',
    @PurchaseOrderCode = 'PO-UAT-000001',
    @ProductCode = 'PRD-010',
    @WarehouseCode = 'WH-001',
    @BatchNumber = 'BATCH-MISSING-001',
    @DeliveredQuantity = 1000,
    @AcceptedQuantity = 1000,
    @RejectedQuantity = 0,
    @DamagedQuantity = 0,
    @QualityBlockedQuantity = 0,
    @AllowedVariancePercentage = 5,
    @VarianceReasonCode = NULL,
    @ExceptionApprovalStatus = 'NOT_REQUIRED';
GO

-- ============================================================
-- TC-GR-011
-- Delivery is 10% below the ordered quantity
-- Exception approval is pending
-- Expected result: PENDING_EXCEPTION_APPROVAL
-- ============================================================

EXEC dbo.usp_ValidateGoodsReceipt
    @UserCode = 'USR-WH-01',
    @PurchaseOrderCode = 'PO-UAT-000001',
    @ProductCode = 'PRD-010',
    @WarehouseCode = 'WH-001',
    @BatchNumber = 'BATCH-GR-001',
    @DeliveredQuantity = 900,
    @AcceptedQuantity = 900,
    @RejectedQuantity = 0,
    @DamagedQuantity = 0,
    @QualityBlockedQuantity = 0,
    @AllowedVariancePercentage = 5,
    @VarianceReasonCode = 'SUPPLIER_SHORT_DELIVERY',
    @ExceptionApprovalStatus = 'PENDING';
GO

-- ============================================================
-- TC-GR-012
-- Delivery exceeds tolerance and exception was rejected
-- Expected result: REJECTED
-- Expected failed check: ORDER_VARIANCE
-- ============================================================

EXEC dbo.usp_ValidateGoodsReceipt
    @UserCode = 'USR-WH-01',
    @PurchaseOrderCode = 'PO-UAT-000001',
    @ProductCode = 'PRD-010',
    @WarehouseCode = 'WH-001',
    @BatchNumber = 'BATCH-GR-001',
    @DeliveredQuantity = 1100,
    @AcceptedQuantity = 1100,
    @RejectedQuantity = 0,
    @DamagedQuantity = 0,
    @QualityBlockedQuantity = 0,
    @AllowedVariancePercentage = 5,
    @VarianceReasonCode = 'SUPPLIER_OVER_DELIVERY',
    @ExceptionApprovalStatus = 'REJECTED';
GO