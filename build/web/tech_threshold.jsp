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
        response.sendRedirect("TechThresholdServlet");
        return;
    }

    String status = request.getParameter("status");
%>

<!DOCTYPE html>
<html>
    <head>
        <title>HiroSumi - Admin Control</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Comic+Neue:wght@700&family=Quicksand:wght@500;700&display=swap" rel="stylesheet">

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

            .header-area {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 10px;
            }

            body {
                overflow: hidden;
                background-color: var(--bg-cream);
                margin: 0;
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
                width: 100%;
            }
            .threshold-layout {
                display: grid;
                grid-template-columns: 1fr 500px;
                gap: 40px;
                padding: 30px 50px;
                width: 100% !important;
                max-width: none !important;
                margin: 0 !important;
                box-sizing: border-box;
            }
            .logic-section {
                min-width: 0;
            }
            .card-strawberry {
                position: relative;
                overflow: hidden !important;
                background: rgba(255, 248, 240, 0.9) !important;
                z-index: 1;
                padding: 30px;
                border-radius: 20px;
                width: 100%;
                box-sizing: border-box;
                border: 2px solid var(--active-pink);
            }

            /* Admin Panel Specific Styles */
            .admin-input-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 15px;
                margin-bottom: 20px;
            }
            .admin-input-group label {
                display: block;
                font-size: 0.85rem;
                font-weight: bold;
                color: var(--text-dark);
                margin-bottom: 5px;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }
            .admin-input-group input {
                width: 100%;
                box-sizing: border-box;
                padding: 10px;
                border-radius: 10px;
                border: 1px solid #ccc;
                font-family: 'Quicksand', sans-serif;
                font-weight: 700;
                color: #444;
            }
            .admin-input-group input:focus {
                outline: none;
                border-color: var(--active-pink);
                box-shadow: 0 0 5px rgba(214, 90, 104, 0.3);
            }
            .section-divider {
                border-bottom: 2px dashed #f0d0d4;
                margin: 25px 0;
            }
            .modal {
                position: fixed; /* 🐾 FIX: Ensures it stays on top of the whole screen */
                z-index: 9999; /* Higher than sidebar */
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
                background-color: rgba(0, 0, 0, 0.5); /* Semi-transparent dark background */
                display: none; /* Hidden by default */
                justify-content: center;
                align-items: center;
            }

            .modal-content {
                background: var(--bg-cream);
                padding: 40px;
                border-radius: 20px;
                width: 90%;
                max-width: 450px; /* Perfect size for a pop-up */
                box-shadow: 0 20px 40px rgba(0,0,0,0.2);
                text-align: center;
                animation: popIn 0.3s cubic-bezier(0.68, -0.55, 0.27, 1.55);
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
        <div class="dashboard-container">
            <jsp:include page="sidebar.jsp"/> 

            <div class="main-content">
                <jsp:include page="header.jsp"/>

                <div class="threshold-layout">
                    <div class="logic-section">
                        <h1 style="font-family:'Comic Neue'; color:var(--text-dark); font-size: 2.8rem; margin: 0 0 5px 0; display: flex; align-items: center;">
                            <i class="fa-solid fa-wrench" style="color: #4CAF50; font-size: 2.2rem; margin-right: 15px;"></i> Tech Configuration
                        </h1>                      
                        <p style="color:var(--text-dark); opacity:0.7; margin: 0 0 35px 5px;">Direct database control for shelter parameters 🍓</p>

                        <div class="card-matcha" style="margin-bottom: 20px;">
                            <div class="section-title"><i class="fa-solid fa-fire"></i> Active Heater Logic (Hysteresis)</div>
                            <div style="display: flex; justify-content: space-between; margin-top: 15px;">
                                <div>
                                    <span style="font-size: 0.9rem; opacity: 0.8;">Turns ON Below</span><br>
                                    <span style="font-size: 1.8rem; font-weight: 800;"><%= sysConfig.getHeaterActivation()%>°C</span>
                                </div>
                                <div style="text-align: right;">
                                    <span style="font-size: 0.9rem; opacity: 0.8;">Turns OFF Above</span><br>
                                    <span style="font-size: 1.8rem; font-weight: 800;"><%= sysConfig.getHeaterCutoff()%>°C</span>
                                </div>
                            </div>
                        </div>

                        <div class="card-matcha" style="margin-bottom: 20px;">
                            <div class="section-title"><i class="fa-solid fa-fan"></i> Active Fan & Ventilation Logic</div>
                            <div style="display: flex; justify-content: space-between; margin-top: 15px;">
                                <div>
                                    <span style="font-size: 0.9rem; opacity: 0.8;">Heat Trigger</span><br>
                                    <span style="font-size: 1.8rem; font-weight: 800;"><%= sysConfig.getFanActivationThreshold()%>°C</span>
                                </div>
                                <div style="text-align: center;">
                                    <span style="font-size: 0.9rem; opacity: 0.8;">Humidity Trigger</span><br>
                                    <span style="font-size: 1.8rem; font-weight: 800;"><%= sysConfig.getHumidityThreshold()%>%</span>
                                </div>
                                <div style="text-align: right;">
                                    <span style="font-size: 0.9rem; opacity: 0.8;">Cut-Off Point</span><br>
                                    <span style="font-size: 1.8rem; font-weight: 800;"><%= sysConfig.getFanCutoffThreshold()%>°C</span>
                                </div>
                            </div>
                        </div>

                        <div class="card-matcha">
                            <div class="section-title"><i class="fa-solid fa-moon"></i> Active Schedule Logic</div>
                            <div style="display: flex; justify-content: space-between; margin-top: 15px;">
                                <div>
                                    <span style="font-size: 0.9rem; opacity: 0.8;">Night Mode Starts</span><br>
                                    <span style="font-size: 1.8rem; font-weight: 800;"><%= sysConfig.getNightModeStart()%>:00</span>
                                </div>
                                <div style="text-align: right;">
                                    <span style="font-size: 0.9rem; opacity: 0.8;">Day Mode Resumes</span><br>
                                    <span style="font-size: 1.8rem; font-weight: 800;">0<%= sysConfig.getNightModeEnd()%>:00</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="control-section">
                        <div class="card-strawberry">
                            <form action="TechThresholdServlet" method="POST">
                                <h3 style="text-align:center; font-family:'Comic Neue'; color:var(--active-pink); margin-bottom:20px; font-size: 1.8rem;">
                                    <i class="fa-solid fa-server"></i> System Override
                                </h3>

                                <div class="admin-input-grid">
                                    <div class="admin-input-group">
                                        <label>Heater ON Temp (°C)</label>
                                        <input type="number" step="0.1" name="heaterAct" value="<%= sysConfig.getHeaterActivation()%>" required>
                                    </div>
                                    <div class="admin-input-group">
                                        <label>Heater OFF Temp (°C)</label>
                                        <input type="number" step="0.1" name="heaterCut" value="<%= sysConfig.getHeaterCutoff()%>" required>
                                    </div>
                                </div>

                                <div class="section-divider"></div>

                                <div class="admin-input-grid">
                                    <div class="admin-input-group">
                                        <label>Fan ON Temp (°C)</label>
                                        <input type="number" step="0.1" name="fanAct" value="<%= sysConfig.getFanActivationThreshold()%>" required>
                                    </div>
                                    <div class="admin-input-group">
                                        <label>Fan OFF Temp (°C)</label>
                                        <input type="number" step="0.1" name="fanCut" value="<%= sysConfig.getFanCutoffThreshold()%>" required>
                                    </div>
                                </div>
                                <div class="admin-input-group" style="margin-bottom: 20px;">
                                    <label>Humidity Override (%)</label>
                                    <input type="number" step="0.1" name="humThresh" value="<%= sysConfig.getHumidityThreshold()%>" required>
                                </div>

                                <div class="section-divider"></div>

                                <div class="admin-input-grid">
                                    <div class="admin-input-group">
                                        <label>Night Mode Start (24h)</label>
                                        <input type="number" name="nightStart" value="<%= sysConfig.getNightModeStart()%>" min="0" max="23" required>
                                    </div>
                                    <div class="admin-input-group">
                                        <label>Night Mode End (24h)</label>
                                        <input type="number" name="nightEnd" value="<%= sysConfig.getNightModeEnd()%>" min="0" max="23" required>
                                    </div>
                                </div>

                                <input type="hidden" name="lightDur" value="<%= sysConfig.getLightActiveDuration()%>">
                                <input type="hidden" name="safetyAlert" value="<%= sysConfig.getSafetyAlertTemp()%>">

                                <button type="submit" class="btn-submit-request" style="width: 100%; margin-top: 15px; padding: 15px; background-color: var(--active-pink); color: white; border: none; border-radius: 10px; font-weight: bold; font-size: 1.1rem; cursor: pointer;">
                                    Deploy Configuration <i class="fa-solid fa-cloud-arrow-up" style="margin-left: 10px;"></i>
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
            <script>
                // Clean URL after success modal shows
                window.onload = function () {
                    if (window.location.search.includes('status=updated')) {
                        const cleanUrl = window.location.protocol + "//" + window.location.host + window.location.pathname;
                        window.history.replaceState({path: cleanUrl}, '', cleanUrl);
                    }
                };
            </script>
            <% if ("updated".equals(status)) { %>
            <div id="successModal" class="modal" style="display:flex;">
                <div class="modal-content" style="border-top:10px solid var(--card-green); background: var(--bg-cream); padding: 30px; border-radius: 20px; text-align: center;">
                    <div style="font-size:3rem; color: #4CAF50;"><i class="fa-solid fa-circle-check"></i></div>
                    <h2 style="font-family:'Comic Neue'; color:var(--card-green);">Database Updated!</h2>
                    <p>New logic thresholds have been deployed to the shelter.</p>
                    <button onclick="document.getElementById('successModal').style.display = 'none'"
                            class="btn-apply" style="width:100%; padding:15px; margin-top:10px; background:var(--card-green); border-radius: 30px; border: none; color: white; font-weight: bold; cursor: pointer;">Acknowledge</button>
                </div>
            </div>
            <% }%>
        </div>
    </body>
</html>