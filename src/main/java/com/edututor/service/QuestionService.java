package com.edututor.service;

import com.edututor.dto.OptionView;
import com.edututor.dto.PageResult;
import com.edututor.dto.QuestionForm;
import com.edututor.dto.QuestionGenerationDTO;
import com.edututor.dto.QuestionView;
import com.edututor.exception.ConflictException;
import com.edututor.exception.ForbiddenException;
import com.edututor.exception.NotFoundException;
import com.edututor.model.Lesson;
import com.edututor.model.Question;
import com.edututor.model.QuestionOption;
import com.edututor.model.QuestionType;
import com.edututor.repository.LessonRepository;
import com.edututor.repository.QuestionOptionRepository;
import com.edututor.repository.QuestionRepository;
import com.edututor.repository.SubmissionRepository;
import com.edututor.repository.UserRepository;
import com.edututor.repository.spec.QuestionSpecs;
import com.edututor.util.HtmlSanitizer;
import com.edututor.util.Pager;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Iterator;
import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Nghiệp vụ ngân hàng câu hỏi (UC-TEA-04, UC-TEA-06). */
@Service
public class QuestionService {

    public static final String[] LETTERS = {"A", "B", "C", "D"};

    private final QuestionRepository questionRepository;
    private final QuestionOptionRepository optionRepository;
    private final LessonRepository lessonRepository;
    private final SubmissionRepository submissionRepository;
    private final UserRepository userRepository;

    public QuestionService(QuestionRepository questionRepository, QuestionOptionRepository optionRepository,
                           LessonRepository lessonRepository, SubmissionRepository submissionRepository,
                           UserRepository userRepository) {
        this.questionRepository = questionRepository;
        this.optionRepository = optionRepository;
        this.lessonRepository = lessonRepository;
        this.submissionRepository = submissionRepository;
        this.userRepository = userRepository;
    }

    /** Danh sách có lọc + phân trang ở CSDL. Tham số lọc &lt;= 0 / rỗng nghĩa là không lọc. */
    @Transactional(readOnly = true)
    public PageResult<QuestionView> search(int topicId, int lessonId, String type, int level, int page, int size) {
        Page<Question> result = questionRepository.findAll(
                QuestionSpecs.search(topicId, lessonId, parseType(type), level),
                Pager.pageRequest(page, size, Sort.by(Sort.Order.desc("createdAt"), Sort.Order.desc("questionId"))));
        return PageResult.of(result, ViewMapper::toView);
    }

    private QuestionType parseType(String type) {
        if ("MCQ".equals(type)) {
            return QuestionType.MCQ;
        }
        return "ESSAY".equals(type) ? QuestionType.ESSAY : null;
    }

    /** Câu tự luận của bài học cho học sinh chọn: không kèm lời giải (BR-11). */
    @Transactional(readOnly = true)
    public List<QuestionView> getEssayQuestions(int lessonId) {
        return questionRepository
                .findByLesson_LessonIdAndQuestionTypeOrderByCreatedAtAscQuestionIdAsc(lessonId, QuestionType.ESSAY)
                .stream().map(q -> {
                    QuestionView v = ViewMapper.toView(q);
                    v.setExplanation(null);
                    return v;
                }).toList();
    }

    /** Câu hỏi kèm phương án (có cờ đúng) để giáo viên sửa; null nếu không tồn tại. */
    @Transactional(readOnly = true)
    public QuestionView getQuestionForEdit(int questionId) {
        return questionRepository.findWithOptionsByQuestionId(questionId).map(q -> {
            QuestionView v = ViewMapper.toView(q);
            List<OptionView> options = new ArrayList<>();
            for (QuestionOption o : q.getOptions()) {
                options.add(ViewMapper.toView(o));
            }
            v.setOptions(options);
            return v;
        }).orElse(null);
    }

