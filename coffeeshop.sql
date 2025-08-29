WITH base AS (
    SELECT
        store_id,
        store_location,
        product_type,
        product_detail,
        product_category,
        CASE
            WHEN MONTH(transaction_date) IN (12,1,2) THEN 'Summer'
            WHEN MONTH(transaction_date) IN (3,4,5) THEN 'Autumn'
            WHEN MONTH(transaction_date) IN (6,7,8) THEN 'Winter'
            WHEN MONTH(transaction_date) IN (9,10,11) THEN 'Spring'
        END AS season_bucket,
        CASE
            WHEN MONTH(transaction_date) BETWEEN 1 AND 3 THEN 'Q1'
            WHEN MONTH(transaction_date) BETWEEN 4 AND 6 THEN 'Q2'
            WHEN MONTH(transaction_date) BETWEEN 7 AND 9 THEN 'Q3'
            WHEN MONTH(transaction_date) BETWEEN 10 AND 12 THEN 'Q4'
        END AS quarter,
        CASE
            WHEN transaction_time >= '06:00:00' AND transaction_time < '11:59:59' THEN 'Morning'
            WHEN transaction_time >= '12:00:00' AND transaction_time < '16:59:59' THEN 'Afternoon'
            WHEN transaction_time >= '17:00:00' AND transaction_time < '18:59:59' THEN 'Evening'
            ELSE 'Night'
        END AS day_bucket,
        CASE
            WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'Weekend'
            ELSE 'Weekday'
        END AS week_bucket,         
        unit_price * transaction_qty AS revenue,
        transaction_id
    FROM coffeeshop.sales_trends.sales_data
)

SELECT
    store_id,
    store_location,
    product_type,
    product_detail,
    product_category,
    season_bucket,
    quarter,
    day_bucket,
    week_bucket,              
    SUM(revenue) AS total_revenue,
    COUNT(transaction_id) AS total_transactions,
    RANK() OVER (--rank products
        PARTITION BY store_id, quarter
        ORDER BY SUM(revenue) DESC
    ) AS product_rank
FROM base
GROUP BY
    store_id,
    store_location,
    product_type,
    product_detail,
    product_category,
    season_bucket,
    quarter,
    day_bucket,
    week_bucket
ORDER BY store_id, quarter, product_rank;
