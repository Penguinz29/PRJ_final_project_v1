package com.edututor.repository.spec;

import com.edututor.model.Question;
import com.edututor.model.QuestionType;
import jakarta.persistence.criteria.Predicate;
import java.util.ArrayList;
import java.util.List;
import org.springframework.data.jpa.domain.Specification;

/** Specification lọc động ngân hàng câu hỏi (UC-TEA-04). Giá trị luôn đi qua tham số, không nối chuỗi. */
public final class QuestionSpecs {

    private QuestionSpecs() {
    }

    /**
     * @param topicId  &lt;= 0: không lọc
     * @param lessonId &lt;= 0: không lọc
     * @param type     null: không lọc
     * @param level    &lt;= 0: không lọc
     */
    public static Specification<Question> search(int topicId, int lessonId, QuestionType type, int level) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            if (topicId > 0) {
                predicates.add(cb.equal(root.get("lesson").get("topic").get("topicId"), topicId));
            }
            if (lessonId > 0) {
                predicates.add(cb.equal(root.get("lesson").get("lessonId"), lessonId));
            }
            if (type != null) {
                predicates.add(cb.equal(root.get("questionType"), type));
            }
            if (level > 0) {
                predicates.add(cb.equal(root.get("level"), level));
            }
            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }
}
