package com.edututor.exception;

/** Vượt hạn mức gọi AI trong giờ (BR-13, NFR-06) → HTTP 429. */
public class AiRateLimitException extends RuntimeException {

    private static final long serialVersionUID = 1L;

    private final long retryAfterMinutes;

    public AiRateLimitException(long retryAfterMinutes) {
        super("Bạn đã dùng hết lượt AI trong giờ này, thử lại sau " + retryAfterMinutes + " phút.");
        this.retryAfterMinutes = retryAfterMinutes;
    }

    public long getRetryAfterMinutes() {
        return retryAfterMinutes;
    }
}
