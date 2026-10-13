package config;

import dto.api.ApiResponse;
import dto.view.SessionUser;
import repository.UserRepository;
import util.WebUtil;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.DispatcherType;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * FR-AUTH-06: phân quyền theo URL cho cả trang lẫn API (kiểm tra từ trên xuống, khớp quy tắc đầu tiên thì dừng):
 * <ol>
 *   <li>/login, /register, /error, /static/** : công khai</li>
 *   <li>/admin/**, /api/admin/** : ADMIN</li>
 *   <li>/teacher/**, /api/teacher/** : TEACHER hoặc ADMIN</li>
 *   <li>/student/**, /api/student/**, /api/tutor/** : STUDENT</li>
 *   <li>/uploads/** (ảnh bài làm; controller kiểm tra thêm chủ bài), /profile/**, /logout, / : chỉ cần đăng nhập</li>
 *   <li>còn lại : 404</li>
 * </ol>
 * Tài khoản bị khóa đang đăng nhập bị chặn ở request kế tiếp (BR-01).
 */
@Component
public class AuthInterceptor implements HandlerInterceptor {

    public static final String SESSION_USER = "LOGGED_IN_USER";

    private final UserRepository userRepository;
    private final ObjectMapper mapper;

    public AuthInterceptor(UserRepository userRepository, ObjectMapper mapper) {
        this.userRepository = userRepository;
        this.mapper = mapper;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
            throws Exception {
        // Request đã được kiểm tra ở lượt đầu; lượt dispatch lại của xử lý bất đồng bộ không cần kiểm tra lần nữa
        if (request.getDispatcherType() == DispatcherType.ASYNC) {
            return true;
        }
        String path = WebUtil.pathWithinApp(request);
        if (isPublic(path)) {
            return true;
        }
        boolean api = WebUtil.isApi(request);

        HttpSession session = request.getSession(false);
        SessionUser user = (session != null) ? (SessionUser) session.getAttribute(SESSION_USER) : null;
        if (user == null) {
            return unauthenticated(request, response, api, "/login");
        }

        // BR-01: chỉ tài khoản đang hoạt động; truy vấn nhẹ theo khóa chính
        Boolean active = userRepository.findActiveById(user.getUserId());
        if (!Boolean.TRUE.equals(active)) {
            session.invalidate();
            return unauthenticated(request, response, api, "/login?locked=1");
        }

        String role = user.getRole();
        boolean allowed;
        if (under(path, "/admin") || under(path, "/api/admin")) {
            allowed = "ADMIN".equals(role);
        } else if (under(path, "/teacher") || under(path, "/api/teacher")) {
            allowed = "TEACHER".equals(role) || "ADMIN".equals(role);
        } else if (under(path, "/student") || under(path, "/api/student") || under(path, "/api/tutor")) {
            allowed = "STUDENT".equals(role);
        } else if (under(path, "/uploads") || under(path, "/profile") || path.equals("/logout") || path.equals("/")) {
            allowed = true;
        } else {
            return deny(request, response, api, 404, "Không tìm thấy tài nguyên yêu cầu.");
        }
        if (!allowed) {
            return deny(request, response, api, 403, "Bạn không có quyền truy cập chức năng này.");
        }
        return true;
    }

    private boolean unauthenticated(HttpServletRequest request, HttpServletResponse response, boolean api,
                                    String loginPath) throws Exception {
        if (api) {
            WebUtil.writeJson(mapper, response, HttpServletResponse.SC_UNAUTHORIZED,
                    ApiResponse.fail("Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại."));
        } else {
            response.sendRedirect(request.getContextPath() + loginPath);
        }
        return false;
    }

    private boolean deny(HttpServletRequest request, HttpServletResponse response, boolean api, int status,
                         String message) throws Exception {
        if (api) {
            WebUtil.writeJson(mapper, response, status, ApiResponse.fail(message));
        } else {
            WebUtil.forwardError(request, response, status);
        }
        return false;
    }

    private static boolean isPublic(String path) {
        return path.equals("/login") || path.equals("/register") || path.equals("/error") || under(path, "/static");
    }

    private static boolean under(String path, String prefix) {
        return path.equals(prefix) || path.startsWith(prefix + "/");
    }
}
