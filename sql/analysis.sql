use catalog ecommerce_retention;
use schema analytics;


 
-- What percentage of customers place a second order within 30 days of their first order?

WITH delivered_orders AS (
    SELECT
        customer_id,
        order_timestamp
    FROM orders
    WHERE LOWER(order_status) = 'delivered'
),

first_purchase AS (
    SELECT
        customer_id,
        MIN(order_timestamp) AS first_order
    FROM delivered_orders
    GROUP BY customer_id
),

ranked_orders AS (
    SELECT
        o.customer_id,
        o.order_timestamp,
        ROW_NUMBER() OVER (
            PARTITION BY o.customer_id
            ORDER BY o.order_timestamp
        ) AS order_rank
    FROM delivered_orders o
),

first_second AS (
    SELECT
        customer_id,
        MAX(CASE WHEN order_rank = 1 THEN order_timestamp END) AS first_order,
        MAX(CASE WHEN order_rank = 2 THEN order_timestamp END) AS second_order
    FROM ranked_orders
    WHERE order_rank <= 2
    GROUP BY customer_id
)

SELECT
    COUNT(*) AS total_customers,
    COUNT(
        CASE
            WHEN second_order IS NOT NULL
             AND DATEDIFF(day, first_order, second_order) <= 30
            THEN customer_id
        END
    ) AS repeat_customers,
    ROUND(
        COUNT(
            CASE
                WHEN second_order IS NOT NULL
                 AND DATEDIFF(day, first_order, second_order) <= 30
                THEN customer_id
            END
        ) * 100.0 / COUNT(*),
    2) AS retention_within_30day
FROM first_second;

-- I want to analyze customers whose lifecycle started recently.
-- Question 3 — Cohort Retention

WITH first_purchase AS (
    SELECT
        customer_id,
        DATE_TRUNC('MM', MIN(order_timestamp)) AS cohort_month
    FROM orders
    WHERE LOWER(order_status) = 'delivered'
    GROUP BY customer_id
),

order_month AS (
    SELECT
        customer_id,
        DATE_TRUNC('MM', order_timestamp) AS order_month
    FROM orders
    WHERE LOWER(order_status) = 'delivered'
),

cohort_size AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_id) AS total_customers
    FROM first_purchase
    GROUP BY cohort_month
),

cohort_activity AS (
    SELECT
        c.cohort_month,
        CAST(MONTHS_BETWEEN(o.order_month, c.cohort_month) AS INT) AS month_number,
        c.customer_id
    FROM first_purchase c
    JOIN order_month o
        ON c.customer_id = o.customer_id
       AND o.order_month >= c.cohort_month
),

retention AS (
    SELECT
        cohort_month,
        month_number,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM cohort_activity
    WHERE month_number BETWEEN 0 AND 6
    GROUP BY cohort_month, month_number
)

SELECT
    r.cohort_month,
    r.month_number,
    ROUND(active_customers * 100.0 / total_customers, 2) AS retention_rate
FROM retention r
JOIN cohort_size cs
    ON r.cohort_month = cs.cohort_month
ORDER BY r.cohort_month, r.month_number;


-- Does repeat rate differ significantly by acquisition channel?
WITH first_purchase AS (
    SELECT
        o.customer_id,
        DATE_TRUNC('MM', MIN(o.order_timestamp)) AS cohort_month
    FROM orders o
    WHERE LOWER(order_status) = 'delivered'
    GROUP BY o.customer_id
),

customer_channel AS (
    SELECT
        f.customer_id,
        f.cohort_month,
        c.acquisition_channel
    FROM first_purchase f
    JOIN customers c
        ON f.customer_id = c.customer_id
),

order_months AS (
    SELECT
        customer_id,
        DATE_TRUNC('MM', order_timestamp) AS order_month
    FROM orders
    WHERE LOWER(order_status) = 'delivered'
),

cohort_activity AS (
    SELECT
        cc.acquisition_channel,
        cc.customer_id,
        CAST(MONTHS_BETWEEN(o.order_month, cc.cohort_month) AS INT) AS month_num
    FROM customer_channel cc
    JOIN order_months o
        ON cc.customer_id = o.customer_id
       AND o.order_month >= cc.cohort_month
),

cohort_size AS (
    SELECT
        acquisition_channel,
        COUNT(DISTINCT customer_id) AS total_customers
    FROM customer_channel
    GROUP BY acquisition_channel
),

month1_repeat AS (
    SELECT
        acquisition_channel,
        COUNT(DISTINCT customer_id) AS repeat_customers
    FROM cohort_activity
    WHERE month_num = 1
    GROUP BY acquisition_channel
)

SELECT
    cs.acquisition_channel,
    ROUND(
        COALESCE(m.repeat_customers,0) * 100.0 / cs.total_customers,
    2) AS month1_retention_rate
