from __future__ import annotations

import json
from pathlib import Path

import numpy as np
import pandas as pd
from pandas.api.types import is_datetime64_any_dtype, is_object_dtype, is_string_dtype


BASE_DIR = Path(__file__).resolve().parent

DATA_FILES = {
    "orders": "orders.csv",
    "customers": "customers.csv",
    "sessions": "sessions.csv",
    "marketing_spend": "marketing_spend.csv",
    "returns": "returns.csv",
    "order_items": "order_items.csv",
    "marketing_events": "marketing_events.csv",
}

PRIMARY_KEYS = {
    "orders": "order_id",
    "customers": "customer_id",
    "sessions": "session_id",
    "marketing_spend": "acquisition_channel",
    "returns": "return_id",
    "order_items": "order_item_id",
    "marketing_events": "event_id",
}

DATE_COLUMNS = {
    "orders": ["order_timestamp"],
    "customers": ["signup_timestamp"],
    "sessions": ["session_start_ts"],
    "returns": ["return_timestamp"],
    "marketing_events": ["event_timestamp"],
}


def load_data() -> dict[str, pd.DataFrame]:
    return {
        name: pd.read_csv(BASE_DIR / filename)
        for name, filename in DATA_FILES.items()
    }


def clean_header(df: pd.DataFrame) -> pd.DataFrame:
    cleaned = df.copy()
    cleaned.columns = (
        cleaned.columns.astype(str)
        .str.strip()
        .str.lower()
        .str.replace(r"[^0-9a-zA-Z]+", "_", regex=True)
        .str.strip("_")
    )
    return cleaned


def remove_duplicates(
    df: pd.DataFrame,
    primary_key: str | None = None,
) -> tuple[pd.DataFrame, dict[str, int]]:
    deduped = df.drop_duplicates().copy()
    full_row_duplicates_removed = int(len(df) - len(deduped))

    primary_key_duplicates_removed = 0
    if primary_key and primary_key in deduped.columns:
        primary_key_duplicates_removed = int(
            deduped.duplicated(subset=[primary_key], keep="last").sum()
        )
        deduped = deduped.drop_duplicates(subset=[primary_key], keep="last").copy()

    summary = {
        "rows_before": int(len(df)),
        "rows_after": int(len(deduped)),
        "full_row_duplicates_removed": full_row_duplicates_removed,
        "primary_key_duplicates_removed": primary_key_duplicates_removed,
    }
    return deduped, summary


def parse_datetime_columns(
    data: dict[str, pd.DataFrame]
) -> tuple[dict[str, pd.DataFrame], dict[str, dict[str, int]]]:
    invalid_counts: dict[str, dict[str, int]] = {}

    for table_name, columns in DATE_COLUMNS.items():
        frame = data[table_name].copy()
        invalid_counts[table_name] = {}

        for column in columns:
            if column not in frame.columns:
                continue

            parsed = pd.to_datetime(frame[column], utc=True, errors="coerce")
            invalid_counts[table_name][column] = int(parsed.isna().sum())
            frame[column] = parsed

        data[table_name] = frame

    return data, invalid_counts


def clean_string_columns(df: pd.DataFrame) -> pd.DataFrame:
    cleaned = df.copy()

    for column in cleaned.columns:
        series = cleaned[column]
        if is_datetime64_any_dtype(series):
            continue
        if is_string_dtype(series) or is_object_dtype(series):
            normalized = (
                series.astype("string")
                .str.replace(r"\s+", " ", regex=True)
                .str.strip()
                .str.lower()
            )
            cleaned[column] = normalized.mask(normalized == "", pd.NA)

    return cleaned


