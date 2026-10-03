package com.edututor.service;

import com.edututor.dto.LessonForm;
import com.edututor.dto.LessonView;
import com.edututor.exception.ConflictException;
import com.edututor.exception.NotFoundException;
import com.edututor.model.Lesson;
import com.edututor.model.Topic;
import com.edututor.repository.IdCount;
import com.edututor.repository.LessonRepository;
import com.edututor.repository.QuestionRepository;
import com.edututor.repository.SubmissionRepository;
import com.edututor.repository.TopicRepository;
import com.edututor.repository.TutorSessionRepository;
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

    public LessonService(LessonRepository lessonRepository, TopicRepository topicRepository,
                         QuestionRepository questionRepository, SubmissionRepository submissionRepository,
                         TutorSessionRepository tutorSessionRepository) {
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

    /** Học sinh mở bài học để học / luyện / ôn tập: kể cả bài giáo viên đã xóa mềm; null nếu không tồn tại. */
    @Transactional(readOnly = true)
    public LessonView getLessonForStudent(int lessonId) {
        return lessonRepository.findWithTopicByLessonId(lessonId).map(l -> {
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
        // Dự báo kết quả nút Xóa (BR-05): còn câu đang hoạt động → chặn; có bài nộp / phiên gia sư → xóa mềm
        Set<Integer> withHistory = new HashSet<>();
        if (!lessons.isEmpty()) {
            List<Integer> ids = lessons.stream().map(Lesson::getLessonId).toList();
            withHistory.addAll(submissionRepository.findLessonIdsWithSubmissions(ids));
            withHistory.addAll(tutorSessionRepository.findLessonIdsWithSessions(ids));
        }
        return lessons.stream().map(l -> {
            int active = counts.getOrDefault(l.getLessonId(), 0);
            LessonView v = ViewMapper.toView(l, active);
            v.setDeleteMode(active > 0 ? "BLOCKED" : withHistory.contains(l.getLessonId()) ? "SOFT" : "HARD");
            return v;
        }).toList();
    }

    @Transactional
    public void createLesson(LessonForm form) {
        Lesson l = new Lesson();
        apply(l, form);
        l.setDisplayOrder(form.getDisplayOrder() == null ? 0 : form.getDisplayOrder());
        lessonRepository.save(l);
    }

    @Transactional
    public void updateLesson(LessonForm form) {
        Lesson l = lessonRepository.findByLessonIdAndActiveTrue(form.getId())
                .orElseThrow(() -> new NotFoundException("Bài học không tồn tại."));
        apply(l, form);
        if (form.getDisplayOrder() != null) {
            l.setDisplayOrder(form.getDisplayOrder());
        }
    }

    /**
     * BR-05: chỉ chặn khi bài học còn câu hỏi ĐANG HOẠT ĐỘNG (409). Chỉ còn câu đã xóa mềm thì được xóa:
     * không còn bài nộp / phiên gia sư liên quan → xóa cứng (câu hỏi, bài giảng xóa theo ON DELETE CASCADE);
     * còn → xóa mềm bài học (IsActive = 0) để giữ lịch sử.
     *
     * @return true nếu xóa cứng, false nếu xóa mềm
     */
    @Transactional
    public boolean deleteLesson(int lessonId) {
        Lesson l = lessonRepository.findByLessonIdAndActiveTrue(lessonId)
                .orElseThrow(() -> new NotFoundException("Bài học không tồn tại."));
        if (questionRepository.countByLesson_LessonIdAndActiveTrue(lessonId) > 0) {
            throw new ConflictException("Bài học còn câu hỏi đang hoạt động nên không thể xóa. Hãy xóa các câu hỏi trước.");
        }
        if (submissionRepository.existsByQuestion_Lesson_LessonId(lessonId)
                || tutorSessionRepository.existsByQuestion_Lesson_LessonId(lessonId)) {
            l.setActive(false);
            return false;
        }
        lessonRepository.delete(l);
        return true;
    }

    private void apply(Lesson l, LessonForm form) {
        Topic topic = topicRepository.findByTopicIdAndActiveTrue(form.getTopicId())
                .orElseThrow(() -> new IllegalArgumentException("Chủ đề không hợp lệ."));
        l.setTopic(topic);
        l.setTitle(form.getTitle());
        l.setSummary(form.getSummary());
        l.setContent(form.getContent());
    }
}
