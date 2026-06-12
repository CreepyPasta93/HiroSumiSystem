package com.hirosumi.dao;

import com.hirosumi.model.NotificationLog;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NotificationLogDAO {

    public List<NotificationLog> getLatestNotifications(int limit) {
        List<NotificationLog> list = new ArrayList<>();

        String sql = "SELECT logId, userId, messageContent, platform, sentTimestamp, status "
                   + "FROM notification_log "
                   + "ORDER BY sentTimestamp DESC "
                   + "LIMIT ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, limit);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    NotificationLog log = new NotificationLog();

                    log.setLogId(rs.getInt("logId"));

                    int userId = rs.getInt("userId");
                    if (rs.wasNull()) {
                        log.setUserId(null);
                    } else {
                        log.setUserId(userId);
                    }

                    log.setMessageContent(rs.getString("messageContent"));
                    log.setPlatform(rs.getString("platform"));
                    log.setSentTimestamp(rs.getTimestamp("sentTimestamp"));
                    log.setStatus(rs.getString("status"));

                    list.add(log);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }
}