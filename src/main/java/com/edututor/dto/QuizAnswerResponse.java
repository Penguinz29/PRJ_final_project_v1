package com.edututor.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

/** Kết quả chấm một câu trắc nghiệm (FRS 5.2). */
public record QuizAnswerResponse(@JsonProperty("isCorrect") boolean isCorrect, String correctOptionLabel, String explanationLatex, double score) {
}
