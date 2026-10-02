package com.edututor.service;

import com.edututor.dto.LessonView;
import com.edututor.dto.TopicForm;
import com.edututor.dto.TopicView;
import com.edututor.exception.ConflictException;
import com.edututor.exception.ForbiddenException;
import com.edututor.exception.NotFoundException;
import com.edututor.model.Lesson;
import com.edututor.model.Topic;
import com.edututor.model.User;
import com.edututor.repository.LessonRepository;
import com.edututor.repository.TopicRepository;
import com.edututor.repository.UserRepository;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Nghiệp vụ Chuyên đề (Topic). */
@Service
public class TopicService {

    private final TopicRepository topicRepository;
    private final LessonRepository lessonRepository;
    private final UserRepository userRepository;

    public TopicService(TopicRepository topicRepository, LessonRepository lessonRepository,
                        UserRepository userRepository) {
        this.topicRepository = topicRepository;
        this.lessonRepository = lessonRepository;
        this.userRepository = userRepository;
    }

    /** Tất cả chuyên đề kèm danh sách bài học (accordion bên học sinh): 2 truy vấn, không N+1. */
    @Transactional(readOnly = true)
    public List<TopicView> getAllTopicsWithLessons() {
        return withLessons(topicRepository.findAllByOrderByCreatedAtDescTopicIdDesc());
    }

    @Transactional(readOnly = true)
    public List<TopicView> getAllTopics() {
        return topicRepository.findAllByOrderByCreatedAtDescTopicIdDesc().stream().map(ViewMapper::toView).toList();
    }

    /** Chuyên đề của một giáo viên kèm số bài học. */
    @Transactional(readOnly = true)
    public List<TopicView> getTopicsByTeacher(int teacherId) {
        return withLessons(topicRepository.findByTeacher_UserIdOrderByCreatedAtDescTopicIdDesc(teacherId));
    }

    private List<TopicView> withLessons(List<Topic> topics) {
        List<TopicView> views = new ArrayList<>();
        Map<Integer, TopicView> byId = new LinkedHashMap<>();
        for (Topic t : topics) {
            TopicView v = ViewMapper.toView(t);
            v.setLessons(new ArrayList<>());
            views.add(v);
            byId.put(t.getTopicId(), v);
        }
        if (!byId.isEmpty()) {
            for (Lesson l : lessonRepository.findByTopic_TopicIdInOrderByDisplayOrderAscLessonIdAsc(byId.keySet())) {
                LessonView lv = ViewMapper.toView(l, 0);
                TopicView owner = byId.get(l.getTopic().getTopicId());
                owner.getLessons().add(lv);
            }
            for (TopicView v : views) {
                v.setLessonCount(v.getLessons().size());
            }
        }
        return views;
    }

    @Transactional(readOnly = true)
    public TopicView getTopicById(int topicId) {
        return topicRepository.findWithTeacherByTopicId(topicId).map(ViewMapper::toView).orElse(null);
    }

    /** UC-TEA-01: tạo chuyên đề; tên chuyên đề duy nhất (không phân biệt hoa thường). */
    @Transactional
    public void createTopic(TopicForm form, int teacherId) {
        if (topicRepository.existsByTopicNameIgnoreCase(form.getTopicName())) {
            throw new ConflictException("Tên chuyên đề đã tồn tại.", "topicName");
        }
        Topic t = new Topic();
        t.setTopicName(form.getTopicName());
        t.setDescription(form.getDescription());
        t.setTeacher(userRepository.getReferenceById(teacherId));
        topicRepository.save(t);
    }

    @Transactional
    public void updateTopic(int topicId, TopicForm form, int actingUserId, boolean admin) {
        Topic existing = requireOwned(topicId, actingUserId, admin);
        if (topicRepository.existsByTopicNameIgnoreCaseAndTopicIdNot(form.getTopicName(), topicId)) {
            throw new ConflictException("Tên chuyên đề đã tồn tại.", "topicName");
        }
        existing.setTopicName(form.getTopicName());
        existing.setDescription(form.getDescription());
    }

    /** BR-05: không xóa chuyên đề còn bài học. */
    @Transactional
    public void deleteTopic(int topicId, int actingUserId, boolean admin) {
        Topic t = requireOwned(topicId, actingUserId, admin);
        if (lessonRepository.countByTopic_TopicId(topicId) > 0) {
            throw new ConflictException("Chuyên đề còn bài học nên không thể xóa. Hãy xóa các bài học trước.");
        }
        topicRepository.delete(t);
    }

    private Topic requireOwned(int topicId, int actingUserId, boolean admin) {
        Topic t = topicRepository.findWithTeacherByTopicId(topicId)
                .orElseThrow(() -> new NotFoundException("Chuyên đề không tồn tại."));
        User owner = t.getTeacher();
        if (!admin && !owner.getUserId().equals(actingUserId)) {
            throw new ForbiddenException("Bạn chỉ được thao tác trên chuyên đề do mình tạo.");
        }
        return t;
    }
}
