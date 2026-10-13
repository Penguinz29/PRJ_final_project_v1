package repository;

/** Projection một dòng thống kê kết quả theo câu hỏi (UC-TEA-08). correctPct null = chưa có lượt làm. */
public interface QuestionResultRow {

    Integer getQuestionId();

    String getContent();

    Integer getLevel();

    Integer getAttempts();

    Integer getStudents();

    Double getCorrectPct();
}
