package com.hirosumi.model;

public class Notification {
    private int requestId;
    private String sensorName;
    private float newThreshold;
    private String reason;
    private int userId;
    private String status; // 🍓 ADD THIS LINE

    // Getters and Setters
    public int getRequestId() { return requestId; }
    public void setRequestId(int requestId) { this.requestId = requestId; }
    
    public String getSensorName() { return sensorName; }
    public void setSensorName(String sensorName) { this.sensorName = sensorName; }
    
    public float getNewThreshold() { return newThreshold; }
    public void setNewThreshold(float newThreshold) { this.newThreshold = newThreshold; }
    
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
    
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    // 🍓 ADD THESE TWO METHODS
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}