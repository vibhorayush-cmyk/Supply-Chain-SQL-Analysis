CREATE TABLE IF NOT EXISTS sales_orders (
    Order_ID TEXT PRIMARY KEY,
    Customer_ID TEXT,
    Product_ID TEXT,
    Order_Date TEXT,
    Order_Status TEXT,
    Order_Quantity INTEGER,
    Unit_Price REAL,
    Discount REAL,
    Shipping_Mode TEXT,
    Shipping_Carrier TEXT,
    Shipping_Date_Scheduled TEXT,
    Shipping_Date_Actual TEXT,
    Delivery_Status TEXT,
    Late_Delivery_Risk_Flag INTEGER,
    VAT_Rate REAL,
    COGS REAL,
    Unit_Price_Effective REAL,
    Order_Total REAL,
    VAT_Amount REAL,
    Profit_Per_Order REAL
);

CREATE TABLE IF NOT EXISTS customer_master (
    Customer_ID TEXT PRIMARY KEY,
    Customer_Name TEXT,
    Industry TEXT,
    Market_Segment TEXT,
    Country TEXT,
    City TEXT,
    Latitude REAL,
    Longitude REAL
);

CREATE TABLE IF NOT EXISTS product_master (
    Product_ID TEXT PRIMARY KEY,
    SKU TEXT,
    Product_Name TEXT,
    Category TEXT,
    Subcategory TEXT,
    Unit TEXT,
    Unit_Cost REAL,
    Standard_Price REAL,
    Launch_Date TEXT,
    Discontinuation_Date TEXT
);

CREATE TABLE IF NOT EXISTS procurement_orders (
    PO_ID TEXT PRIMARY KEY,
    Supplier_ID TEXT,
    Raw_Material_ID TEXT,
    Order_Date TEXT,
    Order_Quantity INTEGER,
    Unit_Cost REAL,
    Delivery_Date_Planned TEXT,
    Delivery_Date_Actual TEXT,
    Total_Cost REAL
);

CREATE TABLE IF NOT EXISTS supplier_master (
    Supplier_ID TEXT PRIMARY KEY,
    Supplier_Name TEXT,
    Country TEXT,
    Region TEXT,
    On_Time_Delivery_Rate REAL,
    Certification_Level TEXT,
    Preferred_Supplier_Flag INTEGER
);

-- Sample queries
SELECT * FROM sales_orders LIMIT 10;