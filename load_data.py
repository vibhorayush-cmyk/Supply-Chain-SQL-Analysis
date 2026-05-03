import sqlite3
import pandas as pd
import os

# Database path
db_path = r"c:\Users\Admin\Downloads\Supply-Chain-SQL-Analysis\supply_chain.db"
data_path = r"c:\Users\Admin\Downloads\Supply-Chain-SQL-Analysis\data"

# Connect to database
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

print("Creating tables and loading data...")

# Drop existing tables if they exist (optional - comment out if you want to keep existing data)
tables = ['sales_orders', 'customer_master', 'product_master', 'procurement_orders', 'supplier_master']
for table in tables:
    cursor.execute(f"DROP TABLE IF EXISTS {table}")
    print(f"Dropped {table} if it existed")

# Load each CSV file into the database
csv_files = {
    'sales_orders': os.path.join(data_path, 'sales_orders.csv'),
    'customer_master': os.path.join(data_path, 'customer_master.csv'),
    'product_master': os.path.join(data_path, 'product_master.csv'),
    'procurement_orders': os.path.join(data_path, 'procurement_orders.csv'),
    'supplier_master': os.path.join(data_path, 'supplier_master.csv')
}

for table_name, csv_file in csv_files.items():
    try:
        df = pd.read_csv(csv_file)
        df.to_sql(table_name, conn, if_exists='replace', index=False)
        print(f"✓ Successfully loaded {table_name} ({len(df)} rows)")
    except Exception as e:
        print(f"✗ Error loading {table_name}: {str(e)}")

# Verify the data
print("\n--- Data Summary ---")
for table in tables:
    cursor.execute(f"SELECT COUNT(*) FROM {table}")
    count = cursor.fetchone()[0]
    print(f"{table}: {count} rows")

conn.commit()
conn.close()
print("\n✓ Data upload completed successfully!")
