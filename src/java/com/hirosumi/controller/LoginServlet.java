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

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String user = request.getParameter("username");
        String pass = request.getParameter("password");
        String role = request.getParameter("role");

        UserDAO dao = new UserDAO();

        // Check if account exists but email is not verified
        if (dao.isUsernameExists(user) && !dao.isUserVerified(user)) {
            request.setAttribute("errorMessage", "Please verify your email before logging in.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        User userObj = dao.authenticateUser(user, pass, role);

        if (userObj != null) {
            HttpSession session = request.getSession();
            session.setAttribute("currentUser", userObj);

            if (userObj.isMustChangePassword()) {
                response.sendRedirect("forceChangePassword.jsp");
            } else {
                response.sendRedirect("DashboardServlet");
            }

        } else {
            request.setAttribute("errorMessage", "Oops! Please check your role, username, or password.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}