package util;

import dto.api.ApiResponse;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.charset.StandardCharsets;

/** Tiện ích dùng chung cho interceptor và bộ xử lý lỗi: nhận diện request API, ghi JSON, chuyển tới trang lỗi. */
public final class WebUtil {

    public static final String VIEW_ERROR_PREFIX = "/WEB-INF/views/error/";

    private WebUtil() {
    }

    /** Đường dẫn trong ứng dụng (đã bỏ context path, do container giải mã và chuẩn hóa sẵn). */
    public static String pathWithinApp(HttpServletRequest request) {
        String path = request.getServletPath();
        if (request.getPathInfo() != null) {
            path += request.getPathInfo();
        }
        return (path == null || path.isEmpty()) ? "/" : path;
    }

    /** Request thuộc /api/** hoặc client yêu cầu JSON (AJAX) → trả JSON thay vì HTML. */
    public static boolean isApi(HttpServletRequest request) {
        String path = pathWithinApp(request);
        String accept = request.getHeader("Accept");
        return path.startsWith("/api/")
                || (accept != null && accept.contains("application/json"))
                || "XMLHttpRequest".equals(request.getHeader("X-Requested-With"));
    }

    public static void writeJson(ObjectMapper mapper, HttpServletResponse response, int status,
                                 ApiResponse<?> body) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json;charset=UTF-8");
        response.getOutputStream().write(mapper.writeValueAsString(body).getBytes(StandardCharsets.UTF_8));
    }

    /** Hiển thị trang lỗi 403 / 404 / 500 (WEB-INF/views/error/NNN.jsp) với đúng mã HTTP. */
    public static void forwardError(HttpServletRequest request, HttpServletResponse response, int status)
            throws IOException {
        int page = (status == 403 || status == 404) ? status : 500;
        response.setStatus(status);
        try {
            request.getRequestDispatcher(VIEW_ERROR_PREFIX + page + ".jsp").forward(request, response);
        } catch (ServletException e) {
            response.sendError(status);
        }
    }
}
