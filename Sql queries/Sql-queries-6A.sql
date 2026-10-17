-- Q6. are we too dependent on a few sellers?
-- A) the top 15 sellers

WITH seller_rev AS (
    SELECT i.seller_id,
           COUNT(DISTINCT i.order_id) AS orders,
           SUM(i.price) AS revenue
    FROM valid_orders o
    JOIN order_items i USING (order_id)
    GROUP BY 1
)
SELECT seller_id,
       orders,
       ROUND(revenue, 2) AS revenue,
       ROUND(100.0 * revenue / SUM(revenue) OVER (), 1) AS pct_revenue,
       ROUND(100.0 * SUM(revenue) OVER (ORDER BY revenue DESC)
             / SUM(revenue) OVER (), 1) AS cumulative_pct
FROM seller_rev
ORDER BY revenue DESC
LIMIT 15;