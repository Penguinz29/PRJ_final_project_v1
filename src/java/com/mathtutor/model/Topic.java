package com.mathtutor.model;

import java.io.Serializable;
import java.util.Date;
import java.util.List;

public class Topic implements Serializable {
    private int topicId;
    private String topicName;
    private String description;
    private int teacherId;
    private Date createdAt;

    // Expand
    private String teacherName;
    private List<Lesson> lessons;

    public Topic() {
    }

    public int getTopicId() {
        return topicId;
    }

    public void setTopicId(int topicId) {
        this.topicId = topicId;
    }

    public String getTopicName() {
        return topicName;
    }

    public void setTopicName(String topicName) {
        this.topicName = topicName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public int getTeacherId() {
        return teacherId;
    }

    public void setTeacherId(int teacherId) {
        this.teacherId = teacherId;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public String getTeacherName() {
        return teacherName;
    }

    public void setTeacherName(String teacherName) {
        this.teacherName = teacherName;
    }

    public List<Lesson> getLessons() {
        return lessons;
    }

    public void setLessons(List<Lesson> lessons) {
        this.lessons = lessons;
    }

    private int lessonCount;

    public int getLessonCount() {
        if (lessons != null && !lessons.isEmpty()) {
            return lessons.size();
        }
        return lessonCount;
    }

    public void setLessonCount(int lessonCount) {
        this.lessonCount = lessonCount;
    }
}
