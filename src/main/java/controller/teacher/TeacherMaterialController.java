package controller.teacher;

import dto.view.LessonView;
import dto.form.MaterialForm;
import dto.view.SessionUser;
import exception.ConflictException;
import exception.NotFoundException;
import config.AuthInterceptor;
import service.LessonService;
import service.MaterialService;
import util.FormErrors;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import util.WebUtil;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.SessionAttribute;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/** UC-TEA-03: quản lý bài giảng (video / YouTube / link / văn bản) của một bài học; dùng chung /teacher và /admin. */
@Controller
@RequestMapping({"/teacher", "/admin"})
public class TeacherMaterialController {

    private final MaterialService materialService;
    private final LessonService lessonService;

    public TeacherMaterialController(MaterialService materialService, LessonService lessonService) {
        this.materialService = materialService;
        this.lessonService = lessonService;
    }

    @GetMapping("/lessons/{lessonId}/materials")
    public String list(@PathVariable int lessonId, Model model) {
        LessonView lesson = lessonService.getLessonById(lessonId);
        if (lesson == null) {
            throw new NotFoundException("Bài học không tồn tại.");
        }
        model.addAttribute("lesson", lesson);
        model.addAttribute("materials", materialService.getByLesson(lessonId));
        return "teacher/materials";
    }

    @PostMapping("/lessons/{lessonId}/materials")
    public String create(@PathVariable int lessonId, @Valid @ModelAttribute MaterialForm form, BindingResult result,
                         @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user,
                         RedirectAttributes redirect, HttpServletRequest request) {
        try {
            FormErrors.requireValid(result);
            materialService.create(lessonId, form, user.getUserId());
            redirect.addFlashAttribute("flash", "Thêm bài giảng thành công.");
        } catch (IllegalArgumentException | ConflictException e) {
            redirect.addFlashAttribute("errorFlash", e.getMessage());
        }
        return materialsPage(request, lessonId);
    }

    @PostMapping("/materials/{id}/update")
    public String update(@PathVariable int id, @Valid @ModelAttribute MaterialForm form, BindingResult result,
                         @RequestParam(name = "lessonId", required = false) Integer fromLesson,
                         @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user,
                         RedirectAttributes redirect, HttpServletRequest request) {
        try {
            FormErrors.requireValid(result);
            int lessonId = materialService.update(id, form, user.getUserId(), user.isAdmin());
            redirect.addFlashAttribute("flash", "Cập nhật bài giảng thành công.");
            return materialsPage(request, lessonId);
        } catch (IllegalArgumentException | ConflictException e) {
            redirect.addFlashAttribute("errorFlash", e.getMessage());
            // Quay lại đúng trang bài giảng để sửa tiếp (lessonId do form gửi kèm)
            return fromLesson != null ? materialsPage(request, fromLesson)
                    : "redirect:" + WebUtil.contentBase(request) + "/lessons";
        }
    }

    @PostMapping("/materials/{id}/delete")
    public String delete(@PathVariable int id, @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user,
                         RedirectAttributes redirect, HttpServletRequest request) {
        int lessonId = materialService.delete(id, user.getUserId(), user.isAdmin());
        redirect.addFlashAttribute("flash", "Xóa bài giảng thành công.");
        return materialsPage(request, lessonId);
    }

    private static String materialsPage(HttpServletRequest request, int lessonId) {
        return "redirect:" + WebUtil.contentBase(request) + "/lessons/" + lessonId + "/materials";
    }
}
