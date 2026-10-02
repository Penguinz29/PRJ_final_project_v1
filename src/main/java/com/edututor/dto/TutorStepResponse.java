package com.edututor.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

/**
 * Kết quả một bước của gia sư AI. Các trường isStepCorrect...isSessionCompleted trùng schema JSON
 * mà Gemini phải trả về; sessionId do server bổ sung.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public record TutorStepResponse(Integer sessionId, @JsonProperty("isStepCorrect") boolean isStepCorrect, int currentStep, int totalSteps,
                                String feedbackToStudent, String nextPromptOrQuestion, @JsonProperty("isSessionCompleted") boolean isSessionCompleted) {

    public TutorStepResponse withSessionId(int id) {
        return new TutorStepResponse(id, isStepCorrect, currentStep, totalSteps,
                feedbackToStudent, nextPromptOrQuestion, isSessionCompleted);
    }
}
