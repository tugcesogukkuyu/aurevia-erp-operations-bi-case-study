# Master Data Dictionary

## Aurevia ERP Operations & BI Dashboard Case Study

### 1. Purpose

This document defines the master data structure required for the Aurevia ERP Operations & BI Dashboard Case Study.

Master data represents the core business entities used across ERP processes, including customers, suppliers, products, warehouses, payment terms, sales channels, and product categories.

These records will be used in two layers:

1. **Odoo ERP operational layer**
   A smaller representative dataset will be created directly in the ERP portal to demonstrate hands-on ERP usage.

2. **SQL Server and Power BI analytics layer**
   A larger synthetic dataset will be generated for professional-scale reporting and dashboard development.

---

## 2. Business Entity Overview

The project includes the following master data entities:

| Entity              | Purpose                                  |
| ------------------- | ---------------------------------------- |
| Customers           | B2B and premium customer accounts        |
| Suppliers           | Vendors providing products and materials |
| Products & Services | Sellable and purchasable items           |
| Product Categories  | Product grouping for reporting           |
| Warehouses          | Inventory locations                      |
| Payment Terms       | Invoice due date and collection tracking |
| Sales Channels      | Source of customer orders                |
| Customer Segments   | Business classification of customers     |

---

## 3. Customer Segments

Aurevia Professional Supply serves different customer groups in the wellness and spa industry.

| Segment Code | Segment Name           | Description                                     |
| ------------ | ---------------------- | ----------------------------------------------- |
| HOTEL        | Hotel & Resort         | Hotels and resorts with spa/wellness facilities |
| SPA          | Spa Center             | Independent spa and wellness centers            |
| BEAUTY       | Beauty Salon           | Beauty and personal care salons                 |
| CLINIC       | Clinic                 | Dermatology, aesthetic, and wellness clinics    |
| PREMIUM      | Premium Individual     | High-value individual customers                 |
| DISTRIBUTOR  | Distributor / Reseller | Regional dealers or product resellers           |

---

## 4. Example Customers for ERP Portal

The following representative customers will be created in Odoo ERP.

| Customer Code | Customer Name             | Segment     | City     | Payment Term | Sales Channel        |
| ------------- | ------------------------- | ----------- | -------- | ------------ | -------------------- |
| CUST-001      | Lunara Hotel & Spa        | HOTEL       | İzmir    | Net 30       | B2B Direct           |
| CUST-002      | Velora Wellness Resort    | HOTEL       | Muğla    | Net 45       | B2B Direct           |
| CUST-003      | Serene Touch Spa          | SPA         | İstanbul | Net 30       | Website Lead         |
| CUST-004      | Mira Beauty Studio        | BEAUTY      | Ankara   | Net 15       | Sales Representative |
| CUST-005      | Dermaline Clinic          | CLINIC      | İzmir    | Net 30       | B2B Direct           |
| CUST-006      | Elara Spa Lounge          | SPA         | Antalya  | Net 30       | Website Lead         |
| CUST-007      | Nova Esthetic Center      | CLINIC      | Bursa    | Net 45       | Sales Representative |
| CUST-008      | Aura Beauty House         | BEAUTY      | İstanbul | Net 15       | Website Lead         |
| CUST-009      | Maris Wellness Hotel      | HOTEL       | Aydın    | Net 30       | B2B Direct           |
| CUST-010      | Ege Wellness Distribution | DISTRIBUTOR | İzmir    | Net 60       | Distributor          |

---

## 5. Product Categories

| Category Code | Category Name         | Description                                        |
| ------------- | --------------------- | -------------------------------------------------- |
| MASSAGE_OIL   | Massage Oils          | Professional massage oils and blends               |
| AROMA         | Aromatherapy Products | Essential oils, diffusers, and aroma sets          |
| HAMMAM        | Hammam & Ritual Kits  | Hammam, kese, köpük, and ritual packages           |
| TEXTILE       | Spa Textile           | Towels, robes, slippers, and textile products      |
| SKINCARE      | Skincare Products     | Facial care and professional skincare items        |
| CONSUMABLE    | Spa Consumables       | Disposable and operational spa supplies            |
| VIP_KIT       | Premium Wellness Kits | High-value bundled wellness packages               |
| SERVICE       | Training & Consulting | Staff training and operational consulting services |

---

## 6. Example Products and Services for ERP Portal

