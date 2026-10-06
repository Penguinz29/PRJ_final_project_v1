package com.edututor.service;

import com.edututor.dto.LessonForm;
import com.edututor.dto.LessonView;
import com.edututor.exception.ForbiddenException;
import com.edututor.exception.NotFoundException;
import com.edututor.model.Lesson;
import com.edututor.model.Topic;
import com.edututor.repository.IdCount;
import com.edututor.repository.LessonRepository;
import com.edututor.repository.QuestionRepository;
import com.edututor.repository.SubmissionRepository;
import com.edututor.repository.TopicRepository;
import com.edututor.repository.TutorSessionRepository;
import com.edututor.repository.UserRepository;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Nghiệp vụ Bài học (Lesson). */
@Service
public class LessonService {

    private final LessonRepository lessonRepository;
    private final TopicRepository topicRepository;
    private final QuestionRepository questionRepository;
    private final SubmissionRepository submissionRepository;
    private final TutorSessionRepository tutorSessionRepository;
    private final UserRepository userRepository;

    public LessonService(LessonRepository lessonRepository, TopicRepository topicRepository,
                         QuestionRepository questionRepository, SubmissionRepository submissionRepository,
                         TutorSessionRepository tutorSessionRepository, UserRepository userRepository) {
        this.userRepository = userRepository;
        this.lessonRepository = lessonRepository;
        this.topicRepository = topicRepository;
        this.questionRepository = questionRepository;
        this.submissionRepository = submissionRepository;
        this.tutorSessionRepository = tutorSessionRepository;
    }

    @Transactional(readOnly = true)
    public List<LessonView> getAllLessons() {
        return toViews(lessonRepository.findByActiveTrueOrderByCreatedAtDescLessonIdDesc());
    }

    @Transactional(readOnly = true)
    public List<LessonView> getLessonsByTopic(int topicId) {
        return toViews(lessonRepository.findByTopic_TopicIdAndActiveTrueOrderByDisplayOrderAscLessonIdAsc(topicId));
    }

    /** @return bài học, hoặc null nếu không tồn tại */
    @Transactional(readOnly = true)
    public LessonView getLessonById(int lessonId) {
        return lessonRepository.findWithTopicByLessonIdAndActiveTrue(lessonId).map(l -> {
            long n = questionRepository.countByLesson_LessonIdAndActiveTrue(lessonId);
            return ViewMapper.toView(l, (int) n);
        }).orElse(null);
    }

    /** Học sinh mở bài học để học / luyện tập; null nếu không tồn tại hoặc đã bị xóa. */
    @Transactional(readOnly = true)
    public LessonView getLessonForStudent(int lessonId) {
        return lessonRepository.findWithTopicByLessonIdAndActiveTrue(lessonId).map(l -> {
            long n = questionRepository.countByLesson_LessonId(lessonId);
            return ViewMapper.toView(l, (int) n);
        }).orElse(null);
    }

    /** Số câu hỏi của cả danh sách bài học được lấy bằng MỘT truy vấn gộp (không N+1). */
    private List<LessonView> toViews(List<Lesson> lessons) {
        Map<Integer, Integer> counts = new HashMap<>();
        if (!lessons.isEmpty()) {
            List<Integer> ids = lessons.stream().map(Lesson::getLessonId).toList();
            for (IdCount c : questionRepository.countByLessonIds(ids)) {
                counts.put(c.getId(), (int) c.getTotal());
            }
        }
        // Dự báo kết quả nút Xóa (BR-05): có bài nộp / phiên gia sư → xóa mềm, ngược lại xóa hẳn (kèm câu hỏi)
        Set<Integer> withHistory = new HashSet<>();
        if (!lessons.isEmpty()) {
            List<Integer> ids = lessons.stream().map(Lesson::getLessonId).toList();
            withHistory.addAll(submissionRepository.findLessonIdsWithSubmissions(ids));
            withHistory.addAll(tutorSessionRepository.findLessonIdsWithSessions(ids));
        }
        return lessons.stream().map(l -> {
            int active = counts.getOrDefault(l.getLessonId(), 0);
            LessonView v = ViewMapper.toView(l, active);
            v.setDeleteMode(withHistory.contains(l.getLessonId()) ? "SOFT" : "HARD");
            return v;
        }).toList();
    }

