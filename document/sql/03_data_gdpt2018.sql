-- =====================================================================================================================
-- File: document/sql/03_data_gdpt2018.sql — dữ liệu mẫu BỔ SUNG theo chương trình Toán 12 mới (GDPT 2018, sách Kết nối tri thức / Cánh diều)
-- Chạy SAU 01_schema.sql và 02_data.sql. KHÔNG xóa dữ liệu cũ, chỉ thêm; chạy lại lần 2 sẽ tự bỏ qua (không nhân đôi).
-- Chương trình Toán 12 (GDPT 2018) gồm 6 chương; file này bổ sung các chuyên đề còn thiếu ở 02_data.sql:
--   Chương 1  Ứng dụng đạo hàm để khảo sát và vẽ đồ thị hàm số      (thêm Bài 5: ứng dụng thực tế vào chủ đề có sẵn)
--   Chương 2  Vectơ và hệ trục tọa độ trong không gian               (chủ đề mới, 3 bài)
--   Chương 3  Các số đặc trưng đo mức độ phân tán của mẫu số liệu ghép nhóm (chủ đề mới, 2 bài)
--   Chương 4  Nguyên hàm và tích phân                                 (thêm Bài 3: ứng dụng hình học của tích phân)
--   Chương 5  Phương pháp tọa độ trong không gian                     (chủ đề mới, 4 bài)
--   Chương 6  Xác suất có điều kiện                                   (chủ đề mới, 2 bài)
-- Gồm: 4 chủ đề mới (+2 bài vào chủ đề cũ), 13 bài học, 26 bài giảng (liên kết YouTube + văn bản), 73 câu trắc nghiệm (đủ 3 mức độ), 5 tự luận,
--       ~150 bài làm trắc nghiệm, 4 bài tự luận (chờ duyệt / đã duyệt), 2 phiên gia sư.
-- Lưu ý: liên kết video là trang kết quả tìm kiếm YouTube (luôn mở được, URL chỉ dùng ký tự ASCII do cột Url là VARCHAR);
--        thay bằng video cụ thể (loại YOUTUBE, dạng https://www.youtube.com/embed/<id>) khi giáo viên đã chọn video.
-- Ngày giờ bài làm tính theo thời điểm chạy script (GETDATE()).
-- =====================================================================================================================
USE MathTutorDB;
GO

SET NOCOUNT ON;

IF EXISTS (SELECT 1 FROM Topics WHERE TopicName = N'Vectơ và hệ trục tọa độ trong không gian')
BEGIN
    PRINT N'03_data_gdpt2018.sql đã được chạy trước đó: bỏ qua.';
    RETURN;
END

DECLARE @t1 INT = (SELECT UserId FROM Users WHERE Username = 'teacher1');
DECLARE @t2 INT = (SELECT UserId FROM Users WHERE Username = 'teacher2');
DECLARE @t3 INT = (SELECT UserId FROM Users WHERE Username = 'teacher3');

-- =====================================================================================================================
-- 1. Topics
-- =====================================================================================================================
INSERT INTO Topics (TopicName, [Description], TeacherId, OrderIndex, IsActive) VALUES
(N'Vectơ và hệ trục tọa độ trong không gian', N'Chương 2 Toán 12 (GDPT 2018): vectơ, hệ trục Oxyz, biểu thức tọa độ của các phép toán vectơ', @t2, 8, 1),
(N'Mẫu số liệu ghép nhóm', N'Chương 3 Toán 12 (GDPT 2018): khoảng biến thiên, khoảng tứ phân vị, phương sai, độ lệch chuẩn', @t3, 9, 1),
(N'Phương pháp tọa độ trong không gian', N'Chương 5 Toán 12 (GDPT 2018): mặt phẳng, đường thẳng, góc, khoảng cách, mặt cầu trong Oxyz', @t1, 10, 1),
(N'Xác suất có điều kiện', N'Chương 6 Toán 12 (GDPT 2018): xác suất có điều kiện, công thức xác suất toàn phần, công thức Bayes', @t3, 11, 1);

DECLARE @tpA INT = (SELECT TOP 1 TopicId FROM Topics WHERE TopicName = N'Vectơ và hệ trục tọa độ trong không gian');
DECLARE @tpB INT = (SELECT TOP 1 TopicId FROM Topics WHERE TopicName = N'Mẫu số liệu ghép nhóm');
DECLARE @tpC INT = (SELECT TOP 1 TopicId FROM Topics WHERE TopicName = N'Phương pháp tọa độ trong không gian');
DECLARE @tpD INT = (SELECT TOP 1 TopicId FROM Topics WHERE TopicName = N'Xác suất có điều kiện');
DECLARE @tp1 INT = (SELECT TOP 1 TopicId FROM Topics WHERE TopicName = N'Khảo sát hàm số và ứng dụng');
DECLARE @tp4 INT = (SELECT TOP 1 TopicId FROM Topics WHERE TopicName = N'Nguyên hàm và Tích phân');

-- =====================================================================================================================
-- 2. Lessons: bảng tạm #L -> MERGE để lấy LessonId theo mã bài (Code)
-- =====================================================================================================================
CREATE TABLE #L (Code VARCHAR(5) PRIMARY KEY, TopicId INT NOT NULL, Title NVARCHAR(255) NOT NULL, Summary NVARCHAR(500) NULL,
                 Content NVARCHAR(MAX) NULL, Ord INT NOT NULL, TeacherId INT NOT NULL);

INSERT INTO #L (Code, TopicId, Title, Summary, Content, Ord, TeacherId) VALUES
('P5', @tp1, N'Bài 5: Ứng dụng đạo hàm giải bài toán thực tế', N'Mô hình hóa bài toán chuyển động, kinh tế, tối ưu hình học bằng đạo hàm.',
 N'<p>Các bước giải bài toán tối ưu thực tế:</p><ol><li>Chọn ẩn $x$ và đặt điều kiện cho $x$ từ ý nghĩa thực tế.</li><li>Lập hàm số $f(x)$ cần tìm GTLN hoặc GTNN.</li><li>Khảo sát $f(x)$ trên tập điều kiện bằng đạo hàm.</li><li>Kết luận theo yêu cầu của bài toán.</li></ol><p>Chuyển động: $v(t)=s^{\prime}(t)$, $a(t)=v^{\prime}(t)$.</p>', 5, @t1),
('A1', @tpA, N'Bài 1: Vectơ và các phép toán vectơ trong không gian', N'Khái niệm vectơ, quy tắc ba điểm, quy tắc hình bình hành, quy tắc hình hộp.',
 N'<p>Các phép toán vectơ trong không gian giống trong mặt phẳng:</p><ul><li><b>Quy tắc ba điểm:</b> $\overrightarrow{AB}+\overrightarrow{BC}=\overrightarrow{AC}$.</li><li><b>Quy tắc hình bình hành:</b> $ABCD$ là hình bình hành thì $\overrightarrow{AB}+\overrightarrow{AD}=\overrightarrow{AC}$.</li><li><b>Quy tắc hình hộp:</b> $ABCD.A^{\prime}B^{\prime}C^{\prime}D^{\prime}$ là hình hộp thì $\overrightarrow{AB}+\overrightarrow{AD}+\overrightarrow{AA^{\prime}}=\overrightarrow{AC^{\prime}}$.</li><li>$G$ là trọng tâm tam giác $ABC$ khi $\overrightarrow{GA}+\overrightarrow{GB}+\overrightarrow{GC}=\vec{0}$.</li></ul>', 1, @t2),
('A2', @tpA, N'Bài 2: Tọa độ của vectơ trong không gian', N'Hệ trục Oxyz, tọa độ điểm và tọa độ vectơ.',
 N'<p>Trong hệ trục $Oxyz$ với các vectơ đơn vị $\vec{i},\vec{j},\vec{k}$: $\vec{u}=x\vec{i}+y\vec{j}+z\vec{k}$ thì $\vec{u}=(x;y;z)$.</p><p>Với $A(x_A;y_A;z_A)$, $B(x_B;y_B;z_B)$: $\overrightarrow{AB}=(x_B-x_A;\,y_B-y_A;\,z_B-z_A)$. Trung điểm $M$ của $AB$ có tọa độ $\left(\dfrac{x_A+x_B}{2};\dfrac{y_A+y_B}{2};\dfrac{z_A+z_B}{2}\right)$.</p>', 2, @t2),
('A3', @tpA, N'Bài 3: Biểu thức tọa độ của các phép toán vectơ', N'Tổng, hiệu, tích vô hướng, độ dài, góc giữa hai vectơ.',
 N'<p>Cho $\vec{a}=(a_1;a_2;a_3)$, $\vec{b}=(b_1;b_2;b_3)$:</p><ul><li>$\vec{a}\cdot\vec{b}=a_1b_1+a_2b_2+a_3b_3$.</li><li>$|\vec{a}|=\sqrt{a_1^2+a_2^2+a_3^2}$.</li><li>$\cos(\vec{a},\vec{b})=\dfrac{\vec{a}\cdot\vec{b}}{|\vec{a}|\cdot|\vec{b}|}$ ($\vec{a},\vec{b}\ne\vec{0}$).</li><li>$\vec{a}\perp\vec{b}\Leftrightarrow\vec{a}\cdot\vec{b}=0$.</li></ul>', 3, @t2),
('B1', @tpB, N'Bài 1: Khoảng biến thiên và khoảng tứ phân vị', N'Hai số đo độ phân tán của mẫu số liệu ghép nhóm.',
 N'<p><b>Khoảng biến thiên</b> $R$ = đầu mút phải của nhóm cuối cùng $-$ đầu mút trái của nhóm đầu tiên.</p><p><b>Khoảng tứ phân vị</b> $\Delta_Q=Q_3-Q_1$. Với $n$ là cỡ mẫu, nhóm chứa $Q_k$ là $[u_m;u_{m+1})$: $Q_k=u_m+\dfrac{\frac{kn}{4}-C}{n_m}(u_{m+1}-u_m)$, trong đó $C$ là tần số tích lũy của các nhóm đứng trước, $n_m$ là tần số của nhóm đó.</p>', 1, @t3),
('B2', @tpB, N'Bài 2: Phương sai và độ lệch chuẩn', N'Tính phương sai, độ lệch chuẩn từ bảng tần số ghép nhóm.',
 N'<p>Dùng giá trị đại diện $x_i$ của mỗi nhóm (trung điểm), tần số $n_i$, cỡ mẫu $n$:</p><p>Số trung bình $\bar{x}=\dfrac{\sum n_ix_i}{n}$; phương sai $s^2=\dfrac{\sum n_ix_i^2}{n}-\bar{x}^2$; độ lệch chuẩn $s=\sqrt{s^2}$.</p><p>Độ lệch chuẩn càng nhỏ thì số liệu càng tập trung quanh giá trị trung bình.</p>', 2, @t3),
