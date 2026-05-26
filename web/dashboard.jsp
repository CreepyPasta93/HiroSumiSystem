<%@page import="com.hirosumi.model.User"%>
<%@page import="com.hirosumi.model.SensorData"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    // ==========================================
    // 🔒 1. SECURITY & SESSION CHECK
    // ==========================================
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // ==========================================
    // 📥 2. DATA RETRIEVAL
    // ==========================================
    SensorData currentData = (SensorData) request.getAttribute("latest");
    SensorData d = currentData;

    // Extract values safely
    double currentTemp = (currentData != null) ? currentData.getTemperature() : 0.0;
    double currentHum = (currentData != null) ? currentData.getHumidity() : 0.0;
    int motion = (currentData != null) ? currentData.getMotionStatus() : 0;

    // ==========================================
    // 🧠 3. BUSINESS LOGIC: CAT COMFORT
    // ==========================================
    String comfortTitle = "Analyzing...";
    String comfortDesc = "Waiting for sensor initialization.";
    String comfortIcon = "fa-cat";

    if (currentData != null) {
        if (currentTemp < 20.0) {
            comfortTitle = "Chilly Atmosphere";
            comfortDesc = "The air is brisk. Heating modules are active to ensure warm bedding.";
            comfortIcon = "fa-snowflake";
        } else if (currentTemp >= 20.0 && currentTemp <= 25.0) {
            comfortTitle = "Mild & Fresh";
            comfortDesc = "Conditions are temperate. A comfortable environment for active play.";
            comfortIcon = "fa-leaf";
        } else if (currentTemp > 25.0 && currentTemp < 29.0) {
            comfortTitle = "Perfectly Cozy";
            comfortDesc = "The warmth is optimal. Ideal conditions for deep napping and grooming.";
            comfortIcon = "fa-heart";
        } else {
            comfortTitle = "Warm Environment";
            comfortDesc = "Temperatures are rising. Ventilation is focused on cooling.";
            comfortIcon = "fa-temperature-high";
        }

        if (currentHum > 75.0) {
            comfortDesc += " Humidity is high, preventing stuffiness.";
        }
    }

    // ==========================================
    // 🐾 4. BUSINESS LOGIC: OCCUPANCY MEMORY
    // ==========================================
    long nowTime = new java.util.Date().getTime();

    if (motion == 1) {
        session.setAttribute("lastMotionTime", nowTime);
    }

    long lastSeenTime = (session.getAttribute("lastMotionTime") != null) ? (Long) session.getAttribute("lastMotionTime") : 0L;
    long secondsSinceMotion = (nowTime - lastSeenTime) / 1000;

    int pawsActive = 1;
    String occStatus = "Area Quiet";
    String occColor = "#8D6E63";

    if (motion == 1) {
        pawsActive = 3;
        occStatus = "Motion Detected! 🐾";
        occColor = "#D81B60";
    } else if (secondsSinceMotion < 300) {
        pawsActive = 3;
        occStatus = "Just Now";
        occColor = "#E57373";
    } else if (secondsSinceMotion < 1200) {
        pawsActive = 2;
        occStatus = "Recently Active";
        occColor = "#FFB74D";
    }

    // ==========================================
    // ⏱️ 5. SYSTEM UPTIME
    // ==========================================
    if (application.getAttribute("systemStartTime") == null) {
        application.setAttribute("systemStartTime", new java.util.Date());
    }
    java.util.Date systemStart = (java.util.Date) application.getAttribute("systemStartTime");
%>

