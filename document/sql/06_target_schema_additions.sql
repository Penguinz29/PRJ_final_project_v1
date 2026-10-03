-- File: document/sql/06_target_schema_additions.sql
-- Bổ sung cấu trúc dữ liệu theo SRS 6.1/6.2 và FRS 1.7 (kiến trúc chuẩn 10 bảng / 10 Entity).
-- Chạy sau 01..05. Script idempotent (chạy lại nhiều lần không lỗi) và KHÔNG làm đổi hành vi của mã hiện có:
-- mọi cột mới đều NOT NULL DEFAULT hoặc NULL nên các câu INSERT hiện tại vẫn hợp lệ.
--
-- Quy ước tên: tài liệu dùng snake_case (questions.is_active); CSDL hiện tại dùng PascalCase (Questions.IsActive).
-- Bảng ánh xạ đầy đủ ở FRS mục 1.7.
USE MathTutorDB;
GO

-- 1) Xóa mềm: Questions.IsActive (BR-05), Lessons.IsActive, Topics.IsActive
IF COL_LENGTH('Questions', 'IsActive') IS NULL ALTER TABLE Questions ADD IsActive BIT NOT NULL CONSTRAINT DF_Questions_IsActive DEFAULT 1;
IF COL_LENGTH('Lessons',   'IsActive') IS NULL ALTER TABLE Lessons   ADD IsActive BIT NOT NULL CONSTRAINT DF_Lessons_IsActive   DEFAULT 1;
IF COL_LENGTH('Topics',    'IsActive') IS NULL ALTER TABLE Topics    ADD IsActive BIT NOT NULL CONSTRAINT DF_Topics_IsActive    DEFAULT 1;
GO

-- 2) Thứ tự hiển thị: Topics.OrderIndex (Lessons.DisplayOrder đã có từ 01_schema.sql, tương ứng lessons.order_index)
IF COL_LENGTH('Topics', 'OrderIndex') IS NULL ALTER TABLE Topics ADD OrderIndex INT NOT NULL CONSTRAINT DF_Topics_OrderIndex DEFAULT 1;
GO

-- 3) Submissions: trạng thái chấm, nhận xét AI/giáo viên, người duyệt
--    Status: GRADED (trắc nghiệm tự chấm) | AI_GRADED (tự luận, chờ giáo viên) | REVIEWED (giáo viên đã duyệt)
IF COL_LENGTH('Submissions', 'Status') IS NULL
    ALTER TABLE Submissions ADD [Status] VARCHAR(20) NOT NULL CONSTRAINT DF_Submissions_Status DEFAULT 'GRADED';
IF COL_LENGTH('Submissions', 'SuggestedCorrection') IS NULL ALTER TABLE Submissions ADD SuggestedCorrection NVARCHAR(MAX) NULL;
IF COL_LENGTH('Submissions', 'ReviewedBy')  IS NULL ALTER TABLE Submissions ADD ReviewedBy INT NULL;
IF COL_LENGTH('Submissions', 'ReviewedAt')  IS NULL ALTER TABLE Submissions ADD ReviewedAt DATETIME NULL;
IF COL_LENGTH('Submissions', 'UpdatedAt')   IS NULL ALTER TABLE Submissions ADD UpdatedAt DATETIME NULL;
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Submissions_Status')
    ALTER TABLE Submissions ADD CONSTRAINT CK_Submissions_Status CHECK ([Status] IN ('GRADED', 'AI_GRADED', 'REVIEWED'));
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Submission_Reviewer')
    ALTER TABLE Submissions ADD CONSTRAINT FK_Submission_Reviewer FOREIGN KEY (ReviewedBy) REFERENCES Users(UserId);
GO
-- Đồng bộ dữ liệu cũ: tự luận chưa duyệt = AI_GRADED, đã duyệt = REVIEWED, trắc nghiệm = GRADED
UPDATE Submissions SET [Status] = CASE WHEN QuestionType = 'ESSAY' AND IsReviewed = 1 THEN 'REVIEWED'
                                       WHEN QuestionType = 'ESSAY' THEN 'AI_GRADED' ELSE 'GRADED' END;
GO

-- 4) TutorSessions: máy trạng thái "chờ học sinh nhập số liệu" (needsStudentInput) + cập nhật lần cuối
IF COL_LENGTH('TutorSessions', 'AwaitingInput') IS NULL
    ALTER TABLE TutorSessions ADD AwaitingInput BIT NOT NULL CONSTRAINT DF_TutorSessions_AwaitingInput DEFAULT 0;
IF COL_LENGTH('TutorSessions', 'InputHint') IS NULL ALTER TABLE TutorSessions ADD InputHint NVARCHAR(255) NULL;
IF COL_LENGTH('TutorSessions', 'UpdatedAt') IS NULL ALTER TABLE TutorSessions ADD UpdatedAt DATETIME NULL;
GO

-- 5) UpdatedAt cho các bảng nghiệp vụ còn lại (CreatedAt đã có sẵn)
IF COL_LENGTH('Users',           'UpdatedAt') IS NULL ALTER TABLE Users           ADD UpdatedAt DATETIME NULL;
IF COL_LENGTH('Topics',          'UpdatedAt') IS NULL ALTER TABLE Topics          ADD UpdatedAt DATETIME NULL;
IF COL_LENGTH('Lessons',         'UpdatedAt') IS NULL ALTER TABLE Lessons         ADD UpdatedAt DATETIME NULL;
IF COL_LENGTH('Questions',       'UpdatedAt') IS NULL ALTER TABLE Questions       ADD UpdatedAt DATETIME NULL;
IF COL_LENGTH('QuestionOptions', 'CreatedAt') IS NULL ALTER TABLE QuestionOptions ADD CreatedAt DATETIME NOT NULL CONSTRAINT DF_QuestionOptions_CreatedAt DEFAULT GETDATE();
IF COL_LENGTH('QuestionOptions', 'UpdatedAt') IS NULL ALTER TABLE QuestionOptions ADD UpdatedAt DATETIME NULL;
IF COL_LENGTH('AiConfigs',       'CreatedAt') IS NULL ALTER TABLE AiConfigs       ADD CreatedAt DATETIME NOT NULL CONSTRAINT DF_AiConfigs_CreatedAt DEFAULT GETDATE();
IF COL_LENGTH('TutorMessages',   'UpdatedAt') IS NULL ALTER TABLE TutorMessages   ADD UpdatedAt DATETIME NULL;
GO

