package com.edututor.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
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

/** Entity bảng Lessons (bài học/bài giảng). */
@Entity
@Table(name = "Lessons")
public class Lesson {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "LessonId")
    private Integer lessonId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "TopicId", nullable = false)
    private Topic topic;

    @Nationalized
    @Column(name = "Title", nullable = false, length = 255)
    private String title;

    @Nationalized
    @Column(name = "Summary", length = 500)
    private String summary;

    @Nationalized
    @Column(name = "Content", columnDefinition = "NVARCHAR(MAX)")
    private String content;

    @Column(name = "YoutubeUrl", length = 255)
    private String youtubeUrl;

    @Column(name = "DisplayOrder")
    private int displayOrder;

    @CreationTimestamp
    @Column(name = "CreatedAt", updatable = false)
    private LocalDateTime createdAt;

    public Integer getLessonId() { return lessonId; }
    public void setLessonId(Integer lessonId) { this.lessonId = lessonId; }
    public Topic getTopic() { return topic; }
    public void setTopic(Topic topic) { this.topic = topic; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getSummary() { return summary; }
    public void setSummary(String summary) { this.summary = summary; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public String getYoutubeUrl() { return youtubeUrl; }
    public void setYoutubeUrl(String youtubeUrl) { this.youtubeUrl = youtubeUrl; }
    public int getDisplayOrder() { return displayOrder; }
    public void setDisplayOrder(int displayOrder) { this.displayOrder = displayOrder; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    @Override
    public boolean equals(Object o) {
        return this == o || (o instanceof Lesson other && lessonId != null && Objects.equals(lessonId, other.lessonId));
    }

    @Override
    public int hashCode() {
        return Lesson.class.hashCode();
    }
}
