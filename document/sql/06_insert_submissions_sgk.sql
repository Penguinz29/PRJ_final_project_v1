-- =====================================================================================================================
-- File: document/sql/06_insert_submissions_sgk.sql — CHỈ INSERT lịch sử làm bài mẫu (không DELETE / UPDATE / DROP bảng thật)
-- Chạy SAU 04_data_sgk_toan12.sql. KHÔNG chạy cùng 05_data_submissions_sgk.sql (06 đã bao gồm phần tự luận của 05, chạy cả hai sẽ trùng).
-- Giữ nguyên mọi bài làm đang có; có thể chạy lại nhiều lần mà không nhân đôi:
--   * Tự luận: bỏ qua bài làm của cùng học sinh + cùng câu + cùng nội dung đã có.
--   * Trắc nghiệm: chỉ nạp cho bài học còn ít hơn 3 lượt làm trắc nghiệm; mỗi bài học nạp 3 câu CHƯA ai làm.
-- Nội dung:
--   1. TỰ LUẬN chương I (Bài 1 - Bài 5 và Bài tập cuối chương I): 33 bài làm của 10 học sinh, đủ mức (làm tốt / thiếu bước / sai hướng),
--      AI_GRADED (chờ duyệt, FinalScore = AiScore) và REVIEWED (giáo viên chỉnh điểm + nhận xét; AiScore giữ nguyên, BR-09).
--   2. TRẮC NGHIỆM cho các bài học có câu trắc nghiệm nhưng chưa có (đủ) lượt làm - phần lớn là "Bài tập cuối chương" của các chương khác:
--      mỗi bài học 3 câu, mỗi câu do 2 học sinh khác nhau làm (độ chính xác khoảng 65%), trải 14 ngày gần đây.
-- Chạy bằng SSMS. Nếu dùng sqlcmd phải thêm -x (công thức LaTeX có "$(" bị hiểu nhầm là biến).
-- =====================================================================================================================
USE MathTutorDB;
GO

SET NOCOUNT ON;

DECLARE @t1 INT = (SELECT UserId FROM Users WHERE Username = 'teacher1');
DECLARE @Today DATETIME = CAST(CAST(GETDATE() AS DATE) AS DATETIME);

BEGIN TRANSACTION;

-- =====================================================================================================================
-- 1. Tự luận chương I. Câu hỏi tìm theo số bài in trong đề ("Bài 1.10." ...).
-- =====================================================================================================================
CREATE TABLE #E (Tag VARCHAR(10) PRIMARY KEY, QuestionId INT NOT NULL, LessonId INT NOT NULL);
INSERT INTO #E (Tag, QuestionId, LessonId)
SELECT t.Tag, q.QuestionId, q.LessonId
FROM (VALUES ('1.2'), ('1.3'), ('1.4'), ('1.5'), ('1.7'), ('1.8'), ('1.9'), ('1.10'), ('1.12'), ('1.13'), ('1.14'),
             ('1.16'), ('1.17'), ('1.18'), ('1.19'), ('1.21'), ('1.22'), ('1.24'), ('1.26'), ('1.27'), ('1.28'),
             ('1.40'), ('1.41'), ('1.42'), ('1.45'), ('1.46')) AS t (Tag)
JOIN Questions q ON q.QuestionType = 'ESSAY' AND q.IsActive = 1 AND q.Content LIKE N'%<b>Bài ' + t.Tag + N'.</b>%';

-- Cột: Username, Tag, AiScore, FinalScore, Dy (số ngày trước), Hr/Mins (giờ nộp), Ans, AiFeedback, SuggestedCorrection, TeacherFeedback
-- TeacherFeedback NULL  -> AI_GRADED (chờ duyệt, FinalScore = AiScore); khác NULL -> REVIEWED (đã duyệt).
INSERT INTO Submissions (StudentId, LessonId, QuestionId, QuestionType, StudentAnswer, EssayImagePath, AiScore, FinalScore,
                         AiFeedback, SuggestedCorrection, TeacherFeedback, [Status], IsReviewed, ReviewedBy, ReviewedAt, SubmittedAt)
SELECT u.UserId, e.LessonId, e.QuestionId, 'ESSAY', v.Ans, NULL, v.Ai, v.Fin, v.Fb, v.Fix, v.TFb,
       CASE WHEN v.TFb IS NULL THEN 'AI_GRADED' ELSE 'REVIEWED' END,
       CASE WHEN v.TFb IS NULL THEN 0 ELSE 1 END,
       CASE WHEN v.TFb IS NULL THEN NULL ELSE @t1 END,
       CASE WHEN v.TFb IS NULL THEN NULL ELSE DATEADD(HOUR, 14, DATEADD(DAY, -(v.Dy - 1), @Today)) END,
       DATEADD(MINUTE, v.Mins, DATEADD(HOUR, v.Hr, DATEADD(DAY, -v.Dy, @Today)))
