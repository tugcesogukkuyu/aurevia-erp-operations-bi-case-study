const express = require('express');

const {
  validateSalesOrderController
} = require('../controllers/salesOrderController');

const router = express.Router();

router.post(
  '/validate',
  validateSalesOrderController
);

module.exports = router;