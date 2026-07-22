# Dashboard Demo Talking Points

## Project

**Aurevia ERP Operations & BI Dashboard**

## Purpose

This document provides a structured talking track for presenting the Aurevia ERP Operations & BI Dashboard during a portfolio review, interview, or technical discussion.

The goal is to explain the project from a business and technical perspective without presenting it as only a visual dashboard.

---

## Opening Summary

This project is an end-to-end ERP operations and business intelligence case study built for a fictional professional wellness supply company named Aurevia Professional Supply.

The project simulates a realistic business environment where ERP transactions are created, stored in SQL Server, validated with SQL, analyzed in Power BI, and extended with Python-based customer segmentation.

---

## 1. Business Context

### Talking Point

Aurevia sells professional spa, wellness, hammam, skincare, aromatherapy, textile, and service-related products to B2B customers.

The business needs visibility across sales, profitability, inventory, receivables, and supplier performance.

### Key Message

The dashboard was not designed only to show charts. It was designed to simulate how an operations and BI team would monitor business performance from ERP data.

---

## 2. ERP Process Flow

### Talking Point

Before creating the dashboard, I simulated the ERP process flow.

The ERP flow includes:

- customers
- suppliers
- products
- purchase orders
- stock receipts
- sales orders
- deliveries
- invoices
- payments

### Key Message

This allowed the project to start from business operations instead of starting directly from visuals.

---

## 3. SQL Server Data Model

### Talking Point

The operational data was stored in SQL Server using a relational structure.

The model includes customer, supplier, product, warehouse, purchase, sales, stock, invoice, payment, and date dimension tables.

### Key Numbers

| Area | Volume |
|---|---:|
| Customers | 150 |
| Products | 82 |
| Sales Orders | 3,000 |
| Sales Order Lines | 8,918 |
| Purchase Orders | 800 |
| Stock Movements | 10,881 |
| Invoices | 3,000 |
| Payments | 2,731 |

### Key Message

The dataset was large enough to support realistic reporting patterns and operational analysis.

---

## 4. Data Quality Validation

### Talking Point

I added SQL validation checks before building the Power BI report.

These checks covered:

- invalid product prices
- invoice mismatches
- overpaid invoices
- incorrect stock movement signs
- service products incorrectly affecting stock
- inventory risk
- receivables risk
- supplier delivery delay

### Key Message

This step shows that the dashboard is based on controlled and validated reporting logic, not just raw synthetic data.

---

## 5. Original Dashboard Pages

### Talking Point

The first version of the dashboard included six operational pages.

| Page | Purpose |
|---|---|
| Executive Overview | High-level performance summary |
| Sales Analysis | Revenue, channel, region, and customer performance |
| Product Profitability | Category and product-level margin analysis |
| Inventory Risk | Stock availability and reorder risk |
| Receivables Collection | Invoice, payment, and overdue balance tracking |
| Supplier Performance | Purchase order and supplier delay monitoring |

### Key Message

These six pages form the operational reporting layer of the project.

---

## 6. Why I Added an Advanced Analytics Layer

### Talking Point

After completing the operational dashboard, I extended the project because a real management dashboard should not only show what happened. It should also help decide what to do next.

The advanced extension focuses on two management needs:

1. monitoring sales operations from one command center
2. prioritizing customers for growth, retention, or collection actions

### Key Message

The advanced extension was intentionally limited to two pages. The goal was not to add more visuals, but to add a clear decision layer.

---

## 7. Page 07 - Sales Operations Command Center

### Talking Point

This page acts as an ERP-style management cockpit.

It brings together:

- total revenue
- gross profit
- gross margin
- open balance
- collection rate
- monthly sales trend
- top customers
- product category revenue
- receivables risk
- operational alerts

### How to Explain the Page

This page answers:

```text
What is happening in sales operations right now, and which issues require
management attention?
```

### Key Message

The page gives a single management view of commercial performance, profitability, receivables, and operational exceptions.

---

## 8. Page 08 - Customer Portfolio Action Model

### Talking Point

This page uses Python-based K-Means segmentation to convert customer performance data into business action groups.

The business question is:

```text
Which customer groups can support revenue growth without increasing collection
risk and profitability risk?
```

### Model Features

The segmentation uses:

- total revenue
- gross margin percentage
- average monthly order frequency
- collection rate
- open balance ratio
- product category diversity

### Customer Clusters

| Cluster | Recommended Action |
|---|---|
| Strategic Value Customers | Protect / Retain / Upsell |
| Growth Potential Customers | Grow / Cross-sell |
| Collection Risk Customers | Collect First / Monitor Credit |
| Low Contribution Customers | Low-Touch Service |

### Key Message

This page connects sales growth with finance risk, so the business does not increase revenue exposure with customers who already show collection problems.

---

## 9. SQL + Python + Power BI Integration

### Talking Point

The advanced analytics flow is designed as follows:

```text
SQL Server reporting views
        ↓
Python feature engineering
        ↓
K-Means segmentation
        ↓
Customer segmentation output
        ↓
Power BI customer action page
```

### Key Message

SQL prepares the reporting layer, Python creates the segmentation model, and Power BI turns the model output into management actions.

---

## 10. DAX and Power BI Build Logic

### Talking Point

I documented the DAX measures and Power BI page build logic separately.

This includes:

- revenue measures
- gross profit measures
- gross margin percentage
- open balance
- collection rate
- segment revenue share
- segment open balance share
- customer priority rank
- channel revenue share

### Key Message

The documentation shows not only the final dashboard, but also how the report logic would be built and maintained.

---

## 11. QA and Reconciliation

### Talking Point

I also added QA and UAT documentation for the advanced analytics layer.

The QA checks cover:

- SQL view existence
- reporting period consistency
- customer count reconciliation
- total revenue reconciliation
- open balance reconciliation
- Python output validation
- cluster count validation
- Power BI screenshot checks

### Key Message

This makes the project more realistic because BI projects require reconciliation and validation, not only dashboard design.

---

## 12. How to Position the Project in an Interview

### Main Positioning Sentence

```text
This is an end-to-end ERP operations and BI case study where I simulated business
transactions, modeled them in SQL Server, validated the data with SQL, built a
Power BI reporting layer, and extended it with Python-based customer segmentation
for management decision support.
```

### Technical Positioning

```text
The project combines SQL Server, Power BI, DAX, Python, and applied customer
analytics in a single portfolio case study.
```

### Business Positioning

```text
The dashboard helps management monitor operational performance and prioritize
customer actions based on revenue, margin, collection quality, and receivables
risk.
```

---

## 13. What to Emphasize

### Emphasize

- the project starts from business process logic
- SQL validation was included
- Power BI pages have clear business purposes
- Python was added for a specific decision problem
- advanced analytics is not shown as academic ML
- customer segmentation is translated into business actions
- QA and documentation were included

### Do Not Overclaim

Do not claim that the advanced screenshots are direct PBIX exports unless the PBIX file is rebuilt with the same advanced analytics outputs.

A safer statement is:

```text
The advanced pages are portfolio dashboard mockups supported by documented SQL,
Python, Power BI, and QA implementation logic.
```

---

## 14. Closing Statement

This project demonstrates how an ERP reporting solution can evolve from operational dashboards into a management decision-support system.

It connects:

- business process understanding
- SQL data modeling
- data quality validation
- Power BI reporting
- DAX calculations
- Python segmentation
- QA documentation
- business action design