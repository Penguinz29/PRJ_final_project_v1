package com.edututor.dto;

import java.io.Serializable;
import java.util.Date;

/** DTO hiển thị cho bảng TutorMessages: tin nhắn của học sinh (USER) hoặc gia sư AI (AI) trong một phiên. */
public class TutorMessageView implements Serializable {
    private static final long serialVersionUID = 1L;

    public static final String SENDER_USER = "USER";
    public static final String SENDER_AI = "AI";

    private int messageId;
    private int sessionId;
    private String senderType; // USER, AI
    private int stepNumber;
    private String contentText;
    private boolean stepCompleted;
    private Date createdAt;

    public TutorMessageView() {}

    public TutorMessageView(int sessionId, String senderType, int stepNumber, String contentText, boolean stepCompleted) {
        this.sessionId = sessionId;
        this.senderType = senderType;
        this.stepNumber = stepNumber;
        this.contentText = contentText;
        this.stepCompleted = stepCompleted;
    }

    public int getMessageId() { return messageId; }
    public void setMessageId(int messageId) { this.messageId = messageId; }
    public int getSessionId() { return sessionId; }
    public void setSessionId(int sessionId) { this.sessionId = sessionId; }
    public String getSenderType() { return senderType; }
    public void setSenderType(String senderType) { this.senderType = senderType; }
    public int getStepNumber() { return stepNumber; }
    public void setStepNumber(int stepNumber) { this.stepNumber = stepNumber; }
    public String getContentText() { return contentText; }
    public void setContentText(String contentText) { this.contentText = contentText; }
    public boolean isStepCompleted() { return stepCompleted; }
    public void setStepCompleted(boolean stepCompleted) { this.stepCompleted = stepCompleted; }
    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
}
