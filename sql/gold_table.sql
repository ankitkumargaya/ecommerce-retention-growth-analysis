use catalog ecommerce_retention;
use schema analytics;
use schema gold;
 
---gold customer_lifecycle

CREATE OR REPLACE TABLE ecommerce_retention.gold.customer_lifecycle AS

WITH delivered_orders AS (
    SELECT
        order_id,
        customer_id,
        order_timestamp,
        DATE(order_timestamp) AS order_date,
        order_value
    FROM ecommerce_retention.analytics.orders
    WHERE LOWER(order_status) = 'delivered'
),

ranked_orders AS (
    SELECT
        customer_id,
        order_id,
        order_value,
        order_date,
        order_timestamp,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_timestamp
        ) AS rn
    FROM delivered_orders
),

customer_order AS (
    SELECT
        customer_id,
        ROUND(SUM(order_value),2) AS total_value,
        MAX(CASE WHEN rn = 1 THEN order_date END) AS first_order_date,
        MAX(CASE WHEN rn = 2 THEN order_date END) AS second_order_date
    FROM ranked_orders
    GROUP BY customer_id
),

lifecycle AS (
    SELECT
        customer_id,
        total_value,
        first_order_date,
        second_order_date,
        CASE
            WHEN second_order_date IS NOT NULL
            THEN DATEDIFF(second_order_date, first_order_date)
        END AS days_to_second_order
     FROM customer_order
)

SELECT
    customer_id,
    total_value,
    first_order_date,
    second_order_date,
    days_to_second_order,

    CASE
        WHEN second_order_date IS NOT NULL
         AND days_to_second_order <= 30
        THEN 1 ELSE 0
    END AS repeat_30d_flag,

    CASE
        WHEN second_order_date IS NULL THEN 'No Repeat'
        WHEN days_to_second_order <= 7 THEN '0-7 days'
        WHEN days_to_second_order <= 30 THEN '8-30 days'
        WHEN days_to_second_order <= 60 THEN '31-60 days'
        WHEN days_to_second_order <= 90 THEN '61-90 days'
        ELSE '90+ days'
    END AS second_order_bucket
FROM lifecycle;


-- Gold Table: Cohort Retention

CREATE OR REPLACE TABLE ecommerce_retention.gold.retention_cohort AS

WITH delivered_orders AS (
    SELECT DISTINCT
        customer_id,
        DATE_TRUNC('month', order_timestamp) AS order_month
    FROM ecommerce_retention.analytics.orders
    WHERE LOWER(order_status) = 'delivered'
),

first_purchase AS (
    SELECT
        customer_id,
        MIN(order_month) AS cohort_month
    FROM delivered_orders
    GROUP BY customer_id
),

cohort_activity AS (
    SELECT DISTINCT
        f.cohort_month,
        DATEDIFF(month, f.cohort_month, o.order_month) AS month_number,
        f.customer_id
    FROM first_purchase f
    JOIN delivered_orders o
        ON f.customer_id = o.customer_id
       AND o.order_month >= f.cohort_month
),

cohort_size AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_size
    FROM first_purchase
    GROUP BY cohort_month
),

retention AS (
    SELECT
        cohort_month,
        month_number,
        COUNT(DISTINCT customer_id) AS active_users
    FROM cohort_activity
    WHERE month_number BETWEEN 0 AND 6
    GROUP BY cohort_month, month_number
)

SELECT
    r.cohort_month,
    r.month_number,
    r.active_users,
    cs.cohort_size,
    ROUND(r.active_users * 100.0 / cs.cohort_size,2) AS retention_rate
FROM retention r
JOIN cohort_size cs
ON r.cohort_month = cs.cohort_month
ORDER BY r.cohort_month, r.month_number;

select distinct order_status from analytics.orders;



CREATE OR REPLACE TABLE ecommerce_retention.gold.channel_ltv AS

WITH order_status AS (

SELECT
o.order_id,
o.customer_id,
o.order_value,
LOWER(o.order_status) AS order_status,
COALESCE(r.refund_amount,0) AS refund_amount

FROM ecommerce_retention.analytics.orders o
LEFT JOIN ecommerce_retention.analytics.returns r
ON r.order_id = o.order_id

WHERE LOWER(o.order_status) IN ('delivered','returned')

),

customer_revenue AS (

SELECT
customer_id,

COUNT(CASE WHEN order_status = 'delivered' THEN order_id END) AS total_orders,

SUM(CASE WHEN order_status = 'delivered' THEN order_value END) AS gross_revenue,

SUM(CASE
        WHEN order_status = 'delivered'
        THEN order_value
    END)  - sum(refund_amount) AS net_revenue

FROM order_status
GROUP BY customer_id
)

SELECT
c.acquisition_channel,

