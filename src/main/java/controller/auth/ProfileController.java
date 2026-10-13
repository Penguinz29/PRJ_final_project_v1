package controller.auth;

import dto.form.PasswordChangeForm;
import dto.form.ProfileForm;
import dto.view.SessionUser;
import dto.view.UserView;
import exception.ConflictException;
import config.AuthInterceptor;
import service.UserService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.SessionAttribute;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/**
 * Hồ sơ cá nhân cho mọi vai trò (UC-AUTH-04) và tự đổi mật khẩu (UC-AUTH-05). Người dùng luôn lấy từ session,
 * không nhận userId từ client. Lỗi hiển thị tại từng trường; lưu thành công thì redirect (PRG) kèm flash.
 */
@Controller
public class ProfileController {

    private static final String VIEW = "auth/profile";

    private final UserService userService;

    public ProfileController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping({"/profile", "/profile/password"})
    public String profile(@SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user,
                          HttpServletRequest request, Model model) {
        model.addAttribute("passwordTab", request.getServletPath().endsWith("/password"));
        UserView me = userService.getProfile(user.getUserId());
        ProfileForm form = new ProfileForm();
        form.setFullName(me.getFullName());
        form.setEmail(me.getEmail());
        model.addAttribute("profileForm", form);
        model.addAttribute("passwordForm", new PasswordChangeForm());
        model.addAttribute("me", me);
        return VIEW;
    }

    @PostMapping("/profile")
    public String updateProfile(@Valid @ModelAttribute("profileForm") ProfileForm form, BindingResult result,
                                @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user,
                                HttpSession session, Model model, RedirectAttributes redirect) {
        if (!result.hasErrors()) {
            try {
                SessionUser updated = userService.updateProfile(user.getUserId(), form);
                session.setAttribute(AuthInterceptor.SESSION_USER, updated); // tên mới hiện ngay trên thanh menu
                redirect.addFlashAttribute("flash", "Đã cập nhật hồ sơ cá nhân.");
                return "redirect:/profile";
            } catch (ConflictException e) {
                result.rejectValue(e.getField() == null ? "email" : e.getField(), "conflict", e.getMessage());
            }
        }
        model.addAttribute("passwordForm", new PasswordChangeForm());
        model.addAttribute("me", userService.getProfile(user.getUserId()));
        return VIEW;
    }

    @PostMapping("/profile/password")
    public String changePassword(@Valid @ModelAttribute("passwordForm") PasswordChangeForm form, BindingResult result,
                                 @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user,
                                 Model model, RedirectAttributes redirect) {
        if (!result.hasErrors()) {
            try {
                userService.changePassword(user.getUserId(), form);
                redirect.addFlashAttribute("flash", "Đổi mật khẩu thành công.");
                return "redirect:/profile";
            } catch (ConflictException e) {
                result.rejectValue(e.getField() == null ? "currentPassword" : e.getField(), "conflict", e.getMessage());
            }
        }
        UserView me = userService.getProfile(user.getUserId());
        ProfileForm profile = new ProfileForm();
        profile.setFullName(me.getFullName());
        profile.setEmail(me.getEmail());
        model.addAttribute("profileForm", profile);
        model.addAttribute("me", me);
        model.addAttribute("passwordTab", true);
        return VIEW;
    }
}
