package com.edututor.controller.student;

import com.edututor.dto.LessonView;
import com.edututor.dto.SessionUser;
import com.edututor.interceptor.AuthInterceptor;
import com.edututor.service.LessonService;
import com.edututor.service.MaterialService;
import com.edututor.service.StatsService;
import com.edututor.service.SubmissionService;
import com.edututor.service.TopicService;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.SessionAttribute;

/** Dashboard, danh sách chuyên đề và trang bài giảng của học sinh. */
@Controller
public class StudentController {

    private static final Logger log = LoggerFactory.getLogger(StudentController.class);

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
    public String dashboard(@SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user, Model model) {
        model.addAllAttributes(statsService.studentStats(user.getUserId()));
        model.addAttribute("recentAttempts", submissionService.getRecentAttempts(user.getUserId(), 5));
        return "student/dashboard";
    }

    @GetMapping("/student/topics")
    public String topics(Model model) {
        model.addAttribute("topics", topicService.getAllTopicsWithLessons());
        return "student/topics";
    }

    @GetMapping("/student/lesson")
    public String lesson(@RequestParam(defaultValue = "0") int id, Model model) {
        LessonView lesson = lessonService.getLessonForStudent(id);
        if (lesson == null) {
            return "redirect:/student/topics";
        }
        model.addAttribute("lesson", lesson);
        // Bài giảng (video / YouTube / link / văn bản). Nếu bảng LessonMaterials chưa được tạo
        // (chưa chạy document/sql/06_*.sql) thì vẫn hiển thị bài học bình thường.
        try {
            model.addAttribute("materials", materialService.getByLesson(id));
        } catch (DataAccessException e) {
            log.warn("Không đọc được LessonMaterials (đã chạy document/sql/06_target_schema_additions.sql chưa?): {}",
                    e.getMostSpecificCause().getMessage());
            model.addAttribute("materials", List.of());
        }
        return "student/lesson";
    }
}
