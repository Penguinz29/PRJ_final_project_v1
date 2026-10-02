package com.edututor.controller.admin;

import com.edututor.dto.PageResult;
import com.edututor.dto.QuestionView;
import com.edututor.service.LessonService;
import com.edututor.service.QuestionService;
import com.edututor.service.TopicService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

/** Admin xem toàn bộ chuyên đề, bài học và ngân hàng câu hỏi. */
@Controller
public class AdminContentController {

    private static final int PAGE_SIZE = 10;

    private final TopicService topicService;
    private final LessonService lessonService;
    private final QuestionService questionService;

    public AdminContentController(TopicService topicService, LessonService lessonService,
                                  QuestionService questionService) {
        this.topicService = topicService;
        this.lessonService = lessonService;
        this.questionService = questionService;
    }

    @GetMapping("/admin/topics")
    public String topics(Model model) {
        model.addAttribute("topics", topicService.getAllTopics());
        return "admin/topics";
    }

    @GetMapping("/admin/lessons")
    public String lessons(Model model) {
        model.addAttribute("lessons", lessonService.getAllLessons());
        return "admin/lessons";
    }

    /** Ngân hàng câu hỏi có thể lớn: phân trang ở CSDL. */
    @GetMapping("/admin/questions")
    public String questions(@RequestParam(defaultValue = "1") int page, Model model) {
        PageResult<QuestionView> result = questionService.search(0, 0, "", 0, page, PAGE_SIZE);
        model.addAttribute("questions", result.getItems());
        model.addAttribute("page", result.getPage());
        model.addAttribute("totalPages", result.getTotalPages());
        model.addAttribute("totalRecords", result.getTotalItems());
        return "admin/questions";
    }
}
