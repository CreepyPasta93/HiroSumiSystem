package com.hirosumi.controller;

import com.hirosumi.dao.SystemLogDAO;
import com.hirosumi.model.SystemLog;
import com.hirosumi.service.TelegramNotifier;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "SystemLogServlet", urlPatterns = {"/SystemLogServlet"})
public class SystemLogServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        SystemLogDAO dao = new SystemLogDAO();

        // 🚀 1. HANDLE TEST BUTTON
        if ("testTelegram".equals(action)) {
            boolean success = TelegramNotifier.sendAlert(
                    getServletContext(),
                    "🚨 HiroSumi System Check: The notification module is active and connected!"
            );

            if (success) {
                dao.insertLog("System Logs", "TEST", "Manual Connectivity Check", "Success");
            } else {
                dao.insertLog("System Logs", "ERROR", "Manual Connectivity Check Failed", "Failed");
            }

            response.setContentType("text/plain");
            response.getWriter().write(success ? "success" : "failed");
            return;
        } // 📂 2. HANDLE EXPORT CSV (New!)
        else if ("exportCSV".equals(action)) {
            List<SystemLog> logs = dao.getAllLogs();

            // Set Headers for File Download
            response.setContentType("text/csv");
            response.setHeader("Content-Disposition", "attachment; filename=\"hirosumi_logs.csv\"");

            try (PrintWriter writer = response.getWriter()) {
                // CSV Header Row
                writer.println("ID,Timestamp,Source,Category,Description,Status");

                // Write Data Rows
                for (SystemLog log : logs) {
                    // Escape commas in description to prevent breaking the CSV format
                    String safeDesc = log.getDescription().replace(",", " ");

                    writer.println(String.format("%d,%s,%s,%s,%s,%s",
                            log.getAlertId(),
                            log.getFormattedDate(),
                            log.getSource(),
                            log.getCategory(),
                            safeDesc,
                            log.getStatus()
                    ));
                }
            }
            return; // Stop here so we don't load the JSP
        }

        // --- Standard Page Load ---
        List<SystemLog> logs = dao.getAllLogs();
        request.setAttribute("logs", logs);
        request.getRequestDispatcher("systemlogs.jsp").forward(request, response);
    }
}
