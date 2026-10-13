package dto.api;

import java.util.List;

/**
 * Kết quả chấm bài tự luận trả về cho học sinh (UC-OCR-02 bước 7). status luôn là AI_GRADED: điểm chỉ là điểm
 * tạm thời cho tới khi giáo viên duyệt (BR-09). canAskTutor: có lỗi sai → hiện nút "Hỏi gia sư AI về lỗi sai".
 */
public record EssayOcrResponse(int submissionId, String extractedText, double score, String detailedFeedback,
                               List<EssayGradingResult.ErrorItem> errors, String suggestedCorrection, String imageUrl,
                               String status, boolean canAskTutor) {
}
