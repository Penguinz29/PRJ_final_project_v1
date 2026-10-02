package com.edututor.controller.teacher;

import com.edututor.dao.SubmissionDAO;
import com.edututor.model.Submission;
import com.edututor.model.User;
import com.edututor.util.Pager;
import com.edututor.util.Validator;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * FR-TEA-04: Giáo viên theo dõi, duyệt và điều chỉnh điểm số bài tự luận viết tay (UC-OCR-02)
 */
@WebServlet(urlPatterns = { "/teacher/submissions", "/teacher/submissions/essay", "/teacher/submission/review" })
public class TeacherSubmissionController extends HttpServlet {

    private SubmissionDAO submissionDAO = new SubmissionDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User currentUser = (User) req.getSession().getAttribute("LOGGED_IN_USER");
        int teacherId = (currentUser != null) ? currentUser.getUserId() : 1;

        int submissionId = Validator.getInt(req, "id", 0);
        if (submissionId > 0) {
            // Xem chi tiết bài nộp để chấm điểm / sửa điểm
            Submission sub = submissionDAO.getById(submissionId);
            if (sub == null) {
                req.getSession().setAttribute("errorFlash", "Không tìm thấy bài làm tự luận yêu cầu.");
                resp.sendRedirect(req.getContextPath() + "/teacher/submissions");
                return;
            }
            req.setAttribute("sub", sub);
            req.getRequestDispatcher("/WEB-INF/views/teacher/submission-review.jsp").forward(req, resp);
            return;
        }

        // Danh sách bài nộp tự luận
        int page = Validator.getInt(req, "page", 1);
        int pageSize = 10;
        String status = Validator.getString(req, "status", "pending");
        boolean reviewed = "reviewed".equalsIgnoreCase(status);

        int totalRecords = submissionDAO.countSubmissionsForTeacher(teacherId, reviewed);
        int totalPages = Pager.getTotalPages(totalRecords, pageSize);
        List<Submission> submissions = submissionDAO.getSubmissionsForTeacher(teacherId, reviewed, page, pageSize);

        req.setAttribute("submissions", submissions);
        req.setAttribute("page", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalRecords", totalRecords);
        req.setAttribute("status", status);

        req.getRequestDispatcher("/WEB-INF/views/teacher/submissions.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        int submissionId = Validator.getInt(req, "submissionId", 0);
        if (submissionId <= 0) {
            req.getSession().setAttribute("errorFlash", "ID bài nộp không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/teacher/submissions");
            return;
        }

        String scoreStr = req.getParameter("score");
        Double score = null;
        try {
            if (scoreStr != null && !scoreStr.trim().isEmpty()) {
                score = Double.parseDouble(scoreStr.trim());
                if (score < 0) score = 0.0;
                if (score > 10.0) score = 10.0;
            }
        } catch (NumberFormatException ignored) {}

        String resultEval = req.getParameter("isCorrect");
        boolean isCorrect = "true".equalsIgnoreCase(resultEval) || (score != null && score >= 5.0);
        String teacherFeedback = req.getParameter("teacherFeedback");

        boolean success = submissionDAO.updateReview(submissionId, isCorrect, score, teacherFeedback != null ? teacherFeedback.trim() : "");
        if (success) {
            req.getSession().setAttribute("flash", "Đã lưu kết quả chấm điểm và nhận xét thành công!");
        } else {
            req.getSession().setAttribute("errorFlash", "Có lỗi xảy ra khi lưu kết quả chấm bài.");
        }

        resp.sendRedirect(req.getContextPath() + "/teacher/submissions?id=" + submissionId);
    }
}

