package repository;

import model.QuestionType;
import model.Submission;
import model.SubmissionStatus;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

/**
 * Bảng Submissions: bài làm trắc nghiệm / tự luận. Quan hệ to-one nạp
 * bằng @EntityGraph (không N+1).
 */
public interface SubmissionRepository extends JpaRepository<Submission, Integer> {

        @EntityGraph(attributePaths = { "student", "question", "lesson", "reviewedBy" })
        Page<Submission> findByStudent_UserId(Integer studentId, Pageable pageable);

        @EntityGraph(attributePaths = { "student", "question", "lesson", "reviewedBy" })
        Page<Submission> findByStudent_UserIdAndQuestionType(Integer studentId, QuestionType type, Pageable pageable);

        /** Bài tự luận theo trạng thái đã duyệt hay chưa (phân trang). */
        @EntityGraph(attributePaths = { "student", "question", "lesson", "reviewedBy" })
        Page<Submission> findByQuestionTypeAndReviewed(QuestionType type, boolean reviewed, Pageable pageable);

        @EntityGraph(attributePaths = { "student", "question", "lesson", "reviewedBy" })
        Page<Submission> findByQuestionType(QuestionType type, Pageable pageable);

        @EntityGraph(attributePaths = { "student", "question", "lesson", "reviewedBy" })
        Optional<Submission> findWithDetailsBySubmissionId(Integer submissionId);

        @EntityGraph(attributePaths = { "student" })
        Optional<Submission> findByEssayImagePath(String essayImagePath);

        long countByQuestionTypeAndReviewed(QuestionType type, boolean reviewed);

        long countByQuestion_QuestionId(Integer questionId);

        /**
         * UC-ADM-08: số bài theo loại (ESSAY = đã chấm qua AI) và theo loại + trạng
         * thái (AI_GRADED = chờ duyệt).
         */
        long countByQuestionType(QuestionType type);

        long countByQuestionTypeAndStatus(QuestionType type, SubmissionStatus status);

        /**
         * UC-ADM-08: lượt làm bài theo ngày trong 7 ngày gần nhất (kể cả hôm nay); ngày
         * không có lượt nào bị thiếu.
         */
        @Query(value = "SELECT CONVERT(VARCHAR(10), CAST(s.SubmittedAt AS DATE), 23) AS day, COUNT(*) AS total "
                        + "FROM Submissions s WHERE s.SubmittedAt >= DATEADD(DAY, -6, CAST(SYSDATETIME() AS DATE)) "
                        + "GROUP BY CAST(s.SubmittedAt AS DATE) ORDER BY CAST(s.SubmittedAt AS DATE)", nativeQuery = true)
        List<DailyCount> countLastSevenDays();

        /**
         * Câu hỏi nào trong danh sách đã có bài nộp (dự báo xóa mềm ở trang quản lý,
         * một truy vấn IN).
         */
        @Query("select distinct s.question.questionId from Submission s where s.question.questionId in :ids")
        List<Integer> findQuestionIdsWithSubmissions(@Param("ids") Collection<Integer> ids);

        /** Bài học nào trong danh sách đã có bài nộp cho câu hỏi của nó. */
        @Query("select distinct s.question.lesson.lessonId from Submission s where s.question.lesson.lessonId in :ids")
        List<Integer> findLessonIdsWithSubmissions(@Param("ids") Collection<Integer> ids);

        /**
         * Có bài nộp nào cho các câu hỏi của bài học không (quyết định xóa cứng hay xóa
         * mềm bài học, BR-05).
         */
        boolean existsByQuestion_Lesson_LessonId(Integer lessonId);

        /** Số bài học đã luyện trắc nghiệm của học sinh. */

        boolean existsByStudent_UserId(Integer studentId);

        /**
         * Người dùng đã duyệt bài tự luận nào chưa (khóa ngoại Submissions.ReviewedBy;
         * BR-06).
         */
        boolean existsByReviewedBy_UserId(Integer reviewerId);

        // ---------- UC-STU-06 / BR-10: tiến độ tính theo lần làm GẦN NHẤT của mỗi câu
        // (CTE ROW_NUMBER()) ----------
        // Chủ đề / bài học giáo viên đã xóa (IsActive = 0) không hiện với học sinh.

