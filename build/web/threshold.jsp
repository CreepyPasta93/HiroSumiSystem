<%@page import="com.hirosumi.model.Notification"%>
<%@page import="java.util.List"%>
<%@page import="com.hirosumi.model.Configuration"%>
<%@page import="com.hirosumi.model.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    /*
        ==========================================================
        PAGE DATA SETUP
        ==========================================================
        This page allows volunteers/members to:
        1. View current threshold settings.
        2. Submit threshold change requests.
        3. View their request history.

        Required request attributes from ThresholdServlet:
        - config
        - userRequests
     */
    User currentUser = (User) session.getAttribute("currentUser");

    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Configuration sysConfig = (Configuration) request.getAttribute("config");

    if (sysConfig == null) {
        response.sendRedirect("ThresholdServlet");
        return;
    }

    String status = request.getParameter("status");
%>

<!DOCTYPE html>
<html>
    <head>
        <title>HiroSumi - Threshold Request Portal</title>

        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <!-- Global project styles -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard-custom.css">

        <!-- Page-specific styles -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/threshold.css">

        <!-- Font Awesome -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

        <!-- Fonts -->
        <link href="https://fonts.googleapis.com/css2?family=Comic+Neue:wght@700&family=Quicksand:wght@500;600;700;800;900&display=swap" rel="stylesheet">
    </head>

    <body class="threshold-page">

        <!-- Sidebar open button -->
        <button class="sidebar-open-btn" type="button" onclick="toggleSidebar()">
            <i class="fa-solid fa-bars"></i>
        </button>

        <!-- Sidebar overlay -->
        <div class="sidebar-overlay" onclick="toggleSidebar()"></div>

        <div class="dashboard-container">

            <%
                /*
                    Highlight Threshold page in shared sidebar.
                 */
                request.setAttribute("activePage", "threshold");
            %>
            <jsp:include page="sidebar.jsp" />

            <main class="main-content">

                <!-- Shared header -->
                <jsp:include page="header.jsp" />

                <section class="threshold-layout">

                    <!-- ===================================================== -->
                    <!-- PAGE HEADING -->
                    <!-- ===================================================== -->
                    <div class="threshold-page-heading">

                        <div class="threshold-title-icon">
                            <i class="fa-solid fa-bell"></i>
                        </div>

                        <div class="threshold-title-copy">
                            <h1>Threshold Request Portal</h1>
                            <p>
                                View current shelter comfort settings and request changes for technician approval
                                <span>🐾</span>
                            </p>
                        </div>
                    </div>

                    <!-- ===================================================== -->
                    <!-- CURRENT THRESHOLD SUMMARY CARDS -->
                    <!-- ===================================================== -->
                    <div class="summary-row">

                        <article class="summary-card summary-heater">
                            <div class="summary-icon">
                                <i class="fa-solid fa-fire"></i>
                            </div>

                            <div class="summary-content">
                                <span class="summary-label">Heater Activation</span>
                                <strong class="summary-value">
                                    <%= String.format("%.1f", sysConfig.getHeaterActivation())%>°C
                                </strong>
                                <p>Turns on when the shelter temperature becomes too low.</p>
                            </div>

                            <span class="summary-paw">🐾</span>
                        </article>

                        <article class="summary-card summary-fan">
                            <div class="summary-icon">
                                <i class="fa-solid fa-fan"></i>
                            </div>

                            <div class="summary-content">
                                <span class="summary-label">Fan Activation</span>
                                <strong class="summary-value">
                                    <%= String.format("%.1f", sysConfig.getFanActivationThreshold())%>°C
                                </strong>
                                <p>Starts airflow when the shelter becomes too warm.</p>
                            </div>

                            <span class="summary-paw">🐾</span>
                        </article>

                        <article class="summary-card summary-humidity">
                            <div class="summary-icon">
                                <i class="fa-solid fa-droplet"></i>
                            </div>

                            <div class="summary-content">
                                <span class="summary-label">Humidity Limit</span>
                                <strong class="summary-value">
                                    <%= String.format("%.1f", sysConfig.getHumidityThreshold())%>%
                                </strong>
                                <p>Keeps air fresh and helps prevent damp shelter conditions.</p>
                            </div>

                            <span class="summary-paw">🐾</span>
                        </article>

                    </div>

                    <!-- ===================================================== -->
                    <!-- FORM + HISTORY TWO-COLUMN SECTION -->
                    <!-- ===================================================== -->
                    <div class="threshold-workspace">

                        <!-- ========================= -->
                        <!-- REQUEST FORM CARD -->
                        <!-- ========================= -->
                        <section class="request-card">

                            <form action="SubmitThresholdRequestServlet" method="POST">

                                <div class="request-card-header">
                                    <div class="request-icon">
                                        <i class="fa-solid fa-pen-to-square"></i>
                                    </div>

                                    <div>
                                        <h2>Request a System Change</h2>
                                        <p>Suggest safer comfort settings for the shelter cats 🍓</p>
                                    </div>
                                </div>

                                <div class="request-form-grid">

                                    <div class="form-group">
                                        <label class="threshold-label" for="sensorName">Parameter</label>

                                        <select id="sensorName" name="sensorName" class="aesthetic-input" required>
                                            <option value="Heater Trigger">Heater Activation</option>
                                            <option value="Heater Cutoff">Heater Cut-off</option>
                                            <option value="Fan Trigger">Fan Activation</option>
                                            <option value="Humidity Limit">Humidity Threshold</option>
                                        </select>
                                    </div>

                                    <div class="form-group">
                                        <label class="threshold-label" for="proposedValue">Proposed Value</label>

                                        <input
                                            id="proposedValue"
                                            type="number"
                                            step="0.1"
                                            name="proposedValue"
                                            class="aesthetic-input"
                                            placeholder="Example: 28.0"
                                            required
                                            >
                                    </div>

                                </div>

                                <div class="form-group reason-group">
                                    <label class="threshold-label" for="reason">Justification</label>

                                    <textarea
                                        id="reason"
                                        name="reason"
                                        class="aesthetic-input"
                                        rows="4"
                                        placeholder="Describe why this change helps the cats..."
                                        ></textarea>
                                </div>

                                <button type="submit" class="btn-submit-request">
                                    <i class="fa-solid fa-paper-plane"></i>
                                    <span>Send to Technician</span>
                                    <span class="btn-paw">🐾</span>
                                </button>

                            </form>

                        </section>

                        <!-- ========================= -->
                        <!-- REQUEST HISTORY CARD -->
                        <!-- ========================= -->
                        <section class="history-card">

                            <div class="history-header">
                                <div class="history-title-wrap">
                                    <div class="history-icon">
                                        <i class="fa-solid fa-clipboard-list"></i>
                                    </div>

                                    <div>
                                        <h3>My Request History</h3>
                                        <p>Track your threshold requests and technician responses</p>
                                    </div>
                                </div>

                                <span class="history-badge">
                                    <i class="fa-solid fa-paw"></i>
                                    Volunteer Log
                                </span>
                            </div>

                            <div class="request-table-wrapper">

                                <table class="request-table">
                                    <thead>
                                        <tr>
                                            <th>Sensor</th>
                                            <th>Proposed Value</th>
                                            <th>Status</th>
                                            <th>Reason</th>
                                        </tr>
                                    </thead>

                                    <tbody>
                                        <%
                                            List<Notification> myRequests = (List<Notification>) request.getAttribute("userRequests");

                                            if (myRequests != null && !myRequests.isEmpty()) {
                                                for (Notification r : myRequests) {
                                                    String requestStatus = (r.getStatus() != null) ? r.getStatus() : "PENDING";
                                                    String statusClass = "status-" + requestStatus.toLowerCase();
                                        %>

                                        <tr>
                                            <td class="sensor-name"><%= r.getSensorName()%></td>
                                            <td><%= r.getNewThreshold()%>°C</td>
                                            <td>
                                                <span class="status-pill <%= statusClass%>">
                                                    <%= requestStatus%>
                                                </span>
                                            </td>
                                            <td class="reason-text"><%= r.getReason()%></td>
                                        </tr>

                                        <%
                                            }
                                        } else {
                                        %>

                                        <tr>
                                            <td colspan="4" class="empty-history">
                                                <div class="empty-state">
                                                    <img
                                                        src="${pageContext.request.contextPath}/images/eepy-cat.png"
                                                        alt="Sleeping cat"
                                                        class="empty-cat"
                                                        >

                                                    <h4>No requests yet.</h4>
                                                    <p>Your requests will appear here.</p>
                                                </div>
                                            </td>
                                        </tr>

                                        <% }%>
                                    </tbody>
                                </table>

                            </div>
                        </section>

                    </div>

                </section>

            </main>

        </div>

        <!-- ===================================================== -->
        <!-- SUCCESS MODAL -->
        <!-- ===================================================== -->
        <% if ("success".equals(status)) { %>
        <div id="successModal" class="modal success-modal-show">
            <div class="modal-content">
                <div class="modal-emoji">🍵🍓</div>

                <h2>Request Sent!</h2>

                <p>The technician will review your proposal shortly.</p>

                <button type="button" onclick="closeSuccessModal()">
                    Got it!
                </button>
            </div>
        </div>
        <% }%>

        <!-- ===================================================== -->
        <!-- PAGE JAVASCRIPT -->
        <!-- ===================================================== -->
        <script>
            function toggleSidebar() {
                const sidebar = document.getElementById('mySidebar');
                const overlay = document.querySelector('.sidebar-overlay');

                if (sidebar && overlay) {
                    sidebar.classList.toggle('active');
                    overlay.classList.toggle('active');
                }
            }

            function closeSuccessModal() {
                const modal = document.getElementById('successModal');

                if (modal) {
                    modal.style.display = 'none';
                }
            }

            window.onload = function () {
                if (window.location.search.includes('status=success')) {
                    const cleanUrl = window.location.protocol + "//" + window.location.host + window.location.pathname;
                    window.history.replaceState({path: cleanUrl}, '', cleanUrl);
                }
            };
        </script>

    </body>
</html>