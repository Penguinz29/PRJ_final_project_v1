package dto.form;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/** Form Admin sửa tài khoản: họ tên, email, vai trò, trạng thái (username không đổi được). */
public class UserEditForm {

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
    private String role;

    /** Chỉ ACTIVE hoặc SUSPENDED; INACTIVE (xóa mềm) không chọn được. */
    @NotBlank(message = "{val.status.required}")
    @Pattern(regexp = "ACTIVE|SUSPENDED", message = "{val.status.invalid}")
    private String status = "ACTIVE";

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName == null ? null : fullName.trim(); }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email == null ? null : email.trim(); }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
