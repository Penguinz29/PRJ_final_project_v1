package com.edututor.controller.auth;

import com.edututor.dto.RegisterForm;
import com.edututor.dto.SessionUser;
import com.edututor.exception.ConflictException;
import com.edututor.interceptor.AuthInterceptor;
import com.edututor.interceptor.CsrfInterceptor;
import com.edututor.service.UserService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/**
 * UC-AUTH-01 / 02 / 03: đăng nhập, đăng ký, đăng xuất.
 * Người dùng đăng nhập được lưu trong HttpSession với khóa {@code LOGGED_IN_USER} (không chứa mã băm mật khẩu).
 */
@Controller
public class AuthController {

    private final UserService userService;

    public AuthController(UserService userService) {
        this.userService = userService;
    }

    /** Trang gốc: chuyển tới dashboard theo vai trò (AuthInterceptor đã chuyển người chưa đăng nhập về /login). */
    @GetMapping("/")
    public String home(HttpSession session) {
        SessionUser user = (SessionUser) session.getAttribute(AuthInterceptor.SESSION_USER);
        return user == null ? "redirect:/login" : redirectByRole(user);
    }

    @GetMapping("/login")
    public String loginForm(HttpSession session) {
        SessionUser user = (SessionUser) session.getAttribute(AuthInterceptor.SESSION_USER);
        return user != null ? redirectByRole(user) : "auth/login";
    }

    @PostMapping("/login")
    public String login(@RequestParam(defaultValue = "") String username,
                        @RequestParam(defaultValue = "") String password,
                        HttpServletRequest request, Model model) {
        if (username.isBlank() || password.isEmpty()) {
            model.addAttribute("error", "Tên đăng nhập và mật khẩu không được để trống.");
            return "auth/login";
        }
        SessionUser user = userService.authenticate(username, password);
        if (user == null) {
            model.addAttribute("username", username.trim());
            model.addAttribute("error", "Tên đăng nhập hoặc mật khẩu sai, hoặc tài khoản đã bị khóa!");
            return "auth/login";
        }
        // Chống session fixation: cấp session ID mới và token CSRF mới sau khi xác thực
        request.getSession(true);
        request.changeSessionId();
        HttpSession session = request.getSession(false);
        session.setAttribute(AuthInterceptor.SESSION_USER, user);
        session.setAttribute(CsrfInterceptor.SESSION_TOKEN, CsrfInterceptor.newToken());
        return redirectByRole(user);
    }

    @GetMapping("/register")
    public String registerForm(HttpSession session, Model model) {
        SessionUser user = (SessionUser) session.getAttribute(AuthInterceptor.SESSION_USER);
        if (user != null) {
            return redirectByRole(user);
        }
        model.addAttribute("registerForm", new RegisterForm());
        return "auth/register";
    }

    /** Vai trò luôn là STUDENT: form không có trường role nên mọi {@code role} do client gửi bị bỏ qua. */
    @PostMapping("/register")
    public String register(@Valid @ModelAttribute("registerForm") RegisterForm form, BindingResult result,
                           RedirectAttributes redirect) {
        if (result.hasErrors()) {
            return "auth/register";
        }
        try {
            userService.register(form);
        } catch (ConflictException e) {
            result.rejectValue(e.getField() == null ? "username" : e.getField(), "conflict", e.getMessage());
            return "auth/register";
        }
        redirect.addFlashAttribute("flashMsg", "Đăng ký thành công! Vui lòng đăng nhập.");
        redirect.addFlashAttribute("flashType", "success");
        return "redirect:/login";
    }

    @PostMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/login";
    }

    /** ADMIN → /admin/dashboard, TEACHER → /teacher/dashboard, STUDENT → /student/dashboard. */
    private String redirectByRole(SessionUser user) {
        return switch (user.getRole()) {
            case "ADMIN" -> "redirect:/admin/dashboard";
            case "TEACHER" -> "redirect:/teacher/dashboard";
            default -> "redirect:/student/dashboard";
        };
    }
}
