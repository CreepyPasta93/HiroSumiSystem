package com.hirosumi.controller;

import com.hirosumi.dao.UserDAO;
import com.hirosumi.model.User;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Retrieve Data from Form
        String fullName = request.getParameter("fullname");
        String email = request.getParameter("email");
        String username = request.getParameter("username"); // Needed for DB
        String pass = request.getParameter("password");
        String confirmPass = request.getParameter("confirmpassword");

        // 2. Simple Validation
        if (!pass.equals(confirmPass)) {
            request.setAttribute("errorMessage", "Passwords do not match!");
            request.getRequestDispatcher("signup.jsp").forward(request, response);
            return;
        }

        // 3. Create User Object
        User newUser = new User();
        newUser.setFullName(fullName);
        newUser.setEmail(email);
        newUser.setUsername(username);
        
        // 4. Save to DB
        UserDAO dao = new UserDAO();
        boolean success = dao.registerUser(newUser, pass);

        if (success) {
            // Registration Success -> Go to Login
            response.sendRedirect("login.jsp");
        } else {
            // Failed (likely duplicate username/email)
            request.setAttribute("errorMessage", "Registration failed. Username or Email may already exist.");
            request.getRequestDispatcher("signup.jsp").forward(request, response);
        }
    }
}