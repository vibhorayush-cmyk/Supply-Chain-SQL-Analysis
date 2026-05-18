# 🚀 Quick Start Guide

Get the Supply Chain SQL Analysis project running in 5 minutes.

## Prerequisites

- Python 3.8 or higher
- Git (to clone the repository)
- 10 MB disk space for the database

## Step 1: Clone the Repository

```bash
git clone https://github.com/yourusername/Supply-Chain-SQL-Analysis.git
cd Supply-Chain-SQL-Analysis
```

## Step 2: Install Dependencies

### Option A: Using pip
```bash
pip install -r requirements.txt
```

### Option B: Using conda
```bash
conda create -n supply-chain python=3.9
conda activate supply-chain
pip install -r requirements.txt
```

## Step 3: Load the Data

```bash
python load_data.py
```

**Expected output:**
```
============================================================
SUPPLY CHAIN DATA PIPELINE - STARTING
Timestamp: 2026-05-18 14:30:00
============================================================

STEP 1: Validating CSV files...
✓ CSV file validated: sales_orders.csv
✓ CSV file validated: customer_master.csv
✓ CSV file validated: product_master.csv
✓ CSV file validated: procurement_orders.csv
✓ CSV file validated: supplier_master.csv

...
============================================================
✓ DATA PIPELINE COMPLETED SUCCESSFULLY
Total records loaded: 22,800
Database: c:\Users\Admin\Downloads\Supply-Chain-SQL-Analysis\supply_chain.db
============================================================
```

## Step 4: Verify the Database (Optional)

### Using SQLite CLI
```bash
sqlite3 supply_chain.db "SELECT COUNT(*) FROM sales_orders;"
```

**Expected output:** `20000`

### Using Python
```python
import sqlite3
conn = sqlite3.connect('supply_chain.db')
cursor = conn.cursor()
cursor.execute("SELECT COUNT(*) FROM sales_orders")
print(cursor.fetchone())
conn.close()
```

## Step 5: Run SQL Queries

### Option A: VS Code with SQLTools Extension

1. **Install SQLTools Extension** (if not already installed)
   - Open VS Code
   - Go to Extensions → Search "SQLTools"
   - Click "Install"

2. **Create Database Connection**
   - Click SQLTools icon (left sidebar)
   - Click "Add New Connection"
   - Select "SQLite" → Browse to `supply_chain.db` → Save

3. **Execute Queries**
   - Open `sql/Supply chain analysis.sql`
   - Click on a query or highlight text
   - Press **`Ctrl + Shift + E`** to execute
   - View results in the "OUTPUT" panel

### Option B: Command Line

```bash
sqlite3 supply_chain.db < sql/"Supply chain analysis.sql"
```

### Option C: Python Script

```python
import sqlite3

conn = sqlite3.connect('supply_chain.db')
cursor = conn.cursor()

# Execute a query
cursor.execute("""
    SELECT Country, SUM(Order_Total) as revenue
    FROM sales_orders s
    JOIN customer_master c ON s.Customer_ID = c.Customer_ID
    GROUP BY c.Country
    ORDER BY revenue DESC
""")

# Fetch and display results
for row in cursor.fetchall():
    print(f"{row[0]}: ${row[1]:,.2f}")

conn.close()
```

## Sample Queries to Get Started

### 1. Revenue Dashboard
```sql
SELECT 
  SUM(Order_Total) AS total_revenue,
  COUNT(DISTINCT Customer_ID) AS customers,
  COUNT(*) AS orders,
  ROUND(AVG(Order_Total), 2) AS avg_order
FROM sales_orders;
```

### 2. Top Products by Revenue
```sql
SELECT p.Product_Name, SUM(s.Order_Total) as revenue
FROM sales_orders s
JOIN product_master p ON s.Product_ID = p.Product_ID
GROUP BY p.Product_Name
ORDER BY revenue DESC
LIMIT 10;
```

### 3. Delivery Performance by Region
```sql
SELECT 
  c.Country,
  COUNT(*) as orders,
  ROUND(SUM(CASE WHEN Late_Delivery_Risk_Flag = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as late_pct
FROM sales_orders s
JOIN customer_master c ON s.Customer_ID = c.Customer_ID
GROUP BY c.Country
ORDER BY late_pct DESC;
```

See [README.md](README.md) for more advanced queries.

## Project Structure

```
Supply-Chain-SQL-Analysis/
├── README.md                          # Full documentation
├── QUICKSTART.md                      # This file
├── requirements.txt                   # Python dependencies
├── load_data.py                       # Data loading script
├── supply_chain.db                    # SQLite database (created after step 3)
│
├── data/                              # Raw data files
│   ├── sales_orders.csv              # 20,000 transaction records
│   ├── customer_master.csv           # 500 customer profiles
│   ├── product_master.csv            # 200 product catalog
│   ├── procurement_orders.csv        # 2,000 PO records
│   ├── supplier_master.csv           # 100 supplier details
│   └── data_dictionary.csv           # Column definitions
│
├── sql/                               # SQL analysis scripts
│   └── Supply chain analysis.sql     # 12 advanced queries
│
└── .gitignore                        # Git ignore rules
```

## Troubleshooting

### Issue: "No such file or directory: 'supply_chain.db'"
**Solution:** Make sure you've run `python load_data.py` first to create the database.

### Issue: "ModuleNotFoundError: No module named 'pandas'"
**Solution:** Install dependencies with `pip install -r requirements.txt`

### Issue: CSV files not found
**Solution:** Ensure the CSV files are in the `data/` subdirectory and the paths in `load_data.py` are correct.

### Issue: SQLTools connection fails
**Solution:** 
- Verify the database file path is correct
- Ensure the file has read permissions
- Try creating a new connection from scratch

## Next Steps

1. **Explore the Data**
   - Run the sample queries above
   - Modify queries to answer your own questions

2. **Advanced Analysis**
   - Check [README.md](README.md) for complex queries with:
     - Window functions
     - CTEs (Common Table Expressions)
     - Advanced aggregations

3. **Build Your Own Queries**
   - Use the `data_dictionary.csv` to understand column names
   - Reference the database schema in README.md

## Getting Help

- **SQL Questions:** [SQL Tutorial](https://www.sql-tutorial.com/)
- **SQLite Syntax:** [SQLite Documentation](https://www.sqlite.org/docs.html)
- **Data Analysis:** [Mode Analytics SQL Tutorial](https://mode.com/sql-tutorial/)

## Performance Tips

For faster query execution:
1. Use indexed columns (Customer_ID, Product_ID, Order_Date)
2. Filter data before joining large tables
3. Avoid SELECT * - specify only needed columns
4. Use EXPLAIN QUERY PLAN to analyze performance

```sql
EXPLAIN QUERY PLAN
SELECT * FROM sales_orders WHERE Customer_ID = 'C123';
```

---

**Happy analyzing! 📊**
