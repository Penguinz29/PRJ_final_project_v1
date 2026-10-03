package com.edututor.dto;

import java.io.Serializable;
import java.util.Date;
import java.util.List;

public class QuestionView implements Serializable {
    private int questionId;
    private int lessonId;
    private String questionType; // MCQ, ESSAY
    private String content;
    private String explanation; // Lời giải chi tiết (LaTeX) - cột ExplanationLatex
    private int level; // 1, 2, 3
    private boolean aiGenerated;
    private int teacherId;
    private Date createdAt;

    // Expand
    private String lessonTitle;
    private List<OptionView> options;

    public QuestionView() {
    }

    public int getQuestionId() {
        return questionId;
    }

    public void setQuestionId(int questionId) {
        this.questionId = questionId;
    }

    public int getLessonId() {
        return lessonId;
    }

    public void setLessonId(int lessonId) {
        this.lessonId = lessonId;
    }

    public String getQuestionType() {
        return questionType;
    }

    public String getType() {
        return questionType;
    }

    public void setQuestionType(String questionType) {
        this.questionType = questionType;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getExplanation() {
        return explanation;
    }

    public void setExplanation(String explanation) {
        this.explanation = explanation;
    }

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public boolean isAiGenerated() {
        return aiGenerated;
    }

    public boolean getAiGenerated() {
        return aiGenerated;
    }

    public void setAiGenerated(boolean aiGenerated) {
        this.aiGenerated = aiGenerated;
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

    public String getLessonTitle() {
        return lessonTitle;
    }

    public void setLessonTitle(String lessonTitle) {
        this.lessonTitle = lessonTitle;
    }

    public List<OptionView> getOptions() {
        return options;
    }

    public void setOptions(List<OptionView> options) {
        this.options = options;
    }

    /** Kết quả nếu giáo viên bấm Xóa: HARD (xóa hẳn) | SOFT (ẩn, giữ lịch sử) | BLOCKED (còn mục con đang hoạt động). */
    private String deleteMode;

    public String getDeleteMode() { return deleteMode; }
    public void setDeleteMode(String deleteMode) { this.deleteMode = deleteMode; }
}