('C1', @tpC, N'Bài 1: Phương trình mặt phẳng', N'Vectơ pháp tuyến, phương trình tổng quát, khoảng cách từ điểm đến mặt phẳng.',
 N'<p>Mặt phẳng đi qua $M(x_0;y_0;z_0)$ có vectơ pháp tuyến $\vec{n}=(A;B;C)$: $A(x-x_0)+B(y-y_0)+C(z-z_0)=0$, hay $Ax+By+Cz+D=0$.</p><p>Khoảng cách từ $M(x_0;y_0;z_0)$ đến $(P)$: $d=\dfrac{|Ax_0+By_0+Cz_0+D|}{\sqrt{A^2+B^2+C^2}}$.</p><p>Mặt phẳng đi qua $A(a;0;0)$, $B(0;b;0)$, $C(0;0;c)$: $\dfrac{x}{a}+\dfrac{y}{b}+\dfrac{z}{c}=1$.</p>', 1, @t1),
('C2', @tpC, N'Bài 2: Phương trình đường thẳng trong không gian', N'Phương trình tham số, chính tắc, vectơ chỉ phương.',
 N'<p>Đường thẳng đi qua $M(x_0;y_0;z_0)$, vectơ chỉ phương $\vec{u}=(a;b;c)$:</p><p>Tham số: $x=x_0+at,\ y=y_0+bt,\ z=z_0+ct$. Chính tắc: $\dfrac{x-x_0}{a}=\dfrac{y-y_0}{b}=\dfrac{z-z_0}{c}$ ($abc\ne0$).</p>', 2, @t1),
('C3', @tpC, N'Bài 3: Công thức tính góc trong không gian', N'Góc giữa hai đường thẳng, đường thẳng và mặt phẳng, hai mặt phẳng.',
 N'<p>$\cos(d_1,d_2)=\dfrac{|\vec{u}_1\cdot\vec{u}_2|}{|\vec{u}_1||\vec{u}_2|}$; $\sin(d,(P))=\dfrac{|\vec{u}\cdot\vec{n}|}{|\vec{u}||\vec{n}|}$; $\cos((P),(Q))=\dfrac{|\vec{n}_1\cdot\vec{n}_2|}{|\vec{n}_1||\vec{n}_2|}$.</p>', 3, @t1),
('C4', @tpC, N'Bài 4: Phương trình mặt cầu', N'Phương trình chính tắc và tổng quát của mặt cầu.',
 N'<p>Mặt cầu tâm $I(a;b;c)$, bán kính $R$: $(x-a)^2+(y-b)^2+(z-c)^2=R^2$.</p><p>Phương trình $x^2+y^2+z^2-2ax-2by-2cz+d=0$ là mặt cầu khi $a^2+b^2+c^2-d>0$, khi đó $R=\sqrt{a^2+b^2+c^2-d}$.</p>', 4, @t1),
('D1', @tpD, N'Bài 1: Xác suất có điều kiện', N'Định nghĩa và cách tính xác suất của A khi biết B đã xảy ra.',
 N'<p>Cho hai biến cố $A$, $B$ với $P(B)>0$: $P(A|B)=\dfrac{P(AB)}{P(B)}$.</p><p>Quy tắc nhân: $P(AB)=P(B)\cdot P(A|B)$. Ngoài ra $P(A|B)+P(\overline{A}|B)=1$.</p>', 1, @t3),
('D2', @tpD, N'Bài 2: Công thức xác suất toàn phần và công thức Bayes', N'Tính xác suất khi có nhiều nguyên nhân (nhóm đầy đủ).',
 N'<p><b>Xác suất toàn phần:</b> $P(A)=P(B)P(A|B)+P(\overline{B})P(A|\overline{B})$.</p><p><b>Công thức Bayes:</b> $P(B|A)=\dfrac{P(B)P(A|B)}{P(A)}=\dfrac{P(B)P(A|B)}{P(B)P(A|B)+P(\overline{B})P(A|\overline{B})}$.</p>', 2, @t3),
('I3', @tp4, N'Bài 3: Ứng dụng hình học của tích phân', N'Tính diện tích hình phẳng và thể tích khối tròn xoay.',
 N'<p>Diện tích hình phẳng giới hạn bởi $y=f(x)$, $y=g(x)$, $x=a$, $x=b$: $S=\int_a^b|f(x)-g(x)|\,dx$.</p><p>Thể tích khối tròn xoay khi quay hình phẳng giới hạn bởi $y=f(x)$, $Ox$, $x=a$, $x=b$ quanh $Ox$: $V=\pi\int_a^b f^2(x)\,dx$.</p>', 3, @t1);

CREATE TABLE #LM (Code VARCHAR(5) PRIMARY KEY, LessonId INT NOT NULL, TeacherId INT NOT NULL);

MERGE Lessons AS tgt
USING (SELECT Code, TopicId, Title, Summary, Content, Ord, TeacherId FROM #L) AS src
ON 1 = 0
WHEN NOT MATCHED THEN
    INSERT (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy)
    VALUES (src.TopicId, src.Title, src.Summary, src.Content, src.Ord, 1, src.TeacherId)
OUTPUT src.Code, inserted.LessonId, src.TeacherId INTO #LM (Code, LessonId, TeacherId);

-- =====================================================================================================================
-- 3. LessonMaterials: mỗi bài 1 liên kết YouTube (trang tìm kiếm) + 1 tóm tắt văn bản
-- =====================================================================================================================
INSERT INTO LessonMaterials (LessonId, MaterialType, Title, Url, ContentText, OrderIndex, CreatedBy)
SELECT m.LessonId, v.MType, v.Title, v.Url, v.Txt, v.Ord, m.TeacherId
FROM (VALUES
('P5', 'LINK', N'YouTube: Ứng dụng đạo hàm giải bài toán thực tế', 'https://www.youtube.com/results?search_query=toan+12+ung+dung+dao+ham+bai+toan+thuc+te+toi+uu', NULL, 1),
('P5', 'TEXT', N'Tóm tắt phương pháp', NULL, N'B1: đặt ẩn và điều kiện. B2: lập hàm số cần tối ưu. B3: khảo sát hàm bằng đạo hàm. B4: kết luận. Chuyển động: v(t) = s''(t); a(t) = v''(t).', 2),
('A1', 'LINK', N'YouTube: Vectơ trong không gian', 'https://www.youtube.com/results?search_query=toan+12+vecto+trong+khong+gian+ket+noi+tri+thuc', NULL, 1),
('A1', 'TEXT', N'Các quy tắc cần nhớ', NULL, N'Quy tắc ba điểm: AB + BC = AC. Quy tắc hình bình hành: AB + AD = AC. Quy tắc hình hộp: AB + AD + AA'' = AC''. Trọng tâm G của tam giác ABC: GA + GB + GC = 0.', 2),
('A2', 'LINK', N'YouTube: Toạ độ của vectơ trong không gian', 'https://www.youtube.com/results?search_query=toan+12+toa+do+cua+vecto+trong+khong+gian+oxyz', NULL, 1),
('A2', 'TEXT', N'Công thức tọa độ', NULL, N'AB = (xB - xA; yB - yA; zB - zA). Trung điểm M của AB: M = ((xA + xB)/2; (yA + yB)/2; (zA + zB)/2). Trọng tâm tam giác: lấy trung bình cộng 3 tọa độ.', 2),
('A3', 'LINK', N'YouTube: Biểu thức toạ độ của các phép toán vectơ', 'https://www.youtube.com/results?search_query=toan+12+bieu+thuc+toa+do+cua+cac+phep+toan+vecto', NULL, 1),
('A3', 'TEXT', N'Công thức tọa độ', NULL, N'a.b = a1b1 + a2b2 + a3b3; |a| = căn(a1^2 + a2^2 + a3^2); cos(a,b) = a.b / (|a||b|); a vuông góc b khi a.b = 0.', 2),
('B1', 'LINK', N'YouTube: Khoảng biến thiên và khoảng tứ phân vị', 'https://www.youtube.com/results?search_query=toan+12+khoang+bien+thien+khoang+tu+phan+vi+mau+so+lieu+ghep+nhom', NULL, 1),
('B1', 'TEXT', N'Các bước tìm tứ phân vị', NULL, N'B1: lập bảng tần số tích lũy. B2: xác định nhóm chứa Qk (kn/4). B3: Qk = um + ((kn/4 - C)/nm) x (um+1 - um). Khoảng tứ phân vị = Q3 - Q1.', 2),
('B2', 'LINK', N'YouTube: Phương sai và độ lệch chuẩn', 'https://www.youtube.com/results?search_query=toan+12+phuong+sai+do+lech+chuan+mau+so+lieu+ghep+nhom', NULL, 1),
('B2', 'TEXT', N'Công thức', NULL, N'Trung bình x = (Σ ni xi)/n; phương sai s^2 = (Σ ni xi^2)/n - x^2; độ lệch chuẩn s = căn(s^2). Với xi là giá trị đại diện (trung điểm) của nhóm.', 2),
('C1', 'LINK', N'YouTube: Phương trình mặt phẳng', 'https://www.youtube.com/results?search_query=toan+12+phuong+trinh+mat+phang+oxyz+ket+noi+tri+thuc', NULL, 1),
('C1', 'TEXT', N'Ghi nhớ', NULL, N'Mặt phẳng Ax + By + Cz + D = 0 có vectơ pháp tuyến n = (A; B; C). d(M,(P)) = |Ax0 + By0 + Cz0 + D| / căn(A^2 + B^2 + C^2).', 2),
('C2', 'LINK', N'YouTube: Phương trình đường thẳng trong không gian', 'https://www.youtube.com/results?search_query=toan+12+phuong+trinh+duong+thang+trong+khong+gian+oxyz', NULL, 1),
('C2', 'TEXT', N'Ghi nhớ', NULL, N'Đường thẳng qua M(x0; y0; z0) với vectơ chỉ phương u = (a; b; c): x = x0 + at, y = y0 + bt, z = z0 + ct.', 2),
('C3', 'LINK', N'YouTube: Công thức tính góc trong không gian', 'https://www.youtube.com/results?search_query=toan+12+cong+thuc+tinh+goc+trong+khong+gian+oxyz', NULL, 1),
('C3', 'TEXT', N'Công thức góc', NULL, N'cos(d1,d2) = |u1.u2|/(|u1||u2|); sin(d,(P)) = |u.n|/(|u||n|); cos((P),(Q)) = |n1.n2|/(|n1||n2|).', 2),
('C4', 'LINK', N'YouTube: Phương trình mặt cầu', 'https://www.youtube.com/results?search_query=toan+12+phuong+trinh+mat+cau+oxyz', NULL, 1),
('C4', 'TEXT', N'Ghi nhớ', NULL, N'Mặt cầu tâm I(a; b; c), bán kính R: (x-a)^2 + (y-b)^2 + (z-c)^2 = R^2. Dạng khai triển là mặt cầu khi a^2 + b^2 + c^2 - d > 0.', 2),
('D1', 'LINK', N'YouTube: Xác suất có điều kiện', 'https://www.youtube.com/results?search_query=toan+12+xac+suat+co+dieu+kien+ket+noi+tri+thuc', NULL, 1),
('D1', 'TEXT', N'Công thức', NULL, N'P(A|B) = P(AB)/P(B) với P(B) > 0. Quy tắc nhân: P(AB) = P(B).P(A|B).', 2),
('D2', 'LINK', N'YouTube: Công thức xác suất toàn phần và Bayes', 'https://www.youtube.com/results?search_query=toan+12+cong+thuc+xac+suat+toan+phan+va+cong+thuc+bayes', NULL, 1),
('D2', 'TEXT', N'Công thức', NULL, N'P(A) = P(B)P(A|B) + P(B-)P(A|B-). Bayes: P(B|A) = P(B)P(A|B)/P(A).', 2),
('I3', 'LINK', N'YouTube: Ứng dụng hình học của tích phân', 'https://www.youtube.com/results?search_query=toan+12+ung+dung+hinh+hoc+cua+tich+phan+dien+tich+the+tich', NULL, 1),
('I3', 'TEXT', N'Công thức', NULL, N'S = ∫|f(x) - g(x)| dx từ a đến b. V = π ∫ f(x)^2 dx từ a đến b (quay quanh trục Ox).', 2)
) AS v (Code, MType, Title, Url, Txt, Ord)
JOIN #LM m ON m.Code = v.Code;

-- =====================================================================================================================
-- 4. Questions: bảng tạm #Q -> MERGE lấy QuestionId -> sinh QuestionOptions
--    Level: 1 Dễ, 2 Trung bình, 3 Khó. AI = 1: câu do AI sinh (hiện nhãn AI). Seq 201-205: tự luận
-- =====================================================================================================================
CREATE TABLE #Q (
    Seq INT PRIMARY KEY, QType VARCHAR(10) NOT NULL, LCode VARCHAR(5) NOT NULL, Lvl INT NOT NULL, AI BIT NOT NULL,
    Content NVARCHAR(MAX) NOT NULL, A NVARCHAR(MAX) NULL, B NVARCHAR(MAX) NULL, C NVARCHAR(MAX) NULL, D NVARCHAR(MAX) NULL,
    Correct CHAR(1) NULL, Expl NVARCHAR(MAX) NULL);

