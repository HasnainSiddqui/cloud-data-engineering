"""
Smart City AQI — Stage 1B: OpenAQ V3 Fetcher
=============================================
Pulls Pakistan monitoring station data from the OpenAQ V3 API and
writes it into RAW.OPENAQ_RAW (Snowflake) as well as a local CSV.

Setup:
    1. Register at https://explore.openaq.org/register
    2. Put your key in a .env file:  OPENAQ_API_KEY=your_key_here

Run:
    python openaq_fetcher.py
    python openaq_fetcher.py --no-snowflake   # CSV only, useful for testing
"""

import argparse
import csv
import os
import time
from datetime import datetime, timezone

import requests
from dotenv import load_dotenv

load_dotenv()

BASE_URL = "https://api.openaq.org/v3"
API_KEY = os.environ.get("OPENAQ_API_KEY")
CSV_PATH = "openaq_readings.csv"
RATE_LIMIT_SLEEP = 1  # seconds between calls, per spec (60/min limit)


def _headers():
    if not API_KEY:
        raise RuntimeError("OPENAQ_API_KEY not set. Add it to your .env file.")
    return {"X-API-Key": API_KEY}


def get_pakistan_locations(limit: int = 100) -> list[dict]:
    """Step 1 — GET /v3/locations?country_id=PK&limit=100"""
    resp = requests.get(
        f"{BASE_URL}/locations",
        headers=_headers(),
        params={"iso": "PK", "limit": limit},
        timeout=30,
    )
    resp.raise_for_status()
    results = resp.json().get("results", [])

    locations = []
    for loc in results:
        coords = loc.get("coordinates") or {}
        locations.append(
            {
                "location_id": loc.get("id"),
                "name": loc.get("name"),
                "city": loc.get("locality") or loc.get("name"),
                "latitude": coords.get("latitude"),
                "longitude": coords.get("longitude"),
            }
        )
    return locations


def get_location_sensors(location_id: int) -> list[dict]:
    """Step 2 — GET /v3/locations/{location_id}/sensors"""
    resp = requests.get(
        f"{BASE_URL}/locations/{location_id}/sensors",
        headers=_headers(),
        timeout=30,
    )
    resp.raise_for_status()
    results = resp.json().get("results", [])

    sensors = []
    for s in results:
        param = s.get("parameter") or {}
        sensors.append(
            {
                "sensor_id": s.get("id"),
                "parameter_name": param.get("name"),
                "parameter_units": param.get("units"),
            }
        )
    return sensors


def get_location_latest(location_id: int) -> list[dict]:
    """Step 3 — GET /v3/locations/{location_id}/latest"""
    resp = requests.get(
        f"{BASE_URL}/locations/{location_id}/latest",
        headers=_headers(),
        timeout=30,
    )
    resp.raise_for_status()
    return resp.json().get("results", [])


def get_sensor_measurements(sensor_id: int, date_from: str, date_to: str, limit: int = 100) -> list[dict]:
    """Step 4 (optional) — GET /v3/sensors/{sensor_id}/measurements"""
    resp = requests.get(
        f"{BASE_URL}/sensors/{sensor_id}/measurements",
        headers=_headers(),
        params={"date_from": date_from, "date_to": date_to, "limit": limit},
        timeout=30,
    )
    resp.raise_for_status()
    return resp.json().get("results", [])


def build_rows_for_location(location: dict) -> list[dict]:
    """Combine sensors + latest measurements into flat rows matching
    the V3 -> Snowflake field mapping in the spec."""
    rows = []

    sensors = get_location_sensors(location["location_id"])
    time.sleep(RATE_LIMIT_SLEEP)
    sensor_lookup = {s["sensor_id"]: s for s in sensors}

    latest = get_location_latest(location["location_id"])
    time.sleep(RATE_LIMIT_SLEEP)

    for entry in latest:
        sensor_id = entry.get("sensorsId") or entry.get("sensorId")
        sensor_meta = sensor_lookup.get(sensor_id, {})
        param_name = sensor_meta.get("parameter_name", "")

        # Only keep pm25 / pm10 / co2 per spec's pollutant scope
        if param_name not in ("pm25", "pm10", "co2"):
            continue

        dt = entry.get("datetime") or {}
        recorded_at = dt.get("utc") if isinstance(dt, dict) else dt

        rows.append(
            {
                "location_id": location["location_id"],
                "station_name": location["name"],
                "city": location["city"],
                "country_code": "PK",
                "latitude": location["latitude"],
                "longitude": location["longitude"],
                "pollutant_type": param_name,
                "pollutant_value": entry.get("value"),
                "unit": sensor_meta.get("parameter_units", ""),
                "recorded_at": recorded_at,
            }
        )
    return rows


def fetch_all_pakistan_data() -> list[dict]:
    locations = get_pakistan_locations()
    time.sleep(RATE_LIMIT_SLEEP)
    print(f"Found {len(locations)} OpenAQ locations in Pakistan.")

    all_rows = []
    for loc in locations:
        try:
            rows = build_rows_for_location(loc)
            all_rows.extend(rows)
            print(f"  {loc['name']} ({loc['city']}): {len(rows)} pollutant readings")
        except requests.HTTPError as e:
            print(f"  Skipping location {loc['location_id']} ({loc['name']}): {e}")
    return all_rows


def write_csv(rows: list[dict]):
    if not rows:
        print("No rows fetched — nothing written to CSV.")
        return
    with open(CSV_PATH, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)
    print(f"Wrote {len(rows)} rows to {CSV_PATH}")


def get_snowflake_connection():
    import snowflake.connector

    return snowflake.connector.connect(
        user=os.environ.get("SNOWFLAKE_USER"),
        password=os.environ.get("SNOWFLAKE_PASSWORD"),
        account=os.environ.get("SNOWFLAKE_ACCOUNT"),
        warehouse=os.environ.get("SNOWFLAKE_WAREHOUSE"),
        database="SMART_CITY_AQI",
        schema="RAW",
    )


def insert_to_snowflake(rows: list[dict]):
    if not rows:
        return
    conn = get_snowflake_connection()
    cursor = conn.cursor()
    try:
        cursor.executemany(
            """
            INSERT INTO SMART_CITY_AQI.RAW.OPENAQ_RAW
                (location_id, station_name, city, country_code, latitude, longitude,
                 pollutant_type, pollutant_value, unit, recorded_at)
            VALUES (%(location_id)s, %(station_name)s, %(city)s, %(country_code)s,
                    %(latitude)s, %(longitude)s, %(pollutant_type)s, %(pollutant_value)s,
                    %(unit)s, %(recorded_at)s)
            """,
            rows,
        )
        conn.commit()
        print(f"Inserted {len(rows)} rows into RAW.OPENAQ_RAW")
    finally:
        cursor.close()
        conn.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="OpenAQ V3 Pakistan fetcher")
    parser.add_argument("--no-snowflake", action="store_true", help="Skip Snowflake insert, write CSV only")
    args = parser.parse_args()

    data = fetch_all_pakistan_data()
    write_csv(data)

    if not args.no_snowflake:
        insert_to_snowflake(data)