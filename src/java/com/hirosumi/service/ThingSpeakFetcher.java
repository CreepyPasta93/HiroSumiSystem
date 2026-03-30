package com.hirosumi.service;

import com.hirosumi.dao.DBConnection;
import com.hirosumi.dao.SystemLogDAO; // 👈 New Import
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.sql.Connection;
import java.sql.PreparedStatement;

public class ThingSpeakFetcher {

    // YOUR KEYS (Read Key)
    private static final String CHANNEL_ID = "3228274";
    private static final String READ_API_KEY = "UELEJEDGB6Q6AZJZ";

    public void fetchAndSaveData() {
        try {
            System.out.println("--- Starting ThingSpeak Sync ---");
            
            // 1. Construct URL
            String urlString = "https://api.thingspeak.com/channels/" + CHANNEL_ID
                    + "/feeds/last.json?api_key=" + READ_API_KEY;

            URL url = new URL(urlString);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");

            // 2. Read Response
            BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            String inputLine;
            StringBuilder content = new StringBuilder();
            while ((inputLine = in.readLine()) != null) {
                content.append(inputLine);
            }
            in.close();

            String json = content.toString();
            System.out.println("Received from Cloud: " + json); 

            // 3. Parse Data
            // Field 1=Temp, Field 2=Hum, Field 3=Press, Field 4=Motion
            double temp = parseValueSafe(json, "field1");
            double humidity = parseValueSafe(json, "field2");
            double pressure = parseValueSafe(json, "field3");
            double motion = parseValueSafe(json, "field4"); 

            // 4. Save to Database & Check Alerts
            if (temp != 0.0) {
                 saveToDB(temp, humidity, pressure, (int) motion);
                 
                 // 🚀 NEW: Trigger the Intelligence Logic!
                 checkAndSendAlerts(temp);
                 
            } else {
                System.out.println("Skipping DB save: Data invalid or empty.");
            }

        } catch (Exception e) {
            System.out.println("Error syncing with ThingSpeak: " + e.getMessage());
            e.printStackTrace();
        }
    }

    // --- 🚨 NEW ALERT LOGIC ---
    private void checkAndSendAlerts(double currentTemp) {
        // Define Limits
        double MAX_TEMP = 30.0;
        double MIN_TEMP = 20.0;
        
        SystemLogDAO logDao = new SystemLogDAO(); // Used to save the alert to history

        if (currentTemp > MAX_TEMP) {
            // 1. Send Telegram
            String msg = "🔥 HIGH TEMP ALERT: " + currentTemp + "°C! Please check the shelter.";
            TelegramNotifier.sendAlert(msg);
            
            // 2. Log to System Logs Page
            logDao.insertLog("DHT22", "ALERT", "Temp exceeded limit (" + currentTemp + "°C)", "Critical");
            System.out.println("⚠️ SENT HIGH TEMP ALERT");
            
        } else if (currentTemp < MIN_TEMP) {
            // 1. Send Telegram
            String msg = "❄️ LOW TEMP ALERT: " + currentTemp + "°C! Heater needed.";
            TelegramNotifier.sendAlert(msg);
            
            // 2. Log to System Logs Page
            logDao.insertLog("DHT22", "ALERT", "Temp dropped below limit (" + currentTemp + "°C)", "Warning");
            System.out.println("⚠️ SENT LOW TEMP ALERT");
        }
    }

    // --- EXISTING HELPERS ---

    // Safer parser that handles "null" or missing quotes
    private double parseValueSafe(String json, String key) {
        try {
            String searchKey = "\"" + key + "\":";
            int startIndex = json.indexOf(searchKey);
            if (startIndex == -1) return 0.0;
            
            startIndex += searchKey.length();
            
            // Skip quotes or spaces
            while (startIndex < json.length() && (json.charAt(startIndex) == '"' || json.charAt(startIndex) == ' ')) {
                startIndex++;
            }
            
            int endIndex = startIndex;
            // Stop at quote, comma, or closing brace
            while (endIndex < json.length() && json.charAt(endIndex) != '"' && json.charAt(endIndex) != ',' && json.charAt(endIndex) != '}') {
                endIndex++;
            }
            
            String value = json.substring(startIndex, endIndex);
            if (value.equals("null")) return 0.0;
            
            return Double.parseDouble(value);
        } catch (Exception e) {
            return 0.0;
        }
    }

    private void saveToDB(double temp, double humidity, double pressure, int motion) {
        String sql = "INSERT INTO environmentaldata "
                + "(temperature, humidity, pressure, motionStatus, sensorId, timestamp) "
                + "VALUES (?, ?, ?, ?, 1, NOW())";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setDouble(1, temp);
            ps.setDouble(2, humidity);
            ps.setDouble(3, pressure);
            ps.setInt(4, motion); 
            
            int rows = ps.executeUpdate();
            
            if(rows > 0) {
                System.out.println("✅ SUCCESS: Saved to DB (T:" + temp + " M:" + motion + ")");
            } else {
                System.out.println("❌ ERROR: DB Insert failed (No rows affected)");
            }

        } catch (Exception e) {
            System.out.println("❌ DB ERROR: " + e.getMessage());
            e.printStackTrace();
        }
    }
}