INSERT INTO #Q (Seq, QType, LCode, Lvl, AI, Content, A, B, C, D, Correct, Expl) VALUES
-- ---- Bài 5 (chương 1): ứng dụng đạo hàm thực tế ----
(1, 'MCQ', 'P5', 1, 0, N'Một chất điểm chuyển động theo quy luật $s(t)=t^3-6t^2+9t$ ($t$ tính bằng giây, $s$ tính bằng mét). Vận tốc của chất điểm tại thời điểm $t=2$ là:',
 N'$-3$ m/s', N'$3$ m/s', N'$0$ m/s', N'$2$ m/s', 'A',
 N'<p>$v(t)=s^{\prime}(t)=3t^2-12t+9$. Do đó $v(2)=12-24+9=-3$ m/s.</p>'),
(2, 'MCQ', 'P5', 2, 0, N'Một chất điểm có vận tốc $v(t)=t^3-3t$ (m/s). Gia tốc của chất điểm tại thời điểm $t=2$ là:',
 N'$6$ m/s$^2$', N'$9$ m/s$^2$', N'$2$ m/s$^2$', N'$12$ m/s$^2$', 'B',
 N'<p>$a(t)=v^{\prime}(t)=3t^2-3$, nên $a(2)=12-3=9$ m/s$^2$.</p>'),
(3, 'MCQ', 'P5', 1, 1, N'Lợi nhuận khi bán $x$ sản phẩm là $P(x)=-x^2+20x-50$ (triệu đồng). Lợi nhuận lớn nhất bằng:',
 N'$100$ triệu', N'$50$ triệu', N'$20$ triệu', N'$10$ triệu', 'B',
 N'<p>Đỉnh parabol tại $x=10$, $P(10)=-100+200-50=50$.</p>'),
(4, 'MCQ', 'P5', 2, 0, N'Một mảnh vườn hình chữ nhật có chu vi $40$ m. Diện tích lớn nhất của mảnh vườn là:',
 N'$80$ m$^2$', N'$90$ m$^2$', N'$100$ m$^2$', N'$110$ m$^2$', 'C',
 N'<p>Gọi một cạnh là $x$ thì cạnh kia là $20-x$, $S=x(20-x)=-x^2+20x\le 100$, đạt tại $x=10$ (hình vuông).</p>'),
-- ---- Chương 2, Bài 1: vectơ trong không gian ----
(5, 'MCQ', 'A1', 1, 0, N'Cho hình hộp $ABCD.A^{\prime}B^{\prime}C^{\prime}D^{\prime}$. Vectơ $\overrightarrow{AB}+\overrightarrow{AD}+\overrightarrow{AA^{\prime}}$ bằng:',
 N'$\overrightarrow{AC^{\prime}}$', N'$\overrightarrow{AC}$', N'$\overrightarrow{A^{\prime}C}$', N'$\overrightarrow{BD^{\prime}}$', 'A',
 N'<p>Theo quy tắc hình hộp, $\overrightarrow{AB}+\overrightarrow{AD}+\overrightarrow{AA^{\prime}}=\overrightarrow{AC^{\prime}}$.</p>'),
(6, 'MCQ', 'A1', 1, 0, N'Cho tứ diện $ABCD$, gọi $G$ là trọng tâm tam giác $BCD$. Khi đó $\overrightarrow{GB}+\overrightarrow{GC}+\overrightarrow{GD}$ bằng:',
 N'$\vec{0}$', N'$\overrightarrow{AG}$', N'$\overrightarrow{GA}$', N'$3\overrightarrow{AG}$', 'A',
 N'<p>$G$ là trọng tâm tam giác $BCD$ nên $\overrightarrow{GB}+\overrightarrow{GC}+\overrightarrow{GD}=\vec{0}$.</p>'),
(7, 'MCQ', 'A1', 2, 0, N'Cho tứ diện $ABCD$. Gọi $M$, $N$ lần lượt là trung điểm của $AB$ và $CD$. Vectơ $\overrightarrow{MN}$ bằng:',
 N'$\dfrac{1}{2}\left(\overrightarrow{AC}+\overrightarrow{BD}\right)$', N'$\overrightarrow{AC}+\overrightarrow{BD}$', N'$\dfrac{1}{2}\left(\overrightarrow{AC}-\overrightarrow{BD}\right)$', N'$\dfrac{1}{2}\left(\overrightarrow{AB}+\overrightarrow{CD}\right)$', 'A',
 N'<p>$\overrightarrow{MN}=\overrightarrow{MA}+\overrightarrow{AC}+\overrightarrow{CN}$ và $\overrightarrow{MN}=\overrightarrow{MB}+\overrightarrow{BD}+\overrightarrow{DN}$. Cộng hai đẳng thức, chú ý $\overrightarrow{MA}+\overrightarrow{MB}=\vec{0}$, $\overrightarrow{CN}+\overrightarrow{DN}=\vec{0}$, ta được $2\overrightarrow{MN}=\overrightarrow{AC}+\overrightarrow{BD}$.</p>'),
(8, 'MCQ', 'A1', 2, 0, N'Cho hình lập phương $ABCD.A^{\prime}B^{\prime}C^{\prime}D^{\prime}$. Góc giữa hai vectơ $\overrightarrow{AB}$ và $\overrightarrow{A^{\prime}C^{\prime}}$ bằng:',
 N'$30^\circ$', N'$45^\circ$', N'$60^\circ$', N'$90^\circ$', 'B',
 N'<p>$\overrightarrow{A^{\prime}C^{\prime}}=\overrightarrow{AC}$ nên góc cần tìm là góc $\widehat{BAC}=45^\circ$ (đường chéo hình vuông).</p>'),
(9, 'MCQ', 'A1', 3, 0, N'Cho hình lập phương $ABCD.A^{\prime}B^{\prime}C^{\prime}D^{\prime}$ có cạnh $a$. Tích vô hướng $\overrightarrow{AB}\cdot\overrightarrow{AC^{\prime}}$ bằng:',
 N'$a^2$', N'$a^2\sqrt{2}$', N'$a^2\sqrt{3}$', N'$0$', 'A',
 N'<p>$\overrightarrow{AC^{\prime}}=\overrightarrow{AB}+\overrightarrow{AD}+\overrightarrow{AA^{\prime}}$. Do $AB\perp AD$, $AB\perp AA^{\prime}$ nên $\overrightarrow{AB}\cdot\overrightarrow{AC^{\prime}}=AB^2=a^2$.</p>'),
-- ---- Chương 2, Bài 2: tọa độ của vectơ ----
(10, 'MCQ', 'A2', 1, 0, N'Trong không gian $Oxyz$, vectơ $\vec{u}=2\vec{i}-\vec{j}+3\vec{k}$ có tọa độ là:',
 N'$(2;-1;3)$', N'$(2;1;3)$', N'$(-2;1;3)$', N'$(3;-1;2)$', 'A',
 N'<p>$\vec{u}=x\vec{i}+y\vec{j}+z\vec{k}$ thì $\vec{u}=(x;y;z)$, nên $\vec{u}=(2;-1;3)$.</p>'),
(11, 'MCQ', 'A2', 1, 0, N'Trong không gian $Oxyz$, cho $A(1;2;3)$ và $B(3;0;-1)$. Tọa độ vectơ $\overrightarrow{AB}$ là:',
 N'$(2;-2;-4)$', N'$(4;2;2)$', N'$(-2;2;4)$', N'$(2;2;4)$', 'A',
 N'<p>$\overrightarrow{AB}=(3-1;\,0-2;\,-1-3)=(2;-2;-4)$.</p>'),
(12, 'MCQ', 'A2', 1, 1, N'Trong không gian $Oxyz$, cho $A(1;2;3)$ và $B(3;0;-1)$. Trung điểm $M$ của đoạn $AB$ có tọa độ là:',
 N'$(2;1;1)$', N'$(4;2;2)$', N'$(1;-1;-2)$', N'$(2;1;-1)$', 'A',
 N'<p>$M\left(\dfrac{1+3}{2};\dfrac{2+0}{2};\dfrac{3-1}{2}\right)=(2;1;1)$.</p>'),
(13, 'MCQ', 'A2', 2, 0, N'Trong không gian $Oxyz$, cho $A(1;0;0)$, $B(0;2;0)$, $C(0;0;3)$. Trọng tâm tam giác $ABC$ có tọa độ là:',
 N'$\left(\dfrac{1}{3};\dfrac{2}{3};1\right)$', N'$(1;2;3)$', N'$\left(\dfrac{1}{2};1;\dfrac{3}{2}\right)$', N'$(3;6;9)$', 'A',
 N'<p>Trọng tâm có tọa độ là trung bình cộng: $\left(\dfrac{1+0+0}{3};\dfrac{0+2+0}{3};\dfrac{0+0+3}{3}\right)$.</p>'),
