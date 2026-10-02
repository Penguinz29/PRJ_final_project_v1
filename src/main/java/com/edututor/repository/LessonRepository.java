package com.edututor.repository;

import com.edututor.model.Lesson;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

public interface LessonRepository extends JpaRepository<Lesson, Integer> {

    @EntityGraph(attributePaths = "topic")
    List<Lesson> findAllByOrderByCreatedAtDescLessonIdDesc();

    @EntityGraph(attributePaths = "topic")
    List<Lesson> findByTopic_TopicIdOrderByDisplayOrderAscLessonIdAsc(Integer topicId);

    /** Nạp bài học của nhiều chuyên đề bằng MỘT truy vấn IN (không N+1). */
    @EntityGraph(attributePaths = "topic")
    List<Lesson> findByTopic_TopicIdInOrderByDisplayOrderAscLessonIdAsc(Collection<Integer> topicIds);

    @EntityGraph(attributePaths = "topic")
    Optional<Lesson> findWithTopicByLessonId(Integer lessonId);

    long countByTopic_TopicId(Integer topicId);

    long countByTopic_Teacher_UserId(Integer teacherId);
}
