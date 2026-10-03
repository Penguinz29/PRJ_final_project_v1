package com.edututor.service;

import com.edututor.dto.PageResult;
import com.edututor.dto.UserCreateForm;
import com.edututor.dto.UserEditForm;
import com.edututor.dto.UserView;
import com.edututor.exception.ConflictException;
import com.edututor.exception.NotFoundException;
import com.edututor.model.Role;
import com.edututor.model.User;
import com.edututor.model.UserStatus;
import com.edututor.repository.AiConfigRepository;
import com.edututor.repository.LessonMaterialRepository;
import com.edututor.repository.LessonRepository;
import com.edututor.repository.QuestionRepository;
import com.edututor.repository.SubmissionRepository;
import com.edututor.repository.TopicRepository;
import com.edututor.repository.TutorSessionRepository;
import com.edututor.repository.UserRepository;
import com.edututor.repository.spec.UserSpecs;
import com.edututor.util.Pager;
import java.security.SecureRandom;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Sort;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Nghiệp vụ Admin quản lý người dùng (UC-ADM-01…05): tìm kiếm/lọc/phân trang, tạo, sửa, khóa/mở khóa,
 * xóa (cứng hoặc mềm), đặt lại mật khẩu. Áp dụng BR-01, BR-02, BR-06.
 */
@Service
public class AdminUserService {

    private static final String PASSWORD_LETTERS = "abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ";
    private static final String PASSWORD_DIGITS = "23456789";
    private static final SecureRandom RANDOM = new SecureRandom();

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final TopicRepository topicRepository;
    private final LessonRepository lessonRepository;
    private final QuestionRepository questionRepository;
    private final LessonMaterialRepository materialRepository;
    private final SubmissionRepository submissionRepository;
    private final TutorSessionRepository tutorSessionRepository;
    private final AiConfigRepository aiConfigRepository;