        /** Tiến độ trắc nghiệm theo từng chủ đề (kể cả chủ đề chưa làm câu nào). */
        @Query(value = "WITH latest AS ( SELECT s.QuestionId, s.IsCorrect, ROW_NUMBER() OVER (PARTITION BY s.QuestionId ORDER BY s.SubmittedAt DESC, s.SubmissionId DESC) AS rn FROM Submissions s WHERE s.StudentId = :studentId AND s.QuestionType = 'MCQ'), "
                        + "done AS (SELECT l.TopicId AS id, COUNT(*) AS answered, "
                        + "                SUM(CASE WHEN lt.IsCorrect = 1 THEN 1 ELSE 0 END) AS correct "
                        + "         FROM latest lt JOIN Questions q ON q.QuestionId = lt.QuestionId "
                        + "         JOIN Lessons l ON l.LessonId = q.LessonId WHERE lt.rn = 1 GROUP BY l.TopicId), "
                        + "total AS (SELECT l.TopicId AS id, COUNT(*) AS total FROM Questions q "
                        + "          JOIN Lessons l ON l.LessonId = q.LessonId WHERE q.QuestionType = 'MCQ' GROUP BY l.TopicId) "
                        + "SELECT t.TopicId AS id, t.TopicName AS name, COALESCE(tt.total, 0) AS total, "
                        + "       COALESCE(d.answered, 0) AS answered, COALESCE(d.correct, 0) AS correct "
                        + "FROM Topics t LEFT JOIN total tt ON tt.id = t.TopicId LEFT JOIN done d ON d.id = t.TopicId WHERE t.IsActive = 1 "
                        + "ORDER BY t.CreatedAt DESC, t.TopicId DESC", nativeQuery = true)
        List<ProgressRow> topicProgress(@Param("studentId") Integer studentId);

        /** Tiến độ trắc nghiệm theo từng bài học của một chủ đề. */
        @Query(value = "WITH latest AS ( SELECT s.QuestionId, s.IsCorrect, ROW_NUMBER() OVER (PARTITION BY s.QuestionId ORDER BY s.SubmittedAt DESC, s.SubmissionId DESC) AS rn FROM Submissions s WHERE s.StudentId = :studentId AND s.QuestionType = 'MCQ'), "
                        + "done AS (SELECT q.LessonId AS id, COUNT(*) AS answered, "
                        + "                SUM(CASE WHEN lt.IsCorrect = 1 THEN 1 ELSE 0 END) AS correct "
                        + "         FROM latest lt JOIN Questions q ON q.QuestionId = lt.QuestionId "
                        + "         WHERE lt.rn = 1 GROUP BY q.LessonId), "
                        + "total AS (SELECT q.LessonId AS id, COUNT(*) AS total FROM Questions q "
                        + "          WHERE q.QuestionType = 'MCQ' GROUP BY q.LessonId) "
                        + "SELECT l.LessonId AS id, l.Title AS name, COALESCE(tt.total, 0) AS total, "
                        + "       COALESCE(d.answered, 0) AS answered, COALESCE(d.correct, 0) AS correct "
                        + "FROM Lessons l LEFT JOIN total tt ON tt.id = l.LessonId LEFT JOIN done d ON d.id = l.LessonId "
                        + "WHERE l.TopicId = :topicId AND l.IsActive = 1 ORDER BY l.DisplayOrder ASC, l.LessonId ASC", nativeQuery = true)
        List<ProgressRow> lessonProgress(@Param("studentId") Integer studentId, @Param("topicId") Integer topicId);

        /**
         * Điểm trung bình tự luận (thang 10): final_score của lần nộp gần nhất mỗi câu;
         * null nếu chưa có.
         */
        @Query(value = "WITH latest AS ( "
                        + "SELECT s.FinalScore, ROW_NUMBER() OVER (PARTITION BY s.QuestionId "
                        + "ORDER BY s.SubmittedAt DESC, s.SubmissionId DESC) AS rn "
                        + "FROM Submissions s WHERE s.StudentId = :studentId AND s.QuestionType = 'ESSAY' AND s.FinalScore IS NOT NULL) "
                        + "SELECT AVG(CAST(FinalScore AS FLOAT)) FROM latest WHERE rn = 1", nativeQuery = true)
        Double latestEssayAverage(@Param("studentId") Integer studentId);

