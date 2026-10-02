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
import com.edututor.repository.TopicRepository;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Nghiệp vụ Bài học (Lesson). */
@Service
public class LessonService {

    private final LessonRepository lessonRepository;
    private final TopicRepository topicRepository;
    private final QuestionRepository questionRepository;

    public LessonService(LessonRepository lessonRepository, TopicRepository topicRepository,
                         QuestionRepository questionRepository) {
        this.lessonRepository = lessonRepository;
        this.topicRepository = topicRepository;
        this.questionRepository = questionRepository;
    }

    @Transactional(readOnly = true)
    public List<LessonView> getAllLessons() {
        return toViews(lessonRepository.findAllByOrderByCreatedAtDescLessonIdDesc());
    }

    @Transactional(readOnly = true)
    public List<LessonView> getLessonsByTopic(int topicId) {
        return toViews(lessonRepository.findByTopic_TopicIdOrderByDisplayOrderAscLessonIdAsc(topicId));
    }

    /** @return bài học, hoặc null nếu không tồn tại */
    @Transactional(readOnly = true)
    public LessonView getLessonById(int lessonId) {
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
        return lessons.stream().map(l -> ViewMapper.toView(l, counts.getOrDefault(l.getLessonId(), 0))).toList();
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
        Lesson l = lessonRepository.findById(form.getId())
                .orElseThrow(() -> new NotFoundException("Bài học không tồn tại."));
        apply(l, form);
        if (form.getDisplayOrder() != null) {
            l.setDisplayOrder(form.getDisplayOrder());
        }
    }

    /** BR-05: không xóa bài học còn câu hỏi. */
    @Transactional
    public void deleteLesson(int lessonId) {
        Lesson l = lessonRepository.findById(lessonId)
                .orElseThrow(() -> new NotFoundException("Bài học không tồn tại."));
        if (questionRepository.countByLesson_LessonId(lessonId) > 0) {
            throw new ConflictException("Bài học còn câu hỏi nên không thể xóa. Hãy xóa các câu hỏi trước.");
        }
        lessonRepository.delete(l);
    }

    private void apply(Lesson l, LessonForm form) {
        Topic topic = topicRepository.findById(form.getTopicId())
                .orElseThrow(() -> new IllegalArgumentException("Chủ đề không hợp lệ."));
        l.setTopic(topic);
        l.setTitle(form.getTitle());
        l.setSummary(form.getSummary());
        l.setContent(form.getContent());
        l.setYoutubeUrl(form.getYoutubeUrl());
    }
}
