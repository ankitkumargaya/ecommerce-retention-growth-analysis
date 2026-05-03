import pandas as pd
import numpy as np

# ===========================================
# 📌 1. LOAD DATA
# ===========================================

def load_data():
    return {
        "orders": pd.read_csv("orders.csv"),
        "customers": pd.read_csv("customers.csv"),
        "sessions": pd.read_csv("sessions.csv"),
        "marketing_spend": pd.read_csv("marketing_spend.csv"),
        "returns": pd.read_csv("returns.csv"),
        "order_items": pd.read_csv("order_items.csv"),
        "marketing_events": pd.read_csv("marketing_events.csv"),
    }

# ===========================================
# 📌 2. STANDARDIZE HEADERS
# ===========================================

def clean_header(df):
    df.columns = (
        df.columns
        .str.strip()
        .str.lower()
        .str.replace(" ", "_")
    )
    return df

# ===========================================
# 📌 3. REMOVE DUPLICATES
# ===========================================

def remove_duplicates(df, key):
    return df.drop_duplicates(subset=[key], keep="last")

# ===========================================
# 📌 4. CLEAN STRING DATA
# ===========================================

def clean_string(df):
    cols = df.select_dtypes(include=["object", "string"]).columns
    for col in cols:
        df[col] = (
            df[col]
            .astype(str)
            .str.lower()
            .str.replace(r"\s+", " ", regex=True)
            .str.strip()
        )
    return df

# ===========================================
# 📌 5. HANDLE MISSING VALUES
# ===========================================

def handle_missing_values(data):
    data["orders"]["order_status"].fillna("unknown", inplace=True)
    data["orders"]["payment_method"].fillna("unknown", inplace=True)

    data["customers"]["age_group"].fillna(method="ffill", inplace=True)
    data["customers"]["gender"].fillna(
        data["customers"]["gender"].mode()[0], inplace=True
    )

    return data

# ===========================================
# 📌 6. OUTLIER DETECTION (IQR)
# ===========================================

def detect_outliers(df, col):
    Q1 = df[col].quantile(0.25)
    Q3 = df[col].quantile(0.75)
    IQR = Q3 - Q1

    lower = Q1 - 1.5 * IQR
    upper = Q3 + 1.5 * IQR

    outliers = df[(df[col] < lower) | (df[col] > upper)]

    print(f"Outliers in {col}: {len(outliers)} ({round(len(outliers)/len(df)*100,2)}%)")

    return df

# ===========================================
# 📌 7. SAVE CLEAN DATA
# ===========================================

def save_data(data):
    data["customers"].to_csv("clean_customers.csv", index=False)
    data["sessions"].to_csv("clean_sessions.csv", index=False)
    data["orders"].to_csv("clean_orders.csv", index=False)
    data["order_items"].to_csv("clean_order_items.csv", index=False)
    data["marketing_events"].to_csv("clean_marketing_events.csv", index=False)
    data["returns"].to_csv("clean_returns.csv", index=False)

# ===========================================
# 🚀 MAIN PIPELINE
# ===========================================

def run_pipeline():
    data = load_data()

    # Header cleaning
    for key in data:
        data[key] = clean_header(data[key])

    # Remove duplicates
    data["orders"] = remove_duplicates(data["orders"], "order_id")
    data["customers"] = remove_duplicates(data["customers"], "customer_id")
    data["sessions"] = remove_duplicates(data["sessions"], "session_id")
    data["marketing_events"] = remove_duplicates(data["marketing_events"], "event_id")

    # String cleaning
    for key in data:
        data[key] = clean_string(data[key])

    # Missing values
    data = handle_missing_values(data)

    # Outlier check
    detect_outliers(data["orders"], "order_value")

    # Save
    save_data(data)

    print("✅ Data cleaning pipeline completed successfully")

# Run
if __name__ == "__main__":
    run_pipeline()