package com.edututor.controller.teacher;

import com.edututor.dto.PageResult;
import com.edututor.dto.SubmissionView;
import com.edututor.dto.UserView;
import com.edututor.service.SubmissionService;
import com.edututor.service.UserService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

/** Giáo viên theo dõi học sinh và lịch sử làm bài của từng em. */
@Controller
public class TeacherStudentController {

    private static final int PAGE_SIZE = 10;

    private final UserService userService;
    private final SubmissionService submissionService;

    public TeacherStudentController(UserService userService, SubmissionService submissionService) {
        this.userService = userService;
        this.submissionService = submissionService;
    }

    @GetMapping("/teacher/students")
    public String students(@RequestParam(defaultValue = "1") int page, Model model) {
        PageResult<UserView> result = userService.getUsersByRole("STUDENT", page, PAGE_SIZE);
        model.addAttribute("students", result.getItems());
        model.addAttribute("page", result.getPage());
        model.addAttribute("totalPages", result.getTotalPages());
        model.addAttribute("totalRecords", result.getTotalItems());
        return "teacher/students";
    }

    @GetMapping("/teacher/students/history")
    public String history(@RequestParam(defaultValue = "0") int studentId,
                          @RequestParam(defaultValue = "ALL") String type,
                          @RequestParam(defaultValue = "1") int page, Model model) {
        String filter = ("MCQ".equals(type) || "ESSAY".equals(type)) ? type : "ALL";
        PageResult<SubmissionView> result = submissionService.getStudentHistory(studentId, filter, 0, page, PAGE_SIZE);
        model.addAttribute("submissions", result.getItems());
        model.addAttribute("page", result.getPage());
        model.addAttribute("totalPages", result.getTotalPages());
        model.addAttribute("studentId", studentId);
        model.addAttribute("type", filter);
        return "teacher/student-history";
    }
}
