package com.edututor.service;

import com.edututor.dto.PageResult;
import com.edututor.dto.QuestionResultView;
import com.edututor.model.QuestionType;
import com.edututor.model.Role;
import com.edututor.repository.LessonRepository;
import com.edututor.repository.QuestionRepository;
import com.edututor.repository.QuestionResultRow;
import com.edututor.repository.SubmissionRepository;
import com.edututor.repository.TopicRepository;
import com.edututor.repository.UserRepository;
import com.edututor.util.Pager;
import java.util.LinkedHashMap;
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

    public Map<String, Object> studentStats(int studentId) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("totalTopics", (int) topics.count()); // học sinh vẫn học được chuyên đề đã xóa mềm
        m.put("doneQuiz", (int) submissions.countQuizLessonsDone(studentId));
        Double avg = submissions.averageMcqPercent(studentId);
        m.put("averageScore", avg == null ? 0.0 : avg);
        return m;
    }
}
