const {
    sql,
    getDatabasePool
  } = require('../config/database');
  
  async function validateSalesOrder(payload) {
    const pool = await getDatabasePool();
  
    const result = await pool
      .request()
      .input('UserCode', sql.NVarChar(30), payload.userCode)
      .input('CustomerCode', sql.NVarChar(30), payload.customerCode)
      .input('ProductCode', sql.NVarChar(30), payload.productCode)
      .input('BatchNumber', sql.NVarChar(50), payload.batchNumber)
      .input('WarehouseCode', sql.NVarChar(30), payload.warehouseCode)
      .input(
        'RequestedQuantity',
        sql.Decimal(18, 3),
        payload.requestedQuantity
      )
      .input(
        'OrderAmount',
        sql.Decimal(18, 2),
        payload.orderAmount
      )
      .input(
        'FinanceApprovalStatus',
        sql.NVarChar(30),
        payload.financeApprovalStatus || 'NOT_REQUIRED'
      )
      .execute('dbo.usp_ValidateSalesOrder');
  
    const validationChecks = result.recordsets?.[0] || [];
    const validationSummary = result.recordsets?.[1]?.[0] || null;
  
    if (!validationSummary) {
      throw new Error(
        'Sales order validation summary was not returned by the database.'
      );
    }
  
    return {
      validationStatus: validationSummary.ValidationStatus,
      validationMessage: validationSummary.ValidationMessage,
      totals: {
        totalChecks: validationSummary.TotalChecks,
        passedChecks: validationSummary.PassedChecks,
        failedChecks: validationSummary.FailedChecks
      },
      approval: {
        requiresFinanceApproval:
          Boolean(validationSummary.RequiresFinanceApproval),
        financeApprovalStatus:
          validationSummary.FinanceApprovalStatus
      },
      inventory: {
        availableQuantity:
          validationSummary.AvailableQuantity,
        requestedQuantity:
          validationSummary.RequestedQuantity
      },
      credit: {
        creditLimit: validationSummary.CreditLimit,
        currentExposure:
          validationSummary.CurrentExposure,
        orderAmount: validationSummary.OrderAmount,
        projectedExposure:
          validationSummary.ProjectedExposure,
        remainingCreditLimit:
          validationSummary.RemainingCreditLimit
      },
      shelfLife: {
        remainingShelfLifeDays:
          validationSummary.RemainingShelfLifeDays,
        minimumShelfLifeDays:
          validationSummary.MinimumShelfLifeDays
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
    validateSalesOrder
  };