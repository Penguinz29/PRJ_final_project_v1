package com.edututor.interceptor;

import com.edututor.dto.ApiResponse;
import com.edututor.util.WebUtil;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.DispatcherType;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.HexFormat;
import java.util.Set;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * Chống CSRF: sinh token ngẫu nhiên lưu trong {@code session["CSRF_TOKEN"]}. Form JSP gửi trường ẩn {@code _csrf},
 * Fetch gửi header {@code X-CSRF-TOKEN}. Mọi POST / PUT / PATCH / DELETE thiếu hoặc sai token → 403.
 */
@Component
public class CsrfInterceptor implements HandlerInterceptor {

    public static final String SESSION_TOKEN = "CSRF_TOKEN";
    public static final String PARAM_NAME = "_csrf";
    public static final String HEADER_NAME = "X-CSRF-TOKEN";

    private static final Set<String> SAFE_METHODS = Set.of("GET", "HEAD", "OPTIONS", "TRACE");
    private static final SecureRandom RANDOM = new SecureRandom();

    private final ObjectMapper mapper;

    public CsrfInterceptor(ObjectMapper mapper) {
        this.mapper = mapper;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
            throws Exception {
        if (request.getDispatcherType() == DispatcherType.ASYNC) {
            return true;
        }
        HttpSession session = request.getSession(true);
        String expected = (String) session.getAttribute(SESSION_TOKEN);
        if (expected == null) {
            expected = newToken();
            session.setAttribute(SESSION_TOKEN, expected);
        }
        if (SAFE_METHODS.contains(request.getMethod())) {
            return true;
        }
        String actual = request.getHeader(HEADER_NAME);
        if (actual == null || actual.isEmpty()) {
            actual = request.getParameter(PARAM_NAME);
        }
        if (actual != null && MessageDigest.isEqual(expected.getBytes(StandardCharsets.UTF_8),
                actual.getBytes(StandardCharsets.UTF_8))) {
            return true;
        }
        if (WebUtil.isApi(request)) {
            WebUtil.writeJson(mapper, response, HttpServletResponse.SC_FORBIDDEN,
                    ApiResponse.fail("Phiên làm việc không hợp lệ (thiếu hoặc sai mã CSRF). Hãy tải lại trang."));
        } else {
            WebUtil.forwardError(request, response, HttpServletResponse.SC_FORBIDDEN);
        }
        return false;
    }

    /** Sinh mã CSRF mới (dùng khi đăng nhập để thay token cùng lúc đổi session ID). */
    public static String newToken() {
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        return HexFormat.of().formatHex(bytes);
    }
}
