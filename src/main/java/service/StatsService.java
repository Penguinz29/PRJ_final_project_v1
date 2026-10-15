package service;

import dto.view.PageResult;
import dto.view.ProgressView;
import dto.view.QuestionResultView;
import dto.view.StreakView;
import model.QuestionType;
import model.Role;
import model.SubmissionStatus;
import model.UserStatus;
import repository.DailyCount;
import repository.LessonRepository;
import repository.ProgressRow;
import repository.QuestionRepository;
import repository.QuestionResultRow;
import repository.ResultGroupRow;
import repository.RoleStatusCount;
import repository.SubmissionRepository;
import repository.TopicRepository;
import repository.TutorSessionRepository;
import repository.UserRepository;
import util.HtmlSanitizer;
import util.Pager;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.EnumMap;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Số liệu thống kê cho các trang dashboard. */
@Service
@Transactional(readOnly = true)
public class StatsService {

    private final UserRepository users;
    private final TopicRepository topics;
    private final LessonRepository lessons;
    private final QuestionRepository questions;
    private final SubmissionRepository submissions;
    private final TutorSessionRepository tutorSessions;

    public StatsService(UserRepository users, TopicRepository topics, LessonRepository lessons,
            QuestionRepository questions, SubmissionRepository submissions,
            TutorSessionRepository tutorSessions) {
        this.users = users;
        this.topics = topics;
        this.lessons = lessons;
        this.questions = questions;
        this.submissions = submissions;
        this.tutorSessions = tutorSessions;
    }

    /**
     * UC-ADM-08 (FR-ADM-08): số liệu lấy từ dữ liệu lưu bền vững trong CSDL (không
     * dùng bộ đếm trong RAM như
     * RateLimiter nên không mất khi khởi động lại). Mỗi nhóm số liệu là một truy
     * vấn gộp.
     */
    public Map<String, Object> adminStats() {
        Map<String, Object> m = new LinkedHashMap<>();

        // Người dùng theo vai trò × trạng thái (một GROUP BY), đủ ô kể cả ô bằng 0
        Map<Role, Map<UserStatus, Long>> byRole = new EnumMap<>(Role.class);
        for (Role r : Role.values()) {
            Map<UserStatus, Long> row = new EnumMap<>(UserStatus.class);
            for (UserStatus s : UserStatus.values()) {
                row.put(s, 0L);
            }
            byRole.put(r, row);
        }
        for (RoleStatusCount c : users.countByRoleAndStatusGrouped()) {
            byRole.get(c.getRole()).put(c.getStatus(), c.getTotal());
        }
        List<Map<String, Object>> userRows = new ArrayList<>();
        long allUsers = 0;
        for (Role r : Role.values()) {
            Map<String, Object> row = new LinkedHashMap<>();
            long sum = 0;
            row.put("role", r.name());
            for (UserStatus s : UserStatus.values()) {
                long n = byRole.get(r).get(s);
                row.put(s.name(), n);
                sum += n;
            }
            row.put("total", sum);
            allUsers += sum;
            userRows.add(row);
        }
        m.put("userRows", userRows);
        m.put("totalUsers", allUsers);
        m.put("totalTeachers", byRole.get(Role.TEACHER).values().stream().mapToLong(Long::longValue).sum());
        m.put("totalStudents", byRole.get(Role.STUDENT).values().stream().mapToLong(Long::longValue).sum());

        // Nội dung
        m.put("totalTopics", topics.countByActiveTrue());
        m.put("totalQuestions", questions.countByActiveTrue());
        m.put("aiQuestions", questions.countByActiveTrueAndAiGeneratedTrue());

        // AI và bài làm
        m.put("tutorSessions", tutorSessions.count());
        m.put("aiGradedEssays", submissions.countByQuestionType(QuestionType.ESSAY));
        m.put("pendingEssays",
                submissions.countByQuestionTypeAndStatus(QuestionType.ESSAY, SubmissionStatus.AI_GRADED));

        // Lượt làm bài 7 ngày gần nhất: điền đủ 7 ngày (ngày không có lượt nào = 0)
        Map<String, Integer> perDay = new HashMap<>();
        for (DailyCount d : submissions.countLastSevenDays()) {
            perDay.put(d.getDay(), d.getTotal() == null ? 0 : d.getTotal());
        }
        LocalDate today = LocalDate.now();
        List<Map<String, Object>> days = new ArrayList<>();
        int weekTotal = 0;
        int max = 0;
        for (int i = 6; i >= 0; i--) {
            LocalDate day = today.minusDays(i);
            int n = perDay.getOrDefault(day.toString(), 0);
            Map<String, Object> d = new LinkedHashMap<>();
            d.put("label", day.format(DateTimeFormatter.ofPattern("dd/MM")));
            d.put("total", n);
            days.add(d);
            weekTotal += n;
            max = Math.max(max, n);
        }
        for (Map<String, Object> d : days) {
            int n = (Integer) d.get("total");
            d.put("pct", max == 0 ? 0 : Math.round(n * 100f / max));
        }
        m.put("weekDays", days);
        m.put("weekTotal", weekTotal);
        return m;
    }

