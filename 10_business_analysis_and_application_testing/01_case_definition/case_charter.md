# Aurevia ERP Business Analysis, Application Testing and UAT Case Study

## 1. Case Study Overview

This phase extends the existing Aurevia ERP Operations and Business Intelligence case study with a structured business analysis, application testing, user acceptance testing, defect management, test data management, and release management scenario.

The existing project demonstrates ERP-style operational workflows, SQL Server data modeling, synthetic data generation, SQL validation, Power BI reporting, and source-to-report reconciliation.

This new phase focuses on how a business application requirement is managed from initial request through analysis, development, test environment validation, user acceptance testing, defect resolution, and production release preparation.

The objective is to demonstrate the full application lifecycle from both business and technical perspectives.

---

## 2. Business Context

Aurevia Professional Supply is a fictional B2B company operating in the professional wellness, spa, textile, skincare, and consumable supply industry.

For this extended case study, the company is assumed to operate through a structured ERP environment with the following departments:

- Sales Operations
- Purchasing
- Warehouse Operations
- Quality Control
- Finance
- Supplier Management
- Business Applications
- Software Development
- IT Operations

The scenarios in this case study are designed to simulate requirements that could arise in a production, distribution, or food-related enterprise environment.

All company names, transactions, users, products, data, and system outputs are fictional and created for portfolio purposes.

---

## 3. Main Business Objective

The main objective is to design and validate ERP application controls that prevent operational errors during sales order allocation and goods receipt processes.

The case study will demonstrate how business requirements are:

1. Collected from business users
2. Analyzed and documented
3. Converted into functional requirements
4. Transferred to a software development team
5. Deployed to a test environment
6. Validated with appropriate test data
7. Tested manually
8. Verified through SQL queries
9. Tested through APIs
10. Automated through UI testing
11. Evaluated through user acceptance testing
12. Managed through defect and retest processes
13. Prepared for production release

---

## 4. Primary Case

### Case 1: Sales Order Eligibility, Batch and Inventory Reservation Control

The first case focuses on sales order validation and stock reservation.

The existing system currently checks only the total physical stock quantity when users create and approve sales orders.

This creates operational risks because a product may appear to be available even when:

- The stock is already reserved for another sales order
- The related batch is under quality control
- The batch has been rejected
- The remaining shelf life does not meet the customer requirement
- The stock is stored in an unsuitable warehouse
- The customer credit limit has been exceeded
- The user does not have approval authority
- A cancelled order still has an active stock reservation

The requested enhancement will introduce a structured validation and approval mechanism.

The system must evaluate:

- Physical stock
- Reserved stock
- Available stock
- Batch status
- Quality status
- Expiration date
- Remaining shelf life
- Warehouse suitability
- Customer credit limit
- User role and approval authority
- Order status
- Reservation status

The purpose is to prevent invalid stock allocations, unsuitable product shipments, unauthorized approvals, and incorrect inventory balances.

---

## 5. Secondary Case

### Case 2: Goods Receipt Variance, Quality Block and Approval Workflow

The second case focuses on purchasing and goods receipt operations.

The current process allows users to complete goods receipt based only on the purchase order quantity.

This creates risks when the physically received quantity differs from the ordered quantity.

Possible differences include:

- Missing quantity
- Excess quantity
- Damaged quantity
- Rejected quantity
- Quality-controlled quantity
- Incorrect product
- Incorrect batch
- Packaging damage
- Delivery outside the accepted tolerance

The requested enhancement will separate:

- Ordered quantity
- Delivered quantity
- Accepted quantity
- Rejected quantity
- Damaged quantity
- Quality-blocked quantity

The system must also:

- Require a variance reason code
- Trigger approval when the tolerance is exceeded
- Prevent rejected quantities from becoming available stock
- Update supplier performance records
- Transfer only accepted quantities to invoice control
- Generate an audit log
- Notify the relevant departments

---

## 6. In-Scope Activities

The case study includes:

- Business request analysis
- Stakeholder identification
- AS-IS process documentation
- TO-BE process design
- Business rules
- Functional requirements
- Non-functional requirements
- User stories
- Acceptance criteria
- Role and authorization matrix
- Test environment simulation
- Test data preparation
- Test data validation
- Manual functional testing
- Negative testing
- Boundary value testing
- Authorization testing
- SQL database validation
- API testing with Postman
- UI automation with Playwright
- Defect reporting
- Defect retesting
- Regression testing
- User acceptance testing
- UAT sign-off simulation
- Go-live checklist
- Release notes
- Smoke testing
- Rollback planning

