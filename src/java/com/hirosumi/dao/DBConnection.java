package com.hirosumi.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    private static final String URL = "jdbc:mysql://localhost:3307/hirosumi_db";
    private static final String USER = "root";
    private static final String PASS = "admin"; 

    public static Connection getConnection() {
        Connection con = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(URL, USER, PASS);
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
        return con;
    }
    
    // ADD THIS MAIN METHOD TO TEST CONNECTION
    public static void main(String[] args) {
        Connection con = getConnection();
        if (con != null) {
            System.out.println("✅ SUCCESS: Database Connection Established!");
        } else {
            System.out.println("❌ ERROR: Failed to Connect. Check URL, User, or Password.");
        }
    }

}