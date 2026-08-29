-- =============================================================================
-- E-Commerce Analytics Database Schema
-- Author: Umar Farooq
-- Database: SQLite / PostgreSQL compatible
-- =============================================================================

DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS customer_rfm;

CREATE TABLE transactions (
    InvoiceNo VARCHAR(20) NOT NULL,
    StockCode VARCHAR(20) NOT NULL,
    Description VARCHAR(255),
    Category VARCHAR(50),
    Quantity INTEGER NOT NULL,
    InvoiceDate TIMESTAMP NOT NULL,
    UnitPrice NUMERIC(10, 2) NOT NULL,
    CustomerID VARCHAR(20) NOT NULL,
    Country VARCHAR(50),
    TotalAmount NUMERIC(10, 2) NOT NULL,
    InvoiceMonth VARCHAR(7) NOT NULL,
    CohortMonth VARCHAR(7)
);

CREATE INDEX idx_trans_customer ON transactions(CustomerID);
CREATE INDEX idx_trans_date ON transactions(InvoiceDate);

CREATE TABLE customer_rfm (
    CustomerID VARCHAR(20) PRIMARY KEY,
    Recency_Days INTEGER NOT NULL,
    Frequency_Orders INTEGER NOT NULL,
    Monetary_Spend NUMERIC(12, 2) NOT NULL,
    Country VARCHAR(50),
    R_Score INTEGER NOT NULL,
    F_Score INTEGER NOT NULL,
    M_Score INTEGER NOT NULL,
    RFM_Score INTEGER NOT NULL,
    Customer_Segment VARCHAR(50) NOT NULL
);

CREATE INDEX idx_rfm_segment ON customer_rfm(Customer_Segment);
