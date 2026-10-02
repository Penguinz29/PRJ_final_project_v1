package com.edututor.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import java.util.ArrayList;
import java.util.List;

/**
 * Form câu hỏi (VAL-09, 10, 11). {@code action} là create | update | delete như giao diện hiện có.
 * Bốn phương án A-D nhận từ các tham số {@code opt_A…opt_D}; controller gom vào {@link #optionTexts}.
 */
public class QuestionForm {

    private String action = "create";
    private int id;

    @Min(value = 1, message = "{val.question.lesson.required}")
    private int lessonId;

    @Pattern(regexp = "MCQ|ESSAY", message = "{val.question.type.invalid}")
    private String type = "MCQ";

    @Min(value = 1, message = "{val.question.level.invalid}")
    @Max(value = 3, message = "{val.question.level.invalid}")
    private int level = 1;

    @NotBlank(message = "{val.question.content.required}")
    @Size(max = 4000, message = "{val.question.content.size}")
    private String content = "";

    @Size(max = 8000, message = "{val.question.explanation.size}")
    private String explanation;

    private String correctOption = "";

    private List<String> optionTexts = new ArrayList<>();

    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getLessonId() { return lessonId; }
    public void setLessonId(int lessonId) { this.lessonId = lessonId; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public int getLevel() { return level; }
    public void setLevel(int level) { this.level = level; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content == null ? "" : content.trim(); }
    public String getExplanation() { return explanation; }
    public void setExplanation(String explanation) { this.explanation = explanation; }
    public String getCorrectOption() { return correctOption; }
    public void setCorrectOption(String correctOption) { this.correctOption = correctOption == null ? "" : correctOption; }
    public List<String> getOptionTexts() { return optionTexts; }
    public void setOptionTexts(List<String> optionTexts) { this.optionTexts = optionTexts; }
}
