-- =====================================================================================================================
-- File: document/sql/01_schema.sql — EduTutor Math 9: tạo CSDL, 10 bảng và toàn bộ ràng buộc (cấu trúc cuối cùng)
-- Chạy TRƯỚC 02_data.sql (toàn bộ dữ liệu). CẢNH BÁO: script XÓA CSDL MathTutorDB cũ (nếu có) rồi tạo lại từ đầu.
-- CSDL tạo theo cấu trúc cũ cũng tạo lại bằng script này (dữ liệu cũ bị xóa, thay bằng dữ liệu của 02_data.sql).
--
-- Quy ước: tài liệu SRS / FRS dùng snake_case (questions.is_active), CSDL dùng PascalCase (Questions.IsActive).
-- 6 bảng lõi: Users, Topics, Lessons, Questions, Submissions, TutorSessions
-- 4 bảng phụ do chuẩn hóa: LessonMaterials, QuestionOptions, TutorMessages (thuộc tính đa trị 1-N), AiConfigs (cấu hình)
-- Mỗi bảng ánh xạ một Entity JPA; Hibernate chạy với hbm2ddl.auto = none nên script này là nguồn sự thật về cấu trúc.
-- =====================================================================================================================
USE master;
GO

IF DB_ID(N'MathTutorDB') IS NOT NULL
BEGIN
    ALTER DATABASE MathTutorDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE MathTutorDB;
END
GO

CREATE DATABASE MathTutorDB;
GO

USE MathTutorDB;
GO

-- ---------------------------------------------------------------------------------------------------------------------
-- 1. Users — tài khoản 3 vai trò (BR-01, BR-02, BR-06)
--    Status: ACTIVE (hoạt động) | SUSPENDED (khóa tạm, mở khóa được) | INACTIVE (xóa mềm, Admin khôi phục được)
--    IsActive: cột cũ, ứng dụng luôn giữ đồng bộ (IsActive = 1 khi và chỉ khi Status = 'ACTIVE')
--    TeacherId: giáo viên phụ trách (chỉ có ý nghĩa với STUDENT)
-- ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE Users (
    UserId        INT IDENTITY(1,1) NOT NULL,
    Username      VARCHAR(50)   NOT NULL,
    PasswordHash  VARCHAR(64)   NOT NULL,                  -- BCrypt (60 ký tự); chỉ chấp nhận BCrypt
    FullName      NVARCHAR(100) NOT NULL,
    Email         VARCHAR(100)  NULL,
    [Role]        VARCHAR(20)   NOT NULL,
    [Status]      VARCHAR(20)   NOT NULL CONSTRAINT DF_Users_Status DEFAULT 'ACTIVE',
    IsActive      BIT           NULL     CONSTRAINT DF_Users_IsActive DEFAULT 1,
    TeacherId     INT           NULL,
    CreatedAt     DATETIME      NULL     CONSTRAINT DF_Users_CreatedAt DEFAULT GETDATE(),
    UpdatedAt     DATETIME      NULL,
    CONSTRAINT PK_Users PRIMARY KEY (UserId),
    CONSTRAINT UQ_Users_Username UNIQUE (Username),
    CONSTRAINT UQ_Users_Email UNIQUE (Email),
    CONSTRAINT CK_Users_Role CHECK ([Role] IN ('ADMIN', 'TEACHER', 'STUDENT')),
    CONSTRAINT CK_Users_Status CHECK ([Status] IN ('ACTIVE', 'SUSPENDED', 'INACTIVE')),
    CONSTRAINT FK_Student_Teacher FOREIGN KEY (TeacherId) REFERENCES Users(UserId)
);
GO

