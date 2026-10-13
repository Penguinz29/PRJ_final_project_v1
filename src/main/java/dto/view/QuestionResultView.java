package dto.view;

/**
 * Kết quả trắc nghiệm theo câu hỏi (FR-TEA-08). Hiển thị song song tỉ lệ đúng (correctPct, %) và điểm trung bình
 * thang 10 (avgScore = correctPct / 10, vì đúng = 10, sai = 0 theo BR-07). correctPct / avgScore null = chưa ai làm.
 */
public record QuestionResultView(int questionId, String content, int level, int attempts, int students,
                                 Double correctPct, Double avgScore) {

    /** Dùng trong JSP (EL đọc thuộc tính của record qua getter). */
    public int getQuestionId() { return questionId; }
    public String getContent() { return content; }
    public int getLevel() { return level; }
    public int getAttempts() { return attempts; }
    public int getStudents() { return students; }
    public Double getCorrectPct() { return correctPct; }
    public Double getAvgScore() { return avgScore; }
}
