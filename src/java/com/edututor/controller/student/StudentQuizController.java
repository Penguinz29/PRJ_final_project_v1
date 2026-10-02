package com.edututor.controller.student;

import com.edututor.model.Lesson;
import com.edututor.model.Question;
import com.edututor.model.QuestionOption;
import com.edututor.model.Submission;
import com.edututor.model.User;
import com.edututor.model.AttemptResult;
import com.edututor.service.LessonService;
import com.edututor.service.QuestionService;
import com.edututor.service.SubmissionService;
import com.edututor.util.Validator;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * UC-STU-01 & UC-STU-02: Controller luyện thi trắc nghiệm.
 *
 * Theo Spring MVC pattern: @Controller
 * GET  /student/quiz?lessonId={id} → Lấy đề thi, hiển thị quiz.jsp
 * POST /student/quiz               → Nộp bài, tính điểm, hiển thị result.jsp
 *
 * Session key: "LOGGED_IN_USER" (theo FRS)
 */
@WebServlet(urlPatterns = {"/student/quiz", "/student/quizSubmit"})
public class StudentQuizController extends HttpServlet {

    // Inject Services (theo Spring MVC pattern - @Autowired)
    private final LessonService lessonService = new LessonService();
    private final QuestionService questionService = new QuestionService();
    private final SubmissionService submissionService = new SubmissionService();

    /**
     * UC-STU-01: GET /student/quiz?lessonId={id}
     * Lấy danh sách câu hỏi MCQ + options, render quiz.jsp với KaTeX.
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int lessonId = Validator.getInt(req, "lessonId", 0);
        Lesson lesson = lessonService.getLessonById(lessonId);
        if (lesson == null) {
            resp.sendRedirect(req.getContextPath() + "/student/topics");
            return;
        }

        // QuestionService trả về Question kèm options
        List<Question> questions = questionService.getQuestionsWithOptions(lessonId, "MCQ");

        // Tạo optionsMap để JSP dùng
        Map<Integer, List<QuestionOption>> optionsMap = new HashMap<>();
        for (Question q : questions) {
            optionsMap.put(q.getQuestionId(), q.getOptions() != null ? q.getOptions() : new ArrayList<>());
        }

        req.setAttribute("lesson", lesson);
        req.setAttribute("questions", questions);
        req.setAttribute("optionsMap", optionsMap);
        req.getRequestDispatcher("/WEB-INF/views/student/quiz.jsp").forward(req, resp);
    }

    /**
     * UC-STU-02: POST /student/quiz
     * Nhận đáp án → Delegate sang SubmissionService chấm điểm → Hiển thị kết quả.
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int lessonId = Validator.getInt(req, "lessonId", 0);
        Lesson lesson = lessonService.getLessonById(lessonId);

        // Lấy user từ session theo FRS key "LOGGED_IN_USER"
        User currentUser = (User) req.getSession().getAttribute("LOGGED_IN_USER");
        if (currentUser == null) {
            // Tương thích ngược
            currentUser = (User) req.getSession().getAttribute("currentUser");
        }

        List<Question> questions = questionService.getQuestionsWithOptions(lessonId, "MCQ");
        AttemptResult result = new AttemptResult();
        List<AttemptResult.AttemptResultItem> items = new ArrayList<>();

        int correctCount = 0;
        int totalQuestions = questions.size();

        for (Question q : questions) {
            String studentAnswer = req.getParameter("question_" + q.getQuestionId());
            List<QuestionOption> options = q.getOptions() != null ? q.getOptions() : new ArrayList<>();

            String correctAnswer = "";
            for (QuestionOption opt : options) {
                if (opt.isCorrect()) {
                    correctAnswer = opt.getOptionLetter();
                    break;
                }
            }

            boolean isCorrect = (studentAnswer != null && studentAnswer.equals(correctAnswer));
            if (isCorrect) correctCount++;

            AttemptResult.AttemptResultItem item = new AttemptResult.AttemptResultItem();
            item.setQuestion(q);
            item.setOptions(options);
            item.setStudentAnswer(studentAnswer);
            item.setCorrectAnswer(correctAnswer);
            item.setCorrect(isCorrect);
            items.add(item);

            // UC-STU-02: Lưu từng câu vào DB thông qua SubmissionDAO
            if (currentUser != null) {
                Submission sub = new Submission();
                sub.setStudentId(currentUser.getUserId());
                sub.setLessonId(lessonId > 0 ? lessonId : null);
                sub.setQuestionId(q.getQuestionId());
                sub.setQuestionType("MCQ");
                sub.setStudentAnswer(studentAnswer != null ? studentAnswer : "");
                sub.setIsCorrect(isCorrect);
                sub.setScore(isCorrect ? 1.0 : 0.0);
                sub.setReviewed(true); // MCQ tự chấm
                new com.edututor.dao.SubmissionDAO().insert(sub);
            }
        }

        result.setCorrectCount(correctCount);
        result.setTotalQuestions(totalQuestions);
        result.setItems(items);
        double score = (totalQuestions > 0) ? ((double) correctCount / totalQuestions * 100.0) : 0;
        result.setScore(score);

        req.setAttribute("score", score);
        req.setAttribute("lesson", lesson);
        req.setAttribute("result", result);
        req.getRequestDispatcher("/WEB-INF/views/student/result.jsp").forward(req, resp);
    }
}
