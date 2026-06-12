package com.hirosumi.controller;

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

        int savedCount = TelegramUpdateFetcher.fetchAndSaveSubscribers(getServletContext());

        response.sendRedirect("dashboard.jsp?telegramSaved=" + savedCount);
    }
}
