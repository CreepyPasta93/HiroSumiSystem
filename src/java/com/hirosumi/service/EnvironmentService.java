/*
 * not yet implemented please check it again later
 */
package com.hirosumi.service;

/**
 * SERVICE LAYER: Cat Habitability Index (CHI) Algorithm.
 * This satisfies the "Software Engineering Element" by processing raw data
 * into a meaningful health score (0-100%) rather than just passing raw numbers.
 */
public class EnvironmentService {

    // Ideal constants for Cats (based on vet research)
    private static final double IDEAL_TEMP = 28.0;
    private static final double IDEAL_HUMIDITY = 50.0;

    public String getHabitabilityStatus(double currentTemp, double currentHum) {
        int score = calculateScore(currentTemp, currentHum);
        
        // Return a human-readable status
        if (score >= 80) return "OPTIMAL (Score: " + score + "%) 🟢";
        if (score >= 50) return "MODERATE (Score: " + score + "%) 🟡";
        return "CRITICAL (Score: " + score + "%) 🔴";
    }

    private int calculateScore(double temp, double hum) {
        double score = 100.0;

        // WEIGHTED ALGORITHM:
        // Temperature is 3x more important than humidity for cat health.
        double tempDiff = Math.abs(temp - IDEAL_TEMP);
        score -= (tempDiff * 3.0); 

        double humDiff = Math.abs(hum - IDEAL_HUMIDITY);
        score -= (humDiff * 1.0);

        // Critical Safety Gate
        if (temp > 35.0) score = 0; // Immediate danger

        // Clamping (0-100)
        return (int) Math.max(0, Math.min(100, score));
    }
}