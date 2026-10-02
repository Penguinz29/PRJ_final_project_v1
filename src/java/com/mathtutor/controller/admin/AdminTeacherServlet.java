package com.mathtutor.controller.admin;

import com.mathtutor.dao.UserDAO;
import com.mathtutor.util.Pager;
import com.mathtutor.util.Validator;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/admin/teachers")
public class AdminTeacherServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int page = Validator.getInt(req, "page", 1);
        int pageSize = 10;

        int totalRecords = userDAO.countByRole("TEACHER");
        int totalPages = Pager.getTotalPages(totalRecords, pageSize);

        req.setAttribute("teachers", userDAO.getByRole("TEACHER", page, pageSize));
        req.setAttribute("page", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalRecords", totalRecords);

        req.getRequestDispatcher("/WEB-INF/views/admin/teachers.jsp").forward(req, resp);
    }
}
