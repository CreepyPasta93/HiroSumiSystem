package com.hirosumi.controller;

import com.hirosumi.dao.AnalyticsDAO;
import com.hirosumi.model.SensorData;
import com.hirosumi.service.ThingSpeakFetcher;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "AnalyticsServlet", urlPatterns = {"/AnalyticsServlet"})
public class AnalyticsServlet extends HttpServlet {

    // 1. DISPLAY PAGE (Sync Data + Load KPIs + Load Table)
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // A. Sync ThingSpeak
        //ThingSpeakFetcher fetcher = new ThingSpeakFetcher();
        //fetcher.fetchAndSaveData();

        // B. Fetch KPIs
        AnalyticsDAO dao = new AnalyticsDAO();
        double avgTemp = dao.getAverageTemp();
        double avgHum = dao.getAverageHumidity();
        String runtime = dao.getHeaterRuntime();
        int[] alerts = dao.getWeeklyAlerts();

        // C. Fetch Table Data (Fixes the "No Data" issue)
        List<SensorData> dataList = dao.getAllReadings();

        // D. Send to JSP
        request.setAttribute("avgTemp", avgTemp);
        request.setAttribute("avgHum", avgHum);
        request.setAttribute("heaterRuntime", runtime);
        request.setAttribute("dataList", dataList); // Send the list!

        StringBuilder alertString = new StringBuilder();
        for (int i = 0; i < alerts.length; i++) {
            alertString.append(alerts[i]).append(i < alerts.length - 1 ? "," : "");
        }
        request.setAttribute("alertData", alertString.toString());

        request.getRequestDispatcher("analytics.jsp").forward(request, response);
    }

    // 2. HANDLE BUTTON CLICKS (Add / Delete)
    // ... inside doPost ...
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        AnalyticsDAO dao = new AnalyticsDAO();

        if ("delete".equals(action)) {
            // 🆕 Parse ID instead of Timestamp
            int id = Integer.parseInt(request.getParameter("id"));
            dao.deleteReading(id);
        } else if ("prune".equals(action)) {
            dao.deleteOldestReadings(10);
        }

        response.sendRedirect("AnalyticsServlet");
    }
}
