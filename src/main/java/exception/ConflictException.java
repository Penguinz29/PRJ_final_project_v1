package exception;

/** Xung đột nghiệp vụ: trùng dữ liệu, xóa bản ghi còn dữ liệu liên quan... (HTTP 409). */
public class ConflictException extends RuntimeException {

    private static final long serialVersionUID = 1L;

    /** Trường dữ liệu gây xung đột (để hiển thị lỗi tại đúng ô nhập); có thể null. */
    private final String field;

    public ConflictException(String message) {
        this(message, null);
    }

    public ConflictException(String message, String field) {
        super(message);
        this.field = field;
    }

    public String getField() {
        return field;
    }
}
