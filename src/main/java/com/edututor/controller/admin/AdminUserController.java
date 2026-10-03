package com.edututor.controller.admin;

import com.edututor.dto.PageResult;
import com.edututor.dto.SessionUser;
import com.edututor.dto.UserCreateForm;
import com.edututor.dto.UserEditForm;
import com.edututor.dto.UserView;
import com.edututor.exception.ConflictException;
import com.edututor.interceptor.AuthInterceptor;
import com.edututor.model.UserStatus;
import com.edututor.service.AdminUserService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
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
import org.springframework.web.util.UriComponentsBuilder;

/**
 * UC-ADM-01…05: Admin quản lý người dùng — danh sách có tìm kiếm / lọc / phân trang, tạo, sửa, khóa / mở khóa,
 * xóa (cứng hoặc mềm), đặt lại mật khẩu.
 */
@Controller
public class AdminUserController {

    private final AdminUserService userService;

    public AdminUserController(AdminUserService userService) {
        this.userService = userService;
    }

    /** Đường dẫn cũ giữ lại cho liên kết đã có: chuyển sang danh sách chung đã lọc theo vai trò. */
    @GetMapping("/admin/teachers")
    public String teachers() {
        return "redirect:/admin/users?role=TEACHER";
    }

    @GetMapping("/admin/students")
    public String students() {
        return "redirect:/admin/users?role=STUDENT";
    }

    // ---------- UC-ADM-01: danh sách ----------

    @GetMapping("/admin/users")
    public String list(@RequestParam(defaultValue = "") String keyword,
                       @RequestParam(defaultValue = "") String role,
                       @RequestParam(defaultValue = "") String status,
                       @RequestParam(defaultValue = "1") int page,
                       @RequestParam(defaultValue = "10") int size,
                       HttpServletRequest request, Model model) {
        PageResult<UserView> result = userService.search(keyword, role, status, page, size);
        String listPath = request.getContextPath() + "/admin/users";
        // baseUrl giữ nguyên bộ lọc khi chuyển trang; returnUrl đưa người dùng về đúng trang sau thao tác
        String baseUrl = UriComponentsBuilder.fromPath(listPath).queryParam("keyword", keyword)
                .queryParam("role", role).queryParam("status", status).queryParam("size", result.getSize())
                .build().encode().toUriString();
        model.addAttribute("users", result.getItems());
        model.addAttribute("page", result.getPage());
        model.addAttribute("size", result.getSize());
        model.addAttribute("totalPages", result.getTotalPages());
        model.addAttribute("totalRecords", result.getTotalItems());
        model.addAttribute("keyword", keyword);
        model.addAttribute("role", role);
        model.addAttribute("status", status);
        model.addAttribute("baseUrl", baseUrl);
        model.addAttribute("returnUrl", baseUrl + "&page=" + result.getPage());
        return "admin/users";
    }

    // ---------- UC-ADM-02: tạo ----------

    @GetMapping("/admin/users/new")
    public String newForm(Model model) {
        model.addAttribute("userCreateForm", new UserCreateForm());
        return "admin/user-form";
    }

    @PostMapping("/admin/users")
    public String create(@Valid @ModelAttribute("userCreateForm") UserCreateForm form, BindingResult result,
                         RedirectAttributes redirect) {
        if (result.hasErrors()) {
            return "admin/user-form";
        }
        try {
            userService.create(form);
        } catch (ConflictException e) {
            result.rejectValue(e.getField() == null ? "username" : e.getField(), "conflict", e.getMessage());
            return "admin/user-form";
        }
        redirect.addFlashAttribute("flash", "Đã tạo tài khoản " + form.getUsername() + " thành công!");
        return "redirect:/admin/users";
    }

    // ---------- UC-ADM-03: sửa ----------

    @GetMapping("/admin/users/{id}/edit")
    public String editForm(@PathVariable int id, Model model) {
        UserView target = userService.get(id);
        UserEditForm form = new UserEditForm();
        form.setFullName(target.getFullName());
        form.setEmail(target.getEmail());
        form.setRole(target.getRole());
        form.setStatus("INACTIVE".equals(target.getStatus()) ? "SUSPENDED" : target.getStatus());
        model.addAttribute("target", target);
        model.addAttribute("userEditForm", form);
        return "admin/user-form";
    }

