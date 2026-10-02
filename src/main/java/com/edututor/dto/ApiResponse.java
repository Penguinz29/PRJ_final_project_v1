package com.edututor.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.util.List;

/**
 * Định dạng phản hồi chung của mọi endpoint {@code /api/**}:
 * <pre>{ "success": true, "message": "OK", "data": {...}, "errors": null }</pre>
 */
@JsonInclude(JsonInclude.Include.ALWAYS)
public class ApiResponse<T> {

    /** Lỗi theo từng trường dữ liệu. */
    public record FieldError(String field, String message) {
    }

    private final boolean success;
    private final String message;
    private final T data;
    private final List<FieldError> errors;

    private ApiResponse(boolean success, String message, T data, List<FieldError> errors) {
        this.success = success;
        this.message = message;
        this.data = data;
        this.errors = errors;
    }

    public static <T> ApiResponse<T> ok(T data) {
        return new ApiResponse<>(true, "OK", data, null);
    }

    public static <T> ApiResponse<T> ok(String message, T data) {
        return new ApiResponse<>(true, message, data, null);
    }

    public static <T> ApiResponse<T> fail(String message) {
        return new ApiResponse<>(false, message, null, null);
    }

    public static <T> ApiResponse<T> fail(String message, List<FieldError> errors) {
        return new ApiResponse<>(false, message, null, errors);
    }

    public boolean isSuccess() { return success; }
    public String getMessage() { return message; }
    public T getData() { return data; }
    public List<FieldError> getErrors() { return errors; }
}
