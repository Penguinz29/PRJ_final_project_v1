package com.edututor.controller.api;

import com.edututor.ai.RateLimiter;
import com.edututor.dto.ApiResponse;
import com.edututor.dto.SessionUser;
import com.edututor.dto.TutorInteractionRequest;
import com.edututor.dto.TutorStartRequest;
import com.edututor.dto.TutorStepResponse;
import com.edututor.interceptor.AuthInterceptor;
import com.edututor.service.AiTutorService;
import jakarta.validation.Valid;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Executor;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.SessionAttribute;

/**
 * Gia sư AI từng bước (UC-TUT-01..04). Các lời gọi AI chạy bất đồng bộ trên executor AI (CompletableFuture)
 * nên không chiếm luồng Tomcat trong lúc chờ Gemini (NFR-02). studentId lấy từ session (đọc ở đây, trước khi
 * chuyển sang luồng khác); hạn mức gọi AI được kiểm tra trên luồng request (BR-13 → 429).
 */
@RestController
public class TutorApiController {

    private final AiTutorService tutorService;
    private final RateLimiter rateLimiter;
    private final Executor aiExecutor;

    public TutorApiController(AiTutorService tutorService, RateLimiter rateLimiter,
                              @Qualifier("aiExecutor") Executor aiExecutor) {
        this.tutorService = tutorService;
        this.rateLimiter = rateLimiter;
        this.aiExecutor = aiExecutor;
    }

    /** UC-TUT-01: mở phiên (mode FREE | LESSON | QUESTION | SUBMISSION). */
    @PostMapping(value = "/api/tutor/start", consumes = MediaType.APPLICATION_JSON_VALUE)
    public CompletableFuture<ResponseEntity<ApiResponse<TutorStepResponse>>> start(
            @Valid @RequestBody TutorStartRequest req,
            @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user) {
        final int studentId = user.getUserId();
        rateLimiter.check(studentId, RateLimiter.Action.STUDENT_AI); // BR-13: vượt hạn mức → 429
        return CompletableFuture.supplyAsync(
                () -> ResponseEntity.ok(ApiResponse.ok(tutorService.start(studentId, req))), aiExecutor);
    }

    /** UC-TUT-02/03: một lượt trả lời hoặc cung cấp dữ liệu. */
    @PostMapping(value = "/api/tutor/next-step", consumes = MediaType.APPLICATION_JSON_VALUE)
    public CompletableFuture<ResponseEntity<ApiResponse<TutorStepResponse>>> nextStep(
            @Valid @RequestBody TutorInteractionRequest req,
            @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user) {
        final int studentId = user.getUserId();
        rateLimiter.check(studentId, RateLimiter.Action.STUDENT_AI); // BR-13: vượt hạn mức → 429
        return CompletableFuture.supplyAsync(
                () -> ResponseEntity.ok(ApiResponse.ok(tutorService.nextStep(studentId, req))), aiExecutor);
    }

    /** UC-TUT-04: kết thúc phiên sớm → ABANDONED (không gọi AI). */
    @PostMapping("/api/tutor/{sessionId}/abandon")
    public ApiResponse<Void> abandon(@PathVariable int sessionId,
                                     @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user) {
        tutorService.abandon(user.getUserId(), sessionId);
        return ApiResponse.ok("Đã kết thúc phiên gia sư.", null);
    }
}
