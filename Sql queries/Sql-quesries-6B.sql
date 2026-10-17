-- Q6. are we too dependent on a few sellers?
-- B) concentration milestones

WITH seller_rev AS (
    SELECT i.seller_id, SUM(i.price) AS revenue
    FROM valid_orders o
    JOIN order_items i USING (order_id)
    GROUP BY 1
),
ranked AS (
    SELECT revenue,
           ROW_NUMBER() OVER (ORDER BY revenue DESC) AS rnk,
           COUNT(*) OVER ()   AS n,
           SUM(revenue) OVER () AS total_rev
    FROM seller_rev
)
SELECT MAX(n) AS sellers,
       ROUND(100.0 * SUM(revenue) FILTER (WHERE rnk <= 10) / MAX(total_rev), 1) AS top_10_sellers_pct,
       ROUND(100.0 * SUM(revenue) FILTER (WHERE rnk <= CEIL(0.01 * n)) / MAX(total_rev), 1) AS top_1pct_pct,
       ROUND(100.0 * SUM(revenue) FILTER (WHERE rnk <= CEIL(0.10 * n)) / MAX(total_rev), 1) AS top_10pct_pct,
       ROUND(100.0 * SUM(revenue) FILTER (WHERE rnk <= CEIL(0.20 * n)) / MAX(total_rev), 1) AS top_20pct_pct
FROM ranked;