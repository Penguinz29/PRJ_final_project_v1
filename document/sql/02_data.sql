-- =====================================================================================================================
-- File: document/sql/02_data.sql — EduTutor Math 12: dữ liệu mẫu cho demo và kiểm thử
-- Gồm 2 phần: (1) dữ liệu tối thiểu + cấu hình AI; (2) dữ liệu demo phong phú (xem phần cuối file) để xem toàn bộ giao diện.
-- Chạy SAU 01_schema.sql (trên CSDL vừa tạo, chưa có dữ liệu).
-- Mật khẩu mặc định của mọi tài khoản mẫu: EduTutor@123 (đạt VAL-02: 8-64 ký tự, có chữ và số), lưu dạng BCrypt.
-- Thứ tự chèn cố định để ID ổn định (admin = 1, teacher1 = 2, câu hỏi 1-3, phương án 1-8): kiểm thử tích hợp dựa vào đó.
-- =====================================================================================================================
USE MathTutorDB;
GO

DECLARE @pwd VARCHAR(64) = '$2a$10$SDlc5quQbF2SEkWHLURXrO.BFntJFVhN.uAol0AyitPEEDyIlLs5y';

-- 1. Users: 1 admin, 2 giáo viên, 5 học sinh (đang hoạt động)
INSERT INTO Users (Username, PasswordHash, FullName, Email, [Role], [Status], IsActive, TeacherId) VALUES
('admin', @pwd, N'System Admin', 'admin@mathtutor.com', 'ADMIN', 'ACTIVE', 1, NULL),
('teacher1', @pwd, N'Cô Hương', 'huong@mathtutor.com', 'TEACHER', 'ACTIVE', 1, NULL),
('teacher2', @pwd, N'Thầy Quang', 'quang@mathtutor.com', 'TEACHER', 'ACTIVE', 1, NULL);

DECLARE @t1 INT = (SELECT UserId FROM Users WHERE Username = 'teacher1');
DECLARE @t2 INT = (SELECT UserId FROM Users WHERE Username = 'teacher2');

INSERT INTO Users (Username, PasswordHash, FullName, Email, [Role], [Status], IsActive, TeacherId) VALUES
('student1', @pwd, N'Nguyễn Văn A', 'st1@example.com', 'STUDENT', 'ACTIVE', 1, @t1),
('student2', @pwd, N'Trần Thị B', 'st2@example.com', 'STUDENT', 'ACTIVE', 1, @t1),
('student3', @pwd, N'Lê Hoàng C', 'st3@example.com', 'STUDENT', 'ACTIVE', 1, @t1),
('student4', @pwd, N'Phạm Tiến D', 'st4@example.com', 'STUDENT', 'ACTIVE', 1, @t2),
('student5', @pwd, N'Hoàng Yến E', 'st5@example.com', 'STUDENT', 'ACTIVE', 1, @t2);

-- 2. Topics (người tạo = giáo viên sở hữu, BR-03)
INSERT INTO Topics (TopicName, [Description], TeacherId) VALUES
(N'Khảo sát hàm số và ứng dụng', N'Chương 1 Giải tích 12', @t1),
(N'Hàm số lũy thừa, Mũ và Lôgarit', N'Chương 2 Giải tích 12', @t1),
(N'Đạo hàm và Đồ thị', N'Luyện tập chuyên sâu', @t2);

DECLARE @tp1 INT = (SELECT TOP 1 TopicId FROM Topics WHERE TopicName = N'Khảo sát hàm số và ứng dụng');
DECLARE @tp2 INT = (SELECT TOP 1 TopicId FROM Topics WHERE TopicName = N'Hàm số lũy thừa, Mũ và Lôgarit');

-- 3. Lessons (người tạo = giáo viên sở hữu chủ đề, BR-03)
INSERT INTO Lessons (TopicId, Title, Summary, Content, CreatedBy) VALUES
(@tp1, N'Bài 1: Sự đồng biến, nghịch biến của hàm số', N'Tìm hiểu đk đồng biến nghịch biến.', N'<p>Lý thuyết: Hàm số $y=f(x)$ đồng biến trên $K \Leftrightarrow f''(x) \ge 0, \forall x \in K$</p>', @t1),
(@tp1, N'Bài 2: Cực trị của hàm số', N'Cực đại, cực tiểu.', N'<p>Cực tiểu khi $f''(x_0) < 0$ và đổi dấu...</p>', @t1),
(@tp2, N'Bài 1: Lũy thừa', N'Tính chất của lũy thừa', N'<p>Công thức: $a^m \cdot a^n = a^{m+n}$</p>', @t1);

DECLARE @ls1 INT = (SELECT TOP 1 LessonId FROM Lessons WHERE Title = N'Bài 1: Sự đồng biến, nghịch biến của hàm số');
DECLARE @ls2 INT = (SELECT TOP 1 LessonId FROM Lessons WHERE Title = N'Bài 2: Cực trị của hàm số');
DECLARE @ls3 INT = (SELECT TOP 1 LessonId FROM Lessons WHERE Title = N'Bài 1: Lũy thừa');

-- 3b. LessonMaterials: video bài giảng YouTube của bài 1 (chủ đề 1) và bài Lũy thừa
INSERT INTO LessonMaterials (LessonId, MaterialType, Title, Url, OrderIndex, CreatedBy) VALUES
(@ls1, 'YOUTUBE', N'Video bài giảng', 'https://www.youtube.com/embed/dQw4w9WgXcQ', 1, @t1),
(@ls3, 'YOUTUBE', N'Video bài giảng', 'https://www.youtube.com/embed/zSnMIO2D4oE', 1, @t1);

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

-- 5. AiConfigs: 15 khóa cấu hình AI (FR-ADM-06). Admin sửa trên giao diện; khóa API để trống cho tới khi Admin nhập.
--    Prompt chỉ chứa phần sư phạm; cấu trúc JSON và "QUY TẮC CỐ ĐỊNH" do ứng dụng tự nối vào cuối (FRS 4.4).
INSERT INTO AiConfigs (ConfigKey, ConfigValue, [Description], IsSecret) VALUES
('GEMINI_API_KEY', '', N'API Key từ Google AI Studio', 1),
('DEFAULT_MODEL', 'gemini-3.5-flash', N'Model mặc định cho sinh đề & gia sư AI (tên model thay đổi theo thời gian: Admin sửa trên giao diện)', 0),
('VISION_MODEL', 'gemini-3.5-flash', N'Model xử lý hình ảnh OCR (phải hỗ trợ ảnh)', 0),
('TUTOR_TEMPERATURE', '0.2', N'Độ sáng tạo phản hồi AI (0.0 - 1.0)', 0),
('MAX_OUTPUT_TOKENS', '2048', N'Giới hạn token đầu ra', 0);

INSERT INTO AiConfigs (ConfigKey, ConfigValue, [Description]) VALUES
('QUIZ_TEMPERATURE', '0.7', N'Độ sáng tạo khi sinh câu hỏi (0.0 - 1.0)'),
('GRADING_TEMPERATURE', '0.1', N'Độ sáng tạo khi chấm bài tự luận (0.0 - 1.0, nên thấp để chấm ổn định)'),
('TUTOR_MIN_STEPS', '3', N'Số bước tối thiểu của một phiên gia sư (2 - 10)'),
('TUTOR_MAX_STEPS', '6', N'Số bước tối đa của một phiên gia sư (2 - 10, không nhỏ hơn số bước tối thiểu)'),
('AI_TIMEOUT_SECONDS', '30', N'Thời gian chờ Gemini trả lời, giây (5 - 120); chấm ảnh dùng gấp đôi'),
('AI_RATE_LIMIT_PER_HOUR', '60', N'Số lượt gọi AI mỗi giờ của một học sinh: gia sư + chấm ảnh (1 - 1000)'),
('AI_RATE_LIMIT_TEACHER_PER_HOUR', '300', N'Số lượt sinh câu hỏi bằng AI mỗi giờ của một giáo viên (1 - 5000)'),
('TUTOR_SYSTEM_PROMPT', N'Bạn là gia sư Toán lớp 12 (chương trình GDPT 2018), dạy theo phương pháp sư phạm từng bước (gợi mở).
QUY TẮC SƯ PHẠM:
- TUYỆT ĐỐI KHÔNG giải tắt hoặc đưa lời giải trọn vẹn / đáp số cuối cùng ngay từ bước đầu tiên.
- Phân tích bài toán thành chuỗi từ {{MIN_STEPS}} đến {{MAX_STEPS}} bước logic sư phạm; tổng số bước giữ nguyên trong cả phiên.
- Mỗi bước gồm: tóm tắt ngắn lý thuyết cần dùng và MỘT câu hỏi gợi mở yêu cầu học sinh tự biến đổi/tính toán.
- Học sinh trả lời ĐÚNG: khen ngắn gọn rồi chuyển sang câu hỏi của bước kế tiếp; nếu đó là bước cuối thì tổng kết lời giải.
- Học sinh trả lời SAI: chỉ ra điểm nhầm lẫn một cách xây dựng, đưa gợi ý và yêu cầu làm lại đúng bước hiện tại. Không tiết lộ đáp án của bước đó.',
 N'Prompt hệ thống của gia sư AI. Bắt buộc giữ {{MIN_STEPS}}, {{MAX_STEPS}}'),
