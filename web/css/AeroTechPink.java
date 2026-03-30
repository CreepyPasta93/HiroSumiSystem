import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.geom.GeneralPath;
import java.awt.geom.RoundRectangle2D;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

public class AeroTechPink extends JFrame {

    // --- CONFIGURATION ---
    // PASTE YOUR KEYS HERE AGAIN
    private static final String CHANNEL_ID = "3214995";
    private static final String READ_API_KEY = "IC0BIUHZWCC1OCSH"; 
    
    private static final String API_URL = 
        "https://api.thingspeak.com/channels/" + CHANNEL_ID + "/feeds/last.json?api_key=" + READ_API_KEY;

    // --- COLORS (Aesthetic Pink Palette) ---
    final Color BG_COLOR = new Color(255, 240, 245); // Lavender Blush
    final Color CARD_COLOR = Color.WHITE;
    final Color ACCENT_COLOR = new Color(255, 105, 180); // Hot Pink
    final Color TEXT_COLOR = new Color(80, 80, 80);
    
    // UI Components
    private JLabel lblStatus, lblTime;
    private StatCard cardTemp, cardHum, cardWind, cardAir;
    private SimpleChartPanel chartPanel;
    private HttpClient client;

    public AeroTechPink() {
        setTitle("AeroTech ♡ Dashboard");
        setSize(900, 650);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLocationRelativeTo(null);
        getContentPane().setBackground(BG_COLOR);
        setLayout(new BorderLayout(20, 20));

        // --- HEADER ---
        JPanel headerPanel = new JPanel(new BorderLayout());
        headerPanel.setOpaque(false);
        headerPanel.setBorder(BorderFactory.createEmptyBorder(20, 30, 0, 30));

        JLabel title = new JLabel("AeroTech Station");
        title.setFont(new Font("SansSerif", Font.BOLD, 28));
        title.setForeground(ACCENT_COLOR);
        
        lblStatus = new JLabel("● Connecting...", SwingConstants.RIGHT);
        lblStatus.setFont(new Font("SansSerif", Font.BOLD, 14));
        lblStatus.setForeground(new Color(255, 160, 122));

        headerPanel.add(title, BorderLayout.WEST);
        headerPanel.add(lblStatus, BorderLayout.EAST);
        add(headerPanel, BorderLayout.NORTH);

        // --- MAIN CONTENT (Grid) ---
        JPanel contentPanel = new JPanel(new BorderLayout(20, 20));
        contentPanel.setOpaque(false);
        contentPanel.setBorder(BorderFactory.createEmptyBorder(20, 30, 30, 30));

        // 1. Stats Row
        JPanel statsGrid = new JPanel(new GridLayout(1, 4, 15, 0));
        statsGrid.setOpaque(false);
        statsGrid.setPreferredSize(new Dimension(0, 120));

        cardTemp = new StatCard("Temperature", "0.0", "°C", "🌡️");
        cardHum = new StatCard("Humidity", "0", "%", "💧");
        cardWind = new StatCard("Wind Speed", "0.0", "m/s", "🌬️");
        cardAir = new StatCard("Air Quality", "--", "", "☁️");

        statsGrid.add(cardTemp);
        statsGrid.add(cardHum);
        statsGrid.add(cardWind);
        statsGrid.add(cardAir);
        
        contentPanel.add(statsGrid, BorderLayout.NORTH);

        // 2. Chart Area
        chartPanel = new SimpleChartPanel("Live Temperature History");
        contentPanel.add(chartPanel, BorderLayout.CENTER);

        add(contentPanel, BorderLayout.CENTER);

        // --- SYSTEM ---
        client = HttpClient.newHttpClient();
        
        // Timer: Update every 20 seconds
        Timer timer = new Timer(20000, e -> fetchData());
        timer.setInitialDelay(0);
        timer.start();
    }

    private void fetchData() {
        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(API_URL))
                    .GET()
                    .build();

            client.sendAsync(request, HttpResponse.BodyHandlers.ofString())
                    .thenApply(HttpResponse::body)
                    .thenAccept(this::updateUI)
                    .exceptionally(e -> {
                        lblStatus.setText("● Offline");
                        lblStatus.setForeground(Color.RED);
                        return null;
                    });

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void updateUI(String json) {
        SwingUtilities.invokeLater(() -> {
            String time = LocalDateTime.now().format(DateTimeFormatter.ofPattern("HH:mm"));
            lblStatus.setText("● Online (Updated " + time + ")");
            lblStatus.setForeground(new Color(50, 205, 50)); // Lime Green

            String t = extractValue(json, "field1");
            String h = extractValue(json, "field2");
            String air = extractValue(json, "field4");
            String w = extractValue(json, "field5");

            cardTemp.updateVal(t);
            cardHum.updateVal(h);
            cardAir.updateVal(air);
            cardWind.updateVal(w);
            
            // Add to chart (try parsing temp as double)
            try {
                double tempVal = Double.parseDouble(t);
                chartPanel.addDataPoint(tempVal);
            } catch (Exception ignored) {}
        });
    }

