package com.edututor.controller.teacher;

import com.edututor.dto.LessonView;
import com.edututor.dto.PageResult;
import com.edututor.dto.QuestionResultView;
import com.edututor.service.LessonService;
import com.edututor.service.StatsService;
import java.util.List;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * UC-TEA-08 (FR-TEA-08): kết quả trắc nghiệm của học sinh theo bài học / câu hỏi. Giáo viên xem được mọi bài học
 * đang hoạt động (nội dung dùng chung); phân quyền TEACHER / ADMIN do AuthInterceptor đảm nhận (/teacher/**).
 */
@Controller
public class TeacherResultController {

    private final LessonService lessonService;
    private final StatsService statsService;

    public TeacherResultController(LessonService lessonService, StatsService statsService) {
        this.lessonService = lessonService;
        this.statsService = statsService;
    }

    @GetMapping("/teacher/results")
    public String results(@RequestParam(defaultValue = "0") int lessonId,
                          @RequestParam(defaultValue = "1") int page,
                          @RequestParam(defaultValue = "10") int size,
                          Model model) {
        List<LessonView> lessons = lessonService.getAllLessons();
        LessonView selected = lessons.stream().filter(l -> l.getLessonId() == lessonId).findFirst()
                .orElse(lessons.isEmpty() ? null : lessons.get(0));
        model.addAttribute("lessons", lessons);
        model.addAttribute("lesson", selected);
        if (selected != null) {
            PageResult<QuestionResultView> result = statsService.questionResults(selected.getLessonId(), page, size);
            model.addAttribute("rows", result.getItems());
            model.addAttribute("page", result.getPage());
            model.addAttribute("size", result.getSize());
            model.addAttribute("totalPages", result.getTotalPages());
            model.addAttribute("totalRecords", result.getTotalItems());
            model.addAttribute("summary", statsService.lessonResultSummary(selected.getLessonId()));
        }
        return "teacher/results";
    }
}
