package com.edututor.exception;

/** Sai chủ sở hữu hoặc không đủ quyền thao tác (HTTP 403). */
public class ForbiddenException extends RuntimeException {

    private static final long serialVersionUID = 1L;

    public ForbiddenException(String message) {
        super(message);
    }
}
