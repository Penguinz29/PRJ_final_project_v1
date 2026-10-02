package com.mathtutor.controller.admin;

import com.mathtutor.dao.TopicDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/admin/topics")
public class AdminTopicServlet extends HttpServlet {
    private TopicDAO topicDAO = new TopicDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("topics", topicDAO.getAll());
        req.getRequestDispatcher("/WEB-INF/views/admin/topics.jsp").forward(req, resp);
    }
}