(14, 'MCQ', 'A2', 3, 0, N'Trong không gian $Oxyz$, cho $A(1;2;1)$, $B(2;1;0)$, $C(0;1;2)$. Điểm $D$ để $ABCD$ là hình bình hành có tọa độ là:',
 N'$(-1;2;3)$', N'$(3;2;-1)$', N'$(1;0;1)$', N'$(-1;0;3)$', 'A',
 N'<p>$ABCD$ là hình bình hành khi $\overrightarrow{AB}=\overrightarrow{DC}$, hay $D=A+C-B=(1+0-2;\,2+1-1;\,1+2-0)=(-1;2;3)$.</p>'),
-- ---- Chương 2, Bài 3: biểu thức tọa độ ----
(15, 'MCQ', 'A3', 1, 0, N'Trong không gian $Oxyz$, cho $\vec{a}=(1;2;3)$ và $\vec{b}=(2;1;-1)$. Tọa độ của $\vec{a}+\vec{b}$ là:',
 N'$(3;3;2)$', N'$(-1;1;4)$', N'$(3;1;2)$', N'$(1;3;2)$', 'A',
 N'<p>$\vec{a}+\vec{b}=(1+2;\,2+1;\,3-1)=(3;3;2)$.</p>'),
(16, 'MCQ', 'A3', 1, 0, N'Trong không gian $Oxyz$, cho $\vec{a}=(1;2;3)$ và $\vec{b}=(2;1;-1)$. Tích vô hướng $\vec{a}\cdot\vec{b}$ bằng:',
 N'$1$', N'$3$', N'$-1$', N'$7$', 'A',
 N'<p>$\vec{a}\cdot\vec{b}=1\cdot2+2\cdot1+3\cdot(-1)=1$.</p>'),
(17, 'MCQ', 'A3', 1, 0, N'Trong không gian $Oxyz$, độ dài của vectơ $\vec{a}=(2;-2;1)$ bằng:',
 N'$3$', N'$9$', N'$\sqrt{5}$', N'$1$', 'A',
 N'<p>$|\vec{a}|=\sqrt{4+4+1}=3$.</p>'),
(18, 'MCQ', 'A3', 2, 0, N'Trong không gian $Oxyz$, góc giữa hai vectơ $\vec{a}=(1;1;0)$ và $\vec{b}=(0;1;1)$ bằng:',
 N'$30^\circ$', N'$45^\circ$', N'$60^\circ$', N'$90^\circ$', 'C',
 N'<p>$\cos(\vec{a},\vec{b})=\dfrac{0+1+0}{\sqrt{2}\cdot\sqrt{2}}=\dfrac{1}{2}$ nên góc bằng $60^\circ$.</p>'),
(19, 'MCQ', 'A3', 3, 0, N'Trong không gian $Oxyz$, cho $\vec{a}=(1;m;2)$ và $\vec{b}=(2;m;-3)$. Tìm $m$ để $\vec{a}\perp\vec{b}$.',
 N'$m=2$', N'$m=-2$', N'$m=\pm2$', N'$m=\pm4$', 'C',
 N'<p>$\vec{a}\cdot\vec{b}=2+m^2-6=m^2-4=0\Leftrightarrow m=\pm2$.</p>'),
-- ---- Chương 3, Bài 1: khoảng biến thiên, khoảng tứ phân vị ----
(20, 'MCQ', 'B1', 1, 0, N'Mẫu số liệu ghép nhóm có nhóm đầu tiên là $[10;20)$ và nhóm cuối cùng là $[50;60)$. Khoảng biến thiên của mẫu số liệu là:',
 N'$40$', N'$50$', N'$60$', N'$10$', 'B',
 N'<p>Khoảng biến thiên $R=60-10=50$.</p>'),
(21, 'MCQ', 'B1', 1, 0, N'Một mẫu số liệu ghép nhóm có $Q_1=12$ và $Q_3=20$. Khoảng tứ phân vị của mẫu là:',
 N'$8$', N'$16$', N'$32$', N'$4$', 'A',
 N'<p>$\Delta_Q=Q_3-Q_1=20-12=8$.</p>'),
(22, 'MCQ', 'B1', 2, 0, N'Cho bảng tần số ghép nhóm: $[0;10)$: 4; $[10;20)$: 8; $[20;30)$: 6; $[30;40)$: 2. Tứ phân vị thứ nhất $Q_1$ của mẫu là:',
 N'$11{,}25$', N'$12{,}5$', N'$10$', N'$15$', 'A',
 N'<p>$n=20$, $\dfrac{n}{4}=5$. Tần số tích lũy: 4; 12; 18; 20. Nhóm chứa $Q_1$ là $[10;20)$: $Q_1=10+\dfrac{5-4}{8}\cdot10=11{,}25$.</p>'),
(23, 'MCQ', 'B1', 2, 0, N'Cho bảng tần số ghép nhóm: $[0;10)$: 4; $[10;20)$: 8; $[20;30)$: 6; $[30;40)$: 2. Tứ phân vị thứ ba $Q_3$ của mẫu là:',
 N'$22{,}5$', N'$25$', N'$20$', N'$27{,}5$', 'B',
 N'<p>$n=20$, $\dfrac{3n}{4}=15$. Tần số tích lũy: 4; 12; 18; 20. Nhóm chứa $Q_3$ là $[20;30)$: $Q_3=20+\dfrac{15-12}{6}\cdot10=25$.</p>'),
(24, 'MCQ', 'B1', 3, 0, N'Cho bảng tần số ghép nhóm: $[0;10)$: 4; $[10;20)$: 8; $[20;30)$: 6; $[30;40)$: 2. Khoảng tứ phân vị của mẫu là:',
 N'$13{,}75$', N'$15$', N'$12{,}5$', N'$25$', 'A',
 N'<p>$Q_1=11{,}25$, $Q_3=25$ nên $\Delta_Q=25-11{,}25=13{,}75$.</p>'),
(25, 'MCQ', 'B1', 2, 1, N'Khi mẫu số liệu có giá trị ngoại lệ (rất lớn hoặc rất nhỏ), đại lượng nào ít bị ảnh hưởng nhất?',
 N'Khoảng biến thiên', N'Khoảng tứ phân vị', N'Cả hai bị ảnh hưởng như nhau', N'Không đại lượng nào', 'B',
 N'<p>Khoảng tứ phân vị chỉ dựa trên $Q_1$, $Q_3$ (nửa giữa của mẫu) nên ít bị ảnh hưởng bởi giá trị ngoại lệ, còn khoảng biến thiên phụ thuộc vào hai đầu mút.</p>'),
-- ---- Chương 3, Bài 2: phương sai, độ lệch chuẩn ----
(26, 'MCQ', 'B2', 1, 0, N'Mẫu số liệu ghép nhóm: $[0;10)$: 4; $[10;20)$: 6; $[20;30)$: 10. Số trung bình của mẫu là:',
 N'$18$', N'$15$', N'$20$', N'$25$', 'A',
 N'<p>Giá trị đại diện: 5; 15; 25. $\bar{x}=\dfrac{4\cdot5+6\cdot15+10\cdot25}{20}=\dfrac{360}{20}=18$.</p>'),
(27, 'MCQ', 'B2', 2, 0, N'Mẫu số liệu ghép nhóm: $[0;10)$: 4; $[10;20)$: 6; $[20;30)$: 10. Phương sai của mẫu là:',
 N'$61$', N'$18$', N'$385$', N'$7{,}81$', 'A',
 N'<p>$\dfrac{\sum n_ix_i^2}{n}=\dfrac{4\cdot25+6\cdot225+10\cdot625}{20}=385$. Phương sai $s^2=385-18^2=61$.</p>'),
(28, 'MCQ', 'B2', 2, 0, N'Mẫu số liệu ghép nhóm: $[0;10)$: 4; $[10;20)$: 6; $[20;30)$: 10 có phương sai $s^2=61$. Độ lệch chuẩn (làm tròn đến hàng phần trăm) là:',
 N'$7{,}81$', N'$61$', N'$8{,}50$', N'$3{,}90$', 'A',
 N'<p>$s=\sqrt{61}\approx7{,}81$.</p>'),
(29, 'MCQ', 'B2', 1, 0, N'Độ lệch chuẩn của mẫu số liệu là:',
 N'Bình phương của phương sai', N'Căn bậc hai của phương sai', N'Hiệu của giá trị lớn nhất và nhỏ nhất', N'Số trung bình của các độ lệch', 'B',
 N'<p>Độ lệch chuẩn $s=\sqrt{s^2}$, với $s^2$ là phương sai.</p>'),
(30, 'MCQ', 'B2', 1, 0, N'Hai mẫu số liệu có cùng đơn vị đo. Mẫu có độ lệch chuẩn nhỏ hơn thì các giá trị của mẫu đó:',
 N'Phân tán hơn', N'Đồng đều (tập trung quanh giá trị trung bình) hơn', N'Luôn có giá trị trung bình nhỏ hơn', N'Luôn có nhiều giá trị hơn', 'B',
 N'<p>Độ lệch chuẩn đo mức độ phân tán: càng nhỏ thì số liệu càng tập trung quanh giá trị trung bình.</p>'),
(31, 'MCQ', 'B2', 3, 0, N'Mẫu số liệu ghép nhóm: $[0;20)$: 5; $[20;40)$: 10; $[40;60)$: 5. Phương sai của mẫu là:',
 N'$200$', N'$100$', N'$300$', N'$400$', 'A',
 N'<p>Giá trị đại diện 10; 30; 50. $\bar{x}=30$. $\dfrac{\sum n_ix_i^2}{n}=\dfrac{5\cdot100+10\cdot900+5\cdot2500}{20}=1100$. $s^2=1100-900=200$.</p>'),
-- ---- Chương 5, Bài 1: mặt phẳng ----
(32, 'MCQ', 'C1', 1, 0, N'Trong không gian $Oxyz$, mặt phẳng $(P): 2x-y+3z-5=0$ có một vectơ pháp tuyến là:',
 N'$(2;-1;3)$', N'$(2;1;3)$', N'$(2;-1;-5)$', N'$(-5;2;-1)$', 'A',
 N'<p>Mặt phẳng $Ax+By+Cz+D=0$ có vectơ pháp tuyến $(A;B;C)=(2;-1;3)$.</p>'),
(33, 'MCQ', 'C1', 1, 0, N'Trong không gian $Oxyz$, mặt phẳng đi qua $M(1;2;3)$ và có vectơ pháp tuyến $\vec{n}=(1;-1;2)$ có phương trình là:',
 N'$x-y+2z-5=0$', N'$x-y+2z+5=0$', N'$x+y+2z-9=0$', N'$x-y+2z-3=0$', 'A',
 N'<p>$(x-1)-(y-2)+2(z-3)=0\Leftrightarrow x-y+2z-5=0$.</p>'),
