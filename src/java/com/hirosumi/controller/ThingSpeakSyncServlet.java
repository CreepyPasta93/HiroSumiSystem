package com.hirosumi.controller;

import com.hirosumi.service.ThingSpeakFetcher;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "ThingSpeakSyncServlet", urlPatterns = {"/ThingSpeakSyncServlet"})
public class ThingSpeakSyncServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        sync(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        sync(request, response);
    }

    private void sync(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("currentUser") == null) {
            response.setContentType("text/plain");
            response.getWriter().write("unauthorized");
            return;
        }

        ThingSpeakFetcher fetcher = new ThingSpeakFetcher();
        boolean success = fetcher.fetchAndSaveData(getServletContext(), false);

        response.setContentType("text/plain");
        response.getWriter().write(success ? "success" : "failed");
    }
}