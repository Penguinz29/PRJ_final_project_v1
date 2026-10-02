package com.edututor.dao;

import com.edututor.model.Question;
import com.edututor.model.QuestionOption;
import com.edututor.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class QuestionDAO {

    public List<Question> getAll() {
        List<Question> list = new ArrayList<>();
        String sql = "SELECT q.*, l.Title as LessonTitle FROM Questions q JOIN Lessons l ON q.LessonId = l.LessonId ORDER BY q.CreatedAt DESC";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next())
                list.add(mapQuestion(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Question> getByLessonAndType(int lessonId, String type) {
        List<Question> list = new ArrayList<>();
        String sql = "SELECT q.*, l.Title as LessonTitle FROM Questions q JOIN Lessons l ON q.LessonId = l.LessonId WHERE q.LessonId = ? AND q.QuestionType = ? ORDER BY q.CreatedAt ASC";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, lessonId);
            ps.setString(2, type);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next())
                    list.add(mapQuestion(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<QuestionOption> getOptions(int questionId) {
        List<QuestionOption> list = new ArrayList<>();
        String sql = "SELECT * FROM QuestionOptions WHERE QuestionId = ? ORDER BY OptionLetter ASC";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, questionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    QuestionOption opt = new QuestionOption();
                    opt.setOptionId(rs.getInt("OptionId"));
                    opt.setQuestionId(rs.getInt("QuestionId"));
                    opt.setOptionLetter(rs.getString("OptionLetter"));
                    opt.setContent(rs.getString("Content"));
                    opt.setCorrect(rs.getBoolean("IsCorrect"));
                    list.add(opt);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Question getById(int questionId) {
        String sql = "SELECT q.*, l.Title as LessonTitle FROM Questions q JOIN Lessons l ON q.LessonId = l.LessonId WHERE q.QuestionId = ?";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, questionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return mapQuestion(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    private Question mapQuestion(ResultSet rs) throws SQLException {
        Question q = new Question();
        q.setQuestionId(rs.getInt("QuestionId"));
        q.setLessonId(rs.getInt("LessonId"));
        q.setQuestionType(rs.getString("QuestionType"));
        q.setContent(rs.getString("Content"));
        q.setLevel(rs.getInt("Level"));
        q.setAiGenerated(rs.getBoolean("IsAiGenerated"));
        q.setTeacherId(rs.getInt("TeacherId"));
        q.setCreatedAt(rs.getDate("CreatedAt"));
        q.setLessonTitle(rs.getString("LessonTitle"));
        return q;
    }

    public int insert(Question q) {
        String sql = "INSERT INTO Questions (LessonId, QuestionType, Content, Level, IsAiGenerated, TeacherId, CreatedAt) VALUES (?, ?, ?, ?, ?, ?, GETDATE())";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, q.getLessonId());
            ps.setString(2, q.getQuestionType());
            ps.setString(3, q.getContent());
            ps.setInt(4, q.getLevel());
            ps.setBoolean(5, q.isAiGenerated());
            ps.setInt(6, q.getTeacherId());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next())
                    return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    public void insertOptions(int questionId, List<QuestionOption> options) {
        String sql = "INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            for (QuestionOption opt : options) {
                ps.setInt(1, questionId);
                ps.setString(2, opt.getOptionLetter());
                ps.setString(3, opt.getContent());
                ps.setBoolean(4, opt.isCorrect());
                ps.addBatch();
            }
            ps.executeBatch();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}

