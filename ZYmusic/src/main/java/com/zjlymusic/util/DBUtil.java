package com.zjlymusic.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBUtil {
    private static boolean initialized = false;
    
    private static synchronized void ensureInitialized() {
        if (!initialized) {
            try {
                Class.forName("org.sqlite.JDBC");
                DBInit.initialize();
                initialized = true;
            } catch (ClassNotFoundException e) {
                throw new RuntimeException("SQLite 驱动加载失败", e);
            }
        }
    }

    public static Connection getConnection() throws SQLException {
        ensureInitialized();
        Connection conn = DriverManager.getConnection("jdbc:sqlite:" + AppPaths.getDatabaseFile().getAbsolutePath());
        try (java.sql.Statement stmt = conn.createStatement()) {
            stmt.execute("PRAGMA busy_timeout=5000");
        }
        return conn;
    }

    public static void close(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
