package com.edututor.service;

import com.edututor.model.QuestionType;
import com.edututor.model.Role;
import com.edututor.repository.LessonRepository;
import com.edututor.repository.QuestionRepository;
import com.edututor.repository.SubmissionRepository;
import com.edututor.repository.TopicRepository;
import com.edututor.repository.UserRepository;
import java.util.LinkedHashMap;
import java.util.Map;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Số liệu thống kê cho các trang dashboard. */
@Service
@Transactional(readOnly = true)
public class StatsService {

    private final UserRepository users;
    private final TopicRepository topics;
    private final LessonRepository lessons;
    private final QuestionRepository questions;
    private final SubmissionRepository submissions;

    public StatsService(UserRepository users, TopicRepository topics, LessonRepository lessons,
                        QuestionRepository questions, SubmissionRepository submissions) {
        this.users = users;
        this.topics = topics;
        this.lessons = lessons;
        this.questions = questions;
        this.submissions = submissions;
    }

    public Map<String, Object> adminStats() {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("totalTeachers", (int) users.countByRole(Role.TEACHER));
        m.put("totalStudents", (int) users.countByRole(Role.STUDENT));
        m.put("totalTopics", (int) topics.count());
        m.put("totalQuestions", (int) questions.count());
        return m;
    }

    public Map<String, Object> teacherStats(int teacherId) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("myTopics", (int) topics.countByTeacher_UserId(teacherId));
        m.put("myLessons", (int) lessons.countByTopic_Teacher_UserId(teacherId));
        m.put("myStudents", (int) users.countByRole(Role.STUDENT));
        m.put("pendingSubmissions", (int) submissions.countByQuestionTypeAndReviewed(QuestionType.ESSAY, false));
        return m;
    }

    public Map<String, Object> studentStats(int studentId) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("totalTopics", (int) topics.count());
        m.put("doneQuiz", (int) submissions.countQuizLessonsDone(studentId));
        Double avg = submissions.averageMcqPercent(studentId);
        m.put("averageScore", avg == null ? 0.0 : avg);
        return m;
    }
}
