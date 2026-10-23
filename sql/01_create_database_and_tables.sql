-- Project: Financial & Retail Business Performance Analysis
-- Requirement: MySQL 8.0+
-- Run this script first in MySQL Workbench.

CREATE DATABASE IF NOT EXISTS retail_financial_analytics;
USE retail_financial_analytics;

CREATE TABLE IF NOT EXISTS customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    city VARCHAR(60) NOT NULL,
    customer_segment VARCHAR(30) NOT NULL
);

CREATE TABLE IF NOT EXISTS products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(40) NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    unit_cost DECIMAL(12,2) NOT NULL,
    CONSTRAINT chk_product_price CHECK (unit_price >= 0),
    CONSTRAINT chk_product_cost CHECK (unit_cost >= 0),
    CONSTRAINT chk_cost_not_above_price CHECK (unit_cost <= unit_price)
);

CREATE TABLE IF NOT EXISTS transactions (
    transaction_id INT PRIMARY KEY,
    transaction_date DATE NOT NULL,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    discount_pct DECIMAL(5,2) NOT NULL DEFAULT 0,
    payment_method VARCHAR(30) NOT NULL,
    transaction_status VARCHAR(20) NOT NULL,
    CONSTRAINT fk_transactions_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_transactions_product
        FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT chk_transaction_quantity CHECK (quantity > 0),
    CONSTRAINT chk_discount_pct CHECK (discount_pct >= 0 AND discount_pct <= 100),
    CONSTRAINT chk_transaction_status CHECK (
        transaction_status IN ('Completed', 'Cancelled', 'Returned', 'Pending')
    )
);

CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_transactions_customer ON transactions(customer_id);
CREATE INDEX idx_transactions_product ON transactions(product_id);
CREATE INDEX idx_transactions_status ON transactions(transaction_status);
