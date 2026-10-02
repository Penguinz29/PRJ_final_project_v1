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

/** Entity bảng Topics (chuyên đề). Xóa dây chuyền xuống Lessons do ON DELETE CASCADE của CSDL. */
@Entity
@Table(name = "Topics")
public class Topic {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "TopicId")
    private Integer topicId;

    @Nationalized
    @Column(name = "TopicName", nullable = false, length = 255)
    private String topicName;

    @Nationalized
    @Column(name = "`Description`", columnDefinition = "NVARCHAR(MAX)")
    private String description;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "TeacherId", nullable = false)
    private User teacher;

    @CreationTimestamp
    @Column(name = "CreatedAt", updatable = false)
    private LocalDateTime createdAt;

    public Integer getTopicId() { return topicId; }
    public void setTopicId(Integer topicId) { this.topicId = topicId; }
    public String getTopicName() { return topicName; }
    public void setTopicName(String topicName) { this.topicName = topicName; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public User getTeacher() { return teacher; }
    public void setTeacher(User teacher) { this.teacher = teacher; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    @Override
    public boolean equals(Object o) {
        return this == o || (o instanceof Topic other && topicId != null && Objects.equals(topicId, other.topicId));
    }

    @Override
    public int hashCode() {
        return Topic.class.hashCode();
    }
}
