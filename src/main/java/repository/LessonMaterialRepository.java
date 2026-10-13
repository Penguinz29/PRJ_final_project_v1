package repository;

import model.LessonMaterial;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface LessonMaterialRepository extends JpaRepository<LessonMaterial, Integer> {

    /** Bài giảng của một bài học theo thứ tự hiển thị; người tạo nạp cùng câu SQL (không N+1). */
    @EntityGraph(attributePaths = "createdBy")
    List<LessonMaterial> findByLesson_LessonIdOrderByOrderIndexAscMaterialIdAsc(Integer lessonId);

    /** Nạp kèm bài học và người tạo để kiểm tra quyền sở hữu (BR-03). */
    @EntityGraph(attributePaths = {"lesson", "createdBy"})
    Optional<LessonMaterial> findWithOwnerByMaterialId(Integer materialId);

    @Query("select coalesce(max(m.orderIndex), 0) from LessonMaterial m where m.lesson.lessonId = :lessonId")
    int findMaxOrderIndex(@Param("lessonId") Integer lessonId);

    boolean existsByCreatedBy_UserId(Integer userId);
}
