package com.edututor.service;

import com.edututor.dto.PageResult;
import com.edututor.dto.QuestionView;
import com.edututor.dto.QuizAnswerResponse;
import com.edututor.dto.QuizOptionView;
import com.edututor.dto.QuizQuestionView;
import com.edututor.dto.ReviewForm;
import com.edututor.dto.SubmissionView;
import com.edututor.exception.NotFoundException;
import com.edututor.model.Question;
import com.edututor.model.QuestionOption;
import com.edututor.model.QuestionType;
import com.edututor.model.Submission;
import com.edututor.model.SubmissionStatus;
import com.edututor.repository.QuestionOptionRepository;
import com.edututor.repository.QuestionRepository;
import com.edututor.repository.QuizQuestionRow;
import com.edututor.repository.SubmissionRepository;
import com.edututor.repository.UserRepository;
import com.edututor.util.HtmlSanitizer;
import com.edututor.util.Pager;
import com.edututor.util.ScoreUtil;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Nghiệp vụ bài làm: chấm trắc nghiệm, lịch sử, lưu và duyệt bài tự luận. */
@Service
public class SubmissionService {

    /** Điểm trắc nghiệm quy về thang 10: đúng = 10, sai = 0 (BR-07). */
    private static final BigDecimal MCQ_CORRECT_SCORE = new BigDecimal("10.00");

    private static final Sort NEWEST_FIRST = Sort.by(Sort.Order.desc("submittedAt"), Sort.Order.desc("submissionId"));

    private final SubmissionRepository submissionRepository;
    private final QuestionRepository questionRepository;
    private final QuestionOptionRepository optionRepository;
    private final UserRepository userRepository;

    public SubmissionService(SubmissionRepository submissionRepository, QuestionRepository questionRepository,
                             QuestionOptionRepository optionRepository, UserRepository userRepository) {
        this.submissionRepository = submissionRepository;
        this.questionRepository = questionRepository;
        this.optionRepository = optionRepository;
        this.userRepository = userRepository;
    }

    // ---------- Trắc nghiệm ----------

    /**
     * UC-STU-04: chấm một câu trắc nghiệm, lưu vào Submissions và trả về đáp án + lời giải.
     * Chỉ sau khi nộp câu này, lời giải mới được gửi cho học sinh (BR-11).
     *
     * @throws IllegalArgumentException khi câu hỏi/phương án không hợp lệ
     */
    @Transactional
    public QuizAnswerResponse submitMcqAnswer(int studentId, int questionId, int selectedOptionId) {
        Question q = questionRepository.findWithLessonByQuestionId(questionId).orElse(null);
        if (q == null || q.getQuestionType() != QuestionType.MCQ) {
            throw new IllegalArgumentException("Câu hỏi trắc nghiệm không tồn tại.");
        }
        List<QuestionOption> options = optionRepository.findByQuestion_QuestionIdOrderByOptionLetterAsc(questionId);
        QuestionOption selected = null;
        QuestionOption correct = null;
        for (QuestionOption o : options) {
            if (o.getOptionId() == selectedOptionId) {
                selected = o;
            }
            if (o.isCorrect()) {
                correct = o;
            }
        }
        if (selected == null) {
            throw new IllegalArgumentException("Phương án đã chọn không thuộc câu hỏi này.");
        }
        boolean isCorrect = selected.isCorrect();
        submissionRepository.save(newMcqSubmission(studentId, q, selected.getOptionLetter(), isCorrect));
        String explanation = q.getExplanationLatex() == null ? null : HtmlSanitizer.clean(q.getExplanationLatex());
        return new QuizAnswerResponse(isCorrect, correct != null ? correct.getOptionId() : null,
                correct != null ? correct.getOptionLetter() : null, explanation,
                isCorrect ? MCQ_CORRECT_SCORE.doubleValue() : 0.0, !isCorrect);
    }

    /** Số câu mỗi đề (UC-STU-03): 5–30, mặc định 10. */
    public static final int QUIZ_MIN = 5;
    public static final int QUIZ_MAX = 30;
    public static final int QUIZ_DEFAULT = 10;

