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
                    <div class="kpi-grid">

                        <div class="kpi-card" style="background: #F06292;"> 
                            <div class="kpi-label">Average Temp</div>
                            <div class="kpi-val"><%= avgTemp%>°C</div>
                            <div style="font-size:0.8rem; opacity:0.8;"><i class="fa-solid fa-circle-check"></i> Conditions Optimal</div>
                            <i class="fa-solid fa-temperature-half" style="position:absolute; right:-15px; bottom:-15px; font-size:6rem; opacity:0.15;"></i>
                        </div>

                        <div class="kpi-card" style="background: #557159;"> 
                            <div class="kpi-label">Average Humidity</div>
                            <div class="kpi-val"><%= avgHum%>%</div>
                            <div style="font-size:0.8rem; opacity:0.8;"><i class="fa-solid fa-arrow-trend-up"></i> Stable Trend</div>
                            <i class="fa-solid fa-droplet" style="position:absolute; right:-15px; bottom:-15px; font-size:6rem; opacity:0.15;"></i>
                        </div>

                        <div class="kpi-card" style="background: #FFAB91;"> 
                            <div style="display:flex; justify-content:space-between; align-items:center;">
                                <div class="kpi-label">Heater Runtime</div>
                                <div style="background:rgba(255,255,255,0.3); padding:2px 8px; border-radius:10px; font-size:0.6rem; font-weight:bold; color: #BF360C;">STANDBY</div>
                            </div>
                            <div class="kpi-val" style="opacity:0.9;">-- h -- m</div>
                            <div style="font-size:0.8rem; opacity:0.9;"><i class="fa-solid fa-pause"></i> Module Inactive</div>
                            <i class="fa-solid fa-fire-burner" style="position:absolute; right:-15px; bottom:-15px; font-size:6rem; opacity:0.15;"></i>
                        </div>

                        <div class="kpi-card visual-card">
                            <div style="width:60px; height:60px; background:rgba(255, 171, 145, 0.2); border-radius:50%; display:flex; align-items:center; justify-content:center; margin-bottom:10px;">
                                <i class="fa-solid fa-power-off" style="font-size:2rem; color:#FF7043;"></i>
                            </div>
                            <div style="font-weight:bold; font-size:1.1rem;">Standby Mode</div>
                            <div style="font-size:0.8rem; opacity:0.8;">Data collection paused</div>
                        </div>

                    </div>

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