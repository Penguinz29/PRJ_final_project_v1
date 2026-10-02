package com.edututor.exception;

/** AI trả dữ liệu không dùng được (sai JSON / sai schema) sau khi đã thử lại hết số lần cho phép (HTTP 422). */
public class AiParseException extends AiServiceException {

    private static final long serialVersionUID = 1L;

    public AiParseException(String message, Throwable cause) {
        super(message, cause, 422);
    }
}