def clean_orders(df: pd.DataFrame) -> pd.DataFrame:
    cleaned = df.copy()

    numeric_columns = [
        "order_value",
        "discount_amount",
        "promised_delivery_days",
        "actual_delivery_days",
    ]
    for column in numeric_columns:
        cleaned[column] = pd.to_numeric(cleaned[column], errors="coerce")

    cleaned["order_value"] = cleaned["order_value"].clip(lower=0).round(2)
    cleaned["discount_amount"] = cleaned["discount_amount"].clip(lower=0).round(2)
    cleaned["discount_exceeds_order_value_flag"] = (
        cleaned["discount_amount"] > cleaned["order_value"]
    ).astype("int8")

    exceeds_discount = cleaned["discount_exceeds_order_value_flag"] == 1
    cleaned.loc[exceeds_discount, "discount_amount"] = cleaned.loc[
        exceeds_discount, "order_value"
    ]

    cleaned["net_order_value"] = (
        cleaned["order_value"] - cleaned["discount_amount"]
    ).round(2)
    cleaned["delivery_delay_days"] = (
        cleaned["actual_delivery_days"] - cleaned["promised_delivery_days"]
    )
    cleaned["late_delivery_flag"] = (cleaned["delivery_delay_days"] > 0).astype("int8")

    return cleaned


def clean_sessions(df: pd.DataFrame) -> pd.DataFrame:
    cleaned = df.copy()

    numeric_columns = [
        "session_duration_sec",
        "pages_viewed",
        "added_to_cart_flag",
        "checkout_started_flag",
    ]
    for column in numeric_columns:
        cleaned[column] = pd.to_numeric(cleaned[column], errors="coerce")

    cleaned["session_duration_sec"] = cleaned["session_duration_sec"].clip(lower=0)
    cleaned["pages_viewed"] = cleaned["pages_viewed"].clip(lower=0)
    cleaned["added_to_cart_flag"] = cleaned["added_to_cart_flag"].fillna(0).astype("int8")
    cleaned["checkout_started_flag"] = (
        cleaned["checkout_started_flag"].fillna(0).astype("int8")
    )

    return cleaned


def clean_marketing_spend(df: pd.DataFrame) -> pd.DataFrame:
    cleaned = df.copy()
    cleaned["total_marketing_spend"] = (
        pd.to_numeric(cleaned["total_marketing_spend"], errors="coerce")
        .clip(lower=0)
        .round(2)
    )
    return cleaned


def clean_returns(df: pd.DataFrame, orders: pd.DataFrame) -> pd.DataFrame:
    cleaned = df.copy()
    cleaned["refund_amount"] = (
        pd.to_numeric(cleaned["refund_amount"], errors="coerce")
        .clip(lower=0)
        .round(2)
    )

    order_lookup = orders[
        ["order_id", "order_timestamp", "order_value", "net_order_value"]
    ].rename(
        columns={
            "order_timestamp": "source_order_timestamp",
            "order_value": "source_order_value",
            "net_order_value": "source_net_order_value",
        }
    )
    cleaned = cleaned.merge(order_lookup, on="order_id", how="left")

    cleaned["refund_exceeds_order_value_flag"] = (
        cleaned["source_order_value"].notna()
        & (cleaned["refund_amount"] > cleaned["source_order_value"])
    ).astype("int8")
    cleaned["refund_exceeds_net_order_value_flag"] = (
        cleaned["source_net_order_value"].notna()
        & (cleaned["refund_amount"] > cleaned["source_net_order_value"])
    ).astype("int8")

    refund_cap = cleaned["source_net_order_value"].where(
        cleaned["source_net_order_value"].notna(),
        cleaned["source_order_value"],
    )
    exceeds_refund = refund_cap.notna() & (cleaned["refund_amount"] > refund_cap)
    cleaned.loc[exceeds_refund, "refund_amount"] = refund_cap.loc[exceeds_refund]
    cleaned["return_days_after_order"] = (
        cleaned["return_timestamp"] - cleaned["source_order_timestamp"]
    ).dt.days

    return cleaned


def clean_order_items(df: pd.DataFrame) -> pd.DataFrame:
    cleaned = df.copy()

    numeric_columns = ["product_price", "quantity", "is_discounted"]
    for column in numeric_columns:
        cleaned[column] = pd.to_numeric(cleaned[column], errors="coerce")

    cleaned["product_price"] = cleaned["product_price"].clip(lower=0).round(2)
    cleaned["quantity"] = cleaned["quantity"].clip(lower=1)
    cleaned["is_discounted"] = cleaned["is_discounted"].fillna(0).astype("int8")
    cleaned["line_item_revenue"] = (
        cleaned["product_price"] * cleaned["quantity"]
    ).round(2)

    return cleaned


