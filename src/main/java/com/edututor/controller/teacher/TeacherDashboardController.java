package com.edututor.controller.teacher;

import com.edututor.dto.SessionUser;
import com.edututor.interceptor.AuthInterceptor;
import com.edututor.service.StatsService;
import com.edututor.service.SubmissionService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.SessionAttribute;

@Controller
public class TeacherDashboardController {

    private final StatsService statsService;
    private final SubmissionService submissionService;

    public TeacherDashboardController(StatsService statsService, SubmissionService submissionService) {
        this.statsService = statsService;
        this.submissionService = submissionService;
    }

    @GetMapping("/teacher/dashboard")
    public String dashboard(@SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user, Model model) {
        model.addAllAttributes(statsService.teacherStats(user.getUserId()));
        model.addAttribute("recentSubmissions", submissionService.getRecentEssays(5));
        return "teacher/dashboard";
    }
}
