package com.edututor.dto;

/** Kết quả chấm bài tự luận viết tay trả về cho học sinh (UC-OCR-01). */
public record EssayOcrResponse(int submissionId, String extractedText, double score, String detailedFeedback,
                               String suggestedCorrection, String imageUrl) {
}
