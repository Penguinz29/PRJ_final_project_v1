package com.edututor.service;

import com.edututor.dao.TopicDAO;
import com.edututor.dao.LessonDAO;
import com.edututor.model.Topic;
import com.edututor.model.Lesson;
import java.util.List;

/**
 * Service xử lý nghiệp vụ Chủ đề (Topic).
 * Theo Spring MVC pattern: @Service
 */
public class TopicService {

    private final TopicDAO topicDAO = new TopicDAO();
    private final LessonDAO lessonDAO = new LessonDAO();

    /**
     * Lấy toàn bộ danh sách chủ đề, kèm số lượng bài học.
     */
    public List<Topic> getAllTopics() {
        List<Topic> topics = topicDAO.getAll();
        for (Topic t : topics) {
            List<Lesson> lessons = lessonDAO.getByTopicId(t.getTopicId());
            t.setLessons(lessons);
            t.setLessonCount(lessons.size());
        }
        return topics;
    }

    /**
     * Lấy danh sách chủ đề theo giáo viên phụ trách.
     */
    public List<Topic> getTopicsByTeacher(int teacherId) {
        List<Topic> topics = topicDAO.getByTeacherId(teacherId);
        for (Topic t : topics) {
            List<Lesson> lessons = lessonDAO.getByTopicId(t.getTopicId());
            t.setLessons(lessons);
            t.setLessonCount(lessons.size());
        }
        return topics;
    }

    /**
     * Lấy chi tiết một chủ đề theo ID.
     */
    public Topic getTopicById(int topicId) {
        return topicDAO.getById(topicId);
    }

    /**
     * Tạo chủ đề mới.
     * Validation: topicName không được rỗng.
     *
     * @throws IllegalArgumentException nếu tên chủ đề rỗng
     */
    public void createTopic(String topicName, String description, int teacherId) {
        if (topicName == null || topicName.trim().isEmpty()) {
            throw new IllegalArgumentException("Tên chủ đề không được để trống.");
        }
        Topic t = new Topic();
        t.setTopicName(topicName.trim());
        t.setDescription(description != null ? description.trim() : "");
        t.setTeacherId(teacherId);
        topicDAO.insert(t);
    }

    /**
     * Cập nhật chủ đề.
     */
    public void updateTopic(int topicId, String topicName, String description) {
        if (topicName == null || topicName.trim().isEmpty()) {
            throw new IllegalArgumentException("Tên chủ đề không được để trống.");
        }
        Topic t = new Topic();
        t.setTopicId(topicId);
        t.setTopicName(topicName.trim());
        t.setDescription(description != null ? description.trim() : "");
        topicDAO.update(t);
    }

    /**
     * Xóa chủ đề theo ID.
     */
    public void deleteTopic(int topicId) {
        topicDAO.delete(topicId);
    }
}
