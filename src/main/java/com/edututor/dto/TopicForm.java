package com.edututor.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/** Form chuyên đề (VAL-06). {@code action} là create | update | delete như giao diện hiện có. */
public class TopicForm {

    private String action = "create";
    private int id;
    private int topicId;

    @NotBlank(message = "{val.topicName.required}")
    @Size(min = 3, max = 200, message = "{val.topicName.size}")
    private String topicName = "";

    @Size(max = 4000, message = "{val.description.size}")
    private String description = "";

    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getTopicId() { return topicId; }
    public void setTopicId(int topicId) { this.topicId = topicId; }
    public String getTopicName() { return topicName; }
    public void setTopicName(String topicName) { this.topicName = topicName == null ? "" : topicName.trim(); }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description == null ? "" : description.trim(); }
}
