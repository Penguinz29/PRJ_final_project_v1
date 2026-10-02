package com.mathtutor.controller.admin;

import com.mathtutor.dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        if (!path.equals("/admin/dashboard")) {
            req.getRequestDispatcher("/WEB-INF/views/admin/placeholder.jsp").forward(req, resp);
            return;
        }

        try {
            int totalTeachers = userDAO.countByRole("TEACHER");
            int totalStudents = userDAO.countByRole("STUDENT");

            // Mock recent users
            req.setAttribute("recentUsers", userDAO.getByRole("TEACHER", 1, 5));

            req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, resp);
        } catch (Exception e) {
            req.setAttribute("javax.servlet.error.exception", e);
            throw new ServletException(e);
        }
    }
}