COUNT(DISTINCT c.customer_id) AS total_customers,

SUM(COALESCE(cr.total_orders,0)) AS total_orders,

ROUND(SUM(COALESCE(cr.gross_revenue,0)),0) AS gross_revenue,

ROUND(SUM(COALESCE(cr.net_revenue,0)),0) AS net_revenue,

ROUND(SUM(cr.net_revenue) / COUNT(DISTINCT c.customer_id),2) AS avg_customer_ltv,

ROUND(SUM(cr.total_orders) / COUNT(DISTINCT c.customer_id),2) AS avg_orders_per_customer

FROM ecommerce_retention.analytics.customers c
LEFT JOIN customer_revenue cr
ON cr.customer_id = c.customer_id
GROUP BY c.acquisition_channel
ORDER BY avg_customer_ltv DESC;
;

CREATE OR REPLACE TABLE ecommerce_retention.gold.activation_funnel AS

WITH first_order AS (
    SELECT
        customer_id,
        MIN(order_timestamp) AS first_order_ts
    FROM ecommerce_retention.analytics.orders
    WHERE LOWER(order_status) = 'delivered'
    GROUP BY customer_id
),

session_activity AS (
    SELECT
        f.customer_id,
        MAX(CASE WHEN s.session_id IS NOT NULL THEN 1 ELSE 0 END) AS has_session,
        MAX(CASE WHEN s.pages_viewed >= 3 THEN 1 ELSE 0 END) AS active_browsing,
        MAX(CASE WHEN s.added_to_cart_flag = 1 THEN 1 ELSE 0 END) AS added_to_cart,
        MAX(CASE WHEN s.checkout_started_flag = 1 THEN 1 ELSE 0 END) AS checkout_started
    FROM first_order f
    LEFT JOIN ecommerce_retention.analytics.sessions s
        ON f.customer_id = s.customer_id
       AND s.session_start_ts > f.first_order_ts
       AND s.session_start_ts <= f.first_order_ts + INTERVAL 30 DAY
    GROUP BY f.customer_id
),

returned_orders AS (
    SELECT order_id
    FROM ecommerce_retention.analytics.returns
),

second_orders AS (
    SELECT
        f.customer_id,
        MAX(
            CASE
                WHEN o.order_id IS NOT NULL
                 AND r.order_id IS NULL
                THEN 1 ELSE 0
            END
        ) AS repeat_order
    FROM first_order f
    LEFT JOIN ecommerce_retention.analytics.orders o
        ON f.customer_id = o.customer_id
       AND LOWER(o.order_status) = 'delivered'
       AND o.order_timestamp > f.first_order_ts
       AND o.order_timestamp <= f.first_order_ts + INTERVAL 30 DAY
    LEFT JOIN returned_orders r
        ON o.order_id = r.order_id
    GROUP BY f.customer_id
),

combined AS (
    SELECT
        f.customer_id,
        COALESCE(sa.has_session,0) AS has_session,
        COALESCE(sa.active_browsing,0) AS active_browsing,
        COALESCE(sa.added_to_cart,0) AS added_to_cart,
        COALESCE(sa.checkout_started,0) AS checkout_started,
        COALESCE(so.repeat_order,0) AS repeat_order
    FROM first_order f
    LEFT JOIN session_activity sa
        ON f.customer_id = sa.customer_id
    LEFT JOIN second_orders so
        ON f.customer_id = so.customer_id
)

SELECT
    COUNT(*) AS first_order_customers,
    SUM(has_session) AS users_with_session,
    SUM(active_browsing) AS browsing_users,
    SUM(added_to_cart) AS cart_users,
    SUM(checkout_started) AS checkout_users,
    SUM(repeat_order) AS repeat_users,

    ROUND(SUM(has_session)*100.0/COUNT(*),2) AS session_rate,
    ROUND(SUM(active_browsing)*100.0/COUNT(*),2) AS browsing_rate,
    ROUND(SUM(added_to_cart)*100.0/COUNT(*),2) AS cart_rate,
    ROUND(SUM(checkout_started)*100.0/COUNT(*),2) AS checkout_rate,
    ROUND(SUM(repeat_order)*100.0/COUNT(*),2) AS repeat_rate,

    ROUND(SUM(active_browsing)*100.0/NULLIF(SUM(has_session),0),2) AS browse_from_session_rate,
    ROUND(SUM(added_to_cart)*100.0/NULLIF(SUM(active_browsing),0),2) AS cart_from_browse_rate,
    ROUND(SUM(checkout_started)*100.0/NULLIF(SUM(added_to_cart),0),2) AS checkout_from_cart_rate,
    ROUND(SUM(repeat_order)*100.0/NULLIF(SUM(checkout_started),0),2) AS repeat_from_checkout_rate

FROM combined;
