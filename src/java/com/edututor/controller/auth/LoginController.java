package com.edututor.controller.auth;

import com.edututor.model.User;
import com.edututor.service.UserService;
import com.edututor.util.Validator;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * UC-AUTH-01: Controller xử lý đăng nhập.
 *
 * Theo Spring MVC pattern: @Controller
 * GET  /login → Hiển thị form đăng nhập
 * POST /login → Xác thực, đặt session, redirect theo role
 *
 * Session key: "LOGGED_IN_USER" (theo FRS)
 */
@WebServlet("/login")
public class LoginController extends HttpServlet {

    // Inject Service (theo Spring MVC pattern - @Autowired)
    private final UserService userService = new UserService();

    /**
     * GET /login: Hiển thị trang đăng nhập.
     * Nếu đã đăng nhập, redirect về dashboard tương ứng.
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("LOGGED_IN_USER") != null) {
            User u = (User) session.getAttribute("LOGGED_IN_USER");
            redirectByRole(resp, u.getRole(), req.getContextPath());
            return;
        }
        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }

    /**
     * POST /login: Xử lý xác thực đăng nhập.
     * Validate → UserService.authenticate() → set session → redirect
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        // Validate input
        if (Validator.isEmpty(username) || Validator.isEmpty(password)) {
            req.setAttribute("error", "Username và Password không được trống.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        // Delegate xác thực sang UserService
        User user = userService.authenticate(username, password);

        if (user != null) {
            // Tạo session, lưu user theo key FRS
            HttpSession session = req.getSession(true);
            session.setAttribute("LOGGED_IN_USER", user);
            // Tương thích ngược với code cũ dùng "currentUser"
            session.setAttribute("currentUser", user);
            redirectByRole(resp, user.getRole(), req.getContextPath());
        } else {
            req.setAttribute("error", "Tên đăng nhập hoặc mật khẩu sai, hoặc tài khoản đã bị khóa!");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        }
    }

    /**
     * Redirect người dùng đến dashboard theo role.
     * ADMIN → /admin/dashboard
     * TEACHER → /teacher/dashboard
     * STUDENT → /student/dashboard
     */
    private void redirectByRole(HttpServletResponse resp, String role, String ctx)
            throws IOException {
        if ("ADMIN".equals(role)) {
            resp.sendRedirect(ctx + "/admin/dashboard");
        } else if ("TEACHER".equals(role)) {
            resp.sendRedirect(ctx + "/teacher/dashboard");
        } else {
            resp.sendRedirect(ctx + "/student/dashboard");
        }
    }
}