FROM (VALUES
 -- ------------------------------------------------ Bài 1 (Bài 1.2 - 1.9, 1.12, 1.14) ------------------------------------------------
 ('student1', '1.2', 9.50, 10.00, 10, 20, 5,
  N'a) y'' = x^2 - 4x + 3 = (x - 1)(x - 3). y'' > 0 khi x < 1 hoặc x > 3; y'' < 0 khi 1 < x < 3. Vậy hàm số đồng biến trên (-∞; 1) và (3; +∞), nghịch biến trên (1; 3).
b) y'' = -3x^2 + 4x - 5, có Δ'' = 4 - 15 = -11 < 0 và a = -3 < 0 nên y'' < 0 với mọi x. Vậy hàm số nghịch biến trên R.',
  N'Lập luận chặt chẽ, xét dấu đạo hàm đầy đủ ở cả hai ý, kết luận đúng. Chỉ có thể trình bày thêm tập xác định $\mathbb{R}$.', NULL,
  N'Em làm rất tốt, cả hai ý đều đủ bước. Cô cho 10 điểm.'),
 ('student2', '1.2', 8.75, 8.75, 1, 20, 10,
  N'a) y'' = x^2 - 4x + 3 = (x-1)(x-3). y'' > 0 khi x < 1 hoặc x > 3, y'' < 0 khi 1 < x < 3 nên đồng biến trên (-∞;1) và (3;+∞), nghịch biến trên (1;3).
b) y'' = -3x^2 + 4x - 5 luôn âm nên hàm số nghịch biến trên R.',
  N'Ý a) đầy đủ, chính xác. Ý b) kết luận đúng nhưng chưa chứng minh $y''<0$ với mọi $x$ (thiếu $\Delta''<0$ và hệ số $a<0$).',
  N'Bổ sung: $y''=-3x^2+4x-5$ có $\Delta''=-11<0$, $a=-3<0$ nên $y''<0$ với mọi $x$.', NULL),
 ('student11', '1.2', 5.00, 5.00, 1, 21, 15,
  N'a) y'' = x^2 - 4x + 3 = 0 khi x = 1 hoặc x = 3. Vậy hàm số đồng biến trên (1;3).
b) y'' = -3x^2 + 4x - 5 có Δ'' < 0 nên y'' không đổi dấu, hệ số a < 0 nên y'' < 0. Hàm số nghịch biến trên R.',
  N'Ý a) tìm đúng nghiệm nhưng xét dấu sai: $y''=(x-1)(x-3)>0$ ngoài khoảng nghiệm. Ý b) đúng và có lập luận.',
  N'Hàm số đồng biến trên $(-\infty;1)$ và $(3;+\infty)$, nghịch biến trên $(1;3)$.', NULL),
 ('student3', '1.3', 5.50, 6.00, 8, 21, 0,
  N'a) TXĐ: R \ {-2}. y'' = 5/(x+2)^2 > 0 nên hàm số đồng biến trên (-∞; -2) và (-2; +∞).
b) TXĐ: R \ {3}. y'' = (x^2 - 6x - 7)/(x - 3)^2. y'' = 0 khi x = -1 hoặc x = 7. Trên (-1; 7) thì y'' > 0 nên hàm số đồng biến trên (-1; 7), nghịch biến ở hai bên.',
  N'Ý a) đúng và đủ. Ý b) tính đúng đạo hàm và nghiệm nhưng xét dấu sai: $x^2-6x-7$ là tam thức có hệ số $a=1>0$ nên dương ngoài khoảng nghiệm, âm trong $(-1;7)$. Quên loại điểm $x=3$ khỏi khoảng nghịch biến.',
  N'$y''>0$ khi $x<-1$ hoặc $x>7$: đồng biến trên $(-\infty;-1)$ và $(7;+\infty)$; $y''<0$ trên $(-1;3)$ và $(3;7)$: nghịch biến.',
  N'Em tính đạo hàm đúng nhưng nhớ lại quy tắc xét dấu tam thức bậc hai nhé. Cô cho 6 điểm vì phần tính toán đã chính xác.'),
 ('student3', '1.3', 8.50, 8.50, 6, 18, 40,
  N'a) TXĐ R \ {-2}. y'' = 5/(x+2)^2 > 0 nên đồng biến trên (-∞;-2) và (-2;+∞).
b) TXĐ R \ {3}. y'' = (x^2 - 6x - 7)/(x-3)^2, y'' = 0 khi x = -1 hoặc x = 7. y'' > 0 khi x < -1 hoặc x > 7 nên đồng biến trên (-∞;-1) và (7;+∞); y'' < 0 khi -1 < x < 7 (x khác 3) nên nghịch biến trên (-1;3) và (3;7).',
  N'Làm lại sau khi được giáo viên nhận xét: xét dấu đúng, loại đúng điểm $x=3$. Chỉ thiếu bảng biến thiên minh họa.', NULL, NULL),
 ('student12', '1.3', 3.50, 3.50, 1, 20, 35,
  N'a) y'' = 5/(x+2)^2 > 0 nên hàm số đồng biến trên R.
b) em chưa biết làm.',
  N'Ý a) đạo hàm đúng nhưng kết luận sai: hàm số không xác định tại $x=-2$ nên chỉ đồng biến trên từng khoảng $(-\infty;-2)$ và $(-2;+\infty)$. Ý b) bỏ trống.',
  N'Cần nêu tập xác định $\mathbb{R}\setminus\{-2\}$ trước khi xét chiều biến thiên.', NULL),
 ('student4', '1.4', 6.25, 6.25, 2, 21, 5,
  N'a) TXĐ [-2;2]. y'' = -x/√(4-x^2). y'' > 0 khi -2 < x < 0 nên đồng biến trên (-2;0); y'' < 0 khi 0 < x < 2 nên nghịch biến trên (0;2).
b) y'' = (1 - x^2)/(x^2+1)^2. Đồng biến trên (-1;1).',
  N'Ý a) đúng và đủ. Ý b) đạo hàm đúng nhưng thiếu các khoảng nghịch biến $(-\infty;-1)$ và $(1;+\infty)$ khi $y''<0$.',
  N'Kết luận đầy đủ: đồng biến trên $(-1;1)$, nghịch biến trên $(-\infty;-1)$ và $(1;+\infty)$.', NULL),
 ('student6', '1.4', 8.00, 8.00, 1, 20, 20,
  N'a) TXĐ [-2;2], y'' = -x/√(4-x^2); đồng biến trên (-2;0), nghịch biến trên (0;2).
b) TXĐ R, y'' = (1-x^2)/(x^2+1)^2; đồng biến trên (-1;1), nghịch biến trên (-∞;-1) và (1;+∞).',
  N'Kết quả hoàn toàn đúng. Nên ghi rõ dấu của $y''$ từng khoảng (hoặc lập bảng biến thiên) để bài làm đầy đủ hơn.', NULL, NULL),
 ('student5', '1.5', 8.50, 8.50, 2, 19, 50,
  N'a) Năm 2000: t = 0, N(0) = 10/5 = 2 nghìn người. Năm 2015: t = 15, N(15) = (25.15+10)/20 = 385/20 = 19,25 nghìn người.
b) N''(t) = (25(t+5) - (25t+10))/(t+5)^2 = 115/(t+5)^2 > 0 nên dân số luôn tăng. lim N(t) = 25 khi t → +∞. Vậy dân số tăng dần tới 25 nghìn người.',
  N'Ý a) chính xác. Ý b) tính đúng đạo hàm và giới hạn, nhưng chưa chỉ ra $N(t)<25$ với mọi $t$ để khẳng định không vượt ngưỡng.',
  N'Thêm: $25-N(t)=\dfrac{115}{t+5}>0$ nên $N(t)<25$ với mọi $t\ge0$.', NULL),
 ('student1', '1.5', 9.75, 9.75, 1, 19, 5,
  N'a) N(0) = 10/5 = 2 (nghìn người); N(15) = (25.15 + 10)/(15 + 5) = 385/20 = 19,25 (nghìn người).
b) N''(t) = 115/(t+5)^2 > 0 với mọi t ≥ 0 nên N(t) luôn tăng. Ta có 25 - N(t) = 115/(t+5) > 0 nên N(t) < 25; ngoài ra lim N(t) = 25 khi t → +∞. Vậy dân số luôn tăng nhưng không vượt quá 25 nghìn người.',
  N'Bài làm gần như hoàn hảo, có cả chứng minh $N(t)<25$ và giới hạn. Chỉ cần ghi đơn vị ở kết luận cuối.', NULL, NULL),
 ('student6', '1.7', 5.00, 5.50, 6, 20, 0,
  N'a) y'' = 6x^2 - 18x + 12 = 6(x - 1)(x - 2). Cực đại tại x = 1, y = 0. Cực tiểu tại x = 2, y = -1.
b) y'' = 4x^3 - 8x = 4x(x^2 - 2) = 0 khi x = 0, x = ±√2. Cực đại tại (0; 2), cực tiểu tại (±√2; -2).
c), d) em chưa làm kịp.',
  N'Hai ý a), b) đúng kết quả và có xét dấu đạo hàm (bảng biến thiên chưa vẽ ra). Hai ý c), d) bỏ trống nên chỉ được nửa số điểm.',
  N'Ý c): $y''=\dfrac{x^2-2x-1}{(x-1)^2}$, cực trị tại $x=1\pm\sqrt2$. Ý d): tập xác định $[0;2]$, cực đại tại $x=1$, $y=\sqrt2$.',
  N'Làm đúng hai ý đầu nhưng em cần hoàn thành bài. Cô cộng 0,5 điểm vì trình bày sạch.'),
 ('student2', '1.8', 8.00, 8.00, 3, 19, 0,
  N'a) f(0) = 0. Giới hạn bên phải: lim x→0+ |x|/x = lim x/x = 1. Giới hạn bên trái: lim x→0- |x|/x = lim -x/x = -1. Hai giới hạn khác nhau nên hàm số không có đạo hàm tại 0.
b) Với mọi x khác 0 thì |x| > 0 = f(0), nên trên khoảng (-1; 1) ta có f(x) > f(0) với mọi x khác 0. Theo định nghĩa, hàm số đạt cực tiểu tại x = 0.',
  N'Hai ý đều đúng và đầy đủ. Nên nêu rõ giá trị cực tiểu bằng $0$.', NULL,
  N'Đồng ý với điểm AI.'),
 ('student7', '1.8', 7.50, 7.50, 1, 19, 25,
  N'a) f(0) = 0. lim x→0+ |x|/x = 1, lim x→0- |x|/x = -1 nên không tồn tại đạo hàm tại x = 0.
b) |x| >= 0 = f(0) với mọi x nên f đạt cực tiểu tại x = 0.',
  N'Ý a) đúng. Ý b) kết luận đúng nhưng chưa chỉ ra khoảng chứa $0$ và dấu bất đẳng thức chặt $f(x)>f(0)$ với $x\ne0$ theo định nghĩa cực trị.',
  N'Với mọi $x\in(-1;1)\setminus\{0\}$: $|x|>0=f(0)$, nên $f$ đạt cực tiểu tại $x=0$.', NULL),
 ('student8', '1.9', 3.00, 3.50, 4, 22, 0,
  N'f''(t) = 25000e^(-t)/(1 + 5e^(-t))^2. Vì e^(-t) giảm khi t tăng nên f''(t) lớn nhất khi t = 0. Khi đó f''(0) = 25000/36 ≈ 694 sản phẩm/năm. Vậy tốc độ bán hàng lớn nhất ngay khi phát hành (t = 0).',
  N'Tính đúng $f''(t)$ nhưng lập luận sai: mẫu số $(1+5e^{-t})^2$ cũng thay đổi theo $t$ nên không thể kết luận chỉ từ $e^{-t}$ giảm. Cần khảo sát hàm $g(t)=f''(t)$.',
  N'Đặt $g(t)=\dfrac{25000e^t}{(e^t+5)^2}$, $g''(t)=0\Leftrightarrow t=\ln5$; $g$ đạt lớn nhất tại $t=\ln5\approx1{,}6$ năm.',
  N'Em có tính đúng đạo hàm bậc nhất, cô cho thêm 0,5 điểm. Cần đạo hàm lần nữa để tìm cực đại của tốc độ.'),
 -- ------------------------------------------------ Bài 2 (GTLN - GTNN) ------------------------------------------------
 ('student3', '1.10', 7.50, 7.50, 2, 20, 30,
  N'a) y'' = -2x + 4 = 0 khi x = 2, y(2) = 7. Hàm số có max = 7, không có min.
b) y'' = 3x^2 - 4x = 0 khi x = 0 hoặc x = 4/3. Lập bảng biến thiên trên [0; +∞): min = y(4/3) = -5/27, không có max.
c) y'' = (x^2 - 2x - 1)/(x-1)^2 = 0 khi x = 1 + √2 (x > 1). min = 2√2, không có max.
d) TXĐ [0; 2], y(1) = √2 nên max = √2, không có min.',
  N'Ý a), b), c) đúng và có bảng biến thiên. Ý d) sai kết luận: $y(0)=y(2)=0$ nên hàm số có giá trị nhỏ nhất bằng $0$.',
  N'Ý d): $\max=\sqrt2$ tại $x=1$, $\min=0$ tại $x=0$ và $x=2$.', NULL),
 ('student1', '1.12', 5.50, 6.00, 12, 20, 15,
  N'a) y'' = 6x^2 - 6 = 0 khi x = ±1. y(-1) = 7, y(1) = -1, y(2) = 7. Vậy max = 7, min = -1.
b) y'' = 4x^3 - 6x = 0 khi x = 0 hoặc x = √(3/2). y(0) = 2, y(√1,5) = -1/4, y(3) = 56. Vậy max = 56, min = -1/4.
c), d) em làm tương tự nhưng chưa kịp tính.',
  N'Hai ý a), b) chính xác, so sánh đủ các điểm tới hạn và đầu mút. Hai ý c), d) bỏ trống.',
  N'Ý c): $y''=1-2\cos2x=0\Leftrightarrow x=\dfrac\pi6$ hoặc $x=\dfrac{5\pi}6$ trên $[0;\pi]$; so sánh $y(0)$, $y(\tfrac\pi6)$, $y(\tfrac{5\pi}6)$, $y(\pi)$.',
  N'Hai ý đầu rất chắc. Em cần làm nốt hai ý còn lại; cô giữ điểm 6.'),
 ('student5', '1.13', 9.75, 9.75, 2, 21, 10,
  N'Gọi hai cạnh là a và b, chu vi 24 nên a + b = 12, b = 12 - a (0 < a < 12). Diện tích S = a(12 - a) = -a^2 + 12a. S'' = -2a + 12 = 0 khi a = 6. Lập bảng biến thiên được S lớn nhất khi a = 6, b = 6, S = 36 cm^2. Vậy hình chữ nhật có diện tích lớn nhất là hình vuông cạnh 6 cm.',
  N'Bài làm đầy đủ, lập luận chặt chẽ. Có thể thêm cách dùng bất đẳng thức $ab\le\left(\dfrac{a+b}2\right)^2$.', NULL, NULL),
 ('student6', '1.14', 3.50, 4.00, 5, 21, 20,
  N'Gọi cạnh đáy là x, chiều cao h. Diện tích bề mặt 2x^2 + 4xh = 108 nên h = (54 - x^2)/(2x). Thể tích V = x^2.h = x(54 - x^2)/2 = (54x - x^3)/2. V'' = (54 - 3x^2)/2 = 0 khi x = 3√2. Vậy đáy hình vuông cạnh 3√2 cm, chiều cao h = 3√2 cm.',
  N'Hướng làm đúng nhưng sai đề: hộp KHÔNG có nắp nên diện tích bề mặt là $x^2+4xh=108$ (một đáy và bốn mặt bên), không phải $2x^2+4xh$.',
  N'$x^2+4xh=108\Rightarrow h=\dfrac{108-x^2}{4x}$; $V=\dfrac{108x-x^3}{4}$, $V''=0\Leftrightarrow x=6$, $h=3$, $V_{\max}=108$ cm$^3$.',
  N'Em đọc kĩ đề: "không có nắp" nên chỉ có một mặt đáy. Phương pháp của em đúng nên cô cho 4 điểm.'),
 -- ------------------------------------------------ Bài 3 (Tiệm cận) ------------------------------------------------
 ('student2', '1.16', 8.50, 8.50, 1, 19, 30,
  N'a) lim x→-∞ f(x) = 2; lim x→+∞ f(x) = 2; lim x→1- f(x) = -∞; lim x→-1+ f(x) = -∞.
b) Tiệm cận ngang: y = 2. Tiệm cận đứng: x = 1 và x = -1.',
  N'Các giới hạn và các đường tiệm cận đều đúng. Bài làm ngắn, nên nêu thêm cách đọc giới hạn từ đồ thị (đồ thị tiến sát đường nào).', NULL, NULL),
 ('student4', '1.17', 9.25, 9.25, 2, 20, 10,
  N'Ta có (x^2 + 2x - 3)/(x - 1) = (x - 1)(x + 3)/(x - 1) = x + 3 với x khác 1. Do đó lim x→1 y = 4 là số hữu hạn nên đường thẳng x = 1 không phải là tiệm cận đứng.',
  N'Lập luận đúng và gọn. Nên nói rõ: tiệm cận đứng cần giới hạn một phía bằng $\pm\infty$.', NULL, NULL),
 ('student7', '1.18', 5.00, 5.00, 3, 20, 45,
  N'a) y = (3-x)/(2x+1): TCĐ x = -1/2, TCN y = -1/2.
b) y = (2x^2+x-1)/(x+2): TCĐ x = -2, TCN y = 2.',
  N'Ý a) đúng. Ý b) sai: bậc của tử lớn hơn bậc của mẫu nên không có tiệm cận ngang; hàm số có tiệm cận xiên.',
  N'Chia đa thức: $\dfrac{2x^2+x-1}{x+2}=2x-3+\dfrac5{x+2}$ nên TCX là $y=2x-3$.', NULL),
 ('student8', '1.19', 8.75, 8.75, 1, 21, 0,
  N'f(x) = C(x)/x = (2x + 50)/x = 2 + 50/x. f''(x) = -50/x^2 < 0 với mọi x > 0 nên f(x) giảm. lim x→+∞ f(x) = 2. Ý nghĩa: sản xuất càng nhiều thì chi phí trung bình mỗi sản phẩm càng giảm và tiến gần tới 2 triệu đồng.',
  N'Đúng và đủ, giải thích ý nghĩa tốt. Chỉ cần ghi rõ điều kiện $x>0$ ngay từ đầu.', NULL, NULL),
 -- ------------------------------------------------ Bài 4 (Khảo sát hàm số) ------------------------------------------------
 ('student3', '1.21', 6.00, 6.50, 9, 20, 0,
  N'a) y = -x^3 + 3x + 1. TXĐ R. y'' = -3x^2 + 3 = 0 khi x = ±1. y'' > 0 trên (-1;1), y'' < 0 trên (-∞;-1) và (1;+∞). Cực đại tại (1; 3), cực tiểu tại (-1; -1). lim x→+∞ y = -∞, lim x→-∞ y = +∞.
b) em chưa làm.',
  N'Ý a) khảo sát đúng sự biến thiên, cực trị và giới hạn. Thiếu bảng biến thiên và đồ thị; ý b) bỏ trống.',
  N'Bổ sung bảng biến thiên và vẽ đồ thị đi qua $(0;1)$, $(-1;-1)$, $(1;3)$.',
  N'Em làm đúng ý a) nhưng còn thiếu hình vẽ và ý b). Cô cho 6,5 điểm.'),
 ('student12', '1.22', 6.50, 6.50, 1, 20, 50,
  N'a) y = (2x+1)/(x+1). TXĐ R \ {-1}. y'' = 1/(x+1)^2 > 0 nên đồng biến trên từng khoảng xác định, không có cực trị. TCĐ x = -1, TCN y = 2.
b) y = (x+3)/(1-x). TXĐ R \ {1}. y'' = 4/(1-x)^2 > 0 nên đồng biến trên từng khoảng, không có cực trị. TCĐ x = 1, TCN y = 1.',
  N'Ý a) đúng và đủ. Ý b) đạo hàm đúng nhưng tiệm cận ngang sai: $\lim_{x\to\pm\infty}\dfrac{x+3}{1-x}=-1$.',
  N'Ý b): tiệm cận ngang $y=-1$.', NULL),
 ('student11', '1.24', 4.50, 4.50, 2, 21, 5,
  N'a) Lượng KOH ban đầu là 30.100 = 3000 mg. Sau khi thêm x ml dung dịch 8 mg/ml thì lượng KOH là 3000 + 8x, thể tích là 30 + x nên C(x) = (3000 + 8x)/(30 + x).
b) C''(x) = (8(30+x) - (3000+8x))/(30+x)^2 > 0 nên C đồng biến trên [0; +∞). TCN y = 8.
c) em chưa giải thích được.',
  N'Ý a) đúng. Ý b) sai dấu đạo hàm: tử số bằng $240-3000=-2760<0$ nên hàm số nghịch biến, mâu thuẫn với ý c) của đề. Ý c) bỏ trống.',
  N'$C''(x)=\dfrac{-2760}{(30+x)^2}<0$; $C(x)=8+\dfrac{2760}{x+30}>8$ và giảm theo $x$.', NULL),
 -- ------------------------------------------------ Bài 5 (Ứng dụng thực tiễn) ------------------------------------------------
 ('student1', '1.26', 9.50, 9.50, 1, 21, 30,
  N'a) v(t) = y'' = 3t^2 - 12, a(t) = v'' = 6t.
b) v = 0 khi t = 2. Với 0 < t < 2 thì v < 0: hạt đi xuống; với t > 2 thì v > 0: hạt đi lên.
c) y(0) = 3, y(2) = -13, y(3) = -6. Quãng đường: |y(2) - y(0)| + |y(3) - y(2)| = 16 + 7 = 23 m.
d) Hạt tăng tốc khi v và a cùng dấu: t > 2. Hạt giảm tốc khi v và a trái dấu: 0 < t < 2.',
  N'Đầy đủ và chính xác, đặc biệt ý c) tính đúng quãng đường vì hạt đổi chiều tại $t=2$.', NULL, NULL),
 ('student4', '1.27', 8.50, 8.50, 2, 20, 40,
  N'a) Hàm chi phí biên C''(x) = 50 - x + 0,00525x^2.
b) C''(100) = 50 - 100 + 52,5 = 2,5. Ý nghĩa: khi đã sản xuất 100 đơn vị thì sản xuất thêm đơn vị thứ 101 tốn khoảng 2,5 trăm nghìn đồng.
c) C(101) - C(100) = 2,52675 xấp xỉ bằng C''(100) = 2,5.',
  N'Đúng cả ba ý, giải thích ý nghĩa chi phí biên tốt. Ý c) nên trình bày phép tính $C(101)$, $C(100)$ cụ thể hơn.', NULL, NULL),
 ('student6', '1.28', 6.50, 6.50, 1, 19, 55,
  N'Gọi k là số lần tăng giá 100 nghìn đồng. Khi đó giá thuê là 8 + 0,1k (triệu) và số căn hộ có người thuê là 100 - k. Doanh thu R(k) = (8 + 0,1k)(100 - k) = 800 + 2k - 0,1k^2. R''(k) = 2 - 0,2k = 0 khi k = 10. Vậy cần đặt giá thuê là 8 + 10 = 18 triệu đồng.',
  N'Lập hàm doanh thu và tìm $k=10$ đúng. Nhưng $k$ là số lần tăng nên giá thuê là $8+0{,}1\cdot10=9$ triệu đồng, không phải $8+10$.',
  N'$R(10)=810$ triệu đồng/tháng khi giá thuê 9 triệu đồng/căn hộ.', NULL),
 -- ------------------------------------------------ Bài tập cuối chương I ------------------------------------------------
 ('student2', '1.40', 7.00, 7.50, 7, 19, 15,
  N'a) y'' = 3(x-1)^2 >= 0 nên hàm số đồng biến trên R, không có cực trị.
b) y'' = 4x^3 - 4x = 4x(x-1)(x+1). Cực đại tại (0; -1), cực tiểu tại (1; -2) và (-1; -2).
c) y'' = 5/(3x+1)^2 > 0 nên đồng biến trên từng khoảng xác định, không có cực trị.
d) y'' = (x^2 + 2x)/(x+1)^2 = 0 khi x = 0 hoặc x = -2. Em chưa lập bảng nên chưa kết luận cực trị.',
  N'Ba ý a), b), c) đúng và đủ. Ý d) tìm đúng điểm tới hạn nhưng chưa xét dấu để kết luận: cực đại $(-2;-2)$, cực tiểu $(0;2)$.',
  N'$y''>0$ khi $x<-2$ hoặc $x>0$; $y''<0$ khi $-2<x<0$ ($x\ne-1$): CĐ $(-2;-2)$, CT $(0;2)$.',
  N'Làm tốt ba ý đầu. Ý d) em nhớ xét dấu đạo hàm rồi mới kết luận cực trị nhé. Cô cho 7,5 điểm.'),
 ('student7', '1.41', 5.00, 5.00, 1, 21, 0,
  N'a) y'' = -7/(3x-2)^2 < 0 nên hàm số nghịch biến trên [2; +∞). max = y(2) = 5/4. lim x→+∞ y = 2/3 nên min = 2/3.
b) TXĐ [-√2; √2]. y'' = -x/√(2-x^2). max y = √2 tại x = 0; min y = 0 tại x = ±√2.',
  N'Ý b) đúng và đủ. Ý a) đúng $\max=\dfrac54$ nhưng sai ở giá trị nhỏ nhất: $\dfrac23$ chỉ là giới hạn, hàm số không bao giờ đạt giá trị này nên không có giá trị nhỏ nhất.',
  N'Ý a): $\max y=\dfrac54$ tại $x=2$, không có giá trị nhỏ nhất.', NULL),
 ('student11', '1.42', 9.25, 9.25, 1, 20, 20,
  N'a) y = (3x-2)/(x+1): lim x→±∞ y = 3 nên TCN y = 3; lim x→-1+ y = -∞ nên TCĐ x = -1.
b) y = (x^2+2x-1)/(2x-1) = x/2 + 5/4 + (1/4)/(2x-1). lim x→1/2+ y = +∞ nên TCĐ x = 1/2; lim [y - (x/2 + 5/4)] = 0 nên TCX y = x/2 + 5/4.',
  N'Chính xác, có chia đa thức để tìm tiệm cận xiên. Nên ghi rõ giới hạn $x\to\pm\infty$ khi kết luận tiệm cận xiên.', NULL, NULL),
 ('student5', '1.45', 9.50, 9.50, 2, 20, 55,
  N'a) Năm 2030: t = 7, N(7) = 100e^0,084 ≈ 108,763. Năm 2035: t = 12, N(12) = 100e^0,144 ≈ 115,488 (triệu người).
b) N''(t) = 1,2e^(0,012t) > 0 với mọi t nên N(t) đồng biến trên [0; 50].
c) N''(t) = 1,6 ⇔ e^(0,012t) = 4/3 ⇔ t = ln(4/3)/0,012 ≈ 23,97 ≈ 24. Vậy vào khoảng năm 2047.',
  N'Tính toán chính xác, đúng đơn vị. Có thể ghi rõ $N''(t)=100\cdot0{,}012e^{0{,}012t}$.', NULL, NULL),
 ('student12', '1.46', 8.00, 8.00, 1, 21, 40,
  N'Đặt BM = x (0 ≤ x ≤ 10), AM = 10 - x, MC = √(x^2 + 16). Chi phí f(x) = 30(10 - x) + 50√(x^2 + 16). f''(x) = -30 + 50x/√(x^2+16) = 0 ⇔ 5x = 3√(x^2+16) ⇔ 25x^2 = 9x^2 + 144 ⇔ x = 3. f(3) = 210 + 250 = 460 triệu đồng. Vậy M cách A 3 km.',
  N'Lập hàm chi phí, tìm $x=3$ và chi phí nhỏ nhất $460$ triệu đúng. Nhưng $x=BM=3$ nên $M$ cách $A$ là $AM=10-3=7$ km, không phải 3 km.',
  N'Kết luận: $M$ cách $A$ $7$ km (cách $B$ $3$ km).', NULL)
) AS v (Username, Tag, Ai, Fin, Dy, Hr, Mins, Ans, Fb, Fix, TFb)
JOIN Users u ON u.Username = v.Username
JOIN #E e ON e.Tag = v.Tag
WHERE NOT EXISTS (SELECT 1 FROM Submissions s
                  WHERE s.StudentId = u.UserId AND s.QuestionId = e.QuestionId AND s.QuestionType = 'ESSAY'
                    AND s.StudentAnswer = v.Ans);

