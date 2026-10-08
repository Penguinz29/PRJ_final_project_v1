-- =====================================================================================================================
-- File: document/sql/04_data_sgk_toan12.sql — nội dung theo SGK Toán 12 (bộ Kết nối tri thức với cuộc sống, Tập 1 + Tập 2)
-- Chạy SAU 01_schema.sql, 02_data.sql (và 03_data_gdpt2018.sql nếu muốn; 04 sẽ xóa nội dung của 02/03 rồi thay mới).
-- CẢNH BÁO: script XÓA TOÀN BỘ chủ đề / bài học / bài giảng / câu hỏi / bài làm / phiên gia sư AI cũ (dữ liệu demo của 02 và 03),
--           rồi nạp lại theo sách giáo khoa. GIỮ NGUYÊN Users và AiConfigs. Chạy lại lần 2 sẽ tự bỏ qua (không nhân đôi).
-- Cấu trúc: mỗi CHƯƠNG của sách = 1 chủ đề (Topics); mỗi BÀI = 1 bài học (Lessons, Content là tóm tắt lý thuyết trọng tâm);
--           mục "Bài tập" cuối bài và "Bài tập cuối chương" của sách thành câu hỏi: câu trắc nghiệm của sách = MCQ (4 phương án, có đáp án và lời giải ngắn),
--           các bài còn lại = TỰ LUẬN (ESSAY, chưa có lời giải). Sách không in đáp án nên đáp án MCQ do người số hóa tự giải và kiểm chứng.
-- Toàn bộ chủ đề / bài học / câu hỏi thuộc teacher1 (giáo viên chỉ thấy chủ đề của mình; Admin thấy tất cả).
-- Chủ đề hiển thị theo CreatedAt giảm dần nên script chèn theo thứ tự ngược (Ôn tập → Chương VI → ... → Chương I): Chương I nằm trên cùng.
-- Mức độ (Level 1-3) do người số hóa tự đánh giá, giáo viên có thể chỉnh trên giao diện.
-- Đề có hình vẽ / đồ thị / bảng biến thiên trong SGK được gắn ảnh cắt từ sách: thẻ <img src="/static/img/sgk/..."> (32 ảnh trong src/main/webapp/static/img/sgk).
-- Cần bản mã nguồn có HtmlSanitizer hỗ trợ <img> (đã sửa cùng đợt) và triển khai lại WAR kèm thư mục ảnh.
-- Riêng câu 6.17 sách in thiếu đáp án đúng (đáp số là 4/15) nên được giữ ở dạng tự luận.
-- Tổng: 7 chủ đề, 26 bài học, 63 câu trắc nghiệm, 182 câu tự luận.
-- =====================================================================================================================
USE MathTutorDB;
GO

SET NOCOUNT ON;

IF EXISTS (SELECT 1 FROM Topics WHERE TopicName = N'Chương I. Ứng dụng đạo hàm để khảo sát và vẽ đồ thị hàm số')
BEGIN
    PRINT N'04_data_sgk_toan12.sql đã được chạy trước đó: bỏ qua.';
    RETURN;
END

DECLARE @t1 INT = (SELECT UserId FROM Users WHERE Username = 'teacher1');
DECLARE @tp INT, @l INT, @q INT;

BEGIN TRANSACTION;

-- 1. Xóa nội dung cũ (theo thứ tự khóa ngoại). TutorMessages / LessonMaterials / QuestionOptions / Lessons / Questions xóa dây chuyền.
DELETE FROM TutorSessions;
DELETE FROM Submissions;
DELETE FROM Topics;


