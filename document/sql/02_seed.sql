-- File: src/conf/02_seed.sql
USE MathTutorDB;
GO

-- Mật khẩu mặc định của mọi tài khoản mẫu: 'EduTutor@123' (đạt VAL-02: 8-64 ký tự, có chữ và số) -> BCrypt (cost 10)
DECLARE @pwd VARCHAR(64) = '$2a$10$SDlc5quQbF2SEkWHLURXrO.BFntJFVhN.uAol0AyitPEEDyIlLs5y';

-- 1. Users
INSERT INTO Users (Username, PasswordHash, FullName, Email, [Role], IsActive, TeacherId) VALUES
('admin', @pwd, N'System Admin', 'admin@mathtutor.com', 'ADMIN', 1, NULL),
('teacher1', @pwd, N'Cô Hương', 'huong@mathtutor.com', 'TEACHER', 1, NULL),
('teacher2', @pwd, N'Thầy Quang', 'quang@mathtutor.com', 'TEACHER', 1, NULL);

-- Lấy ID giáo viên
DECLARE @t1 INT = (SELECT UserId FROM Users WHERE Username = 'teacher1');
DECLARE @t2 INT = (SELECT UserId FROM Users WHERE Username = 'teacher2');

-- Students (10 học sinh)
INSERT INTO Users (Username, PasswordHash, FullName, Email, [Role], IsActive, TeacherId) VALUES
('student1', @pwd, N'Nguyễn Văn A', 'st1@example.com', 'STUDENT', 1, @t1),
('student2', @pwd, N'Trần Thị B', 'st2@example.com', 'STUDENT', 1, @t1),
('student3', @pwd, N'Lê Hoàng C', 'st3@example.com', 'STUDENT', 1, @t1),
('student4', @pwd, N'Phạm Tiến D', 'st4@example.com', 'STUDENT', 1, @t2),
('student5', @pwd, N'Hoàng Yến E', 'st5@example.com', 'STUDENT', 1, @t2);

-- 2. Topics
INSERT INTO Topics (TopicName, [Description], TeacherId) VALUES
(N'Khảo sát hàm số và ứng dụng', N'Chương 1 Giải tích 12', @t1),
(N'Hàm số lũy thừa, Mũ và Lôgarit', N'Chương 2 Giải tích 12', @t1),
(N'Đạo hàm và Đồ thị', N'Luyện tập chuyên sâu', @t2);

DECLARE @tp1 INT = (SELECT TOP 1 TopicId FROM Topics WHERE TopicName = N'Khảo sát hàm số và ứng dụng');
DECLARE @tp2 INT = (SELECT TOP 1 TopicId FROM Topics WHERE TopicName = N'Hàm số lũy thừa, Mũ và Lôgarit');

-- 3. Lessons
INSERT INTO Lessons (TopicId, Title, Summary, Content, YoutubeUrl) VALUES
(@tp1, N'Bài 1: Sự đồng biến, nghịch biến của hàm số', N'Tìm hiểu đk đồng biến nghịch biến.', N'<p>Lý thuyết: Hàm số $y=f(x)$ đồng biến trên $K \Leftrightarrow f''(x) \ge 0, \forall x \in K$</p>', 'https://www.youtube.com/embed/dQw4w9WgXcQ'),
(@tp1, N'Bài 2: Cực trị của hàm số', N'Cực đại, cực tiểu.', N'<p>Cực tiểu khi $f''(x_0) < 0$ và đổi dấu...</p>', NULL),
(@tp2, N'Bài 1: Lũy thừa', N'Tính chất của lũy thừa', N'<p>Công thức: $a^m \cdot a^n = a^{m+n}$</p>', 'https://www.youtube.com/embed/zSnMIO2D4oE');

DECLARE @ls1 INT = (SELECT TOP 1 LessonId FROM Lessons WHERE Title = N'Bài 1: Sự đồng biến, nghịch biến của hàm số');
DECLARE @ls2 INT = (SELECT TOP 1 LessonId FROM Lessons WHERE Title = N'Bài 2: Cực trị của hàm số');

-- 4. Questions & Options
-- MCQ 1
INSERT INTO Questions (LessonId, QuestionType, Content, [Level], IsAiGenerated, TeacherId) VALUES
(@ls1, 'MCQ', N'Cho hàm số $y = x^3 - 3x + 1$. Hàm số đồng biến trên khoảng nào?', 2, 0, @t1);
DECLARE @q1 INT = SCOPE_IDENTITY();

INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q1, 'A', N'$(-\infty; -1)$ và $(1; +\infty)$', 1),
(@q1, 'B', N'$(-1; 1)$', 0),
(@q1, 'C', N'$(-\infty; 1)$', 0),
(@q1, 'D', N'$(-1; +\infty)$', 0);

-- MCQ 2
INSERT INTO Questions (LessonId, QuestionType, Content, [Level], IsAiGenerated, TeacherId) VALUES
(@ls1, 'MCQ', N'Đạo hàm của hàm số $y = e^x$ là:', 1, 0, @t1);
DECLARE @q2 INT = SCOPE_IDENTITY();

INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q2, 'A', N'$e^x$', 1),
(@q2, 'B', N'$x e^{x-1}$', 0),
(@q2, 'C', N'$\frac{e^x}{x}$', 0),
(@q2, 'D', N'$e^x \ln x$', 0);

-- Essay 1
INSERT INTO Questions (LessonId, QuestionType, Content, [Level], IsAiGenerated, TeacherId) VALUES
(@ls2, 'ESSAY', N'Tìm giá trị lớn nhất và nhỏ nhất của hàm số $f(x) = \frac{x^2 - x + 1}{x^2 + x + 1}$. (Trình bày chi tiết)', 3, 1, @t1);
GO
