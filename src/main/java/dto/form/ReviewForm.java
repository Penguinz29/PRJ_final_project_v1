package dto.form;

import jakarta.validation.constraints.Size;

/** Form giáo viên duyệt bài tự luận (VAL-20, VAL-21). Điểm nhận dạng chuỗi để chấp nhận cả "8,5" lẫn "8.5". */
public class ReviewForm {

    private int submissionId;
    private String score;
    private Boolean isCorrect;

    @Size(max = 1000, message = "{val.teacherComment.size}")
    private String teacherFeedback;

    public int getSubmissionId() { return submissionId; }
    public void setSubmissionId(int submissionId) { this.submissionId = submissionId; }
    public String getScore() { return score; }
    public void setScore(String score) { this.score = score; }
    public Boolean getIsCorrect() { return isCorrect; }
    public void setIsCorrect(Boolean isCorrect) { this.isCorrect = isCorrect; }
    public String getTeacherFeedback() { return teacherFeedback; }
    public void setTeacherFeedback(String teacherFeedback) { this.teacherFeedback = teacherFeedback; }
}
