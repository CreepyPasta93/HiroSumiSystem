package com.hirosumi.controller;

import com.hirosumi.dao.DBConnection;
import com.hirosumi.model.User;
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
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        
        // FIXED: Using getUserId() to match your UserDAO naming
        int userId = (currentUser != null) ? currentUser.getUserId() : 0;

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            
            String sql = "INSERT INTO threshold_notifications (type, sensor_name, new_threshold, reason, status, userId) "
                       + "VALUES (?, ?, ?, ?, ?, ?)";
            
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, "Update"); 
            ps.setString(2, sensorName);
            ps.setFloat(3, Float.parseFloat(proposedValueStr));
            ps.setString(4, reason);
            ps.setString(5, "PENDING"); 
            ps.setInt(6, userId);
            
            ps.executeUpdate();
            response.sendRedirect("ThresholdServlet?status=success");
            
        } catch (Exception e) { // FIXED: Generic Exception to avoid ClassNotFound errors
            e.printStackTrace();
            response.sendRedirect("ThresholdServlet?status=error");
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}