package com.mathtutor.dao;

import com.mathtutor.model.Submission;
import com.mathtutor.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class SubmissionDAO {

    public void insert(Submission sub) {
        String sql = "INSERT INTO Submissions (StudentId, LessonId, QuestionId, QuestionType, StudentAnswer, EssayImagePath, IsCorrect, TeacherFeedback, IsReviewed) "
                +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, sub.getStudentId());
            if (sub.getLessonId() != null)
                ps.setInt(2, sub.getLessonId());
            else
                ps.setNull(2, java.sql.Types.INTEGER);
            ps.setInt(3, sub.getQuestionId());
            ps.setString(4, sub.getQuestionType());
            ps.setString(5, sub.getStudentAnswer());
            ps.setString(6, sub.getEssayImagePath());
            if (sub.getIsCorrect() != null)
                ps.setBoolean(7, sub.getIsCorrect());
            else
                ps.setNull(7, java.sql.Types.BIT);
            ps.setString(8, sub.getTeacherFeedback());
            ps.setBoolean(9, sub.isReviewed());
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<Submission> getHistory(int studentId, String type, int page, int pageSize) {
        List<Submission> list = new ArrayList<>();
        int offset = (page - 1) * pageSize;
        String sql = "SELECT s.*, q.Content as QuestionTitle, q.IsAiGenerated, l.Title as LessonTitle " +
                "FROM Submissions s JOIN Questions q ON s.QuestionId = q.QuestionId LEFT JOIN Lessons l ON s.LessonId = l.LessonId "
                +
                "WHERE s.StudentId = ? ";
        if (type != null && !type.equals("ALL")) {
            sql += "AND s.QuestionType = ? ";
        }
        sql += "ORDER BY s.SubmittedAt DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            int pIndex = 2;
            if (type != null && !type.equals("ALL")) {
                ps.setString(pIndex++, type);
            }
            ps.setInt(pIndex++, offset);
            ps.setInt(pIndex, pageSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next())
                    list.add(mapSubmission(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countHistory(int studentId, String type) {
        String sql = "SELECT COUNT(*) FROM Submissions WHERE StudentId = ? ";
        if (type != null && !type.equals("ALL"))
            sql += "AND QuestionType = ?";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            if (type != null && !type.equals("ALL"))
                ps.setString(2, type);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    private Submission mapSubmission(ResultSet rs) throws SQLException {
        Submission s = new Submission();
        s.setSubmissionId(rs.getInt("SubmissionId"));
        s.setStudentId(rs.getInt("StudentId"));
        s.setLessonId(rs.getInt("LessonId"));
        if (rs.wasNull())
            s.setLessonId(null);
        s.setQuestionId(rs.getInt("QuestionId"));
        s.setQuestionType(rs.getString("QuestionType"));
        s.setStudentAnswer(rs.getString("StudentAnswer"));
        s.setEssayImagePath(rs.getString("EssayImagePath"));
        boolean isCrt = rs.getBoolean("IsCorrect");
        if (!rs.wasNull())
            s.setIsCorrect(isCrt);
        else
            s.setIsCorrect(null);
        s.setTeacherFeedback(rs.getString("TeacherFeedback"));
        s.setReviewed(rs.getBoolean("IsReviewed"));
        s.setSubmittedAt(rs.getTimestamp("SubmittedAt"));

        try {
            s.setQuestionTitle(rs.getString("QuestionTitle"));
        } catch (SQLException ex) {
        }
        try {
            s.setLessonTitle(rs.getString("LessonTitle"));
        } catch (SQLException ex) {
        }
        try {
            s.setQuestionAiGenerated(rs.getBoolean("IsAiGenerated"));
        } catch (SQLException ex) {
        }
        return s;
    }
}
