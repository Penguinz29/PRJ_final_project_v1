package com.edututor.exception;

import com.edututor.dto.ApiResponse;
import com.edututor.util.WebUtil;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.ConstraintViolationException;
import java.io.IOException;
import java.net.URI;
import java.security.SecureRandom;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Set;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.TypeMismatchException;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.validation.BindException;
import org.springframework.web.ErrorResponse;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.servlet.FlashMap;
import org.springframework.web.servlet.support.RequestContextUtils;

/**
 * Xử lý ngoại lệ tập trung. Request {@code /api/**} (hoặc AJAX) nhận JSON {@link ApiResponse}; request trang:
 * lỗi người dùng tự khắc phục được thì quay lại trang trước kèm thông báo (flash), còn lại hiện trang lỗi
 * 403 / 404 / 500. Không bao giờ trả stack trace hay câu SQL ra người dùng.
 */
@ControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);
    private static final SecureRandom RANDOM = new SecureRandom();

    /** Các mã lỗi mà người dùng có thể tự khắc phục: hiển thị thông báo ngay trên trang trước. */
    private static final Set<Integer> RECOVERABLE = Set.of(400, 409, 422, 502, 503, 504);

    private final ObjectMapper mapper;

    public GlobalExceptionHandler(ObjectMapper mapper) {
        this.mapper = mapper;
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public void handleBadRequest(IllegalArgumentException ex, HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        respond(HttpStatus.BAD_REQUEST, ex.getMessage(), null, req, res);
    }

    /** @Valid @RequestBody không hợp lệ → 400 kèm danh sách lỗi theo trường. */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public void handleInvalidBody(MethodArgumentNotValidException ex, HttpServletRequest req,
                                  HttpServletResponse res) throws IOException {
        respond(HttpStatus.BAD_REQUEST, "Dữ liệu không hợp lệ", fieldErrors(ex), req, res);
    }

    @ExceptionHandler(BindException.class)
    public void handleBind(BindException ex, HttpServletRequest req, HttpServletResponse res) throws IOException {
        respond(HttpStatus.BAD_REQUEST, "Dữ liệu không hợp lệ", fieldErrors(ex), req, res);
    }

    @ExceptionHandler(ConstraintViolationException.class)
    public void handleConstraint(ConstraintViolationException ex, HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        List<ApiResponse.FieldError> errors = ex.getConstraintViolations().stream()
                .map(v -> new ApiResponse.FieldError(v.getPropertyPath().toString(), v.getMessage())).toList();
        respond(HttpStatus.BAD_REQUEST, "Dữ liệu không hợp lệ", errors, req, res);
    }

    /** Tham số sai kiểu (vd. lessonId=abc) hoặc JSON body hỏng → 400. */
    @ExceptionHandler({TypeMismatchException.class, HttpMessageNotReadableException.class})
    public void handleUnreadable(Exception ex, HttpServletRequest req, HttpServletResponse res) throws IOException {
        respond(HttpStatus.BAD_REQUEST, "Dữ liệu gửi lên không hợp lệ.", null, req, res);
    }

    @ExceptionHandler(MaxUploadSizeExceededException.class)
    public void handleUploadTooLarge(MaxUploadSizeExceededException ex, HttpServletRequest req,
                                     HttpServletResponse res) throws IOException {
        respond(HttpStatus.BAD_REQUEST, "Tệp tải lên vượt quá dung lượng cho phép (tối đa 5MB).", null, req, res);
    }

    @ExceptionHandler(ForbiddenException.class)
    public void handleForbidden(ForbiddenException ex, HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        respond(HttpStatus.FORBIDDEN, ex.getMessage(), null, req, res);
    }

    @ExceptionHandler(NotFoundException.class)
    public void handleNotFound(NotFoundException ex, HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        respond(HttpStatus.NOT_FOUND, ex.getMessage(), null, req, res);
    }

    @ExceptionHandler(ConflictException.class)
    public void handleConflict(ConflictException ex, HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        respond(HttpStatus.CONFLICT, ex.getMessage(), null, req, res);
    }

    /** Vi phạm UNIQUE / FK của CSDL (lớp kiểm tra thứ 4) → 409, không lộ nội dung SQL. */
    @ExceptionHandler(DataIntegrityViolationException.class)
    public void handleDataIntegrity(DataIntegrityViolationException ex, HttpServletRequest req,
                                    HttpServletResponse res) throws IOException {
        log.warn("Vi phạm ràng buộc CSDL tại {} {}", req.getMethod(), req.getRequestURI());
        respond(HttpStatus.CONFLICT, "Dữ liệu bị trùng hoặc đang được sử dụng ở nơi khác nên không thể thực hiện.",
                null, req, res);
    }

    /** Lỗi gọi Gemini: 504 hết thời gian, 503 hệ thống bận, 422 dữ liệu không dùng được, còn lại 502. */
    @ExceptionHandler(AiServiceException.class)
    public void handleAi(AiServiceException ex, HttpServletRequest req, HttpServletResponse res) throws IOException {
        log.warn("Lỗi dịch vụ AI: {}", ex.getMessage());
        HttpStatus status = switch (ex.getHttpStatus()) {
            case 504 -> HttpStatus.GATEWAY_TIMEOUT;
            case 503 -> HttpStatus.SERVICE_UNAVAILABLE;
            case 422 -> HttpStatus.UNPROCESSABLE_ENTITY;
            default -> HttpStatus.BAD_GATEWAY;
        };
        respond(status, ex.getMessage(), null, req, res);
    }

    /** Mọi ngoại lệ còn lại → ghi log chi tiết kèm mã tham chiếu, trả 500 với thông báo thân thiện. */
    @ExceptionHandler(Exception.class)
    public void handleAny(Exception ex, HttpServletRequest req, HttpServletResponse res) throws IOException {
        // Ngoại lệ chuẩn của Spring MVC (404, 405, 415...) đã mang sẵn mã trạng thái đúng
        if (ex instanceof ErrorResponse er) {
            HttpStatusCode code = er.getStatusCode();
            respond(code, friendly(code), null, req, res);
            return;
        }
        String ref = "ERR-" + LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE) + "-"
                + String.format("%04x", RANDOM.nextInt(0x10000));
        log.error("Lỗi không mong đợi [{}] tại {} {}", ref, req.getMethod(), req.getRequestURI(), ex);
        req.setAttribute("errorRef", ref);
        respond(HttpStatus.INTERNAL_SERVER_ERROR,
                "Hệ thống đang gặp sự cố. Vui lòng thử lại sau. Mã tham chiếu: " + ref, null, req, res);
    }

    private List<ApiResponse.FieldError> fieldErrors(BindException ex) {
        return ex.getBindingResult().getFieldErrors().stream()
                .map(f -> new ApiResponse.FieldError(f.getField(), f.getDefaultMessage())).toList();
    }

    private String friendly(HttpStatusCode code) {
        return switch (code.value()) {
            case 404 -> "Không tìm thấy tài nguyên yêu cầu.";
            case 405 -> "Phương thức yêu cầu không được hỗ trợ.";
            default -> "Yêu cầu không hợp lệ.";
        };
    }

    private void respond(HttpStatusCode status, String message, List<ApiResponse.FieldError> errors,
                         HttpServletRequest req, HttpServletResponse res) throws IOException {
        if (res.isCommitted()) {
            return;
        }
        String text = (errors == null || errors.isEmpty()) ? message : message + ": " + joinErrors(errors);
        if (WebUtil.isApi(req)) {
            WebUtil.writeJson(mapper, res, status.value(), ApiResponse.fail(text, errors));
            return;
        }
        int code = status.value();
        if (RECOVERABLE.contains(code)) {
            FlashMap flash = RequestContextUtils.getOutputFlashMap(req);
            flash.put("errorFlash", text);
            String target = backTarget(req);
            RequestContextUtils.saveOutputFlashMap(target, req, res);
            res.sendRedirect(res.encodeRedirectURL(target));
            return;
        }
        req.setAttribute("errorMessage", message);
        WebUtil.forwardError(req, res, code);
    }

    private String joinErrors(List<ApiResponse.FieldError> errors) {
        return String.join("; ", errors.stream().map(ApiResponse.FieldError::message).toList());
    }

    /** Quay lại trang trước (Referer cùng máy chủ), nếu không có thì về trang gốc của ứng dụng. */
    private String backTarget(HttpServletRequest req) {
        String fallback = req.getContextPath() + "/";
        String referer = req.getHeader("Referer");
        if (referer == null || referer.isBlank()) {
            return fallback;
        }
        try {
            URI uri = URI.create(referer);
            if (req.getServerName().equalsIgnoreCase(uri.getHost()) && uri.getRawPath() != null
                    && uri.getRawPath().startsWith(req.getContextPath())) {
                return uri.getRawPath() + (uri.getRawQuery() == null ? "" : "?" + uri.getRawQuery());
            }
        } catch (IllegalArgumentException ignored) {
            // Referer không hợp lệ → dùng trang gốc
        }
        return fallback;
    }
}
