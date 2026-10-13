package repository;

import dto.view.QuizOptionView;
import model.QuestionOption;
import java.util.Collection;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface QuestionOptionRepository extends JpaRepository<QuestionOption, Integer> {

    List<QuestionOption> findByQuestion_QuestionIdOrderByOptionLetterAsc(Integer questionId);

    /** Phương án hiển thị khi làm bài: chỉ chọn các cột được phép, KHÔNG có IsCorrect (BR-11). */
    @Query("select new dto.view.QuizOptionView(o.optionId, o.question.questionId, o.optionLetter, o.content) "
            + "from QuestionOption o where o.question.questionId in :questionIds "
            + "order by o.question.questionId, o.optionLetter")
    List<QuizOptionView> findQuizOptions(@Param("questionIds") Collection<Integer> questionIds);
}
