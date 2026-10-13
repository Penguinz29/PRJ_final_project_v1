package controller.student;

import dto.view.LessonView;
import dto.view.ProgressView;
import dto.view.SessionUser;
import exception.NotFoundException;
import config.AuthInterceptor;
import service.LessonService;
import service.MaterialService;
import service.StatsService;
import service.SubmissionService;
import service.TopicService;
import dto.view.SubmissionView;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.SessionAttribute;

/** Dashboard, danh sách chuyên đề và trang bài giảng của học sinh. */
@Controller
public class StudentController {

    private static final Logger log = LoggerFactory.getLogger(StudentController.class);
    private static final String LAST_LESSON = "STUDENT_LAST_LESSON_ID";

    private final StatsService statsService;
    private final SubmissionService submissionService;
    private final TopicService topicService;
    private final LessonService lessonService;
    private final MaterialService materialService;

    public StudentController(StatsService statsService, SubmissionService submissionService,
                             TopicService topicService, LessonService lessonService,
                             MaterialService materialService) {
        this.statsService = statsService;
        this.submissionService = submissionService;
        this.topicService = topicService;
        this.lessonService = lessonService;
        this.materialService = materialService;
    }

    @GetMapping("/student/dashboard")
    public String dashboard(@SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user, HttpSession session,
                            Model model) {
        model.addAllAttributes(statsService.studentStats(user.getUserId()));
        addRecentLesson(user.getUserId(), session, model);
        return "student/dashboard";
    }

    /** Bài học gần nhất: bài vừa mở xem trong phiên này, nếu chưa có thì bài của lần làm bài gần nhất. */
    private void addRecentLesson(int userId, HttpSession session, Model model) {
        Integer lessonId = (Integer) session.getAttribute(LAST_LESSON);
        if (lessonId == null) {
            List<SubmissionView> recent = submissionService.getRecentAttempts(userId, 1);
            if (!recent.isEmpty()) {
                lessonId = recent.get(0).getLessonId();
            }
        }
        LessonView lesson = lessonId == null ? null : lessonService.getLessonForStudent(lessonId);
        if (lesson == null) {
            return;
        }
        model.addAttribute("recentLesson", lesson);
        try {
            materialService.getByLesson(lessonId).stream()
                    .filter(m -> "YOUTUBE".equals(m.getMaterialType()) || "VIDEO".equals(m.getMaterialType()))
                    .findFirst().ifPresent(m -> model.addAttribute("recentVideo", m));
        } catch (DataAccessException e) {
            log.warn("Không đọc được LessonMaterials: {}", e.getMostSpecificCause().getMessage());
        }
    }

    /** FR-STU-06: tiến độ bóc tách theo từng bài học của một chủ đề (lần làm gần nhất mỗi câu, BR-10). */
    @GetMapping("/student/topics/{topicId}/progress")
    public String topicProgress(@PathVariable int topicId,
                                @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user, Model model) {
        String topicName = statsService.topicName(topicId);
        if (topicName == null) {
            throw new NotFoundException("Chủ đề không tồn tại.");
        }
        List<ProgressView> lessons = statsService.lessonProgress(user.getUserId(), topicId);
        int total = 0;
        int answered = 0;
        int correct = 0;
        for (ProgressView p : lessons) {
            total += p.total();
            answered += p.answered();
            correct += p.correct();
        }
        model.addAttribute("topicName", topicName);
        model.addAttribute("lessonProgress", lessons);
        model.addAttribute("overall", new ProgressView(topicId, topicName, total, answered, correct));
        return "student/progress";
    }

    @GetMapping("/student/topics")
    public String topics(Model model) {
        model.addAttribute("topics", topicService.getAllTopicsWithLessons());
        return "student/topics";
    }

    @GetMapping("/student/lesson")
    public String lesson(@RequestParam(defaultValue = "0") int id, HttpSession session, Model model) {
        LessonView lesson = lessonService.getLessonForStudent(id);
        if (lesson == null) {
            return "redirect:/student/topics";
        }
        model.addAttribute("lesson", lesson);
        session.setAttribute(LAST_LESSON, id);
        // Bài giảng (video / YouTube / link / văn bản). Nếu bảng LessonMaterials chưa được tạo
        // (chưa chạy document/sql/01_schema.sql) thì vẫn hiển thị bài học bình thường.
        try {
            model.addAttribute("materials", materialService.getByLesson(id));
        } catch (DataAccessException e) {
            log.warn("Không đọc được LessonMaterials (đã chạy document/sql/01_schema.sql chưa?): {}",
                    e.getMostSpecificCause().getMessage());
            model.addAttribute("materials", List.of());
        }
        return "student/lesson";
    }
}
