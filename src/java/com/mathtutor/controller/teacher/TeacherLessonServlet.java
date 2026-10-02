package com.mathtutor.controller.teacher;

import com.mathtutor.dao.LessonDAO;
import com.mathtutor.dao.TopicDAO;
import com.mathtutor.model.Topic;
import com.mathtutor.model.User;
import com.mathtutor.model.Lesson;
import com.mathtutor.util.Validator;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(urlPatterns = { "/teacher/lessons", "/teacher/lesson/form" })
public class TeacherLessonServlet extends HttpServlet {
    private LessonDAO lessonDAO = new LessonDAO();
    private TopicDAO topicDAO = new TopicDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        String action = Validator.getString(req, "action", "");

        if (path.equals("/teacher/lesson/form") || "create".equals(action) || "edit".equals(action)) {
            User currentUser = (User) req.getSession().getAttribute("currentUser");
            req.setAttribute("topics", topicDAO.getByTeacherId(currentUser.getUserId()));
            if ("edit".equals(action)) {
                req.setAttribute("isEdit", true);
                req.setAttribute("lesson", lessonDAO.getById(Validator.getInt(req, "id", 0)));
            }
            req.getRequestDispatcher("/WEB-INF/views/teacher/lesson-form.jsp").forward(req, resp);
            return;
        }

        if (path.equals("/teacher/lessons")) {
            int filterTopicId = Validator.getInt(req, "topicId", 0);

            // Get teacher's topics for filter
            User currentUser = (User) req.getSession().getAttribute("currentUser");
            req.setAttribute("topics", topicDAO.getByTeacherId(currentUser.getUserId()));

            if (filterTopicId > 0) {
                req.setAttribute("lessons", lessonDAO.getByTopicId(filterTopicId));
            } else {
                req.setAttribute("lessons", lessonDAO.getAll());
            }
            req.setAttribute("filterTopicId", filterTopicId);
            req.getRequestDispatcher("/WEB-INF/views/teacher/lessons.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = Validator.getString(req, "action", "create");
        String title = Validator.getString(req, "title", "");
        int topicId = Validator.getInt(req, "topicId", 0);
        String summary = Validator.getString(req, "summary", "");
        String content = Validator.getString(req, "content", "");
        String youtubeUrl = Validator.getString(req, "youtubeUrl", "");

        Lesson l = new Lesson();
        l.setTitle(title);
        l.setTopicId(topicId);
        l.setSummary(summary);
        l.setContent(content);
        l.setYoutubeUrl(youtubeUrl);
        l.setDisplayOrder(1);

        if ("create".equals(action)) {
            lessonDAO.insert(l);
            req.getSession().setAttribute("success", "Thêm bài giảng thành công.");
        } else if ("update".equals(action)) {
            int id = Validator.getInt(req, "id", 0);
            l.setLessonId(id);
            lessonDAO.update(l);
            req.getSession().setAttribute("success", "Cập nhật bài giảng thành công.");
        }
        resp.sendRedirect(req.getContextPath() + "/teacher/lessons?topicId=" + topicId);
    }
}
