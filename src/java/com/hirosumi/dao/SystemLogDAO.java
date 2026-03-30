package com.hirosumi.dao;

import com.hirosumi.model.SystemLog;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SystemLogDAO {

    // Fetch all logs, newest first
    public List<SystemLog> getAllLogs() {
        List<SystemLog> logs = new ArrayList<>();

        // Query matches your Database Schema Table 3.8 [cite: 205]
        String sql = "SELECT * FROM SystemLog ORDER BY timestamp DESC";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                logs.add(new SystemLog(
                        rs.getInt("alertId"),
                        rs.getTimestamp("timestamp"),
                        rs.getString("source"),
                        rs.getString("category"),
                        rs.getString("description"),
                        rs.getString("status")
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return logs;
    }

    // ➕ ADD THIS METHOD TO ENABLE LOGGING
    public boolean insertLog(String source, String category, String description, String status) {
        String sql = "INSERT INTO systemlog (timestamp, source, category, description, status) VALUES (NOW(), ?, ?, ?, ?)";
        try (java.sql.Connection con = DBConnection.getConnection();
             java.sql.PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, source);
            ps.setString(2, category);
            ps.setString(3, description);
            ps.setString(4, status);
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}