FROM cohort_size cs
LEFT JOIN month1_repeat m
ON cs.acquisition_channel = m.acquisition_channel
ORDER BY month1_retention_rate DESC;



-- Does time-to-second-order reveal behavioral patterns?
-- Does time-to-second-order reveal behavioral patterns?

WITH delivered_orders AS (
    SELECT
        customer_id,
        order_timestamp
    FROM orders
    WHERE LOWER(order_status) = 'delivered'
),

orders_ranked AS (
    SELECT
        customer_id,
        order_timestamp,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_timestamp
        ) AS rn
    FROM delivered_orders
),

first_second AS (
    SELECT
        customer_id,
        MAX(CASE WHEN rn = 1 THEN order_timestamp END) AS first_order,
        MAX(CASE WHEN rn = 2 THEN order_timestamp END) AS second_order
    FROM orders_ranked
    WHERE rn <= 2
    GROUP BY customer_id
),

time_diff AS (
    SELECT
        customer_id,
        DATEDIFF(second_order, first_order) AS day_to_second
    FROM first_second
    WHERE second_order IS NOT NULL
)

SELECT
    CASE
        WHEN day_to_second <= 7 THEN '0-7 day'
        WHEN day_to_second <= 30 THEN '8-30 day'
        WHEN day_to_second <= 60 THEN '31-60 day'
        WHEN day_to_second <= 90 THEN '61-90 day'
        ELSE '90+ day'
    END AS bucket_,
    COUNT(*) AS users_
FROM time_diff
GROUP BY bucket_
ORDER BY bucket_;


-- Do high-retention channels reorder faster?

WITH delivered_orders AS (
    SELECT
        customer_id,
        order_timestamp
    FROM orders
    WHERE LOWER(order_status) = 'delivered'
),

orders_ranked AS (
    SELECT
        o.customer_id,
        c.acquisition_channel,
        o.order_timestamp,
        ROW_NUMBER() OVER (
            PARTITION BY o.customer_id
            ORDER BY o.order_timestamp
        ) AS rn
    FROM delivered_orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
),

first_second AS (
    SELECT
        customer_id,
        acquisition_channel,
        MAX(CASE WHEN rn = 1 THEN order_timestamp END) AS first_order,
        MAX(CASE WHEN rn = 2 THEN order_timestamp END) AS second_order
    FROM orders_ranked
    WHERE rn <= 2
    GROUP BY customer_id, acquisition_channel
),

time_diff AS (
    SELECT
        customer_id,
        acquisition_channel,
        DATEDIFF(second_order, first_order) AS day_to_second
    FROM first_second
    WHERE second_order IS NOT NULL
),

channel_total AS (
    SELECT
        acquisition_channel,
        COUNT(*) AS total_users
    FROM time_diff
    GROUP BY acquisition_channel
)

SELECT
    t.acquisition_channel,
    CASE
        WHEN day_to_second <= 7 THEN '0-7 day'
        WHEN day_to_second <= 30 THEN '8-30 day'
        WHEN day_to_second <= 60 THEN '31-60 day'
        WHEN day_to_second <= 90 THEN '61-90 day'
        ELSE '90+ day'
    END AS bucket_,
    ROUND(COUNT(*) * 100.0 / total_users, 2) AS users_
FROM time_diff t
JOIN channel_total ct
    ON t.acquisition_channel = ct.acquisition_channel
GROUP BY t.acquisition_channel, bucket_, total_users
ORDER BY acquisition_channel, bucket_
;


-- Does repeat probability differ significantly by first purchase category?

WITH first_purchase AS (
    SELECT
        customer_id,
        MIN(order_timestamp) AS first_order
    FROM orders
    WHERE LOWER(order_status) = 'delivered'
    GROUP BY customer_id
),

first_order_category AS (
    SELECT
        oi.category,
        f.customer_id,
        DATE_TRUNC('MM', f.first_order) AS cohort_month
    FROM first_purchase f
    JOIN orders o
        ON o.customer_id = f.customer_id
       AND o.order_timestamp = f.first_order
    JOIN order_items oi
        ON oi.order_id = o.order_id
    WHERE LOWER(o.order_status) = 'delivered'
),

orders_monthly AS (
    SELECT
        customer_id,
        DATE_TRUNC('MM', order_timestamp) AS order_month
    FROM orders
    WHERE LOWER(order_status) = 'delivered'
),

cohort_size AS (
    SELECT
        category,
        COUNT(DISTINCT customer_id) AS total_users
    FROM first_order_category
    GROUP BY category
),

cohort_activity AS (
    SELECT
        c.category,
        c.customer_id,
        CAST(MONTHS_BETWEEN(o.order_month, c.cohort_month) AS INT) AS month_number
    FROM first_order_category c
    LEFT JOIN orders_monthly o
        ON c.customer_id = o.customer_id
       AND o.order_month >= c.cohort_month
),

