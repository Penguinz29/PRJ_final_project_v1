package com.edututor.controller.student;

import com.edututor.model.User;
import com.edututor.service.SubmissionService;
import com.edututor.util.Pager;
import com.edututor.util.Validator;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * UC-STU-04: Controller xem lịch sử làm bài.
 *
 * Theo Spring MVC pattern: @Controller
 * GET /student/history → Lấy danh sách submissions có phân trang
 *
 * Session key: "LOGGED_IN_USER" (theo FRS)
 */
@WebServlet("/student/history")
public class StudentHistoryController extends HttpServlet {

    // Inject Service (theo Spring MVC pattern - @Autowired)
    private final SubmissionService submissionService = new SubmissionService();

    /**
     * GET /student/history?page={n}&type={MCQ|ESSAY|ALL}
     * Lấy lịch sử làm bài của học sinh, phân trang 10 bản ghi/trang.
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);

        // Lấy user từ session theo FRS key "LOGGED_IN_USER"
        User currentUser = (session != null)
                ? (User) session.getAttribute("LOGGED_IN_USER") : null;
        if (currentUser == null && session != null) {
            // Tương thích ngược với key cũ
            currentUser = (User) session.getAttribute("currentUser");
        }
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        int page = Validator.getInt(req, "page", 1);
        int pageSize = 10;
        String type = Validator.getString(req, "type", "ALL");

        // Delegate sang SubmissionService
        int totalRecords = submissionService.countStudentHistory(currentUser.getUserId(), type);
        int totalPages = Pager.getTotalPages(totalRecords, pageSize);

        req.setAttribute("history", submissionService.getStudentHistory(
                currentUser.getUserId(), type, page, pageSize));
        req.setAttribute("page", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalRecords", totalRecords);
        req.setAttribute("type", type);

        req.getRequestDispatcher("/WEB-INF/views/student/history.jsp").forward(req, resp);
    }
}
