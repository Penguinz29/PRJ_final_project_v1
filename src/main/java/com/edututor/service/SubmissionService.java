package com.edututor.service;

import com.edututor.dto.AttemptResult;
import com.edututor.dto.OptionView;
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
import com.edututor.repository.QuestionOptionRepository;
import com.edututor.repository.QuestionRepository;
import com.edututor.repository.SubmissionRepository;
import com.edututor.repository.UserRepository;
import com.edututor.util.Pager;
import com.edututor.util.ScoreUtil;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
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
        return new QuizAnswerResponse(isCorrect, correct != null ? correct.getOptionLetter() : null,
                q.getExplanationLatex(), isCorrect ? MCQ_CORRECT_SCORE.doubleValue() : 0.0);
    }

    /** Câu hỏi làm bài của một bài học: KHÔNG kèm đáp án đúng/lời giải; phương án nạp bằng MỘT truy vấn IN. */
    @Transactional(readOnly = true)
    public List<QuizQuestionView> getQuizQuestions(int lessonId) {
        List<QuizQuestionView> questions = questionRepository.findQuizQuestions(lessonId);
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

    /**
     * UC-STU-04: chấm cả bài trắc nghiệm của một bài học (form nộp bài), lưu từng câu kể cả câu bỏ trống.
     *
     * @param answers map questionId -> chữ cái đáp án đã chọn (có thể thiếu nếu bỏ trống)
     */
    @Transactional
    public AttemptResult gradeQuiz(int studentId, int lessonId, Map<Integer, String> answers) {
        List<Question> questions = questionRepository
                .findByLesson_LessonIdAndQuestionTypeOrderByCreatedAtAscQuestionIdAsc(lessonId, QuestionType.MCQ);
        Map<Integer, List<QuestionOption>> optionsByQuestion = new HashMap<>();
        if (!questions.isEmpty()) {
            List<Integer> ids = questions.stream().map(Question::getQuestionId).toList();
            for (QuestionOption o : optionRepository
                    .findByQuestion_QuestionIdInOrderByQuestion_QuestionIdAscOptionLetterAsc(ids)) {
                optionsByQuestion.computeIfAbsent(o.getQuestion().getQuestionId(), k -> new ArrayList<>()).add(o);
            }
        }
        List<AttemptResult.AttemptResultItem> items = new ArrayList<>();
        List<Submission> toSave = new ArrayList<>();
        int correctCount = 0;
        for (Question q : questions) {
            String studentAnswer = answers.get(q.getQuestionId());
            List<QuestionOption> options = optionsByQuestion.getOrDefault(q.getQuestionId(), List.of());
            String correctLetter = "";
            List<OptionView> optionViews = new ArrayList<>();
            for (QuestionOption o : options) {
                optionViews.add(ViewMapper.toView(o));
                if (o.isCorrect()) {
                    correctLetter = o.getOptionLetter();
                }
            }
            boolean isCorrect = studentAnswer != null && studentAnswer.equals(correctLetter);
            if (isCorrect) {
                correctCount++;
            }
            QuestionView qv = ViewMapper.toView(q);
            AttemptResult.AttemptResultItem item = new AttemptResult.AttemptResultItem();
            item.setQuestion(qv);
            item.setOptions(optionViews);
            item.setStudentAnswer(studentAnswer);
            item.setCorrectAnswer(correctLetter);
            item.setCorrect(isCorrect);
            items.add(item);
            toSave.add(newMcqSubmission(studentId, q, studentAnswer == null ? "" : studentAnswer, isCorrect));
        }
        submissionRepository.saveAll(toSave);
        AttemptResult result = new AttemptResult();
        result.setItems(items);
        result.setCorrectCount(correctCount);
        result.setTotalQuestions(questions.size());
        result.setScore(questions.isEmpty() ? 0 : (double) correctCount / questions.size() * 100.0);
        return result;
    }

    private Submission newMcqSubmission(int studentId, Question q, String letter, boolean correct) {
        Submission sub = new Submission();
        sub.setStudent(userRepository.getReferenceById(studentId));
        sub.setLesson(q.getLesson());
        sub.setQuestion(q);
        sub.setQuestionType(QuestionType.MCQ);
        sub.setStudentAnswer(letter);
        sub.setIsCorrect(correct);
        sub.setScore(correct ? MCQ_CORRECT_SCORE : BigDecimal.ZERO.setScale(2));
        sub.setReviewed(true); // trắc nghiệm tự chấm, không cần giáo viên duyệt
        return sub;
    }

    // ---------- Lịch sử & thống kê học sinh ----------

    /** Lịch sử làm bài của một học sinh, phân trang ở CSDL. type: MCQ | ESSAY | ALL. */
    @Transactional(readOnly = true)
    public PageResult<SubmissionView> getStudentHistory(int studentId, String type, int page, int size) {
        PageRequest pr = Pager.pageRequest(page, size, NEWEST_FIRST);
        Page<Submission> result = ("MCQ".equals(type) || "ESSAY".equals(type))
                ? submissionRepository.findByStudent_UserIdAndQuestionType(studentId, QuestionType.valueOf(type), pr)
                : submissionRepository.findByStudent_UserId(studentId, pr);
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
                                   double score, String aiFeedback) {
        Question q = questionRepository.findWithLessonByQuestionId(questionId)
                .orElseThrow(() -> new NotFoundException("Câu hỏi tự luận không tồn tại."));
        Submission sub = new Submission();
        sub.setStudent(userRepository.getReferenceById(studentId));
        sub.setLesson(q.getLesson());
        sub.setQuestion(q);
        sub.setQuestionType(QuestionType.ESSAY);
        sub.setStudentAnswer(studentAnswer);
        sub.setEssayImagePath(imagePath);
        sub.setScore(ScoreUtil.toDecimal(score));
        sub.setAiFeedback(aiFeedback);
        sub.setReviewed(false);
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
     * Giáo viên xác nhận / hiệu chỉnh điểm bài tự luận (thang 10, bước 0.25).
     *
     * @throws IllegalArgumentException khi điểm không hợp lệ
     * @throws NotFoundException        khi bài nộp không tồn tại hoặc không phải tự luận
     */
    @Transactional
    public void reviewEssay(ReviewForm form, Double score) {
        Submission s = submissionRepository.findById(form.getSubmissionId())
                .filter(x -> x.getQuestionType() == QuestionType.ESSAY)
                .orElseThrow(() -> new NotFoundException("Không tìm thấy bài làm tự luận yêu cầu."));
        if (score != null && (score < 0.0 || score > 10.0 || !ScoreUtil.isQuarterStep(score))) {
            throw new IllegalArgumentException("Điểm phải từ 0 đến 10, theo bước 0.25.");
        }
        boolean correct = form.getIsCorrect() != null ? form.getIsCorrect() : (score != null && score >= 5.0);
        s.setIsCorrect(correct);
        s.setScore(score == null ? null : ScoreUtil.toDecimal(score));
        s.setTeacherFeedback(form.getTeacherFeedback() == null ? "" : form.getTeacherFeedback().trim());
        s.setReviewed(true);
    }
}
