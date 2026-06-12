package com.hirosumi.controller;

import com.hirosumi.dao.ConfigurationDAO;
import com.hirosumi.dao.SystemLogDAO;
import com.hirosumi.model.Configuration;
import com.hirosumi.service.TelegramNotifier;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "ThresholdServlet", urlPatterns = {"/ThresholdServlet"})
public class ThresholdServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Get current user from session
        javax.servlet.http.HttpSession session = request.getSession();
        com.hirosumi.model.User currentUser = (com.hirosumi.model.User) session.getAttribute("currentUser");

        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 2. Fetch Current Configuration (For the top cards)
        com.hirosumi.dao.ConfigurationDAO configDao = new com.hirosumi.dao.ConfigurationDAO();
        com.hirosumi.model.Configuration config = configDao.getCurrentConfig();

        if (config == null) {
            config = new com.hirosumi.model.Configuration(0, 24.0, 27.0, 10, 32.0, 30.0, 28.0, 75.0, 19, 7);
        }

        // 3. 🔍 FETCH USER HISTORY (The Missing Part!)
        java.util.List<com.hirosumi.model.Notification> userRequests = new java.util.ArrayList<>();
        try (java.sql.Connection conn = com.hirosumi.dao.DBConnection.getConnection()) {
            // Fetch requests for this specific user, newest first
            String sql = "SELECT * FROM threshold_notifications WHERE userId = ? ORDER BY timestamp DESC";
            java.sql.PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, currentUser.getUserId());
            java.sql.ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                com.hirosumi.model.Notification n = new com.hirosumi.model.Notification();
                n.setRequestId(rs.getInt("requestId"));
                n.setSensorName(rs.getString("sensor_name"));
                n.setNewThreshold(rs.getFloat("new_threshold"));
                n.setReason(rs.getString("reason"));
                n.setStatus(rs.getString("status")); // APPROVED, PENDING, DENIED
                userRequests.add(n);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // 4. Send everything to the JSP
        request.setAttribute("config", config);
        request.setAttribute("userRequests", userRequests); // 🍓 Important!
        request.getRequestDispatcher("threshold.jsp").forward(request, response);
    }

    // 2. POST: Handle the "Request Change" Form
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // A. Get Form Data
        String[] actions = request.getParameterValues("actions");
        String reason = request.getParameter("reason");
        String adjustThreshold = request.getParameter("adjustThreshold");
        String thresholdType = request.getParameter("thresholdType");
        String newLimit = request.getParameter("newLimit");

        // B. Build Telegram Message
        StringBuilder msg = new StringBuilder();
        msg.append("📝 *Configuration Change Request*\n");
        msg.append("────────────────\n");
        msg.append("👤 *Requester:* Volunteer (System)\n\n");

        if (actions != null && actions.length > 0) {
            msg.append("⚡ *Requested Actions:*\n");
            for (String act : actions) {
                msg.append("   • ").append(act).append("\n");
            }
        }

        msg.append("\n❓ *Reason:* ").append((reason != null && !reason.isEmpty()) ? reason : "No reason provided").append("\n");

        if ("yes".equals(adjustThreshold)) {
            msg.append("\n⚙️ *Threshold Update:*\n");
            msg.append("   • Setting: ").append(thresholdType != null ? thresholdType : "-").append("\n");
            msg.append("   • New Value: ").append(newLimit).append("\n");
        }

        // C. Send Notification
        boolean success = TelegramNotifier.sendAlert(getServletContext(), msg.toString());
        
        // D. Log to System History
        // 🐾 FIX 2: Changed to "Volunteer Panel" for accurate system logging
        SystemLogDAO logDao = new SystemLogDAO();
        if (success) {
            logDao.insertLog("Volunteer Panel", "CONFIG", "Change Request Submitted", "Success");
        } else {
            logDao.insertLog("Volunteer Panel", "ERROR", "Failed to submit request", "Failed");
        }

        // E. Reload Page with Success Flag
        response.sendRedirect("ThresholdServlet?status=success");
    }
}