    /**
     * UC-STU-03: đề trắc nghiệm ngẫu nhiên của một bài học — KHÔNG kèm đáp án đúng / lời giải (BR-11); phương án
     * nạp bằng MỘT truy vấn IN (không N+1).
     *
     * @param level 0 = mọi mức độ; 1..3 = lọc theo mức độ
     * @param limit số câu, ép vào khoảng 5–30
     */
    @Transactional(readOnly = true)
    public List<QuizQuestionView> getQuizQuestions(int lessonId, int level, int limit) {
        int lv = (level >= 1 && level <= 3) ? level : 0;
        int n = Math.min(QUIZ_MAX, Math.max(QUIZ_MIN, limit));
        List<QuizQuestionView> questions = new ArrayList<>();
        for (QuizQuestionRow r : questionRepository.pickRandomQuizQuestions(lessonId, lv, n)) {
            questions.add(new QuizQuestionView(r.getQuestionId(), r.getContent(), r.getLevel(),
                    Boolean.TRUE.equals(r.getAiGenerated())));
        }
        if (questions.isEmpty()) {
            return questions;
        }
        Map<Integer, QuizQuestionView> byId = new LinkedHashMap<>();
        for (QuizQuestionView q : questions) {
            byId.put(q.getQuestionId(), q);
        }
        for (QuizOptionView o : optionRepository.findQuizOptions(byId.keySet())) {
            byId.get(o.getQuestionId()).getOptions().add(o);
        }
        return questions;
    }

    private Submission newMcqSubmission(int studentId, Question q, String letter, boolean correct) {
        Submission sub = new Submission();
        sub.setStudent(userRepository.getReferenceById(studentId));
        sub.setLesson(q.getLesson());
        sub.setQuestion(q);
        sub.setQuestionType(QuestionType.MCQ);
        sub.setStudentAnswer(letter);
        sub.setIsCorrect(correct);
        sub.setFinalScore(correct ? MCQ_CORRECT_SCORE : BigDecimal.ZERO.setScale(2)); // BR-07: đúng 10, sai 0
        sub.setStatus(SubmissionStatus.GRADED); // trắc nghiệm tự chấm, không cần giáo viên duyệt
        return sub;
    }

    // ---------- Lịch sử & thống kê học sinh ----------

    /**
     * Lịch sử làm bài của một học sinh, phân trang ở CSDL (UC-STU-06).
     *
     * @param type     MCQ | ESSAY | ALL
     * @param lessonId &lt;= 0: mọi bài học
     */
    @Transactional(readOnly = true)
    public PageResult<SubmissionView> getStudentHistory(int studentId, String type, int lessonId, int page, int size) {
        PageRequest pr = Pager.pageRequest(page, size, NEWEST_FIRST);
        boolean byType = "MCQ".equals(type) || "ESSAY".equals(type);
        Page<Submission> result;
        if (lessonId > 0) {
            result = byType
                    ? submissionRepository.findByStudent_UserIdAndQuestionTypeAndQuestion_Lesson_LessonId(
                            studentId, QuestionType.valueOf(type), lessonId, pr)
                    : submissionRepository.findByStudent_UserIdAndQuestion_Lesson_LessonId(studentId, lessonId, pr);
        } else {
            result = byType
                    ? submissionRepository.findByStudent_UserIdAndQuestionType(studentId, QuestionType.valueOf(type), pr)
                    : submissionRepository.findByStudent_UserId(studentId, pr);
        }
        return PageResult.of(result, ViewMapper::toView);
    }

    @Transactional(readOnly = true)
    public List<SubmissionView> getRecentAttempts(int studentId, int limit) {
        return submissionRepository.findByStudent_UserId(studentId, PageRequest.of(0, limit, NEWEST_FIRST))
                .map(ViewMapper::toView).getContent();
    }

    // ---------- Tự luận: lưu bài, giáo viên duyệt ----------

    /** Lưu bài tự luận đã được AI chấm (chờ giáo viên duyệt). Gọi SAU khi AI trả lời, ngoài transaction chờ AI. */
    @Transactional
    public int saveEssaySubmission(int studentId, int questionId, String studentAnswer, String imagePath,
                                   double score, String aiFeedback, String suggestedCorrection) {
        Question q = questionRepository.findWithLessonByQuestionId(questionId)
                .orElseThrow(() -> new NotFoundException("Câu hỏi tự luận không tồn tại."));
        Submission sub = new Submission();
        sub.setStudent(userRepository.getReferenceById(studentId));
        sub.setLesson(q.getLesson());
        sub.setQuestion(q);
        sub.setQuestionType(QuestionType.ESSAY);
        sub.setStudentAnswer(studentAnswer);
        sub.setEssayImagePath(imagePath);
        // BR-09: ai_score là đề xuất, giữ nguyên mãi; final_score ban đầu bằng ai_score cho tới khi giáo viên duyệt
        sub.setAiScore(ScoreUtil.toDecimal(score));
        sub.setFinalScore(ScoreUtil.toDecimal(score));
        sub.setAiFeedback(aiFeedback);
        sub.setSuggestedCorrection(suggestedCorrection == null || suggestedCorrection.isBlank() ? null : suggestedCorrection);
        sub.setStatus(SubmissionStatus.AI_GRADED);
        return submissionRepository.saveAndFlush(sub).getSubmissionId();
    }

