package controller.admin;

import service.TopicService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

/** Admin xem toàn bộ chuyên đề (bài học và câu hỏi dùng chung controller với giáo viên). */
@Controller
public class AdminContentController {

    private final TopicService topicService;

    public AdminContentController(TopicService topicService) {
        this.topicService = topicService;
    }

    @GetMapping("/admin/topics")
    public String topics(Model model) {
        model.addAttribute("topics", topicService.getAllTopicsForManage());
        return "admin/topics";
    }
}
