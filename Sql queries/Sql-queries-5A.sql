-- Q5. do late deliveries hurt review scores
-- A) score by how late the order was

WITH d AS (
    SELECT o.order_id,
           (o.order_delivered_customer_date::date
            - o.order_estimated_delivery_date::date) AS days_late,
           r.review_score
    FROM valid_orders o
    JOIN order_reviews_clean r USING (order_id)
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
)
SELECT CASE WHEN days_late <= 0  THEN '1. on time or early'
            WHEN days_late <= 3  THEN '2. 1-3 days late'
            WHEN days_late <= 7  THEN '3. 4-7 days late'
            WHEN days_late <= 14 THEN '4. 8-14 days late'
            ELSE '5. 15+ days late' END AS delivery_bucket,
       COUNT(*) AS orders,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_orders,
       ROUND(AVG(review_score), 2) AS avg_score,
       ROUND(100.0 * COUNT(*) FILTER (WHERE review_score <= 2) / COUNT(*), 1) AS pct_low_scores
FROM d
GROUP BY 1
ORDER BY 1;