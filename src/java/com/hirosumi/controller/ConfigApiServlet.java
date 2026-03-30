package com.hirosumi.controller;

import com.hirosumi.dao.ConfigurationDAO;
import com.hirosumi.model.Configuration;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "ConfigApiServlet", urlPatterns = {"/api/config"})
public class ConfigApiServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ==========================================
        // 📥 1. CATCH DATA FROM PICO (The "Receiver" logic)
        // ==========================================
        String tempStr = request.getParameter("temp");
        if (tempStr != null) { // Only try to save if the Pico sent data
            try {
                double temp = Double.parseDouble(tempStr);
                double hum = Double.parseDouble(request.getParameter("hum"));
                double pres = Double.parseDouble(request.getParameter("pres"));
                int motion = Integer.parseInt(request.getParameter("motion"));
                int fanStatus = Integer.parseInt(request.getParameter("fanStatus"));

                // Call your DAO to save this to MySQL
                com.hirosumi.dao.AnalyticsDAO sensorDao = new com.hirosumi.dao.AnalyticsDAO();
                // 🐾 IMPORTANT: Make sure your addReading method in AnalyticsDAO 
                // is updated to accept these 5 parameters!
                sensorDao.addReading(temp, hum, pres, motion, fanStatus);
                
                System.out.println("✅ Data Saved from Pico: Fan Status = " + fanStatus);
            } catch (Exception e) {
                System.out.println("⚠️ Failed to parse Pico data: " + e.getMessage());
            }
        }

        // ==========================================
        // 📤 2. SEND RULES TO PICO (The "Sender" logic - Existing)
        // ==========================================
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try (PrintWriter out = response.getWriter()) {
            ConfigurationDAO configDao = new ConfigurationDAO();
            Configuration config = configDao.getCurrentConfig();

            if (config == null) {
                config = new Configuration(0, 24.0, 27.0, 10, 32.0, 30.0, 28.0, 75.0, 19, 7);
            }

            String jsonResponse = String.format(
                "{" +
                "\"heaterActivation\": %.2f, " +
                "\"heaterCutoff\": %.2f, " +
                "\"fanActivation\": %.2f, " +
                "\"fanCutoff\": %.2f, " +
                "\"humidityThreshold\": %.2f, " +
                "\"nightModeStart\": %d, " +
                "\"nightModeEnd\": %d" +
                "}",
                config.getHeaterActivation(),
                config.getHeaterCutoff(),
                config.getFanActivationThreshold(),
                config.getFanCutoffThreshold(),
                config.getHumidityThreshold(),
                config.getNightModeStart(),
                config.getNightModeEnd()
            );

            out.print(jsonResponse);
            out.flush();
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().print("{\"error\": \"Failed to fetch configuration\"}");
        }
    }
}