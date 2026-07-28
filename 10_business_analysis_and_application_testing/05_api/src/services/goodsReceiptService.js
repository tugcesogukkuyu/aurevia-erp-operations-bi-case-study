const {
    sql,
    getDatabasePool
  } = require('../config/database');
  
  async function validateGoodsReceipt(payload) {
    const pool = await getDatabasePool();
  
    const result = await pool
      .request()
      .input('UserCode', sql.NVarChar(30), payload.userCode)
      .input(
        'PurchaseOrderCode',
        sql.NVarChar(30),
        payload.purchaseOrderCode
      )
      .input(
        'ProductCode',
        sql.NVarChar(30),
        payload.productCode
      )
      .input(
        'WarehouseCode',
        sql.NVarChar(30),
        payload.warehouseCode
      )
      .input(
        'BatchNumber',
        sql.NVarChar(50),
        payload.batchNumber
      )
      .input(
        'DeliveredQuantity',
        sql.Decimal(18, 3),
        payload.deliveredQuantity
      )
      .input(
        'AcceptedQuantity',
        sql.Decimal(18, 3),
        payload.acceptedQuantity
      )
      .input(
        'RejectedQuantity',
        sql.Decimal(18, 3),
        payload.rejectedQuantity
      )
      .input(
        'DamagedQuantity',
        sql.Decimal(18, 3),
        payload.damagedQuantity
      )
      .input(
        'QualityBlockedQuantity',
        sql.Decimal(18, 3),
        payload.qualityBlockedQuantity
      )
      .input(
        'AllowedVariancePercentage',
        sql.Decimal(9, 4),
        payload.allowedVariancePercentage
      )
      .input(
        'VarianceReasonCode',
        sql.NVarChar(50),
        payload.varianceReasonCode || null
      )
      .input(
        'ExceptionApprovalStatus',
        sql.NVarChar(30),
        payload.exceptionApprovalStatus || 'NOT_REQUIRED'
      )
      .execute('dbo.usp_ValidateGoodsReceipt');
  
    const validationChecks = result.recordsets?.[0] || [];
    const validationSummary = result.recordsets?.[1]?.[0] || null;
  
    if (!validationSummary) {
      throw new Error(
        'Goods receipt validation summary was not returned by the database.'
      );
    }
  
    return {
      validationStatus:
        validationSummary.ValidationStatus,
      validationMessage:
        validationSummary.ValidationMessage,
      totals: {
        totalChecks: validationSummary.TotalChecks,
        passedChecks: validationSummary.PassedChecks,
        failedChecks: validationSummary.FailedChecks
      },
      approval: {
        requiresExceptionApproval:
          Boolean(
            validationSummary.RequiresExceptionApproval
          ),
        exceptionApprovalStatus:
          validationSummary.ExceptionApprovalStatus
      },
      quantities: {
        orderedQuantity:
          validationSummary.OrderedQuantity,
        deliveredQuantity:
          validationSummary.DeliveredQuantity,
        acceptedQuantity:
          validationSummary.AcceptedQuantity,
        rejectedQuantity:
          validationSummary.RejectedQuantity,
        damagedQuantity:
          validationSummary.DamagedQuantity,
        qualityBlockedQuantity:
          validationSummary.QualityBlockedQuantity
      },
      variance: {
        varianceQuantity:
          validationSummary.VarianceQuantity,
        variancePercentage:
          validationSummary.VariancePercentage,
        allowedVariancePercentage:
          validationSummary.AllowedVariancePercentage,
        varianceReasonCode:
          validationSummary.VarianceReasonCode
      },
      batch: {
        qualityStatus:
          validationSummary.BatchQualityStatus
      },
      checks: validationChecks.map((check) => ({
        order: check.CheckOrder,
        code: check.CheckCode,
        description: check.CheckDescription,
        expectedResult: check.ExpectedResult,
        actualResult: check.ActualResult,
        status: check.CheckStatus
      }))
    };
  }
  
  module.exports = {
    validateGoodsReceipt
  };