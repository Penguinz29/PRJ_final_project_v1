-- File: document/sql/08_tutor_session_state.sql
-- Bổ sung trạng thái phiên gia sư theo SRS 6.1 (tutor_sessions) và FRS UC-TUT-01..04. Chạy sau 01..07.
-- Script idempotent: chạy lại nhiều lần không lỗi.
--   QuestionId  : phiên mở từ một câu hỏi (câu trắc nghiệm làm sai / bài tự luận vừa chấm)
--   ProblemText : đề bài của phiên; luôn được đưa vào prompt nên không mất ngữ cảnh khi cắt bớt lịch sử
--   CurrentStep : bước hiện tại. SERVER là nguồn sự thật (không tin giá trị client hay AI gửi)
--   TotalSteps  : tổng số bước AI đặt ở lượt khởi đầu, giữ nguyên trong cả phiên (0 = chưa xác định)
USE MathTutorDB;
GO

IF COL_LENGTH('TutorSessions', 'QuestionId') IS NULL
    ALTER TABLE TutorSessions ADD QuestionId INT NULL;
IF COL_LENGTH('TutorSessions', 'ProblemText') IS NULL
    ALTER TABLE TutorSessions ADD ProblemText NVARCHAR(MAX) NULL;
IF COL_LENGTH('TutorSessions', 'CurrentStep') IS NULL
    ALTER TABLE TutorSessions ADD CurrentStep INT NOT NULL CONSTRAINT DF_TutorSessions_CurrentStep DEFAULT 1;
IF COL_LENGTH('TutorSessions', 'TotalSteps') IS NULL
    ALTER TABLE TutorSessions ADD TotalSteps INT NOT NULL CONSTRAINT DF_TutorSessions_TotalSteps DEFAULT 0;
GO

-- Câu hỏi chỉ được mở phiên khi đã có bài nộp (không bao giờ bị xóa cứng) nên dùng NO ACTION,
-- tránh lỗi "multiple cascade paths" với Lessons -> Questions / Lessons -> TutorSessions.
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_TutorSession_Question')
    ALTER TABLE TutorSessions ADD CONSTRAINT FK_TutorSession_Question FOREIGN KEY (QuestionId) REFERENCES Questions(QuestionId);
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_TutorSessions_Steps')
    ALTER TABLE TutorSessions ADD CONSTRAINT CK_TutorSessions_Steps CHECK (CurrentStep >= 1 AND TotalSteps >= 0);
GO

-- Đồng bộ phiên cũ: đề bài = tin nhắn đầu tiên của học sinh, bước hiện tại = bước của tin nhắn AI gần nhất
UPDATE s SET ProblemText = (SELECT TOP 1 m.ContentText FROM TutorMessages m
                            WHERE m.SessionId = s.SessionId AND m.SenderType = 'USER' ORDER BY m.MessageId)
FROM TutorSessions s
WHERE s.ProblemText IS NULL;
UPDATE s SET CurrentStep = ISNULL((SELECT TOP 1 CASE WHEN m.StepNumber < 1 THEN 1 ELSE m.StepNumber END
                                   FROM TutorMessages m
                                   WHERE m.SessionId = s.SessionId AND m.SenderType = 'AI'
                                   ORDER BY m.MessageId DESC), 1)
FROM TutorSessions s
WHERE s.TotalSteps = 0;
GO
