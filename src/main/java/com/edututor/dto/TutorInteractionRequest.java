package com.edututor.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/** Body của POST /api/tutor/next-step. sessionId = null nghĩa là bắt đầu phiên mới. */
@JsonIgnoreProperties(ignoreUnknown = true)
public record TutorInteractionRequest(Integer sessionId, Integer lessonId,
                                      @NotBlank(message = "{val.tutor.input.required}") @Size(max = 2000, message = "{val.tutor.input.size}") String studentInput,
                                      Integer currentStep) {
}
