package com.mathtutor.model;

import java.io.Serializable;
import java.util.Date;

public class AiConfig implements Serializable {
    private int configId;
    private String configKey;
    private String configValue;
    private String description;
    private Integer updatedBy;
    private Date updatedAt;

    // Mở rộng cho UI
    private String updatedByName;

    public AiConfig() {}

    public int getConfigId() { return configId; }
    public void setConfigId(int configId) { this.configId = configId; }

    public String getConfigKey() { return configKey; }
    public void setConfigKey(String configKey) { this.configKey = configKey; }

    public String getConfigValue() { return configValue; }
    public void setConfigValue(String configValue) { this.configValue = configValue; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Integer getUpdatedBy() { return updatedBy; }
    public void setUpdatedBy(Integer updatedBy) { this.updatedBy = updatedBy; }

    public Date getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Date updatedAt) { this.updatedAt = updatedAt; }

    public String getUpdatedByName() { return updatedByName; }
    public void setUpdatedByName(String updatedByName) { this.updatedByName = updatedByName; }
}
