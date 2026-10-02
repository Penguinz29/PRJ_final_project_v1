package com.mathtutor.controller.teacher;

import com.mathtutor.util.Validator;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/teacher/submissions")
public class TeacherSubmissionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int page = Validator.getInt(req, "page", 1);
        String status = Validator.getString(req, "status", "pending");

        // Use empty lists for demo purposes if submission logic is too complex
        req.setAttribute("page", page);
        req.setAttribute("totalPages", 1);
        req.setAttribute("totalRecords", 0);
        req.setAttribute("status", status);

        req.getRequestDispatcher("/WEB-INF/views/teacher/submissions.jsp").forward(req, resp);
    }
}
