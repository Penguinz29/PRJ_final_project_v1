package controller.teacher;

import dto.view.PageResult;
import dto.form.ReviewForm;
import dto.view.SessionUser;
import dto.view.SubmissionView;
import config.AuthInterceptor;
import service.SubmissionService;
import util.FormErrors;
import jakarta.validation.Valid;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.SessionAttribute;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/** UC-TEA-07: giáo viên xem bài tự luận (ảnh, OCR, điểm AI) và duyệt / hiệu chỉnh điểm. */
@Controller
public class TeacherSubmissionController {

    private static final int PAGE_SIZE = 10;

    private final SubmissionService submissionService;

    public TeacherSubmissionController(SubmissionService submissionService) {
        this.submissionService = submissionService;
    }

    @GetMapping({"/teacher/submissions", "/teacher/submissions/essay", "/teacher/submission/review"})
    public String list(@RequestParam(defaultValue = "0") int id,
                       @RequestParam(defaultValue = "1") int page,
                       @RequestParam(defaultValue = "pending") String status,
                       Model model, RedirectAttributes redirect) {
        if (id > 0) {
            SubmissionView sub = submissionService.getSubmissionById(id);
            if (sub == null || !"ESSAY".equals(sub.getQuestionType())) {
                redirect.addFlashAttribute("errorFlash", "Không tìm thấy bài làm tự luận yêu cầu.");
                return "redirect:/teacher/submissions";
            }
            model.addAttribute("sub", sub);
            return "teacher/submission-review";
        }
        boolean reviewed = "reviewed".equalsIgnoreCase(status);
        PageResult<SubmissionView> result = submissionService.getEssaySubmissions(reviewed, page, PAGE_SIZE);
        model.addAttribute("submissions", result.getItems());
        model.addAttribute("page", result.getPage());
        model.addAttribute("totalPages", result.getTotalPages());
        model.addAttribute("totalRecords", result.getTotalItems());
        model.addAttribute("status", reviewed ? "reviewed" : "pending");
        return "teacher/submissions";
    }

    /**
     * Giáo viên nhập điểm chính thức (thang 10, bước 0.25) và nhận xét, hoặc "Duyệt giữ nguyên điểm AI"
     * (keepAiScore); bài chuyển sang REVIEWED, điểm AI giữ nguyên (BR-09). Người duyệt lấy từ session.
     */
    @PostMapping("/teacher/submissions")
    public String review(@Valid @ModelAttribute ReviewForm form, BindingResult result,
                         @RequestParam(defaultValue = "false") boolean keepAiScore,
                         @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user,
                         RedirectAttributes redirect) {
        if (form.getSubmissionId() <= 0) {
            redirect.addFlashAttribute("errorFlash", "ID bài nộp không hợp lệ.");
            return "redirect:/teacher/submissions";
        }
        try {
            FormErrors.requireValid(result);
            Double parsed = null;
            if (!keepAiScore && form.getScore() != null && !form.getScore().isBlank()) {
                try {
                    parsed = Double.parseDouble(form.getScore().trim().replace(',', '.'));
                } catch (NumberFormatException e) {
                    throw new IllegalArgumentException("Điểm số phải là một số từ 0 đến 10.");
                }
            }
            submissionService.reviewEssay(form, parsed, keepAiScore, user.getUserId());
            redirect.addFlashAttribute("flash", "Đã lưu kết quả chấm điểm và nhận xét thành công!");
        } catch (IllegalArgumentException | IllegalStateException e) {
            redirect.addFlashAttribute("errorFlash", e.getMessage());
        }
        return "redirect:/teacher/submissions?id=" + form.getSubmissionId();
    }
}
