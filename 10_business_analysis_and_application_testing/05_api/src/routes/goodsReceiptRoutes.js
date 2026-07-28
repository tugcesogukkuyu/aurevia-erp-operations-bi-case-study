const express = require('express');

const {
  validateGoodsReceiptController
} = require(
  '../controllers/goodsReceiptController'
);

const router = express.Router();

router.post(
  '/validate',
  validateGoodsReceiptController
);

module.exports = router;