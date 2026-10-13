package dto.view;

/**
 * Tiến độ của học sinh trên một chủ đề hoặc một bài học (FR-STU-06), tính theo lần làm GẦN NHẤT của mỗi câu (BR-10).
 * completionPct = đã làm / tổng số câu; correctPct = đúng / đã làm (null khi chưa làm câu nào).
 */
public record ProgressView(int id, String name, int total, int answered, int correct) {

    public int getId() { return id; }
    public String getName() { return name; }
    public int getTotal() { return total; }
    public int getAnswered() { return answered; }
    public int getCorrect() { return correct; }

    public int getCompletionPct() {
        return total == 0 ? 0 : (int) Math.round(answered * 100.0 / total);
    }

    public Double getCorrectPct() {
        return answered == 0 ? null : Math.round(correct * 1000.0 / answered) / 10.0;
    }
}
