# 🐾 HiroSumi System – Smart Stray Cat Shelter 🍓🍵

HiroSumi is an IoT-based smart stray cat shelter designed to provide a safer, more comfortable, and climate-aware environment for stray cats. The system combines real-time sensor monitoring, automated actuator control, AI-assisted environmental analysis, and a full-stack web dashboard developed using Java JSP, Servlets, MySQL, and MicroPython.

The project is affectionately named after a beloved cat, Chihiro, shortened to **Hiro**.

---

# 📖 Project Overview

The **HiroSumi System** bridges IoT hardware, web development, automation, and AI-assisted decision support to create an intelligent shelter environment. Instead of functioning as a static pet house, the shelter actively responds to environmental changes such as temperature, humidity, motion detection, and comfort conditions.

The system collects real-time data from sensors, stores readings in a database, controls actuators automatically, displays live and historical information through a web dashboard, sends Telegram notifications, and uses AI integration to generate meaningful environmental insights.

This digital and physical solution provides:

* 🌡️ Automated climate control using a 5V heating pad and ventilation fan
* 🐾 Real-time motion detection using a PIR sensor
* 📊 Live environmental monitoring for temperature, humidity, and pressure using a BME280 sensor
* 🤖 AI-assisted analysis using the Grok API to interpret sensor trends and generate shelter improvement suggestions
* 🔔 Telegram notifications for instant shelter status reports and alerts
* 🍓 A soft Strawberry Matcha themed dashboard for remote monitoring, analytics, and configuration
* 🛠️ Technician-controlled thresholds for heater, fan, lighting, and alert behaviour

---

# 🎯 Purpose of the System

* ✅ **Automated Comfort Control**
  Uses real-time environmental data to automatically control the heater and fan based on configured thresholds, helping maintain a more comfortable shelter condition for stray cats.

* 🌡️ **Hysteresis-Based Climate Logic**
  Prevents the heater and fan from constantly switching on and off by applying a stable threshold control logic suitable for a physical prototype environment.

* 🤖 **AI-Assisted Environmental Insight**
  Integrates the Grok API to analyse recent shelter data and generate useful summaries, heat trend observations, comfort analysis, and practical recommendations for improving the shelter condition.

* 💡 **Smart Lighting Behaviour**
  Activates the shelter light when motion is detected during night-mode hours and turns it off automatically after inactivity.

* 🔔 **Telegram Notification Support**
  Allows subscribed users to receive shelter status updates, alerts, and manual reports directly through Telegram.

* 🧾 **Remote Monitoring**
  Enables Volunteers and Technicians to view live sensor readings, historical graphs, system status, and shelter conditions without physically checking the prototype.

* 🛠️ **Dynamic Configuration**
  Allows Technicians to update temperature thresholds, humidity settings, lighting schedules, and actuator behaviour through the web dashboard.

---

# 👥 Developer & Responsibilities

| Name                                | Modules Responsibility                                                                      | Role & Responsibility                                                                      |
| ----------------------------------- | ------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| Siti Fikriyah Binti I.R Abdul Khawi | IoT Hardware, Web Backend, Dashboard UI/UX, Database, AI Integration, Telegram Notification | Full-Stack & IoT Developer – MicroPython, Java JSP/Servlets, MySQL, Grok API, Telegram Bot |

---

# ⚙️ Technologies Used

## Hardware / IoT Segment

* Raspberry Pi Pico W
* BME280 Sensor for temperature, humidity, and pressure
* PIR Motion Sensor
* 5V Relays
* 5V Heating Pad
* 5V Fan
* LED Strip
* I2C 20x4 LCD Screen

## Software / Web Segment

* Java JDK 17
* JSP JavaServer Pages
* Java Servlets
* HTML5, CSS3, JavaScript
* Chart.js
* MySQL
* Apache Tomcat
* JDBC
* BCrypt password hashing

## API & Integration

* Grok API for AI-assisted environmental analysis
* Telegram Bot API for alert notifications and status reports
* JavaMail for email verification and password reset
* ThingSpeak API for environmental data synchronization

---

