package controller.api;

import dto.api.ApiResponse;
import exception.AiServiceException;
import service.AiConfigService;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Executor;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/** UC-ADM-07: kiểm tra kết nối Gemini. Chạy bất đồng bộ trên executor AI để không chặn luồng Tomcat. */
@RestController
public class AdminApiController {

    private final AiConfigService aiConfigService;
    private final Executor aiExecutor;

    public AdminApiController(AiConfigService aiConfigService, @Qualifier("aiExecutor") Executor aiExecutor) {
        this.aiConfigService = aiConfigService;
        this.aiExecutor = aiExecutor;
    }

    /** Có thể thử giá trị CHƯA lưu (GEMINI_API_KEY, DEFAULT_MODEL trong form); thiếu thì dùng giá trị trong CSDL. */
    @PostMapping("/api/admin/ai-config/test-connection")
    public CompletableFuture<ResponseEntity<ApiResponse<Void>>> testConnection(
            @RequestParam(name = "GEMINI_API_KEY", required = false) String apiKey,
            @RequestParam(name = "DEFAULT_MODEL", required = false) String model) {
        return CompletableFuture.supplyAsync(() -> {
            try {
                return ResponseEntity.ok(ApiResponse.<Void>ok(aiConfigService.testConnection(apiKey, model), null));
            } catch (AiServiceException e) {
                return ResponseEntity.ok(ApiResponse.<Void>fail(friendly(e)));
            } catch (IllegalArgumentException e) {
                return ResponseEntity.ok(ApiResponse.<Void>fail(e.getMessage()));
            }
        }, aiExecutor);
    }

    /** Ánh xạ mã lỗi của Gemini sang thông báo thân thiện. */
    private String friendly(AiServiceException e) {
        // Trang này chỉ Admin dùng: kèm nguyên văn lý do của Google (không chứa khóa API) để biết sửa model nào
        String base = friendlyBase(e);
        if (e instanceof exception.AiConfigException cfg && cfg.getDetail() != null) {
            return base + " Chi tiết: " + cfg.getDetail();
        }
        return base;
    }

    private String friendlyBase(AiServiceException e) {
        return switch (e.getHttpStatus()) {
            case 400, 401, 403 -> "Khóa API hoặc model không hợp lệ.";
            case 404 -> "Model không tồn tại hoặc đã ngừng hỗ trợ.";
            case 429 -> "Hết hạn mức sử dụng Gemini API.";
            case 504 -> "Quá thời gian chờ phản hồi từ Gemini.";
            case 502 -> "Không kết nối được tới Google.";
            default -> e.getMessage();
        };
    }
}
