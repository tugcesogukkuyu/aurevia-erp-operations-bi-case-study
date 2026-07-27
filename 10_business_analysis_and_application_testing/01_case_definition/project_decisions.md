# Project Decisions

## PD-01 — Repository

The new business analysis and application testing work will be developed inside the existing Aurevia ERP Operations and BI repository.

Reason:

- The new cases use the existing ERP business context.
- Existing SQL Server data and operational processes can be reused.
- The repository will demonstrate one end-to-end ERP lifecycle.
- Existing files will not be overwritten during the initial phases.

New work will be stored under:

`10_business_analysis_and_application_testing`

---

## PD-02 — Case Structure

Two connected ERP cases will be implemented:

1. Sales Order, Batch and Stock Reservation Control
2. Goods Receipt Variance and Quality Block Control

Both cases will use the same database and application architecture.

---

## PD-03 — Database

Microsoft SQL Server will remain the main database technology.

The existing database will be extended only when required by the approved business requirements.

Planned additions include:

- Batch information
- Quality status
- Stock reservations
- Customer credit limits
- Approval records
- Goods receipt variances
- User roles
- Audit logs

---

## PD-04 — Application Architecture

The planned demo architecture is:

`React UI → Node.js / Express API → Microsoft SQL Server`

The application will include only the screens and services required to demonstrate the selected business cases.

A full ERP product will not be developed.

---

## PD-05 — Test Environments

The following logical environments will be simulated:

- DEV
- TEST
- UAT
- PROD-DEMO

The environments may use separate databases, configuration files, or environment variables.

Separate physical servers are not required for the portfolio simulation.

---

## PD-06 — Testing Strategy

The project will demonstrate:

- Manual functional testing
- Negative testing
- Boundary-value testing
- Authorization testing
- SQL validation
- Postman API testing
- Playwright UI automation
- Defect retesting
- Regression testing
- User acceptance testing

Manual functional testing and UAT will remain the main focus.

Automation will cover selected repeatable and business-critical scenarios.

---

## PD-07 — Test Data

All test data will be synthetic.

Test data requirements will be documented before execution.

The project will demonstrate:

- Test data availability checks
- Missing test data detection
- Test Data Request preparation
- SQL-based data creation
- SQL-based data verification

---

## PD-08 — Defect Lifecycle

At least one controlled defect will be demonstrated.

Planned defect:

A quality-blocked batch produces a warning message, but the system incorrectly creates an active stock reservation.

The defect will be:

1. Detected during testing
2. Verified through SQL
3. Reported
4. Corrected
5. Retested
6. Included in regression testing
7. Closed with evidence

---

## PD-09 — API and Automation

The existing project does not currently contain an application API.

A limited REST API will be created for the selected business cases.

Postman will be used for API testing.

Playwright will be used for selected UI flows after the application screens are available.

---

## PD-10 — Documentation Standard

Documents will remain concise and evidence-oriented.

Each document must support at least one of the following:

- Business requirement
- Technical decision
- Test execution
- Database validation
- Defect evidence
- UAT evidence
- Release readiness

Documents that do not provide technical or portfolio evidence will not be added.

---

## PD-11 — Commit Strategy

Changes will be committed by completed work package.

Planned commit sequence:

1. `docs: define ERP application testing cases`
2. `docs: add business requirements and process flows`
3. `database: extend ERP schema and test data`
4. `feat: add sales order and goods receipt API`
5. `test: add manual and SQL validation cases`
6. `test: add Postman API collection`
7. `test: add Playwright critical flow tests`
8. `docs: add defect lifecycle and UAT evidence`
9. `docs: add release and go-live documents`

A commit will be created only after the related output has been reviewed.