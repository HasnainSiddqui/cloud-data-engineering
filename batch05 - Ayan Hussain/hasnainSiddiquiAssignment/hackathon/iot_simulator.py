"""
Smart City AQI — Stage 1A: IoT Sensor Simulator
=================================================
Simulates 10 IoT air-quality sensors across 5 Pakistani cities.
Every 10 seconds, generates one reading per sensor, prints
UNHEALTHY/HAZARDOUS readings to console, appends to a local CSV,
and inserts directly into Snowflake RAW.IOT_READINGS.

Run:
    python iot_simulator.py                 # runs forever
    python iot_simulator.py --minutes 30    # runs for 30 minutes then stops
"""

import argparse
import csv
import math
import os
import random
import time
from datetime import datetime, timezone

from dotenv import load_dotenv

load_dotenv()

CSV_PATH = "iot_readings.csv"

# ---------------------------------------------------------------
# Sensor network (from spec)
# ---------------------------------------------------------------
SENSORS = [
    {"sensor_id": "PKS_KHI_IND_01", "city": "Karachi",    "zone_type": "industrial"},
    {"sensor_id": "PKS_KHI_TRF_02", "city": "Karachi",    "zone_type": "traffic"},
    {"sensor_id": "PKS_LHR_RES_01", "city": "Lahore",     "zone_type": "residential"},
    {"sensor_id": "PKS_LHR_IND_02", "city": "Lahore",     "zone_type": "industrial"},
    {"sensor_id": "PKS_ISB_PRK_01", "city": "Islamabad",  "zone_type": "park"},
    {"sensor_id": "PKS_ISB_TRF_02", "city": "Islamabad",  "zone_type": "traffic"},
    {"sensor_id": "PKS_PEW_IND_01", "city": "Peshawar",   "zone_type": "industrial"},
    {"sensor_id": "PKS_PEW_RES_02", "city": "Peshawar",   "zone_type": "residential"},
    {"sensor_id": "PKS_MUL_TRF_01", "city": "Multan",     "zone_type": "traffic"},
    {"sensor_id": "PKS_MUL_PRK_02", "city": "Multan",     "zone_type": "park"},
]

# Zone-based base ranges: (pm25_lo, pm25_hi, co2_lo, co2_hi, temp_lo, temp_hi)
ZONE_BASES = {
    "industrial":  {"pm25": (80, 120), "co2": (600, 900), "temp": (30, 42)},
    "traffic":     {"pm25": (55, 80),  "co2": (500, 700), "temp": (28, 40)},
    "residential": {"pm25": (25, 50),  "co2": (420, 500), "temp": (25, 38)},
    "park":        {"pm25": (8, 20),   "co2": (400, 430), "temp": (22, 35)},
}

# EPA AQI breakpoints: (C_lo, C_hi, I_lo, I_hi, severity)
AQI_BREAKPOINTS = [
    (0.0, 12.0, 0, 50, "GOOD"),
    (12.1, 35.4, 51, 100, "MODERATE"),
    (35.5, 55.4, 101, 150, "UNHEALTHY FOR SENSITIVE"),
    (55.5, 150.4, 151, 200, "UNHEALTHY"),
    (150.5, 250.4, 201, 300, "VERY UNHEALTHY"),
    (250.5, 500.4, 301, 500, "HAZARDOUS"),
]


def calculate_aqi(pm25: float):
    """EPA standard AQI calculation from PM2.5. Returns (aqi_value, severity)."""
    pm25 = max(0.0, min(pm25, 500.4))
    for c_lo, c_hi, i_lo, i_hi, severity in AQI_BREAKPOINTS:
        if c_lo <= pm25 <= c_hi:
            aqi = ((i_hi - i_lo) / (c_hi - c_lo)) * (pm25 - c_lo) + i_lo
            return round(aqi, 1), severity
    # above scale -> cap at HAZARDOUS max
    return 500.0, "HAZARDOUS"


def time_of_day_multiplier(hour: int) -> float:
    """Peaks at 8am and 6pm per spec."""
    return 1.0 + 0.3 * math.sin((hour - 8) * math.pi / 12)