(34, 'MCQ', 'C1', 2, 0, N'Trong không gian $Oxyz$, mặt phẳng đi qua $A(1;0;0)$, $B(0;2;0)$, $C(0;0;3)$ có phương trình là:',
 N'$6x+3y+2z-6=0$', N'$x+2y+3z-1=0$', N'$6x+3y+2z+6=0$', N'$3x+2y+z-6=0$', 'A',
 N'<p>Phương trình đoạn chắn: $\dfrac{x}{1}+\dfrac{y}{2}+\dfrac{z}{3}=1\Leftrightarrow6x+3y+2z-6=0$.</p>'),
(35, 'MCQ', 'C1', 2, 0, N'Trong không gian $Oxyz$, khoảng cách từ điểm $M(1;2;3)$ đến mặt phẳng $(P): 2x-y+2z-3=0$ bằng:',
 N'$1$', N'$2$', N'$3$', N'$\dfrac{1}{3}$', 'A',
 N'<p>$d=\dfrac{|2-2+6-3|}{\sqrt{4+1+4}}=\dfrac{3}{3}=1$.</p>'),
(36, 'MCQ', 'C1', 3, 0, N'Trong không gian $Oxyz$, cho $(P): x+2y-z+1=0$ và $(Q): 2x+4y-2z+m=0$. Hai mặt phẳng song song khi và chỉ khi:',
 N'$m=2$', N'$m\ne2$', N'$m=1$', N'$m\in\mathbb{R}$', 'B',
 N'<p>Hai vectơ pháp tuyến cùng phương. $(Q)\Leftrightarrow x+2y-z+\dfrac{m}{2}=0$. Song song (không trùng) khi $\dfrac{m}{2}\ne1\Leftrightarrow m\ne2$.</p>'),
(37, 'MCQ', 'C1', 3, 1, N'Trong không gian $Oxyz$, cho $A(1;2;3)$, $B(3;0;-1)$. Mặt phẳng trung trực của đoạn $AB$ có phương trình là:',
 N'$x-y-2z+1=0$', N'$x-y-2z-1=0$', N'$x+y+2z-5=0$', N'$x-y+2z+1=0$', 'A',
 N'<p>Mặt phẳng đi qua trung điểm $M(2;1;1)$ và nhận $\overrightarrow{AB}=(2;-2;-4)$, hay $(1;-1;-2)$, làm vectơ pháp tuyến: $(x-2)-(y-1)-2(z-1)=0\Leftrightarrow x-y-2z+1=0$.</p>'),
-- ---- Chương 5, Bài 2: đường thẳng ----
(38, 'MCQ', 'C2', 1, 0, N'Trong không gian $Oxyz$, đường thẳng $d:\ x=1+2t,\ y=-t,\ z=3+t$ có một vectơ chỉ phương là:',
 N'$(2;-1;1)$', N'$(1;0;3)$', N'$(2;1;1)$', N'$(1;-1;3)$', 'A',
 N'<p>Hệ số của $t$ trong phương trình tham số cho vectơ chỉ phương $(2;-1;1)$.</p>'),
(39, 'MCQ', 'C2', 1, 0, N'Trong không gian $Oxyz$, đường thẳng $d:\ \dfrac{x-1}{2}=\dfrac{y+2}{-1}=\dfrac{z}{3}$ đi qua điểm nào sau đây?',
 N'$(1;-2;0)$', N'$(-1;2;0)$', N'$(2;-1;3)$', N'$(1;2;0)$', 'A',
 N'<p>Phương trình chính tắc $\dfrac{x-x_0}{a}=\dfrac{y-y_0}{b}=\dfrac{z-z_0}{c}$ cho điểm $(x_0;y_0;z_0)=(1;-2;0)$.</p>'),
(40, 'MCQ', 'C2', 2, 0, N'Trong không gian $Oxyz$, đường thẳng đi qua $A(1;2;3)$ và $B(3;2;1)$ có phương trình tham số là:',
 N'$x=1+t,\ y=2,\ z=3-t$', N'$x=1+t,\ y=2+t,\ z=3-t$', N'$x=1+2t,\ y=2,\ z=3+2t$', N'$x=1-t,\ y=2+t,\ z=3+t$', 'A',
 N'<p>$\overrightarrow{AB}=(2;0;-2)$, chọn vectơ chỉ phương $(1;0;-1)$. Đường thẳng qua $A$: $x=1+t$, $y=2$, $z=3-t$.</p>'),
(41, 'MCQ', 'C2', 2, 0, N'Trong không gian $Oxyz$, giao điểm của đường thẳng $d:\ x=1+t,\ y=2-t,\ z=t$ và mặt phẳng $(Oxy)$ là:',
 N'$(1;2;0)$', N'$(2;1;1)$', N'$(0;3;-1)$', N'$(1;2;1)$', 'A',
 N'<p>$(Oxy): z=0\Rightarrow t=0$. Giao điểm là $(1;2;0)$.</p>'),
(42, 'MCQ', 'C2', 2, 0, N'Trong không gian $Oxyz$, đường thẳng đi qua $M(1;1;1)$ và vuông góc với mặt phẳng $(P): x+2y-2z+3=0$ có phương trình là:',
 N'$x=1+t,\ y=1+2t,\ z=1-2t$', N'$x=1+t,\ y=1+2t,\ z=1+2t$', N'$x=1+t,\ y=1-2t,\ z=1+2t$', N'$x=1+2t,\ y=1+t,\ z=1-2t$', 'A',
 N'<p>Đường thẳng vuông góc với $(P)$ nhận vectơ pháp tuyến $(1;2;-2)$ làm vectơ chỉ phương.</p>'),
(43, 'MCQ', 'C2', 3, 0, N'Trong không gian $Oxyz$, hình chiếu vuông góc của $M(3;1;2)$ lên mặt phẳng $(P): x+y+z-3=0$ có tọa độ là:',
 N'$(2;0;1)$', N'$(1;-1;0)$', N'$(0;-2;-1)$', N'$(3;1;2)$', 'A',
 N'<p>Đường thẳng qua $M$ vuông góc $(P)$: $(3+t;\,1+t;\,2+t)$. Thay vào $(P)$: $3t+3=0\Rightarrow t=-1$, hình chiếu là $(2;0;1)$.</p>'),
-- ---- Chương 5, Bài 3: góc ----
(44, 'MCQ', 'C3', 1, 0, N'Trong không gian $Oxyz$, hai đường thẳng có vectơ chỉ phương $\vec{u}_1=(1;0;1)$ và $\vec{u}_2=(1;0;0)$. Góc giữa hai đường thẳng đó bằng:',
 N'$30^\circ$', N'$45^\circ$', N'$60^\circ$', N'$90^\circ$', 'B',
 N'<p>$\cos\varphi=\dfrac{|1|}{\sqrt{2}\cdot1}=\dfrac{\sqrt2}{2}$ nên $\varphi=45^\circ$.</p>'),
(45, 'MCQ', 'C3', 2, 0, N'Trong không gian $Oxyz$, gọi $\alpha$ là góc giữa đường thẳng $d$ có vectơ chỉ phương $\vec{u}=(1;1;1)$ và mặt phẳng $(Oxy)$. Giá trị $\sin\alpha$ bằng:',
 N'$\dfrac{\sqrt3}{3}$', N'$\dfrac{\sqrt2}{2}$', N'$\dfrac{1}{3}$', N'$\dfrac{\sqrt6}{3}$', 'A',
 N'<p>$(Oxy)$ có vectơ pháp tuyến $\vec{n}=(0;0;1)$. $\sin\alpha=\dfrac{|\vec{u}\cdot\vec{n}|}{|\vec{u}||\vec{n}|}=\dfrac{1}{\sqrt3}=\dfrac{\sqrt3}{3}$.</p>'),
(46, 'MCQ', 'C3', 2, 0, N'Trong không gian $Oxyz$, cho $(P): x+y-z=0$ và $(Q): x-y+z=0$. Côsin của góc giữa hai mặt phẳng là:',
 N'$\dfrac{1}{3}$', N'$\dfrac{\sqrt3}{3}$', N'$\dfrac{1}{9}$', N'$0$', 'A',
 N'<p>$\vec{n}_1=(1;1;-1)$, $\vec{n}_2=(1;-1;1)$: $\cos=\dfrac{|1-1-1|}{\sqrt3\cdot\sqrt3}=\dfrac{1}{3}$.</p>'),
(47, 'MCQ', 'C3', 2, 0, N'Trong không gian $Oxyz$, cho $(P): x+my-z=0$ và $(Q): 2x-y+z+5=0$. Hai mặt phẳng vuông góc với nhau khi $m$ bằng:',
 N'$3$', N'$-3$', N'$1$', N'$-1$', 'C',
 N'<p>$(P)\perp(Q)\Leftrightarrow\vec{n}_1\cdot\vec{n}_2=0$. Với $\vec{n}_1=(1;m;-1)$, $\vec{n}_2=(2;-1;1)$ ta có $2-m-1=0\Leftrightarrow m=1$.</p>'),
(48, 'MCQ', 'C3', 3, 0, N'Trong không gian $Oxyz$, khoảng cách giữa hai mặt phẳng song song $(P): x+2y-2z+1=0$ và $(Q): x+2y-2z-5=0$ bằng:',
 N'$2$', N'$6$', N'$1$', N'$3$', 'A',
 N'<p>Lấy $M(5;0;0)\in(Q)$: $d(M,(P))=\dfrac{|5+1|}{\sqrt{1+4+4}}=\dfrac{6}{3}=2$.</p>'),
(49, 'MCQ', 'C3', 3, 0, N'Cho hình lập phương $ABCD.A^{\prime}B^{\prime}C^{\prime}D^{\prime}$. Chọn hệ trục $A(0;0;0)$, $B(1;0;0)$, $D(0;1;0)$, $A^{\prime}(0;0;1)$. Góc giữa hai đường thẳng $AC^{\prime}$ và $BD$ bằng:',
 N'$30^\circ$', N'$45^\circ$', N'$60^\circ$', N'$90^\circ$', 'D',
 N'<p>$\overrightarrow{AC^{\prime}}=(1;1;1)$, $\overrightarrow{BD}=(-1;1;0)$. $\overrightarrow{AC^{\prime}}\cdot\overrightarrow{BD}=-1+1+0=0$ nên $AC^{\prime}\perp BD$, góc bằng $90^\circ$.</p>'),
-- ---- Chương 5, Bài 4: mặt cầu ----
(50, 'MCQ', 'C4', 1, 0, N'Trong không gian $Oxyz$, mặt cầu $(S): (x-1)^2+(y+2)^2+z^2=9$ có tâm $I$ và bán kính $R$ là:',
 N'$I(1;-2;0)$, $R=3$', N'$I(-1;2;0)$, $R=3$', N'$I(1;-2;0)$, $R=9$', N'$I(1;2;0)$, $R=3$', 'A',
 N'<p>Phương trình $(x-a)^2+(y-b)^2+(z-c)^2=R^2$ cho $I(1;-2;0)$, $R=\sqrt9=3$.</p>'),
