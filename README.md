# 🐾 HiroSumi System – Smart Stray Cat Shelter 🍓🍵

HiroSumi is an IoT-based automated shelter system designed to provide a safe, climate-controlled, and comfortable environment for stray cats. The system seamlessly integrates MicroPython hardware control with a full-stack web dashboard developed using JSP, Servlets, and MySQL.

The project is affectionately named after a beloved cat, Chihiro (shortened to **Hiro**).

---

# 📖 Project Overview

**HiroSumi System** bridges the gap between hardware engineering and web development to create a smart, responsive animal shelter. It replaces static, manual pet houses with an intelligent environment that reacts to real-time weather and occupancy data.

This digital and physical solution provides:

- 🌡️ Automated climate control using a 5V heating pad and ventilation fan
- 🐾 Real-time occupancy tracking via a PIR motion sensor
- 📊 Live environmental monitoring (Temperature, Humidity, Pressure) utilizing a BME280 sensor
- 🍓 A visually pleasing *Strawberry Matcha* themed web dashboard for remote monitoring and API control
- ☁️ Cloud synchronization pushing data to a Java API and ThingSpeak

---

# 🎯 Purpose of the System

- ✅ **Automated Comfort (Hysteresis)**  
  Intelligently toggles a heater when the temperature drops and a fan when it gets too hot or humid, preventing the actuators from constantly fighting each other.

- 💡 **Smart Energy & Lighting**  
  Automatically activates a soft LED strip when motion is detected during defined night-mode hours and safely turns off after 30 seconds of inactivity.

- 🧾 **Remote Monitoring**  
  Allows administrators and technicians to view live status, historical graphs, and system uptime without physically checking the shelter.

- 🛠️ **Dynamic Configuration**  
  Enables over-the-air updates to temperature thresholds and schedules directly from the web dashboard.

---

# 👥 Developer & Responsibilities

| Name | Modules Responsibility | Role & Responsibility |
|------|-------------------------|------------------------|
| Siti Fikriyah Binti I.R Abdul Khawi | IoT Hardware, Web Backend, UI/UX Dashboard | Full-Stack & IoT Developer – MicroPython, JSP, Java API |

---

# ⚙️ Technologies Used

## Hardware (IoT Segment)

- Raspberry Pi Pico (MicroPython)
- BME280 Sensor (Temperature, Humidity, Pressure)
- PIR Motion Sensor
- 5V Relays
- 5V Heating Pad
- 5V Fan
- LED Strip
- I2C 20x4 LCD Screen

## Software (Web & Cloud Segment)

- Java (JDK 17)
- JSP (JavaServer Pages)
- Java Servlets
- HTML, CSS, JavaScript
- Chart.js
- MySQL
- Apache Tomcat
- ThingSpeak API

---

# ✨ Features

## 🛡️ Technician / Admin Panel

- 🔐 Secure login with credential verification
- 🎛️ **System Override**  
  Directly update heater/fan thresholds and night mode schedules via the API

- 📈 **Analytics Dashboard**  
  View historical environment trends (Temperature, Humidity, Pressure) with Strawberry Matcha themed graphs

- 📝 **System Logs**  
  Track connectivity and API uptime

---

## 🐾 Automated Shelter (Hardware)

- 🌡️ Self-regulates temperature based on Java API rules
- 👁️ “Cat Found” memory system that logs occupancy
- 📱 Offline 20x4 LCD diagnostic dashboard for local monitoring
- 📡 Non-blocking data uploads every 20 seconds without interrupting sensor readings

---

## 📱 Dashboard UI

- 🔔 Telegram integration for instant status reports
- 🎨 “Live Atmosphere” cards with intelligent comfort calculations (e.g., *Perfectly Cozy*)
- ⏱️ Live system uptime clock and heartbeat animations

---

# 📃 License

This project was developed as a Final Year Project for academic purposes at Universiti Malaysia Terengganu (UMT).

No commercial license is provided.

---

# ❤️ Acknowledgement

Special inspiration for this project comes from a beloved cat named **Chihiro (Hiro)**, whose name lives on through the HiroSumi System.
