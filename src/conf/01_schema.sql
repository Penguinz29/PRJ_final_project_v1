-- File: src/conf/01_schema.sql
-- Database: MathTutorDB
USE master;
GO

IF EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = N'MathTutorDB')
BEGIN
    ALTER DATABASE MathTutorDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE MathTutorDB;
END
GO

CREATE DATABASE MathTutorDB;
GO

USE MathTutorDB;
GO

-- 1. Users Table
CREATE TABLE Users (
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    Username VARCHAR(50) NOT NULL UNIQUE,
    PasswordHash VARCHAR(64) NOT NULL, -- SHA-256
    FullName NVARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    [Role] VARCHAR(20) NOT NULL CHECK ([Role] IN ('ADMIN', 'TEACHER', 'STUDENT')),
    IsActive BIT DEFAULT 1,
    TeacherId INT NULL, -- NULL nếu là ADMIN/TEACHER. Nếu là STUDENT, có thể NULL hoặc trỏ tới UserId của TEACHER
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Student_Teacher FOREIGN KEY (TeacherId) REFERENCES Users(UserId)
);
GO

-- 2. Topics Table
CREATE TABLE Topics (
    TopicId INT IDENTITY(1,1) PRIMARY KEY,
    TopicName NVARCHAR(255) NOT NULL,
    [Description] NVARCHAR(MAX),
    TeacherId INT NOT NULL, -- Topic thuộc về 1 giáo viên
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Topic_Teacher FOREIGN KEY (TeacherId) REFERENCES Users(UserId)
);
GO

-- 3. Lessons Table
CREATE TABLE Lessons (
    LessonId INT IDENTITY(1,1) PRIMARY KEY,
    TopicId INT NOT NULL,
    Title NVARCHAR(255) NOT NULL,
    Summary NVARCHAR(500),
    Content NVARCHAR(MAX), -- Lý thuyết LaTeX html
    YoutubeUrl VARCHAR(255),
    DisplayOrder INT DEFAULT 0,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Lesson_Topic FOREIGN KEY (TopicId) REFERENCES Topics(TopicId) ON DELETE CASCADE
);
GO

-- 4. Questions Table
CREATE TABLE Questions (
    QuestionId INT IDENTITY(1,1) PRIMARY KEY,
    LessonId INT NOT NULL,
    QuestionType VARCHAR(10) NOT NULL CHECK (QuestionType IN ('MCQ', 'ESSAY')),
    Content NVARCHAR(MAX) NOT NULL, -- Nội dung đề (LaTeX)
    [Level] INT NOT NULL DEFAULT 1 CHECK ([Level] IN (1, 2, 3)), -- 1: Dễ, 2: TB, 3: Khó
    IsAiGenerated BIT DEFAULT 0,
    TeacherId INT NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Question_Lesson FOREIGN KEY (LessonId) REFERENCES Lessons(LessonId) ON DELETE CASCADE,
    CONSTRAINT FK_Question_Teacher FOREIGN KEY (TeacherId) REFERENCES Users(UserId)
);
GO

-- 5. QuestionOptions Table (Chỉ dùng cho MCQ)
CREATE TABLE QuestionOptions (
    OptionId INT IDENTITY(1,1) PRIMARY KEY,
    QuestionId INT NOT NULL,
    OptionLetter CHAR(1) NOT NULL CHECK (OptionLetter IN ('A', 'B', 'C', 'D', 'E', 'F')),
    Content NVARCHAR(MAX) NOT NULL,
    IsCorrect BIT DEFAULT 0,
    CONSTRAINT FK_Option_Question FOREIGN KEY (QuestionId) REFERENCES Questions(QuestionId) ON DELETE CASCADE,
    CONSTRAINT UQ_Question_OptionLetter UNIQUE (QuestionId, OptionLetter)
);
GO

-- 6. Submissions Table (Bài làm của học sinh)
CREATE TABLE Submissions (
    SubmissionId INT IDENTITY(1,1) PRIMARY KEY,
    StudentId INT NOT NULL,
    LessonId INT NULL, -- Gắn với bài giảng (nếu thi từ bài giảng)
    QuestionId INT NOT NULL, -- Câu hỏi được làm
    QuestionType VARCHAR(10) NOT NULL CHECK (QuestionType IN ('MCQ', 'ESSAY')),
    StudentAnswer NVARCHAR(MAX), -- MCQ: 'A', 'B'... hoặc ESSAY: nội dung text
    EssayImagePath VARCHAR(255), -- Đường dẫn ảnh tự luận
    IsCorrect BIT NULL, -- MCQ: 1=đúng, 0=sai. ESSAY: null
    TeacherFeedback NVARCHAR(MAX),
    IsReviewed BIT DEFAULT 0,
    SubmittedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Submission_Student FOREIGN KEY (StudentId) REFERENCES Users(UserId),
    CONSTRAINT FK_Submission_Question FOREIGN KEY (QuestionId) REFERENCES Questions(QuestionId)
);
GO
