# Supply Chain SQL Analysis

A comprehensive supply chain database analysis project using SQLite with detailed customer, product, sales, and supplier information.

## 📊 Project Overview

This project contains a complete supply chain dataset with 22,800+ records across 5 interconnected tables. The database enables analysis of sales performance, customer behavior, procurement efficiency, and supplier metrics.

---

## 🗂️ Database Structure

### Tables & Records

| Table | Records | Description |
|-------|---------|-------------|
| **sales_orders** | 20,000 | Customer orders with pricing, shipping, and delivery details |
| **customer_master** | 500 | Customer demographics and geographic information |
| **product_master** | 200 | Product catalog with categories and pricing |
| **procurement_orders** | 2,000 | Supplier purchase orders and procurement data |
| **supplier_master** | 100 | Supplier details and performance metrics |

### Table Schemas

#### 📦 sales_orders
```
Order_ID, Customer_ID, Product_ID, Order_Date, Order_Status, Order_Quantity,
Unit_Price, Discount, Shipping_Mode, Shipping_Carrier, Shipping_Date_Scheduled,
Shipping_Date_Actual, Delivery_Status, Late_Delivery_Risk_Flag, VAT_Rate, COGS,
Unit_Price_Effective, Order_Total, VAT_Amount, Profit_Per_Order
```

#### 👥 customer_master
```
Customer_ID, Customer_Name, Industry, Market_Segment, Country, City, Latitude, Longitude
```

#### 📦 product_master
```
Product_ID, SKU, Product_Name, Category, Subcategory, Unit, Unit_Cost, 
Standard_Price, Launch_Date, Discontinuation_Date
```

#### 🚚 procurement_orders
```
PO_ID, Supplier_ID, Raw_Material_ID, Order_Date, Order_Quantity, Unit_Cost,
Delivery_Date_Planned, Delivery_Date_Actual, Total_Cost
```

#### 🏭 supplier_master
```
Supplier_ID, Supplier_Name, Country, Region, On_Time_Delivery_Rate, 
Certification_Level, Preferred_Supplier_Flag
```

---

## 🚀 Setup & Installation

### 1. Database Connection
The database file is pre-loaded at:
```
supply_chain.db
```

### 2. SQL Tools Configuration
- Connection Name: **Supply Chain DB**
- Database: `supply_chain.db`
- Driver: SQLite

### 3. Verify Connection
Open SQL Tools extension and confirm **Supply Chain DB** shows a ✓ checkmark.

---

## 📝 How to Run Queries

### In VS Code with SQL Tools:
1. Open `sql/Supply chain analysis.sql`
2. Write or select a query
3. Press **`Ctrl + Shift + E`** to execute
4. View results in the OUTPUT panel

### Column Names Reference:
**Use these exact column names in queries:**
- `Order_Total` (not `sales`)
- `Order_Quantity` (not `quantity`)
- `Customer_ID`, `Product_ID`, `Supplier_ID` (with underscores)
- `Country` (not `region`)

---

## 📈 Sample Analysis Queries

### 1. Total Revenue
```sql
SELECT SUM(Order_Total) AS total_revenue FROM sales_orders;
```
**Result:** $15,513,239.18

### 2. Top 10 Orders by Revenue
```sql
SELECT Order_ID, Customer_ID, Product_ID, Order_Total 
FROM sales_orders 
ORDER BY Order_Total DESC 
LIMIT 10;
```

### 3. Revenue by Country
```sql
SELECT c.Country, SUM(s.Order_Total) AS revenue
FROM sales_orders s
JOIN customer_master c 
ON s.Customer_ID = c.Customer_ID
GROUP BY c.Country
ORDER BY revenue DESC;
```
**Top Countries:** France, Germany, Australia, Spain, India

