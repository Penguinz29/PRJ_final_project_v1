package com.edututor.repository;

import com.edututor.model.Role;
import com.edututor.model.User;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

/** Truy cập bảng Users. Mọi giá trị đi qua tham số (PreparedStatement) do Hibernate sinh ra. */
public interface UserRepository extends JpaRepository<User, Integer> {

    Optional<User> findByUsername(String username);

    boolean existsByUsernameIgnoreCase(String username);

    boolean existsByEmailIgnoreCase(String email);

    Page<User> findByRole(Role role, Pageable pageable);

    long countByRole(Role role);

    /** Truy vấn nhẹ theo khóa chính cho AuthInterceptor (BR-01): null nếu tài khoản không còn tồn tại. */
    @Query("select u.active from User u where u.userId = :id")
    Boolean findActiveById(@Param("id") Integer id);
}
