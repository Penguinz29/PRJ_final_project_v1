package com.edututor.controller.student;

import com.edututor.dto.LessonView;
import com.edututor.dto.SessionUser;
import com.edututor.interceptor.AuthInterceptor;
import com.edututor.service.LessonService;
import com.edututor.service.StatsService;
import com.edututor.service.SubmissionService;
import com.edututor.service.TopicService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.SessionAttribute;

/** Dashboard, danh sách chuyên đề và trang bài giảng của học sinh. */
@Controller
public class StudentController {

    private final StatsService statsService;
    private final SubmissionService submissionService;
    private final TopicService topicService;
    private final LessonService lessonService;

    public StudentController(StatsService statsService, SubmissionService submissionService,
                             TopicService topicService, LessonService lessonService) {
        this.statsService = statsService;
        this.submissionService = submissionService;
        this.topicService = topicService;
        this.lessonService = lessonService;
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
        LessonView lesson = lessonService.getLessonById(id);
        if (lesson == null) {
            return "redirect:/student/topics";
        }
        model.addAttribute("lesson", lesson);
        return "student/lesson";
    }
}
