package com.edututor.controller.student;

import com.edututor.dto.AttemptResult;
import com.edututor.dto.LessonView;
import com.edututor.dto.QuizQuestionView;
import com.edututor.dto.SessionUser;
import com.edututor.interceptor.AuthInterceptor;
import com.edututor.service.LessonService;
import com.edututor.service.SubmissionService;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.SessionAttribute;

/** UC-STU-03 / UC-STU-04: luyện thi trắc nghiệm theo bài học (render KaTeX ở quiz.jsp / result.jsp). */
@Controller
public class StudentQuizController {

    private static final String ANSWER_PREFIX = "question_";

    private final LessonService lessonService;
    private final SubmissionService submissionService;

    public StudentQuizController(LessonService lessonService, SubmissionService submissionService) {
        this.lessonService = lessonService;
        this.submissionService = submissionService;
    }

    /** Lấy đề thi trắc nghiệm kèm 4 phương án của mỗi câu — KHÔNG kèm đáp án đúng hay lời giải (BR-11). */
    @GetMapping("/student/quiz")
    public String quiz(@RequestParam(defaultValue = "0") int lessonId, Model model) {
        LessonView lesson = lessonService.getLessonForStudent(lessonId);
        if (lesson == null) {
            return "redirect:/student/topics";
        }
        List<QuizQuestionView> questions = submissionService.getQuizQuestions(lessonId);
        model.addAttribute("lesson", lesson);
        model.addAttribute("questions", questions);
        return "student/quiz";
    }

    /** Nộp cả bài, chấm điểm tức thì, lưu vào Submissions và hiển thị kết quả + lời giải. */
    @PostMapping("/student/quizSubmit")
    public String submit(@RequestParam(defaultValue = "0") int lessonId,
                         @RequestParam Map<String, String> params,
                         @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user, Model model) {
        LessonView lesson = lessonService.getLessonForStudent(lessonId);
        if (lesson == null) {
            return "redirect:/student/topics";
        }
        Map<Integer, String> answers = new HashMap<>();
        for (Map.Entry<String, String> e : params.entrySet()) {
            if (e.getKey().startsWith(ANSWER_PREFIX)) {
                try {
                    answers.put(Integer.parseInt(e.getKey().substring(ANSWER_PREFIX.length())), e.getValue());
                } catch (NumberFormatException ignored) {
                    // bỏ qua tham số lạ
                }
            }
        }
        AttemptResult result = submissionService.gradeQuiz(user.getUserId(), lessonId, answers);
        model.addAttribute("lesson", lesson);
        model.addAttribute("result", result);
        model.addAttribute("score", result.getScore());
        return "student/result";
    }
}