(51, 'MCQ', 'C4', 2, 0, N'Trong không gian $Oxyz$, mặt cầu $x^2+y^2+z^2-2x+4y-6z-11=0$ có bán kính bằng:',
 N'$5$', N'$25$', N'$\sqrt{3}$', N'$3$', 'A',
 N'<p>$a=1$, $b=-2$, $c=3$, $d=-11$: $R=\sqrt{1+4+9+11}=5$.</p>'),
(52, 'MCQ', 'C4', 2, 0, N'Trong không gian $Oxyz$, mặt cầu có tâm $I(1;2;3)$ và tiếp xúc với mặt phẳng $(Oxy)$ có phương trình là:',
 N'$(x-1)^2+(y-2)^2+(z-3)^2=9$', N'$(x-1)^2+(y-2)^2+(z-3)^2=1$', N'$(x-1)^2+(y-2)^2+(z-3)^2=4$', N'$(x+1)^2+(y+2)^2+(z+3)^2=9$', 'A',
 N'<p>$R=d(I,(Oxy))=|z_I|=3$, nên $(x-1)^2+(y-2)^2+(z-3)^2=9$.</p>'),
(53, 'MCQ', 'C4', 2, 1, N'Trong không gian $Oxyz$, cho $A(1;2;3)$ và $B(3;0;-1)$. Mặt cầu đường kính $AB$ có phương trình là:',
 N'$(x-2)^2+(y-1)^2+(z-1)^2=6$', N'$(x-2)^2+(y-1)^2+(z-1)^2=24$', N'$(x-1)^2+(y-2)^2+(z-3)^2=6$', N'$(x+2)^2+(y+1)^2+(z+1)^2=6$', 'A',
 N'<p>Tâm là trung điểm $I(2;1;1)$. $AB=\sqrt{4+4+16}=\sqrt{24}$, $R=\dfrac{AB}{2}=\sqrt6$.</p>'),
(54, 'MCQ', 'C4', 3, 0, N'Trong không gian $Oxyz$, phương trình $x^2+y^2+z^2-2x+2y-4z+m=0$ là phương trình của một mặt cầu khi và chỉ khi:',
 N'$m<6$', N'$m>6$', N'$m\le6$', N'$m<0$', 'A',
 N'<p>$a=1$, $b=-1$, $c=2$, $d=m$. Điều kiện: $a^2+b^2+c^2-d>0\Leftrightarrow6-m>0\Leftrightarrow m<6$.</p>'),
(55, 'MCQ', 'C4', 3, 0, N'Trong không gian $Oxyz$, mặt cầu $(S)$ tâm $I(1;2;-1)$, bán kính $3$ cắt mặt phẳng $(P): 2x-2y+z+6=0$ theo một đường tròn. Bán kính đường tròn đó bằng:',
 N'$2\sqrt2$', N'$\sqrt{10}$', N'$3$', N'$2$', 'A',
 N'<p>$d(I,(P))=\dfrac{|2-4-1+6|}{\sqrt{4+4+1}}=1$. Bán kính đường tròn: $r=\sqrt{R^2-d^2}=\sqrt{9-1}=2\sqrt2$.</p>'),
-- ---- Chương 6, Bài 1: xác suất có điều kiện ----
(56, 'MCQ', 'D1', 1, 0, N'Cho hai biến cố $A$, $B$ với $P(B)>0$. Công thức tính xác suất của $A$ với điều kiện $B$ đã xảy ra là:',
 N'$P(A|B)=\dfrac{P(AB)}{P(B)}$', N'$P(A|B)=\dfrac{P(AB)}{P(A)}$', N'$P(A|B)=P(A)\cdot P(B)$', N'$P(A|B)=P(A)+P(B)$', 'A',
 N'<p>Theo định nghĩa, $P(A|B)=\dfrac{P(AB)}{P(B)}$ với $P(B)>0$.</p>'),
(57, 'MCQ', 'D1', 1, 0, N'Cho $P(A)=0{,}5$, $P(B)=0{,}4$, $P(AB)=0{,}2$. Xác suất $P(A|B)$ bằng:',
 N'$0{,}5$', N'$0{,}4$', N'$0{,}2$', N'$0{,}8$', 'A',
 N'<p>$P(A|B)=\dfrac{0{,}2}{0{,}4}=0{,}5$.</p>'),
(58, 'MCQ', 'D1', 1, 1, N'Cho $P(A)=0{,}3$ và $P(AB)=0{,}12$. Xác suất $P(B|A)$ bằng:',
 N'$0{,}4$', N'$0{,}36$', N'$0{,}18$', N'$2{,}5$', 'A',
 N'<p>$P(B|A)=\dfrac{P(AB)}{P(A)}=\dfrac{0{,}12}{0{,}3}=0{,}4$.</p>'),
(59, 'MCQ', 'D1', 2, 0, N'Gieo một con xúc xắc cân đối, đồng chất một lần. Gọi $A$: "số chấm chẵn", $B$: "số chấm lớn hơn 3". Xác suất $P(A|B)$ bằng:',
 N'$\dfrac{2}{3}$', N'$\dfrac{1}{2}$', N'$\dfrac{1}{3}$', N'$\dfrac{1}{6}$', 'A',
 N'<p>$B=\{4;5;6\}$, $AB=\{4;6\}$ nên $P(A|B)=\dfrac{2}{3}$.</p>'),
(60, 'MCQ', 'D1', 2, 0, N'Một hộp có 5 bi đỏ và 3 bi xanh. Lấy lần lượt không hoàn lại 2 viên bi. Xác suất để viên bi thứ hai màu đỏ, biết viên bi thứ nhất màu đỏ, bằng:',
 N'$\dfrac{4}{7}$', N'$\dfrac{5}{8}$', N'$\dfrac{5}{14}$', N'$\dfrac{1}{2}$', 'A',
 N'<p>Sau khi lấy 1 bi đỏ, hộp còn 4 bi đỏ trong tổng số 7 bi nên xác suất là $\dfrac{4}{7}$.</p>'),
(61, 'MCQ', 'D1', 2, 0, N'Với hai biến cố $A$, $B$ có $P(B)>0$, tổng $P(A|B)+P(\overline{A}|B)$ bằng:',
 N'$1$', N'$0$', N'$P(B)$', N'$2P(A)$', 'A',
 N'<p>$A$ và $\overline{A}$ là hai biến cố đối nhau nên $P(A|B)+P(\overline{A}|B)=1$.</p>'),
(62, 'MCQ', 'D1', 3, 0, N'Một lớp có 40 học sinh, trong đó 24 học sinh nữ. Có 15 học sinh đạt loại giỏi, trong đó 9 học sinh nữ. Chọn ngẫu nhiên một học sinh. Biết học sinh đó đạt loại giỏi, xác suất học sinh đó là nữ bằng:',
 N'$\dfrac{3}{5}$', N'$\dfrac{9}{40}$', N'$\dfrac{3}{8}$', N'$\dfrac{2}{5}$', 'A',
 N'<p>$P(\text{nữ}|\text{giỏi})=\dfrac{P(\text{nữ và giỏi})}{P(\text{giỏi})}=\dfrac{9/40}{15/40}=\dfrac{3}{5}$.</p>'),
-- ---- Chương 6, Bài 2: toàn phần, Bayes ----
(63, 'MCQ', 'D2', 1, 0, N'Cho hai biến cố $A$, $B$ với $0<P(B)<1$. Công thức xác suất toàn phần của $A$ là:',
 N'$P(A)=P(B)P(A|B)+P(\overline{B})P(A|\overline{B})$', N'$P(A)=P(B)+P(\overline{B})$', N'$P(A)=P(A|B)+P(A|\overline{B})$', N'$P(A)=P(B)P(A|B)$', 'A',
 N'<p>Hai biến cố $B$, $\overline{B}$ lập thành nhóm đầy đủ nên $P(A)=P(B)P(A|B)+P(\overline{B})P(A|\overline{B})$.</p>'),
(64, 'MCQ', 'D2', 2, 0, N'Cho $P(B)=0{,}6$, $P(A|B)=0{,}5$, $P(A|\overline{B})=0{,}2$. Xác suất $P(A)$ bằng:',
 N'$0{,}38$', N'$0{,}7$', N'$0{,}3$', N'$0{,}5$', 'A',
 N'<p>$P(A)=0{,}6\cdot0{,}5+0{,}4\cdot0{,}2=0{,}3+0{,}08=0{,}38$.</p>'),
(65, 'MCQ', 'D2', 3, 0, N'Cho $P(B)=0{,}6$, $P(A|B)=0{,}5$, $P(A|\overline{B})=0{,}2$. Xác suất $P(B|A)$ bằng:',
 N'$\dfrac{15}{19}$', N'$\dfrac{3}{5}$', N'$\dfrac{1}{2}$', N'$\dfrac{4}{19}$', 'A',
 N'<p>$P(A)=0{,}38$. Theo Bayes: $P(B|A)=\dfrac{0{,}6\cdot0{,}5}{0{,}38}=\dfrac{0{,}3}{0{,}38}=\dfrac{15}{19}$.</p>'),
(66, 'MCQ', 'D2', 2, 0, N'Nhà máy I sản xuất $60\%$ sản phẩm, nhà máy II sản xuất $40\%$. Tỉ lệ phế phẩm của nhà máy I là $2\%$, của nhà máy II là $5\%$. Lấy ngẫu nhiên một sản phẩm. Xác suất để sản phẩm đó là phế phẩm bằng:',
 N'$0{,}032$', N'$0{,}07$', N'$0{,}035$', N'$0{,}012$', 'A',
 N'<p>$P=0{,}6\cdot0{,}02+0{,}4\cdot0{,}05=0{,}012+0{,}02=0{,}032$.</p>'),
(67, 'MCQ', 'D2', 3, 1, N'Nhà máy I sản xuất $60\%$ sản phẩm, nhà máy II sản xuất $40\%$. Tỉ lệ phế phẩm của nhà máy I là $2\%$, của nhà máy II là $5\%$. Lấy ngẫu nhiên một sản phẩm thì được phế phẩm. Xác suất sản phẩm đó do nhà máy I sản xuất bằng:',
 N'$0{,}375$', N'$0{,}6$', N'$0{,}012$', N'$0{,}625$', 'A',
 N'<p>$P(I|\text{phế phẩm})=\dfrac{0{,}6\cdot0{,}02}{0{,}032}=\dfrac{0{,}012}{0{,}032}=0{,}375$.</p>'),
