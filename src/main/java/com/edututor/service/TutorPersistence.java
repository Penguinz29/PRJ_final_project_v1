package com.edututor.service;

import com.edututor.dto.TutorMessageView;
import com.edututor.dto.TutorSessionView;
import com.edututor.dto.TutorStepResponse;
import com.edututor.exception.ConflictException;
import com.edututor.exception.ForbiddenException;
import com.edututor.exception.NotFoundException;
import com.edututor.model.Lesson;
import com.edututor.model.Question;
import com.edututor.model.QuestionOption;
import com.edututor.model.QuestionType;
import com.edututor.model.SenderType;
import com.edututor.model.Submission;
import com.edututor.model.TutorMessage;
import com.edututor.model.TutorSession;
import com.edututor.model.TutorStatus;
import com.edututor.repository.LessonRepository;
import com.edututor.repository.QuestionOptionRepository;
import com.edututor.repository.QuestionRepository;
import com.edututor.repository.SubmissionRepository;
import com.edututor.repository.TutorMessageRepository;
import com.edututor.repository.TutorSessionRepository;
import com.edututor.repository.UserRepository;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Phần truy cập CSDL của gia sư AI, tách thành bean riêng để mỗi thao tác là một transaction NGẮN.
 * {@link AiTutorService} điều phối và gọi Gemini bên ngoài transaction (không giữ kết nối DB khi chờ AI);
 * đặt ở bean khác cũng tránh lỗi self-invocation của {@code @Transactional}.
 */
@Service
public class TutorPersistence {

    /** Chế độ tạo phiên (UC-TUT-01). */
    public enum StartMode {
        FREE, LESSON, QUESTION, SUBMISSION
    }

    /** Một tin nhắn trong ngữ cảnh hội thoại (không phải Entity). */
    public record ContextMessage(SenderType sender, int step, String text) {
    }

    /**
     * Dữ liệu đã kiểm tra để mở phiên mới. reference: lời giải nội bộ giúp AI dẫn dắt đúng (không tiết lộ cho
     * học sinh); openingText: tin nhắn đầu tiên của học sinh được lưu và gửi cho AI.
     */
    public record StartContext(StartMode mode, String problemText, String openingText, Integer lessonId,
                               String lessonTitle, Integer questionId, String reference) {
    }

    /** Ngữ cảnh một phiên đang tiếp tục; mọi trạng thái đọc từ CSDL (server là nguồn sự thật). */
    public record SessionContext(int sessionId, TutorStatus status, String lessonTitle, String problemText,
                                 String reference, int currentStep, int totalSteps, boolean awaitingInput,
                                 String inputHint, List<ContextMessage> messages) {
    }

    private static final int TITLE_MAX = 100;
    private static final int HINT_MAX = 255;

    private final TutorSessionRepository sessionRepository;
    private final TutorMessageRepository messageRepository;
    private final LessonRepository lessonRepository;
    private final QuestionRepository questionRepository;
    private final QuestionOptionRepository optionRepository;
    private final SubmissionRepository submissionRepository;
    private final UserRepository userRepository;

    public TutorPersistence(TutorSessionRepository sessionRepository, TutorMessageRepository messageRepository,
                            LessonRepository lessonRepository, QuestionRepository questionRepository,
                            QuestionOptionRepository optionRepository, SubmissionRepository submissionRepository,
                            UserRepository userRepository) {
        this.sessionRepository = sessionRepository;
        this.messageRepository = messageRepository;
        this.lessonRepository = lessonRepository;
        this.questionRepository = questionRepository;
        this.optionRepository = optionRepository;
        this.submissionRepository = submissionRepository;
        this.userRepository = userRepository;
    }

