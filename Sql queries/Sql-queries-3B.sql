-- Q3. do customers come back?
-- B) how long until the second order
WITH ordered AS (
    SELECT c.customer_unique_id,
           o.order_purchase_timestamp AS ts,
           ROW_NUMBER() OVER (PARTITION BY c.customer_unique_id
                              ORDER BY o.order_purchase_timestamp) AS rn,
           LAG(o.order_purchase_timestamp) OVER (PARTITION BY c.customer_unique_id
                              ORDER BY o.order_purchase_timestamp) AS prev_ts
    FROM valid_orders o
    JOIN customers c USING (customer_id)
)
SELECT COUNT(*) AS repeat_customers,
       ROUND(AVG(EXTRACT(EPOCH FROM ts - prev_ts) / 86400)) AS avg_days_to_second_order,
       PERCENTILE_CONT(0.5) WITHIN GROUP
           (ORDER BY EXTRACT(EPOCH FROM ts - prev_ts) / 86400) AS median_days
FROM ordered
WHERE rn = 2;