-- ---------------------------------------------------------------------------------------------------------------------
-- 2. Topics — chủ đề / chuyên đề (cấp trên của bài học). IsActive = 0: xóa mềm (BR-05, chỉ ẩn ở trang quản lý)
-- ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE Topics (
    TopicId       INT IDENTITY(1,1) NOT NULL,
    TopicName     NVARCHAR(255) NOT NULL,
    [Description] NVARCHAR(MAX) NULL,
    TeacherId     INT           NOT NULL,                  -- người tạo (BR-03)
    OrderIndex    INT           NOT NULL CONSTRAINT DF_Topics_OrderIndex DEFAULT 1,
    IsActive      BIT           NOT NULL CONSTRAINT DF_Topics_IsActive DEFAULT 1,
    CreatedAt     DATETIME      NULL     CONSTRAINT DF_Topics_CreatedAt DEFAULT GETDATE(),
    UpdatedAt     DATETIME      NULL,
    CONSTRAINT PK_Topics PRIMARY KEY (TopicId),
    CONSTRAINT FK_Topic_Teacher FOREIGN KEY (TeacherId) REFERENCES Users(UserId)
);
GO

-- ---------------------------------------------------------------------------------------------------------------------
-- 3. Lessons — bài học. DisplayOrder ≙ lessons.order_index; CreatedBy: người tạo (BR-03)
-- ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE Lessons (
    LessonId      INT IDENTITY(1,1) NOT NULL,
    TopicId       INT           NOT NULL,
    Title         NVARCHAR(255) NOT NULL,
    Summary       NVARCHAR(500) NULL,
    Content       NVARCHAR(MAX) NULL,                      -- lý thuyết (LaTeX)
    DisplayOrder  INT           NULL     CONSTRAINT DF_Lessons_DisplayOrder DEFAULT 0,
    IsActive      BIT           NOT NULL CONSTRAINT DF_Lessons_IsActive DEFAULT 1,
    CreatedBy     INT           NOT NULL,
    CreatedAt     DATETIME      NULL     CONSTRAINT DF_Lessons_CreatedAt DEFAULT GETDATE(),
    UpdatedAt     DATETIME      NULL,
    CONSTRAINT PK_Lessons PRIMARY KEY (LessonId),
    CONSTRAINT FK_Lesson_Topic FOREIGN KEY (TopicId) REFERENCES Topics(TopicId) ON DELETE CASCADE,
    CONSTRAINT FK_Lesson_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES Users(UserId)
);
GO

-- ---------------------------------------------------------------------------------------------------------------------
-- 4. LessonMaterials — bài giảng: VIDEO | YOUTUBE | LINK dùng Url; TEXT dùng ContentText (FR-TEA-03, VAL-08)
-- ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE LessonMaterials (
    MaterialId    INT IDENTITY(1,1) NOT NULL,
    LessonId      INT           NOT NULL,
    MaterialType  VARCHAR(10)   NOT NULL,
    Title         NVARCHAR(200) NOT NULL,
    Url           VARCHAR(500)  NULL,
    ContentText   NVARCHAR(MAX) NULL,
    OrderIndex    INT           NOT NULL CONSTRAINT DF_LessonMaterials_OrderIndex DEFAULT 1,
    CreatedBy     INT           NOT NULL,
    CreatedAt     DATETIME      NOT NULL CONSTRAINT DF_LessonMaterials_CreatedAt DEFAULT GETDATE(),
    UpdatedAt     DATETIME      NULL,
    CONSTRAINT PK_LessonMaterials PRIMARY KEY (MaterialId),
    CONSTRAINT CK_Material_Type CHECK (MaterialType IN ('VIDEO', 'YOUTUBE', 'LINK', 'TEXT')),
    -- TEXT bắt buộc có ContentText; các loại còn lại bắt buộc có Url
    CONSTRAINT CK_Material_Content CHECK (
        (MaterialType = 'TEXT' AND ContentText IS NOT NULL) OR (MaterialType <> 'TEXT' AND Url IS NOT NULL)),
    CONSTRAINT FK_Material_Lesson FOREIGN KEY (LessonId) REFERENCES Lessons(LessonId) ON DELETE CASCADE,
    CONSTRAINT FK_Material_User FOREIGN KEY (CreatedBy) REFERENCES Users(UserId)
);
GO
CREATE INDEX IX_LessonMaterials_Lesson ON LessonMaterials(LessonId, OrderIndex);
GO

