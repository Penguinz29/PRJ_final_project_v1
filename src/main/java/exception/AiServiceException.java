package exception;

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

    /** true: {@code message} do hệ thống tự viết (hàng đợi AI đầy, AI trả dữ liệu hỏng, ảnh không đọc được) nên được hiển thị. */
    private final boolean userFacing;

    public AiServiceException(String message, Throwable cause, int httpStatus) {
        this(message, cause, httpStatus, false);
    }

    public AiServiceException(String message, Throwable cause, int httpStatus, boolean userFacing) {
        super(message, cause);
        this.httpStatus = httpStatus;
        this.userFacing = userFacing;
    }

    /** Lỗi do hệ thống tự tạo với thông báo an toàn để hiển thị; mã HTTP trả về đúng bằng {@code httpStatus}. */
    public static AiServiceException userFacing(String message, int httpStatus) {
        return new AiServiceException(message, null, httpStatus, true);
    }

    public boolean isUserFacing() {
        return userFacing;
    }

    public int getHttpStatus() {
        return httpStatus;
    }

    /** Lỗi tạm thời đáng thử lại: quá tải (429), lỗi server Gemini (5xx), timeout, mất kết nối. */
    public boolean isTransient() {
        return httpStatus == 429 || httpStatus >= 500;
    }
}
