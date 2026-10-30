

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import config.RootConfig;
import dto.view.QuizQuestionView;
import service.LessonService;
import service.QuestionService;
import service.StatsService;
import service.SubmissionService;
import service.TopicService;
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
 * Cần SQL Server đã nạp document/sql/MathTutorDB.sql (xem EduTutorIT để biết cách chạy).
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
                        + "IsCorrect, FinalScore, IsReviewed) VALUES (4, 1, " + (i % 2 + 1) + ", 'MCQ', 'qc', 1, 10, 1)");
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
        // 10 Entity (Users, Topics, Lessons, LessonMaterials, Questions, QuestionOptions, Submissions, AiConfigs,
        // TutorSessions, TutorMessages)
        assertEquals(10, ctx.getBean(EntityManagerFactory.class).getMetamodel().getEntities().size());
    }

    @Test
    void quizUsesOneQueryForQuestionsAndOneForAllOptions() {
        SubmissionService service = ctx.getBean(SubmissionService.class);
        AtomicReference<List<QuizQuestionView>> result = new AtomicReference<>();
        assertEquals(2, statements(() -> result.set(service.getQuizQuestions(1, 0, 10))));
        assertFalse(result.get().isEmpty());
        assertTrue(result.get().stream().allMatch(q -> q.getOptions().size() == 4));
    }

    /** Danh sách phân trang: Spring Data bỏ câu COUNT khi trang đầu chưa đầy, nên chỉ cần "không quá" giới hạn. */
    private void assertAtMost(long max, long actual, String message) {
        assertTrue(actual <= max, message + " (thực tế " + actual + " câu SQL, tối đa " + max + ")");
    }

    @Test
    void lessonMaterialsLoadInOneQuery() {
        assertEquals(1, statements(() -> ctx.getBean(service.MaterialService.class).getByLesson(1)),
                "bài giảng + người tạo trong một câu SQL (EntityGraph)");
    }

    @Test
    void listScreensDoNotRunOneQueryPerRow() {
        assertAtMost(2, statements(() -> ctx.getBean(SubmissionService.class).getStudentHistory(4, "ALL", 0, 1, 10)),
                "lịch sử: 1 câu lấy trang (đã JOIN question/lesson/student) + 1 câu COUNT");
        assertAtMost(4, statements(() -> ctx.getBean(QuestionService.class).search(0, 0, "", 0, 1, 10)),
                "ngân hàng câu hỏi: trang + COUNT + 2 truy vấn IN dự báo nút Xóa (bài nộp, phiên gia sư)");
        assertEquals(4, statements(() -> ctx.getBean(LessonService.class).getAllLessons()),
                "bài học: danh sách + IN số câu hỏi + 2 truy vấn IN dự báo nút Xóa (bài nộp, phiên gia sư)");
        assertEquals(2, statements(() -> ctx.getBean(TopicService.class).getAllTopicsWithLessons()),
                "chủ đề kèm bài học: 2 truy vấn (chủ đề, rồi bài học bằng IN)");
        assertAtMost(2, statements(() -> ctx.getBean(SubmissionService.class).getEssaySubmissions(false, 1, 10)),
                "bài tự luận chờ duyệt: trang + COUNT");
    }

    private static long sql(String query) throws Exception {
        try (Connection c = db(); Statement st = c.createStatement(); java.sql.ResultSet rs = st.executeQuery(query)) {
            rs.next();
            return rs.getLong(1);
        }
    }

    /** FR-ADM-08: mọi số liệu dashboard Admin khớp với dữ liệu đếm trực tiếp trong CSDL; số câu SQL cố định. */
    @Test
    @SuppressWarnings("unchecked")
    void adminDashboardStatsMatchDatabase() throws Exception {
        StatsService service = ctx.getBean(StatsService.class);
        AtomicReference<java.util.Map<String, Object>> ref = new AtomicReference<>();
        long queries = statements(() -> ref.set(service.adminStats()));
        java.util.Map<String, Object> m = ref.get();

        assertEquals(sql("SELECT COUNT(*) FROM Users"), m.get("totalUsers"));
        assertEquals(sql("SELECT COUNT(*) FROM Users WHERE [Role] = 'TEACHER'"), m.get("totalTeachers"));
        assertEquals(sql("SELECT COUNT(*) FROM Users WHERE [Role] = 'STUDENT'"), m.get("totalStudents"));
        assertEquals(sql("SELECT COUNT(*) FROM Questions WHERE IsActive = 1"), m.get("totalQuestions"));
        assertEquals(sql("SELECT COUNT(*) FROM Questions WHERE IsActive = 1 AND IsAiGenerated = 1"), m.get("aiQuestions"));
        assertEquals(sql("SELECT COUNT(*) FROM TutorSessions"), m.get("tutorSessions"));
        assertEquals(sql("SELECT COUNT(*) FROM Submissions WHERE QuestionType = 'ESSAY'"), m.get("aiGradedEssays"));
        assertEquals(sql("SELECT COUNT(*) FROM Submissions WHERE QuestionType = 'ESSAY' AND [Status] = 'AI_GRADED'"),
                m.get("pendingEssays"));

        // Vai trò × trạng thái: đủ 3 vai trò, từng ô khớp SQL
        List<java.util.Map<String, Object>> rows = (List<java.util.Map<String, Object>>) m.get("userRows");
        assertEquals(3, rows.size());
        for (java.util.Map<String, Object> r : rows) {
            for (String status : new String[]{"ACTIVE", "SUSPENDED", "INACTIVE"}) {
                assertEquals(sql("SELECT COUNT(*) FROM Users WHERE [Role] = '" + r.get("role") + "' AND [Status] = '"
                        + status + "'"), r.get(status), r.get("role") + "/" + status);
            }
        }

        // 7 ngày gần nhất: đủ 7 cột (ngày trống = 0), hôm nay ở cuối, tổng khớp SQL
        List<java.util.Map<String, Object>> days = (List<java.util.Map<String, Object>>) m.get("weekDays");
        assertEquals(7, days.size());
        assertEquals(java.time.LocalDate.now().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM")),
                days.get(6).get("label"));
        long weekSql = sql("SELECT COUNT(*) FROM Submissions "
                + "WHERE SubmittedAt >= DATEADD(DAY, -6, CAST(SYSDATETIME() AS DATE))");
        assertEquals(weekSql, ((Number) m.get("weekTotal")).longValue());
        assertTrue(((Number) m.get("weekTotal")).longValue() >= 5, "có 5 bài 'qc' vừa chèn hôm nay");

        // Mỗi nhóm số liệu là một truy vấn gộp: số câu SQL cố định, không phụ thuộc lượng dữ liệu
        assertTrue(queries <= 9, "dashboard Admin: " + queries + " câu SQL");
    }
}
