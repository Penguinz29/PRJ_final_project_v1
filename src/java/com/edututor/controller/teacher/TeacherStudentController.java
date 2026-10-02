package com.edututor.controller.teacher;

import com.edututor.dao.UserDAO;
import com.edututor.util.Pager;
import com.edututor.util.Validator;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

import com.edututor.dao.SubmissionDAO;
import com.edututor.model.Submission;

@WebServlet(urlPatterns = { "/teacher/students", "/teacher/students/history" })
public class TeacherStudentController extends HttpServlet {
    private UserDAO userDAO = new UserDAO();
    private SubmissionDAO submissionDAO = new SubmissionDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        int page = Validator.getInt(req, "page", 1);
        int pageSize = 10;

        if (path.equals("/teacher/students/history")) {
            int studentId = Validator.getInt(req, "studentId", 0);
            String type = Validator.getString(req, "type", "ALL");

            req.setAttribute("submissions", submissionDAO.getHistory(studentId, type, page, pageSize));
            req.setAttribute("page", page);
            req.setAttribute("totalPages", Pager.getTotalPages(submissionDAO.countHistory(studentId, type), pageSize));
            req.setAttribute("studentId", studentId);
            req.setAttribute("type", type);
            req.getRequestDispatcher("/WEB-INF/views/teacher/student-history.jsp").forward(req, resp);
            return;
        }

        int totalRecords = userDAO.countByRole("STUDENT");
        int totalPages = Pager.getTotalPages(totalRecords, pageSize);

        req.setAttribute("students", userDAO.getByRole("STUDENT", page, pageSize));
        req.setAttribute("page", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalRecords", totalRecords);

        req.getRequestDispatcher("/WEB-INF/views/teacher/students.jsp").forward(req, resp);
    }
}

