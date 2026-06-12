package com.hirosumi.controller;

import com.hirosumi.dao.NotificationLogDAO;
import com.hirosumi.model.NotificationLog;
import com.hirosumi.dao.AnalyticsDAO;
import com.hirosumi.dao.SystemLogDAO;
import com.hirosumi.model.SensorData;
import com.hirosumi.service.TelegramNotifier;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "DashboardServlet", urlPatterns = {"/DashboardServlet"})
public class DashboardServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        AnalyticsDAO dao = new AnalyticsDAO();

        if ("getNotifications".equals(action)) {
            getLatestNotifications(request, response);
            return;
        }

        // ==========================================
        // 1. AJAX REQUEST: Graph Data Update
        // ==========================================
        if ("fetchData".equals(action)) {
            String startDate = request.getParameter("start");
            String endDate = request.getParameter("end");
            List<SensorData> data;

            if (startDate != null && !startDate.isEmpty() && endDate != null && !endDate.isEmpty()) {
                data = dao.getReadingsByDateRange(startDate, endDate);
            } else {
                data = dao.getRecentReadings(20);
            }

            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            StringBuilder json = new StringBuilder("[");
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");

            for (int i = 0; i < data.size(); i++) {
                SensorData d = data.get(i);
                json.append("{");
                json.append("\"time\":\"").append(sdf.format(d.getTimestamp())).append("\",");
                json.append("\"temp\":").append(d.getTemperature()).append(",");
                json.append("\"hum\":").append(d.getHumidity()).append(",");
                json.append("\"pres\":").append(d.getPressure()).append(",");
                json.append("\"fan\":").append(d.getFanStatus()); // 🆕 Added for Analytics
                json.append("}");
                if (i < data.size() - 1) {
                    json.append(",");
                }
            }
            json.append("]");
            out.print(json.toString());
            out.flush();
            return;
        } // ==========================================
        // 2. MANUAL REPORT (Bell Click)
        // ==========================================
        else if ("sendReport".equals(action)) {
            SensorData current = dao.getLatestReading();
            SystemLogDAO logDao = new SystemLogDAO();
            String msg;
            boolean success = false;

            if (current != null) {
                // A. CALCULATE COMFORT STATUS
                double t = current.getTemperature();
                String statusEmoji = "🌡";
                String statusText = "Stable";

                if (t < 20.0) {
                    statusEmoji = "❄️";
                    statusText = "Chilly (Heater Active)";
                } else if (t >= 20.0 && t <= 25.0) {
                    statusEmoji = "🌿";
                    statusText = "Mild & Fresh";
                } else if (t > 25.0 && t < 29.0) {
                    statusEmoji = "💚";
                    statusText = "Perfectly Cozy";
                } else {
                    statusEmoji = "🔥";
                    statusText = "Warm";
                }

                // B. CALCULATE MOTION (From Session)
                String motionText = "No recent activity";
                int motion = current.getMotionStatus();

                if (motion == 1) {
                    motionText = "🏃 ACTIVE NOW!";
                } else {
                    Long lastSeen = (Long) request.getSession().getAttribute("lastMotionTime");
                    if (lastSeen != null) {
                        long diffMins = (System.currentTimeMillis() - lastSeen) / 60000;
                        motionText = (diffMins < 1) ? "Just now" : diffMins + " mins ago";
                    }
                }

                // C. FAN STATUS LOGIC 🆕
                String fanText = (current.getFanStatus() == 1) ? "🔄 SPINNING" : "🛑 IDLE";

                // D. SAFE TIME FORMATTING
                String timeStr = "Unknown";
                try {
                    timeStr = current.getTimestamp().toString().substring(0, 16);
                } catch (Exception e) {
                }

                // E. BUILD MESSAGE
                msg = String.format("📢 *HiroSumi Status Report*\n"
                        + "────────────────\n"
                        + "%s *%s*\n"
                        + "🌡 Temp: %.2f°C\n"
                        + "💧 Humidity: %.2f%%\n"
                        + "🐾 Motion: %s\n"
                        + "🌀 Fan: %s\n" // 🆕 Added to Telegram
                        + "────────────────\n"
                        + "🕒 %s",
                        statusEmoji, statusText,
                        current.getTemperature(),
                        current.getHumidity(),
                        motionText,
                        fanText,
                        timeStr);

                success = TelegramNotifier.sendAlert(getServletContext(), msg);

            } else {
                msg = "⚠️ *HiroSumi Alert*: System is offline.";
                success = TelegramNotifier.sendAlert(getServletContext(), msg);
            }

            if (success) {
                logDao.insertLog("Dashboard", "ACTION", "Manual Status Report Sent", "Success");
            } else {
                logDao.insertLog("Dashboard", "ERROR", "Failed to send Manual Report", "Failed");
            }

            response.setContentType("text/plain");
            response.getWriter().write(success ? "success" : "failed");
            return;
        }

        // ==========================================
        // 3. STANDARD PAGE LOAD
        // ==========================================
        SensorData latest = dao.getLatestReading();

        if (latest == null) {
            // Updated to include the new 0 for fanStatus
            latest = new SensorData(0, 0.0, 0.0, 0.0, 0, 0, new java.sql.Timestamp(System.currentTimeMillis()));
        }

        request.setAttribute("latest", latest);
        request.getRequestDispatcher("dashboard.jsp").forward(request, response);
    }

    private void getLatestNotifications(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        NotificationLogDAO dao = new NotificationLogDAO();
        List<NotificationLog> logs = dao.getLatestNotifications(5);

        SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy, hh:mm a");

        StringBuilder json = new StringBuilder();
        json.append("[");

        for (int i = 0; i < logs.size(); i++) {
            NotificationLog log = logs.get(i);

            String message = log.getMessageContent() != null ? log.getMessageContent() : "";
            String platform = log.getPlatform() != null ? log.getPlatform() : "";
            String status = log.getStatus() != null ? log.getStatus() : "";
            String time = log.getSentTimestamp() != null ? sdf.format(log.getSentTimestamp()) : "Unknown time";

            json.append("{");
            json.append("\"logId\":").append(log.getLogId()).append(",");
            json.append("\"messageContent\":\"").append(escapeJson(message)).append("\",");
            json.append("\"platform\":\"").append(escapeJson(platform)).append("\",");
            json.append("\"sentTimestamp\":\"").append(escapeJson(time)).append("\",");
            json.append("\"status\":\"").append(escapeJson(status)).append("\"");
            json.append("}");

            if (i < logs.size() - 1) {
                json.append(",");
            }
        }

        json.append("]");

        response.getWriter().write(json.toString());
    }

    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }

        return value.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", " ")
                .replace("\r", " ");
    }
}