    public AdminUserService(UserRepository userRepository, PasswordEncoder passwordEncoder,
                            TopicRepository topicRepository, LessonRepository lessonRepository,
                            QuestionRepository questionRepository,
                            LessonMaterialRepository materialRepository, SubmissionRepository submissionRepository,
                            TutorSessionRepository tutorSessionRepository, AiConfigRepository aiConfigRepository) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.topicRepository = topicRepository;
        this.lessonRepository = lessonRepository;
        this.questionRepository = questionRepository;
        this.materialRepository = materialRepository;
        this.submissionRepository = submissionRepository;
        this.tutorSessionRepository = tutorSessionRepository;
        this.aiConfigRepository = aiConfigRepository;
    }

    /** UC-ADM-01: danh sách có tìm kiếm (tên, username, email), lọc vai trò/trạng thái, phân trang ở CSDL. */
    @Transactional(readOnly = true)
    public PageResult<UserView> search(String keyword, String role, String status, int page, int size) {
        return PageResult.of(userRepository.findAll(
                UserSpecs.search(keyword, parseRole(role), parseStatus(status)),
                Pager.pageRequest(page, size, Sort.by(Sort.Order.desc("createdAt"), Sort.Order.desc("userId")))),
                u -> ViewMapper.toView(u, null));
    }

    @Transactional(readOnly = true)
    public UserView get(int userId) {
        return ViewMapper.toView(require(userId), null);
    }

    /** UC-ADM-02: tạo tài khoản với vai trò Admin chọn; trạng thái ACTIVE. */
    @Transactional
    public void create(UserCreateForm form) {
        if (userRepository.existsByUsernameIgnoreCase(form.getUsername())) {
            throw new ConflictException("Tên đăng nhập đã được sử dụng.", "username");
        }
        if (userRepository.existsByEmailIgnoreCase(form.getEmail())) {
            throw new ConflictException("Email đã được đăng ký.", "email");
        }
        User u = new User();
        u.setUsername(form.getUsername());
        u.setPasswordHash(passwordEncoder.encode(form.getPassword()));
        u.setFullName(form.getFullName());
        u.setEmail(form.getEmail());
        u.setRole(Role.valueOf(form.getRole()));
        u.setStatus(UserStatus.ACTIVE);
        try {
            userRepository.saveAndFlush(u);
        } catch (DataIntegrityViolationException e) {
            throw new ConflictException("Tên đăng nhập hoặc email đã được sử dụng.", "username");
        }
    }

    /** UC-ADM-03: sửa họ tên, email, vai trò, trạng thái (không đổi username). */
    @Transactional
    public void update(int userId, UserEditForm form, int actingUserId) {
        User u = requireModifiable(userId);
        if (userRepository.existsByEmailIgnoreCaseAndUserIdNot(form.getEmail(), userId)) {
            throw new ConflictException("Email đã được đăng ký bởi người khác.", "email");
        }
        Role newRole = Role.valueOf(form.getRole());
        UserStatus newStatus = UserStatus.valueOf(form.getStatus());
        boolean self = userId == actingUserId;
        if (self && newRole != u.getRole()) {
            throw new ConflictException("Bạn không thể tự đổi vai trò của chính mình.", "role");
        }
        if (self && newStatus != UserStatus.ACTIVE) {
            throw new ConflictException("Bạn không thể tự khóa tài khoản quản trị viên của chính mình!", "status");
        }
        boolean losesAdmin = u.getRole() == Role.ADMIN && u.isActive()
                && (newRole != Role.ADMIN || newStatus != UserStatus.ACTIVE);
        if (losesAdmin) {
            requireAnotherActiveAdmin();
        }
        u.setFullName(form.getFullName());
        u.setEmail(form.getEmail());
        u.setRole(newRole);
        u.setStatus(newStatus);
    }

    /**
     * UC-ADM-04: khóa ({@code SUSPENDED}) hoặc mở khóa ({@code ACTIVE}).
     *
     * @return tài khoản sau khi đổi
     * @throws ConflictException khi tự khóa chính mình, khóa Admin cuối cùng, hoặc tài khoản đã xóa mềm (INACTIVE)
     */
    @Transactional
    public UserView changeStatus(int userId, UserStatus target, int actingUserId) {
        if (target == UserStatus.INACTIVE) {
            throw new IllegalArgumentException("Trạng thái không hợp lệ (chỉ ACTIVE hoặc SUSPENDED).");
        }
        User u = requireModifiable(userId);
        if (target == UserStatus.SUSPENDED) {
            if (userId == actingUserId) {
                throw new ConflictException("Bạn không thể tự khóa tài khoản quản trị viên của chính mình!");
            }
            if (u.getRole() == Role.ADMIN && u.isActive()) {
                requireAnotherActiveAdmin();
            }
        }
        u.setStatus(target);
        return ViewMapper.toView(u, null);
    }

    /**
     * UC-ADM-04: xóa tài khoản. Chưa có dữ liệu liên quan → xóa cứng; ngược lại xóa mềm sang {@code INACTIVE} (BR-06).
     *
     * @return true nếu xóa cứng, false nếu xóa mềm
     */
    @Transactional
    public boolean delete(int userId, int actingUserId) {
        User u = requireModifiable(userId);
        if (userId == actingUserId) {
            throw new ConflictException("Bạn không thể tự xóa tài khoản của chính mình!");
        }
        if (u.getRole() == Role.ADMIN && u.isActive()) {
            requireAnotherActiveAdmin();
        }
        if (hasRelatedData(userId)) {
            u.setStatus(UserStatus.INACTIVE);
            return false;
        }
        userRepository.delete(u);
        return true;
    }

    /**
     * UC-ADM-04: khôi phục tài khoản đã xóa mềm ({@code INACTIVE → ACTIVE}). Dữ liệu liên quan vẫn còn nguyên
     * nên tài khoản dùng lại được ngay.
     *
     * @return tài khoản sau khi khôi phục
     * @throws ConflictException khi tài khoản chưa bị xóa mềm
     */
    @Transactional
    public UserView restore(int userId) {
        User u = require(userId);
        if (u.getStatus() != UserStatus.INACTIVE) {
            throw new ConflictException("Tài khoản này chưa bị xóa nên không cần khôi phục.");
        }
        u.setStatus(UserStatus.ACTIVE);
        return ViewMapper.toView(u, null);
    }

    /**
     * UC-ADM-05: đặt lại mật khẩu bằng chuỗi ngẫu nhiên 10 ký tự (chữ + số), băm BCrypt rồi lưu.
     *
     * @return mật khẩu mới ở dạng rõ — chỉ trả về MỘT lần cho Admin, không ghi log
     */
    @Transactional
    public String resetPassword(int userId) {
        User u = requireModifiable(userId);
        String password = randomPassword();
        u.setPasswordHash(passwordEncoder.encode(password));
        return password;
    }

    /** 10 ký tự, luôn có ít nhất một chữ cái và một chữ số (thỏa VAL-02), vị trí được xáo trộn. */
    static String randomPassword() {
        String all = PASSWORD_LETTERS + PASSWORD_DIGITS;
        char[] chars = new char[10];
        for (int i = 0; i < chars.length; i++) {
            chars[i] = all.charAt(RANDOM.nextInt(all.length()));
        }
        chars[0] = PASSWORD_LETTERS.charAt(RANDOM.nextInt(PASSWORD_LETTERS.length()));
        chars[1] = PASSWORD_DIGITS.charAt(RANDOM.nextInt(PASSWORD_DIGITS.length()));
        for (int i = chars.length - 1; i > 0; i--) { // Fisher-Yates
            int k = RANDOM.nextInt(i + 1);
            char t = chars[i];
            chars[i] = chars[k];
            chars[k] = t;
        }
        return new String(chars);
    }

    /** Dữ liệu liên quan khiến chỉ được xóa mềm: nội dung đã tạo, bài làm, phiên gia sư, cấu hình AI, học sinh phụ trách. */
    private boolean hasRelatedData(int userId) {
        return topicRepository.existsByTeacher_UserId(userId)
                || lessonRepository.existsByCreatedBy_UserId(userId)
                || questionRepository.existsByTeacher_UserId(userId)
                || materialRepository.existsByCreatedBy_UserId(userId)
                || submissionRepository.existsByStudent_UserId(userId)
                || tutorSessionRepository.existsByStudent_UserId(userId)
                || aiConfigRepository.existsByUpdatedBy_UserId(userId)
                || userRepository.existsByTeacherId(userId);
    }

    /** BR-02: hệ thống phải luôn còn ít nhất một Admin hoạt động ngoài tài khoản đang bị tác động. */
    private void requireAnotherActiveAdmin() {
        if (userRepository.countByRoleAndStatus(Role.ADMIN, UserStatus.ACTIVE) <= 1) {
            throw new ConflictException("Phải còn ít nhất một Admin hoạt động.");
        }
    }

    private User require(int userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new NotFoundException("Người dùng không tồn tại trong hệ thống."));
    }

    /** Người dùng chưa bị xóa mềm; tài khoản INACTIVE không được sửa / khóa / mở khóa / đặt lại mật khẩu. */
    private User requireModifiable(int userId) {
        User u = require(userId);
        if (u.getStatus() == UserStatus.INACTIVE) {
            throw new ConflictException("Tài khoản đã bị xóa, không thể thực hiện thao tác này. Hãy khôi phục tài khoản trước.");
        }
        return u;
    }

    private static Role parseRole(String role) {
        try {
            return role == null || role.isBlank() ? null : Role.valueOf(role);
        } catch (IllegalArgumentException e) {
            return null;
        }
    }

    private static UserStatus parseStatus(String status) {
        try {
            return status == null || status.isBlank() ? null : UserStatus.valueOf(status);
        } catch (IllegalArgumentException e) {
            return null;
        }
    }
}