| Product Code | Product Name                        | Category    | Type    | Unit Cost | Sales Price | Reorder Level |
| ------------ | ----------------------------------- | ----------- | ------- | --------: | ----------: | ------------: |
| PRD-001      | Aurevia Lavender Massage Oil 500 ml | MASSAGE_OIL | Product |       180 |         320 |            50 |
| PRD-002      | Aurevia Relax Massage Oil 500 ml    | MASSAGE_OIL | Product |       190 |         340 |            50 |
| PRD-003      | Deep Tissue Massage Oil 1 L         | MASSAGE_OIL | Product |       310 |         560 |            30 |
| PRD-004      | Aromatherapy Essential Oil Set      | AROMA       | Product |       420 |         780 |            25 |
| PRD-005      | Premium Diffuser Set                | AROMA       | Product |       350 |         690 |            20 |
| PRD-006      | Hammam Ritual Kit Standard          | HAMMAM      | Product |       260 |         480 |            40 |
| PRD-007      | Hammam Ritual Kit Premium           | HAMMAM      | Product |       430 |         790 |            30 |
| PRD-008      | Spa Towel Set                       | TEXTILE     | Product |       220 |         410 |            60 |
| PRD-009      | Premium Bathrobe                    | TEXTILE     | Product |       390 |         720 |            35 |
| PRD-010      | Disposable Slipper Pack             | CONSUMABLE  | Product |        90 |         180 |           100 |
| PRD-011      | Facial Care Professional Kit        | SKINCARE    | Product |       520 |         980 |            25 |
| PRD-012      | Anti-Aging Facial Serum 30 ml       | SKINCARE    | Product |       280 |         590 |            40 |
| PRD-013      | VIP Spa Experience Kit              | VIP_KIT     | Product |       760 |        1450 |            15 |
| PRD-014      | Bridal Hammam Package Kit           | VIP_KIT     | Product |       690 |        1290 |            15 |
| SRV-001      | Spa Staff Product Training          | SERVICE     | Service |         0 |        3500 |             0 |
| SRV-002      | Wellness Operations Consulting      | SERVICE     | Service |         0 |        5500 |             0 |

---

## 7. Supplier List

| Supplier Code | Supplier Name       | Supplier Category | City     | Payment Term |
| ------------- | ------------------- | ----------------- | -------- | ------------ |
| SUP-001       | Botanica Oils Ltd.  | Massage Oils      | İzmir    | Net 30       |
| SUP-002       | Natural Essence Co. | Aromatherapy      | İstanbul | Net 30       |
| SUP-003       | Ege Textile Supply  | Spa Textile       | Denizli  | Net 45       |
| SUP-004       | Dermalab Cosmetics  | Skincare          | İstanbul | Net 45       |
| SUP-005       | HammamPro Supplies  | Hammam Products   | Bursa    | Net 30       |
| SUP-006       | Velinor Packaging   | Consumables       | İzmir    | Net 30       |

---

## 8. Warehouses

| Warehouse Code | Warehouse Name              | Location | Purpose                            |
| -------------- | --------------------------- | -------- | ---------------------------------- |
| WH-001         | Main Warehouse              | İzmir    | Main inventory location            |
| WH-002         | Istanbul Transfer Warehouse | İstanbul | Regional transfer and distribution |
| WH-003         | Antalya Seasonal Warehouse  | Antalya  | Seasonal hotel and resort demand   |

---

## 9. Payment Terms

| Payment Term | Description          | Due Days |
| ------------ | -------------------- | -------: |
| Immediate    | Paid at invoice date |        0 |
| Net 15       | Due within 15 days   |       15 |
| Net 30       | Due within 30 days   |       30 |
| Net 45       | Due within 45 days   |       45 |
| Net 60       | Due within 60 days   |       60 |

---

## 10. Sales Channels

| Sales Channel        | Description                            |
| -------------------- | -------------------------------------- |
| B2B Direct           | Direct corporate sales                 |
| Website Lead         | Lead generated from Aurevia website    |
| Sales Representative | Managed by sales team                  |
| Distributor          | Dealer or reseller channel             |
| Repeat Order         | Recurring order from existing customer |

---

## 11. Odoo ERP Portal Setup Scope

The Odoo ERP portal will include a representative operational dataset:

| Entity              | Target Count in Odoo |
| ------------------- | -------------------: |
| Customers           |                   10 |
| Suppliers           |                    6 |
| Products & Services |                   16 |
| Warehouses          |                    3 |
| Purchase Orders     |                 5–10 |
| Sales Orders        |                10–20 |
| Invoices            |                10–20 |
| Payments            |                 8–15 |

This dataset is intended to demonstrate ERP portal usage, screen navigation, transaction creation, and operational process understanding.

---

## 12. SQL Server Analytics Dataset Scope

The SQL Server layer will include a larger synthetic ERP dataset:

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

This dataset will support professional-scale Power BI reporting and KPI analysis.

---

## 13. Business Rules

The following business rules will be used in the synthetic ERP process:

* Each customer belongs to one customer segment.
* Each product belongs to one product category.
* Each product has a unit cost, sales price, and reorder level.
* Sales orders can include multiple products.
* Purchase orders increase inventory after stock receipt.
* Sales deliveries decrease inventory.
* Each invoice is linked to a sales order.
* Payments may be full, partial, delayed, or missing.
* Some invoices will be overdue to support collection analysis.
* Some products will fall below reorder level to support inventory risk analysis.
* Supplier lead times will be simulated for purchasing performance analysis.

---

## 14. Reporting Relevance

The master data structure will support the following Power BI reporting areas:

* Sales performance by month, product, category, customer, and segment
* Gross profit and margin analysis
* Inventory stock level and reorder risk
* Supplier purchasing and delivery performance
* Invoice status and overdue receivables
* Collection rate and payment delay analysis
* Executive KPI overview
