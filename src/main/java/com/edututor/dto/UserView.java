package com.edututor.dto;

import java.io.Serializable;
import java.util.Date;

/**
 * DTO hiển thị cho bảng Users - EduTutor Math 12
 */
public class UserView implements Serializable {
    private static final long serialVersionUID = 1L;

    private int userId;
    private String username;
    private String fullName;
    private String email;
    private String role;
    private boolean active;
    private Integer teacherId;
    private Date createdAt;

    // Thuộc tính mở rộng hiển thị UI
    private String teacherName;

    public UserView() {}

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }


    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public Integer getTeacherId() { return teacherId; }
    public void setTeacherId(Integer teacherId) { this.teacherId = teacherId; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public String getTeacherName() { return teacherName; }
    public void setTeacherName(String teacherName) { this.teacherName = teacherName; }
}
