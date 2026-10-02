package com.edututor.service;

import com.edututor.dao.AiConfigDAO;
import com.edututor.model.AiConfig;
import java.util.List;

/**
 * Service xử lý nghiệp vụ Cấu hình AI (AiConfig).
 * Cung cấp API Key, Model name, Temperature cho các service AI.
 * Theo Spring MVC pattern: @Service
 */
public class AiConfigService {

    private final AiConfigDAO aiConfigDAO = new AiConfigDAO();

    // Tên các khóa cấu hình theo FRS
    public static final String KEY_API_KEY       = "GEMINI_API_KEY";
    public static final String KEY_DEFAULT_MODEL = "DEFAULT_MODEL";
    public static final String KEY_VISION_MODEL  = "VISION_MODEL";
    public static final String KEY_TEMPERATURE   = "TUTOR_TEMPERATURE";
    public static final String KEY_MAX_TOKENS    = "MAX_OUTPUT_TOKENS";

    /**
     * UC-ADM-01: Lấy toàn bộ danh sách cấu hình.
     */
    public List<AiConfig> getAllConfigs() {
        return aiConfigDAO.getAll();
    }

    /**
     * Lấy giá trị cấu hình theo key.
     *
     * @param configKey tên khóa cấu hình
     * @return giá trị dạng String, hoặc null nếu không tồn tại
     */
    public String getConfigValue(String configKey) {
        return aiConfigDAO.getValue(configKey);
    }

    /**
     * Lấy Gemini API Key từ DB.
     */
    public String getApiKey() {
        return aiConfigDAO.getValue(KEY_API_KEY);
    }

    /**
     * Lấy tên model mặc định (cho text generation).
     */
    public String getDefaultModel() {
        String model = aiConfigDAO.getValue(KEY_DEFAULT_MODEL);
        return (model != null && !model.isEmpty()) ? model : "gemini-1.5-flash";
    }

    /**
     * Lấy tên Vision Model (cho OCR / multimodal).
     */
    public String getVisionModel() {
        String model = aiConfigDAO.getValue(KEY_VISION_MODEL);
        return (model != null && !model.isEmpty()) ? model : "gemini-1.5-pro";
    }

    /**
     * Lấy Temperature của AI Tutor.
     */
    public double getTutorTemperature() {
        String val = aiConfigDAO.getValue(KEY_TEMPERATURE);
        try {
            return (val != null) ? Double.parseDouble(val) : 0.2;
        } catch (NumberFormatException e) {
            return 0.2;
        }
    }

    /**
     * UC-ADM-01: Cập nhật một khóa cấu hình.
     *
     * @param configKey   tên khóa
     * @param configValue giá trị mới
     * @param updatedBy   ID admin thực hiện cập nhật
     * @return true nếu cập nhật thành công
     * @throws IllegalArgumentException nếu value rỗng
     */
    public boolean updateConfig(String configKey, String configValue, int updatedBy) {
        if (configKey == null || configKey.trim().isEmpty()) {
            throw new IllegalArgumentException("Config key không được rỗng.");
        }
        if (configValue == null || configValue.trim().isEmpty()) {
            throw new IllegalArgumentException("Config value không được rỗng.");
        }
        return aiConfigDAO.update(configKey.trim(), configValue.trim(), updatedBy);
    }
}
