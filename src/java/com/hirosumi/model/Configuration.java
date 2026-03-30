package com.hirosumi.model;

public class Configuration {

    private int configId;
    private double heaterActivation;
    private double heaterCutoff;
    private int lightActiveDuration;
    private double safetyAlertTemp;

    // 🐾 NEW VARIABLES
    private double fanActivationThreshold;
    private double fanCutoffThreshold;
    private double humidityThreshold;
    private int nightModeStart;
    private int nightModeEnd;

    // UPDATE CONSTRUCTOR
    public Configuration(int configId, double heaterActivation, double heaterCutoff,
            int lightActiveDuration, double safetyAlertTemp,
            double fanActivationThreshold, double fanCutoffThreshold,
            double humidityThreshold, int nightModeStart, int nightModeEnd) {
        this.configId = configId;
        this.heaterActivation = heaterActivation;
        this.heaterCutoff = heaterCutoff;
        this.lightActiveDuration = lightActiveDuration;
        this.safetyAlertTemp = safetyAlertTemp;
        this.fanActivationThreshold = fanActivationThreshold;
        this.fanCutoffThreshold = fanCutoffThreshold;
        this.humidityThreshold = humidityThreshold;
        this.nightModeStart = nightModeStart;
        this.nightModeEnd = nightModeEnd;
    }

    // GETTERS AND SETTERS
    public int getConfigId() {
        return configId;
    }

    public double getHeaterActivation() {
        return heaterActivation;
    }

    public double getHeaterCutoff() {
        return heaterCutoff;
    }

    public int getLightActiveDuration() {
        return lightActiveDuration;
    }

    public double getSafetyAlertTemp() {
        return safetyAlertTemp;
    }

    public double getFanActivationThreshold() {
        return fanActivationThreshold;
    }

    public double getFanCutoffThreshold() {
        return fanCutoffThreshold;
    }

    public double getHumidityThreshold() {
        return humidityThreshold;
    }

    public int getNightModeStart() {
        return nightModeStart;
    }

    public int getNightModeEnd() {
        return nightModeEnd;
    }

    public void setConfigId(int configId) {
        this.configId = configId;
    }

    public void setHeaterActivation(double heaterActivation) {
        this.heaterActivation = heaterActivation;
    }

    public void setHeaterCutoff(double heaterCutoff) {
        this.heaterCutoff = heaterCutoff;
    }

    public void setLightActiveDuration(int lightActiveDuration) {
        this.lightActiveDuration = lightActiveDuration;
    }

    public void setSafetyAlertTemp(double safetyAlertTemp) {
        this.safetyAlertTemp = safetyAlertTemp;
    }

    public void setFanActivationThreshold(double fanActivationThreshold) {
        this.fanActivationThreshold = fanActivationThreshold;
    }

    public void setFanCutoffThreshold(double fanCutoffThreshold) {
        this.fanCutoffThreshold = fanCutoffThreshold;
    }

    public void setHumidityThreshold(double humidityThreshold) {
        this.humidityThreshold = humidityThreshold;
    }

    public void setNightModeStart(int nightModeStart) {
        this.nightModeStart = nightModeStart;
    }

    public void setNightModeEnd(int nightModeEnd) {
        this.nightModeEnd = nightModeEnd;
    }

}
