package exception;

import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;

/** Cấu hình AI không hợp lệ: mang danh sách lỗi theo từng khóa để hiển thị tại từng trường (UC-ADM-06). */
public class ConfigValidationException extends IllegalArgumentException {

    private static final long serialVersionUID = 1L;

    private final Map<String, String> errors;

    public ConfigValidationException(Map<String, String> errors) {
        super(String.join(" ", errors.values()));
        this.errors = Collections.unmodifiableMap(new LinkedHashMap<>(errors));
    }

    /** Khóa cấu hình → thông báo lỗi (tiếng Việt). */
    public Map<String, String> getErrors() {
        return errors;
    }
}
