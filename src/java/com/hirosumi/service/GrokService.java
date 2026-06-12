package com.hirosumi.service;

import java.io.InputStream;
import java.util.Properties;
import javax.servlet.ServletContext;
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

    public String generateAnalyticsInsight(
            ServletContext context,
            double avgTemp,
            double avgHum,
            String fanRuntime,
            int totalRecords,
            int comfortScore,
            String heatRiskLevel,
            String heatPatternInsight,
            String fanEffectivenessInsight
    ) {
        String apiKey = getConfigValue(context, "XAI_API_KEY");

        System.out.println("XAI key loaded? " + (apiKey != null && !apiKey.trim().isEmpty()));

        if (apiKey == null || apiKey.trim().isEmpty()) {
            return getFallbackInsight(
                    avgTemp,
                    avgHum,
                    fanRuntime,
                    totalRecords,
                    comfortScore,
                    heatRiskLevel,
                    heatPatternInsight,
                    fanEffectivenessInsight
            );
        }

        try {
            String prompt = buildPrompt(
                    avgTemp,
                    avgHum,
                    fanRuntime,
                    totalRecords,
                    comfortScore,
                    heatRiskLevel,
                    heatPatternInsight,
                    fanEffectivenessInsight
            );

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
                return getFallbackInsight(
                        avgTemp,
                        avgHum,
                        fanRuntime,
                        totalRecords,
                        comfortScore,
                        heatRiskLevel,
                        heatPatternInsight,
                        fanEffectivenessInsight
                );
            }

            String content = extractContent(response.toString());

            if (content == null || content.trim().isEmpty()) {
                return getFallbackInsight(
                        avgTemp,
                        avgHum,
                        fanRuntime,
                        totalRecords,
                        comfortScore,
                        heatRiskLevel,
                        heatPatternInsight,
                        fanEffectivenessInsight
                );
            }

            return content;

        } catch (Exception e) {
            e.printStackTrace();
            return getFallbackInsight(
                    avgTemp,
                    avgHum,
                    fanRuntime,
                    totalRecords,
                    comfortScore,
                    heatRiskLevel,
                    heatPatternInsight,
                    fanEffectivenessInsight
            );
        }
    }

    private String getConfigValue(ServletContext context, String key) {
        Properties config = new Properties();

        try (InputStream input = context.getResourceAsStream("/WEB-INF/config.properties")) {

            if (input == null) {
                System.out.println("config.properties not found in WEB-INF folder.");
                return null;
            }

            config.load(input);
            return config.getProperty(key);

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private String buildPrompt(
            double avgTemp,
            double avgHum,
            String fanRuntime,
            int totalRecords,
            int comfortScore,
            String heatRiskLevel,
            String heatPatternInsight,
            String fanEffectivenessInsight
    ) {
        return "You are Grok writing an AI Shelter Health Analysis for HiroSumi Smart Stray Cat Shelter. "
                + "Do not only summarize the readings. Explain what the collected data can be used for. "
                + "Write in a warm but professional caretaker-dashboard tone. "
                + "Focus on cat comfort, repeated heat patterns, fan effectiveness, and practical shelter improvement. "
                + "Maximum 4 sentences. No markdown. "
                + "Data: average temperature over 7 days = " + avgTemp + "°C, "
                + "average humidity over 7 days = " + avgHum + "%, "
                + "estimated fan runtime over 7 days = " + fanRuntime + ", "
                + "sensor records shown = " + totalRecords + ", "
                + "comfort score = " + comfortScore + "/100, "
                + "risk level = " + heatRiskLevel + ", "
                + "heat pattern insight = " + heatPatternInsight + ", "
                + "fan effectiveness insight = " + fanEffectivenessInsight + ". "
                + "End with a useful recommendation such as adding another fan, improving airflow, roof insulation, or moving the shelter under shade only if the data suggests it.";
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

    private String getFallbackInsight(
            double avgTemp,
            double avgHum,
            String fanRuntime,
            int totalRecords,
            int comfortScore,
            String heatRiskLevel,
            String heatPatternInsight,
            String fanEffectivenessInsight
    ) {
        if (totalRecords == 0 || avgTemp == 0.0) {
            return "HiroSumi is still gathering enough sensor data to understand the shelter pattern. Once more readings are available, the AI can detect heat trends, fan effectiveness, and comfort risks more clearly.";
        }

        if (comfortScore >= 80) {
            return "The shelter environment looks stable with a comfort score of "
                    + comfortScore + "/100. The collected data shows that temperature and humidity are currently manageable, so HiroSumi can continue monitoring without major shelter changes.";
        }

        if (comfortScore >= 60) {
            return "The shelter is at a moderate comfort level with a score of "
                    + comfortScore + "/100. " + heatPatternInsight
                    + " " + fanEffectivenessInsight;
        }

        return "The shelter may need improvement because the comfort score is only "
                + comfortScore + "/100, which indicates " + heatRiskLevel + ". "
                + heatPatternInsight + " " + fanEffectivenessInsight;
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