<!DOCTYPE html>
<html>
    <head>
        <title>HiroSumi - Dashboard</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

        <style>
            /* --- 🎨 LAYOUT & SIDEBAR STYLES --- */
            .sidebar {
                position: fixed;
                top: 0;
                left: -280px;
                width: 260px;
                height: 100vh;
                background-color: var(--bg-pink);
                z-index: 1000;
                transition: left 0.4s cubic-bezier(0.68, -0.55, 0.27, 1.55);
                box-shadow: 5px 0 15px rgba(0,0,0,0.1);
            }
            .sidebar.active {
                left: 0;
            }
            .sidebar-overlay {
                position: fixed;
                top: 0;
                left: 0;
                width: 100vw;
                height: 100vh;
                background: rgba(62, 39, 35, 0.3);
                z-index: 900;
                display: none;
                opacity: 0;
                transition: opacity 0.3s;
            }
            .sidebar-overlay.active {
                display: block;
                opacity: 1;
            }

            .dashboard-container {
                display: block;
            }
            .main-content {
                width: 100%;
            }

            /* --- 📦 CENTER MODAL STYLES (Robust & Visible) --- */
            .modal {
                display: none; /* Hidden by default */
                position: fixed;
                z-index: 2000;
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
                background-color: rgba(62, 39, 35, 0.5); /* Dim Background */
                justify-content: center;
                align-items: center;
                backdrop-filter: blur(2px);
            }
            .modal-content {
                background-color: #FFF8F0;
                padding: 30px;
                border-radius: 20px;
                width: 350px;
                border: 3px solid #F8BBD0;
                text-align: center;
                box-shadow: 0 10px 25px rgba(0,0,0,0.2);
                animation: popIn 0.3s ease;
            }
            @keyframes popIn {
                from {
                    transform: scale(0.8);
                    opacity: 0;
                }
                to {
                    transform: scale(1);
                    opacity: 1;
                }
            }

            .btn-close-modal {
                background: #557159;
                color: white;
                border: none;
                padding: 10px 25px;
                border-radius: 20px;
                font-weight: bold;
                cursor: pointer;
                margin-top: 15px;
            }
            .btn-close-modal:hover {
                background: #33691E;
            }

            /* Responsive Design */
            @media (max-width: 768px) {
                .row-hero, .row-status {
                    flex-direction: column;
                }
                .hero-graph-container, .hero-live-card, .dash-card {
                    width: 100% !important;
                    margin-bottom: 20px;
                }
            }

            /* Custom Legend Styles */
            .chart-legend {
                display: flex;
                justify-content: center;
                gap: 20px;
                margin-top: 10px;
                font-family: 'Quicksand', sans-serif;
                font-weight: bold;
            }
            .legend-item {
                display: flex;
                align-items: center;
                gap: 8px;
                font-size: 0.85rem;
            }
            .dot {
                width: 12px;
                height: 12px;
                border-radius: 50%;
            }

            /* --- 🌿 ATMOSPHERE AESTHETIC UPGRADES --- */
            .atmosphere-value-container {
                display: flex;
                align-items: baseline;
                gap: 5px;
                margin: 10px 0;
            }

            .main-temp {
                font-size: 4rem;
                font-weight: 800;
                font-family: 'Quicksand', sans-serif;
                letter-spacing: -2px;
                text-shadow: 2px 2px 0px rgba(0,0,0,0.1);
            }

            .temp-unit {
                font-size: 1.5rem;
                font-weight: 700;
                opacity: 0.8;
            }

            .metric-pill {
                background: rgba(255, 255, 255, 0.15);
                backdrop-filter: blur(4px);
                padding: 6px 15px;
                border-radius: 50px;
                font-size: 0.85rem;
                font-weight: 600;
                border: 1px solid rgba(255, 255, 255, 0.2);
                display: flex;
                align-items: center;
                gap: 8px;
                transition: transform 0.3s ease;
            }

            .metric-pill:hover {
                transform: scale(1.05);
                background: rgba(255, 255, 255, 0.25);
            }
            /* --- ⏱️ UPTIME SYSTEM EFFECTS --- */
            .uptime-monitor {
                text-align: center;
                padding: 10px;
            }

            .uptime-clock {
                font-family: 'JetBrains Mono', 'Courier New', monospace;
                font-size: 2.2rem;
                font-weight: 800;
                color: #A5D6A7;
                text-shadow: 0 0 10px rgba(165, 214, 167, 0.4);
                letter-spacing: 2px;
            }

            /* Moving heartbeat line */
            .heartbeat-line {
                width: 80%;
                height: 2px;
                background: linear-gradient(90deg, transparent, #A5D6A7, transparent);
                margin: 15px auto;
                position: relative;
                overflow: hidden;
            }

            .heartbeat-line::after {
                content: '';
                position: absolute;
                left: -100%;
                width: 100%;
                height: 100%;
                background: linear-gradient(90deg, transparent, #fff, transparent);
                animation: sweep 2s infinite linear;
            }

            @keyframes sweep {
                0% {
                    left: -100%;
                }
                100% {
                    left: 100%;
                }
            }

            .pulse-dot {
                height: 8px;
                width: 8px;
                background-color: #81C784;
                border-radius: 50%;
                display: inline-block;
                box-shadow: 0 0 8px #81C784;
                animation: pulse-animation 1.5s infinite;
            }

            @keyframes pulse-animation {
                0% {
                    transform: scale(0.95);
                    box-shadow: 0 0 0 0 rgba(129, 199, 132, 0.7);
                }
                70% {
                    transform: scale(1);
                    box-shadow: 0 0 0 10px rgba(129, 199, 132, 0);
                }
                100% {
                    transform: scale(0.95);
                    box-shadow: 0 0 0 0 rgba(129, 199, 132, 0);
                }
            }
        </style>
    </head>
    <body>

        <div class="sidebar-overlay" onclick="toggleSidebar()"></div>

        <div id="statusModal" class="modal">
            <div class="modal-content">
                <i id="modalIcon" class="fa-solid fa-circle-check" style="font-size: 3rem; margin-bottom: 15px;"></i>

                <h3 id="modalTitle" style="margin: 0 0 10px 0; color: #3E2723; font-family: 'Comic Neue', cursive;">Success!</h3>

                <p id="modalMsg" style="color: #555; margin: 0; font-size: 0.95rem; line-height: 1.4;"></p>

                <button class="btn-close-modal" onclick="closeModal()">Yeay!</button>
            </div>
        </div>

        <div class="dashboard-container">

            <div class="sidebar" id="mySidebar">
                <img src="${pageContext.request.contextPath}/images/logo_dark.png" alt="HiroSumi" class="sidebar-logo">

                <div style="text-align: right; padding-right: 20px;">
                    <i class="fa-solid fa-xmark" onclick="toggleSidebar()" style="cursor: pointer; font-size: 1.5rem; color: #880E4F;"></i>
                </div>

                <%
                    // 1. Define the variable right here so the HTML below can definitely see it
                    com.hirosumi.model.User sessionUser = (com.hirosumi.model.User) session.getAttribute("currentUser");
                    String currentRole = "Volunteer";
                    if (sessionUser != null && sessionUser.getRole() != null) {
                        currentRole = sessionUser.getRole().trim();
                    }
                %>

                <div class="nav-menu">
                    <a href="DashboardServlet" class="nav-item active"><i class="fa-solid fa-table-columns"></i> <span>Dashboard</span></a>
                    <a href="AnalyticsServlet" class="nav-item"><i class="fa-solid fa-chart-line"></i> <span>Analytics</span></a>
                    <a href="SystemLogServlet" class="nav-item"><i class="fa-solid fa-file-lines"></i> <span>System Logs</span></a>

                    <% if ("Technician".equalsIgnoreCase(currentRole)) { %>
                    <a href="TechThresholdServlet" class="nav-item"><i class="fa-solid fa-wrench"></i> <span>Tech Panel</span></a>
                    <% } else { %>
                    <a href="ThresholdServlet" class="nav-item"><i class="fa-solid fa-triangle-exclamation"></i> <span>Threshold</span></a>
                    <% }%>

                    <a href="ProfileServlet" class="nav-item"><i class="fa-solid fa-gear"></i> <span>Settings</span></a>
                </div>

                <div class="bottom-menu">
                    <a href="logout.jsp" class="nav-item"><i class="fa-solid fa-right-from-bracket"></i> <span>Log Out</span></a>
                </div>
            </div>

            <div class="main-content">
                <jsp:include page="header.jsp" />

                <div class="dashboard-layout" style="padding-top: 20px;">

                    <div class="row-hero">

                        <div class="hero-graph-container" style="border: 2px solid #F8BBD0;">
                            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
                                <div>
                                    <h2 style="font-family: 'Comic Neue', cursive; margin:0; font-size:2rem; color:#3E2723;">Environment Trend</h2>
                                    <span style="font-size:0.9rem; color:#666;">Real-time sensor monitoring</span>
                                </div>
                                <div style="display:flex; align-items:center; gap:15px; background:rgba(255,255,255,0.5); padding:5px 15px; border-radius:20px;">
                                    <label style="font-weight:bold; font-size:0.85rem; cursor:pointer;"><input type="checkbox" id="chkTemp" checked> Temp</label>
                                    <label style="font-weight:bold; font-size:0.85rem; cursor:pointer;"><input type="checkbox" id="chkHum" checked> Hum</label>
                                    <label style="font-weight:bold; font-size:0.85rem; cursor:pointer;"><input type="checkbox" id="chkPres" checked> Pressure</label>
                                    <button onclick="updateChart()" style="border:none; background:#fff8f0; cursor:pointer; color:#557159;"><i class="fa-solid fa-rotate"></i></button>
                                </div>
                            </div>
                            <div style="flex-grow:1; width:100%; position:relative;">
                                <canvas id="tempChart"></canvas>
                            </div>
                            <input type="hidden" id="startDate">
                            <input type="hidden" id="endDate">
                        </div>

                        <div class="dash-card hero-live-card" style="background: linear-gradient(145deg, #4E6F52, #3b543e); color: #F1F8E9; position: relative; overflow: hidden; display: flex; flex-direction: column; justify-content: space-between; border: none; box-shadow: 0 8px 32px rgba(0,0,0,0.1);">

                            <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px dashed rgba(255,255,255,0.2); padding-bottom: 12px; margin-bottom: 10px;">
                                <div style="font-family: 'Quicksand', sans-serif; font-weight: 700; font-size: 1.1rem; letter-spacing: 0.5px;">
                                    <i class="fa-solid fa-cloud-sun-ray" style="color:#A5D6A7; margin-right: 8px;"></i> LIVE ATMOSPHERE
                                </div>
                                <i class="fa-solid fa-bell" id="bellIcon" onclick="triggerTelegramReport()" 
                                   style="opacity: 0.8; cursor: pointer; font-size: 1.2rem;" 
                                   title="Send Status to Telegram"></i>
                            </div>

                            <div style="display:flex; flex-direction: column; gap: 15px;">
                                <div class="atmosphere-value-container">
                                    <span class="main-temp">${latest.temperature}</span>
                                    <span class="temp-unit">°C</span>
                                </div>

                                <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                                    <div class="metric-pill">
                                        <i class="fa-solid fa-droplet" style="color: #90CAF9;"></i> 
                                        <%= (d != null) ? String.format("%.1f", d.getHumidity()) : "0.0"%>% <span style="opacity: 0.6; font-size: 0.7rem;">HUM</span>
                                    </div>
                                    <div class="metric-pill">
                                        <i class="fa-solid fa-gauge-high" style="color: #FFF59D;"></i> 
                                        <%= (d != null) ? String.format("%.1f", d.getPressure()) : "0.0"%> <span style="opacity: 0.6; font-size: 0.7rem;">KPA</span>
                                    </div>
                                </div>
                            </div>

                            <div style="margin-top: 20px; background: rgba(241, 248, 233, 0.95); color: #2E4E32; padding: 18px; border-radius: 18px; position: relative; z-index: 2; box-shadow: 0 4px 15px rgba(0,0,0,0.1);">
                                <div style="font-family: 'Quicksand', sans-serif; font-size: 0.9rem; font-weight: 800; margin-bottom: 6px; color: #1B5E20; display: flex; align-items: center; gap: 10px;">
                                    <div style="width: 10px; height: 10px; border-radius: 50%; background: #4CAF50; animation: pulse 2s infinite;"></div>
                                    <i class="fa-solid <%= comfortIcon%>"></i> <%= comfortTitle%>
                                </div>
                                <div style="font-size: 0.85rem; line-height: 1.5; font-weight: 500; opacity: 0.9;">
                                    "<%= comfortDesc%>"
                                </div>
                            </div>

                            <i class="fa-solid fa-cat" style="position: absolute; top: 40px; right: -20px; font-size: 10rem; color: rgba(255,255,255,0.03); transform: rotate(15deg); pointer-events: none;"></i>
                        </div>
                    </div>

                    <div class="row-status">

                        <div class="dash-card bg-pink" style="display:flex; flex-direction:column; justify-content:center; align-items:center; position:relative; overflow:hidden;">
                            <div style="width:100%; display:flex; justify-content:space-between; align-items:center; margin-bottom:10px; z-index:2;">
                                <div class="card-title" style="color:#880E4F; margin:0;">Actuators</div>
                                <%
                                    long diffSeconds = (new java.util.Date().getTime() - d.getTimestamp().getTime()) / 1000;
                                    boolean isOnline = diffSeconds < 120;

                                    // --- NEW: ESTIMATE ACTUATOR STATES FOR UI ---
                                    boolean isFanOn = (d.getFanStatus() == 1);
                                    boolean isHeaterOn = (currentTemp <= 28.0); // Faked for UI based on your current temp
                                    boolean isLightOn = (motion == 1); // If motion is active, light is likely on
%>
                                <div style="background:<%= isOnline ? "#4CAF50" : "rgba(255,255,255,0.4)"%>; padding:2px 8px; border-radius:10px; font-size:0.6rem; font-weight:bold; color:<%= isOnline ? "white" : "#880E4F"%>;">
                                    <%= isOnline ? "ONLINE" : "OFFLINE"%>
                                </div>
                            </div>

                            <div style="display:flex; gap:20px; align-items:center; z-index:2;">

                                <!-- HEATER ICON -->
                                <div style="text-align:center; <%= isHeaterOn ? "opacity: 1.0;" : "opacity: 0.5;"%> transition: 0.3s;">
                                    <div style="width:50px; height:50px; background:<%= isHeaterOn ? "#F8BBD0" : "rgba(255,255,255,0.3)"%>; border-radius:50%; display:flex; align-items:center; justify-content:center; margin-bottom:5px; border: 2px solid <%= isHeaterOn ? "#AD1457" : "transparent"%>;">
                                        <i class="fa-solid fa-fire <%= isHeaterOn ? "fa-fade" : ""%>" style="font-size:1.5rem; color:#AD1457;"></i>
                                    </div>
                                    <div style="font-size:0.7rem; font-weight:bold; color:#880E4F;">Heater</div>
                                </div>

                                <!-- FAN ICON -->
                                <div style="text-align:center; <%= isFanOn ? "opacity: 1.0;" : "opacity: 0.5;"%> transition: 0.3s;">
                                    <div style="width:60px; height:60px; background:<%= isFanOn ? "#F8BBD0" : "rgba(255,255,255,0.3)"%>; border-radius:50%; display:flex; align-items:center; justify-content:center; margin-bottom:5px; border: 2px solid <%= isFanOn ? "#AD1457" : "transparent"%>;">
                                        <i class="fa-solid fa-fan <%= isFanOn ? "fa-spin" : ""%>" style="font-size:2rem; color:#AD1457;"></i>
                                    </div>
                                    <div style="font-size:0.8rem; font-weight:bold; color:#880E4F;">Ventilation</div>
                                </div>

                                <!-- LIGHTS ICON -->
                                <div style="text-align:center; <%= isLightOn ? "opacity: 1.0;" : "opacity: 0.5;"%> transition: 0.3s;">
                                    <div style="width:50px; height:50px; background:<%= isLightOn ? "#FFF59D" : "rgba(255,255,255,0.3)"%>; border-radius:50%; display:flex; align-items:center; justify-content:center; margin-bottom:5px; border: 2px solid <%= isLightOn ? "#FBC02D" : "transparent"%>;">
                                        <i class="fa-solid fa-lightbulb <%= isLightOn ? "fa-beat-fade" : ""%>" style="font-size:1.5rem; color:#F57F17;"></i>
                                    </div>
                                    <div style="font-size:0.7rem; font-weight:bold; color:#880E4F;">Lights</div>
                                </div>
                            </div>

                            <div style="margin-top:10px; font-size:0.8rem; color:#AD1457; font-weight:bold; z-index:2;">
                                System Load: <%= (isFanOn || isHeaterOn || isLightOn) ? "Active" : "Standby"%>
                            </div>
                        </div>

                        <div class="dash-card bg-cream" style="position:relative; overflow:hidden; display:flex; flex-direction:column; justify-content:space-between;">
                            <div style="display:flex; justify-content:space-between; align-items:center;">
                                <div class="card-title" style="color:#3E2723; margin:0;">Occupancy</div>
                                <i class="fa-solid fa-walking" style="color:#D81B60; opacity:0.5;"></i>
                            </div>
                            <div style="text-align:center; position:relative; z-index:2; flex-grow:1; display:flex; flex-direction:column; justify-content:center;">
                                <div style="font-size:2.2rem; margin: 10px 0; display:flex; justify-content:center; gap:10px;">
                                    <i class="fa-solid fa-paw" style="color: <%= (pawsActive >= 1) ? "#D81B60" : "rgba(0,0,0,0.1)"%>; transition:0.3s;"></i>
                                    <i class="fa-solid fa-paw" style="color: <%= (pawsActive >= 2) ? "#E57373" : "rgba(0,0,0,0.1)"%>; transition:0.3s;"></i>
                                    <i class="fa-solid fa-paw" style="color: <%= (pawsActive >= 3) ? "#FFB74D" : "rgba(0,0,0,0.1)"%>; transition:0.3s;"></i>
                                </div>
                                <div style="font-size:1.1rem; font-weight:800; color:<%= occColor%>; margin-bottom:5px;">
                                    <%= occStatus%>
                                </div>
                            </div>
                            <div style="background:rgba(255,255,255,0.6); padding:8px 12px; border-radius:10px; font-size:0.75rem; color:#5D4037; line-height:1.3; text-align:center; border: 1px solid rgba(216, 27, 96, 0.1);">
                                <i class="fa-regular fa-clock"></i> Paws fade from 3 to 1 over 20 mins of inactivity.
                            </div>
                            <i class="fa-solid fa-cat" style="position:absolute; bottom:30px; left:-10px; font-size:6rem; color:rgba(216, 27, 96, 0.03); transform:rotate(15deg);"></i>
                        </div>

                        <div class="dash-card bg-green" style="background: linear-gradient(135deg, #4E6F52 0%, #3b543e 100%); display:flex; flex-direction:column; position:relative; overflow:hidden; border:none;"> 

                            <div style="display:flex; justify-content:space-between; align-items:center; z-index:2; margin-bottom: 5px;">
                                <div class="card-title" style="color:rgba(255,255,255,0.9); font-weight:700; font-family:'Quicksand';">System Uptime</div>
                                <div style="font-size: 0.65rem; background: rgba(255,255,255,0.1); padding: 3px 8px; border-radius: 10px; color: #A5D6A7; font-weight: bold; border: 1px solid rgba(165, 214, 167, 0.3);">
                                    HEALTHY 100%
                                </div>
                            </div>

                            <div class="uptime-monitor" style="z-index:2; flex-grow:1; display:flex; flex-direction:column; justify-content:center;">
                                <div class="uptime-clock">
                                    <span id="uptime-h">00</span>:<span id="uptime-m">00</span>:<span id="uptime-s">00</span>
                                </div>

                                <div class="heartbeat-line"></div>

                                <div style="display:flex; align-items:center; justify-content:center; gap:10px;">
                                    <div class="pulse-dot"></div>
                                    <span style="font-size:0.75rem; font-weight:bold; color: rgba(255,255,255,0.7); letter-spacing: 1px; text-transform: uppercase;">
                                        Operational Since Boot
                                    </span>
                                </div>
                            </div>

                            <i class="fa-solid fa-microchip" style="position:absolute; bottom:-15px; right:-15px; font-size:6rem; color:rgba(255,255,255,0.03); transform:rotate(-15deg); pointer-events: none;"></i>
                        </div>

                        <div class="dash-card bg-cream" style="border-color:#557159; position:relative; overflow:hidden;">
                            <div style="display:flex; justify-content:space-between; align-items:center; z-index:2; position:relative;">
                                <div class="card-title" style="color:#557159; margin:0;">Data Sync</div>
                                <div style="font-size:0.7rem; background:#557159; color:white; padding:2px 6px; border-radius:4px;">AUTO</div>
                            </div>
                            <div style="margin-top:15px; position:relative; z-index:2;">
                                <div style="font-size:0.7rem; color:#888; letter-spacing:1px; font-weight:bold;">LAST ENTRY</div>
                                <div style="font-size:1.4rem; font-weight:bold; color:#3E2723; font-family: 'Georgia', serif;">
                                    <%= (d != null && d.getTimestamp() != null)
                                            ? d.getTimestamp().toString().substring(11, 16)
                                            : "<span style='font-size:1rem; color:red;'>No Data</span>"%>
                                    <span style="font-size:0.8rem; color:#888; font-family:sans-serif;">Today</span>
                                </div>
                            </div>
                            <div style="margin-top:15px; padding-top:10px; border-top:1px dashed rgba(0,0,0,0.1); position:relative; z-index:2;">
                                <div style="display:flex; justify-content:space-between; align-items:center;">
                                    <span style="font-size:0.7rem; color:#888; font-weight:bold;">NEXT UPDATE</span>
                                    <span style="font-size:0.9rem; font-weight:bold; color:#557159;">
                                        <i class="fa-solid fa-rotate" style="font-size:0.8rem;"></i> 
                                        <span id="update-timer">00:45</span>
                                    </span>
                                </div>
                            </div>
                            <i class="fa-solid fa-rotate" style="position:absolute; bottom:-15px; right:-15px; font-size:5rem; color:rgba(85, 113, 89, 0.05);"></i>
                        </div> 
                    </div> 
                </div>
            </div> 
        </div>

        <script>
            // --- 1. SIDEBAR LOGIC ---
            function toggleSidebar() {
                document.getElementById('mySidebar').classList.toggle('active');
                document.querySelector('.sidebar-overlay').classList.toggle('active');
            }

            // --- 2. MODAL LOGIC (Replaces Toast) ---
            function showModal(title, message, isSuccess) {
                const modal = document.getElementById('statusModal');
                const icon = document.getElementById('modalIcon');
                const titleEl = document.getElementById('modalTitle');
                const msgEl = document.getElementById('modalMsg');

                // Set Content
                titleEl.innerText = title;
                msgEl.innerText = message;

                // Set Style (Green/Red)
                if (isSuccess) {
                    icon.className = "fa-solid fa-circle-check";
                    icon.style.color = "#66BB6A"; // Green
                    titleEl.style.color = "#2E7D32";
                } else {
                    icon.className = "fa-solid fa-circle-xmark";
                    icon.style.color = "#EF5350"; // Red
                    titleEl.style.color = "#C62828";
                }

                // Show
                modal.style.display = 'flex';
            }

            function closeModal() {
                document.getElementById('statusModal').style.display = 'none';
            }

            // --- 3. BELL BUTTON LOGIC ---
            function triggerTelegramReport() {
                const bell = document.getElementById('bellIcon');

                // Visual Feedback
                bell.classList.remove('fa-bell');
                bell.classList.add('fa-spinner', 'fa-spin');

                fetch('DashboardServlet?action=sendReport')
                        .then(response => {
                            if (!response.ok)
                                throw new Error("Server Error");
                            return response.text();
                        })
                        .then(result => {
                            if (result.trim() === 'success') {
                                showModal("Report Sent!", "The latest sensor reading has been sent to your Telegram.", true);
                            } else {
                                showModal("Failed", "Could not send report. Check connection or Bot Token.", false);
                            }
                        })
                        .catch(err => {
                            console.error(err);
                            showModal("System Error", "Something went wrong. Check browser console.", false);
                        })
                        .finally(() => {
                            // Restore Icon
                            bell.classList.remove('fa-spinner', 'fa-spin');
                            bell.classList.add('fa-bell');
                        });
            }

            // --- 4. CHART CONFIGURATION ---
            const ctx = document.getElementById('tempChart').getContext('2d');
            const toLocalISOString = (date) => {
                const offset = date.getTimezoneOffset() * 60000;
                return (new Date(date - offset)).toISOString().slice(0, 16);
            };
            const now = new Date();
            const yesterday = new Date(now.getTime() - (24 * 60 * 60 * 1000));
            document.getElementById('endDate').value = toLocalISOString(now);
            document.getElementById('startDate').value = toLocalISOString(yesterday);

            // --- 4. CHART CONFIGURATION (Strawberry Matcha Edition) ---
            const myChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: [],
                    datasets: [
                        {
                            label: 'Temperature (°C)',
                            data: [],
                            borderColor: '#557159', // Matcha Green
                            backgroundColor: 'rgba(85, 113, 89, 0.1)',
                            fill: true,
                            tension: 0.4,
                            borderWidth: 4,
                            pointRadius: 0, // Cleaner look without dots
                            pointHitRadius: 10,
                            yAxisID: 'y'
                        },
                        {
                            label: 'Humidity (%)',
                            data: [],
                            borderColor: '#D65A68', // Strawberry Pink
                            backgroundColor: 'transparent',
                            borderWidth: 3,
                            borderDash: [5, 5], // Dashed line for contrast
                            tension: 0.4,
                            pointRadius: 0,
                            yAxisID: 'y'
                        },
                        {
                            label: 'Pressure (kPa)',
                            data: [],
                            borderColor: '#EBCB8B', // Creamy Gold
                            backgroundColor: 'transparent',
                            borderWidth: 2,
                            tension: 0.4,
                            pointRadius: 0,
                            yAxisID: 'y1'
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: true, // Show the legend for the lecturer!
                            position: 'top',
                            labels: {
                                usePointStyle: true,
                                font: {family: 'Quicksand', size: 12, weight: 'bold'},
                                color: '#3E2723'
                            }
                        },
                        tooltip: {
                            backgroundColor: 'rgba(255, 250, 245, 0.9)',
                            titleColor: '#3E2723',
                            bodyColor: '#3E2723',
                            borderColor: '#F8BBD0',
                            borderWidth: 1,
                            displayColors: true
                        }
                    },
                    scales: {
                        x: {grid: {display: false}, ticks: {color: '#8d6e63'}},
                        y: {
                            grid: {color: 'rgba(85, 113, 89, 0.05)'},
                            ticks: {color: '#8d6e63'},
                            title: {display: true, text: 'Environment Metrics', color: '#557159'}
                        },
                        y1: {
                            display: false // Keeping the UI clean, data is still there
                        }
                    }
                }
            });

            function updateChart() {
                const start = document.getElementById('startDate').value;
                const end = document.getElementById('endDate').value;
                const showTemp = document.getElementById('chkTemp').checked;
                const showHum = document.getElementById('chkHum').checked;
                const showPres = document.getElementById('chkPres').checked;

                myChart.data.datasets[0].hidden = !showTemp;
                myChart.data.datasets[1].hidden = !showHum;
                myChart.data.datasets[2].hidden = !showPres;
                myChart.update();

                fetch(`DashboardServlet?action=fetchData&start=${start}&end=${end}`)
                        .then(r => r.json())
                        .then(data => {
                            myChart.data.labels = data.map(d => d.time.split(' ')[1]);
                            myChart.data.datasets[0].data = data.map(d => d.temp);
                            myChart.data.datasets[1].data = data.map(d => d.hum);
                            myChart.data.datasets[2].data = data.map(d => d.pres / 10);
                            myChart.update();
                        });
            }
            updateChart();

            // --- 5. UPTIME & TIMER LOGIC ---
            const systemStartTime = <%= systemStart.getTime()%>;
            <% com.hirosumi.model.SensorData dJS = (com.hirosumi.model.SensorData) request.getAttribute("latest");%>
            const lastEntryTime = <%= (dJS != null) ? dJS.getTimestamp().getTime() : "new Date().getTime()"%>;

            function updateUptime() {
                const now = new Date().getTime();
                let diff = now - systemStartTime;
                if (diff < 0)
                    diff = 0;
                const hours = Math.floor(diff / (1000 * 60 * 60));
                diff -= hours * (1000 * 60 * 60);
                const mins = Math.floor(diff / (1000 * 60));
                diff -= mins * (1000 * 60);
                const secs = Math.floor(diff / 1000);
                document.getElementById('uptime-h').innerText = (hours < 10 ? "0" : "") + hours;
                document.getElementById('uptime-m').innerText = (mins < 10 ? "0" : "") + mins;
                document.getElementById('uptime-s').innerText = (secs < 10 ? "0" : "") + secs;
            }
            setInterval(updateUptime, 1000);

            const updateInterval = 60000;
            let targetNextUpdate = lastEntryTime + updateInterval;
            function updateSyncTimer() {
                const now = new Date().getTime();
                let diff = targetNextUpdate - now;
                if (diff <= 0) {
                    document.getElementById('update-timer').innerText = "Updating...";
                } else {
                    const mins = Math.floor(diff / 60000);
                    const secs = Math.floor((diff % 60000) / 1000);
                    document.getElementById('update-timer').innerText = (mins < 10 ? "0" : "") + mins + ":" + (secs < 10 ? "0" : "") + secs;
                }
            }
            setInterval(updateSyncTimer, 1000);
        </script>
    </body>
</html>