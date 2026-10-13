package repository;

/** Projection câu trắc nghiệm khi làm bài: chỉ các cột được phép gửi xuống client (BR-11). */
public interface QuizQuestionRow {

    Integer getQuestionId();

    String getContent();

    Integer getLevel();

    Boolean getAiGenerated();
}
