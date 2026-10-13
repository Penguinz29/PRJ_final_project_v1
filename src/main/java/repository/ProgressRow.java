package repository;

/** Projection một dòng tiến độ (theo chủ đề hoặc theo bài học) của học sinh — UC-STU-06, BR-10. */
public interface ProgressRow {

    Integer getId();

    String getName();

    /** Tổng số câu trắc nghiệm. */
    Integer getTotal();

    /** Số câu đã làm (mỗi câu tính một lần, theo lần làm gần nhất). */
    Integer getAnswered();

    /** Số câu mà lần làm gần nhất là đúng. */
    Integer getCorrect();
}
