package com.mathtutor.controller.auth;

import com.mathtutor.dao.UserDAO;
import com.mathtutor.model.User;
import com.mathtutor.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            User u = (User) session.getAttribute("currentUser");
            redirectByRole(resp, u.getRole(), req.getContextPath());
            return;
        }
        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String u = req.getParameter("username");
        String p = req.getParameter("password");

        if (u == null || p == null || u.trim().isEmpty() || p.trim().isEmpty()) {
            req.setAttribute("error", "Username và Password không được trống");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        String hash = PasswordUtil.hashPassword(p);
        User user = userDAO.login(u, hash);

        if (user != null) {
            HttpSession session = req.getSession();
            session.setAttribute("currentUser", user);
            redirectByRole(resp, user.getRole(), req.getContextPath());
        } else {
            req.setAttribute("error", "Tên đăng nhập hoặc mật khẩu sai, hoặc tài khoản đã bị khóa!");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        }
    }

    private void redirectByRole(HttpServletResponse resp, String role, String ctx) throws IOException {
        if ("ADMIN".equals(role)) {
            resp.sendRedirect(ctx + "/admin/dashboard");
        } else if ("TEACHER".equals(role)) {
            resp.sendRedirect(ctx + "/teacher/dashboard");
        } else {
            resp.sendRedirect(ctx + "/student/dashboard");
        }
    }
}
