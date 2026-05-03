
# 🐍 Data Cleaning & Preprocessing (Python)

This folder contains the Python pipeline used to clean, standardize, and prepare raw data for downstream SQL analysis and dashboarding.

---

## 🎯 Objective

To transform raw, unstructured datasets into clean, consistent, and analysis-ready tables by applying industry-standard data preprocessing techniques.

---

## 📁 File

- `data_cleaning.py`

---

## ⚙️ Tools & Libraries

- Python  
- Pandas  
- NumPy  

---

## 🔄 Data Pipeline Workflow

Raw Data → Cleaning & Validation → Structured Tables → SQL Transformation → Power BI Dashboard

---

## 🔧 Data Cleaning Steps

### 1. Column Standardization
- Converted column names to lowercase  
- Replaced spaces with underscores  
- Ensured consistent schema across all tables  

---

### 2. Duplicate Removal
- Removed duplicate records using primary keys:
  - `order_id` (orders)  
  - `customer_id` (customers)  
  - `session_id` (sessions)  
  - `event_id` (marketing_events)  

---

### 3. String Normalization
- Converted text to lowercase  
- Removed extra spaces  
- Standardized categorical values  

---

### 4. Missing Value Handling
- Filled categorical nulls with `"unknown"`  
- Used mode/forward-fill for customer attributes  

---

### 5. Outlier Detection (IQR Method)
- Identified extreme values in `order_value`  
- Used interquartile range (IQR) to detect anomalies  

---

### 6. Data Export
Cleaned datasets are saved as:

- `clean_customers.csv`  
- `clean_sessions.csv`  
- `clean_orders.csv`  
- `clean_order_items.csv`  
- `clean_marketing_events.csv`  
- `clean_returns.csv`  

---

## 📊 Output

The cleaned datasets are used to:

- Build Gold layer tables using SQL  
- Perform retention and funnel analysis  
- Power the Power BI dashboard  

---

## 💡 Key Design Principles

- Modular pipeline structure  
- Reusable functions for cleaning  
- Separation of raw vs processed data  
- Optimized for analytical use  

---

## 📌 Note

This pipeline ensures data consistency and quality before performing any business analysis, following real-world data engineering practices.
