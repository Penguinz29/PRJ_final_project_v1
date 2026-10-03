package com.edututor.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/** Form sửa hồ sơ cá nhân (UC-AUTH-04, VAL-03, VAL-04). Không có username / role: không cho tự đổi. */
public class ProfileForm {

    @NotBlank(message = "{val.fullName.required}")
    @Size(min = 2, max = 100, message = "{val.fullName.size}")
    @Pattern(regexp = "^[^<>]*$", message = "{val.fullName.html}")
    private String fullName;

    @NotBlank(message = "{val.email.required}")
    @Email(message = "{val.email.invalid}")
    @Size(max = 100, message = "{val.email.size}")
    private String email;

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName == null ? null : fullName.trim(); }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email == null ? null : email.trim(); }
}