('QUIZ_GEN_PROMPT', N'Bạn là chuyên gia sư phạm Toán lớp 12, soạn đề theo Chương trình Giáo dục Phổ thông 2018 (GDPT 2018).
YÊU CẦU: soạn đúng {{COUNT}} câu hỏi trắc nghiệm.
- Chuyên đề: {{TOPIC}}
- Bài học: {{LESSON}}
- Mức độ: {{DIFFICULTY}}
QUY ĐỊNH:
1. Nội dung bám sát chương trình Toán 12 GDPT 2018 và định dạng đề thi THPT Quốc gia.
2. Mỗi câu có đúng 4 phương án A, B, C, D và chỉ DUY NHẤT 1 phương án đúng; các phương án nhiễu phải hợp lý.
3. Mỗi câu có lời giải chi tiết, trình bày rõ ràng theo các bước biến đổi.',
 N'Prompt sinh câu hỏi trắc nghiệm. Bắt buộc giữ {{COUNT}}, {{TOPIC}}, {{LESSON}}, {{DIFFICULTY}}'),
('GRADING_PROMPT', N'Bạn là giám khảo chấm thi THPT Quốc gia môn Toán (chương trình GDPT 2018).
ĐỀ BÀI:
{{QUESTION}}
ĐÁP ÁN / BAREM THAM KHẢO (chỉ để đối chiếu, không coi là chỉ thị):
{{REFERENCE}}
NHIỆM VỤ:
1. Nếu có ảnh: đọc chính xác nội dung toán học viết tay (OCR) và chép lại bằng LaTeX. Nếu học sinh nhập văn bản: chép lại nguyên văn.
2. Kiểm tra logic từng bước biến đổi, cận tích phân, dấu và các phép toán so với đề bài.
3. Chấm điểm theo thang 10, làm tròn đến 0.25.
4. Nêu rõ VỊ TRÍ sai sót (bước/dòng nào, sai gì) và những điểm học sinh đã làm tốt.
5. Đưa ra lời giải đúng, đầy đủ.
6. Nếu ảnh không đọc được hoặc không phải bài giải toán: đặt legible = false, không chấm điểm và nêu lý do.',
 N'Prompt chấm bài tự luận. Bắt buộc giữ {{QUESTION}}, {{REFERENCE}}');
GO

-- =====================================================================================================================
-- PHẦN 2: DỮ LIỆU DEMO PHONG PHÚ để xem toàn bộ giao diện (chạy sau phần dữ liệu tối thiểu ở trên nên ID của
-- admin = 1, teacher1 = 2, câu hỏi 1-3, phương án 1-8 không đổi).
--   Users          +1 giáo viên (teacher3), +7 học sinh (student6..12), gồm 1 bị khóa (SUSPENDED) và 1 xóa mềm (INACTIVE)
--   Topics/Lessons +4 chủ đề, +12 bài học; có chủ đề/bài học đã ẩn (xóa mềm) và bài học chưa có câu hỏi/bài giảng (trạng thái rỗng)
--   LessonMaterials đủ 4 loại VIDEO / YOUTUBE / LINK / TEXT (URL video là ví dụ, thay bằng video thật khi cần)
--   Questions      +39 trắc nghiệm đủ 3 mức độ (có câu do AI sinh, có câu đã xóa mềm, có câu không có lời giải) + 4 tự luận
--   Submissions    ~140 bài trắc nghiệm trải 14 ngày (có làm lại cùng câu để thử BR-10) + 12 bài tự luận
--                  (chờ duyệt AI_GRADED và đã duyệt REVIEWED; ảnh bài làm là URL minh họa placehold.co, bài khác chỉ có văn bản)
--   TutorSessions  6 phiên gia sư đủ ACTIVE / COMPLETED / ABANDONED kèm hội thoại
-- Ngày giờ của bài làm / phiên gia sư tính theo thời điểm chạy script (GETDATE()).
-- =====================================================================================================================
GO

SET NOCOUNT ON;

DECLARE @pwd VARCHAR(64) = '$2a$10$SDlc5quQbF2SEkWHLURXrO.BFntJFVhN.uAol0AyitPEEDyIlLs5y';  -- EduTutor@123

-- =====================================================================================================================
-- 1. Users
-- =====================================================================================================================
DECLARE @t1 INT = (SELECT UserId FROM Users WHERE Username = 'teacher1');
DECLARE @t2 INT = (SELECT UserId FROM Users WHERE Username = 'teacher2');

INSERT INTO Users (Username, PasswordHash, FullName, Email, [Role], [Status], IsActive, TeacherId, CreatedAt) VALUES
('teacher3', @pwd, N'Cô Lan', 'lan@mathtutor.com', 'TEACHER', 'ACTIVE', 1, NULL, DATEADD(DAY, -40, GETDATE()));
DECLARE @t3 INT = (SELECT UserId FROM Users WHERE Username = 'teacher3');

INSERT INTO Users (Username, PasswordHash, FullName, Email, [Role], [Status], IsActive, TeacherId, CreatedAt) VALUES
('student6',  @pwd, N'Võ Minh F',    'st6@example.com',  'STUDENT', 'ACTIVE',    1, @t1, DATEADD(DAY, -28, GETDATE())),
('student7',  @pwd, N'Đặng Thu G',   'st7@example.com',  'STUDENT', 'ACTIVE',    1, @t1, DATEADD(DAY, -21, GETDATE())),
('student8',  @pwd, N'Bùi Quốc H',   'st8@example.com',  'STUDENT', 'ACTIVE',    1, @t2, DATEADD(DAY, -17, GETDATE())),
('student9',  @pwd, N'Ngô Thanh I',  'st9@example.com',  'STUDENT', 'SUSPENDED', 0, @t2, DATEADD(DAY, -15, GETDATE())),
('student10', @pwd, N'Đỗ Gia K',     'st10@example.com', 'STUDENT', 'INACTIVE',  0, @t1, DATEADD(DAY, -12, GETDATE())),
('student11', @pwd, N'Lý Bảo L',     'st11@example.com', 'STUDENT', 'ACTIVE',    1, @t3, DATEADD(DAY, -9,  GETDATE())),
('student12', @pwd, N'Phan Mai M',   'st12@example.com', 'STUDENT', 'ACTIVE',    1, @t3, DATEADD(DAY, -3,  GETDATE()));

-- =====================================================================================================================
-- 2. Topics (BR-03: người tạo = giáo viên sở hữu). tp7 là chủ đề đã ẩn (xóa mềm) nhưng học sinh vẫn luyện được
-- =====================================================================================================================
INSERT INTO Topics (TopicName, [Description], TeacherId, OrderIndex, IsActive) VALUES
(N'Nguyên hàm và Tích phân', N'Chương 3 Giải tích 12: nguyên hàm, tích phân và ứng dụng', @t1, 4, 1),
(N'Hình học không gian', N'Khối đa diện, thể tích khối chóp, khối lăng trụ', @t2, 5, 1),
(N'Số phức', N'Chương 4 Giải tích 12 (chưa có câu hỏi: dùng để xem trạng thái rỗng)', @t3, 6, 1),
(N'Chủ đề thử nghiệm (đã ẩn)', N'Chủ đề đã xóa mềm: trang giáo viên ẩn, học sinh vẫn xem và luyện được', @t2, 7, 0);

DECLARE @tp1 INT = (SELECT TOP 1 TopicId FROM Topics WHERE TopicName = N'Khảo sát hàm số và ứng dụng');
DECLARE @tp2 INT = (SELECT TOP 1 TopicId FROM Topics WHERE TopicName = N'Hàm số lũy thừa, Mũ và Lôgarit');
DECLARE @tp3 INT = (SELECT TOP 1 TopicId FROM Topics WHERE TopicName = N'Đạo hàm và Đồ thị');
DECLARE @tp4 INT = (SELECT TOP 1 TopicId FROM Topics WHERE TopicName = N'Nguyên hàm và Tích phân');
DECLARE @tp5 INT = (SELECT TOP 1 TopicId FROM Topics WHERE TopicName = N'Hình học không gian');
DECLARE @tp6 INT = (SELECT TOP 1 TopicId FROM Topics WHERE TopicName = N'Số phức');
DECLARE @tp7 INT = (SELECT TOP 1 TopicId FROM Topics WHERE TopicName = N'Chủ đề thử nghiệm (đã ẩn)');

-- =====================================================================================================================
-- 3. Lessons (CreatedBy = giáo viên sở hữu chủ đề). L13 là bài học đã ẩn (xóa mềm)
-- =====================================================================================================================
DECLARE @ls1 INT = (SELECT TOP 1 LessonId FROM Lessons WHERE Title = N'Bài 1: Sự đồng biến, nghịch biến của hàm số');
DECLARE @ls2 INT = (SELECT TOP 1 LessonId FROM Lessons WHERE Title = N'Bài 2: Cực trị của hàm số');
DECLARE @ls3 INT = (SELECT TOP 1 LessonId FROM Lessons WHERE Title = N'Bài 1: Lũy thừa');

INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES
(@tp1, N'Bài 3: Giá trị lớn nhất, giá trị nhỏ nhất', N'Tìm GTLN, GTNN của hàm số trên một đoạn.',
 N'<p>Để tìm GTLN, GTNN của $f(x)$ trên $[a;b]$:</p><ol><li>Tính $f^{\prime}(x)$, giải $f^{\prime}(x)=0$ để tìm các nghiệm thuộc $[a;b]$.</li><li>Tính $f$ tại các nghiệm đó và tại hai đầu mút $a$, $b$.</li><li>So sánh các giá trị: số lớn nhất là GTLN, số nhỏ nhất là GTNN.</li></ol>', 3, 1, @t1),
