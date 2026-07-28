const {
    validateSalesOrder
  } = require('../services/salesOrderService');
  
  const requiredFields = [
    'userCode',
    'customerCode',
    'productCode',
    'batchNumber',
    'warehouseCode',
    'requestedQuantity',
    'orderAmount'
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
  
  async function validateSalesOrderController(req, res) {
    try {
      const missingFields = findMissingFields(req.body);
  
      if (missingFields.length > 0) {
        return res.status(400).json({
          status: 'error',
          message: 'Required request fields are missing.',
          missingFields
        });
      }
  
      const requestedQuantity =
        Number(req.body.requestedQuantity);
  
      const orderAmount =
        Number(req.body.orderAmount);
  
      if (
        !Number.isFinite(requestedQuantity) ||
        requestedQuantity <= 0
      ) {
        return res.status(400).json({
          status: 'error',
          message:
            'requestedQuantity must be a number greater than zero.'
        });
      }
  
      if (
        !Number.isFinite(orderAmount) ||
        orderAmount < 0
      ) {
        return res.status(400).json({
          status: 'error',
          message:
            'orderAmount must be a non-negative number.'
        });
      }
  
      const allowedFinanceStatuses = [
        'NOT_REQUIRED',
        'PENDING',
        'APPROVED',
        'REJECTED'
      ];
  
      const financeApprovalStatus =
        req.body.financeApprovalStatus ||
        'NOT_REQUIRED';
  
      if (
        !allowedFinanceStatuses.includes(
          financeApprovalStatus
        )
      ) {
        return res.status(400).json({
          status: 'error',
          message:
            'financeApprovalStatus is not valid.',
          allowedValues: allowedFinanceStatuses
        });
      }
  
      const validationResult =
        await validateSalesOrder({
          userCode: req.body.userCode.trim(),
          customerCode:
            req.body.customerCode.trim(),
          productCode:
            req.body.productCode.trim(),
          batchNumber:
            req.body.batchNumber.trim(),
          warehouseCode:
            req.body.warehouseCode.trim(),
          requestedQuantity,
          orderAmount,
          financeApprovalStatus
        });
  
      return res.status(200).json({
        status: 'success',
        data: validationResult
      });
    } catch (error) {
      console.error(
        'Sales order validation failed:',
        error
      );
  
      if (
        error.number >= 51001 &&
        error.number <= 51008
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
          'Sales order validation could not be completed.'
      });
    }
  }
  
  module.exports = {
    validateSalesOrderController
  };