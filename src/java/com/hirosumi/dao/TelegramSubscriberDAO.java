package com.hirosumi.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TelegramSubscriberDAO {

    public boolean saveSubscriber(String chatId, String username, String firstName) {
        String sql = "INSERT INTO telegram_subscribers "
                + "(chatId, username, firstName, status) "
                + "VALUES (?, ?, ?, 'ACTIVE') "
                + "ON DUPLICATE KEY UPDATE "
                + "username = VALUES(username), "
                + "firstName = VALUES(firstName), "
                + "status = 'ACTIVE'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, chatId);
            ps.setString(2, username);
            ps.setString(3, firstName);

            int rows = ps.executeUpdate();

            System.out.println("✅ Telegram subscriber saved/updated: " + chatId + ", rows=" + rows);

            return rows > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<String> getActiveChatIds() {
        List<String> chatIds = new ArrayList<>();

        String sql = "SELECT chatId FROM telegram_subscribers WHERE status = 'ACTIVE'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                chatIds.add(rs.getString("chatId"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return chatIds;
    }

    public long getLastUpdateId() {
        String sql = "SELECT lastUpdateId FROM telegram_bot_state WHERE id = 1";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getLong("lastUpdateId");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public void updateLastUpdateId(long lastUpdateId) {
        String sql = "INSERT INTO telegram_bot_state (id, lastUpdateId) "
                + "VALUES (1, ?) "
                + "ON DUPLICATE KEY UPDATE lastUpdateId = VALUES(lastUpdateId)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, lastUpdateId);
            ps.executeUpdate();

            System.out.println("✅ Updated Telegram lastUpdateId: " + lastUpdateId);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}