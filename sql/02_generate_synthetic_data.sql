-- Generates 50 customers, 20 products, and exactly 550 transaction-line records.
-- Requirement: MySQL 8.0+ (recursive CTE support).
-- Run after 01_create_database_and_tables.sql.
USE retail_financial_analytics;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE transactions;
TRUNCATE TABLE customers;
TRUNCATE TABLE products;
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO customers (customer_id, customer_name, city, customer_segment)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 50
)
SELECT
    n,
    CONCAT('Customer_', LPAD(n, 3, '0')),
    ELT(1 + MOD(n * 7, 8),
        'Hyderabad', 'Bengaluru', 'Mumbai', 'Delhi',
        'Chennai', 'Pune', 'Kolkata', 'Ahmedabad'),
    ELT(1 + MOD(n * 3, 3), 'Consumer', 'Small Business', 'Corporate')
FROM seq;

INSERT INTO products (product_id, product_name, category, unit_price, unit_cost)
VALUES
(1, 'Laptop Basic', 'Electronics', 52000.00, 41000.00),
(2, 'Laptop Pro', 'Electronics', 78000.00, 62000.00),
(3, 'Wireless Mouse', 'Accessories', 900.00, 420.00),
(4, 'Mechanical Keyboard', 'Accessories', 3500.00, 1900.00),
(5, 'Monitor 24 inch', 'Electronics', 12500.00, 9000.00),
(6, 'Monitor 27 inch', 'Electronics', 18500.00, 13800.00),
(7, 'USB-C Hub', 'Accessories', 2400.00, 1150.00),
(8, 'Headphones', 'Accessories', 4200.00, 2300.00),
(9, 'Office Chair', 'Furniture', 9800.00, 6500.00),
(10, 'Standing Desk', 'Furniture', 22000.00, 15800.00),
(11, 'Desk Lamp', 'Furniture', 1800.00, 850.00),
(12, 'Notebook Pack', 'Stationery', 450.00, 180.00),
(13, 'Pen Set', 'Stationery', 300.00, 90.00),
(14, 'Printer', 'Electronics', 14500.00, 10800.00),
(15, 'Webcam', 'Electronics', 3200.00, 1650.00),
(16, 'Backpack', 'Accessories', 2600.00, 1300.00),
(17, 'Filing Cabinet', 'Furniture', 7500.00, 5100.00),
(18, 'Paper Ream', 'Stationery', 380.00, 210.00),
(19, 'Calculator', 'Stationery', 850.00, 390.00),
(20, 'Docking Station', 'Electronics', 8900.00, 6100.00);

INSERT INTO transactions (
    transaction_id, transaction_date, customer_id, product_id,
    quantity, discount_pct, payment_method, transaction_status
)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 550
)
SELECT
    n,
    DATE_ADD('2025-01-01', INTERVAL MOD(n * 17, 365) DAY),
    1 + MOD(n * 13, 50),
    1 + MOD(n * 7, 20),
    1 + MOD(n * 11, 5),
    ELT(1 + MOD(n * 5, 5), 0.00, 5.00, 10.00, 15.00, 20.00),
    ELT(1 + MOD(n * 3, 4), 'Card', 'UPI', 'Cash', 'Net Banking'),
    CASE
        WHEN MOD(n, 20) = 0 THEN 'Cancelled'
        WHEN MOD(n, 17) = 0 THEN 'Returned'
        WHEN MOD(n, 13) = 0 THEN 'Pending'
        ELSE 'Completed'
    END
FROM seq;

-- Expected: customers=50, products=20, transactions=550.
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'transactions', COUNT(*) FROM transactions;
