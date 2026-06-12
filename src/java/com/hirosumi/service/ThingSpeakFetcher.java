package com.hirosumi.service;

import com.hirosumi.dao.DBConnection;
import com.hirosumi.dao.SystemLogDAO;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.Properties;
import javax.servlet.ServletContext;
import org.json.JSONObject;

public class ThingSpeakFetcher {

    private String getConfigValue(ServletContext context, String key) {
        Properties config = new Properties();

        try (InputStream input = context.getResourceAsStream("/WEB-INF/config.properties")) {

            if (input == null) {
                System.out.println("❌ ThingSpeakFetcher: /WEB-INF/config.properties not found.");
                return null;
            }

            config.load(input);
            return config.getProperty(key);

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public boolean fetchAndSaveData(ServletContext context, boolean sendTelegramAlert) {
        try {
            System.out.println("--- Starting ThingSpeak Sync ---");

            String channelId = getConfigValue(context, "THINGSPEAK_CHANNEL_ID");
            String readApiKey = getConfigValue(context, "THINGSPEAK_READ_API_KEY");

            if (channelId == null || channelId.trim().isEmpty()
                    || readApiKey == null || readApiKey.trim().isEmpty()) {
                System.out.println("❌ ThingSpeak channel ID or read API key is missing in config.properties.");
                return false;
            }

            String urlString = "https://api.thingspeak.com/channels/" + channelId.trim()
                    + "/feeds/last.json?api_key=" + readApiKey.trim();

            System.out.println("ThingSpeak URL: " + urlString.replace(readApiKey.trim(), "****"));

            URL url = new URL(urlString);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setConnectTimeout(15000);
            conn.setReadTimeout(30000);

            int responseCode = conn.getResponseCode();
            System.out.println("ThingSpeak Response Code: " + responseCode);

            BufferedReader reader;

            if (responseCode >= 200 && responseCode < 300) {
                reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            } else {
                reader = new BufferedReader(new InputStreamReader(conn.getErrorStream()));
            }

            StringBuilder content = new StringBuilder();
            String inputLine;

            while ((inputLine = reader.readLine()) != null) {
                content.append(inputLine);
            }

            reader.close();

            String json = content.toString();
            System.out.println("Received from ThingSpeak: " + json);

            if (responseCode < 200 || responseCode >= 300) {
                System.out.println("❌ ThingSpeak request failed.");
                return false;
            }

            JSONObject obj = new JSONObject(json);

            double temp = parseField(obj, "field1");
            double humidity = parseField(obj, "field2");
            double pressure = parseField(obj, "field3");
            int motion = (int) parseField(obj, "field4");

            /*
             * If your ThingSpeak channel has fan status in field5, this will use it.
             * If not, fanStatus will stay 0.
             */
            int fanStatus = (int) parseField(obj, "field5");

            if (temp != 0.0) {
                boolean saved = saveToDB(temp, humidity, pressure, motion, fanStatus);

                if (saved && sendTelegramAlert) {
                    checkAndSendAlerts(context, temp);
                } else if (saved) {
                    System.out.println("ThingSpeak data saved without Telegram alert.");
                }

                return saved;
            }

            System.out.println("Skipping DB save: temperature is 0.0 or field1 is empty.");
            return false;

        } catch (Exception e) {
            System.out.println("❌ Error syncing with ThingSpeak: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    private double parseField(JSONObject obj, String fieldName) {
        try {
            if (!obj.has(fieldName) || obj.isNull(fieldName)) {
                return 0.0;
            }

            String value = obj.optString(fieldName, "0");

            if (value == null || value.trim().isEmpty() || value.equalsIgnoreCase("null")) {
                return 0.0;
            }

            return Double.parseDouble(value.trim());

        } catch (Exception e) {
            System.out.println("Could not parse " + fieldName + ". Using 0.0");
            return 0.0;
        }
    }

    private void checkAndSendAlerts(ServletContext context, double currentTemp) {
        double MAX_TEMP = 30.0;
        double MIN_TEMP = 20.0;

        SystemLogDAO logDao = new SystemLogDAO();

        if (currentTemp > MAX_TEMP) {
            String msg = "🔥 HIGH TEMP ALERT: " + currentTemp + "°C! Please check the shelter.";
            TelegramNotifier.sendAlert(context, msg);

            logDao.insertLog("DHT22", "ALERT", "Temp exceeded limit (" + currentTemp + "°C)", "Critical");
            System.out.println("⚠️ SENT HIGH TEMP ALERT");

        } else if (currentTemp < MIN_TEMP) {
            String msg = "❄️ LOW TEMP ALERT: " + currentTemp + "°C! Heater needed.";
            TelegramNotifier.sendAlert(context, msg);

            logDao.insertLog("DHT22", "ALERT", "Temp dropped below limit (" + currentTemp + "°C)", "Warning");
            System.out.println("⚠️ SENT LOW TEMP ALERT");
        }
    }

    private boolean saveToDB(double temp, double humidity, double pressure, int motion, int fanStatus) {
        String sql = "INSERT INTO environmentaldata "
                + "(temperature, humidity, pressure, motionStatus, fan_status, sensorId, timestamp) "
                + "VALUES (?, ?, ?, ?, ?, 1, NOW())";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setDouble(1, temp);
            ps.setDouble(2, humidity);
            ps.setDouble(3, pressure);
            ps.setInt(4, motion);
            ps.setInt(5, fanStatus);

            int rows = ps.executeUpdate();

            if (rows > 0) {
                System.out.println("✅ SUCCESS: Saved to DB (T:" + temp + " H:" + humidity + " P:" + pressure + " M:" + motion + " Fan:" + fanStatus + ")");
                return true;
            }

            System.out.println("❌ ERROR: DB Insert failed. No rows affected.");
            return false;

        } catch (Exception e) {
            System.out.println("❌ DB ERROR: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}
