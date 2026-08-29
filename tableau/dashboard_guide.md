# Tableau & Power BI Dashboard Blueprint: E-Commerce RFM Analytics

## 1. Data Source Connections
* **Database Connection:** Connect directly to `data/ecommerce.db` or load `data/cleaned/online_retail_cleaned.csv` and `data/cleaned/customer_rfm_summary.csv`.
* **Primary Key:** `CustomerID`

---

## 2. Key Calculated Fields (Tableau Formulas)

```tableau
// 1. Customer Acquisition Cohort (LOD Expression)
{ FIXED [CustomerID] : MIN([InvoiceDate]) }

// 2. Customer Lifetime Value (CLV)
{ FIXED [CustomerID] : SUM([TotalAmount]) }

// 3. Cohort Index (Months Since Acquisition)
DATEDIFF('month', [Acquisition Cohort], [InvoiceDate])

// 4. RFM Score Composite
STR([R_Score]) + STR([F_Score]) + STR([M_Score])

// 5. High-Value Customer Indicator
IF [Monetary_Spend] >= 2000 THEN "Tier 1 High-Value"
ELSEIF [Monetary_Spend] >= 1000 THEN "Tier 2 Mid-Value"
ELSE "Tier 3 Standard"
END
```

---

## 3. Dashboard Layout & Visual Structure

### 📌 Top Executive KPI Bar:
1. **Total Revenue:** `$1.24M` (Dynamic SUM)
2. **Active Customers:** `1,200` (COUNTD of CustomerID)
3. **Average Order Value (AOV):** `$82.50`
4. **Repeat Purchase Rate:** `74.2%`

### 📊 Main Visuals:
* **Visual 1 (Top Left):** **RFM Segmentation Matrix** (Treemap / Horizontal Bar) color-coded by tier (Champions = Green, At Risk = Coral, Lost = Gray).
* **Visual 2 (Top Right):** **Monthly Revenue Trend & YoY Growth** with dynamic date slider.
* **Visual 3 (Bottom Left):** **Cohort Retention Heatmap** displaying % retention over 12 months with custom blue color palette.
* **Visual 4 (Bottom Right):** **Geographic Sales Heatmap** filterable by Country.

---

## 4. Interactive Filters
* **Date Range:** Invoice Month Slicer
* **Customer Segment:** Multi-select dropdown
* **Country:** Geographic region selector
