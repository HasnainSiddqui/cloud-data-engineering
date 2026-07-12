# Smart City Air Quality Monitoring System

End-to-end data pipeline for Pakistan air quality: IoT simulation → OpenAQ V3
reference data → Python ETL → Snowflake Bronze/Silver/Gold → Streamlit dashboard.

## Architecture

```
IoT Simulator ──┐
                 ├──► Bronze (RAW) ──► ETL (Pandas) ──► Silver (CLEAN) ──► SQL agg ──► Gold (ANALYTICS) ──► Streamlit
OpenAQ V3 API ───┘
```

## 1. Setup

```bash
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env            # then fill in your keys/credentials
```

Get an OpenAQ API key (free): register at https://explore.openaq.org/register,
copy the key from account settings, and put it in `.env` as `OPENAQ_API_KEY`.

## 2. Create the Snowflake schema

Open a Snowflake worksheet and run the entire script:

```
sql/01_schema.sql
```

This creates `SMART_CITY_AQI` with `RAW` (Bronze), `CLEAN` (Silver), and
`ANALYTICS` (Gold) schemas, plus the Gold aggregation query. Re-run the
`INSERT INTO ... CITY_DAILY` block at the bottom any time you want to refresh
Gold from the latest Silver data (after running the ETL).

## 3. Run the IoT simulator

```bash
python iot_simulator.py --minutes 30
```

Generates readings for 10 sensors every 10 seconds, prints UNHEALTHY/HAZARDOUS
alerts to the console, appends to `iot_readings.csv`, and inserts into
`RAW.IOT_READINGS`. Use `--no-snowflake` to test with CSV output only.

## 4. Fetch OpenAQ reference data

```bash
python openaq_fetcher.py
```

Pulls Pakistan monitoring stations, their sensors, and latest measurements,
writes `openaq_readings.csv`, and inserts into `RAW.OPENAQ_RAW`.

## 5. Run the ETL pipeline

```bash
python etl_pipeline.py
```

Reads both CSVs, cleans/validates/deduplicates with Pandas, computes AQI
category + health risk, writes `aqi_clean.csv`, and loads into
`CLEAN.AQI_CLEAN` (Silver).

## 6. Refresh the Gold layer

Re-run the `TRUNCATE` + `INSERT INTO ANALYTICS.CITY_DAILY` block from
`sql/01_schema.sql` in Snowflake to recompute daily aggregates from the
latest Silver data.

## 7. Launch the dashboard

```bash
streamlit run dashboard.py
```

Shows: average AQI per city (bar chart), AQI trend per sensor over the last
6 hours (line chart), metric cards (highest AQI city, total readings,
% CRITICAL), and a color-coded severity table. Auto-refreshes every 30s.

## Files

| File | Purpose |
|---|---|
| `sql/01_schema.sql` | Snowflake DB/schema/table DDL + Gold aggregation SQL |
| `iot_simulator.py` | Simulates 10 IoT sensors across 5 cities |
| `openaq_fetcher.py` | Pulls real AQI data from OpenAQ V3 |
| `etl_pipeline.py` | Cleans, validates, and loads both sources into Silver |
| `dashboard.py` | Streamlit dashboard on top of Gold/Silver |
| `.env.example` | Template for API keys and Snowflake credentials |

## Notes

- OpenAQ coverage in Pakistan is concentrated in Karachi and Lahore; the
  fetcher uses whatever stations the API returns and tags all rows
  `country_code = PK`.
- All scripts fall back gracefully to CSV-only mode with `--no-snowflake` for
  local testing without live Snowflake credentials.