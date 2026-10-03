package com.edututor.service;

import com.edututor.ai.GeminiClient;
import com.edututor.ai.PromptBuilder;
import com.edututor.dto.AiConfigView;
import com.edututor.exception.AiServiceException;
import com.edututor.exception.ConfigValidationException;
import com.edututor.model.AiConfig;
import com.edututor.repository.AiConfigRepository;
import com.edututor.repository.UserRepository;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

/**
 * Nghiệp vụ cấu hình AI (UC-ADM-06/07). Giá trị đọc từ bảng AiConfigs qua cache TTL 60 giây; Admin lưu cấu hình
 * thì cache bị xóa nên có hiệu lực ngay, không cần khởi động lại. Tên model, khóa API, prompt không hard-code.
 */
@Service
public class AiConfigService {

    public static final String KEY_API_KEY = "GEMINI_API_KEY";
    public static final String KEY_DEFAULT_MODEL = "DEFAULT_MODEL";
    public static final String KEY_VISION_MODEL = "VISION_MODEL";
    public static final String KEY_TEMPERATURE = "TUTOR_TEMPERATURE";
    public static final String KEY_QUIZ_TEMPERATURE = "QUIZ_TEMPERATURE";
    public static final String KEY_GRADING_TEMPERATURE = "GRADING_TEMPERATURE";
    public static final String KEY_MAX_TOKENS = "MAX_OUTPUT_TOKENS";
    public static final String KEY_TUTOR_MIN_STEPS = "TUTOR_MIN_STEPS";
    public static final String KEY_TUTOR_MAX_STEPS = "TUTOR_MAX_STEPS";
    public static final String KEY_TIMEOUT = "AI_TIMEOUT_SECONDS";
    public static final String KEY_RATE_LIMIT_STUDENT = "AI_RATE_LIMIT_PER_HOUR";
    public static final String KEY_RATE_LIMIT_TEACHER = "AI_RATE_LIMIT_TEACHER_PER_HOUR";
    public static final String KEY_TUTOR_PROMPT = "TUTOR_SYSTEM_PROMPT";
    public static final String KEY_QUIZ_PROMPT = "QUIZ_GEN_PROMPT";
    public static final String KEY_GRADING_PROMPT = "GRADING_PROMPT";

    /** Các khóa được phép cập nhật từ giao diện Admin. */
    public static final Set<String> EDITABLE_KEYS = Set.of(KEY_API_KEY, KEY_DEFAULT_MODEL, KEY_VISION_MODEL,
            KEY_TEMPERATURE, KEY_QUIZ_TEMPERATURE, KEY_GRADING_TEMPERATURE, KEY_MAX_TOKENS,
            KEY_TUTOR_MIN_STEPS, KEY_TUTOR_MAX_STEPS, KEY_TIMEOUT, KEY_RATE_LIMIT_STUDENT, KEY_RATE_LIMIT_TEACHER,
            KEY_TUTOR_PROMPT, KEY_QUIZ_PROMPT, KEY_GRADING_PROMPT);

    private static final Set<String> TEMPERATURE_KEYS =
            Set.of(KEY_TEMPERATURE, KEY_QUIZ_TEMPERATURE, KEY_GRADING_TEMPERATURE);

    /** Khóa số nguyên → {min, max} (VAL-14, 15, 16 và hạn mức BR-13). */
    private static final Map<String, int[]> INT_RANGES = Map.of(
            KEY_MAX_TOKENS, new int[]{256, 8192},
            KEY_TUTOR_MIN_STEPS, new int[]{2, 10},
            KEY_TUTOR_MAX_STEPS, new int[]{2, 10},
            KEY_TIMEOUT, new int[]{5, 120},
            KEY_RATE_LIMIT_STUDENT, new int[]{1, 1000},
            KEY_RATE_LIMIT_TEACHER, new int[]{1, 5000});

    public static final int MAX_PROMPT_LENGTH = 8000;
    private static final Pattern MODEL_NAME = Pattern.compile("[a-z0-9.\\-]+");

    private final AiConfigRepository repository;
    private final UserRepository userRepository;
    private final GeminiClient geminiClient;
    private final long cacheTtlMillis;

    /** Bản chụp toàn bộ cấu hình (khóa → giá trị); thay nguyên khối nên đọc không cần khóa. */
    private volatile Map<String, String> cache;
    private volatile long cacheLoadedAt;

