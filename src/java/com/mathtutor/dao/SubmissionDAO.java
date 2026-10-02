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

    /**
     * FR-TEA-04: Lấy danh sách bài nộp tự luận phân trang theo trạng thái đã duyệt hay chưa
     */
    public List<Submission> getSubmissionsForTeacher(int teacherId, boolean reviewed, int page, int pageSize) {
        List<Submission> list = new ArrayList<>();
        int offset = (page - 1) * pageSize;
        String sql = "SELECT s.*, u.FullName as StudentName, u.Email as StudentEmail, "
                + "q.Content as QuestionTitle, q.Content as QuestionContent, q.IsAiGenerated, l.Title as LessonTitle "
                + "FROM Submissions s "
                + "JOIN Users u ON s.StudentId = u.UserId "
                + "JOIN Questions q ON s.QuestionId = q.QuestionId "
                + "LEFT JOIN Lessons l ON s.LessonId = l.LessonId "
                + "WHERE s.QuestionType = 'ESSAY' AND s.IsReviewed = ? "
                + "ORDER BY s.SubmittedAt DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, reviewed);
            ps.setInt(2, offset);
            ps.setInt(3, pageSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapSubmission(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * FR-TEA-04: Đếm số lượng bài nộp tự luận theo trạng thái
     */
    public int countSubmissionsForTeacher(int teacherId, boolean reviewed) {
        String sql = "SELECT COUNT(*) FROM Submissions WHERE QuestionType = 'ESSAY' AND IsReviewed = ?";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, reviewed);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * FR-TEA-04: Lấy chi tiết 1 bài nộp theo ID
     */
    public Submission getById(int submissionId) {
        String sql = "SELECT s.*, u.FullName as StudentName, u.Email as StudentEmail, "
                + "q.Content as QuestionTitle, q.Content as QuestionContent, q.IsAiGenerated, l.Title as LessonTitle "
                + "FROM Submissions s "
                + "JOIN Users u ON s.StudentId = u.UserId "
                + "JOIN Questions q ON s.QuestionId = q.QuestionId "
                + "LEFT JOIN Lessons l ON s.LessonId = l.LessonId "
                + "WHERE s.SubmissionId = ?";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, submissionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapSubmission(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * FR-TEA-04: Cập nhật chấm điểm và nhận xét của giáo viên
     */
    public boolean updateReview(int submissionId, boolean isCorrect, Double score, String teacherFeedback) {
        String sql = "UPDATE Submissions SET IsReviewed = 1, IsCorrect = ?, Score = ?, TeacherFeedback = ? WHERE SubmissionId = ?";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, isCorrect);
            if (score != null) {
                ps.setDouble(2, score);
            } else {
                ps.setNull(2, java.sql.Types.DECIMAL);
            }
            ps.setString(3, teacherFeedback);
            ps.setInt(4, submissionId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
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

        try {
            double sc = rs.getDouble("Score");
            if (!rs.wasNull()) s.setScore(sc);
        } catch (SQLException ex) {}

        try {
            s.setAiFeedback(rs.getString("AiFeedback"));
        } catch (SQLException ex) {}

        s.setTeacherFeedback(rs.getString("TeacherFeedback"));
        s.setReviewed(rs.getBoolean("IsReviewed"));
        s.setSubmittedAt(rs.getTimestamp("SubmittedAt"));

        try {
            s.setStudentName(rs.getString("StudentName"));
        } catch (SQLException ex) {}
        try {
            s.setStudentEmail(rs.getString("StudentEmail"));
        } catch (SQLException ex) {}
        try {
            s.setQuestionTitle(rs.getString("QuestionTitle"));
        } catch (SQLException ex) {}
        try {
            s.setQuestionContent(rs.getString("QuestionContent"));
        } catch (SQLException ex) {}
        try {
            s.setLessonTitle(rs.getString("LessonTitle"));
        } catch (SQLException ex) {}
        try {
            s.setQuestionAiGenerated(rs.getBoolean("IsAiGenerated"));
        } catch (SQLException ex) {}
        return s;
    }
}
