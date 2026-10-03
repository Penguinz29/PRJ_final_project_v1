package com.edututor.service;

import com.edututor.dto.PageResult;
import com.edututor.dto.ProgressView;
import com.edututor.dto.QuestionResultView;
import com.edututor.model.QuestionType;
import com.edututor.model.Role;
import com.edututor.repository.LessonRepository;
import com.edututor.repository.ProgressRow;
import com.edututor.repository.QuestionRepository;
import com.edututor.repository.QuestionResultRow;
import com.edututor.repository.SubmissionRepository;
import com.edututor.repository.TopicRepository;
import com.edututor.repository.UserRepository;
import com.edututor.util.Pager;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.data.domain.Sort;
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
        m.put("totalTopics", (int) topics.countByActiveTrue());
        m.put("totalQuestions", (int) questions.countByActiveTrue());
        return m;
    }

    public Map<String, Object> teacherStats(int teacherId) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("myTopics", (int) topics.countByTeacher_UserIdAndActiveTrue(teacherId));
        m.put("myLessons", (int) lessons.countByTopic_Teacher_UserIdAndActiveTrue(teacherId));
        m.put("myStudents", (int) users.countByRole(Role.STUDENT));
        m.put("pendingSubmissions", (int) submissions.countByQuestionTypeAndReviewed(QuestionType.ESSAY, false));
        return m;
    }

    /** UC-TEA-08: kết quả trắc nghiệm theo câu hỏi của bài học, phân trang ở CSDL (VAL-22). */
    public PageResult<QuestionResultView> questionResults(int lessonId, int page, int size) {
        return PageResult.of(submissions.findQuestionResults(lessonId, Pager.pageRequest(page, size, Sort.unsorted())),
                StatsService::toResultView);
    }

    /** Dòng tổng hợp cả bài học. */
    public QuestionResultView lessonResultSummary(int lessonId) {
        return toResultView(submissions.lessonResultSummary(lessonId));
    }

    private static QuestionResultView toResultView(QuestionResultRow r) {
        Double pct = r.getCorrectPct() == null ? null : Math.round(r.getCorrectPct() * 10) / 10.0;
        Double avg = pct == null ? null : Math.round(pct * 10) / 100.0; // = correct_pct / 10 (33.3% → 3.33)
        return new QuestionResultView(r.getQuestionId() == null ? 0 : r.getQuestionId(), r.getContent(),
                r.getLevel() == null ? 0 : r.getLevel(), r.getAttempts() == null ? 0 : r.getAttempts(),
                r.getStudents() == null ? 0 : r.getStudents(), pct, avg);
    }

    /**
     * Dashboard học sinh (FR-STU-06): tổng hợp tính theo lần làm gần nhất của mỗi câu (BR-10), cộng dồn từ tiến độ
     * từng chủ đề nên không chạy thêm truy vấn đếm riêng.
     */
    public Map<String, Object> studentStats(int studentId) {
        List<ProgressView> progress = topicProgress(studentId);
        int total = 0;
        int answered = 0;
        int correct = 0;
        for (ProgressView p : progress) {
            total += p.total();
            answered += p.answered();
            correct += p.correct();
        }
        ProgressView overall = new ProgressView(0, "", total, answered, correct);
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("totalTopics", progress.size()); // học sinh vẫn học được chuyên đề đã xóa mềm
        m.put("topicProgress", progress);
        m.put("overall", overall);
        Double essayAvg = submissions.latestEssayAverage(studentId);
        m.put("essayAverage", essayAvg == null ? null : Math.round(essayAvg * 100) / 100.0);
        return m;
    }

    /** Tiến độ theo từng chủ đề (UC-STU-06). */
    public List<ProgressView> topicProgress(int studentId) {
        return submissions.topicProgress(studentId).stream().map(StatsService::toProgressView).toList();
    }

    /** Tiến độ theo từng bài học của một chủ đề (UC-STU-06). */
    public List<ProgressView> lessonProgress(int studentId, int topicId) {
        return submissions.lessonProgress(studentId, topicId).stream().map(StatsService::toProgressView).toList();
    }

    /** Tên chủ đề cho trang tiến độ (kể cả chủ đề đã xóa mềm); null nếu không tồn tại. */
    public String topicName(int topicId) {
        return topics.findById(topicId).map(t -> t.getTopicName()).orElse(null);
    }

    private static ProgressView toProgressView(ProgressRow r) {
        return new ProgressView(r.getId(), r.getName(), nz(r.getTotal()), nz(r.getAnswered()), nz(r.getCorrect()));
    }

    private static int nz(Integer v) {
        return v == null ? 0 : v;
    }
}
