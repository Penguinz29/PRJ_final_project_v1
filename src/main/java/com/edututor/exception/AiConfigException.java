package com.edututor.exception;

/**
 * Cấu hình AI chưa đúng: thiếu khóa API / model / prompt, hoặc Gemini từ chối khóa / model (HTTP 400, 401, 403, 404).
 * Không thể khắc phục bằng cách thử lại nên chỉ Admin sửa được; người dùng thấy thông báo thân thiện (HTTP 503),
 * còn chi tiết kỹ thuật ({@link #getDetail()}) chỉ ghi log.
 */
public class AiConfigException extends AiServiceException {

    private static final long serialVersionUID = 1L;

    public static final String USER_MESSAGE = "Cấu hình AI chưa đúng, vui lòng báo quản trị viên.";
    public static final String MODEL_UNAVAILABLE_MESSAGE =
            "Model AI không khả dụng hoặc đã ngừng hỗ trợ, vui lòng báo quản trị viên.";

    private final String detail;

    /** @param httpStatus mã HTTP của Gemini (400/401/403/404), 0 nếu lỗi do thiếu cấu hình trong CSDL */
    public AiConfigException(String detail, int httpStatus) {
        super(httpStatus == 404 ? MODEL_UNAVAILABLE_MESSAGE : USER_MESSAGE, null, httpStatus);
        this.detail = detail;
    }

    /** Chi tiết kỹ thuật cho log và Admin, không hiển thị cho học sinh / giáo viên. */
    public String getDetail() {
        return detail;
    }
}
