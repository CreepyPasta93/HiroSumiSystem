<%@page import="com.hirosumi.model.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>HiroSumi - Change Password</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/signup.css">
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/favicon.png">
</head>

<body>
    <div class="signup-container">

        <div class="left-panel">
            <div class="left-content">
                <img src="${pageContext.request.contextPath}/images/hirosumi_logo.png" 
                     alt="HiroSumi Logo" class="logo-img">

                <p class="tagline">
                    Please update your password before accessing the dashboard.
                </p>
            </div>
        </div>

        <div class="right-panel">
            <div class="signup-card">
                <h2>Update Password</h2>

                <p class="signup-subtitle">
                    For security reasons, your technician account must change the default password first.
                </p>

                <div class="role-note">
                    <strong>Security Notice 🔐</strong><br>
                    Please create a strong password before continuing to the HiroSumi dashboard.
                </div>

                <form action="ForceChangePasswordServlet" method="POST">

                    <div class="input-wrapper password-group">
                        <label>New Password</label>
                        <input type="password" id="password" name="password" class="input-field" required>
                        <button type="button" class="toggle-password" onclick="togglePassword('password', this)">Show</button>

                        <div class="helper-box">
                            <div class="strength-bar-wrap">
                                <div id="strengthBar" class="strength-bar"></div>
                            </div>
                            <div id="strengthMsg" class="strength-msg"></div>
                        </div>
                    </div>

                    <div class="input-wrapper password-group">
                        <label>Confirm New Password</label>
                        <input type="password" id="confirmPassword" name="confirmpassword" class="input-field" required>
                        <button type="button" class="toggle-password" onclick="togglePassword('confirmPassword', this)">Show</button>

                        <div class="helper-box">
                            <div id="matchMsg" class="match-msg"></div>
                        </div>
                    </div>

                    <%
                        String error = (String) request.getAttribute("errorMessage");
                        if (error != null) {
                    %>
                        <div class="error-msg"><%= error %></div>
                    <% } %>

                    <button type="submit" class="login-btn">Update Password</button>
                </form>
            </div>
        </div>
    </div>

    <script>
        function togglePassword(inputId, btn) {
            const input = document.getElementById(inputId);
            if (input.type === "password") {
                input.type = "text";
                btn.textContent = "Hide";
            } else {
                input.type = "password";
                btn.textContent = "Show";
            }
        }

        const passwordInput = document.getElementById("password");
        const confirmPasswordInput = document.getElementById("confirmPassword");
        const strengthBar = document.getElementById("strengthBar");
        const strengthMsg = document.getElementById("strengthMsg");
        const matchMsg = document.getElementById("matchMsg");

        function checkStrength(password) {
            let score = 0;

            if (password.length >= 8) score++;
            if (/[A-Z]/.test(password)) score++;
            if (/[a-z]/.test(password)) score++;
            if (/[0-9]/.test(password)) score++;
            if (/[^A-Za-z0-9]/.test(password)) score++;

            if (password.length === 0) {
                strengthBar.style.width = "0%";
                strengthMsg.textContent = "";
                return;
            }

            if (score <= 2) {
                strengthBar.style.width = "33%";
                strengthBar.style.backgroundColor = "#EF5350";
                strengthMsg.textContent = "Weak password";
                strengthMsg.style.color = "#C62828";
            } else if (score <= 4) {
                strengthBar.style.width = "66%";
                strengthBar.style.backgroundColor = "#FFA726";
                strengthMsg.textContent = "Medium password";
                strengthMsg.style.color = "#EF6C00";
            } else {
                strengthBar.style.width = "100%";
                strengthBar.style.backgroundColor = "#66BB6A";
                strengthMsg.textContent = "Strong password";
                strengthMsg.style.color = "#2E7D32";
            }
        }

        function checkPasswordMatch() {
            const password = passwordInput.value;
            const confirmPassword = confirmPasswordInput.value;

            if (confirmPassword.length === 0) {
                matchMsg.textContent = "";
                return;
            }

            if (password === confirmPassword) {
                matchMsg.textContent = "Passwords match ✓";
                matchMsg.style.color = "#2E7D32";
            } else {
                matchMsg.textContent = "Passwords do not match";
                matchMsg.style.color = "#C62828";
            }
        }

        passwordInput.addEventListener("input", function () {
            checkStrength(this.value);
            checkPasswordMatch();
        });

        confirmPasswordInput.addEventListener("input", checkPasswordMatch);
    </script>
</body>
</html>