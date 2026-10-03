package com.edututor.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/** Form bài học (VAL-07); video / liên kết / văn bản của bài học là "bài giảng" (MaterialForm). {@code action} là create | update | delete như giao diện hiện có. */
public class LessonForm {

    private String action = "create";
    private int id;

    @Min(value = 1, message = "{val.lesson.topic.required}")
    private int topicId;

    @NotBlank(message = "{val.lessonName.required}")
    @Size(min = 3, max = 200, message = "{val.lessonName.size}")
    private String title = "";

    @Size(max = 500, message = "{val.lesson.summary.size}")
    private String summary = "";

    @Size(max = 100000, message = "{val.lesson.content.size}")
    private String content = "";

    private Integer displayOrder;

    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getTopicId() { return topicId; }
    public void setTopicId(int topicId) { this.topicId = topicId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title == null ? "" : title.trim(); }
    public String getSummary() { return summary; }
    public void setSummary(String summary) { this.summary = summary == null ? "" : summary.trim(); }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content == null ? "" : content.trim(); }
    public Integer getDisplayOrder() { return displayOrder; }
    public void setDisplayOrder(Integer displayOrder) { this.displayOrder = displayOrder; }
}
