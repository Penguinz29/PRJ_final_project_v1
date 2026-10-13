package dto.view;

import java.io.Serializable;
import java.util.Date;

/** DTO hiển thị cho bảng TutorSessions: một phiên hỏi đáp gia sư AI 1-on-1. */
public class TutorSessionView implements Serializable {
    private static final long serialVersionUID = 1L;

    private int sessionId;
    private int studentId;
    private Integer lessonId;
    private String title;
    private String status; // ACTIVE, COMPLETED, ABANDONED
    private Integer questionId;
    private int currentStep;
    private int totalSteps;
    private boolean awaitingInput;
    private String inputHint;
    private Date createdAt;

    // Mở rộng cho UI
    private String lessonTitle;

    public int getSessionId() { return sessionId; }
    public void setSessionId(int sessionId) { this.sessionId = sessionId; }
    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }
    public Integer getLessonId() { return lessonId; }
    public void setLessonId(Integer lessonId) { this.lessonId = lessonId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Integer getQuestionId() { return questionId; }
    public void setQuestionId(Integer questionId) { this.questionId = questionId; }
    public int getCurrentStep() { return currentStep; }
    public void setCurrentStep(int currentStep) { this.currentStep = currentStep; }
    public int getTotalSteps() { return totalSteps; }
    public void setTotalSteps(int totalSteps) { this.totalSteps = totalSteps; }
    public boolean isAwaitingInput() { return awaitingInput; }
    public void setAwaitingInput(boolean awaitingInput) { this.awaitingInput = awaitingInput; }
    public String getInputHint() { return inputHint; }
    public void setInputHint(String inputHint) { this.inputHint = inputHint; }
    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
    public String getLessonTitle() { return lessonTitle; }
    public void setLessonTitle(String lessonTitle) { this.lessonTitle = lessonTitle; }
}
