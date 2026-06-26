<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    String token = (String) request.getAttribute("token");

    if (token == null || token.isEmpty()) {
        response.sendRedirect("login.jsp");
        return;
    }

    String errorMessage = request.getAttribute("errorMessage") != null
            ? (String) request.getAttribute("errorMessage")
            : "";
%>

<!DOCTYPE html>
<html>
    <head>
        <title>HiroSumi - Create New Password</title>

        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/reset-password.css">
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/favicon.png">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Comic+Neue:wght@700&family=Quicksand:wght@400;600;700;800&display=swap" rel="stylesheet">
    </head>

    <body class="reset-password-page">

        <main class="reset-shell">

            <section class="reset-card">

                <div class="reset-brand">
                    <div class="reset-brand-icon">
                        <i class="fa-solid fa-lock"></i>
                    </div>

                    <div>
                        <h1>Create New Password</h1>
                        <p>Set a secure password for your HiroSumi account.</p>
                    </div>
                </div>

                <div class="reset-divider"></div>

                <% if (!errorMessage.isEmpty()) {%>
                <div class="reset-alert">
                    <i class="fa-solid fa-circle-exclamation"></i>
                    <span><%= errorMessage%></span>
                </div>
                <% }%>

                <form action="ResetPasswordServlet" method="post" class="reset-form">
                    <input type="hidden" name="token" value="<%= token%>">

                    <div class="input-group">
                        <label for="password">New Password</label>

                        <div class="password-field">
                            <i class="fa-solid fa-key"></i>

                            <input 
                                type="password" 
                                id="password" 
                                name="password" 
                                placeholder="At least 8 characters"
                                autocomplete="new-password"
                                required
                            >

                            <button type="button" class="toggle-password" onclick="togglePassword()" aria-label="Show password">
                                <i class="fa-regular fa-eye" id="toggleIcon"></i>
                            </button>
                        </div>

                        <span id="passwordHint" class="password-hint"></span>
                    </div>

                    <button type="submit" id="submitBtn" class="reset-submit-btn" disabled>
                        <i class="fa-solid fa-check"></i>
                        Save Password
                    </button>
                </form>

                <a href="login.jsp" class="back-login-link">
                    <i class="fa-solid fa-arrow-left"></i>
                    Back to login
                </a>

            </section>

        </main>

        <script>
            const password = document.getElementById("password");
            const hint = document.getElementById("passwordHint");
            const btn = document.getElementById("submitBtn");
            const toggleIcon = document.getElementById("toggleIcon");

            password.addEventListener("input", () => {
                const regex = /^(?=.*[A-Za-z])(?=.*\d).{8,}$/;

                if (password.value.length === 0) {
                    hint.innerText = "";
                    hint.className = "password-hint";
                    btn.disabled = true;
                } else if (!regex.test(password.value)) {
                    hint.innerText = "Password must include at least 8 characters with letters and numbers.";
                    hint.className = "password-hint invalid";
                    btn.disabled = true;
                } else {
                    hint.innerText = "Password strength looks good.";
                    hint.className = "password-hint valid";
                    btn.disabled = false;
                }
            });

            function togglePassword() {
                const isHidden = password.type === "password";

                password.type = isHidden ? "text" : "password";
                toggleIcon.className = isHidden ? "fa-regular fa-eye-slash" : "fa-regular fa-eye";
            }
        </script>

    </body>
</html>