package controller.teacher;

import dto.form.LessonForm;
import dto.view.LessonView;
import dto.view.SessionUser;
import exception.ConflictException;
import config.AuthInterceptor;
import service.LessonService;
import service.TopicService;
import jakarta.servlet.http.HttpServletRequest;
import util.FormErrors;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.SessionAttribute;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/** UC-TEA-02: quản lý bài học (Lesson). */
@Controller
public class TeacherLessonController {

    private final LessonService lessonService;
    private final TopicService topicService;

    public TeacherLessonController(LessonService lessonService, TopicService topicService) {
        this.lessonService = lessonService;
        this.topicService = topicService;
    }

    @GetMapping({"/teacher/lessons", "/teacher/lesson/form"})
    public String list(@RequestParam(defaultValue = "") String action,
                       @RequestParam(defaultValue = "0") int id,
                       @RequestParam(defaultValue = "0") int topicId,
                       @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user,
                       HttpServletRequest request, Model model) {
        // Mọi giáo viên thấy và thêm/sửa bài học ở mọi chủ đề (nội dung dùng chung).
        model.addAttribute("topics", topicService.getAllTopics());

        boolean formPage = request.getServletPath().equals("/teacher/lesson/form")
                || "create".equals(action) || "edit".equals(action);
        if (formPage) {
            if ("edit".equals(action)) {
                LessonView lesson = lessonService.getLessonForEdit(id, user.getUserId(), user.isAdmin()); // BR-03
                if (lesson == null) {
                    return "redirect:/teacher/lessons";
                }
                model.addAttribute("isEdit", true);
                model.addAttribute("lesson", lesson);
            }
            return "teacher/lesson-form";
        }

        List<LessonView> lessons = topicId > 0 ? lessonService.getLessonsByTopic(topicId)
                : lessonService.getAllLessons();
        model.addAttribute("lessons", lessons);
        model.addAttribute("selectedTopicId", topicId);
        model.addAttribute("totalRecords", lessons.size());
        return "teacher/lessons";
    }

    @PostMapping("/teacher/lessons")
    public String save(@Valid @ModelAttribute LessonForm form, BindingResult result,
                       @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user, RedirectAttributes redirect) {
        try {
            switch (form.getAction()) {
                case "create" -> {
                    FormErrors.requireValid(result);
                    lessonService.createLesson(form, user.getUserId(), user.isAdmin());
                    redirect.addFlashAttribute("flash", "Thêm bài giảng thành công.");
                }
                case "update" -> {
                    FormErrors.requireValid(result);
                    lessonService.updateLesson(form, user.getUserId(), user.isAdmin());
                    redirect.addFlashAttribute("flash", "Cập nhật bài giảng thành công.");
                }
                case "delete" -> {
                    boolean hard = lessonService.deleteLesson(form.getId(), user.getUserId(), user.isAdmin());
                    redirect.addFlashAttribute("flash", hard ? "Xóa bài giảng thành công."
                            : "Đã ẩn bài giảng (xóa mềm) vì còn bài làm của học sinh liên quan; lịch sử được giữ nguyên.");
                }
                default -> throw new IllegalArgumentException("Thao tác không hợp lệ.");
            }
        } catch (IllegalArgumentException | ConflictException e) {
            redirect.addFlashAttribute("errorFlash", e.getMessage());
        }
        return form.getTopicId() > 0 && !"delete".equals(form.getAction())
                ? "redirect:/teacher/lessons?topicId=" + form.getTopicId() : "redirect:/teacher/lessons";
    }

}
