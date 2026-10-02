package com.edututor.controller.admin;

import com.edututor.dto.PageResult;
import com.edututor.dto.SessionUser;
import com.edututor.dto.UserView;
import com.edututor.interceptor.AuthInterceptor;
import com.edututor.service.UserService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.SessionAttribute;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/** UC-ADM-01 / 04: danh sách giáo viên / học sinh (phân trang), khóa và mở khóa tài khoản. */
@Controller
public class AdminUserController {

    private static final int PAGE_SIZE = 10;

    private final UserService userService;

    public AdminUserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/admin/teachers")
    public String teachers(@RequestParam(defaultValue = "1") int page, Model model) {
        fillPage(model, "TEACHER", "teachers", page);
        return "admin/teachers";
    }

    @GetMapping("/admin/students")
    public String students(@RequestParam(defaultValue = "1") int page, Model model) {
        fillPage(model, "STUDENT", "students", page);
        model.addAttribute("teachers", userService.getUsersByRole("TEACHER", 1, 50).getItems());
        return "admin/students";
    }

    private void fillPage(Model model, String role, String attr, int page) {
        PageResult<UserView> result = userService.getUsersByRole(role, page, PAGE_SIZE);
        model.addAttribute(attr, result.getItems());
        model.addAttribute("page", result.getPage());
        model.addAttribute("totalPages", result.getTotalPages());
        model.addAttribute("totalRecords", result.getTotalItems());
    }

    @PostMapping("/admin/users/toggle-status")
    public String toggleStatus(@RequestParam(defaultValue = "0") int userId,
                               @RequestParam(required = false) String returnUrl,
                               @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser current,
                               HttpServletRequest request, RedirectAttributes redirect) {
        try {
            UserView before = userService.toggleUserStatus(userId, current.getUserId());
            // before.isActive() là trạng thái trước khi đổi
            redirect.addFlashAttribute("flash", before.isActive()
                    ? "Đã khóa tài khoản " + before.getUsername() + " thành công!"
                    : "Đã kích hoạt lại tài khoản " + before.getUsername() + " thành công!");
        } catch (IllegalArgumentException | IllegalStateException e) {
            redirect.addFlashAttribute("errorFlash", e.getMessage());
        }
        return "redirect:" + safeReturnUrl(returnUrl, request);
    }

    /** Chỉ cho phép quay lại URL nội bộ (chống open redirect). */
    private String safeReturnUrl(String returnUrl, HttpServletRequest request) {
        String ctx = request.getContextPath();
        if (returnUrl != null && returnUrl.startsWith(ctx + "/admin/") && !returnUrl.contains("//")
                && !returnUrl.contains("\r") && !returnUrl.contains("\n")) {
            return returnUrl.substring(ctx.length());
        }
        return "/admin/dashboard";
    }
}
