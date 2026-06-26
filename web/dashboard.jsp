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

    // Force technician/default account to change password first
    if (currentUser.isMustChangePassword()) {
        response.sendRedirect("forceChangePassword.jsp");
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
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard-custom.css">
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/favicon.png">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    </head>
    <body>

        <button class="sidebar-open-btn" onclick="toggleSidebar()">
            <i class="fa-solid fa-bars"></i>
        </button>

        <div class="sidebar-overlay" onclick="toggleSidebar()"></div>

        <div id="statusModal" class="modal">
            <div class="modal-content cute-status-modal">

                <button class="modal-x-btn" onclick="closeModal()" type="button">
                    <i class="fa-solid fa-xmark"></i>
                </button>

                <div class="modal-deco modal-strawberry">🍓</div>
                <div class="modal-deco modal-paw">🐾</div>

                <div class="modal-cat-bubble">
                    <i id="modalIcon" class="fa-solid fa-circle-check"></i>
                </div>

                <h3 id="modalTitle">Report Sent!</h3>

                <p id="modalMsg">
                    The latest sensor reading has been sent to your Telegram.
                </p>

                <div class="modal-mini-note">
                    <i class="fa-solid fa-cat"></i>
                    <span>HiroSumi is keeping the shelter updated.</span>
                </div>

                <button class="btn-close-modal" onclick="closeModal()" type="button">
                    Yeay! <span>♡</span>
                </button>
            </div>
        </div>

        <div id="notificationPanel" class="notification-panel">
            <div class="notification-panel-header">
                <div>
                    <h3>Notifications 🐾</h3>
                    <p>Latest Telegram history</p>
                </div>
                <button type="button" onclick="toggleNotificationPanel()">
                    <i class="fa-solid fa-xmark"></i>
                </button>
            </div>

            <div id="notificationList" class="notification-list">
                <div class="notification-empty">
                    Loading notifications...
                </div>
            </div>
        </div>

        <div class="dashboard-container">
            <% request.setAttribute("activePage", "dashboard");%>
            <jsp:include page="sidebar.jsp" />

            <div class="main-content">
                <jsp:include page="header.jsp" />

                <div class="dashboard-layout">

                    <div class="row-hero">

                        <div class="hero-graph-container" style="border: 2px solid #F8BBD0;">
                            <div class="graph-header">
                                <div class="graph-title-box">
                                    <h2>Environment Trend</h2>
                                    <span>Real-time sensor monitoring</span>
                                </div>

                                <div class="graph-controls">
                                    <label><input type="checkbox" id="chkTemp" checked> Temp</label>
                                    <label><input type="checkbox" id="chkHum" checked> Hum</label>
                                    <label><input type="checkbox" id="chkPres" checked> Pressure</label>
                                    <button onclick="updateChart()" type="button">
                                        <i class="fa-solid fa-rotate"></i>
                                    </button>
                                </div>
                            </div>

                            <div class="chart-box">
                                <canvas id="tempChart"></canvas>
                            </div>

                            <input type="hidden" id="startDate">
                            <input type="hidden" id="endDate">
                        </div>

                        <!-- Live Atmosphere Card -->
                        <div class="dash-card hero-live-card live-atmosphere-card">
                            <div class="live-atmosphere-header">
                                <div>
                                    <h3>Live Atmosphere</h3>
                                    <p>Current environment at a glance</p>
                                </div>
                            </div>

                            <div class="live-atmosphere-main">
                                <div class="atmosphere-value-container">
                                    <span class="main-temp">${latest.temperature}</span>
                                    <span class="temp-unit">°C</span>
                                </div>

                                <div class="live-metric-row">
                                    <div class="metric-pill">
                                        <i class="fa-solid fa-droplet" style="color: #90CAF9;"></i> 
                                        <%= (d != null) ? String.format("%.1f", d.getHumidity()) : "0.0"%>% 
                                        <span>HUM</span>
                                    </div>

                                    <div class="metric-pill">
                                        <i class="fa-solid fa-gauge-high" style="color: #FFF59D;"></i> 
                                        <%= (d != null) ? String.format("%.1f", d.getPressure()) : "0.0"%> 
                                        <span>KPA</span>
                                    </div>
                                </div>
                            </div>

                            <div class="comfort-card">
                                <div class="comfort-title">
                                    <span class="comfort-dot"></span>
                                    <i class="fa-solid <%= comfortIcon%>"></i>
                                    <span><%= comfortTitle%></span>
                                </div>

                                <div class="comfort-desc">
                                    "<%= comfortDesc%>"
                                </div>
                            </div>

                            <img 
                                src="${pageContext.request.contextPath}/images/cat-live-atmosphere.png" 
                                alt="Sleeping cat"
                                class="live-cat-img"
                                >
                        </div>
                    </div>

                    <div class="row-status">

                        <!-- Actuator Card -->
                        <div class="dash-card actuator-card">

                            <%
                                boolean hasData = (d != null && d.getTimestamp() != null);

                                long diffSeconds = hasData
                                        ? (new java.util.Date().getTime() - d.getTimestamp().getTime()) / 1000
                                        : 999999;

                                boolean isOnline = hasData && diffSeconds < 120;

                                boolean isFanOn = isOnline && d != null && d.getFanStatus() == 1;
                                boolean isHeaterOn = isOnline && d != null && currentTemp < 20.0;
                                boolean isLightOn = isOnline && motion == 1;
                            %>

                            <div class="actuator-card-header">
                                <div class="card-title actuator-title">Actuators</div>

                                <div class="actuator-status-pill <%= isOnline ? "online" : "offline"%>">
                                    <%= isOnline ? "ONLINE" : "OFFLINE"%>
                                </div>
                            </div>

                            <div class="actuator-icons">

                                <!-- Heater -->
                                <div class="actuator-item <%= isHeaterOn ? "active" : "inactive"%>">
                                    <div class="actuator-circle">
                                        <i class="fa-solid fa-fire <%= isHeaterOn ? "fa-fade" : ""%>"></i>
                                    </div>
                                    <span>Heater</span>
                                </div>

                                <!-- Ventilation -->
                                <div class="actuator-item <%= isFanOn ? "active" : "inactive"%>">
                                    <div class="actuator-circle actuator-main">
                                        <i class="fa-solid fa-fan <%= isFanOn ? "fa-spin" : ""%>"></i>
                                    </div>
                                    <span>Ventilation</span>
                                </div>

                                <!-- Lights -->
                                <div class="actuator-item <%= isLightOn ? "active" : "inactive"%>">
                                    <div class="actuator-circle">
                                        <i class="fa-solid fa-lightbulb <%= isLightOn ? "fa-beat-fade" : ""%>"></i>
                                    </div>
                                    <span>Lights</span>
                                </div>

                            </div>

                            <div class="actuator-load-text">
                                Status: <%= (isFanOn || isHeaterOn || isLightOn) ? "Running" : "Standby"%>
                            </div>

                        </div>

                        <!-- Occupancy Card -->
                        <div class="dash-card occupancy-card">

                            <div class="occupancy-header">
                                <div class="card-title occupancy-title">Occupancy</div>
                                <i class="fa-solid fa-person-walking occupancy-walk-icon"></i>
                            </div>

                            <div class="occupancy-content">

                                <div class="occupancy-paws">
                                    <i class="fa-solid fa-paw <%= (pawsActive >= 1) ? "paw-active paw-main" : "paw-inactive"%>"></i>
                                    <i class="fa-solid fa-paw <%= (pawsActive >= 2) ? "paw-active paw-mid" : "paw-inactive"%>"></i>
                                    <i class="fa-solid fa-paw <%= (pawsActive >= 3) ? "paw-active paw-light" : "paw-inactive"%>"></i>
                                </div>

                                <div class="occupancy-status" style="color:<%= occColor%>;">
                                    <%= occStatus%>
                                </div>

                            </div>

                            <div class="occupancy-info-box">
                                <i class="fa-regular fa-clock"></i>
                                <span>Paws fade from 3 to 1 over 20 mins of inactivity.</span>
                            </div>

                            <i class="fa-solid fa-cat occupancy-bg-cat"></i>

                        </div>

                        <!-- System Uptime Card -->
                        <div class="dash-card uptime-card">

                            <div class="uptime-card-header">
                                <div class="card-title uptime-title">System Uptime</div>

                                <div class="uptime-health-pill">
                                    HEALTHY 100%
                                </div>
                            </div>

                            <div class="uptime-monitor">
                                <div class="uptime-clock">
                                    <span id="uptime-h">00</span>:<span id="uptime-m">00</span>:<span id="uptime-s">00</span>
                                </div>

                                <div class="uptime-heartbeat">
                                    <svg viewBox="0 0 260 50" preserveAspectRatio="none">
                                    <polyline 
                                        points="0,25 80,25 92,25 102,15 114,35 128,25 150,25 160,18 170,32 184,25 260,25"
                                        />
                                    </svg>
                                </div>

                                <div class="uptime-status">
                                    <div class="pulse-dot"></div>
                                    <span>Operational Since Boot</span>
                                </div>
                            </div>

                            <img 
                                src="${pageContext.request.contextPath}/images/cat-uptime.png" 
                                alt="Sleeping cat"
                                class="uptime-cat"
                                >
                        </div>

                        <!-- Data Sync Card -->
                        <div class="dash-card data-sync-card">

                            <div class="data-sync-header">
                                <div class="card-title data-sync-title">Data Sync</div>
                                <div class="data-sync-pill">AUTO</div>
                            </div>

                            <div class="data-sync-body">

                                <div class="sync-section">
                                    <div class="sync-label">LAST ENTRY</div>

                                    <div class="sync-time">
                                        <%= (d != null && d.getTimestamp() != null)
                                                ? d.getTimestamp().toString().substring(11, 16)
                                                : "<span style='font-size:1rem; color:#d85c7d;'>No Data</span>"%>
                                        <span class="sync-today">Today</span>
                                    </div>
                                </div>

                                <div class="sync-divider"></div>

                                <div class="sync-section">
                                    <div class="sync-label">NEXT UPDATE</div>

                                    <div class="sync-next-row">
                                        <div class="sync-next-time" id="update-timer">00:45</div>
                                        <i class="fa-solid fa-rotate sync-rotate-icon"></i>
                                    </div>
                                </div>

                            </div>

                            <img 
                                src="${pageContext.request.contextPath}/images/cat-data-sync.png" 
                                alt="Cute cat"
                                class="data-sync-cat"
                                >

                            <i class="fa-solid fa-sparkles data-sync-sparkle"></i>

                        </div>

                    </div> 
                </div>
            </div> 
        </div>

        <script>
            // --- 1. SIDEBAR LOGIC ---
            function toggleSidebar() {
                const sidebar = document.getElementById('mySidebar');
                const overlay = document.querySelector('.sidebar-overlay');

                if (sidebar && overlay) {
                    sidebar.classList.toggle('active');
                    overlay.classList.toggle('active');
                }
            }

            // --- 2. MODAL LOGIC (Replaces Toast) ---
            function showModal(title, message, isSuccess) {
                const modal = document.getElementById('statusModal');
                const content = modal.querySelector('.modal-content');
                const icon = document.getElementById('modalIcon');
                const titleEl = document.getElementById('modalTitle');
                const msgEl = document.getElementById('modalMsg');

                titleEl.innerText = title;
                msgEl.innerText = message;

                if (isSuccess) {
                    content.classList.remove('error-mode');
                    icon.className = "fa-solid fa-circle-check";
                } else {
                    content.classList.add('error-mode');
                    icon.className = "fa-solid fa-triangle-exclamation";
                }

                modal.style.display = 'flex';
            }

            function closeModal() {
                document.getElementById('statusModal').style.display = 'none';
            }

            function toggleNotificationPanel() {
                console.log("Bell clicked: opening notification panel");

                const panel = document.getElementById('notificationPanel');

                if (!panel) {
                    console.log("notificationPanel not found");
                    return;
                }

                panel.classList.toggle('active');

                if (panel.classList.contains('active')) {
                    console.log("Panel is active, loading notification history...");
                    loadNotificationHistory();
                }
            }

            function loadNotificationHistory() {
                const list = document.getElementById('notificationList');

                list.innerHTML = `
        <div class="notification-empty">
            Fetching latest notification history...
        </div>
    `;

                fetch('DashboardServlet?action=getNotifications')
                        .then(response => {
                            if (!response.ok) {
                                throw new Error("Failed to fetch notifications");
                            }
                            return response.json();
                        })
                        .then(data => {
                            console.log("Notification data from DB:", data);

                            if (!data || data.length === 0) {
                                list.innerHTML = `
                    <div class="notification-empty">
                        No notification history yet.
                    </div>
                `;
                                return;
                            }

                            list.innerHTML = "";

                            data.forEach(item => {
                                const status = (item.status || "UNKNOWN").trim().toUpperCase();
                                const platform = (item.platform || "Telegram").trim();
                                const time = item.sentTimestamp || "Unknown time";
                                const message = item.messageContent || "";

                                let statusClass = "partial";
                                let icon = "fa-triangle-exclamation";
                                let statusText = status;

                                if (status === "SENT") {
                                    statusClass = "sent";
                                    icon = "fa-circle-check";
                                    statusText = "Sent";
                                } else if (status === "FAILED") {
                                    statusClass = "failed";
                                    icon = "fa-circle-xmark";
                                    statusText = "Failed";
                                } else if (status === "PARTIAL_FAILED") {
                                    statusClass = "partial";
                                    icon = "fa-triangle-exclamation";
                                    statusText = "Partial";
                                }

                                const summary = getNotificationSummary(message);
                                const shortMessage = shortenMessage(message);

                                list.innerHTML +=
                                        '<div class="notification-item ' + statusClass + '">' +
                                        '<div class="notification-icon">' +
                                        '<i class="fa-solid ' + icon + '"></i>' +
                                        '</div>' +
                                        '<div class="notification-info">' +
                                        '<div class="notification-title">' +
                                        '<span class="notification-main-title">' + escapeHtml(platform + ' ' + summary) + '</span>' +
                                        '<span class="notification-status-pill">' + escapeHtml(statusText) + '</span>' +
                                        '</div>' +
                                        '<p>' + escapeHtml(shortMessage) + '</p>' +
                                        '<small><i class="fa-regular fa-clock"></i> ' + escapeHtml(time) + '</small>' +
                                        '</div>' +
                                        '</div>';
                            });
                        })
                        .catch(error => {
                            console.error(error);
                            list.innerHTML = `
                <div class="notification-empty error">
                    Could not load notifications.
                </div>
            `;
                        });
            }

            function getNotificationSummary(message) {
                if (!message) {
                    return "Report";
                }

                let clean = message
                        .replace(/\*/g, "")
                        .replace(/_/g, "")
                        .replace(/\n/g, " ")
                        .replace(/\s+/g, " ")
                        .trim();

                if (clean.includes("HiroSumi Status Report")) {
                    return "Status Report";
                }

                if (clean.includes("Temperature") || clean.includes("Temp")) {
                    return "Sensor Report";
                }

                if (clean.includes("Warning") || clean.includes("Warm")) {
                    return "Alert Report";
                }

                return "Report";
            }

            function shortenMessage(message) {
                if (!message || message.trim() === "") {
                    return "No message content saved.";
                }

                let clean = message
                        .replace(/\*/g, "")
                        .replace(/_/g, "")
                        .replace(/\n/g, " ")
                        .replace(/\s+/g, " ")
                        .trim();

                let temp = clean.match(/Temp:\s*([0-9.]+°C)/i);
                let humidity = clean.match(/Humidity:\s*([0-9.]+%)/i);
                let motion = clean.match(/Motion:\s*([^🕒]+)/i);

                let summaryParts = [];

                if (temp) {
                    summaryParts.push("Temp " + temp[1]);
                }

                if (humidity) {
                    summaryParts.push("Humidity " + humidity[1]);
                }

                if (motion) {
                    let motionText = motion[1].trim();

                    if (motionText.length > 18) {
                        motionText = motionText.substring(0, 18) + "...";
                    }

                    summaryParts.push("Motion " + motionText);
                }

                if (summaryParts.length > 0) {
                    return summaryParts.join(" • ");
                }

                if (clean.includes("HiroSumi Status Report")) {
                    return "Shelter status report was sent successfully.";
                }

                if (clean.length > 70) {
                    clean = clean.substring(0, 70) + "...";
                }

                return clean;
            }

            function escapeHtml(value) {
                if (!value) {
                    return "";
                }

                return String(value)
                        .replace(/&/g, "&amp;")
                        .replace(/</g, "&lt;")
                        .replace(/>/g, "&gt;")
                        .replace(/"/g, "&quot;")
                        .replace(/'/g, "&#039;");
            }

            // --- 3. TELEGRAM SEND REPORT LOGIC ---
            function triggerTelegramReport() {
                const headerBellIcon = document.getElementById('headerBellIcon');

                if (headerBellIcon) {
                    headerBellIcon.className = 'fa-solid fa-spinner fa-spin';
                }

                fetch('DashboardServlet?action=sendReport')
                        .then(response => {
                            if (!response.ok) {
                                throw new Error("Server Error");
                            }
                            return response.text();
                        })
                        .then(result => {
                            console.log("Telegram result:", result);

                            if (result.trim() === 'success') {
                                showModal("Report Sent!", "The latest sensor reading has been sent to your Telegram.", true);
                            } else {
                                showModal("Failed", "Could not send report. Check Telegram subscribers, Bot Token, or server output.", false);
                            }
                        })
                        .catch(err => {
                            console.error(err);
                            showModal("System Error", "Something went wrong. Check browser console and NetBeans output.", false);
                        })
                        .finally(() => {
                            if (headerBellIcon) {
                                headerBellIcon.className = 'fa-regular fa-bell';
                            }
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

            const hoverLinePlugin = {
                id: 'hoverLinePlugin',
                afterDatasetsDraw(chart) {
                    const tooltip = chart.tooltip;

                    if (tooltip && tooltip._active && tooltip._active.length) {
                        const ctx = chart.ctx;
                        const activePoint = tooltip._active[0];
                        const x = activePoint.element.x;
                        const topY = chart.chartArea.top;
                        const bottomY = chart.chartArea.bottom;

                        ctx.save();
                        ctx.beginPath();
                        ctx.moveTo(x, topY);
                        ctx.lineTo(x, bottomY);
                        ctx.lineWidth = 2;
                        ctx.setLineDash([5, 5]);
                        ctx.strokeStyle = 'rgba(214, 90, 104, 0.35)';
                        ctx.stroke();
                        ctx.restore();
                    }
                }
            };

            // --- 4. CHART CONFIGURATION (Strawberry Matcha Edition) ---
            const myChart = new Chart(ctx, {
                type: 'line',
                plugins: [hoverLinePlugin],
                data: {
                    labels: [],
                    datasets: [
                        {
                            label: 'Temperature (°C)',
                            data: [],
                            borderColor: '#557159',
                            backgroundColor: 'rgba(85, 113, 89, 0.1)',
                            fill: true,
                            tension: 0.4,
                            borderWidth: 4,
                            pointRadius: 0,
                            pointHoverRadius: 7,
                            pointHoverBorderWidth: 4,
                            pointHitRadius: 18,
                            pointHoverBackgroundColor: '#FFF8F0',
                            pointHoverBorderColor: '#557159',
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
                            pointHoverBackgroundColor: '#FFF8F0',
                            pointHoverBorderColor: '#D65A68',
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
                            pointHoverBackgroundColor: '#FFF8F0',
                            pointHoverBorderColor: '#EBCB8B',
                            yAxisID: 'y1'
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,

                    interaction: {
                        mode: 'index',
                        intersect: false
                    },

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
                            enabled: true,
                            backgroundColor: 'rgba(255, 248, 240, 0.98)',
                            titleColor: '#D65A68',
                            bodyColor: '#3E2723',
                            borderColor: '#F8BBD0',
                            borderWidth: 2,
                            displayColors: false,
                            padding: {
                                top: 12,
                                bottom: 12,
                                left: 16,
                                right: 16
                            },
                            cornerRadius: 18,
                            caretSize: 8,
                            caretPadding: 8,
                            titleAlign: 'center',
                            bodyAlign: 'left',
                            titleFont: {
                                family: 'Quicksand',
                                size: 14,
                                weight: '900'
                            },
                            bodyFont: {
                                family: 'Quicksand',
                                size: 12,
                                weight: '800'
                            },
                            callbacks: {
                                title: function (context) {
                                    return '🍓 Sensor Reading • ' + context[0].label;
                                },
                                label: function (context) {
                                    let label = context.dataset.label || '';
                                    let value = context.parsed.y;

                                    if (label.includes('Temperature')) {
                                        return '🌿  Temperature     ' + value.toFixed(2) + ' °C';
                                    }

                                    if (label.includes('Humidity')) {
                                        return '💧  Humidity        ' + value.toFixed(2) + ' %';
                                    }

                                    if (label.includes('Pressure')) {
                                        return '🌼  Pressure        ' + value.toFixed(2) + ' kPa';
                                    }

                                    return label + ': ' + value;
                                },
                                footer: function () {
                                    return '🐾 HiroSumi is monitoring safely';
                                }
                            },
                            footerColor: '#557159',
                            footerFont: {
                                family: 'Quicksand',
                                size: 11,
                                weight: '800',
                                style: 'italic'
                            }
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
            const lastEntryTime = <%= (dJS != null && dJS.getTimestamp() != null)
                    ? dJS.getTimestamp().getTime()
                    : "new Date().getTime()"%>;

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
                    document.getElementById('update-timer').innerText = "Syncing";
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