package com.edututor.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

/** JSON mà Gemini Vision trả về khi chấm bài tự luận. */
@JsonIgnoreProperties(ignoreUnknown = true)
public record EssayGradingResult(String extractedText, Double score, String detailedFeedback, String suggestedCorrection) {
}
