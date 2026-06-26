package com.hirosumi.controller;

import com.hirosumi.dao.DBConnection;
import com.hirosumi.model.User;
import com.hirosumi.service.TelegramNotifier;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/SubmitThresholdRequestServlet")
public class SubmitThresholdRequestServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String sensorName = request.getParameter("sensorName");
        String proposedValueStr = request.getParameter("proposedValue");
        String reason = request.getParameter("reason");

        HttpSession session = request.getSession(false);
        User currentUser = null;

        if (session != null) {
            currentUser = (User) session.getAttribute("currentUser");
        }

        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = currentUser.getUserId();

        if (sensorName == null || sensorName.trim().isEmpty()) {
            sensorName = "Unknown Parameter";
        }

        if (reason == null || reason.trim().isEmpty()) {
            reason = "No reason provided";
        }

        float proposedValue;

        try {
            proposedValue = Float.parseFloat(proposedValueStr);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("ThresholdServlet?status=invalid");
            return;
        }

        boolean savedRequest = false;

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();

            String sql = "INSERT INTO threshold_notifications "
                    + "(type, sensor_name, new_threshold, reason, status, userId) "
                    + "VALUES (?, ?, ?, ?, ?, ?)";

            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, "Update");
            ps.setString(2, sensorName);
            ps.setFloat(3, proposedValue);
            ps.setString(4, reason);
            ps.setString(5, "PENDING");
            ps.setInt(6, userId);

            savedRequest = ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("ThresholdServlet?status=error");
            return;

        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }

        if (savedRequest) {

            String requesterName = currentUser.getFullName() != null
                    ? currentUser.getFullName()
                    : currentUser.getUsername();

            /*
             * 1. Save dashboard notification as plain text.
             * This is for the technician notification popup.
             */
            String dashboardMsg = "New threshold request from "
                    + requesterName
                    + ": " + sensorName
                    + " changed to " + proposedValue
                    + ". Reason: " + reason;

            saveDashboardNotification(userId, dashboardMsg);

            /*
             * 2. Send Telegram alert as HTML.
             * This is for the Telegram bot message.
             */
            String telegramMsg = "📩 <b>New Threshold Change Request</b>\n"
                    + "━━━━━━━━━━━━━━━━\n"
                    + "👤 <b>Requested By:</b> " + escapeHtml(requesterName) + "\n"
                    + "⚙️ <b>Parameter:</b> " + escapeHtml(sensorName) + "\n"
                    + "📌 <b>Proposed Value:</b> " + proposedValue + "°C\n"
                    + "📝 <b>Reason:</b> " + escapeHtml(reason) + "\n"
                    + "━━━━━━━━━━━━━━━━\n"
                    + "🌿 <i>Please review this request in the HiroSumi technician page.</i>";

            boolean telegramSent = TelegramNotifier.sendAlert(getServletContext(), telegramMsg);

            System.out.println("DEBUG threshold request saved? " + savedRequest);
            System.out.println("DEBUG dashboard notification saved.");
            System.out.println("DEBUG threshold Telegram sent? " + telegramSent);

            response.sendRedirect("ThresholdServlet?status=success");

        } else {
            response.sendRedirect("ThresholdServlet?status=error");
        }
    }

    private void saveDashboardNotification(Integer userId, String message) {
        String sql = "INSERT INTO notification_log "
                + "(userId, messageContent, platform, status) "
                + "VALUES (?, ?, 'Threshold', 'PENDING')";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

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
