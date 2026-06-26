package com.hirosumi.controller;

import com.hirosumi.dao.NotificationLogDAO;
import com.hirosumi.model.NotificationLog;
import com.hirosumi.dao.AnalyticsDAO;
import com.hirosumi.dao.SystemLogDAO;
import com.hirosumi.model.SensorData;
import com.hirosumi.service.TelegramNotifier;
import com.hirosumi.service.ThingSpeakFetcher;
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

            /*
     * Sync latest ThingSpeak reading before sending Telegram report.
     * This only happens when user clicks Send Report, not on dashboard refresh.
             */
            try {
                ThingSpeakFetcher fetcher = new ThingSpeakFetcher();
                fetcher.fetchAndSaveData(getServletContext(), false);
            } catch (Exception e) {
                System.out.println("ThingSpeak sync before Telegram report failed: " + e.getMessage());
                e.printStackTrace();
            }

            SensorData current = dao.getLatestReading();
            SystemLogDAO logDao = new SystemLogDAO();
            String msg;
            boolean success = false;

            if (current != null) {

                double t = current.getTemperature();
                String statusEmoji = "🌡";
                String statusText = "Stable";
                String comfortNote = "HiroSumi is monitoring the shelter environment.";

                if (t < 20.0) {
                    statusEmoji = "❄️";
                    statusText = "Chilly";
                    comfortNote = "The shelter feels chilly. Heater support may help keep the cats warm.";
                } else if (t >= 20.0 && t <= 25.0) {
                    statusEmoji = "🌿";
                    statusText = "Mild & Fresh";
                    comfortNote = "The shelter looks fresh and comfortable for the cats.";
                } else if (t > 25.0 && t < 29.0) {
                    statusEmoji = "💚";
                    statusText = "Cozy";
                    comfortNote = "The shelter is in a cozy range for resting cats.";
                } else if (t >= 29.0 && t <= 31.0) {
                    statusEmoji = "🌤";
                    statusText = "Warm";
                    comfortNote = "The shelter is a little warm. Ventilation should stay active.";
                } else {
                    statusEmoji = "🔥";
                    statusText = "Hot";
                    comfortNote = "The shelter is hot. Please check airflow and cat comfort soon.";
                }

                String motionText = "No recent activity";
                int motion = current.getMotionStatus();

                if (motion == 1) {
                    motionText = "Active now";
                } else {
                    Long lastSeen = (Long) request.getSession().getAttribute("lastMotionTime");

                    if (lastSeen != null) {
                        long diffMins = (System.currentTimeMillis() - lastSeen) / 60000;
                        motionText = (diffMins < 1) ? "Just now" : diffMins + " mins ago";
                    }
                }

                String fanText = (current.getFanStatus() == 1) ? "Spinning" : "Idle";

                String timeStr = "Unknown";
                try {
                    timeStr = current.getTimestamp().toString().substring(0, 16);
                } catch (Exception e) {
                    e.printStackTrace();
                }

                msg = String.format("🌸 <b>HiroSumi Shelter Report</b>\n"
                        + "━━━━━━━━━━━━━━━━\n"
                        + "🐱 <b>Comfort Status:</b> %s %s\n"
                        + "🌡 <b>Temperature:</b> %.2f°C\n"
                        + "💧 <b>Humidity:</b> %.2f%%\n"
                        + "🌬 <b>Pressure:</b> %.2f kPa\n"
                        + "🐾 <b>Cat Activity:</b> %s\n"
                        + "🌀 <b>Fan:</b> %s\n"
                        + "━━━━━━━━━━━━━━━━\n"
                        + "🕒 <b>Latest Reading:</b> %s\n"
                        + "🍓 <i>%s</i>",
                        statusEmoji,
                        statusText,
                        current.getTemperature(),
                        current.getHumidity(),
                        current.getPressure(),
                        motionText,
                        fanText,
                        timeStr,
                        comfortNote);

                success = TelegramNotifier.sendAlert(getServletContext(), msg);

            } else {
                msg = "⚠️ <b>HiroSumi Alert</b>\n"
                        + "━━━━━━━━━━━━━━━━\n"
                        + "The system is currently offline or no sensor reading is available.";

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
