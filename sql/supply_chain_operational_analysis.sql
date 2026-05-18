-- =====================================================
-- SUPPLY CHAIN OPERATIONS & FULFILLMENT ANALYTICS
-- =====================================================

-- Project Objective:
-- Analyze customer orders, operational trends,
-- product demand, and cancellation behavior
-- to generate business insights for supply chain optimization.


-- =====================================================
-- DATA VALIDATION & CLEANING
-- =====================================================
-- Check for missing values

SELECT *
FROM sales_test
WHERE customer_no IS NULL
   OR item IS NULL;


-- Check for duplicate records

SELECT
    customer_no,
    item,
    date,
    COUNT(*) AS duplicate_count
FROM sales_test
GROUP BY customer_no, item, date
HAVING COUNT(*) > 1;


-- Check for invalid order quantities

SELECT *
FROM sales_test
WHERE ns_order < 0;

-- =====================================================
-- CUSTOMER ANALYSIS
-- =====================================================

-- Top customers by total order volume

SELECT
    customer_no,
    SUM(ns_order) AS total_orders
FROM sales_test
GROUP BY customer_no
ORDER BY total_orders DESC
LIMIT 10;

-- Customer ranking using window functions

SELECT
    customer_no,
    SUM(ns_order) AS total_orders,
    DENSE_RANK() OVER(
        ORDER BY SUM(ns_order) DESC
    ) AS customer_rank
FROM sales_test
GROUP BY customer_no;

-- =====================================================
-- PRODUCT PERFORMANCE ANALYSIS
-- =====================================================


-- Top products by order volume

SELECT
    item,
    SUM(ns_order) AS total_orders
FROM sales_test
GROUP BY item
ORDER BY total_orders DESC;

-- =====================================================
-- CANCELLATION ANALYSIS
-- =====================================================


-- Cancellation rate by product

SELECT
    s.item,
    SUM(s.ns_order) AS total_orders,
    COALESCE(SUM(c.nc_order),0) AS canceled_orders,

    ROUND(
        COALESCE(SUM(c.nc_order),0) * 100.0 /
        SUM(s.ns_order),
        2
    ) AS cancellation_rate

FROM sales_test s

LEFT JOIN canceled_test c
ON s.item = c.item

GROUP BY s.item
ORDER BY cancellation_rate DESC;

-- =====================================================
-- ABC INVENTORY CLASSIFICATION
-- =====================================================


SELECT
    item,
    SUM(ns_order) AS total_orders,

    CASE
        WHEN SUM(ns_order) >= 500 THEN 'A'
        WHEN SUM(ns_order) >= 200 THEN 'B'
        ELSE 'C'
    END AS inventory_category

FROM sales_test
GROUP BY item
ORDER BY total_orders DESC;

-- =====================================================
-- OPERATIONAL TREND ANALYSIS
-- =====================================================


-- Analyze operational demand patterns over time
-- to identify ordering trends and potential demand spikes

SELECT
    date,
    SUM(ns_order) AS total_orders
FROM sales_test
GROUP BY date
ORDER BY date;

-- Running cumulative order volume

SELECT
    date,
    customer_no,
    ns_order,

    SUM(ns_order) OVER(
        ORDER BY date
    ) AS cumulative_orders

FROM sales_test;

-- =====================================================
-- ADVANCED SQL ANALYSIS USING CTEs
-- =====================================================


WITH customer_orders AS (

    SELECT
        customer_no,
        SUM(ns_order) AS total_orders

    FROM sales_test
    GROUP BY customer_no
)

SELECT *
FROM customer_orders
WHERE total_orders >
(
    SELECT AVG(total_orders)
    FROM customer_orders
)
ORDER BY total_orders DESC;

-- =====================================================
-- OPERATIONAL KPI SUMMARY
-- =====================================================


SELECT

    COUNT(DISTINCT customer_no) AS total_customers,

    COUNT(DISTINCT item) AS total_products,

    SUM(ns_order) AS total_orders,

    ROUND(
        AVG(ns_order),
        2
    ) AS avg_order_quantity

FROM sales_test;


-- =====================================================
-- HIGH-RISK PRODUCT IDENTIFICATION
-- =====================================================

-- Identify products with elevated cancellation risk

SELECT
    s.item,

    SUM(s.ns_order) AS total_orders,

    COALESCE(SUM(c.nc_order),0) AS canceled_orders,

    ROUND(
        COALESCE(SUM(c.nc_order),0) * 100.0 /
        SUM(s.ns_order),
        2
    ) AS cancellation_rate

FROM sales_test s

LEFT JOIN canceled_test c
ON s.item = c.item

GROUP BY s.item

HAVING cancellation_rate > 20

ORDER BY cancellation_rate DESC;

-- =====================================================
-- ADVANCED OPERATIONAL INSIGHTS
-- =====================================================

-- Monthly operational order trends

SELECT
    DATE_FORMAT(date, '%Y-%m') AS order_month,
    SUM(ns_order) AS total_orders

FROM sales_test

GROUP BY order_month
ORDER BY order_month;

-- Customer contribution to total order volume

SELECT
    customer_no,

    SUM(ns_order) AS total_orders,

    ROUND(
        SUM(ns_order) * 100.0 /
        (SELECT SUM(ns_order) FROM sales_test),
        2
    ) AS contribution_percentage

FROM sales_test

GROUP BY customer_no

ORDER BY total_orders DESC;

-- Product demand segmentation

SELECT
    item,

    SUM(ns_order) AS total_orders,

    CASE
        WHEN SUM(ns_order) >= 500 THEN 'High Demand'
        WHEN SUM(ns_order) >= 200 THEN 'Medium Demand'
        ELSE 'Low Demand'
    END AS demand_segment

FROM sales_test

GROUP BY item
ORDER BY total_orders DESC;