def clean_marketing_events(df: pd.DataFrame) -> pd.DataFrame:
    cleaned = df.copy()

    for column in ["clicked_flag", "converted_flag"]:
        cleaned[column] = pd.to_numeric(cleaned[column], errors="coerce").fillna(0)
        cleaned[column] = cleaned[column].astype("int8")

    return cleaned


def apply_table_specific_cleaning(
    data: dict[str, pd.DataFrame]
) -> dict[str, pd.DataFrame]:
    data["orders"] = clean_orders(data["orders"])
    data["sessions"] = clean_sessions(data["sessions"])
    data["marketing_spend"] = clean_marketing_spend(data["marketing_spend"])
    data["returns"] = clean_returns(data["returns"], data["orders"])
    data["order_items"] = clean_order_items(data["order_items"])
    data["marketing_events"] = clean_marketing_events(data["marketing_events"])
    return data


def build_final_customer_table(data: dict[str, pd.DataFrame]) -> pd.DataFrame:
    customers = data["customers"].copy()
    orders = data["orders"].copy()
    sessions = data["sessions"].copy()
    marketing_spend = data["marketing_spend"].copy()
    returns = data["returns"].copy()
    order_items = data["order_items"].copy()
    marketing_events = data["marketing_events"].copy()

    snapshot_candidates = [
        data[table_name][column].max()
        for table_name, columns in DATE_COLUMNS.items()
        for column in columns
        if column in data[table_name].columns and data[table_name][column].notna().any()
    ]
    snapshot_date = max(snapshot_candidates)

    channel_customer_counts = customers.groupby(
        "acquisition_channel", as_index=False
    ).agg(channel_customer_count=("customer_id", "nunique"))
    marketing_spend = marketing_spend.merge(
        channel_customer_counts, on="acquisition_channel", how="left"
    )
    marketing_spend["estimated_acquisition_cost_per_customer"] = (
        marketing_spend["total_marketing_spend"]
        / marketing_spend["channel_customer_count"]
    ).round(2)
    customers = customers.merge(marketing_spend, on="acquisition_channel", how="left")

    orders_agg = orders.groupby("customer_id", as_index=False).agg(
        total_orders=("order_id", "nunique"),
        gross_order_value=("order_value", "sum"),
        total_discount_amount=("discount_amount", "sum"),
        total_net_order_value=("net_order_value", "sum"),
        avg_order_value=("order_value", "mean"),
        avg_net_order_value=("net_order_value", "mean"),
        first_order_timestamp=("order_timestamp", "min"),
        last_order_timestamp=("order_timestamp", "max"),
        avg_delivery_delay_days=("delivery_delay_days", "mean"),
        max_delivery_delay_days=("delivery_delay_days", "max"),
        late_delivery_orders=("late_delivery_flag", "sum"),
        discount_anomaly_orders=("discount_exceeds_order_value_flag", "sum"),
    )

    status_counts = (
        orders.assign(status_row_count=1)
        .pivot_table(
            index="customer_id",
            columns="order_status",
            values="status_row_count",
            aggfunc="sum",
            fill_value=0,
        )
        .rename(columns=lambda status: f"{status}_orders")
        .reset_index()
    )
    status_counts.columns.name = None

    sessions_agg = sessions.groupby("customer_id", as_index=False).agg(
        total_sessions=("session_id", "nunique"),
        total_session_duration_sec=("session_duration_sec", "sum"),
        avg_session_duration_sec=("session_duration_sec", "mean"),
        total_pages_viewed=("pages_viewed", "sum"),
        avg_pages_viewed=("pages_viewed", "mean"),
        cart_sessions=("added_to_cart_flag", "sum"),
        checkout_started_sessions=("checkout_started_flag", "sum"),
        first_session_timestamp=("session_start_ts", "min"),
        last_session_timestamp=("session_start_ts", "max"),
    )

    returns_with_customer = returns.merge(
        orders[["order_id", "customer_id"]], on="order_id", how="left"
    )
    returns_agg = returns_with_customer.groupby("customer_id", as_index=False).agg(
        total_returns=("return_id", "nunique"),
        total_refund_amount=("refund_amount", "sum"),
        avg_refund_amount=("refund_amount", "mean"),
        first_return_timestamp=("return_timestamp", "min"),
        last_return_timestamp=("return_timestamp", "max"),
        refund_anomaly_returns=("refund_exceeds_net_order_value_flag", "sum"),
    )

    order_items_with_customer = order_items.merge(
        orders[["order_id", "customer_id"]], on="order_id", how="left"
    )
    order_items_agg = order_items_with_customer.groupby(
        "customer_id", as_index=False
    ).agg(
        total_order_items=("order_item_id", "nunique"),
        total_quantity_purchased=("quantity", "sum"),
        total_item_catalog_value=("line_item_revenue", "sum"),
        unique_products=("product_id", "nunique"),
        unique_categories=("category", "nunique"),
        discounted_items=("is_discounted", "sum"),
    )

    marketing_events_agg = marketing_events.groupby("customer_id", as_index=False).agg(
        total_marketing_events=("event_id", "nunique"),
        marketing_clicks=("clicked_flag", "sum"),
        marketing_conversions=("converted_flag", "sum"),
        first_marketing_event_timestamp=("event_timestamp", "min"),
        last_marketing_event_timestamp=("event_timestamp", "max"),
    )

    final_table = customers.merge(orders_agg, on="customer_id", how="left")
    for frame in [
        status_counts,
        sessions_agg,
        returns_agg,
        order_items_agg,
        marketing_events_agg,
    ]:
        final_table = final_table.merge(frame, on="customer_id", how="left")

    zero_fill_columns = [
        "channel_customer_count",
        "estimated_acquisition_cost_per_customer",
        "total_orders",
        "gross_order_value",
        "total_discount_amount",
        "total_net_order_value",
        "avg_order_value",
        "avg_net_order_value",
        "avg_delivery_delay_days",
        "max_delivery_delay_days",
        "late_delivery_orders",
        "discount_anomaly_orders",
        "delivered_orders",
        "returned_orders",
        "cancelled_orders",
        "total_sessions",
        "total_session_duration_sec",
        "avg_session_duration_sec",
        "total_pages_viewed",
        "avg_pages_viewed",
        "cart_sessions",
        "checkout_started_sessions",
        "total_returns",
        "total_refund_amount",
        "avg_refund_amount",
        "refund_anomaly_returns",
        "total_order_items",
        "total_quantity_purchased",
        "total_item_catalog_value",
        "unique_products",
        "unique_categories",
        "discounted_items",
        "total_marketing_events",
        "marketing_clicks",
        "marketing_conversions",
    ]

    for column in zero_fill_columns:
        if column in final_table.columns:
            final_table[column] = final_table[column].fillna(0)

    round_columns = [
        "total_marketing_spend",
        "estimated_acquisition_cost_per_customer",
        "gross_order_value",
        "total_discount_amount",
        "total_net_order_value",
        "avg_order_value",
        "avg_net_order_value",
        "avg_delivery_delay_days",
        "avg_session_duration_sec",
        "avg_pages_viewed",
        "total_refund_amount",
        "avg_refund_amount",
        "total_item_catalog_value",
    ]
    for column in round_columns:
        if column in final_table.columns:
            final_table[column] = final_table[column].round(2)

    integer_columns = [
        "channel_customer_count",
        "total_orders",
        "late_delivery_orders",
        "discount_anomaly_orders",
        "delivered_orders",
        "returned_orders",
        "cancelled_orders",
        "total_sessions",
        "total_session_duration_sec",
        "total_pages_viewed",
        "cart_sessions",
        "checkout_started_sessions",
        "total_returns",
        "refund_anomaly_returns",
        "total_order_items",
        "total_quantity_purchased",
        "unique_products",
        "unique_categories",
        "discounted_items",
        "total_marketing_events",
        "marketing_clicks",
        "marketing_conversions",
    ]
    for column in integer_columns:
        if column in final_table.columns:
            final_table[column] = final_table[column].astype("int64")

    final_table["analysis_snapshot_date"] = snapshot_date
    final_table["days_since_signup"] = (
        snapshot_date - final_table["signup_timestamp"]
    ).dt.days.astype("Int64")
    final_table["days_since_last_order"] = (
        snapshot_date - final_table["last_order_timestamp"]
    ).dt.days.astype("Int64")
    final_table["days_since_last_session"] = (
        snapshot_date - final_table["last_session_timestamp"]
    ).dt.days.astype("Int64")
    final_table["days_since_last_marketing_event"] = (
        snapshot_date - final_table["last_marketing_event_timestamp"]
    ).dt.days.astype("Int64")
    final_table["days_since_last_return"] = (
        snapshot_date - final_table["last_return_timestamp"]
    ).dt.days.astype("Int64")

    final_table["has_orders_flag"] = final_table["total_orders"].gt(0).astype("int8")
    final_table["has_returns_flag"] = final_table["total_returns"].gt(0).astype("int8")
    final_table["retained_90d_flag"] = (
        final_table["days_since_last_order"].le(90).fillna(False).astype("int8")
    )
    final_table["engaged_90d_flag"] = (
        final_table["days_since_last_session"].le(90).fillna(False).astype("int8")
    )
    final_table["return_rate"] = np.where(
        final_table["total_orders"] > 0,
        final_table["total_returns"] / final_table["total_orders"],
        0,
    ).round(4)
    final_table["conversion_rate"] = np.where(
        final_table["total_marketing_events"] > 0,
        final_table["marketing_conversions"] / final_table["total_marketing_events"],
        0,
    ).round(4)
    final_table["net_revenue_after_refunds"] = (
        final_table["total_net_order_value"] - final_table["total_refund_amount"]
    ).round(2)

    final_table = final_table.sort_values("customer_id").reset_index(drop=True)
    return final_table


