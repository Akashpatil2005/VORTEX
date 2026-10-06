import streamlit as st
import requests
import pandas as pd
import plotly.express as px

# ---------------- PAGE CONFIG ----------------
st.set_page_config(page_title="Scout Dashboard", layout="wide")

st.title("🚀 Scout Dashboard")
st.caption("Click a card to analyze data")
st.divider()

# ---------------- DEFAULT VALUES ----------------
defaults = {
    "field1": 0,    # Distance (cm)
    "field2": 0,    # MPU Tilt
    "field3": 0,    # Gas MQ135
    "field4": 0,    # Sound Level
    "field5": 0,    # PIR Motion
    "field6": 25,   # Temperature (°C)
    "field7": 60,   # Humidity (%)
    "field8": 0     # Human Detected
}

# ---------------- THINGSPEAK CONFIG ----------------
READ_KEY = st.secrets["SCOUT_READ_API_KEY"]
CHANNEL_ID = st.secrets["SCOUT_CHANNEL_ID"]

# ---------------- FETCH DATA ----------------
def fetch_data():
    url = f"https://api.thingspeak.com/channels/{CHANNEL_ID}/feeds.json?api_key={READ_KEY}&results=20"
    try:
        r = requests.get(url, timeout=10)
        if r.status_code == 200:
            return r.json().get("feeds", [])
    except Exception:
        pass
    return []

data = fetch_data()

# ---------------- DATAFRAME ----------------
if data:
    df = pd.DataFrame(data)
    df["created_at"] = pd.to_datetime(df["created_at"])

    # Clean & convert all sensor fields safely
    for k in defaults:
        df[k] = pd.to_numeric(
            df[k].astype(str).str.strip(),
            errors="coerce"
        )

    # Sensor scaling fixes
    if df["field6"].max() > 100:
        df["field6"] = df["field6"] / 10   # Temperature

    if df["field7"].max() > 100:
        df["field7"] = df["field7"] / 10   # Humidity

else:
    df = pd.DataFrame({
        "created_at": pd.date_range(end=pd.Timestamp.now(), periods=10),
        **{k: [v] * 10 for k, v in defaults.items()}
    })

latest = df.iloc[-1]

# ---------------- SESSION STATE ----------------
if "selected" not in st.session_state:
    st.session_state.selected = "distance"

# ---------------- CARDS ----------------
labels = [
    ("📏 Distance", "distance"),
    ("📐 MPU Tilt", "tilt"),
    ("🧪 Gas MQ135", "gas"),
    ("🔊 Sound Level", "sound"),
    ("🚶 PIR Motion", "pir"),
    ("🌡 Temperature", "temp"),
    ("💧 Humidity", "hum"),
    ("🧍 Human Detected", "human"),
]

cols = st.columns(4)
for i, (name, key) in enumerate(labels):
    with cols[i % 4]:
        with st.container(border=True):
            st.markdown(f"### {name}")
            if st.button("Analyze", key=f"btn_{key}"):
                st.session_state.selected = key

st.divider()

# ---------------- DETAIL VIEW ----------------
def show(field, unit, ok_msg, warn_msg, condition):
    value = latest[field]
    display = "No Data" if pd.isna(value) else f"{value:.1f} {unit}"
    st.metric(field.upper(), display)

    if pd.isna(value):
        st.warning("Sensor data not available.")
    elif condition:
        st.success(ok_msg)
    else:
        st.warning(warn_msg)

    fig = px.line(df, x="created_at", y=field, template="plotly_dark")
    st.plotly_chart(fig, use_container_width=True)

# ---------------- DETAILS ----------------
if st.session_state.selected == "distance":
    show("field1", "cm", "Path is clear.", "Obstacle nearby!", latest["field1"] > 50)

elif st.session_state.selected == "tilt":
    show("field2", "°", "Rover stable.", "Rover tilted!", abs(latest["field2"]) < 30)

elif st.session_state.selected == "gas":
    show("field3", "", "Air quality safe.", "Gas detected!", latest["field3"] < 300)

elif st.session_state.selected == "sound":
    show("field4", "", "Sound level normal.", "Loud noise detected!", latest["field4"] < 5)

elif st.session_state.selected == "pir":
    show("field5", "", "No motion.", "Motion detected!", latest["field5"] == 0)

elif st.session_state.selected == "temp":
    show("field6", "°C", "Temperature safe.", "High temperature!", latest["field6"] <= 30)

elif st.session_state.selected == "hum":
    show("field7", "%", "Humidity normal.", "High humidity!", latest["field7"] <= 80)

elif st.session_state.selected == "human":
    value = latest["field8"]
    status = "YES" if value == 1 else "NO"
    st.metric("HUMAN DETECTED", status)

    if value == 1:
        st.error("🚨 Human detected!")
    else:
        st.success("✅ No human detected.")
