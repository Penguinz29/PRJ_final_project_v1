package com.edututor.controller.auth;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * UC-AUTH: Controller xử lý đăng xuất.
 *
 * Theo Spring MVC pattern: @Controller
 * GET /logout → Invalidate session → Redirect /login
 */
@WebServlet("/logout")
public class LogoutController extends HttpServlet {

    /**
     * GET /logout: Xóa session và chuyển về trang đăng nhập.
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        resp.sendRedirect(req.getContextPath() + "/login");
    }
}