# 🗂️ Project Structure
```text
HiroSumiSystem/
├── Web Pages/
│   ├── META-INF/
│   │
│   ├── Resources/
│   │
│   ├── WEB-INF/
│   │
│   ├── css/
│   │   └── analytics.css, dashboard-custom.css, dashboard.css,
│   │       hirosumi_theme.css, login.css, profile.css,
│   │       signup.css, style.css, systemlogs.css,
│   │       techpanel.css, threshold.css
│   │
│   ├── images/
│   │
│   ├── Profile.jsp
│   ├── ResetPassword.jsp
│   ├── analytics.jsp
│   ├── dashboard.jsp
│   ├── debug.jsp
│   ├── forceChangePassword.jsp
│   ├── header.jsp
│   ├── login.jsp
│   ├── logout.jsp
│   ├── sidebar.jsp
│   ├── signup.jsp
│   ├── systemlogs.jsp
│   ├── tech_threshold.jsp
│   └── threshold.jsp
│
├── Source Packages/
│   ├── com.hirosumi.controller/
│   │   └── AnalyticsServlet.java, ConfigApiServlet.java,
│   │       DashboardServlet.java, ForceChangePasswordServlet.java,
│   │       HandleNotificationServlet.java, LoginServlet.java,
│   │       LogoutServlet.java, ProfileServlet.java,
│   │       RegisterServlet.java, ResetPasswordServlet.java,
│   │       SubmitThresholdRequestServlet.java, SystemLogServlet.java,
│   │       TechThresholdServlet.java, TelegramConnectServlet.java,
│   │       ThingSpeakSyncServlet.java, ThresholdServlet.java,
│   │       UpdateUserRoleServlet.java, VerifyEmailServlet.java
│   │
│   ├── com.hirosumi.dao/
│   │   └── AnalyticsDAO.java, ConfigurationDAO.java,
│   │       DBConnection.java, NotificationLogDAO.java,
│   │       SystemLogDAO.java, TelegramSubscriberDAO.java,
│   │       UserDAO.java
│   │
│   ├── com.hirosumi.model/
│   │   └── Configuration.java, Notification.java,
│   │       NotificationLog.java, SensorData.java,
│   │       SystemLog.java, User.java
│   │
│   └── com.hirosumi.service/
│       └── EmailService.java, EnvironmentService.java,
│           GrokService.java, TelegramNotifier.java,
│           TelegramUpdateFetcher.java, ThingSpeakFetcher.java
│
└── README.md
```
---

# ✨ Main Features

## 🧑‍💻 Technician Dashboard

* 🔐 Secure technician login with password protection
* 🎛️ Configure heater, fan, lighting, humidity, and alert thresholds
* 📈 View environmental trends using interactive Chart.js graphs
* 🤖 Access AI-generated insights based on recent shelter readings
* 🔔 Send Telegram shelter status reports
* 📝 Monitor system logs and notification history
* 🧹 Manage stored sensor data when maintenance is needed

---

## 🙋 Volunteer Dashboard

* 📊 View live shelter temperature, humidity, pressure, and motion status
* 🐾 Monitor whether recent motion has been detected inside the shelter
* 🧾 Request threshold or configuration changes from the Technician
* 🔔 Receive useful shelter updates through Telegram subscription
* 👤 Manage profile information and account details

---

## 🐾 Automated Shelter Hardware

* 🌡️ Automatically controls the heater based on temperature readings
* 🌬️ Activates the fan when shelter conditions become too warm or humid
* 💡 Turns on the LED light during night mode when motion is detected
* 👁️ Uses PIR motion detection to identify possible cat presence
* 📟 Displays local diagnostic information using a 20x4 LCD screen
* 📡 Uploads sensor readings to the web system without interrupting hardware monitoring

---

## 🤖 AI & Analytics Module

* Generates AI-assisted summaries from recent sensor data
* Analyses temperature and humidity trends
* Provides comfort-related observations for the shelter environment
* Suggests practical actions such as checking ventilation, adjusting thresholds, or monitoring heat patterns
* Supports better decision-making for shelter maintenance and animal comfort

---

## 📱 Dashboard UI

* 🍓 Strawberry Matcha inspired interface with soft, clean visual styling
* 📊 Live atmosphere cards for temperature, humidity, pressure, and comfort status
* 📈 Historical graph visualization for environmental readings
* 🔔 Telegram integration for quick reports and alert notifications
* ⏱️ Live system status, uptime display, and recent motion indicators
* 📱 Responsive layout for desktop and mobile viewing

---

# 🗂️ System Roles

The HiroSumi System uses two main roles:

| Role       | Description                                                                                                     |
| ---------- | --------------------------------------------------------------------------------------------------------------- |
| Volunteer  | Can monitor shelter conditions, view readings, manage profile details, and request configuration changes        |
| Technician | Can manage system configuration, review logs, control thresholds, analyse data, and maintain the overall system |

---

# 📌 Project Status

This project was developed as a Final Year Project for the Bachelor of Computer Science Software Engineering programme at Universiti Malaysia Terengganu.

Current implemented modules include:

* IoT sensor monitoring
* Automated heater, fan, and lighting control
* Web dashboard
* Role-based login
* Threshold configuration
* Sensor data storage
* Chart-based analytics
* Grok AI insight generation
* Telegram notification integration
* Email verification and password reset
* System logs and notification history

---

# 📃 License

This project was developed for academic purposes as part of a Final Year Project at Universiti Malaysia Terengganu.

No commercial license is provided.

---

# ❤️ Acknowledgement

Special inspiration for this project comes from a beloved cat named **Chihiro**, also known as **Hiro**, whose name lives on through the HiroSumi System.
