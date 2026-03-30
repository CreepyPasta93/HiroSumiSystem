package com.hirosumi.controller;

import com.hirosumi.dao.UserDAO;
import com.hirosumi.model.User;
import java.time.LocalDateTime;
import java.util.UUID;
import java.io.File;
import java.io.IOException;
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
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

/**
 * ProfileServlet handles profile updates, image uploads, and the password reset
 * email process using Jakarta/JavaMail.
 */
@MultipartConfig
@WebServlet("/ProfileServlet")
public class ProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Standard forward to the profile page
        request.getRequestDispatcher("Profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        // Session validation
        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        UserDAO dao = new UserDAO();

        if ("update".equals(action)) {
            handleProfileUpdate(request, response, currentUser, dao, session);
        } else if ("resetPassword".equals(action)) {
            handlePasswordReset(request, response);
        }
    }

    /**
     * Updates user information and handles profile image uploads.
     */
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

        request.getRequestDispatcher("Profile.jsp").forward(request, response);
    }

    /**
     * Generates a token, saves it to the DB, and sends a reset email via Gmail.
     */
    private void handlePasswordReset(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String recipientEmail = request.getParameter("email");
        String token = UUID.randomUUID().toString();
        LocalDateTime expiry = LocalDateTime.now().plusMinutes(15);

        // 1. Save token to DB
        UserDAO dao = new UserDAO();
        dao.saveResetToken(recipientEmail, token, expiry);

        // 2. SMTP Settings 
        // Use the new account you created specifically for the project
        final String senderEmail = "hirosumi.official@gmail.com";
        final String senderPassword = "joxg fnpb cftf ippc"; // The 16-digit App Password

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");

        Session mailSession = Session.getInstance(props, new javax.mail.Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(senderEmail, senderPassword);
            }
        });

        boolean emailSent = false;

        try {
            // 3. Prepare Reset Link and HTML content
            String resetLink = "http://localhost:8080/HiroSumiSystem/ResetPasswordServlet?token=" + token;
            String htmlContent = "<h2>Password Reset</h2>"
                    + "<p>You requested a password reset for HiroSumi.</p>"
                    + "<p>This link will expire in 15 minutes.</p>"
                    + "<a href='" + resetLink + "'>Click here to reset your password</a>";

            // 4. Create and Send Email
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

        // 5. Send JSON response back to SweetAlert in Profile.jsp
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        if (emailSent) {
            response.getWriter().write("{\"status\":\"success\"}");
        } else {
            response.getWriter().write("{\"status\":\"error\"}");
        }
    }
}