retention AS (
    SELECT
        category,
        COUNT(DISTINCT customer_id) AS repeat_users
    FROM cohort_activity
    WHERE month_number = 1
    GROUP BY category
)

SELECT
    cs.category,
    cs.total_users,
    COALESCE(r.repeat_users,0) AS repeat_users,
    ROUND(COALESCE(r.repeat_users,0) * 100.0 / cs.total_users, 2) AS month1_retention
FROM cohort_size cs
LEFT JOIN retention r
    ON cs.category = r.category
ORDER BY month1_retention DESC;



-- Which acquisition channel generates the highest customer lifetime value (LTV)?

WITH delivered_orders AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_value,
        c.acquisition_channel
    FROM orders o
    JOIN customers c
        ON c.customer_id = o.customer_id
    WHERE LOWER(o.order_status) = 'delivered'
),

refunds AS (
    SELECT
        order_id,
        SUM(refund_amount) AS total_refund
    FROM returns
    GROUP BY order_id
),

net_orders AS (
    SELECT
        d.customer_id,
        d.acquisition_channel,
        d.order_id,
        d.order_value - COALESCE(r.total_refund,0) AS net_order_value
    FROM delivered_orders d
    LEFT JOIN refunds r
        ON d.order_id = r.order_id
),

customer_ltv AS (
    SELECT
        acquisition_channel,
        customer_id,
        SUM(net_order_value) AS customer_lifetime_value,
        COUNT(order_id) AS total_orders
    FROM net_orders
    GROUP BY acquisition_channel, customer_id
)

SELECT
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(AVG(total_orders),2) AS avg_orders_per_customer,
    ROUND(AVG(customer_lifetime_value),2) AS avg_net_ltv_per_customer
FROM customer_ltv;



-- LTV vs CAC Analysis by Acquisition Channel

WITH delivered_orders AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_value,
        c.acquisition_channel
    FROM orders o
    JOIN customers c
        ON c.customer_id = o.customer_id
    WHERE LOWER(o.order_status) = 'delivered'
),

refunds AS (
    SELECT
        order_id,
        SUM(refund_amount) AS total_refund
    FROM returns
    GROUP BY order_id
),

net_orders AS (
    SELECT
        d.customer_id,
        d.acquisition_channel,
        d.order_id,
        d.order_value - COALESCE(r.total_refund,0) AS net_order_value
    FROM delivered_orders d
    LEFT JOIN refunds r
        ON d.order_id = r.order_id
),

customer_ltv AS (
    SELECT
        acquisition_channel,
        customer_id,
        SUM(net_order_value) AS customer_lifetime_value
    FROM net_orders
    GROUP BY acquisition_channel, customer_id
),

channel_summary AS (
    SELECT
        acquisition_channel,
        COUNT(customer_id) AS total_customers,
        AVG(customer_lifetime_value) AS avg_net_ltv_per_customer
    FROM customer_ltv
    GROUP BY acquisition_channel
),

cac_calculated AS (
    SELECT
        cs.acquisition_channel,
        cs.total_customers,
        cs.avg_net_ltv_per_customer,
        ms.total_marketing_spend,
        ms.total_marketing_spend / cs.total_customers AS avg_cac_per_customer
    FROM channel_summary cs
    JOIN marketing_spend ms
        ON cs.acquisition_channel = ms.acquisition_channel
)

SELECT
    acquisition_channel,
    total_customers,
    ROUND(avg_net_ltv_per_customer,2) AS avg_net_ltv_per_customer,
    ROUND(avg_cac_per_customer,2) AS avg_cac_per_customer,
    ROUND(avg_net_ltv_per_customer / NULLIF(avg_cac_per_customer,0),2) AS ltv_cac_ratio,
    ROUND(avg_net_ltv_per_customer - avg_cac_per_customer,2) AS net_profit_per_customer
FROM cac_calculated
ORDER BY ltv_cac_ratio DESC;


-- Revenue Uplift Simulation (NET Second Order Based)

WITH delivered_orders AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_timestamp,
        o.order_value
    FROM orders o
    WHERE LOWER(o.order_status) = 'delivered'
),

refunds AS (
    SELECT
        order_id,
        SUM(refund_amount) AS refund_amount
    FROM returns
    GROUP BY order_id
),

net_orders AS (
    SELECT
        d.customer_id,
        d.order_timestamp,
        d.order_value - COALESCE(r.refund_amount,0) AS net_value
    FROM delivered_orders d
    LEFT JOIN refunds r
        ON d.order_id = r.order_id
),

ranked_orders AS (
    SELECT
        customer_id,
        order_timestamp,
        net_value,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_timestamp
        ) AS rn
    FROM net_orders
),

