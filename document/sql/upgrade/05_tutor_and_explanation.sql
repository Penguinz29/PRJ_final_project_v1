-- File: src/conf/05_tutor_and_explanation.sql
-- Nâng cấp CSDL cho phiên bản Spring MVC (chạy sau 01..04):
--   1. Questions.ExplanationLatex: lời giải chi tiết (LaTeX) hiển thị khi học sinh chọn sai (FR-STU-02)
--   2. TutorSessions, TutorMessages: Gia sư AI step-by-step (FR-TUT-01..03)
-- Script có thể chạy lại nhiều lần (idempotent).
USE MathTutorDB;
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Questions') AND name = 'ExplanationLatex')
BEGIN
    ALTER TABLE Questions ADD ExplanationLatex NVARCHAR(MAX) NULL;
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TutorSessions')
BEGIN
    CREATE TABLE TutorSessions (
        SessionId INT IDENTITY(1,1) PRIMARY KEY,
        StudentId INT NOT NULL,
        LessonId INT NULL,
        Title NVARCHAR(255) NOT NULL,
        [Status] VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
            CHECK ([Status] IN ('ACTIVE', 'COMPLETED', 'ABANDONED')),
        CreatedAt DATETIME DEFAULT GETDATE(),
        CONSTRAINT FK_TutorSession_Student FOREIGN KEY (StudentId) REFERENCES Users(UserId),
        CONSTRAINT FK_TutorSession_Lesson FOREIGN KEY (LessonId) REFERENCES Lessons(LessonId) ON DELETE SET NULL
    );
    CREATE INDEX IX_TutorSessions_Student ON TutorSessions(StudentId, CreatedAt DESC);
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TutorMessages')
BEGIN
    CREATE TABLE TutorMessages (
        MessageId INT IDENTITY(1,1) PRIMARY KEY,
        SessionId INT NOT NULL,
        SenderType VARCHAR(10) NOT NULL CHECK (SenderType IN ('USER', 'AI')),
        StepNumber INT NOT NULL DEFAULT 1,
        ContentText NVARCHAR(MAX) NOT NULL,
        IsStepCompleted BIT NOT NULL DEFAULT 0,
        CreatedAt DATETIME DEFAULT GETDATE(),
        CONSTRAINT FK_TutorMessage_Session FOREIGN KEY (SessionId) REFERENCES TutorSessions(SessionId) ON DELETE CASCADE
    );
    CREATE INDEX IX_TutorMessages_Session ON TutorMessages(SessionId, MessageId);
END
GO
