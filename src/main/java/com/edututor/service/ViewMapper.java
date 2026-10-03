package com.edututor.service;

import com.edututor.dto.AiConfigView;
import com.edututor.dto.LessonView;
import com.edututor.dto.OptionView;
import com.edututor.dto.QuestionView;
import com.edututor.dto.SubmissionView;
import com.edututor.dto.TopicView;
import com.edututor.dto.TutorMessageView;
import com.edututor.dto.TutorSessionView;
import com.edututor.dto.UserView;
import com.edututor.model.AiConfig;
import com.edututor.model.Lesson;
import com.edututor.model.Question;
import com.edututor.model.QuestionOption;
import com.edututor.model.Submission;
import com.edututor.model.Topic;
import com.edututor.model.TutorMessage;
import com.edututor.model.TutorSession;
import com.edututor.model.User;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Date;

/**
 * Chuyển Entity sang DTO hiển thị. PHẢI được gọi bên trong {@code @Transactional} của Service
 * (các quan hệ LAZY chỉ được đọc khi đã nạp bằng @EntityGraph hoặc truy vấn IN).
 */
final class ViewMapper {

    static final String API_KEY_CONFIG = "GEMINI_API_KEY";

    private ViewMapper() {
    }

    static Date toDate(LocalDateTime t) {
        return t == null ? null : Date.from(t.atZone(ZoneId.systemDefault()).toInstant());
    }

    static UserView toView(User u, String teacherName) {
        UserView v = new UserView();
        v.setUserId(u.getUserId());
        v.setUsername(u.getUsername());
        v.setFullName(u.getFullName());
        v.setEmail(u.getEmail());
        v.setRole(u.getRole().name());
        v.setActive(u.isActive());
        v.setStatus(u.getStatus().name());
        v.setTeacherId(u.getTeacherId());
        v.setCreatedAt(toDate(u.getCreatedAt()));
        v.setTeacherName(teacherName);
        return v;
    }

    static TopicView toView(Topic t) {
        TopicView v = new TopicView();
        v.setTopicId(t.getTopicId());
        v.setTopicName(t.getTopicName());
        v.setDescription(t.getDescription());
        v.setTeacherId(t.getTeacher().getUserId());
        v.setTeacherName(t.getTeacher().getFullName());
        v.setCreatedAt(toDate(t.getCreatedAt()));
        return v;
    }

    static LessonView toView(Lesson l, int questionCount) {
        LessonView v = new LessonView();
        v.setLessonId(l.getLessonId());
        v.setTopicId(l.getTopic().getTopicId());
        v.setTopicName(l.getTopic().getTopicName());
        v.setTitle(l.getTitle());
        v.setSummary(l.getSummary());
        v.setContent(l.getContent());
        v.setDisplayOrder(l.getDisplayOrder());
        v.setCreatedById(l.getCreatedBy().getUserId());
        v.setCreatedAt(toDate(l.getCreatedAt()));
        v.setQuestionCount(questionCount);
        return v;
    }

    /** Không đụng tới collection options (LAZY); phương án được nạp riêng bằng truy vấn IN. */
    static QuestionView toView(Question q) {
        QuestionView v = new QuestionView();
        v.setQuestionId(q.getQuestionId());
        v.setLessonId(q.getLesson().getLessonId());
        v.setLessonTitle(q.getLesson().getTitle());
        v.setQuestionType(q.getQuestionType().name());
        v.setContent(q.getContent());
        v.setExplanation(q.getExplanationLatex());
        v.setLevel(q.getLevel());
        v.setAiGenerated(q.isAiGenerated());
        v.setTeacherId(q.getTeacher().getUserId());
        v.setCreatedAt(toDate(q.getCreatedAt()));
        return v;
    }

    static OptionView toView(QuestionOption o) {
        OptionView v = new OptionView();
        v.setOptionId(o.getOptionId());
        v.setQuestionId(o.getQuestion().getQuestionId());
        v.setOptionLetter(o.getOptionLetter());
        v.setContent(o.getContent());
        v.setCorrect(o.isCorrect());
        return v;
    }

