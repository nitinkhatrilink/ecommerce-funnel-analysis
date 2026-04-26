# 📊 E-commerce Analytics Database Overview

This database models user behavior and transactions for an e-commerce website. It captures sessions, pageviews, orders, products, and refunds — enabling funnel analysis, revenue tracking, and performance insights.

---

## 🧱 Core Tables

### 1. `website_sessions`
Stores each visit to the website.

- `website_session_id` — unique session ID  
- `created_at` — session start time  
- `user_id` — user identifier  
- `is_repeat_session` — new vs returning user  
- `utm_source`, `utm_campaign`, `utm_content` — marketing attribution  
- `device_type` — device used (desktop/mobile)  
- `http_referer` — traffic source  

👉 **Use case:** Traffic analysis, marketing performance, user segmentation  

---

### 2. `website_pageviews`
Tracks pages viewed during sessions.

- `website_pageview_id` — unique pageview  
- `created_at` — timestamp  
- `website_session_id` — linked session  
- `pageview_url` — page visited  

👉 **Use case:** Funnel analysis, user journey tracking  

---

### 3. `orders`
Represents completed purchases.

- `order_id` — unique order  
- `created_at` — order time  
- `website_session_id` — session that led to purchase  
- `user_id` — customer  
- `primary_product_id` — main product  
- `items_purchased` — total items  
- `price_usd` — total revenue  
- `cogs_usd` — cost of goods sold  

👉 **Use case:** Revenue tracking, conversion analysis  

---

### 4. `order_items`
Breakdown of products within each order.

- `order_item_id` — unique item row  
- `order_id` — linked order  
- `product_id` — product purchased  
- `is_primary_item` — main vs additional item  
- `price_usd`, `cogs_usd` — financials  

👉 **Use case:** Product performance, basket analysis  

---

### 5. `products`
Catalog of available products.

- `product_id` — unique product  
- `created_at` — added date  
- `product_name` — name  

👉 **Use case:** Product-level reporting  

---

### 6. `order_item_refunds`
Tracks refunded items.

- `order_item_refund_id` — unique refund  
- `order_item_id` — refunded item  
- `order_id` — associated order  
- `refund_amount_usd` — refund value  

👉 **Use case:** Return analysis, net revenue calculation  

---

## 🔗 Relationships

- A **session** → has many **pageviews**
- A **session** → may result in an **order**
- An **order** → contains multiple **order_items**
- Each **order_item** → belongs to a **product**
- An **order_item** → may have a **refund**

---

## 📈 What we are analyzing

- Conversion funnel (sessions → pageviews → orders)  
- Marketing channel performance (UTM tracking)  
