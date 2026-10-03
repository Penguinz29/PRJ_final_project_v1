-- File: src/conf/03_ai_configs.sql
-- Bảng cấu hình AI cho Admin (FR-ADM-01/02)
USE MathTutorDB;
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='AiConfigs' AND xtype='U')
BEGIN
    CREATE TABLE AiConfigs (
        ConfigId INT IDENTITY(1,1) PRIMARY KEY,
        ConfigKey VARCHAR(50) NOT NULL UNIQUE,
        ConfigValue NVARCHAR(500) NOT NULL,
        [Description] NVARCHAR(255),
        UpdatedBy INT NULL,
        UpdatedAt DATETIME DEFAULT GETDATE(),
        CONSTRAINT FK_AiConfig_User FOREIGN KEY (UpdatedBy) REFERENCES Users(UserId)
    );

    -- Seed dữ liệu mặc định
    INSERT INTO AiConfigs (ConfigKey, ConfigValue, [Description]) VALUES
    ('GEMINI_API_KEY', '', N'API Key từ Google AI Studio'),
    ('DEFAULT_MODEL', 'gemini-3.5-flash', N'Model mặc định cho sinh đề & gia sư AI (tên model thay đổi theo thời gian: Admin sửa trên giao diện)'),
    ('VISION_MODEL', 'gemini-3.5-flash', N'Model xử lý hình ảnh OCR (phải hỗ trợ ảnh)'),
    ('TUTOR_TEMPERATURE', '0.2', N'Độ sáng tạo phản hồi AI (0.0 - 1.0)'),
    ('MAX_OUTPUT_TOKENS', '2048', N'Giới hạn token đầu ra');
END
GO
