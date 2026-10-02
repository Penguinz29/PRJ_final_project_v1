package com.mathtutor.controller.student;

import com.mathtutor.dao.LessonDAO;
import com.mathtutor.dao.QuestionDAO;
import com.mathtutor.dao.SubmissionDAO;
import com.mathtutor.model.Lesson;
import com.mathtutor.model.Question;
import com.mathtutor.model.QuestionOption;
import com.mathtutor.model.Submission;
import com.mathtutor.model.User;
import com.mathtutor.util.Validator;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = { "/student/quiz", "/student/quizSubmit" })
public class StudentQuizServlet extends HttpServlet {
    private LessonDAO lessonDAO = new LessonDAO();
    private QuestionDAO questionDAO = new QuestionDAO();
    private SubmissionDAO submissionDAO = new SubmissionDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int lessonId = Validator.getInt(req, "lessonId", 0);
        Lesson lesson = lessonDAO.getById(lessonId);
        if (lesson == null) {
            resp.sendRedirect(req.getContextPath() + "/student/topics");
            return;
        }

        List<Question> questions = questionDAO.getByLessonAndType(lessonId, "MCQ");
        Map<Integer, List<QuestionOption>> optionsMap = new HashMap<>();

        for (Question q : questions) {
            optionsMap.put(q.getQuestionId(), questionDAO.getOptions(q.getQuestionId()));
        }

        req.setAttribute("lesson", lesson);
        req.setAttribute("questions", questions);
        req.setAttribute("optionsMap", optionsMap);
        req.getRequestDispatcher("/WEB-INF/views/student/quiz.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int lessonId = Validator.getInt(req, "lessonId", 0);
        Lesson lesson = lessonDAO.getById(lessonId);

        // Lấy user hiện tại từ session
        User currentUser = (User) req.getSession().getAttribute("currentUser");

        List<Question> questions = questionDAO.getByLessonAndType(lessonId, "MCQ");
        com.mathtutor.model.AttemptResult result = new com.mathtutor.model.AttemptResult();
        java.util.List<com.mathtutor.model.AttemptResult.AttemptResultItem> items = new java.util.ArrayList<>();

        int correctCount = 0;
        int totalQuestions = questions.size();

        for (int i = 0; i < questions.size(); i++) {
            Question q = questions.get(i);
            String studentAnswer = req.getParameter("question_" + q.getQuestionId());
            List<QuestionOption> options = questionDAO.getOptions(q.getQuestionId());

            String correctAnswer = "";
            for (QuestionOption opt : options) {
                if (opt.isCorrect()) {
                    correctAnswer = opt.getOptionLetter();
                    break;
                }
            }

            boolean isCorrect = (studentAnswer != null && studentAnswer.equals(correctAnswer));
            if (isCorrect)
                correctCount++;

            com.mathtutor.model.AttemptResult.AttemptResultItem item = new com.mathtutor.model.AttemptResult.AttemptResultItem();
            item.setQuestion(q);
            item.setOptions(options);
            item.setStudentAnswer(studentAnswer);
            item.setCorrectAnswer(correctAnswer);
            item.setCorrect(isCorrect);
            items.add(item);

            // Lưu kết quả từng câu vào Submissions DB
            if (currentUser != null) {
                Submission sub = new Submission();
                sub.setStudentId(currentUser.getUserId());
                sub.setLessonId(lessonId > 0 ? lessonId : null);
                sub.setQuestionId(q.getQuestionId());
                sub.setQuestionType("MCQ");
                sub.setStudentAnswer(studentAnswer != null ? studentAnswer : "");
                sub.setIsCorrect(isCorrect);
                sub.setReviewed(true); // MCQ tự chấm, không cần teacher review
                submissionDAO.insert(sub);
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

