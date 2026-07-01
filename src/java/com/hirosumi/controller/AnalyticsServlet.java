package com.hirosumi.controller;

import com.hirosumi.model.User;
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

        String fanRuntime = dao.getFanRuntimeLast7Days();

        int totalReadings7Days = dao.getTotalReadingsLast7Days();
        int hotReadings7Days = dao.getHotReadingsLast7Days();
        int hotDays7Days = dao.getHotDaysLast7Days();
        String peakHeatPeriod = dao.getPeakHeatPeriod();
        int fanOnButStillHot = dao.getFanOnButStillHotCount();
        int[] dailyHotReadings = dao.getDailyHotReadingsLast7Days();

        int[] alerts = dao.getWeeklyAlerts();

        List<SensorData> dataList = dao.getAllReadings();
        int totalRecords = (dataList != null) ? dataList.size() : 0;

        int comfortScore = 100;

        if (avgTemp >= 30) {
            comfortScore -= 25;
        } else if (avgTemp >= 28) {
            comfortScore -= 15;
        }

        if (avgHum >= 80) {
            comfortScore -= 15;
        } else if (avgHum >= 75) {
            comfortScore -= 8;
        }

        if (hotDays7Days >= 3) {
            comfortScore -= 20;
        }

        if (fanOnButStillHot >= 3) {
            comfortScore -= 15;
        }

        if (comfortScore < 0) {
            comfortScore = 0;
        }

        String heatRiskLevel;

        if (comfortScore >= 80) {
            heatRiskLevel = "Comfortable";
        } else if (comfortScore >= 60) {
            heatRiskLevel = "Moderate Heat Risk";
        } else {
            heatRiskLevel = "High Heat Risk";
        }

        String heatPatternInsight;

        if (totalReadings7Days == 0) {
            heatPatternInsight = "Not enough sensor data has been collected yet to detect a long-term heat pattern.";
        } else if (hotDays7Days >= 3) {
            heatPatternInsight = "Repeated heat pattern detected. The shelter recorded hot readings across "
                    + hotDays7Days + " different days this week, especially during the "
                    + peakHeatPeriod.toLowerCase()
                    + ". This suggests the shelter may need stronger ventilation, better roof insulation, or a more shaded placement.";
        } else if (hotReadings7Days > 0) {
            heatPatternInsight = "Some warm readings were detected, but the heat pattern is not continuous yet. The system should keep monitoring before recommending major hardware changes.";
        } else {
            heatPatternInsight = "No repeated heat pattern was detected this week. The shelter environment appears stable.";
        }

        String fanEffectivenessInsight;

        if (fanOnButStillHot >= 3) {
            fanEffectivenessInsight = "Ventilation may need improvement. The fan was active during several hot readings, but the shelter temperature still remained high. Consider adding another fan, checking airflow openings, or placing the shelter under better shade.";
        } else if (hotReadings7Days > 0) {
            fanEffectivenessInsight = "The fan appears to be helping with short warm periods. Continue monitoring to confirm whether the shelter cools down after ventilation starts.";
        } else {
            fanEffectivenessInsight = "Fan usage appears efficient because no major repeated heat problem was detected.";
        }

        GrokService grokService = new GrokService();
        String aiInsight = grokService.generateAnalyticsInsight(
                getServletContext(),
                avgTemp,
                avgHum,
                fanRuntime,
                totalRecords,
                comfortScore,
                heatRiskLevel,
                heatPatternInsight,
                fanEffectivenessInsight
        );

        request.setAttribute("avgTemp", avgTemp);
        request.setAttribute("avgHum", avgHum);
        request.setAttribute("fanRuntime", fanRuntime);
        request.setAttribute("dataList", dataList);
        request.setAttribute("aiInsight", aiInsight);

        request.setAttribute("comfortScore", comfortScore);
        request.setAttribute("heatRiskLevel", heatRiskLevel);
        request.setAttribute("heatPatternInsight", heatPatternInsight);
        request.setAttribute("fanEffectivenessInsight", fanEffectivenessInsight);
        request.setAttribute("hotDays7Days", hotDays7Days);
        request.setAttribute("peakHeatPeriod", peakHeatPeriod);

        StringBuilder alertString = new StringBuilder();

        for (int i = 0; i < alerts.length; i++) {
            alertString.append(alerts[i]);

            if (i < alerts.length - 1) {
                alertString.append(",");
            }
        }

        request.setAttribute("alertData", alertString.toString());

        StringBuilder heatRiskData = new StringBuilder();

        for (int i = 0; i < dailyHotReadings.length; i++) {
            heatRiskData.append(dailyHotReadings[i]);

            if (i < dailyHotReadings.length - 1) {
                heatRiskData.append(",");
            }
        }

        request.setAttribute("heatRiskData", heatRiskData.toString());

        request.getRequestDispatcher("analytics.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = (User) request.getSession().getAttribute("currentUser");

        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Only technician can delete or prune sensor data
        String userRole = currentUser.getRole();

        boolean isTechnician = userRole != null
                && (userRole.equalsIgnoreCase("Technician")
                || userRole.equalsIgnoreCase("System Technician"));

        if (!isTechnician) {
            response.sendRedirect("AnalyticsServlet?error=unauthorized");
            return;
        }

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
