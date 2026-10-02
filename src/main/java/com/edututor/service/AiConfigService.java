package com.edututor.service;

import com.edututor.ai.GeminiClient;
import com.edututor.dto.AiConfigView;
import com.edututor.model.AiConfig;
import com.edututor.repository.AiConfigRepository;
import com.edututor.repository.UserRepository;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Nghiệp vụ cấu hình AI (UC-ADM-06/07). Mọi giá trị được đọc trực tiếp từ bảng AiConfigs ở mỗi lần gọi,
 * nên Admin đổi cấu hình là có hiệu lực ngay, không cần khởi động lại. Tên model, khóa API không hard-code.
 */
@Service
public class AiConfigService {

    public static final String KEY_API_KEY = "GEMINI_API_KEY";
    public static final String KEY_DEFAULT_MODEL = "DEFAULT_MODEL";
    public static final String KEY_VISION_MODEL = "VISION_MODEL";
    public static final String KEY_TEMPERATURE = "TUTOR_TEMPERATURE";
    public static final String KEY_MAX_TOKENS = "MAX_OUTPUT_TOKENS";

    /** Các khóa được phép cập nhật từ giao diện Admin. */
    public static final Set<String> EDITABLE_KEYS =
            Set.of(KEY_API_KEY, KEY_DEFAULT_MODEL, KEY_VISION_MODEL, KEY_TEMPERATURE, KEY_MAX_TOKENS);

    private static final Pattern MODEL_NAME = Pattern.compile("[a-z0-9.\\-]+");

    private final AiConfigRepository repository;
    private final UserRepository userRepository;
    private final GeminiClient geminiClient;

    public AiConfigService(AiConfigRepository repository, UserRepository userRepository, GeminiClient geminiClient) {
        this.repository = repository;
        this.userRepository = userRepository;
        this.geminiClient = geminiClient;
    }

    /** Danh sách cấu hình để hiển thị; khóa API được che (AIza****abcd). */
    @Transactional(readOnly = true)
    public List<AiConfigView> getAllConfigs() {
        return repository.findAllByOrderByConfigIdAsc().stream().map(ViewMapper::toView).toList();
    }

    private String value(String key) {
        return repository.findByConfigKey(key).map(AiConfig::getConfigValue).orElse(null);
    }

    public String getApiKey() {
        return value(KEY_API_KEY);
    }

    public String getDefaultModel() {
        String model = value(KEY_DEFAULT_MODEL);
        return model == null ? null : model.trim();
    }

    public String getVisionModel() {
        String model = value(KEY_VISION_MODEL);
        return model == null ? null : model.trim();
    }

    public double getTemperature() {
        try {
            String v = value(KEY_TEMPERATURE);
            double t = (v != null) ? Double.parseDouble(v.trim()) : 0.2;
            return Math.min(1.0, Math.max(0.0, t));
        } catch (NumberFormatException e) {
            return 0.2;
        }
    }

    public int getMaxOutputTokens() {
        try {
            String v = value(KEY_MAX_TOKENS);
            int n = (v != null) ? Integer.parseInt(v.trim()) : 2048;
            return n > 0 ? n : 2048;
        } catch (NumberFormatException e) {
            return 2048;
        }
    }

    /**
     * UC-ADM-06: cập nhật các khóa cấu hình trong MỘT transaction. Kiểm tra toàn bộ giá trị trước; chỉ cần một giá
     * trị sai là không khóa nào được ghi. Cột UpdatedBy/UpdatedAt do dirty checking cập nhật.
     *
     * @param values khóa → giá trị mới (chỉ gồm các khóa người dùng gửi lên và muốn đổi)
     * @throws IllegalArgumentException khi khóa không hợp lệ hoặc giá trị sai định dạng
     */
    @Transactional
    public void updateConfigs(Map<String, String> values, int updatedBy) {
        Map<String, String> clean = new LinkedHashMap<>();
        for (Map.Entry<String, String> e : values.entrySet()) {
            String key = e.getKey() == null ? "" : e.getKey().trim();
            if (!EDITABLE_KEYS.contains(key)) {
                throw new IllegalArgumentException("Khóa cấu hình không hợp lệ: " + e.getKey());
            }
            clean.put(key, validate(key, e.getValue() == null ? "" : e.getValue().trim()));
        }
        for (Map.Entry<String, String> e : clean.entrySet()) {
            AiConfig cfg = repository.findByConfigKey(e.getKey())
                    .orElseThrow(() -> new IllegalArgumentException("Khóa cấu hình không hợp lệ: " + e.getKey()));
            cfg.setConfigValue(e.getValue());
            cfg.setUpdatedBy(userRepository.getReferenceById(updatedBy));
        }
    }

    private String validate(String key, String value) {
        // API key được phép để trống (chưa cấu hình); các khóa khác bắt buộc có giá trị
        if (value.isEmpty() && !KEY_API_KEY.equals(key)) {
            throw new IllegalArgumentException("Giá trị của " + key + " không được để trống.");
        }
        switch (key) {
            case KEY_DEFAULT_MODEL, KEY_VISION_MODEL -> {
                if (!MODEL_NAME.matcher(value).matches()) {
                    throw new IllegalArgumentException(key + " chỉ gồm chữ thường, số, dấu chấm và gạch ngang.");
                }
            }
            case KEY_TEMPERATURE -> {
                try {
                    double t = Double.parseDouble(value);
                    if (t < 0.0 || t > 1.0) {
                        throw new NumberFormatException();
                    }
                } catch (NumberFormatException e) {
                    throw new IllegalArgumentException("TUTOR_TEMPERATURE phải là số thực từ 0.0 đến 1.0.");
                }
            }
            case KEY_MAX_TOKENS -> {
                try {
                    int n = Integer.parseInt(value);
                    if (n < 256 || n > 8192) {
                        throw new NumberFormatException();
                    }
                } catch (NumberFormatException e) {
                    throw new IllegalArgumentException("MAX_OUTPUT_TOKENS phải là số nguyên từ 256 đến 8192.");
                }
            }
            default -> {
                // KEY_API_KEY: không ràng buộc định dạng
            }
        }
        return value;
    }

    /**
     * UC-ADM-07: ping Gemini. Dùng giá trị truyền vào (nếu có) để thử trước khi lưu, ngược lại dùng cấu hình hiện hành.
     *
     * @return thông điệp thành công
     * @throws com.edututor.exception.AiServiceException nếu kết nối thất bại
     */
    public String testConnection(String apiKeyOverride, String modelOverride) {
        String apiKey = (apiKeyOverride != null && !apiKeyOverride.isBlank()) ? apiKeyOverride.trim() : getApiKey();
        String model = (modelOverride != null && !modelOverride.isBlank()) ? modelOverride.trim() : getDefaultModel();
        if (apiKey == null || apiKey.isBlank()) {
            throw new IllegalArgumentException("API Key chưa được cấu hình. Vui lòng nhập GEMINI_API_KEY.");
        }
        geminiClient.ping(apiKey, model);
        return "Kết nối Gemini API thành công! Model: " + model;
    }
}
