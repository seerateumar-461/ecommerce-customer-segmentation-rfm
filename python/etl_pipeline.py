"""
E-Commerce Customer Segmentation & Cohort Analysis ETL Pipeline
Author: Umar Farooq
Description: Automated data cleaning, feature engineering for RFM segmentation,
             cohort retention calculation, and SQLite database loading.
"""

import os
import pandas as pd
import numpy as np
import sqlite3

def run_etl():
    raw_path = os.path.join("data", "raw", "online_retail_raw.csv")
    cleaned_path = os.path.join("data", "cleaned", "online_retail_cleaned.csv")
    rfm_path = os.path.join("data", "cleaned", "customer_rfm_summary.csv")
    cohort_path = os.path.join("data", "cleaned", "cohort_retention_matrix.csv")
    db_path = os.path.join("data", "ecommerce.db")

    print("[ETL] Loading raw transaction data...")
    df = pd.read_csv(raw_path)

    # Data Cleaning: Remove missing CustomerIDs & cancellations
    print(f"[ETL] Initial rows: {len(df)}")
    df = df.dropna(subset=["CustomerID"])
    df = df[df["Quantity"] > 0]
    df["TotalAmount"] = (df["Quantity"] * df["UnitPrice"]).round(2)
    df["InvoiceDate"] = pd.to_datetime(df["InvoiceDate"])
    df["InvoiceMonth"] = df["InvoiceDate"].dt.to_period("M").astype(str)
    print(f"[ETL] Cleaned valid rows: {len(df)}")

    # RFM Feature Engineering
    snapshot_date = df["InvoiceDate"].max() + pd.Timedelta(days=1)
    rfm = df.groupby("CustomerID").agg({
        "InvoiceDate": lambda x: (snapshot_date - x.max()).days,
        "InvoiceNo": "nunique",
        "TotalAmount": "sum",
        "Country": "first"
    }).reset_index()
    rfm.columns = ["CustomerID", "Recency_Days", "Frequency_Orders", "Monetary_Spend", "Country"]
    rfm["Monetary_Spend"] = rfm["Monetary_Spend"].round(2)

    rfm["R_Score"] = pd.qcut(rfm["Recency_Days"], 5, labels=[5, 4, 3, 2, 1]).astype(int)
    rfm["F_Score"] = pd.qcut(rfm["Frequency_Orders"].rank(method="first"), 5, labels=[1, 2, 3, 4, 5]).astype(int)
    rfm["M_Score"] = pd.qcut(rfm["Monetary_Spend"], 5, labels=[1, 2, 3, 4, 5]).astype(int)
    rfm["RFM_Score"] = rfm["R_Score"] * 100 + rfm["F_Score"] * 10 + rfm["M_Score"]

    def assign_segment(row):
        r, f, m = row["R_Score"], row["F_Score"], row["M_Score"]
        if r >= 4 and f >= 4:
            return "Champions"
        elif r >= 3 and f >= 3:
            return "Loyal Customers"
        elif r >= 4 and f <= 2:
            return "Recent Customers"
        elif r >= 3 and f <= 2:
            return "Promising"
        elif r == 2 and f >= 3:
            return "Need Attention"
        elif r == 2 and f <= 2:
            return "About To Sleep"
        elif r == 1 and f >= 3:
            return "At Risk"
        else:
            return "Lost / Hibernating"

    rfm["Customer_Segment"] = rfm.apply(assign_segment, axis=1)

    # Cohort Retention Matrix
    df["CohortMonth"] = df.groupby("CustomerID")["InvoiceDate"].transform("min").dt.to_period("M").astype(str)
    cohort_data = df.groupby(["CohortMonth", "InvoiceMonth"])["CustomerID"].nunique().reset_index()
    cohort_data["CohortMonth_dt"] = pd.to_datetime(cohort_data["CohortMonth"])
    cohort_data["InvoiceMonth_dt"] = pd.to_datetime(cohort_data["InvoiceMonth"])
    cohort_data["CohortIndex"] = (cohort_data["InvoiceMonth_dt"].dt.year - cohort_data["CohortMonth_dt"].dt.year) * 12 + (cohort_data["InvoiceMonth_dt"].dt.month - cohort_data["CohortMonth_dt"].dt.month)

    cohort_pivot = cohort_data.pivot_table(index="CohortMonth", columns="CohortIndex", values="CustomerID")
    cohort_sizes = cohort_pivot.iloc[:, 0]
    retention_matrix = cohort_pivot.divide(cohort_sizes, axis=0).round(4) * 100

    # Save Cleaned CSVs
    os.makedirs(os.path.dirname(cleaned_path), exist_ok=True)
    df.to_csv(cleaned_path, index=False)
    rfm.to_csv(rfm_path, index=False)
    retention_matrix.to_csv(cohort_path)

    # Save to SQLite
    conn = sqlite3.connect(db_path)
    df.to_sql("transactions", conn, if_exists="replace", index=False)
    rfm.to_sql("customer_rfm", conn, if_exists="replace", index=False)
    conn.close()

    print("[ETL] Pipeline finished successfully. Database and cleaned CSVs generated.")

if __name__ == "__main__":
    run_etl()
