package com.edututor.repository;

import com.edututor.model.Lesson;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface LessonRepository extends JpaRepository<Lesson, Integer> {

    /** Học sinh: bài học của nhiều chuyên đề, kể cả đã xóa mềm, bằng MỘT truy vấn IN (không N+1). */
    @EntityGraph(attributePaths = "topic")
    List<Lesson> findByTopic_TopicIdInOrderByDisplayOrderAscLessonIdAsc(Collection<Integer> topicIds);

    /** Học sinh: mở bài học kể cả đã xóa mềm. */
    @EntityGraph(attributePaths = "topic")
    Optional<Lesson> findWithTopicByLessonId(Integer lessonId);

    // Trang quản lý của giáo viên / Admin: chỉ bài học đang hoạt động (IsActive = 1)

    @EntityGraph(attributePaths = "topic")
    List<Lesson> findByActiveTrueOrderByCreatedAtDescLessonIdDesc();

    @EntityGraph(attributePaths = "topic")
    List<Lesson> findByTopic_TopicIdAndActiveTrueOrderByDisplayOrderAscLessonIdAsc(Integer topicId);

    /** Nạp bài học của nhiều chuyên đề bằng MỘT truy vấn IN (không N+1). */
    @EntityGraph(attributePaths = "topic")
    List<Lesson> findByTopic_TopicIdInAndActiveTrueOrderByDisplayOrderAscLessonIdAsc(Collection<Integer> topicIds);

    @EntityGraph(attributePaths = "topic")
    Optional<Lesson> findWithTopicByLessonIdAndActiveTrue(Integer lessonId);

    Optional<Lesson> findByLessonIdAndActiveTrue(Integer lessonId);

    boolean existsByLessonIdAndActiveTrue(Integer lessonId);

    /** Tất cả bài học của chuyên đề, kể cả đã xóa mềm (quyết định xóa cứng hay xóa mềm chuyên đề). */
    long countByTopic_TopicId(Integer topicId);

    /** BR-05: số bài học ĐANG HOẠT ĐỘNG của chuyên đề; còn > 0 thì không được xóa chuyên đề. */
    long countByTopic_TopicIdAndActiveTrue(Integer topicId);

    long countByTopic_Teacher_UserIdAndActiveTrue(Integer teacherId);

    /** Xóa tài khoản: giáo viên đã tạo bài học → chỉ được xóa mềm (BR-06). */
    boolean existsByCreatedBy_UserId(Integer userId);

    /** Tổng số bài học (kể cả đã xóa mềm) của nhiều chuyên đề: dự báo xóa hẳn / xóa mềm chuyên đề. */
    @Query("select l.topic.topicId as id, count(l) as total from Lesson l "
            + "where l.topic.topicId in :topicIds group by l.topic.topicId")
    List<IdCount> countAllByTopicIds(@Param("topicIds") Collection<Integer> topicIds);
}
