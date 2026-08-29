-- =============================================================================
-- Advanced SQL Queries: RFM Segmentation & Cohort Retention Analysis
-- Author: Umar Farooq
-- Concepts: CTEs, Window Functions (NTILE, ROW_NUMBER, LAG), Aggregations & Views
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. RFM Score Calculation using NTILE() Window Functions
-- -----------------------------------------------------------------------------
WITH customer_aggregations AS (
    SELECT 
        CustomerID,
        Country,
        CAST((julianday('2026-01-01') - julianday(MAX(InvoiceDate))) AS INTEGER) AS recency_days,
        COUNT(DISTINCT InvoiceNo) AS frequency_orders,
        ROUND(SUM(TotalAmount), 2) AS monetary_spend
    FROM transactions
    GROUP BY CustomerID, Country
),
rfm_ranked AS (
    SELECT 
        CustomerID,
        Country,
        recency_days,
        frequency_orders,
        monetary_spend,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency_orders ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary_spend ASC) AS m_score
    FROM customer_aggregations
)
SELECT 
    CustomerID,
    recency_days,
    frequency_orders,
    monetary_spend,
    r_score,
    f_score,
    m_score,
    (r_score * 100 + f_score * 10 + m_score) AS rfm_score,
    CASE 
        WHEN r_score >= 4 AND f_score >= 4 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customers'
        WHEN r_score >= 4 AND f_score <= 2 THEN 'Recent Customers'
        WHEN r_score >= 3 AND f_score <= 2 THEN 'Promising'
        WHEN r_score = 2 AND f_score >= 3 THEN 'Need Attention'
        WHEN r_score = 2 AND f_score <= 2 THEN 'About To Sleep'
        WHEN r_score = 1 AND f_score >= 3 THEN 'At Risk'
        ELSE 'Lost / Hibernating'
    END AS customer_segment
FROM rfm_ranked
ORDER BY monetary_spend DESC;

-- -----------------------------------------------------------------------------
-- 2. Monthly Cohort Retention Analysis (Cohort Matrix)
-- -----------------------------------------------------------------------------
WITH customer_first_purchase AS (
    SELECT 
        CustomerID,
        MIN(InvoiceMonth) AS cohort_month
    FROM transactions
    GROUP BY CustomerID
),
cohort_activity AS (
    SELECT 
        t.CustomerID,
        c.cohort_month,
        t.InvoiceMonth,
        -- Calculate month index difference
        (CAST(SUBSTR(t.InvoiceMonth, 1, 4) AS INTEGER) - CAST(SUBSTR(c.cohort_month, 1, 4) AS INTEGER)) * 12 +
        (CAST(SUBSTR(t.InvoiceMonth, 6, 2) AS INTEGER) - CAST(SUBSTR(c.cohort_month, 6, 2) AS INTEGER)) AS month_number
    FROM transactions t
    JOIN customer_first_purchase c ON t.CustomerID = c.CustomerID
),
cohort_sizes AS (
    SELECT 
        cohort_month,
        COUNT(DISTINCT CustomerID) AS cohort_size
    FROM customer_first_purchase
    GROUP BY cohort_month
),
retention_counts AS (
    SELECT 
        a.cohort_month,
        a.month_number,
        COUNT(DISTINCT a.CustomerID) AS active_customers
    FROM cohort_activity a
    GROUP BY a.cohort_month, a.month_number
)
SELECT 
    r.cohort_month,
    s.cohort_size,
    r.month_number,
    r.active_customers,
    ROUND((r.active_customers * 100.0 / s.cohort_size), 2) AS retention_rate_pct
FROM retention_counts r
JOIN cohort_sizes s ON r.cohort_month = s.cohort_month
ORDER BY r.cohort_month, r.month_number;

-- -----------------------------------------------------------------------------
-- 3. Pareto 80/20 Rule Analysis (Cumulative Revenue Concentration)
-- -----------------------------------------------------------------------------
WITH customer_spend AS (
    SELECT 
        CustomerID,
        SUM(TotalAmount) AS total_spend
    FROM transactions
    GROUP BY CustomerID
),
ranked_spend AS (
    SELECT 
        CustomerID,
        total_spend,
        ROW_NUMBER() OVER (ORDER BY total_spend DESC) AS customer_rank,
        COUNT(*) OVER () AS total_customers,
        SUM(total_spend) OVER (ORDER BY total_spend DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_revenue,
        SUM(total_spend) OVER () AS total_revenue
    FROM customer_spend
)
SELECT 
    customer_rank,
    CustomerID,
    ROUND(total_spend, 2) AS total_spend,
    ROUND((customer_rank * 100.0 / total_customers), 2) AS pct_of_customer_base,
    ROUND((cumulative_revenue * 100.0 / total_revenue), 2) AS cumulative_revenue_pct
FROM ranked_spend
WHERE customer_rank IN (10, 50, 100, 200, 500, 1000)
ORDER BY customer_rank;

-- -----------------------------------------------------------------------------
-- 4. Analytical View: High-Value At-Risk Customers (Actionable Churn List)
-- -----------------------------------------------------------------------------
CREATE VIEW IF NOT EXISTS v_at_risk_high_spenders AS
SELECT 
    CustomerID,
    Country,
    Recency_Days,
    Frequency_Orders,
    Monetary_Spend,
    Customer_Segment
FROM customer_rfm
WHERE Customer_Segment IN ('At Risk', 'Need Attention')
  AND Monetary_Spend > 1000
ORDER BY Monetary_Spend DESC;
