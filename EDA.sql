SET search_path TO mavenfuzzyfactory;




SELECT 'website_sessions' AS table_name, COUNT(*) AS row_count FROM mavenfuzzyfactory.website_sessions
UNION ALL
SELECT 'orders', COUNT(*) FROM mavenfuzzyfactory.orders
UNION ALL
SELECT 'website_pageviews', COUNT(*) FROM mavenfuzzyfactory.website_pageviews
UNION ALL
SELECT 'products', COUNT(*) FROM mavenfuzzyfactory.products
UNION ALL
SELECT 'order_items', COUNT(*) FROM mavenfuzzyfactory.order_items
UNION ALL
SELECT 'order_item_refunds', COUNT(*) FROM mavenfuzzyfactory.order_item_refunds;





select * from products

--- traffic source analysis 
--- where customers are coming from & which channel gives the best quality traffic 
--- traffic paths 
--- conversion rates 
--- common use cases are analyzing search data , shifting budgets to stronger conversions , user behaviour patterns , channel performing well 
---  can be helpful with conversion funnel analysis 
-- website sesions , pageviews & orders 
select * from website_sessions where website_session_id = 1059
select * from website_pageviews where website_session_id = 1059
select * from orders where website_session_id = 1059



SET search_path TO mavenfuzzyfactory;


SELECT DISTINCT utm_source FROM website_sessions;
SELECT DISTINCT utm_campaign FROM website_sessions;
SELECT DISTINCT utm_content FROM website_sessions;
SELECT DISTINCT device_type FROM website_sessions;
SELECT DISTINCT http_referer FROM website_sessions;


SELECT utm_source, COUNT(*) AS sessions
FROM website_sessions
GROUP BY utm_source
ORDER BY sessions DESC;


SELECT utm_campaign, COUNT(*) AS sessions
FROM website_sessions
GROUP BY utm_campaign
ORDER BY sessions DESC;


SELECT 
  COUNT(*) AS total,
  COUNT(utm_source) AS utm_source_not_null
FROM website_sessions;


SELECT DISTINCT pageview_url FROM website_pageviews;

SELECT pageview_url, COUNT(*) AS views
FROM website_pageviews
GROUP BY pageview_url
ORDER BY views DESC;


SELECT website_session_id, COUNT(*) AS pageviews
FROM website_pageviews
GROUP BY website_session_id
ORDER BY pageviews DESC;


SELECT COUNT(*) AS total_orders,
       SUM(price_usd) AS revenue,
       SUM(price_usd - cogs_usd) AS profit
FROM orders;


SELECT items_purchased, COUNT(*) AS orders
FROM orders
GROUP BY items_purchased
ORDER BY items_purchased;



SET search_path TO mavenfuzzyfactory;


select 
	utm_content, 
	count(distinct website_sessions.website_session_id) as sessions,
	count(distinct orders.order_id) as orders,
	(count(distinct orders.order_id)::float *100)
	/ count(distinct website_sessions.website_session_id) as session_to_ordersconversion
from website_sessions 
left join orders
	ON orders.website_session_id = website_sessions.website_session_id
where utm_source = 'gsearch'
group by 1
order by 2 desc;




SELECT 
  utm_source,
  utm_campaign,
  http_referer,
  COUNT(*) AS sessions
FROM website_sessions
GROUP BY utm_source, utm_campaign, http_referer
ORDER BY sessions DESC;


