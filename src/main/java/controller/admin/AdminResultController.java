package controller.admin;

import dto.view.LessonView;
import dto.view.PageResult;
import dto.view.SubmissionView;
import service.LessonService;
import service.StatsService;
import service.SubmissionService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * Admin xem kết quả bài làm của học sinh theo ba cấp: chủ đề → bài giảng → bài làm của học sinh thuộc bài giảng đó.
 * Cấp hiện tại suy ra từ tham số: lessonId → bài làm; topicId → bài giảng; không có → chủ đề.
 */
@Controller
public class AdminResultController {

    private static final int PAGE_SIZE = 15;

    private final StatsService statsService;
    private final LessonService lessonService;
    private final SubmissionService submissionService;

    public AdminResultController(StatsService statsService, LessonService lessonService,
                                 SubmissionService submissionService) {
        this.statsService = statsService;
        this.lessonService = lessonService;
        this.submissionService = submissionService;
    }

    @GetMapping("/admin/results")
    public String results(@RequestParam(defaultValue = "0") int topicId,
                          @RequestParam(defaultValue = "0") int lessonId,
                          @RequestParam(defaultValue = "1") int page,
                          Model model) {
        if (lessonId > 0) {
            LessonView lesson = lessonService.getLessonById(lessonId);
            if (lesson != null) {
                PageResult<SubmissionView> result = submissionService.getLessonSubmissions(lessonId, page, PAGE_SIZE);
                model.addAttribute("level", "submissions");
                model.addAttribute("lesson", lesson);
                model.addAttribute("topicId", lesson.getTopicId());
                model.addAttribute("topicName", lesson.getTopicName());
                model.addAttribute("submissions", result.getItems());
                model.addAttribute("page", result.getPage());
                model.addAttribute("totalPages", result.getTotalPages());
                model.addAttribute("totalRecords", result.getTotalItems());
                return "admin/results";
            }
        }
        String topicName = topicId > 0 ? statsService.topicName(topicId) : null;
        if (topicName != null) {
            model.addAttribute("level", "lessons");
            model.addAttribute("topicId", topicId);
            model.addAttribute("topicName", topicName);
            model.addAttribute("groups", statsService.lessonResultGroups(topicId));
        } else {
            model.addAttribute("level", "topics");
            model.addAttribute("groups", statsService.topicResultGroups());
        }
        return "admin/results";
    }
}
