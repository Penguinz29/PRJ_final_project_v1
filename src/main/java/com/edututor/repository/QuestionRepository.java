package com.edututor.repository;

import com.edututor.dto.QuizQuestionView;
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
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface QuestionRepository extends JpaRepository<Question, Integer>, JpaSpecificationExecutor<Question> {

    /** Danh sách có lọc + phân trang ở CSDL (Specification + Pageable); bài học nạp bằng @EntityGraph. */
    @Override
    @EntityGraph(attributePaths = "lesson")
    Page<Question> findAll(Specification<Question> spec, Pageable pageable);

    @EntityGraph(attributePaths = "lesson")
    List<Question> findByLesson_LessonIdAndQuestionTypeOrderByCreatedAtAscQuestionIdAsc(Integer lessonId,
                                                                                         QuestionType type);

    @EntityGraph(attributePaths = "lesson")
    Optional<Question> findWithLessonByQuestionId(Integer questionId);

    /** Nạp câu hỏi kèm phương án (một câu, không phân trang nên fetch collection an toàn). */
    @EntityGraph(attributePaths = {"lesson", "options"})
    Optional<Question> findWithOptionsByQuestionId(Integer questionId);

    long countByLesson_LessonId(Integer lessonId);

    /** Câu trắc nghiệm hiển thị khi làm bài: chỉ chọn cột được phép (không lời giải), tránh nạp Entity đầy đủ. */
    @Query("select new com.edututor.dto.QuizQuestionView(q.questionId, q.content, q.level, q.aiGenerated) "
            + "from Question q where q.lesson.lessonId = :lessonId "
            + "and q.questionType = com.edututor.model.QuestionType.MCQ order by q.createdAt asc, q.questionId asc")
    List<QuizQuestionView> findQuizQuestions(@Param("lessonId") Integer lessonId);

    @Query("select q.lesson.lessonId as id, count(q) as total from Question q "
            + "where q.lesson.lessonId in :lessonIds group by q.lesson.lessonId")
    List<IdCount> countByLessonIds(@Param("lessonIds") Collection<Integer> lessonIds);

    boolean existsByTeacher_UserId(Integer teacherId);
}
