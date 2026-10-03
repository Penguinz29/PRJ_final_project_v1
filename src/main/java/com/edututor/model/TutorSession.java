package com.edututor.model;

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

/** Entity bảng TutorSessions: một phiên hỏi đáp gia sư AI 1-on-1 (xóa tin nhắn theo ON DELETE CASCADE). */
@Entity
@Table(name = "TutorSessions")
public class TutorSession {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "SessionId")
    private Integer sessionId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "StudentId", nullable = false)
    private User student;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "LessonId")
    private Lesson lesson;

    @Nationalized
    @Column(name = "Title", nullable = false, length = 255)
    private String title;

    @Enumerated(EnumType.STRING)
    @Column(name = "`Status`", nullable = false, length = 20)
    private TutorStatus status = TutorStatus.ACTIVE;

    /** BR-15: true khi AI đang dừng chờ học sinh nhập số liệu cho bước hiện tại. */
    @Column(name = "AwaitingInput", nullable = false)
    private boolean awaitingInput;

    /** Gợi ý dữ liệu AI cần học sinh nhập (chỉ có khi awaitingInput = true). */
    @Nationalized
    @Column(name = "InputHint", length = 255)
    private String inputHint;

    @CreationTimestamp
    @Column(name = "CreatedAt", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "UpdatedAt")
    private LocalDateTime updatedAt;

    public Integer getSessionId() { return sessionId; }
    public void setSessionId(Integer sessionId) { this.sessionId = sessionId; }
    public User getStudent() { return student; }
    public void setStudent(User student) { this.student = student; }
    public Lesson getLesson() { return lesson; }
    public void setLesson(Lesson lesson) { this.lesson = lesson; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public TutorStatus getStatus() { return status; }
    public void setStatus(TutorStatus status) { this.status = status; }
    public boolean isAwaitingInput() { return awaitingInput; }
    public void setAwaitingInput(boolean awaitingInput) { this.awaitingInput = awaitingInput; }
    public String getInputHint() { return inputHint; }
    public void setInputHint(String inputHint) { this.inputHint = inputHint; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    @Override
    public boolean equals(Object o) {
        return this == o || (o instanceof TutorSession other && sessionId != null
                && Objects.equals(sessionId, other.sessionId));
    }

    @Override
    public int hashCode() {
        return TutorSession.class.hashCode();
    }
}
