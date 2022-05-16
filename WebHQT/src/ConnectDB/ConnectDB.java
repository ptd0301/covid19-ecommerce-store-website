/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Other/File.java to edit this template
 */
package ConnectDB;
import com.microsoft.sqlserver.jdbc.SQLServerException;
import java.sql.*;

/**
 *
 * @author Hoan
 */
public class ConnectDB {
    public static Connection connectDB( String DB_URL ) {
        Driver myDriver = new com.microsoft.sqlserver.jdbc.SQLServerDriver();
        try {
            DriverManager.registerDriver(myDriver);
        } catch (SQLException e) {
        }

        Connection conn = null;
        try {
            conn = DriverManager.getConnection(DB_URL);
        } catch (SQLException e) {
        }
        if (conn != null) {
            System.out.println("Connected");
        }
        return conn;
    }

    /**
     * @param args the command line arguments
     * @throws com.microsoft.sqlserver.jdbc.SQLServerException
     */
    public static void main(String args[]) throws SQLServerException {
        String url = "jdbc:sqlserver://localhost:1433;databaseName=Z;user=sa;password=03012001;trustServerCertificate=true";
        Connection conn = connectDB(url);
    }
}