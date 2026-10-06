import streamlit as st
from PIL import Image

# ---------------- PAGE CONFIG ----------------
st.set_page_config(
    page_title="VORTEX Rover Control Center",
    layout="wide"
)

# ---------------- TITLE ----------------
st.title("🛰️ VORTEX Rover Monitoring System")
st.caption("Select a rover to open its live monitoring dashboard")
st.divider()

# ---------------- IMAGE RESIZE FUNCTION ----------------
def resize_image(img, target_height=260):
    w, h = img.size
    ratio = target_height / h
    new_w = int(w * ratio)
    return img.resize((new_w, target_height))

# ---------------- LOAD & RESIZE IMAGES ----------------
breacher_img = resize_image(Image.open("assets/breacher.png"))
scout_img = resize_image(Image.open("assets/scout.png"))

# ---------------- TWO MAIN CONTAINERS ----------------
col1, col2 = st.columns(2, gap="large")

# ================= BREACHER =================
with col1:
    with st.container(border=True):

        st.image(breacher_img)

        st.markdown(
            """
            <div style="text-align:center;">
                <h3>🛠️ BREACHER ROVER</h3>
                <p>Heavy rescue & breaching operations</p>
            </div>
            """,
            unsafe_allow_html=True
        )

        if st.button(
            "Open Breacher Dashboard",
            key="open_breacher",
            use_container_width=True
        ):
            st.switch_page("pages/Breacher_Dashboard.py")

# ================= SCOUT =================
with col2:
    with st.container(border=True):

        st.image(scout_img)

        st.markdown(
            """
            <div style="text-align:center;">
                <h3>🚀 SCOUT ROVER</h3>
                <p>Reconnaissance & surveillance unit</p>
            </div>
            """,
            unsafe_allow_html=True
        )

        if st.button(
            "Open Scout Dashboard",
            key="open_scout",
            use_container_width=True
        ):
            st.switch_page("pages/Scout_Dashboard.py")
