package com.edututor.repository;

import com.edututor.model.Topic;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TopicRepository extends JpaRepository<Topic, Integer> {

    /** Quan hệ to-one (giáo viên) nạp cùng một câu SQL bằng @EntityGraph, tránh N+1. */
    @EntityGraph(attributePaths = "teacher")
    List<Topic> findAllByOrderByCreatedAtDescTopicIdDesc();

    @EntityGraph(attributePaths = "teacher")
    List<Topic> findByTeacher_UserIdOrderByCreatedAtDescTopicIdDesc(Integer teacherId);

    @EntityGraph(attributePaths = "teacher")
    Optional<Topic> findWithTeacherByTopicId(Integer topicId);

    long countByTeacher_UserId(Integer teacherId);

    boolean existsByTopicNameIgnoreCase(String topicName);

    boolean existsByTopicNameIgnoreCaseAndTopicIdNot(String topicName, Integer topicId);
}
