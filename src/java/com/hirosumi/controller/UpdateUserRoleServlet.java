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

@WebServlet(name = "UpdateUserRoleServlet", urlPatterns = {"/UpdateUserRoleServlet"})
public class UpdateUserRoleServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser.getRole() == null || !currentUser.getRole().equalsIgnoreCase("Technician")) {
            response.sendRedirect("ProfileServlet?roleError=unauthorized");
            return;
        }

        try {
            int targetUserId = Integer.parseInt(request.getParameter("userId"));
            String newRole = request.getParameter("newRole");

            // Prevent technician from changing their own role accidentally
            if (targetUserId == currentUser.getUserId()) {
                response.sendRedirect("ProfileServlet?roleError=self");
                return;
            }

            UserDAO dao = new UserDAO();
            boolean success = dao.updateUserRole(targetUserId, newRole);

            if (success) {
                response.sendRedirect("ProfileServlet?roleSuccess=updated");
            } else {
                response.sendRedirect("ProfileServlet?roleError=failed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("ProfileServlet?roleError=invalid");
        }
    }
}