<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>HiroSumi - Login</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/login.css">
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/favicon.png">
    </head>

    <body>
        <div class="login-container">

            <!-- LEFT PANEL -->
            <div class="left-panel">
                <div class="left-content">
                    <img src="${pageContext.request.contextPath}/images/hirosumi_logo.png" 
                         alt="HiroSumi Logo" 
                         class="logo-img">

                    <p class="tagline">
                        Caring for stray cats through smart shelter monitoring.
                    </p>

                    <div class="feature-row">
                        <span>🐾 Shelter Care</span>
                        <span>🍓 Cat Friendly</span>
                        <span>🍵 Smart Monitoring</span>
                    </div>
                </div>
            </div>

            <!-- RIGHT PANEL -->
            <div class="right-panel">

                <div class="login-card">
                    <div class="card-decoration">🐾</div>

                    <h2>Welcome Back</h2>
                    <p class="login-subtitle">
                        Log in to access your HiroSumi dashboard.
                    </p>

                    <form action="LoginServlet" method="POST" autocomplete="off" data-lpignore="true">

                        <!-- ROLE SELECTOR -->
                        <div class="role-selector">
                            <input type="radio" id="vol" name="role" value="Volunteer" class="role-radio" checked>
                            <label for="vol" class="role-card">
                                <span class="role-icon">🐱</span>
                                <span class="role-title">Volunteer</span>
                                <span class="role-desc">Care updates and shelter support</span>
                            </label>

                            <input type="radio" id="tech" name="role" value="Technician" class="role-radio">
                            <label for="tech" class="role-card">
                                <span class="role-icon">🛠️</span>
                                <span class="role-title">Technician</span>
                                <span class="role-desc">Sensor and device maintenance</span>
                            </label>
                        </div>

                        <!-- ROLE PREVIEW -->
                        <div class="role-preview">
                            <div class="preview-box" id="rolePreviewBox">
                                <h3 id="rolePreviewTitle">Volunteer Access 🐾</h3>
                                <p id="rolePreviewText">
                                    View cat care updates, report shelter issues, and support daily shelter activities.
                                </p>
                            </div>
                        </div>

                        <div class="input-group">
                            <input type="text" name="username" placeholder="Username" class="input-field" required autocomplete="off">
                        </div>

                        <div class="input-group password-group">
                            <input type="password" id="passwordInput" name="password" placeholder="Password" class="input-field" required autocomplete="new-password">
                            <button type="button" class="toggle-password" onclick="togglePassword()">Show</button>
                        </div>

                        <%
                            String error = (String) request.getAttribute("errorMessage");
                            if (error != null) {
                        %>
                        <div class="error-msg">
                            ⚠ <%= error%>
                        </div>
                        <% }%>

                        <div class="form-options">
                            <label class="remember-me">
                                <input type="checkbox" name="remember">
                                Remember me
                            </label>

                            <a href="ResetPassword.jsp" class="forgot-pass">Forgot Password?</a>
                        </div>

                        <button type="submit" class="login-btn">Log in</button>

                        <p class="signup-text">
                            New here? <a href="signup.jsp">Create account</a>
                        </p>
                    </form>
                </div>
            </div>
        </div>

        <script>
            function togglePassword() {
                const passwordInput = document.getElementById("passwordInput");
                const toggleBtn = document.querySelector(".toggle-password");

                if (passwordInput.type === "password") {
                    passwordInput.type = "text";
                    toggleBtn.textContent = "Hide";
                } else {
                    passwordInput.type = "password";
                    toggleBtn.textContent = "Show";
                }
            }

            const volunteerRadio = document.getElementById("vol");
            const technicianRadio = document.getElementById("tech");
            const previewTitle = document.getElementById("rolePreviewTitle");
            const previewText = document.getElementById("rolePreviewText");

            function updateRolePreview() {
                if (technicianRadio.checked) {
                    previewTitle.textContent = "Technician Access 🛠️";
                    previewText.textContent = "Monitor technical alerts, check device status, and manage maintenance-related tasks.";
                } else {
                    previewTitle.textContent = "Volunteer Access 🐾";
                    previewText.textContent = "View cat care updates, report shelter issues, and support daily shelter activities.";
                }
            }

            volunteerRadio.addEventListener("change", updateRolePreview);
            technicianRadio.addEventListener("change", updateRolePreview);
        </script>
    </body>
</html>