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

@WebServlet("/teacher/dashboard")
public class TeacherDashboardController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("LOGGED_IN_USER");

        req.setAttribute("totalTopics", 5);
        req.setAttribute("totalQuestions", 20);
        req.setAttribute("totalStudents", 10);
        req.setAttribute("pendingSubmissions", 3);

        req.getRequestDispatcher("/WEB-INF/views/teacher/dashboard.jsp").forward(req, resp);
    }
}

