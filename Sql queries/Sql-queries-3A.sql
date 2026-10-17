-- Q3. do customers come back?
-- A) repeat purchase rate and order distribution

WITH cust AS (
    SELECT c.customer_unique_id,
           COUNT(DISTINCT o.order_id) AS orders
    FROM valid_orders o
    JOIN customers c USING (customer_id)
    GROUP BY 1
)
SELECT orders,
       COUNT(*)                                          AS customers,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_customers
FROM cust
GROUP BY orders
ORDER BY orders;