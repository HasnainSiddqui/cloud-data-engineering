"""
Smart City AQI — Stage 2: ETL Pipeline
========================================
Extracts from the IoT simulator CSV + OpenAQ CSV, cleans/transforms
with Pandas, and loads the result into Snowflake CLEAN.AQI_CLEAN (Silver).

Run:
    python etl_pipeline.py
    python etl_pipeline.py --no-snowflake   # transform only, writes clean CSVs
"""

import argparse
import os
from datetime import datetime, timezone

import pandas as pd
from dotenv import load_dotenv

load_dotenv()

IOT_CSV = "iot_readings.csv"
OPENAQ_CSV = "openaq_readings.csv"
CLEAN_CSV = "aqi_clean.csv"

# EPA breakpoints reused for category/label lookups
AQI_BREAKPOINTS = [
    (0.0, 12.0, "Good"),
    (12.1, 35.4, "Moderate"),
    (35.5, 55.4, "Unhealthy for Sensitive Groups"),
    (55.5, 150.4, "Unhealthy"),
    (150.5, 250.4, "Very Unhealthy"),
    (250.5, 500.4, "Hazardous"),
]

RISK_MAP = {
    "Good": "LOW",
    "Moderate": "LOW",
    "Unhealthy for Sensitive Groups": "MEDIUM",
    "Unhealthy": "HIGH",
    "Very Unhealthy": "HIGH",
    "Hazardous": "CRITICAL",
}


def aqi_category_from_pm25(pm25: float) -> str:
    if pd.isna(pm25):
        return None
    pm25 = max(0.0, min(pm25, 500.4))
    for c_lo, c_hi, label in AQI_BREAKPOINTS:
        if c_lo <= pm25 <= c_hi:
            return label
    return "Hazardous"


# ---------------------------------------------------------------
# IoT transform
# ---------------------------------------------------------------
def transform_iot(df: pd.DataFrame) -> pd.DataFrame:
    if df.empty:
        return df

    df = df.copy()

    # Drop rows where pm25 or aqi_value is null
    df = df.dropna(subset=["pm25", "aqi_value"])

    # Validate ranges
    df = df[df["pm25"].between(0, 500)]
    df = df[df["co2_ppm"].between(400, 2000)]
    df = df[df["humidity_pct"].between(0, 100)]

    # aqi_category from EPA breakpoints
    df["aqi_category"] = df["pm25"].apply(aqi_category_from_pm25)
    df["health_risk"] = df["aqi_category"].map(RISK_MAP)

    # Deduplicate on (sensor_id, recorded_at)
    df = df.drop_duplicates(subset=["sensor_id", "recorded_at"])

    df["processed_at"] = datetime.now(timezone.utc).isoformat()
    df["source"] = "iot_simulator"

    # Align to Silver schema
    df["latitude"] = None
    df["longitude"] = None

    return df[
        [
            "source", "city", "sensor_id", "pm25", "pm10", "co2_ppm",
            "aqi_value", "aqi_category", "health_risk", "latitude",
            "longitude", "recorded_at", "processed_at",
        ]
    ]


# ---------------------------------------------------------------
# OpenAQ transform
# ---------------------------------------------------------------
def transform_openaq(df: pd.DataFrame) -> pd.DataFrame:
    if df.empty:
        return df

    df = df.copy()

    # Filter to pm25 / pm10 only
    df = df[df["pollutant_type"].isin(["pm25", "pm10"])]

    # Drop non-positive readings
    df = df[df["pollutant_value"] > 0]

    # Convert recorded_at to UTC
    df["recorded_at"] = pd.to_datetime(df["recorded_at"], utc=True, errors="coerce")
    df = df.dropna(subset=["recorded_at"])

    df["source"] = "openaq_v3"
    df["country_code"] = "PK"

    # Pivot pm25/pm10 per station+timestamp so each row has both, like the IoT rows
    pivot = (
        df.pivot_table(
            index=["location_id", "station_name", "city", "latitude", "longitude", "recorded_at"],
            columns="pollutant_type",
            values="pollutant_value",
            aggfunc="mean",
        )
        .reset_index()
    )
    for col in ("pm25", "pm10"):
        if col not in pivot.columns:
            pivot[col] = None

    pivot["aqi_category"] = pivot["pm25"].apply(aqi_category_from_pm25)
    pivot["health_risk"] = pivot["aqi_category"].map(RISK_MAP)
    pivot["aqi_value"] = pivot["pm25"].apply(
        lambda v: calculate_aqi_value(v) if pd.notna(v) else None
    )
    pivot["co2_ppm"] = None
    pivot["sensor_id"] = None
    pivot["source"] = "openaq_v3"
    pivot["processed_at"] = datetime.now(timezone.utc).isoformat()

    return pivot[
        [
            "source", "city", "sensor_id", "pm25", "pm10", "co2_ppm",
            "aqi_value", "aqi_category", "health_risk", "latitude",
            "longitude", "recorded_at", "processed_at",
        ]
    ]


