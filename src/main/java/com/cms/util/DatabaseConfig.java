package com.cms.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConfig {

    private static final String URL = "jdbc:mysql://mysql-3a418559-ridham-aeed.i.aivencloud.com:23165/defaultdb";
    private static final String USERNAME = "avnadmin";
    // Fetch password from Render environment variable to pass GitHub Secret Scanning
    private static final String PASSWORD = System.getenv("AIVEN_PASSWORD") != null ? System.getenv("AIVEN_PASSWORD") : "YOUR_LOCAL_TEST_APP_PASSWORD";

    static {
        try {
            // Load the MySQL JDBC Driver
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            throw new RuntimeException("Failed to load MySQL database driver.");
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USERNAME, PASSWORD);
    }
}
