package com.hirosumi.controller;

import com.hirosumi.dao.UserDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet; // Import added
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

// 1. ADD THIS ANNOTATION - This links your JSP forms to this Servlet
@WebServlet("/ResetPasswordServlet") 
public class ResetPasswordServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String token = request.getParameter("token");

        // Safety check: ensure token exists
        if (token == null || token.isEmpty()) {
            request.setAttribute("error", "Invalid reset link.");
            request.getRequestDispatcher("reset-invalid.jsp").forward(request, response);
            return;
        }

        UserDAO dao = new UserDAO();
        // This method should return the email if the token is valid and not expired
        String email = dao.validateResetToken(token);

        if (email == null) {
            request.setAttribute("error", "This reset link has expired or is invalid.");
            request.getRequestDispatcher("reset-invalid.jsp").forward(request, response);
        } else {
            // Pass the token to the JSP so it can be included in the hidden form field
            request.setAttribute("token", token);
            request.getRequestDispatcher("ResetPassword.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get the hidden token and the new password from the ResetPassword.jsp form
        String token = request.getParameter("token");
        String newPassword = request.getParameter("password");

        if (token == null || newPassword == null || newPassword.isEmpty()) {
            request.setAttribute("error", "Password cannot be empty.");
            request.getRequestDispatcher("reset-invalid.jsp").forward(request, response);
            return;
        }

        UserDAO dao = new UserDAO();
        
        // 1. Validate token again for security during the POST
        String email = dao.validateResetToken(token);

        if (email != null) {
            // 2. Update the password in the database
            // Ensure this method exists in your UserDAO
            boolean success = dao.updatePasswordByEmail(email, newPassword);

            if (success) {
                // 3. IMPORTANT: Delete the token so it cannot be used a second time
                dao.deleteResetToken(token);
                
                request.setAttribute("message", "Password changed successfully! Please login.");
                // Use forward to login.jsp so the message can be displayed
                request.getRequestDispatcher("login.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Database error. Please try again later.");
                request.getRequestDispatcher("reset-invalid.jsp").forward(request, response);
            }
        } else {
            request.setAttribute("error", "Your session has expired. Please request a new link.");
            request.getRequestDispatcher("reset-invalid.jsp").forward(request, response);
        }
    }
}