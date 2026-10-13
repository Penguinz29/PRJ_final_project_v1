package dto.form;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/** Form tự đổi mật khẩu (UC-AUTH-05): mật khẩu cũ + mật khẩu mới theo VAL-02 + xác nhận. */
public class PasswordChangeForm {

    @NotBlank(message = "{val.currentPassword.required}")
    private String currentPassword;

    @NotBlank(message = "{val.password.required}")
    @Size(min = 8, max = 64, message = "{val.password.size}")
    @Pattern(regexp = "^(?=.*[A-Za-z])(?=.*\\d).*$", message = "{val.password.complexity}")
    private String newPassword;

    @NotBlank(message = "{val.confirmPassword.required}")
    private String confirmPassword;

    public String getCurrentPassword() { return currentPassword; }
    public void setCurrentPassword(String currentPassword) { this.currentPassword = currentPassword; }
    public String getNewPassword() { return newPassword; }
    public void setNewPassword(String newPassword) { this.newPassword = newPassword; }
    public String getConfirmPassword() { return confirmPassword; }
    public void setConfirmPassword(String confirmPassword) { this.confirmPassword = confirmPassword; }
}
