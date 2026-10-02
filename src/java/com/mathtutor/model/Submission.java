package com.mathtutor.model;

import java.io.Serializable;
import java.util.Date;

public class Submission implements Serializable {
    private int submissionId;
    private int studentId;
    private Integer lessonId;
    private int questionId;
    private String questionType;
    private String studentAnswer;
    private String essayImagePath;
    private Boolean isCorrect;
    private String teacherFeedback;
    private boolean reviewed;
    private Date submittedAt;

    // Expand
    private String studentName;
    private String questionTitle; // Lấy đoạn đầu câu hỏi để hiển thị UI
    private String lessonTitle;
    private boolean questionAiGenerated;

    public Submission() {
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
}
