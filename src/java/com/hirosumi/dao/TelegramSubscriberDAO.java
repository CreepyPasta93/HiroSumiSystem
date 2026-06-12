package com.hirosumi.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TelegramSubscriberDAO {

    public void saveSubscriber(String chatId, String username, String firstName) {
        String sql = "INSERT IGNORE INTO telegram_subscribers "
                   + "(chatId, username, firstName, status) "
                   + "VALUES (?, ?, ?, 'ACTIVE')";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, chatId);
            ps.setString(2, username);
            ps.setString(3, firstName);
            ps.executeUpdate();

            System.out.println("✅ Saved Telegram subscriber: " + chatId);

        } catch (Exception e) {
            e.printStackTrace();
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
        String sql = "UPDATE telegram_bot_state SET lastUpdateId = ? WHERE id = 1";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, lastUpdateId);
            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}