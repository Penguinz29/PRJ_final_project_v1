package com.edututor.controller.student;

import com.edututor.dto.LessonView;
import com.edututor.dto.QuizQuestionView;
import com.edututor.service.LessonService;
import com.edututor.service.SubmissionService;
import java.util.List;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * UC-STU-03: luyện trắc nghiệm theo bài học — đề ngẫu nhiên (lọc mức độ, số câu 5–30). Từng câu được chấm ngay qua
 * POST /api/student/submit-quiz-answer (UC-STU-04, StudentApiController); trang không nộp cả bài.
 */
@Controller
public class StudentQuizController {

    private final LessonService lessonService;
    private final SubmissionService submissionService;

    public StudentQuizController(LessonService lessonService, SubmissionService submissionService) {
        this.lessonService = lessonService;
        this.submissionService = submissionService;
    }

    /**
     * Lấy đề trắc nghiệm kèm 4 phương án của mỗi câu — KHÔNG kèm đáp án đúng hay lời giải (BR-11).
     *
     * @param difficulty 1 | 2 | 3 hoặc EASY | MEDIUM | HARD; trống = mọi mức độ
     */
    @GetMapping("/student/quiz")
    public String quiz(@RequestParam(defaultValue = "0") int lessonId,
                       @RequestParam(defaultValue = "") String difficulty,
                       @RequestParam(defaultValue = "" + SubmissionService.QUIZ_DEFAULT) int limit,
                       Model model) {
        LessonView lesson = lessonService.getLessonForStudent(lessonId);
        if (lesson == null) {
            return "redirect:/student/topics";
        }
        int level = parseLevel(difficulty);
        int n = Math.min(SubmissionService.QUIZ_MAX, Math.max(SubmissionService.QUIZ_MIN, limit));
        List<QuizQuestionView> questions = submissionService.getQuizQuestions(lessonId, level, n);
        model.addAttribute("lesson", lesson);
        model.addAttribute("questions", questions);
        model.addAttribute("level", level);
        model.addAttribute("limit", n);
        return "student/quiz";
    }

    private static int parseLevel(String raw) {
        return switch (raw == null ? "" : raw.trim().toUpperCase()) {
            case "1", "EASY" -> 1;
            case "2", "MEDIUM" -> 2;
            case "3", "HARD", "ADVANCED" -> 3;
            default -> 0;
        };
    }
}
