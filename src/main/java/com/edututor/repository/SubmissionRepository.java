package com.edututor.repository;

import com.edututor.model.QuestionType;
import com.edututor.model.Submission;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

/** Bảng Submissions: bài làm trắc nghiệm / tự luận. Quan hệ to-one nạp bằng @EntityGraph (không N+1). */
public interface SubmissionRepository extends JpaRepository<Submission, Integer> {

    @EntityGraph(attributePaths = {"student", "question", "lesson"})
    Page<Submission> findByStudent_UserId(Integer studentId, Pageable pageable);

    @EntityGraph(attributePaths = {"student", "question", "lesson"})
    Page<Submission> findByStudent_UserIdAndQuestionType(Integer studentId, QuestionType type, Pageable pageable);

    /** Bài tự luận theo trạng thái đã duyệt hay chưa (phân trang). */
    @EntityGraph(attributePaths = {"student", "question", "lesson"})
    Page<Submission> findByQuestionTypeAndReviewed(QuestionType type, boolean reviewed, Pageable pageable);

    @EntityGraph(attributePaths = {"student", "question", "lesson"})
    Page<Submission> findByQuestionType(QuestionType type, Pageable pageable);

    @EntityGraph(attributePaths = {"student", "question", "lesson"})
    Optional<Submission> findWithDetailsBySubmissionId(Integer submissionId);

    @EntityGraph(attributePaths = {"student"})
    Optional<Submission> findByEssayImagePath(String essayImagePath);

    long countByQuestionTypeAndReviewed(QuestionType type, boolean reviewed);

    long countByQuestion_QuestionId(Integer questionId);

    /** Số bài học đã luyện trắc nghiệm của học sinh. */
    @Query("select count(distinct s.lesson.lessonId) from Submission s "
            + "where s.student.userId = :studentId and s.questionType = com.edututor.model.QuestionType.MCQ "
            + "and s.lesson is not null")
    long countQuizLessonsDone(@Param("studentId") Integer studentId);

    /** Điểm trung bình (thang 100) của các bài trắc nghiệm: % câu đúng; null nếu chưa làm bài nào. */
    @Query("select avg(case when s.isCorrect = true then 100.0 else 0.0 end) from Submission s "
            + "where s.student.userId = :studentId and s.questionType = com.edututor.model.QuestionType.MCQ")
    Double averageMcqPercent(@Param("studentId") Integer studentId);
}
