package dto.api;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Kết quả chấm một câu trắc nghiệm (UC-STU-04). Chỉ gửi sau khi học sinh đã nộp câu đó (BR-11).
 * canAskTutor: trả lời sai → hiện nút "Hỏi gia sư AI" (FR-STU-05).
 */
public record QuizAnswerResponse(@JsonProperty("isCorrect") boolean isCorrect, Integer correctOptionId,
                                 String correctOptionLabel, String explanationLatex, double score,
                                 boolean canAskTutor) {
}
