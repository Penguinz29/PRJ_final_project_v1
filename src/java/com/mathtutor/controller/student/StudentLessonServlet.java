package com.mathtutor.controller.student;

import com.mathtutor.dao.LessonDAO;
import com.mathtutor.model.Lesson;
import com.mathtutor.util.Validator;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/student/lesson")
public class StudentLessonServlet extends HttpServlet {
    private LessonDAO lessonDAO = new LessonDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int lessonId = Validator.getInt(req, "id", 0);
        Lesson lesson = lessonDAO.getById(lessonId);

        if (lesson == null) {
            resp.sendRedirect(req.getContextPath() + "/student/topics");
            return;
        }

        req.setAttribute("lesson", lesson);
        req.getRequestDispatcher("/WEB-INF/views/student/lesson.jsp").forward(req, resp);
    }
}
