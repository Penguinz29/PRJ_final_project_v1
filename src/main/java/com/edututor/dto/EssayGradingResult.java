package com.edututor.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import java.util.List;

/**
 * JSON mà Gemini Vision trả về khi chấm bài tự luận (FRS UC-OCR-02, GradingAiResult).
 * legible = false: ảnh không đọc được / không phải bài giải toán → không chấm, không lưu (TC-OCR-03).
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public record EssayGradingResult(Boolean legible, String extractedText, Double score, String detailedFeedback,
                                 List<ErrorItem> errors, String suggestedCorrection) {

    /** Một lỗi sai cụ thể: vị trí (dòng / bước) và mô tả. */
    @JsonIgnoreProperties(ignoreUnknown = true)
    public record ErrorItem(String location, String description) {
    }
}
