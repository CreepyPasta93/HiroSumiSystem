package com.hirosumi.controller;

import com.hirosumi.dao.AnalyticsDAO;
import com.hirosumi.model.SensorData;
import com.hirosumi.service.GrokService;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "AnalyticsServlet", urlPatterns = {"/AnalyticsServlet"})
public class AnalyticsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        AnalyticsDAO dao = new AnalyticsDAO();

        double avgTemp = dao.getAverageTemp();
        double avgHum = dao.getAverageHumidity();
        String runtime = dao.getHeaterRuntime();
        int[] alerts = dao.getWeeklyAlerts();

        List<SensorData> dataList = dao.getAllReadings();
        int totalRecords = (dataList != null) ? dataList.size() : 0;

        GrokService grokService = new GrokService();
        String aiInsight = grokService.generateAnalyticsInsight(
                avgTemp,
                avgHum,
                runtime,
                totalRecords
        );

        request.setAttribute("avgTemp", avgTemp);
        request.setAttribute("avgHum", avgHum);
        request.setAttribute("heaterRuntime", runtime);
        request.setAttribute("dataList", dataList);
        request.setAttribute("aiInsight", aiInsight);

        StringBuilder alertString = new StringBuilder();

        for (int i = 0; i < alerts.length; i++) {
            alertString.append(alerts[i]);

            if (i < alerts.length - 1) {
                alertString.append(",");
            }
        }

        request.setAttribute("alertData", alertString.toString());

        request.getRequestDispatcher("analytics.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        AnalyticsDAO dao = new AnalyticsDAO();

        if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            dao.deleteReading(id);
        } else if ("prune".equals(action)) {
            dao.deleteOldestReadings(10);
        }

        response.sendRedirect("AnalyticsServlet");
    }
}