package util;

import java.util.Comparator;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;

/** Gom lỗi Bean Validation của một form thành một thông báo tiếng Việt để hiển thị dạng flash. */
public final class FormErrors {

    private FormErrors() {
    }

    /** Thông báo lỗi đầu tiên; lỗi "bắt buộc nhập" (NotBlank/NotNull) được ưu tiên trước lỗi độ dài/định dạng. */
    public static String first(BindingResult result) {
        return result.getFieldErrors().stream()
                .sorted(Comparator.comparingInt(FormErrors::priority))
                .map(FieldError::getDefaultMessage)
                .findFirst().orElse("Dữ liệu không hợp lệ.");
    }

    /** Ném IllegalArgumentException (→ flash lỗi) nếu form có lỗi Bean Validation. */
    public static void requireValid(BindingResult result) {
        if (result.hasErrors()) {
            throw new IllegalArgumentException(first(result));
        }
    }

    private static int priority(FieldError e) {
        return ("NotBlank".equals(e.getCode()) || "NotNull".equals(e.getCode())) ? 0 : 1;
    }
}
