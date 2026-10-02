package com.edututor.exception;

/** Lỗi khi gọi Gemini API (timeout, HTTP lỗi, JSON không hợp lệ sau khi thử lại). */
public class AiServiceException extends RuntimeException {

    private static final long serialVersionUID = 1L;

    /** Mã HTTP của Gemini (nếu có), 0 nếu lỗi không đến từ phản hồi HTTP. */
    private final int httpStatus;

    public AiServiceException(String message) {
        this(message, null, 0);
    }

    public AiServiceException(String message, Throwable cause) {
        this(message, cause, 0);
    }

    public AiServiceException(String message, Throwable cause, int httpStatus) {
        super(message, cause);
        this.httpStatus = httpStatus;
    }

    public int getHttpStatus() {
        return httpStatus;
    }

    /** Lỗi tạm thời đáng thử lại: quá tải (429), lỗi server Gemini (5xx), timeout, mất kết nối. */
    public boolean isTransient() {
        return httpStatus == 429 || httpStatus >= 500;
    }
}