---

## 7. Out-of-Scope Activities

The case study does not include:

- Full-scale ERP product development
- Production machine integration
- PLC or industrial automation testing
- Real company systems
- Real customer data
- Real supplier data
- Real financial transactions
- Electronic invoice integration
- Logistics route optimization
- Advanced production planning
- Live payment processing
- Real production deployment

The technical application will be limited to the screens, database operations, APIs, and business rules required to demonstrate the selected cases.

---

## 8. Stakeholders

| Stakeholder | Responsibility |
|---|---|
| Sales Operations User | Creates and manages sales orders |
| Sales Operations Manager | Approves exceptional orders |
| Warehouse User | Reviews stock and reservation information |
| Warehouse Manager | Manages inventory exceptions |
| Quality Control User | Updates batch quality status |
| Finance User | Reviews customer credit status |
| Purchasing User | Creates and follows purchase orders |
| Goods Receipt User | Records received quantities |
| Supplier Management User | Reviews supplier delivery performance |
| Business Applications Specialist | Analyzes requests, coordinates testing, manages UAT and release readiness |
| Software Developer | Implements the requested functionality |
| Database Specialist | Supports schema, test data, and SQL validation |
| IT Operations / DevOps | Deploys application versions between environments |
| Business Process Owner | Provides final business approval |

---

## 9. System Environments

The following logical environments will be simulated:

| Environment | Purpose |
|---|---|
| DEV | Development and initial developer validation |
| TEST | Functional testing and defect verification |
| UAT | Business user acceptance testing |
| PROD-DEMO | Production release and smoke test simulation |

These environments may be implemented through separate configuration files, databases, test data sets, or application modes rather than separate physical servers.

---

## 10. Testing Approach

The project will include the following testing layers:

### Manual Functional Testing

Business workflows will be tested through application screens using documented test cases.

### SQL Validation

Critical business transactions will be verified directly in SQL Server.

The validation will include:

- Order status
- Reservation creation
- Reservation cancellation
- Inventory balance
- Batch quality status
- Credit limit calculations
- Goods receipt quantities
- Quality-blocked stock
- Audit logs

### API Testing

REST API endpoints will be tested using Postman.

The tests will validate:

- HTTP status codes
- Response payloads
- Business validation messages
- Authorization behavior
- Data creation
- Data updates
- Negative scenarios

### UI Test Automation

Critical user flows will be automated using Playwright.

Automation will focus on repeatable, business-critical scenarios rather than replacing all manual tests.

### User Acceptance Testing

Business-oriented UAT scenarios will be executed using defined users, roles, test data, and acceptance criteria.

---

## 11. Defect Management Approach

A controlled defect will be introduced during the project to demonstrate the complete defect lifecycle.

The planned defect scenario is:

A blocked batch displays an error message during sales order approval, but the system still creates an active stock reservation in the database.

The defect lifecycle will include:

1. Detection during manual testing
2. SQL verification
3. Defect record creation
4. Severity and priority assessment
5. Assignment to development
6. Code correction
7. Deployment to TEST
8. Retest
9. Regression testing
10. Closure

GitHub Issues or a simulated Jira-style defect record will be used for portfolio evidence.

---

## 12. Success Criteria

The case study will be considered successful when:

- Business requirements are documented and traceable
- AS-IS and TO-BE processes are clearly defined
- Functional and non-functional requirements are testable
- Required test data is identified and created
- Manual test cases are executed
- SQL validation confirms database behavior
- API tests are executed successfully
- Critical UI flows are automated
- At least one defect lifecycle is demonstrated
- UAT scenarios are completed
- A UAT completion document is prepared
- Go-live and rollback documentation is completed
- All outputs are clearly presented in the GitHub repository

---

## 13. Portfolio Positioning

This project phase demonstrates the ability to work as a bridge between business teams and software teams.

It is designed to show experience and capability in:

- Business analysis
- ERP process understanding
- Requirement management
- Functional testing
- Test data management
- SQL validation
- API testing
- UI test automation
- Defect management
- User acceptance testing
- Release and go-live coordination

This phase complements the existing ERP Operations and BI project by extending the portfolio from reporting and analytics into business application lifecycle management.