package com.edututor.service;

import com.edututor.dto.TutorMessageView;
import com.edututor.dto.TutorSessionView;
import com.edututor.dto.TutorStepResponse;
import com.edututor.exception.ForbiddenException;
import com.edututor.exception.NotFoundException;
import com.edututor.model.SenderType;
import com.edututor.model.TutorMessage;
import com.edututor.model.TutorSession;
import com.edututor.model.TutorStatus;
import com.edututor.repository.LessonRepository;
import com.edututor.repository.TutorMessageRepository;
import com.edututor.repository.TutorSessionRepository;
import com.edututor.repository.UserRepository;
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

    /** Số tin nhắn gần nhất đưa vào ngữ cảnh gửi Gemini. */
    private static final int MAX_CONTEXT_MESSAGES = 20;

    /** Một tin nhắn trong ngữ cảnh hội thoại (không phải Entity). */
    public record ContextMessage(SenderType sender, int step, String text) {
    }

    /** Ngữ cảnh một phiên đang tiếp tục. */
    public record SessionContext(int sessionId, TutorStatus status, String lessonTitle,
                                 List<ContextMessage> messages) {
    }

    private final TutorSessionRepository sessionRepository;
    private final TutorMessageRepository messageRepository;
    private final LessonRepository lessonRepository;
    private final UserRepository userRepository;

    public TutorPersistence(TutorSessionRepository sessionRepository, TutorMessageRepository messageRepository,
                            LessonRepository lessonRepository, UserRepository userRepository) {
        this.sessionRepository = sessionRepository;
        this.messageRepository = messageRepository;
        this.lessonRepository = lessonRepository;
        this.userRepository = userRepository;
    }

    /** @return tiêu đề bài học, hoặc null nếu lessonId trống / không tồn tại */
    @Transactional(readOnly = true)
    public String lessonTitle(Integer lessonId) {
        if (lessonId == null || lessonId <= 0) {
            return null;
        }
        return lessonRepository.findById(lessonId).map(l -> l.getTitle()).orElse(null);
    }

    /** Nạp phiên của học sinh kèm tối đa 20 tin nhắn gần nhất. BR-14: phiên của người khác → 403. */
    @Transactional(readOnly = true)
    public SessionContext loadContext(int studentId, int sessionId) {
        TutorSession s = requireOwned(studentId, sessionId);
        List<TutorMessage> all = messageRepository.findBySession_SessionIdOrderByMessageIdAsc(sessionId);
        List<TutorMessage> tail = all.size() > MAX_CONTEXT_MESSAGES
                ? all.subList(all.size() - MAX_CONTEXT_MESSAGES, all.size()) : all;
        List<ContextMessage> messages = tail.stream()
                .map(m -> new ContextMessage(m.getSenderType(), m.getStepNumber(), m.getContentText())).toList();
        return new SessionContext(sessionId, s.getStatus(), s.getLesson() == null ? null : s.getLesson().getTitle(),
                messages);
    }

    /**
     * Tạo phiên SAU KHI AI đã trả lời thành công (không để lại phiên rỗng khi AI lỗi), rồi lưu 2 tin nhắn đầu tiên.
     *
     * @return ID phiên mới
     */
    @Transactional
    public int startSession(int studentId, Integer lessonId, String title, String userText, String aiText,
                            TutorStepResponse step) {
        TutorSession s = new TutorSession();
        s.setStudent(userRepository.getReferenceById(studentId));
        if (lessonId != null && lessonId > 0 && lessonRepository.existsById(lessonId)) {
            s.setLesson(lessonRepository.getReferenceById(lessonId));
        }
        s.setTitle(title);
        s.setStatus(TutorStatus.ACTIVE);
        sessionRepository.save(s);
        addMessages(s, 1, userText, aiText, step);
        return s.getSessionId();
    }

    /** Lưu 2 tin nhắn (học sinh + AI) và cập nhật trạng thái phiên trong cùng một transaction. */
    @Transactional
    public void saveTurn(int sessionId, int userStep, String userText, String aiText, TutorStepResponse step) {
        TutorSession s = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new NotFoundException("Phiên gia sư không tồn tại."));
        addMessages(s, userStep, userText, aiText, step);
        if (step.isSessionCompleted()) {
            s.setStatus(TutorStatus.COMPLETED);
        }
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
        ai.setStepCompleted(step.isStepCorrect());
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
