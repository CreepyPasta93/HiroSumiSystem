package com.hirosumi.controller;

import com.hirosumi.dao.UserDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/VerifyEmailServlet")
public class VerifyEmailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String token = request.getParameter("token");
        UserDAO dao = new UserDAO();

        boolean success = dao.verifyUserByToken(token);

        if (success) {
            request.setAttribute("successMessage", "Email verified successfully! You can now log in.");
        } else {
            request.setAttribute("errorMessage", "Verification link is invalid or expired.");
        }

        request.getRequestDispatcher("login.jsp").forward(request, response);
    }
}