    /**
     * Form sửa bài học: chỉ người tạo hoặc Admin (BR-03).
     *
     * @return bài học, hoặc null nếu không tồn tại / đã xóa mềm
     * @throws ForbiddenException khi không phải người tạo
     */
    @Transactional(readOnly = true)
    public LessonView getLessonForEdit(int lessonId, int actingUserId, boolean admin) {
        Lesson l = lessonRepository.findByLessonIdAndActiveTrue(lessonId).orElse(null);
        if (l == null) {
            return null;
        }
        requireOwner(l, actingUserId, admin);
        return getLessonById(lessonId);
    }

    /** BR-03: giáo viên chỉ thêm bài học vào chủ đề của mình (Admin: mọi chủ đề). */
    @Transactional
    public void createLesson(LessonForm form, int actingUserId, boolean admin) {
        Lesson l = new Lesson();
        apply(l, form, actingUserId, admin);
        l.setCreatedBy(userRepository.getReferenceById(actingUserId));
        l.setDisplayOrder(form.getDisplayOrder() == null ? 0 : form.getDisplayOrder());
        lessonRepository.save(l);
    }

    /** BR-03: chỉ người tạo hoặc Admin được sửa. */
    @Transactional
    public void updateLesson(LessonForm form, int actingUserId, boolean admin) {
        Lesson l = lessonRepository.findByLessonIdAndActiveTrue(form.getId())
                .orElseThrow(() -> new NotFoundException("Bài học không tồn tại."));
        requireOwner(l, actingUserId, admin);
        apply(l, form, actingUserId, admin);
        if (form.getDisplayOrder() != null) {
            l.setDisplayOrder(form.getDisplayOrder());
        }
    }

    /**
     * BR-05: xóa bài học thì bài tập (câu hỏi) của bài cũng mất theo. Không còn bài nộp / phiên gia sư liên quan
     * → xóa cứng (câu hỏi, bài giảng xóa theo ON DELETE CASCADE); còn → xóa mềm bài học và toàn bộ câu hỏi của nó
     * (IsActive = 0) để giữ lịch sử.
     *
     * @return true nếu xóa cứng, false nếu xóa mềm
     */
    @Transactional
    public boolean deleteLesson(int lessonId, int actingUserId, boolean admin) {
        Lesson l = lessonRepository.findByLessonIdAndActiveTrue(lessonId)
                .orElseThrow(() -> new NotFoundException("Bài học không tồn tại."));
        requireOwner(l, actingUserId, admin); // BR-03
        if (submissionRepository.existsByQuestion_Lesson_LessonId(lessonId)
                || tutorSessionRepository.existsByQuestion_Lesson_LessonId(lessonId)) {
            l.setActive(false);
            questionRepository.deactivateByLessonId(lessonId);
            return false;
        }
        lessonRepository.delete(l);
        return true;
    }

    /** BR-03: giáo viên chỉ sửa / xóa bài học do mình tạo; Admin có toàn quyền. */
    private void requireOwner(Lesson l, int actingUserId, boolean admin) {
        if (!admin && !l.getCreatedBy().getUserId().equals(actingUserId)) {
            throw new ForbiddenException("Bạn chỉ được sửa hoặc xóa bài học do mình tạo.");
        }
    }

    private void apply(Lesson l, LessonForm form, int actingUserId, boolean admin) {
        Topic topic = topicRepository.findByTopicIdAndActiveTrue(form.getTopicId())
                .orElseThrow(() -> new IllegalArgumentException("Chủ đề không hợp lệ."));
        // Bài học chỉ được đặt vào chủ đề của chính giáo viên (Admin: mọi chủ đề)
        if (!admin && !topic.getTeacher().getUserId().equals(actingUserId)
                && (l.getTopic() == null || !l.getTopic().getTopicId().equals(topic.getTopicId()))) {
            throw new ForbiddenException("Bạn chỉ được thêm bài học vào chủ đề do mình tạo.");
        }
        l.setTopic(topic);
        l.setTitle(form.getTitle());
        l.setSummary(form.getSummary());
        l.setContent(form.getContent());
    }
}
