<%@page import="com.hirosumi.model.Notification"%>
<%@page import="java.util.List"%>
<%@page import="com.hirosumi.model.Configuration"%>
<%@page import="com.hirosumi.model.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
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
        <title>HiroSumi - Volunteer Portal</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Comic+Neue:wght@700&family=Quicksand:wght@500;700&display=swap" rel="stylesheet">

        <style>
            body {
                overflow-x: hidden;
                background-color: var(--bg-cream);
                margin: 0;
            }

            .dashboard-container {
                display: flex;
                width: 100%;
                min-height: 100vh;
            }

            .main-content {
                flex-grow: 1;
                height: 100vh;
                overflow-y: auto;
                display: flex;
                flex-direction: column;
                width: 100%;
                transition: margin-left 0.4s;
            }

            .volunteer-layout {
                display: flex;
                flex-direction: column;
                gap: 30px;
                padding: 30px 50px;
                width: 100%;
                max-width: 1200px; /* Keeps it from stretching too far on big screens */
                margin: 0 auto;
                box-sizing: border-box;
            }

            /* 🍵 LEVEL 1: Aesthetic Matcha Cards */
            .summary-row {
                display: flex;
                gap: 20px;
                width: 100%;
                flex-wrap: wrap;
            }

            .card-matcha {
                background: #f0f4ef !important;
                border: 2px solid #d8e2dc !important;
                border-radius: 25px !important;
                padding: 20px;
                box-shadow: 5px 5px 0px #a3b18a;
                position: relative;
                transition: transform 0.3s ease;
                flex: 1;
                min-width: 200px;
            }

            .card-matcha span {
                color: #6b8e23 !important;
                font-weight: bold;
                text-transform: uppercase;
                font-size: 0.75rem;
                letter-spacing: 1px;
            }

            .card-matcha .big-val {
                color: #4a6d4a !important;
                font-size: 1.8rem;
                font-weight: 800;
                font-family: 'Comic Neue', cursive;
                margin-top: 5px;
            }

            /* 🍓 LEVEL 2: Strawberry Form */
            /* 🍓 FIX THE FORM SIZE */
            .card-strawberry {
                background: #fff;
                border-radius: 25px;
                padding: 35px;
                border: 2px solid var(--active-pink);
                box-shadow: 0 10px 30px rgba(214, 90, 104, 0.1);

                width: 100%;
                max-width: 600px !important; /* Brings it back to the nice, compact size */
                margin: 0 auto !important;   /* Centers it in the middle of the screen */
                box-sizing: border-box;
            }

            /* Make the title slightly smaller so it doesn't push the form out */
            .card-strawberry h2 {
                font-size: 1.8rem !important;
                margin-bottom: 20px !important;
            }

            .request-table {
                width: 100%;
                border-collapse: separate;
                border-spacing: 0 10px;
            }

            .request-table th {
                background-color: #a3b18a;
                color: white;
                padding: 15px;
                text-align: left;
                border-radius: 10px;
            }

            .request-table td {
                background: white;
                padding: 15px;
                border-top: 1px solid #fce4ec;
                border-bottom: 1px solid #fce4ec;
            }

            .status-pending {
                color: #f39c12;
                font-weight: bold;
            }
            .status-approved {
                color: #27ae60;
                font-weight: bold;
            }
            .status-denied {
                color: #e74c3c;
                font-weight: bold;
            }

            .aesthetic-input {
                width: 100%;
                padding: 12px;
                border-radius: 15px;
                border: 2px solid #fce4ec;
                font-family: 'Quicksand';
                background-color: #fffafb;
            }

            .btn-submit-request {
                background-color: var(--active-pink);
                color: white;
                border: none;
                padding: 15px 30px;
                border-radius: 30px;
                width: 100%;
                font-weight: bold;
                font-size: 1.1rem;
                cursor: pointer;
                transition: 0.3s;
                margin-top: 10px;
            }

            .btn-submit-request:hover {
                transform: scale(1.02);
                filter: brightness(1.1);
            }

            /* Modal Styling */
            .modal {
                position: fixed;
                z-index: 9999;
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
                background: rgba(0,0,0,0.5);
                display: none;
                justify-content: center;
                align-items: center;
            }


            /* --- 🎀 SIDEBAR STYLES --- */
            .sidebar {
                position: fixed;
                top: 0;
                left: -280px; /* THIS MAKES IT START HIDDEN */
                width: 260px;
                height: 100vh;
                background-color: var(--bg-pink, #fce4ec);
                z-index: 1000;
                transition: left 0.4s cubic-bezier(0.68, -0.55, 0.27, 1.55);
                box-shadow: 5px 0 15px rgba(0,0,0,0.1);
            }
            .sidebar.active {
                left: 0; /* THIS MAKES IT SLIDE IN */
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
        </style>
    </head>

    <body>
        <div class="sidebar-overlay" onclick="toggleSidebar()"></div>

        <div class="dashboard-container">
            <jsp:include page="sidebar.jsp"/> 

            <div class="main-content">

                <jsp:include page="header.jsp"/>

                <div class="volunteer-layout">

                    <div class="summary-row">
                        <div class="card-matcha">
                            <span>Heater Activation</span>
                            <div class="big-val"><%= sysConfig.getHeaterActivation()%>°C</div>
                            <i class="fa-solid fa-fire" style="position:absolute; bottom:15px; right:20px; opacity:0.1; font-size: 2rem;"></i>
                        </div>
                        <div class="card-matcha">
                            <span>Fan Activation</span>
                            <div class="big-val"><%= sysConfig.getFanActivationThreshold()%>°C</div>
                            <i class="fa-solid fa-fan" style="position:absolute; bottom:15px; right:20px; opacity:0.1; font-size: 2rem;"></i>
                        </div>
                        <div class="card-matcha">
                            <span>Humidity Limit</span>
                            <div class="big-val"><%= sysConfig.getHumidityThreshold()%>%</div>
                            <i class="fa-solid fa-droplet" style="position:absolute; bottom:15px; right:20px; opacity:0.1; font-size: 2rem;"></i>
                        </div>
                    </div>

                    <div class="card-strawberry">
                        <form action="SubmitThresholdRequestServlet" method="POST">
                            <h2 style="text-align:center; font-family:'Comic Neue'; color:var(--active-pink); margin-bottom: 25px;"><h2 style="text-align:center; font-family:'Comic Neue'; color:var(--active-pink); margin-bottom: 25px;">
                                    <i class="fa-solid fa-pen-to-square"></i> Request a System Change
                                </h2>

                                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                                    <div>
                                        <label style="font-weight:bold; color: #555;">PARAMETER</label>
                                        <select name="sensorName" class="aesthetic-input" style="margin-top: 8px;">
                                            <option value="Heater Trigger">Heater Activation</option>
                                            <option value="Heater Cutoff">Heater Cut-off</option>
                                            <option value="Fan Trigger">Fan Activation</option>
                                            <option value="Humidity Limit">Humidity Threshold</option>
                                        </select>
                                    </div>
                                    <div>
                                        <label style="font-weight:bold; color: #555;">PROPOSED VALUE</label>
                                        <input type="number" step="0.1" name="proposedValue" class="aesthetic-input" style="margin-top: 8px;" required>
                                    </div>
                                </div>

                                <div style="margin-top: 20px; margin-bottom: 20px;">
                                    <label style="font-weight:bold; color: #555;">JUSTIFICATION</label>
                                    <textarea name="reason" class="aesthetic-input" rows="3" style="margin-top: 8px;" placeholder="Describe why this change helps the cats..."></textarea>
                                </div>

                                <button type="submit" class="btn-submit-request">
                                    Send to Technician <i class="fa-solid fa-paper-plane" style="margin-left: 10px;"></i>
                                </button>
                        </form>
                    </div>

                    <div style="margin-top: 10px; margin-bottom: 50px;">
                        <h3 style="font-family:'Comic Neue'; color:#4a6d4a;">
                            <i class="fa-solid fa-clock-rotate-left"></i> My Request History
                        </h3>
                        <table class="request-table">
                            <thead>
                                <tr>
                                    <th>Sensor</th>
                                    <th>Proposed Value</th>
                                    <th>Justification</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    List<Notification> myRequests = (List<Notification>) request.getAttribute("userRequests");
                                    if (myRequests != null && !myRequests.isEmpty()) {
                                        for (Notification r : myRequests) {
                                            String s = (r.getStatus() != null) ? r.getStatus() : "PENDING";
                                            String statusClass = "status-" + s.toLowerCase();
                                %>
                                <tr>
                                    <td style="font-weight: bold;"><%= r.getSensorName()%></td>
                                    <td><%= r.getNewThreshold()%>°C</td>
                                    <td style="color: #666; font-size: 0.9rem;"><%= r.getReason()%></td>
                                    <td class="<%= statusClass%>">
                                        <span style="padding: 6px 12px; border-radius: 20px; background: #f8f9fa; border: 1px solid #ddd;">
                                            <%= s%>
                                        </span>
                                    </td>
                                </tr>
                                <%
                                    }
                                } else {
                                %>
                                <tr>
                                    <td colspan="4" style="text-align:center; padding: 40px; color:#999; background: #fff; border-radius: 20px;">
                                        No request history yet. 🌸
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div> 

                <% if ("success".equals(status)) { %>
                <div id="successModal" class="modal" style="display:flex;">
                    <div class="modal-content" style="background: white; padding: 40px; border-radius: 25px; text-align: center; border-top: 10px solid #a3b18a;">
                        <div style="font-size:3rem;">🍵🍓</div>
                        <h2 style="font-family:'Comic Neue'; color:#4a6d4a;">Request Sent!</h2>
                        <p>The technician will review your proposal shortly.</p>
                        <button onclick="document.getElementById('successModal').style.display = 'none'"
                                style="width:100%; padding:15px; margin-top:10px; background:#a3b18a; border-radius: 30px; border: none; color: white; font-weight: bold; cursor: pointer;">Got it!</button>
                    </div>
                </div>
                <% }%>
            </div>
        </div>

        <script>
            // Sidebar Toggle
            function toggleSidebar() {
                // Look for the class '.sidebar' instead of the ID
                const sidebar = document.querySelector('.sidebar');
                const overlay = document.querySelector('.sidebar-overlay');

                if (sidebar) {
                    sidebar.classList.toggle('active');
                }
                if (overlay) {
                    overlay.classList.toggle('active');
                }
            }
            // URL Cleanup
            window.onload = function () {
                if (window.location.search.includes('status=success')) {
                    const cleanUrl = window.location.protocol + "//" + window.location.host + window.location.pathname;
                    window.history.replaceState({path: cleanUrl}, '', cleanUrl);
                }
            };
        </script>
    </body>
</html>