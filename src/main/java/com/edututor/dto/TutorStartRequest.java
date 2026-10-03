package com.edututor.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.validation.constraints.Size;

/**
 * Body của POST /api/tutor/start (UC-TUT-01). Trường bắt buộc phụ thuộc {@code mode}:
 * FREE: problemText (lessonId tùy chọn) • LESSON: lessonId + problemText •
 * QUESTION: questionId (học sinh phải có bài nộp sai câu này; selectedOptionId tùy chọn) •
 * SUBMISSION: submissionId (bài tự luận của chính học sinh).
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public record TutorStartRequest(String mode,
                                @Size(max = 2000, message = "{val.tutor.input.size}") String problemText,
                                Integer lessonId, Integer questionId, Integer selectedOptionId,
                                Integer submissionId) {
}
