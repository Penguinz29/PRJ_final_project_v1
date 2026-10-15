package repository;

/** Projection thống kê bài làm gộp theo chủ đề hoặc theo bài giảng (trang kết quả của Admin). */
public interface ResultGroupRow {

    Integer getId();

    String getName();

    /** Số bài giảng đang hoạt động (chỉ có nghĩa ở cấp chủ đề). */
    Integer getLessons();

    Integer getAttempts();

    Integer getStudents();

    /** Điểm trung bình thang 10 (FinalScore); null = chưa có bài làm chấm xong. */
    Double getAvgScore();
}
