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

    // 1. GET: Show the Page with CURRENT Data
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        ConfigurationDAO dao = new ConfigurationDAO();
        Configuration config = dao.getCurrentConfig();
        
        // 🐾 FIX 1: Updated the constructor to include all 10 parameters!
        // (configId, heaterAct, heaterCut, lightDur, safetyAlert, fanAct, fanCut, humThresh, nightStart, nightEnd)
        if (config == null) {
            config = new Configuration(0, 24.0, 27.0, 10, 32.0, 30.0, 28.0, 75.0, 19, 7); 
        }
        
        request.setAttribute("config", config);
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
            for (String act : actions) msg.append("   • ").append(act).append("\n");
        }

        msg.append("\n❓ *Reason:* ").append((reason != null && !reason.isEmpty()) ? reason : "No reason provided").append("\n");

        if ("yes".equals(adjustThreshold)) {
            msg.append("\n⚙️ *Threshold Update:*\n");
            msg.append("   • Setting: ").append(thresholdType != null ? thresholdType : "-").append("\n");
            msg.append("   • New Value: ").append(newLimit).append("\n");
        }

        // C. Send Notification
        boolean success = TelegramNotifier.sendAlert(msg.toString());

        // D. Log to System History
        // 🐾 FIX 2: Changed to "Volunteer Panel" for accurate system logging
        SystemLogDAO logDao = new SystemLogDAO();
        if(success) {
            logDao.insertLog("Volunteer Panel", "CONFIG", "Change Request Submitted", "Success");
        } else {
            logDao.insertLog("Volunteer Panel", "ERROR", "Failed to submit request", "Failed");
        }

        // E. Reload Page with Success Flag
        response.sendRedirect("ThresholdServlet?status=success");
    }
}