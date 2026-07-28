const {
    validateGoodsReceipt
  } = require('../services/goodsReceiptService');
  
  const requiredFields = [
    'userCode',
    'purchaseOrderCode',
    'productCode',
    'warehouseCode',
    'batchNumber',
    'deliveredQuantity',
    'acceptedQuantity',
    'rejectedQuantity',
    'damagedQuantity',
    'qualityBlockedQuantity'
  ];
  
  function findMissingFields(body) {
    return requiredFields.filter((field) => {
      const value = body[field];
  
      return (
        value === undefined ||
        value === null ||
        value === ''
      );
    });
  }
  
  function parseNonNegativeNumber(value) {
    const parsedValue = Number(value);
  
    if (
      !Number.isFinite(parsedValue) ||
      parsedValue < 0
    ) {
      return null;
    }
  
    return parsedValue;
  }
  
  async function validateGoodsReceiptController(
    req,
    res
  ) {
    try {
      const missingFields = findMissingFields(
        req.body
      );
  
      if (missingFields.length > 0) {
        return res.status(400).json({
          status: 'error',
          message:
            'Required request fields are missing.',
          missingFields
        });
      }
  
      const deliveredQuantity =
        parseNonNegativeNumber(
          req.body.deliveredQuantity
        );
  
      const acceptedQuantity =
        parseNonNegativeNumber(
          req.body.acceptedQuantity
        );
  
      const rejectedQuantity =
        parseNonNegativeNumber(
          req.body.rejectedQuantity
        );
  
      const damagedQuantity =
        parseNonNegativeNumber(
          req.body.damagedQuantity
        );
  
      const qualityBlockedQuantity =
        parseNonNegativeNumber(
          req.body.qualityBlockedQuantity
        );
  
      const allowedVariancePercentage =
        req.body.allowedVariancePercentage ===
        undefined
          ? 5
          : parseNonNegativeNumber(
              req.body.allowedVariancePercentage
            );
  
      if (deliveredQuantity === null) {
        return res.status(400).json({
          status: 'error',
          message:
            'deliveredQuantity must be a non-negative number.'
        });
      }
  
      if (acceptedQuantity === null) {
        return res.status(400).json({
          status: 'error',
          message:
            'acceptedQuantity must be a non-negative number.'
        });
      }
  
      if (rejectedQuantity === null) {
        return res.status(400).json({
          status: 'error',
          message:
            'rejectedQuantity must be a non-negative number.'
        });
      }
  
      if (damagedQuantity === null) {
        return res.status(400).json({
          status: 'error',
          message:
            'damagedQuantity must be a non-negative number.'
        });
      }
  
      if (qualityBlockedQuantity === null) {
        return res.status(400).json({
          status: 'error',
          message:
            'qualityBlockedQuantity must be a non-negative number.'
        });
      }
  
      if (allowedVariancePercentage === null) {
        return res.status(400).json({
          status: 'error',
          message:
            'allowedVariancePercentage must be a non-negative number.'
        });
      }
  
      const allowedApprovalStatuses = [
        'NOT_REQUIRED',
        'PENDING',
        'APPROVED',
        'REJECTED'
      ];
  
      const exceptionApprovalStatus =
        req.body.exceptionApprovalStatus ||
        'NOT_REQUIRED';
  
      if (
        !allowedApprovalStatuses.includes(
          exceptionApprovalStatus
        )
      ) {
        return res.status(400).json({
          status: 'error',
          message:
            'exceptionApprovalStatus is not valid.',
          allowedValues:
            allowedApprovalStatuses
        });
      }
  
      const varianceReasonCode =
        typeof req.body.varianceReasonCode ===
          'string' &&
        req.body.varianceReasonCode.trim()
          ? req.body.varianceReasonCode.trim()
          : null;
  
      const validationResult =
        await validateGoodsReceipt({
          userCode: req.body.userCode.trim(),
          purchaseOrderCode:
            req.body.purchaseOrderCode.trim(),
          productCode:
            req.body.productCode.trim(),
          warehouseCode:
            req.body.warehouseCode.trim(),
          batchNumber:
            req.body.batchNumber.trim(),
          deliveredQuantity,
          acceptedQuantity,
          rejectedQuantity,
          damagedQuantity,
          qualityBlockedQuantity,
          allowedVariancePercentage,
          varianceReasonCode,
          exceptionApprovalStatus
        });
  
      return res.status(200).json({
        status: 'success',
        data: validationResult
      });
    } catch (error) {
      console.error(
        'Goods receipt validation failed:',
        error
      );
  
      if (
        error.number >= 52001 &&
        error.number <= 52012
      ) {
        return res.status(400).json({
          status: 'error',
          message: error.message,
          databaseErrorNumber: error.number
        });
      }
  
      return res.status(500).json({
        status: 'error',
        message:
          'Goods receipt validation could not be completed.'
      });
    }
  }
  
  module.exports = {
    validateGoodsReceiptController
  };