-- ---------------------------------------------------------------------------------------------------------------------
-- 5. Questions — ngân hàng câu hỏi. Level: 1 Dễ, 2 Trung bình, 3 Khó. IsActive = 0: xóa mềm (BR-05)
-- ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE Questions (
    QuestionId       INT IDENTITY(1,1) NOT NULL,
    LessonId         INT           NOT NULL,
    QuestionType     VARCHAR(10)   NOT NULL,
    Content          NVARCHAR(MAX) NOT NULL,               -- nội dung đề (LaTeX)
    ExplanationLatex NVARCHAR(MAX) NULL,                   -- lời giải: chỉ gửi học sinh SAU khi nộp (BR-11)
    [Level]          INT           NOT NULL CONSTRAINT DF_Questions_Level DEFAULT 1,
    IsAiGenerated    BIT           NULL     CONSTRAINT DF_Questions_IsAiGenerated DEFAULT 0,
    IsActive         BIT           NOT NULL CONSTRAINT DF_Questions_IsActive DEFAULT 1,
    TeacherId        INT           NOT NULL,               -- người tạo (BR-03)
    CreatedAt        DATETIME      NULL     CONSTRAINT DF_Questions_CreatedAt DEFAULT GETDATE(),
    UpdatedAt        DATETIME      NULL,
    CONSTRAINT PK_Questions PRIMARY KEY (QuestionId),
    CONSTRAINT CK_Questions_Type CHECK (QuestionType IN ('MCQ', 'ESSAY')),
    CONSTRAINT CK_Questions_Level CHECK ([Level] IN (1, 2, 3)),
    CONSTRAINT FK_Question_Lesson FOREIGN KEY (LessonId) REFERENCES Lessons(LessonId) ON DELETE CASCADE,
    CONSTRAINT FK_Question_Teacher FOREIGN KEY (TeacherId) REFERENCES Users(UserId)
);
GO
CREATE INDEX IX_Questions_Lesson_Active ON Questions(LessonId, IsActive);
GO

-- ---------------------------------------------------------------------------------------------------------------------
-- 6. QuestionOptions — phương án của câu trắc nghiệm (BR-04: đúng 4 phương án A-D, 1 đáp án đúng; kiểm tra ở Service)
-- ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE QuestionOptions (
    OptionId      INT IDENTITY(1,1) NOT NULL,
    QuestionId    INT           NOT NULL,
    OptionLetter  CHAR(1)       NOT NULL,
    Content       NVARCHAR(MAX) NOT NULL,
    IsCorrect     BIT           NULL     CONSTRAINT DF_QuestionOptions_IsCorrect DEFAULT 0,
    CreatedAt     DATETIME      NOT NULL CONSTRAINT DF_QuestionOptions_CreatedAt DEFAULT GETDATE(),
    UpdatedAt     DATETIME      NULL,
    CONSTRAINT PK_QuestionOptions PRIMARY KEY (OptionId),
    CONSTRAINT UQ_Question_OptionLetter UNIQUE (QuestionId, OptionLetter),
    CONSTRAINT CK_QuestionOptions_Letter CHECK (OptionLetter IN ('A', 'B', 'C', 'D', 'E', 'F')),
    CONSTRAINT FK_Option_Question FOREIGN KEY (QuestionId) REFERENCES Questions(QuestionId) ON DELETE CASCADE
);
GO

