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
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Objects;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.Nationalized;

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

    /** Điểm (thang 10 với tự luận; trắc nghiệm: 1 nếu đúng, 0 nếu sai). */
    @Column(name = "Score", precision = 4, scale = 2)
    private BigDecimal score;

    @Nationalized
    @Column(name = "AiFeedback", columnDefinition = "NVARCHAR(MAX)")
    private String aiFeedback;

    @Nationalized
    @Column(name = "TeacherFeedback", columnDefinition = "NVARCHAR(MAX)")
    private String teacherFeedback;

    @Column(name = "IsReviewed")
    private boolean reviewed;

    @CreationTimestamp
    @Column(name = "SubmittedAt", updatable = false)
    private LocalDateTime submittedAt;

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
    public BigDecimal getScore() { return score; }
    public void setScore(BigDecimal score) { this.score = score; }
    public String getAiFeedback() { return aiFeedback; }
    public void setAiFeedback(String aiFeedback) { this.aiFeedback = aiFeedback; }
    public String getTeacherFeedback() { return teacherFeedback; }
    public void setTeacherFeedback(String teacherFeedback) { this.teacherFeedback = teacherFeedback; }
    public boolean isReviewed() { return reviewed; }
    public void setReviewed(boolean reviewed) { this.reviewed = reviewed; }
    public LocalDateTime getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(LocalDateTime submittedAt) { this.submittedAt = submittedAt; }

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
