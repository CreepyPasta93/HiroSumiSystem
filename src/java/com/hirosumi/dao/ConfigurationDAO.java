package com.hirosumi.dao;

import com.hirosumi.model.Configuration;
import java.sql.*;

public class ConfigurationDAO {

    public Configuration getCurrentConfig() {
        Configuration config = null;
        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT * FROM configuration ORDER BY configId DESC LIMIT 1";
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                config = new Configuration(
                        rs.getInt("configId"),
                        rs.getDouble("heaterActivationThreshold"),
                        rs.getDouble("heaterCutoffThreshold"),
                        rs.getInt("lightActiveDuration"),
                        rs.getDouble("safetyAlertTemp"),
                        rs.getDouble("fanActivationThreshold"), // NEW
                        rs.getDouble("fanCutoffThreshold"), // NEW
                        rs.getDouble("humidityThreshold"), // NEW
                        rs.getInt("nightModeStart"), // NEW
                        rs.getInt("nightModeEnd") // NEW
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return config;
    }

    // 2. Update Settings
    public boolean updateConfig(double hAct, double hCut, int lDur, double sAlert,
            double fAct, double fCut, double humThresh,
            int nStart, int nEnd) {
        boolean success = false;
        try (Connection con = DBConnection.getConnection()) {

            // 🐾 FIX: Removed the subquery and replaced it with ORDER BY and LIMIT 1
            String sql = "UPDATE configuration SET "
                    + "heaterActivationThreshold=?, heaterCutoffThreshold=?, "
                    + "lightActiveDuration=?, safetyAlertTemp=?, "
                    + "fanActivationThreshold=?, fanCutoffThreshold=?, "
                    + "humidityThreshold=?, nightModeStart=?, nightModeEnd=? "
                    + "ORDER BY configId DESC LIMIT 1";

            PreparedStatement ps = con.prepareStatement(sql);
            ps.setDouble(1, hAct);
            ps.setDouble(2, hCut);
            ps.setInt(3, lDur);
            ps.setDouble(4, sAlert);
            ps.setDouble(5, fAct);
            ps.setDouble(6, fCut);
            ps.setDouble(7, humThresh);
            ps.setInt(8, nStart);
            ps.setInt(9, nEnd);

            int rows = ps.executeUpdate();

            // If rows > 0, it means the database was successfully changed!
            if (rows > 0) {
                success = true;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return success;
    }
}
