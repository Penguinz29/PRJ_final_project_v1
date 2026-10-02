package com.edututor.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import java.util.List;

/** Một câu hỏi trắc nghiệm do Gemini sinh ra (FR-TEA-03). */
@JsonIgnoreProperties(ignoreUnknown = true)
public record QuestionGenerationDTO(String content, Integer level, String explanation, List<Option> options) {

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record Option(String letter, String content, @JsonProperty("isCorrect") Boolean isCorrect) {
    }
}
