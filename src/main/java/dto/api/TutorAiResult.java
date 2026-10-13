package dto.api;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * JSON thô Gemini trả về cho gia sư (FRS 5.1). Chỉ là đề xuất: server chuẩn hóa lại bước, trạng thái chờ dữ liệu
 * và việc hoàn thành phiên trước khi lưu ({@link TutorStepResponse} mới là kết quả gửi cho client).
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public record TutorAiResult(@JsonProperty("isStepCorrect") Boolean isStepCorrect, Integer currentStep,
                            Integer totalSteps, String feedbackToStudent, String nextPromptOrQuestion,
                            Boolean needsStudentInput, String inputRequestHint,
                            @JsonProperty("isSessionCompleted") Boolean isSessionCompleted, String finalSummary) {
}
