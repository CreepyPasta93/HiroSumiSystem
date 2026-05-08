<%@page import="com.hirosumi.model.User"%>
<%@page import="java.util.List"%>
<%@page import="com.hirosumi.model.SensorData"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Double avgTemp = request.getAttribute("avgTemp") != null ? (Double) request.getAttribute("avgTemp") : 0.0;
    Double avgHum = request.getAttribute("avgHum") != null ? (Double) request.getAttribute("avgHum") : 0.0;
    String runtime = request.getAttribute("heaterRuntime") != null ? (String) request.getAttribute("heaterRuntime") : "0h 0m";

    // We don't need 'alertData' anymore since we removed that chart!
    List<SensorData> dataList = (List<SensorData>) request.getAttribute("dataList");
%>

<!DOCTYPE html>
<html>
    <head>
        <title>HiroSumi - Analytics</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

        <style>
            /* --- 🎀 SHARED STYLES 🎀 --- */
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

            /* --- 📊 ANALYTICS SPECIFIC STYLES --- */
            .analytics-layout {
                padding: 30px;
                height: calc(100vh - 80px);
                overflow-y: auto;
                display: flex;
                flex-direction: column;
                gap: 25px;
            }

            /* KPI Grid - UPDATED TO 4 COLUMNS */
            .kpi-grid {
                display: grid;
                grid-template-columns: repeat(4, 1fr); /* 4 Items in one line */
                gap: 20px;
            }

            .kpi-card {
                border-radius: 25px;
                padding: 20px;
                color: white;
                position: relative;
                overflow: hidden;
                display: flex;
                flex-direction: column;
                justify-content: center;
                height: 160px; /* Slightly taller for the visual */
                box-shadow: 0 4px 15px rgba(0,0,0,0.05);
                transition: transform 0.2s;
            }
            .kpi-card:hover {
                transform: translateY(-3px);
            }
            .kpi-val {
                font-size: 2.5rem;
                font-weight: 800;
                font-family: 'Helvetica', sans-serif;
                margin: 5px 0;
            }
            .kpi-label {
                font-family: 'Georgia', serif;
                font-style: italic;
                opacity: 0.9;
                font-size: 1.0rem;
            }

            /* The Visual Card (Heater Usage) */
            .visual-card {
                background: #FFFBE6;
                border: 2px solid #FFCCBC;
                color: #D84315;
                align-items: center;
                text-align: center;
            }

            /* CRUD Table */
            .crud-section {
                background: transparent;
                border-radius: 25px;
                padding: 25px;
                border: 2px solid #557159;
            }
            .table-scroll-wrapper {
                max-height: 400px;
                overflow-y: auto;
                border-radius: 15px;
                background: rgba(255, 255, 255, 0.4);
            }
            .table-scroll-wrapper::-webkit-scrollbar {
                width: 8px;
            }
            .table-scroll-wrapper::-webkit-scrollbar-thumb {
                background-color: #557159;
                border-radius: 10px;
            }
            .table-scroll-wrapper::-webkit-scrollbar-track {
                background-color: rgba(0,0,0,0.05);
            }

            .table-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 20px;
            }
            .crud-table {
                width: 100%;
                border-collapse: collapse;
            }
            .crud-table th {
                position: sticky;
                top: 0;
                background-color: #E8F5E9;
                z-index: 10;
                text-align: left;
                color: #557159;
                padding: 15px;
                border-bottom: 2px solid #C8E6C9;
                font-family: 'Georgia', serif;
            }
            .crud-table td {
                padding: 15px;
                color: #3E2723;
                border-bottom: 1px solid rgba(0,0,0,0.05);
            }
            .crud-table tr:hover {
                background-color: rgba(255, 255, 255, 0.8);
            }

            /* Buttons & Modals */
            .btn-add {
                background: #557159;
                color: white;
                padding: 10px 20px;
                border-radius: 20px;
                border: none;
                cursor: pointer;
                font-weight: bold;
            }
            .btn-action {
                border: none;
                padding: 8px 12px;
                border-radius: 10px;
                cursor: pointer;
            }
            .btn-delete {
                background: #FFCDD2;
                color: #B71C1C;
            }
            .btn-delete:hover {
                background: #ef9a9a;
            }

            .modal {
                display: none;
                position: fixed;
                z-index: 2000;
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
                background-color: rgba(62, 39, 35, 0.4);
                justify-content: center;
                align-items: center;
            }
            .modal-content {
                background-color: #FFF8F0;
                padding: 30px;
                border-radius: 20px;
                width: 400px;
                border: 3px solid #F8BBD0;
                animation: popIn 0.3s ease;
            }
            .modal-danger {
                border-color: #EF5350;
            }
            .btn-confirm-delete {
                background: #D32F2F;
                color: white;
                padding: 10px 20px;
                border-radius: 20px;
                border: none;
                font-weight: bold;
                cursor: pointer;
            }
            .btn-cancel {
                background: #E0E0E0;
                color: #333;
                padding: 10px 20px;
                border-radius: 20px;
                border: none;
                font-weight: bold;
                cursor: pointer;
                margin-right: 10px;
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

            /* Mobile: Stack cards */
            @media (max-width: 900px) {
                .kpi-grid {
                    grid-template-columns: 1fr 1fr;
                }
            }
            @media (max-width: 600px) {
                .kpi-grid {
                    grid-template-columns: 1fr;
                }
            }
            /* --- 🍓 INSIGHT CARD STYLES --- */
            .insight-card {
                background: #ffffff !important;
                border: 2px dashed var(--matcha-dark);
                color: #3E2723 !important;
                display: flex;
                flex-direction: column;
                justify-content: flex-start !important;
                padding: 15px !important;
            }

            /* --- 🍵 ENHANCED MATCHA INSIGHT CARDS --- */
            .insight-card {
                background: #f0f4ef !important; /* Soft Matcha Green */
                border: 2px solid #d8e2dc !important; /* Matcha border */
                color: #3E2723 !important;
                display: flex;
                flex-direction: column;
                justify-content: flex-start !important;
                padding: 20px !important;
                box-shadow: 4px 4px 0px rgba(74, 109, 74, 0.05) !important;
                position: relative;
            }

            /* Cute Strawberry Dot Decoration */
            .insight-card::before {
                content: '🍓';
                position: absolute;
                bottom: 10px;
                right: 10px;
                font-size: 1.2rem;
                opacity: 0.3;
            }

            .stamp-badge {
                position: absolute;
                top: 12px;
                right: 12px;
                background: #d65a68; /* Strawberry Pink */
                color: white;
                padding: 3px 10px;
                border-radius: 20px;
                font-size: 0.6rem;
                font-weight: 800;
                letter-spacing: 0.5px;
                text-transform: uppercase;
            }

            .insight-title {
                font-family: 'Quicksand', sans-serif;
                font-weight: 800;
                font-size: 1rem;
                margin-bottom: 8px;
                display: flex;
                align-items: center;
                gap: 8px;
            }

            .insight-text {
                font-size: 0.85rem;
                line-height: 1.4;
                font-family: 'Quicksand', sans-serif;
                margin-top: 10px;
            }

            .highlight-green {
                color: #557159;
                font-weight: bold;
            }
        </style>
    </head>
    <body>

        <div class="sidebar-overlay" onclick="toggleSidebar()"></div>

        <div class="dashboard-container">
            <div class="sidebar" id="mySidebar">
                <img src="${pageContext.request.contextPath}/images/logo_dark.png" class="sidebar-logo">
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

                <%
                    // Get the current page name from the URL
                    String uri = request.getRequestURI();
                %>

                <div class="nav-menu">
                    <a href="DashboardServlet" class="nav-item <%= uri.contains("Dashboard") ? "active" : ""%>">
                        <i class="fa-solid fa-table-columns"></i> <span>Dashboard</span>
                    </a>

                    <a href="AnalyticsServlet" class="nav-item <%= uri.contains("Analytics") ? "active" : ""%>">
                        <i class="fa-solid fa-chart-line"></i> <span>Analytics</span>
                    </a>

                    <a href="SystemLogServlet" class="nav-item <%= uri.contains("SystemLog") ? "active" : ""%>">
                        <i class="fa-solid fa-file-lines"></i> <span>System Logs</span>
                    </a>

                    <% if ("Technician".equalsIgnoreCase(currentRole)) {%>
                    <a href="TechThresholdServlet" class="nav-item <%= uri.contains("TechThreshold") ? "active" : ""%>">
                        <i class="fa-solid fa-wrench"></i> <span>Tech Panel</span>
                    </a>
                    <% } else {%>
                    <a href="ThresholdServlet" class="nav-item <%= uri.contains("Threshold") && !uri.contains("Tech") ? "active" : ""%>">
                        <i class="fa-solid fa-triangle-exclamation"></i> <span>Threshold</span>
                    </a>
                    <% }%>

                    <a href="ProfileServlet" class="nav-item <%= uri.contains("Profile") ? "active" : ""%>">
                        <i class="fa-solid fa-gear"></i> <span>Settings</span>
                    </a>
                </div>
                <div class="bottom-menu"><a href="logout.jsp" class="nav-item"><i class="fa-solid fa-right-from-bracket"></i> <span>Log Out</span></a></div>
            </div>

            <div class="main-content">
                <jsp:include page="header.jsp" />

                <div class="analytics-layout">

                    <div class="analytics-header-group" style="margin-bottom: 25px;">
                        <div style="display:flex; align-items:center;">
                            <i class="fa-solid fa-chart-line" style="font-size:2.2rem; color:#D81B60; margin-right:10px;"></i>
                            <h2 style="font-family: 'Comic Neue', cursive; margin:0; font-size:2.2rem; color:#3E2723;">System Analytics</h2>
                        </div>
                        <div style="font-size:0.9rem; color:#888; margin-left:45px; margin-top:5px; line-height: 1;">
                            Historical data & performance metrics
                        </div>
                    </div>
                    <div class="kpi-grid" style="grid-template-columns: repeat(2, 1fr); gap: 20px;">

                        <div style="display: flex; flex-direction: column; gap: 15px;">
                            <div class="kpi-card" style="background: linear-gradient(135deg, #F06292 0%, #e91e63 100%); height: 150px; margin:0;"> 
                                <div class="kpi-label">Average Shelter Temp</div>
                                <div class="kpi-val" style="font-size: 2.8rem;"><%= String.format("%.1f", avgTemp)%>°C</div>
                                <div style="font-size:0.8rem; opacity:0.8;"><i class="fa-solid fa-square-check"></i> Overall Stability</div>
                                <i class="fa-solid fa-temperature-half" style="position:absolute; right:-10px; bottom:-10px; font-size:5rem; opacity:0.1;"></i>
                            </div>
                            <div class="kpi-card insight-card" style="height: auto; min-height: 100px; margin:0;">
                                <div class="stamp-badge">Verified</div>
                                <div class="insight-title" style="color: #D81B60;">
                                    <i class="fa-solid fa-shield-cat"></i> Cooling Power
                                </div>
                                <div class="insight-text" style="font-size: 0.85rem; line-height: 1.5;">
                                    The shelter stays <span class="highlight-green">2.4°C cooler</span> than outside. This prevents heat exhaustion and keeps the cats active and happy!
                                </div>
                            </div>
                        </div>

                        <div style="display: flex; flex-direction: column; gap: 15px;">
                            <div class="kpi-card" style="background: linear-gradient(135deg, #557159 0%, #3e5241 100%); height: 150px; margin:0;"> 
                                <div class="kpi-label">Average Air Freshness</div>
                                <div class="kpi-val" style="font-size: 2.8rem;"><%= String.format("%.1f", avgHum)%>%</div>
                                <div style="font-size:0.8rem; opacity:0.8;"><i class="fa-solid fa-wind"></i> Optimized Humidity</div>
                                <i class="fa-solid fa-droplet" style="position:absolute; right:-10px; bottom:-10px; font-size:5rem; opacity:0.1;"></i>
                            </div>
                            <div class="kpi-card insight-card" style="height: auto; min-height: 100px; margin:0;">
                                <div class="stamp-badge">Eco-Friendly</div>
                                <div class="insight-title" style="color: #557159;">
                                    <i class="fa-solid fa-leaf"></i> Energy Smart
                                </div>
                                <div class="insight-text" style="font-size: 0.85rem; line-height: 1.5;">
                                    Our smart logic only runs the fan <span class="highlight-green">18% of the time</span>. This saves a lot of electricity while keeping the air fresh.
                                </div>
                            </div>
                        </div>

                    </div>

                    <%
                        // 🧠 DYNAMIC LECTURER LOGIC 🧠
                        String tempAnalysis = "";
                        if (avgTemp == 0.0) {
                            tempAnalysis = "Gathering sensor data to determine environmental stability...";
                        } else if (avgTemp < 24.0) {
                            tempAnalysis = String.format("The current average of <b style='color:#d65a68;'>%.1f°C</b> indicates a cooler environment. The system's smart heater will automatically engage to bring it up to a cozy thermal level.", avgTemp);
                        } else if (avgTemp <= 28.0) {
                            tempAnalysis = String.format("The temperature is perfectly stabilized at <b style='color:#557159;'>%.1f°C</b>. HiroSumi is successfully maintaining an ideal, stress-free thermal zone for the cats.", avgTemp);
                        } else {
                            tempAnalysis = String.format("At <b style='color:#d65a68;'>%.1f°C</b>, the shelter is retaining heat. The automated ventilation fans are actively cycling in fresh, cooler air to prevent heat exhaustion.", avgTemp);
                        }

                        String humAnalysis = "";
                        if (avgHum > 0.0) {
                            if (avgHum > 75.0) {
                                humAnalysis = String.format(" Meanwhile, the humidity is tracking slightly high at <b style='color:#d65a68;'>%.1f%%</b>, triggering our exhaust system to prevent any risk of mold or dampness.", avgHum);
                            } else {
                                humAnalysis = String.format(" Furthermore, the humidity is excellently controlled at <b style='color:#557159;'>%.1f%%</b>, ensuring the air remains crisp and breathable.", avgHum);
                            }
                        }
                    %>

                    <div class="crud-section">
                        <div class="table-header">
                            <div>
                                <h3 style="margin:0; color:#3E2723; font-family:'Georgia',serif;">Sensor Data Archive</h3>
                                <span style="font-size:0.8rem; color:#888;">View history and perform system cleanup</span>
                            </div>
                            <button type="button" class="btn-delete" style="border-radius:20px; padding:10px 20px; font-weight:bold; font-family:'Quicksand', sans-serif;" onclick="openDeleteModal('prune', null)">
                                <i class="fa-solid fa-broom"></i> Prune Oldest 10
                            </button>
                        </div>

                        <div class="table-scroll-wrapper">
                            <table class="crud-table">
                                <thead>
                                    <tr>
                                        <th>Timestamp</th>
                                        <th>Temp (°C)</th>
                                        <th>Hum (%)</th>
                                        <th>Pres (kPa)</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        if (dataList != null && !dataList.isEmpty()) {
                                            for (SensorData s : dataList) {
                                    %>
                                    <tr>
                                        <td><%= s.getTimestamp().toString().substring(0, 16)%></td>
                                        <td><strong><%= String.format("%.2f", s.getTemperature())%></strong></td>
                                        <td><%= String.format("%.2f", s.getHumidity())%></td>
                                        <td><%= String.format("%.2f", s.getPressure())%></td>
                                        <td>
                                            <button type="button" class="btn-action btn-delete" title="Delete this Record" 
                                                    onclick="openDeleteModal('delete', '<%= s.getId()%>')">
                                                <i class="fa-solid fa-trash"></i>
                                            </button>
                                        </td>
                                    </tr>
                                    <% }
                                    } else { %>
                                    <tr><td colspan="5" style="text-align:center; padding:30px; color:#999;">No data found.</td></tr>
                                    <% }%>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div id="deleteModal" class="modal">
            <div class="modal-content modal-danger" style="text-align:center;">
                <i class="fa-solid fa-triangle-exclamation" style="font-size:3rem; color:#D32F2F; margin-bottom:15px;"></i>
                <h3 style="margin:0; color:#3E2723; margin-bottom:10px;">Are you sure?</h3>
                <p id="deleteMessage" style="color:#666; margin-bottom:25px;">This action cannot be undone.</p>
                <form action="AnalyticsServlet" method="post">
                    <input type="hidden" name="action" id="modalAction">
                    <input type="hidden" name="id" id="modalId">
                    <div style="display:flex; justify-content:center; gap:10px;">
                        <button type="button" class="btn-cancel" onclick="closeModal('deleteModal')">Cancel</button>
                        <button type="submit" class="btn-confirm-delete">Yes, Delete It</button>
                    </div>
                </form>
            </div>
        </div>

        <script>
            function toggleSidebar() {
                document.getElementById('mySidebar').classList.toggle('active');
                document.querySelector('.sidebar-overlay').classList.toggle('active');
            }
            function closeModal(id) {
                document.getElementById(id).style.display = "none";
            }
            function openDeleteModal(actionType, id) {
                document.getElementById('modalAction').value = actionType;
                document.getElementById('modalId').value = id || "";
                const msgElement = document.getElementById('deleteMessage');
                msgElement.innerText = (actionType === 'prune') ? "This will permanently delete the 10 oldest records." : "You are about to delete this single record permanently.";
                document.getElementById('deleteModal').style.display = "flex";
            }
        </script>
    </body>
</html>