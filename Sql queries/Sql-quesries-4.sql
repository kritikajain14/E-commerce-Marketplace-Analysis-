-- Q4: which product categories drive revenue, and which disappoint customers?
CREATE OR REPLACE VIEW order_reviews_clean AS
SELECT DISTINCT ON (order_id)
       order_id, review_id, review_score,
       review_creation_date, review_answer_timestamp
FROM order_reviews
ORDER BY order_id, review_answer_timestamp DESC, review_id;



WITH cat_rev AS (
    SELECT p.category_en,
           SUM(i.price) AS revenue,
           ROUND(100.0 * SUM(i.price) / SUM(SUM(i.price)) OVER (), 1) AS pct_revenue
    FROM valid_orders o
    JOIN order_items i   USING (order_id)
    JOIN products_clean p USING (product_id)
    GROUP BY 1
),
order_cat AS (
    SELECT DISTINCT o.order_id, p.category_en
    FROM valid_orders o
    JOIN order_items i   USING (order_id)
    JOIN products_clean p USING (product_id)
),
cat_score AS (
    SELECT oc.category_en,
           COUNT(*) AS reviewed_orders,
           ROUND(AVG(r.review_score), 2) AS avg_score,
           ROUND(100.0 * COUNT(*) FILTER (WHERE r.review_score <= 2) / COUNT(*), 1) AS pct_low_scores
    FROM order_cat oc
    JOIN order_reviews_clean r USING (order_id)
    GROUP BY 1
)
SELECT cr.category_en,
       ROUND(cr.revenue, 2) AS revenue,
       cr.pct_revenue,
       cs.reviewed_orders,
       cs.avg_score,
       cs.pct_low_scores
FROM cat_rev cr
JOIN cat_score cs USING (category_en)
WHERE cs.reviewed_orders >= 100
ORDER BY cr.revenue DESC;
