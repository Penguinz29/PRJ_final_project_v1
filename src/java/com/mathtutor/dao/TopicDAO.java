package com.mathtutor.dao;

import com.mathtutor.model.Topic;
import com.mathtutor.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class TopicDAO {

    public List<Topic> getAll() {
        List<Topic> list = new ArrayList<>();
        String sql = "SELECT t.*, u.FullName as TeacherName FROM Topics t JOIN Users u ON t.TeacherId = u.UserId ORDER BY t.CreatedAt DESC";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next())
                list.add(mapTopic(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Topic> getByTeacherId(int teacherId) {
        List<Topic> list = new ArrayList<>();
        String sql = "SELECT t.*, u.FullName as TeacherName FROM Topics t JOIN Users u ON t.TeacherId = u.UserId WHERE t.TeacherId = ? ORDER BY t.CreatedAt DESC";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, teacherId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next())
                    list.add(mapTopic(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Topic getById(int topicId) {
        String sql = "SELECT t.*, u.FullName as TeacherName FROM Topics t JOIN Users u ON t.TeacherId = u.UserId WHERE t.TopicId = ?";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, topicId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return mapTopic(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    private Topic mapTopic(ResultSet rs) throws SQLException {
        Topic t = new Topic();
        t.setTopicId(rs.getInt("TopicId"));
        t.setTopicName(rs.getString("TopicName"));
        t.setDescription(rs.getString("Description"));
        t.setTeacherId(rs.getInt("TeacherId"));
        t.setCreatedAt(rs.getDate("CreatedAt"));
        // Extended
        t.setTeacherName(rs.getString("TeacherName"));
        return t;
    }

    public void insert(Topic t) {
        String sql = "INSERT INTO Topics (TopicName, Description, TeacherId, CreatedAt) VALUES (?, ?, ?, GETDATE())";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, t.getTopicName());
            ps.setString(2, t.getDescription());
            ps.setInt(3, t.getTeacherId());
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void update(Topic t) {
        String sql = "UPDATE Topics SET TopicName=?, Description=? WHERE TopicId=?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, t.getTopicName());
            ps.setString(2, t.getDescription());
            ps.setInt(3, t.getTopicId());
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void delete(int id) {
        String sql = "DELETE FROM Topics WHERE TopicId=?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
