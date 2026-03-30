package com.hirosumi.service;

public class TestConnection {
    public static void main(String[] args) {
        ThingSpeakFetcher fetcher = new ThingSpeakFetcher();
        
        System.out.println("HiroSumi Database Syncer Started...");
        
        // Loop forever to keep fetching data every 20 seconds
        while (true) {
            fetcher.fetchAndSaveData();
            
            try {
                System.out.println("Waiting 20 seconds for next update...");
                Thread.sleep(20000); // Wait 20 seconds (same as Pico upload speed)
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
}