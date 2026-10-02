package com.edututor.controller.admin;

import com.edututor.dao.QuestionDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/admin/questions")
public class AdminQuestionController extends HttpServlet {
    private QuestionDAO questionDAO = new QuestionDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("questions", questionDAO.getAll());
        req.getRequestDispatcher("/WEB-INF/views/admin/questions.jsp").forward(req, resp);
    }
}

