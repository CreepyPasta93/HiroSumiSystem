package com.hirosumi.controller;

import com.hirosumi.dao.DBConnection; 
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/HandleNotificationServlet")
public class HandleNotificationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        String action = request.getParameter("action");
        
        if (idParam == null || action == null) {
            response.sendRedirect("TechThresholdServlet");
            return;
        }

        int requestId = Integer.parseInt(idParam);
        Connection conn = null;
        
        try {
            conn = DBConnection.getConnection(); 
            conn.setAutoCommit(false); 

            if ("approve".equals(action)) {
                // 1. Get the details of the request
                String selectSQL = "SELECT sensor_name, new_threshold FROM threshold_notifications WHERE requestid = ?";
                PreparedStatement psGet = conn.prepareStatement(selectSQL);
                psGet.setInt(1, requestId);
                ResultSet rs = psGet.executeQuery();
                
                if (rs.next()) {
                    String sensorName = rs.getString("sensor_name");
                    float newValue = rs.getFloat("new_threshold");

                    // 2. Map the sensor_name from request to your actual column names
                    String targetColumn = "";
                    if (sensorName.equalsIgnoreCase("Heater Trigger")) {
                        targetColumn = "heaterActivationThreshold";
                    } else if (sensorName.equalsIgnoreCase("Heater Cutoff")) {
                        targetColumn = "heaterCutoffThreshold";
                    } else if (sensorName.equalsIgnoreCase("Fan Trigger")) {
                        targetColumn = "fanActivationThreshold";
                    } else if (sensorName.equalsIgnoreCase("Humidity Limit")) {
                        targetColumn = "humidityThreshold";
                    }

                    if (!targetColumn.equals("")) {
                        // 3. Update the notification status
                        PreparedStatement psStatus = conn.prepareStatement(
                            "UPDATE threshold_notifications SET status = 'APPROVED' WHERE requestid = ?");
                        psStatus.setInt(1, requestId);
                        psStatus.executeUpdate();

                        // 4. Update the specific column in the configuration table
                        // We assume configId = 1 since there is usually only one configuration row
                        String sqlConfig = "UPDATE configuration SET " + targetColumn + " = ? WHERE configId = 1";
                        PreparedStatement psConfig = conn.prepareStatement(sqlConfig);
                        psConfig.setFloat(1, newValue);
                        psConfig.executeUpdate();
                    }
                }
            } else if ("deny".equals(action)) {
                PreparedStatement psDeny = conn.prepareStatement(
                    "UPDATE threshold_notifications SET status = 'DENIED' WHERE requestid = ?");
                psDeny.setInt(1, requestId);
                psDeny.executeUpdate();
            }

            conn.commit();
            response.sendRedirect("TechThresholdServlet?status=updated");
            
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException se) { se.printStackTrace(); }
            }
            e.printStackTrace();
            response.sendRedirect("TechThresholdServlet?status=error");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
}