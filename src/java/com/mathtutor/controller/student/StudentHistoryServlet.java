package com.mathtutor.controller.student;

import com.mathtutor.dao.SubmissionDAO;
import com.mathtutor.model.User;
import com.mathtutor.util.Pager;
import com.mathtutor.util.Validator;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/student/history")
public class StudentHistoryServlet extends HttpServlet {
    private SubmissionDAO submissionDAO = new SubmissionDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        int page = Validator.getInt(req, "page", 1);
        int pageSize = 10;
        String type = Validator.getString(req, "type", "ALL");

        int totalRecords = submissionDAO.countHistory(currentUser.getUserId(), type);
        int totalPages = Pager.getTotalPages(totalRecords, pageSize);

        req.setAttribute("history", submissionDAO.getHistory(currentUser.getUserId(), type, page, pageSize));
        req.setAttribute("page", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalRecords", totalRecords);
        req.setAttribute("type", type);

        req.getRequestDispatcher("/WEB-INF/views/student/history.jsp").forward(req, resp);
    }
}