### 4. Sales by Customer Segment
```sql
SELECT 
    cm.Market_Segment,
    COUNT(so.Order_ID) as Total_Orders,
    SUM(so.Order_Total) as Total_Revenue
FROM sales_orders so
JOIN customer_master cm ON so.Customer_ID = cm.Customer_ID
GROUP BY cm.Market_Segment
ORDER BY Total_Revenue DESC;
```

### 5. Delivery Performance
```sql
SELECT 
    Delivery_Status,
    COUNT(*) as Order_Count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM sales_orders), 2) as Percentage
FROM sales_orders
GROUP BY Delivery_Status;
```

### 6. Top 10 Products by Revenue
```sql
SELECT 
    p.Product_Name,
    COUNT(s.Order_ID) as Units_Sold,
    SUM(s.Order_Total) as Total_Revenue
FROM sales_orders s
JOIN product_master p ON s.Product_ID = p.Product_ID
GROUP BY s.Product_ID, p.Product_Name
ORDER BY Total_Revenue DESC
LIMIT 10;
```

### 7. Supplier Performance
```sql
SELECT 
    Supplier_Name,
    On_Time_Delivery_Rate,
    Certification_Level,
    Preferred_Supplier_Flag
FROM supplier_master
ORDER BY On_Time_Delivery_Rate DESC;
```

### 8. Order Status Distribution
```sql
SELECT 
    Order_Status,
    COUNT(*) as Count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM sales_orders), 2) as Percentage
FROM sales_orders
GROUP BY Order_Status;
```

---

## 📊 Key Insights

- **Total Orders:** 20,000
- **Total Customers:** 500
- **Total Products:** 200
- **Total Suppliers:** 100
- **Total Revenue:** $15,513,239.18
- **Average Order Value:** $775.66
- **Countries Covered:** 10+

---

## 🔧 Troubleshooting

### Issue: "No such column" Error
- Check the exact column names in the table schema above
- Use `Customer_ID` not `customer_id`
- Use `Order_Total` not `sales`

### Issue: No Output in SQL Tools
- Verify the database connection is active (green checkmark)
- Check the OUTPUT panel at the bottom of VS Code
- Try running a simple query: `SELECT COUNT(*) FROM sales_orders;`

### Issue: Join Not Working
- Verify table and column names match exactly
- Example: `s.Customer_ID = c.Customer_ID` (case-sensitive)

---

## 📁 Project Structure

```
Supply-Chain-SQL-Analysis/
├── data/                          # CSV source files
│   ├── sales_orders.csv
│   ├── customer_master.csv
│   ├── product_master.csv
│   ├── procurement_orders.csv
│   ├── supplier_master.csv
│   └── data_dictionary.csv
├── sql/
│   └── Supply chain analysis.sql  # Query file
├── supply_chain.db                # SQLite database
├── load_data.py                   # Data import script
└── README.md                       # This file
```

---

## 💡 Analysis Ideas

1. **Sales Performance:** Identify top-selling products and customer segments
2. **Delivery Metrics:** Analyze on-time delivery rates and risk factors
3. **Geographic Trends:** Compare sales across regions and countries
4. **Supplier Evaluation:** Assess supplier performance and reliability
5. **Profitability Analysis:** Calculate profit margins and identify unprofitable orders
6. **Customer Behavior:** Segment customers and analyze purchase patterns

---

## 📌 Notes

- All dates are in YYYY-MM-DD format
- Currency values are in standard units (no currency symbol in database)
- Discount values are decimals (0.12 = 12%)
- Late_Delivery_Risk_Flag: 0 = No Risk, 1 = Risk
- Preferred_Supplier_Flag: 0 = Not Preferred, 1 = Preferred

---

## 📞 Support

For issues or questions:
1. Check the Troubleshooting section above
2. Verify column names match the schema exactly
3. Ensure SQL Tools connection is active
4. Review sample queries for proper syntax

---

**Last Updated:** May 3, 2026
**Database:** SQLite 3
**Status:** Ready for Analysis ✓
