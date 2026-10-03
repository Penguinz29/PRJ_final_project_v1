package com.edututor.repository;

import com.edututor.model.QuestionType;
import com.edututor.model.Submission;
import java.util.Collection;
import java.util.List;
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

    /** Câu hỏi nào trong danh sách đã có bài nộp (dự báo xóa mềm ở trang quản lý, một truy vấn IN). */
    @Query("select distinct s.question.questionId from Submission s where s.question.questionId in :ids")
    List<Integer> findQuestionIdsWithSubmissions(@Param("ids") Collection<Integer> ids);

    /** Bài học nào trong danh sách đã có bài nộp cho câu hỏi của nó. */
    @Query("select distinct s.question.lesson.lessonId from Submission s where s.question.lesson.lessonId in :ids")
    List<Integer> findLessonIdsWithSubmissions(@Param("ids") Collection<Integer> ids);

    /** Có bài nộp nào cho các câu hỏi của bài học không (quyết định xóa cứng hay xóa mềm bài học, BR-05). */
    boolean existsByQuestion_Lesson_LessonId(Integer lessonId);

    /** Số bài học đã luyện trắc nghiệm của học sinh. */
    @Query("select count(distinct s.lesson.lessonId) from Submission s "
            + "where s.student.userId = :studentId and s.questionType = com.edututor.model.QuestionType.MCQ "
            + "and s.lesson is not null")
    long countQuizLessonsDone(@Param("studentId") Integer studentId);

    /** Điểm trung bình (thang 100) của các bài trắc nghiệm: % câu đúng; null nếu chưa làm bài nào. */
    @Query("select avg(case when s.isCorrect = true then 100.0 else 0.0 end) from Submission s "
            + "where s.student.userId = :studentId and s.questionType = com.edututor.model.QuestionType.MCQ")
    Double averageMcqPercent(@Param("studentId") Integer studentId);

    boolean existsByStudent_UserId(Integer studentId);

    /** Các lần làm SAI một câu của học sinh, mới nhất trước (điều kiện mở gia sư chế độ QUESTION, UC-TUT-01). */
    @Query("select s from Submission s where s.student.userId = :studentId and s.question.questionId = :questionId "
            + "and s.isCorrect = false order by s.submittedAt desc, s.submissionId desc")
    List<Submission> findWrongAttempts(@Param("studentId") Integer studentId, @Param("questionId") Integer questionId,
                                       Pageable pageable);
}
