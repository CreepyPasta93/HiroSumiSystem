<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>HiroSumi - Login</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    </head>
    <body>
        <div class="login-container">
            <div class="left-panel">
                <img src="${pageContext.request.contextPath}/images/logo.png" alt="HiroSumi Logo" class="logo-img">
            </div>

            <div class="right-panel">
                <h2>Log in</h2>

                <form action="LoginServlet" method="POST" autocomplete="off">

                    <div class="role-selector">
                        <input type="radio" id="vol" name="role" value="Volunteer" class="role-radio" checked>
                        <label for="vol" class="role-label">Volunteer</label>

                        <input type="radio" id="tech" name="role" value="Technician" class="role-radio">
                        <label for="tech" class="role-label">Technician</label>
                    </div>

                    <div class="input-group">
                        <input type="text" name="username" placeholder="Username" class="input-field" required autocomplete="off">
                    </div>

                    <div class="input-group">
                        <input type="password" name="password" placeholder="Password" class="input-field" required autocomplete="new-password">
                    </div>

                    <%
                        String error = (String) request.getAttribute("errorMessage");
                        if (error != null) {
                    %>
                    <p class="error-msg" style="color:red"><%= error%></p>
                    <% }%>

                    <a href="#" class="forgot-pass">Forgot Password?</a>

                    <button type="submit" class="login-btn">Log in</button>

                    <p style="margin-top: 20px;">or <a href="signup.jsp" style="color:black;">Sign up</a></p>
                </form>
            </div>
        </div>
    </body>
</html>