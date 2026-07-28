-- ============================================================
-- Aurevia ERP Application Control and Testing Case
-- Goods Receipt Validation Procedure
-- Microsoft SQL Server
-- ============================================================

USE AureviaERPBI;
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.usp_ValidateGoodsReceipt
    @UserCode NVARCHAR(30),
    @PurchaseOrderCode NVARCHAR(30),
    @ProductCode NVARCHAR(30),
    @WarehouseCode NVARCHAR(30),
    @BatchNumber NVARCHAR(50),
    @DeliveredQuantity DECIMAL(18,3),
    @AcceptedQuantity DECIMAL(18,3),
    @RejectedQuantity DECIMAL(18,3),
    @DamagedQuantity DECIMAL(18,3),
    @QualityBlockedQuantity DECIMAL(18,3),
    @AllowedVariancePercentage DECIMAL(9,4) = 5.0000,
    @VarianceReasonCode NVARCHAR(50) = NULL,
    @ExceptionApprovalStatus NVARCHAR(30) = 'NOT_REQUIRED'
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    -- ========================================================
    -- 1. Input Validation
    -- ========================================================

    IF NULLIF(LTRIM(RTRIM(@UserCode)), '') IS NULL
        THROW 52001, 'UserCode is required.', 1;

    IF NULLIF(LTRIM(RTRIM(@PurchaseOrderCode)), '') IS NULL
        THROW 52002, 'PurchaseOrderCode is required.', 1;

    IF NULLIF(LTRIM(RTRIM(@ProductCode)), '') IS NULL
        THROW 52003, 'ProductCode is required.', 1;

    IF NULLIF(LTRIM(RTRIM(@WarehouseCode)), '') IS NULL
        THROW 52004, 'WarehouseCode is required.', 1;

    IF NULLIF(LTRIM(RTRIM(@BatchNumber)), '') IS NULL
        THROW 52005, 'BatchNumber is required.', 1;

    IF @DeliveredQuantity IS NULL OR @DeliveredQuantity < 0
        THROW 52006, 'DeliveredQuantity cannot be negative.', 1;

    IF @AcceptedQuantity IS NULL OR @AcceptedQuantity < 0
        THROW 52007, 'AcceptedQuantity cannot be negative.', 1;

    IF @RejectedQuantity IS NULL OR @RejectedQuantity < 0
        THROW 52008, 'RejectedQuantity cannot be negative.', 1;

    IF @DamagedQuantity IS NULL OR @DamagedQuantity < 0
        THROW 52009, 'DamagedQuantity cannot be negative.', 1;

    IF @QualityBlockedQuantity IS NULL
       OR @QualityBlockedQuantity < 0
        THROW 52010, 'QualityBlockedQuantity cannot be negative.', 1;

    IF @AllowedVariancePercentage IS NULL
       OR @AllowedVariancePercentage < 0
        THROW 52011, 'AllowedVariancePercentage cannot be negative.', 1;

    IF @ExceptionApprovalStatus NOT IN (
        'NOT_REQUIRED',
        'PENDING',
        'APPROVED',
        'REJECTED'
    )
        THROW 52012, 'ExceptionApprovalStatus is not valid.', 1;

    -- ========================================================
    -- 2. Working Variables
    -- ========================================================

    DECLARE
        @UserID INT,
        @IsUserActive BIT,
        @HasWarehouseRole BIT,
        @PurchaseOrderID INT,
        @PurchaseOrderLineID INT,
        @PurchaseOrderStatus NVARCHAR(30),
        @PurchaseOrderWarehouseID INT,
        @ProductID INT,
        @OrderedQuantity DECIMAL(18,3),
        @WarehouseID INT,
        @BatchID INT,
        @BatchProductID INT,
        @BatchQualityStatus NVARCHAR(30),
        @QuantityBreakdownTotal DECIMAL(18,3),
        @VarianceQuantity DECIMAL(18,3),
        @VariancePercentage DECIMAL(9,4),
        @AbsoluteVariancePercentage DECIMAL(9,4),
        @RequiresExceptionApproval BIT,
        @ValidationStatus NVARCHAR(40),
        @ValidationMessage NVARCHAR(500);

    -- ========================================================
    -- 3. Resolve User and Master Data
    -- ========================================================

    SELECT
        @UserID = u.UserID,
        @IsUserActive = u.IsActive
    FROM dbo.ApplicationUsers AS u
    WHERE u.UserCode = @UserCode;

    SELECT
        @HasWarehouseRole =
            CASE
                WHEN EXISTS (
                    SELECT 1
                    FROM dbo.UserRoles AS ur
                    INNER JOIN dbo.Roles AS r
                        ON r.RoleID = ur.RoleID
                    WHERE ur.UserID = @UserID
                      AND r.RoleCode IN (
                          'WAREHOUSE_USER',
                          'WAREHOUSE_MANAGER',
                          'ADMIN'
                      )
                )
                THEN 1
                ELSE 0
            END;

    SELECT
        @WarehouseID = w.WarehouseID
    FROM dbo.Warehouses AS w
    WHERE w.WarehouseCode = @WarehouseCode;

    SELECT
        @ProductID = p.ProductID
    FROM dbo.Products AS p
    WHERE p.ProductCode = @ProductCode;

    SELECT
        @PurchaseOrderID = po.PurchaseOrderID,
        @PurchaseOrderStatus = po.PurchaseOrderStatus,
        @PurchaseOrderWarehouseID = po.WarehouseID
    FROM dbo.PurchaseOrders AS po
    WHERE po.PurchaseOrderCode = @PurchaseOrderCode;

    SELECT TOP (1)
        @PurchaseOrderLineID = pol.PurchaseOrderLineID,
        @OrderedQuantity = pol.Quantity
    FROM dbo.PurchaseOrderLines AS pol
    WHERE pol.PurchaseOrderID = @PurchaseOrderID
      AND pol.ProductID = @ProductID
    ORDER BY pol.PurchaseOrderLineID;

    SELECT
        @BatchID = b.BatchID,
        @BatchProductID = b.ProductID,
        @BatchQualityStatus = b.QualityStatus
    FROM dbo.ProductBatches AS b
    WHERE b.BatchNumber = @BatchNumber
      AND b.ProductID = @ProductID;

    -- ========================================================
    -- 4. Calculated Values
    -- ========================================================

    SET @QuantityBreakdownTotal =
          @AcceptedQuantity
        + @RejectedQuantity
        + @DamagedQuantity
        + @QualityBlockedQuantity;

    SET @VarianceQuantity =
        CASE
            WHEN @OrderedQuantity IS NULL THEN NULL
            ELSE @DeliveredQuantity - @OrderedQuantity
        END;

    SET @VariancePercentage =
        CASE
            WHEN @OrderedQuantity IS NULL
              OR @OrderedQuantity = 0
            THEN NULL
            ELSE CAST(
                (
                    (@DeliveredQuantity - @OrderedQuantity)
                    / @OrderedQuantity
                ) * 100
                AS DECIMAL(9,4)
            )
        END;

    SET @AbsoluteVariancePercentage =
        CASE
            WHEN @VariancePercentage IS NULL THEN NULL
            WHEN @VariancePercentage < 0
            THEN @VariancePercentage * -1
            ELSE @VariancePercentage
        END;

    SET @RequiresExceptionApproval =
        CASE
            WHEN @AbsoluteVariancePercentage
                    > @AllowedVariancePercentage
            THEN 1
            ELSE 0
        END;

    -- ========================================================
    -- 5. Validation Result Table
    -- ========================================================

    DECLARE @ValidationResults TABLE (
        CheckOrder INT NOT NULL,
        CheckCode NVARCHAR(60) NOT NULL,
        CheckDescription NVARCHAR(300) NOT NULL,
        ExpectedResult NVARCHAR(300) NOT NULL,
        ActualResult NVARCHAR(500) NOT NULL,
        CheckStatus NVARCHAR(10) NOT NULL
    );

    -- ========================================================
    -- 6. User and Authorization Checks
    -- ========================================================

    INSERT INTO @ValidationResults
    VALUES (
        1,
        'USER_EXISTS',
        'The requesting application user must exist.',
        'A valid application user',
        CASE
            WHEN @UserID IS NULL
            THEN CONCAT('User not found: ', @UserCode)
            ELSE CONCAT(
                'UserID=',
                @UserID,
                ' / UserCode=',
                @UserCode
            )
        END,
        CASE
            WHEN @UserID IS NOT NULL THEN 'PASS'
            ELSE 'FAIL'
        END
    );

    INSERT INTO @ValidationResults
    VALUES (
        2,
        'USER_ACTIVE',
        'The requesting application user must be active.',
        'IsActive = 1',
        CASE
            WHEN @UserID IS NULL
            THEN 'User could not be evaluated'
            ELSE CONCAT('IsActive=', @IsUserActive)
        END,
        CASE
            WHEN @UserID IS NOT NULL
             AND @IsUserActive = 1
            THEN 'PASS'
            ELSE 'FAIL'
        END
    );

    INSERT INTO @ValidationResults
    VALUES (
        3,
        'WAREHOUSE_ROLE',
        'The user must be authorized to record a goods receipt.',
        'WAREHOUSE_USER, WAREHOUSE_MANAGER or ADMIN role',
        CASE
            WHEN @UserID IS NULL
            THEN 'User role could not be evaluated'
            WHEN @HasWarehouseRole = 1
            THEN 'Authorized warehouse role found'
            ELSE 'Required warehouse role not found'
        END,
        CASE
            WHEN @HasWarehouseRole = 1 THEN 'PASS'
            ELSE 'FAIL'
        END
    );

    -- ========================================================
    -- 7. Purchase Order and Product Checks
    -- ========================================================

    INSERT INTO @ValidationResults
    VALUES (
        4,
        'PURCHASE_ORDER_EXISTS',
        'The purchase order must exist.',
        'A valid purchase order',
        CASE
            WHEN @PurchaseOrderID IS NULL
            THEN CONCAT(
                'Purchase order not found: ',
                @PurchaseOrderCode
            )
            ELSE CONCAT(
                'PurchaseOrderID=',
                @PurchaseOrderID,
                ' / Code=',
                @PurchaseOrderCode
            )
        END,
        CASE
            WHEN @PurchaseOrderID IS NOT NULL THEN 'PASS'
            ELSE 'FAIL'
        END
    );

    INSERT INTO @ValidationResults
    VALUES (
        5,
        'PURCHASE_ORDER_STATUS',
        'The purchase order must be open for receipt processing.',
        'Purchase order status must be Open',
        CASE
            WHEN @PurchaseOrderID IS NULL
            THEN 'Purchase order status could not be evaluated'
            ELSE CONCAT(
                'PurchaseOrderStatus=',
                @PurchaseOrderStatus
            )
        END,
        CASE
            WHEN @PurchaseOrderID IS NOT NULL
             AND UPPER(@PurchaseOrderStatus) = 'OPEN'
            THEN 'PASS'
            ELSE 'FAIL'
        END
    );

    INSERT INTO @ValidationResults
    VALUES (
        6,
        'PRODUCT_EXISTS',
        'The selected product must exist.',
        'A valid product',
        CASE
            WHEN @ProductID IS NULL
            THEN CONCAT('Product not found: ', @ProductCode)
            ELSE CONCAT(
                'ProductID=',
                @ProductID,
                ' / ProductCode=',
                @ProductCode
            )
        END,
        CASE
            WHEN @ProductID IS NOT NULL THEN 'PASS'
            ELSE 'FAIL'
        END
    );

    INSERT INTO @ValidationResults
    VALUES (
        7,
        'PURCHASE_ORDER_LINE_EXISTS',
        'The purchase order must contain the selected product.',
        'A matching purchase order line',
        CASE
            WHEN @PurchaseOrderLineID IS NULL
            THEN 'Matching purchase order line not found'
            ELSE CONCAT(
                'PurchaseOrderLineID=',
                @PurchaseOrderLineID,
                ' / OrderedQuantity=',
                @OrderedQuantity
            )
        END,
        CASE
            WHEN @PurchaseOrderLineID IS NOT NULL THEN 'PASS'
            ELSE 'FAIL'
        END
    );

    -- ========================================================
    -- 8. Warehouse and Batch Checks
    -- ========================================================

    INSERT INTO @ValidationResults
    VALUES (
        8,
        'WAREHOUSE_EXISTS',
        'The selected warehouse must exist.',
        'A valid warehouse',
        CASE
            WHEN @WarehouseID IS NULL
            THEN CONCAT('Warehouse not found: ', @WarehouseCode)
            ELSE CONCAT(
                'WarehouseID=',
                @WarehouseID,
                ' / WarehouseCode=',
                @WarehouseCode
            )
        END,
        CASE
            WHEN @WarehouseID IS NOT NULL THEN 'PASS'
            ELSE 'FAIL'
        END
    );

    INSERT INTO @ValidationResults
    VALUES (
        9,
        'PURCHASE_ORDER_WAREHOUSE',
        'The selected warehouse must match the purchase order warehouse.',
        'Selected WarehouseID = Purchase Order WarehouseID',
        CASE
            WHEN @PurchaseOrderID IS NULL
              OR @WarehouseID IS NULL
            THEN 'Warehouse comparison could not be evaluated'
            ELSE CONCAT(
                'SelectedWarehouseID=',
                @WarehouseID,
                ' / PurchaseOrderWarehouseID=',
                @PurchaseOrderWarehouseID
            )
        END,
        CASE
            WHEN @PurchaseOrderID IS NOT NULL
             AND @WarehouseID IS NOT NULL
             AND @WarehouseID = @PurchaseOrderWarehouseID
            THEN 'PASS'
            ELSE 'FAIL'
        END
    );

    INSERT INTO @ValidationResults
    VALUES (
        10,
        'BATCH_EXISTS',
        'The selected batch must belong to the received product.',
        'A matching product and batch record',
        CASE
            WHEN @BatchID IS NULL
            THEN CONCAT(
                'Batch not found for product: ',
                @BatchNumber,
                ' / ',
                @ProductCode
            )
            ELSE CONCAT(
                'BatchID=',
                @BatchID,
                ' / BatchNumber=',
                @BatchNumber
            )
        END,
        CASE
            WHEN @BatchID IS NOT NULL
             AND @BatchProductID = @ProductID
            THEN 'PASS'
            ELSE 'FAIL'
        END
    );

    -- ========================================================
    -- 9. Quantity Integrity Checks
    -- ========================================================

    INSERT INTO @ValidationResults
    VALUES (
        11,
        'DELIVERED_QUANTITY',
        'Delivered quantity must be greater than zero.',
        'DeliveredQuantity > 0',
        CONCAT(
            'DeliveredQuantity=',
            @DeliveredQuantity
        ),
        CASE
            WHEN @DeliveredQuantity > 0 THEN 'PASS'
            ELSE 'FAIL'
        END
    );

    INSERT INTO @ValidationResults
    VALUES (
        12,
        'QUANTITY_BREAKDOWN',
        'The receipt quantity breakdown must equal the delivered quantity.',
        'Accepted + Rejected + Damaged + QualityBlocked = Delivered',
        CONCAT(
            'BreakdownTotal=',
            @QuantityBreakdownTotal,
            ' / DeliveredQuantity=',
            @DeliveredQuantity
        ),
        CASE
            WHEN @QuantityBreakdownTotal = @DeliveredQuantity
            THEN 'PASS'
            ELSE 'FAIL'
        END
    );

    INSERT INTO @ValidationResults
    VALUES (
        13,
        'ORDER_VARIANCE',
        'The delivery variance must be within tolerance or receive exception approval.',
        CONCAT(
            'Absolute variance <= ',
            @AllowedVariancePercentage,
            '% or ExceptionApprovalStatus = APPROVED'
        ),
        CASE
            WHEN @OrderedQuantity IS NULL
            THEN 'Variance could not be calculated'
            ELSE CONCAT(
                'Ordered=',
                @OrderedQuantity,
                ' / Delivered=',
                @DeliveredQuantity,
                ' / VarianceQuantity=',
                @VarianceQuantity,
                ' / VariancePercentage=',
                @VariancePercentage,
                '% / ApprovalStatus=',
                @ExceptionApprovalStatus
            )
        END,
        CASE
            WHEN @OrderedQuantity IS NULL
            THEN 'FAIL'

            WHEN @AbsoluteVariancePercentage
                    <= @AllowedVariancePercentage
            THEN 'PASS'

            WHEN @AbsoluteVariancePercentage
                    > @AllowedVariancePercentage
             AND @ExceptionApprovalStatus = 'APPROVED'
            THEN 'PASS'

            ELSE 'FAIL'
        END
    );

    INSERT INTO @ValidationResults
    VALUES (
        14,
        'VARIANCE_REASON',
        'A reason code must be provided when the delivery differs from the order.',
        'VarianceReasonCode is required when variance is not zero',
        CASE
            WHEN @VarianceQuantity IS NULL
            THEN 'Variance could not be evaluated'
            WHEN @VarianceQuantity = 0
            THEN 'No variance reason required'
            WHEN NULLIF(LTRIM(RTRIM(@VarianceReasonCode)), '') IS NULL
            THEN 'Variance reason was not provided'
            ELSE CONCAT(
                'VarianceReasonCode=',
                @VarianceReasonCode
            )
        END,
        CASE
            WHEN @VarianceQuantity = 0
            THEN 'PASS'

            WHEN @VarianceQuantity <> 0
             AND NULLIF(
                    LTRIM(RTRIM(@VarianceReasonCode)),
                    ''
                 ) IS NOT NULL
            THEN 'PASS'

            ELSE 'FAIL'
        END
    );

    -- ========================================================
    -- 10. Stock Classification Checks
    -- ========================================================

    INSERT INTO @ValidationResults
    VALUES (
        15,
        'AVAILABLE_STOCK_QUANTITY',
        'Only the accepted quantity may enter available stock.',
        'Available stock movement quantity = AcceptedQuantity',
        CONCAT(
            'AcceptedQuantity=',
            @AcceptedQuantity
        ),
        CASE
            WHEN @AcceptedQuantity >= 0 THEN 'PASS'
            ELSE 'FAIL'
        END
    );

    INSERT INTO @ValidationResults
    VALUES (
        16,
        'QUALITY_BLOCK_CLASSIFICATION',
        'Quality-blocked quantity must remain separate from available stock.',
        'QualityBlockedQuantity must not be included in AcceptedQuantity',
        CONCAT(
            'AcceptedQuantity=',
            @AcceptedQuantity,
            ' / QualityBlockedQuantity=',
            @QualityBlockedQuantity,
            ' / BatchQualityStatus=',
            COALESCE(@BatchQualityStatus, 'NOT_FOUND')
        ),
        CASE
            WHEN @QualityBlockedQuantity = 0
            THEN 'PASS'

            WHEN @QualityBlockedQuantity > 0
             AND @AcceptedQuantity
                    + @RejectedQuantity
                    + @DamagedQuantity
                    + @QualityBlockedQuantity
                    = @DeliveredQuantity
            THEN 'PASS'

            ELSE 'FAIL'
        END
    );

    -- ========================================================
    -- 11. Final Decision
    -- ========================================================

    DECLARE
        @TotalCheckCount INT,
        @PassedCheckCount INT,
        @FailedCheckCount INT;

    SELECT
        @TotalCheckCount = COUNT(*),
        @PassedCheckCount = SUM(
            CASE
                WHEN CheckStatus = 'PASS' THEN 1
                ELSE 0
            END
        ),
        @FailedCheckCount = SUM(
            CASE
                WHEN CheckStatus = 'FAIL' THEN 1
                ELSE 0
            END
        )
    FROM @ValidationResults;

    SET @ValidationStatus =
        CASE
            WHEN @FailedCheckCount = 0
            THEN 'APPROVED'

            WHEN @FailedCheckCount > 0
             AND @RequiresExceptionApproval = 1
             AND @ExceptionApprovalStatus = 'PENDING'
             AND NOT EXISTS (
                    SELECT 1
                    FROM @ValidationResults
                    WHERE CheckStatus = 'FAIL'
                      AND CheckCode <> 'ORDER_VARIANCE'
                )
            THEN 'PENDING_EXCEPTION_APPROVAL'

            ELSE 'REJECTED'
        END;

    SET @ValidationMessage =
        CASE
            WHEN @ValidationStatus = 'APPROVED'
            THEN
                'Goods receipt validation completed successfully.'

            WHEN @ValidationStatus = 'PENDING_EXCEPTION_APPROVAL'
            THEN
                'The delivery variance exceeds tolerance and requires warehouse manager approval.'

            ELSE
                CONCAT(
                    'Goods receipt validation failed with ',
                    @FailedCheckCount,
                    ' failed check(s).'
                )
        END;

    -- ========================================================
    -- 12. Detailed Validation Results
    -- ========================================================

    SELECT
        CheckOrder,
        CheckCode,
        CheckDescription,
        ExpectedResult,
        ActualResult,
        CheckStatus
    FROM @ValidationResults
    ORDER BY CheckOrder;

    -- ========================================================
    -- 13. Validation Summary
    -- ========================================================

    SELECT
        @ValidationStatus AS ValidationStatus,
        @ValidationMessage AS ValidationMessage,
        @TotalCheckCount AS TotalChecks,
        @PassedCheckCount AS PassedChecks,
        @FailedCheckCount AS FailedChecks,
        @RequiresExceptionApproval
            AS RequiresExceptionApproval,
        @ExceptionApprovalStatus
            AS ExceptionApprovalStatus,
        @OrderedQuantity AS OrderedQuantity,
        @DeliveredQuantity AS DeliveredQuantity,
        @AcceptedQuantity AS AcceptedQuantity,
        @RejectedQuantity AS RejectedQuantity,
        @DamagedQuantity AS DamagedQuantity,
        @QualityBlockedQuantity
            AS QualityBlockedQuantity,
        @VarianceQuantity AS VarianceQuantity,
        @VariancePercentage AS VariancePercentage,
        @AllowedVariancePercentage
            AS AllowedVariancePercentage,
        @VarianceReasonCode AS VarianceReasonCode,
        @BatchQualityStatus AS BatchQualityStatus;
END;
GO

-- ============================================================
-- Procedure Verification
-- ============================================================

SELECT
    SCHEMA_NAME(p.schema_id) AS SchemaName,
    p.name AS ProcedureName,
    p.create_date AS CreatedAt,
    p.modify_date AS ModifiedAt
FROM sys.procedures AS p
WHERE p.object_id =
    OBJECT_ID('dbo.usp_ValidateGoodsReceipt');
GO