package com.hirosumi.controller;

import com.hirosumi.dao.UserDAO;
import com.hirosumi.model.User;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/ForceChangePasswordServlet")
public class ForceChangePasswordServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = null;

        if (session != null) {
            currentUser = (User) session.getAttribute("currentUser");
        }

        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmpassword");

        if (password == null || confirmPassword == null || password.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Please fill in all password fields.");
            request.getRequestDispatcher("forceChangePassword.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("errorMessage", "Passwords do not match.");
            request.getRequestDispatcher("forceChangePassword.jsp").forward(request, response);
            return;
        }

        if (!isStrongPassword(password)) {
            request.setAttribute("errorMessage", "Password must be at least 8 characters and include uppercase, lowercase, number, and special character.");
            request.getRequestDispatcher("forceChangePassword.jsp").forward(request, response);
            return;
        }

        UserDAO dao = new UserDAO();
        boolean success = dao.updatePasswordByUserId(currentUser.getUserId(), password);

        if (success) {
            currentUser.setMustChangePassword(false);
            session.setAttribute("currentUser", currentUser);
            response.sendRedirect("DashboardServlet");
        } else {
            request.setAttribute("errorMessage", "Failed to update password. Please try again.");
            request.getRequestDispatcher("forceChangePassword.jsp").forward(request, response);
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