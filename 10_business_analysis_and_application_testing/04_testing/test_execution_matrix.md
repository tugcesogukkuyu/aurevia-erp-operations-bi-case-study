# Test Execution Matrix

## Purpose

This document records the functional test coverage and execution results for the ERP business control scenarios implemented in the Aurevia ERP Operations and BI case study.

The test scope covers:

1. TEST/UAT data readiness validation
2. Sales order, batch, stock and credit control
3. Goods receipt variance and quality block control

All scenarios were executed against the `AureviaERPBI` Microsoft SQL Server database using controlled TEST/UAT data.

---

## Execution Summary

| Test Area | Total Scenarios | Passed | Failed | Execution Status |
|---|---:|---:|---:|---|
| TEST/UAT data readiness | 15 | 14 | 1 controlled missing-data result | Completed |
| Sales order validation | 10 | 10 | 0 | Passed |
| Goods receipt validation | 12 | 12 | 0 | Passed |
| **Functional validation total** | **22** | **22** | **0** | **Passed** |

The single failed readiness check was deliberately designed to confirm that missing prerequisite data can be detected before UAT execution. It is not classified as an application defect.

---

## 1. TEST/UAT Data Readiness Validation

**SQL script:** `03_database/test_data_readiness.sql`

| Check Range | Validation Area | Actual Result | Status |
|---|---|---|---|
| TDR-001 – TDR-004 | Application users and authorization roles | Required active users and roles were available | Passed |
| TDR-005 – TDR-008 | Batch status and shelf-life scenarios | Required released, blocked, short-life and rejected batches were available | Passed |
| TDR-009 – TDR-010 | Inventory and warehouse eligibility | Required stock and sales-ineligible warehouse data were available | Passed |
| TDR-011 – TDR-012 | Customer credit profiles | Required standard and exception credit profiles were available | Passed |
| TDR-013 – TDR-014 | Purchase order and goods receipt prerequisites | Required purchase order line and receipt batch were available | Passed |
| TDR-015 | Controlled missing batch detection | `BATCH-MISSING-001` was correctly reported as missing | Expected Fail |

### Readiness Result

```text
TotalChecks: 15
PassedChecks: 14
FailedChecks: 1
ReadinessPercentage: 93.33
```

The failed readiness check produced the following corrective action:

```text
Create or request the missing batch before executing the related UAT scenario.
```

This result confirms that the validation script can detect missing test prerequisites and prevent unsupported UAT execution.

---

## 2. Sales Order Validation

**Stored procedure:** `dbo.usp_ValidateSalesOrder`  
**Test script:** `03_database/sales_order_validation_tests.sql`

| Test ID | Scenario | Expected Result | Actual Result | Status |
|---|---|---|---|---|
| TC-SO-001 | Valid order with authorized user, sufficient stock and sufficient credit | APPROVED | APPROVED | Passed |
| TC-SO-002 | Unauthorized sales user attempts order approval | REJECTED | REJECTED | Passed |
| TC-SO-003 | Quality-blocked batch is selected | REJECTED | REJECTED | Passed |
| TC-SO-004 | Batch does not meet customer minimum shelf-life requirement | REJECTED | REJECTED | Passed |
| TC-SO-005 | Requested quantity exceeds available stock | REJECTED | REJECTED | Passed |
| TC-SO-006 | Stock is selected from a sales-ineligible warehouse | REJECTED | REJECTED | Passed |
| TC-SO-007 | Credit limit is exceeded and finance approval is pending | PENDING_FINANCE_APPROVAL | PENDING_FINANCE_APPROVAL | Passed |
| TC-SO-008 | Credit-limit exception is approved by finance | APPROVED | APPROVED | Passed |
| TC-SO-009 | Rejected batch is selected | REJECTED | REJECTED | Passed |
| TC-SO-010 | Selected batch does not exist | REJECTED | REJECTED | Passed |

### Validated Business Controls

- Application-user existence and active status
- Role-based sales approval authorization
- Customer existence
- Product existence
- Batch-tracking requirement
- Warehouse existence
- Warehouse sales eligibility
- Batch and product relationship
- Batch quality status
- Customer minimum shelf life
- Inventory balance existence
- Physical, reserved and available stock
- Customer credit profile
- Customer credit-block status
- Credit-limit calculation
- Finance approval workflow

### Sales Order Test Result

All 10 sales order scenarios produced the expected business decision.

```text
Passed scenarios: 10
Failed scenarios: 0
Execution status: Passed
```

---

## 3. Goods Receipt Validation

**Stored procedure:** `dbo.usp_ValidateGoodsReceipt`  
**Test script:** `03_database/goods_receipt_validation_tests.sql`

| Test ID | Scenario | Expected Result | Actual Result | Status |
|---|---|---|---|---|
| TC-GR-001 | Exact delivery is fully accepted | APPROVED | APPROVED | Passed |
| TC-GR-002 | Delivery variance remains within the permitted tolerance | APPROVED | APPROVED | Passed |
| TC-GR-003 | Excess delivery requires exception approval | PENDING_EXCEPTION_APPROVAL | PENDING_EXCEPTION_APPROVAL | Passed |
| TC-GR-004 | Excess-delivery exception is approved | APPROVED | APPROVED | Passed |
| TC-GR-005 | Delivery variance is submitted without a reason code | REJECTED | REJECTED | Passed |
| TC-GR-006 | Quantity classification total does not equal delivered quantity | REJECTED | REJECTED | Passed |
| TC-GR-007 | Quality-blocked quantity is separated from available stock | APPROVED | APPROVED | Passed |
| TC-GR-008 | Unauthorized sales user attempts to record goods receipt | REJECTED | REJECTED | Passed |
| TC-GR-009 | Receipt warehouse does not match purchase order warehouse | REJECTED | REJECTED | Passed |
| TC-GR-010 | Selected receipt batch does not exist | REJECTED | REJECTED | Passed |
| TC-GR-011 | Short delivery requires exception approval | PENDING_EXCEPTION_APPROVAL | PENDING_EXCEPTION_APPROVAL | Passed |
| TC-GR-012 | Quantity-variance exception is rejected | REJECTED | REJECTED | Passed |

### Validated Business Controls

- Application-user existence and active status
- Warehouse-role authorization
- Purchase-order existence
- Purchase-order status
- Product existence
- Purchase-order line existence
- Warehouse existence
- Purchase-order and receipt warehouse consistency
- Batch and product relationship
- Delivered quantity validation
- Quantity breakdown reconciliation
- Delivery variance calculation
- Variance tolerance
- Mandatory variance reason
- Exception approval workflow
- Accepted-stock classification
- Quality-blocked stock separation

### Goods Receipt Test Result

All 12 goods receipt scenarios produced the expected business decision.

```text
Passed scenarios: 12
Failed scenarios: 0
Execution status: Passed
```

---

## 4. Overall Test Conclusion

All 22 functional validation scenarios produced the expected result.

The implemented SQL validation controls successfully prevented, rejected or routed transactions involving:

- Unauthorized application users
- Invalid or missing master data
- Missing or mismatched batches
- Quality-blocked and rejected batches
- Insufficient available stock
- Sales-ineligible warehouses
- Insufficient remaining shelf life
- Customer credit-limit exceptions
- Unapproved goods receipt variances
- Missing variance reason codes
- Invalid receipt quantity breakdowns
- Purchase-order and warehouse mismatches
- Incorrect stock classification

The controlled TEST/UAT readiness failure also confirmed that missing prerequisite data can be detected before execution.

Based on the completed test results, the SQL business-control layer is ready for API integration, Postman validation and application-level UAT.