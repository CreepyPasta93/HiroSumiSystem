package com.hirosumi.controller;

import com.hirosumi.dao.ConfigurationDAO;
import com.hirosumi.dao.SystemLogDAO;
import com.hirosumi.model.Configuration;
import com.hirosumi.model.User;
import java.io.IOException;
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
        
        // Basic Role Check (Ensure they are logged in. You can add role specific checks here!)
        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        ConfigurationDAO dao = new ConfigurationDAO();
        Configuration config = dao.getCurrentConfig();
        
        // Fallback defaults if DB is empty
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
            // 1. Grab all the new inputs from the Technician's form
            double hAct = Double.parseDouble(request.getParameter("heaterAct"));
            double hCut = Double.parseDouble(request.getParameter("heaterCut"));
            double fAct = Double.parseDouble(request.getParameter("fanAct"));
            double fCut = Double.parseDouble(request.getParameter("fanCut"));
            double humThresh = Double.parseDouble(request.getParameter("humThresh"));
            int nStart = Integer.parseInt(request.getParameter("nightStart"));
            int nEnd = Integer.parseInt(request.getParameter("nightEnd"));
            
            // Keeping these two from your original setup, or providing defaults if hidden in UI
            int lDur = Integer.parseInt(request.getParameter("lightDur"));
            double sAlert = Double.parseDouble(request.getParameter("safetyAlert"));

            // 2. Update Database directly (CRUD - Update)
            ConfigurationDAO dao = new ConfigurationDAO();
            boolean success = dao.updateConfig(hAct, hCut, lDur, sAlert, fAct, fCut, humThresh, nStart, nEnd);

            // 3. Log the system change
            SystemLogDAO logDao = new SystemLogDAO();
            if(success) {
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