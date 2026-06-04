package com.hirosumi.service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

public class GrokService {

    private static final String XAI_API_URL = "https://api.x.ai/v1/chat/completions";

    // Safer to use a lightweight/available model for short summaries.
    // You can change this later based on what your xAI Console allows.
    private static final String MODEL = "grok-4.3";

    public String generateAnalyticsInsight(double avgTemp, double avgHum, String heaterRuntime, int totalRecords) {
        String apiKey = System.getenv("XAI_API_KEY");
        System.out.println("XAI key loaded? " + (apiKey != null && !apiKey.trim().isEmpty()));

        // Fallback means your page still works even if API key/Wi-Fi fails.
        if (apiKey == null || apiKey.trim().isEmpty()) {
            return getFallbackInsight(avgTemp, avgHum, heaterRuntime, totalRecords);
        }

        try {
            String prompt = buildPrompt(avgTemp, avgHum, heaterRuntime, totalRecords);
            String requestBody = buildRequestBody(prompt);

            URL url = new URL(XAI_API_URL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();

            conn.setRequestMethod("POST");
            conn.setRequestProperty("Authorization", "Bearer " + apiKey);
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setDoOutput(true);
            conn.setConnectTimeout(15000);
            conn.setReadTimeout(30000);

            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = requestBody.getBytes(StandardCharsets.UTF_8);
                os.write(input, 0, input.length);
            }

            int statusCode = conn.getResponseCode();

            BufferedReader reader = new BufferedReader(
                    new InputStreamReader(
                            statusCode >= 200 && statusCode < 300
                                    ? conn.getInputStream()
                                    : conn.getErrorStream(),
                            StandardCharsets.UTF_8
                    )
            );

            StringBuilder response = new StringBuilder();
            String line;

            while ((line = reader.readLine()) != null) {
                response.append(line);
            }

            reader.close();

            if (statusCode < 200 || statusCode >= 300) {
                System.out.println("Grok API error: " + response.toString());
                return getFallbackInsight(avgTemp, avgHum, heaterRuntime, totalRecords);
            }

            String content = extractContent(response.toString());

            if (content == null || content.trim().isEmpty()) {
                return getFallbackInsight(avgTemp, avgHum, heaterRuntime, totalRecords);
            }

            return content;

        } catch (Exception e) {
            e.printStackTrace();
            return getFallbackInsight(avgTemp, avgHum, heaterRuntime, totalRecords);
        }
    }

    private String buildPrompt(double avgTemp, double avgHum, String heaterRuntime, int totalRecords) {
        return "You are Grok writing an AI Summary Insight for HiroSumi Smart Stray Cat Shelter. "
                + "Write in a warm, cute, useful tone for a caretaker dashboard. "
                + "Use simple wording. Mention cat comfort, temperature, humidity, and system performance. "
                + "Maximum 3 sentences. No markdown. "
                + "Data: average temperature over 7 days = " + avgTemp + "°C, "
                + "average humidity over 7 days = " + avgHum + "%, "
                + "estimated heater runtime over 7 days = " + heaterRuntime + ", "
                + "sensor records shown = " + totalRecords + ".";
    }

    private String buildRequestBody(String prompt) {
        return "{"
                + "\"model\":\"" + MODEL + "\","
                + "\"messages\":["
                + "{"
                + "\"role\":\"system\","
                + "\"content\":\"You create concise AI analytics summaries for an IoT cat shelter dashboard.\""
                + "},"
                + "{"
                + "\"role\":\"user\","
                + "\"content\":\"" + escapeJson(prompt) + "\""
                + "}"
                + "],"
                + "\"temperature\":0.7,"
                + "\"max_tokens\":180"
                + "}";
    }

    private String extractContent(String json) {
        String marker = "\"content\":\"";
        int start = json.indexOf(marker);

        if (start == -1) {
            return null;
        }

        start += marker.length();

        StringBuilder content = new StringBuilder();
        boolean escaping = false;

        for (int i = start; i < json.length(); i++) {
            char c = json.charAt(i);

            if (escaping) {
                switch (c) {
                    case 'n':
                        content.append('\n');
                        break;
                    case 't':
                        content.append('\t');
                        break;
                    case '"':
                        content.append('"');
                        break;
                    case '\\':
                        content.append('\\');
                        break;
                    case '/':
                        content.append('/');
                        break;
                    default:
                        content.append(c);
                        break;
                }
                escaping = false;
            } else if (c == '\\') {
                escaping = true;
            } else if (c == '"') {
                break;
            } else {
                content.append(c);
            }
        }

        return content.toString().trim();
    }

    private String getFallbackInsight(double avgTemp, double avgHum, String heaterRuntime, int totalRecords) {
        if (totalRecords == 0 || avgTemp == 0.0) {
            return "HiroSumi is still gathering enough sensor data to understand the shelter pattern. Once more readings are available, the AI summary will give clearer comfort insights for the cats.";
        }

        if (avgTemp >= 20.0 && avgTemp <= 28.0 && avgHum <= 75.0) {
            return "The shelter environment looks stable and comfortable for the cats. Temperature and humidity are within a healthy range, while HiroSumi continues monitoring the system quietly in the background.";
        }

        if (avgHum > 75.0) {
            return "Humidity is slightly high, so the shelter may feel a little damp. HiroSumi should continue using ventilation to keep the air fresh and comfortable for the cats.";
        }

        if (avgTemp > 28.0) {
            return "The shelter is running a little warm, so ventilation is important right now. HiroSumi should keep balancing airflow and comfort to prevent the cats from overheating.";
        }

        return "HiroSumi is actively monitoring shelter conditions. The current readings help the system balance temperature, humidity, and cat comfort throughout the day.";
    }

    private String escapeJson(String text) {
        if (text == null) {
            return "";
        }

        return text
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}