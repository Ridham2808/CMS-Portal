package com.cms.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConfig {

    private static final String URL = "jdbc:mysql://localhost:3306/cms_db";
    private static final String USERNAME = "root";
    // ⚠️ SECURITY WARNING: NEVER COMMIT REAL PASSWORDS TO GITHUB! ⚠️
    // Use Environment Variables like System.getenv("DB_PASSWORD") or keep them strictly local.
    // For local testing, put your password here but DO NOT push it to the remote repository!
    private static final String PASSWORD = "YOUR_MYSQL_PASSWORD_HERE"; 

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
