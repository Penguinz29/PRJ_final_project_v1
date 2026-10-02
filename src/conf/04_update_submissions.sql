-- File: src/conf/04_update_submissions.sql
-- Cập nhật bảng Submissions hỗ trợ chấm điểm tự luận và nhận xét AI (FR-TEA-04 / FR-OCR-03)
USE MathTutorDB;
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Submissions') AND name = 'Score')
BEGIN
    ALTER TABLE Submissions ADD Score DECIMAL(4,2) NULL;
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Submissions') AND name = 'AiFeedback')
BEGIN
    ALTER TABLE Submissions ADD AiFeedback NVARCHAR(MAX) NULL;
END
GO
