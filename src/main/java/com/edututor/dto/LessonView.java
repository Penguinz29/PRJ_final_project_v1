package com.edututor.dto;

import java.io.Serializable;
import java.util.Date;

public class LessonView implements Serializable {
    private int lessonId;
    private int topicId;
    private String title;
    private String summary;
    private String content;
    private String youtubeUrl;
    private int displayOrder;
    private Date createdAt;

    // Expand
    private String topicName;
    private int questionCount;

    public LessonView() {
    }

    public int getLessonId() {
        return lessonId;
    }

    public void setLessonId(int lessonId) {
        this.lessonId = lessonId;
    }

    public int getTopicId() {
        return topicId;
    }

    public void setTopicId(int topicId) {
        this.topicId = topicId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getSummary() {
        return summary;
    }

    public void setSummary(String summary) {
        this.summary = summary;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    /** Link nhúng iframe (youtube.com/embed/ID) suy ra từ link YouTube đã lưu; null nếu không phải link YouTube hợp lệ. */
    public String getEmbedUrl() {
        return com.edututor.util.YoutubeUtil.getEmbedUrl(youtubeUrl);
    }

    public String getYoutubeUrl() {
        return youtubeUrl;
    }

    public void setYoutubeUrl(String youtubeUrl) {
        this.youtubeUrl = youtubeUrl;
    }

    public int getDisplayOrder() {
        return displayOrder;
    }

    public void setDisplayOrder(int displayOrder) {
        this.displayOrder = displayOrder;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public String getTopicName() {
        return topicName;
    }

    public void setTopicName(String topicName) {
        this.topicName = topicName;
    }

    public int getQuestionCount() {
        return questionCount;
    }

    public void setQuestionCount(int questionCount) {
        this.questionCount = questionCount;
    }
}

