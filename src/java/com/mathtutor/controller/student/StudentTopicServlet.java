package com.mathtutor.controller.student;

import com.mathtutor.dao.TopicDAO;
import com.mathtutor.dao.LessonDAO;
import com.mathtutor.model.Topic;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/student/topics")
public class StudentTopicServlet extends HttpServlet {
    private TopicDAO topicDAO = new TopicDAO();
    private LessonDAO lessonDAO = new LessonDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<Topic> topics = topicDAO.getAll();
        // Load lessons map for UI accordion
        for (Topic t : topics) {
            t.setLessons(lessonDAO.getByTopicId(t.getTopicId()));
        }

        req.setAttribute("topics", topics);
        req.getRequestDispatcher("/WEB-INF/views/student/topics.jsp").forward(req, resp);
    }
}
