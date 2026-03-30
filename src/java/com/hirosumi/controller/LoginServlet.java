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

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String user = request.getParameter("username");
        String pass = request.getParameter("password");
        String role = request.getParameter("role"); // Getting the toggle value

        UserDAO dao = new UserDAO();
        User userObj = dao.authenticateUser(user, pass, role);

        if (userObj != null) {
            // Login Success
            HttpSession session = request.getSession();
            session.setAttribute("currentUser", userObj);

            // Redirect based on role (optional, or just go to dashboard)
            response.sendRedirect("DashboardServlet"); 
        } else {
            // Login Failed
            request.setAttribute("errorMessage", "Invalid Credentials or Role Selection");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}
