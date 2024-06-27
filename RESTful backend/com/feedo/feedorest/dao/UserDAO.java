package com.feedo.feedorest.dao;

import com.feedo.feedorest.data.DBService;
import com.feedo.feedorest.model.User;

import java.sql.*;

public class UserDAO {
    Connection conn;

    public UserDAO(){
        DBService DbServ = new DBService();
        conn = DbServ.getConnection();
    }

    public User doLogin(User user){
        try {
            PreparedStatement ps =
                    conn.prepareStatement("select * from users U where U.email=? and U.password=?");
            ps.setString(1, user.getEmail());
            ps.setString(2, user.getPassword());
            ResultSet rs = ps.executeQuery();
            if(rs.next()){
                user.setName(rs.getString("name"));
                user.setSurname(rs.getString("surname"));
            }
            else
                return null;
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }

        return user;
    }

    public boolean doVerify(User user){
        try {
            PreparedStatement ps =
                    conn.prepareStatement("select * from users U where U.email=?");
            ps.setString(1, user.getEmail());
            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public int doSignup(User user){
        try {
            PreparedStatement ps =
                    conn.prepareStatement("insert into users values(?, ?, ?, ?)");
            ps.setString(1, user.getEmail());
            ps.setString(2, user.getName());
            ps.setString(3, user.getSurname());
            ps.setString(4, user.getPassword());
            return ps.executeUpdate();

        }
        catch (SQLIntegrityConstraintViolationException e){
            return -1;
        }
        catch (SQLException e) {
            throw new RuntimeException(e);
        }

    }

    public int doDelete(User user){
        try {
            PreparedStatement ps =
                    conn.prepareStatement("delete from users u where u.email = ? and u.password = ?");
            ps.setString(1, user.getEmail());
            ps.setString(2, user.getPassword());
            return ps.executeUpdate();

        } catch (SQLException e) {
            throw new RuntimeException(e);
        }

    }

    public int doPasswordReset(User user){
        try {
            PreparedStatement ps =
                    conn.prepareStatement("update users u set u.password = ? where u.email = ?");
            ps.setString(1, user.getPassword());
            ps.setString(2, user.getEmail());
            return ps.executeUpdate();

        } catch (SQLException e) {
            throw new RuntimeException(e);
        }

    }
}
