package com.edututor.service;

import com.edututor.dto.PageResult;
import com.edututor.dto.RegisterForm;
import com.edututor.dto.SessionUser;
import com.edututor.dto.UserView;
import com.edututor.exception.ConflictException;
import com.edututor.model.Role;
import com.edututor.model.User;
import com.edututor.model.UserStatus;
import com.edututor.repository.UserRepository;
import com.edututor.util.Pager;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Nghiệp vụ người dùng: xác thực, đăng ký, quản trị tài khoản. */
@Service
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    /**
     * UC-AUTH-01: xác thực đăng nhập. Mật khẩu lưu bằng BCrypt. Tài khoản cũ còn băm SHA-256 vẫn đăng nhập được
     * và được nâng cấp sang BCrypt ngay lần đăng nhập thành công đầu tiên.
     *
     * @return người dùng để lưu vào session (không chứa mã băm), hoặc null nếu sai thông tin / tài khoản bị khóa
     */
    @Transactional
    public SessionUser authenticate(String username, String plainPassword) {
        if (username == null || username.isBlank() || plainPassword == null || plainPassword.isEmpty()) {
            return null;
        }
        User user = userRepository.findByUsername(username.trim()).orElse(null);
        if (user == null || !user.isActive() || user.getPasswordHash() == null) {
            return null;
        }
        String stored = user.getPasswordHash();
        boolean ok;
        if (isBcrypt(stored)) {
            ok = passwordEncoder.matches(plainPassword, stored);
        } else if (stored.equalsIgnoreCase(sha256Hex(plainPassword))) {
            user.setPasswordHash(passwordEncoder.encode(plainPassword)); // dirty checking → UPDATE
            ok = true;
        } else {
            ok = false;
        }
        return ok ? new SessionUser(user.getUserId(), user.getUsername(), user.getFullName(), user.getRole().name())
                : null;
    }

    private static boolean isBcrypt(String hash) {
        return hash.startsWith("$2a$") || hash.startsWith("$2b$") || hash.startsWith("$2y$");
    }

    private static String sha256Hex(String s) {
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256").digest(s.getBytes(StandardCharsets.UTF_8));
            return java.util.HexFormat.of().formatHex(digest);
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 không khả dụng", e);
        }
    }

    /**
     * UC-AUTH-02: đăng ký tài khoản học sinh. Vai trò luôn là STUDENT, trạng thái ACTIVE (bỏ qua mọi giá trị
     * từ client). Dữ liệu cú pháp đã được Bean Validation kiểm tra ở controller.
     *
     * @throws ConflictException trùng username / email (kèm tên trường để hiển thị tại ô nhập)
     */
    @Transactional
    public void register(RegisterForm form) {
        if (!form.getPassword().equals(form.getConfirmPassword())) {
            throw new ConflictException("Mật khẩu xác nhận không khớp.", "confirmPassword");
        }
        if (userRepository.existsByUsernameIgnoreCase(form.getUsername())) {
            throw new ConflictException("Tên đăng nhập đã được sử dụng. Vui lòng chọn tên khác.", "username");
        }
        if (userRepository.existsByEmailIgnoreCase(form.getEmail())) {
            throw new ConflictException("Email đã được đăng ký. Vui lòng sử dụng email khác.", "email");
        }
        User u = new User();
        u.setUsername(form.getUsername());
        u.setPasswordHash(passwordEncoder.encode(form.getPassword()));
        u.setFullName(form.getFullName());
        u.setEmail(form.getEmail());
        u.setRole(Role.STUDENT);
        u.setStatus(UserStatus.ACTIVE);
        try {
            userRepository.saveAndFlush(u);
        } catch (DataIntegrityViolationException e) {
            // Ràng buộc UNIQUE của CSDL (lớp kiểm tra thứ 4): hai request đăng ký cùng lúc
            throw new ConflictException("Tên đăng nhập hoặc email đã được sử dụng.", "username");
        }
    }

    /** Danh sách theo vai trò, phân trang ở CSDL (mới nhất trước). */
    @Transactional(readOnly = true)
    public PageResult<UserView> getUsersByRole(String role, int page, int size) {
        Page<User> result = userRepository.findByRole(Role.valueOf(role),
                Pager.pageRequest(page, size, Sort.by(Sort.Order.desc("createdAt"), Sort.Order.desc("userId"))));
        Map<Integer, String> teacherNames = teacherNames(result.getContent());
        return PageResult.of(result, u -> ViewMapper.toView(u, teacherNames.get(u.getTeacherId())));
    }

    /** Vài người dùng mới nhất theo vai trò (dùng cho dashboard). */
    @Transactional(readOnly = true)
    public List<UserView> getRecentUsers(String role, int limit) {
        Page<User> result = userRepository.findByRole(Role.valueOf(role), PageRequest.of(0, limit,
                Sort.by(Sort.Order.desc("createdAt"), Sort.Order.desc("userId"))));
        return result.getContent().stream().map(u -> ViewMapper.toView(u, null)).toList();
    }

    /** Tên giáo viên phụ trách của một trang học sinh, nạp bằng MỘT truy vấn IN. */
    private Map<Integer, String> teacherNames(List<User> users) {
        Set<Integer> ids = new HashSet<>();
        for (User u : users) {
            if (u.getTeacherId() != null) {
                ids.add(u.getTeacherId());
            }
        }
        Map<Integer, String> names = new HashMap<>();
        if (!ids.isEmpty()) {
            for (User t : userRepository.findAllById(ids)) {
                names.put(t.getUserId(), t.getFullName());
            }
        }
        return names;
    }

    @Transactional(readOnly = true)
    public long countUsersByRole(String role) {
        return userRepository.countByRole(Role.valueOf(role));
    }
}
