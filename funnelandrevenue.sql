-- Sets the default schema to "mavenfuzzyfactory" so all tables are referenced from here
SET search_path TO mavenfuzzyfactory;


-- This query calculates monthly performance:
-- 1. Groups data by month using DATE_TRUNC on session creation time
-- 2. Counts total unique sessions (visits)
-- 3. Counts total unique orders placed
-- 4. Calculates conversion rate = (orders / sessions) * 100
--    → Shows what percentage of visitors actually made a purchase
-- 5. Results are ordered chronologically by month
SELECT 
    DATE_TRUNC('month', ws.created_at) AS month,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(
        COUNT(DISTINCT o.order_id)::numeric 
        / COUNT(DISTINCT ws.website_session_id) * 100, 
        2
    ) AS conversion_rate_pct
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
GROUP BY 1
ORDER BY 1;



-- This query analyzes marketing channel performance:
-- 1. Groups data by traffic source (utm_source) and campaign (utm_campaign)
-- 2. Counts sessions (how many users came from each source/campaign)
-- 3. Counts orders (how many purchases came from each)
-- 4. Calculates total revenue generated from each source/campaign
-- 5. Computes conversion rate = (orders / sessions) * 100
-- 6. Orders results by revenue in descending order to highlight best-performing channels
SELECT 
    utm_source,
    utm_campaign,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    SUM(o.price_usd) AS revenue,
    ROUND(
        COUNT(DISTINCT o.order_id)::numeric 
        / COUNT(DISTINCT ws.website_session_id) * 100, 
        2
    ) AS conversion_rate_pct
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
GROUP BY 1,2
ORDER BY revenue DESC;



-- This query measures product page effectiveness (funnel step analysis):
-- 1. First (CTE), it extracts all sessions that viewed the '/products' page
-- 2. Then:
--    - Counts how many sessions reached the product page
--    - Counts how many of those sessions resulted in an order
-- 3. Calculates conversion from product page → order
--    → Helps understand how effective the product page is at converting visitors into buyers
WITH product_views AS (
    SELECT DISTINCT website_session_id
    FROM website_pageviews
    WHERE pageview_url = '/products'
)
SELECT 
    COUNT(DISTINCT pv.website_session_id) AS product_page_sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(
        COUNT(DISTINCT o.order_id)::numeric 
        / COUNT(DISTINCT pv.website_session_id) * 100,
        2
    ) AS product_to_order_pct
FROM product_views pv
LEFT JOIN orders o
    ON pv.website_session_id = o.website_session_id;



-- This query analyzes product-level financial performance:
-- 1. Joins order items with product details
-- 2. Calculates total revenue per product (sum of selling prices)
-- 3. Calculates total profit = revenue - cost of goods sold (cogs)
-- 4. Computes profit margin % = (profit / revenue) * 100
--    → Shows how profitable each product is
-- 5. Orders products by highest revenue first
SELECT 
    p.product_name,
    SUM(oi.price_usd) AS revenue,
    SUM(oi.price_usd - oi.cogs_usd) AS profit,
    ROUND(
        SUM(oi.price_usd - oi.cogs_usd) 
        / SUM(oi.price_usd) * 100, 
        2
    ) AS margin_pct
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY 1
ORDER BY revenue DESC;



-- This query calculates Average Order Value (AOV) per month:
-- 1. Groups orders by month
-- 2. Computes the average order value using AVG(price_usd)
-- 3. Rounds the result to 2 decimal places
-- 4. Helps track how much customers spend per order over time
SELECT 
    DATE_TRUNC('month', created_at) AS month,
    ROUND(AVG(price_usd), 2) AS avg_order_value
FROM orders
GROUP BY 1
ORDER BY 1;



-- This query compares performance by device type:
-- 1. Groups data by device_type (e.g., desktop, mobile)
-- 2. Counts total sessions per device
-- 3. Counts total orders per device
-- 4. Calculates conversion rate = (orders / sessions) * 100
--    → Helps identify which device performs better in converting users
--    → Useful for UX optimization (mobile vs desktop experience)
SELECT 
    device_type,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(
        COUNT(DISTINCT o.order_id)::numeric 
        / COUNT(DISTINCT ws.website_session_id) * 100,
        2
    ) AS conversion_rate_pct
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
GROUP BY 1;
