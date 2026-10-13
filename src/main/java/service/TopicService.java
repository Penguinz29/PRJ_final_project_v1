package service;

import dto.view.LessonView;
import dto.form.TopicForm;
import dto.view.TopicView;
import exception.ConflictException;
import exception.ForbiddenException;
import exception.NotFoundException;
import model.Lesson;
import model.Topic;
import model.User;
import repository.LessonRepository;
import repository.TopicRepository;
import repository.UserRepository;
import repository.IdCount;
import java.util.ArrayList;
import java.util.HashMap;
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

    /**
     * Tất cả chuyên đề kèm danh sách bài học (accordion bên học sinh): 2 truy vấn, không N+1.
     * Chuyên đề / bài học đã bị xóa (xóa mềm) không hiển thị với học sinh.
     */
    @Transactional(readOnly = true)
    public List<TopicView> getAllTopicsWithLessons() {
        return withLessons(topicRepository.findByActiveTrueOrderByOrderIndexAscTopicIdAsc(), true);
    }

    @Transactional(readOnly = true)
    public List<TopicView> getAllTopics() {
        return topicRepository.findByActiveTrueOrderByOrderIndexAscTopicIdAsc().stream().map(ViewMapper::toView).toList();
    }

    /** Trang quản lý chuyên đề: mọi giáo viên xem được tất cả chuyên đề (kèm số bài học và dự báo nút Xóa). */
    @Transactional(readOnly = true)
    public List<TopicView> getAllTopicsForManage() {
        return withLessons(topicRepository.findByActiveTrueOrderByOrderIndexAscTopicIdAsc(), false);
    }

    /** @param forStudent true: danh sách cho học sinh; false: trang quản lý (kèm dự báo kết quả nút Xóa) */
    private List<TopicView> withLessons(List<Topic> topics, boolean forStudent) {
        List<TopicView> views = new ArrayList<>();
        Map<Integer, TopicView> byId = new LinkedHashMap<>();
        for (Topic t : topics) {
            TopicView v = ViewMapper.toView(t);
            v.setLessons(new ArrayList<>());
            views.add(v);
            byId.put(t.getTopicId(), v);
        }
        if (!byId.isEmpty()) {
            List<Lesson> lessons = lessonRepository
                    .findByTopic_TopicIdInAndActiveTrueOrderByDisplayOrderAscLessonIdAsc(byId.keySet());
            for (Lesson l : lessons) {
                LessonView lv = ViewMapper.toView(l, 0);
                TopicView owner = byId.get(l.getTopic().getTopicId());
                owner.getLessons().add(lv);
            }
            for (TopicView v : views) {
                v.setLessonCount(v.getLessons().size());
            }
            if (!forStudent) {
                // Dự báo kết quả nút Xóa (BR-05): còn bài học đang hoạt động → chặn; còn bài đã ẩn → xóa mềm
                Map<Integer, Long> allLessons = new HashMap<>();
                for (IdCount c : lessonRepository.countAllByTopicIds(byId.keySet())) {
                    allLessons.put(c.getId(), c.getTotal());
                }
                for (TopicView v : views) {
                    v.setDeleteMode(v.getLessonCount() > 0 ? "BLOCKED"
                            : allLessons.getOrDefault(v.getTopicId(), 0L) > 0 ? "SOFT" : "HARD");
                }
            }
        }
        return views;
    }

    /** UC-TEA-01: tạo chuyên đề; tên chuyên đề duy nhất (không phân biệt hoa thường). */
    @Transactional
    public void createTopic(TopicForm form, int teacherId) {
        if (topicRepository.existsByTopicNameIgnoreCaseAndActiveTrue(form.getTopicName())) {
            throw new ConflictException("Tên chuyên đề đã tồn tại.", "topicName");
        }
        Topic t = new Topic();
        t.setTopicName(form.getTopicName());
        t.setDescription(form.getDescription());
        t.setTeacher(userRepository.getReferenceById(teacherId));
        t.setOrderIndex(topicRepository.findMaxOrderIndex() + 1);
        topicRepository.save(t);
    }

    @Transactional
    public void updateTopic(int topicId, TopicForm form, int actingUserId, boolean admin) {
        // Mọi giáo viên được sửa chuyên đề (nội dung dùng chung); chỉ XÓA mới giới hạn người tạo / Admin (requireOwned)
        Topic existing = topicRepository.findByTopicIdAndActiveTrue(topicId)
                .orElseThrow(() -> new NotFoundException("Chuyên đề không tồn tại."));
        if (topicRepository.existsByTopicNameIgnoreCaseAndActiveTrueAndTopicIdNot(form.getTopicName(), topicId)) {
            throw new ConflictException("Tên chuyên đề đã tồn tại.", "topicName");
        }
        existing.setTopicName(form.getTopicName());
        existing.setDescription(form.getDescription());
    }

    /**
     * BR-05: không xóa chuyên đề còn bài học ĐANG HOẠT ĐỘNG (409). Không còn bài học nào → xóa cứng;
     * chỉ còn bài học đã xóa mềm (giữ lịch sử) → xóa mềm chuyên đề (IsActive = 0).
     *
     * @return true nếu xóa cứng, false nếu xóa mềm
     */
    @Transactional
    public boolean deleteTopic(int topicId, int actingUserId, boolean admin) {
        Topic t = requireOwned(topicId, actingUserId, admin);
        if (lessonRepository.countByTopic_TopicIdAndActiveTrue(topicId) > 0) {
            throw new ConflictException("Chuyên đề còn bài học nên không thể xóa. Hãy xóa các bài học trước.");
        }
        if (lessonRepository.countByTopic_TopicId(topicId) == 0) {
            topicRepository.delete(t);
            return true;
        }
        t.setActive(false);
        return false;
    }

    private Topic requireOwned(int topicId, int actingUserId, boolean admin) {
        Topic t = topicRepository.findWithTeacherByTopicIdAndActiveTrue(topicId)
                .orElseThrow(() -> new NotFoundException("Chuyên đề không tồn tại."));
        User owner = t.getTeacher();
        if (!admin && !owner.getUserId().equals(actingUserId)) {
            throw new ForbiddenException("Bạn chỉ được thao tác trên chuyên đề do mình tạo.");
        }
        return t;
    }
}
