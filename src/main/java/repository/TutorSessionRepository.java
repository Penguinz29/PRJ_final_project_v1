package repository;

import model.TutorSession;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface TutorSessionRepository extends JpaRepository<TutorSession, Integer> {

    @EntityGraph(attributePaths = {"lesson"})
    List<TutorSession> findByStudent_UserId(Integer studentId, Pageable pageable);

    @EntityGraph(attributePaths = {"lesson", "student", "question"})
    Optional<TutorSession> findWithLessonBySessionId(Integer sessionId);

    boolean existsByStudent_UserId(Integer studentId);

    /** Phiên gia sư mở từ câu hỏi: còn tham chiếu thì câu hỏi / bài học chỉ được xóa mềm. */
    boolean existsByQuestion_QuestionId(Integer questionId);

    boolean existsByQuestion_Lesson_LessonId(Integer lessonId);

    @Query("select distinct t.question.questionId from TutorSession t where t.question.questionId in :ids")
    List<Integer> findQuestionIdsWithSessions(@Param("ids") Collection<Integer> ids);

    @Query("select distinct t.question.lesson.lessonId from TutorSession t where t.question.lesson.lessonId in :ids")
    List<Integer> findLessonIdsWithSessions(@Param("ids") Collection<Integer> ids);
}
