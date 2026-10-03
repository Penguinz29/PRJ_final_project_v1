package com.edututor.controller.student;

import com.edututor.dto.LessonView;
import com.edututor.dto.PageResult;
import com.edututor.dto.SessionUser;
import com.edututor.dto.SubmissionView;
import com.edututor.interceptor.AuthInterceptor;
import com.edututor.service.LessonService;
import com.edututor.service.SubmissionService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.SessionAttribute;

/** UC-STU-06: lịch sử làm bài và tiến độ ôn tập, phân trang 10 bản ghi/trang. */
@Controller
public class StudentHistoryController {

    private static final int PAGE_SIZE = 10;

    private final SubmissionService submissionService;
    private final LessonService lessonService;

    public StudentHistoryController(SubmissionService submissionService, LessonService lessonService) {
        this.submissionService = submissionService;
        this.lessonService = lessonService;
    }

    @GetMapping("/student/history")
    public String history(@RequestParam(defaultValue = "1") int page,
                          @RequestParam(defaultValue = "ALL") String type,
                          @RequestParam(defaultValue = "0") int lessonId,
                          @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user, Model model) {
        String filter = ("MCQ".equals(type) || "ESSAY".equals(type)) ? type : "ALL";
        PageResult<SubmissionView> result = submissionService.getStudentHistory(user.getUserId(), filter, lessonId,
                page, PAGE_SIZE);
        if (lessonId > 0) {
            LessonView lesson = lessonService.getLessonForStudent(lessonId);
            model.addAttribute("lessonFilter", lesson);
        }
        model.addAttribute("lessonId", lessonId > 0 ? lessonId : null);
        model.addAttribute("history", result.getItems());
        model.addAttribute("page", result.getPage());
        model.addAttribute("totalPages", result.getTotalPages());
        model.addAttribute("totalRecords", result.getTotalItems());
        model.addAttribute("type", filter);
        return "student/history";
    }
}
