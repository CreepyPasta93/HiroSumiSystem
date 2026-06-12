package com.hirosumi.dao;

import com.hirosumi.model.SensorData;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Collections;

/**
 * Data Access Object for HiroSumi IoT System. Handles environmental data
 * retrieval, analytics, and system logs.
 */
public class AnalyticsDAO {

    // ==========================================
    // 📊 SECTION 1: ANALYTICS WIDGETS (KPIs)
    // ==========================================
    public double getAverageTemp() {
        double avg = 0.0;
        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT AVG(temperature) FROM environmentaldata WHERE timestamp >= NOW() - INTERVAL 7 DAY";
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                avg = rs.getDouble(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return Math.round(avg * 10.0) / 10.0;
    }

    public double getAverageHumidity() {
        double avg = 0.0;
        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT AVG(humidity) FROM environmentaldata WHERE timestamp >= NOW() - INTERVAL 7 DAY";
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                avg = rs.getDouble(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return Math.round(avg);
    }

    public String getHeaterRuntime() {
        int minutes = 0;
        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT COUNT(*) FROM systemlog WHERE description LIKE '%Heater%ON%' AND timestamp >= NOW() - INTERVAL 7 DAY";
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                minutes = rs.getInt(1) * 20; // 20 min interval estimate
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return (minutes / 60) + "h " + (minutes % 60) + "m";
    }

    public int[] getWeeklyAlerts() {
        int[] dailyAlerts = new int[7];
        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT DAYOFWEEK(timestamp) as day, COUNT(*) as count FROM systemlog WHERE category = 'ALERT' AND timestamp >= NOW() - INTERVAL 7 DAY GROUP BY DAYOFWEEK(timestamp)";
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                int dayIndex = rs.getInt("day") - 1;
                if (dayIndex >= 0 && dayIndex < 7) {
                    dailyAlerts[dayIndex] = rs.getInt("count");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return dailyAlerts;
    }

    // ==========================================
    // 📈 SECTION 2: DASHBOARD METHODS (Live Feed & Graphs)
    // ==========================================
    public SensorData getLatestReading() {
        SensorData data = null;
        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT * FROM environmentaldata ORDER BY timestamp DESC LIMIT 1";
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                data = new SensorData(
                        rs.getInt("dataId"),
                        rs.getDouble("temperature"),
                        rs.getDouble("humidity"),
                        rs.getDouble("pressure"),
                        rs.getInt("motionStatus"),
                        rs.getInt("fan_status"),
                        rs.getTimestamp("timestamp")
                );
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return data;
    }

    public List<SensorData> getRecentReadings(int limit) {
        List<SensorData> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT * FROM environmentaldata ORDER BY timestamp DESC LIMIT ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, limit);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new SensorData(
                        rs.getInt("dataId"),
                        rs.getDouble("temperature"),
                        rs.getDouble("humidity"),
                        rs.getDouble("pressure"),
                        rs.getInt("motionStatus"),
                        rs.getInt("fan_status"),
                        rs.getTimestamp("timestamp")
                ));
            }
            Collections.reverse(list);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<SensorData> getReadingsByDateRange(String startStr, String endStr) {
        List<SensorData> list = new ArrayList<>();
        String sqlStart = startStr.replace("T", " ") + ":00";
        String sqlEnd = endStr.replace("T", " ") + ":00";
        String sql = "SELECT * FROM environmentaldata WHERE timestamp BETWEEN ? AND ? ORDER BY timestamp ASC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, sqlStart);
            ps.setString(2, sqlEnd);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new SensorData(
                            rs.getInt("dataId"),
                            rs.getDouble("temperature"),
                            rs.getDouble("humidity"),
                            rs.getDouble("pressure"),
                            rs.getInt("motionStatus"),
                            rs.getInt("fan_status"),
                            rs.getTimestamp("timestamp")
                    ));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ==========================================
    // 📝 SECTION 3: CRUD METHODS (For Analytics Page)
    // ==========================================
    public List<SensorData> getAllReadings() {
        List<SensorData> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT * FROM environmentaldata ORDER BY timestamp DESC LIMIT 50";
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new SensorData(
                        rs.getInt("dataId"),
                        rs.getDouble("temperature"),
                        rs.getDouble("humidity"),
                        rs.getDouble("pressure"),
                        rs.getInt("motionStatus"),
                        rs.getInt("fan_status"),
                        rs.getTimestamp("timestamp")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * CREATE: Add a new sensor entry. 🛠️ FIX: Includes sensorId=1 to avoid
     * NULL errors in phpMyAdmin.
     */
    public boolean addReading(double temp, double hum, double pres, int motion, int fanStatus) {
        try (Connection con = DBConnection.getConnection()) {
            String sql = "INSERT INTO environmentaldata (temperature, humidity, pressure, motionStatus, fan_status, sensorId, timestamp) VALUES (?, ?, ?, ?, ?, ?, NOW())";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setDouble(1, temp);
            ps.setDouble(2, hum);
            ps.setDouble(3, pres);
            ps.setInt(4, motion);
            ps.setInt(5, fanStatus);
            ps.setInt(6, 1); // Hardcoded sensor ID for HiroSumi unit
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteReading(int id) {
        try (Connection con = DBConnection.getConnection()) {
            String sql = "DELETE FROM environmentaldata WHERE dataId = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteOldestReadings(int limit) {
        try (Connection con = DBConnection.getConnection()) {
            String sql = "DELETE FROM environmentaldata ORDER BY timestamp ASC LIMIT ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, limit);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public int getTotalReadingsLast7Days() {
        int count = 0;

        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT COUNT(*) FROM environmentaldata "
                    + "WHERE timestamp >= NOW() - INTERVAL 7 DAY";

            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                count = rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return count;
    }

    public int getHotReadingsLast7Days() {
        int count = 0;

        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT COUNT(*) FROM environmentaldata "
                    + "WHERE temperature >= 30 "
                    + "AND timestamp >= NOW() - INTERVAL 7 DAY";

            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                count = rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return count;
    }

    public int getHotDaysLast7Days() {
        int days = 0;

        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT COUNT(DISTINCT DATE(timestamp)) FROM environmentaldata "
                    + "WHERE temperature >= 30 "
                    + "AND timestamp >= NOW() - INTERVAL 7 DAY";

            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                days = rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return days;
    }

    public String getPeakHeatPeriod() {
        String period = "Not enough data yet";

        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT "
                    + "CASE "
                    + "WHEN HOUR(timestamp) BETWEEN 6 AND 11 THEN 'Morning' "
                    + "WHEN HOUR(timestamp) BETWEEN 12 AND 16 THEN 'Afternoon' "
                    + "WHEN HOUR(timestamp) BETWEEN 17 AND 20 THEN 'Evening' "
                    + "ELSE 'Night' "
                    + "END AS heatPeriod, "
                    + "AVG(temperature) AS avgTemp "
                    + "FROM environmentaldata "
                    + "WHERE timestamp >= NOW() - INTERVAL 7 DAY "
                    + "GROUP BY heatPeriod "
                    + "ORDER BY avgTemp DESC "
                    + "LIMIT 1";

            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                period = rs.getString("heatPeriod");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return period;
    }

    public String getFanRuntimeLast7Days() {
        int minutes = 0;

        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT COUNT(*) FROM environmentaldata "
                    + "WHERE fan_status = 1 "
                    + "AND timestamp >= NOW() - INTERVAL 7 DAY";

            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                minutes = rs.getInt(1) * 20;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return (minutes / 60) + "h " + (minutes % 60) + "m";
    }

    public int getFanOnButStillHotCount() {
        int count = 0;

        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT COUNT(*) FROM environmentaldata "
                    + "WHERE fan_status = 1 "
                    + "AND temperature >= 30 "
                    + "AND timestamp >= NOW() - INTERVAL 7 DAY";

            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                count = rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return count;
    }

    public int[] getDailyHotReadingsLast7Days() {
        int[] hotReadings = new int[7];

        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT DATE(timestamp) AS readingDate, COUNT(*) AS hotCount "
                    + "FROM environmentaldata "
                    + "WHERE temperature >= 30 "
                    + "AND timestamp >= CURDATE() - INTERVAL 6 DAY "
                    + "GROUP BY DATE(timestamp) "
                    + "ORDER BY readingDate ASC";

            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            java.time.LocalDate today = java.time.LocalDate.now();
            java.time.LocalDate startDate = today.minusDays(6);

            while (rs.next()) {
                java.sql.Date sqlDate = rs.getDate("readingDate");
                java.time.LocalDate readingDate = sqlDate.toLocalDate();

                int index = (int) java.time.temporal.ChronoUnit.DAYS.between(startDate, readingDate);

                if (index >= 0 && index < 7) {
                    hotReadings[index] = rs.getInt("hotCount");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return hotReadings;
    }
}
