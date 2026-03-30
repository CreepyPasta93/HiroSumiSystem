<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>HiroSumi - Sign Up</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    </head>
    <body>
        <div class="login-container">
            <div class="left-panel">
                <img src="${pageContext.request.contextPath}/images/logo.png" alt="HiroSumi Logo" class="logo-img">
            </div>

            <div class="right-panel">
                <h2>Sign up</h2>

                <form action="RegisterServlet" method="POST" style="max-width: 500px;" autocomplete="off">
                    
                    <div class="form-row">
                        <div class="input-wrapper">
                            <label>Full Name</label>
                            <input type="text" name="fullname" class="input-field" placeholder="Siti Fikriyah" required autocomplete="off">
                        </div>
                        <div class="input-wrapper">
                            <label>Email Address</label>
                            <input type="email" name="email" class="input-field" placeholder="heroshi@reallycutecat.com" required autocomplete="off">
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="input-wrapper" style="width: 100%;">
                            <label>Username</label>
                            <input type="text" name="username" class="input-field" placeholder="sitifik03" required autocomplete="off">
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="input-wrapper">
                            <label>Password</label>
                            <input type="password" name="password" class="input-field" placeholder="**********" required autocomplete="new-password">
                        </div>
                        <div class="input-wrapper">
                            <label>Confirm Password</label>
                            <input type="password" name="confirmpassword" class="input-field" placeholder="**********" required>
                        </div>
                    </div>

                    <%
                        String error = (String) request.getAttribute("errorMessage");
                        if (error != null) {
                    %>
                    <p style="color:red; margin-top:10px;"><%= error%></p>
                    <% }%>

                    <button type="submit" class="login-btn">Create Account</button>

                    <p style="margin-top: 20px;">or <a href="login.jsp" style="color:black; font-weight:bold;">Log in</a></p>
                </form>
            </div>
        </div>
    </body>
</html>