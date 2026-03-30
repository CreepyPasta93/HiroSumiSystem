<%@page import="com.hirosumi.model.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // 1. SESSION CHECK
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // 2. MODE LOGIC
    String mode = request.getParameter("mode");
    boolean isEditMode = "edit".equals(mode);

    // 3. AVATAR LOGIC
    String avatarUrl = (currentUser.getProfileImage() != null && !currentUser.getProfileImage().isEmpty())
            ? "images/" + currentUser.getProfileImage()
            : "https://i.pravatar.cc/150?u=" + currentUser.getUsername();
%>
<!DOCTYPE html>
<html>
    <head>
        <title>HiroSumi - Settings</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=2.0">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Comic+Neue:wght@700&family=Quicksand:wght@500;700&display=swap" rel="stylesheet">

        <style>
            body {
                margin: 0;
                overflow: hidden;
                background-color: var(--bg-cream);
                font-family: 'Quicksand', sans-serif;
            }

            .dashboard-container {
                display: flex;
                width: 100%;
                height: 100vh;
            }

            .main-content {
                flex-grow: 1;
                overflow-y: auto;
                display: flex;
                flex-direction: column;
                width: 100%;
            }

            /* Sidebar Styles */
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
            }
            .sidebar-overlay.active {
                display: block;
            }

            /* Grid & Card Layouts */
            .profile-grid {
                display: grid;
                grid-template-columns: 600px 1fr;
                gap: 40px;
                width: 95%;
                max-width: 1300px;
                margin: 30px auto;
                align-items: stretch;
            }

            .profile-card {
                background: rgba(255, 248, 240, 0.9) !important;
                border: 3px solid var(--bg-pink) !important;
                border-radius: 35px !important;
                padding: 40px;
                box-shadow: 0 15px 35px rgba(212, 103, 126, 0.1);
                position: relative;
                overflow: hidden;
                display: flex;
                flex-direction: column;
                align-items: center;
            }

            .profile-card form {
                width: 100%;
                display: flex;
                flex-direction: column;
                align-items: center;
            }

            /* Tips Grid */
            .tips-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 20px;
            }

            .tip-box {
                padding: 30px 20px;
                border-radius: 25px;
                background: white;
                border: 2px dashed #EEE;
                text-align: center;
                transition: transform 0.3s ease;
                display: flex;
                flex-direction: column;
                justify-content: center;
                min-height: 160px;
            }

            .tip-box:hover {
                transform: translateY(-5px);
            }

            /* Form Elements */
            .profile-label {
                font-family: 'Comic Neue', cursive;
                color: #557159 !important;
                font-weight: 700;
                margin-bottom: 8px;
                display: block;
                font-size: 1.1rem;
                align-self: flex-start;
            }

            .profile-input {
                background: white !important;
                border: 2px solid #EEE !important;
                border-radius: 20px !important;
                padding: 15px 25px !important;
                font-size: 1.05rem;
                width: 100%;
                box-sizing: border-box;
            }

            .input-wrapper {
                position: relative;
                margin-bottom: 20px;
                width: 100%;
            }

            .input-wrapper i {
                position: absolute;
                right: 20px;
                top: 50%;
                transform: translateY(-50%);
                color: var(--bg-pink);
                opacity: 0.5;
            }

            /* Stats Card */
            .stats-card {
                background: #557159;
                color: white;
                border-radius: 30px;
                padding: 30px;
                box-shadow: 0 10px 25px rgba(85, 113, 89, 0.2);
            }

            .stat-item {
                background: rgba(255, 255, 255, 0.1);
                padding: 15px;
                border-radius: 20px;
                display: flex;
                align-items: center;
                gap: 15px;
            }

            .pw-btn {
                background: none;
                border: none;
                color: #D4677E;
                font-weight: bold;
                cursor: pointer;
                font-family: 'Quicksand';
            }
        </style>

        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
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
                    <% } %>

                    <a href="ProfileServlet" class="nav-item"><i class="fa-solid fa-gear"></i> <span>Settings</span></a>
                </div>
                <div class="bottom-menu"><a href="logout.jsp" class="nav-item"><i class="fa-solid fa-right-from-bracket"></i> <span>Log Out</span></a></div>
            </div>

            <div class="main-content">
                <jsp:include page="header.jsp" />

                <div class="analytics-wrapper" style="width: 90%; display: flex; flex-direction: column; align-items: center;">

                    <div class="logs-header-area" style="width: 95%; max-width: 1300px; margin: 0 auto 0px auto; display: flex; align-items: center;">
                        <h2 style="font-family: 'Comic Neue'; font-size: 2.2rem; color: #4E342E; margin: 0;">Account Settings</h2>                        <% if (!isEditMode) { %>
                        <a href="ProfileServlet?mode=edit" style="text-decoration:none; background-color: #D4677E; border-radius: 30px; padding: 10px 25px; color: white; font-weight: bold; box-shadow: 0 4px 10px rgba(212, 103, 126, 0.3);">
                            <i class="fa-solid fa-user-pen"></i> Edit Profile
                        </a>
                        <% }%>
                    </div>

                    <div class="profile-grid">
                        <div class="profile-card">
                            <form action="ProfileServlet" method="POST" enctype="multipart/form-data">
                                <input type="hidden" name="action" value="update">

                                <div style="display:flex; flex-direction: column; align-items:center; margin-bottom:30px; border-bottom: 2px dashed #FFDDE2; padding-bottom: 20px; width: 100%;">
                                    <div style="position: relative; margin-bottom: 15px;">
                                        <img src="<%= avatarUrl%>" style="width: 120px; height: 120px; border-radius: 50%; object-fit: cover; border: 5px solid white; box-shadow: 0 5px 15px rgba(0,0,0,0.1);">
                                        <% if (isEditMode) { %>
                                        <label style="position: absolute; bottom: 0; right: 0; background: #D4677E; color: white; width: 35px; height: 35px; border-radius: 50%; display: flex; align-items: center; justify-content: center; cursor: pointer; border: 3px solid white;">
                                            <i class="fa-solid fa-camera"></i>
                                            <input type="file" name="profileImage" style="display:none;" accept="image/*">
                                        </label>
                                        <% }%>
                                    </div>
                                    <div style="text-align: center;">
                                        <h3 style="margin: 0; color: #557159; font-family: 'Comic Neue'; font-size: 1.8rem;">
                                            <%= currentUser.getFullName()%> <i class="fa-solid fa-cat" style="color: var(--bg-pink); margin-left: 5px;"></i>
                                        </h3>
                                        <p style="margin: 2px 0; color: #D4677E; font-weight: bold; text-transform: uppercase; font-size: 0.8rem;"><%= currentUser.getRole()%> Account</p>
                                    </div>
                                </div>

                                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; width: 100%;">
                                    <div class="profile-form-group">
                                        <label class="profile-label">Full Name</label>
                                        <div class="input-wrapper">
                                            <input type="text" name="fullname" class="profile-input" value="<%= currentUser.getFullName()%>" <%= isEditMode ? "" : "disabled"%>>
                                            <i class="fa-solid fa-user"></i>
                                        </div>
                                    </div>
                                    <div class="profile-form-group">
                                        <label class="profile-label">Username</label>
                                        <div class="input-wrapper">
                                            <input type="text" name="username" class="profile-input" value="<%= currentUser.getUsername()%>" <%= isEditMode ? "" : "disabled"%>>
                                            <i class="fa-solid fa-id-badge"></i>
                                        </div>
                                    </div>
                                </div>

                                <label class="profile-label">Email Address</label>
                                <div class="input-wrapper">
                                    <input type="email" name="email" class="profile-input" value="<%= currentUser.getEmail()%>" <%= isEditMode ? "" : "disabled"%>>
                                    <i class="fa-solid fa-envelope"></i>
                                </div>

                                <label class="profile-label">Password</label>
                                <div class="input-wrapper">
                                    <input type="password" value="*********" class="profile-input" disabled>
                                    <i class="fa-solid fa-lock"></i>
                                </div>

                                <button type="button" onclick="requestPasswordReset('<%= currentUser.getEmail()%>')" class="pw-btn">
                                    <i class="fa-solid fa-key"></i> Request Password Change?
                                </button>

                                <% if (isEditMode) { %>
                                <div style="text-align:right; margin-top:30px; border-top: 1px solid #EEE; padding-top: 20px; width: 100%;">
                                    <a href="ProfileServlet" style="text-decoration:none; margin-right:20px; color: #999; font-weight: bold;">Cancel</a>
                                    <button type="submit" style="background: #557159; border: none; padding: 12px 35px; border-radius: 30px; color: white; font-weight: bold; cursor: pointer;">
                                        Save Changes <i class="fa-solid fa-paw" style="margin-left: 5px;"></i>
                                    </button>
                                </div>
                                <% }%>
                            </form>
                        </div>

                        <div class="stats-area">
                            <div class="stats-card" style="margin-bottom: 25px;">
                                <h3 style="font-family: 'Comic Neue'; margin: 0 0 15px 0;"><i class="fa-solid fa-shield-cat"></i> System Status</h3>
                                <div style="display: flex; gap: 15px;">
                                    <div class="stat-item" style="flex: 1;">
                                        <i class="fa-solid fa-medal"></i>
                                        <div>
                                            <div style="font-weight: bold; font-size: 0.9rem;">Level</div>
                                            <div style="font-size: 0.75rem; opacity: 0.8;"><%= currentUser.getRole()%></div>
                                        </div>
                                    </div>
                                    <div class="stat-item" style="flex: 1;">
                                        <i class="fa-solid fa-circle-check"></i>
                                        <div>
                                            <div style="font-weight: bold; font-size: 0.9rem;">Status</div>
                                            <div style="font-size: 0.75rem; opacity: 0.8;">Verified</div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <h3 style="font-family: 'Comic Neue'; color: #4E342E; margin: 0 0 15px 10px;">Shelter Tips 🐾</h3>
                            <div class="tips-grid">
                                <div class="tip-box" style="border-color: #D4677E;">
                                    <i class="fa-solid fa-camera" style="color: #D4677E; font-size: 1.8rem; margin-bottom: 12px;"></i>
                                    <h5 style="margin: 0; color: #557159;">Photos</h5>
                                    <p style="font-size: 0.8rem; color: #777;">Clear profile photos help identify you during busy shifts!</p>
                                </div>
                                <div class="tip-box" style="border-color: #B5C99A;">
                                    <i class="fa-solid fa-clock" style="color: #B5C99A; font-size: 1.8rem; margin-bottom: 12px;"></i>
                                    <h5 style="margin: 0; color: #557159;">Be Early</h5>
                                    <p style="font-size: 0.8rem; color: #777;">Arrive 5 mins early to check your daily duty list.</p>
                                </div>
                                <div class="tip-box" style="border-color: #FFD93D;">
                                    <i class="fa-solid fa-bone" style="color: #FFD93D; font-size: 1.8rem; margin-bottom: 12px;"></i>
                                    <h5 style="margin: 0; color: #557159;">Diet Safety</h5>
                                    <p style="font-size: 0.8rem; color: #777;">Double-check food labels for pets with allergies!</p>
                                </div>
                                <div class="tip-box" style="border-color: #557159;">
                                    <i class="fa-solid fa-droplet" style="color: #557159; font-size: 1.8rem; margin-bottom: 12px;"></i>
                                    <h5 style="margin: 0; color: #557159;">Hydration</h5>
                                    <p style="font-size: 0.8rem; color: #777;">Stay hydrated! Take water breaks between tasks.</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script>
            function toggleSidebar() {
                const sidebar = document.getElementById('mySidebar');
                const overlay = document.querySelector('.sidebar-overlay');
                sidebar.classList.toggle('active');
                overlay.classList.toggle('active');
            }

            function requestPasswordReset(email) {
                Swal.fire({
                    title: 'Sending Request...',
                    text: 'Please wait while we process your request.',
                    allowOutsideClick: false,
                    didOpen: () => {
                        Swal.showLoading();
                    }
                });

                // Send request to Servlet
                fetch('ProfileServlet?action=resetPassword&email=' + email, {method: 'POST'})
                        .then(response => response.json())
                        .then(data => {
                            if (data.status === "success") {
                                Swal.fire({
                                    icon: 'success',
                                    title: 'Email Sent!',
                                    text: 'A password reset link has been sent to ' + email,
                                    confirmButtonColor: '#557159'
                                });
                            } else {
                                Swal.fire({icon: 'error', title: 'Error', text: 'Could not send email.'});
                            }
                        });
            }
        </script>
    </body>
</html>