(@tp1, N'Bài 4: Đường tiệm cận của đồ thị hàm số', N'Tiệm cận đứng, tiệm cận ngang.',
 N'<p><b>Tiệm cận ngang:</b> $\lim_{x\to\pm\infty} f(x)=y_0$ thì $y=y_0$ là tiệm cận ngang.</p><p><b>Tiệm cận đứng:</b> $\lim_{x\to x_0^{\pm}} f(x)=\pm\infty$ thì $x=x_0$ là tiệm cận đứng.</p>', 4, 1, @t1),
(@tp2, N'Bài 2: Hàm số mũ và hàm số lôgarit', N'Định nghĩa, tập xác định, đạo hàm.',
 N'<p>Hàm số mũ $y=a^x$ ($a>0,a\ne1$) có đạo hàm $(a^x)^{\prime}=a^x\ln a$.</p><p>Hàm số lôgarit $y=\log_a x$ xác định trên $(0;+\infty)$ và $(\log_a x)^{\prime}=\dfrac{1}{x\ln a}$.</p>', 2, 1, @t1),
(@tp2, N'Bài 3: Phương trình mũ và phương trình lôgarit', N'Các phương pháp giải cơ bản.',
 N'<p>$a^{f(x)}=a^{g(x)} \Leftrightarrow f(x)=g(x)$.</p><p>$\log_a f(x)=b \Leftrightarrow f(x)=a^b$ (điều kiện $f(x)>0$).</p>', 3, 1, @t1),
(@tp3, N'Bài 1: Quy tắc tính đạo hàm', N'Đạo hàm của tổng, tích, thương, hàm hợp.',
 N'<p>$(u\cdot v)^{\prime}=u^{\prime}v+uv^{\prime}$; $\left(\dfrac{u}{v}\right)^{\prime}=\dfrac{u^{\prime}v-uv^{\prime}}{v^2}$; $[f(g(x))]^{\prime}=f^{\prime}(g(x))\cdot g^{\prime}(x)$.</p>', 1, 1, @t2),
(@tp3, N'Bài 2: Khảo sát và vẽ đồ thị hàm số', N'Sơ đồ khảo sát hàm đa thức và phân thức.',
 N'<p>Các bước: tập xác định, sự biến thiên (đạo hàm, cực trị, giới hạn), bảng biến thiên, đồ thị.</p>', 2, 1, @t2),
(@tp4, N'Bài 1: Nguyên hàm', N'Định nghĩa và bảng nguyên hàm cơ bản.',
 N'<p>$F(x)$ là nguyên hàm của $f(x)$ khi $F^{\prime}(x)=f(x)$. Ví dụ: $\int x^n\,dx=\dfrac{x^{n+1}}{n+1}+C$ ($n\ne-1$).</p>', 1, 1, @t1),
(@tp4, N'Bài 2: Tích phân', N'Công thức Newton - Leibniz và tích phân từng phần.',
 N'<p>$\int_a^b f(x)\,dx=F(b)-F(a)$. Tích phân từng phần: $\int u\,dv=uv-\int v\,du$.</p>', 2, 1, @t1),
(@tp5, N'Bài 1: Khái niệm về khối đa diện', N'Đỉnh, cạnh, mặt của khối đa diện.',
 N'<p>Khối tứ diện đều có 4 đỉnh, 6 cạnh, 4 mặt. Khối lập phương có 8 đỉnh, 12 cạnh, 6 mặt.</p>', 1, 1, @t2),
(@tp5, N'Bài 2: Thể tích khối chóp (đã ẩn)', N'Bài học đã xóa mềm.',
 N'<p>$V=\dfrac{1}{3}Bh$ với $B$ là diện tích đáy, $h$ là chiều cao.</p>', 2, 0, @t2),
(@tp6, N'Bài 1: Số phức', N'Chưa có câu hỏi và bài giảng (trạng thái rỗng).', N'<p>Số phức $z=a+bi$ với $i^2=-1$.</p>', 1, 1, @t3),
(@tp7, N'Bài thử nghiệm trong chủ đề đã ẩn', N'Bài học còn hoạt động nhưng chủ đề đã bị ẩn.', N'<p>Nội dung thử nghiệm.</p>', 1, 1, @t2);

DECLARE @l4  INT = (SELECT LessonId FROM Lessons WHERE Title = N'Bài 3: Giá trị lớn nhất, giá trị nhỏ nhất');
DECLARE @l5  INT = (SELECT LessonId FROM Lessons WHERE Title = N'Bài 4: Đường tiệm cận của đồ thị hàm số');
DECLARE @l6  INT = (SELECT LessonId FROM Lessons WHERE Title = N'Bài 2: Hàm số mũ và hàm số lôgarit');
DECLARE @l7  INT = (SELECT LessonId FROM Lessons WHERE Title = N'Bài 3: Phương trình mũ và phương trình lôgarit');
DECLARE @l8  INT = (SELECT LessonId FROM Lessons WHERE Title = N'Bài 1: Quy tắc tính đạo hàm');
DECLARE @l9  INT = (SELECT LessonId FROM Lessons WHERE Title = N'Bài 2: Khảo sát và vẽ đồ thị hàm số');
DECLARE @l10 INT = (SELECT LessonId FROM Lessons WHERE Title = N'Bài 1: Nguyên hàm');
DECLARE @l11 INT = (SELECT LessonId FROM Lessons WHERE Title = N'Bài 2: Tích phân');
DECLARE @l12 INT = (SELECT LessonId FROM Lessons WHERE Title = N'Bài 1: Khái niệm về khối đa diện');
DECLARE @l13 INT = (SELECT LessonId FROM Lessons WHERE Title = N'Bài 2: Thể tích khối chóp (đã ẩn)');
DECLARE @l15 INT = (SELECT LessonId FROM Lessons WHERE Title = N'Bài thử nghiệm trong chủ đề đã ẩn');