def generate_reading(sensor: dict) -> dict:
    zone = sensor["zone_type"]
    base = ZONE_BASES[zone]
    hour = datetime.now().hour
    tod_mult = time_of_day_multiplier(hour)

    def noisy(lo, hi):
        val = random.uniform(lo, hi) * tod_mult
        noise = val * random.uniform(-0.15, 0.15)
        return val + noise

    pm25 = noisy(*base["pm25"])

    # 15% chance of anomaly spike
    if random.random() < 0.15:
        pm25 *= random.uniform(2.5, 4.0)
    pm25 = round(max(0.0, min(pm25, 500.0)), 2)

    pm10 = round(max(pm25, pm25 * random.uniform(1.1, 1.6)), 2)
    pm10 = min(pm10, 600.0)

    co2_ppm = round(max(400.0, min(noisy(*base["co2"]), 2000.0)), 2)
    temperature_c = round(max(15.0, min(noisy(*base["temp"]), 45.0)), 2)
    humidity_pct = round(random.uniform(10, 90), 2)
    wind_speed_kmh = round(random.uniform(0, 60), 2)

    aqi_value, severity = calculate_aqi(pm25)

    return {
        "sensor_id": sensor["sensor_id"],
        "city": sensor["city"],
        "zone_type": zone,
        "pm25": pm25,
        "pm10": pm10,
        "co2_ppm": co2_ppm,
        "temperature_c": temperature_c,
        "humidity_pct": humidity_pct,
        "wind_speed_kmh": wind_speed_kmh,
        "aqi_value": aqi_value,
        "severity": severity,
        "recorded_at": datetime.now(timezone.utc).isoformat(),
    }


def ensure_csv_header():
    if not os.path.exists(CSV_PATH):
        with open(CSV_PATH, "w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=list(generate_reading(SENSORS[0]).keys()))
            writer.writeheader()


def append_to_csv(readings: list[dict]):
    with open(CSV_PATH, "a", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=list(readings[0].keys()))
        writer.writerows(readings)


def get_snowflake_connection():
    """Lazily import + connect so the script still runs (CSV-only) without snowflake creds."""
    import snowflake.connector

    return snowflake.connector.connect(
        user=os.environ.get("SNOWFLAKE_USER"),
        password=os.environ.get("SNOWFLAKE_PASSWORD"),
        account=os.environ.get("SNOWFLAKE_ACCOUNT"),
        warehouse=os.environ.get("SNOWFLAKE_WAREHOUSE"),
        database="SMART_CITY_AQI",
        schema="RAW",
    )


def insert_to_snowflake(conn, readings: list[dict]):
    cursor = conn.cursor()
    try:
        cursor.executemany(
            """
            INSERT INTO SMART_CITY_AQI.RAW.IOT_READINGS
                (sensor_id, city, zone_type, pm25, pm10, co2_ppm,
                 temperature_c, humidity_pct, wind_speed_kmh, aqi_value,
                 severity, recorded_at)
            VALUES (%(sensor_id)s, %(city)s, %(zone_type)s, %(pm25)s, %(pm10)s,
                    %(co2_ppm)s, %(temperature_c)s, %(humidity_pct)s,
                    %(wind_speed_kmh)s, %(aqi_value)s, %(severity)s, %(recorded_at)s)
            """,
            readings,
        )
        conn.commit()
    finally:
        cursor.close()


def run(minutes: int | None, use_snowflake: bool):
    ensure_csv_header()
    conn = get_snowflake_connection() if use_snowflake else None

    start = time.time()
    print(f"Starting IoT simulator — {len(SENSORS)} sensors, 1 reading/10s each.")
    print(f"CSV output: {CSV_PATH}" + (" | Snowflake: RAW.IOT_READINGS" if use_snowflake else " | Snowflake: disabled"))

    try:
        while True:
            batch = [generate_reading(s) for s in SENSORS]

            for r in batch:
                if r["severity"] in ("UNHEALTHY", "VERY UNHEALTHY", "HAZARDOUS"):
                    print(
                        f"[ALERT] {r['recorded_at']} {r['sensor_id']} ({r['city']}) "
                        f"PM2.5={r['pm25']} AQI={r['aqi_value']} -> {r['severity']}"
                    )

            append_to_csv(batch)
            if conn is not None:
                insert_to_snowflake(conn, batch)

            if minutes is not None and (time.time() - start) >= minutes * 60:
                print("Requested run duration reached. Stopping.")
                break

            time.sleep(10)
    except KeyboardInterrupt:
        print("\nStopped by user.")
    finally:
        if conn is not None:
            conn.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Smart City AQI IoT simulator")
    parser.add_argument("--minutes", type=float, default=None, help="Run for N minutes then stop (default: run forever)")
    parser.add_argument("--no-snowflake", action="store_true", help="Skip Snowflake insert, write CSV only")
    args = parser.parse_args()

    run(minutes=args.minutes, use_snowflake=not args.no_snowflake)