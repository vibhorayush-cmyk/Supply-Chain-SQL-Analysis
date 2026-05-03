-- Query 1: View first 10 sales orders
SELECT * FROM sales_orders LIMIT 10;

-- Query 2: Count total orders by customer
SELECT Customer_ID, COUNT(*) as Total_Orders 
FROM sales_orders 
GROUP BY Customer_ID 
LIMIT 5;

-- Query 3: Top 5 products by revenue
SELECT Product_ID, SUM(Order_Total) as Total_Revenue 
FROM sales_orders 
GROUP BY Product_ID 
ORDER BY Total_Revenue DESC 
LIMIT 5;