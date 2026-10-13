package dto.form;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/** Form Admin tạo tài khoản (VAL-01…05). Vai trò do Admin chọn; trạng thái luôn là ACTIVE. */
public class UserCreateForm {

    @NotBlank(message = "{val.username.required}")
    @Pattern(regexp = "[A-Za-z0-9_.]{4,30}", message = "{val.username.invalid}")
    private String username;

    @NotBlank(message = "{val.password.required}")
    @Size(min = 8, max = 64, message = "{val.password.size}")
    @Pattern(regexp = "^(?=.*[A-Za-z])(?=.*\\d).*$", message = "{val.password.complexity}")
    private String password;

    @NotBlank(message = "{val.fullName.required}")
    @Size(min = 2, max = 100, message = "{val.fullName.size}")
    @Pattern(regexp = "^[^<>]*$", message = "{val.fullName.html}")
    private String fullName;

    @NotBlank(message = "{val.email.required}")
    @Email(message = "{val.email.invalid}")
    @Size(max = 100, message = "{val.email.size}")
    private String email;

    @NotBlank(message = "{val.role.required}")
    @Pattern(regexp = "ADMIN|TEACHER|STUDENT", message = "{val.role.invalid}")
    private String role = "TEACHER";

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username == null ? null : username.trim(); }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName == null ? null : fullName.trim(); }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email == null ? null : email.trim(); }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
}
