package dto.api;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

/**
 * Body của POST /api/teacher/generate-questions.
 * difficultyLevel nhận 1|2|3 hoặc EASY|MEDIUM|HARD|ADVANCED (JSON số cũng được chấp nhận).
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public record GenerateQuestionsRequest(
        @NotNull(message = "{val.generate.lesson.required}") @Min(value = 1, message = "{val.generate.lesson.required}") Integer lessonId,
        String difficultyLevel,
        @Min(value = 1, message = "{val.generate.count.range}") @Max(value = 10, message = "{val.generate.count.range}") Integer count) {
}
