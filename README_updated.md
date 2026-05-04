# 📦 Supply Chain SQL Analysis  

A comprehensive supply chain analytics project using **SQLite, SQL, and Python**, covering customer, product, sales, and supplier data.

---

## 📊 Project Overview  

This project simulates a real-world supply chain system with **22,800+ records across 5 relational tables**, enabling:

- Revenue & profitability analysis  
- Customer behavior insights  
- Supplier performance tracking  
- Logistics and delivery analysis  

---

## 🐍 Python Data Pipeline

This project uses Python to automate **data ingestion into SQLite**, making it reproducible and scalable.

### 📄 Script: `load_data.py`

### 🔧 What This Script Does

- Connects to SQLite database (`supply_chain.db`)
- Drops existing tables (optional reset)
- Reads CSV files using pandas
- Loads data into database tables
- Verifies row counts after loading

---

### ⚙️ Libraries Used

- sqlite3  
- pandas  
- os  

---

### ▶️ How to Run the Script

1. Install dependencies:
pip install pandas

2. Update file paths:
db_path = "your_path/supply_chain.db"  
data_path = "your_path/data"

3. Run the script:
python load_data.py

---

### 📥 Input Data Files

Located in `/data` folder:

- sales_orders.csv  
- customer_master.csv  
- product_master.csv  
- procurement_orders.csv  
- supplier_master.csv  

---

### 📤 Output

- SQLite database: supply_chain.db  
- Tables automatically created:
  - sales_orders  
  - customer_master  
  - product_master  
  - procurement_orders  
  - supplier_master  

---

## 🗂️ Database Structure  

Includes:
- 5 tables  
- relational joins  
- business-ready schema  

---

## 🚀 Setup & Installation  

### 1. Run Python Script (Data Load)
python load_data.py

### 2. Connect via SQL Tools (VS Code)
- Database: supply_chain.db  
- Driver: SQLite  

---

## 📁 Project Structure  

Supply-Chain-SQL-Analysis/
├── data/  
├── sql/  
├── supply_chain.db  
├── load_data.py  
├── README.md  

---

## 💡 Why Python Matters in This Project

- Automates data loading  
- Makes project reproducible  
- Demonstrates ETL pipeline skills  
- Adds real-world relevance  

---

## 📌 Key Skills Demonstrated

- SQL  
- Python  
- Pandas  
- SQLite  
- Data Analytics  

---

## ✅ Final Note

This project demonstrates an **end-to-end data workflow**, combining SQL analysis with Python-based data ingestion.