        // ---------- Lịch sử lọc theo bài học (UC-STU-06) ----------

        @EntityGraph(attributePaths = { "student", "question", "lesson", "reviewedBy" })
        Page<Submission> findByStudent_UserIdAndQuestion_Lesson_LessonId(Integer studentId, Integer lessonId,
                        Pageable pageable);

        @EntityGraph(attributePaths = { "student", "question", "lesson", "reviewedBy" })
        Page<Submission> findByStudent_UserIdAndQuestionTypeAndQuestion_Lesson_LessonId(Integer studentId,
                        QuestionType type,
                        Integer lessonId,
                        Pageable pageable);

        /**
         * UC-TEA-08: thống kê trắc nghiệm theo câu hỏi của một bài học (chỉ câu đang
         * hoạt động). Số liệu bài nộp gộp
         * trong subquery theo QuestionId rồi mới JOIN nội dung câu hỏi (SQL Server
         * không GROUP BY được NVARCHAR(MAX)).
         * Câu tỉ lệ đúng thấp nhất lên đầu, câu chưa ai làm xuống cuối. Tham số có tên,
         * không nối chuỗi.
         */
        @Query(value = "SELECT q.QuestionId AS questionId, q.Content AS content, q.[Level] AS level, "
                        + "COALESCE(st.attempts, 0) AS attempts, COALESCE(st.students, 0) AS students, st.correctPct AS correctPct "
                        + "FROM Questions q "
                        + "LEFT JOIN (SELECT s.QuestionId, COUNT(*) AS attempts, COUNT(DISTINCT s.StudentId) AS students, "
                        + "                  AVG(CAST(s.IsCorrect AS FLOAT)) * 100 AS correctPct "
                        + "           FROM Submissions s WHERE s.QuestionType = 'MCQ' GROUP BY s.QuestionId) st "
                        + "       ON st.QuestionId = q.QuestionId "
                        + "WHERE q.LessonId = :lessonId AND q.QuestionType = 'MCQ' AND q.IsActive = 1 "
                        + "ORDER BY CASE WHEN st.correctPct IS NULL THEN 1 ELSE 0 END, st.correctPct ASC, q.QuestionId ASC", countQuery = "SELECT COUNT(*) FROM Questions q "
                                        + "WHERE q.LessonId = :lessonId AND q.QuestionType = 'MCQ' AND q.IsActive = 1", nativeQuery = true)
        Page<QuestionResultRow> findQuestionResults(@Param("lessonId") Integer lessonId, Pageable pageable);

        /**
         * Tổng hợp cả bài học (dòng tóm tắt phía trên bảng): số lượt làm, số học sinh,
         * tỉ lệ đúng chung.
         */
        @Query(value = "SELECT 0 AS questionId, NULL AS content, 0 AS level, COUNT(*) AS attempts, "
                        + "COUNT(DISTINCT s.StudentId) AS students, AVG(CAST(s.IsCorrect AS FLOAT)) * 100 AS correctPct "
                        + "FROM Submissions s JOIN Questions q ON q.QuestionId = s.QuestionId "
                        + "WHERE q.LessonId = :lessonId AND s.QuestionType = 'MCQ' AND q.IsActive = 1", nativeQuery = true)
        QuestionResultRow lessonResultSummary(@Param("lessonId") Integer lessonId);

        /**
         * Các lần làm SAI một câu của học sinh, mới nhất trước (điều kiện mở gia sư chế
         * độ QUESTION, UC-TUT-01).
         */
        @Query("select s from Submission s where s.student.userId = :studentId and s.question.questionId = :questionId "
                        + "and s.isCorrect = false order by s.submittedAt desc, s.submissionId desc")
        List<Submission> findWrongAttempts(@Param("studentId") Integer studentId,
                        @Param("questionId") Integer questionId,
                        Pageable pageable);

        /** Lấy tất cả các ngày mà học sinh có bài nộp (distinct), xếp giảm dần. */
        @Query(value = "SELECT DISTINCT CAST(SubmittedAt AS DATE) "
                + "FROM Submissions WHERE StudentId = :studentId "
                + "ORDER BY CAST(SubmittedAt AS DATE) DESC",
                nativeQuery = true)
        List<java.sql.Date> findAllActiveDatesDesc(@Param("studentId") Integer studentId);
}
