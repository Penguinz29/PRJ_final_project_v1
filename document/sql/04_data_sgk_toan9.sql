-- =====================================================================================================================
-- File: document/sql/04_data_sgk_toan9.sql — nội dung theo SGK Toán 9 (bộ Kết nối tri thức với cuộc sống, Tập 1 + Tập 2)
-- Chạy SAU 01_schema.sql và 02_data.sql (04 sẽ xóa nội dung demo của 02 rồi thay mới). Thay thế 04_data_sgk_toan12.sql.
-- CẢNH BÁO: script XÓA TOÀN BỘ chủ đề / bài học / bài giảng / câu hỏi / bài làm / phiên gia sư AI cũ,
--           rồi nạp lại theo sách giáo khoa. GIỮ NGUYÊN Users và AiConfigs. Chạy lại lần 2 sẽ tự bỏ qua (không nhân đôi).
-- Cấu trúc: mỗi CHƯƠNG của sách = 1 chủ đề (Topics); mỗi BÀI (kể cả "Luyện tập chung" và "Bài tập cuối chương") = 1 bài học (Lessons,
--           Content là tóm tắt lý thuyết trọng tâm kèm ví dụ); mục "Bài tập" của sách thành câu hỏi: câu trắc nghiệm của sách = MCQ
--           (4 phương án, có đáp án và lời giải ngắn), các bài còn lại = TỰ LUẬN (ESSAY, có lời giải từng bước).
--           Sách không in đáp án nên đáp án và lời giải do người số hóa tự giải (giáo viên nên xem lại khi dùng chính thức).
-- Toàn bộ chủ đề / bài học / câu hỏi do teacher1 tạo. Mọi giáo viên xem và sửa được chủ đề / bài học / bài giảng; chỉ người tạo hoặc Admin xóa;
--           câu hỏi chỉ người tạo (hoặc Admin) sửa.
-- Thứ tự hiển thị: chủ đề theo OrderIndex (Chương I → X), bài học theo DisplayOrder, câu hỏi theo QuestionId (đúng thứ tự trong sách).
-- Mức độ (Level 1-3) do người số hóa tự đánh giá, giáo viên có thể chỉnh trên giao diện.
-- Nội dung đã nạp: Tập 1 — Chương I.
-- =====================================================================================================================
USE MathTutorDB;
GO

SET NOCOUNT ON;

IF EXISTS (SELECT 1 FROM Topics WHERE TopicName = N'Chương I. Phương trình và hệ hai phương trình bậc nhất hai ẩn')
BEGIN
    PRINT N'04_data_sgk_toan9.sql đã được chạy trước đó: bỏ qua.';
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
-- Chương I. Phương trình và hệ hai phương trình bậc nhất hai ẩn
-- ---------------------------------------------------------------------------------------------------------------------
INSERT INTO Topics (TopicName, [Description], TeacherId, OrderIndex, IsActive) VALUES (N'Chương I. Phương trình và hệ hai phương trình bậc nhất hai ẩn', N'Khái niệm phương trình và hệ hai phương trình bậc nhất hai ẩn, giải hệ bằng phương pháp thế, phương pháp cộng đại số, máy tính cầm tay và giải bài toán bằng cách lập hệ phương trình. (SGK Toán 9 Kết nối tri thức với cuộc sống, Tập 1)', @t1, 1, 1);
SET @tp = SCOPE_IDENTITY();

