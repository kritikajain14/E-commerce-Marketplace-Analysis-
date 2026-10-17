-- Q2 who are our top customers, by state and by value?
-- B)customer value segments (the 80/20 check)
WITH customer_rev AS (
    SELECT c.customer_unique_id,
           SUM(i.price) AS revenue
    FROM valid_orders o
    JOIN customers c   USING (customer_id)
    JOIN order_items i USING (order_id)
    GROUP BY 1
),
ranked AS (
    SELECT customer_unique_id, revenue,
           NTILE(10) OVER (ORDER BY revenue DESC) AS decile
    FROM customer_rev
)
SELECT decile,
       COUNT(*)                                              AS customers,
       ROUND(SUM(revenue), 2)                                AS revenue,
       ROUND(100.0 * SUM(revenue) / SUM(SUM(revenue)) OVER (), 1) AS pct_of_revenue,
       ROUND(MIN(revenue), 2)                                AS min_spend,
       ROUND(MAX(revenue), 2)                                AS max_spend
FROM ranked
GROUP BY decile
ORDER BY decile;