-- ---------------------------------------------------------------------------------------------------------------------
-- 7. Submissions — bài làm trắc nghiệm (MCQ) và tự luận (ESSAY), điểm thang 10 (BR-07, BR-09)
--    Status: GRADED (trắc nghiệm tự chấm) | AI_GRADED (tự luận AI đã chấm, chờ duyệt) | REVIEWED (giáo viên đã duyệt)
--    AiScore: điểm AI đề xuất, không bao giờ bị ghi đè; FinalScore: điểm chính thức (trắc nghiệm 10 / 0)
--    IsReviewed: cột cũ, ứng dụng giữ đồng bộ (IsReviewed = 0 khi và chỉ khi Status = 'AI_GRADED')
-- ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE Submissions (
    SubmissionId        INT IDENTITY(1,1) NOT NULL,
    StudentId           INT           NOT NULL,
    LessonId            INT           NULL,
    QuestionId          INT           NOT NULL,
    QuestionType        VARCHAR(10)   NOT NULL,
    StudentAnswer       NVARCHAR(MAX) NULL,                -- MCQ: chữ cái đã chọn; ESSAY: nội dung nhận diện / gõ tay
    EssayImagePath      VARCHAR(255)  NULL,                -- /uploads/essays/{studentId}/{uuid}.{ext}
    IsCorrect           BIT           NULL,
    AiScore             DECIMAL(4,2)  NULL,
    FinalScore          DECIMAL(4,2)  NULL,
    AiFeedback          NVARCHAR(MAX) NULL,
    SuggestedCorrection NVARCHAR(MAX) NULL,
    TeacherFeedback     NVARCHAR(MAX) NULL,                -- ≙ teacher_comment
    [Status]            VARCHAR(20)   NOT NULL CONSTRAINT DF_Submissions_Status DEFAULT 'GRADED',
    IsReviewed          BIT           NULL     CONSTRAINT DF_Submissions_IsReviewed DEFAULT 0,
    ReviewedBy          INT           NULL,
    ReviewedAt          DATETIME      NULL,
    SubmittedAt         DATETIME      NULL     CONSTRAINT DF_Submissions_SubmittedAt DEFAULT GETDATE(),
    UpdatedAt           DATETIME      NULL,
    CONSTRAINT PK_Submissions PRIMARY KEY (SubmissionId),
    CONSTRAINT CK_Submissions_QuestionType CHECK (QuestionType IN ('MCQ', 'ESSAY')),
    CONSTRAINT CK_Submissions_Status CHECK ([Status] IN ('GRADED', 'AI_GRADED', 'REVIEWED')),
    CONSTRAINT CK_Submissions_AiScore CHECK (AiScore IS NULL OR (AiScore >= 0 AND AiScore <= 10)),
    CONSTRAINT CK_Submissions_FinalScore CHECK (FinalScore IS NULL OR (FinalScore >= 0 AND FinalScore <= 10)),
    CONSTRAINT FK_Submission_Student FOREIGN KEY (StudentId) REFERENCES Users(UserId),
    CONSTRAINT FK_Submission_Lesson FOREIGN KEY (LessonId) REFERENCES Lessons(LessonId),
    CONSTRAINT FK_Submission_Question FOREIGN KEY (QuestionId) REFERENCES Questions(QuestionId),
    CONSTRAINT FK_Submission_Reviewer FOREIGN KEY (ReviewedBy) REFERENCES Users(UserId)
);
GO
CREATE INDEX IX_Submissions_Student ON Submissions(StudentId, SubmittedAt DESC);
GO

-- ---------------------------------------------------------------------------------------------------------------------
-- 8. AiConfigs — cấu hình AI do Admin sửa trên giao diện (FR-ADM-06). IsSecret = 1: chỉ hiển thị dạng che
-- ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE AiConfigs (
    ConfigId      INT IDENTITY(1,1) NOT NULL,
    ConfigKey     VARCHAR(50)   NOT NULL,
    ConfigValue   NVARCHAR(MAX) NOT NULL,                  -- prompt tới 8.000 ký tự (VAL-17)
    [Description] NVARCHAR(255) NULL,
    IsSecret      BIT           NOT NULL CONSTRAINT DF_AiConfigs_IsSecret DEFAULT 0,
    UpdatedBy     INT           NULL,
    CreatedAt     DATETIME      NOT NULL CONSTRAINT DF_AiConfigs_CreatedAt DEFAULT GETDATE(),
    UpdatedAt     DATETIME      NULL     CONSTRAINT DF_AiConfigs_UpdatedAt DEFAULT GETDATE(),
    CONSTRAINT PK_AiConfigs PRIMARY KEY (ConfigId),
    CONSTRAINT UQ_AiConfigs_ConfigKey UNIQUE (ConfigKey),
    CONSTRAINT FK_AiConfig_User FOREIGN KEY (UpdatedBy) REFERENCES Users(UserId)
);
GO

