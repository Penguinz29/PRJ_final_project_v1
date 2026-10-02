package com.mathtutor.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Lớp kết nối Database SQL Server
 */
public class DBContext {
    private static final String DEFAULT_URL = "jdbc:sqlserver://localhost:1433;databaseName=MathTutorDB;encrypt=true;trustServerCertificate=true";
    private static final String DEFAULT_USER = "sa";
    private static final String DEFAULT_PASS = "123"; // Đổi pass SA tùy môi trường

    static {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE,
                    "Không tìm thấy Microsoft SQL Server JDBC Driver", ex);
        }
    }

    public static Connection getConnection() throws SQLException {
        // Hỗ trợ cấu hình qua environment (tốt cho deploy)
        String envUrl = System.getenv("DB_URL");
        String envUser = System.getenv("DB_USER");
        String envPass = System.getenv("DB_PASS");

        String url = (envUrl != null && !envUrl.trim().isEmpty()) ? envUrl : DEFAULT_URL;
        String user = (envUser != null && !envUser.trim().isEmpty()) ? envUser : DEFAULT_USER;
        String pass = (envPass != null && !envPass.trim().isEmpty()) ? envPass : DEFAULT_PASS;

        return DriverManager.getConnection(url, user, pass);
    }
}
