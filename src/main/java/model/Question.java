package model;

import jakarta.persistence.CascadeType;
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
import jakarta.persistence.OneToMany;
import jakarta.persistence.OrderBy;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.Nationalized;
import org.hibernate.annotations.UpdateTimestamp;

/**
 * Entity bảng Questions. Quan hệ cha-sở-hữu-con duy nhất của dự án: Question → options (cascade PERSIST/MERGE).
 * Xóa phương án khi xóa câu hỏi dựa vào ON DELETE CASCADE của CSDL.
 */
@Entity
@Table(name = "Questions")
public class Question {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "QuestionId")
    private Integer questionId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "LessonId", nullable = false)
    private Lesson lesson;

    @Enumerated(EnumType.STRING)
    @Column(name = "QuestionType", nullable = false, length = 10)
    private QuestionType questionType;

    @Nationalized
    @Column(name = "Content", nullable = false, columnDefinition = "NVARCHAR(MAX)")
    private String content;

    /** Lời giải chi tiết (LaTeX), chỉ gửi cho học sinh sau khi đã nộp câu trả lời. */
    @Nationalized
    @Column(name = "ExplanationLatex", columnDefinition = "NVARCHAR(MAX)")
    private String explanationLatex;

    @Column(name = "`Level`", nullable = false)
    private int level = 1;

    @Column(name = "IsAiGenerated")
    private boolean aiGenerated;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "TeacherId", nullable = false)
    private User teacher;

    /** Xóa mềm (BR-05): false = đã xóa (câu đã có bài nộp), không còn dùng để luyện tập. */
    @Column(name = "IsActive", nullable = false)
    private boolean active = true;

    @CreationTimestamp
    @Column(name = "CreatedAt", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "UpdatedAt")
    private LocalDateTime updatedAt;

    @OneToMany(mappedBy = "question", fetch = FetchType.LAZY, cascade = {CascadeType.PERSIST, CascadeType.MERGE})
    @OrderBy("optionLetter ASC")
    private List<QuestionOption> options = new ArrayList<>();

    /** Thêm phương án và thiết lập chiều quan hệ ngược. */
    public void addOption(QuestionOption option) {
        option.setQuestion(this);
        options.add(option);
    }

    public Integer getQuestionId() { return questionId; }
    public void setQuestionId(Integer questionId) { this.questionId = questionId; }
    public Lesson getLesson() { return lesson; }
    public void setLesson(Lesson lesson) { this.lesson = lesson; }
    public QuestionType getQuestionType() { return questionType; }
    public void setQuestionType(QuestionType questionType) { this.questionType = questionType; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public String getExplanationLatex() { return explanationLatex; }
    public void setExplanationLatex(String explanationLatex) { this.explanationLatex = explanationLatex; }
    public int getLevel() { return level; }
    public void setLevel(int level) { this.level = level; }
    public boolean isAiGenerated() { return aiGenerated; }
    public void setAiGenerated(boolean aiGenerated) { this.aiGenerated = aiGenerated; }
    public User getTeacher() { return teacher; }
    public void setTeacher(User teacher) { this.teacher = teacher; }
    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    public List<QuestionOption> getOptions() { return options; }
    public void setOptions(List<QuestionOption> options) { this.options = options; }

    @Override
    public boolean equals(Object o) {
        return this == o || (o instanceof Question other && questionId != null
                && Objects.equals(questionId, other.questionId));
    }

    @Override
    public int hashCode() {
        return Question.class.hashCode();
    }
}
