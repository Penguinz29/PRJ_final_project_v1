package com.edututor.controller.student;

import com.edututor.dto.LessonView;
import com.edututor.dto.QuestionView;
import com.edututor.service.LessonService;
import com.edututor.service.QuestionService;
import java.util.List;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * Trang nộp bài tự luận. Việc nộp và chấm AI (OCR) thực hiện qua AJAX tới
 * POST /api/student/submit-essay-ocr (xem StudentApiController).
 */
@Controller
public class StudentEssayController {

    private final LessonService lessonService;
    private final QuestionService questionService;

    public StudentEssayController(LessonService lessonService, QuestionService questionService) {
        this.lessonService = lessonService;
        this.questionService = questionService;
    }

    @GetMapping("/student/essay")
    public String essay(@RequestParam(defaultValue = "0") int lessonId,
                        @RequestParam(defaultValue = "0") int questionId, Model model) {
        LessonView lesson = lessonService.getLessonById(lessonId);
        if (lesson == null) {
            return "redirect:/student/topics";
        }
        List<QuestionView> questions = questionService.getEssayQuestions(lessonId);
        model.addAttribute("lesson", lesson);
        model.addAttribute("questions", questions);
        QuestionView chosen = questions.stream().filter(q -> q.getQuestionId() == questionId).findFirst()
                .orElse(questions.isEmpty() ? null : questions.get(0));
        if (chosen != null) {
            model.addAttribute("question", chosen);
        }
        return "student/essay";
    }
}
