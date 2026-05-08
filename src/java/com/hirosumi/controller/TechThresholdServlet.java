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
            String sql = "SELECT * FROM threshold_notifications WHERE status = 'PENDING'";
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Notification n = new Notification();
                n.setRequestId(rs.getInt("requestId"));
                n.setSensorName(rs.getString("sensor_name"));
                n.setNewThreshold(rs.getFloat("new_threshold"));
                n.setReason(rs.getString("reason"));
                n.setUserId(rs.getInt("userId"));
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
}