-- Bài 1
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 1. Khái niệm phương trình và hệ hai phương trình bậc nhất hai ẩn', N'Nhận biết phương trình bậc nhất hai ẩn, nghiệm của phương trình; hệ hai phương trình bậc nhất hai ẩn và nghiệm của hệ.', N'<p><b>1. Phương trình bậc nhất hai ẩn.</b> Phương trình bậc nhất hai ẩn $x$ và $y$ là hệ thức dạng $$ax+by=c,\quad (1)$$ trong đó $a,\ b,\ c$ là các số đã biết ($a\neq 0$ hoặc $b\neq 0$).</p>
<p>Nếu tại $x=x_0$ và $y=y_0$ ta có $ax_0+by_0=c$ là một khẳng định đúng thì cặp số $(x_0;y_0)$ được gọi là một <b>nghiệm</b> của phương trình (1).</p>
<p><b>Ví dụ 1.</b> Hệ thức $4x+3y=5$ và $0x+y=-1$ là phương trình bậc nhất hai ẩn; hệ thức $0x+0y=3$ có $a=b=0$ nên không phải. Cặp số $(2;-1)$ là nghiệm của $4x+3y=5$ vì $4\cdot2+3\cdot(-1)=5$; cặp $(1;0)$ không là nghiệm vì $4\cdot1+3\cdot0=4\neq5$.</p>
<p><b>Chú ý.</b> Mỗi phương trình bậc nhất hai ẩn đều có <b>vô số nghiệm</b>. Chẳng hạn $x+2y=5$ viết được $y=\dfrac{5-x}{2}$: với mỗi giá trị tùy ý của $x$ ta luôn tìm được một giá trị $y$ tương ứng. Khi đó nghiệm tổng quát là $\left(x;\dfrac{5-x}{2}\right)$ với $x\in\mathbb{R}$ tùy ý.</p>
<p><b>Biểu diễn hình học.</b> Trong mặt phẳng tọa độ $Oxy$, tập hợp các điểm có tọa độ $(x;y)$ thỏa mãn $ax+by=c$ là một <b>đường thẳng</b>, gọi là đường thẳng $ax+by=c$.</p>
<ul>
<li>$a\neq0,\ b\neq0$: đường thẳng $y=-\dfrac{a}{b}x+\dfrac{c}{b}$.</li>
<li>$a=0,\ b\neq0$: phương trình thành $y=m$ (với $m=\dfrac{c}{b}$), nghiệm $(x;m)$ với $x\in\mathbb{R}$; đường thẳng song song với trục hoành, cắt trục tung tại $(0;m)$.</li>
<li>$a\neq0,\ b=0$: phương trình thành $x=n$ (với $n=\dfrac{c}{a}$), nghiệm $(n;y)$ với $y\in\mathbb{R}$; đường thẳng song song với trục tung, cắt trục hoành tại $(n;0)$.</li>
</ul>
<p><b>2. Hệ hai phương trình bậc nhất hai ẩn.</b> Một cặp gồm hai phương trình bậc nhất hai ẩn $ax+by=c$ và $a''x+b''y=c''$ được gọi là một hệ hai phương trình bậc nhất hai ẩn, viết dưới dạng $$\begin{cases}ax+by=c\\ a''x+b''y=c''.\end{cases}\quad (*)$$ Mỗi cặp số $(x_0;y_0)$ đồng thời là nghiệm của cả hai phương trình được gọi là một <b>nghiệm của hệ</b> (*), tức là nghiệm chung của hai phương trình.</p>
<p><b>Ví dụ 2.</b> Cặp số $(1;2)$ là nghiệm của hệ $\begin{cases}2x-y=0\\ x+y=3\end{cases}$ vì $2\cdot1-2=0$ và $1+2=3$. Về hình học, điểm $M(1;2)$ là giao điểm của hai đường thẳng $2x-y=0$ và $x+y=3$.</p>
<p><b>Bài toán cổ.</b> "Quýt, cam mười bảy quả tươi, đem chia cho một trăm người cùng vui. Chia ba mỗi quả quýt rồi, còn cam mỗi quả chia mười vừa xinh." Gọi $x$ là số cam, $y$ là số quýt ta có hệ $\begin{cases}x+y=17\\ 10x+3y=100,\end{cases}$ có nghiệm $(10;7)$: 10 quả cam và 7 quả quýt.</p>', 1, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.1.</b> Phương trình nào sau đây là phương trình bậc nhất hai ẩn? Vì sao?</p>
<ol type="a">
<li>$5x-8y=0$;</li>
<li>$4x+0y=-2$;</li>
<li>$0x+0y=1$;</li>
<li>$0x-3y=9$.</li>
</ol>', N'<p>Phương trình $ax+by=c$ là bậc nhất hai ẩn khi $a\neq0$ hoặc $b\neq0$.</p>
<p><b>a)</b> $a=5,\ b=-8$: là phương trình bậc nhất hai ẩn. <b>b)</b> $a=4\neq0$: là phương trình bậc nhất hai ẩn. <b>c)</b> $a=b=0$: không phải. <b>d)</b> $b=-3\neq0$: là phương trình bậc nhất hai ẩn.</p>
<p><b>Đáp số:</b> a), b), d) là phương trình bậc nhất hai ẩn; c) không phải.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.2.</b></p>
<ol type="a">
<li>Tìm giá trị thích hợp thay cho dấu "?" trong bảng sau rồi cho biết 6 nghiệm của phương trình $2x-y=1$:
<table border="1"><tr><th>$x$</th><td>$-1$</td><td>$-0{,}5$</td><td>$0$</td><td>$0{,}5$</td><td>$1$</td><td>$2$</td></tr><tr><th>$y=2x-1$</th><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td></tr></table></li>
<li>Viết nghiệm tổng quát của phương trình đã cho.</li>
</ol>', N'<p><b>a)</b> Thay lần lượt vào $y=2x-1$:</p>
<table border="1"><tr><th>$x$</th><td>$-1$</td><td>$-0{,}5$</td><td>$0$</td><td>$0{,}5$</td><td>$1$</td><td>$2$</td></tr><tr><th>$y$</th><td>$-3$</td><td>$-2$</td><td>$-1$</td><td>$0$</td><td>$1$</td><td>$3$</td></tr></table>
<p>Sáu nghiệm: $(-1;-3),\ (-0{,}5;-2),\ (0;-1),\ (0{,}5;0),\ (1;1),\ (2;3)$.</p>
<p><b>b)</b> Nghiệm tổng quát: $(x;\,2x-1)$ với $x\in\mathbb{R}$ tùy ý.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.3.</b> Viết nghiệm và biểu diễn hình học tất cả các nghiệm của mỗi phương trình bậc nhất hai ẩn sau:</p>
<ol type="a">
<li>$2x-y=3$;</li>
<li>$0x+2y=-4$;</li>
<li>$3x+0y=5$.</li>
</ol>', N'<p><b>a)</b> $y=2x-3$. Nghiệm tổng quát $(x;2x-3)$ với $x\in\mathbb{R}$. Tập nghiệm được biểu diễn bằng đường thẳng $2x-y=3$ đi qua hai điểm, chẳng hạn $A(0;-3)$ và $B(2;1)$.</p>
<p><b>b)</b> Phương trình viết gọn thành $y=-2$. Nghiệm $(x;-2)$ với $x\in\mathbb{R}$. Biểu diễn bằng đường thẳng $y=-2$ song song với trục hoành, cắt trục tung tại điểm $(0;-2)$.</p>
<p><b>c)</b> Phương trình viết gọn thành $x=\dfrac{5}{3}$. Nghiệm $\left(\dfrac{5}{3};y\right)$ với $y\in\mathbb{R}$. Biểu diễn bằng đường thẳng $x=\dfrac{5}{3}$ song song với trục tung, cắt trục hoành tại điểm $\left(\dfrac{5}{3};0\right)$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.4.</b> Cho hệ phương trình $\begin{cases}2x=-6\\ 5x+4y=1.\end{cases}$</p>
<ol type="a">
<li>Hệ phương trình trên có là một hệ hai phương trình bậc nhất hai ẩn không? Vì sao?</li>
<li>Cặp số $(-3;4)$ có là một nghiệm của hệ phương trình đã cho hay không? Vì sao?</li>
</ol>', N'<p><b>a)</b> Phương trình $2x=-6$ viết được dưới dạng $2x+0y=-6$ có $a=2\neq0$ nên là phương trình bậc nhất hai ẩn; phương trình $5x+4y=1$ cũng vậy. Vậy đây là một hệ hai phương trình bậc nhất hai ẩn.</p>
<p><b>b)</b> Thay $x=-3,\ y=4$: $2\cdot(-3)=-6$ đúng; $5\cdot(-3)+4\cdot4=-15+16=1$ đúng. Cặp $(-3;4)$ nghiệm đúng cả hai phương trình nên là một nghiệm của hệ.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.5.</b> Cho các cặp số $(-2;1),\ (0;2),\ (1;0),\ (1{,}5;3),\ (4;-3)$ và hai phương trình $$5x+4y=8,\quad (1)$$ $$3x+5y=-3.\quad (2)$$ Trong các cặp số đã cho:</p>
<ol type="a">
<li>Những cặp số nào là nghiệm của phương trình (1)?</li>
<li>Cặp số nào là nghiệm của hệ hai phương trình gồm phương trình (1) và phương trình (2)?</li>
<li>Vẽ hai đường thẳng $5x+4y=8$ và $3x+5y=-3$ trên cùng một mặt phẳng tọa độ để minh họa kết luận ở câu b.</li>
</ol>', N'<p><b>a)</b> Thay vào $5x+4y$: $(-2;1)\to-6$; $(0;2)\to8$; $(1;0)\to5$; $(1{,}5;3)\to19{,}5$; $(4;-3)\to8$. Các cặp có kết quả bằng 8 là $(0;2)$ và $(4;-3)$.</p>
<p><b>b)</b> Với phương trình (2): $(0;2)\to3\cdot0+5\cdot2=10\neq-3$; $(4;-3)\to12-15=-3$ đúng. Vậy nghiệm của hệ là $(4;-3)$.</p>
<p><b>c)</b> Đường thẳng $5x+4y=8$ đi qua $(0;2)$ và $(4;-3)$; đường thẳng $3x+5y=-3$ đi qua $(4;-3)$ và $(-1;0)$. Hai đường thẳng cắt nhau tại điểm $(4;-3)$, trùng với nghiệm của hệ ở câu b.</p>
<p><b>Đáp số:</b> a) $(0;2)$, $(4;-3)$. b) $(4;-3)$.</p>', 2, 0, 1, @t1);

