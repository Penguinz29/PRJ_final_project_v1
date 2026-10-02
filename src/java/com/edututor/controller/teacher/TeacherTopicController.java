package com.edututor.controller.teacher;

import com.edututor.dao.TopicDAO;
import com.edututor.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/teacher/topics")
public class TeacherTopicController extends HttpServlet {
    private TopicDAO topicDAO = new TopicDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("LOGGED_IN_USER");

        req.setAttribute("topics", topicDAO.getByTeacherId(currentUser.getUserId()));
        req.getRequestDispatcher("/WEB-INF/views/teacher/topics.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = com.edututor.util.Validator.getString(req, "action", "create");
        User currentUser = (User) req.getSession().getAttribute("LOGGED_IN_USER");

        if ("create".equals(action) || "update".equals(action)) {
            String topicName = com.edututor.util.Validator.getString(req, "topicName", "");
            String description = com.edututor.util.Validator.getString(req, "description", "");
            com.edututor.model.Topic t = new com.edututor.model.Topic();
            t.setTopicName(topicName);
            t.setDescription(description);
            t.setTeacherId(currentUser.getUserId());

            if ("create".equals(action)) {
                topicDAO.insert(t);
                req.getSession().setAttribute("success", "Thêm chủ đề thành công.");
            } else {
                t.setTopicId(com.edututor.util.Validator.getInt(req, "topicId", 0));
                topicDAO.update(t);
                req.getSession().setAttribute("success", "Cập nhật chủ đề thành công.");
            }
        } else if ("delete".equals(action)) {
            int id = com.edututor.util.Validator.getInt(req, "id", 0);
            topicDAO.delete(id);
            req.getSession().setAttribute("success", "Xóa chủ đề thành công.");
        }

        resp.sendRedirect(req.getContextPath() + "/teacher/topics");
    }
}