-- =====================================================================================================================
-- 2. Trắc nghiệm: bài học có câu trắc nghiệm nhưng còn ít hơn 3 lượt làm -> nạp 3 câu chưa ai làm, mỗi câu 2 học sinh
-- =====================================================================================================================
CREATE TABLE #St (rn INT PRIMARY KEY, UserId INT NOT NULL);
INSERT INTO #St (rn, UserId)
SELECT ROW_NUMBER() OVER (ORDER BY UserId), UserId
FROM Users
WHERE [Role] = 'STUDENT' AND [Status] = 'ACTIVE'
  AND Username IN ('student1','student2','student3','student4','student5','student6','student7','student8','student11','student12');
DECLARE @S INT = (SELECT COUNT(*) FROM #St);

CREATE TABLE #Pick (QuestionId INT PRIMARY KEY, LessonId INT NOT NULL, Letter CHAR(1) NOT NULL);
INSERT INTO #Pick (QuestionId, LessonId, Letter)
SELECT r.QuestionId, r.LessonId, r.Letter
FROM (
    SELECT q.QuestionId, q.LessonId, o.OptionLetter AS Letter,
           ROW_NUMBER() OVER (PARTITION BY q.LessonId ORDER BY q.QuestionId) AS rk
    FROM Questions q
    JOIN Lessons l ON l.LessonId = q.LessonId AND l.IsActive = 1
    JOIN Topics tp ON tp.TopicId = l.TopicId AND tp.IsActive = 1
    JOIN QuestionOptions o ON o.QuestionId = q.QuestionId AND o.IsCorrect = 1
    WHERE q.QuestionType = 'MCQ' AND q.IsActive = 1
      AND (SELECT COUNT(*) FROM Submissions s WHERE s.LessonId = q.LessonId AND s.QuestionType = 'MCQ') < 3
      AND NOT EXISTS (SELECT 1 FROM Submissions s2 WHERE s2.QuestionId = q.QuestionId)
) r
WHERE r.rk <= 3;

CREATE TABLE #K (k INT PRIMARY KEY);
INSERT INTO #K (k) VALUES (0), (1);

INSERT INTO Submissions (StudentId, LessonId, QuestionId, QuestionType, StudentAnswer, IsCorrect, FinalScore, [Status], IsReviewed, SubmittedAt)
SELECT st.UserId, p.LessonId, p.QuestionId, 'MCQ',
       CASE WHEN c.ok = 1 THEN p.Letter ELSE CHAR(65 + ((ASCII(p.Letter) - 65 + 1 + (p.QuestionId + k.k) % 3) % 4)) END,
       c.ok, CASE WHEN c.ok = 1 THEN 10 ELSE 0 END, 'GRADED', 1,
       DATEADD(MINUTE, 17 * 60 + (p.QuestionId * 37 + k.k * 53) % 330, DATEADD(DAY, -(1 + (p.QuestionId * 3 + k.k) % 14), @Today))
FROM #Pick p
CROSS JOIN #K k
JOIN #St st ON st.rn = ((p.QuestionId + k.k * 3) % @S) + 1
CROSS APPLY (SELECT CASE WHEN (CHECKSUM(p.QuestionId, k.k, 5) & 2147483647) % 100 < 65 THEN 1 ELSE 0 END AS ok) AS c;

COMMIT TRANSACTION;

DROP TABLE #E; DROP TABLE #St; DROP TABLE #Pick; DROP TABLE #K;

-- Kết quả
SELECT QuestionType, [Status], COUNT(*) AS SoBai FROM Submissions GROUP BY QuestionType, [Status] ORDER BY QuestionType, [Status];
SELECT l.LessonId, LEFT(l.Title, 50) AS BaiHoc,
       SUM(CASE WHEN s.QuestionType = 'MCQ' THEN 1 ELSE 0 END) AS TracNghiem,
       SUM(CASE WHEN s.QuestionType = 'ESSAY' THEN 1 ELSE 0 END) AS TuLuan
FROM Lessons l LEFT JOIN Submissions s ON s.LessonId = l.LessonId
WHERE l.IsActive = 1
GROUP BY l.LessonId, l.Title
ORDER BY l.LessonId;
GO