    public Map<String, Object> teacherStats(int teacherId) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("myTopics", (int) topics.countByTeacher_UserIdAndActiveTrue(teacherId));
        m.put("myLessons", (int) lessons.countByTopic_Teacher_UserIdAndActiveTrue(teacherId));
        m.put("myStudents", (int) users.countByRole(Role.STUDENT));
        m.put("pendingSubmissions", (int) submissions.countByQuestionTypeAndReviewed(QuestionType.ESSAY, false));
        return m;
    }

    /**
     * UC-TEA-08: kết quả trắc nghiệm theo câu hỏi của bài học, phân trang ở CSDL
     * (VAL-22).
     */
    public PageResult<QuestionResultView> questionResults(int lessonId, int page, int size) {
        return PageResult.of(submissions.findQuestionResults(lessonId, Pager.pageRequest(page, size, Sort.unsorted())),
                StatsService::toResultView);
    }

    /** Dòng tổng hợp cả bài học. */
    public QuestionResultView lessonResultSummary(int lessonId) {
        return toResultView(submissions.lessonResultSummary(lessonId));
    }

    /** Admin: thống kê bài làm theo từng chủ đề. */
    public List<ResultGroupRow> topicResultGroups() {
        return submissions.topicResultGroups();
    }

    /** Admin: thống kê bài làm theo từng bài giảng của một chủ đề. */
    public List<ResultGroupRow> lessonResultGroups(int topicId) {
        return submissions.lessonResultGroups(topicId);
    }

    private static QuestionResultView toResultView(QuestionResultRow r) {
        Double pct = r.getCorrectPct() == null ? null : Math.round(r.getCorrectPct() * 10) / 10.0;
        Double avg = pct == null ? null : Math.round(pct * 10) / 100.0; // = correct_pct / 10 (33.3% → 3.33)
        return new QuestionResultView(r.getQuestionId() == null ? 0 : r.getQuestionId(), r.getContent(),
                r.getLevel() == null ? 0 : r.getLevel(), r.getAttempts() == null ? 0 : r.getAttempts(),
                r.getStudents() == null ? 0 : r.getStudents(), pct, avg);
    }

    /**
     * Dashboard học sinh (FR-STU-06): tổng hợp tính theo lần làm gần nhất của mỗi
     * câu (BR-10), cộng dồn từ tiến độ
     * từng chủ đề nên không chạy thêm truy vấn đếm riêng.
     */
    public Map<String, Object> studentStats(int studentId) {
        List<ProgressView> progress = topicProgress(studentId);
        int total = 0;
        int answered = 0;
        int correct = 0;
        for (ProgressView p : progress) {
            total += p.total();
            answered += p.answered();
            correct += p.correct();
        }
        ProgressView overall = new ProgressView(0, "", total, answered, correct);
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("totalTopics", progress.size()); // chỉ chuyên đề đang hoạt động (đã xóa thì học sinh không thấy)
        m.put("topicProgress", progress);
        m.put("overall", overall);
        Double essayAvg = submissions.latestEssayAverage(studentId);
        m.put("essayAverage", essayAvg == null ? null : Math.round(essayAvg * 100) / 100.0);
        
        m.put("streakData", studentStreak(studentId));
        return m;
    }

    public StreakView studentStreak(int studentId) {
        List<java.sql.Date> activeDates = submissions.findAllActiveDatesDesc(studentId);
        
        LocalDate today = LocalDate.now();
        int currentYear = today.getYear();
        int currentMonth = today.getMonthValue();
        
        Set<Integer> activeDaysInMonth = new HashSet<>();
        int currentStreak = 0;
        
        if (!activeDates.isEmpty()) {
            LocalDate lastActive = activeDates.get(0).toLocalDate();
            if (lastActive.equals(today) || lastActive.equals(today.minusDays(1))) {
                LocalDate expected = lastActive;
                for (java.sql.Date sqlDate : activeDates) {
                    LocalDate d = sqlDate.toLocalDate();
                    if (d.equals(expected)) {
                        currentStreak++;
                        expected = expected.minusDays(1);
                    } else {
                        break;
                    }
                }
            }
            
            for (java.sql.Date sqlDate : activeDates) {
                LocalDate d = sqlDate.toLocalDate();
                if (d.getYear() == currentYear && d.getMonthValue() == currentMonth) {
                    activeDaysInMonth.add(d.getDayOfMonth());
                }
            }
        }
        
        int emptyOffsetCells = LocalDate.of(currentYear, currentMonth, 1).getDayOfWeek().getValue() - 1;
        int daysInMonth = today.lengthOfMonth();
        int todayDayOfMonth = today.getDayOfMonth();
        
        return new StreakView(currentStreak, activeDaysInMonth.size(), currentYear, currentMonth, activeDaysInMonth, emptyOffsetCells, daysInMonth, todayDayOfMonth);
    }

    /** Tiến độ theo từng chủ đề (UC-STU-06). */
    public List<ProgressView> topicProgress(int studentId) {
        return submissions.topicProgress(studentId).stream().map(StatsService::toProgressView).toList();
    }

    /** Tiến độ theo từng bài học của một chủ đề (UC-STU-06). */
    public List<ProgressView> lessonProgress(int studentId, int topicId) {
        return submissions.lessonProgress(studentId, topicId).stream().map(StatsService::toProgressView).toList();
    }

    /**
     * Tên chủ đề cho trang tiến độ (kể cả chủ đề đã xóa mềm); null nếu không tồn
     * tại.
     */
    public String topicName(int topicId) {
        return topics.findById(topicId).map(t -> HtmlSanitizer.toPlainText(t.getTopicName())).orElse(null);
    }

    private static ProgressView toProgressView(ProgressRow r) {
        return new ProgressView(r.getId(), r.getName(), nz(r.getTotal()), nz(r.getAnswered()), nz(r.getCorrect()));
    }

    private static int nz(Integer v) {
        return v == null ? 0 : v;
    }
}
