package com.mathtutor.filter;

import com.mathtutor.model.User;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter("/*")
public class AuthFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        String uri = req.getRequestURI();

        // 1. Cho phép tài nguyên tĩnh & login & register
        if (uri.contains("/assets/") || uri.endsWith("/login") || uri.endsWith("/register")
                || uri.endsWith("/index.jsp") || uri.endsWith("/FINAL_prj_v1/")) {
            chain.doFilter(request, response);
            return;
        }

        // 2. Chặn trang cần đăng nhập
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (user == null) {
            req.setAttribute("error", "Vui lòng đăng nhập để tiếp tục.");
            req.getRequestDispatcher("/login.jsp").forward(req, res);
            return;
        }

        // 3. Phân quyền theo role
        String role = user.getRole(); // ADMIN, TEACHER, STUDENT
        if (uri.contains("/admin/") && !role.equals("ADMIN")) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập Admin.");
            return;
        }
        if (uri.contains("/teacher/") && !role.equals("TEACHER")) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập Giáo viên.");
            return;
        }
        if (uri.contains("/student/") && !role.equals("STUDENT")) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập Học viên.");
            return;
        }

        chain.doFilter(request, response);
    }
}
