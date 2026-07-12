"""
Smart City AQI — Stage 4: Streamlit Dashboard
================================================
Queries Snowflake's Gold (ANALYTICS.CITY_DAILY) and Silver
(CLEAN.AQI_CLEAN) layers to power decision-maker visuals.

Run:
    streamlit run dashboard.py
"""

import os

import pandas as pd
import snowflake.connector
import streamlit as st
from dotenv import load_dotenv

load_dotenv()

st.set_page_config(page_title="Smart City AQI — Pakistan", layout="wide")

SEVERITY_COLORS = {
    "GOOD": "🟢",
    "MODERATE": "🟢",
    "UNHEALTHY FOR SENSITIVE": "🟡",
    "UNHEALTHY": "🔴",
    "VERY UNHEALTHY": "🔴",
    "HAZARDOUS": "🟣",
}

RISK_COLORS = {"LOW": "🟢", "MEDIUM": "🟡", "HIGH": "🔴", "CRITICAL": "🟣"}


@st.cache_resource
def get_connection():
    return snowflake.connector.connect(
        user=os.environ.get("SNOWFLAKE_USER"),
        password=os.environ.get("SNOWFLAKE_PASSWORD"),
        account=os.environ.get("SNOWFLAKE_ACCOUNT"),
        warehouse=os.environ.get("SNOWFLAKE_WAREHOUSE"),
        database="SMART_CITY_AQI",
    )


@st.cache_data(ttl=30)
def load_city_daily() -> pd.DataFrame:
    conn = get_connection()
    return pd.read_sql(
        "SELECT * FROM SMART_CITY_AQI.ANALYTICS.CITY_DAILY ORDER BY report_date DESC", conn
    )


@st.cache_data(ttl=30)
def load_clean_recent(hours: int = 6) -> pd.DataFrame:
    conn = get_connection()
    return pd.read_sql(
        f"""
        SELECT *
        FROM SMART_CITY_AQI.CLEAN.AQI_CLEAN
        WHERE recorded_at >= DATEADD(hour, -{hours}, CURRENT_TIMESTAMP())
        ORDER BY recorded_at DESC
        """,
        conn,
    )


st.title("🇵🇰 Smart City Air Quality Monitoring — Pakistan")
st.caption("Bronze → Silver → Gold pipeline · IoT sensors + OpenAQ V3 reference data")

try:
    daily_df = load_city_daily()
    clean_df = load_clean_recent()
except Exception as e:
    st.error(f"Could not query Snowflake: {e}")
    st.stop()

if daily_df.empty:
    st.warning("No data in ANALYTICS.CITY_DAILY yet. Run the simulator, fetcher, and ETL pipeline first.")
    st.stop()

today_df = daily_df[daily_df["REPORT_DATE"] == daily_df["REPORT_DATE"].max()]

# ---------------------------------------------------------------
# Metric cards
# ---------------------------------------------------------------
col1, col2, col3 = st.columns(3)

highest_city_row = today_df.loc[today_df["AVG_AQI"].idxmax()] if not today_df.empty else None
total_readings = int(today_df["READING_COUNT"].sum()) if not today_df.empty else 0
critical_pct = (
    round(100 * (clean_df["HEALTH_RISK"] == "CRITICAL").mean(), 1) if not clean_df.empty else 0.0
)

with col1:
    st.metric(
        "Highest AQI City",
        highest_city_row["CITY"] if highest_city_row is not None else "N/A",
        f"{highest_city_row['AVG_AQI']:.0f} AQI" if highest_city_row is not None else "",
    )
with col2:
    st.metric("Total Readings Today", f"{total_readings:,}")
with col3:
    st.metric("% CRITICAL Readings (6h)", f"{critical_pct}%")

st.divider()

# ---------------------------------------------------------------
# Bar chart — average AQI per city today
# ---------------------------------------------------------------
st.subheader("Average AQI per City — Today")
st.bar_chart(today_df.set_index("CITY")["AVG_AQI"])

# ---------------------------------------------------------------
# Line chart — AQI trend per sensor, last 6 hours
# ---------------------------------------------------------------
st.subheader("AQI Trend by Sensor — Last 6 Hours")
if not clean_df.empty:
    trend = clean_df.dropna(subset=["SENSOR_ID"]).copy()
    if not trend.empty:
        trend["RECORDED_AT"] = pd.to_datetime(trend["RECORDED_AT"])
        pivot = trend.pivot_table(index="RECORDED_AT", columns="SENSOR_ID", values="AQI_VALUE")
        st.line_chart(pivot)
    else:
        st.info("No sensor-level readings in the last 6 hours yet.")
else:
    st.info("No recent readings available.")

# ---------------------------------------------------------------
# Color-coded severity table
# ---------------------------------------------------------------
st.subheader("Recent Readings — Severity Badges")
if not clean_df.empty:
    display_df = clean_df.head(50).copy()
    display_df["BADGE"] = display_df["HEALTH_RISK"].map(RISK_COLORS).fillna("⚪")
    st.dataframe(
        display_df[
            ["BADGE", "SOURCE", "CITY", "SENSOR_ID", "PM25", "AQI_VALUE", "AQI_CATEGORY", "HEALTH_RISK", "RECORDED_AT"]
        ],
        use_container_width=True,
        hide_index=True,
    )
else:
    st.info("No readings to display yet.")

st.caption("Auto-refreshes every 30 seconds · Data source: IoT simulator + OpenAQ V3")