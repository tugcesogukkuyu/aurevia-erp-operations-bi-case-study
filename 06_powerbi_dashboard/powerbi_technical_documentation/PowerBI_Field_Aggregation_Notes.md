# Power BI Field Aggregation & Formatting Notes

## Project

**Aurevia ERP Operations & BI Dashboard Case Study**

## Purpose

This document records important Power BI aggregation, formatting, and modeling decisions made during dashboard development.

Power BI can automatically summarize numeric fields incorrectly if aggregation behavior is not reviewed. This document records how those risks were handled.

---

## Main Aggregation Risks

| Risk | Example | Resolution |
|---|---|---|
| Numeric fields defaulting to Count | Revenue showing count instead of total amount | Changed aggregation to `Toplam` |
| Percentage fields being summed | Gross margin % or delay rate % being added together | Used DAX measures or `Ortalama` |
| Rounded KPI values hiding exact operational value | Reorder shortage shown as 2K | Created formatted label measure |
| Wrong business meaning in KPI title | Invoice count labeled as open invoice count | Corrected title to Invoice Count |
| Low-value visuals added only for variety | Scatter/combo charts without clear message | Replaced with tables or insight boxes |

---

## Aggregation Rules Applied

| Field Type | Aggregation Decision |
|---|---|
| Revenue amount | `Toplam` |
| Cost amount | `Toplam` |
| Gross profit amount | `Toplam` |
| Invoice amount | `Toplam` |
| Paid amount | `Toplam` |
| Open balance | `Toplam` |
| Purchase amount | `Toplam` |
| Purchase order count | `Toplam` |
| Delayed purchase order count | `Toplam` |
| Product count | `Toplam` or `DISTINCTCOUNT` depending on context |
| Product code | `DISTINCTCOUNT` |
| Gross margin percentage | DAX measure or `Ortalama` |
| Supplier delay rate percentage | DAX measure |
| Average delay days | `Ortalama` |
| Reorder gap | `Toplam` with risk filter |

---

## Page-Level Aggregation Notes

### Executive Overview

| Area | Decision |
|---|---|
| Total Revenue | Aggregated as total amount |
| Gross Profit | Aggregated as total amount |
| Gross Margin % | Calculated using DAX |
| Collection Rate % | Calculated using DAX |
| Open Balance | Aggregated as total amount |
| Risk KPIs | Validated against inventory and supplier views |

---

### Sales Analysis

| Area | Decision |
|---|---|
| Monthly revenue | Total revenue by month |
| Monthly gross profit | Total gross profit by month |
| Sales channel revenue | Total revenue by channel |
| Customer segment revenue | Total revenue by segment |
| Customer segment gross profit | Total gross profit by segment |

Notes:

- Sales fields were reviewed to prevent count aggregation.
- Revenue and profit were displayed together where comparison was useful.

---

### Product Profitability

| Area | Decision |
|---|---|
| Gross profit by category | Sum of GrossProfit |
| Gross margin by category | Average / measure-based percentage |
| Profit contribution | GrossProfit used as value |
| Product count | Sum of category product count |

Notes:

- GrossMarginPercent was not summed.
- Treemap was used only for profit contribution, not for margin.
- A detail table was included to show revenue, profit, margin, quantity, and product count together.

---

### Inventory Risk

| Area | Decision |
|---|---|
| Products monitored | Distinct count of ProductCode |
| Products below reorder | Filtered product count |
| Negative stock products | Filtered product count where stock < 0 |
| Total reorder shortage | Sum of ReorderGap filtered by negative stock status |
| Reorder shortage label | DAX `FORMAT()` measure |

Notes:

- Reorder shortage was validated carefully because sign direction affects the result.
- Exact shortage value was displayed as 1,855 instead of rounded 2K.
- Inventory action table was filtered to show risk products only.

---

### Receivables Collection

| Area | Decision |
|---|---|
| Total invoice amount | Sum of TotalInvoiceAmount |
| Total paid amount | Sum of TotalPaidAmount |
| Open balance | Sum of OpenBalance |
| Collection rate | DAX ratio |
| Invoice count | Sum of InvoiceCount |

Notes:

- Invoice Count title was corrected to avoid implying that the value represented only open invoices.
- Aging bucket analysis was used because customer-level receivables fields were not available in the source view.

---

### Supplier Performance

| Area | Decision |
|---|---|
| Total purchase amount | Sum of TotalPurchaseAmount |
| Purchase order count | Sum of PurchaseOrderCount |
| Delayed purchase order count | Sum of DelayedPurchaseOrderCount |
| Average delay days | Average of AverageDelayDays |
| Supplier delay rate | DAX ratio |

Notes:

- Supplier delay percentage was calculated with DAX instead of summing percentages.
- The action table was used to make supplier follow-up more practical.
- Table text size and row padding were adjusted for readability.

---

## Formatting Decisions

| Component | Formatting Decision |
|---|---|
| KPI cards | Consistent size, border, shadow, and title style |
| Percentage KPIs | 1 decimal place |
| Revenue values | Display units reviewed for readability |
| Tables | Column names renamed for business readability |
| Table grid | Text size and row padding adjusted |
| Visual titles | Business-oriented titles used |
| Page layout | Consistent spacing and structure across pages |
| Screenshots | Captured from report canvas without Power BI side panels |

---

## Manual Corrections Made

| Issue | Correction |
|---|---|
| Some values displayed as count | Changed field aggregation to `Toplam` |
| Percentage fields risked wrong totals | Used DAX or average aggregation |
| Inventory reorder shortage rounded | Added label measure |
| Supplier table too dense | Reduced text size and padding |
| Redundant visuals | Removed and replaced with business-focused components |
| Dashboard screenshots included UI elements | Re-captured as clean report visuals |

---

## Final Status

Power BI aggregation, formatting, and visual decisions were reviewed and documented.

The final dashboard uses controlled aggregation behavior, validated KPI logic, and business-focused visual design.