package model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import java.util.Objects;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.Nationalized;
import org.hibernate.annotations.UpdateTimestamp;

/** Entity bảng TutorMessages: tin nhắn của học sinh (USER) hoặc gia sư AI (AI) trong một phiên. */
@Entity
@Table(name = "TutorMessages")
public class TutorMessage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MessageId")
    private Integer messageId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "SessionId", nullable = false)
    private TutorSession session;

    @Enumerated(EnumType.STRING)
    @Column(name = "SenderType", nullable = false, length = 10)
    private SenderType senderType;

    @Column(name = "StepNumber", nullable = false)
    private int stepNumber = 1;

    @Nationalized
    @Column(name = "ContentText", nullable = false, columnDefinition = "NVARCHAR(MAX)")
    private String contentText;

    @Column(name = "IsStepCompleted", nullable = false)
    private boolean stepCompleted;

    @CreationTimestamp
    @Column(name = "CreatedAt", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "UpdatedAt")
    private LocalDateTime updatedAt;

    public Integer getMessageId() { return messageId; }
    public void setMessageId(Integer messageId) { this.messageId = messageId; }
    public TutorSession getSession() { return session; }
    public void setSession(TutorSession session) { this.session = session; }
    public SenderType getSenderType() { return senderType; }
    public void setSenderType(SenderType senderType) { this.senderType = senderType; }
    public int getStepNumber() { return stepNumber; }
    public void setStepNumber(int stepNumber) { this.stepNumber = stepNumber; }
    public String getContentText() { return contentText; }
    public void setContentText(String contentText) { this.contentText = contentText; }
    public boolean isStepCompleted() { return stepCompleted; }
    public void setStepCompleted(boolean stepCompleted) { this.stepCompleted = stepCompleted; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    @Override
    public boolean equals(Object o) {
        return this == o || (o instanceof TutorMessage other && messageId != null
                && Objects.equals(messageId, other.messageId));
    }

    @Override
    public int hashCode() {
        return TutorMessage.class.hashCode();
    }
}
