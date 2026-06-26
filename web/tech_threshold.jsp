<%@page import="com.hirosumi.model.Configuration"%>
<%@page import="com.hirosumi.model.User"%>
<%@page import="java.util.List"%>
<%@page import="com.hirosumi.model.Notification"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Configuration sysConfig = (Configuration) request.getAttribute("config");
    if (sysConfig == null) {
        response.sendRedirect("TechThresholdServlet");
        return;
    }

    String status = request.getParameter("status");
%>

<!DOCTYPE html>
<html>
    <head>
        <title>HiroSumi - Admin Control</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard-custom.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/techpanel.css">
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/favicon.png">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">


    </head>

    <body class="tech-panel-page">

        <button class="sidebar-open-btn" onclick="toggleSidebar()">
            <i class="fa-solid fa-bars"></i>
        </button>

        <div class="sidebar-overlay" onclick="toggleSidebar()"></div>

        <div class="dashboard-container">
            <% request.setAttribute("activePage", "tech");%>
            <jsp:include page="sidebar.jsp" />

            <div class="main-content">
                <jsp:include page="header.jsp"/>

                <div class="threshold-layout">
                    <div class="tech-left-panel">

                        <div class="tech-page-heading">
                            <div class="tech-title-icon">
                                <i class="fa-solid fa-screwdriver-wrench"></i>
                            </div>

                            <div>
                                <h1>Tech Configuration</h1>
                                <p>Direct database control for shelter comfort parameters</p>
                            </div>
                        </div>

                        <div class="logic-card-grid">

                            <div class="logic-mini-card heater-card">
                                <div class="logic-card-title">
                                    <span class="logic-icon"><i class="fa-solid fa-fire"></i></span>
                                    <div>
                                        <h3>Active Heater Logic</h3>
                                        <p>Hysteresis</p>
                                    </div>
                                </div>

                                <div class="logic-values two">
                                    <div>
                                        <span>Turns ON Below</span>
                                        <strong><%= sysConfig.getHeaterActivation()%>°C</strong>
                                    </div>

                                    <div>
                                        <span>Turns OFF Above</span>
                                        <strong><%= sysConfig.getHeaterCutoff()%>°C</strong>
                                    </div>
                                </div>

                                <img src="${pageContext.request.contextPath}/images/cat-heater.png"
                                     alt="Heater cat"
                                     class="logic-card-img heater-img">
                            </div>

                            <div class="logic-mini-card fan-card">
                                <div class="logic-card-title">
                                    <span class="logic-icon"><i class="fa-solid fa-fan"></i></span>
                                    <div>
                                        <h3>Active Fan & Ventilation Logic</h3>
                                        <p>Airflow rules</p>
                                    </div>
                                </div>

                                <div class="logic-values three">
                                    <div>
                                        <span>Heat Trigger</span>
                                        <strong><%= sysConfig.getFanActivationThreshold()%>°C</strong>
                                    </div>

                                    <div>
                                        <span>Humidity Trigger</span>
                                        <strong><%= sysConfig.getHumidityThreshold()%>%</strong>
                                    </div>

                                    <div>
                                        <span>Cut-Off Point</span>
                                        <strong><%= sysConfig.getFanCutoffThreshold()%>°C</strong>
                                    </div>
                                </div>

                                <img src="${pageContext.request.contextPath}/images/fan-cat.png"
                                     alt="Fan cat"
                                     class="logic-card-img fan-img">
                            </div>

                            <div class="logic-mini-card schedule-card">
                                <div class="logic-card-title">
                                    <span class="logic-icon"><i class="fa-solid fa-calendar-days"></i></span>
                                    <div>
                                        <h3>Active Schedule Logic</h3>
                                        <p>Night cycle</p>
                                    </div>
                                </div>

                                <div class="logic-values two">
                                    <div>
                                        <span>Night Mode Starts</span>
                                        <strong><%= String.format("%02d:00", sysConfig.getNightModeStart())%>:00</strong>
                                    </div>

                                    <div>
                                        <span>Day Mode Resumes</span>
                                        <strong><%= String.format("%02d:00", sysConfig.getNightModeEnd())%>:00</strong>
                                    </div>
                                </div>

                                <img src="${pageContext.request.contextPath}/images/calico-sleep.png"
                                     alt="Sleeping cat"
                                     class="logic-card-img sleep-img">
                            </div>

                        </div>

                        <div class="guide-card">
                            <div class="guide-title">
                                <i class="fa-solid fa-lightbulb"></i>
                                <h3>System Intelligence Guide</h3>
                                <span>🐾</span>
                            </div>

                            <div class="guide-grid">
                                <div class="guide-item">
                                    <h4>🚩 Triggers vs. Cut-offs</h4>
                                    <p>
                                        
                                        The <b>trigger</b> is the point where a device starts working. The <b>cut-off</b> is the point where it stops. 
                                        This gap helps the system avoid turning devices on and off too often.
                                    </p>
                                </div>

                                <div class="guide-item">
                                    <h4>🛡️ The Hysteresis Gap</h4>
                                    <p>
                                        A small 1–2°C gap keeps the heater or fan from switching on and off repeatedly when the temperature changes slightly.
                                    </p>
                                </div>

                                <div class="guide-item">
                                    <h4>🤝 Fan Co-dependency</h4>
                                    <p>
                                        The fan starts when the shelter is too warm or too humid, helping improve airflow and keep the shelter comfortable.
                                    </p>
                                </div>
                            </div>

                            <img src="${pageContext.request.contextPath}/images/peek-cat.png"
                                 alt="Peek cat"
                                 class="guide-peek-cat">
                        </div>

                    </div>

                    <div class="tech-right-panel">

                        <div class="override-card">
                            <form action="TechThresholdServlet" method="POST">

                                <div class="override-header">
                                    <div class="override-shield">
                                        <i class="fa-solid fa-paw"></i>
                                    </div>

                                    <div>
                                        <h3>System Override</h3>
                                        <p>Advanced parameter control board</p>
                                    </div>
                                </div>

                                <div class="override-form-box">

                                    <div class="admin-input-grid">
                                        <div class="admin-input-group">
                                            <label>Heater On Temp (°C)</label>
                                            <div class="input-with-icon">
                                                <i class="fa-solid fa-temperature-low"></i>
                                                <input type="number" step="0.1" name="heaterAct" value="<%= sysConfig.getHeaterActivation()%>" required>
                                            </div>
                                        </div>

                                        <div class="admin-input-group">
                                            <label>Heater Off Temp (°C)</label>
                                            <div class="input-with-icon">
                                                <i class="fa-solid fa-temperature-high"></i>
                                                <input type="number" step="0.1" name="heaterCut" value="<%= sysConfig.getHeaterCutoff()%>" required>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="section-divider"></div>

                                    <div class="admin-input-grid">
                                        <div class="admin-input-group">
                                            <label>Fan On Temp (°C)</label>
                                            <div class="input-with-icon">
                                                <i class="fa-solid fa-fan"></i>
                                                <input type="number" step="0.1" name="fanAct" value="<%= sysConfig.getFanActivationThreshold()%>" required>
                                            </div>
                                        </div>

                                        <div class="admin-input-group">
                                            <label>Fan Off Temp (°C)</label>
                                            <div class="input-with-icon">
                                                <i class="fa-solid fa-fan"></i>
                                                <input type="number" step="0.1" name="fanCut" value="<%= sysConfig.getFanCutoffThreshold()%>" required>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="admin-input-group full">
                                        <label>Humidity Override (%)</label>
                                        <div class="input-with-icon">
                                            <i class="fa-solid fa-droplet"></i>
                                            <input type="number" step="0.1" name="humThresh" value="<%= sysConfig.getHumidityThreshold()%>" required>
                                        </div>
                                    </div>

                                    <div class="section-divider strawberry-divider"></div>

                                    <div class="admin-input-grid">
                                        <div class="admin-input-group">
                                            <label>Night Mode Start</label>
                                            <div class="input-with-icon">
                                                <i class="fa-solid fa-moon"></i>
                                                <input type="number" name="nightStart" value="<%= sysConfig.getNightModeStart()%>" min="0" max="23" required>
                                            </div>
                                        </div>

                                        <div class="admin-input-group">
                                            <label>Night Mode End</label>
                                            <div class="input-with-icon">
                                                <i class="fa-solid fa-sun"></i>
                                                <input type="number" name="nightEnd" value="<%= sysConfig.getNightModeEnd()%>" min="0" max="23" required>
                                            </div>
                                        </div>
                                    </div>

                                </div>

                                <input type="hidden" name="lightDur" value="<%= sysConfig.getLightActiveDuration()%>">
                                <input type="hidden" name="safetyAlert" value="<%= sysConfig.getSafetyAlertTemp()%>">

                                <button type="submit" class="deploy-btn">
                                    Deploy Configuration
                                    <i class="fa-solid fa-cloud-arrow-up"></i>
                                </button>

                                <div class="safe-note">
                                    <i class="fa-solid fa-shield-heart"></i>
                                    Settings are validated before deployment. 🐾
                                </div>

                            </form>
                        </div>
                    </div>

                    <%
                        List<Notification> reviewRequests
                                = (List<Notification>) request.getAttribute("notifications");

                        Object pendingCountObj = request.getAttribute("pendingCount");
                        int pendingCount = 0;

                        if (pendingCountObj != null) {
                            try {
                                pendingCount = Integer.parseInt(pendingCountObj.toString());
                            } catch (Exception e) {
                                pendingCount = 0;
                            }
                        }
                    %>

                    <section class="tech-request-review-card">
                        <div class="tech-request-header">
                            <div class="tech-request-title-wrap">
                                <div class="tech-request-icon">
                                    <i class="fa-solid fa-clipboard-check"></i>
                                </div>

                                <div>
                                    <h2>Threshold Request Review</h2>
                                    <p>Review volunteer requests and update their approval status.</p>
                                </div>
                            </div>

                            <span class="pending-badge">
                                <i class="fa-solid fa-bell"></i>
                                <%= pendingCount%> Pending
                            </span>
                        </div>

                        <div class="tech-request-table-wrap">
                            <table class="tech-request-table">
                                <thead>
                                    <tr>
                                        <th>Request</th>
                                        <th>Parameter</th>
                                        <th>Value</th>
                                        <th>Reason</th>
                                        <th>Status</th>
                                        <th>Decision</th>
                                    </tr>
                                </thead>

                                <tbody>
                                    <% if (reviewRequests != null && !reviewRequests.isEmpty()) { %>

                                    <% for (Notification n : reviewRequests) {
                                            String currentStatus = n.getStatus() != null ? n.getStatus() : "PENDING";
                                            String statusClass = "review-" + currentStatus.toLowerCase();
                                    %>

                                    <tr>
                                        <td class="request-id-cell">#<%= n.getRequestId()%></td>

                                        <td>
                                            <strong><%= n.getSensorName()%></strong>
                                        </td>

                                        <td>
                                            <span class="request-value-pill">
                                                <%= n.getNewThreshold()%>°C
                                            </span>
                                        </td>

                                        <td class="request-reason-cell">
                                            <%= n.getReason()%>
                                        </td>

                                        <td>
                                            <span class="review-status-pill <%= statusClass%>">
                                                <%= currentStatus%>
                                            </span>
                                        </td>

                                        <td>
                                            <form action="TechThresholdServlet" method="POST" class="review-form">
                                                <input type="hidden" name="action" value="reviewRequest">
                                                <input type="hidden" name="requestId" value="<%= n.getRequestId()%>">

                                                <select name="decision" class="review-select">
                                                    <option value="PENDING" <%= "PENDING".equalsIgnoreCase(currentStatus) ? "selected" : ""%>>
                                                        Pending
                                                    </option>
                                                    <option value="APPROVED" <%= "APPROVED".equalsIgnoreCase(currentStatus) ? "selected" : ""%>>
                                                        Approved
                                                    </option>
                                                    <option value="DENIED" <%= "DENIED".equalsIgnoreCase(currentStatus) ? "selected" : ""%>>
                                                        Denied
                                                    </option>
                                                </select>

                                                <button type="submit" class="review-save-btn">
                                                    Save
                                                </button>
                                            </form>
                                        </td>
                                    </tr>

                                    <% } %>

                                    <% } else { %>

                                    <tr>
                                        <td colspan="6" class="empty-review">
                                            <div class="empty-review-state">
                                                <i class="fa-solid fa-mug-hot"></i>
                                                <h4>No threshold requests yet.</h4>
                                                <p>Volunteer requests will appear here once submitted.</p>
                                            </div>
                                        </td>
                                    </tr>

                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </section>
                </div> 

                <script>
                    // Clean URL after success modal shows
                    window.onload = function () {
                        if (window.location.search.includes('status=updated')) {
                            const cleanUrl = window.location.protocol + "//" + window.location.host + window.location.pathname;
                            window.history.replaceState({path: cleanUrl}, '', cleanUrl);
                        }
                    };
                    function toggleNotifPopup() {
                        const popup = document.getElementById('notifPopup');
                        if (popup.style.display === 'block') {
                            popup.style.display = 'none';
                        } else {
                            popup.style.display = 'block';
                        }
                    }

                    function toggleSidebar() {
                        const sidebar = document.getElementById('mySidebar');
                        const overlay = document.querySelector('.sidebar-overlay');

                        if (sidebar && overlay) {
                            sidebar.classList.toggle('active');
                            overlay.classList.toggle('active');
                        }
                    }

                    // Close popup if user clicks anywhere else
                    window.onclick = function (event) {
                        if (!event.target.matches('.fa-bell') && !event.target.closest('.notif-popup')) {
                            document.getElementById('notifPopup').style.display = 'none';
                        }
                    }
                </script>
                <% if ("updated".equals(status)) { %>
                <div id="successModal" class="modal" style="display:flex;">
                    <div class="modal-content" style="border-top:10px solid var(--card-green); background: var(--bg-cream); padding: 30px; border-radius: 20px; text-align: center;">
                        <div style="font-size:3rem; color: #4CAF50;"><i class="fa-solid fa-circle-check"></i></div>
                        <h2 style="font-family:'Comic Neue'; color:var(--card-green);">Database Updated</h2>
                        <p>New logic thresholds have been safely deployed to the shelter. Everything is ready to go! 🐾</p>
                        <button class="btn-close-modal" onclick="location.reload()">Acknowledge ✨</button>
                    </div>
                </div>
                <% }%>
            </div>
            <div id="notifPopup" class="notif-popup">
                <h4 style="margin: 0 0 10px 0; color: var(--active-pink); font-family: 'Comic Neue'; border-bottom: 2px solid var(--bg-pink); padding-bottom: 5px;">
                    Volunteer Requests 🐾
                </h4>

                <%
                    List<Notification> notifs = (List<Notification>) request.getAttribute("notifications");
                    if (notifs != null && !notifs.isEmpty()) {
                        for (Notification n : notifs) {
                %>
                <div class="notif-item">
                    <p style="margin: 0; font-size: 0.9rem;">
                        <b>User ID: <%= n.getUserId()%></b> wants to change 
                        <b><%= n.getSensorName()%></b> to <b><%= n.getNewThreshold()%></b>
                    </p>
                    <small style="color: #888;">Reason: <%= n.getReason()%></small>
                    <div class="notif-actions">
                        <a href="HandleNotificationServlet?action=approve&id=<%= n.getRequestId()%>" class="btn-approve" style="text-decoration:none;">Approve</a>
                        <a href="HandleNotificationServlet?action=deny&id=<%= n.getRequestId()%>" class="btn-deny" style="text-decoration:none;">Deny</a>
                    </div>
                </div>
                <%
                    }
                } else {
                %>
                <div style="text-align:center; padding:10px; color:#999;">
                    No new requests! ✨
                </div>
                <% }%>
            </div>
        </div> 
    </body>
</html>

