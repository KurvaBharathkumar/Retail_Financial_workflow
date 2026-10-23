USE retail_financial_analytics;

-- 1. Row counts
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'transactions', COUNT(*) FROM transactions;

-- 2. Duplicate transaction IDs (expected: zero rows)
SELECT transaction_id, COUNT(*) AS occurrences
FROM transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1;

-- 3. Invalid values (expected: zero rows)
SELECT *
FROM transactions
WHERE quantity <= 0
   OR discount_pct < 0
   OR discount_pct > 100
   OR transaction_status NOT IN ('Completed', 'Cancelled', 'Returned', 'Pending');

-- 4. Missing mandatory values (expected: zero)
SELECT
    SUM(transaction_date IS NULL) AS missing_dates,
    SUM(customer_id IS NULL) AS missing_customer_ids,
    SUM(product_id IS NULL) AS missing_product_ids
FROM transactions;

-- 5. Date coverage
SELECT MIN(transaction_date) AS first_date,
       MAX(transaction_date) AS last_date
FROM transactions;

-- 6. Transaction status distribution
SELECT transaction_status, COUNT(*) AS row_count
FROM transactions
GROUP BY transaction_status
ORDER BY row_count DESC;
