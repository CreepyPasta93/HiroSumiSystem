package com.hirosumi.service;

import com.hirosumi.dao.TelegramSubscriberDAO;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Properties;
import javax.servlet.ServletContext;
import org.json.JSONArray;
import org.json.JSONObject;

public class TelegramUpdateFetcher {

    private static String loadBotToken(ServletContext context) {
        try (InputStream input = context.getResourceAsStream("/WEB-INF/config.properties")) {
            Properties prop = new Properties();

            if (input == null) {
                System.err.println("❌ Unable to find /WEB-INF/config.properties");
                return null;
            }

            prop.load(input);
            return prop.getProperty("TELEGRAM_BOT_TOKEN");

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public static int fetchAndSaveSubscribers(ServletContext context) {
        int savedCount = 0;

        String botToken = loadBotToken(context);

        if (botToken == null || botToken.trim().isEmpty()) {
            System.err.println("❌ TELEGRAM_BOT_TOKEN is missing in config.properties");
            return 0;
        }

        try {
            TelegramSubscriberDAO dao = new TelegramSubscriberDAO();

            long lastUpdateId = dao.getLastUpdateId();
            long offset = lastUpdateId + 1;

            String urlString = "https://api.telegram.org/bot" + botToken
                    + "/getUpdates?offset=" + offset;

            URL url = new URL(urlString);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");

            BufferedReader reader = new BufferedReader(
                    new InputStreamReader(conn.getInputStream())
            );

            StringBuilder response = new StringBuilder();
            String line;

            while ((line = reader.readLine()) != null) {
                response.append(line);
            }

            reader.close();

            JSONObject json = new JSONObject(response.toString());
            JSONArray results = json.getJSONArray("result");

            long newestUpdateId = lastUpdateId;

            for (int i = 0; i < results.length(); i++) {
                JSONObject update = results.getJSONObject(i);

                long updateId = update.getLong("update_id");
                newestUpdateId = Math.max(newestUpdateId, updateId);

                if (!update.has("message")) {
                    continue;
                }

                JSONObject message = update.getJSONObject("message");

                String text = message.optString("text", "");

                // Only save users who press /start
                if (!text.equals("/start")) {
                    continue;
                }

                JSONObject chat = message.getJSONObject("chat");

                String chatId = String.valueOf(chat.getLong("id"));
                String username = chat.optString("username", "");
                String firstName = chat.optString("first_name", "");

                dao.saveSubscriber(chatId, username, firstName);
                savedCount++;
            }

            if (newestUpdateId > lastUpdateId) {
                dao.updateLastUpdateId(newestUpdateId);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return savedCount;
    }
}