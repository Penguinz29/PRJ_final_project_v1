package repository;

import model.AiConfig;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

/** Bảng AiConfigs: cấu hình AI đọc trực tiếp từ CSDL, Admin đổi là có hiệu lực ngay. */
public interface AiConfigRepository extends JpaRepository<AiConfig, Integer> {

    @EntityGraph(attributePaths = "updatedBy")
    List<AiConfig> findAllByOrderByConfigIdAsc();

    Optional<AiConfig> findByConfigKey(String configKey);

    boolean existsByUpdatedBy_UserId(Integer userId);
}
