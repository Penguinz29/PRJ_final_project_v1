package dto.api;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Kết quả một lượt gia sư gửi cho client (UC-TUT-02), đã được server chuẩn hóa.
 * isStepCorrect = null ở lượt khởi đầu và ở lượt chờ / nhận dữ liệu (BR-15).
 * status: ACTIVE | COMPLETED; finalSummary chỉ có khi hoàn thành.
 */
public record TutorStepResponse(Integer sessionId, int currentStep, int totalSteps,
                                @JsonProperty("isStepCorrect") Boolean isStepCorrect,
                                String feedbackToStudent, String nextPromptOrQuestion,
                                boolean needsStudentInput, String inputRequestHint,
                                String status, String finalSummary) {

    /** Giữ khóa isSessionCompleted cho giao diện cũ. */
    @JsonProperty("isSessionCompleted")
    public boolean isSessionCompleted() {
        return "COMPLETED".equals(status);
    }

    public TutorStepResponse withSessionId(int id) {
        return new TutorStepResponse(id, currentStep, totalSteps, isStepCorrect, feedbackToStudent,
                nextPromptOrQuestion, needsStudentInput, inputRequestHint, status, finalSummary);
    }
}
