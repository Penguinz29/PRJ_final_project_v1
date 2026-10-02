package com.edututor.service;

import com.edututor.dao.QuestionDAO;
import com.edututor.model.Question;
import com.edututor.model.QuestionOption;
import java.util.List;

/**
 * Service xử lý nghiệp vụ Câu hỏi (Question).
 * Theo Spring MVC pattern: @Service
 */
public class QuestionService {

    private final QuestionDAO questionDAO = new QuestionDAO();

    /**
     * UC-TEA-01: Lấy toàn bộ câu hỏi kèm thông tin bài học.
     */
    public List<Question> getAllQuestions() {
        return questionDAO.getAll();
    }

    /**
     * UC-STU-01: Lấy danh sách câu hỏi theo bài học và loại (MCQ/ESSAY).
     * Kèm theo các phương án lựa chọn nếu là MCQ.
     *
     * @param lessonId  ID bài học
     * @param type      loại câu hỏi: "MCQ" hoặc "ESSAY"
     * @return danh sách Question có chứa options nếu là MCQ
     */
    public List<Question> getQuestionsWithOptions(int lessonId, String type) {
        List<Question> questions = questionDAO.getByLessonAndType(lessonId, type);
        if ("MCQ".equals(type)) {
            for (Question q : questions) {
                List<QuestionOption> options = questionDAO.getOptions(q.getQuestionId());
                q.setOptions(options);
            }
        }
        return questions;
    }

    /**
     * Lấy câu hỏi theo ID kèm options.
     */
    public Question getQuestionById(int questionId) {
        Question q = questionDAO.getById(questionId);
        if (q != null && "MCQ".equals(q.getQuestionType())) {
            q.setOptions(questionDAO.getOptions(questionId));
        }
        return q;
    }

    /**
     * Lấy danh sách options của một câu hỏi.
     */
    public List<QuestionOption> getOptions(int questionId) {
        return questionDAO.getOptions(questionId);
    }

    /**
     * UC-TEA-01: Tạo câu hỏi mới (Transaction 1: question + options).
     * INSERT INTO questions -> lấy questionId -> INSERT options
     *
     * @param lessonId  ID bài học liên kết
     * @param type      "MCQ" hoặc "ESSAY"
     * @param content   nội dung câu hỏi
     * @param level     mức độ khó: 1=Dễ, 2=Trung bình, 3=Khó
     * @param teacherId ID giáo viên tạo
     * @param options   danh sách lựa chọn (chỉ dùng nếu type=MCQ)
     * @return ID câu hỏi vừa tạo, -1 nếu thất bại
     * @throws IllegalArgumentException nếu content rỗng
     */
    public int createQuestion(int lessonId, String type, String content,
                               int level, int teacherId, List<QuestionOption> options) {
        if (content == null || content.trim().isEmpty()) {
            throw new IllegalArgumentException("Nội dung câu hỏi không được để trống.");
        }
        Question q = new Question();
        q.setLessonId(lessonId);
        q.setQuestionType(type);
        q.setContent(content.trim());
        q.setLevel(level);
        q.setTeacherId(teacherId);
        q.setAiGenerated(false);

        int questionId = questionDAO.insert(q);
        if (questionId > 0 && "MCQ".equals(type) && options != null && !options.isEmpty()) {
            questionDAO.insertOptions(questionId, options);
        }
        return questionId;
    }

    /**
     * UC-TEA-02: Lưu hàng loạt câu hỏi do AI sinh ra (batch-save).
     * Đánh dấu isAiGenerated = true.
     *
     * @param questions danh sách câu hỏi từ Gemini
     * @param teacherId ID giáo viên xác nhận
     * @param lessonId  ID bài học liên kết
     */
    public void batchSaveAiQuestions(List<Question> questions, int teacherId, int lessonId) {
        for (Question q : questions) {
            q.setTeacherId(teacherId);
            q.setLessonId(lessonId);
            q.setAiGenerated(true);
            int qId = questionDAO.insert(q);
            if (qId > 0 && q.getOptions() != null && !q.getOptions().isEmpty()) {
                questionDAO.insertOptions(qId, q.getOptions());
            }
        }
    }
}
