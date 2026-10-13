package dto.view;

import java.io.Serializable;

/**
 * Người dùng đang đăng nhập, lưu trong HttpSession với khóa {@code LOGGED_IN_USER}.
 * Cố ý KHÔNG chứa mã băm mật khẩu; role là chuỗi (ADMIN / TEACHER / STUDENT) để JSP so sánh trực tiếp.
 */
public class SessionUser implements Serializable {
    private static final long serialVersionUID = 1L;

    private final int userId;
    private final String username;
    private final String fullName;
    private final String role;

    public SessionUser(int userId, String username, String fullName, String role) {
        this.userId = userId;
        this.username = username;
        this.fullName = fullName;
        this.role = role;
    }

    public int getUserId() { return userId; }
    public String getUsername() { return username; }
    public String getFullName() { return fullName; }
    public String getRole() { return role; }

    public boolean isAdmin() { return "ADMIN".equals(role); }
    public boolean isTeacher() { return "TEACHER".equals(role); }
    public boolean isStudent() { return "STUDENT".equals(role); }
}
