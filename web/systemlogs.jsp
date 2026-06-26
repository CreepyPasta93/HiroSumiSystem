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
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard-custom.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/systemlogs.css">
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/favicon.png">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">


    </head>
    <body class="logs-page">

        <div id="statusModal" class="modal">
            <div class="modal-content">
                <i id="modalIcon" class="fa-solid fa-circle-check" style="font-size: 3rem; margin-bottom: 15px;"></i>
                <h3 id="modalTitle" style="margin: 0 0 10px 0; color: #3E2723; font-family: 'Comic Neue', cursive;">Success!</h3>
                <p id="modalMsg" style="color: #555; margin: 0; font-size: 0.95rem; line-height: 1.4;"></p>
                <button class="btn-close-modal" onclick="location.reload()">Awesome</button>
            </div>
        </div>

        <button class="sidebar-open-btn" onclick="toggleSidebar()">
            <i class="fa-solid fa-bars"></i>
        </button>

        <div class="sidebar-overlay" onclick="toggleSidebar()"></div>

        <div class="dashboard-container">
            <% request.setAttribute("activePage", "logs"); %>
            <jsp:include page="sidebar.jsp" />

            <div class="main-content">
                <jsp:include page="header.jsp" />

                <div class="logs-layout">

                    <div class="logs-header-block">

                        <div class="logs-title-wrap">
                            <div class="logs-title-icon">
                                <i class="fa-solid fa-clipboard-list"></i>
                            </div>

                            <div>
                                <h2 class="logs-page-title">System Logs</h2>
                                <p class="logs-page-subtitle">Audit trails & system history</p>
                            </div>
                        </div>

                        <div class="logs-tools">
                            <div class="search-box">
                                <i class="fa-solid fa-magnifying-glass"></i>
                                <input 
                                    type="text" 
                                    id="logSearch" 
                                    onkeyup="filterLogs()" 
                                    class="search-input" 
                                    placeholder="Search logs..."
                                    >
                                <span class="search-strawberry">🍓</span>
                            </div>

                            <button class="btn-export" onclick="window.location.href = 'SystemLogServlet?action=exportCSV'">
                                <i class="fa-solid fa-download"></i>
                                Export CSV
                            </button>
                        </div>

                    </div>

                    <div class="logs-tabs">
                        <a href="#" class="tab-link active" onclick="filterCategory('ALL', event)">
                            <i class="fa-solid fa-strawberry"></i> All Logs
                        </a>

                        <a href="#" class="tab-link" onclick="filterCategory('ALERT', event)">
                            <i class="fa-regular fa-bell"></i> Alerts
                        </a>

                        <a href="#" class="tab-link" onclick="filterCategory('ERROR', event)">
                            <i class="fa-solid fa-circle-exclamation"></i> Errors
                        </a>

                        <a href="#" class="tab-link" onclick="filterCategory('TEST', event)">
                            <i class="fa-solid fa-flask"></i> Test
                        </a>

                        <a href="#" class="tab-link" onclick="filterCategory('ACTION', event)">
                            <i class="fa-solid fa-gear"></i> System Action
                        </a>
                    </div>

                    <div class="logs-table-card">

                        <img 
                            src="${pageContext.request.contextPath}/images/side-strawberry.png" 
                            alt="Strawberry decoration"
                            class="logs-strawberry-deco"
                            >

                        <img 
                            src="${pageContext.request.contextPath}/images/cat-cushion.png" 
                            alt="Sleeping cat"
                            class="logs-cat-deco"
                            >

                        <div class="logs-table-container">
                            <table class="logs-table" id="logsTable">
                                <thead>
                                    <tr>
                                        <th style="width: 80px;">ID <span>🐾</span></th>
                                        <th style="width: 180px;">Timestamp <span>🌿</span></th>
                                        <th style="width: 120px;">Source</th>
                                        <th style="width: 110px;">Category <span>🌿</span></th>
                                        <th>Description</th>
                                        <th style="width: 130px;">Status <span>🐾</span></th>
                                    </tr>
                                </thead>

                                <tbody>
                                    <% if (logs != null && !logs.isEmpty()) {
                                            for (SystemLog log : logs) {
                                                String badgeClass = "badge-info";
                                                if ("Success".equalsIgnoreCase(log.getStatus())) {
                                                    badgeClass = "badge-success";
                                                } else if ("Failed".equalsIgnoreCase(log.getStatus()) || "Critical".equalsIgnoreCase(log.getStatus())) {
                                                    badgeClass = "badge-failed";
                                                } else if ("Warning".equalsIgnoreCase(log.getStatus())) {
                                                    badgeClass = "badge-warning";
                                                }

                                                String categoryClass = "category-info";
                                                if ("ACTION".equalsIgnoreCase(log.getCategory()))
                                                    categoryClass = "category-action";
                                                else if ("SYSTEM".equalsIgnoreCase(log.getCategory()))
                                                    categoryClass = "category-system";
                                                else if ("ERROR".equalsIgnoreCase(log.getCategory()))
                                                    categoryClass = "category-error";
                                                else if ("ALERT".equalsIgnoreCase(log.getCategory()))
                                                    categoryClass = "category-alert";
                                    %>

                                    <tr class="log-row" data-category="<%= log.getCategory().toUpperCase()%>">
                                        <td class="log-id">#<%= log.getAlertId()%></td>
                                        <td><%= log.getFormattedDate()%></td>
                                        <td class="log-source"><%= log.getSource()%></td>
                                        <td>
                                            <span class="category-pill <%= categoryClass%>">
                                                <%= log.getCategory().toUpperCase()%>
                                            </span>
                                        </td>
                                        <td><%= log.getDescription()%></td>
                                        <td>
                                            <span class="badge <%= badgeClass%>">
                                                <% if ("Success".equalsIgnoreCase(log.getStatus())) { %>
                                                <i class="fa-solid fa-circle-check"></i>
                                                <% } else if ("Failed".equalsIgnoreCase(log.getStatus()) || "Critical".equalsIgnoreCase(log.getStatus())) { %>
                                                <i class="fa-solid fa-circle-xmark"></i>
                                                <% } else if ("Warning".equalsIgnoreCase(log.getStatus())) { %>
                                                <i class="fa-solid fa-triangle-exclamation"></i>
                                                <% } else { %>
                                                <i class="fa-solid fa-circle-info"></i>
                                                <% }%>
                                                <%= log.getStatus()%>
                                            </span>
                                        </td>
                                    </tr>

                                    <%  }
                                    } else { %>
                                    <tr>
                                        <td colspan="6" class="empty-log-row">
                                            No logs found.
                                        </td>
                                    </tr>
                                    <% }%>
                                </tbody>
                            </table>
                        </div>

                    </div>

                </div>
            </div>
        </div>

        <script>
            function toggleSidebar() {
                document.getElementById('mySidebar').classList.toggle('active');
                document.querySelector('.sidebar-overlay').classList.toggle('active');
            }

            function filterCategory(category, event) {
                event.preventDefault();

                document.querySelectorAll('.tab-link').forEach(btn => btn.classList.remove('active'));
                event.currentTarget.classList.add('active');

                const rows = document.querySelectorAll('.log-row');

                rows.forEach(row => {
                    const rowCat = row.getAttribute('data-category');
                    row.style.display = (category === 'ALL' || rowCat === category) ? '' : 'none';
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