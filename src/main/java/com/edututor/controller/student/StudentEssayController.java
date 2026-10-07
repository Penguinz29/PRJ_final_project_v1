package com.edututor.controller.student;

import com.edututor.dto.LessonView;
import com.edututor.dto.QuestionView;
import com.edututor.service.LessonService;
import com.edututor.service.QuestionService;
import com.edututor.service.TopicService;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * Trang nộp bài tự luận. Không có lessonId: danh sách Chủ đề → Bài học để chọn; có lessonId: các câu tự luận của bài.
 * Việc nộp và chấm AI (OCR) thực hiện qua AJAX tới POST /api/student/submit-essay-ocr (xem StudentApiController).
 */
@Controller
public class StudentEssayController {

    private final LessonService lessonService;
    private final QuestionService questionService;
    private final TopicService topicService;

    public StudentEssayController(LessonService lessonService, QuestionService questionService,
                                  TopicService topicService) {
        this.lessonService = lessonService;
        this.questionService = questionService;
        this.topicService = topicService;
    }

    @GetMapping("/student/essay")
    public String essay(@RequestParam(defaultValue = "0") int lessonId,
                        @RequestParam(defaultValue = "0") int questionId, Model model) {
        LessonView lesson = lessonId > 0 ? lessonService.getLessonForStudent(lessonId) : null;
        if (lesson == null) {
            return picker(model);
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

    /** Bước chọn: chủ đề → bài học, kèm số câu tự luận của mỗi bài. */
    private String picker(Model model) {
        Map<Integer, Integer> essayCounts = new HashMap<>();
        for (QuestionView q : questionService.getAllEssayQuestions()) {
            essayCounts.merge(q.getLessonId(), 1, Integer::sum);
        }
        model.addAttribute("topics", topicService.getAllTopicsWithLessons());
        model.addAttribute("essayCounts", essayCounts);
        return "student/essay-topics";
    }
}
