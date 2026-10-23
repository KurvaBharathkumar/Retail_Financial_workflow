USE retail_financial_analytics;

-- Analysis definition:
-- Revenue = quantity * unit_price * (1 - discount_pct / 100)
-- COGS = quantity * unit_cost
-- Gross profit = revenue - COGS
-- Only Completed transaction lines contribute to sales KPIs.
-- This synthetic dataset does not model taxes, shipping, operating expenses, or refund amounts.

-- 1. Overall financial KPIs
SELECT
    COUNT(*) AS completed_transaction_lines,
    COUNT(DISTINCT transaction_id) AS completed_transactions,
    ROUND(SUM(t.quantity * p.unit_price * (1 - t.discount_pct / 100)), 2) AS revenue,
    ROUND(SUM(t.quantity * p.unit_cost), 2) AS cogs,
    ROUND(SUM(t.quantity * p.unit_price * (1 - t.discount_pct / 100))
          - SUM(t.quantity * p.unit_cost), 2) AS gross_profit,
    ROUND(
        100 * (
            SUM(t.quantity * p.unit_price * (1 - t.discount_pct / 100))
            - SUM(t.quantity * p.unit_cost)
        ) / NULLIF(SUM(t.quantity * p.unit_price * (1 - t.discount_pct / 100)), 0),
        2
    ) AS gross_profit_margin_pct
FROM transactions t
JOIN products p ON t.product_id = p.product_id
WHERE t.transaction_status = 'Completed';

-- 2. Monthly revenue and profit
SELECT
    DATE_FORMAT(t.transaction_date, '%Y-%m') AS sales_month,
    ROUND(SUM(t.quantity * p.unit_price * (1 - t.discount_pct / 100)), 2) AS revenue,
    ROUND(SUM(t.quantity * p.unit_cost), 2) AS cogs,
    ROUND(SUM(t.quantity * p.unit_price * (1 - t.discount_pct / 100))
          - SUM(t.quantity * p.unit_cost), 2) AS gross_profit
FROM transactions t
JOIN products p ON t.product_id = p.product_id
WHERE t.transaction_status = 'Completed'
GROUP BY DATE_FORMAT(t.transaction_date, '%Y-%m')
ORDER BY sales_month;

-- 3. Category performance
SELECT
    p.category,
    SUM(t.quantity) AS units_sold,
    ROUND(SUM(t.quantity * p.unit_price * (1 - t.discount_pct / 100)), 2) AS revenue,
    ROUND(SUM(t.quantity * p.unit_cost), 2) AS cogs,
    ROUND(SUM(t.quantity * p.unit_price * (1 - t.discount_pct / 100))
          - SUM(t.quantity * p.unit_cost), 2) AS gross_profit,
    ROUND(
        100 * (
            SUM(t.quantity * p.unit_price * (1 - t.discount_pct / 100))
            - SUM(t.quantity * p.unit_cost)
        ) / NULLIF(SUM(t.quantity * p.unit_price * (1 - t.discount_pct / 100)), 0),
        2
    ) AS gross_profit_margin_pct
FROM transactions t
JOIN products p ON t.product_id = p.product_id
WHERE t.transaction_status = 'Completed'
GROUP BY p.category
ORDER BY revenue DESC;

-- 4. Top 10 products by revenue
SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(t.quantity) AS units_sold,
    ROUND(SUM(t.quantity * p.unit_price * (1 - t.discount_pct / 100)), 2) AS revenue,
    ROUND(SUM(t.quantity * p.unit_cost), 2) AS cogs,
    ROUND(SUM(t.quantity * p.unit_price * (1 - t.discount_pct / 100))
          - SUM(t.quantity * p.unit_cost), 2) AS gross_profit
FROM transactions t
JOIN products p ON t.product_id = p.product_id
WHERE t.transaction_status = 'Completed'
GROUP BY p.product_id, p.product_name, p.category
ORDER BY revenue DESC
LIMIT 10;

-- 5. Customer segment performance
SELECT
    c.customer_segment,
    COUNT(DISTINCT t.transaction_id) AS completed_transactions,
    ROUND(SUM(t.quantity * p.unit_price * (1 - t.discount_pct / 100)), 2) AS revenue,
    ROUND(SUM(t.quantity * p.unit_price * (1 - t.discount_pct / 100))
          - SUM(t.quantity * p.unit_cost), 2) AS gross_profit
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
JOIN products p ON t.product_id = p.product_id
WHERE t.transaction_status = 'Completed'
GROUP BY c.customer_segment
ORDER BY revenue DESC;

-- 6. Transaction status mix
SELECT
    transaction_status,
    COUNT(*) AS transaction_lines,
    ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM transactions), 2) AS pct_of_all_lines
FROM transactions
GROUP BY transaction_status
ORDER BY transaction_lines DESC;