    public AiConfigService(AiConfigRepository repository, UserRepository userRepository, GeminiClient geminiClient,
                           @Value("${ai.config.cacheTtlSeconds:60}") long cacheTtlSeconds) {
        this.repository = repository;
        this.userRepository = userRepository;
        this.geminiClient = geminiClient;
        this.cacheTtlMillis = Math.max(0, cacheTtlSeconds) * 1000L;
    }

    /** Danh sách cấu hình để hiển thị; khóa API được che (AIza****abcd). */
    @Transactional(readOnly = true)
    public List<AiConfigView> getAllConfigs() {
        return repository.findAllByOrderByConfigIdAsc().stream().map(ViewMapper::toView).toList();
    }

    private String value(String key) {
        Map<String, String> snapshot = cache;
        if (snapshot == null || System.currentTimeMillis() - cacheLoadedAt >= cacheTtlMillis) {
            Map<String, String> fresh = new HashMap<>();
            for (AiConfig c : repository.findAll()) {
                fresh.put(c.getConfigKey(), c.getConfigValue());
            }
            snapshot = Map.copyOf(fresh);
            cache = snapshot;
            cacheLoadedAt = System.currentTimeMillis();
        }
        return snapshot.get(key);
    }

    /** Xóa cache để lần đọc kế tiếp lấy giá trị mới từ CSDL. */
    public void invalidateCache() {
        cache = null;
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

    /** Nhiệt độ của gia sư AI. */
    public double getTemperature() {
        return doubleValue(KEY_TEMPERATURE, 0.2);
    }

    public double getQuizTemperature() {
        return doubleValue(KEY_QUIZ_TEMPERATURE, 0.7);
    }

    public double getGradingTemperature() {
        return doubleValue(KEY_GRADING_TEMPERATURE, 0.1);
    }

    public int getMaxOutputTokens() {
        return intValue(KEY_MAX_TOKENS, 2048);
    }

    public int getTutorMinSteps() {
        return Math.min(intValue(KEY_TUTOR_MIN_STEPS, 3), getTutorMaxSteps());
    }

    public int getTutorMaxSteps() {
        return intValue(KEY_TUTOR_MAX_STEPS, 6);
    }

    public int getTimeoutSeconds() {
        return intValue(KEY_TIMEOUT, 30);
    }

    public int getStudentRateLimit() {
        return intValue(KEY_RATE_LIMIT_STUDENT, 60);
    }

    public int getTeacherRateLimit() {
        return intValue(KEY_RATE_LIMIT_TEACHER, 300);
    }

    /**
     * Prompt Admin cấu hình (TUTOR_SYSTEM_PROMPT / QUIZ_GEN_PROMPT / GRADING_PROMPT).
     *
     * @throws AiServiceException khi prompt chưa có trong CSDL (chưa chạy document/sql/07_ai_configs_full.sql)
     */
    public String getPrompt(String key) {
        String prompt = value(key);
        if (prompt == null || prompt.isBlank()) {
            throw new AiServiceException("Chưa cấu hình " + key + ". Vui lòng vào Quản trị > Cấu hình AI để cập nhật.");
        }
        return prompt;
    }

    private double doubleValue(String key, double fallback) {
        try {
            String v = value(key);
            double d = (v != null) ? Double.parseDouble(v.trim()) : fallback;
            return Math.min(1.0, Math.max(0.0, d));
        } catch (NumberFormatException e) {
            return fallback;
        }
    }

    private int intValue(String key, int fallback) {
        int[] range = INT_RANGES.get(key);
        try {
            String v = value(key);
            int n = (v != null) ? Integer.parseInt(v.trim()) : fallback;
            return Math.min(range[1], Math.max(range[0], n));
        } catch (NumberFormatException e) {
            return fallback;
        }
    }

    /**
     * UC-ADM-06: cập nhật các khóa cấu hình trong MỘT transaction. Kiểm tra toàn bộ giá trị trước; chỉ cần một giá
     * trị sai là không khóa nào được ghi. Cột UpdatedBy/UpdatedAt do dirty checking cập nhật.
     *
     * @param values khóa → giá trị mới (chỉ gồm các khóa người dùng gửi lên và muốn đổi)
     * @throws ConfigValidationException khi có giá trị sai, kèm lỗi theo từng khóa
     */
    @Transactional
    public void updateConfigs(Map<String, String> values, int updatedBy) {
        Map<String, String> clean = new LinkedHashMap<>();
        Map<String, String> errors = new LinkedHashMap<>();
        for (Map.Entry<String, String> e : values.entrySet()) {
            String key = e.getKey() == null ? "" : e.getKey().trim();
            if (!EDITABLE_KEYS.contains(key)) {
                errors.put(key, "Khóa cấu hình không hợp lệ: " + e.getKey());
                continue;
            }
            String v = e.getValue() == null ? "" : e.getValue().trim();
            String error = validate(key, v);
            if (error != null) {
                errors.put(key, error);
            } else {
                clean.put(key, v);
            }
        }
        // VAL-15: ràng buộc liên trường MIN ≤ MAX (giá trị không gửi lên thì lấy giá trị hiện có)
        if (!errors.containsKey(KEY_TUTOR_MIN_STEPS) && !errors.containsKey(KEY_TUTOR_MAX_STEPS)
                && (clean.containsKey(KEY_TUTOR_MIN_STEPS) || clean.containsKey(KEY_TUTOR_MAX_STEPS))) {
            int min = clean.containsKey(KEY_TUTOR_MIN_STEPS)
                    ? Integer.parseInt(clean.get(KEY_TUTOR_MIN_STEPS)) : intValue(KEY_TUTOR_MIN_STEPS, 3);
            int max = clean.containsKey(KEY_TUTOR_MAX_STEPS)
                    ? Integer.parseInt(clean.get(KEY_TUTOR_MAX_STEPS)) : getTutorMaxSteps();
            if (min > max) {
                errors.put(KEY_TUTOR_MIN_STEPS, "Số bước tối thiểu không được lớn hơn số bước tối đa.");
            }
        }
        if (!errors.isEmpty()) {
            throw new ConfigValidationException(errors);
        }
        for (Map.Entry<String, String> e : clean.entrySet()) {
            AiConfig cfg = repository.findByConfigKey(e.getKey()).orElseThrow(() -> new ConfigValidationException(
                    Map.of(e.getKey(), "Khóa " + e.getKey() + " chưa có trong CSDL. Hãy chạy document/sql/07_ai_configs_full.sql.")));
            cfg.setConfigValue(e.getValue());
            cfg.setUpdatedBy(userRepository.getReferenceById(updatedBy));
        }
        // Xóa cache SAU khi commit, để luồng khác không kịp nạp lại giá trị cũ trước khi dữ liệu mới được ghi
        if (TransactionSynchronizationManager.isSynchronizationActive()) {
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
                @Override
                public void afterCommit() {
                    invalidateCache();
                }
            });
        } else {
            invalidateCache();
        }
    }

    /** @return thông báo lỗi tiếng Việt, hoặc null nếu hợp lệ */
    private String validate(String key, String value) {
        // API key được phép để trống (chưa cấu hình); các khóa khác bắt buộc có giá trị
        if (KEY_API_KEY.equals(key)) {
            return null;
        }
        if (value.isEmpty()) {
            return "Giá trị của " + key + " không được để trống.";
        }
        if (KEY_DEFAULT_MODEL.equals(key) || KEY_VISION_MODEL.equals(key)) {
            return MODEL_NAME.matcher(value).matches() ? null
                    : key + " chỉ gồm chữ thường, số, dấu chấm và gạch ngang.";
        }
        if (TEMPERATURE_KEYS.contains(key)) {
            try {
                double t = Double.parseDouble(value);
                return (t >= 0.0 && t <= 1.0) ? null : key + " phải là số thực từ 0.0 đến 1.0.";
            } catch (NumberFormatException e) {
                return key + " phải là số thực từ 0.0 đến 1.0.";
            }
        }
        int[] range = INT_RANGES.get(key);
        if (range != null) {
            String msg = key + " phải là số nguyên từ " + range[0] + " đến " + range[1] + ".";
            try {
                int n = Integer.parseInt(value);
                return (n >= range[0] && n <= range[1]) ? null : msg;
            } catch (NumberFormatException e) {
                return msg;
            }
        }
        // Prompt (VAL-17)
        if (value.length() > MAX_PROMPT_LENGTH) {
            return key + " tối đa " + MAX_PROMPT_LENGTH + " ký tự.";
        }
        List<String> missing = PromptBuilder.missingPlaceholders(key, value);
        return missing.isEmpty() ? null : key + " thiếu placeholder bắt buộc: " + String.join(", ", missing) + ".";
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