def summarize_table(df: pd.DataFrame, primary_key: str | None = None) -> dict[str, object]:
    summary: dict[str, object] = {
        "row_count": int(len(df)),
        "column_count": int(df.shape[1]),
        "columns": df.columns.tolist(),
        "null_counts": {
            column: int(count)
            for column, count in df.isna().sum().items()
            if count > 0
        },
        "full_row_duplicates": int(df.duplicated().sum()),
    }

    if primary_key and primary_key in df.columns:
        summary["primary_key_duplicates"] = int(
            df.duplicated(subset=[primary_key]).sum()
        )

    return summary


def build_quality_report(
    data: dict[str, pd.DataFrame],
    final_table: pd.DataFrame,
    duplicate_summary: dict[str, dict[str, int]],
    invalid_datetime_summary: dict[str, dict[str, int]],
) -> dict[str, object]:
    orders = data["orders"]
    customers = data["customers"]
    sessions = data["sessions"]
    marketing_events = data["marketing_events"]
    returns = data["returns"]
    order_items = data["order_items"]

    returned_order_ids = set(
        orders.loc[orders["order_status"] == "returned", "order_id"].tolist()
    )
    return_record_order_ids = set(returns["order_id"].tolist())

    refund_residual_mask = (
        returns["source_order_value"].notna()
        & (returns["refund_amount"] > returns["source_order_value"])
    )

    report: dict[str, object] = {
        "table_summaries": {
            name: summarize_table(frame, PRIMARY_KEYS.get(name))
            for name, frame in data.items()
        },
        "duplicate_removal": duplicate_summary,
        "invalid_datetimes_after_parse": invalid_datetime_summary,
        "cross_table_checks": {
            "orders_customer_id_missing_in_customers": int(
                (~orders["customer_id"].isin(customers["customer_id"])).sum()
            ),
            "sessions_customer_id_missing_in_customers": int(
                (~sessions["customer_id"].isin(customers["customer_id"])).sum()
            ),
            "marketing_events_customer_id_missing_in_customers": int(
                (~marketing_events["customer_id"].isin(customers["customer_id"])).sum()
            ),
            "returns_order_id_missing_in_orders": int(
                (~returns["order_id"].isin(orders["order_id"])).sum()
            ),
            "order_items_order_id_missing_in_orders": int(
                (~order_items["order_id"].isin(orders["order_id"])).sum()
            ),
        },
        "business_rule_checks": {
            "discount_amount_exceeded_order_value_flagged": int(
                orders["discount_exceeds_order_value_flag"].sum()
            ),
            "refund_amount_exceeded_order_value_flagged": int(
                returns["refund_exceeds_order_value_flag"].sum()
            ),
            "refund_amount_exceeded_net_order_value_flagged": int(
                returns["refund_exceeds_net_order_value_flag"].sum()
            ),
            "returned_status_orders_without_return_record": int(
                len(returned_order_ids - return_record_order_ids)
            ),
            "return_record_without_returned_status": int(
                len(return_record_order_ids - returned_order_ids)
            ),
            "orders_without_order_items": int(
                (~orders["order_id"].isin(order_items["order_id"])).sum()
            ),
            "customers_without_orders": int(
                (~customers["customer_id"].isin(orders["customer_id"])).sum()
            ),
            "customers_without_sessions": int(
                (~customers["customer_id"].isin(sessions["customer_id"])).sum()
            ),
            "customers_without_marketing_events": int(
                (~customers["customer_id"].isin(marketing_events["customer_id"])).sum()
            ),
        },
        "residual_cleanliness_checks": {
            "negative_net_order_value_after_cleaning": int(
                (orders["net_order_value"] < 0).sum()
            ),
            "refund_still_exceeds_order_value_after_cleaning": int(
                refund_residual_mask.sum()
            ),
            "returns_before_order_after_cleaning": int(
                (returns["return_days_after_order"] < 0).sum()
            ),
        },
        "final_customer_table": summarize_table(final_table, "customer_id"),
        "analysis_snapshot_date": final_table["analysis_snapshot_date"].iloc[0],
    }

    return report


