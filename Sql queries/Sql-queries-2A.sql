-- Q2 who are our top customers, by state and by value?
--A) revenue by state
WITH state_rev AS (
    SELECT c.customer_state,
           COUNT(DISTINCT o.order_id)           AS orders,
           COUNT(DISTINCT c.customer_unique_id) AS customers,
           SUM(i.price)                         AS revenue
    FROM valid_orders o
    JOIN customers c   USING (customer_id)
    JOIN order_items i USING (order_id)
    GROUP BY 1
)
SELECT customer_state,
       orders,
       customers,
       ROUND(revenue, 2)                                   AS revenue,
       ROUND(100.0 * revenue / SUM(revenue) OVER (), 1)    AS pct_of_revenue,
       ROUND(100.0 * SUM(revenue) OVER (ORDER BY revenue DESC)
             / SUM(revenue) OVER (), 1)                    AS cumulative_pct,
       ROUND(revenue / customers, 2)                       AS revenue_per_customer,
       ROUND(revenue / orders, 2)                          AS avg_order_value
FROM state_rev
ORDER BY revenue DESC;