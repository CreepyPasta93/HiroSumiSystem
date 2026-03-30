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

                        <div class="dash-card hero-live-card" style="background: #4E6F52; color: #F1F8E9; position: relative; overflow: hidden; display: flex; flex-direction: column; justify-content: space-between;">

                            <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(255,255,255,0.2); padding-bottom: 10px; margin-bottom: 15px;">
                                <div style="font-family: 'Georgia', serif; font-size: 1.1rem; letter-spacing: 1px; font-style: italic;">
                                    <i class="fa-solid fa-seedling" style="color:#A5D6A7;"></i> Current Atmosphere
                                </div>
                                <i class="fa-solid fa-bell" id="bellIcon" onclick="triggerTelegramReport()" 
                                   style="opacity: 0.9; cursor: pointer; transition: transform 0.2s;" 
                                   title="Send Status to Telegram"></i>
                            </div>

                            <div style="display:flex; align-items: center; gap: 20px;">
                                <div style="font-size: 3.5rem; font-weight: 700; font-family: 'Helvetica', sans-serif;">
                                    ${latest.temperature}°
                                </div>
                                <div style="display: flex; flex-direction: column; justify-content: center; gap: 8px;">
                                    <div style="background: rgba(255,255,255,0.15); padding: 4px 12px; border-radius: 20px; font-size: 0.85rem;">
                                        💧 <%= (d != null) ? String.format("%.2f", d.getHumidity()) : "0.00"%>% Hum
                                    </div>
                                    <div style="background: rgba(255,255,255,0.15); padding: 4px 12px; border-radius: 20px; font-size: 0.85rem;">
                                        ⏲ <%= (d != null) ? String.format("%.2f", d.getPressure()) : "0.00"%> kPa
                                    </div>
                                </div>
                            </div>

                            <div style="margin-top: 15px; background: #F1F8E9; color: #2E4E32; padding: 15px; border-radius: 12px; border-left: 5px solid #A5D6A7; box-shadow: 0 4px 6px rgba(0,0,0,0.1); z-index: 2;">
                                <div style="font-family: 'Georgia', serif; font-size: 1.0rem; font-weight: bold; margin-bottom: 5px; color: #1B5E20; text-transform: uppercase; letter-spacing: 1px;">
                                    <i class="fa-solid <%= comfortIcon%>"></i> <%= comfortTitle%>
                                </div>
                                <div style="font-size: 0.9rem; line-height: 1.4; font-family: 'Georgia', serif; font-style: italic;">
                                    "<%= comfortDesc%>"
                                </div>
                            </div>
                            <i class="fa-solid fa-leaf" style="position: absolute; bottom: -20px; right: -20px; font-size: 8rem; color: rgba(255,255,255,0.05); transform: rotate(-20deg); pointer-events: none;"></i>
                        </div>
                    </div>

                    <div class="row-status">

                        <div class="dash-card bg-pink" style="display:flex; flex-direction:column; justify-content:center; align-items:center; position:relative; overflow:hidden;">
                            <div style="width:100%; display:flex; justify-content:space-between; align-items:center; margin-bottom:10px; z-index:2;">
                                <div class="card-title" style="color:#880E4F; margin:0;">Actuators</div>
                                <%
                                    long diffSeconds = (new java.util.Date().getTime() - d.getTimestamp().getTime()) / 1000;
                                    boolean isOnline = diffSeconds < 120;
                                %>
                                <div style="background:<%= isOnline ? "#4CAF50" : "rgba(255,255,255,0.4)"%>; padding:2px 8px; border-radius:10px; font-size:0.6rem; font-weight:bold; color:<%= isOnline ? "white" : "#880E4F"%>;">
                                    <%= isOnline ? "ONLINE" : "OFFLINE"%>
                                </div>
                            </div>

                            <div style="display:flex; gap:20px; align-items:center; z-index:2;">
                                <div style="text-align:center; opacity: 0.5;">
                                    <div style="width:50px; height:50px; background:rgba(255,255,255,0.3); border-radius:50%; display:flex; align-items:center; justify-content:center; margin-bottom:5px;">
                                        <i class="fa-solid fa-fire" style="font-size:1.5rem; color:#AD1457;"></i>
                                    </div>
                                    <div style="font-size:0.7rem; font-weight:bold; color:#880E4F;">Heater</div>
                                </div>

                                <div style="text-align:center;">
                                    <div style="width:60px; height:60px; background:<%= (d.getFanStatus() == 1) ? "#F8BBD0" : "rgba(255,255,255,0.3)"%>; border-radius:50%; display:flex; align-items:center; justify-content:center; margin-bottom:5px; border: 2px solid <%= (d.getFanStatus() == 1) ? "#AD1457" : "transparent"%>;">
                                        <i class="fa-solid fa-fan <%= (d.getFanStatus() == 1) ? "fa-spin" : ""%>" style="font-size:2rem; color:#AD1457;"></i>
                                    </div>
                                    <div style="font-size:0.8rem; font-weight:bold; color:#880E4F;">Ventilation</div>
                                </div>

                                <div style="text-align:center; opacity: 0.5;">
                                    <div style="width:50px; height:50px; background:rgba(255,255,255,0.3); border-radius:50%; display:flex; align-items:center; justify-content:center; margin-bottom:5px;">
                                        <i class="fa-regular fa-lightbulb" style="font-size:1.5rem; color:#AD1457;"></i>
                                    </div>
                                    <div style="font-size:0.7rem; font-weight:bold; color:#880E4F;">Lights</div>
                                </div>
                            </div>

                            <div style="margin-top:10px; font-size:0.8rem; color:#AD1457; font-weight:bold; z-index:2;">
                                Status: <%= (d.getFanStatus() == 1) ? "Running" : "Standby"%>
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

                        <div class="dash-card bg-green" style="background-color:#4E6F52; display:flex; flex-direction:column; position:relative; overflow:hidden;"> 
                            <div class="card-title" style="color:white; z-index:2;">System Uptime</div>
                            <div style="flex-grow:1; display:flex; flex-direction:column; justify-content:center; align-items:center; z-index:2;">
                                <div style="background:rgba(0,0,0,0.2); padding:5px 15px; border-radius:20px; font-family:monospace; font-size:1.5rem; font-weight:bold; letter-spacing:2px; color:#A5D6A7; margin-bottom:10px; border:1px solid rgba(255,255,255,0.1);">
                                    <span id="uptime-h">00</span>:<span id="uptime-m">00</span>:<span id="uptime-s">00</span>
                                </div>
                                <div style="display:flex; align-items:center; justify-content:center; gap:8px;">
                                    <div class="pulse-dot"></div>
                                    <span style="font-size:0.7rem; font-weight:bold; color: rgba(255,255,255,0.8);">SINCE BOOT</span>
                                </div>
                            </div>
                            <i class="fa-regular fa-clock" style="position:absolute; top:-10px; right:-10px; font-size:5rem; color:rgba(255,255,255,0.05); transform:rotate(20deg);"></i>
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

            const myChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: [],
                    datasets: [
                        {label: 'Temp (°C)', data: [], borderColor: '#4E6F52', backgroundColor: 'rgba(78, 111, 82, 0.1)', fill: true, tension: 0.4, borderWidth: 3, pointRadius: 4, pointBackgroundColor: '#fff', yAxisID: 'y'},
                        {label: 'Hum (%)', data: [], borderColor: '#D81B60', backgroundColor: 'transparent', borderWidth: 2, tension: 0.4, pointRadius: 4, pointBackgroundColor: '#fff', yAxisID: 'y'},
                        {label: 'Pressure (kPa)', data: [], borderColor: '#FBC02D', backgroundColor: 'transparent', borderWidth: 2, tension: 0.4, pointRadius: 4, pointBackgroundColor: '#fff', yAxisID: 'y1', hidden: false}
                    ]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: {legend: {display: false}},
                    scales: {
                        x: {grid: {display: false}, ticks: {maxTicksLimit: 8, color: '#888'}},
                        y: {grid: {color: 'rgba(0,0,0,0.05)'}, ticks: {color: '#888'}, position: 'left', title: {display: true, text: 'Temp / Hum'}},
                        y1: {grid: {display: false}, position: 'right', display: 'auto', title: {display: true, text: 'Pressure (kPa)'}, suggestedMin: 98, suggestedMax: 102}
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