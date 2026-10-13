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
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Objects;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.Nationalized;
import org.hibernate.annotations.UpdateTimestamp;

/** Entity bảng Submissions: bài làm trắc nghiệm (MCQ) và tự luận (ESSAY) của học sinh. */
@Entity
@Table(name = "Submissions")
public class Submission {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "SubmissionId")
    private Integer submissionId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "StudentId", nullable = false)
    private User student;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "LessonId")
    private Lesson lesson;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "QuestionId", nullable = false)
    private Question question;

    @Enumerated(EnumType.STRING)
    @Column(name = "QuestionType", nullable = false, length = 10)
    private QuestionType questionType;

    @Nationalized
    @Column(name = "StudentAnswer", columnDefinition = "NVARCHAR(MAX)")
    private String studentAnswer;

    @Column(name = "EssayImagePath", length = 255)
    private String essayImagePath;

    @Column(name = "IsCorrect")
    private Boolean isCorrect;

    /**
     * Điểm AI đề xuất cho bài tự luận (thang 10, bước 0.25); trắc nghiệm: null.
     * BR-09: updatable = false nên Hibernate KHÔNG BAO GIỜ ghi đè cột này sau khi INSERT.
     */
    @Column(name = "AiScore", precision = 4, scale = 2, updatable = false)
    private BigDecimal aiScore;

    /** Điểm chính thức (thang 10): trắc nghiệm 10 / 0; tự luận ban đầu = aiScore, giáo viên duyệt có thể chỉnh. */
    @Column(name = "FinalScore", precision = 4, scale = 2)
    private BigDecimal finalScore;

    @Nationalized
    @Column(name = "AiFeedback", columnDefinition = "NVARCHAR(MAX)")
    private String aiFeedback;

    @Nationalized
    @Column(name = "TeacherFeedback", columnDefinition = "NVARCHAR(MAX)")
    private String teacherFeedback;

    /** Cột cũ IsReviewed, luôn được giữ đồng bộ với {@link #status} (false khi và chỉ khi AI_GRADED). */
    @Column(name = "IsReviewed")
    private boolean reviewed = true;

    /** Trạng thái chấm (GRADED / AI_GRADED / REVIEWED). Nguồn sự thật của việc bài đã được duyệt hay chưa. */
    @Enumerated(EnumType.STRING)
    @Column(name = "`Status`", nullable = false, length = 20)
    private SubmissionStatus status = SubmissionStatus.GRADED;

    /** Lời giải đúng do AI đề xuất cho bài tự luận. */
    @Nationalized
    @Column(name = "SuggestedCorrection", columnDefinition = "NVARCHAR(MAX)")
    private String suggestedCorrection;

    /** Giáo viên đã duyệt bài tự luận. */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ReviewedBy")
    private User reviewedBy;

    @Column(name = "ReviewedAt")
    private LocalDateTime reviewedAt;

    @CreationTimestamp
    @Column(name = "SubmittedAt", updatable = false)
    private LocalDateTime submittedAt;

    @UpdateTimestamp
    @Column(name = "UpdatedAt")
    private LocalDateTime updatedAt;

    public Integer getSubmissionId() { return submissionId; }
    public void setSubmissionId(Integer submissionId) { this.submissionId = submissionId; }
    public User getStudent() { return student; }
    public void setStudent(User student) { this.student = student; }
    public Lesson getLesson() { return lesson; }
    public void setLesson(Lesson lesson) { this.lesson = lesson; }
    public Question getQuestion() { return question; }
    public void setQuestion(Question question) { this.question = question; }
    public QuestionType getQuestionType() { return questionType; }
    public void setQuestionType(QuestionType questionType) { this.questionType = questionType; }
    public String getStudentAnswer() { return studentAnswer; }
    public void setStudentAnswer(String studentAnswer) { this.studentAnswer = studentAnswer; }
    public String getEssayImagePath() { return essayImagePath; }
    public void setEssayImagePath(String essayImagePath) { this.essayImagePath = essayImagePath; }
    public Boolean getIsCorrect() { return isCorrect; }
    public void setIsCorrect(Boolean isCorrect) { this.isCorrect = isCorrect; }
    public BigDecimal getAiScore() { return aiScore; }
    public void setAiScore(BigDecimal aiScore) { this.aiScore = aiScore; }
    public BigDecimal getFinalScore() { return finalScore; }
    public void setFinalScore(BigDecimal finalScore) { this.finalScore = finalScore; }
    public String getAiFeedback() { return aiFeedback; }
    public void setAiFeedback(String aiFeedback) { this.aiFeedback = aiFeedback; }
    public String getTeacherFeedback() { return teacherFeedback; }
    public void setTeacherFeedback(String teacherFeedback) { this.teacherFeedback = teacherFeedback; }
    public boolean isReviewed() { return status != SubmissionStatus.AI_GRADED; }
    public SubmissionStatus getStatus() { return status; }
    public void setStatus(SubmissionStatus status) {
        this.status = status;
        this.reviewed = status != SubmissionStatus.AI_GRADED;
    }
    public String getSuggestedCorrection() { return suggestedCorrection; }
    public void setSuggestedCorrection(String suggestedCorrection) { this.suggestedCorrection = suggestedCorrection; }
    public User getReviewedBy() { return reviewedBy; }
    public void setReviewedBy(User reviewedBy) { this.reviewedBy = reviewedBy; }
    public LocalDateTime getReviewedAt() { return reviewedAt; }
    public void setReviewedAt(LocalDateTime reviewedAt) { this.reviewedAt = reviewedAt; }
    public LocalDateTime getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(LocalDateTime submittedAt) { this.submittedAt = submittedAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    @Override
    public boolean equals(Object o) {
        return this == o || (o instanceof Submission other && submissionId != null
                && Objects.equals(submissionId, other.submissionId));
    }

    @Override
    public int hashCode() {
        return Submission.class.hashCode();
    }
}
