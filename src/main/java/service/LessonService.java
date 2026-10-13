package service;

import dto.form.LessonForm;
import dto.view.LessonView;
import exception.ForbiddenException;
import exception.NotFoundException;
import model.Lesson;
import model.Topic;
import repository.IdCount;
import repository.LessonRepository;
import repository.QuestionRepository;
import repository.SubmissionRepository;
import repository.TopicRepository;
import repository.TutorSessionRepository;
import repository.UserRepository;
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
        return toViews(lessonRepository.findByActiveTrueOrderByTopic_OrderIndexAscTopic_TopicIdAscDisplayOrderAscLessonIdAsc());
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
     * Form sửa bài học: mọi giáo viên được mở (bài học là nội dung dùng chung).
     *
     * @return bài học, hoặc null nếu không tồn tại / đã xóa mềm
     */
    @Transactional(readOnly = true)
    public LessonView getLessonForEdit(int lessonId, int actingUserId, boolean admin) {
        Lesson l = lessonRepository.findByLessonIdAndActiveTrue(lessonId).orElse(null);
        if (l == null) {
            return null;
        }
        return getLessonById(lessonId);
    }

    /** Mọi giáo viên được thêm bài học vào bất kỳ chuyên đề nào. */
    @Transactional
    public void createLesson(LessonForm form, int actingUserId, boolean admin) {
        Lesson l = new Lesson();
        apply(l, form, actingUserId, admin);
        l.setCreatedBy(userRepository.getReferenceById(actingUserId));
        l.setDisplayOrder(form.getDisplayOrder() == null
                ? lessonRepository.findMaxDisplayOrder(l.getTopic().getTopicId()) + 1 : form.getDisplayOrder());
        lessonRepository.save(l);
    }

    /** Mọi giáo viên được sửa bài học; chỉ XÓA mới giới hạn người tạo / Admin (BR-03). */
    @Transactional
    public void updateLesson(LessonForm form, int actingUserId, boolean admin) {
        Lesson l = lessonRepository.findByLessonIdAndActiveTrue(form.getId())
                .orElseThrow(() -> new NotFoundException("Bài học không tồn tại."));
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

    /** BR-03: xóa bài học kéo theo xóa câu hỏi của bài (có thể của giáo viên khác) nên chỉ người tạo hoặc Admin được xóa. */
    private void requireOwner(Lesson l, int actingUserId, boolean admin) {
        if (!admin && !l.getCreatedBy().getUserId().equals(actingUserId)) {
            throw new ForbiddenException("Bạn chỉ được xóa bài học do mình tạo.");
        }
    }

    private void apply(Lesson l, LessonForm form, int actingUserId, boolean admin) {
        Topic topic = topicRepository.findByTopicIdAndActiveTrue(form.getTopicId())
                .orElseThrow(() -> new IllegalArgumentException("Chủ đề không hợp lệ."));
        l.setTopic(topic);
        l.setTitle(form.getTitle());
        l.setSummary(form.getSummary());
        l.setContent(form.getContent());
    }
}
