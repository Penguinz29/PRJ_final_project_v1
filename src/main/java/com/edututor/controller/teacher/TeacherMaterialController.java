package com.edututor.controller.teacher;

import com.edututor.dto.LessonView;
import com.edututor.dto.MaterialForm;
import com.edututor.dto.SessionUser;
import com.edututor.exception.ConflictException;
import com.edututor.exception.NotFoundException;
import com.edututor.interceptor.AuthInterceptor;
import com.edututor.service.LessonService;
import com.edututor.service.MaterialService;
import com.edututor.util.FormErrors;
import jakarta.validation.Valid;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.SessionAttribute;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/** UC-TEA-03: quản lý bài giảng (video / YouTube / link / văn bản) của một bài học. */
@Controller
public class TeacherMaterialController {

    private final MaterialService materialService;
    private final LessonService lessonService;

    public TeacherMaterialController(MaterialService materialService, LessonService lessonService) {
        this.materialService = materialService;
        this.lessonService = lessonService;
    }

    @GetMapping("/teacher/lessons/{lessonId}/materials")
    public String list(@PathVariable int lessonId, Model model) {
        LessonView lesson = lessonService.getLessonById(lessonId);
        if (lesson == null) {
            throw new NotFoundException("Bài học không tồn tại.");
        }
        model.addAttribute("lesson", lesson);
        model.addAttribute("materials", materialService.getByLesson(lessonId));
        return "teacher/materials";
    }

    @PostMapping("/teacher/lessons/{lessonId}/materials")
    public String create(@PathVariable int lessonId, @Valid @ModelAttribute MaterialForm form, BindingResult result,
                         @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user,
                         RedirectAttributes redirect) {
        try {
            FormErrors.requireValid(result);
            materialService.create(lessonId, form, user.getUserId());
            redirect.addFlashAttribute("flash", "Thêm bài giảng thành công.");
        } catch (IllegalArgumentException | ConflictException e) {
            redirect.addFlashAttribute("errorFlash", e.getMessage());
        }
        return "redirect:/teacher/lessons/" + lessonId + "/materials";
    }

    @PostMapping("/teacher/materials/{id}/update")
    public String update(@PathVariable int id, @Valid @ModelAttribute MaterialForm form, BindingResult result,
                         @RequestParam(name = "lessonId", required = false) Integer fromLesson,
                         @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user,
                         RedirectAttributes redirect) {
        try {
            FormErrors.requireValid(result);
            int lessonId = materialService.update(id, form, user.getUserId(), user.isAdmin());
            redirect.addFlashAttribute("flash", "Cập nhật bài giảng thành công.");
            return "redirect:/teacher/lessons/" + lessonId + "/materials";
        } catch (IllegalArgumentException | ConflictException e) {
            redirect.addFlashAttribute("errorFlash", e.getMessage());
            // Quay lại đúng trang bài giảng để sửa tiếp (lessonId do form gửi kèm)
            return fromLesson != null ? "redirect:/teacher/lessons/" + fromLesson + "/materials"
                    : "redirect:/teacher/lessons";
        }
    }

    @PostMapping("/teacher/materials/{id}/delete")
    public String delete(@PathVariable int id, @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user,
                         RedirectAttributes redirect) {
        int lessonId = materialService.delete(id, user.getUserId(), user.isAdmin());
        redirect.addFlashAttribute("flash", "Xóa bài giảng thành công.");
        return "redirect:/teacher/lessons/" + lessonId + "/materials";
    }
}
