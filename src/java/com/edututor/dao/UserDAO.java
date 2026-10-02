package com.edututor.dao;

import com.edututor.model.User;
import com.edututor.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    public User login(String username, String hashedPass) {
        String sql = "SELECT * FROM Users WHERE Username = ? AND PasswordHash = ? AND IsActive = 1";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, hashedPass);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return mapUser(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<User> getByRole(String role, int page, int pageSize) {
        List<User> list = new ArrayList<>();
        int offset = (page - 1) * pageSize;
        String sql = "SELECT * FROM Users WHERE [Role] = ? ORDER BY CreatedAt DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, role);
            ps.setInt(2, offset);
            ps.setInt(3, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next())
                    list.add(mapUser(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countByRole(String role) {
        String sql = "SELECT COUNT(*) FROM Users WHERE [Role] = ?";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, role);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Kiểm tra username đã tồn tại chưa
     */
    public boolean existsByUsername(String username) {
        String sql = "SELECT COUNT(*) FROM Users WHERE Username = ?";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Kiểm tra email đã tồn tại chưa
     */
    public boolean existsByEmail(String email) {
        String sql = "SELECT COUNT(*) FROM Users WHERE Email = ?";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Đăng ký tài khoản mới (mặc định role=STUDENT, IsActive=1)
     */
    public boolean insertUser(String username, String passwordHash, String fullName, String email) {
        String sql = "INSERT INTO Users (Username, PasswordHash, FullName, Email, [Role], IsActive) VALUES (?, ?, ?, ?, 'STUDENT', 1)";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, passwordHash);
            ps.setString(3, fullName);
            ps.setString(4, email);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * FR-ADM-03: Lấy thông tin user theo ID
     */
    public User getById(int userId) {
        String sql = "SELECT * FROM Users WHERE UserId = ?";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * FR-ADM-03: Đổi trạng thái kích hoạt/khóa tài khoản (IsActive: 1 <-> 0)
     */
    public boolean toggleStatus(int userId) {
        String sql = "UPDATE Users SET IsActive = CASE WHEN IsActive = 1 THEN 0 ELSE 1 END WHERE UserId = ?";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private User mapUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getInt("UserId"));
        u.setUsername(rs.getString("Username"));
        u.setPasswordHash(rs.getString("PasswordHash"));
        u.setFullName(rs.getString("FullName"));
        u.setEmail(rs.getString("Email"));
        u.setRole(rs.getString("Role"));
        u.setActive(rs.getBoolean("IsActive"));

        int teacherId = rs.getInt("TeacherId");
        if (!rs.wasNull())
            u.setTeacherId(teacherId);

        u.setCreatedAt(rs.getDate("CreatedAt"));
        return u;
    }
}