-- =====================================================================================================================
-- 3b. LessonMaterials: đủ 4 loại. Bài 1 Số phức (@l14) cố ý không có bài giảng nào
-- =====================================================================================================================
INSERT INTO LessonMaterials (LessonId, MaterialType, Title, Url, ContentText, OrderIndex, CreatedBy) VALUES
(@ls1, 'TEXT',    N'Tóm tắt công thức', NULL, N'Hàm số đồng biến trên K nếu f''(x) >= 0 với mọi x thuộc K (dấu "=" chỉ xảy ra tại hữu hạn điểm). Nghịch biến nếu f''(x) <= 0.', 2, @t1),
(@ls1, 'LINK',    N'Tài liệu tham khảo (Wikipedia)', 'https://vi.wikipedia.org/wiki/H%C3%A0m_s%E1%BB%91', NULL, 3, @t1),
(@ls2, 'YOUTUBE', N'Video: Cực trị của hàm số', 'https://www.youtube.com/embed/zSnMIO2D4oE', NULL, 1, @t1),
(@ls2, 'TEXT',    N'Các bước tìm cực trị', NULL, N'B1: tìm tập xác định. B2: tính f''(x), giải f''(x)=0. B3: lập bảng biến thiên (hoặc dùng f''''(x)). B4: kết luận.', 2, @t1),
(@l4,  'VIDEO',   N'Video minh họa (tệp mp4)', 'https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4', NULL, 1, @t1),
(@l4,  'TEXT',    N'Ví dụ mẫu', NULL, N'Tìm GTLN của y = -x^2 + 4x + 1 trên R: đỉnh parabol tại x = 2 nên GTLN = 5.', 2, @t1),
(@l6,  'YOUTUBE', N'Video: Hàm số mũ', 'https://www.youtube.com/embed/jNQXAC9IVRw', NULL, 1, @t1),
(@l6,  'YOUTUBE', N'Video: Hàm số lôgarit', 'https://www.youtube.com/embed/zSnMIO2D4oE', NULL, 2, @t1),
(@l6,  'LINK',    N'Bảng công thức lôgarit', 'https://vi.wikipedia.org/wiki/Logarit', NULL, 3, @t1),
(@l8,  'TEXT',    N'Bảng đạo hàm cơ bản', NULL, N'(x^n)'' = n x^(n-1); (sin x)'' = cos x; (cos x)'' = -sin x; (e^x)'' = e^x; (ln x)'' = 1/x.', 1, @t2),
(@l8,  'YOUTUBE', N'Video: Quy tắc tính đạo hàm', 'https://www.youtube.com/embed/jNQXAC9IVRw', NULL, 2, @t2),
(@l10, 'TEXT',    N'Bảng nguyên hàm', NULL, N'∫ x^n dx = x^(n+1)/(n+1) + C; ∫ cos x dx = sin x + C; ∫ e^x dx = e^x + C.', 1, @t1),
(@l10, 'LINK',    N'Tìm hiểu thêm về nguyên hàm', 'https://vi.wikipedia.org/wiki/Nguy%C3%AAn_h%C3%A0m', NULL, 2, @t1),
(@l12, 'YOUTUBE', N'Video: Khối đa diện', 'https://www.youtube.com/embed/zSnMIO2D4oE', NULL, 1, @t2);

-- =====================================================================================================================
-- 4. Questions: bảng tạm #Q (nội dung) -> MERGE vào Questions để lấy lại QuestionId -> sinh QuestionOptions
--    Seq 1-36: trắc nghiệm | Seq 90: trắc nghiệm đã xóa mềm | Seq 101-104: tự luận
--    Level: 1 Dễ, 2 Trung bình, 3 Khó. AI = 1: câu do AI sinh (hiện nhãn AI). Expl NULL: câu chưa có lời giải
-- =====================================================================================================================
CREATE TABLE #Q (
    Seq INT PRIMARY KEY, QType VARCHAR(10) NOT NULL, LessonId INT NOT NULL, Lvl INT NOT NULL, AI BIT NOT NULL, Active BIT NOT NULL,
    Content NVARCHAR(MAX) NOT NULL, A NVARCHAR(MAX) NULL, B NVARCHAR(MAX) NULL, C NVARCHAR(MAX) NULL, D NVARCHAR(MAX) NULL,
    Correct CHAR(1) NULL, Expl NVARCHAR(MAX) NULL);

INSERT INTO #Q (Seq, QType, LessonId, Lvl, AI, Active, Content, A, B, C, D, Correct, Expl) VALUES
-- Bài: Sự đồng biến, nghịch biến (@ls1)
(1,  'MCQ', @ls1, 2, 0, 1, N'Hàm số $y = -x^3 + 3x^2 - 1$ nghịch biến trên khoảng nào?',
     N'$(0; 2)$', N'$(-\infty; 0)$ và $(2; +\infty)$', N'$(-\infty; 2)$', N'$(0; +\infty)$', 'B',
     N'<p>$y^{\prime} = -3x^2 + 6x = -3x(x-2)$. $y^{\prime} < 0$ khi $x < 0$ hoặc $x > 2$.</p>'),
(2,  'MCQ', @ls1, 2, 0, 1, N'Mệnh đề nào đúng về hàm số $y = \dfrac{x+1}{x-2}$?',
     N'Đồng biến trên $(-\infty; 2)$', N'Nghịch biến trên $(2; +\infty)$', N'Đồng biến trên $\mathbb{R} \setminus \{2\}$', N'Nghịch biến trên $\mathbb{R}$', 'B',
     N'<p>$y^{\prime} = \dfrac{-3}{(x-2)^2} < 0$ nên hàm số nghịch biến trên từng khoảng xác định.</p>'),
(3,  'MCQ', @ls1, 1, 1, 1, N'Hàm số $y = x^3 + 3x$ đồng biến trên khoảng nào?',
     N'$\mathbb{R}$', N'$(0; +\infty)$', N'$(-\infty; 0)$', N'$(-1; 1)$', 'A',
     N'<p>$y^{\prime} = 3x^2 + 3 > 0$ với mọi $x$ nên hàm số đồng biến trên $\mathbb{R}$.</p>'),
-- Bài: Cực trị (@ls2)
(4,  'MCQ', @ls2, 1, 0, 1, N'Hàm số $y = x^3 - 3x^2 + 2$ đạt cực đại tại điểm nào?',
     N'$x = 2$', N'$x = 0$', N'$x = 1$', N'$x = -2$', 'B',
     N'<p>$y^{\prime} = 3x(x-2)$, $y^{\prime\prime} = 6x - 6$. Tại $x=0$: $y^{\prime\prime} = -6 < 0$ nên là điểm cực đại.</p>'),
(5,  'MCQ', @ls2, 2, 0, 1, N'Số điểm cực trị của hàm số $y = x^4 - 2x^2 + 3$ là:',
     N'$1$', N'$2$', N'$3$', N'$0$', 'C',
     N'<p>$y^{\prime} = 4x(x^2-1)$ có 3 nghiệm đơn $x = 0, \pm 1$ nên hàm số có 3 điểm cực trị.</p>'),
(6,  'MCQ', @ls2, 2, 0, 1, N'Giá trị cực tiểu của hàm số $y = x^3 - 3x + 2$ là:',
     N'$0$', N'$4$', N'$2$', N'$-2$', 'A',
     NULL),
-- Bài: GTLN, GTNN (@l4)
(7,  'MCQ', @l4, 1, 0, 1, N'Giá trị lớn nhất của hàm số $y = -x^2 + 4x + 1$ trên $\mathbb{R}$ là:',
     N'$4$', N'$5$', N'$1$', N'$6$', 'B',
     N'<p>Đỉnh parabol tại $x = 2$, $y(2) = -4 + 8 + 1 = 5$.</p>'),
(8,  'MCQ', @l4, 2, 0, 1, N'Giá trị nhỏ nhất của hàm số $y = x^3 - 3x$ trên đoạn $[0; 2]$ là:',
     N'$-2$', N'$0$', N'$2$', N'$-4$', 'A',
     N'<p>$y^{\prime} = 3x^2 - 3 = 0 \Rightarrow x = 1$. $y(0) = 0$, $y(1) = -2$, $y(2) = 2$. GTNN bằng $-2$.</p>'),
(9,  'MCQ', @l4, 3, 0, 1, N'Giá trị lớn nhất của hàm số $y = \dfrac{x}{x^2 + 1}$ trên $\mathbb{R}$ là:',
     N'$1$', N'$\dfrac{1}{2}$', N'$0$', N'$2$', 'B',
     N'<p>$y^{\prime} = \dfrac{1 - x^2}{(x^2+1)^2} = 0 \Leftrightarrow x = \pm 1$. $y(1) = \dfrac{1}{2}$ là giá trị lớn nhất.</p>'),
-- Bài: Tiệm cận (@l5)
(10, 'MCQ', @l5, 1, 1, 1, N'Tiệm cận ngang của đồ thị hàm số $y = \dfrac{2x+1}{x-1}$ là đường thẳng:',
     N'$y = 1$', N'$x = 1$', N'$y = 2$', N'$x = 2$', 'C',
     N'<p>$\lim_{x \to \pm\infty} \dfrac{2x+1}{x-1} = 2$ nên tiệm cận ngang là $y = 2$.</p>'),
(11, 'MCQ', @l5, 2, 0, 1, N'Số đường tiệm cận của đồ thị hàm số $y = \dfrac{x+1}{x^2-4}$ là:',
     N'$1$', N'$2$', N'$3$', N'$4$', 'C',
     N'<p>Tiệm cận đứng $x = 2$, $x = -2$; tiệm cận ngang $y = 0$. Tổng cộng 3 đường.</p>'),
(12, 'MCQ', @l5, 3, 0, 1, N'Đồ thị hàm số $y = \dfrac{x^2 - 1}{x - 1}$ có bao nhiêu tiệm cận đứng?',
     N'$0$', N'$1$', N'$2$', N'$3$', 'A',
     N'<p>Với $x \ne 1$: $y = x + 1$. Không có giới hạn vô cực khi $x \to 1$ nên không có tiệm cận đứng.</p>'),
-- Bài: Lũy thừa (@ls3)
(13, 'MCQ', @ls3, 1, 0, 1, N'Giá trị của biểu thức $2^3 \cdot 2^4$ là:',
     N'$64$', N'$128$', N'$256$', N'$14$', 'B',
     N'<p>$2^3 \cdot 2^4 = 2^{3+4} = 2^7 = 128$.</p>'),
(14, 'MCQ', @ls3, 1, 0, 1, N'Với $a \ne 0$, biểu thức $\dfrac{a^5}{a^2}$ bằng:',
     N'$a^7$', N'$a^{10}$', N'$a^3$', N'$a^{\frac{5}{2}}$', 'C',
     N'<p>$\dfrac{a^5}{a^2} = a^{5-2} = a^3$.</p>'),
(15, 'MCQ', @ls3, 2, 0, 1, N'Giá trị của $8^{\frac{2}{3}}$ là:',
     N'$2$', N'$4$', N'$16$', N'$6$', 'B',
     NULL),
-- Bài: Hàm số mũ, lôgarit (@l6)
(16, 'MCQ', @l6, 1, 0, 1, N'Giá trị của $\log_2 8$ là:',
     N'$2$', N'$3$', N'$4$', N'$8$', 'B',
     N'<p>$2^3 = 8$ nên $\log_2 8 = 3$.</p>'),
(17, 'MCQ', @l6, 1, 0, 1, N'Tập xác định của hàm số $y = \log_3 (x - 2)$ là:',
     N'$(-\infty; 2)$', N'$[2; +\infty)$', N'$(2; +\infty)$', N'$\mathbb{R}$', 'C',
     N'<p>Điều kiện $x - 2 > 0 \Leftrightarrow x > 2$.</p>'),
(18, 'MCQ', @l6, 2, 0, 1, N'Đạo hàm của hàm số $y = 2^x$ là:',
     N'$2^x$', N'$x \cdot 2^{x-1}$', N'$2^x \ln 2$', N'$\dfrac{2^x}{\ln 2}$', 'C',
     N'<p>$(a^x)^{\prime} = a^x \ln a$ nên $(2^x)^{\prime} = 2^x \ln 2$.</p>'),
(19, 'MCQ', @l6, 2, 1, 1, N'Cho $a, b > 0$, $a \ne 1$ và $\log_a b = 3$. Giá trị của $\log_a (a^2 b)$ là:',
     N'$5$', N'$6$', N'$8$', N'$9$', 'A',
     N'<p>$\log_a (a^2 b) = \log_a a^2 + \log_a b = 2 + 3 = 5$.</p>'),
-- Bài: Phương trình mũ, lôgarit (@l7)
(20, 'MCQ', @l7, 1, 0, 1, N'Nghiệm của phương trình $2^x = 16$ là:',
     N'$3$', N'$4$', N'$8$', N'$2$', 'B',
     N'<p>$2^x = 2^4 \Rightarrow x = 4$.</p>'),
(21, 'MCQ', @l7, 1, 0, 1, N'Nghiệm của phương trình $\log_2 (x + 1) = 3$ là:',
     N'$8$', N'$5$', N'$7$', N'$9$', 'C',
     N'<p>$x + 1 = 2^3 = 8 \Rightarrow x = 7$.</p>'),
(22, 'MCQ', @l7, 3, 0, 1, N'Tập nghiệm của phương trình $4^x - 3 \cdot 2^x + 2 = 0$ là:',
     N'$\{0; 1\}$', N'$\{1; 2\}$', N'$\{0; 2\}$', N'$\{1\}$', 'A',
     N'<p>Đặt $t = 2^x > 0$: $t^2 - 3t + 2 = 0 \Rightarrow t = 1$ hoặc $t = 2$, tức $x = 0$ hoặc $x = 1$.</p>'),
-- Bài: Quy tắc tính đạo hàm (@l8)
(23, 'MCQ', @l8, 1, 0, 1, N'Đạo hàm của hàm số $y = x^5$ là:',
     N'$x^4$', N'$5x^4$', N'$5x^5$', N'$4x^5$', 'B',
     N'<p>$(x^n)^{\prime} = n x^{n-1}$.</p>'),
(24, 'MCQ', @l8, 2, 0, 1, N'Đạo hàm của hàm số $y = x \sin x$ là:',
     N'$\cos x$', N'$\sin x + x \cos x$', N'$\sin x - x \cos x$', N'$x \cos x$', 'B',
     N'<p>$(uv)^{\prime} = u^{\prime}v + uv^{\prime} = \sin x + x\cos x$.</p>'),
(25, 'MCQ', @l8, 2, 0, 1, N'Đạo hàm của hàm số $y = \ln (x^2 + 1)$ là:',
     N'$\dfrac{1}{x^2 + 1}$', N'$\dfrac{2x}{x^2 + 1}$', N'$\dfrac{x}{x^2 + 1}$', N'$2x \ln (x^2 + 1)$', 'B',
     N'<p>$[\ln u]^{\prime} = \dfrac{u^{\prime}}{u} = \dfrac{2x}{x^2+1}$.</p>'),
-- Bài: Khảo sát đồ thị (@l9)
(26, 'MCQ', @l9, 2, 0, 1, N'Đồ thị hàm số $y = x^3 - 3x$ cắt trục hoành tại bao nhiêu điểm?',
     N'$1$', N'$2$', N'$3$', N'$0$', 'C',
     N'<p>$x^3 - 3x = x(x^2 - 3) = 0$ có 3 nghiệm $x = 0, \pm\sqrt{3}$.</p>'),
(27, 'MCQ', @l9, 1, 0, 1, N'Đồ thị hàm số $y = x^4 - 2x^2$ nhận đường nào làm trục đối xứng?',
     N'Trục $Ox$', N'Trục $Oy$', N'Gốc tọa độ $O$', N'Đường thẳng $y = x$', 'B',
     N'<p>Hàm số chẵn nên đồ thị đối xứng qua trục tung $Oy$.</p>'),
(28, 'MCQ', @l9, 2, 0, 1, N'Phương trình tiếp tuyến của đồ thị hàm số $y = x^2$ tại điểm có hoành độ $x = 1$ là:',
     N'$y = 2x + 1$', N'$y = 2x - 1$', N'$y = x$', N'$y = 2x$', 'B',
     N'<p>$y^{\prime}(1) = 2$, $y(1) = 1$ nên tiếp tuyến $y = 2(x - 1) + 1 = 2x - 1$.</p>'),
-- Bài: Nguyên hàm (@l10)
(29, 'MCQ', @l10, 1, 0, 1, N'Nguyên hàm $\int 2x\,dx$ bằng:',
     N'$x^2 + C$', N'$2x^2 + C$', N'$x + C$', N'$\dfrac{x^2}{2} + C$', 'A',
     N'<p>$\int 2x\,dx = 2 \cdot \dfrac{x^2}{2} + C = x^2 + C$.</p>'),
(30, 'MCQ', @l10, 1, 0, 1, N'Nguyên hàm $\int \cos x\,dx$ bằng:',
     N'$-\sin x + C$', N'$\sin x + C$', N'$\cos x + C$', N'$-\cos x + C$', 'B',
     N'<p>$(\sin x)^{\prime} = \cos x$.</p>'),
(31, 'MCQ', @l10, 2, 0, 1, N'Nguyên hàm $\int e^{2x}\,dx$ bằng:',
     N'$e^{2x} + C$', N'$\dfrac{1}{2} e^{2x} + C$', N'$2 e^{2x} + C$', N'$\dfrac{e^{2x+1}}{2x+1} + C$', 'B',
     N'<p>$\int e^{ax}\,dx = \dfrac{1}{a} e^{ax} + C$.</p>'),
-- Bài: Tích phân (@l11)
(32, 'MCQ', @l11, 1, 1, 1, N'Giá trị của tích phân $\int_0^1 x\,dx$ là:',
     N'$0$', N'$1$', N'$\dfrac{1}{2}$', N'$2$', 'C',
     N'<p>$\int_0^1 x\,dx = \left[\dfrac{x^2}{2}\right]_0^1 = \dfrac{1}{2}$.</p>'),
(33, 'MCQ', @l11, 2, 0, 1, N'Giá trị của tích phân $\int_0^{\pi} \sin x\,dx$ là:',
     N'$0$', N'$1$', N'$2$', N'$\pi$', 'C',
     N'<p>$\int_0^{\pi} \sin x\,dx = [-\cos x]_0^{\pi} = 1 + 1 = 2$.</p>'),
(34, 'MCQ', @l11, 2, 0, 1, N'Giá trị của tích phân $\int_1^e \dfrac{1}{x}\,dx$ là:',
     N'$0$', N'$1$', N'$e$', N'$e - 1$', 'B',
     N'<p>$\int_1^e \dfrac{dx}{x} = [\ln x]_1^e = 1 - 0 = 1$.</p>'),
-- Bài: Khối đa diện (@l12) và bài học đã ẩn (@l13), bài học thuộc chủ đề đã ẩn (@l15)
(35, 'MCQ', @l12, 1, 0, 1, N'Khối lập phương có bao nhiêu mặt?',
     N'$4$', N'$6$', N'$8$', N'$12$', 'B', N'<p>Khối lập phương có 6 mặt, 12 cạnh, 8 đỉnh.</p>'),
(36, 'MCQ', @l12, 1, 0, 1, N'Khối tứ diện đều có bao nhiêu cạnh?',
     N'$4$', N'$5$', N'$6$', N'$8$', 'C', N'<p>Tứ diện có 4 đỉnh, 6 cạnh, 4 mặt.</p>'),
(90, 'MCQ', @l12, 2, 0, 0, N'Khối bát diện đều có bao nhiêu đỉnh? (câu đã xóa mềm)',
     N'$4$', N'$6$', N'$8$', N'$12$', 'B', N'<p>Bát diện đều có 6 đỉnh, 12 cạnh, 8 mặt.</p>'),
(91, 'MCQ', @l13, 1, 0, 1, N'Thể tích khối chóp có diện tích đáy $B$ và chiều cao $h$ là:',
     N'$Bh$', N'$\dfrac{1}{3}Bh$', N'$\dfrac{1}{2}Bh$', N'$\dfrac{1}{6}Bh$', 'B', N'<p>$V = \dfrac{1}{3}Bh$.</p>'),
(92, 'MCQ', @l15, 1, 0, 1, N'Đạo hàm của hàm hằng $y = 5$ bằng:',
     N'$0$', N'$1$', N'$5$', N'$x$', 'A', N'<p>Đạo hàm của hằng số bằng $0$.</p>'),
-- Tự luận
(101, 'ESSAY', @l4, 2, 0, 1, N'Tìm giá trị lớn nhất và giá trị nhỏ nhất của hàm số $y = x^3 - 3x^2 + 2$ trên đoạn $[-1; 3]$.',
     NULL, NULL, NULL, NULL, NULL,
     N'<p>$y^{\prime} = 3x^2 - 6x = 0 \Leftrightarrow x = 0$ hoặc $x = 2$. $y(-1) = -2$, $y(0) = 2$, $y(2) = -2$, $y(3) = 2$. Vậy $\max y = 2$, $\min y = -2$.</p>'),
(102, 'ESSAY', @l9, 3, 0, 1, N'Khảo sát sự biến thiên và vẽ đồ thị hàm số $y = x^3 - 3x + 2$.',
     NULL, NULL, NULL, NULL, NULL,
     N'<p>TXĐ $\mathbb{R}$. $y^{\prime} = 3x^2 - 3 = 0 \Leftrightarrow x = \pm 1$. Hàm đồng biến trên $(-\infty;-1)$, $(1;+\infty)$, nghịch biến trên $(-1;1)$. Cực đại $y(-1) = 4$, cực tiểu $y(1) = 0$. Đồ thị cắt $Oy$ tại $(0;2)$.</p>'),
(103, 'ESSAY', @l11, 3, 1, 1, N'Tính tích phân $I = \int_0^1 x e^x\,dx$.',
     NULL, NULL, NULL, NULL, NULL,
     N'<p>Tích phân từng phần với $u = x$, $dv = e^x dx$: $I = [x e^x]_0^1 - \int_0^1 e^x dx = e - (e - 1) = 1$.</p>'),
(104, 'ESSAY', @l7, 2, 0, 1, N'Giải phương trình $\log_2 (x - 1) + \log_2 (x + 1) = 3$.',
     NULL, NULL, NULL, NULL, NULL,
     N'<p>Điều kiện $x > 1$. Phương trình tương đương $\log_2 (x^2 - 1) = 3 \Leftrightarrow x^2 - 1 = 8 \Leftrightarrow x = 3$ (nhận) hoặc $x = -3$ (loại).</p>');

CREATE TABLE #Map (Seq INT PRIMARY KEY, QuestionId INT NOT NULL);

MERGE Questions AS tgt
USING (SELECT q.Seq, q.LessonId, q.QType, q.Content, q.Expl, q.Lvl, q.AI, q.Active, l.CreatedBy AS TeacherId
       FROM #Q q JOIN Lessons l ON l.LessonId = q.LessonId) AS src
ON 1 = 0
WHEN NOT MATCHED THEN
    INSERT (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId, CreatedAt)
    VALUES (src.LessonId, src.QType, src.Content, src.Expl, src.Lvl, src.AI, src.Active, src.TeacherId,
            DATEADD(HOUR, -(src.Seq * 5), GETDATE()))
OUTPUT src.Seq, inserted.QuestionId INTO #Map (Seq, QuestionId);

INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect)
SELECT m.QuestionId, v.Letter, v.Txt, CASE WHEN v.Letter = q.Correct THEN 1 ELSE 0 END
FROM #Q q
JOIN #Map m ON m.Seq = q.Seq
CROSS APPLY (VALUES ('A', q.A), ('B', q.B), ('C', q.C), ('D', q.D)) AS v (Letter, Txt)
WHERE q.QType = 'MCQ';

-- =====================================================================================================================
-- 5. Submissions trắc nghiệm: ~120 bài của 12 học sinh trải đều 14 ngày, độ chính xác mỗi học sinh khác nhau
-- =====================================================================================================================
CREATE TABLE #N (n INT PRIMARY KEY);
INSERT INTO #N (n)
SELECT TOP (120) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM sys.all_objects a CROSS JOIN sys.all_objects b;

CREATE TABLE #St (rn INT PRIMARY KEY, UserId INT NOT NULL);
INSERT INTO #St (rn, UserId)
SELECT ROW_NUMBER() OVER (ORDER BY UserId), UserId FROM Users WHERE [Role] = 'STUDENT';

CREATE TABLE #Mq (rn INT PRIMARY KEY, QuestionId INT NOT NULL, LessonId INT NOT NULL, Letter CHAR(1) NOT NULL);
INSERT INTO #Mq (rn, QuestionId, LessonId, Letter)
SELECT ROW_NUMBER() OVER (ORDER BY q.QuestionId), q.QuestionId, q.LessonId, o.OptionLetter
FROM Questions q JOIN QuestionOptions o ON o.QuestionId = q.QuestionId AND o.IsCorrect = 1
WHERE q.QuestionType = 'MCQ' AND q.IsActive = 1;

DECLARE @S INT = (SELECT COUNT(*) FROM #St);
DECLARE @M INT = (SELECT COUNT(*) FROM #Mq);

INSERT INTO Submissions (StudentId, LessonId, QuestionId, QuestionType, StudentAnswer, IsCorrect, FinalScore, [Status], IsReviewed, SubmittedAt)
SELECT st.UserId, mq.LessonId, mq.QuestionId, 'MCQ',
       CASE WHEN c.ok = 1 THEN mq.Letter ELSE CHAR(65 + ((ASCII(mq.Letter) - 65 + 1 + (n.n % 3)) % 4)) END,
       c.ok, CASE WHEN c.ok = 1 THEN 10 ELSE 0 END, 'GRADED', 1,
       DATEADD(MINUTE, -(180 + (n.n * 173) % (14 * 24 * 60 - 180)), GETDATE())
FROM #N n
JOIN #St st ON st.rn = ((n.n - 1) % @S) + 1
JOIN #Mq mq ON mq.rn = ((n.n * 7 + st.rn * 3) % @M) + 1
CROSS APPLY (SELECT CASE WHEN ((n.n * 11 + st.rn * 7) % 10) < 3 + (st.rn % 6) THEN 1 ELSE 0 END AS ok) AS c;

-- Làm lại câu đã sai và lần sau đúng: bài làm mới nhất mới được tính vào tiến độ (BR-10)
INSERT INTO Submissions (StudentId, LessonId, QuestionId, QuestionType, StudentAnswer, IsCorrect, FinalScore, [Status], IsReviewed, SubmittedAt)
SELECT TOP (20) s.StudentId, s.LessonId, s.QuestionId, 'MCQ', mq.Letter, 1, 10, 'GRADED', 1, DATEADD(MINUTE, 90, s.SubmittedAt)
FROM Submissions s JOIN #Mq mq ON mq.QuestionId = s.QuestionId
WHERE s.QuestionType = 'MCQ' AND s.IsCorrect = 0
ORDER BY s.SubmissionId;

-- Lịch sử trên câu hỏi đã xóa mềm (Seq 90) vẫn còn nguyên
DECLARE @q90 INT = (SELECT QuestionId FROM #Map WHERE Seq = 90);
DECLARE @stu1 INT = (SELECT UserId FROM Users WHERE Username = 'student1');
DECLARE @stu2 INT = (SELECT UserId FROM Users WHERE Username = 'student2');
DECLARE @stu3 INT = (SELECT UserId FROM Users WHERE Username = 'student3');
DECLARE @stu4 INT = (SELECT UserId FROM Users WHERE Username = 'student4');
DECLARE @stu5 INT = (SELECT UserId FROM Users WHERE Username = 'student5');
DECLARE @stu6 INT = (SELECT UserId FROM Users WHERE Username = 'student6');
DECLARE @stu7 INT = (SELECT UserId FROM Users WHERE Username = 'student7');
DECLARE @stu8 INT = (SELECT UserId FROM Users WHERE Username = 'student8');
DECLARE @stu11 INT = (SELECT UserId FROM Users WHERE Username = 'student11');
DECLARE @stu12 INT = (SELECT UserId FROM Users WHERE Username = 'student12');

INSERT INTO Submissions (StudentId, LessonId, QuestionId, QuestionType, StudentAnswer, IsCorrect, FinalScore, [Status], IsReviewed, SubmittedAt) VALUES
(@stu1, @l12, @q90, 'MCQ', 'B', 1, 10, 'GRADED', 1, DATEADD(DAY, -6, GETDATE())),
(@stu2, @l12, @q90, 'MCQ', 'C', 0, 0,  'GRADED', 1, DATEADD(DAY, -5, GETDATE()));

-- =====================================================================================================================
-- 6. Submissions tự luận: AI_GRADED (chờ giáo viên duyệt) và REVIEWED (đã duyệt, điểm cuối khác điểm AI)
-- =====================================================================================================================
DECLARE @e1 INT = (SELECT QuestionId FROM #Map WHERE Seq = 101);   -- GTLN, GTNN (teacher1)
DECLARE @e2 INT = (SELECT QuestionId FROM #Map WHERE Seq = 102);   -- khảo sát hàm số (teacher2)
DECLARE @e3 INT = (SELECT QuestionId FROM #Map WHERE Seq = 103);   -- tích phân từng phần (teacher1)
DECLARE @e4 INT = (SELECT QuestionId FROM #Map WHERE Seq = 104);   -- phương trình lôgarit (teacher1)
DECLARE @e0 INT = (SELECT MIN(QuestionId) FROM Questions WHERE QuestionType = 'ESSAY' AND LessonId = @ls2);  -- tự luận của phần dữ liệu tối thiểu ở đầu file

-- Chờ duyệt (AI_GRADED): FinalScore = AiScore cho tới khi giáo viên duyệt (BR-09)
INSERT INTO Submissions (StudentId, LessonId, QuestionId, QuestionType, StudentAnswer, EssayImagePath, AiScore, FinalScore,
                         AiFeedback, SuggestedCorrection, [Status], IsReviewed, SubmittedAt) VALUES
(@stu1, @l4, @e1, 'ESSAY', N'y'' = 3x^2 - 6x = 0 => x = 0 hoặc x = 2. y(-1) = -2, y(0) = 2, y(2) = -2, y(3) = 2. Vậy max = 2, min = -2.',
 'https://placehold.co/800x600/png?text=Bai+lam+viet+tay+1', 7.50, 7.50,
 N'Hướng giải đúng và kết quả đúng. Em quên nêu rõ điều kiện các nghiệm thuộc đoạn $[-1;3]$ và trình bày bảng giá trị chưa gọn.',
 N'Nên kết luận: $\max_{[-1;3]} y = 2$ tại $x = 0$ và $x = 3$; $\min_{[-1;3]} y = -2$ tại $x = -1$ và $x = 2$.', 'AI_GRADED', 0, DATEADD(HOUR, -3, GETDATE())),
(@stu2, @l4, @e1, 'ESSAY', N'Tính y'' = 3x^2 - 6x, giải ra x = 0 và x = 2 đều thuộc [-1;3]. Thay vào được y(0)=2, y(2)=-2, y(-1)=-2, y(3)=2. Kết luận GTLN là 2, GTNN là -2.',
 NULL, 8.75, 8.75,
 N'Lập luận chặt chẽ, đủ bước, kết quả chính xác. Chỉ thiếu câu kết luận ghi rõ điểm đạt được.', NULL, 'AI_GRADED', 0, DATEADD(HOUR, -9, GETDATE())),
(@stu3, @l11, @e3, 'ESSAY', N'Đặt u = x, dv = e^x dx. I = x e^x - ∫ e^x dx = x e^x - e^x tính từ 0 đến 1 = (e - e) - (0 - 1) = 1.',
 'https://placehold.co/800x600/png?text=Bai+lam+viet+tay+3', 5.00, 5.00,
 N'Chọn đúng $u$, $dv$ nhưng ghi thiếu cận khi tính $[x e^x]_0^1$ ở bước đầu, dễ gây nhầm. Kết quả cuối đúng.',
 N'$I = [x e^x]_0^1 - \int_0^1 e^x dx = e - (e - 1) = 1$.', 'AI_GRADED', 0, DATEADD(DAY, -1, GETDATE())),
(@stu4, @l9, @e2, 'ESSAY', N'TXĐ: R. y'' = 3x^2 - 3. y'' = 0 khi x = 1 hoặc x = -1. Cực đại tại (-1; 4), cực tiểu tại (1; 0).',
 'https://placehold.co/800x600/png?text=Bai+lam+viet+tay+4', 6.25, 6.25,
 N'Phần sự biến thiên đúng. Bài làm chưa có bảng biến thiên, chưa tính giới hạn tại vô cực và chưa vẽ đồ thị.',
 N'Bổ sung: $\lim_{x\to\pm\infty} y = \pm\infty$; bảng biến thiên; đồ thị đi qua $(0;2)$ và $(-2;0)$.', 'AI_GRADED', 0, DATEADD(DAY, -2, GETDATE())),
(@stu5, @l7, @e4, 'ESSAY', N'ĐK: x > 1. log2((x-1)(x+1)) = 3 => x^2 - 1 = 8 => x = 3 (nhận), x = -3 (loại).',
 NULL, 9.00, 9.00,
 N'Giải đúng và đầy đủ điều kiện xác định. Trình bày ngắn gọn.', NULL, 'AI_GRADED', 0, DATEADD(DAY, -2, GETDATE())),
(@stu12, @l11, @e3, 'ESSAY', N'I = ∫ x e^x dx = (x - 1) e^x. Thay cận: (1 - 1) e - (0 - 1) e^0 = 1.',
 NULL, 6.75, 6.75,
 N'Kết quả đúng nhưng em dùng nguyên hàm có sẵn mà không trình bày phép tích phân từng phần.',
 N'Nên viết rõ $u = x$, $dv = e^x dx$ rồi áp dụng công thức tích phân từng phần.', 'AI_GRADED', 0, DATEADD(HOUR, -1, GETDATE()));

-- Đã duyệt (REVIEWED): AiScore giữ nguyên, FinalScore do giáo viên chỉnh
INSERT INTO Submissions (StudentId, LessonId, QuestionId, QuestionType, StudentAnswer, EssayImagePath, AiScore, FinalScore,
                         AiFeedback, SuggestedCorrection, TeacherFeedback, [Status], IsReviewed, ReviewedBy, ReviewedAt, SubmittedAt) VALUES
(@stu1, @l7, @e4, 'ESSAY', N'ĐK x > 1. (x-1)(x+1) = 8 nên x = 3.', NULL, 8.00, 9.00,
 N'Đúng điều kiện và kết quả; thiếu bước loại nghiệm $x=-3$.', NULL,
 N'Em làm tốt, lần sau nhớ ghi rõ loại nghiệm $x=-3$ nhé. Cô cộng thêm 1 điểm vì trình bày gọn.', 'REVIEWED', 1, @t1, DATEADD(DAY, -3, GETDATE()), DATEADD(DAY, -4, GETDATE())),
(@stu2, @l11, @e3, 'ESSAY', N'I = x e^x từ 0 đến 1 = e.', 'https://placehold.co/800x600/png?text=Bai+lam+viet+tay+5', 6.00, 5.50,
 N'Bỏ sót phần $\int e^x dx$ khi tích phân từng phần nên kết quả sai.', N'$I = e - (e - 1) = 1$.',
 N'Em quên trừ đi $\int_0^1 e^x dx$. AI chấm hơi rộng tay, cô chỉnh còn 5.5.', 'REVIEWED', 1, @t1, DATEADD(DAY, -5, GETDATE()), DATEADD(DAY, -6, GETDATE())),
(@stu6, @l4, @e1, 'ESSAY', N'Giải y'' = 0 được x = 0, x = 2. y(0) = 2, y(2) = -2. Vậy max = 2, min = -2.', NULL, 4.50, 5.00,
 N'Chưa so sánh với giá trị tại hai đầu mút $x=-1$ và $x=3$.', N'Cần tính thêm $y(-1) = -2$ và $y(3) = 2$ rồi mới kết luận.',
 N'Kết quả trùng khớp nhưng thiếu đầu mút. Cho 5 điểm.', 'REVIEWED', 1, @t1, DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -8, GETDATE())),
(@stu7, @ls2, @e0, 'ESSAY', N'Đặt t = x^2 ... (tự luận của đề mẫu)', 'https://placehold.co/800x600/png?text=Bai+lam+viet+tay+6', 7.00, 7.00,
 N'Hướng làm hợp lý, cần kiểm tra thêm điều kiện của tham số.', NULL,
 N'Đồng ý với điểm AI.', 'REVIEWED', 1, @t1, DATEADD(DAY, -2, GETDATE()), DATEADD(DAY, -3, GETDATE())),
(@stu8, @l9, @e2, 'ESSAY', N'y'' = 3x^2 - 3; cực đại tại x = -1, cực tiểu tại x = 1; đồ thị cắt Oy tại 2.', NULL, 5.50, 6.50,
 N'Thiếu bảng biến thiên và giới hạn.', N'Bổ sung bảng biến thiên và vẽ đồ thị.',
 N'Phần tìm cực trị chính xác, cho thêm 1 điểm.', 'REVIEWED', 1, @t2, DATEADD(DAY, -4, GETDATE()), DATEADD(DAY, -5, GETDATE())),
(@stu11, @l9, @e2, 'ESSAY', N'Đầy đủ: TXĐ, y'', BBT, giới hạn, điểm đặc biệt (0;2), (-2;0), (1;0). Đồ thị vẽ ở ảnh.',
 'https://placehold.co/800x600/png?text=Bai+lam+viet+tay+7', 9.00, 9.00,
 N'Bài làm đầy đủ và chính xác; đồ thị vẽ đẹp.', NULL,
 N'Rất tốt!', 'REVIEWED', 1, @t2, DATEADD(DAY, -1, GETDATE()), DATEADD(DAY, -2, GETDATE()));

-- =====================================================================================================================
-- 7. TutorSessions + TutorMessages: ACTIVE (đang chờ nhập), COMPLETED, ABANDONED
-- =====================================================================================================================
DECLARE @q1 INT = (SELECT MIN(QuestionId) FROM Questions WHERE LessonId = @ls1 AND QuestionType = 'MCQ');   -- câu MCQ của phần dữ liệu tối thiểu ở đầu file
DECLARE @sid INT;

-- Phiên 1: student1, mở từ câu trắc nghiệm làm sai, ACTIVE, AI đang chờ nhập nghiệm (bước 2/4)
INSERT INTO TutorSessions (StudentId, LessonId, QuestionId, Title, ProblemText, CurrentStep, TotalSteps, [Status], AwaitingInput, InputHint, CreatedAt, UpdatedAt)
VALUES (@stu1, @ls1, @q1, N'Cho hàm số $y = x^3 - 3x + 1$. Hàm số đồng biến trên khoảng nào?',
        N'Cho hàm số $y = x^3 - 3x + 1$. Hàm số đồng biến trên khoảng nào?', 2, 4, 'ACTIVE', 1, N'Nhập nghiệm của phương trình y'' = 0',
        DATEADD(MINUTE, -50, GETDATE()), DATEADD(MINUTE, -45, GETDATE()));
SET @sid = SCOPE_IDENTITY();
INSERT INTO TutorMessages (SessionId, SenderType, StepNumber, ContentText, IsStepCompleted, CreatedAt) VALUES
(@sid, 'USER', 1, N'Em đã chọn sai đáp án câu này, nhờ gia sư hướng dẫn từng bước.', 0, DATEADD(MINUTE, -50, GETDATE())),
(@sid, 'AI',   1, N'Chào em! Mình cùng làm từng bước nhé. **Bước 1:** Hàm số đồng biến khi $y^{\prime} \ge 0$. Em hãy tính đạo hàm $y^{\prime}$ của $y = x^3 - 3x + 1$.', 0, DATEADD(MINUTE, -50, GETDATE())),
(@sid, 'USER', 1, N'$y^{\prime} = 3x^2 - 3$', 0, DATEADD(MINUTE, -46, GETDATE())),
(@sid, 'AI',   2, N'Chính xác! **Bước 2:** Giải phương trình $y^{\prime} = 0$ để tìm các điểm tới hạn, sau đó xét dấu $y^{\prime}$. Em hãy nhập nghiệm của phương trình.', 1, DATEADD(MINUTE, -45, GETDATE()));

-- Phiên 2: student2, bài toán tự do (không gắn câu hỏi), COMPLETED
INSERT INTO TutorSessions (StudentId, LessonId, QuestionId, Title, ProblemText, CurrentStep, TotalSteps, [Status], AwaitingInput, InputHint, CreatedAt, UpdatedAt)
VALUES (@stu2, @ls3, NULL, N'Rút gọn biểu thức $A = \dfrac{a^5 \cdot a^{-2}}{a^2}$ với $a \ne 0$.',
        N'Rút gọn biểu thức $A = \dfrac{a^5 \cdot a^{-2}}{a^2}$ với $a \ne 0$.', 3, 3, 'COMPLETED', 0, NULL,
        DATEADD(DAY, -1, GETDATE()), DATEADD(DAY, -1, DATEADD(MINUTE, 12, GETDATE())));
SET @sid = SCOPE_IDENTITY();
INSERT INTO TutorMessages (SessionId, SenderType, StepNumber, ContentText, IsStepCompleted, CreatedAt) VALUES
(@sid, 'USER', 1, N'Em chưa biết rút gọn biểu thức này như thế nào.', 0, DATEADD(DAY, -1, GETDATE())),
(@sid, 'AI',   1, N'**Bước 1:** Với cùng cơ số, $a^m \cdot a^n = a^{m+n}$. Em hãy rút gọn tử số $a^5 \cdot a^{-2}$.', 0, DATEADD(DAY, -1, GETDATE())),
(@sid, 'USER', 1, N'$a^{5 + (-2)} = a^3$', 0, DATEADD(DAY, -1, DATEADD(MINUTE, 4, GETDATE()))),
(@sid, 'AI',   2, N'Đúng rồi! **Bước 2:** Dùng $\dfrac{a^m}{a^n} = a^{m-n}$. Em hãy chia $a^3$ cho $a^2$.', 1, DATEADD(DAY, -1, DATEADD(MINUTE, 4, GETDATE()))),
(@sid, 'USER', 2, N'$a^{3-2} = a$', 0, DATEADD(DAY, -1, DATEADD(MINUTE, 9, GETDATE()))),
(@sid, 'AI',   3, N'Chính xác! **Tổng kết:** $A = a^{5-2-2} = a$. Em đã nắm vững quy tắc nhân, chia lũy thừa cùng cơ số.', 1, DATEADD(DAY, -1, DATEADD(MINUTE, 9, GETDATE())));

-- Phiên 3: student3, bỏ dở (ABANDONED) ở bước 2/4
INSERT INTO TutorSessions (StudentId, LessonId, QuestionId, Title, ProblemText, CurrentStep, TotalSteps, [Status], AwaitingInput, InputHint, CreatedAt, UpdatedAt)
VALUES (@stu3, @l6, NULL, N'Tính $\log_3 27 + \log_2 8$.', N'Tính $\log_3 27 + \log_2 8$.', 2, 4, 'ABANDONED', 0, NULL,
        DATEADD(DAY, -3, GETDATE()), DATEADD(DAY, -3, DATEADD(MINUTE, 6, GETDATE())));
SET @sid = SCOPE_IDENTITY();
INSERT INTO TutorMessages (SessionId, SenderType, StepNumber, ContentText, IsStepCompleted, CreatedAt) VALUES
(@sid, 'USER', 1, N'Hướng dẫn em tính $\log_3 27 + \log_2 8$ với.', 0, DATEADD(DAY, -3, GETDATE())),
(@sid, 'AI',   1, N'**Bước 1:** Nhớ lại $\log_a b = c \Leftrightarrow a^c = b$. Em hãy tính $\log_3 27$.', 0, DATEADD(DAY, -3, GETDATE())),
(@sid, 'USER', 1, N'$\log_3 27 = 3$', 0, DATEADD(DAY, -3, DATEADD(MINUTE, 3, GETDATE()))),
(@sid, 'AI',   2, N'Đúng! **Bước 2:** Tương tự, em hãy tính $\log_2 8$.', 1, DATEADD(DAY, -3, DATEADD(MINUTE, 3, GETDATE())));

-- Phiên 4: student1, COMPLETED, bài phương trình mũ
INSERT INTO TutorSessions (StudentId, LessonId, QuestionId, Title, ProblemText, CurrentStep, TotalSteps, [Status], AwaitingInput, InputHint, CreatedAt, UpdatedAt)
VALUES (@stu1, @l7, NULL, N'Giải phương trình $2^x = 32$.', N'Giải phương trình $2^x = 32$.', 3, 3, 'COMPLETED', 0, NULL,
        DATEADD(DAY, -4, GETDATE()), DATEADD(DAY, -4, DATEADD(MINUTE, 10, GETDATE())));
SET @sid = SCOPE_IDENTITY();
INSERT INTO TutorMessages (SessionId, SenderType, StepNumber, ContentText, IsStepCompleted, CreatedAt) VALUES
(@sid, 'USER', 1, N'Giải giúp em phương trình $2^x = 32$.', 0, DATEADD(DAY, -4, GETDATE())),
(@sid, 'AI',   1, N'**Bước 1:** Hãy đưa hai vế về cùng cơ số 2: viết $32$ dưới dạng lũy thừa của $2$.', 0, DATEADD(DAY, -4, GETDATE())),
(@sid, 'USER', 1, N'$32 = 2^5$', 0, DATEADD(DAY, -4, DATEADD(MINUTE, 3, GETDATE()))),
(@sid, 'AI',   2, N'Chính xác! **Bước 2:** Khi hai vế cùng cơ số, ta có $2^x = 2^5$. Từ đó suy ra $x$ bằng bao nhiêu?', 1, DATEADD(DAY, -4, DATEADD(MINUTE, 3, GETDATE()))),
(@sid, 'USER', 2, N'$x = 5$', 0, DATEADD(DAY, -4, DATEADD(MINUTE, 6, GETDATE()))),
(@sid, 'AI',   3, N'Đúng rồi! **Tổng kết:** $2^x = 32 \Leftrightarrow x = 5$. Tập nghiệm là $\{5\}$.', 1, DATEADD(DAY, -4, DATEADD(MINUTE, 6, GETDATE())));

-- Phiên 5: student4, ACTIVE, AI vừa mở bài (bước 1/4, chưa chờ nhập số liệu)
INSERT INTO TutorSessions (StudentId, LessonId, QuestionId, Title, ProblemText, CurrentStep, TotalSteps, [Status], AwaitingInput, InputHint, CreatedAt, UpdatedAt)
VALUES (@stu4, @l4, NULL, N'Tìm giá trị lớn nhất của hàm số $y = -x^2 + 4x + 1$.', N'Tìm giá trị lớn nhất của hàm số $y = -x^2 + 4x + 1$.',
        1, 4, 'ACTIVE', 0, NULL, DATEADD(MINUTE, -20, GETDATE()), DATEADD(MINUTE, -20, GETDATE()));
SET @sid = SCOPE_IDENTITY();
INSERT INTO TutorMessages (SessionId, SenderType, StepNumber, ContentText, IsStepCompleted, CreatedAt) VALUES
(@sid, 'USER', 1, N'Tìm giá trị lớn nhất của hàm số $y = -x^2 + 4x + 1$.', 0, DATEADD(MINUTE, -20, GETDATE())),
(@sid, 'AI',   1, N'**Bước 1:** Hệ số $a = -1 < 0$ nên parabol quay xuống và có giá trị lớn nhất tại đỉnh. Em hãy tính hoành độ đỉnh $x = -\dfrac{b}{2a}$.', 0, DATEADD(MINUTE, -20, GETDATE()));

-- Phiên 6: student5, mở từ bài tự luận vừa chấm (gắn câu hỏi tự luận), COMPLETED
INSERT INTO TutorSessions (StudentId, LessonId, QuestionId, Title, ProblemText, CurrentStep, TotalSteps, [Status], AwaitingInput, InputHint, CreatedAt, UpdatedAt)
VALUES (@stu5, @l7, @e4, N'Giải phương trình $\log_2 (x - 1) + \log_2 (x + 1) = 3$.', N'Giải phương trình $\log_2 (x - 1) + \log_2 (x + 1) = 3$.',
        3, 3, 'COMPLETED', 0, NULL, DATEADD(DAY, -2, GETDATE()), DATEADD(DAY, -2, DATEADD(MINUTE, 11, GETDATE())));
SET @sid = SCOPE_IDENTITY();
INSERT INTO TutorMessages (SessionId, SenderType, StepNumber, ContentText, IsStepCompleted, CreatedAt) VALUES
(@sid, 'USER', 1, N'Em muốn xem lại cách giải bài tự luận vừa nộp.', 0, DATEADD(DAY, -2, GETDATE())),
(@sid, 'AI',   1, N'**Bước 1:** Tìm điều kiện xác định của phương trình. Em hãy nêu điều kiện của $x$.', 0, DATEADD(DAY, -2, GETDATE())),
(@sid, 'USER', 1, N'$x > 1$', 0, DATEADD(DAY, -2, DATEADD(MINUTE, 3, GETDATE()))),
(@sid, 'AI',   2, N'Đúng! **Bước 2:** Gộp hai lôgarit: $\log_2 [(x-1)(x+1)] = 3$. Em hãy suy ra phương trình bậc hai theo $x$.', 1, DATEADD(DAY, -2, DATEADD(MINUTE, 3, GETDATE()))),
(@sid, 'USER', 2, N'$x^2 - 1 = 8$ nên $x = \pm 3$, loại $x = -3$ vì không thỏa $x > 1$.', 0, DATEADD(DAY, -2, DATEADD(MINUTE, 8, GETDATE()))),
(@sid, 'AI',   3, N'Chính xác! **Tổng kết:** nghiệm duy nhất là $x = 3$.', 1, DATEADD(DAY, -2, DATEADD(MINUTE, 8, GETDATE())));

DROP TABLE #N;
DROP TABLE #St;
DROP TABLE #Mq;
DROP TABLE #Map;
DROP TABLE #Q;

-- =====================================================================================================================
-- Tóm tắt
-- =====================================================================================================================
SELECT N'Users' AS [Bảng], COUNT(*) AS [Số dòng] FROM Users
UNION ALL SELECT N'Topics', COUNT(*) FROM Topics
UNION ALL SELECT N'Lessons', COUNT(*) FROM Lessons
UNION ALL SELECT N'LessonMaterials', COUNT(*) FROM LessonMaterials
UNION ALL SELECT N'Questions', COUNT(*) FROM Questions
UNION ALL SELECT N'QuestionOptions', COUNT(*) FROM QuestionOptions
UNION ALL SELECT N'Submissions', COUNT(*) FROM Submissions
UNION ALL SELECT N'TutorSessions', COUNT(*) FROM TutorSessions
UNION ALL SELECT N'TutorMessages', COUNT(*) FROM TutorMessages;
GO
