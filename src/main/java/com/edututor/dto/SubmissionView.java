package com.edututor.dto;

import java.io.Serializable;
import java.util.Date;

public class SubmissionView implements Serializable {
    private int submissionId;
    private int studentId;
    private Integer lessonId;
    private int questionId;
    private String questionType;
    private String studentAnswer;
    private String essayImagePath;
    private Boolean isCorrect;
    private Double score;
    private String aiFeedback;
    private String teacherFeedback;
    private boolean reviewed;
    private Date submittedAt;

    // Expand
    private String studentName;
    private String studentEmail;
    private String questionTitle; // Lấy đoạn đầu câu hỏi để hiển thị UI
    private String questionContent; // Toàn bộ nội dung câu hỏi
    private String lessonTitle;
    private boolean questionAiGenerated;

    public SubmissionView() {
    }

    public int getSubmissionId() {
        return submissionId;
    }

    public void setSubmissionId(int submissionId) {
        this.submissionId = submissionId;
    }

    public int getStudentId() {
        return studentId;
    }

    public void setStudentId(int studentId) {
        this.studentId = studentId;
    }

    public Integer getLessonId() {
        return lessonId;
    }

    public void setLessonId(Integer lessonId) {
        this.lessonId = lessonId;
    }

    public int getQuestionId() {
        return questionId;
    }

    public void setQuestionId(int questionId) {
        this.questionId = questionId;
    }

    public String getQuestionType() {
        return questionType;
    }

    public void setQuestionType(String questionType) {
        this.questionType = questionType;
    }

    public String getStudentAnswer() {
        return studentAnswer;
    }

    public void setStudentAnswer(String studentAnswer) {
        this.studentAnswer = studentAnswer;
    }

    public String getEssayImagePath() {
        return essayImagePath;
    }

    public void setEssayImagePath(String essayImagePath) {
        this.essayImagePath = essayImagePath;
    }

    public Boolean getIsCorrect() {
        return isCorrect;
    }

    public boolean isCorrect() {
        return isCorrect != null && isCorrect;
    }

    public void setIsCorrect(Boolean isCorrect) {
        this.isCorrect = isCorrect;
    }

    public String getTeacherFeedback() {
        return teacherFeedback;
    }

    public void setTeacherFeedback(String teacherFeedback) {
        this.teacherFeedback = teacherFeedback;
    }

    public boolean isReviewed() {
        return reviewed;
    }

    public void setReviewed(boolean reviewed) {
        this.reviewed = reviewed;
    }

    public Date getSubmittedAt() {
        return submittedAt;
    }

    public void setSubmittedAt(Date submittedAt) {
        this.submittedAt = submittedAt;
    }

    // Expand getters/setters
    public String getStudentName() {
        return studentName;
    }

    public void setStudentName(String studentName) {
        this.studentName = studentName;
    }

    public String getQuestionTitle() {
        return questionTitle;
    }

    public void setQuestionTitle(String questionTitle) {
        this.questionTitle = questionTitle;
    }

    public String getLessonTitle() {
        return lessonTitle;
    }

    public void setLessonTitle(String lessonTitle) {
        this.lessonTitle = lessonTitle;
    }

    public boolean isQuestionAiGenerated() {
        return questionAiGenerated;
    }

    public void setQuestionAiGenerated(boolean questionAiGenerated) {
        this.questionAiGenerated = questionAiGenerated;
    }

    public Double getScore() {
        return score;
    }

    public void setScore(Double score) {
        this.score = score;
    }

    public String getAiFeedback() {
        return aiFeedback;
    }

    public void setAiFeedback(String aiFeedback) {
        this.aiFeedback = aiFeedback;
    }

    public String getStudentEmail() {
        return studentEmail;
    }

    public void setStudentEmail(String studentEmail) {
        this.studentEmail = studentEmail;
    }

    public String getQuestionContent() {
        return questionContent;
    }

    public void setQuestionContent(String questionContent) {
        this.questionContent = questionContent;
    }

    public boolean getReviewed() {
        return reviewed;
    }

    // BR-09: điểm AI (đề xuất, không đổi) tách khỏi điểm chính thức (score = final_score)
    private Double aiScore;
    private String status;          // GRADED | AI_GRADED | REVIEWED
    private String reviewedByName;
    private Date reviewedAt;

    public Double getAiScore() { return aiScore; }
    public void setAiScore(Double aiScore) { this.aiScore = aiScore; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getReviewedByName() { return reviewedByName; }
    public void setReviewedByName(String reviewedByName) { this.reviewedByName = reviewedByName; }
    public Date getReviewedAt() { return reviewedAt; }
    public void setReviewedAt(Date reviewedAt) { this.reviewedAt = reviewedAt; }

    /** Lời giải đúng AI đề xuất (cột SuggestedCorrection). */
    private String suggestedCorrection;

    public String getSuggestedCorrection() { return suggestedCorrection; }
    public void setSuggestedCorrection(String suggestedCorrection) { this.suggestedCorrection = suggestedCorrection; }
}
