# Data Quality & Business Validation Notes

This document records the data quality and business validation results for the Aurevia ERP Operations & BI Dashboard Case Study.

## 1. Purpose

The purpose of this validation step is to confirm that the synthetic ERP dataset is not only populated, but also logically consistent, financially reliable and suitable for professional Power BI reporting.

The validation checks focus on:

* Product pricing consistency
* Service and inventory movement logic
* Stock movement direction
* Invoice amount accuracy
* Payment amount accuracy
* Inventory risk indicators
* Collection performance
* Gross margin performance
* Overdue invoice risk
* Supplier delivery delay risk

## 2. Validation Scripts

The following SQL validation scripts were created:

```text
04_sql_database/data_quality_validation_queries.sql
04_sql_database/data_quality_summary.sql
```

## 3. Executive Data Quality Summary

| Metric                            |          Value | Status                   |
| --------------------------------- | -------------: | ------------------------ |
| Invalid Product Price Count       |              0 | PASS                     |
| Service Stock Movement Count      |              0 | PASS                     |
| Invalid Stock Movement Sign Count |              0 | PASS                     |
| Invoice Amount Mismatch Count     |              0 | PASS                     |
| Overpaid Invoice Count            |              0 | PASS                     |
| Products Below Reorder Level      |              4 | BUSINESS RISK IDENTIFIED |
| Negative Stock Product Count      |              4 | BUSINESS RISK IDENTIFIED |
| Collection Rate Percent           |          77.27 | KPI                      |
| Gross Margin Percent              |          45.59 | KPI                      |
| Total Revenue                     | 420,614,142.43 | KPI                      |
| Open Balance                      |  95,623,848.03 | KPI                      |
| Overdue Invoice Count             |            248 | BUSINESS RISK IDENTIFIED |
| Delayed Purchase Order Count      |            679 | BUSINESS RISK IDENTIFIED |

## 4. Passed Validation Checks

The following validation checks passed successfully:

### Product Price Validation

No physical product has a sales price lower than or equal to its unit cost.

This confirms that product-level pricing supports positive gross margin analysis.

### Service Inventory Validation

No service product generated stock movements.

This confirms that the dataset correctly separates physical products from non-stock-tracked services.

### Stock Movement Sign Validation

All stock receipts are positive and all stock-out transactions are negative.

This confirms that inventory movement logic is consistent with ERP stock flow principles.

### Invoice Amount Validation

No invoice amount mismatch was detected.

This confirms that invoice totals are aligned with sales order line revenue.

### Payment Amount Validation

No overpaid invoices were detected.

This confirms that total payment amounts do not exceed invoice amounts.

## 5. Business Risks Identified

The validation process also identified business risks that can be analyzed in Power BI.

### Inventory Risk

There are 4 products below reorder level.

There are also 4 products with negative stock balance.

These issues represent potential procurement planning, stock control or demand forecasting problems.

### Receivables Risk

There are 248 overdue invoices.

This creates a receivables management and cash flow risk.

### Supplier Delivery Risk

There are 679 delayed purchase orders.

This indicates a supplier performance and procurement reliability risk.

## 6. KPI Interpretation

### Collection Rate

The collection rate is 77.27%.

This means that a significant portion of invoiced revenue has been collected, but there is still a material open balance requiring follow-up.

### Gross Margin

The gross margin is 45.59%.

This indicates that the simulated business has a healthy profitability structure, while still allowing product/category-level margin analysis.

### Revenue and Open Balance

Total revenue is 420,614,142.43.

Open balance is 95,623,848.03.

These figures allow Power BI dashboards to analyze revenue generation, collection performance and receivables risk together.

## 7. Portfolio Relevance

This validation step strengthens the project by showing that the dataset was not created only for visual reporting.

The project also includes data quality checks, financial consistency checks, inventory risk detection and operational exception analysis.

This creates a more realistic ERP analytics case study suitable for business analysis, ERP support, UAT / Go-Live preparation and Power BI reporting roles.