-- 6) Bảng thứ 10: LessonMaterials (bài giảng: VIDEO | YOUTUBE | LINK | TEXT) - FR-TEA-03 / FR-STU-02
IF OBJECT_ID('LessonMaterials', 'U') IS NULL
BEGIN
    CREATE TABLE LessonMaterials (
        MaterialId   INT IDENTITY(1,1) PRIMARY KEY,
        LessonId     INT NOT NULL,
        MaterialType VARCHAR(10) NOT NULL CHECK (MaterialType IN ('VIDEO', 'YOUTUBE', 'LINK', 'TEXT')),
        Title        NVARCHAR(200) NOT NULL,
        Url          VARCHAR(500) NULL,
        ContentText  NVARCHAR(MAX) NULL,
        OrderIndex   INT NOT NULL DEFAULT 1,
        CreatedBy    INT NOT NULL,
        CreatedAt    DATETIME NOT NULL DEFAULT GETDATE(),
        UpdatedAt    DATETIME NULL,
        CONSTRAINT FK_Material_Lesson FOREIGN KEY (LessonId)  REFERENCES Lessons(LessonId) ON DELETE CASCADE,
        CONSTRAINT FK_Material_User   FOREIGN KEY (CreatedBy) REFERENCES Users(UserId),
        -- TEXT bắt buộc có ContentText; các loại còn lại bắt buộc có Url
        CONSTRAINT CK_Material_Content CHECK (
            (MaterialType = 'TEXT' AND ContentText IS NOT NULL) OR (MaterialType <> 'TEXT' AND Url IS NOT NULL))
    );
    CREATE INDEX IX_LessonMaterials_Lesson ON LessonMaterials(LessonId, OrderIndex);
END
GO

-- 7) Chỉ mục phục vụ truy vấn danh sách / đếm có điều kiện IsActive
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Questions_Lesson_Active')
    CREATE INDEX IX_Questions_Lesson_Active ON Questions(LessonId, IsActive);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Submissions_Student')
    CREATE INDEX IX_Submissions_Student ON Submissions(StudentId, SubmittedAt DESC);
GO

-- 8) Hợp nhất "video hướng dẫn" cũ (Lessons.YoutubeUrl) vào bài giảng (LessonMaterials)
--    Mỗi bài học có YoutubeUrl hợp lệ được chuyển thành 1 bài giảng (link YouTube -> YOUTUBE, link khác -> LINK),
--    người tạo = giáo viên sở hữu chủ đề. Sau khi chuyển, YoutubeUrl được xóa trắng (cột giữ lại, ứng dụng không còn dùng).
--    Idempotent: chạy lại không tạo trùng.
INSERT INTO LessonMaterials (LessonId, MaterialType, Title, Url, OrderIndex, CreatedBy)
SELECT l.LessonId,
       CASE WHEN l.YoutubeUrl LIKE '%youtube.com/%' OR l.YoutubeUrl LIKE '%youtu.be/%' THEN 'YOUTUBE' ELSE 'LINK' END,
       N'Video bài giảng', LTRIM(RTRIM(l.YoutubeUrl)), 1, t.TeacherId
FROM Lessons l
JOIN Topics t ON t.TopicId = l.TopicId
WHERE l.YoutubeUrl IS NOT NULL
  AND (LTRIM(RTRIM(l.YoutubeUrl)) LIKE 'http://%' OR LTRIM(RTRIM(l.YoutubeUrl)) LIKE 'https://%')
  AND NOT EXISTS (SELECT 1 FROM LessonMaterials m WHERE m.LessonId = l.LessonId AND m.Url = LTRIM(RTRIM(l.YoutubeUrl)));
GO
UPDATE l SET YoutubeUrl = NULL
FROM Lessons l
WHERE l.YoutubeUrl IS NOT NULL
  AND EXISTS (SELECT 1 FROM LessonMaterials m WHERE m.LessonId = l.LessonId AND m.Url = LTRIM(RTRIM(l.YoutubeUrl)));
GO

-- 9) Trạng thái tài khoản: Users.Status ∈ {ACTIVE, SUSPENDED, INACTIVE} (FR-ADM-04, BR-01, BR-06)
--    ACTIVE = hoạt động • SUSPENDED = khóa tạm (mở khóa được) • INACTIVE = xóa mềm (không mở khóa được).
--    Cột IsActive cũ được ứng dụng giữ đồng bộ (IsActive = 1 khi và chỉ khi Status = 'ACTIVE').
IF COL_LENGTH('Users', 'Status') IS NULL
    ALTER TABLE Users ADD [Status] VARCHAR(20) NOT NULL CONSTRAINT DF_Users_Status DEFAULT 'ACTIVE';
GO
UPDATE Users SET [Status] = 'SUSPENDED' WHERE IsActive = 0 AND [Status] = 'ACTIVE';
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Users_Status')
    ALTER TABLE Users ADD CONSTRAINT CK_Users_Status CHECK ([Status] IN ('ACTIVE', 'SUSPENDED', 'INACTIVE'));
GO
