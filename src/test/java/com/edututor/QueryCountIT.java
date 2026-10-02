package com.edututor;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.edututor.config.RootConfig;
import com.edututor.dto.QuizQuestionView;
import com.edututor.service.LessonService;
import com.edututor.service.QuestionService;
import com.edututor.service.SubmissionService;
import com.edututor.service.TopicService;
import com.edututor.service.UserService;
import jakarta.persistence.EntityManagerFactory;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;
import java.util.List;
import java.util.concurrent.atomic.AtomicReference;
import org.hibernate.SessionFactory;
import org.hibernate.stat.Statistics;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfSystemProperty;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

/**
 * TC-DB-02 / TC-DB-03: khởi động Root context với {@code hibernate.hbm2ddl.auto=none} (Hibernate nạp đủ Entity,
 * không lỗi mapping) và kiểm tra các màn hình danh sách KHÔNG bị N+1: số câu SQL cố định, không tăng theo số dòng.
 * Cần SQL Server đã nạp document/sql/01..05 (xem EduTutorIT để biết cách chạy).
 */
@EnabledIfSystemProperty(named = "it.db.url", matches = ".+")
class QueryCountIT {

    static AnnotationConfigApplicationContext ctx;
    static Statistics stats;

    static Connection db() throws Exception {
        return DriverManager.getConnection(System.getProperty("it.db.url"),
                System.getProperty("it.db.user", "sa"), System.getProperty("it.db.pass", "123"));
    }

    @BeforeAll
    static void start() throws Exception {
        System.setProperty("DB_URL", System.getProperty("it.db.url"));
        System.setProperty("DB_USER", System.getProperty("it.db.user", "sa"));
        System.setProperty("DB_PASS", System.getProperty("it.db.pass", "123"));
        System.setProperty("UPLOAD_DIR", System.getProperty("java.io.tmpdir"));
        ctx = new AnnotationConfigApplicationContext(RootConfig.class);
        SessionFactory sf = ctx.getBean(EntityManagerFactory.class).unwrap(SessionFactory.class);
        stats = sf.getStatistics();
        stats.setStatisticsEnabled(true);

        // Thêm vài bài làm trắc nghiệm của học sinh 4 để danh sách lịch sử có nhiều dòng
        try (Connection c = db(); Statement st = c.createStatement()) {
            st.executeUpdate("DELETE FROM Submissions WHERE StudentAnswer = 'qc'");
            for (int i = 0; i < 5; i++) {
                st.executeUpdate("INSERT INTO Submissions (StudentId, LessonId, QuestionId, QuestionType, StudentAnswer, "
                        + "IsCorrect, Score, IsReviewed) VALUES (4, 1, " + (i % 2 + 1) + ", 'MCQ', 'qc', 1, 10, 1)");
            }
        }
    }

    @AfterAll
    static void stop() throws Exception {
        try (Connection c = db(); Statement st = c.createStatement()) {
            st.executeUpdate("DELETE FROM Submissions WHERE StudentAnswer = 'qc'");
        }
        if (ctx != null) {
            ctx.close();
        }
    }

    /** Số câu SQL Hibernate gửi đi khi chạy {@code action}. */
    private long statements(Runnable action) {
        stats.clear();
        action.run();
        return stats.getPrepareStatementCount();
    }

    @Test
    void entityManagerFactoryStartsWithSchemaManagementDisabled() {
        assertTrue(ctx.getBean(EntityManagerFactory.class).isOpen());
        // 9 Entity khớp 9 bảng của CSDL hiện có (Users, Topics, Lessons, Questions, QuestionOptions, Submissions, AiConfigs, TutorSessions, TutorMessages)
        assertEquals(9, ctx.getBean(EntityManagerFactory.class).getMetamodel().getEntities().size());
    }

    @Test
    void quizUsesOneQueryForQuestionsAndOneForAllOptions() {
        SubmissionService service = ctx.getBean(SubmissionService.class);
        AtomicReference<List<QuizQuestionView>> result = new AtomicReference<>();
        assertEquals(2, statements(() -> result.set(service.getQuizQuestions(1))));
        assertFalse(result.get().isEmpty());
        assertTrue(result.get().stream().allMatch(q -> q.getOptions().size() == 4));
    }

    /** Danh sách phân trang: Spring Data bỏ câu COUNT khi trang đầu chưa đầy, nên chỉ cần "không quá" giới hạn. */
    private void assertAtMost(long max, long actual, String message) {
        assertTrue(actual <= max, message + " (thực tế " + actual + " câu SQL, tối đa " + max + ")");
    }

    @Test
    void listScreensDoNotRunOneQueryPerRow() {
        assertAtMost(2, statements(() -> ctx.getBean(SubmissionService.class).getStudentHistory(4, "ALL", 1, 10)),
                "lịch sử: 1 câu lấy trang (đã JOIN question/lesson/student) + 1 câu COUNT");
        assertAtMost(2, statements(() -> ctx.getBean(QuestionService.class).search(0, 0, "", 0, 1, 10)),
                "ngân hàng câu hỏi: trang + COUNT");
        assertEquals(2, statements(() -> ctx.getBean(LessonService.class).getAllLessons()),
                "bài học: danh sách + một truy vấn gộp số câu hỏi theo IN");
        assertEquals(2, statements(() -> ctx.getBean(TopicService.class).getAllTopicsWithLessons()),
                "chủ đề kèm bài học: 2 truy vấn (chủ đề, rồi bài học bằng IN)");
        assertAtMost(3, statements(() -> ctx.getBean(UserService.class).getUsersByRole("STUDENT", 1, 10)),
                "học sinh: trang + COUNT + tên giáo viên bằng IN");
        assertAtMost(2, statements(() -> ctx.getBean(SubmissionService.class).getEssaySubmissions(false, 1, 10)),
                "bài tự luận chờ duyệt: trang + COUNT");
    }
}
