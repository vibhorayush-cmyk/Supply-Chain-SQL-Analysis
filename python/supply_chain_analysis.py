import pandas as pd
import matplotlib.pyplot as plt


# =====================================================
# LOAD DATASETS
# =====================================================

sales = pd.read_csv('data/sales_orders.csv')

procurement = pd.read_csv('data/procurement_orders.csv')

products = pd.read_csv('data/product_master.csv')

customers = pd.read_csv('data/customer_master.csv')

suppliers = pd.read_csv('data/supplier_master.csv')


# =====================================================
# OPERATIONAL KPI SUMMARY
# =====================================================

print("\n--- OPERATIONAL KPI SUMMARY ---")

print("Total Orders:",
      len(sales))

print("Total Revenue:",
      round(sales['Order_Total'].sum(), 2))

print("Average Order Value:",
      round(sales['Order_Total'].mean(), 2))

print("Total Customers:",
      sales['Customer_ID'].nunique())

print("Total Products:",
      sales['Product_ID'].nunique())

# =====================================================
# PRODUCT REVENUE ANALYSIS
# =====================================================

top_products = (
    sales.groupby('Product_ID')['Order_Total']
    .sum()
    .sort_values(ascending=False)
    .head(10)
)

plt.figure(figsize=(10, 5))

top_products.plot(kind='bar')

plt.title('Top Products by Revenue')

plt.xlabel('Product ID')

plt.ylabel('Revenue')

plt.tight_layout()

plt.savefig('images/top_products.png')

plt.close()

print("\nTop product analysis completed.")

# =====================================================
# CUSTOMER REVENUE ANALYSIS
# =====================================================

top_customers = (
    sales.groupby('Customer_ID')['Order_Total']
    .sum()
    .sort_values(ascending=False)
    .head(10)
)

plt.figure(figsize=(10, 5))

top_customers.plot(kind='bar')

plt.title('Top Customers by Revenue')

plt.xlabel('Customer ID')

plt.ylabel('Revenue')

plt.tight_layout()

plt.savefig('images/top_customers.png')

plt.close()

print("Customer revenue analysis completed.")

# =====================================================
# DELIVERY PERFORMANCE ANALYSIS
# =====================================================

delivery_performance = (
    sales['Delivery_Status']
    .value_counts()
)

plt.figure(figsize=(8, 5))

delivery_performance.plot(kind='bar')

plt.title('Delivery Performance Analysis')

plt.xlabel('Delivery Status')

plt.ylabel('Number of Orders')

plt.tight_layout()

plt.savefig('images/delivery_performance.png')

plt.close()

print("Delivery performance analysis completed.")

# =====================================================
# SUPPLIER PROCUREMENT ANALYSIS
# =====================================================

top_suppliers = (
    procurement.groupby('Supplier_ID')['Total_Cost']
    .sum()
    .sort_values(ascending=False)
    .head(10)
)

plt.figure(figsize=(10, 5))

top_suppliers.plot(kind='bar')

plt.title('Top Suppliers by Procurement Spend')

plt.xlabel('Supplier ID')

plt.ylabel('Total Procurement Cost')

plt.tight_layout()

plt.savefig('images/top_suppliers.png')

plt.close()

print("Supplier procurement analysis completed.")

# =====================================================
# MONTHLY OPERATIONAL TREND ANALYSIS
# =====================================================

sales['Order_Date'] = pd.to_datetime(
    sales['Order_Date']
)

monthly_sales = (
    sales.groupby(
        sales['Order_Date'].dt.to_period('M')
    )['Order_Total']
    .sum()
)

plt.figure(figsize=(12, 5))

monthly_sales.plot()

plt.title('Monthly Revenue Trend')

plt.xlabel('Month')

plt.ylabel('Revenue')

plt.tight_layout()

plt.savefig('images/monthly_revenue_trend.png')

plt.close()

print("Monthly operational trend analysis completed.")

# =====================================================
# ABC INVENTORY CLASSIFICATION
# =====================================================

inventory = (
    sales.groupby('Product_ID')['Order_Quantity']
    .sum()
    .reset_index()
)


def classify_inventory(x):

    if x >= 500:
        return 'A'

    elif x >= 200:
        return 'B'

    return 'C'


inventory['Inventory_Category'] = (
    inventory['Order_Quantity']
    .apply(classify_inventory)
)

plt.figure(figsize=(7, 5))

inventory['Inventory_Category'].value_counts().plot(
    kind='bar'
)

plt.title('ABC Inventory Classification')

plt.xlabel('Inventory Category')

plt.ylabel('Number of Products')

plt.tight_layout()

plt.savefig('images/abc_inventory.png')

plt.close()

print("ABC inventory classification completed.")
