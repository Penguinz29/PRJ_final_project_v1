package com.edututor.controller.auth;

import com.edututor.service.UserService;
import com.edututor.util.Validator;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * UC-AUTH-02: Controller xử lý đăng ký tài khoản học sinh.
 *
 * Theo Spring MVC pattern: @Controller
 * GET  /register → Hiển thị form đăng ký
 * POST /register → Validate → Lưu DB → Redirect /login
 */
@WebServlet("/register")
public class RegisterController extends HttpServlet {

    // Inject Service (theo Spring MVC pattern - @Autowired)
    private final UserService userService = new UserService();

    /**
     * GET /register: Hiển thị trang đăng ký.
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Nếu đã đăng nhập → redirect về dashboard
        if (req.getSession(false) != null
                && req.getSession(false).getAttribute("LOGGED_IN_USER") != null) {
            resp.sendRedirect(req.getContextPath() + "/student/dashboard");
            return;
        }
        req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
    }

    /**
     * POST /register: Xử lý đăng ký.
     * Validation → existsByUsername → existsByEmail → register → redirect /login
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String username        = req.getParameter("username");
        String password        = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");
        String fullName        = req.getParameter("fullName");
        String email           = req.getParameter("email");

        // Giữ lại giá trị đã nhập để hiển thị lại khi có lỗi
        req.setAttribute("username", username);
        req.setAttribute("fullName", fullName);
        req.setAttribute("email", email);

        // 1. Validate trống
        if (Validator.isEmpty(username) || Validator.isEmpty(password)
                || Validator.isEmpty(confirmPassword) || Validator.isEmpty(fullName)
                || Validator.isEmpty(email)) {
            req.setAttribute("error", "Vui lòng điền đầy đủ tất cả các trường.");
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
            return;
        }

        // 2. Validate username format (4-30 ký tự, chữ/số/gạch dưới)
        if (!username.matches("[A-Za-z0-9_]{4,30}")) {
            req.setAttribute("error", "Tên đăng nhập phải từ 4-30 ký tự, chỉ gồm chữ cái, số và dấu gạch dưới.");
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
            return;
        }

        // 3. Validate password length
        if (password.length() < 6) {
            req.setAttribute("error", "Mật khẩu phải có ít nhất 6 ký tự.");
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
            return;
        }

        // 4. Validate password match (FRS: kiểm tra confirmPassword)
        if (!password.equals(confirmPassword)) {
            req.setAttribute("error", "Mật khẩu xác nhận không khớp.");
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
            return;
        }

        // 5. Validate email format (Regex theo FRS)
        if (!Validator.isValidEmail(email)) {
            req.setAttribute("error", "Địa chỉ email không đúng định dạng.");
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
            return;
        }

        // 6. UserService.existsByUsername (FRS: kiểm tra trùng username)
        if (userService.existsByUsername(username.trim())) {
            req.setAttribute("error", "Tên đăng nhập đã được sử dụng. Vui lòng chọn tên khác.");
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
            return;
        }

        // 7. UserService.existsByEmail (FRS: kiểm tra trùng email)
        if (userService.existsByEmail(email.trim())) {
            req.setAttribute("error", "Email đã được đăng ký. Vui lòng sử dụng email khác.");
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
            return;
        }

        // 8. Delegate đăng ký sang UserService (băm mật khẩu + lưu DB)
        boolean success = userService.register(username, password, fullName, email);

        if (success) {
            // Đăng ký thành công → redirect /login kèm flash message
            req.getSession(true).setAttribute("flashMsg", "Đăng ký thành công! Vui lòng đăng nhập.");
            req.getSession(true).setAttribute("flashType", "success");
            resp.sendRedirect(req.getContextPath() + "/login");
        } else {
            req.setAttribute("error", "Đã xảy ra lỗi khi đăng ký. Vui lòng thử lại.");
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
        }
    }
}
