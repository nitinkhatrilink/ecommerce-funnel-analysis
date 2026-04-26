set search_path to mavenfuzzyfactory 

USE mavenfuzzyfactory;


--User funnel (sessions → orders) + traffic sources (UTM)
SELECT 
    ws.utm_source,
    ws.utm_campaign,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(
        COUNT(DISTINCT o.order_id) * 100.0 /
        NULLIF(COUNT(DISTINCT ws.website_session_id), 0), 
    2) AS conv_rate_pct
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
WHERE ws.created_at < '2012-04-12'
GROUP BY 
    ws.utm_source,
    ws.utm_campaign
ORDER BY sessions DESC;


--Conversion rate (sessions → orders)
SELECT 
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(
        COUNT(DISTINCT o.order_id) * 100.0 /
        NULLIF(COUNT(DISTINCT ws.website_session_id), 0), 
    2) AS session_to_order_conv_rate_pct
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
WHERE ws.created_at < '2012-04-14'
  AND ws.utm_source = 'gsearch'
  AND ws.utm_campaign = 'nonbrand';


-- imapct of marketing changes 
SELECT 
    CASE 
        WHEN ws.created_at < '2012-04-15' THEN 'before_change'
        ELSE 'after_change'
    END AS period,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(
        COUNT(DISTINCT o.order_id) * 100.0 /
        NULLIF(COUNT(DISTINCT ws.website_session_id), 0), 
    2) AS conv_rate_pct
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
WHERE ws.utm_source = 'gsearch'
  AND ws.utm_campaign = 'nonbrand'
GROUP BY period;






--1. First, I’d like to show our volume growth. Can you pull overall session and order volume, 
--trended by quarter for the life of the business?

SELECT 
    EXTRACT(YEAR FROM website_sessions.created_at) AS yr,
    EXTRACT(QUARTER FROM website_sessions.created_at) AS qtr,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions
LEFT JOIN orders
    ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1, 2
ORDER BY 1, 2;



SELECT 
    EXTRACT(YEAR FROM website_sessions.created_at)::int AS yr,
    EXTRACT(QUARTER FROM website_sessions.created_at)::int AS qtr,
    
    COUNT(DISTINCT orders.order_id)::float 
        / NULLIF(COUNT(DISTINCT website_sessions.website_session_id), 0) 
        AS session_to_order_conv_rate,
    
    SUM(orders.price_usd) 
        / NULLIF(COUNT(DISTINCT orders.order_id), 0) 
        AS revenue_per_order,
    
    SUM(orders.price_usd) 
        / NULLIF(COUNT(DISTINCT website_sessions.website_session_id), 0) 
        AS revenue_per_session

FROM website_sessions
LEFT JOIN orders
    ON website_sessions.website_session_id = orders.website_session_id

GROUP BY 1, 2
ORDER BY 1, 2;



--When someone lands on the products page, how often do they stay engaged and eventually buy?
-- conversion rates session to product , clicked to next page 
CREATE TEMP TABLE products_pageviews AS
SELECT
    website_session_id,
    website_pageview_id,
    created_at AS saw_product_page_at
FROM website_pageviews
WHERE pageview_url = '/products';

SELECT 
    EXTRACT(YEAR FROM saw_product_page_at)::int AS yr,
    EXTRACT(MONTH FROM saw_product_page_at)::int AS mo,

    COUNT(DISTINCT products_pageviews.website_session_id) AS sessions_to_product_page,

    COUNT(DISTINCT website_pageviews.website_session_id) AS clicked_to_next_page,

    COUNT(DISTINCT website_pageviews.website_session_id)::float
        / NULLIF(COUNT(DISTINCT products_pageviews.website_session_id), 0)
        AS clickthrough_rt,

    COUNT(DISTINCT orders.order_id) AS orders,

    COUNT(DISTINCT orders.order_id)::float
        / NULLIF(COUNT(DISTINCT products_pageviews.website_session_id), 0)
        AS products_to_order_rt

FROM products_pageviews

LEFT JOIN website_pageviews
    ON website_pageviews.website_session_id = products_pageviews.website_session_id
    AND website_pageviews.website_pageview_id > products_pageviews.website_pageview_id

LEFT JOIN orders
    ON orders.website_session_id = products_pageviews.website_session_id

GROUP BY 1, 2;
