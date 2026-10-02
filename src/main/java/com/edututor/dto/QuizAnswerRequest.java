package com.edututor.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.validation.constraints.NotNull;

/** Body của POST /api/student/submit-quiz-answer. */
@JsonIgnoreProperties(ignoreUnknown = true)
public record QuizAnswerRequest(@NotNull(message = "{val.quiz.question.required}") Integer questionId,
                                @NotNull(message = "{val.quiz.option.required}") Integer selectedOptionId) {
}
