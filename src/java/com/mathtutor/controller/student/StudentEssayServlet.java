package com.mathtutor.controller.student;

import com.mathtutor.dao.LessonDAO;
import com.mathtutor.dao.QuestionDAO;
import com.mathtutor.model.Lesson;
import com.mathtutor.model.Question;
import com.mathtutor.util.Validator;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = { "/student/essay", "/student/essaySubmit" })
public class StudentEssayServlet extends HttpServlet {
    private LessonDAO lessonDAO = new LessonDAO();
    private QuestionDAO questionDAO = new QuestionDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int lessonId = Validator.getInt(req, "lessonId", 0);
        Lesson lesson = lessonDAO.getById(lessonId);
        if (lesson == null) {
            resp.sendRedirect(req.getContextPath() + "/student/topics");
            return;
        }

        List<Question> questions = questionDAO.getByLessonAndType(lessonId, "ESSAY");

        req.setAttribute("lesson", lesson);
        if (!questions.isEmpty()) {
            req.setAttribute("question", questions.get(0)); // Only take first config for demo
        }

        req.getRequestDispatcher("/WEB-INF/views/student/essay.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Mock save logic, redirect to history
        req.getSession().setAttribute("flashMsg", "Nộp bài thành công! Vui lòng chờ giáo viên chấm điểm.");
        req.getSession().setAttribute("flashType", "success");
        resp.sendRedirect(req.getContextPath() + "/student/history?type=ESSAY");
    }
}
