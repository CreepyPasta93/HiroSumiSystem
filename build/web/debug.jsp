<%@page import="java.sql.*"%>
<%@page import="java.net.*"%>
<%@page import="java.io.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Super Debugger Fixed</title>
        <style>
            body { font-family: monospace; padding: 20px; background: #f4f4f4; }
            .box { background: white; padding: 15px; margin-bottom: 15px; border-left: 5px solid #ccc; box-shadow: 2px 2px 5px rgba(0,0,0,0.1); }
            .success { border-left-color: green; }
            .error { border-left-color: red; color: #d32f2f; }
            .info { border-left-color: blue; }
        </style>
    </head>
    <body>
        <h2>HiroSumi Connection Test (Fixed)</h2>

        <div class="box info">
            <h3>Step 1: Fetching Raw Data from ThingSpeak...</h3>
            <%
                // YOUR KEYS
                String CHANNEL_ID = "3214995"; 
                String READ_API_KEY = "IC0BIUHZWCC1OCSH";
                
                String jsonResponse = "";
                double temp = 0.0;
                double hum = 0.0;

                try {
                    String urlString = "https://api.thingspeak.com/channels/" + CHANNEL_ID + "/feeds/last.json?api_key=" + READ_API_KEY;
                    URL url = new URL(urlString);
                    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                    conn.setRequestMethod("GET");
                    
                    BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
                    String inputLine;
                    StringBuilder content = new StringBuilder();
                    while ((inputLine = in.readLine()) != null) content.append(inputLine);
                    in.close();
                    
                    jsonResponse = content.toString();
                    out.println("<strong>SUCCESS! Raw JSON Received:</strong><br>" + jsonResponse);
                    
                    // QUICK PARSE
                    if(jsonResponse.contains("field1") && jsonResponse.contains("field2")) {
                        String t = jsonResponse.split("\"field1\":\"")[1].split("\"")[0];
                        String h = jsonResponse.split("\"field2\":\"")[1].split("\"")[0];
                        
                        // Handle nulls
                        if(t.equals("null")) t = "0";
                        if(h.equals("null")) h = "0";

                        temp = Double.parseDouble(t);
                        hum = Double.parseDouble(h);
                        out.println("<br><br><strong>Parsed Data:</strong> Temp=" + temp + ", Hum=" + hum);
                    } else {
                         out.println("<br><br><span style='color:red'>WARNING: JSON does not contain field1/field2. Check ThingSpeak settings!</span>");
                    }

                } catch (Exception e) {
                    out.println("<div class='error'><strong>ThingSpeak Error:</strong> " + e.getMessage() + "</div>");
                }
            %>
        </div>

        <div class="box success">
            <h3>Step 2: Attempting Database Save...</h3>
            <%
                if (jsonResponse.equals("")) {
                    out.println("Skipping DB save because Step 1 failed.");
                } else {
                    Connection con = null;
                    try {
                        // 1. CONNECT (Using your Port 3307 and Password admin)
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        con = DriverManager.getConnection("jdbc:mysql://localhost:3307/hirosumi_db?useSSL=false", "root", "admin"); 
                        out.println("Database Connected.<br>");

                        // 2. INSERT
                        // We use NOW() in SQL instead of Java System time to avoid the error
                        String sql = "INSERT INTO EnvironmentalData (temperature, humidity, timestamp) VALUES (?, ?, NOW())";
                        
                        PreparedStatement ps = con.prepareStatement(sql);
                        ps.setDouble(1, temp);
                        ps.setDouble(2, hum);
                        // Line 85 removed - SQL handles the time now
                        
                        int rows = ps.executeUpdate();
                        if(rows > 0) {
                             out.println("<h3 style='color:green'>SUCCESS! Data Saved to Database.</h3>");
                             out.println("Check your 'EnvironmentalData' table in phpMyAdmin now!");
                        }

                    } catch (Exception e) {
                        out.println("<div class='error'><strong>DATABASE ERROR:</strong> " + e.getMessage() + "<br>");
                        out.println("<em>(Hint: If it says 'Table EnvironmentalData doesn't exist', create it in phpMyAdmin!)</em></div>");
                    } finally {
                        if(con != null) con.close();
                    }
                }
            %>
        </div>
    </body>
</html>