package com.edututor.repository;

import com.edututor.dto.QuizOptionView;
import com.edututor.model.QuestionOption;
import java.util.Collection;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface QuestionOptionRepository extends JpaRepository<QuestionOption, Integer> {

    List<QuestionOption> findByQuestion_QuestionIdOrderByOptionLetterAsc(Integer questionId);

    /** Phương án (kèm cờ đúng/sai) của nhiều câu bằng một truy vấn IN — chỉ dùng khi CHẤM bài. */
    List<QuestionOption> findByQuestion_QuestionIdInOrderByQuestion_QuestionIdAscOptionLetterAsc(
            Collection<Integer> questionIds);

    /** Phương án hiển thị khi làm bài: chỉ chọn các cột được phép, KHÔNG có IsCorrect (BR-11). */
    @Query("select new com.edututor.dto.QuizOptionView(o.optionId, o.question.questionId, o.optionLetter, o.content) "
            + "from QuestionOption o where o.question.questionId in :questionIds "
            + "order by o.question.questionId, o.optionLetter")
    List<QuizOptionView> findQuizOptions(@Param("questionIds") Collection<Integer> questionIds);

    void deleteByQuestion_QuestionId(Integer questionId);
}
