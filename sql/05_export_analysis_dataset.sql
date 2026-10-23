USE retail_financial_analytics;

-- Run this SELECT, then export the Result Grid as CSV from MySQL Workbench.
-- In the Result Grid, click the export icon and choose CSV.
-- Save as data/retail_analysis.csv in the VS Code project.
SELECT
    t.transaction_id,
    t.transaction_date,
    t.customer_id,
    c.customer_segment,
    c.city,
    t.product_id,
    p.product_name,
    p.category,
    t.quantity,
    p.unit_price,
    p.unit_cost,
    t.discount_pct,
    t.payment_method,
    t.transaction_status,
    ROUND(t.quantity * p.unit_price * (1 - t.discount_pct / 100), 2) AS revenue,
    ROUND(t.quantity * p.unit_cost, 2) AS cogs,
    ROUND(
        t.quantity * p.unit_price * (1 - t.discount_pct / 100)
        - t.quantity * p.unit_cost,
        2
    ) AS gross_profit
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
JOIN products p ON t.product_id = p.product_id
ORDER BY t.transaction_id;
