-- Q5. do late deliveries hurt review scores
-- B) which states get the most late deliveries

SELECT c.customer_state,
       COUNT(*) AS delivered_orders,
       ROUND(100.0 * COUNT(*) FILTER (
           WHERE o.order_delivered_customer_date::date > o.order_estimated_delivery_date::date
       ) / COUNT(*), 1) AS pct_late
FROM valid_orders o
JOIN customers c USING (customer_id)
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY 1
ORDER BY pct_late DESC;