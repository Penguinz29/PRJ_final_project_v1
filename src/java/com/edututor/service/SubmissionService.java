package com.edututor.service;

import com.edututor.dao.SubmissionDAO;
import com.edututor.dao.QuestionDAO;
import com.edututor.model.Submission;
import com.edututor.model.Question;
import com.edututor.model.QuestionOption;
import java.util.List;

/**
 * Service xử lý nghiệp vụ Bài nộp (Submission).
 * Theo Spring MVC pattern: @Service
 */
public class SubmissionService {

    private final SubmissionDAO submissionDAO = new SubmissionDAO();
    private final QuestionDAO questionDAO = new QuestionDAO();

    /**
     * UC-STU-02: Nộp đáp án trắc nghiệm (MCQ).
     * Kiểm tra đáp án, tính điểm, lưu vào DB.
     *
     * @param studentId       ID học sinh
     * @param lessonId        ID bài học
     * @param questionId      ID câu hỏi
     * @param selectedOptionId ID option học sinh chọn
     * @return Submission đã được lưu với trường isCorrect và score
     */
    public Submission submitMcqAnswer(int studentId, int lessonId,
                                       int questionId, int selectedOptionId) {
        // Lấy danh sách options để kiểm tra đáp án
        List<QuestionOption> options = questionDAO.getOptions(questionId);
        boolean isCorrect = false;
        String selectedAnswerText = "";

        for (QuestionOption opt : options) {
            if (opt.getOptionId() == selectedOptionId) {
                isCorrect = opt.isCorrect();
                selectedAnswerText = opt.getOptionLetter() + ". " + opt.getContent();
                break;
            }
        }

        // Tạo và lưu submission
        Submission sub = new Submission();
        sub.setStudentId(studentId);
        sub.setLessonId(lessonId);
        sub.setQuestionId(questionId);
        sub.setQuestionType("MCQ");
        sub.setStudentAnswer(selectedAnswerText);
        sub.setIsCorrect(isCorrect);
        sub.setScore(isCorrect ? 1.0 : 0.0);
        sub.setReviewed(true); // MCQ tự chấm, không cần giáo viên review

        submissionDAO.insert(sub);
        return sub;
    }

    /**
     * UC-STU-02: Nộp toàn bộ bài trắc nghiệm.
     * Duyệt từng câu hỏi, lưu kể cả câu bỏ trống.
     *
     * @param studentId      ID học sinh
     * @param lessonId       ID bài học
     * @param questionIds    mảng ID câu hỏi
     * @param selectedOptions mảng ID option được chọn (0 = không chọn)
     */
    public void submitQuiz(int studentId, int lessonId,
                            int[] questionIds, int[] selectedOptions) {
        for (int i = 0; i < questionIds.length; i++) {
            int qId = questionIds[i];
            int optId = (selectedOptions != null && i < selectedOptions.length) ? selectedOptions[i] : 0;

            Submission sub = new Submission();
            sub.setStudentId(studentId);
            sub.setLessonId(lessonId);
            sub.setQuestionId(qId);
            sub.setQuestionType("MCQ");

            if (optId > 0) {
                // Câu có chọn
                List<QuestionOption> options = questionDAO.getOptions(qId);
                boolean correct = false;
                String answer = "";
                for (QuestionOption opt : options) {
                    if (opt.getOptionId() == optId) {
                        correct = opt.isCorrect();
                        answer = opt.getOptionLetter() + ". " + opt.getContent();
                        break;
                    }
                }
                sub.setStudentAnswer(answer);
                sub.setIsCorrect(correct);
                sub.setScore(correct ? 1.0 : 0.0);
            } else {
                // Câu bỏ trống
                sub.setStudentAnswer("");
                sub.setIsCorrect(false);
                sub.setScore(0.0);
            }
            sub.setReviewed(true);
            submissionDAO.insert(sub);
        }
    }

    /**
     * UC-STU-04: Lấy lịch sử làm bài của học sinh (có phân trang).
     *
     * @param studentId ID học sinh
     * @param type      loại: "MCQ", "ESSAY" hoặc "ALL"
     * @param page      trang hiện tại (bắt đầu từ 1)
     * @param pageSize  số bản ghi mỗi trang
     */
    public List<Submission> getStudentHistory(int studentId, String type, int page, int pageSize) {
        return submissionDAO.getHistory(studentId, type, page, pageSize);
    }

    /**
     * UC-STU-04: Đếm tổng số bài nộp để phân trang.
     */
    public int countStudentHistory(int studentId, String type) {
        return submissionDAO.countHistory(studentId, type);
    }

    /**
     * UC-OCR-02 / FR-TEA-04: Lấy danh sách bài tự luận cần giáo viên chấm.
     */
    public List<Submission> getEssaySubmissionsForTeacher(int teacherId, boolean reviewed,
                                                            int page, int pageSize) {
        return submissionDAO.getSubmissionsForTeacher(teacherId, reviewed, page, pageSize);
    }

    /**
     * FR-TEA-04: Đếm số bài tự luận theo trạng thái.
     */
    public int countEssaySubmissions(int teacherId, boolean reviewed) {
        return submissionDAO.countSubmissionsForTeacher(teacherId, reviewed);
    }

    /**
     * FR-TEA-04: Lấy chi tiết bài nộp.
     */
    public Submission getSubmissionById(int submissionId) {
        return submissionDAO.getById(submissionId);
    }

    /**
     * UC-OCR-02: Giáo viên chấm điểm và nhận xét bài tự luận.
     *
     * @param submissionId  ID bài nộp
     * @param isCorrect     kết quả đúng/sai
     * @param score         điểm (0.0 - 10.0)
     * @param feedback      nhận xét của giáo viên
     * @return true nếu cập nhật thành công
     */
    public boolean reviewEssay(int submissionId, boolean isCorrect,
                                Double score, String feedback) {
        return submissionDAO.updateReview(submissionId, isCorrect, score, feedback);
    }
}
