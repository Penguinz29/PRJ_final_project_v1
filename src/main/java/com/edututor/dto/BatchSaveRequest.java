package com.edututor.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import java.util.List;

/** Body của POST /teacher/questions/batch-save: lưu hàng loạt câu hỏi do AI sinh. */
@JsonIgnoreProperties(ignoreUnknown = true)
public record BatchSaveRequest(@NotNull(message = "{val.generate.lesson.required}") Integer lessonId,
                               @NotEmpty(message = "{val.batch.empty}") List<QuestionGenerationDTO> questions) {
}
