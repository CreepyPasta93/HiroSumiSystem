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
            String token = prop.getProperty("TELEGRAM_BOT_TOKEN");

            if (token == null || token.trim().isEmpty()) {
                System.err.println("❌ TELEGRAM_BOT_TOKEN is empty or missing.");
                return null;
            }

            return token.trim();

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public static int fetchAndSaveSubscribers(ServletContext context) {
        int savedCount = 0;

        String botToken = loadBotToken(context);

        System.out.println("DEBUG Telegram token loaded? " + (botToken != null && !botToken.trim().isEmpty()));

        if (botToken == null || botToken.trim().isEmpty()) {
            System.err.println("❌ TELEGRAM_BOT_TOKEN is missing in config.properties");
            return 0;
        }

        try {
            TelegramSubscriberDAO dao = new TelegramSubscriberDAO();

            long lastUpdateId = dao.getLastUpdateId();
            long offset = lastUpdateId + 1;

            System.out.println("DEBUG lastUpdateId = " + lastUpdateId);
            System.out.println("DEBUG offset = " + offset);

            String urlString = "https://api.telegram.org/bot" + botToken
                    + "/getUpdates?offset=" + offset;

            URL url = new URL(urlString);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setConnectTimeout(15000);
            conn.setReadTimeout(30000);

            int responseCode = conn.getResponseCode();
            System.out.println("DEBUG Telegram getUpdates response code = " + responseCode);

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

            System.out.println("DEBUG Telegram getUpdates response = " + response.toString());

            if (responseCode < 200 || responseCode >= 300) {
                System.err.println("❌ Telegram getUpdates failed.");
                return 0;
            }

            JSONObject json = new JSONObject(response.toString());

            if (!json.optBoolean("ok", false)) {
                System.err.println("❌ Telegram response is not OK.");
                return 0;
            }

            JSONArray results = json.getJSONArray("result");

            if (results.length() == 0) {
                System.out.println("⚠ No new Telegram updates found. Ask the user to send /start again, then run TelegramConnectServlet.");
                return 0;
            }

            long newestUpdateId = lastUpdateId;

            for (int i = 0; i < results.length(); i++) {
                JSONObject update = results.getJSONObject(i);

                long updateId = update.getLong("update_id");
                newestUpdateId = Math.max(newestUpdateId, updateId);

                System.out.println("DEBUG processing updateId = " + updateId);

                if (!update.has("message")) {
                    System.out.println("DEBUG skipped update: no message object.");
                    continue;
                }

                JSONObject message = update.getJSONObject("message");

                String text = message.optString("text", "");
                System.out.println("DEBUG received Telegram text = [" + text + "]");

                if (text == null || !text.trim().startsWith("/start")) {
                    System.out.println("DEBUG skipped message because it is not /start.");
                    continue;
                }

                if (!message.has("chat")) {
                    System.out.println("DEBUG skipped message: no chat object.");
                    continue;
                }

                JSONObject chat = message.getJSONObject("chat");

                String chatId = String.valueOf(chat.getLong("id"));
                String username = chat.optString("username", "");
                String firstName = chat.optString("first_name", "");

                boolean saved = dao.saveSubscriber(chatId, username, firstName);

                if (saved) {
                    savedCount++;
                    System.out.println("✅ DEBUG saved subscriber chatId = " + chatId
                            + ", username = " + username
                            + ", firstName = " + firstName);
                } else {
                    System.out.println("⚠ DEBUG subscriber was not saved: " + chatId);
                }
            }

            if (newestUpdateId > lastUpdateId) {
                dao.updateLastUpdateId(newestUpdateId);
                System.out.println("✅ DEBUG newestUpdateId saved = " + newestUpdateId);
            } else {
                System.out.println("DEBUG no newer updateId to save.");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        System.out.println("DEBUG total saved subscribers = " + savedCount);
        return savedCount;
    }
}