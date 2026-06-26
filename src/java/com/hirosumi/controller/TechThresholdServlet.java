package com.hirosumi.controller;

import com.hirosumi.dao.ConfigurationDAO;
import com.hirosumi.dao.DBConnection;
import com.hirosumi.dao.SystemLogDAO;
import com.hirosumi.model.Configuration;
import com.hirosumi.model.Notification;
import com.hirosumi.model.User;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList; // Added
import java.util.List;      // Added
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "TechThresholdServlet", urlPatterns = {"/TechThresholdServlet"})
public class TechThresholdServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // --- 🔔 NEW: NOTIFICATION FETCHING LOGIC 🔔 ---
        List<Notification> notifList = new ArrayList<>();
        int pendingCount = 0;

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT * FROM threshold_notifications ORDER BY timestamp DESC";
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Notification n = new Notification();
                n.setRequestId(rs.getInt("requestId"));
                n.setSensorName(rs.getString("sensor_name"));
                n.setNewThreshold(rs.getFloat("new_threshold"));
                n.setReason(rs.getString("reason"));
                n.setUserId(rs.getInt("userId"));
                n.setStatus(rs.getString("status"));
                notifList.add(n);
                pendingCount++;
            }
            // Pass the list and count to the tech_threshold.jsp
            request.setAttribute("notifications", notifList);
            request.setAttribute("pendingCount", pendingCount);

        } catch (Exception e) {
            e.printStackTrace();
        }
        // ----------------------------------------------

        ConfigurationDAO dao = new ConfigurationDAO();
        Configuration config = dao.getCurrentConfig();

        if (config == null) {
            config = new Configuration(0, 24.0, 27.0, 10, 32.0, 30.0, 28.0, 75.0, 19, 7);
        }

        request.setAttribute("config", config);
        request.getRequestDispatcher("tech_threshold.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("reviewRequest".equals(action)) {
            reviewThresholdRequest(request, response);
            return;
        }

        try {
            double hAct = Double.parseDouble(request.getParameter("heaterAct"));
            double hCut = Double.parseDouble(request.getParameter("heaterCut"));
            double fAct = Double.parseDouble(request.getParameter("fanAct"));
            double fCut = Double.parseDouble(request.getParameter("fanCut"));
            double humThresh = Double.parseDouble(request.getParameter("humThresh"));
            int nStart = Integer.parseInt(request.getParameter("nightStart"));
            int nEnd = Integer.parseInt(request.getParameter("nightEnd"));

            // Get hidden values or provide defaults
            String lDurStr = request.getParameter("lightDur");
            int lDur = (lDurStr != null) ? Integer.parseInt(lDurStr) : 10;

            String sAlertStr = request.getParameter("safetyAlert");
            double sAlert = (sAlertStr != null) ? Double.parseDouble(sAlertStr) : 32.0;

            ConfigurationDAO dao = new ConfigurationDAO();
            boolean success = dao.updateConfig(hAct, hCut, lDur, sAlert, fAct, fCut, humThresh, nStart, nEnd);

            SystemLogDAO logDao = new SystemLogDAO();
            if (success) {
                logDao.insertLog("Admin Panel", "SYSTEM", "Thresholds forcefully updated by Technician", "Success");
                response.sendRedirect("TechThresholdServlet?status=updated");
            } else {
                logDao.insertLog("Admin Panel", "ERROR", "Failed to update thresholds", "Failed");
                response.sendRedirect("TechThresholdServlet?status=error");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("TechThresholdServlet?status=error");
        }
    }

    private void reviewThresholdRequest(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        User currentUser = null;

        if (session != null) {
            currentUser = (User) session.getAttribute("currentUser");
        }

        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        if (currentUser.getRole() == null
                || !currentUser.getRole().equalsIgnoreCase("Technician")) {
            response.sendRedirect("TechThresholdServlet?status=unauthorized");
            return;
        }

        String requestIdStr = request.getParameter("requestId");
        String decision = request.getParameter("decision");

        if (decision == null || decision.trim().isEmpty()) {
            decision = "PENDING";
        }

        decision = decision.trim().toUpperCase();

        if (!decision.equals("PENDING")
                && !decision.equals("APPROVED")
                && !decision.equals("DENIED")) {
            response.sendRedirect("TechThresholdServlet?status=invalid");
            return;
        }

        try {
            int requestId = Integer.parseInt(requestIdStr);

            String sql = "UPDATE threshold_notifications "
                    + "SET status = ? "
                    + "WHERE requestId = ?";

            try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

                ps.setString(1, decision);
                ps.setInt(2, requestId);

                int rows = ps.executeUpdate();

                SystemLogDAO logDao = new SystemLogDAO();

                if (rows > 0) {
                    logDao.insertLog("Technician Panel", "CONFIG",
                            "Threshold request #" + requestId + " marked as " + decision,
                            "Success");

                    saveDashboardNotification(
                            currentUser.getUserId(),
                            "Threshold request #" + requestId + " was marked as " + decision + " by technician."
                    );

                    response.sendRedirect("TechThresholdServlet?status=reviewed");
                } else {
                    logDao.insertLog("Technician Panel", "ERROR",
                            "Failed to update threshold request #" + requestId,
                            "Failed");

                    response.sendRedirect("TechThresholdServlet?status=error");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("TechThresholdServlet?status=error");
        }
    }

    private void saveDashboardNotification(Integer userId, String message) {
        String sql = "INSERT INTO notification_log "
                + "(userId, messageContent, platform, status) "
                + "VALUES (?, ?, 'Threshold', 'SENT')";

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
}
