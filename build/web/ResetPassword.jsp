<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String token = (String) request.getAttribute("token");
    if (token == null || token.isEmpty()) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <title>HiroSumi - Create New Password</title>
        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
        <style>
            :root {
                --primary-green: #557159;
                --soft-green: #C9D9C1;
                --cream: #FAF9F6;
                --error-red: #E27D60;
            }

            body {
                font-family: 'Poppins', sans-serif;
                background-color: var(--soft-green);
                background-image: radial-gradient(circle, #ffffff 1px, transparent 1px);
                background-size: 20px 20px; /* Subtle polka dot pattern */
                display: flex;
                justify-content: center;
                align-items: center;
                height: 100vh;
                margin: 0;
            }

            .reset-container {
                background: rgba(255, 255, 255, 0.9);
                backdrop-filter: blur(10px);
                padding: 40px;
                border-radius: 30px;
                box-shadow: 0 10px 25px rgba(0,0,0,0.05);
                width: 100%;
                max-width: 400px;
                text-align: center;
                border: 2px solid white;
            }

            .cat-icon {
                font-size: 50px;
                margin-bottom: 10px;
            }

            h2 {
                color: var(--primary-green);
                margin-bottom: 5px;
                font-weight: 600;
            }

            p {
                color: #777;
                font-size: 0.9rem;
                margin-bottom: 25px;
            }

            .input-group {
                margin-bottom: 20px;
                text-align: left;
            }

            label {
                display: block;
                margin-left: 15px;
                margin-bottom: 5px;
                color: var(--primary-green);
                font-weight: 600;
                font-size: 0.85rem;
            }

            input[type="password"] {
                width: 100%;
                padding: 12px 20px;
                border-radius: 25px;
                border: 2px solid #eee;
                box-sizing: border-box;
                transition: 0.3s;
                outline: none;
                font-size: 1rem;
            }

            input[type="password"]:focus {
                border-color: var(--primary-green);
                background: #fff;
            }

            #passwordHint {
                display: block;
                margin-top: 8px;
                font-size: 0.75rem;
                line-height: 1.4;
                padding: 0 10px;
                color: var(--error-red);
            }

            button {
                background: var(--primary-green);
                color: white;
                padding: 12px 30px;
                border-radius: 30px;
                border: none;
                cursor: pointer;
                width: 100%;
                font-weight: 600;
                font-size: 1rem;
                margin-top: 10px;
                transition: all 0.3s ease;
                box-shadow: 0 4px 15px rgba(85, 113, 89, 0.2);
            }

            button:hover:not(:disabled) {
                transform: translateY(-2px);
                box-shadow: 0 6px 20px rgba(85, 113, 89, 0.3);
            }

            button:disabled {
                background: #ccc;
                cursor: not-allowed;
                opacity: 0.7;
                box-shadow: none;
            }
        </style>
    </head>
    <body>

        <div class="reset-container">
            <div class="cat-icon">🐾</div>
            <h2>New Meow-word</h2>
            <p>Please enter your new strong password below.</p>

            <form action="ResetPasswordServlet" method="post">
                <input type="hidden" name="token" value="<%= token%>">

                <div class="input-group">
                    <label for="password">New Password</label>
                    <input type="password" id="password" name="password" 
                           placeholder="Enter at least 8 characters" required>
                    <span id="passwordHint"></span>
                </div>

                <button type="submit" id="submitBtn" disabled>
                    Save Password
                </button>
            </form>
        </div>

        <script>
            const password = document.getElementById("password");
            const hint = document.getElementById("passwordHint");
            const btn = document.getElementById("submitBtn");

            password.addEventListener("input", () => {
                // New "Chill" Rule: At least 8 characters, 1 letter, and 1 number
                const regex = /^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$/;

                if (password.value.length === 0) {
                    hint.innerText = "";
                    btn.disabled = true;
                } else if (!regex.test(password.value)) {
                    // Updated text to be more helpful
                    hint.innerText = "Paw-word needs at least 8 characters with letters & numbers! 🐾";
                    hint.style.color = "#E27D60"; // Error red
                    btn.disabled = true;
                } else {
                    hint.innerText = "✨ Purr-fectly strong!";
                    hint.style.color = "#557159"; // Success green
                    btn.disabled = false;
                }
            });
        </script>

    </body>
</html>