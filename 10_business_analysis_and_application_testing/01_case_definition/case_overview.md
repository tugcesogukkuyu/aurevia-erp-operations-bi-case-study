# Aurevia ERP Application Control and Testing Case

## 1. Case Overview

This case extends the Aurevia ERP Operations and BI project with application-level business controls, functional testing, database validation, API testing, UI automation, defect management, user acceptance testing, and release verification.

The case focuses on two connected ERP processes:

1. Sales Order, Batch and Stock Reservation Control
2. Goods Receipt Variance and Quality Block Control

Both processes use the same ERP data model and demonstrate how operational requirements are converted into technical controls and verified across the application, API, and database layers.

---

## 2. Business Scope

### Sales Order Control

The sales order process must prevent approval when:

- Available stock is insufficient
- The selected batch is quality-blocked, rejected, or expired
- The remaining shelf life does not meet the customer requirement
- The selected warehouse is not eligible for sales allocation
- The customer credit limit is exceeded
- The current user does not have approval authority
- An active reservation already exists
- A cancelled order retains an active reservation

### Goods Receipt Control

The goods receipt process must distinguish between:

- Ordered quantity
- Delivered quantity
- Accepted quantity
- Rejected quantity
- Damaged quantity
- Quality-blocked quantity

The process must also:

- Require a variance reason
- Apply tolerance controls
- Route exceptions for approval
- Prevent rejected quantities from entering available stock
- Transfer only accepted quantities to invoice control
- Update supplier delivery performance
- Create audit records

---

## 3. Application Components

The solution includes the following application components:

| Component | Purpose |
|---|---|
| Sales Order Screen | Create, validate, approve, and cancel sales orders |
| Inventory and Batch Selection | Display available stock, batch quality, expiration, and warehouse information |
| Approval Queue | Manage sales and finance approval exceptions |
| Goods Receipt Screen | Record delivered, accepted, rejected, and damaged quantities |
| Quality Control Screen | Manage batch quality status |
| Audit Log Screen | Display transaction and status-change history |
| REST API | Execute business validations and ERP transactions |
| SQL Server Database | Store operational, authorization, reservation, approval, and audit data |

---

## 4. Technical Validation Scope

The solution is verified through multiple test layers.

| Test Layer | Coverage |
|---|---|
| Manual Functional Testing | Business workflows, validation messages, status transitions |
| SQL Validation | Inventory, reservation, credit, quality, approval, and audit records |
| API Testing | HTTP responses, business rules, authorization, and transaction results |
| UI Automation | Repeatable critical user flows |
| Authorization Testing | Role-based access and approval restrictions |
| Regression Testing | Existing order and inventory functions after changes |
| User Acceptance Testing | Business-process acceptance using defined roles and test data |

---

## 5. Main Business Rules

### Sales Order Rules

- Available stock equals physical stock minus active reservations.
- Only released and valid batches can be allocated.
- Remaining shelf life must meet the customer requirement.
- Credit-limit exceptions require finance approval.
- Restricted approvals require an authorized role.
- Reservations are created only after all mandatory controls pass.
- Order cancellation releases active reservations.
- Every approval, rejection, cancellation, and reservation action creates an audit record.

### Goods Receipt Rules

- Delivered quantity must be recorded separately from accepted quantity.
- Rejected and quality-blocked quantities must not enter available stock.
- Quantity variances require a reason code.
- Variances above tolerance require manager approval.
- Only accepted quantities are transferred to invoice control.
- Supplier performance is updated from delivery results.
- Every receipt, rejection, approval, and quality action creates an audit record.

---

## 6. Data and Environment Model

The application uses Microsoft SQL Server as the operational database.

The following logical environments are used:

| Environment | Purpose |
|---|---|
| DEV | Development and initial technical validation |
| TEST | Functional testing, defect verification, and regression testing |
| UAT | Business-user acceptance testing |
| PROD-DEMO | Release and smoke-test simulation |

Test data is synthetic and environment-specific.

The project includes:

- Test data prerequisites
- Test data availability checks
- Missing-data detection
- Data creation scripts
- SQL verification queries
- Execution evidence

---

## 7. Defect Lifecycle

A controlled defect is included to demonstrate the full defect-management process.

### Defect Scenario

A quality-blocked batch displays a validation warning but still creates an active stock reservation in the database.

### Verification Flow

1. Execute the manual test
2. Capture the application result
3. Verify the incorrect reservation with SQL
4. Create a defect record
5. Assign severity and priority
6. Correct the application logic
7. Deploy the fix to TEST
8. Retest the failed scenario
9. Run regression tests
10. Close the defect with evidence

---

## 8. Portfolio Evidence

The repository includes the following evidence:

| Evidence | Demonstrated Capability |
|---|---|
| Functional specification | Business analysis and requirement management |
| Process diagrams | AS-IS and TO-BE process design |
| Role and authorization matrix | Access-control analysis |
| SQL schema and scripts | Database design and validation |
| Test data scripts | Test-environment preparation |
| Manual test cases | Functional testing |
| Postman collection | API testing |
| Playwright tests | UI test automation |
| Defect record and retest | Defect lifecycle management |
| UAT results | User acceptance testing |
| Release checklist | Go-live readiness |
| Rollback plan | Release-risk management |

---

## 9. Project Outcome

The completed case demonstrates the ability to:

- Translate operational problems into testable requirements
- Design ERP business controls
- Coordinate application, database, and user-level validation
- Prepare test environments and test data
- Validate transactions through SQL
- Test REST APIs
- Automate critical UI flows
- Report and verify defects
- Execute UAT
- Prepare a release for production deployment

---

## 10. Disclaimer

Aurevia Professional Supply is a fictional company.

All users, products, transactions, system outputs, and business data in this case are synthetic and created for portfolio purposes.