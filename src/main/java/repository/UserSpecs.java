package repository;

import model.Role;
import model.User;
import model.UserStatus;
import jakarta.persistence.criteria.Predicate;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import org.springframework.data.jpa.domain.Specification;

/** Specification tìm kiếm / lọc người dùng (UC-ADM-01). Giá trị luôn đi qua tham số, không nối chuỗi SQL. */
public final class UserSpecs {

    private static final char ESCAPE = '\\';

    private UserSpecs() {
    }

    /**
     * @param keyword khớp một phần với username, họ tên hoặc email (không phân biệt hoa thường); rỗng: không lọc
     * @param role    null: không lọc
     * @param status  null: không lọc
     */
    public static Specification<User> search(String keyword, Role role, UserStatus status) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            if (keyword != null && !keyword.isBlank()) {
                String pattern = "%" + escapeLike(keyword.trim().toLowerCase(Locale.ROOT)) + "%";
                predicates.add(cb.or(
                        cb.like(cb.lower(root.get("username")), pattern, ESCAPE),
                        cb.like(cb.lower(root.get("fullName")), pattern, ESCAPE),
                        cb.like(cb.lower(root.get("email")), pattern, ESCAPE)));
            }
            if (role != null) {
                predicates.add(cb.equal(root.get("role"), role));
            }
            if (status != null) {
                predicates.add(cb.equal(root.get("status"), status));
            }
            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }

    /** Thoát các ký tự đặc biệt của LIKE trong SQL Server: % _ [ và ký tự thoát. */
    static String escapeLike(String s) {
        return s.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_").replace("[", "\\[");
    }
}
