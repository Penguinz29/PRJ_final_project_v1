-- =====================================================================================================================
-- File: document/sql/04_data_sgk_toan12.sql — nội dung theo SGK Toán 12 (bộ Kết nối tri thức với cuộc sống, Tập 1 + Tập 2)
-- Chạy SAU 01_schema.sql, 02_data.sql (và 03_data_gdpt2018.sql nếu muốn; 04 sẽ xóa nội dung của 02/03 rồi thay mới).
-- CẢNH BÁO: script XÓA TOÀN BỘ chủ đề / bài học / bài giảng / câu hỏi / bài làm / phiên gia sư AI cũ (dữ liệu demo của 02 và 03),
--           rồi nạp lại theo sách giáo khoa. GIỮ NGUYÊN Users và AiConfigs. Chạy lại lần 2 sẽ tự bỏ qua (không nhân đôi).
-- Cấu trúc: mỗi CHƯƠNG của sách = 1 chủ đề (Topics); mỗi BÀI = 1 bài học (Lessons, Content là tóm tắt lý thuyết trọng tâm);
--           mục "Bài tập" cuối bài và "Bài tập cuối chương" của sách thành câu hỏi: câu trắc nghiệm của sách = MCQ (4 phương án, có đáp án và lời giải ngắn),
--           các bài còn lại = TỰ LUẬN (ESSAY, có lời giải từng bước). Sách không in đáp án nên đáp án và lời giải do người số hóa tự giải (đáp án trắc nghiệm đã được tính lại độc lập; lời giải tự luận chưa được rà soát độc lập, giáo viên nên xem lại khi dùng chính thức).
-- Toàn bộ chủ đề / bài học / câu hỏi do teacher1 tạo. Mọi giáo viên xem và sửa được chủ đề / bài học / bài giảng; chỉ người tạo hoặc Admin xóa; câu hỏi chỉ người tạo (hoặc Admin) sửa.
-- Thứ tự hiển thị: chủ đề theo OrderIndex (Chương I → VI → Ôn tập), bài học theo DisplayOrder (Bài 1 → 19), câu hỏi theo QuestionId (đúng thứ tự trong sách).
-- Mức độ (Level 1-3) do người số hóa tự đánh giá, giáo viên có thể chỉnh trên giao diện.
-- Đề có hình vẽ / đồ thị / bảng biến thiên trong SGK được gắn ảnh cắt từ sách: thẻ <img src="/static/img/sgk/..."> (32 ảnh trong src/main/webapp/static/img/sgk).
-- Cần bản mã nguồn có HtmlSanitizer hỗ trợ <img> (đã sửa cùng đợt) và triển khai lại WAR kèm thư mục ảnh.
-- Mỗi bài (Bài 1-19) có 1 video bài giảng YouTube của VietJack (tab "Bài giảng"), đã kiểm tra nhúng được.
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
INSERT INTO LessonMaterials (LessonId, MaterialType, Title, Url, ContentText, OrderIndex, CreatedBy) VALUES (@l, 'YOUTUBE', N'Video bài giảng: Bài 1. Tính đơn điệu và cực trị của hàm số', 'https://www.youtube.com/watch?v=mlDaCqG_--g', NULL, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.1.</b> Tìm các khoảng đồng biến, khoảng nghịch biến của các hàm số có đồ thị như sau:</p>
<ol type="a">
<li>Đồ thị hàm số $y=x^3-\dfrac{3}{2}x^2$ (H.1.11);</li>
<li>Đồ thị hàm số $y=\sqrt[3]{(x^2-4)^2}$ (H.1.12).</li>
</ol>
<div><img src="/static/img/sgk/hinh-1-11.png" alt="Hình minh họa bài 1.1 (SGK)"></div><div><img src="/static/img/sgk/hinh-1-12.png" alt="Hình minh họa bài 1.1 (SGK)"></div>', N'<p><b>a)</b> $y''=3x^2-3x=3x(x-1)$. $y''=0 \Leftrightarrow x=0$ hoặc $x=1$. Xét dấu: $y''\gt 0$ trên $(-\infty;0)$ và $(1;+\infty)$; $y''\lt 0$ trên $(0;1)$. Đồ thị đi lên trên hai khoảng đầu và đi xuống trên $(0;1)$ (phù hợp Hình 1.11).</p>
<p><b>b)</b> $y=(x^2-4)^{2/3}$, $y''=\dfrac{4x}{3\sqrt[3]{x^2-4}}$ (không xác định tại $x=\pm 2$, $y''=0$ tại $x=0$). Xét dấu: với $x\lt -2$: tử âm, mẫu dương nên $y''\lt 0$; với $-2\lt x\lt 0$: tử âm, mẫu âm nên $y''\gt 0$; với $0\lt x\lt 2$: $y''\lt 0$; với $x\gt 2$: $y''\gt 0$.</p>
<p><b>Đáp số:</b> a) đồng biến trên $(-\infty;0)$ và $(1;+\infty)$, nghịch biến trên $(0;1)$. b) đồng biến trên $(-2;0)$ và $(2;+\infty)$, nghịch biến trên $(-\infty;-2)$ và $(0;2)$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.2.</b> Xét sự đồng biến, nghịch biến của các hàm số sau:</p>
<ol type="a">
<li>$y=\dfrac{1}{3}x^3-2x^2+3x+1$;</li>
<li>$y=-x^3+2x^2-5x+3$.</li>
</ol>', N'<p><b>a)</b> $y''=x^2-4x+3=(x-1)(x-3)$. $y''\gt 0$ khi $x\lt 1$ hoặc $x\gt 3$; $y''\lt 0$ khi $1\lt x\lt 3$. Hàm số đồng biến trên $(-\infty;1)$ và $(3;+\infty)$, nghịch biến trên $(1;3)$.</p>
<p><b>b)</b> $y''=-3x^2+4x-5$ có $\Delta''=4-15=-11\lt 0$ và hệ số $a=-3\lt 0$ nên $y''\lt 0$ với mọi $x$. Hàm số nghịch biến trên $\mathbb{R}$.</p>
<p><b>Đáp số:</b> a) đồng biến trên $(-\infty;1)$, $(3;+\infty)$; nghịch biến trên $(1;3)$. b) nghịch biến trên $\mathbb{R}$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.3.</b> Tìm các khoảng đơn điệu của các hàm số sau:</p>
<ol type="a">
<li>$y=\dfrac{2x-1}{x+2}$;</li>
<li>$y=\dfrac{x^2+x+4}{x-3}$.</li>
</ol>', N'<p><b>a)</b> Tập xác định $\mathbb{R}\setminus\{-2\}$. $y''=\dfrac{2\cdot 2-(-1)\cdot 1}{(x+2)^2}=\dfrac{5}{(x+2)^2}\gt 0$ với mọi $x\ne -2$. Vậy hàm số đồng biến trên $(-\infty;-2)$ và $(-2;+\infty)$.</p>
<p><b>b)</b> Tập xác định $\mathbb{R}\setminus\{3\}$. $y''=\dfrac{(2x+1)(x-3)-(x^2+x+4)}{(x-3)^2}=\dfrac{x^2-6x-7}{(x-3)^2}$. $y''=0 \Leftrightarrow x=-1$ hoặc $x=7$. Xét dấu: $y''\gt 0$ khi $x\lt -1$ hoặc $x\gt 7$; $y''\lt 0$ khi $-1\lt x\lt 7$ ($x\ne 3$).</p>
<p><b>Đáp số:</b> a) đồng biến trên $(-\infty;-2)$ và $(-2;+\infty)$. b) đồng biến trên $(-\infty;-1)$ và $(7;+\infty)$; nghịch biến trên $(-1;3)$ và $(3;7)$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.4.</b> Xét chiều biến thiên của các hàm số sau:</p>
<ol type="a">
<li>$y=\sqrt{4-x^2}$;</li>
<li>$y=\dfrac{x}{x^2+1}$.</li>
</ol>', N'<p><b>a)</b> Điều kiện $4-x^2\ge 0$ nên tập xác định $[-2;2]$. $y''=\dfrac{-x}{\sqrt{4-x^2}}$ với $x\in(-2;2)$. $y''\gt 0$ khi $-2\lt x\lt 0$; $y''\lt 0$ khi $0\lt x\lt 2$.</p>
<p><b>b)</b> Tập xác định $\mathbb{R}$. $y''=\dfrac{(x^2+1)-2x^2}{(x^2+1)^2}=\dfrac{1-x^2}{(x^2+1)^2}$. $y''\gt 0$ khi $-1\lt x\lt 1$; $y''\lt 0$ khi $x\lt -1$ hoặc $x\gt 1$.</p>
<p><b>Đáp số:</b> a) đồng biến trên $(-2;0)$, nghịch biến trên $(0;2)$. b) đồng biến trên $(-1;1)$, nghịch biến trên $(-\infty;-1)$ và $(1;+\infty)$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.5.</b> Giả sử số dân của một thị trấn sau $t$ năm kể từ năm 2000 được mô tả bởi hàm số</p>
<p>$$N(t)=\dfrac{25t+10}{t+5},\ t\ge 0,$$</p>
<p>trong đó $N(t)$ được tính bằng nghìn người.</p>
<ol type="a">
<li>Tính số dân của thị trấn đó vào các năm 2000 và 2015.</li>
<li>Tính đạo hàm $N''(t)$ và $\lim_{t\to+\infty}N(t)$. Từ đó, giải thích tại sao số dân của thị trấn đó luôn tăng nhưng sẽ không vượt quá một ngưỡng nào đó.</li>
</ol>', N'<p><b>a)</b> Năm 2000 ứng với $t=0$: $N(0)=\dfrac{10}{5}=2$ (nghìn người). Năm 2015 ứng với $t=15$: $N(15)=\dfrac{25\cdot 15+10}{20}=\dfrac{385}{20}=19{,}25$ (nghìn người).</p>
<p><b>b)</b> $N''(t)=\dfrac{25(t+5)-(25t+10)}{(t+5)^2}=\dfrac{115}{(t+5)^2}$. Vì $N''(t)\gt 0$ với mọi $t\ge 0$ nên $N(t)$ luôn tăng, tức dân số luôn tăng. Mặt khác $\lim_{t\to+\infty}N(t)=\lim_{t\to+\infty}\dfrac{25+10/t}{1+5/t}=25$. Hơn nữa $25-N(t)=\dfrac{115}{t+5}\gt 0$ nên $N(t)\lt 25$ với mọi $t$: dân số luôn tăng nhưng không vượt quá 25 nghìn người.</p>
<p><b>Đáp số:</b> a) 2 nghìn người (năm 2000), 19,25 nghìn người (năm 2015). b) $N''(t)=\dfrac{115}{(t+5)^2}\gt 0$, $\lim N(t)=25$; dân số không vượt quá 25 nghìn người.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.6.</b> Đồ thị của đạo hàm bậc nhất $y=f''(x)$ của hàm số $f(x)$ được cho trong Hình 1.13.</p>
<ol type="a">
<li>Hàm số $f(x)$ đồng biến trên những khoảng nào? Giải thích.</li>
<li>Tại giá trị nào của $x$ thì $f(x)$ có cực đại hoặc cực tiểu? Giải thích.</li>
</ol>
<div><img src="/static/img/sgk/hinh-1-13.png" alt="Hình minh họa bài 1.6 (SGK)"></div>', N'<p>Dựa vào dấu của $f''(x)$ trên đồ thị (đồ thị $y=f''(x)$ nằm trên trục hoành thì $f''\gt 0$, nằm dưới thì $f''\lt 0$): $f''(x)\lt 0$ trên $(0;2)$, $f''(x)\gt 0$ trên $(2;4)$, $f''(x)\lt 0$ trên $(4;6)$, $f''(x)\gt 0$ trên $(6;+\infty)$; $f''(x)=0$ tại $x=2,\,4,\,6$.</p>
<p><b>a)</b> $f(x)$ đồng biến trên các khoảng mà $f''(x)\gt 0$: $(2;4)$ và $(6;+\infty)$ (còn nghịch biến trên $(0;2)$ và $(4;6)$).</p>
<p><b>b)</b> $f''$ đổi dấu từ âm sang dương khi qua $x=2$ và $x=6$ nên $f$ đạt cực tiểu tại $x=2$ và $x=6$; $f''$ đổi dấu từ dương sang âm khi qua $x=4$ nên $f$ đạt cực đại tại $x=4$.</p>
<p><b>Đáp số:</b> a) đồng biến trên $(2;4)$ và $(6;+\infty)$. b) cực đại tại $x=4$; cực tiểu tại $x=2$ và $x=6$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.7.</b> Tìm cực trị của các hàm số sau:</p>
<ol type="a">
<li>$y=2x^3-9x^2+12x-5$;</li>
<li>$y=x^4-4x^2+2$;</li>
<li>$y=\dfrac{x^2-2x+3}{x-1}$;</li>
<li>$y=\sqrt{4x-2x^2}$.</li>
</ol>', N'<p><b>a)</b> $y''=6x^2-18x+12=6(x-1)(x-2)$. $y''\gt 0$ khi $x\lt 1$ hoặc $x\gt 2$; $y''\lt 0$ khi $1\lt x\lt 2$. Cực đại tại $x=1$, $y_{CĐ}=y(1)=0$; cực tiểu tại $x=2$, $y_{CT}=y(2)=-1$.</p>
<p><b>b)</b> $y''=4x^3-8x=4x(x^2-2)$, $y''=0\Leftrightarrow x=0$ hoặc $x=\pm\sqrt2$. Xét dấu: $y''\lt 0$ trên $(-\infty;-\sqrt2)$ và $(0;\sqrt2)$; $y''\gt 0$ trên $(-\sqrt2;0)$ và $(\sqrt2;+\infty)$. Cực đại tại $x=0$, $y_{CĐ}=2$; cực tiểu tại $x=\pm\sqrt2$, $y_{CT}=-2$.</p>
<p><b>c)</b> Tập xác định $\mathbb{R}\setminus\{1\}$. $y''=\dfrac{(2x-2)(x-1)-(x^2-2x+3)}{(x-1)^2}=\dfrac{x^2-2x-1}{(x-1)^2}$, $y''=0\Leftrightarrow x=1\pm\sqrt2$. $y''\gt 0$ khi $x\lt 1-\sqrt2$ hoặc $x\gt 1+\sqrt2$; $y''\lt 0$ trên các khoảng còn lại. Viết $y=x-1+\dfrac{2}{x-1}$: $y(1-\sqrt2)=-2\sqrt2$, $y(1+\sqrt2)=2\sqrt2$. Cực đại tại $x=1-\sqrt2$, $y_{CĐ}=-2\sqrt2$; cực tiểu tại $x=1+\sqrt2$, $y_{CT}=2\sqrt2$.</p>
<p><b>d)</b> Điều kiện $4x-2x^2\ge 0\Leftrightarrow 0\le x\le 2$. $y''=\dfrac{2-2x}{\sqrt{4x-2x^2}}$ trên $(0;2)$; $y''\gt 0$ khi $0\lt x\lt 1$, $y''\lt 0$ khi $1\lt x\lt 2$. Cực đại tại $x=1$, $y_{CĐ}=\sqrt2$; hàm số không có cực tiểu (hai đầu mút $x=0$, $x=2$ không phải điểm cực trị).</p>
<p><b>Đáp số:</b> a) CĐ $(1;0)$, CT $(2;-1)$. b) CĐ $(0;2)$, CT $(\pm\sqrt2;-2)$. c) CĐ $(1-\sqrt2;-2\sqrt2)$, CT $(1+\sqrt2;2\sqrt2)$. d) CĐ $(1;\sqrt2)$, không có cực tiểu.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.8.</b> Cho hàm số $y=f(x)=|x|$.</p>
<ol type="a">
<li>Tính các giới hạn $\lim_{x\to 0^+}\dfrac{f(x)-f(0)}{x-0}$ và $\lim_{x\to 0^-}\dfrac{f(x)-f(0)}{x-0}$. Từ đó suy ra hàm số không có đạo hàm tại $x=0$.</li>
<li>Sử dụng định nghĩa, chứng minh hàm số có cực tiểu tại $x=0$ (xem Hình 1.4).</li>
</ol>', N'<p><b>a)</b> $f(0)=0$.</p>
<ul><li>$\lim_{x\to0^+}\dfrac{|x|-0}{x-0}=\lim_{x\to0^+}\dfrac{x}{x}=1$.</li>
<li>$\lim_{x\to0^-}\dfrac{|x|-0}{x-0}=\lim_{x\to0^-}\dfrac{-x}{x}=-1$.</li></ul>
<p>Hai giới hạn một phía khác nhau nên không tồn tại $\lim_{x\to0}\dfrac{f(x)-f(0)}{x-0}$, tức hàm số không có đạo hàm tại $x=0$.</p>
<p><b>b)</b> Với mọi $x\ne0$ ta có $f(x)=|x|\gt 0=f(0)$. Do đó tồn tại khoảng $(-1;1)$ chứa $0$ sao cho $f(x)\gt f(0)$ với mọi $x\in(-1;1)\setminus\{0\}$. Theo định nghĩa, hàm số đạt cực tiểu tại $x=0$ (giá trị cực tiểu bằng 0).</p>
<p><b>Đáp số:</b> a) giới hạn bên phải bằng $1$, bên trái bằng $-1$, nên không có đạo hàm tại $0$. b) hàm số đạt cực tiểu tại $x=0$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.9.</b> Giả sử doanh số (tính bằng số sản phẩm) của một sản phẩm mới (trong vòng một số năm nhất định) tuân theo quy luật logistic được mô hình hoá bằng hàm số</p>
<p>$$f(t)=\dfrac{5\,000}{1+5e^{-t}},\ t\ge 0,$$</p>
<p>trong đó thời gian $t$ được tính bằng năm, kể từ khi phát hành sản phẩm mới. Khi đó, đạo hàm $f''(t)$ sẽ biểu thị tốc độ bán hàng. Hỏi sau khi phát hành bao nhiêu năm thì tốc độ bán hàng là lớn nhất?</p>', N'<p>Tốc độ bán hàng: $f''(t)=\dfrac{5000\cdot5e^{-t}}{(1+5e^{-t})^2}=\dfrac{25000e^{-t}}{(1+5e^{-t})^2}$. Nhân tử và mẫu với $e^{2t}$: $f''(t)=\dfrac{25000e^{t}}{(e^{t}+5)^2}$.</p>
<p>Đặt $g(t)=f''(t)$. Ta có $g''(t)=25000\cdot\dfrac{e^t(e^t+5)^2-e^t\cdot2(e^t+5)e^t}{(e^t+5)^4}=25000\cdot\dfrac{e^t(5-e^t)}{(e^t+5)^3}$.</p>
<p>$g''(t)=0\Leftrightarrow e^t=5\Leftrightarrow t=\ln5$. Với $0\le t\lt\ln5$ thì $g''\gt 0$, với $t\gt\ln5$ thì $g''\lt 0$. Vậy $g(t)$ đạt giá trị lớn nhất tại $t=\ln5\approx1{,}61$, khi đó $g=\dfrac{25000\cdot5}{100}=1250$ sản phẩm/năm.</p>
<p><b>Đáp số:</b> sau $\ln5\approx1{,}6$ năm (khoảng 1 năm 7 tháng) thì tốc độ bán hàng lớn nhất (khoảng 1250 sản phẩm/năm).</p>', 3, 0, 1, @t1);
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
INSERT INTO LessonMaterials (LessonId, MaterialType, Title, Url, ContentText, OrderIndex, CreatedBy) VALUES (@l, 'YOUTUBE', N'Video bài giảng: Bài 2. Giá trị lớn nhất và giá trị nhỏ nhất của hàm số', 'https://www.youtube.com/watch?v=Uv56Mhz3HvY', NULL, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.10.</b> Tìm giá trị lớn nhất và giá trị nhỏ nhất (nếu có) của các hàm số sau:</p>
<ol type="a">
<li>$y=-x^2+4x+3$;</li>
<li>$y=x^3-2x^2+1$ trên $[0;+\infty)$;</li>
<li>$y=\dfrac{x^2-2x+3}{x-1}$ trên $(1;+\infty)$;</li>
<li>$y=\sqrt{4x-2x^2}$.</li>
</ol>', N'<p><b>a)</b> $y=-(x-2)^2+7\le7$, dấu bằng khi $x=2$. Giá trị lớn nhất bằng $7$ tại $x=2$; hàm số không có giá trị nhỏ nhất (vì $y\to-\infty$ khi $x\to\pm\infty$).</p>
<p><b>b)</b> $y''=3x^2-4x=0\Leftrightarrow x=0$ hoặc $x=\dfrac43$. Trên $[0;+\infty)$: $y''\lt 0$ với $0\lt x\lt\dfrac43$, $y''\gt 0$ với $x\gt\dfrac43$, và $y\to+\infty$ khi $x\to+\infty$. $y\left(\dfrac43\right)=\dfrac{64}{27}-\dfrac{32}{9}+1=-\dfrac5{27}$. Vậy giá trị nhỏ nhất là $-\dfrac5{27}$ tại $x=\dfrac43$; không có giá trị lớn nhất.</p>
<p><b>c)</b> Trên $(1;+\infty)$, $y=x-1+\dfrac2{x-1}$; $y''=\dfrac{x^2-2x-1}{(x-1)^2}=0\Leftrightarrow x=1+\sqrt2$. $y''\lt 0$ trên $(1;1+\sqrt2)$, $y''\gt 0$ trên $(1+\sqrt2;+\infty)$, $y\to+\infty$ ở hai đầu. Giá trị nhỏ nhất là $y(1+\sqrt2)=2\sqrt2$; không có giá trị lớn nhất.</p>
<p><b>d)</b> Tập xác định $[0;2]$. $4x-2x^2=2-2(x-1)^2\in[0;2]$ nên $0\le y\le\sqrt2$; $y=\sqrt2$ khi $x=1$, $y=0$ khi $x=0$ hoặc $x=2$.</p>
<p><b>Đáp số:</b> a) $\max=7$, không có min. b) $\min=-\dfrac5{27}$, không có max. c) $\min=2\sqrt2$, không có max. d) $\max=\sqrt2$, $\min=0$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.11.</b> Tìm giá trị lớn nhất và giá trị nhỏ nhất (nếu có) của các hàm số sau:</p>
<ol type="a">
<li>$y=x^4-2x^2+3$;</li>
<li>$y=xe^{-x}$;</li>
<li>$y=x\ln x$;</li>
<li>$y=\sqrt{x-1}+\sqrt{3-x}$.</li>
</ol>', N'<p><b>a)</b> $y''=4x^3-4x=4x(x-1)(x+1)$. Lập bảng biến thiên: $y(0)=3$ (cực đại), $y(\pm1)=2$ (cực tiểu); $y\to+\infty$ khi $x\to\pm\infty$. Giá trị nhỏ nhất bằng $2$ tại $x=\pm1$; không có giá trị lớn nhất.</p>
<p><b>b)</b> $y''=(1-x)e^{-x}$. $y''\gt 0$ khi $x\lt1$, $y''\lt 0$ khi $x\gt1$ nên $\max y=y(1)=\dfrac1e$. Khi $x\to-\infty$, $y\to-\infty$ nên không có giá trị nhỏ nhất.</p>
<p><b>c)</b> Tập xác định $(0;+\infty)$. $y''=\ln x+1=0\Leftrightarrow x=\dfrac1e$; $y''\lt 0$ khi $0\lt x\lt\dfrac1e$, $y''\gt 0$ khi $x\gt\dfrac1e$. $\min y=y\left(\dfrac1e\right)=-\dfrac1e$. Vì $y\to+\infty$ khi $x\to+\infty$ nên không có giá trị lớn nhất.</p>
<p><b>d)</b> Tập xác định $[1;3]$. $y''=\dfrac1{2\sqrt{x-1}}-\dfrac1{2\sqrt{3-x}}=0\Leftrightarrow x-1=3-x\Leftrightarrow x=2$. $y(1)=y(3)=\sqrt2$, $y(2)=2$. Vậy $\max y=2$ tại $x=2$, $\min y=\sqrt2$ tại $x=1$ và $x=3$.</p>
<p><b>Đáp số:</b> a) $\min=2$, không có max. b) $\max=\dfrac1e$, không có min. c) $\min=-\dfrac1e$, không có max. d) $\max=2$, $\min=\sqrt2$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.12.</b> Tìm giá trị lớn nhất và giá trị nhỏ nhất của các hàm số sau:</p>
<ol type="a">
<li>$y=2x^3-6x+3$ trên đoạn $[-1;2]$;</li>
<li>$y=x^4-3x^2+2$ trên đoạn $[0;3]$;</li>
<li>$y=x-\sin 2x$ trên đoạn $[0;\pi]$;</li>
<li>$y=(x^2-x)e^x$ trên đoạn $[0;1]$.</li>
</ol>', N'<p><b>a)</b> $y''=6x^2-6=0\Leftrightarrow x=\pm1$. $y(-1)=7$, $y(1)=-1$, $y(2)=7$. Vậy $\max=7$ (tại $x=-1$ và $x=2$), $\min=-1$ (tại $x=1$).</p>
<p><b>b)</b> $y''=4x^3-6x=2x(2x^2-3)=0\Leftrightarrow x=0$ hoặc $x=\sqrt{\tfrac32}$ (trong $[0;3]$). $y(0)=2$, $y\left(\sqrt{\tfrac32}\right)=\dfrac94-\dfrac92+2=-\dfrac14$, $y(3)=56$. Vậy $\max=56$ tại $x=3$, $\min=-\dfrac14$ tại $x=\sqrt{\tfrac32}$.</p>
<p><b>c)</b> $y''=1-2\cos2x=0\Leftrightarrow\cos2x=\dfrac12$, trong $[0;\pi]$ có $x=\dfrac\pi6$, $x=\dfrac{5\pi}6$. $y(0)=0$; $y\left(\dfrac\pi6\right)=\dfrac\pi6-\dfrac{\sqrt3}2$; $y\left(\dfrac{5\pi}6\right)=\dfrac{5\pi}6+\dfrac{\sqrt3}2$; $y(\pi)=\pi$. So sánh: $\max=\dfrac{5\pi}6+\dfrac{\sqrt3}2\approx3{,}48$, $\min=\dfrac\pi6-\dfrac{\sqrt3}2\approx-0{,}34$.</p>
<p><b>d)</b> $y''=(2x-1)e^x+(x^2-x)e^x=(x^2+x-1)e^x=0\Leftrightarrow x=\dfrac{-1+\sqrt5}2=x_0\in[0;1]$. $y(0)=y(1)=0$; vì $x_0^2=1-x_0$ nên $x_0^2-x_0=1-2x_0=2-\sqrt5$, do đó $y(x_0)=(2-\sqrt5)e^{\frac{\sqrt5-1}2}\approx-0{,}438$. Vậy $\max=0$ (tại $x=0$ và $x=1$), $\min=(2-\sqrt5)e^{\frac{\sqrt5-1}2}$.</p>
<p><b>Đáp số:</b> a) $\max=7$, $\min=-1$. b) $\max=56$, $\min=-\dfrac14$. c) $\max=\dfrac{5\pi}6+\dfrac{\sqrt3}2$, $\min=\dfrac\pi6-\dfrac{\sqrt3}2$. d) $\max=0$, $\min=(2-\sqrt5)e^{\frac{\sqrt5-1}2}$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.13.</b> Trong các hình chữ nhật có chu vi là 24 cm, hãy tìm hình chữ nhật có diện tích lớn nhất.</p>', N'<p>Gọi một cạnh của hình chữ nhật là $x$ (cm), $0\lt x\lt12$. Nửa chu vi bằng 12 nên cạnh kia là $12-x$. Diện tích $S(x)=x(12-x)=12x-x^2$.</p>
<p>$S''(x)=12-2x=0\Leftrightarrow x=6$. $S''\gt 0$ khi $x\lt6$, $S''\lt 0$ khi $x\gt6$ nên $S$ lớn nhất tại $x=6$, $S(6)=36$. (Cũng có thể viết $S=36-(x-6)^2\le36$.)</p>
<p><b>Đáp số:</b> hình vuông cạnh $6$ cm, diện tích lớn nhất $36\ \text{cm}^2$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.14.</b> Một nhà sản xuất muốn thiết kế một chiếc hộp có dạng hình hộp chữ nhật không có nắp, có đáy là hình vuông và diện tích bề mặt bằng 108 cm$^2$ như Hình 1.17. Tìm các kích thước của chiếc hộp sao cho thể tích của hộp là lớn nhất.</p>
<div><img src="/static/img/sgk/hinh-1-17.png" alt="Hình minh họa bài 1.14 (SGK)"></div>', N'<p>Gọi cạnh đáy là $x$ (cm), chiều cao là $h$ (cm), $x\gt0$, $h\gt0$. Hộp không nắp nên diện tích bề mặt: $x^2+4xh=108$, suy ra $h=\dfrac{108-x^2}{4x}$ (với $0\lt x\lt\sqrt{108}$).</p>
<p>Thể tích: $V(x)=x^2h=\dfrac{x(108-x^2)}4=\dfrac{108x-x^3}4$. $V''(x)=\dfrac{108-3x^2}4=0\Leftrightarrow x=6$. $V''\gt 0$ khi $0\lt x\lt6$, $V''\lt 0$ khi $x\gt6$ nên $V$ lớn nhất tại $x=6$; khi đó $h=\dfrac{108-36}{24}=3$ và $V=108\ \text{cm}^3$.</p>
<p><b>Đáp số:</b> đáy hình vuông cạnh $6$ cm, chiều cao $3$ cm (thể tích lớn nhất $108\ \text{cm}^3$).</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.15.</b> Một nhà sản xuất cần làm ra những chiếc bình có dạng hình trụ với dung tích 1 000 cm$^3$. Mặt trên và mặt dưới của bình được làm bằng vật liệu có giá 1,2 nghìn đồng/cm$^2$, trong khi mặt bên của bình được làm bằng vật liệu có giá 0,75 nghìn đồng/cm$^2$. Tìm các kích thước của bình (bán kính đáy và chiều cao của bình) để chi phí vật liệu sản xuất mỗi chiếc bình là nhỏ nhất.</p>', N'<p>Gọi bán kính đáy là $r$ (cm), chiều cao $h$ (cm). Dung tích: $\pi r^2h=1000$, suy ra $h=\dfrac{1000}{\pi r^2}$.</p>
<p>Chi phí (nghìn đồng): hai đáy có diện tích $2\pi r^2$, mặt bên có diện tích $2\pi rh=\dfrac{2000}{r}$. Do đó
$$C(r)=1{,}2\cdot2\pi r^2+0{,}75\cdot\dfrac{2000}{r}=2{,}4\pi r^2+\dfrac{1500}{r},\ r\gt0.$$</p>
<p>$C''(r)=4{,}8\pi r-\dfrac{1500}{r^2}=0\Leftrightarrow r^3=\dfrac{1500}{4{,}8\pi}=\dfrac{625}{2\pi}$, tức $r=\sqrt[3]{\dfrac{625}{2\pi}}\approx4{,}63$. $C''\lt 0$ khi $r$ nhỏ hơn giá trị này và $C''\gt 0$ khi lớn hơn, nên $C$ nhỏ nhất tại đó. Khi đó $h=\dfrac{1000}{\pi r^2}=3{,}2r\approx14{,}83$. Chi phí nhỏ nhất khoảng $485{,}6$ nghìn đồng.</p>
<p><b>Đáp số:</b> $r=\sqrt[3]{\dfrac{625}{2\pi}}\approx4{,}63$ cm, $h\approx14{,}83$ cm.</p>', 3, 0, 1, @t1);
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
INSERT INTO LessonMaterials (LessonId, MaterialType, Title, Url, ContentText, OrderIndex, CreatedBy) VALUES (@l, 'YOUTUBE', N'Video bài giảng: Bài 3. Đường tiệm cận của đồ thị hàm số', 'https://www.youtube.com/watch?v=vHjEes8Ri8A', NULL, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.16.</b> Hình 1.26 là đồ thị của hàm số $y=f(x)=\dfrac{2x^2}{x^2-1}$. Sử dụng đồ thị này, hãy:</p>
<ol type="a">
<li>Viết kết quả của các giới hạn sau: $\lim_{x\to-\infty}f(x)$; $\lim_{x\to+\infty}f(x)$; $\lim_{x\to1^-}f(x)$; $\lim_{x\to-1^+}f(x)$.</li>
<li>Chỉ ra các tiệm cận của đồ thị hàm số đã cho.</li>
</ol>
<div><img src="/static/img/sgk/hinh-1-26.png" alt="Hình minh họa bài 1.16 (SGK)"></div>', N'<p><b>a)</b> Từ đồ thị (Hình 1.26): khi $x\to-\infty$ và $x\to+\infty$ đồ thị tiến sát đường $y=2$; khi $x\to1^-$ đồ thị đi xuống vô hạn; khi $x\to-1^+$ đồ thị cũng đi xuống vô hạn. Vậy
$$\lim_{x\to-\infty}f(x)=2,\ \lim_{x\to+\infty}f(x)=2,\ \lim_{x\to1^-}f(x)=-\infty,\ \lim_{x\to-1^+}f(x)=-\infty.$$
(Kiểm tra: khi $x\to1^-$, tử $\to2$, mẫu $x^2-1\to0^-$ nên $f\to-\infty$.)</p>
<p><b>b)</b> Vì $\lim_{x\to\pm\infty}f(x)=2$ nên $y=2$ là tiệm cận ngang. Vì $f(x)\to-\infty$ khi $x\to1^-$ và $x\to-1^+$ nên $x=1$ và $x=-1$ là các tiệm cận đứng.</p>
<p><b>Đáp số:</b> a) $2;\ 2;\ -\infty;\ -\infty$. b) tiệm cận ngang $y=2$; tiệm cận đứng $x=1$ và $x=-1$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.17.</b> Đường thẳng $x=1$ có phải là tiệm cận đứng của đồ thị hàm số $y=\dfrac{x^2+2x-3}{x-1}$ không?</p>', N'<p>Với $x\ne1$: $\dfrac{x^2+2x-3}{x-1}=\dfrac{(x-1)(x+3)}{x-1}=x+3$.</p>
<p>Do đó $\lim_{x\to1^+}y=\lim_{x\to1^-}y=1+3=4$, là một số hữu hạn, không phải $\pm\infty$. Vậy đường thẳng $x=1$ không là tiệm cận đứng của đồ thị (đồ thị chính là đường thẳng $y=x+3$ bỏ đi điểm $(1;4)$).</p>
<p><b>Đáp số:</b> Không.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.18.</b> Tìm các tiệm cận của đồ thị các hàm số sau:</p>
<ol type="a">
<li>$y=\dfrac{3-x}{2x+1}$;</li>
<li>$y=\dfrac{2x^2+x-1}{x+2}$.</li>
</ol>', N'<p><b>a)</b> $\lim_{x\to-\frac12^+}\dfrac{3-x}{2x+1}=+\infty$ (tử $\to\dfrac72\gt0$, mẫu $\to0^+$) và $\lim_{x\to-\frac12^-}y=-\infty$ nên $x=-\dfrac12$ là tiệm cận đứng. $\lim_{x\to\pm\infty}\dfrac{3-x}{2x+1}=-\dfrac12$ nên $y=-\dfrac12$ là tiệm cận ngang.</p>
<p><b>b)</b> $2x^2+x-1=(2x-1)(x+1)$ không triệt tiêu tại $x=-2$ (tử bằng $5$), và $\lim_{x\to-2^+}y=+\infty$, $\lim_{x\to-2^-}y=-\infty$ nên $x=-2$ là tiệm cận đứng. Chia đa thức: $y=2x-3+\dfrac5{x+2}$, mà $\lim_{x\to\pm\infty}\dfrac5{x+2}=0$ nên $y=2x-3$ là tiệm cận xiên. Không có tiệm cận ngang.</p>
<p><b>Đáp số:</b> a) tiệm cận đứng $x=-\dfrac12$, tiệm cận ngang $y=-\dfrac12$. b) tiệm cận đứng $x=-2$, tiệm cận xiên $y=2x-3$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.19.</b> Một công ty sản xuất đồ gia dụng ước tính chi phí để sản xuất $x$ (sản phẩm) là</p>
<p>$$C(x)=2x+50\ \text{(triệu đồng)}.$$</p>
<p>Khi đó $f(x)=\dfrac{C(x)}{x}$ là chi phí sản xuất trung bình cho mỗi sản phẩm. Chứng tỏ rằng hàm số $f(x)$ giảm và $\lim_{x\to+\infty}f(x)=2$. Tính chất này nói lên điều gì?</p>', N'<p>Với $x\gt0$: $f(x)=\dfrac{2x+50}{x}=2+\dfrac{50}{x}$.</p>
<p>$f''(x)=-\dfrac{50}{x^2}\lt0$ với mọi $x\gt0$ nên $f(x)$ giảm trên $(0;+\infty)$.</p>
<p>$\lim_{x\to+\infty}f(x)=\lim_{x\to+\infty}\left(2+\dfrac{50}{x}\right)=2$.</p>
<p><b>Ý nghĩa:</b> sản xuất càng nhiều sản phẩm thì chi phí trung bình cho mỗi sản phẩm càng giảm, và tiến dần đến 2 triệu đồng (không bao giờ thấp hơn mức này vì phần $50/x\gt0$). Đồ thị có tiệm cận ngang $y=2$.</p>
<p><b>Đáp số:</b> $f$ giảm, $\lim_{x\to+\infty}f(x)=2$: chi phí trung bình mỗi sản phẩm giảm dần và tiến tới 2 triệu đồng.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.20.</b> Một mảnh vườn hình chữ nhật có diện tích bằng 144 m$^2$. Biết độ dài một cạnh của mảnh vườn là $x$ (m).</p>
<ol type="a">
<li>Viết biểu thức tính chu vi $P(x)$ (mét) của mảnh vườn.</li>
<li>Tìm các tiệm cận của đồ thị hàm số $y=P(x)$. Giải thích ý nghĩa thực tiễn của các kết quả này.</li>
</ol>', N'<p>a) Cạnh còn lại dài $\dfrac{144}{x}$ (m) nên chu vi $P(x)=2\left(x+\dfrac{144}{x}\right)=2x+\dfrac{288}{x}$, $x\gt0$.</p>
<p>b) $\lim_{x\to0^+}P(x)=+\infty$ nên $x=0$ là tiệm cận đứng.</p>
<p>$\lim_{x\to+\infty}[P(x)-2x]=\lim_{x\to+\infty}\dfrac{288}{x}=0$ nên $y=2x$ là tiệm cận xiên (khi $x\to+\infty$). Không có tiệm cận ngang.</p>
<p><b>Ý nghĩa:</b> khi một cạnh rất ngắn ($x\to0^+$) thì cạnh kia rất dài nên chu vi tăng vô hạn; khi một cạnh rất dài thì cạnh kia rất ngắn, chu vi xấp xỉ $2x$, tức gần bằng hai lần cạnh dài.</p>
<p><b>Đáp số:</b> a) $P(x)=2x+\dfrac{288}{x}$; b) tiệm cận đứng $x=0$, tiệm cận xiên $y=2x$.</p>', 3, 0, 1, @t1);
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
INSERT INTO LessonMaterials (LessonId, MaterialType, Title, Url, ContentText, OrderIndex, CreatedBy) VALUES (@l, 'YOUTUBE', N'Video bài giảng: Bài 4. Khảo sát sự biến thiên và vẽ đồ thị của hàm số', 'https://www.youtube.com/watch?v=4mEcDhCFqcc', NULL, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.21.</b> Khảo sát sự biến thiên và vẽ đồ thị của các hàm số sau:</p>
<ol type="a">
<li>$y=-x^3+3x+1$;</li>
<li>$y=x^3+3x^2-x-1$.</li>
</ol>', N'<p><b>a) $y=-x^3+3x+1$.</b></p>
<ul><li>TXĐ: $\mathbb R$. $y''=-3x^2+3=0\Leftrightarrow x=\pm1$.</li>
<li>$y''\gt0$ trên $(-1;1)$: hàm đồng biến; $y''\lt0$ trên $(-\infty;-1)$ và $(1;+\infty)$: hàm nghịch biến.</li>
<li>Cực tiểu tại $x=-1$, $y_{CT}=-1$; cực đại tại $x=1$, $y_{CĐ}=3$.</li>
<li>Giới hạn: $x\to-\infty$ thì $y\to+\infty$; $x\to+\infty$ thì $y\to-\infty$.</li>
<li>Điểm uốn: $y''''=-6x=0\Rightarrow x=0$, điểm $(0;1)$. Đồ thị cắt Oy tại $(0;1)$, đi qua $(-1;-1)$, $(1;3)$, $(2;-1)$, $(-2;3)$.</li></ul>
<p><b>b) $y=x^3+3x^2-x-1$.</b></p>
<ul><li>TXĐ: $\mathbb R$. $y''=3x^2+6x-1=0\Leftrightarrow x=-1\pm\dfrac{2\sqrt3}{3}$ ($x\approx0{,}155$ hoặc $x\approx-2{,}155$).</li>
<li>$y''\gt0$ trên $(-\infty;-1-\tfrac{2\sqrt3}{3})$ và $(-1+\tfrac{2\sqrt3}{3};+\infty)$: đồng biến; $y''\lt0$ giữa hai nghiệm: nghịch biến.</li>
<li>Cực đại tại $x=-1-\tfrac{2\sqrt3}{3}$, $y\approx5{,}08$ (chính xác $2+\tfrac{16\sqrt3}{9}$); cực tiểu tại $x=-1+\tfrac{2\sqrt3}{3}$, $y\approx-1{,}08$ (chính xác $2-\tfrac{16\sqrt3}{9}$).</li>
<li>Giới hạn: $x\to-\infty$ thì $y\to-\infty$; $x\to+\infty$ thì $y\to+\infty$.</li>
<li>Điểm uốn: $y''''=6x+6=0\Rightarrow x=-1$, điểm $(-1;2)$. Cắt Oy tại $(0;-1)$; đi qua $(1;2)$, $(-3;2)$.</li></ul>
<p><b>Đáp số:</b> a) đồng biến trên $(-1;1)$, nghịch biến trên $(-\infty;-1)$, $(1;+\infty)$; CĐ $(1;3)$, CT $(-1;-1)$. b) đồng biến trên $(-\infty;-1-\tfrac{2\sqrt3}{3})$ và $(-1+\tfrac{2\sqrt3}{3};+\infty)$, nghịch biến ở giữa; CĐ $\left(-1-\tfrac{2\sqrt3}{3};2+\tfrac{16\sqrt3}{9}\right)$, CT $\left(-1+\tfrac{2\sqrt3}{3};2-\tfrac{16\sqrt3}{9}\right)$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.22.</b> Khảo sát sự biến thiên và vẽ đồ thị của các hàm số sau:</p>
<ol type="a">
<li>$y=\dfrac{2x+1}{x+1}$;</li>
<li>$y=\dfrac{x+3}{1-x}$.</li>
</ol>', N'<p><b>a) $y=\dfrac{2x+1}{x+1}=2-\dfrac{1}{x+1}$.</b></p>
<ul><li>TXĐ: $\mathbb R\setminus\{-1\}$. $y''=\dfrac{1}{(x+1)^2}\gt0$: hàm đồng biến trên $(-\infty;-1)$ và $(-1;+\infty)$, không có cực trị.</li>
<li>$\lim_{x\to\pm\infty}y=2$: tiệm cận ngang $y=2$. $\lim_{x\to-1^-}y=+\infty$, $\lim_{x\to-1^+}y=-\infty$: tiệm cận đứng $x=-1$.</li>
<li>Bảng biến thiên: trên $(-\infty;-1)$ y tăng từ 2 đến $+\infty$; trên $(-1;+\infty)$ y tăng từ $-\infty$ đến 2.</li>
<li>Đồ thị cắt Oy tại $(0;1)$, cắt Ox tại $(-\tfrac12;0)$; nhận $I(-1;2)$ làm tâm đối xứng.</li></ul>
<p><b>b) $y=\dfrac{x+3}{1-x}=-1+\dfrac{4}{1-x}$.</b></p>
<ul><li>TXĐ: $\mathbb R\setminus\{1\}$. $y''=\dfrac{4}{(1-x)^2}\gt0$: đồng biến trên $(-\infty;1)$ và $(1;+\infty)$, không có cực trị.</li>
<li>$\lim_{x\to\pm\infty}y=-1$: tiệm cận ngang $y=-1$. $\lim_{x\to1^-}y=+\infty$, $\lim_{x\to1^+}y=-\infty$: tiệm cận đứng $x=1$.</li>
<li>Đồ thị cắt Oy tại $(0;3)$, cắt Ox tại $(-3;0)$; tâm đối xứng $I(1;-1)$.</li></ul>
<p><b>Đáp số:</b> cả hai hàm đều đồng biến trên từng khoảng xác định, không có cực trị; a) TCĐ $x=-1$, TCN $y=2$; b) TCĐ $x=1$, TCN $y=-1$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.23.</b> Khảo sát sự biến thiên và vẽ đồ thị của các hàm số sau:</p>
<ol type="a">
<li>$y=\dfrac{2x^2-x+4}{x-1}$;</li>
<li>$y=\dfrac{x^2+2x+1}{x+3}$.</li>
</ol>', N'<p><b>a) $y=\dfrac{2x^2-x+4}{x-1}=2x+1+\dfrac{5}{x-1}$.</b></p>
<ul><li>TXĐ: $\mathbb R\setminus\{1\}$. $y''=2-\dfrac{5}{(x-1)^2}=0\Leftrightarrow x=1\pm\dfrac{\sqrt{10}}{2}$ ($x\approx2{,}58$ hoặc $x\approx-0{,}58$).</li>
<li>$y''\gt0$ trên $(-\infty;1-\tfrac{\sqrt{10}}2)$ và $(1+\tfrac{\sqrt{10}}2;+\infty)$: đồng biến; $y''\lt0$ trên $(1-\tfrac{\sqrt{10}}2;1)$ và $(1;1+\tfrac{\sqrt{10}}2)$: nghịch biến.</li>
<li>Cực đại tại $x=1-\tfrac{\sqrt{10}}2$, $y=3-2\sqrt{10}\approx-3{,}32$; cực tiểu tại $x=1+\tfrac{\sqrt{10}}2$, $y=3+2\sqrt{10}\approx9{,}32$.</li>
<li>Tiệm cận đứng $x=1$ ($\lim_{x\to1^-}y=-\infty$, $\lim_{x\to1^+}y=+\infty$); tiệm cận xiên $y=2x+1$.</li>
<li>Đồ thị cắt Oy tại $(0;-4)$, không cắt Ox (vì $2x^2-x+4\gt0$).</li></ul>
<p><b>b) $y=\dfrac{x^2+2x+1}{x+3}=x-1+\dfrac{4}{x+3}$.</b></p>
<ul><li>TXĐ: $\mathbb R\setminus\{-3\}$. $y''=1-\dfrac{4}{(x+3)^2}=0\Leftrightarrow x=-1$ hoặc $x=-5$.</li>
<li>Đồng biến trên $(-\infty;-5)$ và $(-1;+\infty)$; nghịch biến trên $(-5;-3)$ và $(-3;-1)$.</li>
<li>Cực đại tại $x=-5$, $y=-8$; cực tiểu tại $x=-1$, $y=0$.</li>
<li>Tiệm cận đứng $x=-3$; tiệm cận xiên $y=x-1$.</li>
<li>Đồ thị cắt Oy tại $(0;\tfrac13)$, tiếp xúc Ox tại $(-1;0)$.</li></ul>
<p><b>Đáp số:</b> a) CĐ $(1-\tfrac{\sqrt{10}}2;3-2\sqrt{10})$, CT $(1+\tfrac{\sqrt{10}}2;3+2\sqrt{10})$, TCĐ $x=1$, TCX $y=2x+1$. b) CĐ $(-5;-8)$, CT $(-1;0)$, TCĐ $x=-3$, TCX $y=x-1$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.24.</b> Một cốc chứa 30 ml dung dịch KOH (potassium hydroxide) với nồng độ 100 mg/ml. Một bình chứa dung dịch KOH khác với nồng độ 8 mg/ml được trộn vào cốc.</p>
<ol type="a">
<li>Tính nồng độ KOH trong cốc sau khi trộn $x$ (ml) từ bình chứa, kí hiệu là $C(x)$.</li>
<li>Coi $C(x)$ là hàm số xác định với $x\ge0$. Khảo sát sự biến thiên và vẽ đồ thị của hàm số này.</li>
<li>Giải thích tại sao nồng độ KOH trong cốc giảm theo $x$ nhưng luôn lớn hơn 8 mg/ml.</li>
</ol>', N'<p>a) Lượng KOH ban đầu: $30\cdot100=3000$ mg; lượng thêm vào: $8x$ mg; thể tích dung dịch: $30+x$ ml. Vậy
$$C(x)=\dfrac{3000+8x}{30+x}\ \text{(mg/ml)}.$$</p>
<p>b) $C(x)=8+\dfrac{2760}{x+30}$, $x\ge0$.</p>
<ul><li>$C''(x)=-\dfrac{2760}{(x+30)^2}\lt0$ nên $C$ nghịch biến trên $[0;+\infty)$.</li>
<li>$C(0)=100$; $\lim_{x\to+\infty}C(x)=8$: tiệm cận ngang $y=8$.</li>
<li>Đồ thị là một nhánh hypebol xuất phát từ $(0;100)$, đi xuống và tiến dần đến đường $y=8$ (ví dụ $C(30)=54$, $C(90)=\tfrac{3720}{120}=31$).</li></ul>
<p>c) Vì $C$ nghịch biến nên nồng độ giảm khi $x$ tăng. Vì $\dfrac{2760}{x+30}\gt0$ nên $C(x)\gt8$ với mọi $x$. Về thực tế: ta trộn dung dịch 100 mg/ml với dung dịch loãng hơn 8 mg/ml nên nồng độ hỗn hợp giảm dần nhưng chỉ tiến tới 8 mg/ml, không thể thấp hơn nồng độ của dung dịch được thêm vào.</p>
<p><b>Đáp số:</b> a) $C(x)=\dfrac{3000+8x}{30+x}$; b) $C$ nghịch biến trên $[0;+\infty)$, TCN $y=8$; c) $C(x)=8+\dfrac{2760}{x+30}\gt8$ và giảm.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.25.</b> Trong Vật lí, ta biết rằng khi mắc song song hai điện trở $R_1$ và $R_2$ thì điện trở tương đương $R$ của mạch điện được tính theo công thức $R=\dfrac{R_1R_2}{R_1+R_2}$ (theo <i>Vật lí đại cương</i>, NXB Giáo dục Việt Nam, 2016).</p>
<p>Giả sử một điện trở 8 $\Omega$ được mắc song song với một biến trở như Hình 1.33. Nếu biến trở đó được kí hiệu là $x$ ($\Omega$) thì điện trở tương đương $R$ là hàm số của $x$. Vẽ đồ thị của hàm số $y=R(x)$, $x>0$ và dựa vào đồ thị đã vẽ để trả lời các câu hỏi sau:</p>
<ol type="a">
<li>Điện trở tương đương của mạch thay đổi thế nào khi $x$ tăng?</li>
<li>Tại sao điện trở tương đương của mạch không bao giờ vượt quá 8 $\Omega$?</li>
</ol>
<div><img src="/static/img/sgk/hinh-1-33.png" alt="Hình minh họa bài 1.25 (SGK)"></div>', N'<p>Với $R_1=8$, $R_2=x$: $R(x)=\dfrac{8x}{8+x}=8-\dfrac{64}{x+8}$, $x\gt0$.</p>
<ul><li>$R''(x)=\dfrac{64}{(x+8)^2}\gt0$ nên $R$ đồng biến trên $(0;+\infty)$.</li>
<li>$R(0)=0$ (giá trị giới hạn khi $x\to0^+$); $\lim_{x\to+\infty}R(x)=8$: tiệm cận ngang $y=8$.</li>
<li>Một số điểm: $R(8)=4$, $R(24)=6$. Đồ thị là một nhánh hypebol đi lên từ gốc toạ độ, tiến dần tới đường $y=8$.</li></ul>
<p>a) Khi $x$ tăng thì điện trở tương đương $R$ tăng (nhưng tăng chậm dần và tiến tới 8 $\Omega$).</p>
<p>b) $R(x)=8-\dfrac{64}{x+8}\lt8$ với mọi $x\gt0$; đồ thị luôn nằm dưới tiệm cận ngang $y=8$. Về vật lí: mắc song song thì điện trở tương đương luôn nhỏ hơn mỗi điện trở thành phần, nên không vượt quá điện trở 8 $\Omega$.</p>
<p><b>Đáp số:</b> $R(x)=\dfrac{8x}{x+8}$; a) $R$ tăng khi $x$ tăng; b) $R\lt8$ vì $R=8-\dfrac{64}{x+8}$.</p>', 3, 0, 1, @t1);
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
INSERT INTO LessonMaterials (LessonId, MaterialType, Title, Url, ContentText, OrderIndex, CreatedBy) VALUES (@l, 'YOUTUBE', N'Video bài giảng: Bài 5. Ứng dụng đạo hàm để giải quyết một số vấn đề liên quan đến thực tiễn', 'https://www.youtube.com/watch?v=_3jvMW3Swhc', NULL, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.26.</b> Giả sử một hạt chuyển động trên một trục thẳng đứng chiều dương hướng lên trên sao cho toạ độ của hạt (đơn vị: mét) tại thời điểm $t$ (giây) là $y=t^3-12t+3$, $t\ge0$.</p>
<ol type="a">
<li>Tìm các hàm vận tốc và gia tốc.</li>
<li>Khi nào thì hạt chuyển động lên trên và khi nào thì hạt chuyển động xuống dưới?</li>
<li>Tìm quãng đường hạt đi được trong khoảng thời gian $0\le t\le3$.</li>
<li>Khi nào hạt tăng tốc? Khi nào hạt giảm tốc?</li>
</ol>', N'<p>a) Vận tốc $v(t)=y''=3t^2-12$ (m/s); gia tốc $a(t)=v''=6t$ (m/s$^2$).</p>
<p>b) $v(t)=0\Leftrightarrow t=2$ (với $t\ge0$). Hạt đi lên khi $v\gt0$, tức $t\gt2$; hạt đi xuống khi $v\lt0$, tức $0\lt t\lt2$.</p>
<p>c) $y(0)=3$, $y(2)=8-24+3=-13$, $y(3)=27-36+3=-6$. Trên $[0;2]$ hạt đi xuống quãng $|{-13}-3|=16$ m; trên $[2;3]$ hạt đi lên quãng $|{-6}-(-13)|=7$ m. Quãng đường: $16+7=23$ m.</p>
<p>d) Hạt tăng tốc khi $v$ và $a$ cùng dấu; giảm tốc khi trái dấu. Với $t\gt0$ ta có $a\gt0$. Với $t\gt2$: $v\gt0$ nên tăng tốc; với $0\lt t\lt2$: $v\lt0$ nên giảm tốc.</p>
<p><b>Đáp số:</b> a) $v=3t^2-12$, $a=6t$; b) lên khi $t\gt2$, xuống khi $0\lt t\lt2$; c) 23 m; d) tăng tốc khi $t\gt2$, giảm tốc khi $0\lt t\lt2$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.27.</b> Giả sử chi phí (tính bằng trăm nghìn đồng) để sản xuất $x$ đơn vị hàng hoá nào đó là:</p>
<p>$$C(x)=23\,000+50x-0,5x^2+0,00175x^3.$$</p>
<ol type="a">
<li>Tìm hàm chi phí biên.</li>
<li>Tìm $C''(100)$ và giải thích ý nghĩa của nó.</li>
<li>So sánh $C''(100)$ với chi phí sản xuất đơn vị hàng hoá thứ 101.</li>
</ol>', N'<p>a) Hàm chi phí biên: $C''(x)=50-x+0{,}00525x^2$ (trăm nghìn đồng/đơn vị).</p>
<p>b) $C''(100)=50-100+0{,}00525\cdot10000=50-100+52{,}5=2{,}5$.</p>
<p><b>Ý nghĩa:</b> khi đã sản xuất 100 đơn vị, chi phí để sản xuất thêm một đơn vị hàng nữa xấp xỉ 2,5 trăm nghìn đồng (250 nghìn đồng).</p>
<p>c) Chi phí sản xuất đơn vị thứ 101 là
$C(101)-C(100)=50(1)-0{,}5(101^2-100^2)+0{,}00175(101^3-100^3)=50-100{,}5+0{,}00175\cdot30301=2{,}52675$ (trăm nghìn đồng).</p>
<p>Vậy $C''(100)=2{,}5$ xấp xỉ $2{,}52675$; chênh lệch chỉ khoảng $0{,}027$, nên $C''(100)$ là giá trị gần đúng tốt của chi phí đơn vị thứ 101 (hơi nhỏ hơn).</p>
<p><b>Đáp số:</b> a) $C''(x)=50-x+0{,}00525x^2$; b) $C''(100)=2{,}5$; c) $C(101)-C(100)=2{,}52675\approx C''(100)$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.28.</b> Người quản lí của một khu chung cư có 100 căn hộ cho thuê nhận thấy rằng tất cả các căn hộ sẽ có người thuê nếu giá thuê một căn hộ là 8 triệu đồng một tháng. Một cuộc khảo sát thị trường cho thấy rằng, trung bình cứ mỗi lần tăng giá thuê căn hộ thêm 100 nghìn đồng thì sẽ có thêm một căn hộ bị bỏ trống. Người quản lí nên đặt giá thuê mỗi căn hộ là bao nhiêu để doanh thu là lớn nhất?</p>', N'<p>Gọi $k$ ($0\le k\le100$, nguyên) là số lần tăng giá 100 nghìn đồng. Khi đó giá thuê là $8+0{,}1k$ (triệu đồng) và số căn hộ được thuê là $100-k$.</p>
<p>Doanh thu mỗi tháng: $R(k)=(8+0{,}1k)(100-k)=800+2k-0{,}1k^2$ (triệu đồng).</p>
<p>$R''(k)=2-0{,}2k=0\Leftrightarrow k=10$. Vì $R''''=-0{,}2\lt0$ (parabol quay xuống) nên $R$ đạt lớn nhất tại $k=10$: $R(10)=800+20-10=810$.</p>
<p>Khi đó giá thuê là $8+0{,}1\cdot10=9$ triệu đồng, có 90 căn hộ được thuê.</p>
<p><b>Đáp số:</b> đặt giá 9 triệu đồng/căn hộ/tháng, doanh thu lớn nhất 810 triệu đồng/tháng.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.29.</b> Giả sử hàm cầu đối với một loại hàng hoá được cho bởi công thức</p>
<p>$$p=\dfrac{354}{1+0,01x},\ x\ge0,$$</p>
<p>trong đó $p$ là giá bán (nghìn đồng) của mỗi đơn vị sản phẩm và $x$ là số lượng đơn vị sản phẩm đã bán.</p>
<ol type="a">
<li>Tìm công thức tính $x$ như là hàm số của $p$. Tìm tập xác định của hàm số này. Tính số đơn vị sản phẩm đã bán khi giá bán của mỗi đơn vị sản phẩm là 240 nghìn đồng.</li>
<li>Khảo sát sự biến thiên và vẽ đồ thị của hàm số $x=x(p)$. Từ đồ thị đã vẽ, hãy cho biết:
<ul><li>Số lượng đơn vị sản phẩm bán được sẽ thay đổi thế nào khi giá bán $p$ tăng;</li>
<li>Ý nghĩa thực tiễn của giới hạn $\lim_{p\to0^+}x(p)$.</li></ul></li>
</ol>', N'<p>a) $p(1+0{,}01x)=354\Rightarrow 1+0{,}01x=\dfrac{354}{p}\Rightarrow x=\dfrac{354}{0{,}01p}-\dfrac{1}{0{,}01}=\dfrac{35400}{p}-100$.</p>
<p>Điều kiện: $p\gt0$ và $x\ge0\Leftrightarrow p\le354$. Tập xác định: $(0;354]$.</p>
<p>Khi $p=240$: $x=\dfrac{35400}{240}-100=147{,}5-100=47{,}5$ (đơn vị sản phẩm).</p>
<p>b) $x(p)=\dfrac{35400}{p}-100$ trên $(0;354]$.</p>
<ul><li>$x''(p)=-\dfrac{35400}{p^2}\lt0$ nên $x$ nghịch biến trên $(0;354]$.</li>
<li>$\lim_{p\to0^+}x(p)=+\infty$ (tiệm cận đứng $p=0$); $x(354)=0$.</li>
<li>Đồ thị là một phần nhánh hypebol đi từ rất cao (gần trục tung) xuống điểm $(354;0)$.</li></ul>
<p>Từ đồ thị: khi giá bán $p$ tăng thì số lượng sản phẩm bán được giảm. Giới hạn $\lim_{p\to0^+}x(p)=+\infty$ cho biết: nếu giá bán càng gần 0 (gần như cho không) thì nhu cầu (số lượng bán được) tăng lên rất lớn, vô hạn.</p>
<p><b>Đáp số:</b> a) $x=\dfrac{35400}{p}-100$, TXĐ $(0;354]$, $x(240)=47{,}5$; b) $x$ nghịch biến, giá tăng thì lượng bán giảm; $\lim_{p\to0^+}x=+\infty$.</p>', 3, 0, 1, @t1);
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
</ol>', N'<p><b>a)</b> $y''=3x^2-6x+3=3(x-1)^2\ge0$, bằng 0 chỉ tại $x=1$. Hàm đồng biến trên $\mathbb R$, không có cực trị.</p>
<p><b>b)</b> $y''=4x^3-4x=4x(x-1)(x+1)$, có nghiệm $x=-1,0,1$. Hàm nghịch biến trên $(-\infty;-1)$ và $(0;1)$; đồng biến trên $(-1;0)$ và $(1;+\infty)$. Cực đại tại $x=0$, $y_{CĐ}=-1$; cực tiểu tại $x=\pm1$, $y_{CT}=-2$.</p>
<p><b>c)</b> TXĐ $\mathbb R\setminus\{-\tfrac13\}$. $y''=\dfrac{2\cdot1-(-1)\cdot3}{(3x+1)^2}=\dfrac{5}{(3x+1)^2}\gt0$. Hàm đồng biến trên $(-\infty;-\tfrac13)$ và $(-\tfrac13;+\infty)$, không có cực trị.</p>
<p><b>d)</b> $y=x+1+\dfrac{1}{x+1}$, TXĐ $\mathbb R\setminus\{-1\}$. $y''=1-\dfrac{1}{(x+1)^2}=\dfrac{x(x+2)}{(x+1)^2}$, có nghiệm $x=0$, $x=-2$. Đồng biến trên $(-\infty;-2)$ và $(0;+\infty)$; nghịch biến trên $(-2;-1)$ và $(-1;0)$. Cực đại tại $x=-2$, $y=-2$; cực tiểu tại $x=0$, $y=2$.</p>
<p><b>Đáp số:</b> a) đồng biến trên $\mathbb R$, không cực trị; b) CĐ $(0;-1)$, CT $(\pm1;-2)$; c) đồng biến trên từng khoảng xác định, không cực trị; d) CĐ $(-2;-2)$, CT $(0;2)$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.41.</b> Tìm giá trị lớn nhất và giá trị nhỏ nhất (nếu có) của các hàm số sau:</p>
<ol type="a">
<li>$y=\dfrac{2x+1}{3x-2}$ trên nửa khoảng $[2;+\infty)$;</li>
<li>$y=\sqrt{2-x^2}$.</li>
</ol>', N'<p><b>a)</b> $y=\dfrac{2x+1}{3x-2}$ trên $[2;+\infty)$. $y''=\dfrac{2(-2)-1\cdot3}{(3x-2)^2}=\dfrac{-7}{(3x-2)^2}\lt0$ nên hàm nghịch biến trên $[2;+\infty)$.</p>
<p>Do đó giá trị lớn nhất là $y(2)=\dfrac{5}{4}$. Mặt khác $\lim_{x\to+\infty}y=\dfrac23$ và $y\gt\dfrac23$ với mọi $x\ge2$ (vì $y-\tfrac23=\tfrac{7}{3(3x-2)}\gt0$), nên $y$ tiến gần $\tfrac23$ nhưng không đạt được: hàm không có giá trị nhỏ nhất.</p>
<p><b>b)</b> $y=\sqrt{2-x^2}$ xác định trên $[-\sqrt2;\sqrt2]$. Vì $0\le2-x^2\le2$ nên $0\le y\le\sqrt2$. $y=\sqrt2$ khi $x=0$; $y=0$ khi $x=\pm\sqrt2$.</p>
<p><b>Đáp số:</b> a) $\max y=\dfrac54$ tại $x=2$, không có giá trị nhỏ nhất; b) $\max y=\sqrt2$ (tại $x=0$), $\min y=0$ (tại $x=\pm\sqrt2$).</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.42.</b> Tìm các tiệm cận của đồ thị các hàm số sau:</p>
<ol type="a">
<li>$y=\dfrac{3x-2}{x+1}$;</li>
<li>$y=\dfrac{x^2+2x-1}{2x-1}$.</li>
</ol>', N'<p><b>a)</b> $y=\dfrac{3x-2}{x+1}$. $\lim_{x\to\pm\infty}y=3$ nên TCN: $y=3$. $\lim_{x\to-1^-}y=+\infty$ (tử $\to-5$, mẫu $\to0^-$), $\lim_{x\to-1^+}y=-\infty$ nên TCĐ: $x=-1$.</p>
<p><b>b)</b> $y=\dfrac{x^2+2x-1}{2x-1}=\dfrac x2+\dfrac54+\dfrac{1}{4(2x-1)}$.</p>
<p>Tại $x=\tfrac12$: tử $=\tfrac14+1-1=\tfrac14\ne0$, mẫu $\to0$ nên $\lim_{x\to\frac12^\pm}y=\pm\infty$: TCĐ $x=\tfrac12$.</p>
<p>$\lim_{x\to\pm\infty}\left[y-\left(\dfrac x2+\dfrac54\right)\right]=\lim\dfrac{1}{4(2x-1)}=0$ nên TCX: $y=\dfrac x2+\dfrac54$. Không có TCN.</p>
<p><b>Đáp số:</b> a) TCĐ $x=-1$, TCN $y=3$; b) TCĐ $x=\dfrac12$, TCX $y=\dfrac x2+\dfrac54$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.43.</b> Khảo sát sự biến thiên và vẽ đồ thị của các hàm số sau:</p>
<ol type="a">
<li>$y=-x^3+6x^2-9x+12$;</li>
<li>$y=\dfrac{2x-1}{x+1}$;</li>
<li>$y=\dfrac{x^2-2x}{x-1}$.</li>
</ol>', N'<p><b>a) $y=-x^3+6x^2-9x+12$.</b></p>
<ul><li>TXĐ $\mathbb R$. $y''=-3x^2+12x-9=-3(x-1)(x-3)$; $y''=0\Leftrightarrow x=1$ hoặc $x=3$.</li>
<li>Nghịch biến trên $(-\infty;1)$ và $(3;+\infty)$; đồng biến trên $(1;3)$. Cực tiểu $(1;8)$, cực đại $(3;12)$.</li>
<li>$x\to-\infty$: $y\to+\infty$; $x\to+\infty$: $y\to-\infty$.</li>
<li>$y''''=-6x+12=0\Rightarrow x=2$, điểm uốn $(2;10)$. Cắt Oy tại $(0;12)$; đi qua $(4;8)$.</li></ul>
<p><b>b) $y=\dfrac{2x-1}{x+1}=2-\dfrac{3}{x+1}$.</b></p>
<ul><li>TXĐ $\mathbb R\setminus\{-1\}$. $y''=\dfrac{3}{(x+1)^2}\gt0$: đồng biến trên từng khoảng $(-\infty;-1)$, $(-1;+\infty)$, không cực trị.</li>
<li>TCN $y=2$; TCĐ $x=-1$.</li>
<li>Cắt Oy tại $(0;-1)$, cắt Ox tại $(\tfrac12;0)$; tâm đối xứng $(-1;2)$.</li></ul>
<p><b>c) $y=\dfrac{x^2-2x}{x-1}=x-1-\dfrac{1}{x-1}$.</b></p>
<ul><li>TXĐ $\mathbb R\setminus\{1\}$. $y''=1+\dfrac{1}{(x-1)^2}\gt0$: đồng biến trên $(-\infty;1)$ và $(1;+\infty)$, không cực trị.</li>
<li>TCĐ $x=1$ ($\lim_{x\to1^-}y=+\infty$, $\lim_{x\to1^+}y=-\infty$); TCX $y=x-1$.</li>
<li>Cắt Ox tại $(0;0)$ và $(2;0)$; đi qua gốc toạ độ; tâm đối xứng $(1;0)$.</li></ul>
<p><b>Đáp số:</b> a) CT $(1;8)$, CĐ $(3;12)$; b) đồng biến, TCĐ $x=-1$, TCN $y=2$; c) đồng biến, TCĐ $x=1$, TCX $y=x-1$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.44.</b> Xét một thấu kính hội tụ có tiêu cự $f$ (H.1.39). Khoảng cách $p$ từ vật đến thấu kính liên hệ với khoảng cách $q$ từ ảnh đến thấu kính bởi hệ thức:</p>
<p>$$\dfrac{1}{p}+\dfrac{1}{q}=\dfrac{1}{f}.$$</p>
<ol type="a">
<li>Viết công thức tính $q=g(p)$ như một hàm số của biến $p\in(f;+\infty)$.</li>
<li>Tính các giới hạn $\lim_{p\to+\infty}g(p)$; $\lim_{p\to f^+}g(p)$ và giải thích ý nghĩa các kết quả này.</li>
<li>Lập bảng biến thiên của hàm số $q=g(p)$ trên khoảng $(f;+\infty)$.</li>
</ol>
<div><img src="/static/img/sgk/hinh-1-39.png" alt="Hình minh họa bài 1.44 (SGK)"></div>', N'<p>a) Từ $\dfrac1q=\dfrac1f-\dfrac1p=\dfrac{p-f}{pf}$ suy ra $q=g(p)=\dfrac{pf}{p-f}$, $p\gt f$.</p>
<p>b) $g(p)=f+\dfrac{f^2}{p-f}$.</p>
<ul><li>$\lim_{p\to+\infty}g(p)=f$: khi vật ở rất xa thấu kính thì ảnh nằm gần tiêu điểm (cách thấu kính khoảng xấp xỉ $f$). Đồ thị có tiệm cận ngang $q=f$.</li>
<li>$\lim_{p\to f^+}g(p)=+\infty$: khi vật tiến gần tới tiêu điểm thì ảnh ở rất xa thấu kính. Đồ thị có tiệm cận đứng $p=f$.</li></ul>
<p>c) $g''(p)=-\dfrac{f^2}{(p-f)^2}\lt0$ trên $(f;+\infty)$ nên hàm nghịch biến.</p>
<p>Bảng biến thiên: $p$ chạy từ $f$ đến $+\infty$; $q$ giảm từ $+\infty$ xuống $f$.</p>
<p><b>Đáp số:</b> a) $q=\dfrac{pf}{p-f}$; b) $\lim_{p\to+\infty}q=f$, $\lim_{p\to f^+}q=+\infty$; c) $q$ nghịch biến trên $(f;+\infty)$, giảm từ $+\infty$ về $f$.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.45.</b> Dân số của một quốc gia sau $t$ (năm) kể từ năm 2023 được ước tính bởi công thức:</p>
<p>$$N(t)=100e^{0,012t}\ (N(t)\text{ được tính bằng triệu người},\ 0\le t\le50).$$</p>
<ol type="a">
<li>Ước tính dân số của quốc gia này vào các năm 2030 và 2035 (kết quả tính bằng triệu người, làm tròn kết quả đến chữ số thập phân thứ ba).</li>
<li>Xem $N(t)$ là hàm số của biến số $t$ xác định trên đoạn $[0;50]$. Xét chiều biến thiên của hàm số $N(t)$ trên đoạn $[0;50]$.</li>
<li>Đạo hàm của hàm số $N(t)$ biểu thị tốc độ tăng dân số của quốc gia đó (tính bằng triệu người/năm). Vào năm nào tốc độ tăng dân số của quốc gia đó là 1,6 triệu người/năm?</li>
</ol>', N'<p>a) Năm 2030: $t=7$, $N(7)=100e^{0{,}084}\approx108{,}763$ (triệu người). Năm 2035: $t=12$, $N(12)=100e^{0{,}144}\approx115{,}488$ (triệu người).</p>
<p>b) $N''(t)=1{,}2e^{0{,}012t}\gt0$ với mọi $t$ nên $N(t)$ đồng biến trên $[0;50]$ (dân số tăng).</p>
<p>c) $N''(t)=1{,}6\Leftrightarrow e^{0{,}012t}=\dfrac{4}{3}\Leftrightarrow t=\dfrac{\ln(4/3)}{0{,}012}\approx23{,}97$. Thuộc đoạn $[0;50]$, tức khoảng 24 năm sau 2023, vào năm 2047.</p>
<p><b>Đáp số:</b> a) $\approx108{,}763$ và $\approx115{,}488$ triệu người; b) đồng biến trên $[0;50]$; c) $t\approx24$, tức khoảng năm 2047.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.46.</b> Một đường dây điện được nối từ một nhà máy điện ở $A$ đến một hòn đảo ở $C$ như Hình 1.40. Khoảng cách từ $C$ đến $B$ là 4 km. Bờ biển chạy thẳng từ $A$ đến $B$ với khoảng cách là 10 km. Tổng chi phí lắp đặt cho 1 km dây điện trên biển là 50 triệu đồng, còn trên đất liền là 30 triệu đồng. Xác định vị trí điểm $M$ trên đoạn $AB$ (điểm nối dây từ đất liền ra đảo) để tổng chi phí lắp đặt là nhỏ nhất.</p>
<div><img src="/static/img/sgk/hinh-1-40.png" alt="Hình minh họa bài 1.46 (SGK)"></div>', N'<p>Đặt $AM=x$ (km), $0\le x\le10$. Khi đó $MB=10-x$ và $MC=\sqrt{4^2+(10-x)^2}=\sqrt{x^2-20x+116}$ (tam giác $MBC$ vuông tại $B$).</p>
<p>Tổng chi phí (triệu đồng): $f(x)=30x+50\sqrt{x^2-20x+116}$.</p>
<p>$f''(x)=30+\dfrac{50(x-10)}{\sqrt{x^2-20x+116}}=0\Leftrightarrow 5(10-x)=3\sqrt{(10-x)^2+16}$.</p>
<p>Với $u=10-x\ge0$: $25u^2=9u^2+144\Rightarrow u^2=9\Rightarrow u=3$, tức $x=7$.</p>
<p>So sánh: $f(0)=50\sqrt{116}\approx538{,}5$; $f(7)=210+50\cdot5=460$; $f(10)=300+200=500$. Giá trị nhỏ nhất là $f(7)=460$.</p>
<p><b>Đáp số:</b> đặt M cách A 7 km (cách B 3 km); tổng chi phí nhỏ nhất là 460 triệu đồng.</p>', 3, 0, 1, @t1);

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
INSERT INTO LessonMaterials (LessonId, MaterialType, Title, Url, ContentText, OrderIndex, CreatedBy) VALUES (@l, 'YOUTUBE', N'Video bài giảng: Bài 6. Vectơ trong không gian', 'https://www.youtube.com/watch?v=tFmRxrIzfDg', NULL, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.1.</b> Trong không gian, cho ba vectơ $\vec{a}$, $\vec{b}$, $\vec{c}$ phân biệt và đều khác $\vec{0}$. Những mệnh đề nào sau đây là đúng?</p>
<ol type="a">
<li>Nếu $\vec{a}$ và $\vec{b}$ đều cùng hướng với $\vec{c}$ thì $\vec{a}$ và $\vec{b}$ cùng hướng.</li>
<li>Nếu $\vec{a}$ và $\vec{b}$ đều ngược hướng với $\vec{c}$ thì $\vec{a}$ và $\vec{b}$ cùng hướng.</li>
<li>Nếu $\vec{a}$ và $\vec{b}$ đều cùng hướng với $\vec{c}$ thì $\vec{a}$ và $\vec{b}$ ngược hướng.</li>
<li>Nếu $\vec{a}$ và $\vec{b}$ đều ngược hướng với $\vec{c}$ thì $\vec{a}$ và $\vec{b}$ ngược hướng.</li>
</ol>', N'<p>Dùng tính chất: hai vectơ cùng hướng với một vectơ thứ ba (khác $\vec{0}$) thì cùng hướng với nhau; hai vectơ cùng ngược hướng với vectơ thứ ba thì cũng cùng hướng với nhau (cùng phương và cùng chiều với $-\vec{c}$).</p>
<ul><li>a) Đúng: $\vec{a}$, $\vec{b}$ cùng hướng với $\vec{c}$ nên cùng phương và cùng chiều với $\vec{c}$, do đó cùng hướng với nhau.</li>
<li>b) Đúng: $\vec{a}$, $\vec{b}$ đều ngược hướng với $\vec{c}$ nên cả hai cùng hướng với $-\vec{c}$, suy ra $\vec{a}$ và $\vec{b}$ cùng hướng.</li>
<li>c) Sai, vì theo a) chúng cùng hướng.</li>
<li>d) Sai, vì theo b) chúng cùng hướng.</li></ul>
<p><b>Đáp số:</b> các mệnh đề đúng là a) và b).</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.2.</b> Cho hình hộp chữ nhật $ABCD.A''B''C''D''$ có $AB=2$, $AD=3$ và $AA''=4$. Tính độ dài của các vectơ $\overrightarrow{BB''}$, $\overrightarrow{BD}$ và $\overrightarrow{BD''}$.</p>', N'<p>Hình hộp chữ nhật nên $AB$, $AD$, $AA''$ đôi một vuông góc; $BB''=AA''$.</p>
<ul><li>$|\overrightarrow{BB''}|=BB''=AA''=4$.</li>
<li>$ABCD$ là hình chữ nhật: $BD=\sqrt{AB^2+AD^2}=\sqrt{4+9}=\sqrt{13}$.</li>
<li>$DD''\perp(ABCD)$ nên $DD''\perp BD$, do đó $BD''^2=BD^2+DD''^2$: $BD''=\sqrt{13+16}=\sqrt{29}$.</li></ul>
<p><b>Đáp số:</b> $|\overrightarrow{BB''}|=4$, $|\overrightarrow{BD}|=\sqrt{13}$, $|\overrightarrow{BD''}|=\sqrt{29}$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.3.</b> Một chiếc bàn cân đối hình chữ nhật được đặt trên mặt sàn nằm ngang, mặt bàn song song với mặt sàn và bốn chân bàn vuông góc với mặt sàn như Hình 2.29. Trọng lực tác dụng lên bàn (biểu thị bởi vectơ $\vec{a}$) phân tán đều qua bốn chân bàn và gây nên các phản lực từ mặt sàn lên các chân bàn (biểu thị bởi các vectơ $\vec{b}$, $\vec{c}$, $\vec{d}$, $\vec{e}$). <div><img src="/static/img/sgk/hinh-2-29.png" alt="Hình minh họa bài 2.3 (SGK)"></div></p>
<ol type="a">
<li>Hãy chỉ ra mối quan hệ về phương và hướng của các vectơ $\vec{a}$, $\vec{b}$, $\vec{c}$, $\vec{d}$ và $\vec{e}$.</li>
<li>Giải thích vì sao các vectơ $\vec{b}$, $\vec{c}$, $\vec{d}$, $\vec{e}$ đôi một bằng nhau.</li>
</ol>', N'<p>a) Trọng lực $\vec{a}$ hướng thẳng đứng xuống dưới; các chân bàn vuông góc với sàn nên các phản lực $\vec{b}$, $\vec{c}$, $\vec{d}$, $\vec{e}$ cũng có phương thẳng đứng. Vậy cả năm vectơ cùng phương (song song với nhau). Trong đó $\vec{b}$, $\vec{c}$, $\vec{d}$, $\vec{e}$ cùng hướng (thẳng đứng lên trên), còn $\vec{a}$ ngược hướng với từng vectơ đó.</p>
<p>b) Bàn cân đối, hình chữ nhật nên trọng lực phân tán đều qua bốn chân: mỗi chân chịu một lực có độ lớn như nhau. Vậy $\vec{b}$, $\vec{c}$, $\vec{d}$, $\vec{e}$ có cùng độ lớn, và theo câu a) chúng cùng hướng. Hai vectơ cùng hướng và cùng độ dài thì bằng nhau, nên $\vec{b}=\vec{c}=\vec{d}=\vec{e}$. (Bàn đứng yên nên $\vec{a}+\vec{b}+\vec{c}+\vec{d}+\vec{e}=\vec{0}$, tức $|\vec{a}|=4|\vec{b}|$.)</p>
<p><b>Đáp số:</b> a) cùng phương; $\vec{b},\vec{c},\vec{d},\vec{e}$ cùng hướng, ngược hướng với $\vec{a}$; b) cùng hướng và cùng độ dài nên đôi một bằng nhau.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.4.</b> Cho hình hộp $ABCD.A''B''C''D''$. Chứng minh rằng:</p>
<ol type="a">
<li>$\overrightarrow{AB}+\overrightarrow{DD''}+\overrightarrow{C''D''}=\overrightarrow{CC''}$;</li>
<li>$\overrightarrow{AB}+\overrightarrow{CD''}-\overrightarrow{CC''}=\vec{0}$;</li>
<li>$\overrightarrow{BC}-\overrightarrow{CC''}+\overrightarrow{DC}=\overrightarrow{A''C}$.</li>
</ol>', N'<p>Trong hình hộp: $\overrightarrow{DD''}=\overrightarrow{CC''}$, $\overrightarrow{C''D''}=\overrightarrow{CD}=-\overrightarrow{AB}$ (vì $\overrightarrow{AB}=\overrightarrow{DC}$).</p>
<p>a) $\overrightarrow{AB}+\overrightarrow{DD''}+\overrightarrow{C''D''}=\overrightarrow{AB}+\overrightarrow{CC''}-\overrightarrow{AB}=\overrightarrow{CC''}$. (đpcm)</p>
<p>b) $\overrightarrow{CD''}-\overrightarrow{CC''}=\overrightarrow{C''D''}$ (quy tắc hiệu), nên $\overrightarrow{AB}+\overrightarrow{CD''}-\overrightarrow{CC''}=\overrightarrow{AB}+\overrightarrow{C''D''}=\overrightarrow{AB}-\overrightarrow{AB}=\vec{0}$. (đpcm)</p>
<p>c) $\overrightarrow{DC}=\overrightarrow{AB}$ nên $\overrightarrow{BC}+\overrightarrow{DC}=\overrightarrow{AB}+\overrightarrow{BC}=\overrightarrow{AC}$. Do đó vế trái $=\overrightarrow{AC}-\overrightarrow{CC''}=\overrightarrow{AC}+\overrightarrow{C''C}=\overrightarrow{AC}+\overrightarrow{A''A}=\overrightarrow{A''C}$. (đpcm)</p>
<p><b>Đáp số:</b> đã chứng minh được cả ba đẳng thức.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.5.</b> Cho hình lăng trụ tam giác $ABC.A''B''C''$ có $\overrightarrow{AA''}=\vec{a}$, $\overrightarrow{AB}=\vec{b}$ và $\overrightarrow{AC}=\vec{c}$. Hãy biểu diễn các vectơ sau qua các vectơ $\vec{a}$, $\vec{b}$, $\vec{c}$:</p>
<ol type="a">
<li>$\overrightarrow{AB''}$;</li>
<li>$\overrightarrow{B''C}$;</li>
<li>$\overrightarrow{BC''}$.</li>
</ol>', N'<p>Lăng trụ: $\overrightarrow{BB''}=\overrightarrow{CC''}=\overrightarrow{AA''}=\vec{a}$, $\overrightarrow{A''C''}=\overrightarrow{AC}=\vec{c}$.</p>
<p>a) $\overrightarrow{AB''}=\overrightarrow{AB}+\overrightarrow{BB''}=\vec{b}+\vec{a}$.</p>
<p>b) $\overrightarrow{B''C}=\overrightarrow{B''B}+\overrightarrow{BC}=-\vec{a}+(\overrightarrow{AC}-\overrightarrow{AB})=-\vec{a}+\vec{c}-\vec{b}$.</p>
<p>c) $\overrightarrow{BC''}=\overrightarrow{BA}+\overrightarrow{AA''}+\overrightarrow{A''C''}=-\vec{b}+\vec{a}+\vec{c}$ (hoặc $\overrightarrow{BC}+\overrightarrow{CC''}=(\vec{c}-\vec{b})+\vec{a}$).</p>
<p><b>Đáp số:</b> a) $\vec{a}+\vec{b}$; b) $\vec{c}-\vec{a}-\vec{b}$; c) $\vec{a}-\vec{b}+\vec{c}$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.6.</b> Cho hình chóp tứ giác $S.ABCD$. Chứng minh rằng tứ giác $ABCD$ là hình bình hành nếu và chỉ nếu $\overrightarrow{SA}+\overrightarrow{SC}=\overrightarrow{SB}+\overrightarrow{SD}$.</p>', N'<p>Tứ giác $ABCD$ là đáy của hình chóp nên $A,B,C,D$ cùng thuộc một mặt phẳng. Ta biến đổi tương đương:</p>
<p>$\overrightarrow{SA}+\overrightarrow{SC}=\overrightarrow{SB}+\overrightarrow{SD}\iff\overrightarrow{SA}-\overrightarrow{SB}=\overrightarrow{SD}-\overrightarrow{SC}\iff\overrightarrow{BA}=\overrightarrow{CD}\iff\overrightarrow{AB}=\overrightarrow{DC}.$</p>
<p>Tứ giác $ABCD$ có $\overrightarrow{AB}=\overrightarrow{DC}$ khi và chỉ khi $ABCD$ là hình bình hành. Vậy $ABCD$ là hình bình hành khi và chỉ khi $\overrightarrow{SA}+\overrightarrow{SC}=\overrightarrow{SB}+\overrightarrow{SD}$.</p>
<p><b>Đáp số:</b> đã chứng minh (các phép biến đổi đều là tương đương).</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.7.</b> Cho hình chóp $S.ABC$. Trên cạnh $SA$, lấy điểm $M$ sao cho $SM=2AM$. Trên cạnh $BC$, lấy điểm $N$ sao cho $CN=2BN$. Chứng minh rằng $\overrightarrow{MN}=\dfrac{1}{3}\left(\overrightarrow{SA}+\overrightarrow{BC}\right)+\overrightarrow{AB}$.</p>', N'<p>Từ $SM=2AM$ với $M$ nằm trên cạnh $SA$ ta có $AM=\dfrac13 SA$, nên $\overrightarrow{MA}=\dfrac13\overrightarrow{SA}$. Từ $CN=2BN$ với $N$ nằm trên $BC$ ta có $BN=\dfrac13 BC$, nên $\overrightarrow{BN}=\dfrac13\overrightarrow{BC}$.</p>
<p>Theo quy tắc ba điểm:</p>
<p>$$\overrightarrow{MN}=\overrightarrow{MA}+\overrightarrow{AB}+\overrightarrow{BN}=\dfrac13\overrightarrow{SA}+\overrightarrow{AB}+\dfrac13\overrightarrow{BC}=\dfrac13\left(\overrightarrow{SA}+\overrightarrow{BC}\right)+\overrightarrow{AB}.$$</p>
<p><b>Đáp số:</b> đẳng thức được chứng minh.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.8.</b> Trong Luyện tập 8, ta đã biết trọng tâm của tứ diện $ABCD$ là một điểm $I$ thoả mãn $\overrightarrow{AI}=3\overrightarrow{IG}$, ở đó $G$ là trọng tâm của tam giác $BCD$. Áp dụng tính chất trên để tính khoảng cách từ trọng tâm của một khối rubik (đồng chất) hình tứ diện đều đến một mặt của nó, biết rằng chiều cao của khối rubik là 8 cm (H.2.30). <div><img src="/static/img/sgk/hinh-2-30.png" alt="Hình minh họa bài 2.8 (SGK)"></div></p>', N'<p>Gọi tứ diện đều là $ABCD$, $G$ là trọng tâm tam giác đáy $BCD$ (khi đó $AG\perp(BCD)$ nên $AG$ là chiều cao của khối: $AG=8$ cm), $I$ là trọng tâm tứ diện.</p>
<p>Từ $\overrightarrow{AI}=3\overrightarrow{IG}$ suy ra $I$ nằm trên đoạn $AG$ và $AI=3IG$, do đó $AG=AI+IG=4IG$.</p>
<p>Khoảng cách từ $I$ đến mặt $(BCD)$ chính là $IG$ (vì $IG\subset AG\perp(BCD)$): $IG=\dfrac{AG}{4}=\dfrac84=2$ (cm). Do tứ diện đều nên khoảng cách đến các mặt khác cũng bằng 2 cm.</p>
<p><b>Đáp số:</b> 2 cm.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.9.</b> Ba sợi dây không giãn với khối lượng không đáng kể được buộc chung một đầu và được kéo căng về ba hướng khác nhau (H.2.31). Nếu các lực kéo làm cho ba sợi dây ở trạng thái đứng yên thì khi đó ba sợi dây nằm trên cùng một mặt phẳng. Hãy giải thích vì sao. <div><img src="/static/img/sgk/hinh-2-31.png" alt="Hình minh họa bài 2.9 (SGK)"></div></p>', N'<p>Gọi $O$ là điểm buộc chung và $\vec{F_1}$, $\vec{F_2}$, $\vec{F_3}$ là ba lực kéo của ba sợi dây tác dụng vào $O$ (cùng phương với từng sợi dây, có điểm đặt tại $O$).</p>
<p>Vì hệ đứng yên nên hợp lực bằng $\vec{0}$: $\vec{F_1}+\vec{F_2}+\vec{F_3}=\vec{0}$, suy ra $\vec{F_3}=-(\vec{F_1}+\vec{F_2})$.</p>
<p>Hai lực $\vec{F_1}$, $\vec{F_2}$ (không cùng phương) xác định mặt phẳng $(P)$ đi qua $O$. Vectơ $\vec{F_1}+\vec{F_2}$ là đường chéo của hình bình hành dựng trên hai vectơ đó nên nằm trong $(P)$; do đó $\vec{F_3}$ cũng có giá nằm trong $(P)$. Vậy cả ba lực, tức cả ba sợi dây, nằm trên cùng một mặt phẳng.</p>
<p><b>Đáp số:</b> Ba lực cân bằng nên $\vec{F_3}=-(\vec{F_1}+\vec{F_2})$, tức ba vectơ đồng phẳng, vì vậy ba sợi dây cùng nằm trong một mặt phẳng.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.10.</b> Cho hình lăng trụ tứ giác đều $ABCD.A''B''C''D''$ có độ dài mỗi cạnh đáy bằng 1 và độ dài mỗi cạnh bên bằng 2. Hãy tính góc giữa các cặp vectơ sau đây và tính tích vô hướng của mỗi cặp vectơ đó:</p>
<ol type="a">
<li>$\overrightarrow{AA''}$ và $\overrightarrow{C''C}$;</li>
<li>$\overrightarrow{AA''}$ và $\overrightarrow{BC}$;</li>
<li>$\overrightarrow{AC}$ và $\overrightarrow{B''A''}$.</li>
</ol>', N'<p>Đáy $ABCD$ là hình vuông cạnh 1, cạnh bên $AA''=2$ vuông góc với đáy. Dùng $\vec{u}\cdot\vec{v}=|\vec{u}||\vec{v}|\cos(\vec{u},\vec{v})$.</p>
<p>a) $\overrightarrow{C''C}=-\overrightarrow{AA''}$ nên hai vectơ ngược hướng, góc $180^\circ$. $\overrightarrow{AA''}\cdot\overrightarrow{C''C}=2\cdot2\cdot\cos180^\circ=-4$.</p>
<p>b) $AA''\perp(ABCD)$ nên $AA''\perp BC$: góc $90^\circ$, tích vô hướng bằng $0$.</p>
<p>c) $\overrightarrow{B''A''}=\overrightarrow{BA}$. Góc giữa $\overrightarrow{AC}$ và $\overrightarrow{BA}$: lấy $\overrightarrow{AE}=\overrightarrow{BA}$ thì $\widehat{CAE}=180^\circ-\widehat{BAC}=180^\circ-45^\circ=135^\circ$ (đường chéo hình vuông tạo với cạnh góc $45^\circ$). Với $AC=\sqrt2$, $B''A''=1$: $\overrightarrow{AC}\cdot\overrightarrow{B''A''}=\sqrt2\cdot1\cdot\cos135^\circ=-1$.</p>
<p><b>Đáp số:</b> a) $180^\circ$, $-4$; b) $90^\circ$, $0$; c) $135^\circ$, $-1$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.11.</b> Trong không gian, cho hai vectơ $\vec{a}$ và $\vec{b}$ cùng có độ dài bằng 1. Biết rằng góc giữa hai vectơ đó là $45^\circ$, hãy tính:</p>
<ol type="a">
<li>$\vec{a}\cdot\vec{b}$;</li>
<li>$(\vec{a}+3\vec{b})\cdot(\vec{a}-2\vec{b})$;</li>
<li>$(\vec{a}+\vec{b})^2$.</li>
</ol>', N'<p>Ta có $|\vec{a}|=|\vec{b}|=1$, $\cos45^\circ=\dfrac{\sqrt2}{2}$.</p>
<p>a) $\vec{a}\cdot\vec{b}=1\cdot1\cdot\cos45^\circ=\dfrac{\sqrt2}{2}$.</p>
<p>b) $(\vec{a}+3\vec{b})\cdot(\vec{a}-2\vec{b})=\vec{a}^2+\vec{a}\cdot\vec{b}-6\vec{b}^2=1+\dfrac{\sqrt2}{2}-6=-5+\dfrac{\sqrt2}{2}$.</p>
<p>c) $(\vec{a}+\vec{b})^2=\vec{a}^2+2\vec{a}\cdot\vec{b}+\vec{b}^2=1+\sqrt2+1=2+\sqrt2$.</p>
<p><b>Đáp số:</b> a) $\dfrac{\sqrt2}{2}$; b) $\dfrac{\sqrt2}{2}-5$; c) $2+\sqrt2$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.12.</b> Cho tứ diện $ABCD$. Chứng minh rằng:</p>
<ol type="a">
<li>$\overrightarrow{AB}\cdot\overrightarrow{CD}=\overrightarrow{AC}\cdot\overrightarrow{CD}+\overrightarrow{BC}\cdot\overrightarrow{DC}$;</li>
<li>$\overrightarrow{AB}\cdot\overrightarrow{CD}+\overrightarrow{AC}\cdot\overrightarrow{DB}+\overrightarrow{AD}\cdot\overrightarrow{BC}=0$.</li>
</ol>', N'<p>a) Ta có $\overrightarrow{AB}=\overrightarrow{AC}+\overrightarrow{CB}$, nên</p>
<p>$\overrightarrow{AB}\cdot\overrightarrow{CD}=\overrightarrow{AC}\cdot\overrightarrow{CD}+\overrightarrow{CB}\cdot\overrightarrow{CD}=\overrightarrow{AC}\cdot\overrightarrow{CD}+\overrightarrow{BC}\cdot\overrightarrow{DC}$ (vì $\overrightarrow{CB}=-\overrightarrow{BC}$, $\overrightarrow{CD}=-\overrightarrow{DC}$ nên tích không đổi dấu). (đpcm)</p>
<p>b) Đặt $\vec{b}=\overrightarrow{AB}$, $\vec{c}=\overrightarrow{AC}$, $\vec{d}=\overrightarrow{AD}$. Khi đó $\overrightarrow{CD}=\vec{d}-\vec{c}$, $\overrightarrow{DB}=\vec{b}-\vec{d}$, $\overrightarrow{BC}=\vec{c}-\vec{b}$. Vế trái:</p>
<p>$\vec{b}\cdot(\vec{d}-\vec{c})+\vec{c}\cdot(\vec{b}-\vec{d})+\vec{d}\cdot(\vec{c}-\vec{b})=\vec{b}\cdot\vec{d}-\vec{b}\cdot\vec{c}+\vec{c}\cdot\vec{b}-\vec{c}\cdot\vec{d}+\vec{d}\cdot\vec{c}-\vec{d}\cdot\vec{b}=0.$ (đpcm)</p>
<p><b>Đáp số:</b> đã chứng minh cả hai đẳng thức.</p>', 2, 0, 1, @t1);
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
INSERT INTO LessonMaterials (LessonId, MaterialType, Title, Url, ContentText, OrderIndex, CreatedBy) VALUES (@l, 'YOUTUBE', N'Video bài giảng: Bài 7. Hệ trục toạ độ trong không gian', 'https://www.youtube.com/watch?v=RT-Uy7InSxE', NULL, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.13.</b> Trong không gian $Oxyz$, cho ba vectơ $\vec{a}$, $\vec{b}$, $\vec{c}$ đều khác $\vec{0}$ và có giá đôi một vuông góc. Những mệnh đề nào sau đây là đúng?</p>
<ol type="a">
<li>Có thể lập một hệ toạ độ $Oxyz$ có các trục toạ độ lần lượt song song với giá của các vectơ $\vec{a}$, $\vec{b}$, $\vec{c}$.</li>
<li>Có thể lập một hệ toạ độ $Oxyz$ có các trục toạ độ lần lượt trùng với giá của các vectơ $\vec{a}$, $\vec{b}$, $\vec{c}$.</li>
<li>Có thể lập một hệ toạ độ $Oxyz$ có các vectơ $\vec{i}$, $\vec{j}$, $\vec{k}$ lần lượt bằng các vectơ $\vec{a}$, $\vec{b}$, $\vec{c}$.</li>
<li>Có thể lập một hệ toạ độ $Oxyz$ có các vectơ $\vec{i}$, $\vec{j}$, $\vec{k}$ lần lượt cùng phương với các vectơ $\vec{a}$, $\vec{b}$, $\vec{c}$.</li>
</ol>', N'<p>Hệ toạ độ $Oxyz$ có ba trục đôi một vuông góc, cắt nhau tại gốc $O$, và $\vec{i},\vec{j},\vec{k}$ là các vectơ đơn vị (độ dài 1) trên các trục.</p>
<ul><li>a) Đúng: ba vectơ có giá đôi một vuông góc, ta chọn gốc $O$ tuỳ ý rồi vẽ qua $O$ ba đường thẳng lần lượt song song với giá của $\vec{a},\vec{b},\vec{c}$; chúng đôi một vuông góc nên làm ba trục.</li>
<li>b) Sai: các giá của $\vec{a},\vec{b},\vec{c}$ chưa chắc cắt nhau tại một điểm (có thể chéo nhau), nên không thể cho các trục trùng với các giá đó.</li>
<li>c) Sai: $\vec{i},\vec{j},\vec{k}$ là vectơ đơn vị, còn $\vec{a},\vec{b},\vec{c}$ chưa chắc có độ dài 1.</li>
<li>d) Đúng: chọn $O$ tuỳ ý, các trục song song với giá của $\vec{a},\vec{b},\vec{c}$ và vectơ đơn vị $\vec{i},\vec{j},\vec{k}$ chọn cùng phương (cùng hoặc ngược chiều) với $\vec{a},\vec{b},\vec{c}$; có thể chọn chiều để hệ thuận.</li></ul>
<p><b>Đáp số:</b> các mệnh đề đúng là a) và d).</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.14.</b> Hãy mô tả hệ toạ độ $Oxyz$ trong căn phòng ở Hình 2.44 sao cho gốc $O$ trùng với góc trên của căn phòng, khung tranh nằm trong mặt phẳng $(Oxy)$ và mặt trần nhà trùng với mặt phẳng $(Oxz)$. <div><img src="/static/img/sgk/hinh-2-44.png" alt="Hình minh họa bài 2.14 (SGK)"></div></p>', N'<p>Điểm $O$ là góc trên của căn phòng, nơi gặp nhau của ba mặt: trần nhà, bức tường có khung tranh (tường chính diện) và bức tường bên phải. Ba giao tuyến đi qua $O$ đôi một vuông góc nên dùng làm ba trục:</p>
<ul><li>Trục $Ox$: giao tuyến của tường có khung tranh và trần nhà (đường nằm ngang, hướng sang trái nhìn từ trong phòng).</li>
<li>Trục $Oy$: giao tuyến của tường có khung tranh và tường bên phải (đường thẳng đứng, hướng xuống dưới).</li>
<li>Trục $Oz$: giao tuyến của trần nhà và tường bên phải (nằm ngang, hướng ra phía người nhìn).</li></ul>
<p>Khi đó mặt phẳng $(Oxy)$ là mặt tường có khung tranh (chứa $Ox$ và $Oy$), mặt phẳng $(Oxz)$ là trần nhà (chứa $Ox$ và $Oz$), đúng yêu cầu của đề; còn $(Oyz)$ là tường bên phải. Với chiều như trên, ba trục lập thành hệ trục thuận (đúng quy tắc bàn tay phải).</p>
<p><b>Đáp số:</b> $O$ là góc trên; $Ox$ dọc theo chân trần của tường có tranh, $Oy$ dọc theo góc tường thẳng đứng, $Oz$ dọc theo chân trần của tường bên.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.15.</b> Trong không gian $Oxyz$, xác định toạ độ của vectơ $\overrightarrow{AB}$ trong mỗi trường hợp sau:</p>
<ol type="a">
<li>$A(0;0;0)$ và $B(4;2;-5)$;</li>
<li>$A(1;-3;7)$ và $B(1;-3;7)$;</li>
<li>$A(5;4;9)$ và $B(-5;7;2)$.</li>
</ol>', N'<p>Công thức: $\overrightarrow{AB}=(x_B-x_A;\,y_B-y_A;\,z_B-z_A)$.</p>
<p>a) $\overrightarrow{AB}=(4-0;\,2-0;\,-5-0)=(4;2;-5)$.</p>
<p>b) $A\equiv B$ nên $\overrightarrow{AB}=(1-1;\,-3+3;\,7-7)=(0;0;0)=\vec{0}$.</p>
<p>c) $\overrightarrow{AB}=(-5-5;\,7-4;\,2-9)=(-10;3;-7)$.</p>
<p><b>Đáp số:</b> a) $(4;2;-5)$; b) $(0;0;0)$; c) $(-10;3;-7)$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.16.</b> Trong không gian $Oxyz$, xác định toạ độ của điểm $A$ trong mỗi trường hợp sau:</p>
<ol type="a">
<li>$A$ trùng với gốc toạ độ;</li>
<li>$A$ nằm trên tia $Ox$ và $OA=2$;</li>
<li>$A$ nằm trên tia đối của tia $Oy$ và $OA=3$.</li>
</ol>', N'<p>a) $A$ trùng gốc toạ độ nên $A(0;0;0)$.</p>
<p>b) $A$ nằm trên tia $Ox$ nên có tung độ, cao độ bằng 0 và hoành độ dương bằng $OA$: $A(2;0;0)$.</p>
<p>c) $A$ nằm trên tia đối của tia $Oy$ nên hoành độ, cao độ bằng 0 và tung độ âm có giá trị tuyệt đối $OA=3$: $A(0;-3;0)$.</p>
<p><b>Đáp số:</b> a) $(0;0;0)$; b) $(2;0;0)$; c) $(0;-3;0)$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.17.</b> Trong không gian $Oxyz$, cho hình hộp chữ nhật $ABCD.A''B''C''D''$ có đỉnh $A$ trùng với gốc $O$ và các đỉnh $D$, $B$, $A''$ có toạ độ lần lượt là $(2;0;0)$, $(0;4;0)$, $(0;0;3)$ (H.2.45). Xác định toạ độ của các đỉnh còn lại của hình hộp chữ nhật. <div><img src="/static/img/sgk/hinh-2-45.png" alt="Hình minh họa bài 2.17 (SGK)"></div></p>', N'<p>Hình hộp chữ nhật có $A$ trùng gốc $O$ và ba cạnh $AD$, $AB$, $AA''$ lần lượt nằm trên các trục $Ox$, $Oy$, $Oz$ với $AD=2$, $AB=4$, $AA''=3$.</p>
<p>Vì $ABCD$ là hình chữ nhật nên $\overrightarrow{AC}=\overrightarrow{AB}+\overrightarrow{AD}=(0;4;0)+(2;0;0)=(2;4;0)$, suy ra $C(2;4;0)$.</p>
<p>Các đỉnh của mặt $A''B''C''D''$ nhận được bằng cách tịnh tiến các đỉnh đáy $ABCD$ theo $\overrightarrow{AA''}=(0;0;3)$ (cộng thêm $3$ vào cao độ):</p>
<ul><li>$B''(0;4;3)$</li><li>$C''(2;4;3)$</li><li>$D''(2;0;3)$</li></ul>
<p><b>Đáp số:</b> $C(2;4;0)$, $B''(0;4;3)$, $C''(2;4;3)$, $D''(2;0;3)$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.18.</b> Trong không gian $Oxyz$, cho hình hộp $OABC.O''A''B''C''$ có $A(1;1;-1)$, $B(0;3;0)$, $C''(2;-3;6)$.</p>
<ol type="a">
<li>Xác định toạ độ của điểm $C$.</li>
<li>Xác định toạ độ các đỉnh còn lại của hình hộp.</li>
</ol>', N'<p>Hình hộp $OABC.O''A''B''C''$ có $O$ là gốc toạ độ $(0;0;0)$.</p>
<p><b>a)</b> Đáy $OABC$ là hình bình hành nên $\overrightarrow{OB}=\overrightarrow{OA}+\overrightarrow{OC}$, suy ra $\overrightarrow{OC}=\overrightarrow{OB}-\overrightarrow{OA}=(0-1;3-1;0+1)=(-1;2;1)$. Vậy $C(-1;2;1)$.</p>
<p><b>b)</b> Ta có $\overrightarrow{CC''}=(2+1;-3-2;6-1)=(3;-5;5)$. Do các cạnh bên song song và bằng nhau nên $\overrightarrow{OO''}=\overrightarrow{AA''}=\overrightarrow{BB''}=\overrightarrow{CC''}=(3;-5;5)$. Do đó:</p>
<ul><li>$O''(3;-5;5)$</li><li>$A''(1+3;1-5;-1+5)=(4;-4;4)$</li><li>$B''(0+3;3-5;0+5)=(3;-2;5)$</li></ul>
<p><b>Đáp số:</b> a) $C(-1;2;1)$; b) $O''(3;-5;5)$, $A''(4;-4;4)$, $B''(3;-2;5)$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.19.</b> Trong Vận dụng 2, hãy giải thích vì sao tại mỗi thời điểm chiếc máy bay di chuyển trên đường băng thì toạ độ của nó luôn có dạng $(x;y;0)$ với $x$, $y$ là hai số thực nào đó.</p>
<p><i>(Vận dụng 2, SGK trang 64: lập hệ toạ độ $Oxyz$ có gốc $O$ trùng với vị trí của trung tâm kiểm soát không lưu, mặt phẳng $(Oxy)$ trùng với mặt đất (được coi là phẳng), trục $Ox$ hướng về phía tây, trục $Oy$ hướng về phía nam và trục $Oz$ hướng thẳng đứng lên trời.)</i></p>', N'<p>Trong hệ toạ độ đã lập, mặt phẳng $(Oxy)$ trùng với mặt đất, còn trục $Oz$ hướng thẳng đứng lên trời, nên cao độ $z$ của một điểm chính là độ cao của điểm đó so với mặt đất.</p>
<p>Khi máy bay di chuyển trên đường băng, máy bay ở trên mặt đất (được coi là phẳng) nên độ cao so với mặt đất bằng $0$, tức là điểm biểu diễn máy bay nằm trong mặt phẳng $(Oxy)$. Mọi điểm thuộc $(Oxy)$ có cao độ bằng $0$.</p>
<p>Vì vậy, tại mỗi thời điểm, toạ độ của máy bay có dạng $(x;y;0)$, trong đó $x$, $y$ là các số thực xác định vị trí của máy bay theo hướng tây và hướng nam so với trung tâm kiểm soát không lưu.</p>
<p><b>Đáp số:</b> Vì đường băng nằm trên mặt đất, tức trong mặt phẳng $(Oxy)$, nên cao độ $z=0$.</p>', 3, 0, 1, @t1);
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
INSERT INTO LessonMaterials (LessonId, MaterialType, Title, Url, ContentText, OrderIndex, CreatedBy) VALUES (@l, 'YOUTUBE', N'Video bài giảng: Bài 8. Biểu thức toạ độ của các phép toán vectơ', 'https://www.youtube.com/watch?v=naw1tqH_CNs', NULL, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.20.</b> Trong không gian $Oxyz$, cho ba vectơ $\vec{a}=(3;1;2)$, $\vec{b}=(-3;0;4)$ và $\vec{c}=(6;-1;0)$.</p>
<ol type="a">
<li>Tìm toạ độ của các vectơ $\vec{a}+\vec{b}+\vec{c}$ và $2\vec{a}-3\vec{b}-5\vec{c}$.</li>
<li>Tính các tích vô hướng $\vec{a}\cdot(-\vec{b})$ và $(2\vec{a})\cdot\vec{c}$.</li>
</ol>', N'<p><b>a)</b> Ta có $\vec{a}+\vec{b}+\vec{c}=(3-3+6;\,1+0-1;\,2+4+0)=(6;0;6)$.</p>
<p>$2\vec{a}=(6;2;4)$, $3\vec{b}=(-9;0;12)$, $5\vec{c}=(30;-5;0)$ nên</p>
<p>$2\vec{a}-3\vec{b}-5\vec{c}=(6+9-30;\,2-0+5;\,4-12-0)=(-15;7;-8)$.</p>
<p><b>b)</b> $-\vec{b}=(3;0;-4)$ nên $\vec{a}\cdot(-\vec{b})=3\cdot3+1\cdot0+2\cdot(-4)=9-8=1$.</p>
<p>$2\vec{a}=(6;2;4)$ nên $(2\vec{a})\cdot\vec{c}=6\cdot6+2\cdot(-1)+4\cdot0=34$.</p>
<p><b>Đáp số:</b> a) $(6;0;6)$ và $(-15;7;-8)$; b) $1$ và $34$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.21.</b> Trong không gian $Oxyz$, cho ba điểm $M(-4;3;3)$, $N(4;-4;2)$ và $P(3;6;-1)$.</p>
<ol type="a">
<li>Tìm toạ độ của các vectơ $\overrightarrow{MN}$, $\overrightarrow{MP}$, từ đó chứng minh rằng ba điểm $M$, $N$, $P$ không thẳng hàng.</li>
<li>Tìm toạ độ của vectơ $\overrightarrow{NM}+\overrightarrow{NP}$, từ đó suy ra toạ độ của điểm $Q$ sao cho tứ giác $MNPQ$ là hình bình hành.</li>
<li>Tính chu vi của hình bình hành $MNPQ$.</li>
</ol>', N'<p><b>a)</b> $\overrightarrow{MN}=(4+4;\,-4-3;\,2-3)=(8;-7;-1)$, $\overrightarrow{MP}=(3+4;\,6-3;\,-1-3)=(7;3;-4)$.</p>
<p>Vì $\dfrac{8}{7}\ne\dfrac{-7}{3}$ nên hai vectơ không cùng phương, do đó $M$, $N$, $P$ không thẳng hàng.</p>
<p><b>b)</b> $\overrightarrow{NM}=(-8;7;1)$, $\overrightarrow{NP}=(-1;10;-3)$ nên $\overrightarrow{NM}+\overrightarrow{NP}=(-9;17;-2)$.</p>
<p>Hình bình hành $MNPQ$ có hai đường chéo $MP$, $NQ$ cắt nhau tại trung điểm mỗi đường, nên $\overrightarrow{NQ}=\overrightarrow{NM}+\overrightarrow{NP}=(-9;17;-2)$. Gọi $Q(x;y;z)$: $x-4=-9$, $y+4=17$, $z-2=-2$, suy ra $Q(-5;13;0)$.</p>
<p><b>c)</b> Hai cạnh kề tại $N$ là $NM$ và $NP$: $NM=\sqrt{8^2+7^2+1^2}=\sqrt{114}$, $NP=\sqrt{1^2+10^2+3^2}=\sqrt{110}$.</p>
<p>Chu vi $=2(NM+NP)=2(\sqrt{114}+\sqrt{110})\approx2(10{,}68+10{,}49)\approx42{,}3$.</p>
<p><b>Đáp số:</b> a) $\overrightarrow{MN}=(8;-7;-1)$, $\overrightarrow{MP}=(7;3;-4)$; b) $Q(-5;13;0)$; c) chu vi $=2(\sqrt{114}+\sqrt{110})\approx 42{,}3$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.22.</b> Trong không gian $Oxyz$, cho tam giác $ABC$ có $A(1;0;1)$, $B(0;-3;1)$ và $C(4;-1;4)$.</p>
<ol type="a">
<li>Tìm toạ độ trọng tâm của tam giác $ABC$.</li>
<li>Chứng minh rằng $\widehat{BAC}=90^\circ$.</li>
<li>Tính $\widehat{ABC}$.</li>
</ol>', N'<p><b>a)</b> Trọng tâm $G\left(\dfrac{1+0+4}{3};\dfrac{0-3-1}{3};\dfrac{1+1+4}{3}\right)=\left(\dfrac53;-\dfrac43;2\right)$.</p>
<p><b>b)</b> $\overrightarrow{AB}=(-1;-3;0)$, $\overrightarrow{AC}=(3;-1;3)$. Khi đó $\overrightarrow{AB}\cdot\overrightarrow{AC}=-3+3+0=0$ nên $AB\perp AC$, tức $\widehat{BAC}=90^\circ$.</p>
<p><b>c)</b> $\overrightarrow{BA}=(1;3;0)$, $\overrightarrow{BC}=(4;2;3)$. Ta có $\overrightarrow{BA}\cdot\overrightarrow{BC}=4+6+0=10$, $|\overrightarrow{BA}|=\sqrt{10}$, $|\overrightarrow{BC}|=\sqrt{29}$.</p>
<p>$\cos\widehat{ABC}=\dfrac{10}{\sqrt{10}\cdot\sqrt{29}}=\sqrt{\dfrac{10}{29}}\approx0{,}587$, suy ra $\widehat{ABC}\approx54^\circ$.</p>
<p><b>Đáp số:</b> a) $G\left(\frac53;-\frac43;2\right)$; b) chứng minh như trên; c) $\widehat{ABC}\approx54^\circ$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.23.</b> Một phòng học có thiết kế dạng hình hộp chữ nhật với chiều dài là 8 m, chiều rộng là 6 m và chiều cao là 3 m. Một chiếc đèn được treo tại chính giữa trần nhà của phòng học. Xét hệ trục toạ độ $Oxyz$ có gốc $O$ trùng với một góc phòng và mặt phẳng $(Oxy)$ trùng với mặt sàn, đơn vị đo được lấy theo mét (H.2.51). Hãy tìm toạ độ của điểm treo đèn. <div><img src="/static/img/sgk/hinh-2-51.png" alt="Hình minh họa bài 2.23 (SGK)"></div></p>', N'<p>Theo hình vẽ, $O$ là một góc phòng, trục $Ox$ chạy dọc chiều dài ($8$ m), trục $Oy$ chạy dọc chiều rộng ($6$ m), trục $Oz$ thẳng đứng (chiều cao $3$ m).</p>
<p>Đèn treo ở chính giữa trần nhà. Trần nhà là hình chữ nhật $8\times6$ nằm ở độ cao $z=3$. Tâm của hình chữ nhật có $x=\dfrac82=4$, $y=\dfrac62=3$.</p>
<p>Vậy điểm treo đèn có toạ độ $(4;3;3)$.</p>
<p><b>Đáp số:</b> $(4;3;3)$.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.24.</b> Trong không gian, xét hệ toạ độ $Oxyz$ có gốc $O$ trùng với vị trí của một giàn khoan trên biển, mặt phẳng $(Oxy)$ trùng với mặt biển (được coi là phẳng) với trục $Ox$ hướng về phía tây, trục $Oy$ hướng về phía nam và trục $Oz$ hướng thẳng đứng lên trời (H.2.52). Đơn vị đo trong không gian $Oxyz$ lấy theo kilômét. Một chiếc radar đặt tại giàn khoan có phạm vi theo dõi là 30 km. Hỏi radar có thể phát hiện được một chiếc tàu thám hiểm có toạ độ là $(25;15;-10)$ đối với hệ toạ độ nói trên hay không? Hãy giải thích vì sao. <div><img src="/static/img/sgk/hinh-2-52.png" alt="Hình minh họa bài 2.24 (SGK)"></div></p>', N'<p>Radar đặt tại gốc $O(0;0;0)$ và có phạm vi theo dõi $30$ km, tức phát hiện được các vật có khoảng cách tới $O$ không quá $30$ km.</p>
<p>Khoảng cách từ $O$ đến tàu $T(25;15;-10)$ là</p>
<p>$OT=\sqrt{25^2+15^2+(-10)^2}=\sqrt{625+225+100}=\sqrt{950}\approx30{,}8$ (km).</p>
<p>Vì $30{,}8\gt30$ nên tàu nằm ngoài phạm vi theo dõi của radar.</p>
<p><b>Đáp số:</b> Radar không phát hiện được tàu vì $OT=\sqrt{950}\approx30{,}8\gt30$ km.</p>', 3, 0, 1, @t1);
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
$$\overrightarrow{SA}+\overrightarrow{SC}=\overrightarrow{SB}+\overrightarrow{SD}.$$', N'<p>Gọi $O$ là giao điểm của hai đường chéo $AC$ và $BD$ của hình chữ nhật $ABCD$. Hình chữ nhật là hình bình hành nên $O$ là trung điểm của cả $AC$ và $BD$.</p>
<p>Vì $O$ là trung điểm của $AC$: $\overrightarrow{SA}+\overrightarrow{SC}=2\overrightarrow{SO}$.</p>
<p>Vì $O$ là trung điểm của $BD$: $\overrightarrow{SB}+\overrightarrow{SD}=2\overrightarrow{SO}$.</p>
<p>Từ hai đẳng thức trên ta có $\overrightarrow{SA}+\overrightarrow{SC}=\overrightarrow{SB}+\overrightarrow{SD}$ (đpcm).</p>
<p><b>Đáp số:</b> Chứng minh như trên (chỉ cần $ABCD$ là hình bình hành).</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.36.</b> Cho tứ diện $ABCD$, lấy hai điểm $M$, $N$ thoả mãn $\overrightarrow{MB}+2\overrightarrow{MA}=\vec{0}$ và $\overrightarrow{NC}=2\overrightarrow{DN}$. Hãy biểu diễn $\overrightarrow{MN}$ theo $\overrightarrow{AD}$ và $\overrightarrow{BC}$.</p>', N'<p>Từ $\overrightarrow{MB}+2\overrightarrow{MA}=\vec{0}$ và $\overrightarrow{NC}=2\overrightarrow{DN}$ (tức $\overrightarrow{CN}=-2\overrightarrow{DN}$) ta có $2\overrightarrow{DN}+\overrightarrow{CN}=\vec{0}$.</p>
<p>Biểu diễn $\overrightarrow{MN}$ theo hai đường đi khác nhau:</p>
<ul><li>$2\overrightarrow{MN}=2\overrightarrow{MA}+2\overrightarrow{AD}+2\overrightarrow{DN}$ (từ $\overrightarrow{MN}=\overrightarrow{MA}+\overrightarrow{AD}+\overrightarrow{DN}$).</li>
<li>$\overrightarrow{MN}=\overrightarrow{MB}+\overrightarrow{BC}+\overrightarrow{CN}$.</li></ul>
<p>Cộng hai đẳng thức:</p>
<p>$3\overrightarrow{MN}=(2\overrightarrow{MA}+\overrightarrow{MB})+2\overrightarrow{AD}+\overrightarrow{BC}+(2\overrightarrow{DN}+\overrightarrow{CN})=2\overrightarrow{AD}+\overrightarrow{BC}$.</p>
<p>Vậy $\overrightarrow{MN}=\dfrac23\overrightarrow{AD}+\dfrac13\overrightarrow{BC}$.</p>
<p><b>Đáp số:</b> $\overrightarrow{MN}=\dfrac23\overrightarrow{AD}+\dfrac13\overrightarrow{BC}$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.37.</b> Cho hình hộp $ABCD.A''B''C''D''$. Gọi $G$ là trọng tâm của tam giác $BDA''$.</p>
<ol type="a">
<li>Biểu diễn $\overrightarrow{AG}$ theo $\overrightarrow{AB}$, $\overrightarrow{AD}$ và $\overrightarrow{AA''}$.</li>
<li>Từ câu a, hãy chứng tỏ ba điểm $A$, $G$ và $C''$ thẳng hàng.</li>
</ol>', N'<p><b>a)</b> $G$ là trọng tâm tam giác $BDA''$ nên $\overrightarrow{AG}=\dfrac13(\overrightarrow{AB}+\overrightarrow{AD}+\overrightarrow{AA''})$.</p>
<p><b>b)</b> Theo quy tắc hình hộp: $\overrightarrow{AC''}=\overrightarrow{AB}+\overrightarrow{AD}+\overrightarrow{AA''}$.</p>
<p>Do đó $\overrightarrow{AG}=\dfrac13\overrightarrow{AC''}$, nghĩa là hai vectơ $\overrightarrow{AG}$, $\overrightarrow{AC''}$ cùng phương và có chung điểm đầu $A$. Vậy $A$, $G$, $C''$ thẳng hàng.</p>
<p><b>Đáp số:</b> a) $\overrightarrow{AG}=\frac13(\overrightarrow{AB}+\overrightarrow{AD}+\overrightarrow{AA''})$; b) $\overrightarrow{AG}=\frac13\overrightarrow{AC''}$ nên $A,G,C''$ thẳng hàng.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.38.</b> Trong không gian $Oxyz$, cho các điểm $A(2;-1;3)$, $B(1;1;-1)$ và $C(-1;0;2)$.</p>
<ol type="a">
<li>Tìm toạ độ trọng tâm $G$ của tam giác $ABC$.</li>
<li>Tìm toạ độ điểm $M$ thuộc trục $Oz$ sao cho đường thẳng $BM$ vuông góc với đường thẳng $AC$.</li>
</ol>', N'<p><b>a)</b> $G\left(\dfrac{2+1-1}{3};\dfrac{-1+1+0}{3};\dfrac{3-1+2}{3}\right)=\left(\dfrac23;0;\dfrac43\right)$.</p>
<p><b>b)</b> $M$ thuộc trục $Oz$ nên $M(0;0;m)$. Khi đó $\overrightarrow{BM}=(-1;-1;m+1)$ và $\overrightarrow{AC}=(-3;1;-1)$.</p>
<p>$BM\perp AC\iff\overrightarrow{BM}\cdot\overrightarrow{AC}=0\iff3-1-(m+1)=0\iff m=1$.</p>
<p>Vậy $M(0;0;1)$.</p>
<p><b>Đáp số:</b> a) $G\left(\frac23;0;\frac43\right)$; b) $M(0;0;1)$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.39.</b> Trong không gian $Oxyz$, cho hình hộp $OABC.O''A''B''C''$ có $A(2;3;1)$, $C(-1;2;3)$ và $O''(1;-2;2)$. Tìm toạ độ các đỉnh còn lại của hình hộp.</p>', N'<p>Gốc $O(0;0;0)$. Đáy $OABC$ là hình bình hành nên $\overrightarrow{OB}=\overrightarrow{OA}+\overrightarrow{OC}=(2-1;3+2;1+3)$, suy ra $B(1;5;4)$.</p>
<p>$\overrightarrow{OO''}=(1;-2;2)$ và $\overrightarrow{OO''}=\overrightarrow{AA''}=\overrightarrow{BB''}=\overrightarrow{CC''}$, nên:</p>
<ul><li>$A''(2+1;3-2;1+2)=(3;1;3)$</li><li>$B''(1+1;5-2;4+2)=(2;3;6)$</li><li>$C''(-1+1;2-2;3+2)=(0;0;5)$</li></ul>
<p><b>Đáp số:</b> $B(1;5;4)$, $A''(3;1;3)$, $B''(2;3;6)$, $C''(0;0;5)$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.40.</b> Trong không gian $Oxyz$, cho hai vectơ $\vec{a}=(-2;1;2)$, $\vec{b}=(1;1;-1)$.</p>
<ol type="a">
<li>Xác định toạ độ của $\vec{u}=\vec{a}-2\vec{b}$.</li>
<li>Tính độ dài của $\vec{u}$.</li>
<li>Tính $\cos(\vec{a},\vec{b})$.</li>
</ol>', N'<p><b>a)</b> $2\vec{b}=(2;2;-2)$ nên $\vec{u}=\vec{a}-2\vec{b}=(-2-2;\,1-2;\,2+2)=(-4;-1;4)$.</p>
<p><b>b)</b> $|\vec{u}|=\sqrt{16+1+16}=\sqrt{33}$.</p>
<p><b>c)</b> $\vec{a}\cdot\vec{b}=-2+1-2=-3$, $|\vec{a}|=\sqrt{4+1+4}=3$, $|\vec{b}|=\sqrt{3}$.</p>
<p>$\cos(\vec{a},\vec{b})=\dfrac{-3}{3\sqrt3}=-\dfrac{1}{\sqrt3}=-\dfrac{\sqrt3}{3}$.</p>
<p><b>Đáp số:</b> a) $(-4;-1;4)$; b) $\sqrt{33}$; c) $-\dfrac{\sqrt3}{3}$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.41.</b> Trong không gian $Oxyz$, cho các điểm $A(4;2;-1)$, $B(1;-1;2)$ và $C(0;-2;3)$.</p>
<ol type="a">
<li>Tìm toạ độ của vectơ $\overrightarrow{AB}$ và tính độ dài đoạn thẳng $AB$.</li>
<li>Tìm toạ độ điểm $M$ sao cho $\overrightarrow{AB}+\overrightarrow{CM}=\vec{0}$.</li>
<li>Tìm toạ độ điểm $N$ thuộc mặt phẳng $(Oxy)$ sao cho $A$, $B$, $N$ thẳng hàng.</li>
</ol>', N'<p><b>a)</b> $\overrightarrow{AB}=(1-4;-1-2;2+1)=(-3;-3;3)$, $AB=\sqrt{9+9+9}=3\sqrt3$.</p>
<p><b>b)</b> $\overrightarrow{AB}+\overrightarrow{CM}=\vec0\iff\overrightarrow{CM}=-\overrightarrow{AB}=(3;3;-3)$. Gọi $M(x;y;z)$: $x-0=3$, $y+2=3$, $z-3=-3$, suy ra $M(3;1;0)$.</p>
<p><b>c)</b> $N\in(Oxy)$ nên $N(x;y;0)$. $A$, $B$, $N$ thẳng hàng khi $\overrightarrow{AN}=t\overrightarrow{AB}$, tức $(x-4;y-2;1)=(-3t;-3t;3t)$.</p>
<p>Từ $1=3t$ được $t=\dfrac13$, suy ra $x-4=-1$, $y-2=-1$, nên $x=3$, $y=1$. Vậy $N(3;1;0)$ (trùng với $M$).</p>
<p><b>Đáp số:</b> a) $\overrightarrow{AB}=(-3;-3;3)$, $AB=3\sqrt3$; b) $M(3;1;0)$; c) $N(3;1;0)$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.42.</b> Hình 2.53 minh hoạ một chiếc đèn được treo cách trần nhà là 0,5 m, cách hai tường lần lượt là 1,2 m và 1,6 m. Hai bức tường vuông góc với nhau và cùng vuông góc với trần nhà. Người ta di chuyển chiếc đèn đó đến vị trí mới cách trần nhà là 0,4 m, cách hai tường đều là 1,5 m. <div><img src="/static/img/sgk/hinh-2-53.png" alt="Hình minh họa bài 2.42 (SGK)"></div></p>
<ol type="a">
<li>Lập một hệ trục toạ độ $Oxyz$ phù hợp và xác định toạ độ của chiếc đèn lúc đầu và sau khi di chuyển.</li>
<li>Vị trí mới của chiếc đèn cách vị trí ban đầu là bao nhiêu mét? (Làm tròn kết quả đến chữ số thập phân thứ nhất).</li>
</ol>', N'<p><b>a)</b> Chọn gốc $O$ là điểm gặp nhau của hai bức tường và trần nhà; trục $Ox$, $Oy$ là giao tuyến của trần nhà với hai bức tường, trục $Oz$ là giao tuyến của hai bức tường, hướng lên trên. Khi đó trần nhà là mặt phẳng $z=0$ (đơn vị mét) và phòng nằm ở phía $z\lt0$.</p>
<p>Lúc đầu đèn cách hai tường $1{,}2$ m và $1{,}6$ m, cách trần $0{,}5$ m nên đèn ở vị trí $D_1(1{,}2;\,1{,}6;\,-0{,}5)$.</p>
<p>Sau khi di chuyển, đèn cách trần $0{,}4$ m và cách hai tường đều $1{,}5$ m nên $D_2(1{,}5;\,1{,}5;\,-0{,}4)$.</p>
<p><b>b)</b> $\overrightarrow{D_1D_2}=(0{,}3;\,-0{,}1;\,0{,}1)$ nên</p>
<p>$D_1D_2=\sqrt{0{,}09+0{,}01+0{,}01}=\sqrt{0{,}11}\approx0{,}33\approx0{,}3$ (m).</p>
<p><b>Đáp số:</b> a) $(1{,}2;1{,}6;-0{,}5)$ và $(1{,}5;1{,}5;-0{,}4)$ (với hệ trục đã chọn); b) $\approx0{,}3$ m.</p>', 3, 0, 1, @t1);

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
INSERT INTO LessonMaterials (LessonId, MaterialType, Title, Url, ContentText, OrderIndex, CreatedBy) VALUES (@l, 'YOUTUBE', N'Video bài giảng: Bài 9. Khoảng biến thiên và khoảng tứ phân vị', 'https://www.youtube.com/watch?v=nne7K_Lh4uQ', NULL, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.1.</b> Thống kê số thẻ vàng của mỗi câu lạc bộ trong giải ngoại hạng Anh mùa giải 2021 – 2022 cho kết quả như sau:</p>
<p>101, 79, 79, 78, 75, 73, 68, 67, 67, 63,<br>63, 61, 60, 59, 57, 55, 55, 50, 47, 42.</p>
<ol type="a"><li>Hãy ghép nhóm dãy số liệu trên thành các nhóm có độ dài bằng nhau với nhóm đầu tiên là $[40; 50)$.</li>
<li>Tính khoảng biến thiên, khoảng tứ phân vị của mẫu số liệu gốc và mẫu số liệu ghép nhóm thu được ở câu a. Giá trị nào là giá trị chính xác? Giá trị nào là giá trị xấp xỉ?</li></ol>', N'<p><b>a)</b> Số liệu nhỏ nhất là 42, lớn nhất là 101. Ghép nhóm với độ dài 10, bắt đầu từ $[40;50)$:</p>
<table border="1"><tr><td>Nhóm</td><td>[40;50)</td><td>[50;60)</td><td>[60;70)</td><td>[70;80)</td><td>[80;90)</td><td>[90;100)</td><td>[100;110)</td></tr><tr><td>Số CLB</td><td>2</td><td>5</td><td>7</td><td>5</td><td>0</td><td>0</td><td>1</td></tr></table>
<p><b>b)</b> <i>Mẫu số liệu gốc</i> (n = 20, đã sắp xếp tăng dần): khoảng biến thiên $R = 101-42 = 59$. $Q_1$ là trung vị của 10 số đầu: $Q_1=\dfrac{55+57}{2}=56$; $Q_3$ là trung vị của 10 số sau: $Q_3=\dfrac{73+75}{2}=74$. Vậy $\Delta_Q = 74-56 = 18$.</p>
<p><i>Mẫu ghép nhóm</i>: $R = 110-40 = 70$.</p>
<p>$\dfrac{n}{4}=5$: nhóm chứa $Q_1$ là $[50;60)$ (tần số tích lũy trước đó là 2): $Q_1 = 50+\dfrac{5-2}{5}\cdot 10 = 56$.</p>
<p>$\dfrac{3n}{4}=15$: nhóm chứa $Q_3$ là $[70;80)$ (tích lũy trước đó là 14): $Q_3 = 70+\dfrac{15-14}{5}\cdot 10 = 72$. Vậy $\Delta_Q = 72-56=16$.</p>
<p>Giá trị tính từ mẫu số liệu gốc ($59$ và $18$) là <b>chính xác</b>; giá trị tính từ mẫu ghép nhóm ($70$ và $16$) là <b>xấp xỉ</b>.</p>
<p><b>Đáp số:</b> Gốc: $R=59$, $\Delta_Q=18$ (chính xác). Ghép nhóm: $R=70$, $\Delta_Q=16$ (xấp xỉ).</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.2.</b> Thu nhập theo tháng của người lao động ở hai nhà máy như sau:</p><table border="1"><tr><td>Thu nhập (triệu đồng)</td><td>[5; 8)</td><td>[8; 11)</td><td>[11; 14)</td><td>[14; 17)</td><td>[17; 20)</td></tr><tr><td>Số người của nhà máy A</td><td>20</td><td>35</td><td>45</td><td>35</td><td>20</td></tr><tr><td>Số người của nhà máy B</td><td>17</td><td>23</td><td>30</td><td>23</td><td>17</td></tr></table><p>Tính mức thu nhập trung bình của người lao động ở hai nhà máy trên. Dựa vào khoảng tứ phân vị, hãy xác định xem mức thu nhập của người lao động ở nhà máy nào biến động nhiều hơn.</p>', N'<p>Giá trị đại diện của các nhóm: $6,5;\ 9,5;\ 12,5;\ 15,5;\ 18,5$.</p>
<p><b>Thu nhập trung bình.</b> Nhà máy A (155 người): $\bar x_A=\dfrac{20\cdot6{,}5+35\cdot9{,}5+45\cdot12{,}5+35\cdot15{,}5+20\cdot18{,}5}{155}=12{,}5$ (triệu đồng). Nhà máy B (110 người): $\bar x_B=\dfrac{17\cdot6{,}5+23\cdot9{,}5+30\cdot12{,}5+23\cdot15{,}5+17\cdot18{,}5}{110}=12{,}5$ (triệu đồng).</p>
<p><b>Khoảng tứ phân vị.</b></p>
<p>Nhà máy A: $\dfrac n4=38{,}75$ thuộc nhóm $[8;11)$ (tích lũy trước: 20): $Q_1=8+\dfrac{38{,}75-20}{35}\cdot3\approx 9{,}61$. $\dfrac{3n}4=116{,}25$ thuộc nhóm $[14;17)$ (tích lũy trước: 100): $Q_3=14+\dfrac{116{,}25-100}{35}\cdot3\approx15{,}39$. Do đó $\Delta_Q^A\approx5{,}79$.</p>
<p>Nhà máy B: $\dfrac n4=27{,}5$ thuộc nhóm $[8;11)$ (tích lũy trước: 17): $Q_1=8+\dfrac{27{,}5-17}{23}\cdot3\approx9{,}37$. $\dfrac{3n}4=82{,}5$ thuộc nhóm $[14;17)$ (tích lũy trước: 70): $Q_3=14+\dfrac{82{,}5-70}{23}\cdot3\approx15{,}63$. Do đó $\Delta_Q^B\approx6{,}26$.</p>
<p>Vì $\Delta_Q^B \gt \Delta_Q^A$ nên thu nhập ở nhà máy B biến động nhiều hơn.</p>
<p><b>Đáp số:</b> Thu nhập trung bình ở cả hai nhà máy đều là 12,5 triệu đồng; thu nhập ở nhà máy B biến động nhiều hơn ($\Delta_Q\approx6{,}26$ so với $5{,}79$).</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.3.</b> Bảng sau đây cho biết chiều cao của các học sinh hai lớp 12A và 12B.</p><table border="1"><tr><td>Chiều cao (cm)</td><td>[145; 150)</td><td>[150; 155)</td><td>[155; 160)</td><td>[160; 165)</td><td>[165; 170)</td><td>[170; 175)</td></tr><tr><td>Số học sinh của lớp 12A</td><td>1</td><td>0</td><td>15</td><td>12</td><td>10</td><td>5</td></tr><tr><td>Số học sinh của lớp 12B</td><td>0</td><td>0</td><td>17</td><td>10</td><td>9</td><td>6</td></tr></table><ol type="a"><li>Tìm khoảng biến thiên, khoảng tứ phân vị cho các mẫu số liệu ghép nhóm về chiều cao của học sinh hai lớp 12A và 12B.</li>
<li>Để so sánh độ phân tán về chiều cao của học sinh hai lớp này ta nên dùng khoảng biến thiên hay khoảng tứ phân vị? Vì sao?</li></ol>', N'<p><b>a)</b> <i>Lớp 12A</i> (n = 43): nhóm đầu có dữ liệu là $[145;150)$, nhóm cuối là $[170;175)$, nên $R=175-145=30$ (cm).</p>
<p>$\dfrac n4=10{,}75$ thuộc nhóm $[155;160)$ (tích lũy trước: 1): $Q_1=155+\dfrac{10{,}75-1}{15}\cdot5=158{,}25$. $\dfrac{3n}4=32{,}25$ thuộc nhóm $[165;170)$ (tích lũy trước: 28): $Q_3=165+\dfrac{32{,}25-28}{10}\cdot5=167{,}125$. Vậy $\Delta_Q\approx8{,}88$ (cm).</p>
<p><i>Lớp 12B</i> (n = 42): nhóm có dữ liệu đầu tiên là $[155;160)$, cuối cùng là $[170;175)$, nên $R=175-155=20$ (cm).</p>
<p>$\dfrac n4=10{,}5$ thuộc nhóm $[155;160)$ (tích lũy trước: 0): $Q_1=155+\dfrac{10{,}5}{17}\cdot5\approx158{,}09$. $\dfrac{3n}4=31{,}5$ thuộc nhóm $[165;170)$ (tích lũy trước: 27): $Q_3=165+\dfrac{31{,}5-27}{9}\cdot5=167{,}5$. Vậy $\Delta_Q\approx9{,}41$ (cm).</p>
<p><b>b)</b> Nên dùng khoảng tứ phân vị, vì khoảng biến thiên chỉ dựa vào hai giá trị đầu mút nên bị ảnh hưởng mạnh bởi giá trị ngoại lệ (ở lớp 12A có 1 bạn rất thấp, thuộc nhóm $[145;150)$), còn khoảng tứ phân vị chỉ xét 50% số liệu ở giữa nên ổn định hơn. Theo khoảng tứ phân vị, chiều cao lớp 12B phân tán hơn lớp 12A một chút ($9{,}41 \gt 8{,}88$), trong khi khoảng biến thiên lại cho kết quả ngược lại ($20 \lt 30$).</p>
<p><b>Đáp số:</b> 12A: $R=30$, $\Delta_Q\approx8{,}88$; 12B: $R=20$, $\Delta_Q\approx9{,}41$. Nên dùng khoảng tứ phân vị.</p>', 2, 0, 1, @t1);
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
INSERT INTO LessonMaterials (LessonId, MaterialType, Title, Url, ContentText, OrderIndex, CreatedBy) VALUES (@l, 'YOUTUBE', N'Video bài giảng: Bài 10. Phương sai và độ lệch chuẩn', 'https://www.youtube.com/watch?v=Gf6JNhpM8xs', NULL, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.4.</b> Kiểm tra khối lượng của 30 bao xi măng (đơn vị: kg) được chọn ngẫu nhiên trước khi xuất xưởng cho kết quả như sau:</p>
<p>49,5 51,1 50,8 50,2 48,7 49,6 51,3 51,4 50,1 50,5<br>48,9 49,3 50,7 48,8 49,8 48,8 51,2 50,4 50,0 51,2<br>51,4 48,7 51,2 50,6 50,9 49,2 50,7 51,1 48,6 49,6.</p>
<ol type="a"><li>Thay mỗi dấu "?" bằng số thích hợp để hoàn thiện mẫu số liệu ghép nhóm sau:<table border="1"><tr><td>Nhóm số liệu</td><td>[48,5; 49)</td><td>[49; 49,5)</td><td>[49,5; 50)</td><td>[50; 50,5)</td><td>[50,5; 51)</td><td>[51; 51,5)</td></tr><tr><td>Số bao xi măng</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td></tr></table></li>
<li>Tính phương sai và độ lệch chuẩn của mẫu số liệu gốc và mẫu số liệu ghép nhóm. Giá trị nào là giá trị chính xác? Giá trị nào là giá trị xấp xỉ?</li></ol>', N'<p><b>a)</b> Đếm số bao trong từng nhóm:</p>
<table border="1"><tr><td>Nhóm</td><td>[48,5; 49)</td><td>[49; 49,5)</td><td>[49,5; 50)</td><td>[50; 50,5)</td><td>[50,5; 51)</td><td>[51; 51,5)</td></tr><tr><td>Số bao</td><td>6</td><td>2</td><td>4</td><td>4</td><td>6</td><td>8</td></tr></table>
<p>(Tổng: $6+2+4+4+6+8=30$.)</p>
<p><b>b)</b> <i>Mẫu số liệu gốc</i>: tổng 30 giá trị là $1504{,}3$ nên $\bar x=\dfrac{1504{,}3}{30}\approx50{,}143$. Phương sai $s^2=\dfrac1{30}\sum x_i^2-\bar x^2\approx0{,}872$, độ lệch chuẩn $s\approx0{,}934$.</p>
<p><i>Mẫu ghép nhóm</i>: giá trị đại diện lần lượt là $48{,}75;\ 49{,}25;\ 49{,}75;\ 50{,}25;\ 50{,}75;\ 51{,}25$.</p>
<p>$\bar x=\dfrac{6\cdot48{,}75+2\cdot49{,}25+4\cdot49{,}75+4\cdot50{,}25+6\cdot50{,}75+8\cdot51{,}25}{30}\approx50{,}183$.</p>
<p>$s^2=\dfrac{6\cdot48{,}75^2+2\cdot49{,}25^2+4\cdot49{,}75^2+4\cdot50{,}25^2+6\cdot50{,}75^2+8\cdot51{,}25^2}{30}-\bar x^2\approx0{,}862$, $s\approx0{,}929$.</p>
<p>Giá trị tính từ mẫu số liệu gốc là <b>chính xác</b>, giá trị tính từ mẫu ghép nhóm là <b>xấp xỉ</b>.</p>
<p><b>Đáp số:</b> a) 6; 2; 4; 4; 6; 8. b) Gốc: $s^2\approx0{,}872$, $s\approx0{,}934$ (chính xác). Ghép nhóm: $s^2\approx0{,}862$, $s\approx0{,}929$ (xấp xỉ).</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.5.</b> Tuổi thọ của một số linh kiện điện tử được sản xuất bởi hai phân xưởng được cho như sau:</p><table border="1"><tr><td>Tuổi thọ (năm)</td><td>[1,5; 2)</td><td>[2; 2,5)</td><td>[2,5; 3)</td><td>[3; 3,5)</td><td>[3,5; 4)</td></tr><tr><td>Số linh kiện của phân xưởng 1</td><td>4</td><td>9</td><td>13</td><td>8</td><td>6</td></tr><tr><td>Số linh kiện của phân xưởng 2</td><td>2</td><td>8</td><td>20</td><td>7</td><td>3</td></tr></table><p>Tính phương sai và độ lệch chuẩn của mỗi mẫu số liệu ghép nhóm và nhận xét về độ phân tán của tuổi thọ các linh kiện điện tử được sản xuất bởi mỗi phân xưởng.</p>', N'<p>Giá trị đại diện: $1{,}75;\ 2{,}25;\ 2{,}75;\ 3{,}25;\ 3{,}75$. Cả hai phân xưởng đều có 40 linh kiện.</p>
<p><b>Phân xưởng 1:</b> $\bar x_1=\dfrac{4\cdot1{,}75+9\cdot2{,}25+13\cdot2{,}75+8\cdot3{,}25+6\cdot3{,}75}{40}=2{,}7875$.</p>
<p>$s_1^2=\dfrac{4\cdot1{,}75^2+9\cdot2{,}25^2+13\cdot2{,}75^2+8\cdot3{,}25^2+6\cdot3{,}75^2}{40}-2{,}7875^2\approx0{,}355$, $s_1\approx0{,}596$.</p>
<p><b>Phân xưởng 2:</b> $\bar x_2=\dfrac{2\cdot1{,}75+8\cdot2{,}25+20\cdot2{,}75+7\cdot3{,}25+3\cdot3{,}75}{40}=2{,}7625$.</p>
<p>$s_2^2=\dfrac{2\cdot1{,}75^2+8\cdot2{,}25^2+20\cdot2{,}75^2+7\cdot3{,}25^2+3\cdot3{,}75^2}{40}-2{,}7625^2\approx0{,}219$, $s_2\approx0{,}468$.</p>
<p><b>Nhận xét:</b> Tuổi thọ trung bình của hai phân xưởng gần bằng nhau, nhưng $s_2 \lt s_1$ nên tuổi thọ linh kiện của phân xưởng 2 ít phân tán (đồng đều, ổn định) hơn phân xưởng 1.</p>
<p><b>Đáp số:</b> Phân xưởng 1: $s^2\approx0{,}355$, $s\approx0{,}596$; phân xưởng 2: $s^2\approx0{,}219$, $s\approx0{,}468$. Phân xưởng 2 đồng đều hơn.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.6.</b> Một nhóm 20 học sinh dùng một thiết bị đo đường kính của một nhân tế bào cho kết quả như sau:</p><table border="1"><tr><td>Kết quả đo (μm)</td><td>[4,5; 5)</td><td>[5; 5,5)</td><td>[5,5; 6)</td><td>[6; 6,5)</td></tr><tr><td>Số học sinh</td><td>3</td><td>8</td><td>7</td><td>2</td></tr></table><ol type="a"><li>Tính số trung bình và độ lệch chuẩn của mẫu số liệu ghép nhóm trên.</li>
<li>Số trung bình và độ lệch chuẩn cho biết thông tin gì?</li></ol>', N'<p><b>a)</b> Giá trị đại diện: $4{,}75;\ 5{,}25;\ 5{,}75;\ 6{,}25$; $n=20$.</p>
<p>Số trung bình: $\bar x=\dfrac{3\cdot4{,}75+8\cdot5{,}25+7\cdot5{,}75+2\cdot6{,}25}{20}=5{,}45$ (μm).</p>
<p>Phương sai: $s^2=\dfrac{3\cdot4{,}75^2+8\cdot5{,}25^2+7\cdot5{,}75^2+2\cdot6{,}25^2}{20}-5{,}45^2=0{,}185$.</p>
<p>Độ lệch chuẩn: $s=\sqrt{0{,}185}\approx0{,}43$ (μm).</p>
<p><b>b)</b> Số trung bình cho biết đường kính nhân tế bào đo được vào khoảng $5{,}45$ μm. Độ lệch chuẩn cho biết các kết quả đo lệch khỏi giá trị trung bình khoảng $0{,}43$ μm, tức là các kết quả đo khá tập trung quanh $5{,}45$ μm.</p>
<p><b>Đáp số:</b> a) $\bar x=5{,}45$ μm; $s\approx0{,}43$ μm. b) Như phần giải thích ở trên.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.7.</b> Thời gian chạy tập luyện cự li 100 mét của hai vận động viên A và B được cho trong bảng sau:</p><table border="1"><tr><td>Thời gian (giây)</td><td>[10; 10,3)</td><td>[10,3; 10,6)</td><td>[10,6; 10,9)</td><td>[10,9; 11,2)</td></tr><tr><td>Số lần chạy của A</td><td>2</td><td>10</td><td>5</td><td>3</td></tr><tr><td>Số lần chạy của B</td><td>3</td><td>7</td><td>9</td><td>6</td></tr></table><p>Dựa trên độ lệch chuẩn của các mẫu số liệu ghép nhóm, hãy cho biết vận động viên nào có thành tích luyện tập ổn định hơn.</p>', N'<p>Giá trị đại diện: $10{,}15;\ 10{,}45;\ 10{,}75;\ 11{,}05$.</p>
<p><b>Vận động viên A</b> ($n=20$): $\bar x_A=\dfrac{2\cdot10{,}15+10\cdot10{,}45+5\cdot10{,}75+3\cdot11{,}05}{20}=10{,}585$. $s_A^2=\dfrac{2\cdot10{,}15^2+10\cdot10{,}45^2+5\cdot10{,}75^2+3\cdot11{,}05^2}{20}-10{,}585^2\approx0{,}0673$, nên $s_A\approx0{,}259$.</p>
<p><b>Vận động viên B</b> ($n=25$): $\bar x_B=\dfrac{3\cdot10{,}15+7\cdot10{,}45+9\cdot10{,}75+6\cdot11{,}05}{25}=10{,}666$. $s_B^2=\dfrac{3\cdot10{,}15^2+7\cdot10{,}45^2+9\cdot10{,}75^2+6\cdot11{,}05^2}{25}-10{,}666^2\approx0{,}0829$, nên $s_B\approx0{,}288$.</p>
<p>Vì $s_A \lt s_B$ nên thành tích luyện tập của vận động viên A ổn định hơn.</p>
<p><b>Đáp số:</b> $s_A\approx0{,}259$, $s_B\approx0{,}288$; vận động viên A ổn định hơn.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.8.</b> Có nên dùng phương sai (hoặc độ lệch chuẩn) để so sánh độ phân tán của hai mẫu số liệu ghép nhóm trong mỗi trường hợp sau không? Tại sao?</p>
<ol type="a"><li>Các mẫu số liệu ghép nhóm về điểm thi tốt nghiệp môn Toán của học sinh hai trường trung học phổ thông có chất lượng tương đương.</li>
<li>Các mẫu số liệu ghép nhóm về doanh thu của 100 cửa hàng bán lẻ và doanh thu của 100 siêu thị.</li></ol>', N'<p>Phương sai và độ lệch chuẩn đo độ phân tán <i>tuyệt đối</i> quanh số trung bình, có cùng đơn vị với số liệu, nên chỉ so sánh trực tiếp được khi hai mẫu có cùng đơn vị đo và có số trung bình xấp xỉ nhau (cùng mặt bằng giá trị).</p>
<p><b>a)</b> <b>Nên.</b> Hai mẫu cùng là điểm thi môn Toán (cùng đơn vị, cùng thang điểm) của hai trường có chất lượng tương đương, tức là điểm trung bình xấp xỉ nhau, nên so sánh độ lệch chuẩn sẽ phản ánh đúng mức độ phân tán của điểm.</p>
<p><b>b)</b> <b>Không nên.</b> Doanh thu của siêu thị thường lớn hơn nhiều so với cửa hàng bán lẻ nên giá trị trung bình rất khác nhau; khi đó độ lệch chuẩn của siêu thị gần như luôn lớn hơn, không phản ánh mức độ biến động tương đối của doanh thu. Muốn so sánh cần dùng đại lượng khác, chẳng hạn hệ số biến thiên $\dfrac{s}{\bar x}$.</p>
<p><b>Đáp số:</b> a) Nên; b) Không nên (vì mặt bằng giá trị hai mẫu chênh lệch lớn).</p>', 3, 0, 1, @t1);
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
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.14.</b> Để đánh giá chất lượng một loại pin điện thoại mới, người ta ghi lại thời gian nghe nhạc liên tục của điện thoại được sạc đầy pin cho đến khi hết pin cho kết quả như sau:</p><table border="1"><tr><td>Thời gian (giờ)</td><td>[5; 5,5)</td><td>[5,5; 6)</td><td>[6; 6,5)</td><td>[6,5; 7)</td><td>[7; 7,5)</td></tr><tr><td>Số chiếc điện thoại (tần số)</td><td>2</td><td>8</td><td>15</td><td>10</td><td>5</td></tr></table><p>Tính khoảng biến thiên, khoảng tứ phân vị và độ lệch chuẩn của mẫu số liệu ghép nhóm trên.</p>', N'<p>Có $n=2+8+15+10+5=40$ chiếc. Tần số tích lũy qua các nhóm: $2;\ 10;\ 25;\ 35;\ 40$.</p>
<p><b>Khoảng biến thiên:</b> $R=7{,}5-5=2{,}5$ (giờ).</p>
<p><b>Khoảng tứ phân vị:</b> $\dfrac n4=10$. Nhóm đầu tiên có tần số tích lũy không nhỏ hơn 10 là $[5{,}5;6)$ (tích lũy trước đó: 2, tần số nhóm: 8), nên $Q_1=5{,}5+\dfrac{10-2}{8}\cdot0{,}5=6$.</p>
<p>$\dfrac{3n}4=30$ thuộc nhóm $[6{,}5;7)$ (tích lũy trước: 25, tần số: 10): $Q_3=6{,}5+\dfrac{30-25}{10}\cdot0{,}5=6{,}75$. Vậy $\Delta_Q=6{,}75-6=0{,}75$ (giờ).</p>
<p><b>Độ lệch chuẩn:</b> giá trị đại diện $5{,}25;\ 5{,}75;\ 6{,}25;\ 6{,}75;\ 7{,}25$.</p>
<p>$\bar x=\dfrac{2\cdot5{,}25+8\cdot5{,}75+15\cdot6{,}25+10\cdot6{,}75+5\cdot7{,}25}{40}=6{,}35$.</p>
<p>$s^2=\dfrac{2\cdot5{,}25^2+8\cdot5{,}75^2+15\cdot6{,}25^2+10\cdot6{,}75^2+5\cdot7{,}25^2}{40}-6{,}35^2=0{,}2775$, $s\approx0{,}527$ (giờ).</p>
<p><b>Đáp số:</b> $R=2{,}5$ giờ; $\Delta_Q=0{,}75$ giờ; $s\approx0{,}53$ giờ.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.15.</b> Người ta ghi lại tiền lãi của một số nhà đầu tư (với số tiền đầu tư như nhau), khi đầu tư vào hai lĩnh vực A và B cho kết quả như sau:</p><table border="1"><tr><td>Tiền lãi (triệu đồng)</td><td>[5; 10)</td><td>[10; 15)</td><td>[15; 20)</td><td>[20; 25)</td><td>[25; 30)</td></tr><tr><td>Số nhà đầu tư vào lĩnh vực A</td><td>2</td><td>5</td><td>8</td><td>6</td><td>4</td></tr><tr><td>Số nhà đầu tư vào lĩnh vực B</td><td>8</td><td>4</td><td>2</td><td>5</td><td>6</td></tr></table><ol type="a"><li>Về trung bình, đầu tư vào lĩnh vực nào đem lại tiền lãi cao hơn?</li>
<li>Tính độ lệch chuẩn cho các mẫu số liệu về tiền lãi của các nhà đầu tư ở hai lĩnh vực này và giải thích ý nghĩa của các số thu được.</li></ol>', N'<p>Giá trị đại diện: $7{,}5;\ 12{,}5;\ 17{,}5;\ 22{,}5;\ 27{,}5$. Mỗi lĩnh vực có 25 nhà đầu tư.</p>
<p><b>a)</b> Lĩnh vực A: $\bar x_A=\dfrac{2\cdot7{,}5+5\cdot12{,}5+8\cdot17{,}5+6\cdot22{,}5+4\cdot27{,}5}{25}=18{,}5$ (triệu đồng).</p>
<p>Lĩnh vực B: $\bar x_B=\dfrac{8\cdot7{,}5+4\cdot12{,}5+2\cdot17{,}5+5\cdot22{,}5+6\cdot27{,}5}{25}=16{,}9$ (triệu đồng).</p>
<p>Vì $18{,}5 \gt 16{,}9$ nên về trung bình, đầu tư vào lĩnh vực A đem lại tiền lãi cao hơn.</p>
<p><b>b)</b> $s_A^2=\dfrac{2\cdot7{,}5^2+5\cdot12{,}5^2+8\cdot17{,}5^2+6\cdot22{,}5^2+4\cdot27{,}5^2}{25}-18{,}5^2=34$, nên $s_A\approx5{,}83$.</p>
<p>$s_B^2=\dfrac{8\cdot7{,}5^2+4\cdot12{,}5^2+2\cdot17{,}5^2+5\cdot22{,}5^2+6\cdot27{,}5^2}{25}-16{,}9^2=64{,}64$, nên $s_B\approx8{,}04$.</p>
<p>Ý nghĩa: độ lệch chuẩn đo mức độ phân tán của tiền lãi quanh giá trị trung bình. $s_B \gt s_A$ nên tiền lãi ở lĩnh vực B biến động mạnh hơn (rủi ro cao hơn), còn lĩnh vực A vừa có lãi trung bình cao hơn vừa ổn định hơn.</p>
<p><b>Đáp số:</b> a) Lĩnh vực A ($18{,}5$ so với $16{,}9$ triệu đồng). b) $s_A\approx5{,}83$; $s_B\approx8{,}04$ (triệu đồng).</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.16.</b> Thành tích môn nhảy cao của các vận động viên tại một giải điền kinh dành cho học sinh trung học phổ thông như sau:</p><table border="1"><tr><td>Mức xà (cm)</td><td>[170; 172)</td><td>[172; 174)</td><td>[174; 176)</td><td>[176; 178)</td></tr><tr><td>Số vận động viên</td><td>3</td><td>10</td><td>6</td><td>1</td></tr></table><ol type="a"><li>Tính các số đặc trưng đo mức độ phân tán của mẫu số liệu ghép nhóm trên.</li>
<li>Độ phân tán của mẫu số liệu cho biết điều gì?</li></ol>', N'<p>Có $n=3+10+6+1=20$ vận động viên. Giá trị đại diện: $171;\ 173;\ 175;\ 177$.</p>
<p><b>a)</b> <i>Khoảng biến thiên:</i> $R=178-170=8$ (cm).</p>
<p><i>Khoảng tứ phân vị:</i> tích lũy qua các nhóm là $3;13;19;20$. $\dfrac n4=5$ thuộc nhóm $[172;174)$ (tích lũy trước: 3): $Q_1=172+\dfrac{5-3}{10}\cdot2=172{,}4$. $\dfrac{3n}4=15$ thuộc nhóm $[174;176)$ (tích lũy trước: 13): $Q_3=174+\dfrac{15-13}{6}\cdot2=\dfrac{524}{3}\approx174{,}67$. Vậy $\Delta_Q\approx2{,}27$ (cm).</p>
<p><i>Phương sai, độ lệch chuẩn:</i> $\bar x=\dfrac{3\cdot171+10\cdot173+6\cdot175+1\cdot177}{20}=173{,}5$; $s^2=\dfrac{3\cdot171^2+10\cdot173^2+6\cdot175^2+177^2}{20}-173{,}5^2=2{,}35$; $s\approx1{,}53$ (cm).</p>
<p><b>b)</b> Các số đặc trưng trên cho biết mức xà mà các vận động viên nhảy được khá đồng đều: đa số chênh nhau khoảng 1 đến 2 cm quanh mức trung bình $173{,}5$ cm. Các số đo càng nhỏ thì thành tích càng tập trung, độ phân tán càng thấp.</p>
<p><b>Đáp số:</b> a) $R=8$ cm; $\Delta_Q\approx2{,}27$ cm; $s^2=2{,}35$; $s\approx1{,}53$ cm. b) Thành tích khá đồng đều, độ phân tán thấp.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.17.</b> Trong bài thực hành đo hiệu điện thế của mạch điện, An và Bình đã dùng hai vôn kế khác nhau để đo, mỗi bạn tiến hành đo 10 lần cho kết quả như sau:</p><table border="1"><tr><td>Hiệu điện thế đo được (Vôn)</td><td>[3,85; 3,90)</td><td>[3,90; 3,95)</td><td>[3,95; 4,00)</td><td>[4,00; 4,05)</td></tr><tr><td>Số lần An đo</td><td>1</td><td>6</td><td>2</td><td>1</td></tr><tr><td>Số lần Bình đo</td><td>1</td><td>3</td><td>4</td><td>2</td></tr></table><p>Tính độ lệch chuẩn của các mẫu số liệu ghép nhóm cho kết quả đo của An và Bình. Từ đó kết luận xem vôn kế của bạn nào cho kết quả đo ổn định hơn.</p>', N'<p>Giá trị đại diện: $3{,}875;\ 3{,}925;\ 3{,}975;\ 4{,}025$; mỗi bạn đo 10 lần.</p>
<p><b>An:</b> $\bar x_A=\dfrac{3{,}875+6\cdot3{,}925+2\cdot3{,}975+4{,}025}{10}=3{,}94$. $s_A^2=\dfrac{3{,}875^2+6\cdot3{,}925^2+2\cdot3{,}975^2+4{,}025^2}{10}-3{,}94^2=0{,}001525$, nên $s_A\approx0{,}039$ (V).</p>
<p><b>Bình:</b> $\bar x_B=\dfrac{3{,}875+3\cdot3{,}925+4\cdot3{,}975+2\cdot4{,}025}{10}=3{,}96$. $s_B^2=\dfrac{3{,}875^2+3\cdot3{,}925^2+4\cdot3{,}975^2+2\cdot4{,}025^2}{10}-3{,}96^2=0{,}002025$, nên $s_B=0{,}045$ (V).</p>
<p>Vì $s_A \lt s_B$ nên các kết quả đo của An ít phân tán hơn, tức là vôn kế của An cho kết quả đo ổn định hơn.</p>
<p><b>Đáp số:</b> $s_A\approx0{,}039$ V; $s_B=0{,}045$ V; vôn kế của An ổn định hơn.</p>', 2, 0, 1, @t1);

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
INSERT INTO LessonMaterials (LessonId, MaterialType, Title, Url, ContentText, OrderIndex, CreatedBy) VALUES (@l, 'YOUTUBE', N'Video bài giảng: Bài 11. Nguyên hàm', 'https://www.youtube.com/watch?v=H8x4Cjktaq8', NULL, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.1.</b> Trong mỗi trường hợp sau, hàm số $F(x)$ có là một nguyên hàm của hàm số $f(x)$ trên khoảng tương ứng không? Vì sao?</p>
<ol type="a"><li>$F(x)=x\ln x$ và $f(x)=1+\ln x$ trên khoảng $(0;+\infty)$;</li>
<li>$F(x)=e^{\sin x}$ và $f(x)=e^{\cos x}$ trên $\mathbb{R}$.</li></ol>', N'<p>$F(x)$ là nguyên hàm của $f(x)$ trên khoảng $K$ khi và chỉ khi $F''(x)=f(x)$ với mọi $x\in K$.</p>
<ol type="a"><li>$F''(x)=(x\ln x)''=\ln x+x\cdot\dfrac{1}{x}=1+\ln x=f(x)$ với mọi $x\in(0;+\infty)$. Vậy <b>có</b>.</li>
<li>$F''(x)=(e^{\sin x})''=\cos x\cdot e^{\sin x}$. Biểu thức này không đồng nhất bằng $e^{\cos x}$ (chẳng hạn tại $x=0$: $F''(0)=1\cdot e^0=1$, còn $f(0)=e^1=e$). Vậy <b>không</b>.</li></ol>
<p><b>Đáp số:</b> a) Có; b) Không.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.2.</b> Tìm nguyên hàm của các hàm số sau:</p>
<ol type="a"><li>$f(x)=3x^2+2x-1$;</li>
<li>$f(x)=x^3-x$;</li>
<li>$f(x)=(2x+1)^2$;</li>
<li>$f(x)=\left(2x-\dfrac{1}{x}\right)^2$.</li></ol>', N'<ol type="a"><li>$\int(3x^2+2x-1)\,\mathrm{d}x=x^3+x^2-x+C$.</li>
<li>$\int(x^3-x)\,\mathrm{d}x=\dfrac{x^4}{4}-\dfrac{x^2}{2}+C$.</li>
<li>$(2x+1)^2=4x^2+4x+1$ nên nguyên hàm là $\dfrac{4x^3}{3}+2x^2+x+C$.</li>
<li>$\left(2x-\dfrac1x\right)^2=4x^2-4+\dfrac{1}{x^2}$ nên nguyên hàm là $\dfrac{4x^3}{3}-4x-\dfrac1x+C$ (trên mỗi khoảng không chứa 0).</li></ol>
<p><b>Đáp số:</b> a) $x^3+x^2-x+C$; b) $\dfrac{x^4}{4}-\dfrac{x^2}{2}+C$; c) $\dfrac{4x^3}{3}+2x^2+x+C$; d) $\dfrac{4x^3}{3}-4x-\dfrac1x+C$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.3.</b> Tìm:</p>
<ol type="a"><li>$\int\left(3\sqrt{x}+\dfrac{1}{\sqrt[3]{x}}\right)\mathrm{d}x$;</li>
<li>$\int\sqrt{x}\,(7x^2-3)\,\mathrm{d}x\ \ (x&gt;0)$;</li>
<li>$\int\dfrac{(2x+1)^2}{x^2}\,\mathrm{d}x$;</li>
<li>$\int\left(2^x+\dfrac{3}{x^2}\right)\mathrm{d}x$.</li></ol>', N'<p>Dùng $\int x^\alpha\mathrm{d}x=\dfrac{x^{\alpha+1}}{\alpha+1}+C$ và $\int a^x\mathrm{d}x=\dfrac{a^x}{\ln a}+C$.</p>
<ol type="a"><li>$3\sqrt x+x^{-1/3}$ cho $2x^{3/2}+\dfrac32x^{2/3}+C=2x\sqrt x+\dfrac32\sqrt[3]{x^2}+C$.</li>
<li>$\sqrt x(7x^2-3)=7x^{5/2}-3x^{1/2}$ cho $2x^{7/2}-2x^{3/2}+C$.</li>
<li>$\dfrac{(2x+1)^2}{x^2}=4+\dfrac4x+\dfrac1{x^2}$ cho $4x+4\ln|x|-\dfrac1x+C$.</li>
<li>$\int 2^x\mathrm{d}x=\dfrac{2^x}{\ln2}$, $\int\dfrac{3}{x^2}\mathrm{d}x=-\dfrac3x$, nên kết quả là $\dfrac{2^x}{\ln 2}-\dfrac3x+C$.</li></ol>
<p><b>Đáp số:</b> a) $2x\sqrt x+\dfrac32\sqrt[3]{x^2}+C$; b) $2x^{7/2}-2x^{3/2}+C$; c) $4x+4\ln|x|-\dfrac1x+C$; d) $\dfrac{2^x}{\ln 2}-\dfrac3x+C$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.4.</b> Tìm:</p>
<ol type="a"><li>$\int\left(2\cos x-\dfrac{3}{\sin^2 x}\right)\mathrm{d}x$;</li>
<li>$\int 4\sin^2\dfrac{x}{2}\,\mathrm{d}x$;</li>
<li>$\int\left(\sin\dfrac{x}{2}-\cos\dfrac{x}{2}\right)^2\mathrm{d}x$;</li>
<li>$\int(x+\tan^2 x)\,\mathrm{d}x$.</li></ol>', N'<ol type="a"><li>$\int\left(2\cos x-\dfrac{3}{\sin^2x}\right)\mathrm{d}x=2\sin x+3\cot x+C$ (vì $\int\dfrac{\mathrm{d}x}{\sin^2x}=-\cot x$).</li>
<li>$4\sin^2\dfrac x2=2(1-\cos x)$, nên $\int=2x-2\sin x+C$.</li>
<li>$\left(\sin\dfrac x2-\cos\dfrac x2\right)^2=1-2\sin\dfrac x2\cos\dfrac x2=1-\sin x$, nên $\int=x+\cos x+C$.</li>
<li>$\tan^2x=\dfrac{1}{\cos^2x}-1$, nên $x+\tan^2x=x-1+\dfrac1{\cos^2x}$ và $\int=\dfrac{x^2}{2}-x+\tan x+C$.</li></ol>
<p><b>Đáp số:</b> a) $2\sin x+3\cot x+C$; b) $2x-2\sin x+C$; c) $x+\cos x+C$; d) $\dfrac{x^2}2-x+\tan x+C$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.5.</b> Cho hàm số $y=f(x)$ xác định trên khoảng $(0;+\infty)$. Biết rằng, $f''(x)=2x+\dfrac{1}{x^2}$ với mọi $x\in(0;+\infty)$ và $f(1)=1$. Tính giá trị $f(4)$.</p>', N'<p>$f(x)=\int\left(2x+\dfrac1{x^2}\right)\mathrm{d}x=x^2-\dfrac1x+C$.</p>
<p>Từ $f(1)=1$: $1-1+C=1$ nên $C=1$. Vậy $f(x)=x^2-\dfrac1x+1$.</p>
<p>$f(4)=16-\dfrac14+1=\dfrac{67}{4}$.</p>
<p><b>Đáp số:</b> $f(4)=\dfrac{67}{4}=16{,}75$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.6.</b> Cho hàm số $y=f(x)$ có đồ thị là $(C)$. Xét điểm $M(x;f(x))$ thay đổi trên $(C)$. Biết rằng, hệ số góc của tiếp tuyến của đồ thị $(C)$ tại $M$ là $k_M=(x-1)^2$ và điểm $M$ trùng với gốc toạ độ khi nó nằm trên trục tung. Tìm biểu thức $f(x)$.</p>', N'<p>Hệ số góc tiếp tuyến là $f''(x)=(x-1)^2$, nên $f(x)=\dfrac{(x-1)^3}{3}+C$.</p>
<p>Điểm $M$ nằm trên trục tung ($x=0$) thì trùng gốc toạ độ, nghĩa là $f(0)=0$: $-\dfrac13+C=0$ nên $C=\dfrac13$.</p>
<p>Vậy $f(x)=\dfrac{(x-1)^3+1}{3}=\dfrac{x^3}{3}-x^2+x$.</p>
<p><b>Đáp số:</b> $f(x)=\dfrac{x^3}{3}-x^2+x$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.7.</b> Một viên đạn được bắn thẳng đứng lên trên từ mặt đất. Giả sử tại thời điểm $t$ giây (coi $t=0$ là thời điểm viên đạn được bắn lên), vận tốc của nó được cho bởi $v(t)=160-9{,}8t$ (m/s). Tìm độ cao của viên đạn (tính từ mặt đất):</p>
<ol type="a"><li>Sau $t=5$ giây;</li>
<li>Khi nó đạt độ cao lớn nhất (làm tròn kết quả đến chữ số thập phân thứ nhất của mét).</li></ol>', N'<p>Độ cao $h(t)$ là nguyên hàm của $v(t)$: $h(t)=\int(160-9{,}8t)\,\mathrm{d}t=160t-4{,}9t^2+C$. Tại $t=0$ viên đạn ở mặt đất nên $h(0)=0$, suy ra $C=0$ và $h(t)=160t-4{,}9t^2$.</p>
<ol type="a"><li>$h(5)=800-4{,}9\cdot25=677{,}5$ m.</li>
<li>Đạn đạt độ cao lớn nhất khi $v(t)=0$, tức $t=\dfrac{160}{9{,}8}=\dfrac{800}{49}\approx16{,}33$ s. Khi đó $h=\dfrac{160^2}{2\cdot9{,}8}\approx1306{,}1$ m.</li></ol>
<p><b>Đáp số:</b> a) $677{,}5$ m; b) khoảng $1306{,}1$ m.</p>', 3, 0, 1, @t1);
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
INSERT INTO LessonMaterials (LessonId, MaterialType, Title, Url, ContentText, OrderIndex, CreatedBy) VALUES (@l, 'YOUTUBE', N'Video bài giảng: Bài 12. Tích phân', 'https://www.youtube.com/watch?v=HZQpRGEb5_0', NULL, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.8.</b> Sử dụng ý nghĩa hình học của tích phân, tính:</p>
<ol type="a"><li>$\int_1^2(2x+1)\,\mathrm{d}x$;</li>
<li>$\int_{-3}^{3}\sqrt{9-x^2}\,\mathrm{d}x$.</li></ol>', N'<ol type="a"><li>Với $x\in[1;2]$, $2x+1\gt0$ nên tích phân bằng diện tích hình thang giới hạn bởi $y=2x+1$, $Ox$, $x=1$, $x=2$. Hai đáy là $y(1)=3$, $y(2)=5$, chiều cao là $1$: $S=\dfrac{(3+5)\cdot1}{2}=4$.</li>
<li>Đồ thị $y=\sqrt{9-x^2}$ là nửa đường tròn tâm $O$, bán kính $3$ nằm phía trên $Ox$, nên tích phân bằng diện tích nửa hình tròn: $\dfrac12\pi\cdot3^2=\dfrac{9\pi}{2}$.</li></ol>
<p><b>Đáp số:</b> a) $4$; b) $\dfrac{9\pi}{2}$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.9.</b> Cho $\int_0^3 f(x)\,\mathrm{d}x=5$ và $\int_0^3 g(x)\,\mathrm{d}x=2$. Tính:</p>
<ol type="a"><li>$\int_0^3[f(x)+g(x)]\,\mathrm{d}x$;</li>
<li>$\int_0^3[f(x)-g(x)]\,\mathrm{d}x$;</li>
<li>$\int_0^3 3f(x)\,\mathrm{d}x$;</li>
<li>$\int_0^3[2f(x)-3g(x)]\,\mathrm{d}x$.</li></ol>', N'<p>Dùng tính chất tuyến tính của tích phân.</p>
<ol type="a"><li>$5+2=7$.</li>
<li>$5-2=3$.</li>
<li>$3\cdot5=15$.</li>
<li>$2\cdot5-3\cdot2=10-6=4$.</li></ol>
<p><b>Đáp số:</b> a) $7$; b) $3$; c) $15$; d) $4$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.10.</b> Tính:</p>
<ol type="a"><li>$\int_0^3(3x-1)^2\,\mathrm{d}x$;</li>
<li>$\int_0^{\frac{\pi}{2}}(1+\sin x)\,\mathrm{d}x$;</li>
<li>$\int_0^1(e^{2x}+3x^2)\,\mathrm{d}x$;</li>
<li>$\int_1^2|2x+1|\,\mathrm{d}x$.</li></ol>', N'<ol type="a"><li>$(3x-1)^2=9x^2-6x+1$, nên $\int_0^3=\left[3x^3-3x^2+x\right]_0^3=81-27+3=57$.</li>
<li>$\int_0^{\pi/2}(1+\sin x)\,\mathrm{d}x=\left[x-\cos x\right]_0^{\pi/2}=\dfrac\pi2-(0-1)=\dfrac\pi2+1$.</li>
<li>$\int_0^1(e^{2x}+3x^2)\,\mathrm{d}x=\left[\dfrac{e^{2x}}2+x^3\right]_0^1=\dfrac{e^2}{2}+1-\dfrac12=\dfrac{e^2+1}{2}$.</li>
<li>Với $x\in[1;2]$, $2x+1\gt0$ nên $\int_1^2(2x+1)\,\mathrm{d}x=\left[x^2+x\right]_1^2=6-2=4$.</li></ol>
<p><b>Đáp số:</b> a) $57$; b) $\dfrac\pi2+1$; c) $\dfrac{e^2+1}{2}$; d) $4$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.11.</b> Một vật chuyển động dọc theo một đường thẳng sao cho vận tốc của nó tại thời điểm $t$ (giây) là $v(t)=t^2-t-6$ (m/s).</p>
<ol type="a"><li>Tìm độ dịch chuyển của vật trong khoảng thời gian $1\le t\le 4$, tức là tính $\int_1^4 v(t)\,\mathrm{d}t$.</li>
<li>Tìm tổng quãng đường vật đi được trong khoảng thời gian $1\le t\le 4$, tức là tính $\int_1^4|v(t)|\,\mathrm{d}t$.</li></ol>', N'<p>Một nguyên hàm của $v(t)$ là $F(t)=\dfrac{t^3}{3}-\dfrac{t^2}{2}-6t$.</p>
<ol type="a"><li>Độ dịch chuyển: $\int_1^4v\,\mathrm{d}t=F(4)-F(1)=-\dfrac{32}{3}-\left(-\dfrac{37}{6}\right)=-\dfrac92$ m.</li>
<li>$v(t)=(t-3)(t+2)$ nên $v\le0$ trên $[1;3]$ và $v\ge0$ trên $[3;4]$. Do đó
$$\int_1^4|v|\,\mathrm{d}t=-\int_1^3v\,\mathrm{d}t+\int_3^4v\,\mathrm{d}t=-(F(3)-F(1))+(F(4)-F(3)).$$
Với $F(3)=-\dfrac{27}{2}$: $-\left(-\dfrac{27}2+\dfrac{37}6\right)=\dfrac{22}{3}$ và $-\dfrac{32}{3}+\dfrac{27}{2}=\dfrac{17}{6}$. Tổng: $\dfrac{22}3+\dfrac{17}6=\dfrac{61}{6}$ m.</li></ol>
<p><b>Đáp số:</b> a) $-\dfrac92$ m (vật dịch chuyển $4{,}5$ m theo chiều âm); b) $\dfrac{61}{6}\approx10{,}17$ m.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.12.</b> Giả sử lợi nhuận biên (tính bằng triệu đồng) của một sản phẩm được mô hình hoá bằng công thức
$$P''(x)=-0{,}0005x+12{,}2.$$
Ở đây $P(x)$ là lợi nhuận (tính bằng triệu đồng) khi bán được $x$ đơn vị sản phẩm.</p>
<ol type="a"><li>Tìm sự thay đổi của lợi nhuận khi doanh số tăng từ 100 lên 101 đơn vị sản phẩm.</li>
<li>Tìm sự thay đổi của lợi nhuận khi doanh số tăng từ 100 lên 110 đơn vị sản phẩm.</li></ol>', N'<p>Sự thay đổi lợi nhuận khi doanh số tăng từ $a$ đến $b$ là $P(b)-P(a)=\int_a^bP''(x)\,\mathrm{d}x$.</p>
<ol type="a"><li>$\int_{100}^{101}(-0{,}0005x+12{,}2)\,\mathrm{d}x=\left[-0{,}00025x^2+12{,}2x\right]_{100}^{101}=-0{,}00025\cdot201+12{,}2=12{,}14975$ (triệu đồng).</li>
<li>$\int_{100}^{110}(-0{,}0005x+12{,}2)\,\mathrm{d}x=-0{,}00025\cdot(110^2-100^2)+12{,}2\cdot10=-0{,}525+122=121{,}475$ (triệu đồng).</li></ol>
<p><b>Đáp số:</b> a) tăng $12{,}14975$ triệu đồng; b) tăng $121{,}475$ triệu đồng.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.13.</b> Giả sử vận tốc $v$ của dòng máu ở khoảng cách $r$ từ tâm của động mạch bán kính $R$ không đổi, có thể được mô hình hoá bởi công thức
$$v=k\left(R^2-r^2\right),$$
trong đó $k$ là một hằng số. Tìm vận tốc trung bình (đối với $r$) của động mạch trong khoảng $0\le r\le R$. So sánh vận tốc trung bình với vận tốc lớn nhất.</p>', N'<p>Vận tốc trung bình theo $r$ trên $[0;R]$ là $\bar v=\dfrac{1}{R-0}\int_0^Rk(R^2-r^2)\,\mathrm{d}r$.</p>
<p>$\int_0^Rk(R^2-r^2)\,\mathrm{d}r=k\left[R^2r-\dfrac{r^3}{3}\right]_0^R=\dfrac{2kR^3}{3}$, nên $\bar v=\dfrac{2kR^2}{3}$.</p>
<p>Vận tốc lớn nhất đạt tại $r=0$ (tâm động mạch, với $k\gt0$): $v_{\max}=kR^2$.</p>
<p>So sánh: $\bar v=\dfrac23v_{\max}$.</p>
<p><b>Đáp số:</b> $\bar v=\dfrac{2kR^2}{3}$, bằng $\dfrac23$ vận tốc lớn nhất $kR^2$.</p>', 3, 0, 1, @t1);
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
INSERT INTO LessonMaterials (LessonId, MaterialType, Title, Url, ContentText, OrderIndex, CreatedBy) VALUES (@l, 'YOUTUBE', N'Video bài giảng: Bài 13. Ứng dụng hình học của tích phân', 'https://www.youtube.com/watch?v=hJdOTOpkVCQ', NULL, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.14.</b> Tính diện tích của hình phẳng được tô màu trong Hình 4.29.</p>
<p><div><img src="/static/img/sgk/hinh-4-29.png" alt="Hình minh họa bài 4.14 (SGK)"></div></p>', N'<p>Từ hình: parabol $y=5x-x^2$ và đường thẳng $y=x$ cắt nhau tại $O(0;0)$ và $(4;4)$ (giải $5x-x^2=x\iff x=0$ hoặc $x=4$). Trên $[0;4]$ parabol nằm trên đường thẳng.</p>
<p>$S=\int_0^4\left[(5x-x^2)-x\right]\mathrm{d}x=\int_0^4(4x-x^2)\,\mathrm{d}x=\left[2x^2-\dfrac{x^3}{3}\right]_0^4=32-\dfrac{64}{3}=\dfrac{32}{3}$.</p>
<p><b>Đáp số:</b> $\dfrac{32}{3}$ (đơn vị diện tích).</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.15.</b> Tính diện tích của hình phẳng giới hạn bởi các đường:</p>
<ol type="a"><li>$y=e^x,\ y=x^2-1,\ x=-1,\ x=1$;</li>
<li>$y=\sin x,\ y=x,\ x=\dfrac{\pi}{2},\ x=\pi$;</li>
<li>$y=9-x^2,\ y=2x^2,\ x=-\sqrt{3},\ x=\sqrt{3}$;</li>
<li>$y=\sqrt{x},\ y=x^2,\ x=0,\ x=1$.</li></ol>', N'<p>Dùng $S=\int_a^b|f(x)-g(x)|\,\mathrm{d}x$, xét dấu hiệu trên đoạn đang xét.</p>
<ol type="a"><li>Trên $[-1;1]$: $e^x\gt0\ge x^2-1$. $S=\int_{-1}^1(e^x-x^2+1)\,\mathrm{d}x=\left[e^x-\dfrac{x^3}3+x\right]_{-1}^1=e-\dfrac1e+\dfrac43$.</li>
<li>Trên $\left[\dfrac\pi2;\pi\right]$: $x\gt\sin x$. $S=\int_{\pi/2}^{\pi}(x-\sin x)\,\mathrm{d}x=\left[\dfrac{x^2}{2}+\cos x\right]_{\pi/2}^{\pi}=\dfrac{3\pi^2}{8}-1$.</li>
<li>$9-x^2\ge2x^2\iff x^2\le3$, nên trên $[-\sqrt3;\sqrt3]$: $S=\int_{-\sqrt3}^{\sqrt3}(9-3x^2)\,\mathrm{d}x=\left[9x-x^3\right]_{-\sqrt3}^{\sqrt3}=2(9\sqrt3-3\sqrt3)=12\sqrt3$.</li>
<li>Trên $[0;1]$: $\sqrt x\ge x^2$. $S=\int_0^1(\sqrt x-x^2)\,\mathrm{d}x=\left[\dfrac23x^{3/2}-\dfrac{x^3}{3}\right]_0^1=\dfrac13$.</li></ol>
<p><b>Đáp số:</b> a) $e-\dfrac1e+\dfrac43$; b) $\dfrac{3\pi^2}{8}-1$; c) $12\sqrt3$; d) $\dfrac13$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.16.</b> Các nhà kinh tế sử dụng đường cong Lorenz để minh hoạ sự phân phối thu nhập trong một quốc gia. Gọi $x$ là đại diện cho phần trăm số gia đình trong một quốc gia và $y$ là phần trăm tổng thu nhập. Đường $y=x$ sẽ đại diện cho một quốc gia mà các gia đình có thu nhập như nhau. Đường cong Lorenz $y=f(x)$ biểu thị phân phối thu nhập thực tế. Diện tích hình phẳng giới hạn bởi hai đường này, với $0\le x\le 100$, biểu thị &ldquo;sự bất bình đẳng về thu nhập&rdquo; của một quốc gia. Năm 2005, đường cong Lorenz của Hoa Kỳ có thể được mô hình hoá bởi hàm số
$$y=\left(0{,}00061x^2+0{,}0218x+1\,723\right)^2,\quad 0\le x\le 100,$$
trong đó $x$ được tính từ các gia đình nghèo nhất đến giàu có nhất (Theo <i>R. Larson, Brief Calculus: An Applied Approach, 8th edition, Cengage Learning, 2009</i>).</p>
<p>Tìm sự bất bình đẳng về thu nhập của Hoa Kỳ vào năm 2005.</p>', N'<p><i>Giả thiết:</i> số hạng "1 723" trong đề là $1{,}723$ (dấu phẩy thập phân bị in sai), tức $y=(0{,}00061x^2+0{,}0218x+1{,}723)^2$. Kiểm tra: $y(100)\approx100{,}06\approx100$, đúng ý nghĩa đường Lorenz (100% gia đình có 100% thu nhập).</p>
<p>Sự bất bình đẳng thu nhập là diện tích hình phẳng giới hạn bởi $y=x$ và đường cong, $0\le x\le100$. Trên đoạn này đường cong nằm dưới đường $y=x$ (chẳng hạn $y(50)\approx18{,}8\lt50$), nên
$$S=\int_0^{100}\left[x-(0{,}00061x^2+0{,}0218x+1{,}723)^2\right]\mathrm{d}x.$$</p>
<p>Khai triển: $(\dots)^2=3{,}721\cdot10^{-7}x^4+2{,}6596\cdot10^{-5}x^3+2{,}5773\cdot10^{-3}x^2+0{,}0751228x+2{,}968729$. Lấy tích phân từ $0$ đến $100$: $\int_0^{100}x\,\mathrm{d}x=5000$ và $\int_0^{100}y\,\mathrm{d}x\approx2940{,}69$.</p>
<p>$S\approx5000-2940{,}69=2059{,}31$.</p>
<p><b>Đáp số:</b> $S\approx2059{,}3$ (đơn vị diện tích, tính theo thang phần trăm; tương đương khoảng $0{,}206$ nếu quy về thang $[0;1]$).</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.17.</b> Tính thể tích của khối tròn xoay sinh ra khi quay hình phẳng giới hạn bởi các đường sau xung quanh trục $Ox$: $y=2x-x^2,\ y=0,\ x=0,\ x=2$.</p>', N'<p>Trên $[0;2]$, $2x-x^2\ge0$. Thể tích:
$$V=\pi\int_0^2(2x-x^2)^2\mathrm{d}x=\pi\int_0^2(4x^2-4x^3+x^4)\,\mathrm{d}x=\pi\left[\dfrac{4x^3}{3}-x^4+\dfrac{x^5}{5}\right]_0^2=\pi\left(\dfrac{32}{3}-16+\dfrac{32}{5}\right)=\dfrac{16\pi}{15}.$$</p>
<p><b>Đáp số:</b> $\dfrac{16\pi}{15}$ (đơn vị thể tích).</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.18.</b> Khối chỏm cầu có bán kính $R$ và chiều cao $h\ (0&lt;h\le R)$ sinh ra khi quay hình phẳng giới hạn bởi cung tròn có phương trình $y=\sqrt{R^2-x^2}$, trục hoành và hai đường thẳng $x=R-h,\ x=R$ xung quanh trục $Ox$ (H.4.30). Tính thể tích của khối chỏm cầu này.</p>
<p><div><img src="/static/img/sgk/hinh-4-30.png" alt="Hình minh họa bài 4.18 (SGK)"></div></p>', N'<p>Thể tích khối chỏm cầu:
$$V=\pi\int_{R-h}^{R}\left(R^2-x^2\right)\mathrm{d}x=\pi\left[R^2x-\dfrac{x^3}{3}\right]_{R-h}^{R}=\pi\left[\dfrac{2R^3}{3}-R^2(R-h)+\dfrac{(R-h)^3}{3}\right].$$</p>
<p>Khai triển $(R-h)^3=R^3-3R^2h+3Rh^2-h^3$, rút gọn được $V=\pi\left(Rh^2-\dfrac{h^3}{3}\right)=\dfrac{\pi h^2(3R-h)}{3}$.</p>
<p>Kiểm tra: $h=R$ cho nửa cầu $V=\dfrac{2\pi R^3}{3}$.</p>
<p><b>Đáp số:</b> $V=\dfrac{\pi h^2(3R-h)}{3}$.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.19.</b> Cho tam giác vuông $OAB$ có cạnh $OA=a$ nằm trên trục $Ox$ và $\widehat{AOB}=\alpha\ \left(0&lt;\alpha\le\dfrac{\pi}{4}\right)$. Gọi $\mathcal{B}$ là khối tròn xoay sinh ra khi quay miền tam giác $OAB$ xung quanh trục $Ox$ (H.4.31).</p>
<ol type="a"><li>Tính thể tích $V$ của $\mathcal{B}$ theo $a$ và $\alpha$.</li>
<li>Tìm $\alpha$ sao cho thể tích $V$ lớn nhất.</li></ol>
<p><div><img src="/static/img/sgk/hinh-4-31.png" alt="Hình minh họa bài 4.19 (SGK)"></div></p>', N'<p>Từ hình, tam giác vuông tại $A$ nên $AB=OA\tan\alpha=a\tan\alpha$. Quay quanh $Ox$ ta được hình nón đỉnh $O$, bán kính đáy $AB$, chiều cao $OA=a$.</p>
<ol type="a"><li>$V=\dfrac13\pi\cdot AB^2\cdot OA=\dfrac{\pi a^3\tan^2\alpha}{3}$. (Cũng có thể tính $V=\pi\int_0^a(x\tan\alpha)^2\mathrm{d}x=\pi\tan^2\alpha\cdot\dfrac{a^3}{3}$.)</li>
<li>Với $a$ cố định, trên $\left(0;\dfrac\pi4\right]$ hàm $\tan\alpha$ dương và đồng biến nên $V$ tăng theo $\alpha$. Vậy $V$ lớn nhất khi $\alpha=\dfrac\pi4$, khi đó $V_{\max}=\dfrac{\pi a^3}{3}$.</li></ol>
<p><b>Đáp số:</b> a) $V=\dfrac{\pi a^3\tan^2\alpha}{3}$; b) $\alpha=\dfrac\pi4$.</p>', 3, 0, 1, @t1);
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
<li>$y=x\sqrt{x}+3\cos x-\dfrac{2}{\sin^2 x}$.</li></ol>', N'<ol type="a"><li>$\int\left(2^x-\dfrac1x\right)\mathrm{d}x=\dfrac{2^x}{\ln2}-\ln|x|+C$.</li>
<li>$x\sqrt x=x^{3/2}$ có nguyên hàm $\dfrac25x^{5/2}$; $\int3\cos x\,\mathrm{d}x=3\sin x$; $\int-\dfrac{2}{\sin^2x}\mathrm{d}x=2\cot x$. Họ nguyên hàm: $\dfrac25x^2\sqrt x+3\sin x+2\cot x+C$.</li></ol>
<p><b>Đáp số:</b> a) $\dfrac{2^x}{\ln2}-\ln|x|+C$; b) $\dfrac25x^2\sqrt x+3\sin x+2\cot x+C$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.29.</b> Tìm một nguyên hàm $F(x)$ của hàm số $f(x)=2\cos x+\dfrac{1}{\sin^2 x}$ thoả mãn điều kiện $F\left(\dfrac{\pi}{4}\right)=-1$.</p>', N'<p>$F(x)=\int\left(2\cos x+\dfrac{1}{\sin^2x}\right)\mathrm{d}x=2\sin x-\cot x+C$.</p>
<p>$F\left(\dfrac\pi4\right)=2\cdot\dfrac{\sqrt2}{2}-1+C=\sqrt2-1+C=-1$ nên $C=-\sqrt2$.</p>
<p><b>Đáp số:</b> $F(x)=2\sin x-\cot x-\sqrt2$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.30.</b> Một viên đạn được bắn lên từ mặt đất theo phương thẳng đứng với vận tốc ban đầu là 30 m/s. Viên đạn chuyển động với gia tốc $a=-9{,}8$ m/s$^2$. Tìm vận tốc của viên đạn ở thời điểm 2 giây.</p>', N'<p>Vận tốc là nguyên hàm của gia tốc: $v(t)=\int(-9{,}8)\,\mathrm{d}t=-9{,}8t+C$. Vận tốc ban đầu $v(0)=30$ nên $C=30$, $v(t)=30-9{,}8t$.</p>
<p>$v(2)=30-19{,}6=10{,}4$ m/s (dương, đạn vẫn đang đi lên).</p>
<p><b>Đáp số:</b> $10{,}4$ m/s.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.31.</b> Cá hồi Thái Bình Dương đến mùa sinh sản thường bơi từ biển ngược dòng vào sông và đến thượng nguồn các dòng sông để đẻ trứng. Giả sử cá bơi ngược dòng sông với vận tốc là $v(t)=-\dfrac{2t}{5}+4$ (km/h). Nếu coi thời điểm ban đầu $t=0$ là lúc cá bắt đầu bơi vào dòng sông thì khoảng cách xa nhất mà con cá có thể bơi được là bao nhiêu?</p>', N'<p>Cá bơi tới khi $v(t)=0$: $-\dfrac{2t}{5}+4=0\iff t=10$ (giờ). Với $0\le t\le10$, $v(t)\ge0$ nên quãng đường xa nhất là
$$s=\int_0^{10}\left(-\dfrac{2t}5+4\right)\mathrm{d}t=\left[-\dfrac{t^2}{5}+4t\right]_0^{10}=-20+40=20\ \text{(km)}.$$</p>
<p><b>Đáp số:</b> $20$ km.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.32.</b> Tính các tích phân sau:</p>
<ol type="a"><li>$\int_1^4\left(x^3-2\sqrt{x}\right)\mathrm{d}x$;</li>
<li>$\int_0^{\frac{\pi}{2}}(\cos x-\sin x)\,\mathrm{d}x$;</li>
<li>$\int_{\frac{\pi}{6}}^{\frac{\pi}{4}}\dfrac{\mathrm{d}x}{\sin^2 x}$;</li>
<li>$\int_1^{16}\dfrac{x-1}{\sqrt{x}}\,\mathrm{d}x$.</li></ol>', N'<ol type="a"><li>$\int_1^4\left(x^3-2\sqrt x\right)\mathrm{d}x=\left[\dfrac{x^4}4-\dfrac43x^{3/2}\right]_1^4=\dfrac{255}{4}-\dfrac43\cdot7=\dfrac{653}{12}$.</li>
<li>$\left[\sin x+\cos x\right]_0^{\pi/2}=(1+0)-(0+1)=0$.</li>
<li>$\left[-\cot x\right]_{\pi/6}^{\pi/4}=-1+\sqrt3=\sqrt3-1$.</li>
<li>$\dfrac{x-1}{\sqrt x}=\sqrt x-\dfrac1{\sqrt x}$, nguyên hàm $\dfrac23x^{3/2}-2\sqrt x$. Giá trị: $\left(\dfrac{128}{3}-8\right)-\left(\dfrac23-2\right)=\dfrac{104}{3}+\dfrac43=36$.</li></ol>
<p><b>Đáp số:</b> a) $\dfrac{653}{12}$; b) $0$; c) $\sqrt3-1$; d) $36$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.33.</b> Tính diện tích hình phẳng giới hạn bởi các đường $y=e^x,\ y=x,\ x=0$ và $x=1$.</p>', N'<p>Trên $[0;1]$ có $e^x\ge1\gt x$, nên
$$S=\int_0^1(e^x-x)\,\mathrm{d}x=\left[e^x-\dfrac{x^2}{2}\right]_0^1=e-\dfrac12-1=e-\dfrac32.$$</p>
<p><b>Đáp số:</b> $e-\dfrac32\approx1{,}22$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.34.</b> Tính thể tích của khối tròn xoay sinh ra khi quay hình phẳng giới hạn bởi các đường sau xung quanh trục $Ox$:</p>
<ol type="a"><li>$y=1-x^2,\ y=0,\ x=-1,\ x=1$;</li>
<li>$y=\sqrt{25-x^2},\ y=0,\ x=2,\ x=4$.</li></ol>', N'<ol type="a"><li>$V=\pi\int_{-1}^1(1-x^2)^2\mathrm{d}x=\pi\int_{-1}^1(1-2x^2+x^4)\,\mathrm{d}x=\pi\left[x-\dfrac{2x^3}3+\dfrac{x^5}5\right]_{-1}^1=\pi\cdot2\left(1-\dfrac23+\dfrac15\right)=\dfrac{16\pi}{15}$.</li>
<li>$V=\pi\int_2^4\left(25-x^2\right)\mathrm{d}x=\pi\left[25x-\dfrac{x^3}3\right]_2^4=\pi\left[\left(100-\dfrac{64}3\right)-\left(50-\dfrac83\right)\right]=\dfrac{94\pi}{3}$.</li></ol>
<p><b>Đáp số:</b> a) $\dfrac{16\pi}{15}$; b) $\dfrac{94\pi}{3}$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.35.</b> Nghệ thuật làm gốm có lịch sử phát triển lâu đời và vẫn còn tồn tại cho đến ngày nay. Giả sử một bình gốm có mặt trong của bình là một mặt tròn xoay sinh ra khi cho phần đồ thị của hàm số $y=\dfrac{1}{175}x^2+\dfrac{3}{35}x+5\ (0\le x\le 30)$ ($x,y$ tính theo cm) quay tròn quanh bệ gốm có trục trùng với trục hoành $Ox$. Hỏi để hoàn thành bình gốm đó ta cần sử dụng bao nhiêu centimét khối đất sét, biết rằng bình gốm đó có độ dày không đổi là 1 cm?</p>', N'<p>Mặt trong của bình là mặt tròn xoay sinh bởi $y=f(x)=\dfrac{x^2}{175}+\dfrac{3x}{35}+5$, nên bán kính trong tại hoành độ $x$ là $f(x)$; vì bình dày $1$ cm nên bán kính ngoài là $f(x)+1$. Lượng đất sét là thể tích phần giữa hai mặt:
$$V=\pi\int_0^{30}\left[(f(x)+1)^2-f(x)^2\right]\mathrm{d}x=\pi\int_0^{30}\left(2f(x)+1\right)\mathrm{d}x.$$</p>
<p>Tính $\int_0^{30}f(x)\,\mathrm{d}x=\left[\dfrac{x^3}{525}+\dfrac{3x^2}{70}+5x\right]_0^{30}=\dfrac{360}{7}+\dfrac{270}{7}+150=240$.</p>
<p>Vậy $V=\pi(2\cdot240+30)=510\pi\approx1602{,}2$ cm$^3$.</p>
<p><b>Đáp số:</b> $510\pi\approx1602$ cm$^3$ đất sét.</p>', 3, 0, 1, @t1);

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
INSERT INTO LessonMaterials (LessonId, MaterialType, Title, Url, ContentText, OrderIndex, CreatedBy) VALUES (@l, 'YOUTUBE', N'Video bài giảng: Bài 14. Phương trình mặt phẳng', 'https://www.youtube.com/watch?v=6FvHP8YzQA0', NULL, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.1.</b> Trong không gian $Oxyz$, viết phương trình mặt phẳng đi qua điểm $M(1;2;-1)$ và vuông góc với trục $Ox$.</p>', N'<p>Mặt phẳng vuông góc với trục $Ox$ nhận vectơ chỉ phương của $Ox$ là $\vec i=(1;0;0)$ làm vectơ pháp tuyến.</p><p>Phương trình: $1\cdot(x-1)+0\cdot(y-2)+0\cdot(z+1)=0$, tức $x-1=0$.</p><p><b>Đáp số:</b> $x-1=0$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.2.</b> Trong không gian $Oxyz$, cho hình hộp $ABCD.A''B''C''D''$, với $A(1;-1;3)$, $B(0;2;4)$, $D(2;-1;1)$, $A''(0;1;2)$.</p><ol type="a"><li>Tính toạ độ các điểm $C$, $B''$, $D''$.</li><li>Viết phương trình mặt phẳng $(CB''D'')$.</li></ol>', N'<p>a) Vì $ABCD.A''B''C''D''$ là hình hộp nên $\overrightarrow{BC}=\overrightarrow{AD}$ và $\overrightarrow{BB''}=\overrightarrow{DD''}=\overrightarrow{AA''}$.</p><p>Ta có $\overrightarrow{AD}=(1;0;-2)$, $\overrightarrow{AA''}=(-1;2;-1)$.</p><ul><li>$C=B+\overrightarrow{AD}=(1;2;2)$.</li><li>$B''=B+\overrightarrow{AA''}=(-1;4;3)$.</li><li>$D''=D+\overrightarrow{AA''}=(1;1;0)$.</li></ul><p>b) $\overrightarrow{CB''}=(-2;2;1)$, $\overrightarrow{CD''}=(0;-1;-2)$. Vectơ pháp tuyến $\vec n=[\overrightarrow{CB''},\overrightarrow{CD''}]=(-3;-4;2)$, chọn $\vec n=(3;4;-2)$.</p><p>Mặt phẳng đi qua $C(1;2;2)$: $3(x-1)+4(y-2)-2(z-2)=0$, tức $3x+4y-2z-7=0$.</p><p>Kiểm tra: $B''$: $-3+16-6-7=0$; $D''$: $3+4-0-7=0$.</p><p><b>Đáp số:</b> a) $C(1;2;2)$, $B''(-1;4;3)$, $D''(1;1;0)$; b) $(CB''D''): 3x+4y-2z-7=0$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.3.</b> Trong không gian $Oxyz$, viết phương trình mặt phẳng $(P)$ đi qua điểm $M(1;-1;5)$ và vuông góc với hai mặt phẳng $(Q): 3x+2y-z=0$, $(R): x+y-z=0$.</p>', N'<p>$(Q)$ có $\vec n_Q=(3;2;-1)$, $(R)$ có $\vec n_R=(1;1;-1)$. Vì $(P)$ vuông góc với cả hai nên $(P)$ nhận $\vec n=[\vec n_Q,\vec n_R]$ làm vectơ pháp tuyến:</p><p>$$\vec n=(2\cdot(-1)-(-1)\cdot1;\ (-1)\cdot1-3\cdot(-1);\ 3\cdot1-2\cdot1)=(-1;2;1).$$</p><p>$(P)$ đi qua $M(1;-1;5)$: $-(x-1)+2(y+1)+(z-5)=0$, tức $x-2y-z+2=0$.</p><p>Kiểm tra: $1+2-5+2=0$.</p><p><b>Đáp số:</b> $(P): x-2y-z+2=0$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.4.</b> Trong không gian $Oxyz$, viết phương trình mặt phẳng đi qua $M(2;3;-1)$, song song với trục $Ox$ và vuông góc với mặt phẳng $(Q): x+2y-3z+1=0$.</p>', N'<p>Mặt phẳng cần tìm có vectơ pháp tuyến $\vec n$ vuông góc với $\vec i=(1;0;0)$ (song song $Ox$) và vuông góc với $\vec n_Q=(1;2;-3)$ (vuông góc $(Q)$). Chọn</p><p>$$\vec n=[\vec i,\vec n_Q]=(0;3;2).$$</p><p>Đi qua $M(2;3;-1)$: $3(y-3)+2(z+1)=0$, tức $3y+2z-7=0$.</p><p>Kiểm tra: $M$ thoả mãn ($9-2-7=0$) và mặt phẳng không chứa trục $Ox$ (gốc $O$ không thuộc mặt phẳng).</p><p><b>Đáp số:</b> $3y+2z-7=0$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.5.</b> Trong không gian $Oxyz$, tính khoảng cách từ gốc toạ độ đến mặt phẳng $(P): 2x+2y-z+1=0$.</p>', N'<p>Công thức: $d(O,(P))=\dfrac{|2\cdot0+2\cdot0-0+1|}{\sqrt{2^2+2^2+(-1)^2}}=\dfrac{1}{3}$.</p><p><b>Đáp số:</b> $\dfrac13$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.6.</b> Trong không gian $Oxyz$, cho hai mặt phẳng $(P): x+y+z+2=0$, $(Q): x+y+z+6=0$. Chứng minh rằng hai mặt phẳng đã cho song song với nhau và tính khoảng cách giữa hai mặt phẳng đó.</p>', N'<p>$(P)$ có $\vec n_P=(1;1;1)$, $(Q)$ có $\vec n_Q=(1;1;1)$ nên hai vectơ pháp tuyến cùng phương. Điểm $M(-2;0;0)\in(P)$ nhưng $-2+0+0+6=4\ne0$ nên $M\notin(Q)$. Vậy $(P)\parallel(Q)$.</p><p>Khoảng cách giữa hai mặt phẳng song song bằng khoảng cách từ $M$ tới $(Q)$:</p><p>$$d=\dfrac{|-2+6|}{\sqrt{1+1+1}}=\dfrac{4}{\sqrt3}=\dfrac{4\sqrt3}{3}.$$</p><p><b>Đáp số:</b> $\dfrac{4\sqrt3}{3}$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.7.</b> Trong không gian $Oxyz$, cho hai mặt phẳng $(P): x+3y-z=0$, $(Q): x-y-2z+1=0$.</p><ol type="a"><li>Chứng minh rằng hai mặt phẳng $(P)$ và $(Q)$ vuông góc với nhau.</li><li>Tìm điểm $M$ thuộc trục $Ox$ và cách đều hai mặt phẳng $(P)$ và $(Q)$.</li></ol>', N'<p>a) $\vec n_P=(1;3;-1)$, $\vec n_Q=(1;-1;-2)$. Ta có $\vec n_P\cdot\vec n_Q=1-3+2=0$ nên $(P)\perp(Q)$.</p><p>b) Gọi $M(m;0;0)\in Ox$. Ta có</p><p>$$d(M,(P))=\dfrac{|m|}{\sqrt{11}},\qquad d(M,(Q))=\dfrac{|m+1|}{\sqrt6}.$$</p><p>Cách đều: $6m^2=11(m+1)^2\iff 5m^2+22m+11=0$, suy ra $m=\dfrac{-11\pm\sqrt{66}}{5}$.</p><p><b>Đáp số:</b> $M\left(\dfrac{-11+\sqrt{66}}{5};0;0\right)$ hoặc $M\left(\dfrac{-11-\sqrt{66}}{5};0;0\right)$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.8.</b> Bác An dự định làm bốn mái của ngôi nhà sao cho chúng là bốn mặt bên của một hình chóp đều và các mái nhà kề nhau thì vuông góc với nhau. Hỏi ý tưởng trên có thực hiện được không?</p><p><div><img src="/static/img/sgk/hinh-5-15.png" alt="Hình minh họa bài 5.8 (SGK)"></div></p>', N'<p>Xét hình chóp tứ giác đều (mái nhà có bốn mặt). Chọn hệ trục với tâm đáy là gốc $O$, đáy là hình vuông có các cạnh nằm trên $x=\pm a$, $y=\pm a$, đỉnh $S(0;0;h)$ với $a\gt0$, $h\gt0$.</p><p>Mặt bên chứa cạnh $x=a$, $z=0$ và $S$ có phương trình $hx+az-ah=0$, vectơ pháp tuyến $\vec n_1=(h;0;a)$.</p><p>Mặt bên kề chứa cạnh $y=a$, $z=0$ và $S$ có phương trình $hy+az-ah=0$, vectơ pháp tuyến $\vec n_2=(0;h;a)$.</p><p>$\vec n_1\cdot\vec n_2=a^2\gt0$, khác $0$ nên hai mặt kề nhau không bao giờ vuông góc, với mọi $a,h$.</p><p><b>Đáp số:</b> Ý tưởng của bác An không thực hiện được.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.9.</b> Trong không gian $Oxyz$, một ngôi nhà có sàn nhà thuộc mặt phẳng $(Oxy)$, trần nhà tầng 1 thuộc mặt phẳng $z-1=0$, mái nhà tầng 2 thuộc mặt phẳng $x+y+50z-100=0$. Hỏi trong ba mặt phẳng tương ứng chứa sàn nhà, trần tầng 1, mái tầng 2, hai mặt phẳng nào song song với nhau?</p>', N'<p>Ba mặt phẳng: sàn $(Oxy): z=0$ có $\vec n_1=(0;0;1)$; trần tầng 1: $z-1=0$ có $\vec n_2=(0;0;1)$; mái tầng 2: $x+y+50z-100=0$ có $\vec n_3=(1;1;50)$.</p><p>$\vec n_1,\vec n_2$ cùng phương và hai mặt phẳng phân biệt ($z=0$ và $z=1$) nên song song. $\vec n_3$ không cùng phương với $\vec n_1$ nên mái tầng 2 không song song với hai mặt phẳng kia.</p><p><b>Đáp số:</b> Mặt phẳng chứa sàn nhà và mặt phẳng chứa trần tầng 1 song song với nhau.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.10.</b> Xét một cối xay lúa trong không gian $Oxyz$, với đơn vị đo độ dài là mét. Nếu tác động vào tai cối xay lúa (ở vị trí $P$) một lực $\vec F$ thì moment lực $\vec M$ được tính bởi công thức $\vec M=[\overrightarrow{OP},\vec F]$ (H.5.16). Trong quá trình xay, các thanh gỗ $AB$ và $PQ$ luôn có phương nằm ngang. Vectơ lực $\vec F$ có giá song song với $AB$. Giải thích vì sao giá của vectơ moment lực $\vec M$ có phương thẳng đứng.</p><p><div><img src="/static/img/sgk/hinh-5-16.png" alt="Hình minh họa bài 5.10 (SGK)"></div></p>', N'<p>Gọi $\vec M=[\overrightarrow{OP},\vec F]$. Theo tính chất của tích có hướng, $\vec M$ vuông góc với cả $\overrightarrow{OP}$ và $\vec F$.</p><ul><li>$O$ thuộc thanh $PQ$ nên $\overrightarrow{OP}$ cùng phương với $PQ$, nằm ngang.</li><li>$\vec F$ có giá song song với $AB$, cũng nằm ngang.</li></ul><p>Hai thanh $AB$ và $PQ$ cùng nằm ngang nhưng không song song nhau, nên $\overrightarrow{OP}$ và $\vec F$ là hai vectơ không cùng phương, cùng song song với mặt phẳng nằm ngang. Do đó $\vec M$, vuông góc với hai vectơ không cùng phương đó, vuông góc với mặt phẳng nằm ngang, tức có phương thẳng đứng.</p><p><b>Đáp số:</b> $\vec M$ vuông góc với mặt phẳng ngang chứa $\overrightarrow{OP}$, $\vec F$ nên giá của $\vec M$ thẳng đứng.</p>', 3, 0, 1, @t1);
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
INSERT INTO LessonMaterials (LessonId, MaterialType, Title, Url, ContentText, OrderIndex, CreatedBy) VALUES (@l, 'YOUTUBE', N'Video bài giảng: Bài 15. Phương trình đường thẳng trong không gian', 'https://www.youtube.com/watch?v=DX-IxtirjZA', NULL, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.11.</b> Trong không gian $Oxyz$, viết các phương trình tham số và chính tắc của đường thẳng $\Delta$ đi qua điểm $A(1;1;2)$ và song song với đường thẳng $d: \dfrac{x-3}{2}=\dfrac{y-1}{1}=\dfrac{z+5}{3}$.</p>', N'<p>$\Delta\parallel d$ nên $\Delta$ nhận vectơ chỉ phương của $d$ là $\vec u=(2;1;3)$.</p><p>Phương trình tham số: $\begin{cases}x=1+2t\\y=1+t\\z=2+3t\end{cases}$ ($t\in\mathbb R$).</p><p>Phương trình chính tắc: $\dfrac{x-1}{2}=\dfrac{y-1}{1}=\dfrac{z-2}{3}$.</p><p><b>Đáp số:</b> như trên.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.12.</b> Trong không gian $Oxyz$, viết các phương trình tham số và chính tắc của đường thẳng $\Delta$ đi qua điểm $A(2;-1;4)$ và vuông góc với mặt phẳng $(P): x+3y-z-1=0$.</p>', N'<p>$\Delta\perp(P)$ nên $\Delta$ nhận vectơ pháp tuyến của $(P)$ là $\vec u=(1;3;-1)$ làm vectơ chỉ phương.</p><p>Tham số: $\begin{cases}x=2+t\\y=-1+3t\\z=4-t\end{cases}$.</p><p>Chính tắc: $\dfrac{x-2}{1}=\dfrac{y+1}{3}=\dfrac{z-4}{-1}$.</p><p><b>Đáp số:</b> như trên.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.13.</b> Trong không gian $Oxyz$, viết các phương trình tham số và chính tắc của đường thẳng $\Delta$ đi qua hai điểm $A(2;3;-1)$ và $B(1;-2;4)$.</p>', N'<p>$\Delta$ nhận $\overrightarrow{AB}=(-1;-5;5)$ làm vectơ chỉ phương, đi qua $A(2;3;-1)$.</p><p>Tham số: $\begin{cases}x=2-t\\y=3-5t\\z=-1+5t\end{cases}$.</p><p>Chính tắc: $\dfrac{x-2}{-1}=\dfrac{y-3}{-5}=\dfrac{z+1}{5}$.</p><p><b>Đáp số:</b> như trên.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.14.</b> Trong không gian $Oxyz$, cho hai đường thẳng:</p><p>$$\Delta_1:\begin{cases}x=1+2t\\y=3-t\\z=2+3t\end{cases}\quad\text{và}\quad\Delta_2:\dfrac{x-8}{-1}=\dfrac{y+2}{1}=\dfrac{z-2}{2}.$$</p><ol type="a"><li>Chứng minh rằng $\Delta_1$ và $\Delta_2$ cắt nhau.</li><li>Viết phương trình mặt phẳng $(P)$ chứa $\Delta_1$ và $\Delta_2$.</li></ol>', N'<p>a) $\Delta_1$ đi qua $M_1(1;3;2)$, $\vec u_1=(2;-1;3)$; $\Delta_2$ đi qua $M_2(8;-2;2)$, $\vec u_2=(-1;1;2)$. Hai vectơ không cùng phương.</p><p>Viết $\Delta_2$: $x=8-s$, $y=-2+s$, $z=2+2s$. Giải $1+2t=8-s$, $3-t=-2+s$, $2+3t=2+2s$: từ phương trình cuối $s=\dfrac{3t}{2}$; thay vào phương trình thứ hai: $5=\dfrac52t$, $t=2$, $s=3$. Kiểm tra phương trình đầu: $1+4=5=8-3$. Hệ có nghiệm duy nhất nên hai đường thẳng cắt nhau tại $(5;1;8)$.</p><p>b) Vectơ pháp tuyến $\vec n=[\vec u_1,\vec u_2]=(-5;-7;1)$, chọn $(5;7;-1)$. Mặt phẳng đi qua $(5;1;8)$: $5(x-5)+7(y-1)-(z-8)=0$, tức $5x+7y-z-24=0$.</p><p>Kiểm tra: $M_1$: $5+21-2-24=0$; $M_2$: $40-14-2-24=0$.</p><p><b>Đáp số:</b> a) cắt nhau tại $(5;1;8)$; b) $(P): 5x+7y-z-24=0$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.15.</b> Trong không gian $Oxyz$, cho hai đường thẳng:</p><p>$$\Delta_1:\dfrac{x-1}{3}=\dfrac{y-3}{1}=\dfrac{z-2}{2}\quad\text{và}\quad\Delta_2:\dfrac{x-1}{3}=\dfrac{y+1}{1}=\dfrac{z}{2}.$$</p><ol type="a"><li>Chứng minh rằng $\Delta_1$ và $\Delta_2$ song song với nhau.</li><li>Viết phương trình mặt phẳng $(P)$ chứa $\Delta_1$ và $\Delta_2$.</li></ol>', N'<p>a) Cả hai có vectơ chỉ phương $\vec u=(3;1;2)$. Điểm $A(1;3;2)\in\Delta_1$; thay vào $\Delta_2$: $\dfrac{0}{3}\ne\dfrac{4}{1}$ nên $A\notin\Delta_2$. Vậy $\Delta_1\parallel\Delta_2$.</p><p>b) Lấy $B(1;-1;0)\in\Delta_2$, $\overrightarrow{AB}=(0;-4;-2)$, chọn $(0;2;1)$. Vectơ pháp tuyến $\vec n=[\vec u,(0;2;1)]=(-3;-3;6)$, chọn $(1;1;-2)$. Mặt phẳng đi qua $A$: $(x-1)+(y-3)-2(z-2)=0$, tức $x+y-2z=0$.</p><p>Kiểm tra: $B$: $1-1-0=0$.</p><p><b>Đáp số:</b> a) song song; b) $(P): x+y-2z=0$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.16.</b> Trong không gian $Oxyz$, xét vị trí tương đối giữa hai đường thẳng:</p><p>$$\Delta_1:\begin{cases}x=-1+t\\y=1\\z=3+2t\end{cases}\quad\text{và}\quad\Delta_2:\begin{cases}x=-1+2s\\y=2+s\\z=1+3s.\end{cases}$$</p>', N'<p>$\Delta_1$: điểm $M_1(-1;1;3)$, $\vec u_1=(1;0;2)$. $\Delta_2$: điểm $M_2(-1;2;1)$, $\vec u_2=(2;1;3)$.</p><p>Hai vectơ không cùng phương nên hai đường thẳng không song song, không trùng nhau.</p><p>Xét giao điểm: $-1+t=-1+2s$, $1=2+s$, $3+2t=1+3s$. Từ phương trình thứ hai $s=-1$, từ phương trình đầu $t=-2$; phương trình cuối: vế trái $3-4=-1$, vế phải $1-3=-2$, mâu thuẫn. Vậy không có giao điểm.</p><p>(Kiểm tra: $[\vec u_1,\vec u_2]=(-2;1;1)$, $\overrightarrow{M_1M_2}=(0;1;-2)$, tích vô hướng $=-1\ne0$.)</p><p><b>Đáp số:</b> $\Delta_1$ và $\Delta_2$ chéo nhau.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.17.</b> Tại một nút giao thông có hai con đường. Trên thiết kế, trong không gian $Oxyz$, hai con đường đó thuộc hai đường thẳng lần lượt có phương trình:</p><p>$$\Delta_1:\dfrac{x-1}{2}=\dfrac{y}{-1}=\dfrac{z+1}{3}\quad\text{và}\quad\Delta_2:\dfrac{x-3}{-1}=\dfrac{y+1}{1}=\dfrac{z}{1}.$$</p><ol type="a"><li>Hai con đường trên có vuông góc với nhau hay không?</li><li>Nút giao thông trên có phải là nút giao thông khác mức hay không?</li></ol><p><div><img src="/static/img/sgk/hinh-5-31.png" alt="Hình minh họa bài 5.17 (SGK)"></div></p>', N'<p>$\Delta_1$: điểm $P_1(1;0;-1)$, $\vec u_1=(2;-1;3)$; $\Delta_2$: điểm $P_2(3;-1;0)$, $\vec u_2=(-1;1;1)$.</p><p>a) $\vec u_1\cdot\vec u_2=-2-1+3=0$ nên hai con đường vuông góc với nhau.</p><p>b) Hai vectơ chỉ phương không cùng phương. Xét giao điểm: $1+2t=3-s$, $-t=-1+s$, $-1+3t=s$. Từ hai phương trình đầu: $s=1-t$ và $1+2t=2+t$ nên $t=1$, $s=0$; phương trình thứ ba: $-1+3=2\ne0$. Không có giao điểm nên hai đường chéo nhau.</p><p>Hai con đường vuông góc, không cắt nhau (chéo nhau) nên nút giao thông là khác mức.</p><p><b>Đáp số:</b> a) có; b) có, đó là nút giao thông khác mức.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.18.</b> Trong không gian $Oxyz$, một viên đạn được bắn ra từ điểm $A(1;3;4)$ và trong 3 giây, đầu đạn đi với vận tốc không đổi; vectơ vận tốc (trên giây) là $\vec v=(2;1;6)$. Hỏi viên đạn trên có bắn trúng mục tiêu trong mỗi tình huống sau hay không?</p><ol type="a"><li>Mục tiêu đặt tại điểm $M\left(7;\dfrac{7}{2};21\right)$.</li><li>Mục tiêu đặt tại điểm $N(-3;1;-8)$.</li></ol>', N'<p>Quỹ đạo đầu đạn: $\begin{cases}x=1+2t\\y=3+t\\z=4+6t\end{cases}$, với $0\le t\le3$ (giây).</p><p>a) Với $M\left(7;\dfrac72;21\right)$: $7=1+2t\Rightarrow t=3$; $\dfrac72=3+t\Rightarrow t=\dfrac12$. Hai giá trị khác nhau nên $M$ không nằm trên quỹ đạo. Đạn không trúng.</p><p>b) Với $N(-3;1;-8)$: $-3=1+2t\Rightarrow t=-2$; $1=3+t\Rightarrow t=-2$; $-8=4+6t\Rightarrow t=-2$. $N$ nằm trên đường thẳng nhưng ứng với $t=-2$ âm, tức phía sau điểm bắn, không thuộc đoạn đường đạn bay ($0\le t\le3$). Đạn không trúng.</p><p><b>Đáp số:</b> a) không trúng; b) không trúng.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.19.</b> Trên mặt đất phẳng, người ta dựng một cây cột thẳng cao 6 m vuông góc với mặt đất, có chân cột đặt tại vị trí $O$ trên mặt đất. Tại một thời điểm, dưới ánh nắng mặt trời, bóng của đỉnh cột dưới mặt đất cách chân cột 3 m về hướng $S60^\circ E$ (hướng tạo với hướng nam góc $60^\circ$ và tạo với hướng đông góc $30^\circ$) (H.5.32). Chọn hệ trục $Oxyz$ có gốc toạ độ là $O$, tia $Ox$ chỉ hướng nam, tia $Oy$ chỉ hướng đông, tia $Oz$ chứa cây cột, đơn vị đo là mét. Hãy viết phương trình đường thẳng chứa tia nắng mặt trời đi qua đỉnh cột tại thời điểm đang xét.</p><p><div><img src="/static/img/sgk/hinh-5-32.png" alt="Hình minh họa bài 5.19 (SGK)"></div></p>', N'<p>Gọi $A(0;0;6)$ là đỉnh cột và $A''$ là bóng của $A$ trên mặt đất. Vì $OA''=3$, $\widehat{A''Ox}=60^\circ$, $\widehat{A''Oy}=30^\circ$ nên</p><p>$$A''\left(3\cos60^\circ;3\cos30^\circ;0\right)=\left(\dfrac32;\dfrac{3\sqrt3}{2};0\right).$$</p><p>Tia nắng đi qua $A$ và $A''$ nên có vectơ chỉ phương $\overrightarrow{AA''}=\left(\dfrac32;\dfrac{3\sqrt3}{2};-6\right)$, cùng phương với $\vec u=(1;\sqrt3;-4)$.</p><p>Phương trình tham số: $\begin{cases}x=t\\y=\sqrt3\,t\\z=6-4t\end{cases}$; chính tắc: $\dfrac{x}{1}=\dfrac{y}{\sqrt3}=\dfrac{z-6}{-4}$.</p><p><b>Đáp số:</b> $\dfrac{x}{1}=\dfrac{y}{\sqrt3}=\dfrac{z-6}{-4}$.</p>', 3, 0, 1, @t1);
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
INSERT INTO LessonMaterials (LessonId, MaterialType, Title, Url, ContentText, OrderIndex, CreatedBy) VALUES (@l, 'YOUTUBE', N'Video bài giảng: Bài 16. Công thức tính góc trong không gian', 'https://www.youtube.com/watch?v=D2ZZOtsKw58', NULL, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.20.</b> Trong không gian $Oxyz$, tính góc giữa hai đường thẳng:</p><p>$$\Delta_1:\begin{cases}x=1+2t\\y=1-t\\z=2+3t\end{cases}\quad\text{và}\quad\Delta_2:\dfrac{x-2}{-1}=\dfrac{y+1}{1}=\dfrac{z-2}{2}.$$</p>', N'<p>$\Delta_1$ có $\vec u_1=(2;-1;3)$, $\Delta_2$ có $\vec u_2=(-1;1;2)$.</p><p>$$\cos(\Delta_1,\Delta_2)=\dfrac{|\vec u_1\cdot\vec u_2|}{|\vec u_1||\vec u_2|}=\dfrac{|-2-1+6|}{\sqrt{14}\cdot\sqrt6}=\dfrac{3}{\sqrt{84}}=\dfrac{\sqrt{21}}{14}\approx0{,}327.$$</p><p>Suy ra góc $\approx70{,}9^\circ$.</p><p><b>Đáp số:</b> $\cos\varphi=\dfrac{\sqrt{21}}{14}$, $\varphi\approx70{,}9^\circ$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.21.</b> Trong không gian $Oxyz$, tính góc giữa trục $Oz$ và mặt phẳng $(P): x+2y-z-1=0$.</p>', N'<p>Trục $Oz$ có vectơ chỉ phương $\vec k=(0;0;1)$; $(P)$ có $\vec n=(1;2;-1)$.</p><p>$$\sin\varphi=\dfrac{|\vec k\cdot\vec n|}{|\vec k||\vec n|}=\dfrac{1}{\sqrt6}\approx0{,}408.$$</p><p>Suy ra $\varphi\approx24{,}1^\circ$.</p><p><b>Đáp số:</b> $\sin\varphi=\dfrac{1}{\sqrt6}$, $\varphi\approx24{,}1^\circ$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.22.</b> Tính góc giữa đường thẳng $\Delta: \dfrac{x+1}{-1}=\dfrac{y-3}{2}=\dfrac{z+2}{3}$ và mặt phẳng $(P): x+y+z+3=0$.</p>', N'<p>$\Delta$ có $\vec u=(-1;2;3)$; $(P)$ có $\vec n=(1;1;1)$.</p><p>$$\sin\varphi=\dfrac{|-1+2+3|}{\sqrt{14}\cdot\sqrt3}=\dfrac{4}{\sqrt{42}}\approx0{,}617.$$</p><p>Suy ra $\varphi\approx38{,}1^\circ$.</p><p><b>Đáp số:</b> $\sin\varphi=\dfrac{4}{\sqrt{42}}$, $\varphi\approx38{,}1^\circ$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.23.</b> Kim tự tháp Kheops ở Ai Cập có dạng hình chóp $S.ABCD$, có đáy là hình vuông với cạnh dài 230 m, các cạnh bên bằng nhau và dài 219 m (theo britannica.com) (H.5.38). Tính góc giữa hai mặt phẳng $(SAB)$ và $(SBC)$.</p><p><div><img src="/static/img/sgk/hinh-5-38.png" alt="Hình minh họa bài 5.23 (SGK)"></div></p>', N'<p>Đặt hệ toạ độ có gốc $O$ là tâm hình vuông $ABCD$, $A(-115;-115;0)$, $B(115;-115;0)$, $C(115;115;0)$, $S(0;0;h)$.</p>
<p>Vì $SA=219$ nên $h^2=219^2-2\cdot115^2=47961-26450=21511$.</p>
<p>Ta có $\overrightarrow{AB}=(230;0;0)$, $\overrightarrow{AS}=(115;115;h)$. Vectơ pháp tuyến của $(SAB)$: $\vec n_1=\dfrac{1}{230}[\overrightarrow{AB},\overrightarrow{AS}]=(0;-h;115)$.</p>
<p>Tương tự $\overrightarrow{BC}=(0;230;0)$, $\overrightarrow{BS}=(-115;115;h)$ nên $\vec n_2=(h;0;115)$ là vectơ pháp tuyến của $(SBC)$.</p>
<p>$$\cos\varphi=\dfrac{|\vec n_1\cdot\vec n_2|}{|\vec n_1||\vec n_2|}=\dfrac{115^2}{h^2+115^2}=\dfrac{13225}{34736}\approx 0{,}3807.$$</p>
<p>Suy ra $\varphi\approx 67{,}6^\circ$.</p>
<p><b>Đáp số:</b> góc giữa $(SAB)$ và $(SBC)$ khoảng $67{,}6^\circ$ (khoảng $67^\circ37''$).</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.24.</b> (H.5.39) Trong một bể hình lập phương cạnh 1 m có chứa một ít nước. Người ta đặt đáy bể nghiêng so với mặt phẳng nằm ngang. Biết rằng, lúc đó mặt nước có dạng hình bình hành $ABCD$ và khoảng cách từ các điểm $A$, $B$, $C$ đến đáy bể tương ứng là 40 cm, 44 cm, 48 cm.</p><ol type="a"><li>Khoảng cách từ điểm $D$ đến đáy bể bằng bao nhiêu centimét? (Tính gần đúng, lấy giá trị nguyên.)</li><li>Đáy bể nghiêng so với mặt phẳng nằm ngang một góc bao nhiêu độ?</li></ol><p><div><img src="/static/img/sgk/hinh-5-39.png" alt="Hình minh họa bài 5.24 (SGK)"></div></p>', N'<p>Chọn hệ toạ độ có đáy bể là mặt phẳng $(Oxy)$, bốn cạnh bên thẳng đứng; độ cao của một điểm là cao độ $z$ (tính theo mét). Đặt $A(0;0;0{,}40)$, $B(0;1;0{,}44)$, $C(1;1;0{,}48)$, $D(1;0;z_D)$.</p>
<p>a) $ABCD$ là hình bình hành nên $\overrightarrow{AB}=\overrightarrow{DC}$, suy ra $0{,}44-0{,}40=0{,}48-z_D$, do đó $z_D=0{,}44$ m.</p>
<p>b) Mặt nước nằm ngang. Góc nghiêng của đáy bể chính là góc giữa mặt phẳng $(ABCD)$ và mặt đáy $(Oxy)$.</p>
<p>$\overrightarrow{AB}=(0;1;0{,}04)$, $\overrightarrow{AD}=(1;0;0{,}04)$ nên pháp tuyến của $(ABCD)$ là $\vec n=[\overrightarrow{AB},\overrightarrow{AD}]=(0{,}04;0{,}04;-1)$. Pháp tuyến của $(Oxy)$ là $\vec k=(0;0;1)$.</p>
<p>$$\cos\varphi=\dfrac{1}{\sqrt{0{,}04^2+0{,}04^2+1}}=\dfrac{1}{\sqrt{1{,}0032}}\approx0{,}9984\Rightarrow\varphi\approx3{,}2^\circ.$$</p>
<p><b>Đáp số:</b> a) 44 cm; b) khoảng $3{,}2^\circ$.</p>', 3, 0, 1, @t1);
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
INSERT INTO LessonMaterials (LessonId, MaterialType, Title, Url, ContentText, OrderIndex, CreatedBy) VALUES (@l, 'YOUTUBE', N'Video bài giảng: Bài 17. Phương trình mặt cầu', 'https://www.youtube.com/watch?v=wQDy0vf-WD8', NULL, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.25.</b> Trong không gian $Oxyz$, cho mặt cầu $(S)$ có phương trình $\left(x-\dfrac12\right)^2+(y+1)^2+z^2=9$. Xác định tâm và bán kính của $(S)$.</p>', N'<p>Phương trình mặt cầu có dạng $(x-a)^2+(y-b)^2+(z-c)^2=R^2$ với tâm $I(a;b;c)$, bán kính $R$.</p>
<p>Viết $(y+1)^2=(y-(-1))^2$ và $z^2=(z-0)^2$, ta được tâm $I\left(\dfrac12;-1;0\right)$ và $R^2=9$, suy ra $R=3$.</p>
<p><b>Đáp số:</b> tâm $I\left(\dfrac12;-1;0\right)$, bán kính $R=3$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.26.</b> Trong không gian $Oxyz$, viết phương trình của mặt cầu $(S)$ có tâm $I(-2;0;5)$ và bán kính $R=2$.</p>', N'<p>Mặt cầu tâm $I(a;b;c)$, bán kính $R$ có phương trình $(x-a)^2+(y-b)^2+(z-c)^2=R^2$.</p>
<p>Với $I(-2;0;5)$, $R=2$ ta có:</p>
<p>$$(x+2)^2+y^2+(z-5)^2=4.$$</p>
<p><b>Đáp số:</b> $(S): (x+2)^2+y^2+(z-5)^2=4$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.27.</b> Trong không gian $Oxyz$, viết phương trình của mặt cầu $(S)$ có tâm $I(0;3;-1)$ và có bán kính bằng khoảng cách từ $I$ đến mặt phẳng $(P): 3x+2y-z=0$.</p>', N'<p>Bán kính $R=d(I,(P))$ với $I(0;3;-1)$ và $(P): 3x+2y-z=0$:</p>
<p>$$R=\dfrac{|3\cdot0+2\cdot3-(-1)|}{\sqrt{3^2+2^2+(-1)^2}}=\dfrac{7}{\sqrt{14}}=\dfrac{\sqrt{14}}{2},\quad R^2=\dfrac{49}{14}=\dfrac72.$$</p>
<p>Phương trình mặt cầu: $x^2+(y-3)^2+(z+1)^2=\dfrac72$.</p>
<p><b>Đáp số:</b> $(S): x^2+(y-3)^2+(z+1)^2=\dfrac72$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.28.</b> Trong không gian $Oxyz$, cho mặt cầu $(S): x^2+y^2+z^2+2x-2y+8z-18=0$. Xác định tâm và bán kính của $(S)$.</p>', N'<p>Đưa về dạng $x^2+y^2+z^2-2ax-2by-2cz+d=0$ với tâm $I(a;b;c)$, bán kính $R=\sqrt{a^2+b^2+c^2-d}$.</p>
<p>So sánh: $-2a=2\Rightarrow a=-1$; $-2b=-2\Rightarrow b=1$; $-2c=8\Rightarrow c=-4$; $d=-18$.</p>
<p>$R=\sqrt{1+1+16+18}=\sqrt{36}=6$.</p>
<p><b>Đáp số:</b> tâm $I(-1;1;-4)$, bán kính $R=6$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.29.</b> Trong không gian $Oxyz$, phương trình nào trong các phương trình sau là phương trình mặt cầu? Xác định tâm và bán kính của mặt cầu ứng với phương trình đó.</p><ol type="a"><li>$x^2+y^2+z^2-2x-5z+30=0$;</li><li>$x^2+y^2+z^2-4x+2y-2z=0$;</li><li>$x^3+y^3+z^3-2x+6y-9z-10=0$;</li><li>$x^2+y^2+z^2+5=0$.</li></ol>', N'<p>Phương trình $x^2+y^2+z^2-2ax-2by-2cz+d=0$ là phương trình mặt cầu khi và chỉ khi $a^2+b^2+c^2-d\gt0$; khi đó tâm $I(a;b;c)$, $R=\sqrt{a^2+b^2+c^2-d}$.</p>
<ul><li>a) $a=1$, $b=0$, $c=\dfrac52$, $d=30$: $a^2+b^2+c^2-d=1+\dfrac{25}{4}-30\lt0$. Không phải mặt cầu.</li>
<li>b) $a=2$, $b=-1$, $c=1$, $d=0$: $4+1+1-0=6\gt0$. Là mặt cầu, tâm $I(2;-1;1)$, $R=\sqrt6$.</li>
<li>c) Chứa $x^3,y^3,z^3$ nên không phải dạng phương trình mặt cầu.</li>
<li>d) $a=b=c=0$, $d=5$: $0-5\lt0$. Không phải mặt cầu.</li></ul>
<p><b>Đáp số:</b> chỉ phương trình b) là mặt cầu, tâm $I(2;-1;1)$, bán kính $R=\sqrt6$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.30.</b> Trong không gian $Oxyz$, một thiết bị phát sóng đặt tại vị trí $A(2;0;0)$. Vùng phủ sóng của thiết bị có bán kính bằng 1. Hỏi vị trí $M(2;1;1)$ có thuộc vùng phủ sóng của thiết bị nói trên hay không?</p>', N'<p>Vị trí $M$ thuộc vùng phủ sóng khi $AM\le1$.</p>
<p>$AM=\sqrt{(2-2)^2+(1-0)^2+(1-0)^2}=\sqrt2\gt1$.</p>
<p>Vậy $M$ nằm ngoài mặt cầu tâm $A$ bán kính 1, tức không thuộc vùng phủ sóng.</p>
<p><b>Đáp số:</b> $M$ không thuộc vùng phủ sóng.</p>', 1, 0, 1, @t1);
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
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.40.</b> Trong không gian $Oxyz$, cho ba điểm $A(1;0;-1)$, $B(0;1;2)$, $C(-1;-2;3)$.</p><ol type="a"><li>Viết phương trình mặt phẳng $(ABC)$.</li><li>Viết phương trình đường thẳng $AC$.</li><li>Viết phương trình mặt cầu đường kính $AC$.</li><li>Viết phương trình mặt cầu có tâm $A$ và đi qua $B$.</li></ol>', N'<p>a) $\overrightarrow{AB}=(-1;1;3)$, $\overrightarrow{AC}=(-2;-2;4)$. Vectơ pháp tuyến $\vec n=[\overrightarrow{AB},\overrightarrow{AC}]=(10;-2;4)$, chọn $\vec n=(5;-1;2)$.</p>
<p>$(ABC)$: $5(x-1)-y+2(z+1)=0\Leftrightarrow 5x-y+2z-3=0$. (Kiểm tra: $B$: $-1+4-3=0$; $C$: $-5+2+6-3=0$.)</p>
<p>b) $\overrightarrow{AC}=(-2;-2;4)$, chọn vectơ chỉ phương $\vec u=(1;1;-2)$. Đường thẳng $AC$: $\begin{cases}x=1+t\\y=t\\z=-1-2t.\end{cases}$</p>
<p>c) Tâm là trung điểm $I(0;-1;1)$ của $AC$; $R^2=\dfrac{AC^2}{4}=\dfrac{4+4+16}{4}=6$.</p>
<p>$$x^2+(y+1)^2+(z-1)^2=6.$$</p>
<p>d) $R^2=AB^2=1+1+9=11$: $(x-1)^2+y^2+(z+1)^2=11$.</p>
<p><b>Đáp số:</b> a) $5x-y+2z-3=0$; b) $\begin{cases}x=1+t\\y=t\\z=-1-2t\end{cases}$; c) $x^2+(y+1)^2+(z-1)^2=6$; d) $(x-1)^2+y^2+(z+1)^2=11$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.41.</b> Trong không gian $Oxyz$, cho đường thẳng $d:\begin{cases}x=1+t\\y=-2+t\\z=4-2t.\end{cases}$</p><p>Viết phương trình mặt phẳng $(P)$ chứa đường thẳng $d$ và gốc toạ độ $O$.</p>', N'<p>$d$ đi qua $M(1;-2;4)$ với vectơ chỉ phương $\vec u=(1;1;-2)$; $\overrightarrow{OM}=(1;-2;4)$.</p>
<p>Vectơ pháp tuyến của $(P)$: $\vec n=[\vec u,\overrightarrow{OM}]=(1\cdot4-(-2)(-2);\,(-2)\cdot1-1\cdot4;\,1\cdot(-2)-1\cdot1)=(0;-6;-3)$, chọn $\vec n=(0;2;1)$.</p>
<p>$(P)$ đi qua $O$ nên $(P): 2y+z=0$. (Kiểm tra: $M$: $-4+4=0$; $\vec n\cdot\vec u=2-2=0$.)</p>
<p><b>Đáp số:</b> $(P): 2y+z=0$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.42.</b> Trong không gian $Oxyz$, cho mặt phẳng $(P): x-2y+2z-1=0$ và hai điểm $A(1;-1;2)$, $B(-1;1;0)$.</p><ol type="a"><li>Tính khoảng cách từ $A$ đến mặt phẳng $(P)$.</li><li>Viết phương trình mặt phẳng $(Q)$ đi qua $A$ và song song với mặt phẳng $(P)$.</li><li>Viết phương trình mặt phẳng $(R)$ chứa $A$, $B$ và vuông góc với mặt phẳng $(P)$.</li></ol>', N'<p>a) $d(A,(P))=\dfrac{|1-2(-1)+2\cdot2-1|}{\sqrt{1+4+4}}=\dfrac{6}{3}=2$.</p>
<p>b) $(Q)\parallel(P)$ nên $(Q): x-2y+2z+m=0$. Qua $A$: $1+2+4+m=0\Rightarrow m=-7$. Vậy $(Q): x-2y+2z-7=0$.</p>
<p>c) $\overrightarrow{AB}=(-2;2;-2)$, chọn $(-1;1;-1)$; $\vec n_P=(1;-2;2)$. Pháp tuyến của $(R)$: $[(-1;1;-1),(1;-2;2)]=(0;1;1)$.</p>
<p>$(R)$ qua $A$: $1\cdot(y+1)+1\cdot(z-2)=0\Leftrightarrow y+z-1=0$. (Kiểm tra: $B$: $1+0-1=0$.)</p>
<p><b>Đáp số:</b> a) $2$; b) $x-2y+2z-7=0$; c) $y+z-1=0$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.43.</b> Trong không gian $Oxyz$, cho điểm $A(1;0;2)$ và hai đường thẳng $d: \dfrac{x}{1}=\dfrac{y-1}{2}=\dfrac{z}{2}$, $d'': \dfrac{x+1}{2}=\dfrac{y+2}{2}=\dfrac{z-3}{-1}$.</p><ol type="a"><li>Xét vị trí tương đối của hai đường thẳng $d$ và $d''$.</li><li>Viết phương trình đường thẳng $\Delta$ đi qua $A$ và song song với đường thẳng $d$.</li><li>Viết phương trình mặt phẳng $(P)$ chứa $A$ và $d$.</li><li>Tìm giao điểm của đường thẳng $d$ với mặt phẳng $(Oxz)$.</li></ol>', N'<p>$d$ đi qua $M(0;1;0)$, $\vec u=(1;2;2)$; $d''$ đi qua $M''(-1;-2;3)$, $\vec u''=(2;2;-1)$.</p>
<p>a) $\vec u,\vec u''$ không cùng phương nên $d,d''$ không song song hoặc trùng. $[\vec u,\vec u'']=(-6;5;-2)$, $\overrightarrow{MM''}=(-1;-3;3)$, tích hỗn hợp $=6-15-6=-15\ne0$. Vậy $d$ và $d''$ chéo nhau.</p>
<p>b) $\Delta$ qua $A(1;0;2)$ nhận $\vec u=(1;2;2)$: $\begin{cases}x=1+t\\y=2t\\z=2+2t.\end{cases}$</p>
<p>c) $\overrightarrow{MA}=(1;-1;2)$. Pháp tuyến $\vec n=[\vec u,\overrightarrow{MA}]=(6;0;-3)$, chọn $(2;0;-1)$. $(P): 2(x-1)-(z-2)=0\Leftrightarrow 2x-z=0$. (Kiểm tra $M$: $0$.)</p>
<p>d) $(Oxz): y=0$. Điểm của $d$: $(t;1+2t;2t)$, $y=0\Rightarrow t=-\dfrac12$, giao điểm $\left(-\dfrac12;0;-1\right)$.</p>
<p><b>Đáp số:</b> a) chéo nhau; b) $\begin{cases}x=1+t\\y=2t\\z=2+2t\end{cases}$; c) $2x-z=0$; d) $\left(-\dfrac12;0;-1\right)$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.44.</b> Trong không gian $Oxyz$, cho mặt phẳng $(P): x-2y-2z-3=0$ và đường thẳng $d: \dfrac{x-1}{2}=\dfrac{y+1}{1}=\dfrac{z}{-1}$. Viết phương trình mặt phẳng $(Q)$ chứa $d$ và vuông góc với mặt phẳng $(P)$.</p>', N'<p>$d$ đi qua $M(1;-1;0)$, $\vec u=(2;1;-1)$; $(P)$ có $\vec n_P=(1;-2;-2)$.</p>
<p>$(Q)$ chứa $d$ và vuông góc $(P)$ nên pháp tuyến $\vec n_Q=[\vec u,\vec n_P]=(1\cdot(-2)-(-1)(-2);\,(-1)\cdot1-2\cdot(-2);\,2\cdot(-2)-1\cdot1)=(-4;3;-5)$, chọn $(4;-3;5)$.</p>
<p>$(Q)$: $4(x-1)-3(y+1)+5z=0\Leftrightarrow 4x-3y+5z-7=0$. (Kiểm tra: $\vec n_Q\cdot\vec u=8-3-5=0$, $\vec n_Q\cdot\vec n_P=4+6-10=0$.)</p>
<p><b>Đáp số:</b> $(Q): 4x-3y+5z-7=0$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.45.</b> Trong không gian $Oxyz$, cho hai đường thẳng:</p><p>$$d:\dfrac{x+1}{1}=\dfrac{y-1}{2}=\dfrac{z}{-1}\quad\text{và}\quad d'':\dfrac{x-1}{1}=\dfrac{y-2}{1}=\dfrac{z+1}{2}.$$</p><p>Viết phương trình mặt phẳng $(P)$ chứa đường thẳng $d$ và song song với đường thẳng $d''$.</p>', N'<p>$d$ qua $M(-1;1;0)$, $\vec u=(1;2;-1)$; $d''$ có $\vec u''=(1;1;2)$.</p>
<p>$(P)\supset d$, $(P)\parallel d''$ nên $\vec n=[\vec u,\vec u'']=(2\cdot2-(-1)\cdot1;\,(-1)\cdot1-1\cdot2;\,1\cdot1-2\cdot1)=(5;-3;-1)$.</p>
<p>$(P)$: $5(x+1)-3(y-1)-z=0\Leftrightarrow 5x-3y-z+8=0$.</p>
<p>Điểm $(1;2;-1)\in d''$ không thuộc $(P)$ ($5-6+1+8=8\ne0$) nên $d''$ song song với $(P)$.</p>
<p><b>Đáp số:</b> $(P): 5x-3y-z+8=0$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.46.</b> Trong không gian $Oxyz$, cho hai mặt phẳng $(P): x-y-z-1=0$, $(Q): 2x+y-z-2=0$ và điểm $A(-1;2;0)$. Viết phương trình mặt phẳng $(R)$ đi qua điểm $A$ đồng thời vuông góc với cả hai mặt phẳng $(P)$ và $(Q)$.</p>', N'<p>$\vec n_P=(1;-1;-1)$, $\vec n_Q=(2;1;-1)$.</p>
<p>$(R)$ vuông góc với cả $(P)$ và $(Q)$ nên $\vec n_R=[\vec n_P,\vec n_Q]=((-1)(-1)-(-1)\cdot1;\,(-1)\cdot2-1\cdot(-1);\,1\cdot1-(-1)\cdot2)=(2;-1;3)$.</p>
<p>$(R)$ qua $A(-1;2;0)$: $2(x+1)-(y-2)+3z=0\Leftrightarrow 2x-y+3z+4=0$.</p>
<p><b>Đáp số:</b> $(R): 2x-y+3z+4=0$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.47.</b> Trong không gian $Oxyz$, cho hai đường thẳng $d:\dfrac{x+2}{1}=\dfrac{y+3}{2}=\dfrac{z-3}{-2}$ và $d'':\begin{cases}x=1-t\\y=-2+t\\z=2t.\end{cases}$</p><ol type="a"><li>Xác định vị trí tương đối của hai đường thẳng $d$ và $d''$.</li><li>Tính góc giữa $d$ và $d''$.</li></ol>', N'<p>$d$ qua $M(-2;-3;3)$, $\vec u=(1;2;-2)$; $d''$ qua $M''(1;-2;0)$, $\vec u''=(-1;1;2)$.</p>
<p>a) $\vec u,\vec u''$ không cùng phương. $[\vec u,\vec u'']=(6;0;3)$, $\overrightarrow{MM''}=(3;1;-3)$, tích hỗn hợp $=18+0-9=9\ne0$. Vậy $d$, $d''$ chéo nhau.</p>
<p>b) $$\cos(d,d'')=\dfrac{|\vec u\cdot\vec u''|}{|\vec u||\vec u''|}=\dfrac{|-1+2-4|}{3\cdot\sqrt6}=\dfrac{1}{\sqrt6}\approx0{,}408.$$ Suy ra góc khoảng $65{,}9^\circ$.</p>
<p><b>Đáp số:</b> a) chéo nhau; b) $\cos\varphi=\dfrac{1}{\sqrt6}$, $\varphi\approx65{,}9^\circ$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.48.</b> Trong không gian $Oxyz$, tính góc tạo bởi đường thẳng $d: \dfrac{x+3}{2}=\dfrac{y-2}{-2}=\dfrac{z+1}{1}$ và mặt phẳng $(P): x+y-2z+3=0$.</p>', N'<p>Vectơ chỉ phương $\vec u=(2;-2;1)$, $|\vec u|=3$; vectơ pháp tuyến $\vec n=(1;1;-2)$, $|\vec n|=\sqrt6$.</p>
<p>$$\sin\varphi=\dfrac{|\vec u\cdot\vec n|}{|\vec u||\vec n|}=\dfrac{|2-2-2|}{3\sqrt6}=\dfrac{2}{3\sqrt6}\approx0{,}272.$$</p>
<p>Suy ra $\varphi\approx15{,}8^\circ$.</p>
<p><b>Đáp số:</b> khoảng $15{,}8^\circ$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.49.</b> Trong không gian $Oxyz$, tính góc giữa mặt phẳng $(P): x+y+z-1=0$ và mặt phẳng $(Oxy)$.</p>', N'<p>$\vec n_P=(1;1;1)$, $(Oxy)$ có $\vec k=(0;0;1)$.</p>
<p>$$\cos\varphi=\dfrac{|\vec n_P\cdot\vec k|}{|\vec n_P||\vec k|}=\dfrac{1}{\sqrt3}\Rightarrow\varphi\approx54{,}7^\circ.$$</p>
<p><b>Đáp số:</b> khoảng $54{,}7^\circ$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.50.</b> Từ mặt nước trong một bể nước, tại ba vị trí đôi một cách nhau 2 m, người ta lần lượt thả dây dọi để quả dọi chạm đáy bể. Phần dây dọi (thẳng) nằm trong nước tại ba vị trí đó lần lượt có độ dài 4 m; 4,4 m; 4,8 m. Biết đáy bể là phẳng. Hỏi đáy bể nghiêng so với mặt phẳng nằm ngang một góc bao nhiêu độ?</p>', N'<p>Mặt nước là mặt phẳng nằm ngang; ba vị trí $A,B,C$ tạo tam giác đều cạnh 2 m. Chọn hệ toạ độ: mặt nước là $(Oxy)$, $A(0;0;0)$, $B(2;0;0)$, $C(1;\sqrt3;0)$. Các điểm đáy: $A_1(0;0;-4)$, $B_1(2;0;-4{,}4)$, $C_1(1;\sqrt3;-4{,}8)$.</p>
<p>$\overrightarrow{A_1B_1}=(2;0;-0{,}4)$, $\overrightarrow{A_1C_1}=(1;\sqrt3;-0{,}8)$. Pháp tuyến của đáy: $\vec n=[\overrightarrow{A_1B_1},\overrightarrow{A_1C_1}]=(0{,}4\sqrt3;\,1{,}2;\,2\sqrt3)$, $|\vec n|=\sqrt{0{,}48+1{,}44+12}=\sqrt{13{,}92}$.</p>
<p>Góc giữa đáy và mặt nằm ngang: $$\cos\varphi=\dfrac{2\sqrt3}{\sqrt{13{,}92}}\approx0{,}9285\Rightarrow\varphi\approx21{,}8^\circ.$$</p>
<p>(Cách khác: độ dốc theo hướng dốc nhất là $\sqrt{0{,}2^2+(0{,}2\sqrt3)^2}=0{,}4$, nên $\tan\varphi=0{,}4$.)</p>
<p><b>Đáp số:</b> khoảng $21{,}8^\circ$.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.51.</b> Bản vẽ thiết kế của một công trình được vẽ trong một hệ trục toạ độ $Oxyz$. Sàn nhà của công trình thuộc mặt phẳng $(Oxy)$, đường ống thoát nước thẳng và đi qua hai điểm $A(1;2;-1)$ và $B(5;6;-2)$. Tính góc tạo bởi đường ống thoát nước và mặt sàn.</p>', N'<p>$\overrightarrow{AB}=(4;4;-1)$, $|\overrightarrow{AB}|=\sqrt{33}$. Mặt sàn $(Oxy)$ có pháp tuyến $\vec k=(0;0;1)$.</p>
<p>$$\sin\varphi=\dfrac{|\overrightarrow{AB}\cdot\vec k|}{|\overrightarrow{AB}||\vec k|}=\dfrac{1}{\sqrt{33}}\approx0{,}174\Rightarrow\varphi\approx10^\circ.$$</p>
<p><b>Đáp số:</b> khoảng $10^\circ$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.52.</b> Nếu đứng trước biển và nhìn ra xa, người ta sẽ thấy một đường giao giữa mặt biển và bầu trời, đó là đường chân trời đối với người quan sát (H.5.45a). Về mặt Vật lí, đường chân trời là đường giới hạn phần Trái Đất mà người quan sát có thể nhìn thấy được (phần còn lại bị chính Trái Đất che khuất). Ta có thể hình dung rằng, nếu người quan sát ở tại đỉnh của một chiếc nón và Trái Đất được “thả” vào trong chiếc nón đó, thì đường chân trời trong trường hợp này là đường chạm giữa Trái Đất và chiếc nón (H.5.45b). Trong mô hình toán học, đường chân trời đối với người quan sát tại vị trí $B$ là tập hợp những điểm $A$ nằm trên bề mặt Trái Đất sao cho $\widehat{BAO}=90^\circ$, với $O$ là tâm Trái Đất (H.5.45c). Trong không gian $Oxyz$, giả sử bề mặt Trái Đất $(S)$ có phương trình $x^2+y^2+z^2=1$ và người quan sát ở vị trí $B(1;1;-1)$.</p><p>Gọi $A$ là một vị trí bất kì trên đường chân trời đối với người quan sát ở vị trí $B$. Tính khoảng cách $AB$.</p><p><div><img src="/static/img/sgk/hinh-5-45.png" alt="Hình minh họa bài 5.52 (SGK)"></div></p>', N'<p>Mặt Trái Đất $(S)$: $x^2+y^2+z^2=1$ có tâm $O(0;0;0)$, bán kính $OA=1$. Người quan sát tại $B(1;1;-1)$ nên $OB^2=1+1+1=3$.</p>
<p>Vì $\widehat{BAO}=90^\circ$, tam giác $OAB$ vuông tại $A$, theo định lí Pythagore:</p>
<p>$$AB^2=OB^2-OA^2=3-1=2\Rightarrow AB=\sqrt2.$$</p>
<p><b>Đáp số:</b> $AB=\sqrt2$.</p>', 3, 0, 1, @t1);

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
INSERT INTO LessonMaterials (LessonId, MaterialType, Title, Url, ContentText, OrderIndex, CreatedBy) VALUES (@l, 'YOUTUBE', N'Video bài giảng: Bài 18. Xác suất có điều kiện', 'https://www.youtube.com/watch?v=wabUhaxcrUc', NULL, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.1.</b> Một hộp kín đựng 20 tấm thẻ giống hệt nhau đánh số từ 1 đến 20. Một người rút ngẫu nhiên ra một tấm thẻ từ trong hộp. Người đó được thông báo rằng thẻ rút ra mang số chẵn. Tính xác suất để người đó rút được thẻ số 10.</p>', N'<p>Gọi $A$: "thẻ rút ra mang số chẵn", $B$: "thẻ rút ra là số 10". Trong 20 thẻ có 10 thẻ chẵn nên $P(A)=\dfrac{10}{20}=\dfrac12$. Vì $B\subset A$ nên $P(AB)=P(B)=\dfrac1{20}$.</p>
<p>$$P(B\mid A)=\frac{P(AB)}{P(A)}=\frac{1/20}{1/2}=\frac1{10}.$$</p>
<p>(Cách khác: biết thẻ chẵn thì có 10 khả năng đồng khả năng, trong đó 1 khả năng là thẻ số 10.)</p>
<p><b>Đáp số:</b> $\dfrac1{10}$</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.2.</b> Cho $P(A)=0{,}2$; $P(B)=0{,}51$; $P(B\mid A)=0{,}8$. Tính $P(A\mid B)$.</p>', N'<p>Theo công thức nhân xác suất: $P(AB)=P(A)\cdot P(B\mid A)=0{,}2\cdot0{,}8=0{,}16$.</p>
<p>Do đó $$P(A\mid B)=\frac{P(AB)}{P(B)}=\frac{0{,}16}{0{,}51}=\frac{16}{51}\approx0{,}314.$$</p>
<p><b>Đáp số:</b> $P(A\mid B)=\dfrac{16}{51}\approx0{,}314$</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.3.</b> Gieo hai con xúc xắc cân đối, đồng chất. Tính xác suất để:</p>
<ol type="a"><li>Tổng số chấm xuất hiện trên hai con xúc xắc bằng 7 nếu biết rằng ít nhất có một con xúc xắc xuất hiện mặt 5 chấm;</li>
<li>Có ít nhất có một con xúc xắc xuất hiện mặt 5 chấm nếu biết rằng tổng số chấm xuất hiện trên hai con xúc xắc bằng 7.</li></ol>', N'<p>Không gian mẫu gồm $6\cdot6=36$ kết quả đồng khả năng.</p>
<p><b>a)</b> Gọi $A$: "tổng bằng 7", $B$: "có ít nhất một con ra 5 chấm". $B$ có $36-25=11$ kết quả nên $P(B)=\dfrac{11}{36}$. $AB=\{(2,5),(5,2)\}$ nên $P(AB)=\dfrac2{36}$. Suy ra $$P(A\mid B)=\frac{2/36}{11/36}=\frac2{11}.$$</p>
<p><b>b)</b> $A$ có 6 kết quả: $(1,6),(2,5),(3,4),(4,3),(5,2),(6,1)$ nên $P(A)=\dfrac6{36}$. Do đó $$P(B\mid A)=\frac{P(AB)}{P(A)}=\frac{2/36}{6/36}=\frac13.$$</p>
<p><b>Đáp số:</b> a) $\dfrac2{11}$; b) $\dfrac13$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.4.</b> Gieo hai con xúc xắc cân đối, đồng chất. Tính xác suất để tổng số chấm xuất hiện trên hai con xúc xắc đó không nhỏ hơn 10 nếu biết rằng có ít nhất một con xúc xắc xuất hiện mặt 5 chấm.</p>', N'<p>Gọi $A$: "tổng số chấm không nhỏ hơn 10", $B$: "có ít nhất một con ra 5 chấm". Không gian mẫu có 36 kết quả.</p>
<p>$B$ có 11 kết quả nên $P(B)=\dfrac{11}{36}$. Các kết quả có tổng không nhỏ hơn 10 và có mặt 5 chấm: $(5,5),(5,6),(6,5)$, nên $P(AB)=\dfrac3{36}$.</p>
<p>$$P(A\mid B)=\frac{P(AB)}{P(B)}=\frac{3/36}{11/36}=\frac3{11}.$$</p>
<p><b>Đáp số:</b> $\dfrac3{11}$</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.5.</b> Bạn An phải thực hiện hai thí nghiệm liên tiếp. Thí nghiệm thứ nhất có xác suất thành công là 0,7. Nếu thí nghiệm thứ nhất thành công thì xác suất thành công của thí nghiệm thứ hai là 0,9. Nếu thí nghiệm thứ nhất không thành công thì xác suất thành công của thí nghiệm thứ hai chỉ là 0,4. Tính xác suất để:</p>
<ol type="a"><li>Cả hai thí nghiệm đều thành công;</li>
<li>Cả hai thí nghiệm đều không thành công;</li>
<li>Thí nghiệm thứ nhất thành công và thí nghiệm thứ hai không thành công.</li></ol>', N'<p>Gọi $A$: "thí nghiệm thứ nhất thành công", $B$: "thí nghiệm thứ hai thành công". Ta có $P(A)=0{,}7$, $P(\overline A)=0{,}3$, $P(B\mid A)=0{,}9$, $P(B\mid\overline A)=0{,}4$, nên $P(\overline B\mid A)=0{,}1$ và $P(\overline B\mid\overline A)=0{,}6$.</p>
<p><b>a)</b> $P(AB)=P(A)P(B\mid A)=0{,}7\cdot0{,}9=0{,}63$.</p>
<p><b>b)</b> $P(\overline A\,\overline B)=P(\overline A)P(\overline B\mid\overline A)=0{,}3\cdot0{,}6=0{,}18$.</p>
<p><b>c)</b> $P(A\overline B)=P(A)P(\overline B\mid A)=0{,}7\cdot0{,}1=0{,}07$.</p>
<p><b>Đáp số:</b> a) $0{,}63$; b) $0{,}18$; c) $0{,}07$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.6.</b> Trong một túi có một số chiếc kẹo cùng loại, chỉ khác màu, trong đó có 6 cái kẹo màu cam, còn lại là kẹo màu vàng. Hà lấy ngẫu nhiên một cái kẹo từ trong túi, không trả lại. Sau đó Hà lại lấy ngẫu nhiên thêm một cái kẹo khác từ trong túi. Biết rằng xác suất Hà lấy được cả hai cái kẹo màu cam là $\dfrac{1}{3}$. Hỏi ban đầu trong túi có bao nhiêu cái kẹo?</p>', N'<p>Gọi $n$ là số kẹo ban đầu (với $n \ge 2$), trong đó có 6 kẹo cam. Xác suất lần thứ nhất lấy được kẹo cam là $\dfrac6n$; sau đó còn $n-1$ kẹo, trong đó 5 kẹo cam, nên xác suất lần thứ hai lấy được kẹo cam là $\dfrac5{n-1}$.</p>
<p>Xác suất cả hai là kẹo cam: $\dfrac6n\cdot\dfrac5{n-1}=\dfrac13$, suy ra $n(n-1)=90$, hay $n^2-n-90=0$. Giải ra $n=10$ hoặc $n=-9$ (loại).</p>
<p>Kiểm tra: $\dfrac6{10}\cdot\dfrac59=\dfrac13$ (đúng).</p>
<p><b>Đáp số:</b> Ban đầu trong túi có 10 cái kẹo.</p>', 3, 0, 1, @t1);
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
INSERT INTO LessonMaterials (LessonId, MaterialType, Title, Url, ContentText, OrderIndex, CreatedBy) VALUES (@l, 'YOUTUBE', N'Video bài giảng: Bài 19. Công thức xác suất toàn phần và công thức Bayes', 'https://www.youtube.com/watch?v=_aTZ6QynR2U', NULL, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.7.</b> Trong quân sự, một máy bay chiến đấu của đối phương có thể xuất hiện ở vị trí X với xác suất 0,55. Nếu máy bay đó không xuất hiện ở vị trí X thì nó xuất hiện ở vị trí Y. Để phòng thủ, các bệ phóng tên lửa được bố trí tại các vị trí X và Y. Khi máy bay đối phương xuất hiện ở vị trí X hoặc Y thì tên lửa sẽ được phóng để hạ máy bay đó.</p>
<p>Xét phương án tác chiến sau: Nếu máy bay xuất hiện tại X thì bắn 2 quả tên lửa và nếu máy bay xuất hiện tại Y thì bắn 1 quả tên lửa. Biết rằng, xác suất bắn trúng máy bay của mỗi quả tên lửa là 0,8 và các bệ phóng tên lửa hoạt động độc lập. Máy bay bị bắn hạ nếu nó trúng ít nhất 1 quả tên lửa. Tính xác suất bắn hạ máy bay đối phương trong phương án tác chiến nêu trên.</p>', N'<p>Gọi $X$: "máy bay xuất hiện ở vị trí X", $\overline X$: "máy bay xuất hiện ở vị trí Y", $H$: "máy bay bị bắn hạ". Khi đó $P(X)=0{,}55$, $P(\overline X)=0{,}45$.</p>
<p>Nếu máy bay ở X, bắn 2 quả, độc lập, máy bay không bị hạ khi cả 2 quả đều trượt: $P(H\mid X)=1-(1-0{,}8)^2=1-0{,}04=0{,}96$.</p>
<p>Nếu máy bay ở Y, bắn 1 quả: $P(H\mid\overline X)=0{,}8$.</p>
<p>Theo công thức xác suất toàn phần: $$P(H)=P(X)P(H\mid X)+P(\overline X)P(H\mid\overline X)=0{,}55\cdot0{,}96+0{,}45\cdot0{,}8=0{,}528+0{,}36=0{,}888.$$</p>
<p><b>Đáp số:</b> $0{,}888$</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.8.</b> Có hai chuồng thỏ. Chuồng I có 5 con thỏ đen và 10 con thỏ trắng. Chuồng II có 7 con thỏ đen và 3 con thỏ trắng. Trước tiên, từ chuồng II lấy ra ngẫu nhiên 1 con thỏ rồi cho vào chuồng I. Sau đó, từ chuồng I lấy ra ngẫu nhiên 1 con thỏ. Tính xác suất để con thỏ được lấy ra là con thỏ trắng.</p>', N'<p>Gọi $A$: "con thỏ lấy từ chuồng II cho vào chuồng I là thỏ đen", $\overline A$: "là thỏ trắng"; $B$: "con thỏ lấy ra từ chuồng I (sau đó) là thỏ trắng".</p>
<p>Chuồng II có 10 con: $P(A)=\dfrac7{10}$, $P(\overline A)=\dfrac3{10}$.</p>
<p>Nếu $A$ xảy ra: chuồng I có 16 con, gồm 6 đen, 10 trắng nên $P(B\mid A)=\dfrac{10}{16}$. Nếu $\overline A$ xảy ra: chuồng I có 16 con, gồm 5 đen, 11 trắng nên $P(B\mid\overline A)=\dfrac{11}{16}$.</p>
<p>Theo công thức xác suất toàn phần: $$P(B)=\frac7{10}\cdot\frac{10}{16}+\frac3{10}\cdot\frac{11}{16}=\frac{70+33}{160}=\frac{103}{160}=0{,}64375.$$</p>
<p><b>Đáp số:</b> $\dfrac{103}{160}\approx0{,}644$</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.9.</b> Tại nhà máy X sản xuất linh kiện điện tử, tỉ lệ sản phẩm đạt tiêu chuẩn là 80%. Trước khi xuất xưởng ra thị trường, các linh kiện điện tử đều phải qua khâu kiểm tra chất lượng để đóng dấu OTK. Vì sự kiểm tra không tuyệt đối hoàn hảo nên nếu một linh kiện điện tử đạt tiêu chuẩn thì nó có xác suất 0,99 được đóng dấu OTK; nếu một linh kiện điện tử không đạt tiêu chuẩn thì nó có xác suất 0,95 không được đóng dấu OTK. Chọn ngẫu nhiên một linh kiện điện tử của nhà máy X trên thị trường.</p>
<ol type="a"><li>Tính xác suất để linh kiện điện tử đó được đóng dấu OTK.</li>
<li>Dùng sơ đồ hình cây, hãy mô tả cách tính xác suất để linh kiện điện tử được chọn không được đóng dấu OTK.</li></ol>', N'<p>Gọi $A$: "linh kiện đạt tiêu chuẩn", $B$: "linh kiện được đóng dấu OTK". Ta có $P(A)=0{,}8$, $P(\overline A)=0{,}2$, $P(B\mid A)=0{,}99$, $P(\overline B\mid\overline A)=0{,}95$ nên $P(B\mid\overline A)=0{,}05$.</p>
<p><b>a)</b> $P(B)=P(A)P(B\mid A)+P(\overline A)P(B\mid\overline A)=0{,}8\cdot0{,}99+0{,}2\cdot0{,}05=0{,}792+0{,}01=0{,}802$.</p>
<p><b>b)</b> Sơ đồ hình cây: từ gốc rẽ hai nhánh $A$ (xác suất 0,8) và $\overline A$ (xác suất 0,2). Từ nhánh $A$ rẽ tiếp hai nhánh: $B$ (0,99) và $\overline B$ (0,01). Từ nhánh $\overline A$ rẽ tiếp: $B$ (0,05) và $\overline B$ (0,95). Xác suất không được đóng dấu là tổng xác suất của các đường đi dẫn đến $\overline B$:</p>
<p>$$P(\overline B)=0{,}8\cdot0{,}01+0{,}2\cdot0{,}95=0{,}008+0{,}19=0{,}198.$$</p>
<p>(Kiểm tra: $1-0{,}802=0{,}198$.)</p>
<p><b>Đáp số:</b> a) $0{,}802$; b) $0{,}198$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.10.</b> Có hai đội thi đấu môn Bắn súng. Đội I có 5 vận động viên, đội II có 7 vận động viên. Xác suất đạt huy chương vàng của mỗi vận động viên đội I và đội II tương ứng là 0,65 và 0,55. Chọn ngẫu nhiên một vận động viên.</p>
<ol type="a"><li>Tính xác suất để vận động viên này đạt huy chương vàng;</li>
<li>Giả sử vận động viên được chọn đạt huy chương vàng. Tính xác suất để vận động viên này thuộc đội I.</li></ol>', N'<p>Gọi $A_1$: "vận động viên thuộc đội I", $A_2$: "thuộc đội II", $H$: "đạt huy chương vàng". Tổng cộng có 12 vận động viên nên $P(A_1)=\dfrac5{12}$, $P(A_2)=\dfrac7{12}$; $P(H\mid A_1)=0{,}65$, $P(H\mid A_2)=0{,}55$.</p>
<p><b>a)</b> $$P(H)=\frac5{12}\cdot0{,}65+\frac7{12}\cdot0{,}55=\frac{3{,}25+3{,}85}{12}=\frac{7{,}1}{12}=\frac{71}{120}\approx0{,}592.$$</p>
<p><b>b)</b> Theo công thức Bayes: $$P(A_1\mid H)=\frac{P(A_1)P(H\mid A_1)}{P(H)}=\frac{3{,}25/12}{7{,}1/12}=\frac{325}{710}=\frac{65}{142}\approx0{,}458.$$</p>
<p><b>Đáp số:</b> a) $\dfrac{71}{120}\approx0{,}592$; b) $\dfrac{65}{142}\approx0{,}458$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.11.</b> Một bộ lọc được sử dụng để chặn thư rác trong các tài khoản thư điện tử. Tuy nhiên, vì bộ lọc không tuyệt đối hoàn hảo nên một thư rác bị chặn với xác suất 0,95 và một thư đúng (không phải là thư rác) bị chặn với xác suất 0,01. Thống kê cho thấy tỉ lệ thư rác là 3%.</p>
<ol type="a"><li>Chọn ngẫu nhiên một thư bị chặn. Tính xác suất để đó là thư rác.</li>
<li>Chọn ngẫu nhiên một thư không bị chặn. Tính xác suất để đó là thư đúng.</li>
<li>Trong số các thư bị chặn, có bao nhiêu phần trăm là thư đúng? Trong số các thư không bị chặn, có bao nhiêu phần trăm là thư rác?</li></ol>', N'<p>Gọi $A$: "thư là thư rác", $B$: "thư bị chặn". Ta có $P(A)=0{,}03$, $P(\overline A)=0{,}97$, $P(B\mid A)=0{,}95$, $P(B\mid\overline A)=0{,}01$.</p>
<p>Xác suất toàn phần: $P(B)=0{,}03\cdot0{,}95+0{,}97\cdot0{,}01=0{,}0285+0{,}0097=0{,}0382$, và $P(\overline B)=1-0{,}0382=0{,}9618$.</p>
<p><b>a)</b> $P(A\mid B)=\dfrac{0{,}0285}{0{,}0382}=\dfrac{285}{382}\approx0{,}746$.</p>
<p><b>b)</b> $P(\overline A\mid\overline B)=\dfrac{P(\overline A)P(\overline B\mid\overline A)}{P(\overline B)}=\dfrac{0{,}97\cdot0{,}99}{0{,}9618}=\dfrac{0{,}9603}{0{,}9618}=\dfrac{3201}{3206}\approx0{,}998$.</p>
<p><b>c)</b> Trong các thư bị chặn, tỉ lệ thư đúng là $P(\overline A\mid B)=1-\dfrac{285}{382}=\dfrac{97}{382}\approx25{,}4\%$.</p>
<p>Trong các thư không bị chặn, tỉ lệ thư rác là $P(A\mid\overline B)=1-\dfrac{3201}{3206}=\dfrac5{3206}\approx0{,}16\%$.</p>
<p><b>Đáp số:</b> a) $\approx0{,}746$; b) $\approx0{,}998$; c) khoảng $25{,}4\%$ và khoảng $0{,}16\%$.</p>', 2, 0, 1, @t1);
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
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.17.</b> <i>Sử dụng dữ kiện sau để trả lời các câu từ 6.15 đến 6.17:</i> Bạn An có một túi gồm một số chiếc kẹo cùng loại, chỉ khác màu, trong đó có 6 chiếc kẹo sô cô la đen, còn lại 4 chiếc kẹo sô cô la trắng. An lấy ngẫu nhiên 1 chiếc kẹo trong túi để cho Bình, rồi lại lấy ngẫu nhiên tiếp 1 chiếc kẹo nữa trong túi và cũng đưa cho Bình.</p><p>Xác suất để Bình nhận được chiếc kẹo sô cô la đen ở lần thứ nhất, chiếc kẹo sô cô la trắng ở lần thứ hai là</p><ul><li>A. $\dfrac{1}{5}$</li><li>B. $\dfrac{3}{16}$</li><li>C. $\dfrac{1}{4}$</li><li>D. $\dfrac{4}{17}$</li></ul>', N'<p>Trong túi có $6+4=10$ chiếc kẹo. Gọi $A$: "kẹo thứ nhất là sô cô la đen", $B$: "kẹo thứ hai là sô cô la trắng".</p>
<p>$P(A)=\dfrac6{10}=\dfrac35$. Sau khi lấy 1 kẹo đen, còn 9 kẹo trong đó có 4 kẹo trắng nên $P(B\mid A)=\dfrac49$.</p>
<p>$$P(AB)=P(A)P(B\mid A)=\frac35\cdot\frac49=\frac{12}{45}=\frac4{15}.$$</p>
<p>So với các phương án: $\dfrac15=\dfrac3{15}$, $\dfrac3{16}$, $\dfrac14$, $\dfrac4{17}$ đều khác $\dfrac4{15}$. Vậy đề in trong sách không có phương án nào đúng; đáp số đúng là $\dfrac4{15}$.</p>
<p><b>Đáp án:</b> Không có phương án nào (A, B, C, D) đúng; kết quả đúng là $\dfrac4{15}$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.18.</b> Để thử nghiệm tác dụng điều trị bệnh mất ngủ của hai loại thuốc X và Y, người ta tiến hành thử nghiệm trên 4 000 người bệnh tình nguyện. Kết quả được cho trong bảng thống kê $2\times 2$ sau:</p>
<table border="1"><tr><th>Kết quả \ Dùng thuốc</th><th>X</th><th>Y</th></tr><tr><td>Khỏi bệnh</td><td>1 600</td><td>1 200</td></tr><tr><td>Không khỏi bệnh</td><td>800</td><td>400</td></tr></table>
<p>Chọn ngẫu nhiên 1 người bệnh tham gia tình nguyện thử nghiệm thuốc.</p>
<ol type="a"><li>Tính xác suất để người đó khỏi bệnh nếu biết người bệnh đó uống thuốc X.</li>
<li>Tính xác suất để người bệnh đó uống thuốc Y, biết rằng người đó khỏi bệnh.</li></ol>', N'<p>Tổng số người: $1600+1200+800+400=4000$. Số người dùng thuốc X: $1600+800=2400$; dùng thuốc Y: $1200+400=1600$; số người khỏi bệnh: $1600+1200=2800$.</p>
<p><b>a)</b> Gọi $A$: "người đó uống thuốc X", $K$: "khỏi bệnh". Trong 2400 người uống thuốc X có 1600 người khỏi bệnh nên $$P(K\mid A)=\frac{1600}{2400}=\frac23.$$</p>
<p><b>b)</b> Gọi $B$: "người đó uống thuốc Y". Trong 2800 người khỏi bệnh có 1200 người uống thuốc Y nên $$P(B\mid K)=\frac{1200}{2800}=\frac37.$$</p>
<p><b>Đáp số:</b> a) $\dfrac23$; b) $\dfrac37$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.19.</b> Một nhóm có 25 học sinh, trong đó có 14 em học khá môn Toán, 16 em học khá môn Vật lí, 1 em không học khá cả hai môn Toán và Vật lí. Chọn ngẫu nhiên một học sinh trong số đó. Tính xác suất để học sinh đó:</p>
<ol type="a"><li>Học khá môn Toán, đồng thời học khá môn Vật lí;</li>
<li>Học khá môn Toán, nhưng không học khá môn Vật lí;</li>
<li>Học khá môn Toán, biết rằng học sinh đó học khá môn Vật lí.</li></ol>', N'<p>Gọi $T$: "học khá Toán", $L$: "học khá Vật lí". Có 1 em không khá cả hai môn nên số em khá ít nhất một môn là $25-1=24$. Số em khá cả hai môn: $n(T\cap L)=14+16-24=6$.</p>
<p><b>a)</b> $P(TL)=\dfrac6{25}$.</p>
<p><b>b)</b> Số em khá Toán nhưng không khá Lí là $14-6=8$ nên $P(T\overline L)=\dfrac8{25}$.</p>
<p><b>c)</b> $P(T\mid L)=\dfrac{P(TL)}{P(L)}=\dfrac{6/25}{16/25}=\dfrac6{16}=\dfrac38$.</p>
<p><b>Đáp số:</b> a) $\dfrac6{25}$; b) $\dfrac8{25}$; c) $\dfrac38$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.20.</b> Chuồng I có 5 con gà mái, 2 con gà trống. Chuồng II có 3 con gà mái, 5 con gà trống. Trong một trò chơi, người chơi bắt một con gà trong số đó theo cách sau: &ldquo;Người chơi tung một con xúc xắc cân đối, đồng chất. Nếu số chấm chia hết cho 3 thì người chơi chọn chuồng I. Nếu số chấm không chia hết cho 3 thì người chơi chọn chuồng II. Sau đó, từ chuồng đã chọn người chơi bắt ngẫu nhiên một con gà&rdquo;. Tính xác suất để người chơi bắt được con gà mái.</p>', N'<p>Gọi $A$: "số chấm chia hết cho 3" (mặt 3 hoặc 6), nên $P(A)=\dfrac26=\dfrac13$ (chọn chuồng I) và $P(\overline A)=\dfrac23$ (chọn chuồng II). Gọi $B$: "bắt được gà mái".</p>
<p>Chuồng I có 7 con, 5 mái: $P(B\mid A)=\dfrac57$. Chuồng II có 8 con, 3 mái: $P(B\mid\overline A)=\dfrac38$.</p>
<p>$$P(B)=\frac13\cdot\frac57+\frac23\cdot\frac38=\frac5{21}+\frac14=\frac{20+21}{84}=\frac{41}{84}.$$</p>
<p><b>Đáp số:</b> $\dfrac{41}{84}\approx0{,}488$</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.21.</b> Một loại vaccine được tiêm ở địa phương X. Người có bệnh nền thì với xác suất 0,35 có phản ứng phụ sau tiêm; người không có bệnh nền thì chỉ có phản ứng phụ sau tiêm với xác suất 0,16. Chọn ngẫu nhiên một người được tiêm vaccine và người này có phản ứng phụ. Tính xác suất để người này có bệnh nền, biết rằng tỉ lệ người có bệnh nền ở địa phương X là 18%.</p>', N'<p>Gọi $A$: "người có bệnh nền", $B$: "người có phản ứng phụ sau tiêm". Ta có $P(A)=0{,}18$, $P(\overline A)=0{,}82$, $P(B\mid A)=0{,}35$, $P(B\mid\overline A)=0{,}16$.</p>
<p>Xác suất toàn phần: $P(B)=0{,}18\cdot0{,}35+0{,}82\cdot0{,}16=0{,}063+0{,}1312=0{,}1942$.</p>
<p>Theo công thức Bayes: $$P(A\mid B)=\frac{P(A)P(B\mid A)}{P(B)}=\frac{0{,}063}{0{,}1942}=\frac{315}{971}\approx0{,}324.$$</p>
<p><b>Đáp số:</b> $\dfrac{315}{971}\approx0{,}324$</p>', 3, 0, 1, @t1);

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
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 16.</b> Khảo sát sự biến thiên và vẽ đồ thị của các hàm số sau:</p><ol type="a"><li>$y=x^3-3x^2$;</li><li>$y=\dfrac{2x+1}{x+2}$;</li><li>$y=\dfrac{2x^2+x-2}{x-1}$.</li></ol>', N'<p><b>a) $y=x^3-3x^2$</b></p><ul><li>TXĐ: $\mathbb{R}$. $y''=3x^2-6x=3x(x-2)$, $y''=0 \Leftrightarrow x=0$ hoặc $x=2$.</li><li>Hàm số đồng biến trên $(-\infty;0)$ và $(2;+\infty)$, nghịch biến trên $(0;2)$. Cực đại tại $x=0$, $y_{CĐ}=0$; cực tiểu tại $x=2$, $y_{CT}=-4$.</li><li>Giới hạn: $\lim_{x\to\pm\infty}y=\pm\infty$.</li><li>Đồ thị cắt $Ox$ tại $(0;0)$, $(3;0)$; cắt $Oy$ tại $(0;0)$; $y''''=6x-6=0$ tại $x=1$ nên điểm uốn $(1;-2)$.</li></ul><p><b>b) $y=\dfrac{2x+1}{x+2}$</b></p><ul><li>TXĐ: $\mathbb{R}\setminus\{-2\}$. $y''=\dfrac{3}{(x+2)^2}\gt 0$ nên hàm số đồng biến trên từng khoảng $(-\infty;-2)$, $(-2;+\infty)$, không có cực trị.</li><li>$\lim_{x\to\pm\infty}y=2$ nên TCN: $y=2$; $\lim_{x\to-2^{\pm}}y=\mp\infty$ nên TCĐ: $x=-2$.</li><li>Đồ thị cắt $Ox$ tại $\left(-\dfrac12;0\right)$, cắt $Oy$ tại $\left(0;\dfrac12\right)$; nhận $(-2;2)$ làm tâm đối xứng.</li></ul><p><b>c) $y=\dfrac{2x^2+x-2}{x-1}=2x+3+\dfrac{1}{x-1}$</b></p><ul><li>TXĐ: $\mathbb{R}\setminus\{1\}$. $y''=2-\dfrac{1}{(x-1)^2}=0 \Leftrightarrow x=1\pm\dfrac{\sqrt2}{2}$.</li><li>Đồng biến trên $\left(-\infty;1-\dfrac{\sqrt2}{2}\right)$ và $\left(1+\dfrac{\sqrt2}{2};+\infty\right)$; nghịch biến trên $\left(1-\dfrac{\sqrt2}{2};1\right)$ và $\left(1;1+\dfrac{\sqrt2}{2}\right)$.</li><li>Cực đại: $\left(1-\dfrac{\sqrt2}{2};\,5-2\sqrt2\right)$; cực tiểu: $\left(1+\dfrac{\sqrt2}{2};\,5+2\sqrt2\right)$.</li><li>TCĐ: $x=1$; TCX: $y=2x+3$.</li><li>Giao $Oy$: $(0;2)$; giao $Ox$: $x=\dfrac{-1\pm\sqrt{17}}{4}$.</li></ul><p>Từ bảng biến thiên và các điểm đặc biệt, vẽ đồ thị tương ứng.</p><p><b>Đáp số:</b> a) cực đại $(0;0)$, cực tiểu $(2;-4)$; b) TCĐ $x=-2$, TCN $y=2$, hàm đồng biến; c) TCĐ $x=1$, TCX $y=2x+3$, cực đại $y=5-2\sqrt2$, cực tiểu $y=5+2\sqrt2$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 17.</b> Tìm giá trị lớn nhất và giá trị nhỏ nhất của các hàm số sau:</p><ol type="a"><li>$y=\dfrac{x+1}{\sqrt{x^2+1}}$ trên đoạn $[-1;2]$;</li><li>$y=x+\sqrt{1-x^2}$.</li></ol>', N'<p><b>a)</b> Trên $[-1;2]$: $y''=\dfrac{\sqrt{x^2+1}-\dfrac{x(x+1)}{\sqrt{x^2+1}}}{x^2+1}=\dfrac{1-x}{(x^2+1)\sqrt{x^2+1}}$.</p><p>$y''=0 \Leftrightarrow x=1\in[-1;2]$. Ta có $y(-1)=0$, $y(1)=\sqrt2$, $y(2)=\dfrac{3}{\sqrt5}\approx 1{,}342$.</p><p>Vậy $\max y=\sqrt2$ tại $x=1$; $\min y=0$ tại $x=-1$.</p><p><b>b)</b> TXĐ: $[-1;1]$. $y''=1-\dfrac{x}{\sqrt{1-x^2}}$ với $x\in(-1;1)$.</p><p>$y''=0 \Leftrightarrow \sqrt{1-x^2}=x \Leftrightarrow x\ge0,\ 1-x^2=x^2 \Leftrightarrow x=\dfrac{\sqrt2}{2}$.</p><p>$y(-1)=-1$, $y\left(\dfrac{\sqrt2}{2}\right)=\sqrt2$, $y(1)=1$.</p><p><b>Đáp số:</b> a) $\max=\sqrt2$, $\min=0$; b) $\max=\sqrt2$, $\min=-1$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 18.</b> Khi đạp phanh thì một ô tô chuyển động chậm dần đều với gia tốc có độ lớn $10\ \mathrm{m/s^2}$.</p><ol type="a"><li>Nếu khi bắt đầu đạp phanh ô tô đang chạy với vận tốc 54 km/h thì sau bao lâu kể từ khi đạp phanh, ô tô sẽ dừng lại?</li><li>Nếu ô tô dừng lại trong vòng 20 m sau khi đạp phanh thì vận tốc lớn nhất của ô tô ngay trước lúc đạp phanh (tính bằng km/h) có thể là bao nhiêu?</li></ol>', N'<p>Chọn gốc thời gian lúc bắt đầu đạp phanh: $v(t)=v_0-10t$ (m/s), quãng đường $s(t)=v_0t-5t^2$.</p><p><b>a)</b> $v_0=54\ \mathrm{km/h}=\dfrac{54\cdot1000}{3600}=15\ \mathrm{m/s}$. Ô tô dừng khi $v(t)=0$: $15-10t=0 \Rightarrow t=1{,}5$ s.</p><p><b>b)</b> Ô tô dừng sau $t=\dfrac{v_0}{10}$, quãng đường đi được là $s=\dfrac{v_0^2}{20}$. Điều kiện $s\le 20$ cho $v_0^2\le400$, tức $v_0\le20\ \mathrm{m/s}=72\ \mathrm{km/h}$.</p><p><b>Đáp số:</b> a) $1{,}5$ giây; b) tối đa $72$ km/h.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 19.</b> Tìm hàm số $f(x)$ biết rằng $f''(x)=x-\dfrac{1}{x^2}+2$ và $f(1)=2$.</p>', N'<p>$f(x)=\displaystyle\int\left(x-\dfrac1{x^2}+2\right)\mathrm{d}x=\dfrac{x^2}{2}+\dfrac1x+2x+C$.</p><p>$f(1)=\dfrac12+1+2+C=2 \Rightarrow C=-\dfrac32$.</p><p><b>Đáp số:</b> $f(x)=\dfrac{x^2}{2}+2x+\dfrac1x-\dfrac32$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 20.</b> Tính các tích phân sau:</p><ol type="a"><li>$I=\displaystyle\int_0^2 \left|x^2-x\right|\mathrm{d}x$;</li><li>$I=\displaystyle\int_0^1 (2x-1)^3\,\mathrm{d}x$;</li><li>$I=\displaystyle\int_0^{\pi/4}\left(3\sin x-\dfrac{2}{\cos^2 x}\right)\mathrm{d}x$;</li><li>$I=\displaystyle\int_1^2\left(2e^x-\dfrac{1}{x}\right)\mathrm{d}x$.</li></ol>', N'<p><b>a)</b> $x^2-x\le0$ khi $x\in[0;1]$ và $\ge0$ khi $x\in[1;2]$. Do đó
$$I=\int_0^1(x-x^2)\,\mathrm{d}x+\int_1^2(x^2-x)\,\mathrm{d}x=\left(\dfrac12-\dfrac13\right)+\left(\dfrac83-2-\dfrac13+\dfrac12\right)=\dfrac16+\dfrac56=1.$$</p><p><b>b)</b> $I=\left.\dfrac{(2x-1)^4}{8}\right|_0^1=\dfrac{1-1}{8}=0$.</p><p><b>c)</b> $I=\left.(-3\cos x-2\tan x)\right|_0^{\pi/4}=\left(-\dfrac{3\sqrt2}{2}-2\right)-(-3)=1-\dfrac{3\sqrt2}{2}$.</p><p><b>d)</b> $I=\left.(2e^x-\ln x)\right|_1^2=(2e^2-\ln2)-2e=2e^2-2e-\ln2$.</p><p><b>Đáp số:</b> a) $1$; b) $0$; c) $1-\dfrac{3\sqrt2}{2}$; d) $2e^2-2e-\ln2$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 21.</b> Tính diện tích hình phẳng giới hạn bởi các đường $y=x^2-1$, $y=x+5$, $x=-2$, $x=3$.</p>', N'<p>Xét $(x+5)-(x^2-1)=-x^2+x+6=-(x+2)(x-3)\ge0$ với mọi $x\in[-2;3]$, nên đường $y=x+5$ nằm trên parabol trên đoạn này.</p><p>$$S=\int_{-2}^{3}(-x^2+x+6)\,\mathrm{d}x=\left.\left(-\dfrac{x^3}{3}+\dfrac{x^2}{2}+6x\right)\right|_{-2}^{3}=\dfrac{27}{2}-\left(-\dfrac{22}{3}\right)=\dfrac{125}{6}.$$</p><p><b>Đáp số:</b> $S=\dfrac{125}{6}$ (đơn vị diện tích).</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 22.</b> Gọi $(H)$ là hình phẳng giới hạn bởi các đường $y=-x^2+2x$, $y=0$, $x=0$ và $x=2$. Tính thể tích của khối tròn xoay thu được khi quay hình phẳng $(H)$ xung quanh trục $Ox$.</p>', N'<p>Thể tích khối tròn xoay: $V=\pi\displaystyle\int_0^2(-x^2+2x)^2\,\mathrm{d}x=\pi\int_0^2(x^4-4x^3+4x^2)\,\mathrm{d}x$.</p><p>$=\pi\left.\left(\dfrac{x^5}{5}-x^4+\dfrac{4x^3}{3}\right)\right|_0^2=\pi\left(\dfrac{32}{5}-16+\dfrac{32}{3}\right)=\dfrac{16\pi}{15}$.</p><p><b>Đáp số:</b> $V=\dfrac{16\pi}{15}$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 23.</b> Cho tứ diện $ABCD$, chứng minh rằng:</p><ol type="a"><li>$\overrightarrow{AB}\cdot\overrightarrow{CD}+\overrightarrow{AC}\cdot\overrightarrow{DB}+\overrightarrow{AD}\cdot\overrightarrow{BC}=0$;</li><li>Nếu $AB\perp CD$ và $AC\perp BD$ thì $AD\perp BC$.</li></ol>', N'<p>Đặt $\vec b=\overrightarrow{AB}$, $\vec c=\overrightarrow{AC}$, $\vec d=\overrightarrow{AD}$. Khi đó $\overrightarrow{CD}=\vec d-\vec c$, $\overrightarrow{DB}=\vec b-\vec d$, $\overrightarrow{BC}=\vec c-\vec b$.</p><p><b>a)</b> Vế trái $=\vec b(\vec d-\vec c)+\vec c(\vec b-\vec d)+\vec d(\vec c-\vec b)$
$=\vec b\vec d-\vec b\vec c+\vec c\vec b-\vec c\vec d+\vec d\vec c-\vec d\vec b=0$.</p><p><b>b)</b> $AB\perp CD$ nên $\overrightarrow{AB}\cdot\overrightarrow{CD}=0$; $AC\perp BD$ nên $\overrightarrow{AC}\cdot\overrightarrow{DB}=0$. Theo a) suy ra $\overrightarrow{AD}\cdot\overrightarrow{BC}=0$, tức $AD\perp BC$.</p><p><b>Đáp số:</b> Đã chứng minh.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 24.</b> Cho hình lập phương $ABCD.A''B''C''D''$ có cạnh bằng $a$. Gọi $G$ là trọng tâm của tam giác $BC''D''$.</p><ol type="a"><li>Chứng minh rằng $\overrightarrow{AG}=\dfrac{2}{3}\left(\overrightarrow{AB}+\overrightarrow{AD}+\overrightarrow{AA''}\right)$.</li><li>Tính theo $a$ độ dài đoạn thẳng $AG$.</li></ol>', N'<p><b>a)</b> $G$ là trọng tâm tam giác $BC''D''$ nên $\overrightarrow{AG}=\dfrac13\left(\overrightarrow{AB}+\overrightarrow{AC''}+\overrightarrow{AD''}\right)$.</p><p>Mà $\overrightarrow{AC''}=\overrightarrow{AB}+\overrightarrow{AD}+\overrightarrow{AA''}$, $\overrightarrow{AD''}=\overrightarrow{AD}+\overrightarrow{AA''}$. Do đó
$\overrightarrow{AG}=\dfrac13\left(2\overrightarrow{AB}+2\overrightarrow{AD}+2\overrightarrow{AA''}\right)=\dfrac23\left(\overrightarrow{AB}+\overrightarrow{AD}+\overrightarrow{AA''}\right)$.</p><p><b>b)</b> $\overrightarrow{AB}+\overrightarrow{AD}+\overrightarrow{AA''}=\overrightarrow{AC''}$ có độ dài $a\sqrt3$. Vậy $AG=\dfrac23AC''=\dfrac{2a\sqrt3}{3}$.</p><p><b>Đáp số:</b> $AG=\dfrac{2\sqrt3}{3}a$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 25.</b> Trong không gian $Oxyz$, cho điểm $I(-1;2;1)$ và mặt phẳng $(P): 2x-2y-z-5=0$. Viết phương trình đường thẳng $d$ đi qua $I$ và vuông góc với mặt phẳng $(P)$.</p>', N'<p>Mặt phẳng $(P)$ có vectơ pháp tuyến $\vec n=(2;-2;-1)$. Đường thẳng $d\perp(P)$ nhận $\vec n$ làm vectơ chỉ phương và đi qua $I(-1;2;1)$.</p><p>Phương trình tham số: $\begin{cases}x=-1+2t\\ y=2-2t\\ z=1-t\end{cases}$, hay phương trình chính tắc $\dfrac{x+1}{2}=\dfrac{y-2}{-2}=\dfrac{z-1}{-1}$.</p><p><b>Đáp số:</b> $d:\ \dfrac{x+1}{2}=\dfrac{y-2}{-2}=\dfrac{z-1}{-1}$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 26.</b> Trong không gian $Oxyz$, cho điểm $A(-1;1;2)$ và đường thẳng $d:\begin{cases}x=2+t\\ y=3-2t\\ z=-1+2t.\end{cases}$</p><ol type="a"><li>Viết phương trình đường thẳng $d''$ đi qua $A$ và song song với đường thẳng $d$.</li><li>Viết phương trình mặt phẳng $(P)$ chứa điểm $A$ và đường thẳng $d$.</li></ol>', N'<p>$d$ đi qua $B(2;3;-1)$ và có vectơ chỉ phương $\vec u=(1;-2;2)$.</p><p><b>a)</b> $d''\parallel d$ nên nhận $\vec u=(1;-2;2)$ làm vectơ chỉ phương; $d''$ đi qua $A(-1;1;2)$: $\begin{cases}x=-1+t\\ y=1-2t\\ z=2+2t.\end{cases}$</p><p><b>b)</b> $\overrightarrow{AB}=(3;2;-3)$. Vectơ pháp tuyến của $(P)$: $\vec n=[\overrightarrow{AB},\vec u]=(2\cdot2-(-3)(-2);\ (-3)\cdot1-3\cdot2;\ 3\cdot(-2)-2\cdot1)=(-2;-9;-8)$, chọn $(2;9;8)$.</p><p>$(P)$ đi qua $A$: $2(x+1)+9(y-1)+8(z-2)=0 \Leftrightarrow 2x+9y+8z-23=0$. (Kiểm tra: $B$ thoả mãn: $4+27-8-23=0$.)</p><p><b>Đáp số:</b> a) $d'':\ \dfrac{x+1}{1}=\dfrac{y-1}{-2}=\dfrac{z-2}{2}$; b) $(P):\ 2x+9y+8z-23=0$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 27.</b> Trong không gian $Oxyz$, cho hai điểm $A(1;-2;3)$, $B(3;0;-1)$.</p><ol type="a"><li>Viết phương trình mặt phẳng $(OAB)$.</li><li>Tìm toạ độ trung điểm $I$ của đoạn thẳng $AB$.</li><li>Tìm điểm $M$ thuộc mặt phẳng $(Oxy)$ sao cho $\left|\overrightarrow{MA}+\overrightarrow{MB}\right|$ nhỏ nhất.</li></ol>', N'<p><b>a)</b> $\overrightarrow{OA}=(1;-2;3)$, $\overrightarrow{OB}=(3;0;-1)$. Vectơ pháp tuyến: $[\overrightarrow{OA},\overrightarrow{OB}]=(2;10;6)$, chọn $\vec n=(1;5;3)$. Mặt phẳng đi qua $O$: $x+5y+3z=0$. (Kiểm tra: $A$: $1-10+9=0$; $B$: $3-3=0$.)</p><p><b>b)</b> $I=\left(\dfrac{1+3}{2};\dfrac{-2+0}{2};\dfrac{3-1}{2}\right)=(2;-1;1)$.</p><p><b>c)</b> $\overrightarrow{MA}+\overrightarrow{MB}=2\overrightarrow{MI}$ nên $\left|\overrightarrow{MA}+\overrightarrow{MB}\right|=2MI$ nhỏ nhất khi $M$ là hình chiếu vuông góc của $I$ trên $(Oxy)$. Vậy $M(2;-1;0)$ (khi đó giá trị nhỏ nhất bằng $2$).</p><p><b>Đáp số:</b> a) $x+5y+3z=0$; b) $I(2;-1;1)$; c) $M(2;-1;0)$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 28.</b> Trong không gian $Oxyz$, có một nguồn sáng phát ra từ điểm $S(2;3;5)$ và một đoạn dây thẳng nối từ điểm $A(1;2;1)$ đến điểm $B(3;1;2)$. Dưới nguồn sáng, đoạn dây trên có bóng trên mặt phẳng $(xOy)$ là một đoạn thẳng. Tính độ dài đoạn thẳng đó.</p>', N'<p>Bóng của một điểm $P$ là giao điểm của đường thẳng $SP$ với mặt phẳng $z=0$.</p><p>Điểm $A''$ (bóng của $A$): $S+t\overrightarrow{SA}=(2-t;\,3-t;\,5-4t)$, $z=0\Rightarrow t=\dfrac54$, nên $A''\left(\dfrac34;\dfrac74;0\right)$.</p><p>Điểm $B''$ (bóng của $B$): $\overrightarrow{SB}=(1;-2;-3)$, $S+t\overrightarrow{SB}=(2+t;\,3-2t;\,5-3t)$, $z=0\Rightarrow t=\dfrac53$, nên $B''\left(\dfrac{11}{3};-\dfrac13;0\right)$.</p><p>Bóng của đoạn $AB$ là đoạn $A''B''$ với $\overrightarrow{A''B''}=\left(\dfrac{35}{12};-\dfrac{25}{12};0\right)$, nên $A''B''=\dfrac{\sqrt{35^2+25^2}}{12}=\dfrac{\sqrt{1850}}{12}=\dfrac{5\sqrt{74}}{12}$.</p><p><b>Đáp số:</b> $\dfrac{5\sqrt{74}}{12}\approx3{,}59$.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 29.</b> Thu nhập của người lao động trong một công ty được cho trong bảng sau:</p><table border="1"><tr><th>Mức thu nhập (triệu đồng)</th><td>[8; 10)</td><td>[10; 12)</td><td>[12; 14)</td><td>[14; 16)</td><td>[16; 18)</td></tr><tr><th>Số người</th><td>2</td><td>60</td><td>90</td><td>50</td><td>1</td></tr></table><p>Tính khoảng tứ phân vị cho mẫu số liệu này.</p>', N'<p>Cỡ mẫu $n=2+60+90+50+1=203$. Tần số tích luỹ: $2;\ 62;\ 152;\ 202;\ 203$.</p><ul><li>$Q_1$ ứng với $\dfrac{203}{4}=50{,}75$: thuộc nhóm $[10;12)$. $Q_1=10+\dfrac{50{,}75-2}{60}\cdot2=11{,}625$.</li><li>$Q_3$ ứng với $\dfrac{3\cdot203}{4}=152{,}25$: thuộc nhóm $[14;16)$ (tần số tích luỹ trước đó là $152$). $Q_3=14+\dfrac{152{,}25-152}{50}\cdot2=14{,}01$.</li></ul><p>Khoảng tứ phân vị: $\Delta_Q=Q_3-Q_1=14{,}01-11{,}625=2{,}385$ (triệu đồng).</p><p><b>Đáp số:</b> $\Delta_Q\approx2{,}385$ triệu đồng.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 30.</b> Có hai chuồng nuôi gà. Chuồng I có 8 con gà trống và 13 con gà mái. Chuồng II có 10 con gà trống và 6 con gà mái. An bắt ngẫu nhiên một con gà từ chuồng II đem thả vào chuồng I. Sau đó, Bình bắt ngẫu nhiên một con gà từ chuồng I.</p><p>Giả sử Bình bắt được con gà mái. Tính xác suất để Bình bắt được con gà mái của chuồng I.</p>', N'<p>Gọi $A$: "An thả gà trống từ chuồng II", $\bar A$: "An thả gà mái", $P(A)=\dfrac{10}{16}$, $P(\bar A)=\dfrac6{16}$. Gọi $B$: "Bình bắt được gà mái". Chuồng I sau khi thả có $22$ con.</p><ul><li>Nếu An thả gà trống: chuồng I có $13$ mái, $P(B|A)=\dfrac{13}{22}$.</li><li>Nếu An thả gà mái: chuồng I có $14$ mái, $P(B|\bar A)=\dfrac{14}{22}$.</li></ul><p>$P(B)=\dfrac{10}{16}\cdot\dfrac{13}{22}+\dfrac6{16}\cdot\dfrac{14}{22}=\dfrac{214}{352}=\dfrac{107}{176}$.</p><p>Biến cố "gà mái bắt được vốn thuộc chuồng I" có xác suất đồng thời với $B$ là $\dfrac{13}{22}$ (13 mái gốc chuồng I trong 22 con, bất kể An thả con nào). Xác suất cần tìm:
$$\dfrac{13/22}{107/176}=\dfrac{13\cdot8}{107}=\dfrac{104}{107}.$$</p><p><b>Đáp số:</b> $\dfrac{104}{107}\approx0{,}972$.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 31.</b> Trong một tuần, Sơn chọn ngẫu nhiên ba ngày chạy bộ buổi sáng. Nếu chạy bộ thì xác suất Sơn ăn thêm một quả trứng vào bữa sáng hôm đó là 0,7. Nếu không chạy bộ thì xác suất Sơn ăn thêm một quả trứng vào bữa sáng hôm đó là 0,25. Chọn ngẫu nhiên một ngày trong tuần của Sơn. Tính xác suất để hôm đó Sơn chạy bộ nếu biết rằng bữa sáng hôm đó Sơn có ăn thêm một quả trứng.</p>', N'<p>Gọi $A$: "hôm đó Sơn chạy bộ", $B$: "hôm đó Sơn ăn thêm trứng". Có $3$ ngày chạy bộ trong $7$ ngày: $P(A)=\dfrac37$, $P(\bar A)=\dfrac47$; $P(B|A)=0{,}7$, $P(B|\bar A)=0{,}25$.</p><p>Công thức xác suất toàn phần: $P(B)=\dfrac37\cdot0{,}7+\dfrac47\cdot0{,}25=\dfrac{2{,}1+1}{7}=\dfrac{3{,}1}{7}$.</p><p>Công thức Bayes: $P(A|B)=\dfrac{P(A)P(B|A)}{P(B)}=\dfrac{2{,}1/7}{3{,}1/7}=\dfrac{21}{31}$.</p><p><b>Đáp số:</b> $\dfrac{21}{31}\approx0{,}677$.</p>', 3, 0, 1, @t1);

COMMIT TRANSACTION;

SELECT t.TopicName, COUNT(DISTINCT l.LessonId) AS Lessons, COUNT(q.QuestionId) AS Questions
FROM Topics t LEFT JOIN Lessons l ON l.TopicId = t.TopicId LEFT JOIN Questions q ON q.LessonId = l.LessonId
GROUP BY t.TopicId, t.TopicName, t.OrderIndex ORDER BY t.OrderIndex;
GO
