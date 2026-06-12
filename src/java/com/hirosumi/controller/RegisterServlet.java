package com.hirosumi.controller;

import com.hirosumi.dao.UserDAO;
import com.hirosumi.model.User;
import com.hirosumi.service.EmailService;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.UUID;
import javax.mail.MessagingException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fullName = request.getParameter("fullname");
        String email = request.getParameter("email");
        String username = request.getParameter("username");
        String pass = request.getParameter("password");
        String confirmPass = request.getParameter("confirmpassword");

        fullName = fullName != null ? fullName.trim() : "";
        email = email != null ? email.trim() : "";
        username = username != null ? username.trim() : "";

        UserDAO dao = new UserDAO();

        if (fullName.isEmpty() || email.isEmpty() || username.isEmpty() || pass == null || confirmPass == null) {
            request.setAttribute("errorMessage", "Please fill in all fields.");
            request.getRequestDispatcher("signup.jsp").forward(request, response);
            return;
        }

        if (!pass.equals(confirmPass)) {
            request.setAttribute("errorMessage", "Passwords do not match!");
            request.getRequestDispatcher("signup.jsp").forward(request, response);
            return;
        }

        // Server-side password rule
        if (!isStrongPassword(pass)) {
            request.setAttribute("errorMessage", "Password must be at least 8 characters and include uppercase, lowercase, number, and special character.");
            request.getRequestDispatcher("signup.jsp").forward(request, response);
            return;
        }

        if (dao.isUsernameExists(username)) {
            request.setAttribute("errorMessage", "Username already exists. Please choose another username.");
            request.getRequestDispatcher("signup.jsp").forward(request, response);
            return;
        }

        if (dao.isEmailExists(email)) {
            request.setAttribute("errorMessage", "Email already exists. Please use another email.");
            request.getRequestDispatcher("signup.jsp").forward(request, response);
            return;
        }

        User newUser = new User();
        newUser.setFullName(fullName);
        newUser.setEmail(email);
        newUser.setUsername(username);
        newUser.setRole("Volunteer");

        String token = UUID.randomUUID().toString();
        LocalDateTime expiry = LocalDateTime.now().plusHours(24);

        boolean success = dao.registerUser(newUser, pass, token, expiry);

        if (success) {
            try {
                String appUrl = request.getScheme() + "://" + request.getServerName() + ":"
                        + request.getServerPort() + request.getContextPath();

                System.out.println("REGISTER SUCCESS: Account created for " + email);
                System.out.println("CALLING EMAIL SERVICE NOW...");
                EmailService.sendVerificationEmail(email, fullName, token, appUrl);

                request.setAttribute("successMessage", "Registration successful! Please check your email to verify your account before logging in.");
                request.getRequestDispatcher("signup.jsp").forward(request, response);

            } catch (MessagingException e) {
                e.printStackTrace();
                request.setAttribute("errorMessage", "Account created, but verification email could not be sent.");
                request.getRequestDispatcher("signup.jsp").forward(request, response);
            }
        } else {
            request.setAttribute("errorMessage", "Registration failed. Please try again.");
            request.getRequestDispatcher("signup.jsp").forward(request, response);
        }
    }

    private boolean isStrongPassword(String password) {
        return password.length() >= 8
                && password.matches(".*[A-Z].*")
                && password.matches(".*[a-z].*")
                && password.matches(".*\\d.*")
                && password.matches(".*[^A-Za-z0-9].*");
    }
}
