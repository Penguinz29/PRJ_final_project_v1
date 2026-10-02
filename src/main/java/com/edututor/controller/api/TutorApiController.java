package com.edututor.controller.api;

import com.edututor.dto.ApiResponse;
import com.edututor.dto.SessionUser;
import com.edututor.dto.TutorInteractionRequest;
import com.edututor.dto.TutorStepResponse;
import com.edututor.interceptor.AuthInterceptor;
import com.edututor.service.AiTutorService;
import jakarta.validation.Valid;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Executor;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.SessionAttribute;

/**
 * Gia sư AI step-by-step. POST /api/tutor/next-step chạy bất đồng bộ trên executor AI (CompletableFuture)
 * nên không chiếm luồng Tomcat trong 3-5 giây chờ Gemini (NFR-02). studentId lấy từ session (đọc ở đây,
 * trước khi chuyển sang luồng khác).
 */
@RestController
public class TutorApiController {

    private final AiTutorService tutorService;
    private final Executor aiExecutor;

    public TutorApiController(AiTutorService tutorService, @Qualifier("aiExecutor") Executor aiExecutor) {
        this.tutorService = tutorService;
        this.aiExecutor = aiExecutor;
    }

    @PostMapping(value = "/api/tutor/next-step", consumes = MediaType.APPLICATION_JSON_VALUE)
    public CompletableFuture<ResponseEntity<ApiResponse<TutorStepResponse>>> nextStep(
            @Valid @RequestBody TutorInteractionRequest req,
            @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user) {
        final int studentId = user.getUserId();
        return CompletableFuture.supplyAsync(
                () -> ResponseEntity.ok(ApiResponse.ok(tutorService.nextStep(studentId, req))), aiExecutor);
    }
}