    /**
     * UC-TEA-04: tạo câu hỏi thủ công. Câu hỏi và 4 phương án được lưu trong cùng một transaction
     * (cascade PERSIST từ Question).
     *
     * @return ID câu hỏi mới
     */
    @Transactional
    public int createQuestion(QuestionForm form, int teacherId) {
        Question q = new Question();
        q.setTeacher(userRepository.getReferenceById(teacherId));
        q.setAiGenerated(false);
        applyQuestion(q, form);
        if (q.getQuestionType() == QuestionType.MCQ) {
            for (QuestionOption o : buildOptions(form.getCorrectOption(), form.getOptionTexts())) {
                q.addOption(o);
            }
        }
        return questionRepository.save(q).getQuestionId();
    }

    /** Sửa câu hỏi; phương án được cập nhật tại chỗ theo ký hiệu (giữ nguyên option_id). */
    @Transactional
    public void updateQuestion(QuestionForm form, int actingUserId, boolean admin) {
        Question q = questionRepository.findWithOptionsByQuestionId(form.getId())
                .orElseThrow(() -> new NotFoundException("Câu hỏi không tồn tại."));
        requireOwner(q, actingUserId, admin);
        applyQuestion(q, form);
        if (q.getQuestionType() == QuestionType.MCQ) {
            List<QuestionOption> wanted = buildOptions(form.getCorrectOption(), form.getOptionTexts());
            for (QuestionOption w : wanted) {
                QuestionOption existing = q.getOptions().stream()
                        .filter(o -> o.getOptionLetter().equals(w.getOptionLetter())).findFirst().orElse(null);
                if (existing == null) {
                    q.addOption(w);
                } else {
                    existing.setContent(w.getContent());
                    existing.setCorrect(w.isCorrect());
                }
            }
            removeOptions(q, o -> wanted.stream().noneMatch(w -> w.getOptionLetter().equals(o.getOptionLetter())));
        } else {
            removeOptions(q, o -> true);
        }
    }

    private void removeOptions(Question q, java.util.function.Predicate<QuestionOption> filter) {
        List<QuestionOption> removed = new ArrayList<>();
        for (Iterator<QuestionOption> it = q.getOptions().iterator(); it.hasNext(); ) {
            QuestionOption o = it.next();
            if (filter.test(o)) {
                removed.add(o);
                it.remove();
            }
        }
        optionRepository.deleteAll(removed);
    }

    /** BR-05: câu hỏi đã có bài làm của học sinh thì không xóa để bảo toàn lịch sử. */
    @Transactional
    public void deleteQuestion(int questionId, int actingUserId, boolean admin) {
        Question q = questionRepository.findWithLessonByQuestionId(questionId)
                .orElseThrow(() -> new NotFoundException("Câu hỏi không tồn tại."));
        requireOwner(q, actingUserId, admin);
        if (submissionRepository.countByQuestion_QuestionId(questionId) > 0) {
            throw new ConflictException(
                    "Câu hỏi này đã có bài làm của học sinh nên không thể xóa để bảo toàn lịch sử.");
        }
        questionRepository.delete(q); // các phương án bị xóa theo ON DELETE CASCADE của CSDL
    }

    /** BR-03: giáo viên chỉ sửa/xóa câu hỏi do mình tạo; Admin sửa được tất cả. */
    private void requireOwner(Question q, int actingUserId, boolean admin) {
        if (!admin && !q.getTeacher().getUserId().equals(actingUserId)) {
            throw new ForbiddenException("Bạn chỉ được sửa hoặc xóa câu hỏi do mình tạo.");
        }
    }

