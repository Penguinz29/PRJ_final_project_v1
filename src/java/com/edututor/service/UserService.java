package com.edututor.service;

import com.edututor.dao.UserDAO;
import com.edututor.model.User;
import com.edututor.util.PasswordUtil;
import java.util.List;

/**
 * Service xử lý nghiệp vụ User.
 * Tầng trung gian giữa Controller và UserDAO.
 * Theo Spring MVC pattern: @Service
 */
public class UserService {

    private final UserDAO userDAO = new UserDAO();

    /**
     * UC-AUTH-01: Xác thực đăng nhập.
     * Băm mật khẩu và kiểm tra với DB.
     *
     * @param username tên đăng nhập
     * @param plainPassword mật khẩu thô chưa băm
     * @return User nếu hợp lệ, null nếu sai
     */
    public User authenticate(String username, String plainPassword) {
        if (username == null || username.trim().isEmpty()) return null;
        if (plainPassword == null || plainPassword.trim().isEmpty()) return null;
        String hashed = PasswordUtil.hashPassword(plainPassword);
        return userDAO.login(username.trim(), hashed);
    }

    /**
     * UC-AUTH-02: Kiểm tra username đã tồn tại chưa.
     */
    public boolean existsByUsername(String username) {
        return userDAO.existsByUsername(username);
    }

    /**
     * UC-AUTH-02: Kiểm tra email đã tồn tại chưa.
     */
    public boolean existsByEmail(String email) {
        return userDAO.existsByEmail(email);
    }

    /**
     * UC-AUTH-02: Đăng ký tài khoản học sinh mới.
     * Băm mật khẩu, thiết lập role=STUDENT, status=ACTIVE.
     *
     * @return true nếu đăng ký thành công
     */
    public boolean register(String username, String plainPassword, String fullName, String email) {
        String hashed = PasswordUtil.hashPassword(plainPassword);
        return userDAO.insertUser(username.trim(), hashed, fullName.trim(), email.trim());
    }

    /**
     * FR-ADM-03: Lấy danh sách user theo role (phân trang).
     */
    public List<User> getUsersByRole(String role, int page, int pageSize) {
        return userDAO.getByRole(role, page, pageSize);
    }

    /**
     * FR-ADM-03: Đếm số lượng user theo role.
     */
    public int countUsersByRole(String role) {
        return userDAO.countByRole(role);
    }

    /**
     * FR-ADM-03: Lấy user theo ID.
     */
    public User getUserById(int userId) {
        return userDAO.getById(userId);
    }

    /**
     * FR-ADM-03: Kích hoạt/Khóa tài khoản (toggle IsActive).
     */
    public boolean toggleUserStatus(int userId) {
        return userDAO.toggleStatus(userId);
    }
}
