-- File: document/sql/10_lesson_created_by.sql
-- Bổ sung lessons.created_by theo SRS 6.1 để thực thi BR-03 (giáo viên chỉ sửa / xóa bài học do mình tạo).
-- Chạy sau 01..09. Script idempotent: chạy lại nhiều lần không lỗi.
-- Dữ liệu cũ: người tạo bài học = giáo viên sở hữu chủ đề chứa bài học đó.
USE MathTutorDB;
GO

IF COL_LENGTH('Lessons', 'CreatedBy') IS NULL
    ALTER TABLE Lessons ADD CreatedBy INT NULL;
GO

UPDATE l SET CreatedBy = t.TeacherId
FROM Lessons l
JOIN Topics t ON t.TopicId = l.TopicId
WHERE l.CreatedBy IS NULL;
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Lessons') AND name = 'CreatedBy' AND is_nullable = 1)
    ALTER TABLE Lessons ALTER COLUMN CreatedBy INT NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Lesson_CreatedBy')
    ALTER TABLE Lessons ADD CONSTRAINT FK_Lesson_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES Users(UserId);
GO