first_second AS (
    SELECT
        customer_id,
        MAX(CASE WHEN rn = 1 THEN order_timestamp END) AS first_order,
        MAX(CASE WHEN rn = 2 THEN order_timestamp END) AS second_order,
        MAX(CASE WHEN rn = 2 THEN net_value END) AS second_order_value
    FROM ranked_orders
    WHERE rn <= 2
    GROUP BY customer_id
),

retention_base AS (
    SELECT
        customer_id,
        second_order_value,
        CASE
            WHEN second_order IS NOT NULL
             AND DATEDIFF(second_order, first_order) <= 30
            THEN 1 ELSE 0
        END AS is_30day_repeat
    FROM first_second
),

summary AS (
    SELECT
        COUNT(*) AS total_users,
        SUM(is_30day_repeat) AS repeat_users
    FROM retention_base
),

avg_second_value AS (
    SELECT
        AVG(second_order_value) AS avg_second_order_value
    FROM retention_base
    WHERE is_30day_repeat = 1
)

SELECT
    s.total_users,
    s.repeat_users,
    ROUND(s.repeat_users * 100.0 / s.total_users,2) AS current_30day_retention,
    ROUND(s.total_users * 0.20) AS target_repeat_users,
    GREATEST(ROUND((s.total_users * 0.20) - s.repeat_users),0) AS additional_repeat_users,
    ROUND(a.avg_second_order_value,2) AS avg_net_second_order_value,
    ROUND(
        GREATEST((s.total_users * 0.20) - s.repeat_users,0)
        * a.avg_second_order_value,
    2) AS projected_net_revenue_uplift
FROM summary s
CROSS JOIN avg_second_value a;




-- Post-Purchase 30-Day Funnel Drop-Off Analysis

WITH delivered_orders AS (
    SELECT
        order_id,
        customer_id,
        order_timestamp
    FROM orders
    WHERE LOWER(order_status) = 'delivered'
),

first_purchase AS (
    SELECT
        customer_id,
        MIN(order_timestamp) AS first_order
    FROM delivered_orders
    GROUP BY customer_id
),

session_activity AS (
    SELECT
        f.customer_id,
        CASE WHEN COUNT(DISTINCT s.session_id) > 0 THEN 1 ELSE 0 END AS has_session,
        MAX(CASE WHEN s.pages_viewed >= 3 THEN 1 ELSE 0 END) AS active_browsing,
        MAX(CASE WHEN s.added_to_cart_flag = 1 THEN 1 ELSE 0 END) AS added_to_cart,
        MAX(CASE WHEN s.checkout_started_flag = 1 THEN 1 ELSE 0 END) AS checkout_started
    FROM first_purchase f
    LEFT JOIN sessions s
        ON s.customer_id = f.customer_id
       AND s.session_start_ts > f.first_order
       AND s.session_start_ts <= f.first_order + INTERVAL 30 DAY
    GROUP BY f.customer_id
),

repeat_30d AS (
    SELECT
        f.customer_id,
        CASE WHEN COUNT(o.order_id) > 0 THEN 1 ELSE 0 END AS has_second_order_30d
    FROM first_purchase f
    LEFT JOIN delivered_orders o
        ON o.customer_id = f.customer_id
       AND o.order_timestamp > f.first_order
       AND o.order_timestamp <= f.first_order + INTERVAL 30 DAY
    GROUP BY f.customer_id
),

final AS (
    SELECT
        f.customer_id,
        COALESCE(sa.has_session,0) AS has_session,
        COALESCE(sa.active_browsing,0) AS active_browsing,
        COALESCE(sa.added_to_cart,0) AS added_to_cart,
        COALESCE(sa.checkout_started,0) AS checkout_started,
        COALESCE(r.has_second_order_30d,0) AS repeat_30d
    FROM first_purchase f
    LEFT JOIN session_activity sa
        ON f.customer_id = sa.customer_id
    LEFT JOIN repeat_30d r
        ON f.customer_id = r.customer_id
)

SELECT
    COUNT(*) AS total_users,
    SUM(has_session) AS users_with_session,
    SUM(active_browsing) AS users_with_browsing,
    SUM(added_to_cart) AS users_with_cart,
    SUM(checkout_started) AS users_with_checkout,
    SUM(repeat_30d) AS users_with_repeat_30d,

    ROUND(SUM(has_session)*100.0/COUNT(*),2) AS session_rate,
    ROUND(SUM(active_browsing)*100.0/COUNT(*),2) AS browsing_rate,
    ROUND(SUM(added_to_cart)*100.0/COUNT(*),2) AS cart_rate,
    ROUND(SUM(checkout_started)*100.0/COUNT(*),2) AS checkout_rate,
    ROUND(SUM(repeat_30d)*100.0/COUNT(*),2) AS repeat_rate
FROM final;














