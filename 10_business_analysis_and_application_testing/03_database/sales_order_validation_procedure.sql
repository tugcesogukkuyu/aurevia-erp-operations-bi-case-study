-- ============================================================
-- Aurevia ERP Application Control and Testing Case
-- Sales Order Validation Procedure
-- Microsoft SQL Server
-- ============================================================

USE AureviaERPBI;
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.usp_ValidateSalesOrder
    @UserCode NVARCHAR(30),
    @CustomerCode NVARCHAR(30),
    @ProductCode NVARCHAR(30),
    @BatchNumber NVARCHAR(50),
    @WarehouseCode NVARCHAR(30),
    @RequestedQuantity DECIMAL(18,3),
    @OrderAmount DECIMAL(18,2),
    @FinanceApprovalStatus NVARCHAR(30) = 'NOT_REQUIRED'
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    -- ========================================================
    -- 1. Input Validation
    -- ========================================================

    IF NULLIF(LTRIM(RTRIM(@UserCode)), '') IS NULL
        THROW 51001, 'UserCode is required.', 1;

    IF NULLIF(LTRIM(RTRIM(@CustomerCode)), '') IS NULL
        THROW 51002, 'CustomerCode is required.', 1;

    IF NULLIF(LTRIM(RTRIM(@ProductCode)), '') IS NULL
        THROW 51003, 'ProductCode is required.', 1;

    IF NULLIF(LTRIM(RTRIM(@BatchNumber)), '') IS NULL
        THROW 51004, 'BatchNumber is required.', 1;

    IF NULLIF(LTRIM(RTRIM(@WarehouseCode)), '') IS NULL
        THROW 51005, 'WarehouseCode is required.', 1;

    IF @RequestedQuantity IS NULL OR @RequestedQuantity <= 0
        THROW 51006, 'RequestedQuantity must be greater than zero.', 1;

    IF @OrderAmount IS NULL OR @OrderAmount < 0
        THROW 51007, 'OrderAmount cannot be negative.', 1;

    IF @FinanceApprovalStatus NOT IN (
        'NOT_REQUIRED',
        'PENDING',
        'APPROVED',
        'REJECTED'
    )
        THROW 51008, 'FinanceApprovalStatus is not valid.', 1;

    -- ========================================================
    -- 2. Working Variables
    -- ========================================================

    DECLARE
        @UserID INT,
        @IsUserActive BIT,
        @CustomerID INT,
        @ProductID INT,
        @IsBatchTracked BIT,
        @BatchID INT,
        @BatchQualityStatus NVARCHAR(30),
        @ExpirationDate DATE,
        @WarehouseID INT,
        @IsSalesEligible BIT,
        @PhysicalQuantity DECIMAL(18,3),
        @ReservedQuantity DECIMAL(18,3),
        @AvailableQuantity DECIMAL(18,3),
        @MinimumShelfLifeDays INT,
        @RemainingShelfLifeDays INT,
        @CreditLimit DECIMAL(18,2),
        @CurrentExposure DECIMAL(18,2),
        @RemainingCreditLimit DECIMAL(18,2),
        @IsCreditBlocked BIT,
        @ProjectedExposure DECIMAL(18,2),
        @RequiresFinanceApproval BIT,
        @HasApprovalRole BIT,
        @ValidationStatus NVARCHAR(30),
        @ValidationMessage NVARCHAR(500);

    -- ========================================================
    -- 3. Resolve Master Data
    -- ========================================================

    SELECT
        @UserID = u.UserID,
        @IsUserActive = u.IsActive
    FROM dbo.ApplicationUsers AS u
    WHERE u.UserCode = @UserCode;

    SELECT
        @CustomerID = c.CustomerID,
        @MinimumShelfLifeDays = c.MinimumShelfLifeDays
    FROM dbo.Customers AS c
    WHERE c.CustomerCode = @CustomerCode;

    SELECT
        @ProductID = p.ProductID,
        @IsBatchTracked = p.IsBatchTracked
    FROM dbo.Products AS p
    WHERE p.ProductCode = @ProductCode;

    SELECT
        @WarehouseID = w.WarehouseID,
        @IsSalesEligible = w.IsSalesEligible
    FROM dbo.Warehouses AS w
    WHERE w.WarehouseCode = @WarehouseCode;

    SELECT
        @BatchID = b.BatchID,
        @BatchQualityStatus = b.QualityStatus,
        @ExpirationDate = b.ExpirationDate
    FROM dbo.ProductBatches AS b
    WHERE b.BatchNumber = @BatchNumber
      AND b.ProductID = @ProductID;

    SELECT
        @PhysicalQuantity = i.PhysicalQuantity,
        @ReservedQuantity = i.ReservedQuantity,
        @AvailableQuantity = i.AvailableQuantity
    FROM dbo.InventoryBalances AS i
    WHERE i.ProductID = @ProductID
      AND i.BatchID = @BatchID
      AND i.WarehouseID = @WarehouseID;

    SELECT
        @CreditLimit = cp.CreditLimit,
        @CurrentExposure = cp.CurrentExposure,
        @IsCreditBlocked = cp.IsCreditBlocked
    FROM dbo.CustomerCreditProfiles AS cp
    WHERE cp.CustomerID = @CustomerID;

    SET @RemainingShelfLifeDays =
        CASE
            WHEN @ExpirationDate IS NULL THEN NULL
            ELSE DATEDIFF(
                DAY,
                CAST(GETDATE() AS DATE),
                @ExpirationDate
            )
        END;

    SET @RemainingCreditLimit =
        CASE
            WHEN @CreditLimit IS NULL
              OR @CurrentExposure IS NULL
            THEN NULL
            ELSE @CreditLimit - @CurrentExposure
        END;

    SET @ProjectedExposure =
        CASE
            WHEN @CurrentExposure IS NULL THEN NULL
            ELSE @CurrentExposure + @OrderAmount
        END;

    SET @RequiresFinanceApproval =
        CASE
            WHEN @CreditLimit IS NOT NULL
             AND @ProjectedExposure > @CreditLimit
            THEN 1
            ELSE 0
        END;

    SELECT
        @HasApprovalRole =
            CASE
                WHEN EXISTS (
                    SELECT 1
                    FROM dbo.UserRoles AS ur
                    INNER JOIN dbo.Roles AS r
                        ON r.RoleID = ur.RoleID
                    WHERE ur.UserID = @UserID
                      AND r.RoleCode IN (
                          'SALES_MANAGER',
                          'ADMIN'
                      )
                )
                THEN 1
                ELSE 0
            END;

    -- ========================================================
    -- 4. Validation Result Table
    -- ========================================================

    DECLARE @ValidationResults TABLE (
        CheckOrder INT NOT NULL,
        CheckCode NVARCHAR(50) NOT NULL,
        CheckDescription NVARCHAR(250) NOT NULL,
        ExpectedResult NVARCHAR(300) NOT NULL,
        ActualResult NVARCHAR(500) NOT NULL,
        CheckStatus NVARCHAR(10) NOT NULL
    );

    -- ========================================================
    -- 5. User and Authorization Checks
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
        'APPROVAL_ROLE',
        'The user must have authority to approve a sales order.',
        'SALES_MANAGER or ADMIN role',
        CASE
            WHEN @UserID IS NULL
            THEN 'User role could not be evaluated'
            WHEN @HasApprovalRole = 1
            THEN 'Authorized approval role found'
            ELSE 'Required approval role not found'
        END,
        CASE
            WHEN @HasApprovalRole = 1 THEN 'PASS'
            ELSE 'FAIL'
        END
    );

    -- ========================================================
    -- 6. Customer and Product Checks
    -- ========================================================

    INSERT INTO @ValidationResults
    VALUES (
        4,
        'CUSTOMER_EXISTS',
        'The customer must exist.',
        'A valid customer record',
        CASE
            WHEN @CustomerID IS NULL
            THEN CONCAT('Customer not found: ', @CustomerCode)
            ELSE CONCAT(
                'CustomerID=',
                @CustomerID,
                ' / CustomerCode=',
                @CustomerCode
            )
        END,
        CASE
            WHEN @CustomerID IS NOT NULL THEN 'PASS'
            ELSE 'FAIL'
        END
    );

    INSERT INTO @ValidationResults
    VALUES (
        5,
        'PRODUCT_EXISTS',
        'The product must exist.',
        'A valid product record',
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
        6,
        'BATCH_TRACKING',
        'The selected product must support batch-controlled processing.',
        'IsBatchTracked = 1',
        CASE
            WHEN @ProductID IS NULL
            THEN 'Product could not be evaluated'
            ELSE CONCAT('IsBatchTracked=', @IsBatchTracked)
        END,
        CASE
            WHEN @ProductID IS NOT NULL
             AND @IsBatchTracked = 1
            THEN 'PASS'
            ELSE 'FAIL'
        END
    );

    -- ========================================================
    -- 7. Warehouse and Batch Checks
    -- ========================================================

    INSERT INTO @ValidationResults
    VALUES (
        7,
        'WAREHOUSE_EXISTS',
        'The selected warehouse must exist.',
        'A valid warehouse record',
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
        8,
        'WAREHOUSE_SALES_ELIGIBILITY',
        'The warehouse must be eligible for sales reservations.',
        'IsSalesEligible = 1',
        CASE
            WHEN @WarehouseID IS NULL
            THEN 'Warehouse could not be evaluated'
            ELSE CONCAT('IsSalesEligible=', @IsSalesEligible)
        END,
        CASE
            WHEN @WarehouseID IS NOT NULL
             AND @IsSalesEligible = 1
            THEN 'PASS'
            ELSE 'FAIL'
        END
    );

    INSERT INTO @ValidationResults
    VALUES (
        9,
        'BATCH_EXISTS',
        'The selected batch must belong to the selected product.',
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
            WHEN @BatchID IS NOT NULL THEN 'PASS'
            ELSE 'FAIL'
        END
    );

    INSERT INTO @ValidationResults
    VALUES (
        10,
        'BATCH_QUALITY_STATUS',
        'The selected batch must be released for sales.',
        'QualityStatus = RELEASED',
        CASE
            WHEN @BatchID IS NULL
            THEN 'Batch quality could not be evaluated'
            ELSE CONCAT(
                'QualityStatus=',
                @BatchQualityStatus
            )
        END,
        CASE
            WHEN @BatchID IS NOT NULL
             AND @BatchQualityStatus = 'RELEASED'
            THEN 'PASS'
            ELSE 'FAIL'
        END
    );

    INSERT INTO @ValidationResults
    VALUES (
        11,
        'SHELF_LIFE_REQUIREMENT',
        'The remaining shelf life must meet the customer requirement.',
        CONCAT(
            'Remaining shelf life must be at least ',
            COALESCE(@MinimumShelfLifeDays, 0),
            ' day(s)'
        ),
        CASE
            WHEN @BatchID IS NULL
              OR @CustomerID IS NULL
            THEN 'Shelf life could not be evaluated'
            ELSE CONCAT(
                'Remaining=',
                @RemainingShelfLifeDays,
                ' day(s) / Required=',
                @MinimumShelfLifeDays,
                ' day(s)'
            )
        END,
        CASE
            WHEN @BatchID IS NOT NULL
             AND @CustomerID IS NOT NULL
             AND @RemainingShelfLifeDays
                    >= @MinimumShelfLifeDays
            THEN 'PASS'
            ELSE 'FAIL'
        END
    );

    -- ========================================================
    -- 8. Inventory Checks
    -- ========================================================

    INSERT INTO @ValidationResults
    VALUES (
        12,
        'INVENTORY_BALANCE_EXISTS',
        'An inventory balance must exist for the selected combination.',
        'Product, batch and warehouse inventory record',
        CASE
            WHEN @AvailableQuantity IS NULL
            THEN 'Matching inventory balance not found'
            ELSE CONCAT(
                'Physical=',
                @PhysicalQuantity,
                ' / Reserved=',
                @ReservedQuantity,
                ' / Available=',
                @AvailableQuantity
            )
        END,
        CASE
            WHEN @AvailableQuantity IS NOT NULL THEN 'PASS'
            ELSE 'FAIL'
        END
    );

    INSERT INTO @ValidationResults
    VALUES (
        13,
        'AVAILABLE_STOCK',
        'Available stock must cover the requested quantity.',
        CONCAT(
            'AvailableQuantity >= ',
            @RequestedQuantity
        ),
        CASE
            WHEN @AvailableQuantity IS NULL
            THEN 'Available stock could not be evaluated'
            ELSE CONCAT(
                'Available=',
                @AvailableQuantity,
                ' / Requested=',
                @RequestedQuantity
            )
        END,
        CASE
            WHEN @AvailableQuantity IS NOT NULL
             AND @AvailableQuantity >= @RequestedQuantity
            THEN 'PASS'
            ELSE 'FAIL'
        END
    );

    -- ========================================================
    -- 9. Credit Checks
    -- ========================================================

    INSERT INTO @ValidationResults
    VALUES (
        14,
        'CREDIT_PROFILE_EXISTS',
        'The customer must have a credit profile.',
        'A valid customer credit profile',
        CASE
            WHEN @CreditLimit IS NULL
            THEN 'Customer credit profile not found'
            ELSE CONCAT(
                'CreditLimit=',
                @CreditLimit,
                ' / CurrentExposure=',
                @CurrentExposure
            )
        END,
        CASE
            WHEN @CreditLimit IS NOT NULL THEN 'PASS'
            ELSE 'FAIL'
        END
    );

    INSERT INTO @ValidationResults
    VALUES (
        15,
        'CUSTOMER_CREDIT_BLOCK',
        'The customer must not be credit blocked.',
        'IsCreditBlocked = 0',
        CASE
            WHEN @CreditLimit IS NULL
            THEN 'Credit block status could not be evaluated'
            ELSE CONCAT(
                'IsCreditBlocked=',
                @IsCreditBlocked
            )
        END,
        CASE
            WHEN @CreditLimit IS NOT NULL
             AND @IsCreditBlocked = 0
            THEN 'PASS'
            ELSE 'FAIL'
        END
    );

    INSERT INTO @ValidationResults
    VALUES (
        16,
        'CREDIT_LIMIT',
        'The projected exposure must remain within the credit limit or receive finance approval.',
        'Within limit or FinanceApprovalStatus = APPROVED',
        CASE
            WHEN @CreditLimit IS NULL
            THEN 'Credit limit could not be evaluated'
            ELSE CONCAT(
                'Limit=',
                @CreditLimit,
                ' / CurrentExposure=',
                @CurrentExposure,
                ' / OrderAmount=',
                @OrderAmount,
                ' / ProjectedExposure=',
                @ProjectedExposure,
                ' / FinanceApprovalStatus=',
                @FinanceApprovalStatus
            )
        END,
        CASE
            WHEN @CreditLimit IS NULL
            THEN 'FAIL'

            WHEN @IsCreditBlocked = 1
            THEN 'FAIL'

            WHEN @ProjectedExposure <= @CreditLimit
            THEN 'PASS'

            WHEN @ProjectedExposure > @CreditLimit
             AND @FinanceApprovalStatus = 'APPROVED'
            THEN 'PASS'

            ELSE 'FAIL'
        END
    );

    -- ========================================================
    -- 10. Final Decision
    -- ========================================================

    DECLARE
        @FailedCheckCount INT,
        @PassedCheckCount INT,
        @TotalCheckCount INT;

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
             AND @RequiresFinanceApproval = 1
             AND @FinanceApprovalStatus = 'PENDING'
             AND NOT EXISTS (
                    SELECT 1
                    FROM @ValidationResults
                    WHERE CheckStatus = 'FAIL'
                      AND CheckCode <> 'CREDIT_LIMIT'
                )
            THEN 'PENDING_FINANCE_APPROVAL'

            ELSE 'REJECTED'
        END;

    SET @ValidationMessage =
        CASE
            WHEN @ValidationStatus = 'APPROVED'
            THEN
                'Sales order validation completed successfully.'

            WHEN @ValidationStatus = 'PENDING_FINANCE_APPROVAL'
            THEN
                'The order exceeds the available credit limit and requires finance approval.'

            ELSE
                CONCAT(
                    'Sales order validation failed with ',
                    @FailedCheckCount,
                    ' failed check(s).'
                )
        END;

    -- ========================================================
    -- 11. Detailed Result Set
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
    -- 12. Validation Summary
    -- ========================================================

    SELECT
        @ValidationStatus AS ValidationStatus,
        @ValidationMessage AS ValidationMessage,
        @TotalCheckCount AS TotalChecks,
        @PassedCheckCount AS PassedChecks,
        @FailedCheckCount AS FailedChecks,
        @RequiresFinanceApproval AS RequiresFinanceApproval,
        @FinanceApprovalStatus AS FinanceApprovalStatus,
        @AvailableQuantity AS AvailableQuantity,
        @RequestedQuantity AS RequestedQuantity,
        @CreditLimit AS CreditLimit,
        @CurrentExposure AS CurrentExposure,
        @OrderAmount AS OrderAmount,
        @ProjectedExposure AS ProjectedExposure,
        @RemainingCreditLimit AS RemainingCreditLimit,
        @RemainingShelfLifeDays AS RemainingShelfLifeDays,
        @MinimumShelfLifeDays AS MinimumShelfLifeDays;
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
    OBJECT_ID('dbo.usp_ValidateSalesOrder');
GO