    @Transactional(readOnly = true)
    public PageResult<SubmissionView> getEssaySubmissions(boolean reviewed, int page, int size) {
        return PageResult.of(submissionRepository.findByQuestionTypeAndReviewed(QuestionType.ESSAY, reviewed,
                Pager.pageRequest(page, size, NEWEST_FIRST)), ViewMapper::toView);
    }

    @Transactional(readOnly = true)
    public long countEssaySubmissions(boolean reviewed) {
        return submissionRepository.countByQuestionTypeAndReviewed(QuestionType.ESSAY, reviewed);
    }

    @Transactional(readOnly = true)
    public List<SubmissionView> getRecentEssays(int limit) {
        return submissionRepository.findByQuestionType(QuestionType.ESSAY, PageRequest.of(0, limit, NEWEST_FIRST))
                .map(ViewMapper::toView).getContent();
    }

    @Transactional(readOnly = true)
    public SubmissionView getSubmissionById(int submissionId) {
        return submissionRepository.findWithDetailsBySubmissionId(submissionId).map(ViewMapper::toView).orElse(null);
    }

    /**
     * Chủ sở hữu của một ảnh bài làm: dùng để kiểm tra quyền khi phục vụ ảnh (chủ bài, giáo viên, admin).
     *
     * @return ID học sinh sở hữu bài làm chứa ảnh này, rỗng nếu không có bài nào
     */
    @Transactional(readOnly = true)
    public Optional<Integer> findEssayImageOwner(String imagePath) {
        return submissionRepository.findByEssayImagePath(imagePath).map(s -> s.getStudent().getUserId());
    }

    /**
     * UC-TEA-07: giáo viên xác nhận / hiệu chỉnh điểm bài tự luận (VAL-20: 0–10, bước 0.25; VAL-21: nhận xét ≤ 1000).
     * BR-09: chỉ sửa final_score; ai_score giữ nguyên (cột còn được khóa ở tầng ORM bằng updatable = false).
     * Bài chuyển AI_GRADED → REVIEWED, ghi người duyệt và thời điểm duyệt.
     *
     * @param score       điểm chính thức giáo viên nhập; null khi keepAiScore
     * @param keepAiScore true: "Duyệt giữ nguyên điểm AI" (final_score = ai_score)
     * @throws IllegalArgumentException khi điểm không hợp lệ / thiếu điểm
     * @throws NotFoundException        khi bài nộp không tồn tại hoặc không phải tự luận
     */
    @Transactional
    public void reviewEssay(ReviewForm form, Double score, boolean keepAiScore, int reviewerId) {
        Submission s = submissionRepository.findById(form.getSubmissionId())
                .filter(x -> x.getQuestionType() == QuestionType.ESSAY)
                .orElseThrow(() -> new NotFoundException("Không tìm thấy bài làm tự luận yêu cầu."));
        BigDecimal finalScore;
        if (keepAiScore) {
            finalScore = s.getAiScore() != null ? s.getAiScore() : s.getFinalScore();
            if (finalScore == null) {
                throw new IllegalArgumentException("Bài này chưa có điểm AI, vui lòng nhập điểm.");
            }
        } else {
            if (score == null) {
                throw new IllegalArgumentException("Vui lòng nhập điểm (0–10) hoặc chọn \"Duyệt giữ nguyên điểm AI\".");
            }
            if (score < 0.0 || score > 10.0 || !ScoreUtil.isQuarterStep(score)) {
                throw new IllegalArgumentException("Điểm phải từ 0 đến 10, theo bước 0.25.");
            }
            finalScore = ScoreUtil.toDecimal(score);
        }
        boolean correct = form.getIsCorrect() != null ? form.getIsCorrect() : finalScore.doubleValue() >= 5.0;
        s.setIsCorrect(correct);
        s.setFinalScore(finalScore);
        s.setTeacherFeedback(form.getTeacherFeedback() == null ? "" : form.getTeacherFeedback().trim());
        s.setStatus(SubmissionStatus.REVIEWED);
        s.setReviewedBy(userRepository.getReferenceById(reviewerId));
        s.setReviewedAt(LocalDateTime.now());
    }
}