    /** Cần đã nạp student, question, lesson (xem SubmissionRepository). */
    static SubmissionView toView(Submission s) {
        SubmissionView v = new SubmissionView();
        v.setSubmissionId(s.getSubmissionId());
        v.setStudentId(s.getStudent().getUserId());
        v.setStudentName(s.getStudent().getFullName());
        v.setStudentEmail(s.getStudent().getEmail());
        v.setLessonId(s.getLesson() == null ? null : s.getLesson().getLessonId());
        v.setLessonTitle(s.getLesson() == null ? null : s.getLesson().getTitle());
        v.setQuestionId(s.getQuestion().getQuestionId());
        v.setQuestionTitle(s.getQuestion().getContent());
        v.setQuestionContent(s.getQuestion().getContent());
        v.setQuestionAiGenerated(s.getQuestion().isAiGenerated());
        v.setQuestionType(s.getQuestionType().name());
        v.setStudentAnswer(s.getStudentAnswer());
        v.setEssayImagePath(s.getEssayImagePath());
        v.setIsCorrect(s.getIsCorrect());
        v.setScore(s.getFinalScore() == null ? null : s.getFinalScore().doubleValue());
        v.setAiScore(s.getAiScore() == null ? null : s.getAiScore().doubleValue());
        v.setStatus(s.getStatus().name());
        v.setReviewedByName(s.getReviewedBy() == null ? null : s.getReviewedBy().getFullName());
        v.setReviewedAt(toDate(s.getReviewedAt()));
        v.setAiFeedback(s.getAiFeedback());
        v.setTeacherFeedback(s.getTeacherFeedback());
        v.setReviewed(s.isReviewed());
        v.setSubmittedAt(toDate(s.getSubmittedAt()));
        return v;
    }

    static AiConfigView toView(AiConfig c) {
        AiConfigView v = new AiConfigView();
        v.setConfigId(c.getConfigId());
        v.setConfigKey(c.getConfigKey());
        // Khóa API chỉ hiển thị dạng che, không bao giờ lộ nguyên văn ra giao diện (NFR-05)
        v.setConfigValue(c.isSecret() || API_KEY_CONFIG.equals(c.getConfigKey()) ? maskKey(c.getConfigValue()) : c.getConfigValue());
        v.setDescription(c.getDescription());
        v.setUpdatedBy(c.getUpdatedBy() == null ? null : c.getUpdatedBy().getUserId());
        v.setUpdatedByName(c.getUpdatedBy() == null ? null : c.getUpdatedBy().getFullName());
        v.setUpdatedAt(toDate(c.getUpdatedAt()));
        return v;
    }

    static String maskKey(String key) {
        if (key == null || key.isBlank()) {
            return "";
        }
        String k = key.trim();
        return k.length() <= 8 ? "****" : k.substring(0, 4) + "****" + k.substring(k.length() - 4);
    }

    static TutorSessionView toView(TutorSession s) {
        TutorSessionView v = new TutorSessionView();
        v.setSessionId(s.getSessionId());
        v.setStudentId(s.getStudent().getUserId());
        v.setLessonId(s.getLesson() == null ? null : s.getLesson().getLessonId());
        v.setLessonTitle(s.getLesson() == null ? null : s.getLesson().getTitle());
        v.setTitle(s.getTitle());
        v.setStatus(s.getStatus().name());
        v.setQuestionId(s.getQuestion() == null ? null : s.getQuestion().getQuestionId());
        v.setCurrentStep(s.getCurrentStep());
        v.setTotalSteps(s.getTotalSteps());
        v.setAwaitingInput(s.isAwaitingInput());
        v.setInputHint(s.getInputHint());
        v.setCreatedAt(toDate(s.getCreatedAt()));
        return v;
    }

    static TutorMessageView toView(TutorMessage m) {
        TutorMessageView v = new TutorMessageView();
        v.setMessageId(m.getMessageId());
        v.setSessionId(m.getSession().getSessionId());
        v.setSenderType(m.getSenderType().name());
        v.setStepNumber(m.getStepNumber());
        v.setContentText(m.getContentText());
        v.setStepCompleted(m.isStepCompleted());
        v.setCreatedAt(toDate(m.getCreatedAt()));
        return v;
    }
}
