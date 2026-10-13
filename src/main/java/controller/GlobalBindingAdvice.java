package controller;

import java.beans.PropertyEditorSupport;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.InitBinder;

/**
 * Cấu hình binding dùng chung cho mọi controller: ô số nguyên (kiểu {@code int}) gửi lên rỗng — ví dụ trường ẩn
 * {@code topicId=""} / {@code id=""} khi TẠO MỚI bằng modal dùng chung với SỬA — được hiểu là 0 thay vì gây lỗi
 * "Failed to convert property value of type 'java.lang.String' to required type 'int'".
 * Giá trị không phải số (vd. "abc") vẫn báo lỗi chuyển kiểu bình thường.
 */
@ControllerAdvice
public class GlobalBindingAdvice {

    @InitBinder
    public void initBinder(WebDataBinder binder) {
        binder.registerCustomEditor(int.class, new PropertyEditorSupport() {
            @Override
            public void setAsText(String text) {
                String t = text == null ? "" : text.trim();
                setValue(t.isEmpty() ? 0 : Integer.valueOf(t));
            }
        });
    }
}
