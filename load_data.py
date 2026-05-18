"""
Supply Chain Data Pipeline - ETL Script

Purpose:
    Automates the loading of CSV data files into a SQLite database.
    Includes validation, error handling, and data integrity checks.

Usage:
    python load_data.py

Output:
    - Creates/updates supply_chain.db
    - Logs data loading status and record counts
    - Validates data integrity

Author: Data Analyst Portfolio Project
Version: 1.0
"""

import sqlite3
import pandas as pd
import os
import logging
from pathlib import Path
from datetime import datetime

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('data_load.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# Configuration
DB_PATH = r"c:\Users\Admin\Downloads\Supply-Chain-SQL-Analysis\supply_chain.db"
DATA_PATH = r"c:\Users\Admin\Downloads\Supply-Chain-SQL-Analysis\data"

# Define tables with expected row counts for validation
TABLES_CONFIG = {
    'sales_orders': {
        'csv': 'sales_orders.csv',
        'expected_rows': 20000,
        'critical': True
    },
    'customer_master': {
        'csv': 'customer_master.csv',
        'expected_rows': 500,
        'critical': True
    },
    'product_master': {
        'csv': 'product_master.csv',
        'expected_rows': 200,
        'critical': True
    },
    'procurement_orders': {
        'csv': 'procurement_orders.csv',
        'expected_rows': 2000,
        'critical': True
    },
    'supplier_master': {
        'csv': 'supplier_master.csv',
        'expected_rows': 100,
        'critical': True
    }
}


def validate_csv_file(file_path):
    """
    Validate that a CSV file exists and is readable.
    
    Args:
        file_path (str): Path to CSV file
        
    Returns:
        bool: True if valid, False otherwise
    """
    if not os.path.exists(file_path):
        logger.error(f"CSV file not found: {file_path}")
        return False
    
    try:
        pd.read_csv(file_path, nrows=1)
        logger.info(f"✓ CSV file validated: {os.path.basename(file_path)}")
        return True
    except Exception as e:
        logger.error(f"✗ CSV file validation failed: {file_path} - {str(e)}")
        return False


def create_database_connection(db_path):
    """
    Create a connection to SQLite database.
    
    Args:
        db_path (str): Path to database file
        
    Returns:
        sqlite3.Connection: Database connection object
    """
    try:
        conn = sqlite3.connect(db_path)
        logger.info(f"✓ Connected to database: {db_path}")
        return conn
    except Exception as e:
        logger.error(f"✗ Database connection failed: {str(e)}")
        raise


def drop_existing_tables(cursor, tables):
    """
    Drop existing tables to ensure clean data load.
    
    Args:
        cursor (sqlite3.Cursor): Database cursor
        tables (list): List of table names to drop
    """
    for table in tables:
        try:
            cursor.execute(f"DROP TABLE IF EXISTS {table}")
            logger.info(f"  ↻ Dropped {table} (if existed)")
        except Exception as e:
            logger.error(f"  ✗ Failed to drop {table}: {str(e)}")
            raise


def load_csv_to_database(cursor, conn, table_name, csv_file_path, expected_rows):
    """
    Load a single CSV file into the database with validation.
    
    Args:
        cursor (sqlite3.Cursor): Database cursor
        conn (sqlite3.Connection): Database connection
        table_name (str): Name of target table
        csv_file_path (str): Path to source CSV
        expected_rows (int): Expected number of rows for validation
        
    Returns:
        dict: Load statistics including row count and status
    """
    try:
        # Read CSV
        df = pd.read_csv(csv_file_path)
        rows_loaded = len(df)
        
        # Validate row count
        variance = abs(rows_loaded - expected_rows)
        variance_pct = (variance / expected_rows) * 100 if expected_rows > 0 else 0
        
        if variance_pct > 10:  # Alert if variance > 10%
            logger.warning(
                f"  ⚠ Row count variance for {table_name}: "
                f"Expected {expected_rows}, got {rows_loaded} ({variance_pct:.1f}%)"
            )
        
        # Load into database
        df.to_sql(table_name, conn, if_exists='replace', index=False)
        
        # Verify load
        cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
        verified_count = cursor.fetchone()[0]
        
        if verified_count == rows_loaded:
            logger.info(f"  ✓ {table_name}: {rows_loaded:,} rows loaded successfully")
            return {
                'table': table_name,
                'status': 'SUCCESS',
                'rows_loaded': rows_loaded,
                'verified': True
            }
        else:
            logger.error(
                f"  ✗ {table_name}: Verification failed "
                f"(loaded {rows_loaded}, verified {verified_count})"
            )
            return {
                'table': table_name,
                'status': 'VERIFICATION_FAILED',
                'rows_loaded': rows_loaded,
                'verified': False
            }
            
    except Exception as e:
        logger.error(f"  ✗ Error loading {table_name}: {str(e)}")
        return {
            'table': table_name,
            'status': 'ERROR',
            'rows_loaded': 0,
            'verified': False,
            'error': str(e)
        }


def print_data_summary(cursor, tables):
    """
    Print summary statistics for all loaded tables.
    
    Args:
        cursor (sqlite3.Cursor): Database cursor
        tables (list): List of table names
    """
    logger.info("\n" + "="*60)
    logger.info("DATA LOAD SUMMARY")
    logger.info("="*60)
    
    total_rows = 0
    for table in tables:
        try:
            cursor.execute(f"SELECT COUNT(*) FROM {table}")
            count = cursor.fetchone()[0]
            total_rows += count
            logger.info(f"  {table:<25} : {count:>10,} rows")
        except Exception as e:
            logger.error(f"  {table:<25} : Failed to count - {str(e)}")
    
    logger.info("-"*60)
    logger.info(f"  {'TOTAL':<25} : {total_rows:>10,} rows")
    logger.info("="*60 + "\n")
    
    return total_rows


def main():
    """
    Main ETL pipeline orchestration.
    """
    logger.info("\n" + "="*60)
    logger.info("SUPPLY CHAIN DATA PIPELINE - STARTING")
    logger.info(f"Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    logger.info("="*60 + "\n")
    
    try:
        # Step 1: Validate all CSV files exist
        logger.info("STEP 1: Validating CSV files...")
        all_valid = True
        for table_config in TABLES_CONFIG.values():
            csv_path = os.path.join(DATA_PATH, table_config['csv'])
            if not validate_csv_file(csv_path):
                if table_config['critical']:
                    all_valid = False
        
        if not all_valid:
            raise FileNotFoundError("Critical CSV files are missing")
        
        # Step 2: Connect to database
        logger.info("\nSTEP 2: Connecting to database...")
        conn = create_database_connection(DB_PATH)
        cursor = conn.cursor()
        
        # Step 3: Drop existing tables
        logger.info("\nSTEP 3: Dropping existing tables...")
        drop_existing_tables(cursor, list(TABLES_CONFIG.keys()))
        
        # Step 4: Load data
        logger.info("\nSTEP 4: Loading CSV data...")
        load_results = []
        
        for table_name, config in TABLES_CONFIG.items():
            csv_path = os.path.join(DATA_PATH, config['csv'])
            result = load_csv_to_database(
                cursor, conn, table_name, csv_path, config['expected_rows']
            )
            load_results.append(result)
        
        # Step 5: Commit and close
        logger.info("\nSTEP 5: Committing changes...")
        conn.commit()
        
        # Step 6: Print summary
        logger.info("\nSTEP 6: Generating summary...")
        total_rows = print_data_summary(cursor, list(TABLES_CONFIG.keys()))
        
        # Step 7: Validation
        logger.info("STEP 7: Final validation...")
        failed_loads = [r for r in load_results if r['status'] != 'SUCCESS']
        
        if failed_loads:
            logger.warning(f"⚠ {len(failed_loads)} table(s) failed to load properly")
            for failed in failed_loads:
                logger.warning(f"  - {failed['table']}: {failed['status']}")
        
        conn.close()
        
        # Final message
        logger.info("\n" + "="*60)
        logger.info("✓ DATA PIPELINE COMPLETED SUCCESSFULLY")
        logger.info(f"Total records loaded: {total_rows:,}")
        logger.info(f"Database: {DB_PATH}")
        logger.info("="*60 + "\n")
        
        return True
        
    except Exception as e:
        logger.error(f"\n✗ PIPELINE FAILED: {str(e)}")
        logger.info("="*60 + "\n")
        return False


if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)
