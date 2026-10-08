package com.edututor.controller.teacher;

import com.edututor.dto.OptionView;
import com.edututor.dto.PageResult;
import com.edututor.dto.QuestionForm;
import com.edututor.dto.QuestionView;
import com.edututor.dto.SessionUser;
import com.edututor.dto.TopicView;
import com.edututor.exception.ConflictException;
import com.edututor.interceptor.AuthInterceptor;
import com.edututor.service.LessonService;
import com.edututor.service.QuestionService;
import com.edututor.service.TopicService;
import jakarta.servlet.http.HttpServletRequest;
import com.edututor.util.FormErrors;
import jakarta.validation.Valid;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.SessionAttribute;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/** UC-TEA-04: ngân hàng câu hỏi (danh sách có lọc + phân trang ở CSDL, tạo, sửa, xóa). */
@Controller
public class TeacherQuestionController {

    private static final int PAGE_SIZE = 10;

    private final QuestionService questionService;
    private final TopicService topicService;
    private final LessonService lessonService;

    public TeacherQuestionController(QuestionService questionService, TopicService topicService,
                                     LessonService lessonService) {
        this.questionService = questionService;
        this.topicService = topicService;
        this.lessonService = lessonService;
    }

    @GetMapping({"/teacher/questions", "/teacher/question/form"})
    public String list(@RequestParam(defaultValue = "") String action,
                       @RequestParam(defaultValue = "0") int id,
                       @RequestParam(defaultValue = "0") int topicId,
                       @RequestParam(defaultValue = "0") int lessonId,
                       @RequestParam(defaultValue = "") String type,
                       @RequestParam(defaultValue = "0") int level,
                       @RequestParam(defaultValue = "1") int page,
                       @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user,
                       HttpServletRequest request, Model model) {
        List<TopicView> topics = topicService.getAllTopics();
        model.addAttribute("topics", topics);

        boolean formPage = request.getServletPath().equals("/teacher/question/form")
                || "create".equals(action) || "edit".equals(action);
        if (formPage) {
            model.addAttribute("lessons", lessonService.getAllLessons());
            if ("edit".equals(action)) {
                QuestionView q = questionService.getQuestionForEdit(id, user.getUserId(), user.isAdmin()); // BR-03
                if (q == null) {
                    return "redirect:/teacher/questions";
                }
                Map<String, String> optionMap = new LinkedHashMap<>();
                String correct = "";
                if (q.getOptions() != null) {
                    for (OptionView o : q.getOptions()) {
                        optionMap.put(o.getOptionLetter(), o.getContent());
                        if (o.isCorrect()) {
                            correct = o.getOptionLetter();
                        }
                    }
                }
                model.addAttribute("isEdit", true);
                model.addAttribute("question", q);
                model.addAttribute("optionMap", optionMap);
                model.addAttribute("correctOption", correct);
            }
            return "teacher/question-form";
        }

        PageResult<QuestionView> result = questionService.search(topicId, lessonId, type, level, page, PAGE_SIZE);
        model.addAttribute("questions", result.getItems());
        model.addAttribute("lessons", topicId > 0 ? lessonService.getLessonsByTopic(topicId)
                : lessonService.getAllLessons());
        model.addAttribute("page", result.getPage());
        model.addAttribute("totalPages", result.getTotalPages());
        model.addAttribute("totalRecords", result.getTotalItems());
        model.addAttribute("selectedTopicId", topicId);
        model.addAttribute("selectedLessonId", lessonId);
        model.addAttribute("selectedType", type);
        model.addAttribute("selectedLevel", level);
        return "teacher/questions";
    }

    @PostMapping({"/teacher/questions", "/teacher/questions/create"})
    public String save(@Valid @ModelAttribute QuestionForm form, BindingResult result,
                       @RequestParam(name = "opt_A", defaultValue = "") String optA,
                       @RequestParam(name = "opt_B", defaultValue = "") String optB,
                       @RequestParam(name = "opt_C", defaultValue = "") String optC,
                       @RequestParam(name = "opt_D", defaultValue = "") String optD,
                       @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user,
                       RedirectAttributes redirect) {
        form.setOptionTexts(List.of(optA, optB, optC, optD));
        String action = form.getAction();
        try {
            switch (action) {
                case "create" -> {
                    FormErrors.requireValid(result);
                    questionService.createQuestion(form, user.getUserId());
                    redirect.addFlashAttribute("flash", "Thêm câu hỏi thành công.");
                }
                case "update" -> {
                    FormErrors.requireValid(result);
                    questionService.updateQuestion(form, user.getUserId(), user.isAdmin());
                    redirect.addFlashAttribute("flash", "Cập nhật câu hỏi thành công.");
                }
                case "delete" -> {
                    boolean hard = questionService.deleteQuestion(form.getId(), user.getUserId(), user.isAdmin());
                    redirect.addFlashAttribute("flash", hard ? "Xóa câu hỏi thành công."
                            : "Đã ẩn câu hỏi (xóa mềm) vì đã có bài làm của học sinh; lịch sử được giữ nguyên.");
                    return "redirect:/teacher/questions";
                }
                default -> throw new IllegalArgumentException("Thao tác không hợp lệ.");
            }
        } catch (IllegalArgumentException | ConflictException e) {
            redirect.addFlashAttribute("errorFlash", e.getMessage());
            if ("delete".equals(action)) {
                return "redirect:/teacher/questions";
            }
            // Lỗi khi tạo/sửa: quay lại form để người dùng chỉnh tiếp
            return "redirect:/teacher/questions" + ("update".equals(action) && form.getId() > 0
                    ? "?action=edit&id=" + form.getId() : "?action=create");
        }
        return "redirect:/teacher/questions?lessonId=" + form.getLessonId() + "&type=" + form.getType();
    }

}
