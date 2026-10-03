package com.edututor.controller.api;

import com.edututor.ai.RateLimiter;
import com.edututor.dto.ApiResponse;
import com.edututor.dto.EssayOcrResponse;
import com.edututor.dto.QuizAnswerRequest;
import com.edututor.dto.QuizAnswerResponse;
import com.edututor.dto.SessionUser;
import com.edututor.interceptor.AuthInterceptor;
import com.edututor.service.EssayGradingService;
import com.edututor.service.SubmissionService;
import jakarta.validation.Valid;
import java.io.IOException;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Executor;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.SessionAttribute;
import org.springframework.web.multipart.MultipartFile;

/**
 * API JSON cho học sinh (studentId luôn lấy từ session, không tin dữ liệu client):
 * <ul>
 *   <li>POST /api/student/submit-quiz-answer - chấm 1 câu trắc nghiệm (UC-STU-04)</li>
 *   <li>POST /api/student/submit-essay-ocr - chấm tự luận viết tay bằng Gemini Vision (UC-OCR-01)</li>
 * </ul>
 * Cuộc gọi AI chạy bất đồng bộ trên executor riêng (CompletableFuture) để không chặn luồng Tomcat (NFR-02).
 */
@RestController
public class StudentApiController {

    private final SubmissionService submissionService;
    private final EssayGradingService essayGradingService;
    private final RateLimiter rateLimiter;
    private final Executor aiExecutor;

    public StudentApiController(SubmissionService submissionService, EssayGradingService essayGradingService,
                                RateLimiter rateLimiter, @Qualifier("aiExecutor") Executor aiExecutor) {
        this.submissionService = submissionService;
        this.essayGradingService = essayGradingService;
        this.rateLimiter = rateLimiter;
        this.aiExecutor = aiExecutor;
    }

    @PostMapping(value = "/api/student/submit-quiz-answer", consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<ApiResponse<QuizAnswerResponse>> submitQuizAnswer(
            @Valid @RequestBody QuizAnswerRequest req,
            @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user) {
        return ResponseEntity.ok(ApiResponse.ok(
                submissionService.submitMcqAnswer(user.getUserId(), req.questionId(), req.selectedOptionId())));
    }

    @PostMapping(value = "/api/student/submit-essay-ocr", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public CompletableFuture<ResponseEntity<ApiResponse<EssayOcrResponse>>> submitEssayOcr(
            @RequestParam int questionId,
            @RequestParam(required = false) MultipartFile essayImage,
            @RequestParam(required = false) String studentAnswer,
            @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user) {
        // Đọc nội dung tệp ngay trên luồng request (tệp tạm của multipart gắn với vòng đời request)
        final byte[] bytes;
        try {
            bytes = (essayImage == null || essayImage.isEmpty()) ? null : essayImage.getBytes();
        } catch (IOException e) {
            throw new IllegalArgumentException("Không đọc được ảnh tải lên.");
        }
        final int studentId = user.getUserId();
        rateLimiter.check(studentId, RateLimiter.Action.STUDENT_AI); // BR-13: dùng chung hạn mức với gia sư
        return CompletableFuture.supplyAsync(() -> ResponseEntity.ok(ApiResponse.ok(
                essayGradingService.gradeAndSave(studentId, questionId, bytes, studentAnswer))), aiExecutor);
    }
}