-- Bài 2
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 2. Giải hệ hai phương trình bậc nhất hai ẩn', N'Giải hệ hai phương trình bậc nhất hai ẩn bằng phương pháp thế, phương pháp cộng đại số và máy tính cầm tay.', N'<p><b>1. Phương pháp thế.</b></p>
<ul>
<li><i>Bước 1.</i> Từ một phương trình của hệ, biểu diễn một ẩn theo ẩn kia rồi thế vào phương trình còn lại để được phương trình chỉ còn chứa một ẩn.</li>
<li><i>Bước 2.</i> Giải phương trình một ẩn vừa nhận được, từ đó suy ra nghiệm của hệ đã cho.</li>
</ul>
<p><b>Ví dụ 1.</b> Giải hệ $\begin{cases}2x-y=3\\ x+2y=4.\end{cases}$ Từ phương trình thứ nhất: $y=2x-3$. Thế vào phương trình thứ hai: $x+2(2x-3)=4$ hay $5x-6=4$, suy ra $x=2$; $y=2\cdot2-3=1$. Hệ có nghiệm $(2;1)$.</p>
<p><b>Ví dụ 2 (vô nghiệm).</b> Hệ $\begin{cases}x-y=-2\\ 2x-2y=8\end{cases}$: từ $x=y-2$ thế vào phương trình thứ hai được $0y-4=8$, không có giá trị nào của $y$ thỏa mãn nên hệ <b>vô nghiệm</b>.</p>
<p><b>Ví dụ 3 (vô số nghiệm).</b> Hệ $\begin{cases}-x+y=-2\\ 3x-3y=6\end{cases}$: từ $y=x-2$ thế vào phương trình thứ hai được $0x=0$, mọi $x$ đều thỏa mãn. Hệ có nghiệm $(x;x-2)$ với $x\in\mathbb{R}$ tùy ý.</p>
<p><b>2. Phương pháp cộng đại số.</b> Khi hệ số của cùng một ẩn trong hai phương trình bằng nhau hoặc đối nhau:</p>
<ul>
<li><i>Bước 1.</i> Cộng hay trừ từng vế của hai phương trình để được phương trình chỉ còn chứa một ẩn.</li>
<li><i>Bước 2.</i> Giải phương trình một ẩn đó, từ đó suy ra nghiệm của hệ.</li>
</ul>
<p><b>Chú ý.</b> Nếu hệ số của cùng một ẩn không bằng nhau hay đối nhau, ta nhân hai vế của mỗi phương trình với một số thích hợp (khác 0) để đưa về trường hợp trên.</p>
<p><b>Ví dụ 4.</b> Giải $\begin{cases}-2x+5y=12\\ 2x+3y=4.\end{cases}$ Cộng từng vế: $8y=16$, $y=2$; thế vào phương trình thứ hai: $2x+6=4$, $x=-1$. Nghiệm $(-1;2)$.</p>
<p><b>Ví dụ 5.</b> Giải $\begin{cases}3x+2y=7\\ 2x-3y=-4.\end{cases}$ Nhân phương trình thứ nhất với 3, phương trình thứ hai với 2: $\begin{cases}9x+6y=21\\ 4x-6y=-8.\end{cases}$ Cộng vế: $13x=13$, $x=1$; $y=2$. Nghiệm $(1;2)$.</p>
<p><b>3. Sử dụng máy tính cầm tay.</b> Viết hệ dưới dạng $\begin{cases}a_1x+b_1y=c_1\\ a_2x+b_2y=c_2\end{cases}$, bấm MODE chọn chức năng giải hệ hai phương trình bậc nhất hai ẩn, nhập lần lượt $a_1,b_1,c_1,a_2,b_2,c_2$ rồi bấm = để đọc $x$ và $y$. Nếu máy báo "Infinite Sol" thì hệ có vô số nghiệm; nếu máy báo "No-Solution" thì hệ vô nghiệm.</p>
<p><b>Em có biết (phương pháp hình học).</b> Giải hệ bằng cách vẽ hai đường thẳng $\Delta:ax+by=c$ và $\Delta'':a''x+b''y=c''$: nếu cắt nhau thì hệ có một nghiệm duy nhất; nếu song song thì hệ vô nghiệm; nếu trùng nhau thì hệ có vô số nghiệm.</p>', 2, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.6.</b> Giải các hệ phương trình sau bằng phương pháp thế:</p>
<ol type="a">
<li>$\begin{cases}x-y=3\\ 3x-4y=2;\end{cases}$</li>
<li>$\begin{cases}7x-3y=13\\ 4x+y=2;\end{cases}$</li>
<li>$\begin{cases}0{,}5x-1{,}5y=1\\ -x+3y=2.\end{cases}$</li>
</ol>', N'<p><b>a)</b> Từ phương trình thứ nhất $x=y+3$. Thế vào phương trình thứ hai: $3(y+3)-4y=2$ hay $-y+9=2$, suy ra $y=7$, $x=10$.</p>
<p><b>b)</b> Từ phương trình thứ hai $y=2-4x$. Thế vào phương trình thứ nhất: $7x-3(2-4x)=13$ hay $19x-6=13$, suy ra $x=1$, $y=-2$.</p>
<p><b>c)</b> Từ phương trình thứ nhất $x=2+3y$. Thế vào phương trình thứ hai: $-(2+3y)+3y=2$ hay $-2=2$, vô lí. Hệ vô nghiệm.</p>
<p><b>Đáp số:</b> a) $(10;7)$. b) $(1;-2)$. c) vô nghiệm.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.7.</b> Giải các hệ phương trình sau bằng phương pháp cộng đại số:</p>
<ol type="a">
<li>$\begin{cases}3x+2y=6\\ 2x-2y=14;\end{cases}$</li>
<li>$\begin{cases}0{,}3x+0{,}5y=3\\ 1{,}5x-2y=1{,}5;\end{cases}$</li>
<li>$\begin{cases}-2x+6y=8\\ 3x-9y=-12.\end{cases}$</li>
</ol>', N'<p><b>a)</b> Cộng từng vế: $5x=20$, $x=4$. Thế vào $3x+2y=6$: $12+2y=6$, $y=-3$.</p>
<p><b>b)</b> Nhân phương trình thứ nhất với 10 và phương trình thứ hai với 2: $\begin{cases}3x+5y=30\\ 3x-4y=3.\end{cases}$ Trừ từng vế: $9y=27$, $y=3$; thay vào $3x+5y=30$ được $x=5$.</p>
<p><b>c)</b> Nhân phương trình thứ nhất với 3 và phương trình thứ hai với 2: $\begin{cases}-6x+18y=24\\ 6x-18y=-24.\end{cases}$ Cộng từng vế được $0x+0y=0$ luôn đúng. Từ $-2x+6y=8$ suy ra $y=\dfrac{x+4}{3}$; hệ có vô số nghiệm $\left(x;\dfrac{x+4}{3}\right)$ với $x\in\mathbb{R}$.</p>
<p><b>Đáp số:</b> a) $(4;-3)$. b) $(5;3)$. c) vô số nghiệm $\left(x;\dfrac{x+4}{3}\right)$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.8.</b> Cho hệ phương trình $\begin{cases}2x-y=-3\\ -2m^2x+9y=3(m+3),\end{cases}$ trong đó $m$ là số đã cho. Giải hệ phương trình trong mỗi trường hợp sau:</p>
<ol type="a">
<li>$m=-2$;</li>
<li>$m=-3$;</li>
<li>$m=3$.</li>
</ol>', N'<p>Từ phương trình thứ nhất $y=2x+3$. Thế vào phương trình thứ hai: $-2m^2x+9(2x+3)=3(m+3)$ hay $(18-2m^2)x=3m-18$. (*)</p>
<p><b>a)</b> $m=-2$: (*) thành $10x=-24$, $x=-\dfrac{12}{5}$, $y=2\cdot\left(-\dfrac{12}{5}\right)+3=-\dfrac{9}{5}$.</p>
<p><b>b)</b> $m=-3$: (*) thành $0x=-27$, vô lí. Hệ vô nghiệm.</p>
<p><b>c)</b> $m=3$: (*) thành $0x=-9$, vô lí. Hệ vô nghiệm.</p>
<p><b>Đáp số:</b> a) $\left(-\dfrac{12}{5};-\dfrac{9}{5}\right)$. b) vô nghiệm. c) vô nghiệm.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.9.</b> Dùng máy tính cầm tay thích hợp để tìm nghiệm của các hệ phương trình sau:</p>
<ol type="a">
<li>$\begin{cases}12x-5y+24=0\\ -5x-3y-10=0;\end{cases}$</li>
<li>$\begin{cases}\dfrac{1}{3}x-y=\dfrac{2}{3}\\ x-3y=2;\end{cases}$</li>
<li>$\begin{cases}3x-2y=1\\ -x+\dfrac{2}{3}y=0;\end{cases}$</li>
<li>$\begin{cases}\dfrac{4}{9}x-\dfrac{3}{5}y=11\\ \dfrac{2}{9}x+\dfrac{1}{5}y=-2.\end{cases}$</li>
</ol>', N'<p><b>a)</b> Viết lại $\begin{cases}12x-5y=-24\\ -5x-3y=10.\end{cases}$ Nhập $12,-5,-24,-5,-3,10$ được $x=-2$, $y=0$. Kiểm tra: $12\cdot(-2)+24=0$; $-5\cdot(-2)-10=0$.</p>
<p><b>b)</b> Nhân phương trình thứ nhất với 3 được $x-3y=2$, trùng với phương trình thứ hai. Máy báo "Infinite Sol": hệ có vô số nghiệm $\left(x;\dfrac{x-2}{3}\right)$.</p>
<p><b>c)</b> Từ phương trình thứ hai $y=\dfrac{3}{2}x$; thế vào phương trình thứ nhất được $3x-3x=1$ hay $0=1$. Máy báo "No-Solution": hệ vô nghiệm.</p>
<p><b>d)</b> Nhân phương trình thứ hai với 3 rồi cộng với phương trình thứ nhất: $\dfrac{10}{9}x=5$, $x=\dfrac{9}{2}$; thay vào phương trình thứ hai: $1+\dfrac{y}{5}=-2$, $y=-15$.</p>
<p><b>Đáp số:</b> a) $(-2;0)$. b) vô số nghiệm. c) vô nghiệm. d) $\left(\dfrac{9}{2};-15\right)$.</p>', 2, 0, 1, @t1);

