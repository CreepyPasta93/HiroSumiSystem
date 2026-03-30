<%@page import="java.util.List"%>
<%@page import="com.hirosumi.model.SystemLog"%>
<%@page import="com.hirosumi.model.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<SystemLog> logs = (List<SystemLog>) request.getAttribute("logs");
%>

<!DOCTYPE html>
<html>
    <head>
        <title>HiroSumi - System Logs</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

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
                transition: left 0.4s;
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

            /* --- 📜 LOGS LAYOUT --- */
            .logs-layout {
                padding: 30px;
                height: calc(100vh - 80px);
                display: flex;
                flex-direction: column;
                gap: 20px;
                overflow: hidden;
            }

            /* Header & Search (FIXED STYLING) */
            .header-area {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 10px;
            }
            .search-box {
                position: relative;
                background: white;
                border-radius: 30px; /* Rounder */
                border: 2px solid #F8BBD0;
                padding: 8px 20px; /* Better padding */
                width: 300px;
                display: flex; /* Flexbox aligns icon and text perfectly */
                align-items: center;
                gap: 10px;
                box-shadow: 0 2px 5px rgba(0,0,0,0.02);
                transition: 0.3s;
            }
            .search-box:focus-within {
                border-color: #D81B60;
                box-shadow: 0 4px 10px rgba(216, 27, 96, 0.1);
            }
            .search-input {
                border: none;
                outline: none;
                width: 100%;
                font-size: 0.95rem;
                color: #555;
                background: transparent;
            }

            /* Telegram Card */
            .config-card {
                background: linear-gradient(135deg, #4E6F52 0%, #2E4E32 100%);
                border-radius: 25px;
                padding: 25px;
                color: white;
                display: flex;
                justify-content: space-between;
                align-items: center;
                box-shadow: 0 8px 20px rgba(78, 111, 82, 0.25);
                border: 2px solid #A5D6A7;
                flex-shrink: 0;
            }
            .config-icon {
                background: rgba(255,255,255,0.2);
                width: 60px;
                height: 60px;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 2rem;
                color: #FFF;
            }
            .config-info h3 {
                margin: 0 0 5px 0;
                font-family: 'Comic Neue', cursive;
                font-size: 1.6rem;
                letter-spacing: 0.5px;
            }
            .config-info p {
                margin: 0;
                font-size: 0.9rem;
                opacity: 0.9;
                font-family: 'Helvetica', sans-serif;
            }
            .btn-telegram {
                background: #FFF;
                color: #2E4E32;
                border: none;
                padding: 12px 25px;
                border-radius: 30px;
                font-weight: bold;
                cursor: pointer;
                display: flex;
                align-items: center;
                gap: 10px;
                transition: 0.2s;
                font-family: 'Quicksand', sans-serif;
            }
            .btn-telegram:hover {
                transform: translateY(-3px);
                box-shadow: 0 5px 15px rgba(0,0,0,0.15);
                color: #D81B60;
            }

            /* Controls */
            .logs-controls-bar {
                display: flex;
                justify-content: space-between;
                align-items: center;
                flex-shrink: 0;
            }
            .logs-tabs {
                display: flex;
                gap: 10px;
                background: #FFF0F5;
                padding: 6px;
                border-radius: 30px;
                border: 1px solid #F8BBD0;
            }
            .tab-link {
                text-decoration: none;
                color: #880E4F;
                padding: 8px 20px;
                border-radius: 20px;
                font-size: 0.9rem;
                font-weight: bold;
                transition: 0.3s;
                font-family: 'Quicksand', sans-serif;
            }
            .tab-link.active {
                background: #D81B60;
                color: white;
                box-shadow: 0 4px 10px rgba(216, 27, 96, 0.3);
            }
            .btn-export {
                background: white;
                border: 2px solid #557159;
                color: #557159;
                padding: 8px 20px;
                border-radius: 20px;
                font-weight: bold;
                cursor: pointer;
                display: flex;
                align-items: center;
                gap: 8px;
                transition: 0.2s;
            }
            .btn-export:hover {
                background: #557159;
                color: white;
            }

            /* Table */
            .logs-table-container {
                background: white;
                border-radius: 25px;
                padding: 0;
                overflow: hidden;
                border: 2px solid #F8BBD0;
                box-shadow: 0 5px 15px rgba(0,0,0,0.03);
                flex-grow: 1;
                overflow-y: auto;
                display: flex;
                flex-direction: column;
            }
            .logs-table {
                width: 100%;
                border-collapse: collapse;
            }
            .logs-table th {
                background: #FCE4EC;
                color: #880E4F;
                padding: 18px;
                text-align: left;
                position: sticky;
                top: 0;
                font-family: 'Comic Neue', cursive;
                font-size: 1.1rem;
                z-index: 10;
                border-bottom: 2px solid #F8BBD0;
            }
            .logs-table td {
                padding: 15px 18px;
                border-bottom: 1px solid #f0f0f0;
                color: #4E342E;
                font-size: 0.95rem;
                font-family: 'Helvetica', sans-serif;
            }
            .logs-table tr:hover {
                background: #FFF8E1;
            }

            /* Badges */
            .badge {
                padding: 5px 12px;
                border-radius: 15px;
                font-size: 0.75rem;
                font-weight: 800;
                letter-spacing: 0.5px;
                text-transform: uppercase;
            }
            .badge-success {
                background: #C8E6C9;
                color: #2E7D32;
                border: 1px solid #A5D6A7;
            }
            .badge-failed {
                background: #FFCDD2;
                color: #C62828;
                border: 1px solid #EF9A9A;
            }
            .badge-info {
                background: #E1F5FE;
                color: #0277BD;
                border: 1px solid #81D4FA;
            }
            .badge-warning {
                background: #FFF9C4;
                color: #FBC02D;
                border: 1px solid #FFF59D;
            }

            /* Modal */
            .modal {
                display: none;
                position: fixed;
                z-index: 2000;
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
                background-color: rgba(62, 39, 35, 0.5);
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
        </style>
    </head>
    <body>

        <div id="statusModal" class="modal">
            <div class="modal-content">
                <i id="modalIcon" class="fa-solid fa-circle-check" style="font-size: 3rem; margin-bottom: 15px;"></i>
                <h3 id="modalTitle" style="margin: 0 0 10px 0; color: #3E2723; font-family: 'Comic Neue', cursive;">Success!</h3>
                <p id="modalMsg" style="color: #555; margin: 0; font-size: 0.95rem; line-height: 1.4;"></p>
                <button class="btn-close-modal" onclick="location.reload()">Awesome</button>
            </div>
        </div>

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
                    <% } %>

                    <a href="ProfileServlet" class="nav-item"><i class="fa-solid fa-gear"></i> <span>Settings</span></a>
                </div>
                <div class="bottom-menu"><a href="logout.jsp" class="nav-item"><i class="fa-solid fa-right-from-bracket"></i> <span>Log Out</span></a></div>
            </div>

            <div class="main-content">
                <jsp:include page="header.jsp" />

                <div class="logs-layout">

                    <div class="header-area">
                        <div>
                            <h2 style="font-family: 'Comic Neue', cursive; margin:0; font-size:2.2rem; color:#3E2723;">
                                <i class="fa-solid fa-clipboard-list" style="color:#D81B60; margin-right:10px;"></i>System Logs
                            </h2>
                            <span style="font-size:0.9rem; color:#888; margin-left:45px;">Audit trails & system history</span>
                        </div>
                        <div class="search-box">
                            <i class="fa-solid fa-magnifying-glass" style="color:#F48FB1;"></i>
                            <input type="text" id="logSearch" onkeyup="filterLogs()" class="search-input" placeholder="Search logs...">
                        </div>
                    </div>

                    <div class="config-card">
                        <div style="display:flex; align-items:center; gap:20px;">
                            <div class="config-icon"><i class="fa-brands fa-telegram"></i></div>
                            <div class="config-info">
                                <h3>Telegram Alerts</h3>
                                <p>Status: <strong>Active</strong> • Bot: @HiroSumiBot</p>
                            </div>
                        </div>
                        <div>
                            <button class="btn-telegram" onclick="sendTestAlert()" id="testBtn">
                                <i class="fa-solid fa-paper-plane"></i> Test Alert
                            </button>
                        </div>
                    </div>

                    <div class="logs-controls-bar">
                        <div class="logs-tabs">
                            <a href="#" class="tab-link active" onclick="filterCategory('ALL')">All Logs</a>
                            <a href="#" class="tab-link" onclick="filterCategory('ALERT')">Alerts</a>
                            <a href="#" class="tab-link" onclick="filterCategory('ERROR')">Errors</a>
                            <a href="#" class="tab-link" onclick="filterCategory('TEST')">Test</a>
                            <a href="#" class="tab-link" onclick="filterCategory('ACTION')">System Action</a>
                        </div>

                        <button class="btn-export" onclick="window.location.href = 'SystemLogServlet?action=exportCSV'">
                            <i class="fa-solid fa-download"></i> Export CSV
                        </button>
                    </div>

                    <div class="logs-table-container">
                        <table class="logs-table" id="logsTable">
                            <thead>
                                <tr>
                                    <th style="width: 80px;">ID</th>
                                    <th style="width: 180px;">Timestamp</th>
                                    <th style="width: 120px;">Source</th>
                                    <th style="width: 100px;">Category</th>
                                    <th>Description</th>
                                    <th style="width: 100px;">Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (logs != null && !logs.isEmpty()) {
                                        for (SystemLog log : logs) {
                                            String badgeClass = "badge-info";
                                            if ("Success".equalsIgnoreCase(log.getStatus()))
                                                badgeClass = "badge-success";
                                            else if ("Failed".equalsIgnoreCase(log.getStatus()) || "Critical".equalsIgnoreCase(log.getStatus()))
                                                badgeClass = "badge-failed";
                                            else if ("Warning".equalsIgnoreCase(log.getStatus()))
                                                badgeClass = "badge-warning";
                                %>
                                <tr class="log-row" data-category="<%= log.getCategory().toUpperCase()%>">
                                    <td style="font-weight:bold; color:#AAA;">#<%= log.getAlertId()%></td>
                                    <td><%= log.getFormattedDate()%></td>
                                    <td style="font-weight:bold; color:#557159;"><%= log.getSource()%></td>
                                    <td style="font-weight:bold; font-size:0.8rem; letter-spacing:0.5px; color:#880E4F;"><%= log.getCategory().toUpperCase()%></td>
                                    <td><%= log.getDescription()%></td>
                                    <td><span class="badge <%= badgeClass%>"><%= log.getStatus()%></span></td>
                                </tr>
                                <%  }
                                } else { %>
                                <tr><td colspan="6" style="padding:40px; text-align:center; color:#888;">No logs found.</td></tr>
                                <% }%>
                            </tbody>
                        </table>
                    </div>

                </div>
            </div>
        </div>

        <script>
            function toggleSidebar() {
                document.getElementById('mySidebar').classList.toggle('active');
                document.querySelector('.sidebar-overlay').classList.toggle('active');
            }

            function filterCategory(category) {
                document.querySelectorAll('.tab-link').forEach(btn => btn.classList.remove('active'));
                event.target.classList.add('active');
                const rows = document.querySelectorAll('.log-row');
                rows.forEach(row => {
                    const rowCat = row.getAttribute('data-category');
                    if (category === 'ALL' || rowCat === category)
                        row.style.display = '';
                    else
                        row.style.display = 'none';
                });
            }

            function filterLogs() {
                const input = document.getElementById('logSearch').value.toLowerCase();
                const rows = document.querySelectorAll('.log-row');
                rows.forEach(row => {
                    const text = row.innerText.toLowerCase();
                    row.style.display = text.includes(input) ? '' : 'none';
                });
            }

            function showModal(title, message, isSuccess) {
                const modal = document.getElementById('statusModal');
                const icon = document.getElementById('modalIcon');
                const titleEl = document.getElementById('modalTitle');
                const msgEl = document.getElementById('modalMsg');
                titleEl.innerText = title;
                msgEl.innerText = message;
                if (isSuccess) {
                    icon.className = "fa-solid fa-circle-check";
                    icon.style.color = "#66BB6A";
                    titleEl.style.color = "#2E7D32";
                } else {
                    icon.className = "fa-solid fa-circle-xmark";
                    icon.style.color = "#EF5350";
                    titleEl.style.color = "#C62828";
                }
                modal.style.display = 'flex';
            }

            function sendTestAlert() {
                const btn = document.getElementById('testBtn');
                const originalText = btn.innerHTML;
                btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Sending...';
                btn.disabled = true;

                fetch('SystemLogServlet?action=testTelegram')
                        .then(response => response.text())
                        .then(result => {
                            if (result.trim() === 'success') {
                                showModal("Test Sent!", "Check your Telegram.", true);
                            } else {
                                showModal("Failed", "Connection failed.", false);
                            }
                        })
                        .catch(error => showModal("Error", "System Error.", false))
                        .finally(() => {
                            btn.innerHTML = originalText;
                            btn.disabled = false;
                        });
            }
        </script>
    </body>
</html>