(68, 'MCQ', 'D2', 3, 0, N'Một bệnh có tỉ lệ mắc trong dân số là $1\%$. Một xét nghiệm cho kết quả dương tính với $95\%$ người mắc bệnh và với $5\%$ người không mắc bệnh. Một người xét nghiệm dương tính. Xác suất người đó thật sự mắc bệnh xấp xỉ bằng:',
 N'$0{,}95$', N'$0{,}16$', N'$0{,}05$', N'$0{,}5$', 'B',
 N'<p>$P(+)=0{,}01\cdot0{,}95+0{,}99\cdot0{,}05=0{,}059$. $P(\text{bệnh}|+)=\dfrac{0{,}0095}{0{,}059}\approx0{,}16$.</p>'),
-- ---- Chương 4, Bài 3: ứng dụng hình học của tích phân ----
(69, 'MCQ', 'I3', 1, 0, N'Diện tích hình phẳng giới hạn bởi đồ thị $y=x^2$, trục $Ox$ và hai đường thẳng $x=0$, $x=3$ bằng:',
 N'$9$', N'$27$', N'$3$', N'$\dfrac{9}{2}$', 'A',
 N'<p>$S=\int_0^3x^2\,dx=\left.\dfrac{x^3}{3}\right|_0^3=9$.</p>'),
(70, 'MCQ', 'I3', 2, 0, N'Diện tích hình phẳng giới hạn bởi hai đồ thị $y=x$ và $y=x^2$ bằng:',
 N'$\dfrac{1}{6}$', N'$\dfrac{1}{2}$', N'$\dfrac{1}{3}$', N'$\dfrac{1}{4}$', 'A',
 N'<p>$x=x^2\Leftrightarrow x=0$ hoặc $x=1$. $S=\int_0^1(x-x^2)\,dx=\dfrac12-\dfrac13=\dfrac16$.</p>'),
(71, 'MCQ', 'I3', 2, 0, N'Thể tích khối tròn xoay khi quay hình phẳng giới hạn bởi $y=\sqrt{x}$, trục $Ox$ và các đường $x=0$, $x=4$ quanh trục $Ox$ bằng:',
 N'$8\pi$', N'$4\pi$', N'$16\pi$', N'$\dfrac{8\pi}{3}$', 'A',
 N'<p>$V=\pi\int_0^4x\,dx=\pi\cdot\dfrac{x^2}{2}\Big|_0^4=8\pi$.</p>'),
(72, 'MCQ', 'I3', 2, 1, N'Thể tích khối tròn xoay khi quay hình phẳng giới hạn bởi $y=x^2$, trục $Ox$ và các đường $x=0$, $x=1$ quanh trục $Ox$ bằng:',
 N'$\dfrac{\pi}{5}$', N'$\dfrac{\pi}{3}$', N'$\dfrac{\pi}{2}$', N'$\pi$', 'A',
 N'<p>$V=\pi\int_0^1x^4\,dx=\dfrac{\pi}{5}$.</p>'),
(73, 'MCQ', 'I3', 3, 0, N'Diện tích hình phẳng giới hạn bởi parabol $y=x^2-2x$ và trục hoành bằng:',
 N'$\dfrac{4}{3}$', N'$\dfrac{8}{3}$', N'$-\dfrac{4}{3}$', N'$2$', 'A',
 N'<p>$x^2-2x=0\Leftrightarrow x=0$ hoặc $x=2$. Trên $[0;2]$, $y\le0$ nên $S=\int_0^2(2x-x^2)\,dx=\left(x^2-\dfrac{x^3}{3}\right)\Big|_0^2=4-\dfrac83=\dfrac43$.</p>'),
-- ---- Tự luận ----
(201, 'ESSAY', 'C1', 2, 0, N'Trong không gian $Oxyz$, cho $A(1;0;0)$, $B(0;2;0)$, $C(0;0;3)$. Viết phương trình mặt phẳng $(ABC)$ và tính khoảng cách từ gốc tọa độ $O$ đến mặt phẳng $(ABC)$.',
 NULL, NULL, NULL, NULL, NULL,
 N'<p>Phương trình đoạn chắn: $\dfrac{x}{1}+\dfrac{y}{2}+\dfrac{z}{3}=1\Leftrightarrow6x+3y+2z-6=0$. Khoảng cách: $d(O,(ABC))=\dfrac{|-6|}{\sqrt{36+9+4}}=\dfrac{6}{7}$.</p>'),
(202, 'ESSAY', 'B2', 2, 0, N'Kết quả khảo sát thời gian tự học mỗi ngày (phút) của 20 học sinh: $[0;10)$: 4; $[10;20)$: 6; $[20;30)$: 10. Tính số trung bình, phương sai và độ lệch chuẩn của mẫu số liệu ghép nhóm trên.',
 NULL, NULL, NULL, NULL, NULL,
 N'<p>Giá trị đại diện: 5; 15; 25. $\bar{x}=\dfrac{4\cdot5+6\cdot15+10\cdot25}{20}=18$. $s^2=\dfrac{4\cdot25+6\cdot225+10\cdot625}{20}-18^2=385-324=61$. $s=\sqrt{61}\approx7{,}81$.</p>'),
(203, 'ESSAY', 'D2', 3, 1, N'Nhà máy I sản xuất $60\%$ sản phẩm, nhà máy II sản xuất $40\%$. Tỉ lệ phế phẩm của hai nhà máy lần lượt là $2\%$ và $5\%$. (a) Tính xác suất để một sản phẩm lấy ngẫu nhiên là phế phẩm. (b) Biết sản phẩm lấy ra là phế phẩm, tính xác suất sản phẩm đó do nhà máy I sản xuất.',
 NULL, NULL, NULL, NULL, NULL,
 N'<p>(a) Theo công thức xác suất toàn phần: $P=0{,}6\cdot0{,}02+0{,}4\cdot0{,}05=0{,}032$. (b) Theo công thức Bayes: $P(I|\text{phế phẩm})=\dfrac{0{,}6\cdot0{,}02}{0{,}032}=0{,}375$.</p>'),
(204, 'ESSAY', 'I3', 2, 0, N'Tính diện tích hình phẳng giới hạn bởi parabol $y=x^2-2x$ và đường thẳng $y=x$.',
 NULL, NULL, NULL, NULL, NULL,
 N'<p>$x^2-2x=x\Leftrightarrow x=0$ hoặc $x=3$. Trên $[0;3]$: $x\ge x^2-2x$. $S=\int_0^3(3x-x^2)\,dx=\left(\dfrac{3x^2}{2}-\dfrac{x^3}{3}\right)\Big|_0^3=\dfrac{27}{2}-9=\dfrac92$.</p>'),
(205, 'ESSAY', 'P5', 3, 0, N'Một bể cá dạng hình hộp chữ nhật không nắp, đáy là hình vuông, thể tích $32\ \text{m}^3$. Tìm kích thước của bể để diện tích vật liệu (diện tích toàn phần của bể không nắp) nhỏ nhất.',
 NULL, NULL, NULL, NULL, NULL,
 N'<p>Gọi cạnh đáy là $x>0$, chiều cao $h=\dfrac{32}{x^2}$. Diện tích vật liệu $S(x)=x^2+4xh=x^2+\dfrac{128}{x}$. $S^{\prime}(x)=2x-\dfrac{128}{x^2}=0\Leftrightarrow x=4$. Lập bảng biến thiên: $S$ nhỏ nhất tại $x=4$, khi đó $h=2$ và $S_{\min}=48\ \text{m}^2$.</p>');

CREATE TABLE #Map (Seq INT PRIMARY KEY, QuestionId INT NOT NULL);

MERGE Questions AS tgt
USING (SELECT q.Seq, m.LessonId, q.QType, q.Content, q.Expl, q.Lvl, q.AI, m.TeacherId
       FROM #Q q JOIN #LM m ON m.Code = q.LCode) AS src
ON 1 = 0
WHEN NOT MATCHED THEN
    INSERT (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId, CreatedAt)
    VALUES (src.LessonId, src.QType, src.Content, src.Expl, src.Lvl, src.AI, 1, src.TeacherId,
            DATEADD(HOUR, -(src.Seq % 100), GETDATE()))
OUTPUT src.Seq, inserted.QuestionId INTO #Map (Seq, QuestionId);

INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect)
SELECT m.QuestionId, v.Letter, v.Txt, CASE WHEN v.Letter = q.Correct THEN 1 ELSE 0 END
FROM #Q q
JOIN #Map m ON m.Seq = q.Seq
CROSS APPLY (VALUES ('A', q.A), ('B', q.B), ('C', q.C), ('D', q.D)) AS v (Letter, Txt)
WHERE q.QType = 'MCQ';

-- =====================================================================================================================
-- 5. Submissions trắc nghiệm: ~150 bài của các học sinh đang hoạt động, trải đều 14 ngày, độ chính xác mỗi học sinh khác nhau
-- =====================================================================================================================
CREATE TABLE #N (n INT PRIMARY KEY);
INSERT INTO #N (n)
SELECT TOP (150) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM sys.all_objects a CROSS JOIN sys.all_objects b;

CREATE TABLE #St (rn INT PRIMARY KEY, UserId INT NOT NULL);
INSERT INTO #St (rn, UserId)
SELECT ROW_NUMBER() OVER (ORDER BY UserId), UserId FROM Users WHERE [Role] = 'STUDENT' AND [Status] = 'ACTIVE';

CREATE TABLE #Mq (rn INT PRIMARY KEY, QuestionId INT NOT NULL, LessonId INT NOT NULL, Letter CHAR(1) NOT NULL);
INSERT INTO #Mq (rn, QuestionId, LessonId, Letter)
SELECT ROW_NUMBER() OVER (ORDER BY q.QuestionId), q.QuestionId, q.LessonId, o.OptionLetter
FROM Questions q
JOIN #Map mp ON mp.QuestionId = q.QuestionId AND mp.Seq < 200
JOIN QuestionOptions o ON o.QuestionId = q.QuestionId AND o.IsCorrect = 1;

