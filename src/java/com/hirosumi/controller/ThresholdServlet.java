package com.hirosumi.controller;

import com.hirosumi.dao.ConfigurationDAO;
import com.hirosumi.dao.DBConnection;
import com.hirosumi.dao.SystemLogDAO;
import com.hirosumi.model.Configuration;
import com.hirosumi.model.Notification;
import com.hirosumi.model.User;
import com.hirosumi.service.TelegramNotifier;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "ThresholdServlet", urlPatterns = {"/ThresholdServlet"})
public class ThresholdServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        ConfigurationDAO configDao = new ConfigurationDAO();
        Configuration config = configDao.getCurrentConfig();

        if (config == null) {
            config = new Configuration(0, 24.0, 27.0, 10, 32.0, 30.0, 28.0, 75.0, 19, 7);
        }

        List<Notification> userRequests = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection()) {

            String sql = "SELECT * FROM threshold_notifications "
                    + "WHERE userId = ? "
                    + "ORDER BY timestamp DESC";

            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, currentUser.getUserId());

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Notification n = new Notification();
                n.setRequestId(rs.getInt("requestId"));
                n.setSensorName(rs.getString("sensor_name"));
                n.setNewThreshold(rs.getFloat("new_threshold"));
                n.setReason(rs.getString("reason"));
                n.setStatus(rs.getString("status"));
                userRequests.add(n);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("config", config);
        request.setAttribute("userRequests", userRequests);
        request.getRequestDispatcher("threshold.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        javax.servlet.http.HttpSession session = request.getSession();
        com.hirosumi.model.User currentUser
                = (com.hirosumi.model.User) session.getAttribute("currentUser");

        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String reason = request.getParameter("reason");
        String thresholdType = request.getParameter("thresholdType");
        String newLimitStr = request.getParameter("newLimit");

        if (reason == null || reason.trim().isEmpty()) {
            reason = "No reason provided";
        }

        if (thresholdType == null || thresholdType.trim().isEmpty()) {
            thresholdType = "Unknown Parameter";
        }

        float newLimit;

        try {
            newLimit = Float.parseFloat(newLimitStr);
        } catch (Exception e) {
            response.sendRedirect("ThresholdServlet?status=invalid");
            return;
        }

        boolean savedRequest = false;

        try (java.sql.Connection conn = com.hirosumi.dao.DBConnection.getConnection()) {

            String sql = "INSERT INTO threshold_notifications "
                    + "(type, reason, sensor_name, new_threshold, status, timestamp, userId) "
                    + "VALUES ('Update', ?, ?, ?, 'PENDING', NOW(), ?)";

            java.sql.PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, reason);
            ps.setString(2, thresholdType);
            ps.setFloat(3, newLimit);
            ps.setInt(4, currentUser.getUserId());

            savedRequest = ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        SystemLogDAO logDao = new SystemLogDAO();

        if (savedRequest) {

            // 1. Save dashboard notification as plain text
            String dashboardMsg = "New threshold request from "
                    + currentUser.getFullName()
                    + ": " + thresholdType
                    + " changed to " + newLimit
                    + ". Reason: " + reason;

            saveDashboardNotification(currentUser.getUserId(), dashboardMsg);

            // 2. Send Telegram message as HTML
            String telegramMsg = "📩 <b>New Threshold Change Request</b>\n"
                    + "━━━━━━━━━━━━━━━━\n"
                    + "👤 <b>Requested By:</b> " + escapeHtml(currentUser.getFullName()) + "\n"
                    + "⚙️ <b>Parameter:</b> " + escapeHtml(thresholdType) + "\n"
                    + "📌 <b>Proposed Value:</b> " + newLimit + "°C\n"
                    + "📝 <b>Reason:</b> " + escapeHtml(reason) + "\n"
                    + "━━━━━━━━━━━━━━━━\n"
                    + "🌿 <i>Please review this request in the HiroSumi technician page.</i>";

            boolean telegramSent = TelegramNotifier.sendAlert(getServletContext(), telegramMsg);

            System.out.println("DEBUG threshold request saved? " + savedRequest);
            System.out.println("DEBUG dashboard notification saved.");
            System.out.println("DEBUG threshold Telegram sent? " + telegramSent);

            if (telegramSent) {
                logDao.insertLog("Volunteer Panel", "CONFIG",
                        "Threshold request submitted and Telegram alert sent", "Success");
            } else {
                logDao.insertLog("Volunteer Panel", "CONFIG",
                        "Threshold request submitted but Telegram alert failed", "Warning");
            }

            response.sendRedirect("ThresholdServlet?status=success");

        } else {
            logDao.insertLog("Volunteer Panel", "ERROR",
                    "Failed to save threshold request", "Failed");

            response.sendRedirect("ThresholdServlet?status=error");
        }
    }

    private void saveDashboardNotification(Integer userId, String message) {
        String sql = "INSERT INTO notification_log "
                + "(userId, messageContent, platform, status) "
                + "VALUES (?, ?, 'Threshold', 'PENDING')";

        try (java.sql.Connection conn = com.hirosumi.dao.DBConnection.getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {

            if (userId == null) {
                ps.setNull(1, java.sql.Types.INTEGER);
            } else {
                ps.setInt(1, userId);
            }

            ps.setString(2, message);
            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private String escapeHtml(String value) {
        if (value == null) {
            return "";
        }

        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;");
    }
}
