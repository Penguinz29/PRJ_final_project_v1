package controller.teacher;

import dto.view.SessionUser;
import dto.form.TopicForm;
import exception.ConflictException;
import config.AuthInterceptor;
import service.TopicService;
import util.FormErrors;
import jakarta.validation.Valid;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.SessionAttribute;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/** UC-TEA-01: quản lý chuyên đề của giáo viên (tạo / sửa / xóa theo tham số {@code action}). */
@Controller
public class TeacherTopicController {

    private final TopicService topicService;

    public TeacherTopicController(TopicService topicService) {
        this.topicService = topicService;
    }

    @GetMapping("/teacher/topics")
    public String list(@SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user, Model model) {
        model.addAttribute("topics", topicService.getAllTopicsForManage());
        return "teacher/topics";
    }

    @PostMapping("/teacher/topics")
    public String save(@Valid @ModelAttribute TopicForm form, BindingResult result,
                       @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user,
                       RedirectAttributes redirect) {
        boolean admin = user.isAdmin();
        try {
            switch (form.getAction()) {
                case "create" -> {
                    FormErrors.requireValid(result);
                    topicService.createTopic(form, user.getUserId());
                    redirect.addFlashAttribute("flash", "Thêm chủ đề thành công.");
                }
                case "update" -> {
                    FormErrors.requireValid(result);
                    topicService.updateTopic(form.getTopicId(), form, user.getUserId(), admin);
                    redirect.addFlashAttribute("flash", "Cập nhật chủ đề thành công.");
                }
                case "delete" -> {
                    boolean hard = topicService.deleteTopic(form.getId(), user.getUserId(), admin);
                    redirect.addFlashAttribute("flash", hard ? "Xóa chủ đề thành công."
                            : "Đã ẩn chủ đề (xóa mềm) vì còn lịch sử học tập liên quan.");
                }
                default -> throw new IllegalArgumentException("Thao tác không hợp lệ.");
            }
        } catch (IllegalArgumentException | ConflictException e) {
            redirect.addFlashAttribute("errorFlash", e.getMessage());
        }
        return "redirect:/teacher/topics";
    }

}
