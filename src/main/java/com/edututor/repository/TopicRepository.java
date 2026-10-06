package com.edututor.repository;

import com.edututor.model.Topic;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TopicRepository extends JpaRepository<Topic, Integer> {

    // Mọi truy vấn (học sinh lẫn giáo viên / Admin) chỉ lấy chuyên đề đang hoạt động (IsActive = 1).
    // Quan hệ to-one (giáo viên) nạp cùng một câu SQL bằng @EntityGraph, tránh N+1.

    @EntityGraph(attributePaths = "teacher")
    List<Topic> findByActiveTrueOrderByCreatedAtDescTopicIdDesc();

    @EntityGraph(attributePaths = "teacher")
    List<Topic> findByTeacher_UserIdAndActiveTrueOrderByCreatedAtDescTopicIdDesc(Integer teacherId);

    @EntityGraph(attributePaths = "teacher")
    Optional<Topic> findWithTeacherByTopicIdAndActiveTrue(Integer topicId);

    Optional<Topic> findByTopicIdAndActiveTrue(Integer topicId);

    long countByActiveTrue();

    long countByTeacher_UserIdAndActiveTrue(Integer teacherId);

    /** Tên chuyên đề chỉ cần duy nhất trong các chuyên đề đang hoạt động (chuyên đề đã xóa mềm không chặn tên). */
    boolean existsByTopicNameIgnoreCaseAndActiveTrue(String topicName);

    boolean existsByTopicNameIgnoreCaseAndActiveTrueAndTopicIdNot(String topicName, Integer topicId);

    boolean existsByTeacher_UserId(Integer teacherId);
}
