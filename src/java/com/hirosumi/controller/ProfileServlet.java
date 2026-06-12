package com.hirosumi.controller;

import com.hirosumi.dao.UserDAO;
import com.hirosumi.model.User;
import java.time.LocalDateTime;
import java.util.UUID;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Paths;
import java.util.Properties;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

// Email Imports
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

@MultipartConfig
@WebServlet("/ProfileServlet")
public class ProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");

        loadUserListIfTechnician(request, currentUser);

        request.getRequestDispatcher("Profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        UserDAO dao = new UserDAO();

        if ("update".equals(action)) {
            handleProfileUpdate(request, response, currentUser, dao, session);
        } else if ("resetPassword".equals(action)) {
            handlePasswordReset(request, response);
        } else {
            response.sendRedirect("ProfileServlet");
        }
    }

    private void loadUserListIfTechnician(HttpServletRequest request, User currentUser) {
        System.out.println("PROFILE DEBUG: loadUserListIfTechnician called");
        System.out.println("PROFILE DEBUG: currentUser role = [" + currentUser.getRole() + "]");

        if (currentUser.getRole() != null && currentUser.getRole().trim().equalsIgnoreCase("Technician")) {
            UserDAO userDAO = new UserDAO();
            java.util.List<User> users = userDAO.getAllUsers();

            System.out.println("PROFILE DEBUG: users found = " + users.size());

            request.setAttribute("userList", users);
        } else {
            System.out.println("PROFILE DEBUG: user is not technician");
        }
    }

    private void handleProfileUpdate(HttpServletRequest request, HttpServletResponse response,
            User currentUser, UserDAO dao, HttpSession session)
            throws ServletException, IOException {

        String fullName = request.getParameter("fullname");
        String email = request.getParameter("email");
        String username = request.getParameter("username");

        Part filePart = request.getPart("profileImage");

        if (filePart != null && filePart.getSize() > 0) {
            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String uploadPath = getServletContext().getRealPath("") + File.separator + "images";

            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdir();
            }

            filePart.write(uploadPath + File.separator + fileName);
            currentUser.setProfileImage(fileName);
        }

        currentUser.setFullName(fullName);
        currentUser.setEmail(email);
        currentUser.setUsername(username);

        boolean success = dao.updateUser(currentUser);

        if (success) {
            session.setAttribute("currentUser", currentUser);
            request.setAttribute("message", "Profile updated successfully!");
        } else {
            request.setAttribute("message", "Update failed.");
        }

        loadUserListIfTechnician(request, currentUser);

        request.getRequestDispatcher("Profile.jsp").forward(request, response);
    }

    private String getConfigValue(String key) {
        Properties config = new Properties();

        try (InputStream input = getServletContext().getResourceAsStream("/WEB-INF/config.properties")) {

            if (input == null) {
                System.out.println("config.properties not found in WEB-INF folder.");
                return null;
            }

            config.load(input);
            return config.getProperty(key);

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private void handlePasswordReset(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String recipientEmail = request.getParameter("email");
        String token = UUID.randomUUID().toString();
        LocalDateTime expiry = LocalDateTime.now().plusMinutes(15);

        UserDAO dao = new UserDAO();
        dao.saveResetToken(recipientEmail, token, expiry);

        final String senderEmail = "hirosumi.official@gmail.com";
        final String senderPassword = getConfigValue("HIROSUMI_EMAIL_APP_PASSWORD");

        boolean emailSent = false;

        if (senderPassword == null || senderPassword.trim().isEmpty()) {
            System.out.println("Email app password is missing from config.properties.");
        } else {
            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.host", "smtp.gmail.com");
            props.put("mail.smtp.port", "587");

            javax.mail.Session mailSession = javax.mail.Session.getInstance(props, new javax.mail.Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(senderEmail, senderPassword);
                }
            });

            try {
                String resetLink = "http://localhost:8080/HiroSumiSystem/ResetPasswordServlet?token=" + token;

                String htmlContent = "<h2>Password Reset</h2>"
                        + "<p>You requested a password reset for HiroSumi.</p>"
                        + "<p>This link will expire in 15 minutes.</p>"
                        + "<a href='" + resetLink + "'>Click here to reset your password</a>";

                Message message = new MimeMessage(mailSession);
                message.setFrom(InternetAddress.parse(senderEmail)[0]);
                message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
                message.setSubject("HiroSumi - Password Reset Request");
                message.setContent(htmlContent, "text/html");

                Transport.send(message);
                emailSent = true;

            } catch (MessagingException e) {
                e.printStackTrace();
            }
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        if (emailSent) {
            response.getWriter().write("{\"status\":\"success\"}");
        } else {
            response.getWriter().write("{\"status\":\"error\"}");
        }
    }
}
