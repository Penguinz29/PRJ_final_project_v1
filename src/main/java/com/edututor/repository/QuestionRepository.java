package com.edututor.repository;

import com.edututor.model.Question;
import com.edututor.model.QuestionType;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface QuestionRepository extends JpaRepository<Question, Integer>, JpaSpecificationExecutor<Question> {

    /** Danh sách có lọc + phân trang ở CSDL (Specification + Pageable); bài học nạp bằng @EntityGraph. */
    @Override
    @EntityGraph(attributePaths = "lesson")
    Page<Question> findAll(Specification<Question> spec, Pageable pageable);

    /** Học sinh: câu hỏi của bài học, kể cả đã xóa mềm (vẫn ôn tập được). */
    @EntityGraph(attributePaths = "lesson")
    List<Question> findByLesson_LessonIdAndQuestionTypeOrderByCreatedAtAscQuestionIdAsc(Integer lessonId,
                                                                                         QuestionType type);

    /** Học sinh: làm bài, nộp bài, gia sư — chỉ khi bài học chứa câu hỏi còn hoạt động. */
    @EntityGraph(attributePaths = "lesson")
    Optional<Question> findWithLessonByQuestionIdAndLessonActiveTrue(Integer questionId);

    /** Giáo viên: chỉ câu đang hoạt động (sửa / xóa). */
    @EntityGraph(attributePaths = "lesson")
    Optional<Question> findWithLessonByQuestionIdAndActiveTrue(Integer questionId);

    /** Nạp câu hỏi kèm phương án (một câu, không phân trang nên fetch collection an toàn). */
    @EntityGraph(attributePaths = {"lesson", "options"})
    Optional<Question> findWithOptionsByQuestionIdAndActiveTrue(Integer questionId);

    /** BR-05: số câu hỏi ĐANG HOẠT ĐỘNG của bài học; còn > 0 thì không được xóa bài học. */
    long countByLesson_LessonIdAndActiveTrue(Integer lessonId);

    long countByLesson_LessonId(Integer lessonId);

    /** Xóa mềm bài học thì xóa mềm luôn mọi câu hỏi (bài tập) của bài đó. */
    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("update Question q set q.active = false where q.lesson.lessonId = :lessonId")
    int deactivateByLessonId(@Param("lessonId") Integer lessonId);

    long countByActiveTrue();

    /** UC-ADM-08: câu hỏi đang hoạt động do AI sinh. */
    long countByActiveTrueAndAiGeneratedTrue();

    /**
     * UC-STU-03: chọn NGẪU NHIÊN tối đa {@code limit} câu trắc nghiệm của bài (ORDER BY NEWID()), lọc mức độ nếu
     * {@code level} &gt; 0. Chỉ chọn cột được phép (không is_correct, không lời giải — BR-11, TC-SEC-08). Bài học đã xóa
     * bị chặn ở tầng service. Tham số có tên, không nối chuỗi.
     */
    @Query(value = "SELECT TOP (:limit) q.QuestionId AS questionId, q.Content AS content, q.[Level] AS level, "
            + "q.IsAiGenerated AS aiGenerated FROM Questions q "
            + "WHERE q.LessonId = :lessonId AND q.QuestionType = 'MCQ' AND (:level = 0 OR q.[Level] = :level) "
            + "ORDER BY NEWID()", nativeQuery = true)
    List<QuizQuestionRow> pickRandomQuizQuestions(@Param("lessonId") Integer lessonId, @Param("level") Integer level,
                                                  @Param("limit") Integer limit);

    @Query("select q.lesson.lessonId as id, count(q) as total from Question q "
            + "where q.lesson.lessonId in :lessonIds and q.active = true group by q.lesson.lessonId")
    List<IdCount> countByLessonIds(@Param("lessonIds") Collection<Integer> lessonIds);

    boolean existsByTeacher_UserId(Integer teacherId);
}
