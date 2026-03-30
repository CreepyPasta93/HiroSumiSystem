package com.hirosumi.model;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class SystemLog {
    private int alertId;
    private Timestamp timestamp;
    private String source;
    private String category;
    private String description;
    private String status;

    public SystemLog(int alertId, Timestamp timestamp, String source, String category, String description, String status) {
        this.alertId = alertId;
        this.timestamp = timestamp;
        this.source = source;
        this.category = category;
        this.description = description;
        this.status = status;
    }

    // Getters
    public int getAlertId() { return alertId; }
    public String getSource() { return source; }
    public String getCategory() { return category; }
    public String getDescription() { return description; }
    public String getStatus() { return status; }
    
    // Helper to format date nicely like "Dec 08, 09:30 PM"
    public String getFormattedDate() {
        if (timestamp == null) return "";
        SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, hh:mm a");
        return sdf.format(timestamp);
    }
}