-- ---------------------------------------------------------------------------------------------------------------------
-- 9. TutorSessions — phiên gia sư AI từng bước (FR-TUT-01..05, BR-14, BR-15)
--    CurrentStep / TotalSteps: server là nguồn sự thật về bước (TotalSteps = 0: chưa xác định)
--    AwaitingInput = 1: AI đang dừng chờ học sinh nhập số liệu (InputHint mô tả cần nhập gì)
--    QuestionId: phiên mở từ câu trắc nghiệm làm sai / bài tự luận vừa chấm. NO ACTION để tránh nhiều đường
--    cascade (Lessons → Questions → TutorSessions và Lessons → TutorSessions); câu đã có bài nộp không bị xóa cứng.
-- ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE TutorSessions (
    SessionId     INT IDENTITY(1,1) NOT NULL,
    StudentId     INT           NOT NULL,
    LessonId      INT           NULL,
    QuestionId    INT           NULL,
    Title         NVARCHAR(255) NOT NULL,
    ProblemText   NVARCHAR(MAX) NULL,
    CurrentStep   INT           NOT NULL CONSTRAINT DF_TutorSessions_CurrentStep DEFAULT 1,
    TotalSteps    INT           NOT NULL CONSTRAINT DF_TutorSessions_TotalSteps DEFAULT 0,
    [Status]      VARCHAR(20)   NOT NULL CONSTRAINT DF_TutorSessions_Status DEFAULT 'ACTIVE',
    AwaitingInput BIT           NOT NULL CONSTRAINT DF_TutorSessions_AwaitingInput DEFAULT 0,
    InputHint     NVARCHAR(255) NULL,
    CreatedAt     DATETIME      NULL     CONSTRAINT DF_TutorSessions_CreatedAt DEFAULT GETDATE(),
    UpdatedAt     DATETIME      NULL,
    CONSTRAINT PK_TutorSessions PRIMARY KEY (SessionId),
    CONSTRAINT CK_TutorSessions_Status CHECK ([Status] IN ('ACTIVE', 'COMPLETED', 'ABANDONED')),
    CONSTRAINT CK_TutorSessions_Steps CHECK (CurrentStep >= 1 AND TotalSteps >= 0),
    CONSTRAINT FK_TutorSession_Student FOREIGN KEY (StudentId) REFERENCES Users(UserId),
    CONSTRAINT FK_TutorSession_Lesson FOREIGN KEY (LessonId) REFERENCES Lessons(LessonId) ON DELETE SET NULL,
    CONSTRAINT FK_TutorSession_Question FOREIGN KEY (QuestionId) REFERENCES Questions(QuestionId)
);
GO
CREATE INDEX IX_TutorSessions_Student ON TutorSessions(StudentId, CreatedAt DESC);
GO

-- ---------------------------------------------------------------------------------------------------------------------
-- 10. TutorMessages — hội thoại trong phiên gia sư (USER = học sinh, AI = gia sư)
-- ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE TutorMessages (
    MessageId       INT IDENTITY(1,1) NOT NULL,
    SessionId       INT           NOT NULL,
    SenderType      VARCHAR(10)   NOT NULL,
    StepNumber      INT           NOT NULL CONSTRAINT DF_TutorMessages_StepNumber DEFAULT 1,
    ContentText     NVARCHAR(MAX) NOT NULL,
    IsStepCompleted BIT           NOT NULL CONSTRAINT DF_TutorMessages_IsStepCompleted DEFAULT 0,
    CreatedAt       DATETIME      NULL     CONSTRAINT DF_TutorMessages_CreatedAt DEFAULT GETDATE(),
    UpdatedAt       DATETIME      NULL,
    CONSTRAINT PK_TutorMessages PRIMARY KEY (MessageId),
    CONSTRAINT CK_TutorMessages_Sender CHECK (SenderType IN ('USER', 'AI')),
    CONSTRAINT FK_TutorMessage_Session FOREIGN KEY (SessionId) REFERENCES TutorSessions(SessionId) ON DELETE CASCADE
);
GO
CREATE INDEX IX_TutorMessages_Session ON TutorMessages(SessionId, MessageId);
GO
