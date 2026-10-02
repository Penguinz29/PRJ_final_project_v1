package com.edututor.filter;

import com.edututor.model.User;
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

/**
 * UC-AUTH-03: Bộ lọc bảo mật xác thực và phân quyền.
 *
 * Theo FRS pattern: AuthInterceptor (implements HandlerInterceptor trong Spring MVC).
 * Trong môi trường Servlet thuần, triển khai qua jakarta.servlet.Filter.
 *
 * Luồng xử lý:
 * 1. Trích xuất user từ session bằng key "LOGGED_IN_USER".
 * 2. Nếu user null và URI không nằm trong whitelist → redirect /login.
 * 3. Nếu URI bắt đầu bằng /admin/ nhưng role != ADMIN → 403 Access Denied.
 * 4. Nếu URI bắt đầu bằng /teacher/ nhưng role không phải TEACHER hoặc ADMIN → 403.
 * 5. Các request hợp lệ → tiếp tục.
 */
@WebFilter("/*")
public class AuthInterceptor implements Filter {

    // Danh sách URI công khai (whitelist) - không cần đăng nhập
    private static final String[] PUBLIC_PATHS = {
        "/login", "/register", "/assets/", "/index.jsp", "/index.html"
    };

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        String uri = req.getRequestURI();

        // 1. Cho phép các tài nguyên công khai (whitelist)
        if (isPublicPath(uri)) {
            chain.doFilter(request, response);
            return;
        }

        // 2. Kiểm tra session — theo FRS dùng key "LOGGED_IN_USER"
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("LOGGED_IN_USER") : null;

        if (user == null) {
            // Chưa đăng nhập → chuyển về trang login
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // 3. Phân quyền theo URI prefix
        String role = user.getRole(); // ADMIN, TEACHER, STUDENT

        if (uri.contains("/admin/") && !"ADMIN".equals(role)) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập khu vực Admin.");
            return;
        }

        if (uri.contains("/teacher/") && !"TEACHER".equals(role) && !"ADMIN".equals(role)) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập khu vực Giáo viên.");
            return;
        }

        // 4. Request hợp lệ → tiếp tục
        chain.doFilter(request, response);
    }

    /**
     * Kiểm tra URI có thuộc danh sách whitelist hay không.
     */
    private boolean isPublicPath(String uri) {
        for (String path : PUBLIC_PATHS) {
            if (uri.contains(path)) {
                return true;
            }
        }
        // Cho phép context root redirect về login
        if (uri.endsWith("/") || uri.endsWith("/FINAL_prj_v1/")) {
            return true;
        }
        return false;
    }
}