DECLARE @S INT = (SELECT COUNT(*) FROM #St);
DECLARE @M INT = (SELECT COUNT(*) FROM #Mq);

INSERT INTO Submissions (StudentId, LessonId, QuestionId, QuestionType, StudentAnswer, IsCorrect, FinalScore, [Status], IsReviewed, SubmittedAt)
SELECT st.UserId, mq.LessonId, mq.QuestionId, 'MCQ',
       CASE WHEN c.ok = 1 THEN mq.Letter ELSE CHAR(65 + ((ASCII(mq.Letter) - 65 + 1 + (n.n % 3)) % 4)) END,
       c.ok, CASE WHEN c.ok = 1 THEN 10 ELSE 0 END, 'GRADED', 1,
       DATEADD(MINUTE, -(120 + (n.n * 149) % (14 * 24 * 60 - 120)), GETDATE())
FROM #N n
JOIN #St st ON st.rn = ((n.n - 1) % @S) + 1
JOIN #Mq mq ON mq.rn = ((n.n * 5 + st.rn * 3) % @M) + 1
CROSS APPLY (SELECT CASE WHEN ((n.n * 13 + st.rn * 7) % 10) < 3 + (st.rn % 6) THEN 1 ELSE 0 END AS ok) AS c;

-- =====================================================================================================================
-- 6. Submissions tự luận: 2 bài chờ duyệt (AI_GRADED) và 2 bài đã duyệt (REVIEWED, điểm cuối khác điểm AI)
-- =====================================================================================================================
DECLARE @stu1  INT = (SELECT UserId FROM Users WHERE Username = 'student1');
DECLARE @stu2  INT = (SELECT UserId FROM Users WHERE Username = 'student2');
DECLARE @stu4  INT = (SELECT UserId FROM Users WHERE Username = 'student4');
DECLARE @stu5  INT = (SELECT UserId FROM Users WHERE Username = 'student5');
DECLARE @stu6  INT = (SELECT UserId FROM Users WHERE Username = 'student6');
DECLARE @stu11 INT = (SELECT UserId FROM Users WHERE Username = 'student11');

DECLARE @e201 INT = (SELECT QuestionId FROM #Map WHERE Seq = 201);
DECLARE @e202 INT = (SELECT QuestionId FROM #Map WHERE Seq = 202);
DECLARE @e203 INT = (SELECT QuestionId FROM #Map WHERE Seq = 203);
DECLARE @e204 INT = (SELECT QuestionId FROM #Map WHERE Seq = 204);
DECLARE @lC1 INT = (SELECT LessonId FROM #LM WHERE Code = 'C1');
DECLARE @lB2 INT = (SELECT LessonId FROM #LM WHERE Code = 'B2');
DECLARE @lD2 INT = (SELECT LessonId FROM #LM WHERE Code = 'D2');
DECLARE @lI3 INT = (SELECT LessonId FROM #LM WHERE Code = 'I3');

-- Chờ duyệt: FinalScore = AiScore cho tới khi giáo viên duyệt (BR-09)
INSERT INTO Submissions (StudentId, LessonId, QuestionId, QuestionType, StudentAnswer, EssayImagePath, AiScore, FinalScore,
                         AiFeedback, SuggestedCorrection, [Status], IsReviewed, SubmittedAt) VALUES
(@stu1, @lC1, @e201, 'ESSAY', N'(ABC): x/1 + y/2 + z/3 = 1 hay 6x + 3y + 2z - 6 = 0. d(O,(ABC)) = |-6| / căn(36+9+4) = 6/7.',
 'https://placehold.co/800x600/png?text=Bai+lam+viet+tay+C1', 9.50, 9.50,
 N'Viết đúng phương trình đoạn chắn, tính khoảng cách chính xác. Trình bày gọn, đủ bước.', NULL, 'AI_GRADED', 0, DATEADD(HOUR, -2, GETDATE())),
(@stu4, @lB2, @e202, 'ESSAY', N'Trung bình = 18. Phương sai = 385 - 18^2 = 61. Độ lệch chuẩn = căn 61 = 7,81.',
 NULL, 8.00, 8.00,
 N'Kết quả đúng. Em chưa trình bày cách tính giá trị đại diện của từng nhóm và tổng $\sum n_ix_i^2$.',
 N'Nên viết rõ giá trị đại diện 5; 15; 25 và biểu thức $\dfrac{4\cdot25+6\cdot225+10\cdot625}{20}=385$.', 'AI_GRADED', 0, DATEADD(HOUR, -6, GETDATE()));

-- Đã duyệt: AiScore giữ nguyên, FinalScore do giáo viên chỉnh
INSERT INTO Submissions (StudentId, LessonId, QuestionId, QuestionType, StudentAnswer, EssayImagePath, AiScore, FinalScore,
                         AiFeedback, SuggestedCorrection, TeacherFeedback, [Status], IsReviewed, ReviewedBy, ReviewedAt, SubmittedAt) VALUES
(@stu2, @lD2, @e203, 'ESSAY', N'(a) P = 0,6.0,02 + 0,4.0,05 = 0,032. (b) P = 0,6.0,02 / 0,032 = 0,375.',
 NULL, 8.50, 9.50,
 N'Đúng cả hai ý, dùng đúng công thức toàn phần và Bayes. Chưa gọi tên các biến cố.', N'Nên đặt $B$: "sản phẩm của nhà máy I", $A$: "phế phẩm" trước khi tính.',
 N'Làm tốt! Cô cộng thêm 1 điểm vì kết quả chính xác và lập luận gọn.', 'REVIEWED', 1, @t3, DATEADD(DAY, -1, GETDATE()), DATEADD(DAY, -2, GETDATE())),
(@stu5, @lI3, @e204, 'ESSAY', N'Giao điểm x = 0 và x = 3. S = tích phân từ 0 đến 3 của (x^2 - 2x - x) = x^3/3 - 3x^2/2 = 9 - 13,5 = -4,5.',
 'https://placehold.co/800x600/png?text=Bai+lam+viet+tay+I3', 5.00, 6.00,
 N'Tìm đúng giao điểm nhưng quên lấy giá trị tuyệt đối, ra diện tích âm.', N'$S=\int_0^3\left|x^2-3x\right|dx=\int_0^3(3x-x^2)dx=\dfrac92$.',
 N'Diện tích luôn dương, em nhớ đặt dấu giá trị tuyệt đối. Phần còn lại đúng nên cô cho 6 điểm.', 'REVIEWED', 1, @t1, DATEADD(DAY, -3, GETDATE()), DATEADD(DAY, -4, GETDATE()));

-- =====================================================================================================================
-- 7. TutorSessions + TutorMessages: 1 phiên ACTIVE (đang chờ nhập) và 1 phiên COMPLETED
-- =====================================================================================================================
DECLARE @lC4 INT = (SELECT LessonId FROM #LM WHERE Code = 'C4');
DECLARE @lD1 INT = (SELECT LessonId FROM #LM WHERE Code = 'D1');
DECLARE @q55 INT = (SELECT QuestionId FROM #Map WHERE Seq = 55);   -- mặt cầu cắt mặt phẳng
DECLARE @sid INT;

INSERT INTO TutorSessions (StudentId, LessonId, QuestionId, Title, ProblemText, CurrentStep, TotalSteps, [Status], AwaitingInput, InputHint, CreatedAt, UpdatedAt)
VALUES (@stu6, @lC4, @q55, N'Mặt cầu tâm $I(1;2;-1)$, bán kính $3$ cắt mặt phẳng $(P): 2x-2y+z+6=0$ theo một đường tròn. Tính bán kính đường tròn.',
        N'Trong không gian $Oxyz$, mặt cầu $(S)$ tâm $I(1;2;-1)$, bán kính $3$ cắt mặt phẳng $(P): 2x-2y+z+6=0$ theo một đường tròn. Tính bán kính đường tròn đó.',
        2, 3, 'ACTIVE', 1, N'Nhập khoảng cách d(I,(P))', DATEADD(MINUTE, -30, GETDATE()), DATEADD(MINUTE, -26, GETDATE()));
SET @sid = SCOPE_IDENTITY();
INSERT INTO TutorMessages (SessionId, SenderType, StepNumber, ContentText, IsStepCompleted, CreatedAt) VALUES
(@sid, 'USER', 1, N'Em làm sai câu này, nhờ gia sư hướng dẫn từng bước.', 0, DATEADD(MINUTE, -30, GETDATE())),
(@sid, 'AI',   1, N'Chào em! Mình cùng làm từng bước nhé. **Bước 1:** Mặt phẳng cắt mặt cầu theo đường tròn có bán kính $r=\sqrt{R^2-d^2}$ với $d=d(I,(P))$. Em hãy viết công thức khoảng cách từ $I(1;2;-1)$ đến $(P)$.', 0, DATEADD(MINUTE, -30, GETDATE())),
(@sid, 'USER', 1, N'$d=\dfrac{|2\cdot1-2\cdot2+(-1)+6|}{\sqrt{2^2+(-2)^2+1^2}}$', 0, DATEADD(MINUTE, -27, GETDATE())),
(@sid, 'AI',   2, N'Chính xác! **Bước 2:** Em hãy tính giá trị của $d$ từ biểu thức trên.', 1, DATEADD(MINUTE, -26, GETDATE()));

INSERT INTO TutorSessions (StudentId, LessonId, QuestionId, Title, ProblemText, CurrentStep, TotalSteps, [Status], AwaitingInput, InputHint, CreatedAt, UpdatedAt)
VALUES (@stu11, @lD1, NULL, N'Gieo một con xúc xắc cân đối. Tính $P(A|B)$ với $A$: "số chấm chẵn", $B$: "số chấm lớn hơn 3".',
        N'Gieo một con xúc xắc cân đối, đồng chất một lần. Gọi $A$: "số chấm chẵn", $B$: "số chấm lớn hơn 3". Tính $P(A|B)$.', 3, 3, 'COMPLETED', 0, NULL,
        DATEADD(DAY, -2, GETDATE()), DATEADD(DAY, -2, DATEADD(MINUTE, 9, GETDATE())));
SET @sid = SCOPE_IDENTITY();
INSERT INTO TutorMessages (SessionId, SenderType, StepNumber, ContentText, IsStepCompleted, CreatedAt) VALUES
(@sid, 'USER', 1, N'Em chưa biết bắt đầu tính xác suất có điều kiện thế nào.', 0, DATEADD(DAY, -2, GETDATE())),
(@sid, 'AI',   1, N'**Bước 1:** Theo định nghĩa, $P(A|B)=\dfrac{P(AB)}{P(B)}$. Em hãy liệt kê các kết quả thuận lợi của biến cố $B$ và tính $P(B)$.', 0, DATEADD(DAY, -2, GETDATE())),
(@sid, 'USER', 1, N'$B=\{4;5;6\}$ nên $P(B)=\dfrac{3}{6}=\dfrac{1}{2}$', 0, DATEADD(DAY, -2, DATEADD(MINUTE, 3, GETDATE()))),
(@sid, 'AI',   2, N'Đúng rồi! **Bước 2:** Em hãy tìm các kết quả vừa thuộc $A$ vừa thuộc $B$ và tính $P(AB)$.', 1, DATEADD(DAY, -2, DATEADD(MINUTE, 3, GETDATE()))),
(@sid, 'USER', 2, N'$AB=\{4;6\}$ nên $P(AB)=\dfrac{2}{6}=\dfrac{1}{3}$', 0, DATEADD(DAY, -2, DATEADD(MINUTE, 7, GETDATE()))),
(@sid, 'AI',   3, N'Chính xác! **Tổng kết:** $P(A|B)=\dfrac{1/3}{1/2}=\dfrac{2}{3}$.', 1, DATEADD(DAY, -2, DATEADD(MINUTE, 7, GETDATE())));

DROP TABLE #N, #St, #Mq, #Map, #Q, #LM, #L;

PRINT N'Đã thêm dữ liệu Toán 12 (GDPT 2018): 4 chủ đề mới, 13 bài học, 73 câu trắc nghiệm, 5 tự luận.';
GO
