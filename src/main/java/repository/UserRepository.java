package repository;

import model.Role;
import model.User;
import model.UserStatus;
import java.util.List;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

/** Truy cập bảng Users. Mọi giá trị đi qua tham số (PreparedStatement) do Hibernate sinh ra. */
public interface UserRepository extends JpaRepository<User, Integer>, JpaSpecificationExecutor<User> {

    Optional<User> findByUsername(String username);

    boolean existsByUsernameIgnoreCase(String username);

    boolean existsByEmailIgnoreCase(String email);

    boolean existsByEmailIgnoreCaseAndUserIdNot(String email, Integer userId);

    Page<User> findByRole(Role role, Pageable pageable);

    long countByRole(Role role);

    long countByRoleAndStatus(Role role, UserStatus status);

    /** UC-ADM-08: người dùng theo vai trò × trạng thái trong MỘT truy vấn GROUP BY. */
    @Query("select u.role as role, u.status as status, count(u) as total from User u group by u.role, u.status")
    List<RoleStatusCount> countByRoleAndStatusGrouped();

    /** Có học sinh nào đang được gán cho giáo viên này không (dữ liệu liên quan khi xóa tài khoản). */
    boolean existsByTeacherId(Integer teacherId);

    /** Truy vấn nhẹ theo khóa chính cho AuthInterceptor (BR-01): null nếu tài khoản không còn tồn tại. */
    @Query("select case when u.status = model.UserStatus.ACTIVE then true else false end "
            + "from User u where u.userId = :id")
    Boolean findActiveById(@Param("id") Integer id);
}
