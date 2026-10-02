import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class TestDB {
    public static void main(String[] args) {
        String url = "jdbc:sqlserver://localhost:1433;databaseName=MathTutorDB;encrypt=false";
        String user = "sa";
        String pass = "123456";
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            System.out.println("Driver loaded.");
            Connection conn = DriverManager.getConnection(url, user, pass);
            System.out.println("Connected to DB successfully!");
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