    /**
     * UC-TEA-06: lưu hàng loạt câu hỏi do AI sinh (IsAiGenerated = 1) trong MỘT transaction.
     * Validate lại toàn bộ dữ liệu từ modal; một câu lỗi thì rollback cả lô.
     *
     * @return số câu đã lưu
     */
    @Transactional
    public int batchSaveAiQuestions(int teacherId, int lessonId, List<QuestionGenerationDTO> items) {
        if (lessonId <= 0 || !lessonRepository.existsById(lessonId)) {
            throw new IllegalArgumentException("Bài học không hợp lệ.");
        }
        if (items == null || items.isEmpty()) {
            throw new IllegalArgumentException("Không có câu hỏi nào để lưu.");
        }
        Lesson lesson = lessonRepository.getReferenceById(lessonId);
        int index = 0;
        for (QuestionGenerationDTO dto : items) {
            index++;
            try {
                if (dto == null || dto.content() == null || dto.content().isBlank()) {
                    throw new IllegalArgumentException("Nội dung câu hỏi không được để trống.");
                }
                if (dto.content().length() > 4000) {
                    throw new IllegalArgumentException("Nội dung câu hỏi tối đa 4000 ký tự.");
                }
                String correct = null;
                List<String> texts = new ArrayList<>();
                List<QuestionGenerationDTO.Option> sorted = new ArrayList<>(
                        dto.options() == null ? List.of() : dto.options());
                sorted.sort(Comparator.comparing(o -> o.letter() == null ? "" : o.letter().toUpperCase()));
                for (QuestionGenerationDTO.Option o : sorted) {
                    texts.add(HtmlSanitizer.clean(o.content()));
                    if (Boolean.TRUE.equals(o.isCorrect())) {
                        correct = o.letter() == null ? null : o.letter().toUpperCase();
                    }
                }
                long correctCount = sorted.stream().filter(o -> Boolean.TRUE.equals(o.isCorrect())).count();
                if (correctCount != 1) {
                    throw new IllegalArgumentException("Phải có đúng một đáp án đúng.");
                }
                Question q = new Question();
                q.setLesson(lesson);
                q.setTeacher(userRepository.getReferenceById(teacherId));
                q.setQuestionType(QuestionType.MCQ);
                q.setContent(HtmlSanitizer.clean(dto.content().trim()));
                String expl = HtmlSanitizer.clean(dto.explanation());
                q.setExplanationLatex(expl == null || expl.isBlank() ? null : expl.trim());
                int level = dto.level() == null ? 1 : dto.level();
                if (level < 1 || level > 3) {
                    throw new IllegalArgumentException("Mức độ phải là 1 (Dễ), 2 (Trung bình) hoặc 3 (Khó).");
                }
                q.setLevel(level);
                q.setAiGenerated(true);
                for (QuestionOption o : buildOptions(correct, texts)) {
                    q.addOption(o);
                }
                questionRepository.save(q);
            } catch (IllegalArgumentException e) {
                throw new IllegalArgumentException("Câu " + index + ": " + e.getMessage(), e);
            }
        }
        return index;
    }

    private void applyQuestion(Question q, QuestionForm form) {
        Lesson lesson = lessonRepository.findById(form.getLessonId())
                .orElseThrow(() -> new IllegalArgumentException("Vui lòng chọn bài học hợp lệ."));
        q.setLesson(lesson);
        q.setQuestionType(QuestionType.valueOf(form.getType()));
        q.setContent(form.getContent());
        String explanation = form.getExplanation();
        q.setExplanationLatex(explanation == null || explanation.isBlank() ? null : explanation.trim());
        q.setLevel(form.getLevel());
    }

    /** Dựng đúng 4 phương án A-D, có đúng một đáp án đúng (BR-04). */
    private List<QuestionOption> buildOptions(String correctLetter, List<String> texts) {
        if (texts == null || texts.size() != LETTERS.length) {
            throw new IllegalArgumentException("Câu trắc nghiệm phải có đủ 4 phương án A, B, C, D.");
        }
        boolean correctFound = false;
        List<QuestionOption> options = new ArrayList<>();
        for (int i = 0; i < LETTERS.length; i++) {
            String text = texts.get(i) == null ? "" : texts.get(i).trim();
            if (text.isEmpty()) {
                throw new IllegalArgumentException("Phương án " + LETTERS[i] + " không được để trống.");
            }
            QuestionOption o = new QuestionOption();
            o.setOptionLetter(LETTERS[i]);
            o.setContent(text);
            boolean isCorrect = LETTERS[i].equalsIgnoreCase(correctLetter);
            o.setCorrect(isCorrect);
            correctFound |= isCorrect;
            options.add(o);
        }
        if (!correctFound) {
            throw new IllegalArgumentException("Vui lòng chọn một đáp án đúng (A, B, C hoặc D).");
        }
        return options;
    }
}
