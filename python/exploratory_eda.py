"""
E-Commerce Exploratory Data Analysis & Visualizations
Author: Umar Farooq
"""

import os
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

def generate_eda_charts():
    rfm = pd.read_csv(os.path.join("data", "cleaned", "customer_rfm_summary.csv"))
    df = pd.read_csv(os.path.join("data", "cleaned", "online_retail_cleaned.csv"))
    retention = pd.read_csv(os.path.join("data", "cleaned", "cohort_retention_matrix.csv"), index_col=0)

    os.makedirs(os.path.join("tableau", "visuals"), exist_ok=True)
    plt.style.use("seaborn-v0_8-whitegrid")

    # Chart 1: Segment Breakdown & Revenue
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    seg_counts = rfm["Customer_Segment"].value_counts()
    sns.barplot(x=seg_counts.values, y=seg_counts.index, palette="viridis", ax=axes[0], hue=seg_counts.index, legend=False)
    axes[0].set_title("Customer Count by RFM Segment", fontsize=12, fontweight="bold")
    axes[0].set_xlabel("Number of Customers")

    monthly_rev = df.groupby("InvoiceMonth")["TotalAmount"].sum()
    axes[1].plot(monthly_rev.index, monthly_rev.values / 1000, marker="o", color="#1F4E78", linewidth=2.5)
    axes[1].set_title("Monthly Revenue Trend ($ in Thousands)", fontsize=12, fontweight="bold")
    axes[1].set_ylabel("Revenue ($K)")
    axes[1].tick_params(axis="x", rotation=45)
    plt.tight_layout()
    fig.savefig(os.path.join("tableau", "visuals", "eda_rfm_summary.png"), dpi=200)
    plt.close()

    # Chart 2: Cohort Retention Heatmap
    plt.figure(figsize=(10, 6))
    sns.heatmap(retention, annot=True, fmt=".1f", cmap="Blues", cbar_kws={'label': 'Retention Rate (%)'}, vmin=0, vmax=100)
    plt.title("Monthly Customer Retention Cohorts (%)", fontsize=13, fontweight="bold", pad=12)
    plt.xlabel("Months Since Acquisition (Cohort Index)")
    plt.ylabel("Acquisition Cohort Month")
    plt.tight_layout()
    plt.savefig(os.path.join("tableau", "visuals", "cohort_retention_heatmap.png"), dpi=200)
    plt.close()

    print("[EDA] Visual charts generated in tableau/visuals/")

if __name__ == "__main__":
    generate_eda_charts()
