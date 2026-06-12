package com.hirosumi.service;

import com.hirosumi.dao.DBConnection;
import com.hirosumi.dao.TelegramSubscriberDAO;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.List;
import java.util.Properties;
import javax.servlet.ServletContext;

public class TelegramNotifier {

    private static String loadBotToken(ServletContext context) {
        Properties prop = new Properties();

        try (InputStream input = context.getResourceAsStream("/WEB-INF/config.properties")) {

            if (input == null) {
                System.err.println("❌ Unable to find /WEB-INF/config.properties");
                return null;
            }

            prop.load(input);
            String token = prop.getProperty("TELEGRAM_BOT_TOKEN");

            if (token == null || token.trim().isEmpty()) {
                System.err.println("❌ TELEGRAM_BOT_TOKEN is missing in config.properties");
                return null;
            }

            return token.trim();

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public static boolean sendMessageToChat(ServletContext context, String chatId, String message) {
        String botToken = loadBotToken(context);

        if (botToken == null || botToken.trim().isEmpty()) {
            System.err.println("❌ Telegram bot token is null. Message not sent.");
            return false;
        }

        try {
            String encodedMessage = URLEncoder.encode(message, "UTF-8");

            String urlString = "https://api.telegram.org/bot" + botToken
                    + "/sendMessage?chat_id=" + chatId
                    + "&text=" + encodedMessage;

            URL url = new URL(urlString);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");

            int responseCode = conn.getResponseCode();
            System.out.println("Telegram Response for " + chatId + ": " + responseCode);

            BufferedReader reader;

            if (responseCode >= 200 && responseCode < 300) {
                reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            } else {
                reader = new BufferedReader(new InputStreamReader(conn.getErrorStream()));
            }

            StringBuilder response = new StringBuilder();
            String line;

            while ((line = reader.readLine()) != null) {
                response.append(line);
            }

            reader.close();

            System.out.println("Telegram API response: " + response.toString());

            return responseCode == 200;

        } catch (Exception e) {
            System.err.println("❌ Failed to send Telegram alert to " + chatId + ": " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public static boolean sendAlert(ServletContext context, String message) {
        TelegramSubscriberDAO dao = new TelegramSubscriberDAO();
        List<String> chatIds = dao.getActiveChatIds();

        if (chatIds.isEmpty()) {
            System.out.println("⚠ No Telegram subscribers found.");
            saveNotificationLog(null, message, "FAILED");
            return false;
        }

        boolean allSuccess = true;

        for (String chatId : chatIds) {
            boolean success = sendMessageToChat(context, chatId, message);

            if (!success) {
                allSuccess = false;
            }
        }

        if (allSuccess) {
            saveNotificationLog(null, message, "SENT");
        } else {
            saveNotificationLog(null, message, "PARTIAL_FAILED");
        }

        return allSuccess;
    }

    private static void saveNotificationLog(Integer userId, String message, String status) {
        String sql = "INSERT INTO notification_log (userId, messageContent, platform, status) "
                + "VALUES (?, ?, 'Telegram', ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            if (userId == null) {
                ps.setNull(1, java.sql.Types.INTEGER);
            } else {
                ps.setInt(1, userId);
            }

            ps.setString(2, message);
            ps.setString(3, status);

            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}