-- ---------------------------------------------------------------------------------------------------------------------
-- Ôn tập cuối năm
-- ---------------------------------------------------------------------------------------------------------------------
INSERT INTO Topics (TopicName, [Description], TeacherId, OrderIndex, IsActive) VALUES (N'Ôn tập cuối năm', N'Bài tập ôn tập tổng hợp cuối năm gồm các nội dung Giải tích, Hình học không gian, Thống kê và Xác suất của chương trình Toán 12. (SGK Toán 12 Kết nối tri thức với cuộc sống, Tập 2)', @t1, 7, 1);
SET @tp = SCOPE_IDENTITY();
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài tập ôn tập cuối năm', N'Bài tập tổng hợp trắc nghiệm và tự luận ôn tập kiến thức cả năm: khảo sát hàm số, nguyên hàm - tích phân, vectơ và hình học Oxyz, thống kê, xác suất.', N'<p>Phần bài tập tổng hợp ôn tập toàn bộ kiến thức Toán 12 cuối năm (trắc nghiệm và tự luận).</p>', 1, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 1.</b> Khoảng nghịch biến của hàm số $y=x^3-6x^2+9x+1$ là</p>', N'<p>$y''=3x^2-12x+9=3(x-1)(x-3)$, $y''\lt 0$ khi $1\lt x\lt 3$. Hàm nghịch biến trên $(1;3)$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$(-\infty;1)$.', 0),
(@q, 'B', N'$(3;+\infty)$.', 0),
(@q, 'C', N'$(1;3)$.', 1),
(@q, 'D', N'$(-\infty;+\infty)$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 2.</b> Giá trị lớn nhất $M$ của hàm số $y=\dfrac{x^2+3}{x-1}$ trên đoạn $[2;4]$ là</p>', N'<p>$y''=\dfrac{x^2-2x-3}{(x-1)^2}=0\Rightarrow x=3$ (thuộc $[2;4]$). $y(2)=7$, $y(3)=6$, $y(4)=\dfrac{19}{3}$. Vậy $M=7$.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$M=6$.', 0),
(@q, 'B', N'$M=7$.', 1),
(@q, 'C', N'$M=\dfrac{19}{3}$.', 0),
(@q, 'D', N'$M=\dfrac{20}{3}$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 3.</b> Tổng số các đường tiệm cận của đồ thị hàm số $y=\dfrac{\sqrt{x^2-1}}{x}$ là</p>', N'<p>Tập xác định $|x|\ge 1$ nên không có tiệm cận đứng. $\lim_{x\to\pm\infty}y=\pm1$ nên có 2 tiệm cận ngang $y=1$, $y=-1$. Tổng cộng 2.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'0.', 0),
(@q, 'B', N'1.', 0),
(@q, 'C', N'2.', 1),
(@q, 'D', N'3.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 4.</b> Đường cong trong hình bên là đồ thị của một trong bốn hàm số dưới đây. Hàm số đó là hàm số nào? <div><img src="/static/img/sgk/on-tap-4.png" alt="Hình minh họa bài 4 (SGK)"></div></p>', N'<p>Đồ thị bậc ba có hệ số $a\gt0$ (nhánh phải đi lên), cực đại tại $x=0$ với $y=3$, cực tiểu ở bên phải. Hàm $y=x^3-3x^2+3$ có $y''=3x(x-2)$, cực đại $(0;3)$, cực tiểu $(2;-1)$ nên khớp hình.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$y=-x^3+3x^2+1$.', 0),
(@q, 'B', N'$y=x^3-3x^2+3$.', 1),
(@q, 'C', N'$y=-x^2+2x+1$.', 0),
(@q, 'D', N'$y=\dfrac{x+1}{x-1}$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 5.</b> Cho hàm số $f(x)=x^2+3$. Khẳng định nào dưới đây là đúng?</p>', N'<p>$\int (x^2+3)\,dx=\dfrac{x^3}{3}+3x+C$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$\displaystyle\int f(x)\,\mathrm{d}x=2x+C$.', 0),
(@q, 'B', N'$\displaystyle\int f(x)\,\mathrm{d}x=x^2+3x+C$.', 0),
(@q, 'C', N'$\displaystyle\int f(x)\,\mathrm{d}x=x^3+3x+C$.', 0),
(@q, 'D', N'$\displaystyle\int f(x)\,\mathrm{d}x=\dfrac{x^3}{3}+3x+C$.', 1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 6.</b> Cho hàm số $f(x)$ thoả mãn $f(0)=1$ và $f''(x)=2\sin x+1$. Khi đó $\displaystyle\int_0^{\pi/2} f(x)\,\mathrm{d}x$ bằng</p>', N'<p>$f(x)=-2\cos x+x+C$, $f(0)=1\Rightarrow C=3$. $\int_0^{\pi/2}(-2\cos x+x+3)dx=-2+\dfrac{\pi^2}{8}+\dfrac{3\pi}{2}=\dfrac{\pi^2+12\pi-16}{8}$.</p>', 3, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$\dfrac{\pi^2+12\pi-16}{8}$.', 1),
(@q, 'B', N'$\dfrac{\pi^2-4\pi+16}{8}$.', 0),
(@q, 'C', N'$\dfrac{\pi^2+6\pi-8}{4}$.', 0),
(@q, 'D', N'$\dfrac{\pi^2-2\pi+8}{4}$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 7.</b> Cho hàm số $f(x)$ liên tục trên $\mathbb{R}$. Gọi $S$ là diện tích hình phẳng giới hạn bởi các đường $y=f(x)$, $y=0$, $x=-1$ và $x=4$ như hình bên. <div><img src="/static/img/sgk/on-tap-7.png" alt="Hình minh họa bài 7 (SGK)"></div> Khẳng định nào dưới đây là đúng?</p>', N'<p>Trên $[-1;1]$ đồ thị nằm trên trục hoành ($f\ge0$), trên $[1;4]$ nằm dưới ($f\le0$). Vậy $S=\int_{-1}^{1}f\,dx-\int_{1}^{4}f\,dx$.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$S=\displaystyle\int_{-1}^{1}f(x)\,\mathrm{d}x+\int_{1}^{4}f(x)\,\mathrm{d}x$.', 0),
(@q, 'B', N'$S=\displaystyle\int_{-1}^{1}f(x)\,\mathrm{d}x-\int_{1}^{4}f(x)\,\mathrm{d}x$.', 1),
(@q, 'C', N'$S=-\displaystyle\int_{-1}^{1}f(x)\,\mathrm{d}x+\int_{1}^{4}f(x)\,\mathrm{d}x$.', 0),
(@q, 'D', N'$S=-\displaystyle\int_{-1}^{1}f(x)\,\mathrm{d}x-\int_{1}^{4}f(x)\,\mathrm{d}x$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 8.</b> Gọi $(H)$ là hình phẳng giới hạn bởi các đường $y=2\sqrt{x}$, $y=0$, $x=0$ và $x=4$. Thể tích $V$ của khối tròn xoay sinh ra khi quay hình phẳng $(H)$ quanh trục $Ox$ là</p>', N'<p>$V=\pi\int_0^4 (2\sqrt{x})^2dx=\pi\int_0^4 4x\,dx=\pi\cdot 2x^2\Big|_0^4=32\pi$.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$V=32$.', 0),
(@q, 'B', N'$V=32\pi$.', 1),
(@q, 'C', N'$V=\dfrac{32}{3}$.', 0),
(@q, 'D', N'$V=\dfrac{32\pi}{3}$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 9.</b> Cho tứ diện $ABCD$, gọi $G$ là trọng tâm của tam giác $BCD$ và $M$ là trung điểm của đoạn thẳng $AG$. Khi đó $\overrightarrow{MA}+\overrightarrow{MB}+\overrightarrow{MC}+\overrightarrow{MD}$ bằng</p>', N'<p>$G$ là trọng tâm $BCD$ nên $\overrightarrow{MB}+\overrightarrow{MC}+\overrightarrow{MD}=3\overrightarrow{MG}$. $M$ là trung điểm $AG$ nên $\overrightarrow{MA}=-\overrightarrow{MG}$. Tổng $=2\overrightarrow{MG}$.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$\overrightarrow{MG}$.', 0),
(@q, 'B', N'$2\overrightarrow{MG}$.', 1),
(@q, 'C', N'$3\overrightarrow{MG}$.', 0),
(@q, 'D', N'$4\overrightarrow{MG}$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 10.</b> Cho hình hộp $ABCD.A''B''C''D''$ có tâm $O$ và gọi $G$ là trọng tâm của tam giác $BDA''$. Tỉ số $\dfrac{AG}{AO}$ bằng</p>', N'<p>Đặt $\vec a=\overrightarrow{AB},\vec b=\overrightarrow{AD},\vec c=\overrightarrow{AA''}$. $\overrightarrow{AG}=\dfrac{\vec a+\vec b+\vec c}{3}$, $\overrightarrow{AO}=\dfrac{\vec a+\vec b+\vec c}{2}$. Tỉ số $=\dfrac{2}{3}$.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$\dfrac{1}{3}$.', 0),
(@q, 'B', N'$\dfrac{1}{2}$.', 0),
(@q, 'C', N'$\dfrac{2}{3}$.', 1),
(@q, 'D', N'$\dfrac{3}{4}$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 11.</b> Trong không gian $Oxyz$, cho đường thẳng $d:\begin{cases}x=2-t\\ y=3\\ z=-1+2t\end{cases}$ và mặt phẳng $(P): 2x-y-2z+1=0$. Côsin của góc giữa đường thẳng $d$ và mặt phẳng $(P)$ là</p>', N'<p>$\vec u=(-1;0;2)$, $\vec n=(2;-1;-2)$. $\sin\varphi=\dfrac{|\vec u\cdot\vec n|}{|\vec u||\vec n|}=\dfrac{6}{3\sqrt5}=\dfrac{2}{\sqrt5}$, nên $\cos\varphi=\sqrt{1-\dfrac45}=\dfrac{\sqrt5}{5}$.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$\dfrac{2\sqrt{5}}{5}$.', 0),
(@q, 'B', N'$\dfrac{\sqrt{5}}{5}$.', 1),
(@q, 'C', N'$\dfrac{2\sqrt{3}}{5}$.', 0),
(@q, 'D', N'$\dfrac{\sqrt{3}}{5}$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 12.</b> Trong không gian $Oxyz$, cho điểm $M(2;-1;3)$. Gọi $A$, $B$, $C$ lần lượt là hình chiếu vuông góc của $M$ trên các trục $Ox$, $Oy$, $Oz$. Phương trình mặt phẳng $(ABC)$ là</p>', N'<p>$A(2;0;0)$, $B(0;-1;0)$, $C(0;0;3)$. Phương trình đoạn chắn: $\dfrac x2-y+\dfrac z3=1\Leftrightarrow 3x-6y+2z-6=0$.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$3x-6y+2z+6=0$.', 0),
(@q, 'B', N'$3x-6y+2z-6=0$.', 1),
(@q, 'C', N'$3x-2y+2z-1=0$.', 0),
(@q, 'D', N'$3x-6y+2z-1=0$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 13a.</b> Thống kê thời gian trong tuần dành cho đọc sách của một số nhân viên trong một công ty được cho trong bảng sau:</p><table border="1"><tr><th>Thời gian (giờ)</th><td>[0; 2)</td><td>[2; 4)</td><td>[4; 6)</td><td>[6; 8)</td><td>[8; 10)</td></tr><tr><th>Số nhân viên</th><td>3</td><td>8</td><td>15</td><td>7</td><td>2</td></tr></table><p>a) Khoảng biến thiên của mẫu số liệu ghép nhóm này là</p>', N'<p>Khoảng biến thiên = đầu mút phải nhóm cuối trừ đầu mút trái nhóm đầu $=10-0=10$.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'13.', 0),
(@q, 'B', N'10.', 1),
(@q, 'C', N'8.', 0),
(@q, 'D', N'6.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 13b.</b> Thống kê thời gian trong tuần dành cho đọc sách của một số nhân viên trong một công ty được cho trong bảng sau:</p><table border="1"><tr><th>Thời gian (giờ)</th><td>[0; 2)</td><td>[2; 4)</td><td>[4; 6)</td><td>[6; 8)</td><td>[8; 10)</td></tr><tr><th>Số nhân viên</th><td>3</td><td>8</td><td>15</td><td>7</td><td>2</td></tr></table><p>b) Độ lệch chuẩn của mẫu số liệu ghép nhóm này là (làm tròn kết quả đến hàng phần trăm)</p>', N'<p>Giá trị đại diện $1;3;5;7;9$, $n=35$. $\bar x=\dfrac{169}{35}\approx4{,}83$; $\overline{x^2}=\dfrac{955}{35}\approx27{,}29$. $s^2\approx27{,}2857-23{,}3159\approx3{,}97$, $s\approx1{,}99$.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'1,99.', 1),
(@q, 'B', N'2,02.', 0),
(@q, 'C', N'3,97.', 0),
(@q, 'D', N'4,09.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 14.</b> Trong một nhóm 25 người, có 15 người thích uống trà, 17 người thích uống cà phê, 9 người thích uống cả cà phê và trà. Chọn ngẫu nhiên một người trong nhóm. Biết rằng người đó thích uống cà phê. Xác suất để người đó thích uống trà là</p>', N'<p>$P(\text{trà}\mid\text{cà phê})=\dfrac{n(\text{trà}\cap\text{cà phê})}{n(\text{cà phê})}=\dfrac{9}{17}$.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$\dfrac{9}{17}$.', 1),
(@q, 'B', N'$\dfrac{8}{17}$.', 0),
(@q, 'C', N'$\dfrac{9}{19}$.', 0),
(@q, 'D', N'$\dfrac{10}{19}$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 15.</b> Trong số 40 học sinh lớp 12A, có 22 em đăng kí thi ngành Kinh tế, 25 em đăng kí thi ngành Luật, 3 em không đăng kí thi cả hai ngành này. Chọn ngẫu nhiên một học sinh, biết rằng em đó đăng kí thi ngành Luật. Xác suất để em đó đăng kí thi ngành Kinh tế là</p>', N'<p>Số em đăng kí ít nhất một ngành là $37$, nên số em đăng kí cả hai là $22+25-37=10$. $P=\dfrac{10}{25}=\dfrac25$.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$\dfrac{3}{5}$.', 0),
(@q, 'B', N'$\dfrac{2}{5}$.', 1),
(@q, 'C', N'$\dfrac{3}{7}$.', 0),
(@q, 'D', N'$\dfrac{4}{7}$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 16.</b> Khảo sát sự biến thiên và vẽ đồ thị của các hàm số sau:</p><ol type="a"><li>$y=x^3-3x^2$;</li><li>$y=\dfrac{2x+1}{x+2}$;</li><li>$y=\dfrac{2x^2+x-2}{x-1}$.</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 17.</b> Tìm giá trị lớn nhất và giá trị nhỏ nhất của các hàm số sau:</p><ol type="a"><li>$y=\dfrac{x+1}{\sqrt{x^2+1}}$ trên đoạn $[-1;2]$;</li><li>$y=x+\sqrt{1-x^2}$.</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 18.</b> Khi đạp phanh thì một ô tô chuyển động chậm dần đều với gia tốc có độ lớn $10\ \mathrm{m/s^2}$.</p><ol type="a"><li>Nếu khi bắt đầu đạp phanh ô tô đang chạy với vận tốc 54 km/h thì sau bao lâu kể từ khi đạp phanh, ô tô sẽ dừng lại?</li><li>Nếu ô tô dừng lại trong vòng 20 m sau khi đạp phanh thì vận tốc lớn nhất của ô tô ngay trước lúc đạp phanh (tính bằng km/h) có thể là bao nhiêu?</li></ol>', NULL, 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 19.</b> Tìm hàm số $f(x)$ biết rằng $f''(x)=x-\dfrac{1}{x^2}+2$ và $f(1)=2$.</p>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 20.</b> Tính các tích phân sau:</p><ol type="a"><li>$I=\displaystyle\int_0^2 \left|x^2-x\right|\mathrm{d}x$;</li><li>$I=\displaystyle\int_0^1 (2x-1)^3\,\mathrm{d}x$;</li><li>$I=\displaystyle\int_0^{\pi/4}\left(3\sin x-\dfrac{2}{\cos^2 x}\right)\mathrm{d}x$;</li><li>$I=\displaystyle\int_1^2\left(2e^x-\dfrac{1}{x}\right)\mathrm{d}x$.</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 21.</b> Tính diện tích hình phẳng giới hạn bởi các đường $y=x^2-1$, $y=x+5$, $x=-2$, $x=3$.</p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 22.</b> Gọi $(H)$ là hình phẳng giới hạn bởi các đường $y=-x^2+2x$, $y=0$, $x=0$ và $x=2$. Tính thể tích của khối tròn xoay thu được khi quay hình phẳng $(H)$ xung quanh trục $Ox$.</p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 23.</b> Cho tứ diện $ABCD$, chứng minh rằng:</p><ol type="a"><li>$\overrightarrow{AB}\cdot\overrightarrow{CD}+\overrightarrow{AC}\cdot\overrightarrow{DB}+\overrightarrow{AD}\cdot\overrightarrow{BC}=0$;</li><li>Nếu $AB\perp CD$ và $AC\perp BD$ thì $AD\perp BC$.</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 24.</b> Cho hình lập phương $ABCD.A''B''C''D''$ có cạnh bằng $a$. Gọi $G$ là trọng tâm của tam giác $BC''D''$.</p><ol type="a"><li>Chứng minh rằng $\overrightarrow{AG}=\dfrac{2}{3}\left(\overrightarrow{AB}+\overrightarrow{AD}+\overrightarrow{AA''}\right)$.</li><li>Tính theo $a$ độ dài đoạn thẳng $AG$.</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 25.</b> Trong không gian $Oxyz$, cho điểm $I(-1;2;1)$ và mặt phẳng $(P): 2x-2y-z-5=0$. Viết phương trình đường thẳng $d$ đi qua $I$ và vuông góc với mặt phẳng $(P)$.</p>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 26.</b> Trong không gian $Oxyz$, cho điểm $A(-1;1;2)$ và đường thẳng $d:\begin{cases}x=2+t\\ y=3-2t\\ z=-1+2t.\end{cases}$</p><ol type="a"><li>Viết phương trình đường thẳng $d''$ đi qua $A$ và song song với đường thẳng $d$.</li><li>Viết phương trình mặt phẳng $(P)$ chứa điểm $A$ và đường thẳng $d$.</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 27.</b> Trong không gian $Oxyz$, cho hai điểm $A(1;-2;3)$, $B(3;0;-1)$.</p><ol type="a"><li>Viết phương trình mặt phẳng $(OAB)$.</li><li>Tìm toạ độ trung điểm $I$ của đoạn thẳng $AB$.</li><li>Tìm điểm $M$ thuộc mặt phẳng $(Oxy)$ sao cho $\left|\overrightarrow{MA}+\overrightarrow{MB}\right|$ nhỏ nhất.</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 28.</b> Trong không gian $Oxyz$, có một nguồn sáng phát ra từ điểm $S(2;3;5)$ và một đoạn dây thẳng nối từ điểm $A(1;2;1)$ đến điểm $B(3;1;2)$. Dưới nguồn sáng, đoạn dây trên có bóng trên mặt phẳng $(xOy)$ là một đoạn thẳng. Tính độ dài đoạn thẳng đó.</p>', NULL, 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 29.</b> Thu nhập của người lao động trong một công ty được cho trong bảng sau:</p><table border="1"><tr><th>Mức thu nhập (triệu đồng)</th><td>[8; 10)</td><td>[10; 12)</td><td>[12; 14)</td><td>[14; 16)</td><td>[16; 18)</td></tr><tr><th>Số người</th><td>2</td><td>60</td><td>90</td><td>50</td><td>1</td></tr></table><p>Tính khoảng tứ phân vị cho mẫu số liệu này.</p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 30.</b> Có hai chuồng nuôi gà. Chuồng I có 8 con gà trống và 13 con gà mái. Chuồng II có 10 con gà trống và 6 con gà mái. An bắt ngẫu nhiên một con gà từ chuồng II đem thả vào chuồng I. Sau đó, Bình bắt ngẫu nhiên một con gà từ chuồng I.</p><p>Giả sử Bình bắt được con gà mái. Tính xác suất để Bình bắt được con gà mái của chuồng I.</p>', NULL, 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 31.</b> Trong một tuần, Sơn chọn ngẫu nhiên ba ngày chạy bộ buổi sáng. Nếu chạy bộ thì xác suất Sơn ăn thêm một quả trứng vào bữa sáng hôm đó là 0,7. Nếu không chạy bộ thì xác suất Sơn ăn thêm một quả trứng vào bữa sáng hôm đó là 0,25. Chọn ngẫu nhiên một ngày trong tuần của Sơn. Tính xác suất để hôm đó Sơn chạy bộ nếu biết rằng bữa sáng hôm đó Sơn có ăn thêm một quả trứng.</p>', NULL, 3, 0, 1, @t1);

-- ---------------------------------------------------------------------------------------------------------------------
-- Chương VI. Xác suất có điều kiện
-- ---------------------------------------------------------------------------------------------------------------------
INSERT INTO Topics (TopicName, [Description], TeacherId, OrderIndex, IsActive) VALUES (N'Chương VI. Xác suất có điều kiện', N'Chương giới thiệu khái niệm xác suất có điều kiện, công thức nhân xác suất, công thức xác suất toàn phần và công thức Bayes cùng các ứng dụng thực tiễn. (SGK Toán 12 Kết nối tri thức với cuộc sống, Tập 2)', @t1, 6, 1);
SET @tp = SCOPE_IDENTITY();
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 18. Xác suất có điều kiện', N'Khái niệm xác suất có điều kiện P(A|B), công thức tính, bảng dữ liệu thống kê 2x2 và công thức nhân xác suất; liên hệ với tính độc lập của hai biến cố.', N'<p><b>1. Xác suất có điều kiện.</b> Cho hai biến cố $A$ và $B$. Xác suất của biến cố $A$, được tính khi biết biến cố $B$ đã xảy ra, được gọi là <b>xác suất của $A$ với điều kiện $B$</b> và kí hiệu là $P(A\mid B)$.</p>
<p><b>Công thức:</b> Cho hai biến cố $A$ và $B$ bất kì, với $P(B)>0$. Khi đó
$$P(A\mid B)=\dfrac{P(AB)}{P(B)}.$$</p>
<p><b>Nếu $A$ và $B$ độc lập</b> (với $P(A)>0,\ P(B)>0$) thì $P(A\mid B)=P(A)$ và $P(B\mid A)=P(B)$.</p>
<p><b>Bảng dữ liệu thống kê $2\times 2$:</b> bảng gồm 2 dòng, 2 cột, thường dùng để tính xác suất có điều kiện bằng cách đếm số phần tử, $P(A\mid B)=\dfrac{n(AB)}{n(B)}$.</p>
<p><b>2. Công thức nhân xác suất.</b> Với hai biến cố $A$ và $B$ bất kì:
$$P(AB)=P(B)\cdot P(A\mid B).$$
<i>Chú ý:</i> nếu $P(B)=0$ thì $P(AB)=0$ nên công thức đúng với mọi biến cố $A$, $B$.</p>
<p><i>Nhận xét.</i> Vì $AB=BA$ nên ta cũng có $P(AB)=P(A)\cdot P(B\mid A)$. Nếu $A$, $B$ độc lập thì $P(AB)=P(A)\cdot P(B)$.</p>
<p><b>Ví dụ 1.</b> Một hộp có 20 viên bi trắng và 10 viên bi đen. Bình lấy ngẫu nhiên một viên bi, không trả lại; sau đó An lấy ngẫu nhiên một viên bi trong hộp. Gọi $A$: &ldquo;An lấy được bi trắng&rdquo;, $B$: &ldquo;Bình lấy được bi trắng&rdquo;. Tính $P(A\mid B)$.<br>
<i>Hướng giải:</i> nếu $B$ xảy ra thì trong hộp còn 29 viên bi gồm 19 trắng, 10 đen, nên $P(A\mid B)=\dfrac{19}{29}$. (Bằng công thức: $P(AB)=\dfrac{20\cdot 19}{30\cdot 29}$, $P(B)=\dfrac{20\cdot 29}{30\cdot 29}$, suy ra $P(A\mid B)=\dfrac{19}{29}$.)</p>
<p><b>Ví dụ 2.</b> Hộp kín có 7 bút bi xanh và 5 bút bi đen. Sơn lấy ngẫu nhiên một bút, không trả lại, sau đó Tùng lấy ngẫu nhiên một trong 11 bút còn lại. Tính xác suất để Sơn lấy bút đen và Tùng lấy bút xanh.<br>
<i>Hướng giải:</i> $A$: &ldquo;Sơn lấy bút đen&rdquo;, $B$: &ldquo;Tùng lấy bút xanh&rdquo;. $P(A)=\dfrac{5}{12}$, $P(B\mid A)=\dfrac{7}{11}$. Theo công thức nhân: $P(AB)=\dfrac{5}{12}\cdot\dfrac{7}{11}=\dfrac{35}{132}$. (Có thể mô tả bằng sơ đồ hình cây.)</p>', 1, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.1.</b> Một hộp kín đựng 20 tấm thẻ giống hệt nhau đánh số từ 1 đến 20. Một người rút ngẫu nhiên ra một tấm thẻ từ trong hộp. Người đó được thông báo rằng thẻ rút ra mang số chẵn. Tính xác suất để người đó rút được thẻ số 10.</p>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.2.</b> Cho $P(A)=0{,}2$; $P(B)=0{,}51$; $P(B\mid A)=0{,}8$. Tính $P(A\mid B)$.</p>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.3.</b> Gieo hai con xúc xắc cân đối, đồng chất. Tính xác suất để:</p>
<ol type="a"><li>Tổng số chấm xuất hiện trên hai con xúc xắc bằng 7 nếu biết rằng ít nhất có một con xúc xắc xuất hiện mặt 5 chấm;</li>
<li>Có ít nhất có một con xúc xắc xuất hiện mặt 5 chấm nếu biết rằng tổng số chấm xuất hiện trên hai con xúc xắc bằng 7.</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.4.</b> Gieo hai con xúc xắc cân đối, đồng chất. Tính xác suất để tổng số chấm xuất hiện trên hai con xúc xắc đó không nhỏ hơn 10 nếu biết rằng có ít nhất một con xúc xắc xuất hiện mặt 5 chấm.</p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.5.</b> Bạn An phải thực hiện hai thí nghiệm liên tiếp. Thí nghiệm thứ nhất có xác suất thành công là 0,7. Nếu thí nghiệm thứ nhất thành công thì xác suất thành công của thí nghiệm thứ hai là 0,9. Nếu thí nghiệm thứ nhất không thành công thì xác suất thành công của thí nghiệm thứ hai chỉ là 0,4. Tính xác suất để:</p>
<ol type="a"><li>Cả hai thí nghiệm đều thành công;</li>
<li>Cả hai thí nghiệm đều không thành công;</li>
<li>Thí nghiệm thứ nhất thành công và thí nghiệm thứ hai không thành công.</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.6.</b> Trong một túi có một số chiếc kẹo cùng loại, chỉ khác màu, trong đó có 6 cái kẹo màu cam, còn lại là kẹo màu vàng. Hà lấy ngẫu nhiên một cái kẹo từ trong túi, không trả lại. Sau đó Hà lại lấy ngẫu nhiên thêm một cái kẹo khác từ trong túi. Biết rằng xác suất Hà lấy được cả hai cái kẹo màu cam là $\dfrac{1}{3}$. Hỏi ban đầu trong túi có bao nhiêu cái kẹo?</p>', NULL, 3, 0, 1, @t1);
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 19. Công thức xác suất toàn phần và công thức Bayes', N'Công thức xác suất toàn phần, sơ đồ hình cây và công thức Bayes để cập nhật xác suất khi có thêm thông tin; ứng dụng trong y học, sản xuất, thi cử.', N'<p><b>1. Công thức xác suất toàn phần.</b> Cho hai biến cố $A$ và $B$. Khi đó
$$P(B)=P(A)\cdot P(B\mid A)+P(\overline{A})\cdot P(B\mid \overline{A}).$$
Công thức trên được gọi là <b>công thức xác suất toàn phần</b>.</p>
<p><i>Chú ý.</i> Có thể mô tả trực quan bằng <b>sơ đồ hình cây</b>: trên các nhánh $OA$, $O\overline{A}$ ghi $P(A)$, $P(\overline{A})$; trên các nhánh $AB$, $A\overline{B}$ ghi $P(B\mid A)$, $P(\overline{B}\mid A)$; trên các nhánh $\overline{A}B$, $\overline{A}\overline{B}$ ghi $P(B\mid \overline{A})$, $P(\overline{B}\mid \overline{A})$. Xác suất của $B$ bằng tổng xác suất theo các nhánh cây đi tới $B$.</p>
<p><b>2. Công thức Bayes.</b> Cho $A$ và $B$ là hai biến cố, với $P(B)>0$. Khi đó
$$P(A\mid B)=\dfrac{P(A)\cdot P(B\mid A)}{P(A)\cdot P(B\mid A)+P(\overline{A})\cdot P(B\mid \overline{A})}.$$
Công thức trên có tên là <b>công thức Bayes</b>. Do $P(B)=P(A)P(B\mid A)+P(\overline{A})P(B\mid \overline{A})$ nên công thức Bayes còn viết được dưới dạng
$$P(A\mid B)=\dfrac{P(A)\cdot P(B\mid A)}{P(B)}.$$</p>
<p><i>Ý nghĩa:</i> ban đầu $A$ có xác suất $P(A)$; khi biết thêm thông tin &ldquo;$B$ đã xảy ra&rdquo;, ta cập nhật hiểu biết về $A$ bằng cách tính $P(A\mid B)$. Cần phân biệt $P(A\mid B)$ với $P(B\mid A)$.</p>
<p><b>Ví dụ 1.</b> Ông An đi làm bằng xe máy hoặc xe buýt. Nếu hôm nay đi xe buýt thì xác suất hôm sau đi xe máy là 0,4; nếu hôm nay đi xe máy thì xác suất hôm sau đi xe buýt là 0,7. Thứ Hai ông An đi xe buýt. Tính xác suất thứ Tư ông đi xe máy.<br>
<i>Hướng giải:</i> $A$: &ldquo;Thứ Ba đi xe máy&rdquo;, $B$: &ldquo;Thứ Tư đi xe máy&rdquo;. $P(A)=0{,}4$, $P(\overline{A})=0{,}6$, $P(B\mid A)=1-0{,}7=0{,}3$, $P(B\mid \overline{A})=0{,}4$. Vậy $P(B)=0{,}4\cdot 0{,}3+0{,}6\cdot 0{,}4=0{,}36$.</p>
<p><b>Ví dụ 2.</b> Một tỉnh có 80% học sinh chọn tổ hợp A00. Nếu chọn A00 thì xác suất đỗ đại học là 0,6; nếu không chọn A00 thì là 0,7. Chọn ngẫu nhiên một học sinh đã đỗ đại học. Tính xác suất học sinh đó chọn tổ hợp A00.<br>
<i>Hướng giải:</i> $A$: &ldquo;chọn A00&rdquo;, $B$: &ldquo;đỗ đại học&rdquo;. Theo công thức Bayes: $P(A\mid B)=\dfrac{0{,}8\cdot 0{,}6}{0{,}8\cdot 0{,}6+0{,}2\cdot 0{,}7}\approx 0{,}7742$.</p>', 2, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.7.</b> Trong quân sự, một máy bay chiến đấu của đối phương có thể xuất hiện ở vị trí X với xác suất 0,55. Nếu máy bay đó không xuất hiện ở vị trí X thì nó xuất hiện ở vị trí Y. Để phòng thủ, các bệ phóng tên lửa được bố trí tại các vị trí X và Y. Khi máy bay đối phương xuất hiện ở vị trí X hoặc Y thì tên lửa sẽ được phóng để hạ máy bay đó.</p>
<p>Xét phương án tác chiến sau: Nếu máy bay xuất hiện tại X thì bắn 2 quả tên lửa và nếu máy bay xuất hiện tại Y thì bắn 1 quả tên lửa. Biết rằng, xác suất bắn trúng máy bay của mỗi quả tên lửa là 0,8 và các bệ phóng tên lửa hoạt động độc lập. Máy bay bị bắn hạ nếu nó trúng ít nhất 1 quả tên lửa. Tính xác suất bắn hạ máy bay đối phương trong phương án tác chiến nêu trên.</p>', NULL, 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.8.</b> Có hai chuồng thỏ. Chuồng I có 5 con thỏ đen và 10 con thỏ trắng. Chuồng II có 7 con thỏ đen và 3 con thỏ trắng. Trước tiên, từ chuồng II lấy ra ngẫu nhiên 1 con thỏ rồi cho vào chuồng I. Sau đó, từ chuồng I lấy ra ngẫu nhiên 1 con thỏ. Tính xác suất để con thỏ được lấy ra là con thỏ trắng.</p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.9.</b> Tại nhà máy X sản xuất linh kiện điện tử, tỉ lệ sản phẩm đạt tiêu chuẩn là 80%. Trước khi xuất xưởng ra thị trường, các linh kiện điện tử đều phải qua khâu kiểm tra chất lượng để đóng dấu OTK. Vì sự kiểm tra không tuyệt đối hoàn hảo nên nếu một linh kiện điện tử đạt tiêu chuẩn thì nó có xác suất 0,99 được đóng dấu OTK; nếu một linh kiện điện tử không đạt tiêu chuẩn thì nó có xác suất 0,95 không được đóng dấu OTK. Chọn ngẫu nhiên một linh kiện điện tử của nhà máy X trên thị trường.</p>
<ol type="a"><li>Tính xác suất để linh kiện điện tử đó được đóng dấu OTK.</li>
<li>Dùng sơ đồ hình cây, hãy mô tả cách tính xác suất để linh kiện điện tử được chọn không được đóng dấu OTK.</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.10.</b> Có hai đội thi đấu môn Bắn súng. Đội I có 5 vận động viên, đội II có 7 vận động viên. Xác suất đạt huy chương vàng của mỗi vận động viên đội I và đội II tương ứng là 0,65 và 0,55. Chọn ngẫu nhiên một vận động viên.</p>
<ol type="a"><li>Tính xác suất để vận động viên này đạt huy chương vàng;</li>
<li>Giả sử vận động viên được chọn đạt huy chương vàng. Tính xác suất để vận động viên này thuộc đội I.</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.11.</b> Một bộ lọc được sử dụng để chặn thư rác trong các tài khoản thư điện tử. Tuy nhiên, vì bộ lọc không tuyệt đối hoàn hảo nên một thư rác bị chặn với xác suất 0,95 và một thư đúng (không phải là thư rác) bị chặn với xác suất 0,01. Thống kê cho thấy tỉ lệ thư rác là 3%.</p>
<ol type="a"><li>Chọn ngẫu nhiên một thư bị chặn. Tính xác suất để đó là thư rác.</li>
<li>Chọn ngẫu nhiên một thư không bị chặn. Tính xác suất để đó là thư đúng.</li>
<li>Trong số các thư bị chặn, có bao nhiêu phần trăm là thư đúng? Trong số các thư không bị chặn, có bao nhiêu phần trăm là thư rác?</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài tập cuối chương VI', N'Bài tập tổng hợp trắc nghiệm và tự luận về xác suất có điều kiện, công thức nhân, xác suất toàn phần và công thức Bayes.', N'<p>Phần bài tập tổng hợp (trắc nghiệm và tự luận) ôn tập toàn bộ kiến thức Chương VI.</p>', 3, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 6.12.</b> <i>Sử dụng dữ kiện sau để trả lời các câu từ 6.12 đến 6.14:</i> Cho $P(A)=\dfrac{2}{5}$; $P(B\mid A)=\dfrac{1}{3}$; $P(B\mid \overline{A})=\dfrac{1}{4}$.</p><p>Giá trị của $P(AB)$ là</p>', N'<p>$P(AB)=P(A)P(B\mid A)=\dfrac25\cdot\dfrac13=\dfrac{2}{15}$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$\dfrac{2}{15}$', 1),
(@q, 'B', N'$\dfrac{3}{16}$', 0),
(@q, 'C', N'$\dfrac{1}{5}$', 0),
(@q, 'D', N'$\dfrac{4}{15}$', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 6.13.</b> <i>Sử dụng dữ kiện sau để trả lời các câu từ 6.12 đến 6.14:</i> Cho $P(A)=\dfrac{2}{5}$; $P(B\mid A)=\dfrac{1}{3}$; $P(B\mid \overline{A})=\dfrac{1}{4}$.</p><p>Giá trị của $P(B\overline{A})$ là</p>', N'<p>$P(\overline A)=\dfrac35$, $P(B\overline A)=P(\overline A)P(B\mid\overline A)=\dfrac35\cdot\dfrac14=\dfrac{3}{20}$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$\dfrac{1}{7}$', 0),
(@q, 'B', N'$\dfrac{4}{19}$', 0),
(@q, 'C', N'$\dfrac{4}{21}$', 0),
(@q, 'D', N'$\dfrac{3}{20}$', 1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 6.14.</b> <i>Sử dụng dữ kiện sau để trả lời các câu từ 6.12 đến 6.14:</i> Cho $P(A)=\dfrac{2}{5}$; $P(B\mid A)=\dfrac{1}{3}$; $P(B\mid \overline{A})=\dfrac{1}{4}$.</p><p>Giá trị của $P(B)$ là</p>', N'<p>$P(B)=P(AB)+P(B\overline A)=\dfrac{2}{15}+\dfrac{3}{20}=\dfrac{8+9}{60}=\dfrac{17}{60}$.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$\dfrac{19}{60}$', 0),
(@q, 'B', N'$\dfrac{17}{60}$', 1),
(@q, 'C', N'$\dfrac{9}{20}$', 0),
(@q, 'D', N'$\dfrac{7}{30}$', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 6.15.</b> <i>Sử dụng dữ kiện sau để trả lời các câu từ 6.15 đến 6.17:</i> Bạn An có một túi gồm một số chiếc kẹo cùng loại, chỉ khác màu, trong đó có 6 chiếc kẹo sô cô la đen, còn lại 4 chiếc kẹo sô cô la trắng. An lấy ngẫu nhiên 1 chiếc kẹo trong túi để cho Bình, rồi lại lấy ngẫu nhiên tiếp 1 chiếc kẹo nữa trong túi và cũng đưa cho Bình.</p><p>Xác suất để Bình nhận được 2 chiếc kẹo sô cô la đen là</p>', N'<p>Tổng 10 kẹo. $P=\dfrac{6}{10}\cdot\dfrac59=\dfrac13$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$\dfrac{1}{3}$', 1),
(@q, 'B', N'$\dfrac{1}{4}$', 0),
(@q, 'C', N'$\dfrac{2}{5}$', 0),
(@q, 'D', N'$\dfrac{3}{7}$', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 6.16.</b> <i>Sử dụng dữ kiện sau để trả lời các câu từ 6.15 đến 6.17:</i> Bạn An có một túi gồm một số chiếc kẹo cùng loại, chỉ khác màu, trong đó có 6 chiếc kẹo sô cô la đen, còn lại 4 chiếc kẹo sô cô la trắng. An lấy ngẫu nhiên 1 chiếc kẹo trong túi để cho Bình, rồi lại lấy ngẫu nhiên tiếp 1 chiếc kẹo nữa trong túi và cũng đưa cho Bình.</p><p>Xác suất để Bình nhận được 2 chiếc kẹo sô cô la trắng là</p>', N'<p>$P=\dfrac{4}{10}\cdot\dfrac39=\dfrac{2}{15}$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$\dfrac{1}{5}$', 0),
(@q, 'B', N'$\dfrac{2}{15}$', 1),
(@q, 'C', N'$\dfrac{3}{16}$', 0),
(@q, 'D', N'$\dfrac{4}{17}$', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.17.</b> <i>Sử dụng dữ kiện sau để trả lời các câu từ 6.15 đến 6.17:</i> Bạn An có một túi gồm một số chiếc kẹo cùng loại, chỉ khác màu, trong đó có 6 chiếc kẹo sô cô la đen, còn lại 4 chiếc kẹo sô cô la trắng. An lấy ngẫu nhiên 1 chiếc kẹo trong túi để cho Bình, rồi lại lấy ngẫu nhiên tiếp 1 chiếc kẹo nữa trong túi và cũng đưa cho Bình.</p><p>Xác suất để Bình nhận được chiếc kẹo sô cô la đen ở lần thứ nhất, chiếc kẹo sô cô la trắng ở lần thứ hai là</p><ul><li>A. $\dfrac{1}{5}$</li><li>B. $\dfrac{3}{16}$</li><li>C. $\dfrac{1}{4}$</li><li>D. $\dfrac{4}{17}$</li></ul>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.18.</b> Để thử nghiệm tác dụng điều trị bệnh mất ngủ của hai loại thuốc X và Y, người ta tiến hành thử nghiệm trên 4 000 người bệnh tình nguyện. Kết quả được cho trong bảng thống kê $2\times 2$ sau:</p>
<table border="1"><tr><th>Kết quả \ Dùng thuốc</th><th>X</th><th>Y</th></tr><tr><td>Khỏi bệnh</td><td>1 600</td><td>1 200</td></tr><tr><td>Không khỏi bệnh</td><td>800</td><td>400</td></tr></table>
<p>Chọn ngẫu nhiên 1 người bệnh tham gia tình nguyện thử nghiệm thuốc.</p>
<ol type="a"><li>Tính xác suất để người đó khỏi bệnh nếu biết người bệnh đó uống thuốc X.</li>
<li>Tính xác suất để người bệnh đó uống thuốc Y, biết rằng người đó khỏi bệnh.</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.19.</b> Một nhóm có 25 học sinh, trong đó có 14 em học khá môn Toán, 16 em học khá môn Vật lí, 1 em không học khá cả hai môn Toán và Vật lí. Chọn ngẫu nhiên một học sinh trong số đó. Tính xác suất để học sinh đó:</p>
<ol type="a"><li>Học khá môn Toán, đồng thời học khá môn Vật lí;</li>
<li>Học khá môn Toán, nhưng không học khá môn Vật lí;</li>
<li>Học khá môn Toán, biết rằng học sinh đó học khá môn Vật lí.</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.20.</b> Chuồng I có 5 con gà mái, 2 con gà trống. Chuồng II có 3 con gà mái, 5 con gà trống. Trong một trò chơi, người chơi bắt một con gà trong số đó theo cách sau: &ldquo;Người chơi tung một con xúc xắc cân đối, đồng chất. Nếu số chấm chia hết cho 3 thì người chơi chọn chuồng I. Nếu số chấm không chia hết cho 3 thì người chơi chọn chuồng II. Sau đó, từ chuồng đã chọn người chơi bắt ngẫu nhiên một con gà&rdquo;. Tính xác suất để người chơi bắt được con gà mái.</p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.21.</b> Một loại vaccine được tiêm ở địa phương X. Người có bệnh nền thì với xác suất 0,35 có phản ứng phụ sau tiêm; người không có bệnh nền thì chỉ có phản ứng phụ sau tiêm với xác suất 0,16. Chọn ngẫu nhiên một người được tiêm vaccine và người này có phản ứng phụ. Tính xác suất để người này có bệnh nền, biết rằng tỉ lệ người có bệnh nền ở địa phương X là 18%.</p>', NULL, 3, 0, 1, @t1);

-- ---------------------------------------------------------------------------------------------------------------------
-- Chương V. Phương pháp toạ độ trong không gian
-- ---------------------------------------------------------------------------------------------------------------------
INSERT INTO Topics (TopicName, [Description], TeacherId, OrderIndex, IsActive) VALUES (N'Chương V. Phương pháp toạ độ trong không gian', N'Chương V trình bày phương pháp toạ độ trong không gian Oxyz: phương trình mặt phẳng, phương trình đường thẳng, công thức tính góc và phương trình mặt cầu, cùng các ứng dụng thực tiễn. (SGK Toán 12 Kết nối tri thức với cuộc sống, Tập 2)', @t1, 5, 1);
SET @tp = SCOPE_IDENTITY();
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 14. Phương trình mặt phẳng', N'Vectơ pháp tuyến, tích có hướng, phương trình tổng quát của mặt phẳng; lập phương trình mặt phẳng; điều kiện hai mặt phẳng vuông góc, song song; công thức khoảng cách từ một điểm đến một mặt phẳng.', N'<p><b>1. Vectơ pháp tuyến.</b> Vectơ $\vec n \ne \vec 0$ được gọi là <b>vectơ pháp tuyến</b> của mặt phẳng $(\alpha)$ nếu giá của $\vec n$ vuông góc với $(\alpha)$. Mặt phẳng hoàn toàn xác định khi biết một điểm và một vectơ pháp tuyến; nếu $\vec n$ là vectơ pháp tuyến thì $k\vec n$ ($k \ne 0$) cũng là vectơ pháp tuyến.</p>
<p><b>Tích có hướng.</b> Cho $\vec u=(a;b;c)$, $\vec v=(a'';b'';c'')$. Vectơ
$[\vec u,\vec v]=\left(\begin{vmatrix} b & c\\ b'' & c''\end{vmatrix};\begin{vmatrix} c & a\\ c'' & a''\end{vmatrix};\begin{vmatrix} a & b\\ a'' & b''\end{vmatrix}\right)=(bc''-b''c;\ ca''-c''a;\ ab''-a''b)$
vuông góc với cả $\vec u$ và $\vec v$. $[\vec u,\vec v]=\vec 0$ khi và chỉ khi $\vec u,\vec v$ cùng phương.</p>
<p><b>Cặp vectơ chỉ phương</b> của $(P)$: hai vectơ $\vec u,\vec v$ không cùng phương, có giá nằm trong hoặc song song với $(P)$. Khi đó $[\vec u,\vec v]$ là một vectơ pháp tuyến của $(P)$.</p>
<p><b>2. Phương trình tổng quát.</b> Mỗi mặt phẳng có phương trình dạng $Ax+By+Cz+D=0$ ($A,B,C$ không đồng thời bằng 0) và nhận $\vec n=(A;B;C)$ làm một vectơ pháp tuyến.</p>
<p><b>3. Lập phương trình mặt phẳng.</b></p>
<ul>
<li>Qua $M_0(x_0;y_0;z_0)$, có vectơ pháp tuyến $\vec n=(A;B;C)$: $A(x-x_0)+B(y-y_0)+C(z-z_0)=0 \Leftrightarrow Ax+By+Cz+D=0$, với $D=-(Ax_0+By_0+Cz_0)$.</li>
<li>Qua điểm $M$ và biết cặp vectơ chỉ phương $\vec u,\vec v$: tìm $\vec n=[\vec u,\vec v]$ rồi lập phương trình qua $M$ với vectơ pháp tuyến $\vec n$.</li>
<li>Qua ba điểm không thẳng hàng $A,B,C$: tìm cặp vectơ chỉ phương $\overrightarrow{AB},\overrightarrow{AC}$, vectơ pháp tuyến $\vec n=[\overrightarrow{AB},\overrightarrow{AC}]$, rồi lập phương trình qua $A$.</li>
<li>Mặt phẳng theo đoạn chắn (cắt $Ox,Oy,Oz$ tại $A(a;0;0)$, $B(0;b;0)$, $C(0;0;c)$): $\dfrac{x}{a}+\dfrac{y}{b}+\dfrac{z}{c}=1$.</li>
</ul>
<p><b>4. Hai mặt phẳng vuông góc.</b> Cho $(\alpha): Ax+By+Cz+D=0$, $(\beta): A''x+B''y+C''z+D''=0$ với $\vec n=(A;B;C)$, $\vec n''=(A'';B'';C'')$. Khi đó $(\alpha)\perp(\beta)\Leftrightarrow \vec n\perp\vec n''\Leftrightarrow AA''+BB''+CC''=0$.</p>
<p><b>5. Hai mặt phẳng song song.</b> $(\alpha)\parallel(\beta)\Leftrightarrow\begin{cases}\vec n''=k\vec n\\ D''\ne kD\end{cases}$ với $k$ nào đó. Hai mặt phẳng trùng nhau khi và chỉ khi tồn tại $k\ne 0$ sao cho $A''=kA,\ B''=kB,\ C''=kC,\ D''=kD$.</p>
<p><b>6. Khoảng cách từ điểm đến mặt phẳng.</b> Khoảng cách từ $M(x_0;y_0;z_0)$ đến $(P): Ax+By+Cz+D=0$ là
$$d(M,(P))=\dfrac{|Ax_0+By_0+Cz_0+D|}{\sqrt{A^2+B^2+C^2}}.$$</p>
<p><b>Ví dụ 1.</b> Viết phương trình mặt phẳng $(ABC)$ với $A(2;1;-1)$, $B(3;2;1)$, $C(3;1;4)$. <i>Giải:</i> $\overrightarrow{AB}=(1;1;2)$, $\overrightarrow{AC}=(1;0;5)$, $\vec n=[\overrightarrow{AB},\overrightarrow{AC}]=(5;-3;-1)$. Phương trình: $5(x-2)-3(y-1)-(z+1)=0\Leftrightarrow 5x-3y-z-8=0$.</p>
<p><b>Ví dụ 2.</b> Tính khoảng cách từ $M(1;2;-1)$ đến $(P): x+2y-2z+5=0$. <i>Giải:</i> $d=\dfrac{|1+4+2+5|}{\sqrt{1+4+4}}=4$.</p>', 1, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.1.</b> Trong không gian $Oxyz$, viết phương trình mặt phẳng đi qua điểm $M(1;2;-1)$ và vuông góc với trục $Ox$.</p>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.2.</b> Trong không gian $Oxyz$, cho hình hộp $ABCD.A''B''C''D''$, với $A(1;-1;3)$, $B(0;2;4)$, $D(2;-1;1)$, $A''(0;1;2)$.</p><ol type="a"><li>Tính toạ độ các điểm $C$, $B''$, $D''$.</li><li>Viết phương trình mặt phẳng $(CB''D'')$.</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.3.</b> Trong không gian $Oxyz$, viết phương trình mặt phẳng $(P)$ đi qua điểm $M(1;-1;5)$ và vuông góc với hai mặt phẳng $(Q): 3x+2y-z=0$, $(R): x+y-z=0$.</p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.4.</b> Trong không gian $Oxyz$, viết phương trình mặt phẳng đi qua $M(2;3;-1)$, song song với trục $Ox$ và vuông góc với mặt phẳng $(Q): x+2y-3z+1=0$.</p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.5.</b> Trong không gian $Oxyz$, tính khoảng cách từ gốc toạ độ đến mặt phẳng $(P): 2x+2y-z+1=0$.</p>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.6.</b> Trong không gian $Oxyz$, cho hai mặt phẳng $(P): x+y+z+2=0$, $(Q): x+y+z+6=0$. Chứng minh rằng hai mặt phẳng đã cho song song với nhau và tính khoảng cách giữa hai mặt phẳng đó.</p>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.7.</b> Trong không gian $Oxyz$, cho hai mặt phẳng $(P): x+3y-z=0$, $(Q): x-y-2z+1=0$.</p><ol type="a"><li>Chứng minh rằng hai mặt phẳng $(P)$ và $(Q)$ vuông góc với nhau.</li><li>Tìm điểm $M$ thuộc trục $Ox$ và cách đều hai mặt phẳng $(P)$ và $(Q)$.</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.8.</b> Bác An dự định làm bốn mái của ngôi nhà sao cho chúng là bốn mặt bên của một hình chóp đều và các mái nhà kề nhau thì vuông góc với nhau. Hỏi ý tưởng trên có thực hiện được không?</p><p><div><img src="/static/img/sgk/hinh-5-15.png" alt="Hình minh họa bài 5.8 (SGK)"></div></p>', NULL, 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.9.</b> Trong không gian $Oxyz$, một ngôi nhà có sàn nhà thuộc mặt phẳng $(Oxy)$, trần nhà tầng 1 thuộc mặt phẳng $z-1=0$, mái nhà tầng 2 thuộc mặt phẳng $x+y+50z-100=0$. Hỏi trong ba mặt phẳng tương ứng chứa sàn nhà, trần tầng 1, mái tầng 2, hai mặt phẳng nào song song với nhau?</p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.10.</b> Xét một cối xay lúa trong không gian $Oxyz$, với đơn vị đo độ dài là mét. Nếu tác động vào tai cối xay lúa (ở vị trí $P$) một lực $\vec F$ thì moment lực $\vec M$ được tính bởi công thức $\vec M=[\overrightarrow{OP},\vec F]$ (H.5.16). Trong quá trình xay, các thanh gỗ $AB$ và $PQ$ luôn có phương nằm ngang. Vectơ lực $\vec F$ có giá song song với $AB$. Giải thích vì sao giá của vectơ moment lực $\vec M$ có phương thẳng đứng.</p><p><div><img src="/static/img/sgk/hinh-5-16.png" alt="Hình minh họa bài 5.10 (SGK)"></div></p>', NULL, 3, 0, 1, @t1);
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 15. Phương trình đường thẳng trong không gian', N'Vectơ chỉ phương, phương trình tham số và chính tắc của đường thẳng, đường thẳng qua hai điểm; điều kiện hai đường thẳng vuông góc và xét vị trí tương đối (song song, trùng, cắt, chéo nhau).', N'<p><b>1. Vectơ chỉ phương.</b> Vectơ $\vec u\ne\vec 0$ được gọi là <b>vectơ chỉ phương</b> của đường thẳng $\Delta$ nếu giá của $\vec u$ song song hoặc trùng với $\Delta$. Đường thẳng hoàn toàn xác định khi biết một điểm mà nó đi qua và một vectơ chỉ phương; nếu $\vec u$ là vectơ chỉ phương thì $k\vec u$ ($k\ne0$) cũng là vectơ chỉ phương.</p>
<p><b>2. Phương trình tham số.</b> Đường thẳng $\Delta$ đi qua $A(x_0;y_0;z_0)$, có vectơ chỉ phương $\vec u=(a;b;c)$ có phương trình tham số
$$\begin{cases}x=x_0+at\\ y=y_0+bt\\ z=z_0+ct\end{cases}\quad(t\in\mathbb R).$$</p>
<p><b>3. Phương trình chính tắc.</b> Nếu $a,b,c$ đều khác 0 thì $\Delta$ có phương trình chính tắc
$$\dfrac{x-x_0}{a}=\dfrac{y-y_0}{b}=\dfrac{z-z_0}{c}.$$</p>
<p><b>4. Đường thẳng đi qua hai điểm</b> $A_1(x_1;y_1;z_1)$, $A_2(x_2;y_2;z_2)$: nhận $\overrightarrow{A_1A_2}=(x_2-x_1;y_2-y_1;z_2-z_1)$ làm vectơ chỉ phương, có phương trình tham số $x=x_1+(x_2-x_1)t$, $y=y_1+(y_2-y_1)t$, $z=z_1+(z_2-z_1)t$; nếu $x_1\ne x_2$, $y_1\ne y_2$, $z_1\ne z_2$ thì có phương trình chính tắc $\dfrac{x-x_1}{x_2-x_1}=\dfrac{y-y_1}{y_2-y_1}=\dfrac{z-z_1}{z_2-z_1}$.</p>
<p><b>5. Hai đường thẳng vuông góc.</b> Với $\vec u_1=(a_1;b_1;c_1)$, $\vec u_2=(a_2;b_2;c_2)$ là các vectơ chỉ phương: $\Delta_1\perp\Delta_2\Leftrightarrow\vec u_1\cdot\vec u_2=0\Leftrightarrow a_1a_2+b_1b_2+c_1c_2=0$.</p>
<p><b>6. Vị trí tương đối của hai đường thẳng.</b> Cho $\Delta_1$ qua $A_1$, có vectơ chỉ phương $\vec u_1$; $\Delta_2$ qua $A_2$, có vectơ chỉ phương $\vec u_2$. Khi đó:</p>
<ul>
<li>$\Delta_1\parallel\Delta_2\Leftrightarrow\vec u_1$ cùng phương với $\vec u_2$ và $A_1\notin\Delta_2$.</li>
<li>$\Delta_1\equiv\Delta_2\Leftrightarrow\vec u_1$ cùng phương với $\vec u_2$ và $A_1\in\Delta_2$.</li>
<li>$\Delta_1,\Delta_2$ cắt nhau $\Leftrightarrow[\vec u_1,\vec u_2]\ne\vec 0$ và $\overrightarrow{A_1A_2}\cdot[\vec u_1,\vec u_2]=0$.</li>
<li>$\Delta_1,\Delta_2$ chéo nhau $\Leftrightarrow\overrightarrow{A_1A_2}\cdot[\vec u_1,\vec u_2]\ne0$.</li>
</ul>
<p><b>Ví dụ 1.</b> Viết phương trình tham số và chính tắc của đường thẳng đi qua $A(1;2;-1)$ và $B(2;4;0)$. <i>Giải:</i> $\overrightarrow{AB}=(1;2;1)$ nên $\begin{cases}x=1+t\\y=2+2t\\z=-1+t\end{cases}$ và $\dfrac{x-1}{1}=\dfrac{y-2}{2}=\dfrac{z+1}{1}$.</p>
<p><b>Ví dụ 2.</b> Chứng minh $\Delta_1:\begin{cases}x=1+t\\y=2-t\\z=-1+2t\end{cases}$ và $\Delta_2:\dfrac{x-4}{3}=\dfrac{y+1}{1}=\dfrac{z}{-1}$ vuông góc và chéo nhau. <i>Giải:</i> $\vec u_1=(1;-1;2)$, $\vec u_2=(3;1;-1)$, $\vec u_1\cdot\vec u_2=0$ nên vuông góc. $A_1(1;2;-1)$, $A_2(4;-1;0)$, $\overrightarrow{A_1A_2}=(3;-3;1)$, $[\vec u_1,\vec u_2]=(-1;7;4)$, $\overrightarrow{A_1A_2}\cdot[\vec u_1,\vec u_2]=-20\ne0$ nên chéo nhau.</p>', 2, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.11.</b> Trong không gian $Oxyz$, viết các phương trình tham số và chính tắc của đường thẳng $\Delta$ đi qua điểm $A(1;1;2)$ và song song với đường thẳng $d: \dfrac{x-3}{2}=\dfrac{y-1}{1}=\dfrac{z+5}{3}$.</p>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.12.</b> Trong không gian $Oxyz$, viết các phương trình tham số và chính tắc của đường thẳng $\Delta$ đi qua điểm $A(2;-1;4)$ và vuông góc với mặt phẳng $(P): x+3y-z-1=0$.</p>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.13.</b> Trong không gian $Oxyz$, viết các phương trình tham số và chính tắc của đường thẳng $\Delta$ đi qua hai điểm $A(2;3;-1)$ và $B(1;-2;4)$.</p>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.14.</b> Trong không gian $Oxyz$, cho hai đường thẳng:</p><p>$$\Delta_1:\begin{cases}x=1+2t\\y=3-t\\z=2+3t\end{cases}\quad\text{và}\quad\Delta_2:\dfrac{x-8}{-1}=\dfrac{y+2}{1}=\dfrac{z-2}{2}.$$</p><ol type="a"><li>Chứng minh rằng $\Delta_1$ và $\Delta_2$ cắt nhau.</li><li>Viết phương trình mặt phẳng $(P)$ chứa $\Delta_1$ và $\Delta_2$.</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.15.</b> Trong không gian $Oxyz$, cho hai đường thẳng:</p><p>$$\Delta_1:\dfrac{x-1}{3}=\dfrac{y-3}{1}=\dfrac{z-2}{2}\quad\text{và}\quad\Delta_2:\dfrac{x-1}{3}=\dfrac{y+1}{1}=\dfrac{z}{2}.$$</p><ol type="a"><li>Chứng minh rằng $\Delta_1$ và $\Delta_2$ song song với nhau.</li><li>Viết phương trình mặt phẳng $(P)$ chứa $\Delta_1$ và $\Delta_2$.</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.16.</b> Trong không gian $Oxyz$, xét vị trí tương đối giữa hai đường thẳng:</p><p>$$\Delta_1:\begin{cases}x=-1+t\\y=1\\z=3+2t\end{cases}\quad\text{và}\quad\Delta_2:\begin{cases}x=-1+2s\\y=2+s\\z=1+3s.\end{cases}$$</p>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.17.</b> Tại một nút giao thông có hai con đường. Trên thiết kế, trong không gian $Oxyz$, hai con đường đó thuộc hai đường thẳng lần lượt có phương trình:</p><p>$$\Delta_1:\dfrac{x-1}{2}=\dfrac{y}{-1}=\dfrac{z+1}{3}\quad\text{và}\quad\Delta_2:\dfrac{x-3}{-1}=\dfrac{y+1}{1}=\dfrac{z}{1}.$$</p><ol type="a"><li>Hai con đường trên có vuông góc với nhau hay không?</li><li>Nút giao thông trên có phải là nút giao thông khác mức hay không?</li></ol><p><div><img src="/static/img/sgk/hinh-5-31.png" alt="Hình minh họa bài 5.17 (SGK)"></div></p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.18.</b> Trong không gian $Oxyz$, một viên đạn được bắn ra từ điểm $A(1;3;4)$ và trong 3 giây, đầu đạn đi với vận tốc không đổi; vectơ vận tốc (trên giây) là $\vec v=(2;1;6)$. Hỏi viên đạn trên có bắn trúng mục tiêu trong mỗi tình huống sau hay không?</p><ol type="a"><li>Mục tiêu đặt tại điểm $M\left(7;\dfrac{7}{2};21\right)$.</li><li>Mục tiêu đặt tại điểm $N(-3;1;-8)$.</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.19.</b> Trên mặt đất phẳng, người ta dựng một cây cột thẳng cao 6 m vuông góc với mặt đất, có chân cột đặt tại vị trí $O$ trên mặt đất. Tại một thời điểm, dưới ánh nắng mặt trời, bóng của đỉnh cột dưới mặt đất cách chân cột 3 m về hướng $S60^\circ E$ (hướng tạo với hướng nam góc $60^\circ$ và tạo với hướng đông góc $30^\circ$) (H.5.32). Chọn hệ trục $Oxyz$ có gốc toạ độ là $O$, tia $Ox$ chỉ hướng nam, tia $Oy$ chỉ hướng đông, tia $Oz$ chứa cây cột, đơn vị đo là mét. Hãy viết phương trình đường thẳng chứa tia nắng mặt trời đi qua đỉnh cột tại thời điểm đang xét.</p><p><div><img src="/static/img/sgk/hinh-5-32.png" alt="Hình minh họa bài 5.19 (SGK)"></div></p>', NULL, 3, 0, 1, @t1);
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 16. Công thức tính góc trong không gian', N'Công thức tính góc giữa hai đường thẳng, góc giữa đường thẳng và mặt phẳng, góc giữa hai mặt phẳng bằng vectơ chỉ phương và vectơ pháp tuyến; vận dụng vào bài toán thực tiễn.', N'<p><b>Quy ước:</b> góc tính theo đơn vị độ và làm tròn đến chữ số thập phân thứ nhất.</p>
<p><b>1. Góc giữa hai đường thẳng.</b> Cho $\Delta,\Delta''$ có vectơ chỉ phương $\vec u=(a;b;c)$, $\vec u''=(a'';b'';c'')$. Khi đó
$$\cos(\Delta,\Delta'')=|\cos(\vec u,\vec u'')|=\dfrac{|aa''+bb''+cc''|}{\sqrt{a^2+b^2+c^2}\cdot\sqrt{a''^2+b''^2+c''^2}}.$$</p>
<p><b>2. Góc giữa đường thẳng và mặt phẳng.</b> Cho đường thẳng $\Delta$ có vectơ chỉ phương $\vec u=(a;b;c)$ và mặt phẳng $(P)$ có vectơ pháp tuyến $\vec n=(A;B;C)$. Khi đó
$$\sin(\Delta,(P))=|\cos(\vec u,\vec n)|=\dfrac{|aA+bB+cC|}{\sqrt{a^2+b^2+c^2}\cdot\sqrt{A^2+B^2+C^2}}.$$</p>
<p><b>3. Góc giữa hai mặt phẳng.</b> Cho $(P),(Q)$ có vectơ pháp tuyến $\vec n=(A;B;C)$, $\vec n''=(A'';B'';C'')$. Khi đó
$$\cos((P),(Q))=|\cos(\vec n,\vec n'')|=\dfrac{|AA''+BB''+CC''|}{\sqrt{A^2+B^2+C^2}\cdot\sqrt{A''^2+B''^2+C''^2}}.$$</p>
<p><b>Ví dụ 1.</b> Tính góc giữa $\Delta:\begin{cases}x=1+t\\y=-1+t\\z=3\end{cases}$ và $\Delta'':\begin{cases}x=1+2s\\y=-2+2s\\z=4+s.\end{cases}$ <i>Giải:</i> $\vec u=(1;1;0)$, $\vec u''=(2;2;1)$, $\cos(\Delta,\Delta'')=\dfrac{|2+2|}{\sqrt2\cdot3}=\dfrac{2\sqrt2}{3}$, suy ra $(\Delta,\Delta'')\approx19{,}5^\circ$.</p>
<p><b>Ví dụ 2.</b> Tính góc giữa trục $Ox$ và $(P):\sqrt2x-y+z+2=0$. <i>Giải:</i> $\vec i=(1;0;0)$, $\vec n=(\sqrt2;-1;1)$, $\sin(Ox,(P))=\dfrac{\sqrt2}{1\cdot2}=\dfrac{\sqrt2}{2}$. Vậy góc là $45^\circ$.</p>
<p><b>Ví dụ 3.</b> Tính góc giữa $(P):x+2y+2z-1=0$ và $(Q):x+y-z+1=0$. <i>Giải:</i> $\vec n=(1;2;2)$, $\vec n''=(1;1;-1)$, $\cos((P),(Q))=\dfrac{|1+2-2|}{3\sqrt3}=\dfrac{\sqrt3}{9}$, suy ra $((P),(Q))\approx78{,}9^\circ$.</p>', 3, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.20.</b> Trong không gian $Oxyz$, tính góc giữa hai đường thẳng:</p><p>$$\Delta_1:\begin{cases}x=1+2t\\y=1-t\\z=2+3t\end{cases}\quad\text{và}\quad\Delta_2:\dfrac{x-2}{-1}=\dfrac{y+1}{1}=\dfrac{z-2}{2}.$$</p>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.21.</b> Trong không gian $Oxyz$, tính góc giữa trục $Oz$ và mặt phẳng $(P): x+2y-z-1=0$.</p>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.22.</b> Tính góc giữa đường thẳng $\Delta: \dfrac{x+1}{-1}=\dfrac{y-3}{2}=\dfrac{z+2}{3}$ và mặt phẳng $(P): x+y+z+3=0$.</p>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.23.</b> Kim tự tháp Kheops ở Ai Cập có dạng hình chóp $S.ABCD$, có đáy là hình vuông với cạnh dài 230 m, các cạnh bên bằng nhau và dài 219 m (theo britannica.com) (H.5.38). Tính góc giữa hai mặt phẳng $(SAB)$ và $(SBC)$.</p><p><div><img src="/static/img/sgk/hinh-5-38.png" alt="Hình minh họa bài 5.23 (SGK)"></div></p>', NULL, 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.24.</b> (H.5.39) Trong một bể hình lập phương cạnh 1 m có chứa một ít nước. Người ta đặt đáy bể nghiêng so với mặt phẳng nằm ngang. Biết rằng, lúc đó mặt nước có dạng hình bình hành $ABCD$ và khoảng cách từ các điểm $A$, $B$, $C$ đến đáy bể tương ứng là 40 cm, 44 cm, 48 cm.</p><ol type="a"><li>Khoảng cách từ điểm $D$ đến đáy bể bằng bao nhiêu centimét? (Tính gần đúng, lấy giá trị nguyên.)</li><li>Đáy bể nghiêng so với mặt phẳng nằm ngang một góc bao nhiêu độ?</li></ol><p><div><img src="/static/img/sgk/hinh-5-39.png" alt="Hình minh họa bài 5.24 (SGK)"></div></p>', NULL, 3, 0, 1, @t1);
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 17. Phương trình mặt cầu', N'Phương trình mặt cầu khi biết tâm và bán kính, xác định tâm và bán kính từ phương trình dạng khai triển, vị trí điểm so với mặt cầu và ứng dụng tính khoảng cách trên bề mặt Trái Đất.', N'<p><b>1. Phương trình mặt cầu.</b> Mặt cầu tâm $I$ bán kính $R$ ($R>0$) là tập hợp các điểm trong không gian cách $I$ một khoảng bằng $R$. Điểm $M$ nằm trong mặt cầu nếu $IM<R$, nằm ngoài mặt cầu nếu $IM>R$. Đường kính của mặt cầu có trung điểm là tâm mặt cầu và có độ dài bằng $2R$.</p>
<p>Trong không gian $Oxyz$, mặt cầu $(S)$ tâm $I(a;b;c)$, bán kính $R$ có phương trình
$$(x-a)^2+(y-b)^2+(z-c)^2=R^2.$$</p>
<ul>
<li>Điểm $M(x;y;z)$ nằm trong $(S)$ nếu $(x-a)^2+(y-b)^2+(z-c)^2<R^2$.</li>
<li>Điểm $M(x;y;z)$ nằm ngoài $(S)$ nếu $(x-a)^2+(y-b)^2+(z-c)^2>R^2$.</li>
</ul>
<p><b>Nhận xét.</b> Với $a,b,c,d$ là các hằng số, phương trình $x^2+y^2+z^2-2ax-2by-2cz+d=0$ viết lại thành $(x-a)^2+(y-b)^2+(z-c)^2=a^2+b^2+c^2-d$, và là phương trình của một mặt cầu khi và chỉ khi $a^2+b^2+c^2-d>0$. Khi đó mặt cầu có tâm $I(a;b;c)$ và bán kính $R=\sqrt{a^2+b^2+c^2-d}$.</p>
<p><b>2. Ứng dụng thực tiễn.</b> Coi Trái Đất là mặt cầu bán kính 6371 km; chọn hệ $Oxyz$ có $O$ là tâm Trái Đất, tia $Ox$ chứa giao điểm của kinh tuyến gốc và xích đạo, tia $Oz$ chứa cực Bắc, 1 đơn vị dài ứng với 6371 km; khi đó bề mặt Trái Đất có phương trình $x^2+y^2+z^2=1$. Điểm có vĩ độ, kinh độ $\alpha^\circ N,\ \beta^\circ E$ ($0<\alpha<90$, $0<\beta<180$) có toạ độ $P(\cos\alpha^\circ\cos\beta^\circ;\ \cos\alpha^\circ\sin\beta^\circ;\ \sin\alpha^\circ)$; điểm $\alpha^\circ N,\ \beta^\circ W$ có toạ độ $Q(\cos\alpha^\circ\cos\beta^\circ;\ -\cos\alpha^\circ\sin\beta^\circ;\ \sin\alpha^\circ)$. Khoảng cách trên mặt đất giữa hai vị trí $P,Q$ là độ dài cung nhỏ $PQ$, tính qua góc $\widehat{POQ}$ với $\cos\widehat{POQ}=\overrightarrow{OP}\cdot\overrightarrow{OQ}$.</p>
<p><b>Ví dụ 1.</b> Xác định tâm và bán kính của $(S): x^2+y^2+z^2-2x+4y-6z-2=0$. <i>Giải:</i> $(x-1)^2+(y+2)^2+(z-3)^2=16$, nên $(S)$ có tâm $I(1;-2;3)$, $R=4$.</p>
<p><b>Ví dụ 2.</b> Viết phương trình mặt cầu đường kính $AB$ với $A(1;2;1)$, $B(3;1;5)$. <i>Giải:</i> Tâm là trung điểm $J\left(2;\dfrac32;3\right)$, bán kính $R=\dfrac12AB=\dfrac{\sqrt{21}}{2}$. Vậy $(x-2)^2+\left(y-\dfrac32\right)^2+(z-3)^2=\dfrac{21}{4}$.</p>
<p><b>Ví dụ 3.</b> Phương trình $x^2+y^2+z^2-2xy+6y-9z+10=0$ không phải phương trình mặt cầu vì có số hạng $-2xy$.</p>', 4, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.25.</b> Trong không gian $Oxyz$, cho mặt cầu $(S)$ có phương trình $\left(x-\dfrac12\right)^2+(y+1)^2+z^2=9$. Xác định tâm và bán kính của $(S)$.</p>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.26.</b> Trong không gian $Oxyz$, viết phương trình của mặt cầu $(S)$ có tâm $I(-2;0;5)$ và bán kính $R=2$.</p>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.27.</b> Trong không gian $Oxyz$, viết phương trình của mặt cầu $(S)$ có tâm $I(0;3;-1)$ và có bán kính bằng khoảng cách từ $I$ đến mặt phẳng $(P): 3x+2y-z=0$.</p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.28.</b> Trong không gian $Oxyz$, cho mặt cầu $(S): x^2+y^2+z^2+2x-2y+8z-18=0$. Xác định tâm và bán kính của $(S)$.</p>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.29.</b> Trong không gian $Oxyz$, phương trình nào trong các phương trình sau là phương trình mặt cầu? Xác định tâm và bán kính của mặt cầu ứng với phương trình đó.</p><ol type="a"><li>$x^2+y^2+z^2-2x-5z+30=0$;</li><li>$x^2+y^2+z^2-4x+2y-2z=0$;</li><li>$x^3+y^3+z^3-2x+6y-9z-10=0$;</li><li>$x^2+y^2+z^2+5=0$.</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.30.</b> Trong không gian $Oxyz$, một thiết bị phát sóng đặt tại vị trí $A(2;0;0)$. Vùng phủ sóng của thiết bị có bán kính bằng 1. Hỏi vị trí $M(2;1;1)$ có thuộc vùng phủ sóng của thiết bị nói trên hay không?</p>', NULL, 1, 0, 1, @t1);
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài tập cuối chương V', N'Bài tập tổng hợp chương V gồm phần trắc nghiệm và tự luận về phương trình mặt phẳng, đường thẳng, mặt cầu, vị trí tương đối, góc và khoảng cách trong không gian.', N'<p>Phần bài tập tổng hợp kiến thức chương V: phương trình mặt phẳng, đường thẳng, mặt cầu, vị trí tương đối, góc và khoảng cách trong không gian Oxyz.</p>', 5, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 5.31.</b> Trong không gian $Oxyz$, cho mặt phẳng $(P): x-2y-3z+1=0$. Một vectơ pháp tuyến của mặt phẳng $(P)$ có toạ độ là</p>', N'<p>Hệ số của $x,y,z$ là $(1;-2;-3)$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$(1;2;3)$', 0),
(@q, 'B', N'$(1;-2;3)$', 0),
(@q, 'C', N'$(1;2;-3)$', 0),
(@q, 'D', N'$(1;-2;-3)$', 1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 5.32.</b> Trong không gian $Oxyz$, phương trình mặt phẳng $(P)$ đi qua điểm $I(1;-1;2)$ và nhận vectơ $\vec n=(2;1;-1)$ làm một vectơ pháp tuyến là</p>', N'<p>$2(x-1)+(y+1)-(z-2)=0\iff 2x+y-z+1=0$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$x-y+2z+1=0$', 0),
(@q, 'B', N'$x-y+2z-6=0$', 0),
(@q, 'C', N'$2x+y-z-1=0$', 0),
(@q, 'D', N'$2x+y-z+1=0$', 1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 5.33.</b> Trong không gian $Oxyz$, cho đường thẳng $d: \dfrac{x-1}{2}=\dfrac{y+2}{1}=\dfrac{z-3}{-2}$. Một vectơ chỉ phương của đường thẳng $d$ có toạ độ là</p>', N'<p>Mẫu số các phân thức: $(2;1;-2)$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$(1;-2;3)$', 0),
(@q, 'B', N'$(2;1;-2)$', 1),
(@q, 'C', N'$(2;1;2)$', 0),
(@q, 'D', N'$(1;2;3)$', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 5.34.</b> Trong không gian $Oxyz$, cho đường thẳng $d:\begin{cases}x=1+2t\\y=-2+t\\z=3-t.\end{cases}$ Một vectơ chỉ phương của đường thẳng $d$ có toạ độ là</p>', N'<p>Hệ số của $t$: $(2;1;-1)$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$(1;-2;3)$', 0),
(@q, 'B', N'$(2;0;0)$', 0),
(@q, 'C', N'$(2;1;-1)$', 1),
(@q, 'D', N'$(2;1;1)$', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 5.35.</b> Trong không gian $Oxyz$, phương trình đường thẳng $d$ đi qua $I(2;-1;1)$ và nhận vectơ $\vec u=(1;2;-3)$ làm một vectơ chỉ phương là</p>', N'<p>Đi qua $I(2;-1;1)$, VTCP $(1;2;-3)$: $\dfrac{x-2}{1}=\dfrac{y+1}{2}=\dfrac{z-1}{-3}$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$\dfrac{x-1}{2}=\dfrac{y-2}{-1}=\dfrac{z+3}{1}$', 0),
(@q, 'B', N'$\dfrac{x-2}{1}=\dfrac{y-1}{2}=\dfrac{z-1}{-3}$', 0),
(@q, 'C', N'$\dfrac{x-2}{1}=\dfrac{y+1}{2}=\dfrac{z-1}{-3}$', 1),
(@q, 'D', N'$\dfrac{x-1}{2}=\dfrac{y-2}{1}=\dfrac{z+3}{1}$', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 5.36.</b> Trong không gian $Oxyz$, cho hai điểm $A(-1;0;-1)$, $B(2;1;1)$. Phương trình đường thẳng $AB$ là</p>', N'<p>$\overrightarrow{AB}=(3;1;2)$, qua $A(-1;0;-1)$: $x=-1+3t,\ y=t,\ z=-1+2t$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$\begin{cases}x=1+3t\\y=t\\z=1+2t\end{cases}$', 0),
(@q, 'B', N'$\begin{cases}x=-1+t\\y=t\\z=-1+2t\end{cases}$', 0),
(@q, 'C', N'$\begin{cases}x=2+t\\y=1+t\\z=1+2t\end{cases}$', 0),
(@q, 'D', N'$\begin{cases}x=-1+3t\\y=t\\z=-1+2t\end{cases}$', 1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 5.37.</b> Trong không gian $Oxyz$, phương trình đường thẳng $d$ đi qua $I(2;1;-3)$ và vuông góc với mặt phẳng $(P): x-2y+z-3=0$ là</p>', N'<p>VTCP của $d$ là VTPT $(1;-2;1)$ của $(P)$: $\dfrac{x-2}{1}=\dfrac{y-1}{-2}=\dfrac{z+3}{1}$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$\dfrac{x-2}{1}=\dfrac{y-1}{-2}=\dfrac{z+3}{1}$', 1),
(@q, 'B', N'$\dfrac{x-2}{1}=\dfrac{y-1}{2}=\dfrac{z-3}{1}$', 0),
(@q, 'C', N'$\dfrac{x-2}{1}=\dfrac{y-1}{-2}=\dfrac{z-3}{1}$', 0),
(@q, 'D', N'$\dfrac{x-2}{1}=\dfrac{y-1}{2}=\dfrac{z+3}{1}$', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 5.38.</b> Trong không gian $Oxyz$, cho mặt cầu $(S): (x+1)^2+y^2+(z-3)^2=4$. Toạ độ tâm $I$ và bán kính $R$ của $(S)$ lần lượt là</p>', N'<p>Tâm $I(-1;0;3)$, $R^2=4\Rightarrow R=2$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$I(1;0;3)$, $R=4$', 0),
(@q, 'B', N'$I(1;0;3)$, $R=2$', 0),
(@q, 'C', N'$I(-1;0;3)$, $R=2$', 1),
(@q, 'D', N'$I(-1;0;3)$, $R=4$', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 5.39.</b> Trong không gian $Oxyz$, cho mặt cầu $(S): x^2+y^2+z^2-2x+4y+2z-3=0$. Toạ độ tâm $I$ và bán kính $R$ của mặt cầu $(S)$ lần lượt là</p>', N'<p>$I(1;-2;-1)$, $R=\sqrt{1+4+1+3}=3$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$I(1;-2;-1)$, $R=3$', 1),
(@q, 'B', N'$I(1;2;1)$, $R=9$', 0),
(@q, 'C', N'$I(1;2;1)$, $R=3$', 0),
(@q, 'D', N'$I(1;-2;-1)$, $R=9$', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.40.</b> Trong không gian $Oxyz$, cho ba điểm $A(1;0;-1)$, $B(0;1;2)$, $C(-1;-2;3)$.</p><ol type="a"><li>Viết phương trình mặt phẳng $(ABC)$.</li><li>Viết phương trình đường thẳng $AC$.</li><li>Viết phương trình mặt cầu đường kính $AC$.</li><li>Viết phương trình mặt cầu có tâm $A$ và đi qua $B$.</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.41.</b> Trong không gian $Oxyz$, cho đường thẳng $d:\begin{cases}x=1+t\\y=-2+t\\z=4-2t.\end{cases}$</p><p>Viết phương trình mặt phẳng $(P)$ chứa đường thẳng $d$ và gốc toạ độ $O$.</p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.42.</b> Trong không gian $Oxyz$, cho mặt phẳng $(P): x-2y+2z-1=0$ và hai điểm $A(1;-1;2)$, $B(-1;1;0)$.</p><ol type="a"><li>Tính khoảng cách từ $A$ đến mặt phẳng $(P)$.</li><li>Viết phương trình mặt phẳng $(Q)$ đi qua $A$ và song song với mặt phẳng $(P)$.</li><li>Viết phương trình mặt phẳng $(R)$ chứa $A$, $B$ và vuông góc với mặt phẳng $(P)$.</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.43.</b> Trong không gian $Oxyz$, cho điểm $A(1;0;2)$ và hai đường thẳng $d: \dfrac{x}{1}=\dfrac{y-1}{2}=\dfrac{z}{2}$, $d'': \dfrac{x+1}{2}=\dfrac{y+2}{2}=\dfrac{z-3}{-1}$.</p><ol type="a"><li>Xét vị trí tương đối của hai đường thẳng $d$ và $d''$.</li><li>Viết phương trình đường thẳng $\Delta$ đi qua $A$ và song song với đường thẳng $d$.</li><li>Viết phương trình mặt phẳng $(P)$ chứa $A$ và $d$.</li><li>Tìm giao điểm của đường thẳng $d$ với mặt phẳng $(Oxz)$.</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.44.</b> Trong không gian $Oxyz$, cho mặt phẳng $(P): x-2y-2z-3=0$ và đường thẳng $d: \dfrac{x-1}{2}=\dfrac{y+1}{1}=\dfrac{z}{-1}$. Viết phương trình mặt phẳng $(Q)$ chứa $d$ và vuông góc với mặt phẳng $(P)$.</p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.45.</b> Trong không gian $Oxyz$, cho hai đường thẳng:</p><p>$$d:\dfrac{x+1}{1}=\dfrac{y-1}{2}=\dfrac{z}{-1}\quad\text{và}\quad d'':\dfrac{x-1}{1}=\dfrac{y-2}{1}=\dfrac{z+1}{2}.$$</p><p>Viết phương trình mặt phẳng $(P)$ chứa đường thẳng $d$ và song song với đường thẳng $d''$.</p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.46.</b> Trong không gian $Oxyz$, cho hai mặt phẳng $(P): x-y-z-1=0$, $(Q): 2x+y-z-2=0$ và điểm $A(-1;2;0)$. Viết phương trình mặt phẳng $(R)$ đi qua điểm $A$ đồng thời vuông góc với cả hai mặt phẳng $(P)$ và $(Q)$.</p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.47.</b> Trong không gian $Oxyz$, cho hai đường thẳng $d:\dfrac{x+2}{1}=\dfrac{y+3}{2}=\dfrac{z-3}{-2}$ và $d'':\begin{cases}x=1-t\\y=-2+t\\z=2t.\end{cases}$</p><ol type="a"><li>Xác định vị trí tương đối của hai đường thẳng $d$ và $d''$.</li><li>Tính góc giữa $d$ và $d''$.</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.48.</b> Trong không gian $Oxyz$, tính góc tạo bởi đường thẳng $d: \dfrac{x+3}{2}=\dfrac{y-2}{-2}=\dfrac{z+1}{1}$ và mặt phẳng $(P): x+y-2z+3=0$.</p>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.49.</b> Trong không gian $Oxyz$, tính góc giữa mặt phẳng $(P): x+y+z-1=0$ và mặt phẳng $(Oxy)$.</p>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.50.</b> Từ mặt nước trong một bể nước, tại ba vị trí đôi một cách nhau 2 m, người ta lần lượt thả dây dọi để quả dọi chạm đáy bể. Phần dây dọi (thẳng) nằm trong nước tại ba vị trí đó lần lượt có độ dài 4 m; 4,4 m; 4,8 m. Biết đáy bể là phẳng. Hỏi đáy bể nghiêng so với mặt phẳng nằm ngang một góc bao nhiêu độ?</p>', NULL, 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.51.</b> Bản vẽ thiết kế của một công trình được vẽ trong một hệ trục toạ độ $Oxyz$. Sàn nhà của công trình thuộc mặt phẳng $(Oxy)$, đường ống thoát nước thẳng và đi qua hai điểm $A(1;2;-1)$ và $B(5;6;-2)$. Tính góc tạo bởi đường ống thoát nước và mặt sàn.</p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.52.</b> Nếu đứng trước biển và nhìn ra xa, người ta sẽ thấy một đường giao giữa mặt biển và bầu trời, đó là đường chân trời đối với người quan sát (H.5.45a). Về mặt Vật lí, đường chân trời là đường giới hạn phần Trái Đất mà người quan sát có thể nhìn thấy được (phần còn lại bị chính Trái Đất che khuất). Ta có thể hình dung rằng, nếu người quan sát ở tại đỉnh của một chiếc nón và Trái Đất được “thả” vào trong chiếc nón đó, thì đường chân trời trong trường hợp này là đường chạm giữa Trái Đất và chiếc nón (H.5.45b). Trong mô hình toán học, đường chân trời đối với người quan sát tại vị trí $B$ là tập hợp những điểm $A$ nằm trên bề mặt Trái Đất sao cho $\widehat{BAO}=90^\circ$, với $O$ là tâm Trái Đất (H.5.45c). Trong không gian $Oxyz$, giả sử bề mặt Trái Đất $(S)$ có phương trình $x^2+y^2+z^2=1$ và người quan sát ở vị trí $B(1;1;-1)$.</p><p>Gọi $A$ là một vị trí bất kì trên đường chân trời đối với người quan sát ở vị trí $B$. Tính khoảng cách $AB$.</p><p><div><img src="/static/img/sgk/hinh-5-45.png" alt="Hình minh họa bài 5.52 (SGK)"></div></p>', NULL, 3, 0, 1, @t1);

-- ---------------------------------------------------------------------------------------------------------------------
-- Chương IV. Nguyên hàm và tích phân
-- ---------------------------------------------------------------------------------------------------------------------
INSERT INTO Topics (TopicName, [Description], TeacherId, OrderIndex, IsActive) VALUES (N'Chương IV. Nguyên hàm và tích phân', N'Chương trình bày khái niệm, tính chất cơ bản của nguyên hàm và tích phân cũng như ứng dụng tích phân để tính diện tích hình phẳng và thể tích vật thể. (SGK Toán 12 Kết nối tri thức với cuộc sống, Tập 2)', @t1, 4, 1);
SET @tp = SCOPE_IDENTITY();
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 11. Nguyên hàm', N'Khái niệm nguyên hàm, họ các nguyên hàm, tính chất cơ bản và bảng nguyên hàm của một số hàm số thường gặp (luỹ thừa, lượng giác, mũ); vận dụng vào bài toán chuyển động và kinh tế.', N'<p><b>1. Nguyên hàm của một hàm số</b></p>
<p><b>Định nghĩa.</b> Cho hàm số $f(x)$ xác định trên một khoảng $K$ (hoặc một đoạn, hoặc một nửa khoảng). Hàm số $F(x)$ được gọi là một <b>nguyên hàm</b> của hàm số $f(x)$ trên $K$ nếu $F''(x)=f(x)$ với mọi $x$ thuộc $K$.</p>
<p><b>Họ các nguyên hàm.</b> Giả sử hàm số $F(x)$ là một nguyên hàm của $f(x)$ trên $K$. Khi đó:</p>
<ul><li>Với mỗi hằng số $C$, hàm số $F(x)+C$ cũng là một nguyên hàm của $f(x)$ trên $K$;</li>
<li>Nếu hàm số $G(x)$ là một nguyên hàm của $f(x)$ trên $K$ thì tồn tại một hằng số $C$ sao cho $G(x)=F(x)+C$ với mọi $x\in K$.</li></ul>
<p>Ta gọi $F(x)+C\ (C\in\mathbb{R})$ là <b>họ các nguyên hàm</b> của $f(x)$ trên $K$, kí hiệu $\int f(x)\,\mathrm{d}x$. Vậy $\int f(x)\,\mathrm{d}x=F(x)+C$.</p>
<p><i>Chú ý.</i> Hàm số $f(x)$ liên tục trên khoảng $K$ thì có nguyên hàm trên khoảng đó. Biểu thức $f(x)\mathrm{d}x$ là vi phân của nguyên hàm $F(x)$: $\mathrm{d}F(x)=F''(x)\mathrm{d}x=f(x)\mathrm{d}x$. Khi không chỉ rõ tập $K$, ta hiểu là tìm nguyên hàm trên tập xác định của hàm số.</p>
<p><b>2. Tính chất cơ bản của nguyên hàm</b></p>
<ul><li>$\int kf(x)\,\mathrm{d}x=k\int f(x)\,\mathrm{d}x\ \ (k\neq 0)$.</li>
<li>$\int [f(x)+g(x)]\,\mathrm{d}x=\int f(x)\,\mathrm{d}x+\int g(x)\,\mathrm{d}x$.</li>
<li>$\int [f(x)-g(x)]\,\mathrm{d}x=\int f(x)\,\mathrm{d}x-\int g(x)\,\mathrm{d}x$.</li></ul>
<p><b>3. Bảng nguyên hàm của một số hàm số thường gặp</b></p>
<table border="1">
<tr><td>$\int 0\,\mathrm{d}x=C$</td><td>$\int 1\,\mathrm{d}x=x+C$</td></tr>
<tr><td>$\int x^{\alpha}\,\mathrm{d}x=\dfrac{x^{\alpha+1}}{\alpha+1}+C\ (\alpha\neq -1)$</td><td>$\int \dfrac{1}{x}\,\mathrm{d}x=\ln|x|+C$</td></tr>
<tr><td>$\int e^x\,\mathrm{d}x=e^x+C$</td><td>$\int a^x\,\mathrm{d}x=\dfrac{a^x}{\ln a}+C\ (0&lt;a\neq 1)$</td></tr>
<tr><td>$\int \cos x\,\mathrm{d}x=\sin x+C$</td><td>$\int \sin x\,\mathrm{d}x=-\cos x+C$</td></tr>
<tr><td>$\int \dfrac{1}{\cos^2 x}\,\mathrm{d}x=\tan x+C$</td><td>$\int \dfrac{1}{\sin^2 x}\,\mathrm{d}x=-\cot x+C$</td></tr>
</table>
<p><b>Ví dụ 1.</b> Tìm $\int\left(2x^2+\dfrac{3}{\sqrt{x}}\right)\mathrm{d}x$. <i>Giải:</i> $=2\int x^2\mathrm{d}x+3\int x^{-\frac12}\mathrm{d}x=\dfrac{2}{3}x^3+6\sqrt{x}+C$.</p>
<p><b>Ví dụ 2.</b> Tìm $\int\left(2e^x-5^x\right)\mathrm{d}x$. <i>Giải:</i> $=2e^x-\dfrac{5^x}{\ln 5}+C$.</p>
<p><b>Ví dụ 3 (chuyển động).</b> Vận tốc $v(t)=5+3t$ (m/s), quãng đường $S(t)$ thoả $S''(t)=v(t)$ và $S(0)=0$. Khi đó $S(t)=\int(5+3t)\mathrm{d}t=5t+\dfrac32t^2+C$, $C=0$; sau 30 giây $S(30)=1\,500$ m.</p>', 1, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.1.</b> Trong mỗi trường hợp sau, hàm số $F(x)$ có là một nguyên hàm của hàm số $f(x)$ trên khoảng tương ứng không? Vì sao?</p>
<ol type="a"><li>$F(x)=x\ln x$ và $f(x)=1+\ln x$ trên khoảng $(0;+\infty)$;</li>
<li>$F(x)=e^{\sin x}$ và $f(x)=e^{\cos x}$ trên $\mathbb{R}$.</li></ol>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.2.</b> Tìm nguyên hàm của các hàm số sau:</p>
<ol type="a"><li>$f(x)=3x^2+2x-1$;</li>
<li>$f(x)=x^3-x$;</li>
<li>$f(x)=(2x+1)^2$;</li>
<li>$f(x)=\left(2x-\dfrac{1}{x}\right)^2$.</li></ol>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.3.</b> Tìm:</p>
<ol type="a"><li>$\int\left(3\sqrt{x}+\dfrac{1}{\sqrt[3]{x}}\right)\mathrm{d}x$;</li>
<li>$\int\sqrt{x}\,(7x^2-3)\,\mathrm{d}x\ \ (x&gt;0)$;</li>
<li>$\int\dfrac{(2x+1)^2}{x^2}\,\mathrm{d}x$;</li>
<li>$\int\left(2^x+\dfrac{3}{x^2}\right)\mathrm{d}x$.</li></ol>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.4.</b> Tìm:</p>
<ol type="a"><li>$\int\left(2\cos x-\dfrac{3}{\sin^2 x}\right)\mathrm{d}x$;</li>
<li>$\int 4\sin^2\dfrac{x}{2}\,\mathrm{d}x$;</li>
<li>$\int\left(\sin\dfrac{x}{2}-\cos\dfrac{x}{2}\right)^2\mathrm{d}x$;</li>
<li>$\int(x+\tan^2 x)\,\mathrm{d}x$.</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.5.</b> Cho hàm số $y=f(x)$ xác định trên khoảng $(0;+\infty)$. Biết rằng, $f''(x)=2x+\dfrac{1}{x^2}$ với mọi $x\in(0;+\infty)$ và $f(1)=1$. Tính giá trị $f(4)$.</p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.6.</b> Cho hàm số $y=f(x)$ có đồ thị là $(C)$. Xét điểm $M(x;f(x))$ thay đổi trên $(C)$. Biết rằng, hệ số góc của tiếp tuyến của đồ thị $(C)$ tại $M$ là $k_M=(x-1)^2$ và điểm $M$ trùng với gốc toạ độ khi nó nằm trên trục tung. Tìm biểu thức $f(x)$.</p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.7.</b> Một viên đạn được bắn thẳng đứng lên trên từ mặt đất. Giả sử tại thời điểm $t$ giây (coi $t=0$ là thời điểm viên đạn được bắn lên), vận tốc của nó được cho bởi $v(t)=160-9{,}8t$ (m/s). Tìm độ cao của viên đạn (tính từ mặt đất):</p>
<ol type="a"><li>Sau $t=5$ giây;</li>
<li>Khi nó đạt độ cao lớn nhất (làm tròn kết quả đến chữ số thập phân thứ nhất của mét).</li></ol>', NULL, 3, 0, 1, @t1);
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 12. Tích phân', N'Khái niệm tích phân qua diện tích hình thang cong, định nghĩa và ý nghĩa hình học của tích phân, các tính chất của tích phân và cách tính tích phân; vận dụng vào bài toán thực tiễn.', N'<p><b>1. Khái niệm tích phân</b></p>
<p><b>Hình thang cong.</b> Hình phẳng giới hạn bởi đồ thị $y=f(x)$, trục hoành và hai đường thẳng $x=a,\ x=b\ (a&lt;b)$, trong đó $f(x)$ là hàm liên tục không âm trên đoạn $[a;b]$, gọi là một <i>hình thang cong</i>. Diện tích hình thang cong đó là $S=F(b)-F(a)$, trong đó $F(x)$ là một nguyên hàm của $f(x)$ trên $[a;b]$.</p>
<p><b>Định nghĩa tích phân.</b> Cho $f(x)$ là hàm số liên tục trên đoạn $[a;b]$. Nếu $F(x)$ là một nguyên hàm của hàm số $f(x)$ trên đoạn $[a;b]$ thì hiệu số $F(b)-F(a)$ được gọi là <b>tích phân</b> từ $a$ đến $b$ của hàm số $f(x)$, kí hiệu $\int_a^b f(x)\,\mathrm{d}x$.</p>
<p><i>Chú ý.</i></p>
<ul><li>Hiệu $F(b)-F(a)$ thường được kí hiệu là $F(x)\Big|_a^b$. Như vậy $\int_a^b f(x)\,\mathrm{d}x=F(x)\Big|_a^b$.</li>
<li>$a$ là cận dưới, $b$ là cận trên, $f(x)$ là hàm số dưới dấu tích phân. Tích phân không phụ thuộc vào cách kí hiệu biến: $\int_a^b f(x)\mathrm{d}x=\int_a^b f(t)\mathrm{d}t$.</li>
<li>Quy ước: $\int_a^a f(x)\,\mathrm{d}x=0;\ \ \int_a^b f(x)\,\mathrm{d}x=-\int_b^a f(x)\,\mathrm{d}x$.</li></ul>
<p><b>Ý nghĩa hình học.</b> Nếu hàm số $f(x)$ liên tục và không âm trên đoạn $[a;b]$ thì $\int_a^b f(x)\,\mathrm{d}x$ là diện tích $S$ của hình thang cong giới hạn bởi đồ thị $y=f(x)$, trục hoành và hai đường thẳng $x=a,\ x=b$. Vậy $S=\int_a^b f(x)\,\mathrm{d}x$.</p>
<p><b>2. Tính chất của tích phân.</b> Cho $f(x),g(x)$ là các hàm số liên tục trên đoạn $[a;b]$. Khi đó:</p>
<ol><li>$\int_a^b kf(x)\,\mathrm{d}x=k\int_a^b f(x)\,\mathrm{d}x$ ($k$ là hằng số);</li>
<li>$\int_a^b [f(x)+g(x)]\,\mathrm{d}x=\int_a^b f(x)\,\mathrm{d}x+\int_a^b g(x)\,\mathrm{d}x$;</li>
<li>$\int_a^b [f(x)-g(x)]\,\mathrm{d}x=\int_a^b f(x)\,\mathrm{d}x-\int_a^b g(x)\,\mathrm{d}x$;</li>
<li>$\int_a^b f(x)\,\mathrm{d}x=\int_a^c f(x)\,\mathrm{d}x+\int_c^b f(x)\,\mathrm{d}x\ \ (a&lt;c&lt;b)$.</li></ol>
<p><b>Ví dụ 1.</b> Tính $\int_{-1}^{3}x^2\,\mathrm{d}x$. <i>Giải:</i> $=\dfrac{x^3}{3}\Big|_{-1}^{3}=\dfrac13\left[3^3-(-1)^3\right]=\dfrac{28}{3}$.</p>
<p><b>Ví dụ 2.</b> Tính $\int_0^3|x-2|\,\mathrm{d}x$. <i>Giải:</i> Tách tại $x=2$: $\int_0^2(2-x)\mathrm{d}x+\int_2^3(x-2)\mathrm{d}x=\left(2x-\dfrac{x^2}{2}\right)\Big|_0^2+\left(\dfrac{x^2}{2}-2x\right)\Big|_2^3=\dfrac52$.</p>
<p><b>Ví dụ 3.</b> Dùng ý nghĩa hình học: $\int_{-1}^{1}\sqrt{1-x^2}\,\mathrm{d}x$ là diện tích nửa hình tròn tâm $O$ bán kính 1 nằm phía trên trục hoành, nên bằng $\dfrac{\pi}{2}$.</p>', 2, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.8.</b> Sử dụng ý nghĩa hình học của tích phân, tính:</p>
<ol type="a"><li>$\int_1^2(2x+1)\,\mathrm{d}x$;</li>
<li>$\int_{-3}^{3}\sqrt{9-x^2}\,\mathrm{d}x$.</li></ol>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.9.</b> Cho $\int_0^3 f(x)\,\mathrm{d}x=5$ và $\int_0^3 g(x)\,\mathrm{d}x=2$. Tính:</p>
<ol type="a"><li>$\int_0^3[f(x)+g(x)]\,\mathrm{d}x$;</li>
<li>$\int_0^3[f(x)-g(x)]\,\mathrm{d}x$;</li>
<li>$\int_0^3 3f(x)\,\mathrm{d}x$;</li>
<li>$\int_0^3[2f(x)-3g(x)]\,\mathrm{d}x$.</li></ol>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.10.</b> Tính:</p>
<ol type="a"><li>$\int_0^3(3x-1)^2\,\mathrm{d}x$;</li>
<li>$\int_0^{\frac{\pi}{2}}(1+\sin x)\,\mathrm{d}x$;</li>
<li>$\int_0^1(e^{2x}+3x^2)\,\mathrm{d}x$;</li>
<li>$\int_1^2|2x+1|\,\mathrm{d}x$.</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.11.</b> Một vật chuyển động dọc theo một đường thẳng sao cho vận tốc của nó tại thời điểm $t$ (giây) là $v(t)=t^2-t-6$ (m/s).</p>
<ol type="a"><li>Tìm độ dịch chuyển của vật trong khoảng thời gian $1\le t\le 4$, tức là tính $\int_1^4 v(t)\,\mathrm{d}t$.</li>
<li>Tìm tổng quãng đường vật đi được trong khoảng thời gian $1\le t\le 4$, tức là tính $\int_1^4|v(t)|\,\mathrm{d}t$.</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.12.</b> Giả sử lợi nhuận biên (tính bằng triệu đồng) của một sản phẩm được mô hình hoá bằng công thức
$$P''(x)=-0{,}0005x+12{,}2.$$
Ở đây $P(x)$ là lợi nhuận (tính bằng triệu đồng) khi bán được $x$ đơn vị sản phẩm.</p>
<ol type="a"><li>Tìm sự thay đổi của lợi nhuận khi doanh số tăng từ 100 lên 101 đơn vị sản phẩm.</li>
<li>Tìm sự thay đổi của lợi nhuận khi doanh số tăng từ 100 lên 110 đơn vị sản phẩm.</li></ol>', NULL, 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.13.</b> Giả sử vận tốc $v$ của dòng máu ở khoảng cách $r$ từ tâm của động mạch bán kính $R$ không đổi, có thể được mô hình hoá bởi công thức
$$v=k\left(R^2-r^2\right),$$
trong đó $k$ là một hằng số. Tìm vận tốc trung bình (đối với $r$) của động mạch trong khoảng $0\le r\le R$. So sánh vận tốc trung bình với vận tốc lớn nhất.</p>', NULL, 3, 0, 1, @t1);
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 13. Ứng dụng hình học của tích phân', N'Dùng tích phân tính diện tích hình phẳng giới hạn bởi một hoặc hai đồ thị hàm số, tính thể tích vật thể theo diện tích mặt cắt và thể tích khối tròn xoay (khối nón, khối cầu...).', N'<p><b>1. Ứng dụng tích phân để tính diện tích hình phẳng</b></p>
<p><b>a) Hình phẳng giới hạn bởi một đồ thị hàm số, trục hoành và hai đường thẳng $x=a,\ x=b$.</b> Diện tích $S$ của hình phẳng giới hạn bởi đồ thị của hàm số $f(x)$ liên tục, trục hoành và hai đường thẳng $x=a,\ x=b\ (a&lt;b)$ được tính bằng công thức
$$S=\int_a^b|f(x)|\,\mathrm{d}x.$$</p>
<p><b>b) Hình phẳng giới hạn bởi hai đồ thị hàm số và hai đường thẳng $x=a,\ x=b$.</b> Diện tích $S$ của hình phẳng giới hạn bởi đồ thị của hai hàm số $f(x),g(x)$ liên tục trên đoạn $[a;b]$ và hai đường thẳng $x=a,\ x=b$ được tính bằng công thức
$$S=\int_a^b|f(x)-g(x)|\,\mathrm{d}x.$$</p>
<p><i>Chú ý.</i> Nếu hiệu $f(x)-g(x)$ không đổi dấu trên đoạn $[a;b]$ thì $\int_a^b|f(x)-g(x)|\,\mathrm{d}x=\left|\int_a^b[f(x)-g(x)]\,\mathrm{d}x\right|$. Nếu đổi dấu thì cần tách đoạn $[a;b]$ tại các nghiệm của $f(x)-g(x)=0$ để bỏ dấu giá trị tuyệt đối.</p>
<p><b>2. Ứng dụng tích phân để tính thể tích vật thể</b></p>
<p><b>a) Công thức tính thể tích vật thể.</b> Cho một vật thể trong không gian $Oxyz$. Gọi $\mathcal{B}$ là phần vật thể giới hạn bởi hai mặt phẳng vuông góc với trục $Ox$ tại các điểm có hoành độ $x=a,\ x=b$. Một mặt phẳng vuông góc với trục $Ox$ tại điểm có hoành độ $x$ cắt vật thể theo mặt cắt có diện tích là $S(x)$. Giả sử $S(x)$ là hàm số liên tục trên đoạn $[a;b]$. Khi đó thể tích $V$ của phần vật thể $\mathcal{B}$ được tính bởi công thức
$$V=\int_a^b S(x)\,\mathrm{d}x.$$</p>
<p><b>b) Thể tích khối tròn xoay.</b> Cho hàm số $f(x)$ liên tục, không âm trên đoạn $[a;b]$. Khi quay hình phẳng giới hạn bởi đồ thị hàm số $y=f(x)$, trục hoành và hai đường thẳng $x=a,\ x=b$ xung quanh trục hoành, ta được một khối gọi là <i>khối tròn xoay</i>. Thể tích của khối tròn xoay này là
$$V=\pi\int_a^b f^2(x)\,\mathrm{d}x.$$</p>
<p><b>Ví dụ 1.</b> Diện tích hình phẳng giới hạn bởi $y=x^3$, trục hoành, $x=0,\ x=2$: $S=\int_0^2|x^3|\,\mathrm{d}x=\dfrac{x^4}{4}\Big|_0^2=4$.</p>
<p><b>Ví dụ 2.</b> Diện tích hình phẳng giới hạn bởi $y=\sin x,\ y=\cos x$, $x=0,\ x=\dfrac{\pi}{4}$: vì $\cos x\ge\sin x$ trên $\left[0;\dfrac{\pi}{4}\right]$ nên $S=\int_0^{\frac{\pi}{4}}(\cos x-\sin x)\,\mathrm{d}x=(\sin x+\cos x)\Big|_0^{\frac{\pi}{4}}=\sqrt{2}-1$.</p>
<p><b>Ví dụ 3.</b> Thể tích khối cầu bán kính $R$ (quay nửa hình tròn $y=\sqrt{R^2-x^2},\ -R\le x\le R$ quanh $Ox$): $V=\pi\int_{-R}^{R}(R^2-x^2)\,\mathrm{d}x=\pi\left(R^2x-\dfrac{x^3}{3}\right)\Big|_{-R}^{R}=\dfrac{4}{3}\pi R^3$.</p>', 3, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.14.</b> Tính diện tích của hình phẳng được tô màu trong Hình 4.29.</p>
<p><div><img src="/static/img/sgk/hinh-4-29.png" alt="Hình minh họa bài 4.14 (SGK)"></div></p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.15.</b> Tính diện tích của hình phẳng giới hạn bởi các đường:</p>
<ol type="a"><li>$y=e^x,\ y=x^2-1,\ x=-1,\ x=1$;</li>
<li>$y=\sin x,\ y=x,\ x=\dfrac{\pi}{2},\ x=\pi$;</li>
<li>$y=9-x^2,\ y=2x^2,\ x=-\sqrt{3},\ x=\sqrt{3}$;</li>
<li>$y=\sqrt{x},\ y=x^2,\ x=0,\ x=1$.</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.16.</b> Các nhà kinh tế sử dụng đường cong Lorenz để minh hoạ sự phân phối thu nhập trong một quốc gia. Gọi $x$ là đại diện cho phần trăm số gia đình trong một quốc gia và $y$ là phần trăm tổng thu nhập. Đường $y=x$ sẽ đại diện cho một quốc gia mà các gia đình có thu nhập như nhau. Đường cong Lorenz $y=f(x)$ biểu thị phân phối thu nhập thực tế. Diện tích hình phẳng giới hạn bởi hai đường này, với $0\le x\le 100$, biểu thị &ldquo;sự bất bình đẳng về thu nhập&rdquo; của một quốc gia. Năm 2005, đường cong Lorenz của Hoa Kỳ có thể được mô hình hoá bởi hàm số
$$y=\left(0{,}00061x^2+0{,}0218x+1\,723\right)^2,\quad 0\le x\le 100,$$
trong đó $x$ được tính từ các gia đình nghèo nhất đến giàu có nhất (Theo <i>R. Larson, Brief Calculus: An Applied Approach, 8th edition, Cengage Learning, 2009</i>).</p>
<p>Tìm sự bất bình đẳng về thu nhập của Hoa Kỳ vào năm 2005.</p>', NULL, 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.17.</b> Tính thể tích của khối tròn xoay sinh ra khi quay hình phẳng giới hạn bởi các đường sau xung quanh trục $Ox$: $y=2x-x^2,\ y=0,\ x=0,\ x=2$.</p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.18.</b> Khối chỏm cầu có bán kính $R$ và chiều cao $h\ (0&lt;h\le R)$ sinh ra khi quay hình phẳng giới hạn bởi cung tròn có phương trình $y=\sqrt{R^2-x^2}$, trục hoành và hai đường thẳng $x=R-h,\ x=R$ xung quanh trục $Ox$ (H.4.30). Tính thể tích của khối chỏm cầu này.</p>
<p><div><img src="/static/img/sgk/hinh-4-30.png" alt="Hình minh họa bài 4.18 (SGK)"></div></p>', NULL, 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.19.</b> Cho tam giác vuông $OAB$ có cạnh $OA=a$ nằm trên trục $Ox$ và $\widehat{AOB}=\alpha\ \left(0&lt;\alpha\le\dfrac{\pi}{4}\right)$. Gọi $\mathcal{B}$ là khối tròn xoay sinh ra khi quay miền tam giác $OAB$ xung quanh trục $Ox$ (H.4.31).</p>
<ol type="a"><li>Tính thể tích $V$ của $\mathcal{B}$ theo $a$ và $\alpha$.</li>
<li>Tìm $\alpha$ sao cho thể tích $V$ lớn nhất.</li></ol>
<p><div><img src="/static/img/sgk/hinh-4-31.png" alt="Hình minh họa bài 4.19 (SGK)"></div></p>', NULL, 3, 0, 1, @t1);
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài tập cuối chương IV', N'Bài tập tổng hợp chương IV gồm phần trắc nghiệm và tự luận về nguyên hàm, tích phân, diện tích hình phẳng, thể tích khối tròn xoay và các bài toán thực tiễn.', N'<p>Đây là phần bài tập tổng hợp của chương IV (Nguyên hàm và tích phân), gồm các câu trắc nghiệm và tự luận ôn tập toàn bộ kiến thức Bài 11, 12, 13.</p>', 4, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 4.20.</b> Một nguyên hàm của hàm số $f(x)=\sin 2x$ là</p>', N'<p>$\int \sin 2x\,dx=-\tfrac12\cos 2x+C$. Đạo hàm của $-\tfrac12\cos2x$ là $\sin2x$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$F(x)=2\cos 2x$.', 0),
(@q, 'B', N'$F(x)=-\cos 2x$.', 0),
(@q, 'C', N'$F(x)=\dfrac12\cos 2x$.', 0),
(@q, 'D', N'$F(x)=\dfrac{-1}{2}\cos 2x$.', 1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 4.21.</b> Họ các nguyên hàm của hàm số $2e^x$ là</p>', N'<p>$\int 2e^x\,dx=2e^x+C$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$2xe^x+C$.', 0),
(@q, 'B', N'$-2e^x+C$.', 0),
(@q, 'C', N'$2e^x$.', 0),
(@q, 'D', N'$2e^x+C$.', 1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 4.22.</b> Nguyên hàm $F(x)$ của hàm số $f(x)=e^x-3e^{-x}$ thoả mãn $F(0)=4$ là</p>', N'<p>$F(x)=e^x+3e^{-x}+C$. $F(0)=1+3+C=4\Rightarrow C=0$, nên $F(x)=e^x+3e^{-x}$.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$F(x)=e^x-3e^{-x}$.', 0),
(@q, 'B', N'$F(x)=e^x+3e^{-2x}$.', 0),
(@q, 'C', N'$F(x)=e^x+3e^{-x}$.', 1),
(@q, 'D', N'$F(x)=e^x+3e^{-x}+4$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 4.23.</b> Cho hàm số $f(x)$ có đạo hàm $f''(x)$ liên tục trên $\mathbb{R}$, $f(1)=16$ và $\int_1^3 f''(x)\,\mathrm{d}x=4$. Khi đó giá trị của $f(3)$ bằng</p>', N'<p>$f(3)-f(1)=4\Rightarrow f(3)=16+4=20$.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'20.', 1),
(@q, 'B', N'16.', 0),
(@q, 'C', N'12.', 0),
(@q, 'D', N'10.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 4.24.</b> Diện tích hình phẳng giới hạn bởi đồ thị các hàm số $y=x^2-2x,\ y=-x^2+4x$ và hai đường thẳng $x=0,\ x=3$ là</p>', N'<p>$|(x^2-2x)-(-x^2+4x)|=|2x^2-6x|=6x-2x^2$ trên $[0;3]$.</p><p>$S=\int_0^3(6x-2x^2)dx=27-18=9$.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$-9$.', 0),
(@q, 'B', N'$9$.', 1),
(@q, 'C', N'$\dfrac{16}{3}$.', 0),
(@q, 'D', N'$\dfrac{20}{3}$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 4.25.</b> Cho đồ thị hàm số $y=f(x)$ trên đoạn $[-2;2]$ như Hình 4.32.</p>
<p><div><img src="/static/img/sgk/hinh-4-32.png" alt="Hình minh họa bài 4.25 (SGK)"></div></p>
<p>Biết $\int_{-2}^{-1}f(x)\,\mathrm{d}x=\int_1^2 f(x)\,\mathrm{d}x=\dfrac{-22}{15}$ và $\int_{-1}^{1}f(x)\,\mathrm{d}x=\dfrac{76}{15}$. Khi đó, diện tích của hình phẳng được tô màu là</p>', N'<p>Diện tích $=\left|\int_{-2}^{-1}f\right|+\int_{-1}^1 f+\left|\int_1^2 f\right|=\tfrac{22}{15}+\tfrac{76}{15}+\tfrac{22}{15}=\tfrac{120}{15}=8$.</p>', 3, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$8$.', 1),
(@q, 'B', N'$\dfrac{22}{15}$.', 0),
(@q, 'C', N'$\dfrac{32}{15}$.', 0),
(@q, 'D', N'$\dfrac{76}{15}$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 4.26.</b> Cho hình phẳng $(S)$ giới hạn bởi đồ thị hàm số $y=\sqrt{1-x^2}$, trục hoành và hai đường thẳng $x=-1,\ x=1$. Thể tích của khối tròn xoay sinh ra khi quay $(S)$ quanh $Ox$ là</p>', N'<p>$V=\pi\int_{-1}^1(1-x^2)dx=\pi\left(2-\tfrac23\right)=\tfrac{4\pi}{3}$ (thể tích khối cầu bán kính 1).</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$\dfrac{3\pi}{4}$.', 0),
(@q, 'B', N'$\dfrac{3\pi}{2}$.', 0),
(@q, 'C', N'$\dfrac{2\pi}{3}$.', 0),
(@q, 'D', N'$\dfrac{4\pi}{3}$.', 1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 4.27.</b> Một vật chuyển động có gia tốc là $a(t)=3t^2+t$ (m/s$^2$). Biết rằng vận tốc ban đầu của vật là 2 m/s. Vận tốc của vật đó sau 2 giây là</p>', N'<p>$v(t)=\int(3t^2+t)dt=t^3+\tfrac{t^2}{2}+C$, $v(0)=2\Rightarrow C=2$. $v(2)=8+2+2=12$ m/s.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'8 m/s.', 0),
(@q, 'B', N'10 m/s.', 0),
(@q, 'C', N'12 m/s.', 1),
(@q, 'D', N'16 m/s.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.28.</b> Tìm họ các nguyên hàm của các hàm số sau:</p>
<ol type="a"><li>$y=2^x-\dfrac{1}{x}$;</li>
<li>$y=x\sqrt{x}+3\cos x-\dfrac{2}{\sin^2 x}$.</li></ol>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.29.</b> Tìm một nguyên hàm $F(x)$ của hàm số $f(x)=2\cos x+\dfrac{1}{\sin^2 x}$ thoả mãn điều kiện $F\left(\dfrac{\pi}{4}\right)=-1$.</p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.30.</b> Một viên đạn được bắn lên từ mặt đất theo phương thẳng đứng với vận tốc ban đầu là 30 m/s. Viên đạn chuyển động với gia tốc $a=-9{,}8$ m/s$^2$. Tìm vận tốc của viên đạn ở thời điểm 2 giây.</p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.31.</b> Cá hồi Thái Bình Dương đến mùa sinh sản thường bơi từ biển ngược dòng vào sông và đến thượng nguồn các dòng sông để đẻ trứng. Giả sử cá bơi ngược dòng sông với vận tốc là $v(t)=-\dfrac{2t}{5}+4$ (km/h). Nếu coi thời điểm ban đầu $t=0$ là lúc cá bắt đầu bơi vào dòng sông thì khoảng cách xa nhất mà con cá có thể bơi được là bao nhiêu?</p>', NULL, 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.32.</b> Tính các tích phân sau:</p>
<ol type="a"><li>$\int_1^4\left(x^3-2\sqrt{x}\right)\mathrm{d}x$;</li>
<li>$\int_0^{\frac{\pi}{2}}(\cos x-\sin x)\,\mathrm{d}x$;</li>
<li>$\int_{\frac{\pi}{6}}^{\frac{\pi}{4}}\dfrac{\mathrm{d}x}{\sin^2 x}$;</li>
<li>$\int_1^{16}\dfrac{x-1}{\sqrt{x}}\,\mathrm{d}x$.</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.33.</b> Tính diện tích hình phẳng giới hạn bởi các đường $y=e^x,\ y=x,\ x=0$ và $x=1$.</p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.34.</b> Tính thể tích của khối tròn xoay sinh ra khi quay hình phẳng giới hạn bởi các đường sau xung quanh trục $Ox$:</p>
<ol type="a"><li>$y=1-x^2,\ y=0,\ x=-1,\ x=1$;</li>
<li>$y=\sqrt{25-x^2},\ y=0,\ x=2,\ x=4$.</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.35.</b> Nghệ thuật làm gốm có lịch sử phát triển lâu đời và vẫn còn tồn tại cho đến ngày nay. Giả sử một bình gốm có mặt trong của bình là một mặt tròn xoay sinh ra khi cho phần đồ thị của hàm số $y=\dfrac{1}{175}x^2+\dfrac{3}{35}x+5\ (0\le x\le 30)$ ($x,y$ tính theo cm) quay tròn quanh bệ gốm có trục trùng với trục hoành $Ox$. Hỏi để hoàn thành bình gốm đó ta cần sử dụng bao nhiêu centimét khối đất sét, biết rằng bình gốm đó có độ dày không đổi là 1 cm?</p>', NULL, 3, 0, 1, @t1);

-- ---------------------------------------------------------------------------------------------------------------------
-- Chương III. Các số đặc trưng đo mức độ phân tán của mẫu số liệu ghép nhóm
-- ---------------------------------------------------------------------------------------------------------------------
INSERT INTO Topics (TopicName, [Description], TeacherId, OrderIndex, IsActive) VALUES (N'Chương III. Các số đặc trưng đo mức độ phân tán của mẫu số liệu ghép nhóm', N'Chương giới thiệu các số đặc trưng đo mức độ phân tán của mẫu số liệu ghép nhóm: khoảng biến thiên, khoảng tứ phân vị, phương sai và độ lệch chuẩn. (SGK Toán 12 Kết nối tri thức với cuộc sống, Tập 1)', @t1, 3, 1);
SET @tp = SCOPE_IDENTITY();
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 9. Khoảng biến thiên và khoảng tứ phân vị', N'Tính khoảng biến thiên, tứ phân vị và khoảng tứ phân vị của mẫu số liệu ghép nhóm; hiểu ý nghĩa của chúng trong việc đo mức độ phân tán của số liệu.', N'<p>Cho mẫu số liệu ghép nhóm gồm các nhóm $[a_1; a_2), \ldots, [a_i; a_{i+1}), \ldots, [a_k; a_{k+1})$ với tần số tương ứng $m_1, \ldots, m_k$ ($m_1 > 0$, $m_k > 0$) và cỡ mẫu $n = m_1 + \ldots + m_k$.</p>
<p><b>1. Khoảng biến thiên.</b> Khoảng biến thiên của mẫu số liệu ghép nhóm là $$R = a_{k+1} - a_1.$$</p>
<p><i>Ý nghĩa.</i> Khoảng biến thiên của mẫu số liệu ghép nhóm xấp xỉ cho khoảng biến thiên của mẫu số liệu gốc, dùng để đo mức độ phân tán: khoảng biến thiên càng lớn thì mẫu số liệu càng phân tán.</p>
<p><b>2. Khoảng tứ phân vị.</b> Tứ phân vị thứ $r$ ($r = 1, 2, 3$) là
$$Q_r = a_p + \dfrac{\dfrac{r \cdot n}{4} - (m_1 + \ldots + m_{p-1})}{m_p} \cdot (a_{p+1} - a_p),$$
trong đó $[a_p; a_{p+1})$ là nhóm chứa tứ phân vị thứ $r$.</p>
<p>Khoảng tứ phân vị của mẫu số liệu ghép nhóm, kí hiệu $\Delta_Q$, là hiệu giữa tứ phân vị thứ ba và tứ phân vị thứ nhất: $$\Delta_Q = Q_3 - Q_1.$$</p>
<p><i>Ý nghĩa.</i> Khoảng tứ phân vị xấp xỉ cho khoảng tứ phân vị của mẫu số liệu gốc, cũng dùng để đo mức độ phân tán: càng lớn thì mẫu số liệu càng phân tán.</p>
<p><i>Nhận xét.</i> Khoảng tứ phân vị chỉ phụ thuộc vào nửa giữa của mẫu số liệu nên không bị ảnh hưởng bởi các giá trị bất thường và có thể dùng để loại giá trị bất thường.</p>
<p><b>Ví dụ.</b> Thời gian chờ khám bệnh tại phòng khám X:</p>
<table border="1"><tr><td>Thời gian (phút)</td><td>[0; 5)</td><td>[5; 10)</td><td>[10; 15)</td><td>[15; 20)</td></tr><tr><td>Số bệnh nhân</td><td>3</td><td>12</td><td>15</td><td>8</td></tr></table>
<p>Cỡ mẫu $n = 38$. Nhóm chứa $Q_1$ là $[5; 10)$: $Q_1 = 5 + \dfrac{\frac{38}{4} - 3}{12} \cdot 5 \approx 7{,}71$. Nhóm chứa $Q_3$ là $[10; 15)$: $Q_3 = 10 + \dfrac{\frac{3 \cdot 38}{4} - 15}{15} \cdot 5 = 14{,}5$. Vậy $\Delta_Q = Q_3 - Q_1 \approx 6{,}79$.</p>', 1, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.1.</b> Thống kê số thẻ vàng của mỗi câu lạc bộ trong giải ngoại hạng Anh mùa giải 2021 – 2022 cho kết quả như sau:</p>
<p>101, 79, 79, 78, 75, 73, 68, 67, 67, 63,<br>63, 61, 60, 59, 57, 55, 55, 50, 47, 42.</p>
<ol type="a"><li>Hãy ghép nhóm dãy số liệu trên thành các nhóm có độ dài bằng nhau với nhóm đầu tiên là $[40; 50)$.</li>
<li>Tính khoảng biến thiên, khoảng tứ phân vị của mẫu số liệu gốc và mẫu số liệu ghép nhóm thu được ở câu a. Giá trị nào là giá trị chính xác? Giá trị nào là giá trị xấp xỉ?</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.2.</b> Thu nhập theo tháng của người lao động ở hai nhà máy như sau:</p><table border="1"><tr><td>Thu nhập (triệu đồng)</td><td>[5; 8)</td><td>[8; 11)</td><td>[11; 14)</td><td>[14; 17)</td><td>[17; 20)</td></tr><tr><td>Số người của nhà máy A</td><td>20</td><td>35</td><td>45</td><td>35</td><td>20</td></tr><tr><td>Số người của nhà máy B</td><td>17</td><td>23</td><td>30</td><td>23</td><td>17</td></tr></table><p>Tính mức thu nhập trung bình của người lao động ở hai nhà máy trên. Dựa vào khoảng tứ phân vị, hãy xác định xem mức thu nhập của người lao động ở nhà máy nào biến động nhiều hơn.</p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.3.</b> Bảng sau đây cho biết chiều cao của các học sinh hai lớp 12A và 12B.</p><table border="1"><tr><td>Chiều cao (cm)</td><td>[145; 150)</td><td>[150; 155)</td><td>[155; 160)</td><td>[160; 165)</td><td>[165; 170)</td><td>[170; 175)</td></tr><tr><td>Số học sinh của lớp 12A</td><td>1</td><td>0</td><td>15</td><td>12</td><td>10</td><td>5</td></tr><tr><td>Số học sinh của lớp 12B</td><td>0</td><td>0</td><td>17</td><td>10</td><td>9</td><td>6</td></tr></table><ol type="a"><li>Tìm khoảng biến thiên, khoảng tứ phân vị cho các mẫu số liệu ghép nhóm về chiều cao của học sinh hai lớp 12A và 12B.</li>
<li>Để so sánh độ phân tán về chiều cao của học sinh hai lớp này ta nên dùng khoảng biến thiên hay khoảng tứ phân vị? Vì sao?</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 10. Phương sai và độ lệch chuẩn', N'Tính phương sai, độ lệch chuẩn của mẫu số liệu ghép nhóm, hiểu ý nghĩa đo độ phân tán quanh số trung bình và ứng dụng đo độ rủi ro trong đầu tư.', N'<p>Xét mẫu số liệu ghép nhóm gồm các nhóm $[a_i; a_{i+1})$ với tần số $m_i$, $i = 1, \ldots, k$ và cỡ mẫu $n = m_1 + \ldots + m_k$.</p>
<p><b>1. Phương sai và độ lệch chuẩn.</b></p>
<ul>
<li>Phương sai của mẫu số liệu ghép nhóm, kí hiệu $s^2$, được tính theo công thức
$$s^2 = \dfrac{m_1 (x_1 - \overline{x})^2 + \ldots + m_k (x_k - \overline{x})^2}{n},$$
trong đó $x_i = \dfrac{a_i + a_{i+1}}{2}$ ($i = 1, 2, \ldots, k$) là giá trị đại diện cho nhóm $[a_i; a_{i+1})$ và $\overline{x} = \dfrac{m_1 x_1 + \ldots + m_k x_k}{n}$ là số trung bình của mẫu số liệu ghép nhóm.</li>
<li>Độ lệch chuẩn của mẫu số liệu ghép nhóm, kí hiệu $s$, là căn bậc hai số học của phương sai: $s = \sqrt{s^2}$.</li>
</ul>
<p><i>Nhận xét.</i> Có thể tính phương sai theo công thức $$s^2 = \dfrac{1}{n}\left(m_1 x_1^2 + \ldots + m_k x_k^2\right) - \left(\overline{x}\right)^2.$$ Độ lệch chuẩn có cùng đơn vị với đơn vị của mẫu số liệu.</p>
<p><i>Ý nghĩa.</i> Phương sai, độ lệch chuẩn của mẫu số liệu ghép nhóm xấp xỉ cho phương sai, độ lệch chuẩn của mẫu số liệu gốc. Chúng đo mức độ phân tán của mẫu số liệu xung quanh số trung bình; phương sai, độ lệch chuẩn càng lớn thì mẫu số liệu càng phân tán.</p>
<p><i>Chú ý.</i> Người ta còn dùng đại lượng $\hat{s}^2 = \dfrac{m_1 (x_1 - \overline{x})^2 + \ldots + m_k (x_k - \overline{x})^2}{n - 1}$, $\hat{s} = \sqrt{\hat{s}^2}$.</p>
<p><b>2. Sử dụng phương sai, độ lệch chuẩn đo độ rủi ro.</b> Trong tài chính, độ lệch chuẩn của lợi nhuận thu được theo phương án đầu tư được dùng để đo độ rủi ro: độ lệch chuẩn càng lớn thì phương án đầu tư càng rủi ro.</p>
<p><i>Nhận xét.</i> Không nên dùng phương sai hay độ lệch chuẩn để so sánh độ rủi ro của hai phương án đầu tư khi lợi nhuận trung bình của hai phương án này khác nhau rất nhiều.</p>
<p><i>Em có biết?</i> Để so sánh độ phân tán của hai mẫu số liệu khi đơn vị đo khác nhau hoặc giá trị trung bình khác nhau rất nhiều, người ta dùng hệ số biến thiên $CV = \dfrac{s}{\overline{x}}$.</p>
<p><b>Ví dụ.</b> Số tiền thu được mỗi tháng (triệu đồng) trong 60 tháng khi đầu tư vào hai lĩnh vực A, B:</p>
<table border="1"><tr><td>Số tiền</td><td>[5; 10)</td><td>[10; 15)</td><td>[15; 20)</td><td>[20; 25)</td><td>[25; 30)</td></tr><tr><td>Số tháng (A)</td><td>5</td><td>10</td><td>30</td><td>10</td><td>5</td></tr><tr><td>Số tháng (B)</td><td>20</td><td>5</td><td>10</td><td>5</td><td>20</td></tr></table>
<p>Lấy giá trị đại diện $7{,}5; 12{,}5; 17{,}5; 22{,}5; 27{,}5$: $\overline{x}_A = \overline{x}_B = 17{,}5$; $s_A = 5$, $s_B \approx 8{,}42$. Vì $s_B > s_A$ nên đầu tư vào lĩnh vực B rủi ro hơn.</p>', 2, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.4.</b> Kiểm tra khối lượng của 30 bao xi măng (đơn vị: kg) được chọn ngẫu nhiên trước khi xuất xưởng cho kết quả như sau:</p>
<p>49,5 51,1 50,8 50,2 48,7 49,6 51,3 51,4 50,1 50,5<br>48,9 49,3 50,7 48,8 49,8 48,8 51,2 50,4 50,0 51,2<br>51,4 48,7 51,2 50,6 50,9 49,2 50,7 51,1 48,6 49,6.</p>
<ol type="a"><li>Thay mỗi dấu "?" bằng số thích hợp để hoàn thiện mẫu số liệu ghép nhóm sau:<table border="1"><tr><td>Nhóm số liệu</td><td>[48,5; 49)</td><td>[49; 49,5)</td><td>[49,5; 50)</td><td>[50; 50,5)</td><td>[50,5; 51)</td><td>[51; 51,5)</td></tr><tr><td>Số bao xi măng</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td></tr></table></li>
<li>Tính phương sai và độ lệch chuẩn của mẫu số liệu gốc và mẫu số liệu ghép nhóm. Giá trị nào là giá trị chính xác? Giá trị nào là giá trị xấp xỉ?</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.5.</b> Tuổi thọ của một số linh kiện điện tử được sản xuất bởi hai phân xưởng được cho như sau:</p><table border="1"><tr><td>Tuổi thọ (năm)</td><td>[1,5; 2)</td><td>[2; 2,5)</td><td>[2,5; 3)</td><td>[3; 3,5)</td><td>[3,5; 4)</td></tr><tr><td>Số linh kiện của phân xưởng 1</td><td>4</td><td>9</td><td>13</td><td>8</td><td>6</td></tr><tr><td>Số linh kiện của phân xưởng 2</td><td>2</td><td>8</td><td>20</td><td>7</td><td>3</td></tr></table><p>Tính phương sai và độ lệch chuẩn của mỗi mẫu số liệu ghép nhóm và nhận xét về độ phân tán của tuổi thọ các linh kiện điện tử được sản xuất bởi mỗi phân xưởng.</p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.6.</b> Một nhóm 20 học sinh dùng một thiết bị đo đường kính của một nhân tế bào cho kết quả như sau:</p><table border="1"><tr><td>Kết quả đo (μm)</td><td>[4,5; 5)</td><td>[5; 5,5)</td><td>[5,5; 6)</td><td>[6; 6,5)</td></tr><tr><td>Số học sinh</td><td>3</td><td>8</td><td>7</td><td>2</td></tr></table><ol type="a"><li>Tính số trung bình và độ lệch chuẩn của mẫu số liệu ghép nhóm trên.</li>
<li>Số trung bình và độ lệch chuẩn cho biết thông tin gì?</li></ol>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.7.</b> Thời gian chạy tập luyện cự li 100 mét của hai vận động viên A và B được cho trong bảng sau:</p><table border="1"><tr><td>Thời gian (giây)</td><td>[10; 10,3)</td><td>[10,3; 10,6)</td><td>[10,6; 10,9)</td><td>[10,9; 11,2)</td></tr><tr><td>Số lần chạy của A</td><td>2</td><td>10</td><td>5</td><td>3</td></tr><tr><td>Số lần chạy của B</td><td>3</td><td>7</td><td>9</td><td>6</td></tr></table><p>Dựa trên độ lệch chuẩn của các mẫu số liệu ghép nhóm, hãy cho biết vận động viên nào có thành tích luyện tập ổn định hơn.</p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.8.</b> Có nên dùng phương sai (hoặc độ lệch chuẩn) để so sánh độ phân tán của hai mẫu số liệu ghép nhóm trong mỗi trường hợp sau không? Tại sao?</p>
<ol type="a"><li>Các mẫu số liệu ghép nhóm về điểm thi tốt nghiệp môn Toán của học sinh hai trường trung học phổ thông có chất lượng tương đương.</li>
<li>Các mẫu số liệu ghép nhóm về doanh thu của 100 cửa hàng bán lẻ và doanh thu của 100 siêu thị.</li></ol>', NULL, 3, 0, 1, @t1);
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài tập cuối chương III', N'Bài tập tổng hợp trắc nghiệm và tự luận về khoảng biến thiên, khoảng tứ phân vị, phương sai và độ lệch chuẩn của mẫu số liệu ghép nhóm.', N'<p>Đây là phần bài tập tổng hợp của Chương III, gồm câu hỏi trắc nghiệm và bài tập tự luận.</p>', 3, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 3.9.</b> Một vườn thú ghi lại tuổi thọ của 20 con hổ và thu được kết quả như sau:</p><table border="1"><tr><td>Tuổi thọ (năm)</td><td>[14; 15)</td><td>[15; 16)</td><td>[16; 17)</td><td>[17; 18)</td><td>[18; 19)</td></tr><tr><td>Số con hổ</td><td>1</td><td>3</td><td>8</td><td>6</td><td>2</td></tr></table><p>Khoảng biến thiên của mẫu số liệu ghép nhóm trên là</p>', N'<p>Khoảng biến thiên $=19-14=5$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'3.', 0),
(@q, 'B', N'4.', 0),
(@q, 'C', N'5.', 1),
(@q, 'D', N'6.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 3.10.</b> Một vườn thú ghi lại tuổi thọ của 20 con hổ và thu được kết quả như sau:</p><table border="1"><tr><td>Tuổi thọ (năm)</td><td>[14; 15)</td><td>[15; 16)</td><td>[16; 17)</td><td>[17; 18)</td><td>[18; 19)</td></tr><tr><td>Số con hổ</td><td>1</td><td>3</td><td>8</td><td>6</td><td>2</td></tr></table><p>Nhóm chứa tứ phân vị thứ nhất là</p>', N'<p>$n=20$, tần số tích luỹ: $1,4,12,18,20$. $Q_1$ ứng với giá trị thứ $n/4=5$, rơi vào nhóm có tần số tích luỹ vượt $5$ đầu tiên là $[16;17)$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$[14; 15)$.', 0),
(@q, 'B', N'$[15; 16)$.', 0),
(@q, 'C', N'$[16; 17)$.', 1),
(@q, 'D', N'$[17; 18)$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 3.11.</b> Một vườn thú ghi lại tuổi thọ của 20 con hổ và thu được kết quả như sau:</p><table border="1"><tr><td>Tuổi thọ (năm)</td><td>[14; 15)</td><td>[15; 16)</td><td>[16; 17)</td><td>[17; 18)</td><td>[18; 19)</td></tr><tr><td>Số con hổ</td><td>1</td><td>3</td><td>8</td><td>6</td><td>2</td></tr></table><p>Nhóm chứa tứ phân vị thứ ba là</p>', N'<p>$Q_3$ ứng với $3n/4=15$; tần số tích luỹ $12\lt15\le18$ nên nhóm chứa $Q_3$ là $[17;18)$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$[15; 16)$.', 0),
(@q, 'B', N'$[16; 17)$.', 0),
(@q, 'C', N'$[17; 18)$.', 1),
(@q, 'D', N'$[18; 19)$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 3.12.</b> Một vườn thú ghi lại tuổi thọ của 20 con hổ và thu được kết quả như sau:</p><table border="1"><tr><td>Tuổi thọ (năm)</td><td>[14; 15)</td><td>[15; 16)</td><td>[16; 17)</td><td>[17; 18)</td><td>[18; 19)</td></tr><tr><td>Số con hổ</td><td>1</td><td>3</td><td>8</td><td>6</td><td>2</td></tr></table><p>Số đặc trưng nào <b>không</b> sử dụng thông tin của nhóm số liệu đầu tiên và nhóm số liệu cuối cùng?</p>', N'<p>Khoảng biến thiên dùng đầu mút nhóm đầu và nhóm cuối; phương sai và độ lệch chuẩn dùng mọi nhóm. Khoảng tứ phân vị $Q_3-Q_1$ chỉ dùng các nhóm chứa $Q_1,Q_3$ và các nhóm ở giữa ($[16;17)$, $[17;18)$ và nhóm tích luỹ liên quan), không dùng nhóm đầu và cuối.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'Khoảng biến thiên.', 0),
(@q, 'B', N'Khoảng tứ phân vị.', 1),
(@q, 'C', N'Phương sai.', 0),
(@q, 'D', N'Độ lệch chuẩn.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 3.13.</b> Một vườn thú ghi lại tuổi thọ của 20 con hổ và thu được kết quả như sau:</p><table border="1"><tr><td>Tuổi thọ (năm)</td><td>[14; 15)</td><td>[15; 16)</td><td>[16; 17)</td><td>[17; 18)</td><td>[18; 19)</td></tr><tr><td>Số con hổ</td><td>1</td><td>3</td><td>8</td><td>6</td><td>2</td></tr></table><p>Nếu thay tất cả các tần số trong mẫu số liệu ghép nhóm trên bằng 4 thì số đặc trưng nào sau đây không thay đổi?</p>', N'<p>Khoảng biến thiên chỉ phụ thuộc đầu mút các nhóm nên không đổi ($5$). Khi các tần số đều bằng $4$, phân bố thay đổi nên $Q_1,Q_3$, phương sai, độ lệch chuẩn đều thay đổi.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'Khoảng biến thiên.', 1),
(@q, 'B', N'Khoảng tứ phân vị.', 0),
(@q, 'C', N'Phương sai.', 0),
(@q, 'D', N'Độ lệch chuẩn.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.14.</b> Để đánh giá chất lượng một loại pin điện thoại mới, người ta ghi lại thời gian nghe nhạc liên tục của điện thoại được sạc đầy pin cho đến khi hết pin cho kết quả như sau:</p><table border="1"><tr><td>Thời gian (giờ)</td><td>[5; 5,5)</td><td>[5,5; 6)</td><td>[6; 6,5)</td><td>[6,5; 7)</td><td>[7; 7,5)</td></tr><tr><td>Số chiếc điện thoại (tần số)</td><td>2</td><td>8</td><td>15</td><td>10</td><td>5</td></tr></table><p>Tính khoảng biến thiên, khoảng tứ phân vị và độ lệch chuẩn của mẫu số liệu ghép nhóm trên.</p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.15.</b> Người ta ghi lại tiền lãi của một số nhà đầu tư (với số tiền đầu tư như nhau), khi đầu tư vào hai lĩnh vực A và B cho kết quả như sau:</p><table border="1"><tr><td>Tiền lãi (triệu đồng)</td><td>[5; 10)</td><td>[10; 15)</td><td>[15; 20)</td><td>[20; 25)</td><td>[25; 30)</td></tr><tr><td>Số nhà đầu tư vào lĩnh vực A</td><td>2</td><td>5</td><td>8</td><td>6</td><td>4</td></tr><tr><td>Số nhà đầu tư vào lĩnh vực B</td><td>8</td><td>4</td><td>2</td><td>5</td><td>6</td></tr></table><ol type="a"><li>Về trung bình, đầu tư vào lĩnh vực nào đem lại tiền lãi cao hơn?</li>
<li>Tính độ lệch chuẩn cho các mẫu số liệu về tiền lãi của các nhà đầu tư ở hai lĩnh vực này và giải thích ý nghĩa của các số thu được.</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.16.</b> Thành tích môn nhảy cao của các vận động viên tại một giải điền kinh dành cho học sinh trung học phổ thông như sau:</p><table border="1"><tr><td>Mức xà (cm)</td><td>[170; 172)</td><td>[172; 174)</td><td>[174; 176)</td><td>[176; 178)</td></tr><tr><td>Số vận động viên</td><td>3</td><td>10</td><td>6</td><td>1</td></tr></table><ol type="a"><li>Tính các số đặc trưng đo mức độ phân tán của mẫu số liệu ghép nhóm trên.</li>
<li>Độ phân tán của mẫu số liệu cho biết điều gì?</li></ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.17.</b> Trong bài thực hành đo hiệu điện thế của mạch điện, An và Bình đã dùng hai vôn kế khác nhau để đo, mỗi bạn tiến hành đo 10 lần cho kết quả như sau:</p><table border="1"><tr><td>Hiệu điện thế đo được (Vôn)</td><td>[3,85; 3,90)</td><td>[3,90; 3,95)</td><td>[3,95; 4,00)</td><td>[4,00; 4,05)</td></tr><tr><td>Số lần An đo</td><td>1</td><td>6</td><td>2</td><td>1</td></tr><tr><td>Số lần Bình đo</td><td>1</td><td>3</td><td>4</td><td>2</td></tr></table><p>Tính độ lệch chuẩn của các mẫu số liệu ghép nhóm cho kết quả đo của An và Bình. Từ đó kết luận xem vôn kế của bạn nào cho kết quả đo ổn định hơn.</p>', NULL, 2, 0, 1, @t1);

-- ---------------------------------------------------------------------------------------------------------------------
-- Chương II. Vectơ và hệ trục toạ độ trong không gian
-- ---------------------------------------------------------------------------------------------------------------------
INSERT INTO Topics (TopicName, [Description], TeacherId, OrderIndex, IsActive) VALUES (N'Chương II. Vectơ và hệ trục toạ độ trong không gian', N'Chương giới thiệu vectơ và các phép toán vectơ trong không gian, hệ trục toạ độ Oxyz, toạ độ của điểm và vectơ cùng biểu thức toạ độ của các phép toán vectơ, kèm ứng dụng vào bài toán thực tiễn. (SGK Toán 12 Kết nối tri thức với cuộc sống, Tập 1)', @t1, 2, 1);
SET @tp = SCOPE_IDENTITY();
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 6. Vectơ trong không gian', N'Khái niệm vectơ trong không gian, hai vectơ bằng nhau, tổng và hiệu hai vectơ, tích của một số với một vectơ, góc giữa hai vectơ và tích vô hướng, cùng quy tắc hình hộp.', N'<p><b>1. Vectơ trong không gian.</b> Vectơ trong không gian là một đoạn thẳng có hướng. Độ dài của vectơ là khoảng cách giữa điểm đầu và điểm cuối của vectơ đó. Kí hiệu: $\overrightarrow{AB}$, $\vec{a}$; độ dài $|\overrightarrow{AB}|$, $|\vec{a}|$. Đường thẳng đi qua điểm đầu và điểm cuối của một vectơ gọi là giá của vectơ đó.</p>
<ul>
<li>Hai vectơ cùng phương nếu giá của chúng song song hoặc trùng nhau; hai vectơ cùng phương thì cùng hướng hoặc ngược hướng.</li>
<li>Hai vectơ $\vec{a}$, $\vec{b}$ bằng nhau ($\vec{a}=\vec{b}$) nếu chúng có cùng độ dài và cùng hướng.</li>
<li>Với mỗi điểm $O$ và vectơ $\vec{a}$ cho trước, có duy nhất điểm $M$ sao cho $\overrightarrow{OM}=\vec{a}$.</li>
<li>Các vectơ có điểm đầu và điểm cuối trùng nhau ($\overrightarrow{AA}$, $\overrightarrow{BB}$,...) là vectơ-không, kí hiệu $\vec{0}$; có độ dài bằng 0, cùng hướng với mọi vectơ.</li>
</ul>
<p><b>2. Tổng và hiệu của hai vectơ.</b> Lấy điểm $A$ bất kì, $B$, $C$ sao cho $\overrightarrow{AB}=\vec{a}$, $\overrightarrow{BC}=\vec{b}$; khi đó $\overrightarrow{AC}$ là tổng của $\vec{a}$ và $\vec{b}$, kí hiệu $\vec{a}+\vec{b}$.</p>
<ul>
<li>Quy tắc ba điểm: $\overrightarrow{AB}+\overrightarrow{BC}=\overrightarrow{AC}$. Quy tắc hình bình hành: nếu $ABCD$ là hình bình hành thì $\overrightarrow{AB}+\overrightarrow{AD}=\overrightarrow{AC}$.</li>
<li>Quy tắc hình hộp: cho hình hộp $ABCD.A''B''C''D''$ thì $\overrightarrow{AB}+\overrightarrow{AD}+\overrightarrow{AA''}=\overrightarrow{AC''}$.</li>
<li>Tính chất: giao hoán, kết hợp, $\vec{a}+\vec{0}=\vec{a}$.</li>
<li>Vectơ đối của $\vec{a}$ là vectơ cùng độ dài, ngược hướng với $\vec{a}$, kí hiệu $-\vec{a}$. Hiệu: $\vec{a}-\vec{b}=\vec{a}+(-\vec{b})$. Với ba điểm $O, A, B$ bất kì: $\overrightarrow{OB}-\overrightarrow{OA}=\overrightarrow{AB}$.</li>
</ul>
<p><b>3. Tích của một số với một vectơ.</b> Với $k\neq 0$, $\vec{a}\neq\vec{0}$, vectơ $k\vec{a}$ cùng hướng với $\vec{a}$ nếu $k>0$, ngược hướng nếu $k<0$, và có độ dài $|k|\cdot|\vec{a}|$. Quy ước $0\vec{a}=\vec{0}$, $k\vec{0}=\vec{0}$.</p>
<ul>
<li>Điều kiện cần và đủ để hai vectơ $\vec{a}$, $\vec{b}$ ($\vec{b}\neq\vec{0}$) cùng phương là có số thực $k$ sao cho $\vec{a}=k\vec{b}$.</li>
<li>Tính chất: $h(k\vec{a})=(hk)\vec{a}$; $(h+k)\vec{a}=h\vec{a}+k\vec{a}$; $k(\vec{a}+\vec{b})=k\vec{a}+k\vec{b}$; $1\vec{a}=\vec{a}$; $(-1)\vec{a}=-\vec{a}$.</li>
<li>Nếu $G$ là trọng tâm tam giác $ABC$ thì với mọi điểm $O$: $\overrightarrow{OA}+\overrightarrow{OB}+\overrightarrow{OC}=3\overrightarrow{OG}$.</li>
</ul>
<p><b>4. Tích vô hướng của hai vectơ.</b> Góc giữa hai vectơ $\vec{a}$, $\vec{b}$ khác $\vec{0}$: lấy $O$, $A$, $B$ sao cho $\overrightarrow{OA}=\vec{a}$, $\overrightarrow{OB}=\vec{b}$, khi đó $\widehat{AOB}$ ($0^\circ\le\widehat{AOB}\le180^\circ$) là góc giữa $\vec{a}$ và $\vec{b}$, kí hiệu $(\vec{a},\vec{b})$.</p>
$$\vec{a}\cdot\vec{b}=|\vec{a}|\cdot|\vec{b}|\cdot\cos(\vec{a},\vec{b})$$
<ul>
<li>Nếu $\vec{a}=\vec{0}$ hoặc $\vec{b}=\vec{0}$ thì $\vec{a}\cdot\vec{b}=0$. Với $\vec{a},\vec{b}\neq\vec{0}$: $\vec{a}\perp\vec{b}\Leftrightarrow\vec{a}\cdot\vec{b}=0$; $\cos(\vec{a},\vec{b})=\dfrac{\vec{a}\cdot\vec{b}}{|\vec{a}|\cdot|\vec{b}|}$; $\vec{a}^2=|\vec{a}|^2$.</li>
<li>Tính chất: $\vec{a}\cdot\vec{b}=\vec{b}\cdot\vec{a}$; $k(\vec{a}\cdot\vec{b})=(k\vec{a})\cdot\vec{b}=\vec{a}\cdot(k\vec{b})$; $\vec{a}\cdot(\vec{b}+\vec{c})=\vec{a}\cdot\vec{b}+\vec{a}\cdot\vec{c}$.</li>
</ul>
<p><i>Ví dụ.</i> Cho hình lập phương $ABCD.A''B''C''D''$ có cạnh bằng 1. Tính $|\overrightarrow{BC}+\overrightarrow{DD''}|$. Giải: $\overrightarrow{BC}=\overrightarrow{AD}$ nên $\overrightarrow{BC}+\overrightarrow{DD''}=\overrightarrow{AD}+\overrightarrow{DD''}=\overrightarrow{AD''}$, suy ra $|\overrightarrow{BC}+\overrightarrow{DD''}|=AD''=\sqrt{2}$.</p>
<p><i>Ví dụ.</i> Cho tứ diện $ABCD$, $G$ là trọng tâm tam giác $BCD$. Chứng minh $\overrightarrow{AB}+\overrightarrow{AC}+\overrightarrow{AD}=3\overrightarrow{AG}$. Giải: vì $\overrightarrow{GB}+\overrightarrow{GC}+\overrightarrow{GD}=\vec{0}$ nên $\overrightarrow{AB}+\overrightarrow{AC}+\overrightarrow{AD}=3\overrightarrow{AG}+(\overrightarrow{GB}+\overrightarrow{GC}+\overrightarrow{GD})=3\overrightarrow{AG}$.</p>', 1, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.1.</b> Trong không gian, cho ba vectơ $\vec{a}$, $\vec{b}$, $\vec{c}$ phân biệt và đều khác $\vec{0}$. Những mệnh đề nào sau đây là đúng?</p>
<ol type="a">
<li>Nếu $\vec{a}$ và $\vec{b}$ đều cùng hướng với $\vec{c}$ thì $\vec{a}$ và $\vec{b}$ cùng hướng.</li>
<li>Nếu $\vec{a}$ và $\vec{b}$ đều ngược hướng với $\vec{c}$ thì $\vec{a}$ và $\vec{b}$ cùng hướng.</li>
<li>Nếu $\vec{a}$ và $\vec{b}$ đều cùng hướng với $\vec{c}$ thì $\vec{a}$ và $\vec{b}$ ngược hướng.</li>
<li>Nếu $\vec{a}$ và $\vec{b}$ đều ngược hướng với $\vec{c}$ thì $\vec{a}$ và $\vec{b}$ ngược hướng.</li>
</ol>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.2.</b> Cho hình hộp chữ nhật $ABCD.A''B''C''D''$ có $AB=2$, $AD=3$ và $AA''=4$. Tính độ dài của các vectơ $\overrightarrow{BB''}$, $\overrightarrow{BD}$ và $\overrightarrow{BD''}$.</p>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.3.</b> Một chiếc bàn cân đối hình chữ nhật được đặt trên mặt sàn nằm ngang, mặt bàn song song với mặt sàn và bốn chân bàn vuông góc với mặt sàn như Hình 2.29. Trọng lực tác dụng lên bàn (biểu thị bởi vectơ $\vec{a}$) phân tán đều qua bốn chân bàn và gây nên các phản lực từ mặt sàn lên các chân bàn (biểu thị bởi các vectơ $\vec{b}$, $\vec{c}$, $\vec{d}$, $\vec{e}$). <div><img src="/static/img/sgk/hinh-2-29.png" alt="Hình minh họa bài 2.3 (SGK)"></div></p>
<ol type="a">
<li>Hãy chỉ ra mối quan hệ về phương và hướng của các vectơ $\vec{a}$, $\vec{b}$, $\vec{c}$, $\vec{d}$ và $\vec{e}$.</li>
<li>Giải thích vì sao các vectơ $\vec{b}$, $\vec{c}$, $\vec{d}$, $\vec{e}$ đôi một bằng nhau.</li>
</ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.4.</b> Cho hình hộp $ABCD.A''B''C''D''$. Chứng minh rằng:</p>
<ol type="a">
<li>$\overrightarrow{AB}+\overrightarrow{DD''}+\overrightarrow{C''D''}=\overrightarrow{CC''}$;</li>
<li>$\overrightarrow{AB}+\overrightarrow{CD''}-\overrightarrow{CC''}=\vec{0}$;</li>
<li>$\overrightarrow{BC}-\overrightarrow{CC''}+\overrightarrow{DC}=\overrightarrow{A''C}$.</li>
</ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.5.</b> Cho hình lăng trụ tam giác $ABC.A''B''C''$ có $\overrightarrow{AA''}=\vec{a}$, $\overrightarrow{AB}=\vec{b}$ và $\overrightarrow{AC}=\vec{c}$. Hãy biểu diễn các vectơ sau qua các vectơ $\vec{a}$, $\vec{b}$, $\vec{c}$:</p>
<ol type="a">
<li>$\overrightarrow{AB''}$;</li>
<li>$\overrightarrow{B''C}$;</li>
<li>$\overrightarrow{BC''}$.</li>
</ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.6.</b> Cho hình chóp tứ giác $S.ABCD$. Chứng minh rằng tứ giác $ABCD$ là hình bình hành nếu và chỉ nếu $\overrightarrow{SA}+\overrightarrow{SC}=\overrightarrow{SB}+\overrightarrow{SD}$.</p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.7.</b> Cho hình chóp $S.ABC$. Trên cạnh $SA$, lấy điểm $M$ sao cho $SM=2AM$. Trên cạnh $BC$, lấy điểm $N$ sao cho $CN=2BN$. Chứng minh rằng $\overrightarrow{MN}=\dfrac{1}{3}\left(\overrightarrow{SA}+\overrightarrow{BC}\right)+\overrightarrow{AB}$.</p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.8.</b> Trong Luyện tập 8, ta đã biết trọng tâm của tứ diện $ABCD$ là một điểm $I$ thoả mãn $\overrightarrow{AI}=3\overrightarrow{IG}$, ở đó $G$ là trọng tâm của tam giác $BCD$. Áp dụng tính chất trên để tính khoảng cách từ trọng tâm của một khối rubik (đồng chất) hình tứ diện đều đến một mặt của nó, biết rằng chiều cao của khối rubik là 8 cm (H.2.30). <div><img src="/static/img/sgk/hinh-2-30.png" alt="Hình minh họa bài 2.8 (SGK)"></div></p>', NULL, 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.9.</b> Ba sợi dây không giãn với khối lượng không đáng kể được buộc chung một đầu và được kéo căng về ba hướng khác nhau (H.2.31). Nếu các lực kéo làm cho ba sợi dây ở trạng thái đứng yên thì khi đó ba sợi dây nằm trên cùng một mặt phẳng. Hãy giải thích vì sao. <div><img src="/static/img/sgk/hinh-2-31.png" alt="Hình minh họa bài 2.9 (SGK)"></div></p>', NULL, 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.10.</b> Cho hình lăng trụ tứ giác đều $ABCD.A''B''C''D''$ có độ dài mỗi cạnh đáy bằng 1 và độ dài mỗi cạnh bên bằng 2. Hãy tính góc giữa các cặp vectơ sau đây và tính tích vô hướng của mỗi cặp vectơ đó:</p>
<ol type="a">
<li>$\overrightarrow{AA''}$ và $\overrightarrow{C''C}$;</li>
<li>$\overrightarrow{AA''}$ và $\overrightarrow{BC}$;</li>
<li>$\overrightarrow{AC}$ và $\overrightarrow{B''A''}$.</li>
</ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.11.</b> Trong không gian, cho hai vectơ $\vec{a}$ và $\vec{b}$ cùng có độ dài bằng 1. Biết rằng góc giữa hai vectơ đó là $45^\circ$, hãy tính:</p>
<ol type="a">
<li>$\vec{a}\cdot\vec{b}$;</li>
<li>$(\vec{a}+3\vec{b})\cdot(\vec{a}-2\vec{b})$;</li>
<li>$(\vec{a}+\vec{b})^2$.</li>
</ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.12.</b> Cho tứ diện $ABCD$. Chứng minh rằng:</p>
<ol type="a">
<li>$\overrightarrow{AB}\cdot\overrightarrow{CD}=\overrightarrow{AC}\cdot\overrightarrow{CD}+\overrightarrow{BC}\cdot\overrightarrow{DC}$;</li>
<li>$\overrightarrow{AB}\cdot\overrightarrow{CD}+\overrightarrow{AC}\cdot\overrightarrow{DB}+\overrightarrow{AD}\cdot\overrightarrow{BC}=0$.</li>
</ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 7. Hệ trục toạ độ trong không gian', N'Hệ trục toạ độ Oxyz, toạ độ của điểm và của vectơ trong không gian, toạ độ vectơ theo toạ độ hai đầu mút và vận dụng vào mô tả vị trí trong thực tiễn.', N'<p><b>1. Hệ trục toạ độ trong không gian.</b> Trong không gian, ba trục $Ox$, $Oy$, $Oz$ đôi một vuông góc với nhau tại gốc $O$; $\vec{i}$, $\vec{j}$, $\vec{k}$ lần lượt là các vectơ đơn vị trên các trục $Ox$, $Oy$, $Oz$.</p>
<ul>
<li>Hệ ba trục như vậy gọi là hệ trục toạ độ Descartes vuông góc $Oxyz$, hay hệ toạ độ $Oxyz$. Điểm $O$ là gốc toạ độ.</li>
<li>Các mặt phẳng $(Oxy)$, $(Oyz)$, $(Ozx)$ đôi một vuông góc gọi là các mặt phẳng toạ độ. Không gian với hệ toạ độ $Oxyz$ còn gọi là không gian $Oxyz$.</li>
</ul>
<p><b>2. Toạ độ của điểm, toạ độ của vectơ.</b></p>
<ul>
<li>Toạ độ điểm: với điểm $M$ tuỳ ý, bộ ba số $(x;y;z)$ duy nhất sao cho $\overrightarrow{OM}=x\vec{i}+y\vec{j}+z\vec{k}$ gọi là toạ độ của $M$; viết $M(x;y;z)$, trong đó $x$ là hoành độ, $y$ là tung độ, $z$ là cao độ.</li>
<li>Toạ độ vectơ: bộ ba số $(x;y;z)$ duy nhất sao cho $\vec{a}=x\vec{i}+y\vec{j}+z\vec{k}$ gọi là toạ độ của $\vec{a}$; viết $\vec{a}=(x;y;z)$. Toạ độ của $\vec{a}$ cũng là toạ độ của điểm $M$ sao cho $\overrightarrow{OM}=\vec{a}$. Do đó $\vec{i}=(1;0;0)$, $\vec{j}=(0;1;0)$, $\vec{k}=(0;0;1)$.</li>
<li>Hai vectơ bằng nhau khi và chỉ khi các toạ độ tương ứng bằng nhau: $\vec{a}=(x;y;z)=\vec{b}=(x'';y'';z'')\Leftrightarrow\begin{cases}x=x''\\y=y''\\z=z''.\end{cases}$</li>
<li>Nếu $M(x;y;z)$ thì hình chiếu vuông góc của $M$ lên các trục $Ox$, $Oy$, $Oz$ có toạ độ $(x;0;0)$, $(0;y;0)$, $(0;0;z)$; lên các mặt phẳng $(Oxy)$, $(Oyz)$, $(Ozx)$ có toạ độ $(x;y;0)$, $(0;y;z)$, $(x;0;z)$.</li>
</ul>
<p><b>3. Toạ độ của vectơ theo toạ độ hai đầu mút.</b> Với $M(x_M;y_M;z_M)$ và $N(x_N;y_N;z_N)$:</p>
$$\overrightarrow{MN}=(x_N-x_M;\ y_N-y_M;\ z_N-z_M).$$
<p><i>Ví dụ.</i> Cho hình hộp chữ nhật $ABCD.A''B''C''D''$ có $A''$ trùng gốc $O$, các đỉnh $D''$, $B''$, $A$ lần lượt thuộc tia $Ox$, $Oy$, $Oz$ và $C(2;3;5)$. Tìm toạ độ $D''$, $B''$, $A$. Giải: $\overrightarrow{OD''}=m\vec{i}$, $\overrightarrow{OB''}=n\vec{j}$, $\overrightarrow{OA}=p\vec{k}$; theo quy tắc hình hộp $\overrightarrow{OC}=m\vec{i}+n\vec{j}+p\vec{k}$ nên $m=2$, $n=3$, $p=5$. Vậy $D''(2;0;0)$, $B''(0;3;0)$, $A(0;0;5)$.</p>
<p><i>Ví dụ.</i> Cho $A(1;0;2)$, $A''(5;0;1)$. Khi đó $\overrightarrow{AA''}=(5-1;\ 0-0;\ 1-2)=(4;0;-1)$.</p>', 2, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.13.</b> Trong không gian $Oxyz$, cho ba vectơ $\vec{a}$, $\vec{b}$, $\vec{c}$ đều khác $\vec{0}$ và có giá đôi một vuông góc. Những mệnh đề nào sau đây là đúng?</p>
<ol type="a">
<li>Có thể lập một hệ toạ độ $Oxyz$ có các trục toạ độ lần lượt song song với giá của các vectơ $\vec{a}$, $\vec{b}$, $\vec{c}$.</li>
<li>Có thể lập một hệ toạ độ $Oxyz$ có các trục toạ độ lần lượt trùng với giá của các vectơ $\vec{a}$, $\vec{b}$, $\vec{c}$.</li>
<li>Có thể lập một hệ toạ độ $Oxyz$ có các vectơ $\vec{i}$, $\vec{j}$, $\vec{k}$ lần lượt bằng các vectơ $\vec{a}$, $\vec{b}$, $\vec{c}$.</li>
<li>Có thể lập một hệ toạ độ $Oxyz$ có các vectơ $\vec{i}$, $\vec{j}$, $\vec{k}$ lần lượt cùng phương với các vectơ $\vec{a}$, $\vec{b}$, $\vec{c}$.</li>
</ol>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.14.</b> Hãy mô tả hệ toạ độ $Oxyz$ trong căn phòng ở Hình 2.44 sao cho gốc $O$ trùng với góc trên của căn phòng, khung tranh nằm trong mặt phẳng $(Oxy)$ và mặt trần nhà trùng với mặt phẳng $(Oxz)$. <div><img src="/static/img/sgk/hinh-2-44.png" alt="Hình minh họa bài 2.14 (SGK)"></div></p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.15.</b> Trong không gian $Oxyz$, xác định toạ độ của vectơ $\overrightarrow{AB}$ trong mỗi trường hợp sau:</p>
<ol type="a">
<li>$A(0;0;0)$ và $B(4;2;-5)$;</li>
<li>$A(1;-3;7)$ và $B(1;-3;7)$;</li>
<li>$A(5;4;9)$ và $B(-5;7;2)$.</li>
</ol>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.16.</b> Trong không gian $Oxyz$, xác định toạ độ của điểm $A$ trong mỗi trường hợp sau:</p>
<ol type="a">
<li>$A$ trùng với gốc toạ độ;</li>
<li>$A$ nằm trên tia $Ox$ và $OA=2$;</li>
<li>$A$ nằm trên tia đối của tia $Oy$ và $OA=3$.</li>
</ol>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.17.</b> Trong không gian $Oxyz$, cho hình hộp chữ nhật $ABCD.A''B''C''D''$ có đỉnh $A$ trùng với gốc $O$ và các đỉnh $D$, $B$, $A''$ có toạ độ lần lượt là $(2;0;0)$, $(0;4;0)$, $(0;0;3)$ (H.2.45). Xác định toạ độ của các đỉnh còn lại của hình hộp chữ nhật. <div><img src="/static/img/sgk/hinh-2-45.png" alt="Hình minh họa bài 2.17 (SGK)"></div></p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.18.</b> Trong không gian $Oxyz$, cho hình hộp $OABC.O''A''B''C''$ có $A(1;1;-1)$, $B(0;3;0)$, $C''(2;-3;6)$.</p>
<ol type="a">
<li>Xác định toạ độ của điểm $C$.</li>
<li>Xác định toạ độ các đỉnh còn lại của hình hộp.</li>
</ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.19.</b> Trong Vận dụng 2, hãy giải thích vì sao tại mỗi thời điểm chiếc máy bay di chuyển trên đường băng thì toạ độ của nó luôn có dạng $(x;y;0)$ với $x$, $y$ là hai số thực nào đó.</p>
<p><i>(Vận dụng 2, SGK trang 64: lập hệ toạ độ $Oxyz$ có gốc $O$ trùng với vị trí của trung tâm kiểm soát không lưu, mặt phẳng $(Oxy)$ trùng với mặt đất (được coi là phẳng), trục $Ox$ hướng về phía tây, trục $Oy$ hướng về phía nam và trục $Oz$ hướng thẳng đứng lên trời.)</i></p>', NULL, 3, 0, 1, @t1);
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 8. Biểu thức toạ độ của các phép toán vectơ', N'Biểu thức toạ độ của phép cộng, trừ, nhân một số với vectơ và tích vô hướng; toạ độ trung điểm, trọng tâm; độ dài vectơ, khoảng cách, góc giữa hai vectơ và ứng dụng thực tiễn.', N'<p><b>1. Biểu thức toạ độ của phép cộng, trừ vectơ và nhân một số với một vectơ.</b> Trong không gian $Oxyz$, cho $\vec{a}=(x;y;z)$ và $\vec{b}=(x'';y'';z'')$. Ta có:</p>
<ul>
<li>$\vec{a}+\vec{b}=(x+x'';\ y+y'';\ z+z'')$;</li>
<li>$\vec{a}-\vec{b}=(x-x'';\ y-y'';\ z-z'')$;</li>
<li>$k\vec{a}=(kx;\ ky;\ kz)$ với $k$ là một số thực.</li>
</ul>
<p>Nhận xét: $\vec{a}=(x;y;z)$ cùng phương với $\vec{b}=(x'';y'';z'')\neq\vec{0}$ khi và chỉ khi tồn tại số thực $k$ sao cho $x=kx''$, $y=ky''$, $z=kz''$.</p>
<p><b>Toạ độ trung điểm, trọng tâm.</b> Cho ba điểm không thẳng hàng $A(x_A;y_A;z_A)$, $B(x_B;y_B;z_B)$, $C(x_C;y_C;z_C)$. Khi đó:</p>
<ul>
<li>Trung điểm của đoạn thẳng $AB$ có toạ độ $\left(\dfrac{x_A+x_B}{2};\ \dfrac{y_A+y_B}{2};\ \dfrac{z_A+z_B}{2}\right)$;</li>
<li>Trọng tâm tam giác $ABC$ có toạ độ $\left(\dfrac{x_A+x_B+x_C}{3};\ \dfrac{y_A+y_B+y_C}{3};\ \dfrac{z_A+z_B+z_C}{3}\right)$.</li>
</ul>
<p><b>2. Biểu thức toạ độ của tích vô hướng.</b> Với $\vec{a}=(x;y;z)$ và $\vec{b}=(x'';y'';z'')$:</p>
$$\vec{a}\cdot\vec{b}=xx''+yy''+zz''.$$
<ul>
<li>$\vec{a}\perp\vec{b}\Leftrightarrow xx''+yy''+zz''=0$.</li>
<li>$|\vec{a}|=\sqrt{\vec{a}\cdot\vec{a}}=\sqrt{x^2+y^2+z^2}$.</li>
<li>Nếu $\vec{a},\vec{b}\neq\vec{0}$ thì $\cos(\vec{a},\vec{b})=\dfrac{\vec{a}\cdot\vec{b}}{|\vec{a}|\cdot|\vec{b}|}=\dfrac{xx''+yy''+zz''}{\sqrt{x^2+y^2+z^2}\cdot\sqrt{x''^2+y''^2+z''^2}}$.</li>
<li>Khoảng cách: $AB=|\overrightarrow{AB}|=\sqrt{(x_B-x_A)^2+(y_B-y_A)^2+(z_B-z_A)^2}$; đặc biệt $OA=\sqrt{x_A^2+y_A^2+z_A^2}$.</li>
</ul>
<p><b>3. Vận dụng toạ độ của vectơ trong bài toán thực tiễn:</b> chọn hệ trục toạ độ thích hợp, xác định toạ độ các điểm, vectơ liên quan rồi tính theo các công thức trên.</p>
<p><i>Ví dụ.</i> Cho $\vec{a}=(2;1;5)$, $\vec{b}=(2;2;1)$. Tìm toạ độ $\vec{a}-\vec{b}$ và $3\vec{a}+2\vec{b}$. Giải: $\vec{a}-\vec{b}=(0;-1;4)$; $3\vec{a}=(6;3;15)$, $2\vec{b}=(4;4;2)$ nên $3\vec{a}+2\vec{b}=(10;7;17)$.</p>
<p><i>Ví dụ.</i> Cho $\vec{a}=(1;4;2)$, $\vec{b}=(-4;1;0)$. Ta có $\vec{a}\cdot\vec{b}=1\cdot(-4)+4\cdot1+2\cdot0=0$ nên $\vec{a}\perp\vec{b}$; $|\vec{a}|=\sqrt{1^2+4^2+2^2}=\sqrt{21}$.</p>', 3, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.20.</b> Trong không gian $Oxyz$, cho ba vectơ $\vec{a}=(3;1;2)$, $\vec{b}=(-3;0;4)$ và $\vec{c}=(6;-1;0)$.</p>
<ol type="a">
<li>Tìm toạ độ của các vectơ $\vec{a}+\vec{b}+\vec{c}$ và $2\vec{a}-3\vec{b}-5\vec{c}$.</li>
<li>Tính các tích vô hướng $\vec{a}\cdot(-\vec{b})$ và $(2\vec{a})\cdot\vec{c}$.</li>
</ol>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.21.</b> Trong không gian $Oxyz$, cho ba điểm $M(-4;3;3)$, $N(4;-4;2)$ và $P(3;6;-1)$.</p>
<ol type="a">
<li>Tìm toạ độ của các vectơ $\overrightarrow{MN}$, $\overrightarrow{MP}$, từ đó chứng minh rằng ba điểm $M$, $N$, $P$ không thẳng hàng.</li>
<li>Tìm toạ độ của vectơ $\overrightarrow{NM}+\overrightarrow{NP}$, từ đó suy ra toạ độ của điểm $Q$ sao cho tứ giác $MNPQ$ là hình bình hành.</li>
<li>Tính chu vi của hình bình hành $MNPQ$.</li>
</ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.22.</b> Trong không gian $Oxyz$, cho tam giác $ABC$ có $A(1;0;1)$, $B(0;-3;1)$ và $C(4;-1;4)$.</p>
<ol type="a">
<li>Tìm toạ độ trọng tâm của tam giác $ABC$.</li>
<li>Chứng minh rằng $\widehat{BAC}=90^\circ$.</li>
<li>Tính $\widehat{ABC}$.</li>
</ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.23.</b> Một phòng học có thiết kế dạng hình hộp chữ nhật với chiều dài là 8 m, chiều rộng là 6 m và chiều cao là 3 m. Một chiếc đèn được treo tại chính giữa trần nhà của phòng học. Xét hệ trục toạ độ $Oxyz$ có gốc $O$ trùng với một góc phòng và mặt phẳng $(Oxy)$ trùng với mặt sàn, đơn vị đo được lấy theo mét (H.2.51). Hãy tìm toạ độ của điểm treo đèn. <div><img src="/static/img/sgk/hinh-2-51.png" alt="Hình minh họa bài 2.23 (SGK)"></div></p>', NULL, 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.24.</b> Trong không gian, xét hệ toạ độ $Oxyz$ có gốc $O$ trùng với vị trí của một giàn khoan trên biển, mặt phẳng $(Oxy)$ trùng với mặt biển (được coi là phẳng) với trục $Ox$ hướng về phía tây, trục $Oy$ hướng về phía nam và trục $Oz$ hướng thẳng đứng lên trời (H.2.52). Đơn vị đo trong không gian $Oxyz$ lấy theo kilômét. Một chiếc radar đặt tại giàn khoan có phạm vi theo dõi là 30 km. Hỏi radar có thể phát hiện được một chiếc tàu thám hiểm có toạ độ là $(25;15;-10)$ đối với hệ toạ độ nói trên hay không? Hãy giải thích vì sao. <div><img src="/static/img/sgk/hinh-2-52.png" alt="Hình minh họa bài 2.24 (SGK)"></div></p>', NULL, 3, 0, 1, @t1);
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài tập cuối chương II', N'Bài tập tổng hợp chương II gồm phần trắc nghiệm và tự luận về vectơ, hệ trục toạ độ và biểu thức toạ độ của các phép toán vectơ trong không gian.', N'<p>Phần bài tập tổng hợp kiến thức của Chương II: vectơ và hệ trục toạ độ trong không gian.</p>', 4, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 2.25.</b> Cho tứ diện $ABCD$. Gọi $G$ là trọng tâm của tam giác $BCD$. Khẳng định nào sau đây là <b>sai</b>?</p>', N'<p>Vì $G$ là trọng tâm tam giác $BCD$ nên $\overrightarrow{GB}+\overrightarrow{GC}+\overrightarrow{GD}=\vec 0$, suy ra A đúng; $\overrightarrow{AB}+\overrightarrow{AC}+\overrightarrow{AD}=3\overrightarrow{AG}$ (B đúng); $\overrightarrow{BC}+\overrightarrow{BD}=2\overrightarrow{BM}=3\overrightarrow{BG}$ với $M$ là trung điểm $CD$ (C đúng).</p><p>D sai vì $\overrightarrow{GA}+\overrightarrow{GB}+\overrightarrow{GC}+\overrightarrow{GD}=\overrightarrow{GA}\ne\vec 0$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$\overrightarrow{BG}+\overrightarrow{CG}+\overrightarrow{DG}=\vec{0}$.', 0),
(@q, 'B', N'$\overrightarrow{AB}+\overrightarrow{AC}+\overrightarrow{AD}=3\overrightarrow{AG}$.', 0),
(@q, 'C', N'$\overrightarrow{BC}+\overrightarrow{BD}=3\overrightarrow{BG}$.', 0),
(@q, 'D', N'$\overrightarrow{GA}+\overrightarrow{GB}+\overrightarrow{GC}+\overrightarrow{GD}=\vec{0}$.', 1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 2.26.</b> Cho hình hộp $ABCD.A''B''C''D''$. Gọi $M$ là trung điểm của đoạn thẳng $CC''$. Vectơ $\overrightarrow{AM}$ bằng</p>', N'<p>$\overrightarrow{AM}=\overrightarrow{AC}+\overrightarrow{CM}=\overrightarrow{AB}+\overrightarrow{AD}+\dfrac12\overrightarrow{CC''}=\overrightarrow{AB}+\overrightarrow{AD}+\dfrac12\overrightarrow{AA''}$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$\overrightarrow{AB}+\overrightarrow{AD}+\overrightarrow{AA''}$.', 0),
(@q, 'B', N'$\overrightarrow{AB}+\overrightarrow{AD}+\dfrac{1}{2}\overrightarrow{AA''}$.', 1),
(@q, 'C', N'$\overrightarrow{AB}+\dfrac{1}{2}\overrightarrow{AD}+\dfrac{1}{2}\overrightarrow{AA''}$.', 0),
(@q, 'D', N'$\dfrac{1}{2}\overrightarrow{AB}+\overrightarrow{AD}+\overrightarrow{AA''}$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 2.27.</b> Cho hình hộp $ABCD.A''B''C''D''$. Khẳng định nào dưới đây là <b>sai</b>?</p>', N'<p>$\overrightarrow{CC''}=\overrightarrow{BB''}=\overrightarrow{AA''}$. Do đó A: $\overrightarrow{AB}+\overrightarrow{BB''}=\overrightarrow{AB''}$ đúng; B đúng (quy tắc hình hộp); C: $\overrightarrow{AD}+\overrightarrow{AA''}=\overrightarrow{AD''}$ đúng.</p><p>D sai vì $\overrightarrow{AB}+\overrightarrow{CC''}=\overrightarrow{AB''}\ne\overrightarrow{AC''}$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$\overrightarrow{AB}+\overrightarrow{CC''}=\overrightarrow{AB''}$.', 0),
(@q, 'B', N'$\overrightarrow{AB}+\overrightarrow{AD}+\overrightarrow{AA''}=\overrightarrow{AC''}$.', 0),
(@q, 'C', N'$\overrightarrow{AD}+\overrightarrow{BB''}=\overrightarrow{AD''}$.', 0),
(@q, 'D', N'$\overrightarrow{AB}+\overrightarrow{CC''}=\overrightarrow{AC''}$.', 1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 2.28.</b> Cho tứ diện đều $ABCD$ có độ dài cạnh bằng $a$. Gọi $M$ là trung điểm của đoạn thẳng $CD$. Tích vô hướng $\overrightarrow{AB}\cdot\overrightarrow{AM}$ bằng</p>', N'<p>$\overrightarrow{AM}=\dfrac12(\overrightarrow{AC}+\overrightarrow{AD})$. Mỗi tích $\overrightarrow{AB}\cdot\overrightarrow{AC}=\overrightarrow{AB}\cdot\overrightarrow{AD}=a\cdot a\cos60^\circ=\dfrac{a^2}{2}$.</p><p>Vậy $\overrightarrow{AB}\cdot\overrightarrow{AM}=\dfrac12\left(\dfrac{a^2}{2}+\dfrac{a^2}{2}\right)=\dfrac{a^2}{2}$.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$\dfrac{a^2}{4}$.', 0),
(@q, 'B', N'$\dfrac{a^2}{2}$.', 1),
(@q, 'C', N'$\dfrac{a^2}{3}$.', 0),
(@q, 'D', N'$a^2$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 2.29.</b> Trong không gian $Oxyz$, cho $\vec{a}=(1;-2;2)$, $\vec{b}=(-2;0;3)$. Khẳng định nào dưới đây là <b>sai</b>?</p>', N'<p>$3\vec a=(3;-6;6)$ chứ không phải $(3;-2;2)$ nên C sai. Các phương án còn lại đúng: $\vec a+\vec b=(-1;-2;5)$, $\vec a-\vec b=(3;-2;-1)$, $2\vec a+\vec b=(0;-4;7)$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$\vec{a}+\vec{b}=(-1;-2;5)$.', 0),
(@q, 'B', N'$\vec{a}-\vec{b}=(3;-2;-1)$.', 0),
(@q, 'C', N'$3\vec{a}=(3;-2;2)$.', 1),
(@q, 'D', N'$2\vec{a}+\vec{b}=(0;-4;7)$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 2.30.</b> Trong không gian $Oxyz$, cho hình bình hành $ABCD$ có $A(-1;0;3)$, $B(2;1;-1)$ và $C(3;2;2)$. Toạ độ của điểm $D$ là</p>', N'<p>$ABCD$ là hình bình hành nên $\overrightarrow{AD}=\overrightarrow{BC}$, suy ra $D=A+C-B=(-1+3-2;\,0+2-1;\,3+2+1)=(0;1;6)$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$(2;-1;0)$.', 0),
(@q, 'B', N'$(0;-1;-6)$.', 0),
(@q, 'C', N'$(0;1;6)$.', 1),
(@q, 'D', N'$(-2;1;0)$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 2.31.</b> Trong không gian $Oxyz$, cho $A(1;0;-1)$, $B(0;-1;2)$ và $G(2;1;0)$. Biết tam giác $ABC$ có trọng tâm là điểm $G$. Toạ độ của điểm $C$ là</p>', N'<p>$G$ là trọng tâm nên $x_C=3x_G-x_A-x_B=6-1-0=5$; $y_C=3-0+1=4$; $z_C=0+1-2=-1$. Vậy $C(5;4;-1)$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$(5;4;-1)$.', 1),
(@q, 'B', N'$(-5;-4;1)$.', 0),
(@q, 'C', N'$(1;2;-1)$.', 0),
(@q, 'D', N'$(-1;-2;1)$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 2.32.</b> Trong không gian $Oxyz$, cho $\vec{a}=(2;1;-3)$, $\vec{b}=(-2;-1;2)$. Tích vô hướng $\vec{a}\cdot\vec{b}$ bằng</p>', N'<p>$\vec a\cdot\vec b=2\cdot(-2)+1\cdot(-1)+(-3)\cdot2=-4-1-6=-11$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$-2$.', 0),
(@q, 'B', N'$-11$.', 1),
(@q, 'C', N'$11$.', 0),
(@q, 'D', N'$2$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 2.33.</b> Trong không gian $Oxyz$, cho $\vec{a}=(2;1;-2)$, $\vec{b}=(0;-1;1)$. Góc giữa hai vectơ $\vec{a}$, $\vec{b}$ bằng</p>', N'<p>$\vec a\cdot\vec b=-1-2=-3$, $|\vec a|=3$, $|\vec b|=\sqrt2$. $\cos\varphi=\dfrac{-3}{3\sqrt2}=-\dfrac{\sqrt2}{2}$ nên $\varphi=135^\circ$.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$60^\circ$.', 0),
(@q, 'B', N'$135^\circ$.', 1),
(@q, 'C', N'$120^\circ$.', 0),
(@q, 'D', N'$45^\circ$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 2.34.</b> Trong không gian $Oxyz$, cho $\vec{a}=(-2;2;2)$, $\vec{b}=(1;-1;-2)$. Côsin của góc giữa hai vectơ $\vec{a}$, $\vec{b}$ bằng</p>', N'<p>$\vec a\cdot\vec b=-2-2-4=-8$, $|\vec a|=2\sqrt3$, $|\vec b|=\sqrt6$. $\cos=\dfrac{-8}{2\sqrt3\cdot\sqrt6}=\dfrac{-8}{6\sqrt2}=\dfrac{-2\sqrt2}{3}$.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$\dfrac{-2\sqrt{2}}{3}$.', 1),
(@q, 'B', N'$\dfrac{2\sqrt{2}}{3}$.', 0),
(@q, 'C', N'$\dfrac{\sqrt{2}}{3}$.', 0),
(@q, 'D', N'$\dfrac{-\sqrt{2}}{3}$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.35.</b> Cho hình chóp $S.ABCD$ có đáy $ABCD$ là hình chữ nhật. Chứng minh rằng:</p>
$$\overrightarrow{SA}+\overrightarrow{SC}=\overrightarrow{SB}+\overrightarrow{SD}.$$', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.36.</b> Cho tứ diện $ABCD$, lấy hai điểm $M$, $N$ thoả mãn $\overrightarrow{MB}+2\overrightarrow{MA}=\vec{0}$ và $\overrightarrow{NC}=2\overrightarrow{DN}$. Hãy biểu diễn $\overrightarrow{MN}$ theo $\overrightarrow{AD}$ và $\overrightarrow{BC}$.</p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.37.</b> Cho hình hộp $ABCD.A''B''C''D''$. Gọi $G$ là trọng tâm của tam giác $BDA''$.</p>
<ol type="a">
<li>Biểu diễn $\overrightarrow{AG}$ theo $\overrightarrow{AB}$, $\overrightarrow{AD}$ và $\overrightarrow{AA''}$.</li>
<li>Từ câu a, hãy chứng tỏ ba điểm $A$, $G$ và $C''$ thẳng hàng.</li>
</ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.38.</b> Trong không gian $Oxyz$, cho các điểm $A(2;-1;3)$, $B(1;1;-1)$ và $C(-1;0;2)$.</p>
<ol type="a">
<li>Tìm toạ độ trọng tâm $G$ của tam giác $ABC$.</li>
<li>Tìm toạ độ điểm $M$ thuộc trục $Oz$ sao cho đường thẳng $BM$ vuông góc với đường thẳng $AC$.</li>
</ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.39.</b> Trong không gian $Oxyz$, cho hình hộp $OABC.O''A''B''C''$ có $A(2;3;1)$, $C(-1;2;3)$ và $O''(1;-2;2)$. Tìm toạ độ các đỉnh còn lại của hình hộp.</p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.40.</b> Trong không gian $Oxyz$, cho hai vectơ $\vec{a}=(-2;1;2)$, $\vec{b}=(1;1;-1)$.</p>
<ol type="a">
<li>Xác định toạ độ của $\vec{u}=\vec{a}-2\vec{b}$.</li>
<li>Tính độ dài của $\vec{u}$.</li>
<li>Tính $\cos(\vec{a},\vec{b})$.</li>
</ol>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.41.</b> Trong không gian $Oxyz$, cho các điểm $A(4;2;-1)$, $B(1;-1;2)$ và $C(0;-2;3)$.</p>
<ol type="a">
<li>Tìm toạ độ của vectơ $\overrightarrow{AB}$ và tính độ dài đoạn thẳng $AB$.</li>
<li>Tìm toạ độ điểm $M$ sao cho $\overrightarrow{AB}+\overrightarrow{CM}=\vec{0}$.</li>
<li>Tìm toạ độ điểm $N$ thuộc mặt phẳng $(Oxy)$ sao cho $A$, $B$, $N$ thẳng hàng.</li>
</ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.42.</b> Hình 2.53 minh hoạ một chiếc đèn được treo cách trần nhà là 0,5 m, cách hai tường lần lượt là 1,2 m và 1,6 m. Hai bức tường vuông góc với nhau và cùng vuông góc với trần nhà. Người ta di chuyển chiếc đèn đó đến vị trí mới cách trần nhà là 0,4 m, cách hai tường đều là 1,5 m. <div><img src="/static/img/sgk/hinh-2-53.png" alt="Hình minh họa bài 2.42 (SGK)"></div></p>
<ol type="a">
<li>Lập một hệ trục toạ độ $Oxyz$ phù hợp và xác định toạ độ của chiếc đèn lúc đầu và sau khi di chuyển.</li>
<li>Vị trí mới của chiếc đèn cách vị trí ban đầu là bao nhiêu mét? (Làm tròn kết quả đến chữ số thập phân thứ nhất).</li>
</ol>', NULL, 3, 0, 1, @t1);

-- ---------------------------------------------------------------------------------------------------------------------
-- Chương I. Ứng dụng đạo hàm để khảo sát và vẽ đồ thị hàm số
-- ---------------------------------------------------------------------------------------------------------------------
INSERT INTO Topics (TopicName, [Description], TeacherId, OrderIndex, IsActive) VALUES (N'Chương I. Ứng dụng đạo hàm để khảo sát và vẽ đồ thị hàm số', N'Ứng dụng đạo hàm để khảo sát sự biến thiên, cực trị, giá trị lớn nhất - nhỏ nhất, tiệm cận, vẽ đồ thị hàm số và giải quyết các vấn đề thực tiễn. (SGK Toán 12 Kết nối tri thức với cuộc sống, Tập 1)', @t1, 1, 1);
SET @tp = SCOPE_IDENTITY();
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 1. Tính đơn điệu và cực trị của hàm số', N'Xét tính đồng biến, nghịch biến của hàm số bằng dấu đạo hàm và bảng biến thiên; khái niệm cực đại, cực tiểu và cách tìm cực trị của hàm số.', N'<p><b>1. Tính đơn điệu.</b> Giả sử $K$ là một khoảng, một đoạn hoặc một nửa khoảng và $y=f(x)$ xác định trên $K$.</p>
<ul>
<li>Hàm số đồng biến trên $K$ nếu $\forall x_1,x_2\in K,\ x_1<x_2 \Rightarrow f(x_1)<f(x_2)$.</li>
<li>Hàm số nghịch biến trên $K$ nếu $\forall x_1,x_2\in K,\ x_1<x_2 \Rightarrow f(x_1)>f(x_2)$.</li>
</ul>
<p><i>Chú ý:</i> đồng biến thì đồ thị đi lên từ trái sang phải, nghịch biến thì đồ thị đi xuống. Đồng biến hay nghịch biến gọi chung là đơn điệu.</p>
<p><b>Định lí.</b> Cho hàm số $y=f(x)$ có đạo hàm trên khoảng $K$. Nếu $f''(x)>0$ với mọi $x\in K$ thì $f(x)$ đồng biến trên $K$; nếu $f''(x)<0$ với mọi $x\in K$ thì $f(x)$ nghịch biến trên $K$.</p>
<p><i>Chú ý:</i> nếu $f''(x)\ge 0$ ($f''(x)\le 0$) với mọi $x\in K$ và $f''(x)=0$ chỉ tại một số hữu hạn điểm của $K$ thì $f(x)$ vẫn đồng biến (nghịch biến) trên $K$. Nếu $f''(x)=0$ với mọi $x\in K$ thì $f(x)$ không đổi trên $K$.</p>
<p><b>Các bước xét tính đơn điệu:</b></p>
<ol>
<li>Tìm tập xác định của hàm số.</li>
<li>Tính $f''(x)$; tìm các điểm $x_i$ mà tại đó đạo hàm bằng 0 hoặc không tồn tại.</li>
<li>Sắp xếp các điểm $x_i$ theo thứ tự tăng dần và lập bảng biến thiên.</li>
<li>Nêu kết luận về khoảng đồng biến, nghịch biến.</li>
</ol>
<p><b>Ví dụ 1.</b> Xét chiều biến thiên của $y=\dfrac{x-2}{x+1}$. Tập xác định $\mathbb{R}\setminus\{-1\}$; $y''=\dfrac{3}{(x+1)^2}>0$ với mọi $x\neq -1$ nên hàm số đồng biến trên $(-\infty;-1)$ và $(-1;+\infty)$.</p>
<p><b>2. Cực trị.</b> Cho hàm số $y=f(x)$ xác định và liên tục trên khoảng $(a;b)$ và điểm $x_0\in(a;b)$.</p>
<ul>
<li>Nếu tồn tại $h>0$ sao cho $f(x)<f(x_0)$ với mọi $x\in(x_0-h;x_0+h)\subset(a;b)$, $x\neq x_0$ thì $f$ đạt <b>cực đại</b> tại $x_0$.</li>
<li>Nếu tồn tại $h>0$ sao cho $f(x)>f(x_0)$ với mọi $x\in(x_0-h;x_0+h)\subset(a;b)$, $x\neq x_0$ thì $f$ đạt <b>cực tiểu</b> tại $x_0$.</li>
</ul>
<p>Khi đó $x_0$ là điểm cực đại (cực tiểu), $f(x_0)$ là giá trị cực đại $y_{CĐ}$ (giá trị cực tiểu $y_{CT}$); điểm $M_0(x_0;f(x_0))$ là điểm cực đại (cực tiểu) của đồ thị. Điểm cực đại và cực tiểu gọi chung là điểm cực trị.</p>
<p><b>Định lí (tìm cực trị).</b> Giả sử $y=f(x)$ liên tục trên $(a;b)$ chứa $x_0$ và có đạo hàm trên $(a;x_0)$ và $(x_0;b)$. Nếu $f''(x)<0$ trên $(a;x_0)$ và $f''(x)>0$ trên $(x_0;b)$ thì $x_0$ là điểm cực tiểu; nếu $f''(x)>0$ trên $(a;x_0)$ và $f''(x)<0$ trên $(x_0;b)$ thì $x_0$ là điểm cực đại.</p>
<p><i>Chú ý:</i> nếu $f''(x_0)=0$ nhưng $f''(x)$ không đổi dấu khi $x$ qua $x_0$ thì $x_0$ không phải điểm cực trị (ví dụ $y=x^3$ tại $x=0$).</p>
<p><b>Các bước tìm cực trị:</b> (1) tìm tập xác định; (2) tính $f''(x)$, tìm các điểm mà $f''(x)=0$ hoặc không tồn tại; (3) lập bảng biến thiên; (4) từ bảng biến thiên suy ra các cực trị.</p>
<p><b>Ví dụ 2.</b> Tìm cực trị của $y=x^3-6x^2+9x+30$. Ta có $y''=3x^2-12x+9$, $y''=0\Leftrightarrow x=1$ hoặc $x=3$. Lập bảng biến thiên: $y''>0$ trên $(-\infty;1)$ và $(3;+\infty)$, $y''<0$ trên $(1;3)$. Hàm số đạt cực đại tại $x=1$, $y_{CĐ}=34$; đạt cực tiểu tại $x=3$, $y_{CT}=30$.</p>', 1, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.1.</b> Tìm các khoảng đồng biến, khoảng nghịch biến của các hàm số có đồ thị như sau:</p>
<ol type="a">
<li>Đồ thị hàm số $y=x^3-\dfrac{3}{2}x^2$ (H.1.11);</li>
<li>Đồ thị hàm số $y=\sqrt[3]{(x^2-4)^2}$ (H.1.12).</li>
</ol>
<div><img src="/static/img/sgk/hinh-1-11.png" alt="Hình minh họa bài 1.1 (SGK)"></div><div><img src="/static/img/sgk/hinh-1-12.png" alt="Hình minh họa bài 1.1 (SGK)"></div>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.2.</b> Xét sự đồng biến, nghịch biến của các hàm số sau:</p>
<ol type="a">
<li>$y=\dfrac{1}{3}x^3-2x^2+3x+1$;</li>
<li>$y=-x^3+2x^2-5x+3$.</li>
</ol>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.3.</b> Tìm các khoảng đơn điệu của các hàm số sau:</p>
<ol type="a">
<li>$y=\dfrac{2x-1}{x+2}$;</li>
<li>$y=\dfrac{x^2+x+4}{x-3}$.</li>
</ol>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.4.</b> Xét chiều biến thiên của các hàm số sau:</p>
<ol type="a">
<li>$y=\sqrt{4-x^2}$;</li>
<li>$y=\dfrac{x}{x^2+1}$.</li>
</ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.5.</b> Giả sử số dân của một thị trấn sau $t$ năm kể từ năm 2000 được mô tả bởi hàm số</p>
<p>$$N(t)=\dfrac{25t+10}{t+5},\ t\ge 0,$$</p>
<p>trong đó $N(t)$ được tính bằng nghìn người.</p>
<ol type="a">
<li>Tính số dân của thị trấn đó vào các năm 2000 và 2015.</li>
<li>Tính đạo hàm $N''(t)$ và $\lim_{t\to+\infty}N(t)$. Từ đó, giải thích tại sao số dân của thị trấn đó luôn tăng nhưng sẽ không vượt quá một ngưỡng nào đó.</li>
</ol>', NULL, 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.6.</b> Đồ thị của đạo hàm bậc nhất $y=f''(x)$ của hàm số $f(x)$ được cho trong Hình 1.13.</p>
<ol type="a">
<li>Hàm số $f(x)$ đồng biến trên những khoảng nào? Giải thích.</li>
<li>Tại giá trị nào của $x$ thì $f(x)$ có cực đại hoặc cực tiểu? Giải thích.</li>
</ol>
<div><img src="/static/img/sgk/hinh-1-13.png" alt="Hình minh họa bài 1.6 (SGK)"></div>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.7.</b> Tìm cực trị của các hàm số sau:</p>
<ol type="a">
<li>$y=2x^3-9x^2+12x-5$;</li>
<li>$y=x^4-4x^2+2$;</li>
<li>$y=\dfrac{x^2-2x+3}{x-1}$;</li>
<li>$y=\sqrt{4x-2x^2}$.</li>
</ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.8.</b> Cho hàm số $y=f(x)=|x|$.</p>
<ol type="a">
<li>Tính các giới hạn $\lim_{x\to 0^+}\dfrac{f(x)-f(0)}{x-0}$ và $\lim_{x\to 0^-}\dfrac{f(x)-f(0)}{x-0}$. Từ đó suy ra hàm số không có đạo hàm tại $x=0$.</li>
<li>Sử dụng định nghĩa, chứng minh hàm số có cực tiểu tại $x=0$ (xem Hình 1.4).</li>
</ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.9.</b> Giả sử doanh số (tính bằng số sản phẩm) của một sản phẩm mới (trong vòng một số năm nhất định) tuân theo quy luật logistic được mô hình hoá bằng hàm số</p>
<p>$$f(t)=\dfrac{5\,000}{1+5e^{-t}},\ t\ge 0,$$</p>
<p>trong đó thời gian $t$ được tính bằng năm, kể từ khi phát hành sản phẩm mới. Khi đó, đạo hàm $f''(t)$ sẽ biểu thị tốc độ bán hàng. Hỏi sau khi phát hành bao nhiêu năm thì tốc độ bán hàng là lớn nhất?</p>', NULL, 3, 0, 1, @t1);
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 2. Giá trị lớn nhất và giá trị nhỏ nhất của hàm số', N'Định nghĩa giá trị lớn nhất, giá trị nhỏ nhất của hàm số trên một tập; cách tìm bằng bảng biến thiên và quy tắc tìm GTLN, GTNN trên một đoạn; ứng dụng bài toán thực tế.', N'<p><b>1. Định nghĩa.</b> Cho hàm số $y=f(x)$ xác định trên tập $D$.</p>
<ul>
<li>Số $M$ gọi là <b>giá trị lớn nhất</b> của $f(x)$ trên $D$ nếu $f(x)\le M$ với mọi $x\in D$ và tồn tại $x_0\in D$ sao cho $f(x_0)=M$. Kí hiệu $M=\max_{x\in D}f(x)$ hoặc $M=\max_D f(x)$.</li>
<li>Số $m$ gọi là <b>giá trị nhỏ nhất</b> của $f(x)$ trên $D$ nếu $f(x)\ge m$ với mọi $x\in D$ và tồn tại $x_0\in D$ sao cho $f(x_0)=m$. Kí hiệu $m=\min_{x\in D}f(x)$ hoặc $m=\min_D f(x)$.</li>
</ul>
<p><i>Chú ý:</i> khi nói giá trị lớn nhất, nhỏ nhất của $f(x)$ mà không nói &ldquo;trên tập $D$&rdquo; thì hiểu là trên tập xác định của hàm số. Để tìm GTLN, GTNN trên $D$, ta thường lập bảng biến thiên của hàm số trên $D$ để kết luận.</p>
<p><b>Ví dụ 1.</b> Tìm GTLN, GTNN của $y=\sqrt{1-x^2}$. Tập xác định $[-1;1]$. Ta có $0\le\sqrt{1-x^2}\le 1$; dấu bằng bên trái xảy ra khi $x=\pm1$, bên phải khi $x=0$. Vậy $\min y=y(-1)=y(1)=0$; $\max y=y(0)=1$.</p>
<p><b>Ví dụ 2.</b> Tìm GTLN, GTNN (nếu có) của $y=x-2+\dfrac{1}{x}$ trên $(0;+\infty)$. Ta có $y''=1-\dfrac{1}{x^2}$, $y''=0\Leftrightarrow x=1$; $\lim_{x\to0^+}y=\lim_{x\to+\infty}y=+\infty$. Từ bảng biến thiên: $\min y=y(1)=0$; hàm số không có giá trị lớn nhất trên $(0;+\infty)$.</p>
<p><b>2. Cách tìm GTLN, GTNN trên một đoạn.</b> Giả sử $y=f(x)$ liên tục trên $[a;b]$ và có đạo hàm trên $(a;b)$, có thể trừ ra tại một số hữu hạn điểm mà tại đó hàm số không có đạo hàm; giả sử chỉ có hữu hạn điểm trong $[a;b]$ mà $f''(x)=0$. Các bước:</p>
<ol>
<li>Tìm các điểm $x_1,x_2,\dots,x_n\in(a;b)$ tại đó $f''(x)=0$ hoặc không tồn tại.</li>
<li>Tính $f(x_1),f(x_2),\dots,f(x_n)$, $f(a)$ và $f(b)$.</li>
<li>Tìm số lớn nhất $M$ và số nhỏ nhất $m$ trong các số trên. Khi đó $M=\max_{[a;b]}f(x)$, $m=\min_{[a;b]}f(x)$.</li>
</ol>
<p><b>Ví dụ 3.</b> Tìm GTLN, GTNN của $y=x^4-4x^2+3$ trên $[0;4]$. Ta có $y''=4x(x^2-2)$, trên $(0;4)$ thì $y''=0\Leftrightarrow x=\sqrt2$. $y(0)=3$, $y(4)=195$, $y(\sqrt2)=-1$. Vậy $\max_{[0;4]}y=y(4)=195$, $\min_{[0;4]}y=y(\sqrt2)=-1$.</p>
<p><b>Ví dụ 4 (bài toán hộp).</b> Từ tấm bìa hình vuông cạnh 60 cm cắt bốn hình vuông cạnh $x$ ở bốn góc rồi gập thành hộp không nắp: $V(x)=(60-2x)^2x$, $0<x<30$. $V''(x)=0\Leftrightarrow x=10$; lập bảng biến thiên được $V$ lớn nhất bằng 16 000 cm$^3$ khi $x=10$ cm.</p>', 2, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.10.</b> Tìm giá trị lớn nhất và giá trị nhỏ nhất (nếu có) của các hàm số sau:</p>
<ol type="a">
<li>$y=-x^2+4x+3$;</li>
<li>$y=x^3-2x^2+1$ trên $[0;+\infty)$;</li>
<li>$y=\dfrac{x^2-2x+3}{x-1}$ trên $(1;+\infty)$;</li>
<li>$y=\sqrt{4x-2x^2}$.</li>
</ol>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.11.</b> Tìm giá trị lớn nhất và giá trị nhỏ nhất (nếu có) của các hàm số sau:</p>
<ol type="a">
<li>$y=x^4-2x^2+3$;</li>
<li>$y=xe^{-x}$;</li>
<li>$y=x\ln x$;</li>
<li>$y=\sqrt{x-1}+\sqrt{3-x}$.</li>
</ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.12.</b> Tìm giá trị lớn nhất và giá trị nhỏ nhất của các hàm số sau:</p>
<ol type="a">
<li>$y=2x^3-6x+3$ trên đoạn $[-1;2]$;</li>
<li>$y=x^4-3x^2+2$ trên đoạn $[0;3]$;</li>
<li>$y=x-\sin 2x$ trên đoạn $[0;\pi]$;</li>
<li>$y=(x^2-x)e^x$ trên đoạn $[0;1]$.</li>
</ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.13.</b> Trong các hình chữ nhật có chu vi là 24 cm, hãy tìm hình chữ nhật có diện tích lớn nhất.</p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.14.</b> Một nhà sản xuất muốn thiết kế một chiếc hộp có dạng hình hộp chữ nhật không có nắp, có đáy là hình vuông và diện tích bề mặt bằng 108 cm$^2$ như Hình 1.17. Tìm các kích thước của chiếc hộp sao cho thể tích của hộp là lớn nhất.</p>
<div><img src="/static/img/sgk/hinh-1-17.png" alt="Hình minh họa bài 1.14 (SGK)"></div>', NULL, 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.15.</b> Một nhà sản xuất cần làm ra những chiếc bình có dạng hình trụ với dung tích 1 000 cm$^3$. Mặt trên và mặt dưới của bình được làm bằng vật liệu có giá 1,2 nghìn đồng/cm$^2$, trong khi mặt bên của bình được làm bằng vật liệu có giá 0,75 nghìn đồng/cm$^2$. Tìm các kích thước của bình (bán kính đáy và chiều cao của bình) để chi phí vật liệu sản xuất mỗi chiếc bình là nhỏ nhất.</p>', NULL, 3, 0, 1, @t1);
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 3. Đường tiệm cận của đồ thị hàm số', N'Khái niệm và cách tìm đường tiệm cận ngang, tiệm cận đứng và tiệm cận xiên của đồ thị hàm số thông qua giới hạn.', N'<p><b>1. Đường tiệm cận ngang.</b> Đường thẳng $y=y_0$ gọi là <b>đường tiệm cận ngang</b> của đồ thị hàm số $y=f(x)$ nếu
$$\lim_{x\to+\infty}f(x)=y_0\ \text{ hoặc }\ \lim_{x\to-\infty}f(x)=y_0.$$</p>
<p><b>Ví dụ 1.</b> Đồ thị $y=\dfrac{3x-2}{x+1}$: $\lim_{x\to\pm\infty}\dfrac{3x-2}{x+1}=3$ nên có tiệm cận ngang $y=3$.</p>
<p><b>Ví dụ 2.</b> Đồ thị $y=\dfrac{\sqrt{x^2+1}}{x}$: $\lim_{x\to+\infty}f(x)=1$, $\lim_{x\to-\infty}f(x)=-1$ nên có hai tiệm cận ngang $y=1$ và $y=-1$.</p>
<p><b>2. Đường tiệm cận đứng.</b> Đường thẳng $x=x_0$ gọi là <b>đường tiệm cận đứng</b> của đồ thị hàm số $y=f(x)$ nếu ít nhất một trong các điều kiện sau được thoả mãn:
$$\lim_{x\to x_0^+}f(x)=+\infty;\quad \lim_{x\to x_0^-}f(x)=-\infty;\quad \lim_{x\to x_0^+}f(x)=-\infty;\quad \lim_{x\to x_0^-}f(x)=+\infty.$$</p>
<p><b>Ví dụ 3.</b> Đồ thị $y=\dfrac{3-x}{x+2}$: $\lim_{x\to(-2)^+}f(x)=+\infty$, $\lim_{x\to(-2)^-}f(x)=-\infty$ nên có tiệm cận đứng $x=-2$.</p>
<p><b>3. Đường tiệm cận xiên.</b> Đường thẳng $y=ax+b$ ($a\neq0$) gọi là <b>đường tiệm cận xiên</b> của đồ thị hàm số $y=f(x)$ nếu
$$\lim_{x\to+\infty}\left[f(x)-(ax+b)\right]=0\ \text{ hoặc }\ \lim_{x\to-\infty}\left[f(x)-(ax+b)\right]=0.$$</p>
<p><i>Chú ý.</i> Nếu $y=ax+b$ ($a\neq0$) là tiệm cận xiên thì
$$a=\lim_{x\to+\infty}\dfrac{f(x)}{x}\ \text{(hoặc }\lim_{x\to-\infty}\dfrac{f(x)}{x}\text{)},\qquad b=\lim_{x\to+\infty}\left[f(x)-ax\right]\ \text{(hoặc }\lim_{x\to-\infty}\left[f(x)-ax\right]\text{)}.$$
Ngược lại, với $a,b$ xác định như trên thì $y=ax+b$ là tiệm cận xiên. Đặc biệt, nếu $a=0$ thì đồ thị có tiệm cận ngang.</p>
<p><b>Ví dụ 4.</b> Tìm tiệm cận xiên của $y=\dfrac{x^2-x+2}{x+1}$. Viết $y=x-2+\dfrac{4}{x+1}$. Vì $\lim_{x\to\pm\infty}\left[f(x)-(x-2)\right]=\lim\dfrac{4}{x+1}=0$ nên đồ thị có tiệm cận xiên $y=x-2$.</p>', 3, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.16.</b> Hình 1.26 là đồ thị của hàm số $y=f(x)=\dfrac{2x^2}{x^2-1}$. Sử dụng đồ thị này, hãy:</p>
<ol type="a">
<li>Viết kết quả của các giới hạn sau: $\lim_{x\to-\infty}f(x)$; $\lim_{x\to+\infty}f(x)$; $\lim_{x\to1^-}f(x)$; $\lim_{x\to-1^+}f(x)$.</li>
<li>Chỉ ra các tiệm cận của đồ thị hàm số đã cho.</li>
</ol>
<div><img src="/static/img/sgk/hinh-1-26.png" alt="Hình minh họa bài 1.16 (SGK)"></div>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.17.</b> Đường thẳng $x=1$ có phải là tiệm cận đứng của đồ thị hàm số $y=\dfrac{x^2+2x-3}{x-1}$ không?</p>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.18.</b> Tìm các tiệm cận của đồ thị các hàm số sau:</p>
<ol type="a">
<li>$y=\dfrac{3-x}{2x+1}$;</li>
<li>$y=\dfrac{2x^2+x-1}{x+2}$.</li>
</ol>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.19.</b> Một công ty sản xuất đồ gia dụng ước tính chi phí để sản xuất $x$ (sản phẩm) là</p>
<p>$$C(x)=2x+50\ \text{(triệu đồng)}.$$</p>
<p>Khi đó $f(x)=\dfrac{C(x)}{x}$ là chi phí sản xuất trung bình cho mỗi sản phẩm. Chứng tỏ rằng hàm số $f(x)$ giảm và $\lim_{x\to+\infty}f(x)=2$. Tính chất này nói lên điều gì?</p>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.20.</b> Một mảnh vườn hình chữ nhật có diện tích bằng 144 m$^2$. Biết độ dài một cạnh của mảnh vườn là $x$ (m).</p>
<ol type="a">
<li>Viết biểu thức tính chu vi $P(x)$ (mét) của mảnh vườn.</li>
<li>Tìm các tiệm cận của đồ thị hàm số $y=P(x)$. Giải thích ý nghĩa thực tiễn của các kết quả này.</li>
</ol>', NULL, 3, 0, 1, @t1);
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 4. Khảo sát sự biến thiên và vẽ đồ thị của hàm số', N'Sơ đồ khảo sát hàm số; khảo sát sự biến thiên và vẽ đồ thị hàm số bậc ba và hàm phân thức hữu tỉ (bậc nhất/bậc nhất, bậc hai/bậc nhất); nhận biết tâm đối xứng, trục đối xứng của đồ thị.', N'<p><b>1. Sơ đồ khảo sát hàm số $y=f(x)$.</b></p>
<ol>
<li>Tìm tập xác định của hàm số.</li>
<li>Khảo sát sự biến thiên của hàm số:
<ul>
<li>Tính đạo hàm $y''$. Tìm các điểm tại đó $y''$ bằng 0 hoặc đạo hàm không tồn tại.</li>
<li>Xét dấu $y''$ để chỉ ra các khoảng đơn điệu của hàm số.</li>
<li>Tìm cực trị của hàm số.</li>
<li>Tìm các giới hạn tại vô cực, giới hạn vô cực và tìm tiệm cận của đồ thị hàm số (nếu có).</li>
<li>Lập bảng biến thiên của hàm số.</li>
</ul></li>
<li>Vẽ đồ thị của hàm số dựa vào bảng biến thiên.</li>
</ol>
<p><i>Chú ý.</i> Khi vẽ đồ thị, nên xác định thêm một số điểm đặc biệt (chẳng hạn giao điểm với các trục toạ độ) và lưu ý tính đối xứng của đồ thị (đối xứng tâm, đối xứng trục).</p>
<p><b>2. Hàm số bậc ba</b> $y=ax^3+bx^2+cx+d$ ($a\neq0$): đồ thị có tâm đối xứng là điểm có hoành độ thoả mãn $y''''=0$, hay $x=-\dfrac{b}{3a}$; không có tiệm cận.</p>
<p><b>Ví dụ 1.</b> Khảo sát hàm số $y=-x^3+3x^2-4$. Tập xác định $\mathbb{R}$. $y''=-3x^2+6x$, $y''=0\Leftrightarrow x=0$ hoặc $x=2$. Hàm số nghịch biến trên $(-\infty;0)$ và $(2;+\infty)$, đồng biến trên $(0;2)$; cực tiểu tại $x=0$ với $y_{CT}=-4$, cực đại tại $x=2$ với $y_{CĐ}=0$; $\lim_{x\to-\infty}y=+\infty$, $\lim_{x\to+\infty}y=-\infty$. Đồ thị cắt $Oy$ tại $(0;-4)$, cắt $Ox$ tại $(-1;0)$ và $(2;0)$, có tâm đối xứng $(1;-2)$.</p>
<p><b>3. Hàm số phân thức hữu tỉ.</b></p>
<p><i>a) $y=\dfrac{ax+b}{cx+d}$ ($c\neq0$, $ad-bc\neq0$).</i> Đồ thị nhận giao điểm của tiệm cận đứng và tiệm cận ngang làm tâm đối xứng; nhận hai đường phân giác của các góc tạo bởi hai tiệm cận này làm các trục đối xứng. Hàm số không có cực trị.</p>
<p><b>Ví dụ 2.</b> $y=\dfrac{x+1}{x-2}$: tập xác định $\mathbb{R}\setminus\{2\}$; $y''=-\dfrac{3}{(x-2)^2}<0$ nên nghịch biến trên $(-\infty;2)$ và $(2;+\infty)$; tiệm cận đứng $x=2$, tiệm cận ngang $y=1$; đồ thị cắt $Oy$ tại $\left(0;-\dfrac12\right)$, cắt $Ox$ tại $(-1;0)$, tâm đối xứng $I(2;1)$.</p>
<p><i>b) $y=\dfrac{ax^2+bx+c}{px+q}$ ($a\neq0$, $p\neq0$, đa thức tử không chia hết cho đa thức mẫu).</i> Đồ thị nhận giao điểm của tiệm cận đứng và tiệm cận xiên làm tâm đối xứng; nhận hai đường phân giác của các góc tạo bởi hai tiệm cận này làm các trục đối xứng.</p>
<p><b>Ví dụ 3.</b> $y=\dfrac{x^2-x-1}{x-2}=x+1+\dfrac{1}{x-2}$: $y''=\dfrac{x^2-4x+3}{(x-2)^2}$, $y''=0\Leftrightarrow x=1$ hoặc $x=3$. Đồng biến trên $(-\infty;1)$, $(3;+\infty)$; nghịch biến trên $(1;2)$, $(2;3)$; $y_{CĐ}=1$ tại $x=1$, $y_{CT}=5$ tại $x=3$. Tiệm cận đứng $x=2$, tiệm cận xiên $y=x+1$; tâm đối xứng $I(2;3)$.</p>', 4, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.21.</b> Khảo sát sự biến thiên và vẽ đồ thị của các hàm số sau:</p>
<ol type="a">
<li>$y=-x^3+3x+1$;</li>
<li>$y=x^3+3x^2-x-1$.</li>
</ol>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.22.</b> Khảo sát sự biến thiên và vẽ đồ thị của các hàm số sau:</p>
<ol type="a">
<li>$y=\dfrac{2x+1}{x+1}$;</li>
<li>$y=\dfrac{x+3}{1-x}$.</li>
</ol>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.23.</b> Khảo sát sự biến thiên và vẽ đồ thị của các hàm số sau:</p>
<ol type="a">
<li>$y=\dfrac{2x^2-x+4}{x-1}$;</li>
<li>$y=\dfrac{x^2+2x+1}{x+3}$.</li>
</ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.24.</b> Một cốc chứa 30 ml dung dịch KOH (potassium hydroxide) với nồng độ 100 mg/ml. Một bình chứa dung dịch KOH khác với nồng độ 8 mg/ml được trộn vào cốc.</p>
<ol type="a">
<li>Tính nồng độ KOH trong cốc sau khi trộn $x$ (ml) từ bình chứa, kí hiệu là $C(x)$.</li>
<li>Coi $C(x)$ là hàm số xác định với $x\ge0$. Khảo sát sự biến thiên và vẽ đồ thị của hàm số này.</li>
<li>Giải thích tại sao nồng độ KOH trong cốc giảm theo $x$ nhưng luôn lớn hơn 8 mg/ml.</li>
</ol>', NULL, 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.25.</b> Trong Vật lí, ta biết rằng khi mắc song song hai điện trở $R_1$ và $R_2$ thì điện trở tương đương $R$ của mạch điện được tính theo công thức $R=\dfrac{R_1R_2}{R_1+R_2}$ (theo <i>Vật lí đại cương</i>, NXB Giáo dục Việt Nam, 2016).</p>
<p>Giả sử một điện trở 8 $\Omega$ được mắc song song với một biến trở như Hình 1.33. Nếu biến trở đó được kí hiệu là $x$ ($\Omega$) thì điện trở tương đương $R$ là hàm số của $x$. Vẽ đồ thị của hàm số $y=R(x)$, $x>0$ và dựa vào đồ thị đã vẽ để trả lời các câu hỏi sau:</p>
<ol type="a">
<li>Điện trở tương đương của mạch thay đổi thế nào khi $x$ tăng?</li>
<li>Tại sao điện trở tương đương của mạch không bao giờ vượt quá 8 $\Omega$?</li>
</ol>
<div><img src="/static/img/sgk/hinh-1-33.png" alt="Hình minh họa bài 1.25 (SGK)"></div>', NULL, 3, 0, 1, @t1);
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 5. Ứng dụng đạo hàm để giải quyết một số vấn đề liên quan đến thực tiễn', N'Vận dụng đạo hàm và khảo sát hàm số để giải các bài toán thực tiễn: tốc độ thay đổi tức thời trong vật lí, hoá học, sinh học, kinh tế và các bài toán tối ưu hoá đơn giản.', N'<p><b>1. Tốc độ thay đổi của một đại lượng.</b> Giả sử $y=f(x)$. Nếu $x$ thay đổi từ $x_1$ đến $x_2$ thì $\Delta x=x_2-x_1$ và $\Delta y=f(x_2)-f(x_1)$.</p>
<ul>
<li>Tỉ số $\dfrac{\Delta y}{\Delta x}=\dfrac{f(x_2)-f(x_1)}{x_2-x_1}$ là <i>tốc độ thay đổi trung bình</i> của $y$ đối với $x$ trên đoạn $[x_1;x_2]$.</li>
<li>Giới hạn $\lim_{\Delta x\to0}\dfrac{\Delta y}{\Delta x}=\lim_{x_2\to x_1}\dfrac{f(x_2)-f(x_1)}{x_2-x_1}$ là <i>tốc độ thay đổi tức thời</i> của $y$ đối với $x$ tại $x=x_1$. Như vậy $f''(a)$ là tốc độ thay đổi tức thời của $y=f(x)$ tại $x=a$.</li>
</ul>
<p>Một số ứng dụng:</p>
<ul>
<li>Nếu $s=s(t)$ là hàm vị trí thì $v=s''(t)$ là vận tốc tức thời; gia tốc tức thời $a(t)=v''(t)=s''''(t)$.</li>
<li>Nếu $C=C(t)$ là nồng độ một chất thì $C''(t)$ là tốc độ phản ứng tức thời của chất đó.</li>
<li>Nếu $P=P(t)$ là số lượng cá thể của quần thể thì $P''(t)$ là tốc độ tăng trưởng tức thời của quần thể.</li>
<li>Nếu $C=C(x)$ là hàm chi phí (tổng chi phí sản xuất $x$ đơn vị hàng hoá) thì $C''(x)$ là <i>chi phí biên</i>, xấp xỉ chi phí để sản xuất thêm một đơn vị hàng hoá thứ $x+1$.</li>
</ul>
<p><b>Ví dụ 1.</b> Độ cao của vật phóng thẳng đứng từ độ cao 2 m với vận tốc 24,5 m/s là $h(t)=2+24,5t-4,9t^2$. Vận tốc $v=h''(t)=24,5-9,8t$, nên $v(2)=4,9$ m/s. Vật cao nhất tại $t=-\dfrac{b}{2a}=2,5$ s, khi đó $h(2,5)=32,625$ m.</p>
<p><b>2. Một vài bài toán tối ưu hoá đơn giản.</b> Quy trình giải:</p>
<ol>
<li>Xác định đại lượng $Q$ cần làm lớn nhất hoặc nhỏ nhất và biểu diễn nó qua các đại lượng khác trong bài toán.</li>
<li>Chọn một đại lượng thích hợp, kí hiệu $x$, biểu diễn các đại lượng khác theo $x$. Khi đó $Q$ là hàm số của một biến $x$; tìm tập xác định của hàm số $Q=Q(x)$.</li>
<li>Tìm giá trị lớn nhất hoặc nhỏ nhất của $Q=Q(x)$ bằng các phương pháp đã biết và kết luận.</li>
</ol>
<p><b>Hàm kinh tế.</b> Nếu $p(x)$ là giá bán mỗi đơn vị khi bán $x$ đơn vị (hàm cầu) thì doanh thu $R(x)=x\cdot p(x)$ (hàm doanh thu); lợi nhuận $P(x)=R(x)-C(x)$ (hàm lợi nhuận). Các đạo hàm $R''(x)$, $P''(x)$ là doanh thu biên, lợi nhuận biên.</p>
<p><b>Ví dụ 2.</b> Hộp trụ có thể tích 1 lít ($1\,000\ \text{cm}^3$): diện tích toàn phần $S=2\pi r^2+\dfrac{2\,000}{r}$ ($r>0$). $S''=0\Leftrightarrow r=\sqrt[3]{\dfrac{500}{\pi}}\approx5,42$ cm, khi đó $h=\dfrac{100}{\sqrt[3]{250\pi}}\approx10,84$ cm. Khi thể tích không đổi, diện tích bề mặt hình trụ nhỏ nhất khi chiều cao bằng đường kính đáy.</p>', 5, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.26.</b> Giả sử một hạt chuyển động trên một trục thẳng đứng chiều dương hướng lên trên sao cho toạ độ của hạt (đơn vị: mét) tại thời điểm $t$ (giây) là $y=t^3-12t+3$, $t\ge0$.</p>
<ol type="a">
<li>Tìm các hàm vận tốc và gia tốc.</li>
<li>Khi nào thì hạt chuyển động lên trên và khi nào thì hạt chuyển động xuống dưới?</li>
<li>Tìm quãng đường hạt đi được trong khoảng thời gian $0\le t\le3$.</li>
<li>Khi nào hạt tăng tốc? Khi nào hạt giảm tốc?</li>
</ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.27.</b> Giả sử chi phí (tính bằng trăm nghìn đồng) để sản xuất $x$ đơn vị hàng hoá nào đó là:</p>
<p>$$C(x)=23\,000+50x-0,5x^2+0,00175x^3.$$</p>
<ol type="a">
<li>Tìm hàm chi phí biên.</li>
<li>Tìm $C''(100)$ và giải thích ý nghĩa của nó.</li>
<li>So sánh $C''(100)$ với chi phí sản xuất đơn vị hàng hoá thứ 101.</li>
</ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.28.</b> Người quản lí của một khu chung cư có 100 căn hộ cho thuê nhận thấy rằng tất cả các căn hộ sẽ có người thuê nếu giá thuê một căn hộ là 8 triệu đồng một tháng. Một cuộc khảo sát thị trường cho thấy rằng, trung bình cứ mỗi lần tăng giá thuê căn hộ thêm 100 nghìn đồng thì sẽ có thêm một căn hộ bị bỏ trống. Người quản lí nên đặt giá thuê mỗi căn hộ là bao nhiêu để doanh thu là lớn nhất?</p>', NULL, 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.29.</b> Giả sử hàm cầu đối với một loại hàng hoá được cho bởi công thức</p>
<p>$$p=\dfrac{354}{1+0,01x},\ x\ge0,$$</p>
<p>trong đó $p$ là giá bán (nghìn đồng) của mỗi đơn vị sản phẩm và $x$ là số lượng đơn vị sản phẩm đã bán.</p>
<ol type="a">
<li>Tìm công thức tính $x$ như là hàm số của $p$. Tìm tập xác định của hàm số này. Tính số đơn vị sản phẩm đã bán khi giá bán của mỗi đơn vị sản phẩm là 240 nghìn đồng.</li>
<li>Khảo sát sự biến thiên và vẽ đồ thị của hàm số $x=x(p)$. Từ đồ thị đã vẽ, hãy cho biết:
<ul><li>Số lượng đơn vị sản phẩm bán được sẽ thay đổi thế nào khi giá bán $p$ tăng;</li>
<li>Ý nghĩa thực tiễn của giới hạn $\lim_{p\to0^+}x(p)$.</li></ul></li>
</ol>', NULL, 3, 0, 1, @t1);
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài tập cuối chương I', N'Bài tập tổng hợp chương I gồm câu hỏi trắc nghiệm và tự luận về tính đơn điệu, cực trị, GTLN-GTNN, tiệm cận, khảo sát và vẽ đồ thị hàm số và ứng dụng thực tiễn.', N'<p>Đây là phần bài tập tổng hợp kiến thức của chương I: tính đơn điệu, cực trị, giá trị lớn nhất và nhỏ nhất, đường tiệm cận, khảo sát và vẽ đồ thị hàm số cùng các ứng dụng thực tiễn.</p>', 6, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 1.30.</b> Cho hàm số $y=f(x)$ có đạo hàm trên khoảng $(a;b)$. Phát biểu nào sau đây là đúng?</p>', N'<p>Định lí: $f''(x)\gt0$ với mọi $x\in(a;b)$ thì hàm đồng biến. Phương án A sai (ví dụ $f''\ge0$ nhưng $f$ hằng thì không đồng biến); C, D sai vì chiều ngược lại không đúng: hàm $y=x^3$ đồng biến nhưng $f''(0)=0$ (D sai), còn C sai vì hàm hằng có $f''\ge0$ nhưng không đồng biến.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'Nếu $f''(x)\ge0$ với mọi $x$ thuộc $(a;b)$ thì hàm số $y=f(x)$ đồng biến trên $(a;b)$.', 0),
(@q, 'B', N'Nếu $f''(x)>0$ với mọi $x$ thuộc $(a;b)$ thì hàm số $y=f(x)$ đồng biến trên $(a;b)$.', 1),
(@q, 'C', N'Hàm số $y=f(x)$ đồng biến trên $(a;b)$ khi và chỉ khi $f''(x)\ge0$ với mọi $x$ thuộc $(a;b)$.', 0),
(@q, 'D', N'Hàm số $y=f(x)$ đồng biến trên $(a;b)$ khi và chỉ khi $f''(x)>0$ với mọi $x$ thuộc $(a;b)$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 1.31.</b> Hàm số nào sau đây nghịch biến trên $\mathbb{R}$?</p>', N'<p>$y''=-3x^2+6x-9$ có $\Delta=36-108\lt0$ và hệ số $a=-3\lt0$ nên $y''\lt0$ với mọi $x$, hàm nghịch biến trên $\mathbb{R}$. Các phương án còn lại: B có $y''=-3x^2+1$ đổi dấu; C không xác định trên $\mathbb{R}$; D là parabol.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$y=-x^3+3x^2-9x$.', 1),
(@q, 'B', N'$y=-x^3+x+1$.', 0),
(@q, 'C', N'$y=\dfrac{x-1}{x-2}$.', 0),
(@q, 'D', N'$y=2x^2+3x+2$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 1.32.</b> Hàm số nào dưới đây không có cực trị?</p>', N'<p>$y=\dfrac{2x-1}{x+1}$ có $y''=\dfrac{3}{(x+1)^2}\gt0$ nên không có cực trị. $y=|x|$ có cực tiểu tại $0$; $y=x^4$ có cực tiểu tại $0$; $y=-x^3+x$ có $y''=-3x^2+1$ đổi dấu nên có cực trị.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$y=|x|$.', 0),
(@q, 'B', N'$y=x^4$.', 0),
(@q, 'C', N'$y=-x^3+x$.', 0),
(@q, 'D', N'$y=\dfrac{2x-1}{x+1}$.', 1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 1.33.</b> Giá trị cực tiểu của hàm số $y=x^2\ln x$ là</p>', N'<p>$y''=2x\ln x+x=x(2\ln x+1)$, $x\gt0$. $y''=0\Leftrightarrow x=e^{-1/2}$; $y''$ đổi dấu từ âm sang dương nên là điểm cực tiểu. $y=e^{-1}\cdot(-\tfrac12)=-\dfrac{1}{2e}$.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$\dfrac{1}{e}$.', 0),
(@q, 'B', N'$-\dfrac{1}{e}$.', 0),
(@q, 'C', N'$-\dfrac{1}{2e}$.', 1),
(@q, 'D', N'$\dfrac{1}{2e}$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 1.34.</b> Giá trị lớn nhất của hàm số $y=(x-2)^2\cdot e^x$ trên đoạn $[1;3]$ là</p>', N'<p>$y''=(x-2)e^x(2+x-2)=x(x-2)e^x$. Trên $[1;3]$: $y''=0$ tại $x=2$. $y(1)=e$, $y(2)=0$, $y(3)=e^3$. Giá trị lớn nhất là $e^3$.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'0.', 0),
(@q, 'B', N'$e^3$.', 1),
(@q, 'C', N'$e^4$.', 0),
(@q, 'D', N'e.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 1.35.</b> Cho hàm số $y=f(x)$ thoả mãn: $\lim_{x\to2^+}f(x)=1$; $\lim_{x\to2^-}f(x)=1$; $\lim_{x\to-\infty}f(x)=2$ và $\lim_{x\to+\infty}f(x)=2$. Khẳng định nào sau đây là đúng?</p>', N'<p>$\lim_{x\to\pm\infty}f(x)=2$ nên $y=2$ là tiệm cận ngang. Tại $x=2$ các giới hạn một phía bằng $1$ (hữu hạn) nên $x=2$ không là tiệm cận đứng; $y=1$ không phải tiệm cận ngang.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'Đường thẳng $x=2$ là tiệm cận đứng của đồ thị hàm số.', 0),
(@q, 'B', N'Đường thẳng $y=2$ là tiệm cận ngang của đồ thị hàm số.', 1),
(@q, 'C', N'Đường thẳng $y=1$ là tiệm cận ngang của đồ thị hàm số.', 0),
(@q, 'D', N'Đường thẳng $x=2$ là tiệm cận ngang của đồ thị hàm số.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 1.36.</b> Tiệm cận xiên của đồ thị hàm số $y=\dfrac{x^2+2x-2}{x+2}$ là</p>', N'<p>$y=\dfrac{x^2+2x-2}{x+2}=x-\dfrac{2}{x+2}$, mà $\dfrac{2}{x+2}\to0$ khi $x\to\pm\infty$ nên tiệm cận xiên là $y=x$.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$y=-2$.', 0),
(@q, 'B', N'$y=1$.', 0),
(@q, 'C', N'$y=x+2$.', 0),
(@q, 'D', N'$y=x$.', 1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 1.37.</b> Cho hàm số $y=f(x)$ xác định trên $\mathbb{R}\setminus\{1;3\}$, liên tục trên mỗi khoảng xác định và có bảng biến thiên như sau (mô tả bằng lời):</p>
<ul>
<li>Trên $(-\infty;1)$: $f''(x)<0$, hàm số giảm từ $1$ (khi $x\to-\infty$) xuống $-1$ (khi $x\to1^-$).</li>
<li>Trên $(1;2)$: $f''(x)<0$, hàm số giảm từ $7$ (khi $x\to1^+$) xuống $5$ (tại $x=2$, $f''(2)=0$).</li>
<li>Trên $(2;3)$: $f''(x)>0$, hàm số tăng từ $5$ lên $+\infty$ (khi $x\to3^-$).</li>
<li>Trên $(3;+\infty)$: $f''(x)>0$, hàm số tăng từ $-4$ (khi $x\to3^+$) lên $-1$ (khi $x\to+\infty$).</li>
</ul>
<p>Khẳng định nào sau đây là <b>sai</b>?</p><div><img src="/static/img/sgk/bang-1-37.png" alt="Hình minh họa bài 1.37 (SGK)"></div>', N'<p>Theo bảng: $\lim_{x\to-\infty}f=1$, $\lim_{x\to+\infty}f=-1$ nên $y=1$, $y=-1$ là tiệm cận ngang (A, B đúng). $\lim_{x\to3^-}f=+\infty$ nên $x=3$ là tiệm cận đứng (C đúng). Tại $x=1$: các giới hạn một phía là $-1$ và $7$ (hữu hạn) nên $x=1$ <b>không</b> là tiệm cận đứng. Vậy D sai.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'Đường thẳng $y=1$ là tiệm cận ngang của đồ thị hàm số đã cho.', 0),
(@q, 'B', N'Đường thẳng $y=-1$ là tiệm cận ngang của đồ thị hàm số đã cho.', 0),
(@q, 'C', N'Đường thẳng $x=3$ là tiệm cận đứng của đồ thị hàm số đã cho.', 0),
(@q, 'D', N'Đường thẳng $x=1$ là tiệm cận đứng của đồ thị hàm số đã cho.', 1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 1.38.</b> Đồ thị trong Hình 1.37 là đồ thị của hàm số:</p><div><img src="/static/img/sgk/hinh-1-37.png" alt="Hình minh họa bài 1.38 (SGK)"></div>', N'<p>Đồ thị có tiệm cận đứng $x=-1$, tiệm cận ngang $y=2$, cắt trục tung tại $(0;1)$. Hàm $y=\dfrac{2x+1}{x+1}$ có $x=-1$, $y=2$ và $y(0)=1$ nên đúng. Các phương án khác có tiệm cận ngang khác $2$ hoặc $y(0)\ne1$.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$y=\dfrac{x+2}{x+1}$.', 0),
(@q, 'B', N'$y=\dfrac{2x+1}{x+1}$.', 1),
(@q, 'C', N'$y=\dfrac{x-1}{x+1}$.', 0),
(@q, 'D', N'$y=\dfrac{x+3}{1-x}$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 1.39.</b> Đồ thị trong Hình 1.38 là đồ thị của hàm số:</p><div><img src="/static/img/sgk/hinh-1-38.png" alt="Hình minh họa bài 1.39 (SGK)"></div>', N'<p>Đồ thị có tiệm cận đứng $x=-1$, tiệm cận xiên $y=x$, đi qua $(0;1)$ và $(-2;-3)$. Hàm $y=\dfrac{x^2+x+1}{x+1}=x+\dfrac{1}{x+1}$: tiệm cận xiên $y=x$, $y(0)=1$, $y(-2)=-3$. Phương án A có $y(0)=-1$; B không có tiệm cận xiên; C có tiệm cận xiên $y=x-2$.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$y=x-\dfrac{1}{x+1}$.', 0),
(@q, 'B', N'$y=\dfrac{2x+1}{x+1}$.', 0),
(@q, 'C', N'$y=\dfrac{x^2-x+1}{x+1}$.', 0),
(@q, 'D', N'$y=\dfrac{x^2+x+1}{x+1}$.', 1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.40.</b> Xét chiều biến thiên và tìm các cực trị (nếu có) của các hàm số sau:</p>
<ol type="a">
<li>$y=x^3-3x^2+3x-1$;</li>
<li>$y=x^4-2x^2-1$;</li>
<li>$y=\dfrac{2x-1}{3x+1}$;</li>
<li>$y=\dfrac{x^2+2x+2}{x+1}$.</li>
</ol>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.41.</b> Tìm giá trị lớn nhất và giá trị nhỏ nhất (nếu có) của các hàm số sau:</p>
<ol type="a">
<li>$y=\dfrac{2x+1}{3x-2}$ trên nửa khoảng $[2;+\infty)$;</li>
<li>$y=\sqrt{2-x^2}$.</li>
</ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.42.</b> Tìm các tiệm cận của đồ thị các hàm số sau:</p>
<ol type="a">
<li>$y=\dfrac{3x-2}{x+1}$;</li>
<li>$y=\dfrac{x^2+2x-1}{2x-1}$.</li>
</ol>', NULL, 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.43.</b> Khảo sát sự biến thiên và vẽ đồ thị của các hàm số sau:</p>
<ol type="a">
<li>$y=-x^3+6x^2-9x+12$;</li>
<li>$y=\dfrac{2x-1}{x+1}$;</li>
<li>$y=\dfrac{x^2-2x}{x-1}$.</li>
</ol>', NULL, 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.44.</b> Xét một thấu kính hội tụ có tiêu cự $f$ (H.1.39). Khoảng cách $p$ từ vật đến thấu kính liên hệ với khoảng cách $q$ từ ảnh đến thấu kính bởi hệ thức:</p>
<p>$$\dfrac{1}{p}+\dfrac{1}{q}=\dfrac{1}{f}.$$</p>
<ol type="a">
<li>Viết công thức tính $q=g(p)$ như một hàm số của biến $p\in(f;+\infty)$.</li>
<li>Tính các giới hạn $\lim_{p\to+\infty}g(p)$; $\lim_{p\to f^+}g(p)$ và giải thích ý nghĩa các kết quả này.</li>
<li>Lập bảng biến thiên của hàm số $q=g(p)$ trên khoảng $(f;+\infty)$.</li>
</ol>
<div><img src="/static/img/sgk/hinh-1-39.png" alt="Hình minh họa bài 1.44 (SGK)"></div>', NULL, 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.45.</b> Dân số của một quốc gia sau $t$ (năm) kể từ năm 2023 được ước tính bởi công thức:</p>
<p>$$N(t)=100e^{0,012t}\ (N(t)\text{ được tính bằng triệu người},\ 0\le t\le50).$$</p>
<ol type="a">
<li>Ước tính dân số của quốc gia này vào các năm 2030 và 2035 (kết quả tính bằng triệu người, làm tròn kết quả đến chữ số thập phân thứ ba).</li>
<li>Xem $N(t)$ là hàm số của biến số $t$ xác định trên đoạn $[0;50]$. Xét chiều biến thiên của hàm số $N(t)$ trên đoạn $[0;50]$.</li>
<li>Đạo hàm của hàm số $N(t)$ biểu thị tốc độ tăng dân số của quốc gia đó (tính bằng triệu người/năm). Vào năm nào tốc độ tăng dân số của quốc gia đó là 1,6 triệu người/năm?</li>
</ol>', NULL, 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.46.</b> Một đường dây điện được nối từ một nhà máy điện ở $A$ đến một hòn đảo ở $C$ như Hình 1.40. Khoảng cách từ $C$ đến $B$ là 4 km. Bờ biển chạy thẳng từ $A$ đến $B$ với khoảng cách là 10 km. Tổng chi phí lắp đặt cho 1 km dây điện trên biển là 50 triệu đồng, còn trên đất liền là 30 triệu đồng. Xác định vị trí điểm $M$ trên đoạn $AB$ (điểm nối dây từ đất liền ra đảo) để tổng chi phí lắp đặt là nhỏ nhất.</p>
<div><img src="/static/img/sgk/hinh-1-40.png" alt="Hình minh họa bài 1.46 (SGK)"></div>', NULL, 3, 0, 1, @t1);

COMMIT TRANSACTION;

SELECT t.TopicName, COUNT(DISTINCT l.LessonId) AS Lessons, COUNT(q.QuestionId) AS Questions
FROM Topics t LEFT JOIN Lessons l ON l.TopicId = t.TopicId LEFT JOIN Questions q ON q.LessonId = l.LessonId
GROUP BY t.TopicId, t.TopicName, t.OrderIndex ORDER BY t.OrderIndex;
GO
