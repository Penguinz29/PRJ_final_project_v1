package controller.admin;

import dto.view.PageResult;
import dto.view.QuestionView;
import service.QuestionService;
import service.TopicService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

/** Admin xem toàn bộ chuyên đề, bài học và ngân hàng câu hỏi. */
@Controller
public class AdminContentController {

    private static final int PAGE_SIZE = 10;

    private final TopicService topicService;
    private final QuestionService questionService;

    public AdminContentController(TopicService topicService,
                                  QuestionService questionService) {
        this.topicService = topicService;
        this.questionService = questionService;
    }

    @GetMapping("/admin/topics")
    public String topics(Model model) {
        model.addAttribute("topics", topicService.getAllTopicsForManage());
        return "admin/topics";
    }

    @GetMapping("/admin/lessons")
    public String lessons() {
        // Admin dùng chung giao diện quản lý bài giảng của giáo viên (xem/thêm/sửa/xóa).
        return "redirect:/teacher/lessons";
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
