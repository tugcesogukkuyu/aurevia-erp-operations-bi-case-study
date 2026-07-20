# SQL Server Data Model Design

## Aurevia ERP Operations & BI Dashboard Case Study

## 1. Purpose

This document defines the SQL Server relational data model for the Aurevia ERP Operations & BI Dashboard Case Study.

The SQL Server layer is designed to extend the ERP workflow demonstrated in Odoo into a larger synthetic dataset suitable for professional-scale analysis and Power BI reporting.

The goal is to model ERP-style operational data across customers, suppliers, products, purchasing, inventory, sales, invoicing and payments.

---

## 2. Data Model Scope

The SQL Server database will include the following business areas:

* Customer master data
* Supplier master data
* Product and service master data
* Warehouse data
* Purchase orders
* Purchase order lines
* Sales orders
* Sales order lines
* Stock movements
* Invoices
* Payments
* Date dimension

---

## 3. Core Tables

| Table Name         | Purpose                                                                                             |
| ------------------ | --------------------------------------------------------------------------------------------------- |
| Customers          | Stores customer master data such as customer name, segment, city, payment term and sales channel    |
| Suppliers          | Stores supplier master data such as supplier name, supplier category, city and payment term         |
| Products           | Stores product and service data such as product code, category, cost, sales price and reorder level |
| Warehouses         | Stores warehouse and inventory location information                                                 |
| PurchaseOrders     | Stores purchase order header information                                                            |
| PurchaseOrderLines | Stores product-level details of purchase orders                                                     |
| SalesOrders        | Stores sales order header information                                                               |
| SalesOrderLines    | Stores product-level details of sales orders                                                        |
| StockMovements     | Stores inventory movements such as stock receipts and stock-outs                                    |
| Invoices           | Stores customer invoice information                                                                 |
| Payments           | Stores invoice payment and collection information                                                   |
| DateDim            | Stores calendar data for time-based reporting                                                       |

---

## 4. Table Relationships

The main relationships are:

| Relationship                           | Description                                           |
| -------------------------------------- | ----------------------------------------------------- |
| Customers → SalesOrders                | One customer can have many sales orders               |
| SalesOrders → SalesOrderLines          | One sales order can include multiple product lines    |
| Products → SalesOrderLines             | One product can appear in many sales order lines      |
| Suppliers → PurchaseOrders             | One supplier can have many purchase orders            |
| PurchaseOrders → PurchaseOrderLines    | One purchase order can include multiple product lines |
| Products → PurchaseOrderLines          | One product can appear in many purchase order lines   |
| Products → StockMovements              | One product can have many stock movements             |
| Warehouses → StockMovements            | One warehouse can have many stock movements           |
| SalesOrders → Invoices                 | One sales order can generate one invoice              |
| Invoices → Payments                    | One invoice can have zero, one or multiple payments   |
| DateDim → Orders / Invoices / Payments | Date table supports time-based reporting              |

---

## 5. Business Process Coverage

The data model supports two main ERP process flows.

### Procure-to-Stock

Supplier → Purchase Order → Purchase Order Lines → Stock Receipt → Inventory Increase

### Order-to-Cash

Customer → Sales Order → Sales Order Lines → Delivery / Stock-Out → Invoice → Payment

---

## 6. Planned Synthetic Data Volume

| Entity              | Target Count |
| ------------------- | -----------: |
| Customers           |          150 |
| Suppliers           |           10 |
| Products & Services |           80 |
| Warehouses          |            3 |
| Purchase Orders     |          800 |
| Sales Orders        |        3,000 |
| Sales Order Lines   | 8,000–12,000 |
| Stock Movements     |      10,000+ |
| Invoices            |        3,000 |
| Payments            |  2,500–3,000 |
| Date Range          | 12–18 months |

---

## 7. Key Business Rules

The SQL model will follow these business rules:

* Each customer belongs to one customer segment.
* Each customer has one default payment term.
* Each customer has one primary sales channel.
* Each product belongs to one product category.
* Physical products have unit cost, sales price and reorder level.
* Service products do not create inventory movements.
* Purchase order lines increase stock after receipt.
* Sales order lines decrease stock after delivery.
* Each invoice is linked to a sales order.
* Payments can be full, partial, delayed or missing.
* Some invoices will be overdue to support collection analysis.
* Some products will fall below reorder level to support inventory risk reporting.
* Supplier lead times will be simulated to support supplier performance analysis.

---

## 8. Power BI Reporting Areas

The SQL Server model will support the following Power BI dashboard pages:

### Executive Overview

* Total revenue
* Total cost
* Gross profit
* Gross margin
* Open invoice amount
* Collection rate
* Low stock product count

### Sales Analysis

* Monthly sales trend
* Sales by product category
* Sales by customer segment
* Top customers
* Top products
* Sales channel performance

### Inventory Analysis

* Stock on hand
* Products below reorder level
* Stock movement trend
* Inventory by warehouse
* Slow-moving products

### Purchasing & Supplier Analysis

* Purchase volume by supplier
* Supplier category analysis
* Supplier lead time
* Purchase cost trend
* Most purchased products

### Invoice & Payment Tracking

* Invoice amount
* Paid amount
* Open balance
* Overdue invoices
* Payment delay analysis
* Collection performance by customer segment

---

## 9. Portfolio Relevance

This SQL Server data model demonstrates the ability to translate ERP business processes into a structured relational database model.

It connects operational ERP usage with data analysis, reporting, business intelligence and management decision support.
