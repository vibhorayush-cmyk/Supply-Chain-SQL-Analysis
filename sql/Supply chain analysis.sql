/**
  ==================================================================================
  SUPPLY CHAIN ANALYTICS - ADVANCED SQL QUERIES
  ==================================================================================
  
  This file contains production-ready SQL queries demonstrating:
  - Window functions (ROW_NUMBER, RANK, DENSE_RANK, LAG, LEAD)
  - Common Table Expressions (CTEs) for complex multi-step logic
  - Advanced aggregations and statistical analysis
  - Business intelligence and KPI calculations
  
  Database: SQLite
  Last Updated: May 2026
  ==================================================================================
*/

-- ====================================================================================
-- 1. EXECUTIVE DASHBOARD - KEY PERFORMANCE INDICATORS
-- ====================================================================================
-- Purpose: High-level business metrics for executive reporting
-- Metrics: Revenue, Orders, Customers, Profitability

SELECT 
  SUM(Order_Total) AS total_revenue,
  COUNT(DISTINCT Customer_ID) AS unique_customers,
  COUNT(DISTINCT Product_ID) AS products_sold,
  COUNT(*) AS total_orders,
  ROUND(AVG(Order_Total), 2) AS avg_order_value,
  MAX(Order_Total) AS max_order_value,
  ROUND(SUM(Profit_Per_Order), 2) AS total_profit,
  ROUND(SUM(Profit_Per_Order) / SUM(Order_Total) * 100, 2) AS overall_profit_margin_pct,
  ROUND(SUM(CASE WHEN Late_Delivery_Risk_Flag = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS late_delivery_rate_pct
FROM sales_orders;

-- ====================================================================================
-- 2. GEOGRAPHIC PERFORMANCE ANALYSIS
-- ====================================================================================
-- Purpose: Identify high-performing regions and expansion opportunities
-- Metrics by Country: Revenue, customers, orders, profitability

SELECT 
  c.Country,
  COUNT(DISTINCT c.Customer_ID) AS customer_count,
  COUNT(*) AS order_count,
  SUM(s.Order_Total) AS total_revenue,
  ROUND(AVG(s.Order_Total), 2) AS avg_order_value,
  SUM(s.Order_Quantity) AS total_units_sold,
  ROUND(SUM(s.Profit_Per_Order), 2) AS total_profit,
  ROUND(SUM(s.Profit_Per_Order) / SUM(s.Order_Total) * 100, 2) AS profit_margin_pct,
  ROUND(SUM(CASE WHEN s.Late_Delivery_Risk_Flag = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS late_delivery_rate_pct
FROM sales_orders s
JOIN customer_master c ON s.Customer_ID = c.Customer_ID
GROUP BY c.Country
ORDER BY total_revenue DESC;

-- ====================================================================================
-- 3. TOP 15 PRODUCTS - COMPREHENSIVE RANKING WITH WINDOW FUNCTIONS
-- ====================================================================================
-- Purpose: Product strategy and inventory allocation decisions
-- Techniques: CTEs, Window Functions (ROW_NUMBER), Multiple KPIs

WITH product_metrics AS (
  SELECT 
    p.Product_ID,
    p.Product_Name,
    p.Category,
    p.Subcategory,
    COUNT(*) AS order_count,
    SUM(s.Order_Quantity) AS total_quantity_sold,
    SUM(s.Order_Total) AS revenue,
    ROUND(AVG(s.Order_Total), 2) AS avg_order_value,
    ROUND(SUM(s.Profit_Per_Order), 2) AS total_profit,
    ROUND(SUM(s.Profit_Per_Order) / SUM(s.Order_Total) * 100, 2) AS profit_margin_pct,
    MIN(s.Order_Date) AS first_sold,
    MAX(s.Order_Date) AS last_sold,
    ROUND(CAST((julianday(MAX(s.Order_Date)) - julianday(MIN(s.Order_Date))) AS FLOAT) / 30, 1) AS months_active
  FROM sales_orders s
  JOIN product_master p ON s.Product_ID = p.Product_ID
  GROUP BY p.Product_ID, p.Product_Name, p.Category, p.Subcategory
)
SELECT 
  ROW_NUMBER() OVER (ORDER BY revenue DESC) AS rank,
  Product_Name,
  Category,
  Subcategory,
  total_quantity_sold,
  order_count,
  revenue,
  avg_order_value,
  total_profit,
  profit_margin_pct,
  months_active
FROM product_metrics
LIMIT 15;

-- ====================================================================================
-- 4. CUSTOMER LIFETIME VALUE (CLV) ANALYSIS
-- ====================================================================================
-- Purpose: Identify high-value customers and churn risk
-- Techniques: CTEs, Window Functions (RANK), Customer segmentation

WITH customer_metrics AS (
  SELECT 
    c.Customer_ID,
    c.Customer_Name,
    c.Industry,
    c.Market_Segment,
    c.Country,
    COUNT(DISTINCT s.Order_ID) AS lifetime_orders,
    ROUND(SUM(s.Order_Total), 2) AS lifetime_revenue,
    ROUND(AVG(s.Order_Total), 2) AS avg_order_value,
    ROUND(SUM(s.Profit_Per_Order), 2) AS lifetime_profit,
    MIN(s.Order_Date) AS first_purchase_date,
    MAX(s.Order_Date) AS last_purchase_date,
    ROUND(CAST((julianday(MAX(s.Order_Date)) - julianday(MIN(s.Order_Date))) AS FLOAT) / 30, 1) AS customer_tenure_months
  FROM sales_orders s
  JOIN customer_master c ON s.Customer_ID = c.Customer_ID
  GROUP BY c.Customer_ID, c.Customer_Name, c.Industry, c.Market_Segment, c.Country
)
SELECT 
  RANK() OVER (ORDER BY lifetime_revenue DESC) AS clv_rank,
  Customer_Name,
  Industry,
  Market_Segment,
  Country,
  lifetime_orders,
  lifetime_revenue,
  avg_order_value,
  lifetime_profit,
  customer_tenure_months,
  CASE 
    WHEN lifetime_revenue >= 50000 THEN 'Platinum'
    WHEN lifetime_revenue >= 20000 THEN 'Gold'
    WHEN lifetime_revenue >= 10000 THEN 'Silver'
    ELSE 'Bronze'
  END AS customer_tier
FROM customer_metrics
WHERE lifetime_revenue >= 10000
ORDER BY lifetime_revenue DESC
LIMIT 20;

-- ====================================================================================
-- 5. DELIVERY PERFORMANCE ANALYSIS - REGIONAL INSIGHTS
-- ====================================================================================
-- Purpose: Identify supply chain bottlenecks and service level risks
-- Metrics: Late delivery rates, patterns, root causes

SELECT 
  c.Country,
  COUNT(*) AS total_orders,
  SUM(CASE WHEN s.Late_Delivery_Risk_Flag = 1 THEN 1 ELSE 0 END) AS late_orders,
  ROUND(SUM(CASE WHEN s.Late_Delivery_Risk_Flag = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS late_delivery_rate_pct,
  ROUND(AVG(CAST((julianday(s.Shipping_Date_Actual) - julianday(s.Shipping_Date_Scheduled)) AS FLOAT)), 1) AS avg_days_variance,
  MAX(CAST((julianday(s.Shipping_Date_Actual) - julianday(s.Shipping_Date_Scheduled)) AS FLOAT)) AS max_days_late,
  ROUND(AVG(CASE WHEN s.Late_Delivery_Risk_Flag = 1 
           THEN CAST((julianday(s.Shipping_Date_Actual) - julianday(s.Shipping_Date_Scheduled)) AS FLOAT) 
           ELSE NULL END), 1) AS avg_lateness_when_late
FROM sales_orders s
JOIN customer_master c ON s.Customer_ID = c.Customer_ID
GROUP BY c.Country
ORDER BY late_delivery_rate_pct DESC;

-- ====================================================================================
-- 6. SUPPLIER PERFORMANCE SCORECARD WITH RANKINGS
-- ====================================================================================
-- Purpose: Strategic vendor management and contract negotiation
-- Techniques: CTEs, Window Functions, Multi-dimensional scoring

WITH supplier_analysis AS (
  SELECT 
    sp.Supplier_ID,
    sp.Supplier_Name,
    sp.Country,
    sp.Certification_Level,
    sp.On_Time_Delivery_Rate,
    sp.Preferred_Supplier_Flag,
    COUNT(po.PO_ID) AS order_count,
    SUM(po.Total_Cost) AS total_procurement_value,
    ROUND(AVG(CAST((julianday(po.Delivery_Date_Actual) - julianday(po.Delivery_Date_Planned)) AS FLOAT)), 1) AS avg_days_variance,
    COUNT(CASE WHEN julianday(po.Delivery_Date_Actual) > julianday(po.Delivery_Date_Planned) THEN 1 END) AS late_deliveries
  FROM supplier_master sp
  LEFT JOIN procurement_orders po ON sp.Supplier_ID = po.Supplier_ID
  GROUP BY sp.Supplier_ID, sp.Supplier_Name, sp.Country, sp.Certification_Level, sp.On_Time_Delivery_Rate, sp.Preferred_Supplier_Flag
)
SELECT 
  RANK() OVER (ORDER BY On_Time_Delivery_Rate DESC, total_procurement_value DESC) AS performance_rank,
  Supplier_Name,
  Country,
  order_count,
  total_procurement_value,
  On_Time_Delivery_Rate,
  Certification_Level,
  avg_days_variance,
  late_deliveries,
  CASE 
    WHEN On_Time_Delivery_Rate >= 95 AND avg_days_variance <= 0 THEN 'A+ Preferred'
    WHEN On_Time_Delivery_Rate >= 90 AND avg_days_variance <= 1 THEN 'A Standard'
    WHEN On_Time_Delivery_Rate >= 85 THEN 'B Acceptable'
    ELSE 'C Monitoring'
  END AS supplier_tier,
  CASE WHEN Preferred_Supplier_Flag = 1 THEN 'Yes' ELSE 'No' END AS is_preferred
FROM supplier_analysis
WHERE order_count > 0
ORDER BY performance_rank
LIMIT 25;

-- ====================================================================================
-- 7. MARKET SEGMENT ANALYSIS - B2B vs B2C COMPARISON
-- ====================================================================================
-- Purpose: Targeted marketing and account management strategies
-- Metrics by Segment: Revenue, customers, profitability, delivery performance

SELECT 
  c.Market_Segment,
  COUNT(DISTINCT c.Customer_ID) AS customer_count,
  COUNT(*) AS order_count,
  SUM(s.Order_Total) AS segment_revenue,
  ROUND(AVG(s.Order_Total), 2) AS avg_order_value,
  SUM(s.Order_Quantity) AS total_units,
  ROUND(SUM(s.Profit_Per_Order), 2) AS segment_profit,
  ROUND(SUM(s.Profit_Per_Order) / SUM(s.Order_Total) * 100, 2) AS profit_margin_pct,
  ROUND(SUM(CASE WHEN s.Late_Delivery_Risk_Flag = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS late_delivery_pct,
  MIN(s.Order_Date) AS period_start,
  MAX(s.Order_Date) AS period_end
FROM sales_orders s
JOIN customer_master c ON s.Customer_ID = c.Customer_ID
GROUP BY c.Market_Segment
ORDER BY segment_revenue DESC;

-- ====================================================================================
-- 8. COHORT ANALYSIS - ORDER PATTERNS BY SHIPPING MODE
-- ====================================================================================
-- Purpose: Optimize shipping strategy and cost reduction
-- Metrics: Volume, profitability, and delivery performance by shipping mode

SELECT 
  s.Shipping_Mode,
  s.Shipping_Carrier,
  COUNT(*) AS order_count,
  SUM(s.Order_Total) AS revenue,
  ROUND(AVG(s.Order_Total), 2) AS avg_order_value,
  SUM(s.Order_Quantity) AS total_units,
  ROUND(SUM(s.Profit_Per_Order), 2) AS total_profit,
  ROUND(SUM(s.Profit_Per_Order) / SUM(s.Order_Total) * 100, 2) AS profit_margin_pct,
  ROUND(AVG(CAST((julianday(s.Shipping_Date_Actual) - julianday(s.Shipping_Date_Scheduled)) AS FLOAT)), 1) AS avg_days_variance,
  ROUND(SUM(CASE WHEN s.Late_Delivery_Risk_Flag = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS late_delivery_pct
FROM sales_orders s
GROUP BY s.Shipping_Mode, s.Shipping_Carrier
ORDER BY revenue DESC;

-- ====================================================================================
-- 9. PRODUCT CATEGORY PERFORMANCE - GROWTH & DECLINE ANALYSIS
-- ====================================================================================
-- Purpose: Category strategy and portfolio optimization
-- Techniques: CTEs, Window Functions (LAG for month-over-month comparison)

WITH monthly_category_sales AS (
  SELECT 
    p.Category,
    DATE(s.Order_Date, 'start of month') AS month,
    COUNT(*) AS order_count,
    SUM(s.Order_Total) AS monthly_revenue,
    SUM(s.Profit_Per_Order) AS monthly_profit
  FROM sales_orders s
  JOIN product_master p ON s.Product_ID = p.Product_ID
  GROUP BY p.Category, DATE(s.Order_Date, 'start of month')
)
SELECT 
  Category,
  month,
  order_count,
  monthly_revenue,
  monthly_profit,
  LAG(monthly_revenue) OVER (PARTITION BY Category ORDER BY month) AS prev_month_revenue,
  ROUND(monthly_revenue - LAG(monthly_revenue) OVER (PARTITION BY Category ORDER BY month), 2) AS revenue_change,
  ROUND((monthly_revenue - LAG(monthly_revenue) OVER (PARTITION BY Category ORDER BY month)) 
        / LAG(monthly_revenue) OVER (PARTITION BY Category ORDER BY month) * 100, 2) AS revenue_change_pct
FROM monthly_category_sales
ORDER BY Category, month DESC
LIMIT 24;

-- ====================================================================================
-- 10. DISCOUNT IMPACT ANALYSIS - PROFITABILITY CORRELATION
-- ====================================================================================
-- Purpose: Optimize pricing strategy and discount management
-- Metrics: Discount rates vs profit margins and order volume

SELECT 
  CASE 
    WHEN s.Discount = 0 THEN 'No Discount'
    WHEN s.Discount <= 0.1 THEN '1-10% Discount'
    WHEN s.Discount <= 0.2 THEN '11-20% Discount'
    WHEN s.Discount <= 0.3 THEN '21-30% Discount'
    ELSE '>30% Discount'
  END AS discount_band,
  COUNT(*) AS order_count,
  SUM(s.Order_Total) AS revenue,
  ROUND(AVG(s.Order_Total), 2) AS avg_order_value,
  ROUND(SUM(s.Profit_Per_Order), 2) AS total_profit,
  ROUND(SUM(s.Profit_Per_Order) / SUM(s.Order_Total) * 100, 2) AS profit_margin_pct,
  ROUND(AVG(s.Discount) * 100, 2) AS avg_discount_pct,
  ROUND(AVG(CASE WHEN s.Late_Delivery_Risk_Flag = 1 THEN 1 ELSE 0 END) * 100, 2) AS late_delivery_pct
FROM sales_orders s
GROUP BY discount_band
ORDER BY 
  CASE 
    WHEN discount_band = 'No Discount' THEN 1
    WHEN discount_band = '1-10% Discount' THEN 2
    WHEN discount_band = '11-20% Discount' THEN 3
    WHEN discount_band = '21-30% Discount' THEN 4
    ELSE 5
  END;

-- ====================================================================================
-- 11. INVENTORY OPTIMIZATION - FAST & SLOW MOVERS
-- ====================================================================================
-- Purpose: Optimize inventory management and reduce carrying costs
-- Metrics: Velocity, revenue contribution, profitability

WITH product_velocity AS (
  SELECT 
    p.Product_ID,
    p.Product_Name,
    p.Category,
    COUNT(DISTINCT s.Order_ID) AS purchase_frequency,
    SUM(s.Order_Quantity) AS total_units_sold,
    ROUND(SUM(s.Order_Total), 2) AS total_revenue,
    ROUND(SUM(s.Profit_Per_Order) / SUM(s.Order_Total) * 100, 2) AS profit_margin_pct,
    ROUND(CAST((julianday(MAX(s.Order_Date)) - julianday(MIN(s.Order_Date))) AS FLOAT) / 30, 1) AS months_in_catalog
  FROM sales_orders s
  JOIN product_master p ON s.Product_ID = p.Product_ID
  GROUP BY p.Product_ID, p.Product_Name, p.Category
)
SELECT 
  Product_Name,
  Category,
  purchase_frequency,
  total_units_sold,
  total_revenue,
  profit_margin_pct,
  months_in_catalog,
  ROUND(total_units_sold / NULLIF(months_in_catalog, 0), 1) AS avg_units_per_month,
  CASE 
    WHEN purchase_frequency >= 100 AND total_units_sold >= 500 THEN 'Fast Mover - A'
    WHEN purchase_frequency >= 50 AND total_units_sold >= 250 THEN 'Medium Mover - B'
    WHEN purchase_frequency >= 20 THEN 'Slow Mover - C'
    ELSE 'Very Slow - D'
  END AS inventory_classification
FROM product_velocity
ORDER BY purchase_frequency DESC;

-- ====================================================================================
-- 12. PROFITABILITY DRILL DOWN - IDENTIFY UNPROFITABLE PRODUCTS
-- ====================================================================================
-- Purpose: Product portfolio review and optimization
-- Risk: Identify products with negative or minimal margins

SELECT 
  p.Product_Name,
  p.Category,
  p.Subcategory,
  COUNT(*) AS orders,
  SUM(s.Order_Quantity) AS units_sold,
  ROUND(SUM(s.Order_Total), 2) AS revenue,
  ROUND(SUM(s.COGS), 2) AS cogs,
  ROUND(SUM(s.Profit_Per_Order), 2) AS total_profit,
  ROUND(SUM(s.Profit_Per_Order) / SUM(s.Order_Total) * 100, 2) AS profit_margin_pct,
  ROUND(AVG(s.Discount) * 100, 2) AS avg_discount_pct,
  CASE 
    WHEN SUM(s.Profit_Per_Order) / SUM(s.Order_Total) * 100 < 0 THEN '🔴 Loss'
    WHEN SUM(s.Profit_Per_Order) / SUM(s.Order_Total) * 100 < 10 THEN '⚠️  Low Margin'
    WHEN SUM(s.Profit_Per_Order) / SUM(s.Order_Total) * 100 < 20 THEN '🟡 Medium Margin'
    ELSE '🟢 Healthy Margin'
  END AS profitability_status
FROM sales_orders s
JOIN product_master p ON s.Product_ID = p.Product_ID
GROUP BY p.Product_ID, p.Product_Name, p.Category, p.Subcategory
HAVING SUM(s.Order_Total) > 10000  -- Filter for meaningful volume
ORDER BY profit_margin_pct ASC;