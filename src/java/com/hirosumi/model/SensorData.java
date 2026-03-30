package com.hirosumi.model;

import java.sql.Timestamp;

public class SensorData {
    private int id; // 🆕 Added ID
    private double temperature;
    private double humidity;
    private double pressure;
    private int motionStatus;
    private int fanStatus;
    private Timestamp timestamp;

    //Constructor
    public SensorData(int id, double temperature, double humidity, double pressure, int motionStatus, int fanStatus, Timestamp timestamp) {
        this.id = id;
        this.temperature = temperature;
        this.humidity = humidity;
        this.pressure = pressure;
        this.motionStatus = motionStatus;
        this.fanStatus = fanStatus;
        this.timestamp = timestamp;
    }

    // Default constructor for compatibility if needed (optional)
    public SensorData(double temperature, double humidity, double pressure, int motionStatus, int fanStatus, Timestamp timestamp) {
        this.id = 0; // Default
        this.temperature = temperature;
        this.humidity = humidity;
        this.pressure = pressure;
        this.motionStatus = motionStatus;
        this.fanStatus = fanStatus;
        this.timestamp = timestamp;
    }

    // Getters
    public int getId() { return id; } // 🆕 Getter
    public double getTemperature() { return temperature; }
    public double getHumidity() { return humidity; }
    public double getPressure() { return pressure; }
    public int getMotionStatus() { return motionStatus; }
    public int getFanStatus() {return fanStatus; }
    public Timestamp getTimestamp() { return timestamp; }
}