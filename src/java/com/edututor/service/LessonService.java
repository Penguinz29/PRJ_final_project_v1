package com.edututor.service;

import com.edututor.dao.LessonDAO;
import com.edututor.model.Lesson;
import java.util.List;

/**
 * Service xử lý nghiệp vụ Bài học (Lesson).
 * Theo Spring MVC pattern: @Service
 */
public class LessonService {

    private final LessonDAO lessonDAO = new LessonDAO();

    /**
     * Lấy toàn bộ danh sách bài học.
     */
    public List<Lesson> getAllLessons() {
        return lessonDAO.getAll();
    }

    /**
     * Lấy danh sách bài học theo chủ đề.
     */
    public List<Lesson> getLessonsByTopic(int topicId) {
        return lessonDAO.getByTopicId(topicId);
    }

    /**
     * Lấy chi tiết một bài học theo ID.
     */
    public Lesson getLessonById(int lessonId) {
        return lessonDAO.getById(lessonId);
    }

    /**
     * UC-TEA-03: Tạo bài học mới.
     * Validation: title, topicId bắt buộc.
     *
     * @throws IllegalArgumentException nếu thiếu dữ liệu bắt buộc
     */
    public void createLesson(int topicId, String title, String summary,
                              String content, String youtubeUrl, int displayOrder) {
        if (title == null || title.trim().isEmpty()) {
            throw new IllegalArgumentException("Tiêu đề bài học không được để trống.");
        }
        if (topicId <= 0) {
            throw new IllegalArgumentException("Chủ đề không hợp lệ.");
        }
        Lesson l = new Lesson();
        l.setTopicId(topicId);
        l.setTitle(title.trim());
        l.setSummary(summary != null ? summary.trim() : "");
        l.setContent(content != null ? content.trim() : "");
        l.setYoutubeUrl(youtubeUrl != null ? youtubeUrl.trim() : "");
        l.setDisplayOrder(displayOrder);
        lessonDAO.insert(l);
    }

    /**
     * UC-TEA-03: Cập nhật bài học.
     */
    public void updateLesson(int lessonId, int topicId, String title, String summary,
                              String content, String youtubeUrl, int displayOrder) {
        if (title == null || title.trim().isEmpty()) {
            throw new IllegalArgumentException("Tiêu đề bài học không được để trống.");
        }
        Lesson l = new Lesson();
        l.setLessonId(lessonId);
        l.setTopicId(topicId);
        l.setTitle(title.trim());
        l.setSummary(summary != null ? summary.trim() : "");
        l.setContent(content != null ? content.trim() : "");
        l.setYoutubeUrl(youtubeUrl != null ? youtubeUrl.trim() : "");
        l.setDisplayOrder(displayOrder);
        lessonDAO.update(l);
    }
}
