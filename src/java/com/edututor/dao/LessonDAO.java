package com.edututor.dao;

import com.edututor.model.Lesson;
import com.edututor.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class LessonDAO {

    public List<Lesson> getAll() {
        List<Lesson> list = new ArrayList<>();
        String sql = "SELECT l.*, t.TopicName FROM Lessons l JOIN Topics t ON l.TopicId = t.TopicId ORDER BY l.CreatedAt DESC";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next())
                list.add(mapLesson(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Lesson> getByTopicId(int topicId) {
        List<Lesson> list = new ArrayList<>();
        String sql = "SELECT l.*, t.TopicName FROM Lessons l JOIN Topics t ON l.TopicId = t.TopicId WHERE l.TopicId = ? ORDER BY l.DisplayOrder ASC";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, topicId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next())
                    list.add(mapLesson(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Lesson getById(int lessonId) {
        String sql = "SELECT l.*, t.TopicName FROM Lessons l JOIN Topics t ON l.TopicId = t.TopicId WHERE l.LessonId = ?";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, lessonId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return mapLesson(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    private Lesson mapLesson(ResultSet rs) throws SQLException {
        Lesson l = new Lesson();
        l.setLessonId(rs.getInt("LessonId"));
        l.setTopicId(rs.getInt("TopicId"));
        l.setTitle(rs.getString("Title"));
        l.setSummary(rs.getString("Summary"));
        l.setContent(rs.getString("Content"));
        l.setYoutubeUrl(rs.getString("YoutubeUrl"));
        l.setDisplayOrder(rs.getInt("DisplayOrder"));
        l.setCreatedAt(rs.getDate("CreatedAt"));
        l.setTopicName(rs.getString("TopicName"));
        return l;
    }

    public void insert(Lesson l) {
        String sql = "INSERT INTO Lessons (TopicId, Title, Summary, Content, YoutubeUrl, DisplayOrder, CreatedAt) VALUES (?, ?, ?, ?, ?, ?, GETDATE())";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, l.getTopicId());
            ps.setString(2, l.getTitle());
            ps.setString(3, l.getSummary());
            ps.setString(4, l.getContent());
            ps.setString(5, l.getYoutubeUrl());
            ps.setInt(6, l.getDisplayOrder());
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void update(Lesson l) {
        String sql = "UPDATE Lessons SET TopicId=?, Title=?, Summary=?, Content=?, YoutubeUrl=?, DisplayOrder=? WHERE LessonId=?";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, l.getTopicId());
            ps.setString(2, l.getTitle());
            ps.setString(3, l.getSummary());
            ps.setString(4, l.getContent());
            ps.setString(5, l.getYoutubeUrl());
            ps.setInt(6, l.getDisplayOrder());
            ps.setInt(7, l.getLessonId());
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}

