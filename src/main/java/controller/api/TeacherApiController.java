package controller.api;

import ai.RateLimiter;
import dto.api.ApiResponse;
import dto.api.BatchSaveRequest;
import dto.api.GenerateQuestionsRequest;
import dto.view.LessonView;
import dto.api.QuestionExtractResult;
import dto.api.QuestionGenerationDTO;
import dto.view.SessionUser;
import config.AuthInterceptor;
import service.AiExamService;
import service.LessonService;
import service.QuestionImportService;
import service.QuestionService;
import util.HtmlSanitizer;
import jakarta.validation.Valid;
import java.io.IOException;
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
import org.springframework.web.multipart.MultipartFile;

/**
 * API JSON cho giáo viên (phân quyền TEACHER/ADMIN bởi AuthInterceptor):
 * <ul>
 *   <li>POST /api/teacher/generate-questions - sinh đề bằng Gemini (UC-TEA-05), chạy bất đồng bộ; CHƯA ghi CSDL</li>
 *   <li>POST /api/teacher/extract-question - AI đọc câu hỏi (+ đáp án tùy chọn) từ tệp PDF/Word/ảnh; CHƯA ghi CSDL</li>
 *   <li>POST /api/teacher/questions/batch-save - lưu hàng loạt câu hỏi AI đã duyệt (UC-TEA-06)</li>
 *   <li>GET  /api/teacher/lessons-by-topic - nạp bài học theo chuyên đề cho modal sinh đề</li>
 * </ul>
 */
@RestController
public class TeacherApiController {

    private static final long MAX_UPLOAD_BYTES = 5L * 1024 * 1024;

    private final AiExamService aiExamService;
    private final QuestionImportService importService;
    private final QuestionService questionService;
    private final LessonService lessonService;
    private final RateLimiter rateLimiter;
    private final Executor aiExecutor;

    public TeacherApiController(AiExamService aiExamService, QuestionImportService importService,
                                QuestionService questionService,
                                LessonService lessonService, RateLimiter rateLimiter,
                                @Qualifier("aiExecutor") Executor aiExecutor) {
        this.aiExamService = aiExamService;
        this.importService = importService;
        this.questionService = questionService;
        this.lessonService = lessonService;
        this.rateLimiter = rateLimiter;
        this.aiExecutor = aiExecutor;
    }

    @PostMapping(value = "/api/teacher/generate-questions", consumes = MediaType.APPLICATION_JSON_VALUE)
    public CompletableFuture<ResponseEntity<ApiResponse<List<QuestionGenerationDTO>>>> generateQuestions(
            @Valid @RequestBody GenerateQuestionsRequest req,
            @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user) {
        // Kiểm tra dữ liệu trước, để request không hợp lệ không bị trừ lượt AI (FRS UC-TEA-05 bước 1 → 2)
        if (lessonService.getLessonById(req.lessonId()) == null) {
            throw new IllegalArgumentException("Bài học không tồn tại.");
        }
        rateLimiter.check(user.getUserId(), RateLimiter.Action.QUIZ_GEN); // BR-13: hạn mức giáo viên → 429
        return CompletableFuture.supplyAsync(() -> {
            AiExamService.Result r = aiExamService.generateQuestions(req);
            // warning (nếu có) nằm ở message để modal xem trước hiển thị: "AI chỉ sinh được 4/5 câu hợp lệ."
            return ResponseEntity.ok(ApiResponse.ok(r.warning() != null ? r.warning() : "OK", r.questions()));
        }, aiExecutor);
    }

    /** Tệp tối đa 5MB mỗi tệp (khớp cấu hình multipart); tệp đáp án là tùy chọn, thiếu thì AI tự giải. */
    @PostMapping(value = "/api/teacher/extract-question", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public CompletableFuture<ResponseEntity<ApiResponse<QuestionExtractResult>>> extractQuestion(
            @RequestParam MultipartFile questionFile,
            @RequestParam(required = false) MultipartFile answerFile,
            @RequestParam(defaultValue = "MCQ") String type,
            @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user) {
        // Đọc tệp ngay trên luồng request (tệp tạm của multipart gắn với vòng đời request)
        final byte[] question = readUpload(questionFile);
        final byte[] answer = readUpload(answerFile);
        if (question == null) {
            throw new IllegalArgumentException("Vui lòng chọn tệp đề bài.");
        }
        rateLimiter.check(user.getUserId(), RateLimiter.Action.QUIZ_GEN); // BR-13: hạn mức giáo viên → 429
        return CompletableFuture.supplyAsync(() -> ResponseEntity.ok(ApiResponse.ok(
                importService.extract(question, answer, type))), aiExecutor);
    }

    private static byte[] readUpload(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            return null;
        }
        if (file.getSize() > MAX_UPLOAD_BYTES) {
            throw new IllegalArgumentException("Tệp vượt quá dung lượng tối đa 5MB.");
        }
        try {
            return file.getBytes();
        } catch (IOException e) {
            throw new IllegalArgumentException("Không đọc được tệp tải lên.");
        }
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
            m.put("title", HtmlSanitizer.toPlainText(l.getTitle()));
            result.add(m);
        }
        return ApiResponse.ok(result);
    }
}
