# Data Cleaning Summary

This project cleans the raw e-commerce files and creates a final customer retention table for analysis.

## Files Used

- `orders.csv`
- `customers.csv`
- `sessions.csv`
- `marketing_spend.csv`
- `returns.csv`
- `order_items.csv`
- `marketing_events.csv`

## Cleaning Steps Done

1. Loaded all raw CSV files into pandas.
2. Standardized column names by trimming spaces, converting to lowercase, and replacing special characters with `_`.
3. Removed full-row duplicates and duplicate primary key records.
4. Converted timestamp columns into proper datetime format.
5. Cleaned text columns by trimming extra spaces and converting text to lowercase.
6. Converted numeric columns to proper numeric type and handled invalid values.
7. In `orders`, flagged cases where `discount_amount > order_value`, capped the discount, and created `net_order_value`, `delivery_delay_days`, and `late_delivery_flag`.
8. In `returns`, flagged cases where refund amount was higher than the allowed order value, capped the refund, and created `return_days_after_order` plus refund anomaly flags.
9. In `order_items`, created `line_item_revenue`.
10. In `sessions` and `marketing_events`, cleaned flag columns and standardized values.
11. Built `final_customer_retention_table.csv` by combining customer, order, session, return, item, and marketing summaries.
12. Exported cleaned tables and a quality report.

## Output Files Created

- `clean_orders.csv`
- `clean_customers.csv`
- `clean_sessions.csv`
- `clean_marketing_spend.csv`
- `clean_returns.csv`
- `clean_order_items.csv`
- `clean_marketing_events.csv`
- `final_customer_retention_table.csv`
- `data_quality_report.json`

## Main Data Quality Findings

- `3,761` orders had discount greater than order value.
- `3,577` returns had refund greater than gross order value.
- `4,560` returns had refund greater than net order value.
- `130` returned orders had no matching record in `returns.csv`.
- `27,198` orders had no matching rows in `order_items.csv`.

## Final Result

- Final customer table size: `50,000` rows and `64` columns.
- After cleaning, `0` negative net order values remain.
- After cleaning, `0` refunds remain above the allowed cleaned value.
- After cleaning, `0` returns happen before the order date.
