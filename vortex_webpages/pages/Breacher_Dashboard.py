import streamlit as st
import requests
import pandas as pd
import plotly.express as px

# ---------------- PAGE CONFIG ----------------
st.set_page_config(page_title="Breacher Dashboard", layout="wide")

st.title("🛠️ Breacher Dashboard")
st.caption("Click a card to analyze data")
st.divider()

# ---------------- THINGSPEAK CONFIG ----------------
READ_KEY = st.secrets["BREACHER_READ_API_KEY"]
CHANNEL_ID = st.secrets["BREACHER_CHANNEL_ID"]

# ---------------- FETCH DATA ----------------
def fetch_data():
    url = f"https://api.thingspeak.com/channels/{CHANNEL_ID}/feeds.json?api_key={READ_KEY}&results=20"
    r = requests.get(url, timeout=10)
    if r.status_code == 200:
        return r.json().get("feeds", [])
    return []

data = fetch_data()

# ---------------- DATAFRAME ----------------
if data:
    df = pd.DataFrame(data)
    df["created_at"] = pd.to_datetime(df["created_at"])

    df["field1"] = pd.to_numeric(df["field1"], errors="coerce")  # Distance (cm)
    df["field2"] = pd.to_numeric(df["field2"], errors="coerce")  # Tilt (°)
    df["field3"] = pd.to_numeric(df["field3"], errors="coerce")  # Left Wheel RPM
    df["field4"] = pd.to_numeric(df["field4"], errors="coerce")  # Right Wheel RPM
    df["field5"] = pd.to_numeric(df["field5"], errors="coerce")  # Plow State
else:
    st.warning("⚠ No data received from ThingSpeak.")
    df = pd.DataFrame(columns=["created_at","field1","field2","field3","field4","field5"])

# ---------------- LATEST VALID ROW ----------------
df_valid = df.dropna(how="all", subset=["field1","field2","field3","field4","field5"])
latest = None if df_valid.empty else df_valid.iloc[-1]

# ---------------- SESSION STATE ----------------
if "selected" not in st.session_state:
    st.session_state.selected = None

# ---------------- CARDS (5 ONLY) ----------------
c1, c2, c3, c4, c5 = st.columns(5)

with c1:
    with st.container(border=True):
        st.markdown("### 📏 Distance")
        if st.button("View Distance", key="btn_distance"):
            st.session_state.selected = "distance"

with c2:
    with st.container(border=True):
        st.markdown("### 📐 Tilt")
        if st.button("View Tilt", key="btn_tilt"):
            st.session_state.selected = "tilt"

with c3:
    with st.container(border=True):
        st.markdown("### Left Wheel")
        if st.button("View Left Wheel", key="btn_left"):
            st.session_state.selected = "left"

with c4:
    with st.container(border=True):
        st.markdown("### Right Wheel")
        if st.button("View Right Wheel", key="btn_right"):
            st.session_state.selected = "right"

with c5:
    with st.container(border=True):
        st.markdown("### 🛠 Plow")
        if st.button("View Plow", key="btn_plow"):
            st.session_state.selected = "plow"

st.divider()

# ---------------- DETAILS ----------------
if latest is None:
    st.warning("No valid sensor data available yet.")
    st.stop()

# ---------- DISTANCE ----------
if st.session_state.selected == "distance":
    value = latest["field1"]
    st.metric("Distance", "No Data" if pd.isna(value) else f"{value} cm")

    if pd.isna(value):
        st.warning("Distance sensor not available.")
    elif value < 20:
        st.error("🚨 Obstacle very close!")
    elif value < 50:
        st.warning("⚠ Obstacle nearby.")
    else:
        st.success("✅ Path is clear.")

    fig = px.line(df, x="created_at", y="field1", template="plotly_dark")
    st.plotly_chart(fig, use_container_width=True)

# ---------- TILT ----------
elif st.session_state.selected == "tilt":
    value = latest["field2"]
    st.metric("Tilt Angle", "No Data" if pd.isna(value) else f"{value} °")

    if pd.isna(value):
        st.warning("Tilt sensor not available.")
    elif value > 35:
        st.error("🚨 Risk of tipping!")
    elif value > 20:
        st.warning("⚠ Uneven terrain detected.")
    else:
        st.success("✅ Robot stable.")

    fig = px.line(df, x="created_at", y="field2", template="plotly_dark")
    st.plotly_chart(fig, use_container_width=True)

# ---------- LEFT WHEEL ----------
elif st.session_state.selected == "left":
    value = latest["field3"]
    st.metric("Left Wheel Speed", "No Data" if pd.isna(value) else f"{value} RPM")

    fig = px.line(df, x="created_at", y="field3", template="plotly_dark")
    st.plotly_chart(fig, use_container_width=True)

# ---------- RIGHT WHEEL ----------
elif st.session_state.selected == "right":
    value = latest["field4"]
    st.metric("Right Wheel Speed", "No Data" if pd.isna(value) else f"{value} RPM")

    fig = px.line(df, x="created_at", y="field4", template="plotly_dark")
    st.plotly_chart(fig, use_container_width=True)

# ---------- PLOW ----------
elif st.session_state.selected == "plow":
    value = latest["field5"]

    if pd.isna(value):
        st.metric("Plow State", "No Data")
        st.warning("Plow status not available.")
    else:
        status = "DEPLOYED" if value == 1 else "RETRACTED"
        st.metric("Plow State", status)

        if value == 1:
            st.success("🛠 Plow deployed.")
        else:
            st.info("Plow retracted.")
