package com.hirosumi.service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;

public class TelegramNotifier {

    // 🔴 REPLACE THESE WITH YOUR ACTUAL DATA
    private static final String BOT_TOKEN = "8141817246:AAEYb1uTDFc3QstWGqV410anx6VIVf5JS_Q";
    private static final String CHAT_ID = "695310284";

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
            System.out.println("❌ Failed to send message. Check Token/ChatID.");
        }
    }
}