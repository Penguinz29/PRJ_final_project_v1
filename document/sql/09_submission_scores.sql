-- File: document/sql/09_submission_scores.sql
-- Tách điểm AI và điểm chính thức theo SRS 6.2 / BR-09 (FR-TEA-07, FR-OCR-03). Chạy sau 01..08.
-- Script idempotent: chạy lại nhiều lần không lỗi.
--   AiScore    : điểm AI đề xuất cho bài tự luận; KHÔNG bao giờ bị ghi đè (BR-09). Trắc nghiệm: NULL.
--   FinalScore : điểm chính thức (đổi tên từ cột Score cũ). Trắc nghiệm: 10 / 0. Tự luận: ban đầu = AiScore,
--                giáo viên duyệt có thể chỉnh (status AI_GRADED -> REVIEWED, ghi ReviewedBy / ReviewedAt).
USE MathTutorDB;
GO

-- 1) Score -> FinalScore
IF COL_LENGTH('Submissions', 'Score') IS NOT NULL AND COL_LENGTH('Submissions', 'FinalScore') IS NULL
    EXEC sp_rename 'Submissions.Score', 'FinalScore', 'COLUMN';
GO

-- 2) AiScore
IF COL_LENGTH('Submissions', 'AiScore') IS NULL
BEGIN
    ALTER TABLE Submissions ADD AiScore DECIMAL(4,2) NULL;
    -- Dữ liệu cũ: bài tự luận CHƯA duyệt thì điểm hiện có chính là điểm AI.
    -- Bài đã duyệt trước đây bị ghi đè điểm AI nên không khôi phục được: để NULL (không rõ).
    EXEC('UPDATE Submissions SET AiScore = FinalScore WHERE QuestionType = ''ESSAY'' AND [Status] = ''AI_GRADED''');
END
GO

-- 3) Ràng buộc thang điểm 0..10 (BR-07, VAL-20)
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Submissions_AiScore')
    ALTER TABLE Submissions ADD CONSTRAINT CK_Submissions_AiScore CHECK (AiScore IS NULL OR (AiScore >= 0 AND AiScore <= 10));
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Submissions_FinalScore')
    ALTER TABLE Submissions ADD CONSTRAINT CK_Submissions_FinalScore CHECK (FinalScore IS NULL OR (FinalScore >= 0 AND FinalScore <= 10));
GO