    private String extractValue(String json, String key) {
        try {
            String searchKey = "\"" + key + "\":\"";
            int start = json.indexOf(searchKey);
            if (start == -1) return "--";
            start += searchKey.length();
            int end = json.indexOf("\"", start);
            return json.substring(start, end);
        } catch (Exception e) { return "--"; }
    }

    public static void main(String[] args) {
        // Set System Look and Feel for better fonts
        try { UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName()); } catch (Exception e) {}
        
        SwingUtilities.invokeLater(() -> new AeroTechPink().setVisible(true));
    }

    // ==========================================
    // CUSTOM COMPONENT: ROUNDED STAT CARD
    // ==========================================
    class StatCard extends JPanel {
        private JLabel valLabel;
        
        public StatCard(String title, String val, String unit, String icon) {
            setOpaque(false);
            setLayout(new BorderLayout());
            setBorder(BorderFactory.createEmptyBorder(15, 20, 15, 20));

            JLabel titleLbl = new JLabel(icon + " " + title);
            titleLbl.setFont(new Font("SansSerif", Font.BOLD, 12));
            titleLbl.setForeground(new Color(150, 150, 150));

            valLabel = new JLabel(val + unit);
            valLabel.setFont(new Font("SansSerif", Font.BOLD, 24));
            valLabel.setForeground(ACCENT_COLOR);
            valLabel.setHorizontalAlignment(SwingConstants.CENTER);

            add(titleLbl, BorderLayout.NORTH);
            add(valLabel, BorderLayout.CENTER);
        }

        public void updateVal(String v) {
            // Keep the unit (last char/s) if possible, or just reset text
            String current = valLabel.getText();
            String unit = current.replaceAll("[0-9.]", ""); 
            valLabel.setText(v + unit);
        }

        @Override
        protected void paintComponent(Graphics g) {
            Graphics2D g2 = (Graphics2D) g;
            g2.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
            
            // Draw Shadow
            g2.setColor(new Color(230, 230, 230));
            g2.fillRoundRect(3, 3, getWidth()-6, getHeight()-6, 30, 30);
            
            // Draw Card
            g2.setColor(CARD_COLOR);
            g2.fillRoundRect(0, 0, getWidth()-4, getHeight()-4, 30, 30);
            
            super.paintComponent(g);
        }
    }

    // ==========================================
    // CUSTOM COMPONENT: CUTE CURVY CHART
    // ==========================================
    class SimpleChartPanel extends JPanel {
        private List<Double> history = new ArrayList<>();
        private final int MAX_POINTS = 20; // Keep last 20 readings
        private String title;

        public SimpleChartPanel(String title) {
            this.title = title;
            setOpaque(false);
        }

        public void addDataPoint(double val) {
            history.add(val);
            if (history.size() > MAX_POINTS) history.remove(0);
            repaint();
        }

        @Override
        protected void paintComponent(Graphics g) {
            super.paintComponent(g);
            Graphics2D g2 = (Graphics2D) g;
            g2.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);

            int w = getWidth();
            int h = getHeight();

            // Background Bubble
            g2.setColor(Color.WHITE);
            g2.fillRoundRect(0, 0, w, h, 40, 40);
            
            // Title
            g2.setColor(Color.GRAY);
            g2.setFont(new Font("SansSerif", Font.BOLD, 14));
            g2.drawString(title, 20, 30);

            if (history.size() < 2) return;

            // Chart Drawing Logic
            int padding = 50;
            int graphW = w - (padding * 2);
            int graphH = h - (padding * 2);

            // Find Min/Max to scale the chart
            double min = history.stream().min(Double::compare).get() - 1;
            double max = history.stream().max(Double::compare).get() + 1;
            
            g2.setColor(new Color(255, 182, 193)); // Light Pink Grid lines
            g2.setStroke(new BasicStroke(1));
            g2.drawLine(padding, h-padding, w-padding, h-padding); // X Axis
            g2.drawLine(padding, padding, padding, h-padding); // Y Axis

            // Draw Curve
            GeneralPath path = new GeneralPath();
            int pointGap = graphW / (MAX_POINTS - 1);
            
            g2.setColor(ACCENT_COLOR);
            g2.setStroke(new BasicStroke(3f, BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND));

            for (int i = 0; i < history.size(); i++) {
                double val = history.get(i);
                int x = padding + (i * pointGap);
                // Map value to Y position (Invert because 0 is top)
                int y = (int) ((h - padding) - ((val - min) / (max - min)) * graphH);

                if (i == 0) path.moveTo(x, y);
                else path.lineTo(x, y);
                
                // Draw little dots
                g2.fillOval(x-4, y-4, 8, 8);
            }
            g2.draw(path);
        }
    }
}