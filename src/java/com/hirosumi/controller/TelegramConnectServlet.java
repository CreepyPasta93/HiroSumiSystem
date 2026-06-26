package com.hirosumi.controller;

import com.hirosumi.model.User;
import com.hirosumi.service.TelegramUpdateFetcher;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/TelegramConnectServlet")
public class TelegramConnectServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        process(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        process(request, response);
    }

    private void process(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser.getRole() == null
                || !currentUser.getRole().trim().equalsIgnoreCase("Technician")) {
            response.sendRedirect("ProfileServlet?telegramError=unauthorized");
            return;
        }

        int savedCount = TelegramUpdateFetcher.fetchAndSaveSubscribers(getServletContext());

        response.sendRedirect("ProfileServlet?telegramSaved=" + savedCount);
    }
}