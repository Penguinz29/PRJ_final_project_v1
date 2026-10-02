package com.edututor.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import java.util.Objects;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.Nationalized;

/** Entity bảng Users. Không bao giờ được trả ra JSP/JSON (chứa mã băm mật khẩu). */
@Entity
@Table(name = "Users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "UserId")
    private Integer userId;

    @Column(name = "Username", nullable = false, updatable = false, length = 50)
    private String username;

    @Column(name = "PasswordHash", nullable = false, length = 64)
    private String passwordHash;

    @Nationalized
    @Column(name = "FullName", nullable = false, length = 100)
    private String fullName;

    @Column(name = "Email", length = 100)
    private String email;

    @Enumerated(EnumType.STRING)
    @Column(name = "`Role`", nullable = false, length = 20)
    private Role role;

    @Column(name = "IsActive")
    private boolean active = true;

    /** Giáo viên phụ trách (chỉ có ý nghĩa với STUDENT). */
    @Column(name = "TeacherId")
    private Integer teacherId;

    @CreationTimestamp
    @Column(name = "CreatedAt", updatable = false)
    private LocalDateTime createdAt;

    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public Role getRole() { return role; }
    public void setRole(Role role) { this.role = role; }
    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
    public Integer getTeacherId() { return teacherId; }
    public void setTeacherId(Integer teacherId) { this.teacherId = teacherId; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    @Override
    public boolean equals(Object o) {
        return this == o || (o instanceof User other && userId != null && Objects.equals(userId, other.userId));
    }

    @Override
    public int hashCode() {
        return User.class.hashCode();
    }
}