    @PostMapping("/admin/users/{id}")
    public String update(@PathVariable int id, @Valid @ModelAttribute("userEditForm") UserEditForm form,
                         BindingResult result, @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser admin,
                         Model model, RedirectAttributes redirect) {
        if (!result.hasErrors()) {
            try {
                userService.update(id, form, admin.getUserId());
                redirect.addFlashAttribute("flash", "Đã cập nhật tài khoản thành công!");
                return "redirect:/admin/users";
            } catch (ConflictException e) {
                if (e.getField() == null) {
                    redirect.addFlashAttribute("errorFlash", e.getMessage());
                    return "redirect:/admin/users";
                }
                result.rejectValue(e.getField(), "conflict", e.getMessage());
            }
        }
        model.addAttribute("target", userService.get(id));
        return "admin/user-form";
    }

    // ---------- UC-ADM-04: khóa / mở khóa / xóa ----------

    @PostMapping("/admin/users/{id}/status")
    public String changeStatus(@PathVariable int id, @RequestParam String status,
                               @RequestParam(required = false) String returnUrl,
                               @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser admin,
                               HttpServletRequest request, RedirectAttributes redirect) {
        try {
            UserStatus target = UserStatus.valueOf(status);
            UserView after = userService.changeStatus(id, target, admin.getUserId());
            redirect.addFlashAttribute("flash", target == UserStatus.SUSPENDED
                    ? "Đã khóa tài khoản " + after.getUsername() + " thành công!"
                    : "Đã kích hoạt lại tài khoản " + after.getUsername() + " thành công!");
        } catch (IllegalArgumentException | ConflictException e) {
            redirect.addFlashAttribute("errorFlash", e.getMessage());
        }
        return "redirect:" + safeReturnUrl(returnUrl, request);
    }

    @PostMapping("/admin/users/{id}/delete")
    public String delete(@PathVariable int id, @RequestParam(required = false) String returnUrl,
                         @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser admin,
                         HttpServletRequest request, RedirectAttributes redirect) {
        try {
            boolean hard = userService.delete(id, admin.getUserId());
            redirect.addFlashAttribute("flash", hard
                    ? "Đã xóa tài khoản."
                    : "Tài khoản đã có dữ liệu liên quan nên được chuyển sang trạng thái đã xóa (INACTIVE).");
        } catch (ConflictException e) {
            redirect.addFlashAttribute("errorFlash", e.getMessage());
        }
        return "redirect:" + safeReturnUrl(returnUrl, request);
    }

    /** Khôi phục tài khoản đã xóa mềm (INACTIVE → ACTIVE). */
    @PostMapping("/admin/users/{id}/restore")
    public String restore(@PathVariable int id, @RequestParam(required = false) String returnUrl,
                          HttpServletRequest request, RedirectAttributes redirect) {
        try {
            UserView after = userService.restore(id);
            redirect.addFlashAttribute("flash", "Đã khôi phục tài khoản " + after.getUsername() + " thành công!");
        } catch (ConflictException e) {
            redirect.addFlashAttribute("errorFlash", e.getMessage());
        }
        return "redirect:" + safeReturnUrl(returnUrl, request);
    }

    // ---------- UC-ADM-05: đặt lại mật khẩu ----------

    /** Mật khẩu mới hiển thị MỘT lần ngay trong phản hồi này (không redirect, không cache, không ghi log). */
    @PostMapping("/admin/users/{id}/reset-password")
    public String resetPassword(@PathVariable int id, HttpServletResponse response, Model model,
                                RedirectAttributes redirect) {
        try {
            String password = userService.resetPassword(id);
            response.setHeader("Cache-Control", "no-store");
            model.addAttribute("target", userService.get(id));
            model.addAttribute("newPassword", password);
            return "admin/user-password";
        } catch (ConflictException e) {
            redirect.addFlashAttribute("errorFlash", e.getMessage());
            return "redirect:/admin/users";
        }
    }

    /** Chỉ cho phép quay lại URL nội bộ của khu vực admin (chống open redirect). */
    private String safeReturnUrl(String returnUrl, HttpServletRequest request) {
        String ctx = request.getContextPath();
        if (returnUrl != null && returnUrl.startsWith(ctx + "/admin/") && !returnUrl.contains("//")
                && !returnUrl.contains("\r") && !returnUrl.contains("\n")) {
            return returnUrl.substring(ctx.length());
        }
        return "/admin/users";
    }
}