def calculate_aqi_value(pm25: float) -> float:
    breakpoints = [
        (0.0, 12.0, 0, 50), (12.1, 35.4, 51, 100), (35.5, 55.4, 101, 150),
        (55.5, 150.4, 151, 200), (150.5, 250.4, 201, 300), (250.5, 500.4, 301, 500),
    ]
    pm25 = max(0.0, min(pm25, 500.4))
    for c_lo, c_hi, i_lo, i_hi in breakpoints:
        if c_lo <= pm25 <= c_hi:
            return round(((i_hi - i_lo) / (c_hi - c_lo)) * (pm25 - c_lo) + i_lo, 1)
    return 500.0


# ---------------------------------------------------------------
# Load
# ---------------------------------------------------------------
def get_snowflake_connection():
    import snowflake.connector

    return snowflake.connector.connect(
        user=os.environ.get("SNOWFLAKE_USER"),
        password=os.environ.get("SNOWFLAKE_PASSWORD"),
        account=os.environ.get("SNOWFLAKE_ACCOUNT"),
        warehouse=os.environ.get("SNOWFLAKE_WAREHOUSE"),
        database="SMART_CITY_AQI",
        schema="CLEAN",
    )


def load_to_snowflake(df: pd.DataFrame):
    if df.empty:
        print("Nothing to load — clean dataframe is empty.")
        return

    conn = get_snowflake_connection()
    cursor = conn.cursor()
    try:
        df = df.copy()
        # Snowflake connector can't bind pandas Timestamp objects directly —
        # convert to plain ISO strings first (preserving nulls).
        df["recorded_at"] = df["recorded_at"].apply(lambda x: None if pd.isna(x) else str(x))
        df["processed_at"] = df["processed_at"].apply(lambda x: None if pd.isna(x) else str(x))

        records = df.to_dict("records")
        for record in records:
            for key, value in record.items():
                if pd.isna(value):
                    record[key] = None

        cursor.executemany(
            """
            INSERT INTO SMART_CITY_AQI.CLEAN.AQI_CLEAN
                (source, city, sensor_id, pm25, pm10, co2_ppm, aqi_value,
                 aqi_category, health_risk, latitude, longitude, recorded_at, processed_at)
            VALUES (%(source)s, %(city)s, %(sensor_id)s, %(pm25)s, %(pm10)s, %(co2_ppm)s,
                    %(aqi_value)s, %(aqi_category)s, %(health_risk)s, %(latitude)s,
                    %(longitude)s, %(recorded_at)s, %(processed_at)s)
            """,
            records,
        )
        conn.commit()
        print(f"Loaded {len(records)} rows into CLEAN.AQI_CLEAN")
    finally:
        cursor.close()
        conn.close()


def run(use_snowflake: bool):
    def safe_read_csv(path):
        if not os.path.exists(path):
            return pd.DataFrame()
        try:
            return pd.read_csv(path, encoding="utf-8")
        except UnicodeDecodeError:
            # Fallback for CSVs written with a non-UTF-8 system default encoding
            return pd.read_csv(path, encoding="latin1")

    iot_raw = safe_read_csv(IOT_CSV)
    openaq_raw = safe_read_csv(OPENAQ_CSV)

    print(f"Loaded {len(iot_raw)} raw IoT rows, {len(openaq_raw)} raw OpenAQ rows.")

    iot_clean = transform_iot(iot_raw)
    openaq_clean = transform_openaq(openaq_raw)

    combined = pd.concat([iot_clean, openaq_clean], ignore_index=True)
    combined.to_csv(CLEAN_CSV, index=False)
    print(f"Wrote {len(combined)} cleaned rows to {CLEAN_CSV}")

    if use_snowflake:
        load_to_snowflake(combined)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Smart City AQI ETL pipeline")
    parser.add_argument("--no-snowflake", action="store_true", help="Transform only, skip Snowflake load")
    args = parser.parse_args()

    run(use_snowflake=not args.no_snowflake)