-- Luyện tập chung (Bài 1 - Bài 2)
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Luyện tập chung (Chương I)', N'Rèn luyện giải hệ phương trình bậc nhất hai ẩn có hệ số thập phân, cân bằng phản ứng hóa học và tìm đường thẳng đi qua hai điểm.', N'<p><b>Ví dụ 1.</b> Giải hệ $\begin{cases}0{,}5x+0{,}6y=0{,}4\\ 0{,}4x-0{,}9y=1{,}7.\end{cases}$ Nhân hai vế của mỗi phương trình với 10: $\begin{cases}5x+6y=4\\ 4x-9y=17.\end{cases}$ Nhân phương trình thứ nhất với 3, phương trình thứ hai với 2: $\begin{cases}15x+18y=12\\ 8x-18y=34.\end{cases}$ Cộng từng vế: $23x=46$, $x=2$; thế vào $5x+6y=4$ được $y=-1$. Nghiệm $(2;-1)$.</p>
<p><b>Ví dụ 2 (cân bằng phản ứng hóa học).</b> Tìm $x,y$ để $3\mathrm{Fe}+x\mathrm{O}_2\to y\mathrm{Fe}_3\mathrm{O}_4$ cân bằng. Số nguyên tử Fe và O ở hai vế phải bằng nhau nên $\begin{cases}3=3y\\ 2x=4y,\end{cases}$ suy ra $y=1$, $x=2$.</p>
<p><b>Ví dụ 3.</b> Tìm $a,b$ để đường thẳng $y=ax+b$ đi qua $A(-2;-1)$ và $B(2;3)$. Đường thẳng đi qua $A$ nên $-2a+b=-1$; đi qua $B$ nên $2a+b=3$. Cộng từng vế: $2b=2$, $b=1$; thay vào được $a=1$. Vậy $a=1,\ b=1$.</p>', 3, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.10.</b> Cho hai phương trình $$-2x+5y=7;\quad (1)$$ $$4x-3y=7.\quad (2)$$ Trong các cặp số $(2;0),\ (1;-1),\ (-1;1),\ (-1;6),\ (4;3)$ và $(-2;-5)$, cặp số nào là:</p>
<ol type="a">
<li>Nghiệm của phương trình (1)?</li>
<li>Nghiệm của phương trình (2)?</li>
<li>Nghiệm của hệ gồm phương trình (1) và phương trình (2)?</li>
</ol>', N'<p>Tính giá trị hai vế trái:</p>
<table border="1"><tr><th>Cặp số</th><td>$(2;0)$</td><td>$(1;-1)$</td><td>$(-1;1)$</td><td>$(-1;6)$</td><td>$(4;3)$</td><td>$(-2;-5)$</td></tr><tr><th>$-2x+5y$</th><td>$-4$</td><td>$-7$</td><td>$7$</td><td>$32$</td><td>$7$</td><td>$-21$</td></tr><tr><th>$4x-3y$</th><td>$8$</td><td>$7$</td><td>$-7$</td><td>$-22$</td><td>$7$</td><td>$7$</td></tr></table>
<p><b>a)</b> Nghiệm của (1) (vế trái bằng 7): $(-1;1)$ và $(4;3)$.</p>
<p><b>b)</b> Nghiệm của (2): $(1;-1)$, $(4;3)$ và $(-2;-5)$.</p>
<p><b>c)</b> Nghiệm chung của hai phương trình: $(4;3)$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.11.</b> Giải các hệ phương trình sau bằng phương pháp thế:</p>
<ol type="a">
<li>$\begin{cases}2x-y=1\\ x-2y=-1;\end{cases}$</li>
<li>$\begin{cases}0{,}5x-0{,}5y=0{,}5\\ 1{,}2x-1{,}2y=1{,}2;\end{cases}$</li>
<li>$\begin{cases}x+3y=-2\\ 5x-4y=28.\end{cases}$</li>
</ol>', N'<p><b>a)</b> $y=2x-1$. Thế vào phương trình thứ hai: $x-2(2x-1)=-1$ hay $-3x+2=-1$, $x=1$, $y=1$.</p>
<p><b>b)</b> Phương trình thứ nhất tương đương $x-y=1$, phương trình thứ hai cũng tương đương $x-y=1$. Từ $x=y+1$ thế vào phương trình thứ hai được $0y=0$. Hệ có vô số nghiệm $(x;x-1)$ với $x\in\mathbb{R}$.</p>
<p><b>c)</b> $x=-2-3y$. Thế vào phương trình thứ hai: $5(-2-3y)-4y=28$ hay $-19y=38$, $y=-2$, $x=4$.</p>
<p><b>Đáp số:</b> a) $(1;1)$. b) vô số nghiệm $(x;x-1)$. c) $(4;-2)$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.12.</b> Giải các hệ phương trình sau bằng phương pháp cộng đại số:</p>
<ol type="a">
<li>$\begin{cases}5x+7y=-1\\ 3x+2y=-5;\end{cases}$</li>
<li>$\begin{cases}2x-3y=11\\ -0{,}8x+1{,}2y=1;\end{cases}$</li>
<li>$\begin{cases}4x-3y=6\\ 0{,}4x+0{,}2y=0{,}8.\end{cases}$</li>
</ol>', N'<p><b>a)</b> Nhân phương trình thứ nhất với 2, phương trình thứ hai với 7: $\begin{cases}10x+14y=-2\\ 21x+14y=-35.\end{cases}$ Trừ từng vế: $11x=-33$, $x=-3$; thay vào $3x+2y=-5$: $y=2$.</p>
<p><b>b)</b> Nhân phương trình thứ hai với $\dfrac{5}{2}$: $-2x+3y=\dfrac{5}{2}$. Cộng với phương trình thứ nhất: $0=11+\dfrac{5}{2}$, vô lí. Hệ vô nghiệm.</p>
<p><b>c)</b> Nhân phương trình thứ hai với 10: $4x+2y=8$. Trừ từng vế phương trình thứ nhất cho phương trình này: $-5y=-2$, $y=\dfrac{2}{5}$; thay vào $4x+2y=8$: $x=\dfrac{9}{5}$.</p>
<p><b>Đáp số:</b> a) $(-3;2)$. b) vô nghiệm. c) $\left(\dfrac{9}{5};\dfrac{2}{5}\right)$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.13.</b> Tìm các hệ số $x,\ y$ trong phản ứng hóa học đã được cân bằng sau: $$4\mathrm{Al}+x\mathrm{O}_2\to y\mathrm{Al}_2\mathrm{O}_3.$$</p>', N'<p>Số nguyên tử Al ở hai vế bằng nhau: $4=2y$, suy ra $y=2$. Số nguyên tử O ở hai vế bằng nhau: $2x=3y$, suy ra $x=3$.</p>
<p><b>Đáp số:</b> $x=3,\ y=2$ (phản ứng $4\mathrm{Al}+3\mathrm{O}_2\to2\mathrm{Al}_2\mathrm{O}_3$).</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.14.</b> Tìm $a$ và $b$ sao cho hệ phương trình $\begin{cases}ax+by=1\\ ax+(2-b)y=3\end{cases}$ có nghiệm là $(1;-2)$.</p>', N'<p>Thay $x=1,\ y=-2$ vào hai phương trình: $\begin{cases}a-2b=1\\ a-2(2-b)=3,\end{cases}$ tức $\begin{cases}a-2b=1\\ a+2b=7.\end{cases}$</p>
<p>Cộng từng vế: $2a=8$, $a=4$. Thay vào $a-2b=1$: $b=\dfrac{3}{2}$.</p>
<p><b>Đáp số:</b> $a=4,\ b=\dfrac{3}{2}$.</p>', 2, 0, 1, @t1);

