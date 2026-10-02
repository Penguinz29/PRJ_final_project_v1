package com.edututor.controller.admin;

import com.edututor.dao.LessonDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/admin/lessons")
public class AdminLessonController extends HttpServlet {
    private LessonDAO lessonDAO = new LessonDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("lessons", lessonDAO.getAll());
        req.getRequestDispatcher("/WEB-INF/views/admin/lessons.jsp").forward(req, resp);
    }
}

