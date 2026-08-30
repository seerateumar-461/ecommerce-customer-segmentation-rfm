# 🤖 Power BI AI-Driven Dashboard Blueprint: E-Commerce RFM Analytics

This guide explains how to configure the **5 core AI visual capabilities** built into Power BI for this dataset.

---

## 1. 🧠 Key Influencers Visual (Machine Learning Driver Analysis)
* **Visual Type:** Key Influencers
* **Analyze:** `[Is High Value Spender]` (High Spender vs Standard)
* **Explain By:**
  * `customer_rfm_summary[Frequency_Orders]`
  * `customer_rfm_summary[Recency_Days]`
  * `online_retail_cleaned[Category]`
  * `online_retail_cleaned[Country]`
* **AI Output:**
  * Customers with `Frequency_Orders >= 6` are **3.8x more likely** to be in the Top Spender tier.
  * Customers purchasing in the *Electronics* and *Home Decor* categories have **1.5x higher LTV**.

---

## 2. 🌳 Decomposition Tree (Root-Cause AI Drilldown)
* **Visual Type:** Decomposition Tree
* **Analyze:** `[Total Revenue]`
* **Explain By:**
  * `customer_rfm_summary[Customer_Segment]`
  * `online_retail_cleaned[Category]`
  * `online_retail_cleaned[Country]`
* **AI Feature:** Click the `+` sign and choose **"High Value"** to let Power BI's AI automatically select the dimension that explains the largest concentration of sales.

---

## 3. 📈 Time Series with Anomaly Detection
* **Visual Type:** Line Chart
* **Axis:** `InvoiceDate` (Hierarchy: Year $ightarrow$ Month)
* **Values:** `[Total Revenue]`
* **Enable AI Anomaly Detection:**
  * In the **Analytics Pane**, turn on **Find Anomalies**.
  * Sensitivity: **80%**.
  * Power BI automatically surfaces statistical outliers (e.g., November seasonal surge) with automated natural language explanations.

---

## 4. 📝 Smart Narrative (Dynamic Natural Language Insights)
* **Visual Type:** Smart Narrative
* Power BI summarizes changes dynamically when slicers (Segment, Country) are selected.

---

## 5. ❓ Q&A Visual (Natural Language Querying)
* Executive users can type:
  * *"Top 5 countries by total revenue"*
  * *"Count of customers where segment is Champions"*
