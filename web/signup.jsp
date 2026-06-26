<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>HiroSumi - Sign Up</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/signup.css">
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/favicon.png">
    </head>
    <body>
        <div class="signup-container">

            <div class="left-panel">
                <div class="left-content">
                    <img src="${pageContext.request.contextPath}/images/hirosumi_logo.png" alt="HiroSumi Logo" class="logo-img">

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

            <div class="right-panel">
                <div class="signup-card">
                    <h2>Create Account</h2>
                    <p class="signup-subtitle">Register to join HiroSumi as a volunteer.</p>

                    <div class="role-note">
                        <strong>Volunteer Registration Only 🐾</strong><br>
                        All public sign-ups are created as <strong>Volunteer</strong> accounts. Technician access can only be granted by an existing technician.
                    </div>

                    <form action="RegisterServlet" method="POST" autocomplete="off">

                        <div class="input-wrapper">
                            <label>Full Name</label>
                            <input type="text" name="fullname" class="input-field" placeholder="e.g., Jane Doe" required autocomplete="off">
                        </div>

                        <div class="input-wrapper">
                            <label>Email Address</label>
                            <input type="email" name="email" class="input-field" placeholder="e.g., name@example.com" required autocomplete="off">
                        </div>

                        <div class="input-wrapper">
                            <label>Username</label>
                            <input type="text" name="username" class="input-field" placeholder="e.g., user123" required autocomplete="off">
                        </div>

                        <div class="input-wrapper password-group">
                            <label>Password</label>
                            <input type="password" id="password" name="password" class="input-field" placeholder="Enter your password" required autocomplete="new-password">
                            <button type="button" class="toggle-password" onclick="togglePassword('password', this)">Show</button>

                            <div class="helper-box">
                                <div class="strength-bar-wrap">
                                    <div id="strengthBar" class="strength-bar"></div>
                                </div>
                                <div id="strengthMsg" class="strength-msg"></div>
                            </div>
                        </div>

                        <div class="input-wrapper password-group">
                            <label>Confirm Password</label>
                            <input type="password" id="confirmPassword" name="confirmpassword" class="input-field" placeholder="Confirm your password" required>
                            <button type="button" class="toggle-password" onclick="togglePassword('confirmPassword', this)">Show</button>

                            <div class="helper-box">
                                <div id="matchMsg" class="match-msg"></div>
                            </div>
                        </div>

                        <%
                            String error = (String) request.getAttribute("errorMessage");
                            String success = (String) request.getAttribute("successMessage");
                            if (error != null) {
                        %>
                            <div class="error-msg"><%= error %></div>
                        <%
                            }
                            if (success != null) {
                        %>
                            <div class="success-msg"><%= success %></div>
                        <%
                            }
                        %>

                        <button type="submit" class="login-btn">Create Account</button>

                        <p class="login-link">
                            Already have an account? <a href="login.jsp">Log in</a>
                        </p>
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
                    strengthBar.style.backgroundColor = "transparent";
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