    /**
     * UC-TUT-01 bước 1: kiểm tra dữ liệu và quyền, dựng đề bài của phiên theo chế độ.
     *
     * @throws IllegalArgumentException thiếu dữ liệu bắt buộc
     * @throws ForbiddenException       câu hỏi chưa làm sai / bài tự luận không phải của học sinh
     * @throws NotFoundException        bài học / câu hỏi / bài nộp không tồn tại
     */
    @Transactional(readOnly = true)
    public StartContext prepareStart(int studentId, StartMode mode, String problemText, Integer lessonId,
                                     Integer questionId, Integer selectedOptionId, Integer submissionId) {
        String text = problemText == null ? "" : problemText.trim();
        switch (mode) {
            case FREE, LESSON -> {
                if (text.isEmpty()) {
                    throw new IllegalArgumentException("Vui lòng nhập bài toán của bạn.");
                }
                if (text.length() > 2000) {
                    throw new IllegalArgumentException("Nội dung quá dài (tối đa 2000 ký tự).");
                }
                Lesson lesson = null;
                if (lessonId != null && lessonId > 0) {
                    lesson = lessonRepository.findById(lessonId).orElse(null);
                }
                if (mode == StartMode.LESSON && lesson == null) {
                    throw new NotFoundException("Bài học không tồn tại.");
                }
                return new StartContext(mode, text, text, lesson == null ? null : lesson.getLessonId(),
                        lesson == null ? null : lesson.getTitle(), null, null);
            }
            case QUESTION -> {
                if (questionId == null) {
                    throw new IllegalArgumentException("Thiếu câu hỏi cần hỏi gia sư.");
                }
                Question q = questionRepository.findWithLessonByQuestionId(questionId)
                        .orElseThrow(() -> new NotFoundException("Câu hỏi không tồn tại."));
                if (q.getQuestionType() != QuestionType.MCQ) {
                    throw new IllegalArgumentException("Chế độ này chỉ dành cho câu trắc nghiệm.");
                }
                List<Submission> wrong = submissionRepository.findWrongAttempts(studentId, questionId,
                        PageRequest.of(0, 1));
                if (wrong.isEmpty()) {
                    throw new ForbiddenException("Bạn chỉ có thể hỏi gia sư về câu trắc nghiệm mình đã làm sai.");
                }
                String chosen = describeChosen(questionId, selectedOptionId, wrong.get(0).getStudentAnswer());
                String problem = q.getContent() + "\n\nHọc sinh đã chọn: " + chosen;
                return new StartContext(mode, problem, "Em làm sai câu trắc nghiệm này, hãy hướng dẫn em:\n" + problem,
                        q.getLesson().getLessonId(), q.getLesson().getTitle(), q.getQuestionId(),
                        q.getExplanationLatex());
            }
            case SUBMISSION -> {
                if (submissionId == null) {
                    throw new IllegalArgumentException("Thiếu bài tự luận cần hỏi gia sư.");
                }
                Submission s = submissionRepository.findWithDetailsBySubmissionId(submissionId)
                        .orElseThrow(() -> new NotFoundException("Bài làm không tồn tại."));
                if (!s.getStudent().getUserId().equals(studentId)) {
                    throw new ForbiddenException("Bạn không có quyền truy cập bài làm này.");
                }
                if (s.getQuestionType() != QuestionType.ESSAY) {
                    throw new IllegalArgumentException("Chế độ này chỉ dành cho bài tự luận.");
                }
                Question q = s.getQuestion();
                StringBuilder problem = new StringBuilder(q.getContent());
                if (s.getStudentAnswer() != null && !s.getStudentAnswer().isBlank()) {
                    problem.append("\n\nBài làm của học sinh (đã nhận diện):\n").append(s.getStudentAnswer().trim());
                }
                if (s.getAiFeedback() != null && !s.getAiFeedback().isBlank()) {
                    problem.append("\n\nNhận xét khi chấm bài:\n").append(s.getAiFeedback().trim());
                }
                Lesson lesson = s.getLesson();
                return new StartContext(mode, problem.toString(),
                        "Em muốn hiểu lỗi sai trong bài tự luận này:\n" + q.getContent(),
                        lesson == null ? null : lesson.getLessonId(), lesson == null ? null : lesson.getTitle(),
                        q.getQuestionId(), q.getExplanationLatex());
            }
            default -> throw new IllegalArgumentException("Chế độ không hợp lệ.");
        }
    }

    /** "B. nội dung phương án" của phương án học sinh đã chọn (ưu tiên selectedOptionId nếu thuộc câu hỏi). */
    private String describeChosen(int questionId, Integer selectedOptionId, String letterFromSubmission) {
        List<QuestionOption> options = optionRepository.findByQuestion_QuestionIdOrderByOptionLetterAsc(questionId);
        for (QuestionOption o : options) {
            boolean match = selectedOptionId != null
                    ? o.getOptionId().equals(selectedOptionId)
                    : o.getOptionLetter().equalsIgnoreCase(letterFromSubmission == null ? "" : letterFromSubmission);
            if (match) {
                return o.getOptionLetter() + ". " + o.getContent();
            }
        }
        if (selectedOptionId != null) {
            throw new IllegalArgumentException("Phương án không thuộc câu hỏi.");
        }
        return "(bỏ trống)";
    }

    /** Nạp phiên của học sinh kèm tối đa 20 tin nhắn gần nhất. BR-14: phiên của người khác → 403. */
    @Transactional(readOnly = true)
    public SessionContext loadContext(int studentId, int sessionId) {
        TutorSession s = requireOwned(studentId, sessionId);
        List<TutorMessage> latest = new ArrayList<>(
                messageRepository.findTop20BySession_SessionIdOrderByMessageIdDesc(sessionId));
        Collections.reverse(latest);
        List<ContextMessage> messages = latest.stream()
                .map(m -> new ContextMessage(m.getSenderType(), m.getStepNumber(), m.getContentText())).toList();
        String problem = s.getProblemText() != null ? s.getProblemText() : s.getTitle();
        String reference = s.getQuestion() == null ? null : s.getQuestion().getExplanationLatex();
        return new SessionContext(sessionId, s.getStatus(), s.getLesson() == null ? null : s.getLesson().getTitle(),
                problem, reference, Math.max(1, s.getCurrentStep()), s.getTotalSteps(), s.isAwaitingInput(),
                s.getInputHint(), messages);
    }