-- Bài 3
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 3. Giải bài toán bằng cách lập hệ phương trình', N'Các bước giải bài toán bằng cách lập hệ hai phương trình bậc nhất hai ẩn: tìm số, chuyển động, năng suất, hóa học.', N'<p><b>Các bước giải một bài toán bằng cách lập hệ phương trình:</b></p>
<ol>
<li><i>Bước 1. Lập hệ phương trình:</i> chọn ẩn số (thường chọn hai ẩn) và đặt điều kiện thích hợp; biểu diễn các đại lượng chưa biết theo ẩn và các đại lượng đã biết; lập hệ phương trình biểu thị mối quan hệ giữa các đại lượng.</li>
<li><i>Bước 2. Giải hệ phương trình.</i></li>
<li><i>Bước 3. Trả lời:</i> kiểm tra xem trong các nghiệm tìm được của hệ, nghiệm nào thỏa mãn, nghiệm nào không thỏa mãn điều kiện của ẩn rồi kết luận.</li>
</ol>
<p><b>Bài toán mở đầu.</b> Vật có khối lượng 124 g, thể tích 15 cm³ là hợp kim của đồng và kẽm; 1 cm³ đồng nặng 8,9 g, 1 cm³ kẽm nặng 7 g. Gọi $x,y$ là số gam đồng, kẽm: khối lượng $x+y=124$; thể tích $\dfrac{x}{8{,}9}+\dfrac{y}{7}=15$.</p>
<p><b>Ví dụ 1.</b> Tìm hai số tự nhiên có tổng bằng 1 006, biết rằng nếu lấy số lớn chia cho số nhỏ thì được thương là 2 và số dư là 124. Gọi hai số là $xt y$ (điều kiện $124t xt y$). Ta có $\begin{cases}x+y=1006\\ y=2x+124.\end{cases}$ Thế $y$ vào phương trình thứ nhất: $3x+124=1006$, $x=294$, $y=712$ (thỏa mãn). Vậy hai số cần tìm là 294 và 712.</p>
<p><b>Ví dụ 2 (năng suất).</b> Hai đội công nhân cùng làm một đoạn đường trong 24 ngày thì xong. Mỗi ngày đội I làm được nhiều gấp rưỡi đội II. Hỏi mỗi đội làm một mình thì xong trong bao lâu? Gọi $x,y$ là số ngày đội I, đội II làm xong một mình ($x,y>0$). Mỗi ngày hai đội làm được $\dfrac{1}{x}$ và $\dfrac{1}{y}$ công việc, nên $\dfrac{1}{x}=\dfrac{3}{2}\cdot\dfrac{1}{y}$ và $\dfrac{1}{x}+\dfrac{1}{y}=\dfrac{1}{24}$. Đặt $u=\dfrac{1}{x},\ v=\dfrac{1}{y}$ được $\begin{cases}u=\dfrac{3}{2}v\\ u+v=\dfrac{1}{24}\end{cases}$ suy ra $v=\dfrac{1}{60},\ u=\dfrac{1}{40}$. Vậy $x=40$ ngày, $y=60$ ngày.</p>', 4, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.15.</b> Tìm số tự nhiên $n$ có hai chữ số, biết rằng tổng của hai chữ số đó bằng 12, và nếu viết hai chữ số đó theo thứ tự ngược lại thì được một số lớn hơn $n$ là 36 đơn vị.</p>', N'<p>Gọi chữ số hàng chục là $a$, hàng đơn vị là $b$ ($a,b\in\mathbb{N}$, $1\le a\le9$, $0\le b\le9$), $n=10a+b$.</p>
<p>Tổng hai chữ số bằng 12: $a+b=12$. Số viết ngược là $10b+a$ lớn hơn $n$ là 36: $(10b+a)-(10a+b)=36$ hay $b-a=4$.</p>
<p>Hệ $\begin{cases}a+b=12\\ b-a=4\end{cases}$ cho $b=8,\ a=4$ (thỏa mãn điều kiện).</p>
<p><b>Đáp số:</b> $n=48$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.16.</b> Điểm số trung bình của một vận động viên bắn súng sau 100 lần bắn là 8,69 điểm. Kết quả cụ thể được ghi trong bảng sau, trong đó có hai ô bị mờ không đọc được (đánh dấu "?"):</p>
<table border="1"><tr><th>Điểm số của mỗi lần bắn</th><td>10</td><td>9</td><td>8</td><td>7</td><td>6</td></tr><tr><th>Số lần bắn</th><td>25</td><td>42</td><td>?</td><td>15</td><td>?</td></tr></table>
<p>Em hãy tìm lại các số bị mờ trong hai ô đó.</p>', N'<p>Gọi $x$ là số lần bắn được 8 điểm, $y$ là số lần bắn được 6 điểm ($x,y\in\mathbb{N}$).</p>
<p>Tổng số lần bắn: $25+42+x+15+y=100$ hay $x+y=18$.</p>
<p>Tổng điểm: $10\cdot25+9\cdot42+8x+7\cdot15+6y=8{,}69\cdot100=869$, tức $733+8x+6y=869$ hay $4x+3y=68$.</p>
<p>Từ $x=18-y$ thế vào: $72-4y+3y=68$, suy ra $y=4$, $x=14$ (thỏa mãn).</p>
<p><b>Đáp số:</b> 14 lần bắn được 8 điểm và 4 lần bắn được 6 điểm.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.17.</b> Năm ngoái, hai đơn vị sản xuất nông nghiệp thu hoạch được 3 600 tấn thóc. Năm nay, hai đơn vị thu hoạch được 4 095 tấn thóc. Hỏi năm nay, mỗi đơn vị thu hoạch được bao nhiêu tấn thóc, biết rằng năm nay, đơn vị thứ nhất làm vượt mức 15%, đơn vị thứ hai làm vượt mức 12% so với năm ngoái?</p>
<p>Hãy dùng máy tính cầm tay để kiểm tra lại kết quả thu được.</p>', N'<p>Gọi $x,y$ (tấn) là số thóc năm ngoái của đơn vị thứ nhất, thứ hai ($x,y>0$). Ta có $x+y=3600$.</p>
<p>Năm nay đơn vị thứ nhất thu được $1{,}15x$, đơn vị thứ hai thu được $1{,}12y$ nên $1{,}15x+1{,}12y=4095$.</p>
<p>Thế $y=3600-x$: $1{,}15x+4032-1{,}12x=4095$ hay $0{,}03x=63$, $x=2100$, $y=1500$ (thỏa mãn).</p>
<p>Năm nay: đơn vị thứ nhất $1{,}15\cdot2100=2415$ tấn; đơn vị thứ hai $1{,}12\cdot1500=1680$ tấn (tổng $4095$ tấn).</p>
<p><b>Đáp số:</b> 2 415 tấn và 1 680 tấn.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.18.</b> Hai người thợ cùng làm một công việc trong 16 giờ thì xong. Nếu người thứ nhất làm trong 3 giờ và người thứ hai làm trong 6 giờ thì chỉ hoàn thành được 25% công việc. Hỏi nếu làm riêng thì mỗi người hoàn thành công việc trong bao lâu?</p>', N'<p>Gọi $x,y$ (giờ) là thời gian người thứ nhất, người thứ hai làm một mình xong công việc ($x,y>0$). Mỗi giờ họ làm được $\dfrac{1}{x}$ và $\dfrac{1}{y}$ công việc.</p>
<p>Làm chung 16 giờ xong: $16\left(\dfrac{1}{x}+\dfrac{1}{y}\right)=1$. Làm 3 giờ và 6 giờ được 25%: $\dfrac{3}{x}+\dfrac{6}{y}=\dfrac{1}{4}$.</p>
<p>Đặt $u=\dfrac{1}{x},\ v=\dfrac{1}{y}$: $\begin{cases}u+v=\dfrac{1}{16}\\ 3u+6v=\dfrac{1}{4}.\end{cases}$ Thế $u=\dfrac{1}{16}-v$: $\dfrac{3}{16}+3v=\dfrac{1}{4}$, $v=\dfrac{1}{48}$, $u=\dfrac{1}{24}$.</p>
<p>Suy ra $x=24,\ y=48$ (thỏa mãn).</p>
<p><b>Đáp số:</b> người thứ nhất làm một mình trong 24 giờ, người thứ hai làm một mình trong 48 giờ.</p>', 3, 0, 1, @t1);

