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
        <title>HiroSumi - Threshold Configuration</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Comic+Neue:wght@700&family=Quicksand:wght@500;700&display=swap" rel="stylesheet">

        <style>
            /* 🛠️ LAYOUT FIXES - FORCING FULL WIDTH */
            body {
                overflow: hidden;
                background-color: var(--bg-cream);
                margin: 0;
            }

            /* 🛠️ HEADER WIDTH FIX */
            .main-content > *:first-child {
                width: 90% !important;
                flex-shrink: 0; /* Prevents the flex container from squishing it */
            }

            .dashboard-container {
                display: flex;
                width: 100%;
                height: 100vh;
            }

            .main-content {
                flex-grow: 1;
                height: 100vh;
                overflow-y: auto;
                display: flex;
                flex-direction: column;
                width: 100%; /* Ensure it takes up all space next to sidebar */
            }

            /* This overrides the center-limiting code in style.css */
            .threshold-layout {
                display: grid;
                grid-template-columns: 1fr 450px; /* Left side grows, right side stays fixed */
                gap: 40px;
                padding: 30px 50px; /* Matches your other dashboard pages */
                width: 100% !important;
                max-width: none !important; /* Removes the 1200px limit */
                margin: 0 !important; /* Removes the centering */
                box-sizing: border-box;
            }

            /* Ensures cards don't collapse */
            .logic-section {
                min-width: 0;
            }

            /* Control Panel Card Re-fix */
            .card-strawberry {
                position: relative;
                overflow: hidden !important;
                background: rgba(255, 248, 240, 0.9) !important;
                z-index: 1;
                padding: 30px;
                border-radius: 20px;
                width: 100%; /* Take full width of its 450px column */
                box-sizing: border-box;
            }

            /* 🎨 SIDEBAR STYLES (Keep as is) */
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

            .modal {
                position: fixed;
                z-index: 2000;
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
                background-color: rgba(0,0,0,0.5);
                display: none;
                justify-content: center;
                align-items: center;
            }
            .modal-content {
                width: 90%;
                max-width: 400px;
                margin: auto;
            }

            /* ✨ BUTTON HOVER ANIMATIONS */
            .action-card {
                transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1) !important;
                cursor: pointer;
                position: relative;
                top: 0;
            }

            /* This makes the button rise up and glow slightly when hovered */
            .action-option:hover .action-card {
                transform: translateY(-5px); /* This is the "rise up" effect */
                box-shadow: 0 10px 15px rgba(214, 90, 104, 0.15); /* Soft shadow beneath */
                background: #fff0f3 !important; /* Very soft strawberry tint */
                border-color: var(--active-pink) !important;
            }

            /* Subtle color change for the text on hover */
            .action-option:hover .action-card {
                color: var(--active-pink);
            }

            /* If the button is ALREADY checked, we make it pulse slightly instead of just rising */
            .action-option input:checked + .action-card:hover {
                transform: translateY(-3px) scale(1.02);
                filter: brightness(1.1); /* Makes the pink pop more */
            }

            .btn-submit-request {
                transition: transform 0.3s ease, box-shadow 0.3s ease;
            }

            .btn-submit-request:hover {
                transform: translateY(-3px);
                box-shadow: 0 12px 25px rgba(214, 90, 104, 0.4);
            }
        </style>
    </head>

    <body>
        <div class="sidebar-overlay" onclick="toggleSidebar()"></div>

        <div class="dashboard-container">
            <div class="sidebar" id="mySidebar">
                <img src="${pageContext.request.contextPath}/images/logo_dark.png" alt="HiroSumi" class="sidebar-logo">
                <div style="text-align: right; padding-right: 20px;">
                    <i class="fa-solid fa-xmark" onclick="toggleSidebar()" style="cursor: pointer; font-size: 1.5rem; color: #880E4F;"></i>
                </div>
                <div class="nav-menu">
                    <a href="DashboardServlet" class="nav-item"><i class="fa-solid fa-table-columns"></i> <span>Dashboard</span></a>
                    <a href="AnalyticsServlet" class="nav-item"><i class="fa-solid fa-chart-line"></i> <span>Analytics</span></a>
                    <a href="SystemLogServlet" class="nav-item"><i class="fa-solid fa-file-lines"></i> <span>System Logs</span></a>
                    <a href="ThresholdServlet" class="nav-item active"><i class="fa-solid fa-triangle-exclamation"></i> <span>Threshold</span></a>
                    <a href="ProfileServlet" class="nav-item"><i class="fa-solid fa-gear"></i> <span>Settings</span></a>
                </div>
                <div class="bottom-menu" style="padding: 20px;">
                    <a href="logout.jsp" class="nav-item"><i class="fa-solid fa-right-from-bracket"></i> <span>Log Out</span></a>
                </div>
            </div>

            <div class="main-content">
                <jsp:include page="header.jsp"/>

                <div class="threshold-layout">
                    <div class="logic-section">
                        <h1 style="font-family:'Comic Neue'; color:var(--text-dark); font-size: 2.8rem; margin: 0 0 5px 0; display: flex; align-items: center;">
                            <i class="fa-solid fa-microchip" style="color: #D65A68; font-size: 2.2rem; margin-right: 15px;"></i> System Logic
                        </h1>                      
                        <p style="color:var(--text-dark); opacity:0.7; margin: 0 0 35px 5px;">How HiroSumi keeps the cats cozy 🍵</p>

                        <div class="card-matcha">
                            <div class="section-title"><i class="fa-solid fa-snowflake"></i> Cold Trigger</div>
                            <div class="logic-context">
                                <strong>LOGIC</strong> Heater activates automatically when temperature drops below this set point.
                            </div>
                            <div class="rule-value-box">
                                <span class="stat-label">Activation Point</span>
                                <span class="big-stat" style="font-size:2rem; font-weight:800;">Below <%= sysConfig.getHeaterActivation()%>°C</span>
                            </div>
                        </div>

                        <div class="card-matcha" style="margin-top: 25px;">
                            <div class="section-title"><i class="fa-solid fa-fire-burner"></i> Warm Target</div>
                            <div class="logic-context">
                                <strong>LOGIC</strong> Heater stops operating once target temperature is reached.
                            </div>
                            <div class="rule-value-box">
                                <span class="stat-label">Cut-Off Point</span>
                                <span class="big-stat" style="font-size:2rem; font-weight:800;"><%= sysConfig.getHeaterCutoff()%>°C</span>
                            </div>
                        </div>
                    </div>

                    <div class="control-section">
                        <div class="card-strawberry">
                            <form action="ThresholdServlet" method="POST" style="position:relative; z-index:2; width: 100%;">
                                <h3 style="text-align:center; font-family:'Comic Neue'; color:var(--active-pink); margin-bottom:25px; font-size: 1.8rem;">
                                    <i class="fa-solid fa-sliders"></i> Control Panel
                                </h3>

                                <label class="control-group-title" style="display:block; text-align:center; margin-bottom:12px; font-weight:bold; letter-spacing: 1px;">HEATER OVERRIDE</label>
                                <div class="action-grid" style="display:grid; grid-template-columns: 1fr 1fr; gap:15px; margin-bottom:25px;">
                                    <label class="action-option">
                                        <input type="checkbox" name="actions" value="Switch On Heater" id="heatOn" onchange="checkConflict('heatOn', 'heatOff')" style="display:none;">
                                        <div class="action-card" style="text-align:center; cursor:pointer;">Force ON</div>
                                    </label>
                                    <label class="action-option">
                                        <input type="checkbox" name="actions" value="Switch Off Heater" id="heatOff" onchange="checkConflict('heatOff', 'heatOn')" style="display:none;">
                                        <div class="action-card" style="text-align:center; cursor:pointer;">Force OFF</div>
                                    </label>
                                </div>

                                <label class="control-group-title" style="display:block; text-align:center; margin-bottom:12px; font-weight:bold; letter-spacing: 1px;">LIGHT OVERRIDE</label>
                                <div class="action-grid" style="display:grid; grid-template-columns: 1fr 1fr; gap:15px; margin-bottom:25px;">
                                    <label class="action-option">
                                        <input type="checkbox" name="actions" value="Switch On Lights" id="lightOn" onchange="checkConflict('lightOn', 'lightOff')" style="display:none;">
                                        <div class="action-card" style="text-align:center; cursor:pointer;">Force ON</div>
                                    </label>
                                    <label class="action-option">
                                        <input type="checkbox" name="actions" value="Switch Off Lights" id="lightOff" onchange="checkConflict('lightOff', 'lightOn')" style="display:none;">
                                        <div class="action-card" style="text-align:center; cursor:pointer;">Force OFF</div>
                                    </label>
                                </div>

                                <label style="display:block; margin-bottom:8px; font-weight:bold; color: var(--text-dark);">MODIFY THRESHOLD</label>
                                <input type="text" name="newLimit" class="aesthetic-input" placeholder="New Temperature (e.g. 26.5)">

                                <label style="display:block; margin-bottom:8px; font-weight:bold; color: var(--text-dark);">JUSTIFICATION</label>
                                <textarea name="reason" class="aesthetic-input" rows="3" placeholder="Reason for admin approval..." style="margin-bottom: 25px;"></textarea>

                                <button type="submit" class="btn-submit-request">
                                    Submit Request <i class="fa-solid fa-paper-plane" style="margin-left: 10px;"></i>
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>

            <div id="alertModal" class="modal">
                <div class="modal-content" style="border-top:10px solid #EF5350; background: var(--bg-cream); padding: 30px; border-radius: 20px; text-align: center;">
                    <div style="font-size:2.2rem;">🚫</div>
                    <h3 style="font-family:'Comic Neue'; color:#C62828;">Action Conflict</h3>
                    <p>You cannot select Force ON and Force OFF at the same time.</p>
                    <button onclick="document.getElementById('alertModal').style.display = 'none'"
                            class="btn-apply" style="width:100%; padding:15px; margin-top:10px; border-radius: 30px; border: none; background: #EF5350; color: white; font-weight: bold; cursor: pointer;">Understood</button>
                </div>
            </div>

            <% if ("success".equals(status)) { %>
            <div id="successModal" class="modal" style="display:flex;">
                <div class="modal-content" style="border-top:10px solid var(--card-green); background: var(--bg-cream); padding: 30px; border-radius: 20px; text-align: center;">
                    <div style="font-size:4rem;">🍵🍓</div>
                    <h2 style="font-family:'Comic Neue'; color:var(--card-green);">Request Sent!</h2>
                    <p>The admin has been notified.</p>
                    <button onclick="document.getElementById('successModal').style.display = 'none'"
                            class="btn-apply" style="width:100%; padding:15px; margin-top:10px; background:var(--card-green); border-radius: 30px; border: none; color: white; font-weight: bold; cursor: pointer;">Awesome</button>
                </div>
            </div>
            <% }%>
        </div>

        <script>
            // 🐾 NEW: Clean the URL on page load to prevent modal on refresh
            window.onload = function () {
                if (window.location.search.includes('status=success')) {
                    // This removes the "?status=success" from the URL without reloading the page
                    const cleanUrl = window.location.protocol + "//" + window.location.host + window.location.pathname;
                    window.history.replaceState({path: cleanUrl}, '', cleanUrl);
                }
            };

            function toggleSidebar() {
                const sidebar = document.getElementById('mySidebar');
                const overlay = document.querySelector('.sidebar-overlay');
                sidebar.classList.toggle('active');
                overlay.classList.toggle('active');
            }

            function checkConflict(currentId, conflictId) {
                const current = document.getElementById(currentId);
                const conflict = document.getElementById(conflictId);
                if (current.checked && conflict.checked) {
                    current.checked = false;
                    document.getElementById("alertModal").style.display = "flex";
                }
            }
        </script>
    </body>
</html>