def save_outputs(
    data: dict[str, pd.DataFrame],
    final_table: pd.DataFrame,
    quality_report: dict[str, object],
) -> None:
    for name, frame in data.items():
        frame.to_csv(BASE_DIR / f"clean_{name}.csv", index=False)

    final_table.to_csv(BASE_DIR / "final_customer_retention_table.csv", index=False)
    (BASE_DIR / "data_quality_report.json").write_text(
        json.dumps(quality_report, indent=2, default=str),
        encoding="utf-8",
    )


def print_pipeline_summary(
    data: dict[str, pd.DataFrame],
    final_table: pd.DataFrame,
    quality_report: dict[str, object],
) -> None:
    print("Data cleaning and final table build completed.")
    print()
    print("Clean table shapes:")
    for name, frame in data.items():
        print(f" - {name}: {frame.shape[0]} rows x {frame.shape[1]} columns")

    print(
        f" - final_customer_retention_table: {final_table.shape[0]} rows x {final_table.shape[1]} columns"
    )
    print()
    print("Key quality findings:")
    print(
        " - Orders with discount_amount > order_value flagged and capped:",
        quality_report["business_rule_checks"]["discount_amount_exceeded_order_value_flagged"],
    )
    print(
        " - Returns with refund_amount > order_value flagged and capped:",
        quality_report["business_rule_checks"]["refund_amount_exceeded_order_value_flagged"],
    )
    print(
        " - Returns with refund_amount > net_order_value flagged and capped:",
        quality_report["business_rule_checks"]["refund_amount_exceeded_net_order_value_flagged"],
    )
    print(
        " - Returned orders missing a matching return record:",
        quality_report["business_rule_checks"]["returned_status_orders_without_return_record"],
    )
    print(
        " - Orders with no matching order_items rows:",
        quality_report["business_rule_checks"]["orders_without_order_items"],
    )


def run_pipeline() -> tuple[dict[str, pd.DataFrame], pd.DataFrame, dict[str, object]]:
    data = load_data()

    duplicate_summary: dict[str, dict[str, int]] = {}
    for table_name, frame in data.items():
        data[table_name] = clean_header(frame)
        data[table_name], duplicate_summary[table_name] = remove_duplicates(
            data[table_name], PRIMARY_KEYS.get(table_name)
        )

    data, invalid_datetime_summary = parse_datetime_columns(data)

    for table_name, frame in data.items():
        data[table_name] = clean_string_columns(frame)

    data = apply_table_specific_cleaning(data)
    final_table = build_final_customer_table(data)
    quality_report = build_quality_report(
        data,
        final_table,
        duplicate_summary,
        invalid_datetime_summary,
    )

    save_outputs(data, final_table, quality_report)
    print_pipeline_summary(data, final_table, quality_report)

    return data, final_table, quality_report


if __name__ == "__main__":
    run_pipeline()