    /**
     * Tạo phiên SAU KHI AI đã trả lời thành công (không để lại phiên rỗng khi AI lỗi), rồi lưu 2 tin nhắn đầu tiên.
     *
     * @return ID phiên mới
     */
    @Transactional
    public int startSession(int studentId, StartContext ctx, String aiText, TutorStepResponse step) {
        TutorSession s = new TutorSession();
        s.setStudent(userRepository.getReferenceById(studentId));
        if (ctx.lessonId() != null) {
            s.setLesson(lessonRepository.getReferenceById(ctx.lessonId()));
        }
        if (ctx.questionId() != null) {
            s.setQuestion(questionRepository.getReferenceById(ctx.questionId()));
        }
        String title = ctx.problemText().replaceAll("\\s+", " ").trim();
        s.setTitle(title.length() > TITLE_MAX ? title.substring(0, TITLE_MAX) : title);
        s.setProblemText(ctx.problemText());
        s.setStatus(TutorStatus.ACTIVE);
        applyState(s, step);
        sessionRepository.save(s);
        addMessages(s, 1, ctx.openingText(), aiText, step);
        return s.getSessionId();
    }

    /** Lưu 2 tin nhắn (học sinh + AI) và cập nhật trạng thái phiên trong cùng một transaction. */
    @Transactional
    public void saveTurn(int sessionId, int userStep, String userText, String aiText, TutorStepResponse step) {
        TutorSession s = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new NotFoundException("Phiên gia sư không tồn tại."));
        addMessages(s, userStep, userText, aiText, step);
        applyState(s, step);
    }

    private void applyState(TutorSession s, TutorStepResponse step) {
        s.setCurrentStep(step.currentStep());
        s.setTotalSteps(step.totalSteps());
        s.setAwaitingInput(step.needsStudentInput());
        String hint = step.needsStudentInput() ? step.inputRequestHint() : null;
        s.setInputHint(hint != null && hint.length() > HINT_MAX ? hint.substring(0, HINT_MAX) : hint);
        if (step.isSessionCompleted()) {
            s.setStatus(TutorStatus.COMPLETED);
        }
    }

    /**
     * UC-TUT-04: học sinh chủ động kết thúc phiên đang học → ABANDONED.
     *
     * @throws ConflictException phiên đã kết thúc
     */
    @Transactional
    public void abandon(int studentId, int sessionId) {
        TutorSession s = requireOwned(studentId, sessionId);
        if (s.getStatus() != TutorStatus.ACTIVE) {
            throw new ConflictException("Phiên này đã kết thúc.");
        }
        s.setStatus(TutorStatus.ABANDONED);
        s.setAwaitingInput(false);
        s.setInputHint(null);
    }

    private void addMessages(TutorSession s, int userStep, String userText, String aiText, TutorStepResponse step) {
        TutorMessage user = new TutorMessage();
        user.setSession(s);
        user.setSenderType(SenderType.USER);
        user.setStepNumber(userStep);
        user.setContentText(userText);
        user.setStepCompleted(false);
        TutorMessage ai = new TutorMessage();
        ai.setSession(s);
        ai.setSenderType(SenderType.AI);
        ai.setStepNumber(step.currentStep());
        ai.setContentText(aiText);
        ai.setStepCompleted(Boolean.TRUE.equals(step.isStepCorrect()));
        messageRepository.saveAll(List.of(user, ai));
    }

    // ---------- Truy vấn cho giao diện ----------

    @Transactional(readOnly = true)
    public List<TutorSessionView> recentSessions(int studentId, int limit) {
        return sessionRepository.findByStudent_UserId(studentId, PageRequest.of(0, limit,
                Sort.by(Sort.Order.desc("createdAt"), Sort.Order.desc("sessionId"))))
                .stream().map(ViewMapper::toView).toList();
    }

    @Transactional(readOnly = true)
    public TutorSessionView getSession(int studentId, int sessionId) {
        return ViewMapper.toView(requireOwned(studentId, sessionId));
    }

    @Transactional(readOnly = true)
    public List<TutorMessageView> getMessages(int studentId, int sessionId) {
        requireOwned(studentId, sessionId);
        return messageRepository.findBySession_SessionIdOrderByMessageIdAsc(sessionId).stream()
                .map(ViewMapper::toView).toList();
    }

    private TutorSession requireOwned(int studentId, int sessionId) {
        TutorSession s = sessionRepository.findWithLessonBySessionId(sessionId)
                .orElseThrow(() -> new NotFoundException("Phiên gia sư không tồn tại."));
        if (!s.getStudent().getUserId().equals(studentId)) {
            throw new ForbiddenException("Bạn không có quyền truy cập phiên gia sư này.");
        }
        return s;
    }
}
