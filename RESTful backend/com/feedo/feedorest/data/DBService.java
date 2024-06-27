package com.feedo.feedorest.data;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;


public class DBService {
    private Connection conn;

    public DBService(){
        try {
            String url = String.format("");
            String uname = "";
            String pwd = "";

            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, uname, pwd);
        } catch (SQLException | ClassNotFoundException e) {
            throw new RuntimeException(e);
        }
    }

    public Connection getConnection(){
        return conn;
    }
}
