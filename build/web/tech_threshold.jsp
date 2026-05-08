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

            .card-matcha {
                background-color: #f0f4ef !important; /* Soft Matcha Green */
                padding: 25px;
                border-radius: 20px;
                border: 1px solid #d8e2dc;
                margin-bottom: 20px;
                box-shadow: 2px 4px 12px rgba(0,0,0,0.05);
                position: relative;
                box-shadow: 4px 4px 0px rgba(74, 109, 74, 0.1) !important; /* Matcha shadow */
                border: 2px solid #d8e2dc !important;
            }

            .card-matcha span {
                color: #2d472d !important; /* Deep dark green for visibility */
            }

            .section-title {
                font-family: 'Quicksand', sans-serif;
                font-weight: 700;
                color: #4a6d4a;
                font-size: 1.1rem;
                border-bottom: 1px solid rgba(0,0,0,0.1);
                padding-bottom: 8px;
                margin-bottom: 15px;
                border-bottom: 1px dashed rgba(74, 109, 74, 0.3) !important;
            }

            /* The cute matcha leaf symbol */
            .card-matcha::after {
                content: '🍃';
                position: absolute;
                top: 10px;
                right: 15px;
                opacity: 0.4;
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

            /* --- 🔔 NOTIFICATION POPUP 🔔 --- */
            .notif-popup {
                position: fixed; /* Use fixed so it follows the bell */
                top: 75px;      /* Just below the header line */
                right: 150px;   /* Adjusted to align under the new bell position */
                width: 320px;
                background: white;
                border: 2px solid var(--active-pink);
                border-radius: 15px;
                box-shadow: 0 10px 25px rgba(0,0,0,0.1);
                display: none;
                z-index: 2000;  /* Higher than everything else */
                padding: 15px;
            }

            .notif-item {
                padding: 10px;
                border-bottom: 1px dashed #eee;
                font-family: 'Quicksand', sans-serif;
            }

            .notif-item:last-child {
                border-bottom: none;
            }

            .notif-actions {
                display: flex;
                gap: 10px;
                margin-top: 8px;
            }

            .btn-approve {
                background: #a3b18a; /* Matcha Green */
                color: white;
                border: none;
                border-radius: 20px;
                padding: 8px 15px;
                cursor: pointer;
                font-family: 'Quicksand', sans-serif;
                font-weight: bold;
                transition: 0.3s;
            }

            .btn-deny {
                background: #ffb7c5; /* Strawberry Pink */
                color: white;
                border: none;
                border-radius: 20px;
                padding: 8px 15px;
                cursor: pointer;
                font-family: 'Quicksand', sans-serif;
                font-weight: bold;
                transition: 0.3s;
            }
        </style>
    </head>

    <body>
        <div class="dashboard-container">
            <jsp:include page="sidebar.jsp"/> 

            <div class="main-content">
                <jsp:include page="header.jsp"/>

                <div class="notification-wrapper" 
                     style="position: absolute; top: 15px; right: 250px; cursor: pointer; z-index: 1002;" 
                     onclick="toggleNotifPopup()">

                    <i class="fa-solid fa-bell" style="font-size: 1.6rem; color: var(--active-pink); filter: drop-shadow(2px 2px 2px rgba(0,0,0,0.1));"></i>

                    <span class="notif-badge" style="position: absolute; top: -5px; right: -5px; background: #ff4d4d; color: white; border-radius: 50%; padding: 2px 6px; font-size: 0.7rem; font-weight: bold; border: 2px solid white;">
                        <%= (request.getAttribute("pendingCount") != null) ? request.getAttribute("pendingCount") : "0"%>
                    </span>
                </div>

                <div class="threshold-layout">
                    <div class="logic-section">
                        <h1 style="font-family:'Comic Neue'; color:var(--text-dark); font-size: 2.8rem; margin: 0 0 5px 0; display: flex; align-items: center;">
                            <i class="fa-solid fa-wrench" style="color: #4CAF50; font-size: 2.2rem; margin-right: 15px;"></i> Tech Configuration
                        </h1>                       
                        <p style="color:var(--text-dark); opacity:0.7; margin: 0 0 35px 5px;">Direct database control for shelter parameters 🍓</p>

                        <div class="card-matcha">
                            <div class="section-title"><i class="fa-solid fa-fire"></i> Active Heater Logic (Hysteresis)</div>
                            <div style="display: flex; justify-content: space-between; margin-top: 15px;">
                                <div>
                                    <span style="font-size: 0.9rem; opacity: 0.8; color: #444;">Turns ON Below</span><br>
                                    <span style="font-size: 1.8rem; font-weight: 800; color: #2d472d;"><%= sysConfig.getHeaterActivation()%>°C</span>
                                </div>
                                <div style="text-align: right;">
                                    <span style="font-size: 0.9rem; opacity: 0.8; color: #444;">Turns OFF Above</span><br>
                                    <span style="font-size: 1.8rem; font-weight: 800; color: #2d472d;"><%= sysConfig.getHeaterCutoff()%>°C</span>
                                </div>
                            </div>
                        </div>

                        <div class="card-matcha">
                            <div class="section-title"><i class="fa-solid fa-fan"></i> Active Fan & Ventilation Logic</div>
                            <div style="display: flex; justify-content: space-between; margin-top: 15px;">
                                <div>
                                    <span style="font-size: 0.8rem; opacity: 0.8; color: #444;">Heat Trigger</span><br>
                                    <span style="font-size: 1.6rem; font-weight: 800; color: #2d472d;"><%= sysConfig.getFanActivationThreshold()%>°C</span>
                                </div>
                                <div style="text-align: center;">
                                    <span style="font-size: 0.8rem; opacity: 0.8; color: #444;">Humidity Trigger</span><br>
                                    <span style="font-size: 1.6rem; font-weight: 800; color: #2d472d;"><%= sysConfig.getHumidityThreshold()%>%</span>
                                </div>
                                <div style="text-align: right;">
                                    <span style="font-size: 0.8rem; opacity: 0.8; color: #444;">Cut-Off Point</span><br>
                                    <span style="font-size: 1.6rem; font-weight: 800; color: #2d472d;"><%= sysConfig.getFanCutoffThreshold()%>°C</span>
                                </div>
                            </div>
                        </div>

                        <div class="card-matcha">
                            <div class="section-title"><i class="fa-solid fa-moon"></i> Active Schedule Logic</div>
                            <div style="display: flex; justify-content: space-between; margin-top: 15px;">
                                <div>
                                    <span style="font-size: 0.9rem; opacity: 0.8; color: #444;">Night Mode Starts</span><br>
                                    <span style="font-size: 1.8rem; font-weight: 800; color: #2d472d;"><%= String.format("%02d:00", sysConfig.getNightModeStart())%>:00</span>
                                </div>
                                <div style="text-align: right;">
                                    <span style="font-size: 0.9rem; opacity: 0.8; color: #444;">Day Mode Resumes</span><br>
                                    <span style="font-size: 1.8rem; font-weight: 800; color: #2d472d;"><%= String.format("%02d:00", sysConfig.getNightModeEnd())%>:00</span>
                                </div>
                            </div>
                        </div>

                        <div class="card-matcha" style="margin-top: 20px; border: 2px dashed #6b8e23; background: #fdfdfd;">
                            <div class="section-title" style="color: #2e4d2e;"><i class="fa-solid fa-lightbulb"></i> System Intelligence Guide</div>
                            <div class="card-matcha" style="margin-top: 30px; border: 2px dashed #4a6d4a; background: #fff;">
                                <div class="section-title" style="border-bottom:none; margin-bottom:10px;">
                                    <i class="fa-solid fa-wand-magic-sparkles"></i> Operational Logic Guide 🍵
                                </div>
                                <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 20px; font-size: 0.85rem; color: #555;">
                                    <div>
                                        <strong>🚩 Triggers vs. Cut-offs</strong><br>
                                        The <b>Trigger</b> is the "Start" point (e.g., Fan starts at 30°C). The <b>Cut-off</b> is the "Stop" point. Always keep the Cut-off slightly lower than the Trigger to ensure the system knows when to quit!
                                    </div>
                                    <div>
                                        <strong>🔄 The Hysteresis Gap</strong><br>
                                        Think of this as a safety buffer. A 1-2°C gap prevents the hardware from "stuttering" (turning on and off every second), which keeps your motors healthy.
                                    </div>
                                    <div>
                                        <strong>🤝 Fan Co-dependency</strong><br>
                                        The Fan is smart! It only starts if <b>BOTH</b> the Heat and Humidity reach their trigger levels. This keeps the air fresh without over-drying the shelter.
                                    </div>
                                </div>
                            </div>
                        </div>

                    </div> <div class="control-section">
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
                                        <label>Night Mode Start</label>
                                        <input type="number" name="nightStart" value="<%= sysConfig.getNightModeStart()%>" min="0" max="23" required>
                                    </div>
                                    <div class="admin-input-group">
                                        <label>Night Mode End</label>
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
                        <h2 style="font-family:'Comic Neue'; color:var(--card-green);">Database Updated!</h2>
                        <p>New logic thresholds have been deployed to the shelter.</p>
                        <button onclick="document.getElementById('successModal').style.display = 'none'"
                                class="btn-apply" style="width:100%; padding:15px; margin-top:10px; background:var(--card-green); border-radius: 30px; border: none; color: white; font-weight: bold; cursor: pointer;">Acknowledge</button>
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
        </div> </body>
</html>

</body>
