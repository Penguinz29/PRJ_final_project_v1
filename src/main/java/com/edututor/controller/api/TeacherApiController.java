package com.edututor.controller.api;

import com.edututor.ai.RateLimiter;
import com.edututor.dto.ApiResponse;
import com.edututor.dto.BatchSaveRequest;
import com.edututor.dto.GenerateQuestionsRequest;
import com.edututor.dto.LessonView;
import com.edututor.dto.QuestionGenerationDTO;
import com.edututor.dto.SessionUser;
import com.edututor.interceptor.AuthInterceptor;
import com.edututor.service.AiExamService;
import com.edututor.service.LessonService;
import com.edututor.service.QuestionService;
import jakarta.validation.Valid;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Executor;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.SessionAttribute;

/**
 * API JSON cho giáo viên (phân quyền TEACHER/ADMIN bởi AuthInterceptor):
 * <ul>
 *   <li>POST /api/teacher/generate-questions - sinh đề bằng Gemini (UC-TEA-05), chạy bất đồng bộ; CHƯA ghi CSDL</li>
 *   <li>POST /api/teacher/questions/batch-save - lưu hàng loạt câu hỏi AI đã duyệt (UC-TEA-06)</li>
 *   <li>GET  /api/teacher/lessons-by-topic - nạp bài học theo chuyên đề cho modal sinh đề</li>
 * </ul>
 */
@RestController
public class TeacherApiController {

    private final AiExamService aiExamService;
    private final QuestionService questionService;
    private final LessonService lessonService;
    private final RateLimiter rateLimiter;
    private final Executor aiExecutor;

    public TeacherApiController(AiExamService aiExamService, QuestionService questionService,
                                LessonService lessonService, RateLimiter rateLimiter,
                                @Qualifier("aiExecutor") Executor aiExecutor) {
        this.aiExamService = aiExamService;
        this.questionService = questionService;
        this.lessonService = lessonService;
        this.rateLimiter = rateLimiter;
        this.aiExecutor = aiExecutor;
    }

    @PostMapping(value = "/api/teacher/generate-questions", consumes = MediaType.APPLICATION_JSON_VALUE)
    public CompletableFuture<ResponseEntity<ApiResponse<List<QuestionGenerationDTO>>>> generateQuestions(
            @Valid @RequestBody GenerateQuestionsRequest req,
            @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user) {
        rateLimiter.check(user.getUserId(), RateLimiter.Action.QUIZ_GEN); // BR-13: hạn mức giáo viên → 429
        return CompletableFuture.supplyAsync(
                () -> ResponseEntity.ok(ApiResponse.ok(aiExamService.generateQuestions(req))), aiExecutor);
    }

    @PostMapping(value = "/api/teacher/questions/batch-save", consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<ApiResponse<Map<String, Integer>>> batchSave(
            @Valid @RequestBody BatchSaveRequest req,
            @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user) {
        int saved = questionService.batchSaveAiQuestions(user.getUserId(), req.lessonId(), req.questions());
        return ResponseEntity.ok(ApiResponse.ok("Đã lưu " + saved + " câu hỏi vào ngân hàng đề thành công!",
                Map.of("saved", saved)));
    }

    @GetMapping("/api/teacher/lessons-by-topic")
    public ApiResponse<List<Map<String, Object>>> lessonsByTopic(@RequestParam(defaultValue = "0") int topicId) {
        List<Map<String, Object>> result = new java.util.ArrayList<>();
        for (LessonView l : lessonService.getLessonsByTopic(topicId)) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("lessonId", l.getLessonId());
            m.put("title", l.getTitle());
            result.add(m);
        }
        return ApiResponse.ok(result);
    }
}
