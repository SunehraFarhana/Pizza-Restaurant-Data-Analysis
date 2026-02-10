-- 1. What is the total number of orders and total revenue?
SELECT 
    COUNT(*) AS total_orders,
    SUM(menu_item_quantity) AS total_units_sold,
    ROUND(SUM(menu_item_price * menu_item_quantity), 2) AS total_revenue
FROM pizza_restaurant_schema.pizza_restaurant_dataset_cleaned;


-- 2. What is the total number of orders per delivery status?
-- What percent of orders are delivery?
SELECT
    CASE
        WHEN delivery = 'Yes' THEN 'Yes'
        WHEN delivery = 'No' THEN 'No'
        ELSE 'Unknown'
    END AS delivery_status,
    COUNT(*) AS order_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) 
         FROM pizza_restaurant_schema.pizza_restaurant_dataset_cleaned),
    2) AS pct_of_orders
FROM pizza_restaurant_schema.pizza_restaurant_dataset_cleaned
GROUP BY delivery_status;


-- 3. What is the order count, units sold, and revenue by month?
-- Which month had the highest revenue?
SELECT
    MONTHNAME(order_date) AS month,
    COUNT(*) AS order_count,
    SUM(menu_item_quantity) AS units_sold,
    ROUND(SUM(menu_item_price * menu_item_quantity), 2) AS revenue
FROM pizza_restaurant_schema.pizza_restaurant_dataset_cleaned
GROUP BY month
ORDER BY revenue DESC;


-- 4. What is the order count, units sold, and revenue by weekday?
-- Which weekday had the highest revenue?
SELECT
    DAYNAME(order_date) AS weekday,
    COUNT(*) AS order_count,
    SUM(menu_item_quantity) AS units_sold,
    ROUND(SUM(menu_item_price * menu_item_quantity), 2) AS revenue
FROM pizza_restaurant_schema.pizza_restaurant_dataset_cleaned
GROUP BY weekday
ORDER BY revenue DESC;


-- 5. Which menu item sold the most units?
-- Which menu item generated the most revenue?
SELECT
    menu_item_name,
    SUM(menu_item_quantity) AS units_sold,
    ROUND(SUM(menu_item_price * menu_item_quantity), 2) AS revenue
FROM pizza_restaurant_schema.pizza_restaurant_dataset_cleaned
GROUP BY menu_item_name
ORDER BY revenue DESC;


-- 6. Which menu item category sold the most units?
-- Which menu item category generated the most revenue?
SELECT
    menu_item_category,
    SUM(menu_item_quantity) AS units_sold,
    ROUND(SUM(menu_item_price * menu_item_quantity), 2) AS revenue
FROM pizza_restaurant_schema.pizza_restaurant_dataset_cleaned
GROUP BY menu_item_category
ORDER BY revenue DESC;


-- 7. Which menu item size sold the most units?
-- Which menu item size generated the most revenue?
SELECT
    menu_item_size,
    SUM(menu_item_quantity) AS units_sold,
    ROUND(SUM(menu_item_price * menu_item_quantity), 2) AS revenue
FROM pizza_restaurant_schema.pizza_restaurant_dataset_cleaned
WHERE menu_item_size IN ('Small', 'Regular', 'Large', '20oz', '2L')
GROUP BY menu_item_size
ORDER BY revenue DESC;


-- 8. Which month had the highest number of beverages sold?
SELECT
    MONTHNAME(order_date) AS month,
    SUM(menu_item_quantity) AS beverage_units_sold
FROM pizza_restaurant_schema.pizza_restaurant_dataset_cleaned
WHERE menu_item_category = 'Beverage'
GROUP BY month
ORDER BY beverage_units_sold DESC;


-- 9. Who are the most frequent customers, and how much money have they spent on orders?
SELECT
    customer_name,
    COUNT(*) AS order_count,
    ROUND(SUM(menu_item_price * menu_item_quantity),2) AS total_money_spent
FROM pizza_restaurant_schema.pizza_restaurant_dataset_cleaned
GROUP BY customer_name
ORDER BY order_count DESC
LIMIT 15;