-- Bài tập cuối chương I
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài tập cuối chương I', N'Ôn tập chương I: nghiệm của phương trình, hệ phương trình bậc nhất hai ẩn và các bài toán giải bằng cách lập hệ phương trình.', N'<p><b>Tóm tắt kiến thức chương I.</b></p>
<ul>
<li>Phương trình bậc nhất hai ẩn $ax+by=c$ ($a\neq0$ hoặc $b\neq0$) luôn có vô số nghiệm; tập nghiệm là một đường thẳng trên mặt phẳng tọa độ.</li>
<li>Hệ hai phương trình bậc nhất hai ẩn $\begin{cases}ax+by=c\\ a''x+b''y=c''\end{cases}$ có thể có một nghiệm duy nhất (hai đường thẳng cắt nhau), vô nghiệm (hai đường thẳng song song) hoặc vô số nghiệm (hai đường thẳng trùng nhau).</li>
<li>Giải hệ bằng <b>phương pháp thế</b>, <b>phương pháp cộng đại số</b> hoặc máy tính cầm tay.</li>
<li>Giải bài toán bằng cách lập hệ phương trình: chọn ẩn và đặt điều kiện, lập hệ, giải hệ, đối chiếu điều kiện rồi trả lời.</li>
</ul>
<p><b>Mẹo nhận biết số nghiệm.</b> Nếu đưa hai phương trình về dạng $y=mx+n$ mà hệ số góc khác nhau thì hệ có nghiệm duy nhất; hệ số góc bằng nhau nhưng tung độ gốc khác nhau thì hệ vô nghiệm; hệ số góc và tung độ gốc đều bằng nhau thì hệ có vô số nghiệm.</p>', 5, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 1.19.</b> Cặp số nào sau đây là nghiệm của hệ phương trình $\begin{cases}5x+7y=-1\\ 3x+2y=-5\end{cases}$ ?</p>', N'<p>Thay $(-3;2)$: $5\cdot(-3)+7\cdot2=-15+14=-1$ và $3\cdot(-3)+2\cdot2=-9+4=-5$, đều đúng. Các cặp còn lại không thỏa mãn: $(-1;1)$ cho $5\cdot(-1)+7\cdot1=2\neq-1$; $(2;-3)$ cho $5\cdot2+7\cdot(-3)=-11\neq-1$; $(5;5)$ cho $60\neq-1$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$(-1;1)$.', 0),
(@q, 'B', N'$(-3;2)$.', 1),
(@q, 'C', N'$(2;-3)$.', 0),
(@q, 'D', N'$(5;5)$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 1.20.</b> Trên mặt phẳng tọa độ $Oxy$, cho các điểm $A(1;2),\ B(5;6),\ C(2;3),\ D(-1;-1)$. Đường thẳng $4x-3y=-1$ đi qua hai điểm nào trong các điểm đã cho?</p>', N'<p>Tính $4x-3y$ tại từng điểm: $A:\ 4-6=-2$; $B:\ 20-18=2$; $C:\ 8-9=-1$; $D:\ -4+3=-1$. Chỉ $C$ và $D$ cho kết quả $-1$ nên đường thẳng đi qua $C$ và $D$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$A$ và $B$.', 0),
(@q, 'B', N'$B$ và $C$.', 0),
(@q, 'C', N'$C$ và $D$.', 1),
(@q, 'D', N'$D$ và $A$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 1.21.</b> Hệ phương trình $\begin{cases}1{,}5x-0{,}6y=0{,}3\\ -2x+y=-2\end{cases}$</p>', N'<p>Từ phương trình thứ hai $y=2x-2$. Thế vào phương trình thứ nhất: $1{,}5x-0{,}6(2x-2)=0{,}3$ hay $0{,}3x+1{,}2=0{,}3$, suy ra $x=-3$, $y=-8$. Hệ có nghiệm duy nhất $(-3;-8)$.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'có nghiệm là $(0;-0{,}5)$.', 0),
(@q, 'B', N'có nghiệm là $(1;0)$.', 0),
(@q, 'C', N'có nghiệm là $(-3;-8)$.', 1),
(@q, 'D', N'vô nghiệm.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 1.22.</b> Hệ phương trình $\begin{cases}0{,}6x+0{,}3y=1{,}8\\ 2x+y=-6\end{cases}$</p>', N'<p>Nhân hai vế phương trình thứ nhất với $\dfrac{10}{3}$ được $2x+y=6$. Hệ trở thành $\begin{cases}2x+y=6\\ 2x+y=-6,\end{cases}$ vô lí vì $6\neq-6$. Hai đường thẳng song song nên hệ vô nghiệm.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'có một nghiệm.', 0),
(@q, 'B', N'vô nghiệm.', 1),
(@q, 'C', N'có vô số nghiệm.', 0),
(@q, 'D', N'có hai nghiệm.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.23.</b> Giải các hệ phương trình:</p>
<ol type="a">
<li>$\begin{cases}2x+5y=10\\ \dfrac{2}{5}x+y=1;\end{cases}$</li>
<li>$\begin{cases}0{,}2x+0{,}1y=0{,}3\\ 3x+y=5;\end{cases}$</li>
<li>$\begin{cases}\dfrac{3}{2}x-y=\dfrac{1}{2}\\ 6x-4y=2.\end{cases}$</li>
</ol>', N'<p><b>a)</b> Nhân phương trình thứ hai với 5: $2x+5y=5$. Trừ từng vế với phương trình thứ nhất: $0=5$, vô lí. Hệ vô nghiệm.</p>
<p><b>b)</b> Nhân phương trình thứ nhất với 10: $2x+y=3$. Trừ từng vế cho phương trình thứ hai $3x+y=5$: $x=2$; thay vào $2x+y=3$: $y=-1$.</p>
<p><b>c)</b> Nhân phương trình thứ nhất với 4: $6x-4y=2$, trùng với phương trình thứ hai. Hệ có vô số nghiệm $\left(x;\dfrac{3x-1}{2}\right)$ với $x\in\mathbb{R}$.</p>
<p><b>Đáp số:</b> a) vô nghiệm. b) $(2;-1)$. c) vô số nghiệm $\left(x;\dfrac{3x-1}{2}\right)$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.24.</b> Giải các hệ phương trình:</p>
<ol type="a">
<li>$\begin{cases}0{,}5x+2y=-2{,}5\\ 0{,}7x-3y=8{,}1;\end{cases}$</li>
<li>$\begin{cases}5x-3y=-2\\ 14x+8y=19;\end{cases}$</li>
<li>$\begin{cases}2(x-2)+3(1+y)=-2\\ 3(x-2)-2(1+y)=-3.\end{cases}$</li>
</ol>', N'<p><b>a)</b> Nhân hai vế mỗi phương trình với 10: $\begin{cases}5x+20y=-25\\ 7x-30y=81\end{cases}$ hay $\begin{cases}x+4y=-5\\ 7x-30y=81.\end{cases}$ Thế $x=-5-4y$: $-35-28y-30y=81$, $y=-2$, $x=3$.</p>
<p><b>b)</b> Nhân phương trình thứ nhất với 8, phương trình thứ hai với 3: $\begin{cases}40x-24y=-16\\ 42x+24y=57.\end{cases}$ Cộng từng vế: $82x=41$, $x=\dfrac{1}{2}$; thay vào $5x-3y=-2$: $y=\dfrac{3}{2}$.</p>
<p><b>c)</b> Đặt $u=x-2,\ v=1+y$: $\begin{cases}2u+3v=-2\\ 3u-2v=-3.\end{cases}$ Nhân với 2 và 3 rồi cộng: $13u=-13$, $u=-1$, $v=0$. Suy ra $x=1,\ y=-1$.</p>
<p><b>Đáp số:</b> a) $(3;-2)$. b) $\left(\dfrac{1}{2};\dfrac{3}{2}\right)$. c) $(1;-1)$.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.25.</b> Tìm số tự nhiên $n$ có hai chữ số, biết rằng nếu viết thêm chữ số 3 vào giữa hai chữ số của số $n$ thì được một số lớn hơn số $2n$ là 585 đơn vị, và nếu viết hai chữ số của số $n$ theo thứ tự ngược lại thì được một số nhỏ hơn số $n$ là 18 đơn vị.</p>', N'<p>Gọi chữ số hàng chục là $a$, hàng đơn vị là $b$; $n=10a+b$.</p>
<p>Viết thêm chữ số 3 vào giữa được số $\overline{a3b}=100a+30+b$; số này lớn hơn $2n$ là 585: $100a+30+b=2(10a+b)+585$ hay $80a-b=555$.</p>
<p>Viết ngược được $10b+a$, nhỏ hơn $n$ là 18: $(10a+b)-(10b+a)=18$ hay $a-b=2$.</p>
<p>Từ $a=b+2$ thế vào $80a-b=555$: $79b+160=555$, $b=5$, $a=7$ (thỏa mãn).</p>
<p><b>Đáp số:</b> $n=75$.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.26.</b> Trên cánh đồng có diện tích 160 ha của một đơn vị sản xuất, người ta dành 60 ha để cấy thí điểm giống lúa mới, còn lại vẫn cấy giống lúa cũ. Khi thu hoạch, đầu tiên người ta gặt 8 ha giống lúa cũ và 7 ha giống lúa mới để đối chứng. Kết quả là 7 ha giống lúa mới cho thu hoạch nhiều hơn 8 ha giống lúa cũ là 2 tấn thóc. Biết rằng tổng số thóc (cả hai giống) thu hoạch cả vụ trên 160 ha là 860 tấn. Hỏi năng suất của mỗi giống lúa trên 1 ha là bao nhiêu tấn thóc?</p>', N'<p>Gọi $x,y$ (tấn/ha) là năng suất giống lúa cũ, giống lúa mới ($x,y>0$).</p>
<p>7 ha lúa mới hơn 8 ha lúa cũ là 2 tấn: $7y-8x=2$. Cả vụ: 100 ha lúa cũ và 60 ha lúa mới thu 860 tấn: $100x+60y=860$ hay $5x+3y=43$.</p>
<p>Từ phương trình thứ nhất $y=\dfrac{8x+2}{7}$; thế vào $5x+3y=43$: $35x+24x+6=301$, $59x=295$, $x=5$, $y=6$ (thỏa mãn).</p>
<p><b>Đáp số:</b> giống lúa cũ 5 tấn/ha, giống lúa mới 6 tấn/ha.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.27.</b> Hai vật chuyển động đều trên một đường tròn đường kính 20 cm, xuất phát cùng một lúc, từ cùng một điểm. Nếu chuyển động ngược chiều thì cứ sau 4 giây chúng lại gặp nhau. Nếu chuyển động cùng chiều thì cứ sau 20 giây chúng lại gặp nhau. Tính vận tốc (cm/s) của mỗi vật.</p>', N'<p>Chu vi đường tròn: $\pi\cdot20=20\pi$ (cm). Gọi $x,y$ (cm/s) là vận tốc hai vật, $x>y>0$.</p>
<p>Chuyển động ngược chiều, sau 4 giây gặp nhau: tổng quãng đường bằng một vòng nên $4(x+y)=20\pi$ hay $x+y=5\pi$.</p>
<p>Chuyển động cùng chiều, sau 20 giây gặp nhau: vật nhanh hơn đi nhiều hơn đúng một vòng nên $20(x-y)=20\pi$ hay $x-y=\pi$.</p>
<p>Cộng từng vế: $2x=6\pi$, $x=3\pi$; $y=2\pi$ (thỏa mãn).</p>
<p><b>Đáp số:</b> $3\pi$ cm/s (khoảng 9,42 cm/s) và $2\pi$ cm/s (khoảng 6,28 cm/s).</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 1.28.</b> Một người mua hai loại hàng và phải trả tổng cộng là 21,7 triệu đồng, kể cả thuế giá trị gia tăng (VAT) với mức 10% đối với loại hàng thứ nhất và 8% đối với loại hàng thứ hai. Nếu thuế VAT là 9% đối với cả hai loại hàng thì người đó phải trả tổng cộng 21,8 triệu đồng. Hỏi nếu không kể thuế VAT thì người đó phải trả bao nhiêu tiền cho mỗi loại hàng?</p>', N'<p>Gọi $x,y$ (triệu đồng) là giá tiền hai loại hàng chưa kể VAT ($x,y>0$).</p>
<p>Lần đầu: $1{,}1x+1{,}08y=21{,}7$. Lần sau: $1{,}09(x+y)=21{,}8$ nên $x+y=20$.</p>
<p>Thế $y=20-x$: $1{,}1x+21{,}6-1{,}08x=21{,}7$ hay $0{,}02x=0{,}1$, $x=5$, $y=15$ (thỏa mãn).</p>
<p><b>Đáp số:</b> loại hàng thứ nhất 5 triệu đồng, loại hàng thứ hai 15 triệu đồng (chưa kể VAT).</p>', 3, 0, 1, @t1);

-- (Các chương II - X sẽ được bổ sung ở các phần tiếp theo, trước dòng COMMIT bên dưới.)

COMMIT TRANSACTION;

SELECT t.TopicName, COUNT(DISTINCT l.LessonId) AS Lessons, COUNT(q.QuestionId) AS Questions
FROM Topics t LEFT JOIN Lessons l ON l.TopicId = t.TopicId LEFT JOIN Questions q ON q.LessonId = l.LessonId
GROUP BY t.TopicId, t.TopicName, t.OrderIndex ORDER BY t.OrderIndex;
GO
