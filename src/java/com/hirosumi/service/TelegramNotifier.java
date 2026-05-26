package com.hirosumi.service;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.Properties;

public class TelegramNotifier {

    private static String BOT_TOKEN;
    private static String CHAT_ID;

    // This block automatically loads your secrets from config.properties
    static {
        try (InputStream input = TelegramNotifier.class.getClassLoader().getResourceAsStream("config.properties")) {
            Properties prop = new Properties();
            if (input == null) {
                System.err.println("❌ Unable to find config.properties");
            } else {
                prop.load(input);
                BOT_TOKEN = prop.getProperty("TELEGRAM_BOT_TOKEN");
                CHAT_ID = prop.getProperty("TELEGRAM_CHAT_ID");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static boolean sendAlert(String message) {
        try {
            // 1. Encode message to handle spaces and special characters safely
            String encodedMessage = URLEncoder.encode(message, "UTF-8");

            // 2. Construct the URL
            String urlString = "https://api.telegram.org/bot" + BOT_TOKEN + 
                               "/sendMessage?chat_id=" + CHAT_ID + 
                               "&text=" + encodedMessage;

            // 3. Open Connection
            URL url = new URL(urlString);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");

            // 4. Check Response Code (200 = OK)
            int responseCode = conn.getResponseCode();
            System.out.println("Telegram Response: " + responseCode); // Debugging

            // Clean up
            BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            in.close();

            return responseCode == 200;

        } catch (Exception e) {
            System.err.println("❌ Failed to send Telegram alert: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // --- MAIN METHOD FOR TESTING (Run this file directly to test) ---
    public static void main(String[] args) {
        System.out.println("Attempting to send test message...");
        
        boolean success = sendAlert("🚨 HiroSumi System Alert: Testing notification connection!");
        
        if (success) {
            System.out.println("✅ Message sent successfully!");
        } else {
            System.out.println("❌ Failed to send message. Check Token/ChatID in config.properties.");
        }
    }
}