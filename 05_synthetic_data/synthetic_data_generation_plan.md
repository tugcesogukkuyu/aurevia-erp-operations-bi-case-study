# Synthetic Data Generation Plan
## Aurevia ERP Operations & BI Dashboard Case Study

## 1. Purpose

This document defines the synthetic ERP dataset generation plan for the Aurevia ERP Operations & BI Dashboard Case Study.

The purpose of the synthetic dataset is to extend the hands-on Odoo ERP workflow into a larger SQL Server dataset that can support professional-scale Power BI reporting.

The Odoo ERP layer demonstrates real ERP portal usage.

The SQL Server synthetic data layer demonstrates how ERP-generated operational data can be modeled, analyzed and reported at scale.

---

## 2. Dataset Scope

The SQL Server dataset will simulate ERP transactions across the following business areas:

- Customers
- Suppliers
- Products and services
- Warehouses
- Purchase orders
- Purchase order lines
- Sales orders
- Sales order lines
- Stock movements
- Invoices
- Payments
- Date dimension

---

## 3. Target Data Volume

| Entity | Target Count |
|---|---:|
| Customers | 150 |
| Suppliers | 10 |
| Products & Services | 80 |
| Warehouses | 3 |
| Purchase Orders | 800 |
| Sales Orders | 3,000 |
| Sales Order Lines | 8,000–12,000 |
| Stock Movements | 10,000+ |
| Invoices | 3,000 |
| Payments | 2,500–3,000 |
| Date Range | 18 months |

---

## 4. Date Range

The synthetic dataset will cover an 18-month operational period.

Planned date range:

- Start Date: 2025-01-01
- End Date: 2026-06-30

This date range supports monthly, quarterly and year-over-year style trend analysis in Power BI.

---

## 5. Master Data Logic

### Customers

The customer table will include 150 synthetic B2B customers.

Customer segments:

- Hotel & Resort
- Spa Center
- Beauty Salon
- Clinic
- Premium Individual
- Distributor / Reseller

Each customer will have:

- Customer code
- Customer name
- Segment
- City
- Country
- Payment term
- Sales channel
- Created date

### Suppliers

The supplier table will include 10 synthetic suppliers.

Supplier categories:

- Massage Oils
- Aromatherapy
- Spa Textile
- Skincare
- Hammam Products
- Consumables
- Premium Wellness Kits
- Packaging
- Training Materials
- General Wellness Supply

### Products and Services

The product table will include 80 products and services.

Product categories:

- Massage Oils
- Aromatherapy Products
- Hammam & Ritual Kits
- Spa Textile
- Skincare Products
- Spa Consumables
- Premium Wellness Kits
- Training & Consulting

Physical products will be stock-tracked.

Services will not create inventory movements.

### Warehouses

The warehouse table will include 3 locations:

- Main Warehouse — İzmir
- Istanbul Transfer Warehouse — İstanbul
- Antalya Seasonal Warehouse — Antalya

---

## 6. Transaction Data Logic

### Purchase Orders

Purchase orders will simulate supplier-based stock replenishment.

Each purchase order will include:

- Supplier
- Order date
- Expected delivery date
- Actual delivery date
- Warehouse
- Purchase status

Purchase order lines will include:

- Product
- Quantity
- Unit cost
- Line amount

Each received purchase order line will create a positive stock movement.

### Sales Orders

Sales orders will simulate B2B customer orders.

Each sales order will include:

- Customer
- Order date
- Delivery date
- Sales order status
- Payment term
- Sales channel
- Warehouse

Sales order lines will include:

- Product or service
- Quantity
- Unit sales price
- Unit cost
- Revenue amount
- Cost amount
- Gross profit amount

Physical product sales will create negative stock movements.

Service sales will not create stock movements.

### Invoices

Each sales order will generate one invoice.

Invoices will include:

- Invoice date
- Due date
- Invoice amount
- Invoice status

Invoice statuses will include:

- Paid
- Open
- Partial
- Overdue

### Payments

Payments will simulate collection performance.

Payment scenarios:

- Fully paid
- Partially paid
- Open / unpaid
- Delayed payment

This will support receivables and collection rate analysis in Power BI.

---

## 7. KPI Coverage

The synthetic dataset will support the following KPIs:

### Sales KPIs

- Total revenue
- Monthly revenue
- Revenue by product category
- Revenue by customer segment
- Top customers
- Top products
- Sales channel performance

### Profitability KPIs

- Total cost
- Gross profit
- Gross margin
- Product-level margin
- Category-level margin

### Inventory KPIs

- Stock-in quantity
- Stock-out quantity
- Stock on hand
- Products below reorder level
- Inventory movement trend
- Warehouse-based stock distribution

### Purchasing KPIs

- Purchase volume by supplier
- Purchase cost trend
- Supplier lead time
- Delayed purchase receipts
- Most purchased products

### Invoice and Payment KPIs

- Total invoice amount
- Paid amount
- Open balance
- Overdue amount
- Collection rate
- Average payment delay
- Customer-based receivables

---

## 8. Data Quality Rules

The synthetic data must be realistic enough for professional reporting.

Rules:

- Product prices must be greater than unit costs.
- Service products must not generate stock movements.
- Physical products must generate stock movements.
- Purchase orders must increase stock.
- Sales deliveries must decrease stock.
- Invoice due dates must be based on payment terms.
- Some invoices must remain open or overdue.
- Some payments must be partial.
- Some supplier deliveries must be delayed.
- Some products must fall below reorder level.

---

## 9. Implementation Method

The synthetic dataset will be generated directly inside SQL Server using a T-SQL seed script.

The planned script name:

```text
04_sql_database/seed_synthetic_data.sql