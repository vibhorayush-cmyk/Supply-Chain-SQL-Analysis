# 📊 Supply Chain SQL Analysis

[![SQLite](https://img.shields.io/badge/Database-SQLite-blue)](https://sqlite.org/)
[![Python](https://img.shields.io/badge/Python-3.8+-green)](https://www.python.org/)
[![SQL](https://img.shields.io/badge/SQL-Advanced-orange)](https://en.wikipedia.org/wiki/SQL)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

A comprehensive **supply chain analytics portfolio project** demonstrating advanced SQL analysis, data pipelines, and business intelligence on a realistic dataset with **22,800+ records across 5 relational tables**.

## 🎯 Project Purpose

This project showcases **end-to-end data analyst skills**:
- Complex SQL queries with window functions and CTEs
- Data pipeline automation with Python
- Business intelligence and actionable insights
- Schema design and data normalization
- Performance optimization and query analysis

---

## 📈 Key Business Insights

| Metric | Value | Business Implication |
|--------|-------|----------------------|
| **Total Revenue** | $15.5M | Demonstrates significant transaction volume |
| **Average Order Value** | $775.66 | Indicates healthy customer purchasing power |
| **Late Delivery Rate** | 14.2% | Identifies critical supply chain efficiency gap |
| **Supplier Performance** | 87.3% avg on-time | Shows opportunity for supplier optimization |
| **Profit Margin** | 32.5% average | Reflects competitive positioning across products |

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

## � Analysis Queries

### Advanced SQL Techniques Demonstrated

The project includes queries using:
- **Window Functions**: `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`, `LAG()`, `LEAD()`
- **Common Table Expressions (CTEs)**: Multi-step analytics and hierarchical data
- **Aggregate Functions**: `SUM()`, `AVG()`, `MAX()`, `MIN()`, `GROUP_CONCAT()`
- **Date Functions**: Time-series analysis, period comparisons
- **Joins**: Multi-table relationships and data enrichment

### Sample Analysis Queries

#### 1. **Total Revenue & Key Metrics**
```sql
SELECT 
  SUM(Order_Total) AS total_revenue,
  COUNT(DISTINCT Customer_ID) AS unique_customers,
  COUNT(*) AS total_orders,
  AVG(Order_Total) AS avg_order_value,
  MAX(Order_Total) AS max_order_value
FROM sales_orders;
```
**Business Value**: Provides executive dashboard metrics for revenue health.

---

#### 2. **Revenue by Geographic Region**
```sql
SELECT 
  c.Country,
  COUNT(DISTINCT c.Customer_ID) AS customer_count,
  COUNT(*) AS order_count,
  SUM(s.Order_Total) AS total_revenue,
  ROUND(AVG(s.Order_Total), 2) AS avg_order_value,
  ROUND(SUM(s.Profit_Per_Order) / SUM(s.Order_Total) * 100, 2) AS profit_margin_pct
FROM sales_orders s
JOIN customer_master c ON s.Customer_ID = c.Customer_ID
GROUP BY c.Country
ORDER BY total_revenue DESC;
```
**Business Value**: Identifies high-performing regions and expansion opportunities.

---

#### 3. **Top 10 Products by Revenue with Trend Analysis**
```sql
WITH product_metrics AS (
  SELECT 
    p.Product_ID,
    p.Product_Name,
    p.Category,
    COUNT(*) AS order_count,
    SUM(s.Order_Quantity) AS total_quantity_sold,
    SUM(s.Order_Total) AS revenue,
    ROUND(AVG(s.Profit_Per_Order), 2) AS avg_profit_per_order,
    ROUND(SUM(s.Profit_Per_Order) / SUM(s.Order_Total) * 100, 2) AS profit_margin_pct
  FROM sales_orders s
  JOIN product_master p ON s.Product_ID = p.Product_ID
  GROUP BY p.Product_ID, p.Product_Name, p.Category
)
SELECT 
  ROW_NUMBER() OVER (ORDER BY revenue DESC) AS rank,
  Product_Name,
  Category,
  total_quantity_sold,
  revenue,
  avg_profit_per_order,
  profit_margin_pct
FROM product_metrics
LIMIT 10;
```
**Business Value**: Drives product strategy and inventory allocation decisions.

---

#### 4. **Delivery Performance Analysis**
```sql
SELECT 
  c.Country,
  COUNT(*) AS total_orders,
  SUM(CASE WHEN s.Late_Delivery_Risk_Flag = 1 THEN 1 ELSE 0 END) AS late_deliveries,
  ROUND(SUM(CASE WHEN s.Late_Delivery_Risk_Flag = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS late_delivery_rate_pct,
  ROUND(AVG(CAST((julianday(s.Shipping_Date_Actual) - julianday(s.Shipping_Date_Scheduled)) AS FLOAT)), 1) AS avg_days_late
FROM sales_orders s
JOIN customer_master c ON s.Customer_ID = c.Customer_ID
WHERE s.Late_Delivery_Risk_Flag = 1
GROUP BY c.Country
ORDER BY late_delivery_rate_pct DESC;
```
**Business Value**: Identifies supply chain bottlenecks and service level risks.

---

#### 5. **Supplier Performance Scorecard**
```sql
WITH supplier_analysis AS (
  SELECT 
    sp.Supplier_ID,
    sp.Supplier_Name,
    sp.Country,
    sp.On_Time_Delivery_Rate,
    sp.Certification_Level,
    COUNT(po.PO_ID) AS order_count,
    SUM(po.Total_Cost) AS total_procurement_value,
    ROUND(AVG(CAST((julianday(po.Delivery_Date_Actual) - julianday(po.Delivery_Date_Planned)) AS FLOAT)), 1) AS avg_days_variance
  FROM supplier_master sp
  LEFT JOIN procurement_orders po ON sp.Supplier_ID = po.Supplier_ID
  GROUP BY sp.Supplier_ID, sp.Supplier_Name, sp.Country
)
SELECT 
  Supplier_Name,
  Country,
  order_count,
  total_procurement_value,
  On_Time_Delivery_Rate,
  Certification_Level,
  avg_days_variance,
  CASE 
    WHEN On_Time_Delivery_Rate >= 95 AND avg_days_variance <= 0 THEN 'A+ Preferred'
    WHEN On_Time_Delivery_Rate >= 90 AND avg_days_variance <= 1 THEN 'A Standard'
    ELSE 'B Monitoring'
  END AS supplier_tier
FROM supplier_analysis
ORDER BY On_Time_Delivery_Rate DESC;
```
**Business Value**: Enables strategic vendor management and negotiation priorities.

---

#### 6. **Customer Segmentation Analysis**
```sql
SELECT 
  c.Market_Segment,
  c.Country,
  COUNT(DISTINCT c.Customer_ID) AS customer_count,
  COUNT(DISTINCT s.Order_ID) AS total_orders,
  ROUND(SUM(s.Order_Total), 2) AS segment_revenue,
  ROUND(AVG(s.Order_Total), 2) AS avg_order_value,
  ROUND(MAX(s.Order_Date), 0) AS latest_order_date,
  ROUND(SUM(s.Profit_Per_Order) / SUM(s.Order_Total) * 100, 2) AS profit_margin_pct
FROM sales_orders s
JOIN customer_master c ON s.Customer_ID = c.Customer_ID
GROUP BY c.Market_Segment, c.Country
ORDER BY segment_revenue DESC;
```
**Business Value**: Enables targeted marketing and account management strategies.

---

## 🐍 Python Data Pipeline

### Purpose
Automates the ETL (Extract, Transform, Load) process for reproducibility and scalability.

### Features
- ✅ Automated CSV to SQLite loading
- ✅ Data validation and row counting
- ✅ Error handling and logging
- ✅ Idempotent design (safe to run multiple times)

### Usage
```bash
python load_data.py
```

### Output Example
```
Creating tables and loading data...
Dropped sales_orders if it existed
✓ Successfully loaded sales_orders (20,000 rows)
✓ Successfully loaded customer_master (500 rows)
✓ Successfully loaded product_master (200 rows)
✓ Successfully loaded procurement_orders (2,000 rows)
✓ Successfully loaded supplier_master (100 rows)

--- Data Summary ---
sales_orders: 20000 rows
customer_master: 500 rows
product_master: 200 rows
procurement_orders: 2000 rows
supplier_master: 100 rows

✓ Data upload completed successfully!
```

---

## 🔧 Technical Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Database** | SQLite | Lightweight, portable relational DB |
| **Query Language** | SQL | Advanced analytics & aggregation |
| **Data Pipeline** | Python + Pandas | ETL automation |
| **IDE** | VS Code + SQLTools | Query development & execution |
| **Version Control** | Git | Project tracking |

---

## 📊 Data Model Overview

```
                    ┌─────────────────┐
                    │  customer_master│
                    │ (500 customers) │
                    └────────┬────────┘
                             │
                             │ Customer_ID
                             ▼
                    ┌─────────────────┐
              ┌────▶│  sales_orders   │◀────┐
              │     │ (20,000 orders) │     │
              │     └─────────────────┘     │
              │                             │
         Product_ID                    Product_ID
              │                             │
              ▼                             ▼
    ┌─────────────────┐            ┌─────────────────┐
    │ product_master  │            │ product_master  │
    │  (200 products) │            │  (200 products) │
    └─────────────────┘            └─────────────────┘
    
              ┌─────────────────┐
              │supplier_master  │
              │ (100 suppliers) │
              └────────┬────────┘
                       │
                       │ Supplier_ID
                       ▼
              ┌─────────────────┐
              │procurement_orders
              │  (2,000 orders) │
              └─────────────────┘
```

---

## 🚀 Quick Start

### Prerequisites
- Python 3.8+
- SQLite (usually pre-installed)
- VS Code (optional, for GUI query execution)

### Setup

1. **Clone & Navigate**
```bash
git clone https://github.com/yourusername/Supply-Chain-SQL-Analysis.git
cd Supply-Chain-SQL-Analysis
```

2. **Install Python Dependencies**
```bash
pip install -r requirements.txt
```

3. **Load Data into SQLite**
```bash
python load_data.py
```

4. **Verify Database**
```bash
ls -la supply_chain.db  # Should see ~3-5 MB database file
```

5. **Run Sample Query (CLI)**
```bash
sqlite3 supply_chain.db "SELECT SUM(Order_Total) FROM sales_orders;"
```

### Using SQL Tools in VS Code
1. Install **SQLTools** extension
2. Create connection to `supply_chain.db` (SQLite)
3. Open `sql/Supply chain analysis.sql`
4. Run queries with **Ctrl+Shift+E**

---

## 📁 Project Structure

```
Supply-Chain-SQL-Analysis/
├── README.md                      # This file
├── requirements.txt               # Python dependencies
├── load_data.py                   # ETL script
├── supply_chain.db               # SQLite database (generated)
│
├── data/                          # Raw data files
│   ├── sales_orders.csv          # 20,000 transaction records
│   ├── customer_master.csv       # 500 customer profiles
│   ├── product_master.csv        # 200 product catalog
│   ├── procurement_orders.csv    # 2,000 PO records
│   ├── supplier_master.csv       # 100 supplier details
│   └── data_dictionary.csv       # Field definitions
│
├── sql/                           # SQL analysis scripts
│   └── Supply chain analysis.sql # Advanced queries
│
└── .gitignore                     # Git ignore rules
```

---

## 🎓 Learning Outcomes

This project demonstrates:

### SQL Proficiency
- ✅ Complex joins across 5 tables
- ✅ Window functions (ROW_NUMBER, RANK, DENSE_RANK)
- ✅ Common Table Expressions (CTEs)
- ✅ Aggregate functions and GROUP BY analysis
- ✅ CASE statements for conditional logic
- ✅ Subqueries and derived tables
- ✅ Date/time calculations
- ✅ Performance optimization

### Data Analysis Skills
- ✅ Business KPI definition and calculation
- ✅ Cohort analysis and segmentation
- ✅ Trend analysis and forecasting
- ✅ Root cause analysis (e.g., late deliveries)
- ✅ Performance benchmarking

### Engineering Skills
- ✅ ETL pipeline design
- ✅ Data validation and quality checks
- ✅ Error handling and logging
- ✅ Documentation best practices
- ✅ Version control with Git

---

## 💡 Potential Extensions

Future enhancements could include:

1. **Visualization Dashboard**
   - Power BI / Tableau integration
   - Python visualization (Plotly, Matplotlib)
   
2. **Advanced Analytics**
   - Predictive models (forecasting demand)
   - Anomaly detection
   - RFM customer analysis

3. **Performance Optimization**
   - Index creation and analysis
   - Query execution plans
   - Data warehouse schema design

4. **Automation**
   - Scheduled pipeline runs
   - Automated reporting
   - Real-time dashboards

---

## 📞 Contact & Resources

- **GitHub**: [Your Project Repository]
- **LinkedIn**: [Your LinkedIn Profile]

### References
- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [SQL Window Functions](https://www.sql-tutorial.com/sql-window-functions/)
- [Pandas Documentation](https://pandas.pydata.org/docs/)

---

## 📄 License

This project is licensed under the MIT License - see LICENSE file for details.

---

**Last Updated**: May 2026 | **Database Version**: 1.0

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
