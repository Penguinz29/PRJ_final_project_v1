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
-- Đề có hình vẽ trong SGK được gắn ảnh cắt từ sách: thẻ <img src="/static/img/sgk9/..."> (thư mục src/main/webapp/static/img/sgk9); cần triển khai lại WAR kèm thư mục ảnh.
-- Nội dung đã nạp: Tập 1 — Chương I-V; Tập 2 — Chương VI-X (chưa gồm phần Hoạt động thực hành trải nghiệm và Bài tập ôn tập cuối năm).
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

-- ---------------------------------------------------------------------------------------------------------------------
-- Chương II. Phương trình và bất phương trình bậc nhất một ẩn
-- ---------------------------------------------------------------------------------------------------------------------
INSERT INTO Topics (TopicName, [Description], TeacherId, OrderIndex, IsActive) VALUES (N'Chương II. Phương trình và bất phương trình bậc nhất một ẩn', N'Phương trình quy về phương trình bậc nhất một ẩn (phương trình tích, phương trình chứa ẩn ở mẫu), bất đẳng thức và tính chất, bất phương trình bậc nhất một ẩn. (SGK Toán 9 Kết nối tri thức với cuộc sống, Tập 1)', @t1, 2, 1);
SET @tp = SCOPE_IDENTITY();

-- Bài 4
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 4. Phương trình quy về phương trình bậc nhất một ẩn', N'Giải phương trình tích dạng (ax + b)(cx + d) = 0 và phương trình chứa ẩn ở mẫu quy về phương trình bậc nhất.', N'<p><b>1. Phương trình tích.</b> Để giải phương trình tích $(ax+b)(cx+d)=0$, ta giải hai phương trình $ax+b=0$ và $cx+d=0$, sau đó lấy tất cả các nghiệm của chúng.</p>
<p><b>Ví dụ 1.</b> Giải $(2x+1)(3x-1)=0$. Ta có $2x+1=0$ suy ra $x=-\dfrac{1}{2}$; $3x-1=0$ suy ra $x=\dfrac{1}{3}$. Phương trình có hai nghiệm $x=-\dfrac{1}{2}$ và $x=\dfrac{1}{3}$.</p>
<p><b>Ví dụ 2.</b> Giải $x^2-x=-2x+2$. Biến đổi: $x^2-x+2x-2=0$, $x(x-1)+2(x-1)=0$, $(x+2)(x-1)=0$. Suy ra $x=-2$ hoặc $x=1$.</p>
<p><b>Nhận xét.</b> Giải phương trình theo hai bước: <i>Bước 1.</i> Đưa phương trình về dạng phương trình tích $(ax+b)(cx+d)=0$ (chuyển vế, phân tích đa thức thành nhân tử). <i>Bước 2.</i> Giải phương trình tích tìm được.</p>
<p><b>2. Phương trình chứa ẩn ở mẫu.</b> Với phương trình chứa ẩn ở mẫu, ta thường đặt điều kiện cho ẩn để tất cả các mẫu thức trong phương trình đều khác 0; đó là <b>điều kiện xác định</b> (ĐKXĐ) của phương trình.</p>
<p><b>Ví dụ 3.</b> ĐKXĐ của $\dfrac{5x+2}{x-1}=0$ là $x\neq1$. ĐKXĐ của $\dfrac{1}{x+1}=1+\dfrac{1}{x-2}$ là $x\neq-1$ và $x\neq2$.</p>
<p><b>Các bước giải phương trình chứa ẩn ở mẫu:</b></p>
<ol>
<li><i>Bước 1.</i> Tìm điều kiện xác định của phương trình.</li>
<li><i>Bước 2.</i> Quy đồng mẫu hai vế của phương trình rồi khử mẫu.</li>
<li><i>Bước 3.</i> Giải phương trình vừa tìm được.</li>
<li><i>Bước 4 (kết luận).</i> Trong các giá trị tìm được của ẩn ở Bước 3, giá trị nào thỏa mãn điều kiện xác định chính là nghiệm của phương trình đã cho.</li>
</ol>
<p><b>Ví dụ 4.</b> Giải $\dfrac{2}{x+1}+\dfrac{1}{x-2}=\dfrac{3}{(x+1)(x-2)}$. ĐKXĐ: $x\neq-1$ và $x\neq2$. Quy đồng mẫu và khử mẫu: $2(x-2)+(x+1)=3$, suy ra $3x-3=3$, $x=2$. Giá trị $x=2$ không thỏa mãn ĐKXĐ nên phương trình <b>vô nghiệm</b>.</p>', 1, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.1.</b> Giải các phương trình sau:</p>
<ol type="a">
<li>$x(x-2)=0$;</li>
<li>$(2x+1)(3x-2)=0$.</li>
</ol>', N'<p><b>a)</b> $x=0$ hoặc $x-2=0$, tức $x=0$ hoặc $x=2$.</p>
<p><b>b)</b> $2x+1=0$ suy ra $x=-\dfrac{1}{2}$; $3x-2=0$ suy ra $x=\dfrac{2}{3}$.</p>
<p><b>Đáp số:</b> a) $x=0$; $x=2$. b) $x=-\dfrac{1}{2}$; $x=\dfrac{2}{3}$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.2.</b> Giải các phương trình sau:</p>
<ol type="a">
<li>$(x^2-4)+x(x-2)=0$;</li>
<li>$(2x+1)^2-9x^2=0$.</li>
</ol>', N'<p><b>a)</b> $(x-2)(x+2)+x(x-2)=0$ hay $(x-2)(2x+2)=0$. Suy ra $x=2$ hoặc $x=-1$.</p>
<p><b>b)</b> $(2x+1)^2-(3x)^2=(2x+1-3x)(2x+1+3x)=(1-x)(5x+1)=0$. Suy ra $x=1$ hoặc $x=-\dfrac{1}{5}$.</p>
<p><b>Đáp số:</b> a) $x=2$; $x=-1$. b) $x=1$; $x=-\dfrac{1}{5}$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.3.</b> Giải các phương trình sau:</p>
<ol type="a">
<li>$\dfrac{2}{2x+1}+\dfrac{1}{x+1}=\dfrac{3}{(2x+1)(x+1)}$;</li>
<li>$\dfrac{1}{x+1}-\dfrac{x}{x^2-x+1}=\dfrac{3x}{x^3+1}$.</li>
</ol>', N'<p><b>a)</b> ĐKXĐ: $x\neq-\dfrac{1}{2}$ và $x\neq-1$. Quy đồng và khử mẫu: $2(x+1)+(2x+1)=3$ hay $4x+3=3$, suy ra $x=0$ (thỏa mãn ĐKXĐ).</p>
<p><b>b)</b> Vì $x^3+1=(x+1)(x^2-x+1)$ và $x^2-x+1\gt0$ với mọi $x$ nên ĐKXĐ: $x\neq-1$. Quy đồng và khử mẫu: $(x^2-x+1)-x(x+1)=3x$ hay $-2x+1=3x$, suy ra $x=\dfrac{1}{5}$ (thỏa mãn ĐKXĐ).</p>
<p><b>Đáp số:</b> a) $x=0$. b) $x=\dfrac{1}{5}$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.4.</b> Bác An có một mảnh đất hình chữ nhật với chiều dài 14 m và chiều rộng 12 m. Bác dự định xây nhà trên mảnh đất đó và dành một phần diện tích đất để làm sân vườn như Hình 2.2 (sân vườn là dải rộng $x$ (m) phía trên và dải rộng $x+2$ (m) bên phải mảnh đất; phần còn lại là nhà). Biết diện tích đất làm nhà là 100 m². Hỏi $x$ bằng bao nhiêu mét?</p>', N'<p>Điều kiện $0\lt x\lt12$. Phần đất làm nhà là hình chữ nhật có chiều dài $14-(x+2)=12-x$ (m) và chiều rộng $12-x$ (m).</p>
<p>Diện tích nhà bằng 100 nên $(12-x)^2=100$, tức $(12-x-10)(12-x+10)=0$ hay $(2-x)(22-x)=0$. Suy ra $x=2$ hoặc $x=22$.</p>
<p>Chỉ $x=2$ thỏa mãn điều kiện $0\lt x\lt12$. Khi đó nhà có kích thước $10\ \text{m}\times10\ \text{m}$.</p>
<p><b>Đáp số:</b> $x=2$ m.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.5.</b> Hai người cùng làm chung một công việc thì xong trong 8 giờ. Hai người cùng làm được 4 giờ thì người thứ nhất bị điều đi làm công việc khác. Người thứ hai tiếp tục làm việc trong 12 giờ nữa thì xong công việc. Gọi $x$ là thời gian người thứ nhất làm một mình xong công việc (đơn vị tính là giờ, $x\gt0$).</p>
<ol type="a">
<li>Hãy biểu thị theo $x$: khối lượng công việc mà người thứ nhất làm được trong 1 giờ; khối lượng công việc mà người thứ hai làm được trong 1 giờ.</li>
<li>Hãy lập phương trình theo $x$ và giải phương trình đó. Sau đó cho biết, nếu làm một mình thì mỗi người phải làm trong bao lâu mới xong công việc đó.</li>
</ol>', N'<p><b>a)</b> Người thứ nhất làm được $\dfrac{1}{x}$ công việc trong 1 giờ. Hai người cùng làm trong 1 giờ được $\dfrac{1}{8}$ công việc nên người thứ hai làm được $\dfrac{1}{8}-\dfrac{1}{x}$ công việc trong 1 giờ.</p>
<p><b>b)</b> Làm chung 4 giờ được $\dfrac{4}{8}=\dfrac{1}{2}$ công việc; còn lại $\dfrac{1}{2}$ công việc do người thứ hai làm trong 12 giờ: $$12\left(\dfrac{1}{8}-\dfrac{1}{x}\right)=\dfrac{1}{2}.$$ Suy ra $\dfrac{3}{2}-\dfrac{12}{x}=\dfrac{1}{2}$ hay $\dfrac{12}{x}=1$, $x=12$ (thỏa mãn). Khi đó người thứ hai mỗi giờ làm được $\dfrac{1}{8}-\dfrac{1}{12}=\dfrac{1}{24}$ công việc nên làm một mình xong trong 24 giờ.</p>
<p><b>Đáp số:</b> người thứ nhất 12 giờ, người thứ hai 24 giờ.</p>', 3, 0, 1, @t1);

-- Bài 5
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 5. Bất đẳng thức và tính chất', N'Khái niệm bất đẳng thức, tính chất bắc cầu, liên hệ giữa thứ tự với phép cộng và phép nhân.', N'<p><b>1. Bất đẳng thức.</b> Trên tập số thực, với hai số $a$ và $b$ có ba trường hợp: $a=b$, $a\gt b$ hoặc $a\lt b$. Số $a$ lớn hơn hoặc bằng $b$ ký hiệu $a\ge b$; số $a$ nhỏ hơn hoặc bằng $b$ ký hiệu $a\le b$.</p>
<p>Hệ thức dạng $a\gt b$ (hay $a\lt b$, $a\ge b$, $a\le b$) gọi là <b>bất đẳng thức</b>; $a$ là vế trái, $b$ là vế phải.</p>
<p><b>Chú ý.</b> Hai bất đẳng thức $1\lt2$ và $-3\lt-2$ (hay $6\gt3$ và $8\gt5$) gọi là hai bất đẳng thức <b>cùng chiều</b>; hai bất đẳng thức $1\lt2$ và $-2\gt-3$ gọi là <b>ngược chiều</b>.</p>
<p><b>Tính chất bắc cầu.</b> Nếu $a\lt b$ và $b\lt c$ thì $a\lt c$. Tương tự với các thứ tự $\gt$, $\ge$, $\le$.</p>
<p><b>Ví dụ 1.</b> Chứng minh $\dfrac{2024}{2023}\gt\dfrac{2021}{2022}$. Ta có $\dfrac{2024}{2023}=1+\dfrac{1}{2023}\gt1$ và $\dfrac{2021}{2022}=1-\dfrac{1}{2022}\lt1$ nên $\dfrac{2024}{2023}\gt\dfrac{2021}{2022}$.</p>
<p><b>2. Liên hệ giữa thứ tự và phép cộng.</b> Khi cộng cùng một số vào hai vế của một bất đẳng thức ta được bất đẳng thức mới cùng chiều với bất đẳng thức đã cho. Với ba số $a,b,c$: nếu $a\lt b$ thì $a+c\lt b+c$; nếu $a\le b$ thì $a+c\le b+c$; nếu $a\gt b$ thì $a+c\gt b+c$; nếu $a\ge b$ thì $a+c\ge b+c$.</p>
<p><b>3. Liên hệ giữa thứ tự và phép nhân.</b></p>
<ul>
<li>Khi nhân cả hai vế của một bất đẳng thức với cùng một <b>số dương</b> ta được bất đẳng thức mới <b>cùng chiều</b>: với $c\gt0$, nếu $a\lt b$ thì $ac\lt bc$.</li>
<li>Khi nhân cả hai vế của một bất đẳng thức với cùng một <b>số âm</b> ta được bất đẳng thức mới <b>ngược chiều</b>: với $c\lt0$, nếu $a\lt b$ thì $ac\gt bc$.</li>
</ul>
<p><b>Ví dụ 2.</b> Vì $-7\lt-5$ và $3\gt0$ nên $3\cdot(-7)\lt3\cdot(-5)$. Vì $-7\lt-5$ và $-3\lt0$ nên $(-3)\cdot(-7)\gt(-3)\cdot(-5)$.</p>', 2, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.6.</b> Dùng kí hiệu để viết bất đẳng thức tương ứng với mỗi trường hợp sau:</p>
<ol type="a">
<li>$x$ nhỏ hơn hoặc bằng $-2$;</li>
<li>$m$ là số âm;</li>
<li>$y$ là số dương;</li>
<li>$p$ lớn hơn hoặc bằng 2 024.</li>
</ol>', N'<p><b>a)</b> $x\le-2$. <b>b)</b> $m\lt0$. <b>c)</b> $y\gt0$. <b>d)</b> $p\ge2024$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.7.</b> Viết một bất đẳng thức phù hợp trong mỗi trường hợp sau:</p>
<ol type="a">
<li>Bạn phải ít nhất 18 tuổi mới được phép lái ô tô;</li>
<li>Xe buýt chở được tối đa 45 người;</li>
<li>Mức lương tối thiểu cho một giờ làm việc của người lao động là 20 000 đồng.</li>
</ol>', N'<p><b>a)</b> Gọi $a$ là số tuổi: $a\ge18$.</p>
<p><b>b)</b> Gọi $n$ là số người trên xe buýt: $n\le45$.</p>
<p><b>c)</b> Gọi $m$ (đồng) là tiền lương một giờ làm việc: $m\ge20000$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.8.</b> Không thực hiện phép tính, hãy chứng minh:</p>
<ol type="a">
<li>$2\cdot(-7)+2023\lt2\cdot(-1)+2023$;</li>
<li>$(-3)\cdot(-8)+1975\gt(-3)\cdot(-7)+1975$.</li>
</ol>', N'<p><b>a)</b> Vì $-7\lt-1$, nhân hai vế với $2\gt0$ được $2\cdot(-7)\lt2\cdot(-1)$. Cộng hai vế với 2 023 được bất đẳng thức cần chứng minh.</p>
<p><b>b)</b> Vì $-8\lt-7$, nhân hai vế với $-3\lt0$ được $(-3)\cdot(-8)\gt(-3)\cdot(-7)$. Cộng hai vế với 1 975 được bất đẳng thức cần chứng minh.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.9.</b> Cho $a\lt b$, hãy so sánh:</p>
<ol type="a">
<li>$5a+7$ và $5b+7$;</li>
<li>$-3a-9$ và $-3b-9$.</li>
</ol>', N'<p><b>a)</b> Từ $a\lt b$, nhân hai vế với $5\gt0$: $5a\lt5b$. Cộng hai vế với 7: $5a+7\lt5b+7$.</p>
<p><b>b)</b> Từ $a\lt b$, nhân hai vế với $-3\lt0$: $-3a\gt-3b$. Cộng hai vế với $-9$: $-3a-9\gt-3b-9$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.10.</b> So sánh hai số $a$ và $b$, nếu:</p>
<ol type="a">
<li>$a+1954\lt b+1954$;</li>
<li>$-2a\gt-2b$.</li>
</ol>', N'<p><b>a)</b> Cộng hai vế của bất đẳng thức với $-1954$ được $a\lt b$.</p>
<p><b>b)</b> Nhân hai vế của bất đẳng thức với $-\dfrac{1}{2}\lt0$ (đổi chiều) được $a\lt b$.</p>
<p><b>Đáp số:</b> cả hai trường hợp đều có $a\lt b$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.11.</b> Chứng minh rằng:</p>
<ol type="a">
<li>$-\dfrac{2023}{2024}\gt-\dfrac{2024}{2023}$;</li>
<li>$\dfrac{34}{11}\gt\dfrac{26}{9}$.</li>
</ol>', N'<p><b>a)</b> Ta có $\dfrac{2023}{2024}\lt1$ và $\dfrac{2024}{2023}\gt1$ nên $\dfrac{2023}{2024}\lt\dfrac{2024}{2023}$. Nhân hai vế với $-1\lt0$ (đổi chiều) được $-\dfrac{2023}{2024}\gt-\dfrac{2024}{2023}$.</p>
<p><b>b)</b> Ta có $\dfrac{34}{11}=3+\dfrac{1}{11}\gt3$ và $\dfrac{26}{9}=2+\dfrac{8}{9}\lt3$. Theo tính chất bắc cầu, $\dfrac{34}{11}\gt3\gt\dfrac{26}{9}$.</p>', 2, 0, 1, @t1);

-- Luyện tập chung (Bài 4 - Bài 5)
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Luyện tập chung (Chương II)', N'Rèn luyện giải phương trình chứa ẩn ở mẫu, phương trình tích và chứng minh bất đẳng thức.', N'<p><b>Ví dụ 1.</b> Giải $\dfrac{1}{x-1}+\dfrac{2}{x^2+x+1}=\dfrac{x^2+x}{x^3-1}$. ĐKXĐ: $x\neq1$. Quy đồng mẫu hai vế (mẫu chung $x^3-1=(x-1)(x^2+x+1)$): $\dfrac{x^2+3x-1}{x^3-1}=\dfrac{x^2+x}{x^3-1}$. Suy ra $x^2+3x-1=x^2+x$ hay $2x-1=0$, $x=\dfrac{1}{2}$ (thỏa mãn ĐKXĐ).</p>
<p><b>Ví dụ 2.</b> Giải $\dfrac{x}{x+3}-\dfrac{2}{x-3}=\dfrac{-2x-6}{x^2-9}$. ĐKXĐ: $x\neq3$ và $x\neq-3$. Quy đồng và khử mẫu: $x(x-3)-2(x+3)=-2x-6$ hay $x^2-3x=0$, $x(x-3)=0$. Suy ra $x=0$ (thỏa mãn) hoặc $x=3$ (không thỏa mãn ĐKXĐ). Phương trình có nghiệm $x=0$.</p>
<p><b>Ví dụ 3.</b> Cho $a\lt b$. Chứng minh $2a+1\lt2b+2$. Từ $a\lt b$ có $2a\lt2b$ nên $2a+1\lt2b+1$ (1). Vì $1\lt2$ nên $2b+1\lt2b+2$ (2). Theo tính chất bắc cầu, từ (1) và (2) suy ra $2a+1\lt2b+2$.</p>', 3, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.12.</b> Giải các phương trình sau:</p>
<ol type="a">
<li>$2(x+1)=(5x-1)(x+1)$;</li>
<li>$(-4x+3)x=(2x+5)x$.</li>
</ol>', N'<p><b>a)</b> $2(x+1)-(5x-1)(x+1)=0$ hay $(x+1)(2-5x+1)=(x+1)(3-5x)=0$. Suy ra $x=-1$ hoặc $x=\dfrac{3}{5}$.</p>
<p><b>b)</b> $(-4x+3)x-(2x+5)x=0$ hay $x(-6x-2)=0$. Suy ra $x=0$ hoặc $x=-\dfrac{1}{3}$.</p>
<p><b>Đáp số:</b> a) $x=-1$; $x=\dfrac{3}{5}$. b) $x=0$; $x=-\dfrac{1}{3}$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.13.</b> Để loại bỏ $x\%$ một loại tảo độc khỏi một hồ nước, người ta ước tính chi phí cần bỏ ra là $$C(x)=\dfrac{50x}{100-x}\ \text{(triệu đồng)},\quad 0\le x\lt100.$$ Nếu bỏ ra 450 triệu đồng, người ta có thể loại bỏ được bao nhiêu phần trăm loại tảo độc đó?</p>', N'<p>Giải phương trình $\dfrac{50x}{100-x}=450$ với $0\le x\lt100$ (khi đó $100-x\neq0$).</p>
<p>Khử mẫu: $50x=450(100-x)=45000-450x$, suy ra $500x=45000$, $x=90$ (thỏa mãn $0\le x\lt100$).</p>
<p><b>Đáp số:</b> loại bỏ được 90% loại tảo độc.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.14.</b> Giải các phương trình sau:</p>
<ol type="a">
<li>$\dfrac{1}{x+2}-\dfrac{2}{x^2-2x+4}=\dfrac{x-4}{x^3+8}$;</li>
<li>$\dfrac{2x}{x-4}+\dfrac{3}{x+4}=\dfrac{x-12}{x^2-16}$.</li>
</ol>', N'<p><b>a)</b> $x^3+8=(x+2)(x^2-2x+4)$ và $x^2-2x+4\gt0$ với mọi $x$ nên ĐKXĐ: $x\neq-2$. Quy đồng và khử mẫu: $(x^2-2x+4)-2(x+2)=x-4$ hay $x^2-4x=x-4$, tức $x^2-5x+4=0$, $(x-1)(x-4)=0$. Suy ra $x=1$ hoặc $x=4$ (đều thỏa mãn ĐKXĐ).</p>
<p><b>b)</b> ĐKXĐ: $x\neq4$ và $x\neq-4$. Quy đồng và khử mẫu: $2x(x+4)+3(x-4)=x-12$ hay $2x^2+11x-12=x-12$, tức $2x^2+10x=0$, $2x(x+5)=0$. Suy ra $x=0$ hoặc $x=-5$ (đều thỏa mãn ĐKXĐ).</p>
<p><b>Đáp số:</b> a) $x=1$; $x=4$. b) $x=0$; $x=-5$.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.15.</b> Cho $a\gt b$, chứng minh rằng:</p>
<ol type="a">
<li>$4a+4\gt4b+3$;</li>
<li>$1-3a\lt3-3b$.</li>
</ol>', N'<p><b>a)</b> Từ $a\gt b$ suy ra $4a\gt4b$, nên $4a+4\gt4b+4$ (1). Vì $4\gt3$ nên $4b+4\gt4b+3$ (2). Từ (1) và (2) theo tính chất bắc cầu: $4a+4\gt4b+3$.</p>
<p><b>b)</b> Từ $a\gt b$ suy ra $-3a\lt-3b$, nên $1-3a\lt1-3b$ (1). Vì $1\lt3$ nên $1-3b\lt3-3b$ (2). Từ (1) và (2): $1-3a\lt3-3b$.</p>', 2, 0, 1, @t1);

-- Bài 6
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 6. Bất phương trình bậc nhất một ẩn', N'Khái niệm bất phương trình bậc nhất một ẩn, nghiệm của bất phương trình và cách giải.', N'<p><b>1. Khái niệm.</b> Bất phương trình dạng $ax+b\lt0$ (hoặc $ax+b\gt0$; $ax+b\le0$; $ax+b\ge0$), trong đó $a,b$ là hai số đã cho, $a\neq0$, gọi là <b>bất phương trình bậc nhất một ẩn</b> $x$.</p>
<p>Số $x_0$ là một <b>nghiệm</b> của bất phương trình $A(x)\lt B(x)$ nếu $A(x_0)\lt B(x_0)$ là khẳng định đúng. Giải một bất phương trình là tìm tất cả các nghiệm của nó.</p>
<p><b>Ví dụ 1.</b> $3x+16\le0$, $-5x+5\gt0$, $-3x\lt0$ là các bất phương trình bậc nhất một ẩn; $x^2-4\gt0$ không phải vì $x^2-4$ là đa thức bậc hai. Với bất phương trình $3x+8\lt20$: $x=\dfrac{4}{3}$ là nghiệm vì $3\cdot\dfrac{4}{3}+8=12\lt20$; $x=5$ không là nghiệm vì $23\lt20$ sai.</p>
<p><b>2. Cách giải.</b> Bất phương trình bậc nhất một ẩn $ax+b\lt0$ ($a\neq0$) được giải như sau: $ax\lt-b$.</p>
<ul>
<li>Nếu $a\gt0$ thì $x\lt-\dfrac{b}{a}$.</li>
<li>Nếu $a\lt0$ thì $x\gt-\dfrac{b}{a}$ (đổi chiều bất đẳng thức khi nhân hai vế với số âm).</li>
</ul>
<p>Các bất phương trình $ax+b\gt0$, $ax+b\le0$, $ax+b\ge0$ được giải tương tự.</p>
<p><b>Ví dụ 2.</b> Giải $-2x-4\gt0$. Ta có $-2x\gt4$, nhân hai vế với $-\dfrac{1}{2}$ và đổi chiều: $x\lt-2$.</p>
<p><b>Ví dụ 3 (bài toán mở đầu).</b> Bạn Thanh có 100 nghìn đồng, mua một bút giá 18 nghìn đồng và $x$ quyển vở giá 7 nghìn đồng/quyển: $7x+18\le100$ suy ra $x\le\dfrac{82}{7}\approx11{,}7$. Vì số vở là số tự nhiên nên Thanh mua được nhiều nhất 11 quyển vở.</p>
<p><b>Ví dụ 4.</b> a) $2x+5\lt3x-4\Leftrightarrow-x\lt-9\Leftrightarrow x\gt9$. b) $-3x+5\ge-4x+3\Leftrightarrow x\ge-2$.</p>
<p><b>Ví dụ 5.</b> Lãi suất gửi tiết kiệm 12 tháng là 7,4%/năm. Để tiền lãi hằng năm ít nhất 60 triệu đồng thì số tiền gửi $x$ (triệu đồng) phải thỏa mãn $0{,}074x\ge60$, suy ra $x\ge810{,}81$. Vậy cần gửi ít nhất 811 triệu đồng.</p>', 4, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.16.</b> Giải các bất phương trình sau:</p>
<ol type="a">
<li>$x-5\ge0$;</li>
<li>$x+5\le0$;</li>
<li>$-2x-6\gt0$;</li>
<li>$4x-12\lt0$.</li>
</ol>', N'<p><b>a)</b> $x\ge5$. <b>b)</b> $x\le-5$.</p>
<p><b>c)</b> $-2x\gt6$; nhân hai vế với $-\dfrac{1}{2}$ và đổi chiều: $x\lt-3$.</p>
<p><b>d)</b> $4x\lt12$ suy ra $x\lt3$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.17.</b> Giải các bất phương trình sau:</p>
<ol type="a">
<li>$3x+2\gt2x+3$;</li>
<li>$5x+4\lt-3x-2$.</li>
</ol>', N'<p><b>a)</b> $3x-2x\gt3-2$ hay $x\gt1$.</p>
<p><b>b)</b> $5x+3x\lt-2-4$ hay $8x\lt-6$, suy ra $x\lt-\dfrac{3}{4}$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.18.</b> Một ngân hàng đang áp dụng lãi suất gửi tiết kiệm kì hạn 1 tháng là 0,4%/tháng. Hỏi nếu muốn có số tiền lãi hằng tháng ít nhất là 3 triệu đồng thì số tiền gửi tiết kiệm ít nhất là bao nhiêu (làm tròn đến triệu đồng)?</p>', N'<p>Gọi $x$ (triệu đồng) là số tiền gửi. Tiền lãi một tháng là $0{,}004x$ (triệu đồng).</p>
<p>Cần $0{,}004x\ge3$, suy ra $x\ge750$.</p>
<p><b>Đáp số:</b> ít nhất 750 triệu đồng.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.19.</b> Một hãng taxi có giá mở cửa là 15 nghìn đồng và giá 12 nghìn đồng cho mỗi kilômét tiếp theo. Hỏi với 200 nghìn đồng thì hành khách có thể di chuyển được tối đa bao nhiêu kilômét (làm tròn đến hàng đơn vị)?</p>', N'<p>Gọi $x$ (km) là quãng đường tính theo giá 12 nghìn đồng/km ($x\gt0$). Số tiền phải trả là $15+12x$ (nghìn đồng).</p>
<p>Với 200 nghìn đồng: $15+12x\le200$, suy ra $12x\le185$, $x\le\dfrac{185}{12}\approx15{,}4$.</p>
<p>Vì phải làm tròn xuống để số tiền không vượt quá 200 nghìn đồng nên $x=15$.</p>
<p><b>Đáp số:</b> tối đa khoảng 15 km tính theo giá 12 nghìn đồng/km (không kể phần giá mở cửa).</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.20.</b> Người ta dùng một loại xe tải để chở sữa tươi cho một nhà máy. Biết mỗi thùng sữa loại 180 ml nặng trung bình 10 kg. Theo khuyến nghị, trọng tải của xe (tức là tổng khối lượng tối đa cho phép mà xe có thể chở) là 5,25 tấn. Hỏi xe có thể chở được tối đa bao nhiêu thùng sữa như vậy, biết bác lái xe nặng 65 kg?</p>', N'<p>Đổi 5,25 tấn $=5250$ kg. Gọi $x$ là số thùng sữa chở được ($x\in\mathbb{N}$).</p>
<p>Tổng khối lượng không vượt quá trọng tải: $10x+65\le5250$, suy ra $10x\le5185$, $x\le518{,}5$.</p>
<p>Vì $x$ là số tự nhiên nên $x\le518$.</p>
<p><b>Đáp số:</b> tối đa 518 thùng sữa.</p>', 2, 0, 1, @t1);

-- Bài tập cuối chương II
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài tập cuối chương II', N'Ôn tập chương II: phương trình tích, phương trình chứa ẩn ở mẫu, bất đẳng thức và bất phương trình bậc nhất một ẩn.', N'<p><b>Tóm tắt kiến thức chương II.</b></p>
<ul>
<li><b>Phương trình tích</b> $(ax+b)(cx+d)=0$: giải $ax+b=0$ và $cx+d=0$ rồi lấy tất cả các nghiệm.</li>
<li><b>Phương trình chứa ẩn ở mẫu:</b> tìm ĐKXĐ, quy đồng và khử mẫu, giải phương trình, đối chiếu ĐKXĐ để kết luận.</li>
<li><b>Bất đẳng thức:</b> tính chất bắc cầu; cộng cùng một số vào hai vế thì giữ nguyên chiều; nhân hai vế với số dương thì giữ nguyên chiều, nhân với số âm thì đổi chiều.</li>
<li><b>Bất phương trình bậc nhất một ẩn</b> $ax+b\lt0$ ($a\neq0$): nếu $a\gt0$ thì $x\lt-\dfrac{b}{a}$; nếu $a\lt0$ thì $x\gt-\dfrac{b}{a}$.</li>
</ul>
<p><b>Em có biết: bất đẳng thức giữa trung bình cộng và trung bình nhân (Cauchy, AM-GM).</b> Với hai số $a,b\ge0$ ta luôn có $$\dfrac{a+b}{2}\ge\sqrt{ab}.$$ Dấu bằng xảy ra khi và chỉ khi $a=b$.</p>', 5, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 2.21.</b> Nghiệm của bất phương trình $-2x+1\lt0$ là</p>', N'<p>$-2x+1\lt0$ suy ra $-2x\lt-1$. Nhân hai vế với $-\dfrac{1}{2}\lt0$ và đổi chiều bất đẳng thức: $x\gt\dfrac{1}{2}$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$x\lt\dfrac{1}{2}$.', 0),
(@q, 'B', N'$x\gt\dfrac{1}{2}$.', 1),
(@q, 'C', N'$x\le\dfrac{1}{2}$.', 0),
(@q, 'D', N'$x\ge\dfrac{1}{2}$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 2.22.</b> Điều kiện xác định của phương trình $\dfrac{x}{2x+1}+\dfrac{3}{x-5}=\dfrac{x}{(2x+1)(x-5)}$ là</p>', N'<p>Các mẫu thức phải khác 0: $2x+1\neq0$ suy ra $x\neq-\dfrac{1}{2}$; $x-5\neq0$ suy ra $x\neq5$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$x\neq-\dfrac{1}{2}$.', 0),
(@q, 'B', N'$x\neq-\dfrac{1}{2}$ và $x\neq-5$.', 0),
(@q, 'C', N'$x\neq5$.', 0),
(@q, 'D', N'$x\neq-\dfrac{1}{2}$ và $x\neq5$.', 1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 2.23.</b> Phương trình $x-1=m+4$ có nghiệm lớn hơn 1 với</p>', N'<p>Phương trình có nghiệm $x=m+5$. Nghiệm lớn hơn 1 khi $m+5\gt1$, tức $m\gt-4$.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$m\ge-4$.', 0),
(@q, 'B', N'$m\le4$.', 0),
(@q, 'C', N'$m\gt-4$.', 1),
(@q, 'D', N'$m\lt-4$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 2.24.</b> Nghiệm của bất phương trình $1-2x\ge2-x$ là</p>', N'<p>$1-2x\ge2-x$ suy ra $-2x+x\ge2-1$ hay $-x\ge1$. Nhân hai vế với $-1$ và đổi chiều: $x\le-1$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$x\gt\dfrac{1}{2}$.', 0),
(@q, 'B', N'$x\lt\dfrac{1}{2}$.', 0),
(@q, 'C', N'$x\le-1$.', 1),
(@q, 'D', N'$x\ge-1$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 2.25.</b> Cho $a\gt b$. Khi đó ta có:</p>', N'<p>C đúng: từ $a\gt b$ suy ra $5a\gt5b$ nên $5a+1\gt5b+1$. A sai (ví dụ $a=1,\ b=0{,}9$ thì $2a=2\lt2{,}7=3b$). B sai (ví dụ $a=1,\ b=0{,}9$ thì $2a=2\lt2{,}8=2b+1$). D sai (cũng với $a=1,\ b=0{,}9$: $-3a=-3$ còn $-3b-3=-5{,}7$, mà $-3\lt-5{,}7$ là khẳng định sai).</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$2a\gt3b$.', 0),
(@q, 'B', N'$2a\gt2b+1$.', 0),
(@q, 'C', N'$5a+1\gt5b+1$.', 1),
(@q, 'D', N'$-3a\lt-3b-3$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.26.</b> Giải các phương trình sau:</p>
<ol type="a">
<li>$(3x-1)^2-(x+2)^2=0$;</li>
<li>$x(x+1)=2(x^2-1)$.</li>
</ol>', N'<p><b>a)</b> $(3x-1-x-2)(3x-1+x+2)=(2x-3)(4x+1)=0$. Suy ra $x=\dfrac{3}{2}$ hoặc $x=-\dfrac{1}{4}$.</p>
<p><b>b)</b> $x(x+1)-2(x-1)(x+1)=0$ hay $(x+1)(x-2x+2)=(x+1)(2-x)=0$. Suy ra $x=-1$ hoặc $x=2$.</p>
<p><b>Đáp số:</b> a) $x=\dfrac{3}{2}$; $x=-\dfrac{1}{4}$. b) $x=-1$; $x=2$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.27.</b> Giải các phương trình sau:</p>
<ol type="a">
<li>$\dfrac{x}{x-5}-\dfrac{2}{x+5}=\dfrac{x^2}{x^2-25}$;</li>
<li>$\dfrac{1}{x+1}-\dfrac{x}{x^2-x+1}=\dfrac{3}{x^3+1}$.</li>
</ol>', N'<p><b>a)</b> ĐKXĐ: $x\neq5$ và $x\neq-5$. Quy đồng và khử mẫu: $x(x+5)-2(x-5)=x^2$ hay $x^2+3x+10=x^2$, suy ra $x=-\dfrac{10}{3}$ (thỏa mãn ĐKXĐ).</p>
<p><b>b)</b> ĐKXĐ: $x\neq-1$ (vì $x^2-x+1\gt0$ với mọi $x$). Quy đồng và khử mẫu: $(x^2-x+1)-x(x+1)=3$ hay $-2x+1=3$, suy ra $x=-1$. Giá trị này không thỏa mãn ĐKXĐ nên phương trình vô nghiệm.</p>
<p><b>Đáp số:</b> a) $x=-\dfrac{10}{3}$. b) vô nghiệm.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.28.</b> Cho $a\lt b$, hãy so sánh:</p>
<ol type="a">
<li>$a+b+5$ với $2b+5$;</li>
<li>$-2a-3$ với $-(a+b)-3$.</li>
</ol>', N'<p><b>a)</b> Từ $a\lt b$, cộng hai vế với $b$: $a+b\lt2b$. Cộng hai vế với 5: $a+b+5\lt2b+5$.</p>
<p><b>b)</b> Từ $a\lt b$ suy ra $-a\gt-b$; cộng hai vế với $-a$ được $-2a\gt-a-b$. Cộng hai vế với $-3$: $-2a-3\gt-(a+b)-3$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.29.</b> Giải các bất phương trình:</p>
<ol type="a">
<li>$2x+3(x+1)\gt5x-(2x-4)$;</li>
<li>$(x+1)(2x-1)\lt2x^2-4x+1$.</li>
</ol>', N'<p><b>a)</b> $2x+3x+3\gt5x-2x+4$ hay $5x+3\gt3x+4$, suy ra $2x\gt1$, $x\gt\dfrac{1}{2}$.</p>
<p><b>b)</b> $(x+1)(2x-1)=2x^2+x-1$. Bất phương trình thành $2x^2+x-1\lt2x^2-4x+1$ hay $5x\lt2$, suy ra $x\lt\dfrac{2}{5}$.</p>
<p><b>Đáp số:</b> a) $x\gt\dfrac{1}{2}$. b) $x\lt\dfrac{2}{5}$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.30.</b> Một hãng viễn thông nước ngoài có hai gói cước như sau:</p>
<table border="1"><tr><th>Gói cước A</th><th>Gói cước B</th></tr><tr><td>Cước thuê bao hằng tháng 32 USD; 45 phút miễn phí; 0,4 USD cho mỗi phút thêm</td><td>Cước thuê bao hằng tháng là 44 USD; không có phút miễn phí; 0,25 USD/phút</td></tr></table>
<ol type="a">
<li>Hãy viết một phương trình xác định thời gian gọi (phút) mà phí phải trả trong cùng một tháng của hai gói cước là như nhau và giải phương trình đó.</li>
<li>Nếu khách hàng chỉ gọi tối đa là 180 phút trong 1 tháng thì nên dùng gói cước nào? Nếu khách hàng gọi 500 phút trong 1 tháng thì nên dùng gói cước nào?</li>
</ol>', N'<p><b>a)</b> Gọi $t$ (phút) là thời gian gọi trong tháng ($t\gt45$). Phí gói A: $32+0{,}4(t-45)$ (USD); phí gói B: $44+0{,}25t$ (USD).</p>
<p>Hai gói bằng nhau: $32+0{,}4(t-45)=44+0{,}25t$ hay $0{,}4t+14=0{,}25t+44$, suy ra $0{,}15t=30$, $t=200$ (phút). Khi đó cả hai gói đều phải trả 94 USD.</p>
<p><b>b)</b> Với $t=180\lt200$: gói A phải trả $32+0{,}4\cdot135=86$ USD, gói B phải trả $44+0{,}25\cdot180=89$ USD nên chọn <b>gói A</b>. (Với $t\le45$ gói A chỉ mất 32 USD, vẫn rẻ hơn.)</p>
<p>Với $t=500\gt200$: gói A phải trả $32+0{,}4\cdot455=214$ USD, gói B phải trả $44+0{,}25\cdot500=169$ USD nên chọn <b>gói B</b>.</p>
<p><b>Đáp số:</b> a) 200 phút. b) gọi tối đa 180 phút: gói A; gọi 500 phút: gói B.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.31.</b> Thanh tham dự một kì kiểm tra năng lực tiếng Anh gồm 4 bài kiểm tra nghe, nói, đọc và viết. Mỗi bài kiểm tra có điểm là số nguyên từ 0 đến 10. Điểm trung bình của ba bài kiểm tra nghe, nói, đọc của Thanh là 6,7. Hỏi bài kiểm tra viết của Thanh cần được bao nhiêu điểm để điểm trung bình cả 4 bài kiểm tra được từ 7,0 trở lên? Biết điểm trung bình được tính gần đúng đến chữ số thập phân thứ nhất.</p>', N'<p>Gọi $x$ là điểm bài viết ($x\in\mathbb{N}$, $0\le x\le10$). Tổng điểm ba bài đầu là $3\cdot6{,}7=20{,}1$. Điểm trung bình bốn bài là $\dfrac{20{,}1+x}{4}$.</p>
<p>Vì điểm trung bình được làm tròn đến chữ số thập phân thứ nhất và phải đạt từ 7,0 trở lên nên giá trị trước khi làm tròn phải $\ge6{,}95$: $\dfrac{20{,}1+x}{4}\ge6{,}95$, suy ra $20{,}1+x\ge27{,}8$, $x\ge7{,}7$.</p>
<p>Vì $x$ nguyên nên $x\ge8$.</p>
<p><b>Đáp số:</b> bài viết cần ít nhất 8 điểm.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 2.32.</b> Để lập đội tuyển năng khiếu về bóng rổ của trường, thầy thể dục đưa ra quy định tuyển chọn như sau: mỗi bạn dự tuyển sẽ được ném 15 quả bóng vào rổ, quả bóng vào rổ được cộng 2 điểm; quả bóng ném ra ngoài bị trừ 1 điểm. Nếu bạn nào có số điểm từ 15 điểm trở lên thì sẽ được chọn vào đội tuyển. Hỏi một học sinh muốn được chọn vào đội tuyển thì phải ném ít nhất bao nhiêu quả vào rổ?</p>', N'<p>Gọi $x$ là số quả bóng vào rổ ($x\in\mathbb{N}$, $0\le x\le15$); số quả ném ra ngoài là $15-x$.</p>
<p>Số điểm: $2x-(15-x)=3x-15$. Cần $3x-15\ge15$, suy ra $3x\ge30$, $x\ge10$.</p>
<p><b>Đáp số:</b> phải ném vào rổ ít nhất 10 quả.</p>', 2, 0, 1, @t1);

-- ---------------------------------------------------------------------------------------------------------------------
-- Chương III. Căn bậc hai và căn bậc ba
-- ---------------------------------------------------------------------------------------------------------------------
INSERT INTO Topics (TopicName, [Description], TeacherId, OrderIndex, IsActive) VALUES (N'Chương III. Căn bậc hai và căn bậc ba', N'Căn bậc hai và căn thức bậc hai, khai căn bậc hai với phép nhân và phép chia, biến đổi đơn giản và rút gọn biểu thức chứa căn thức bậc hai, căn bậc ba và căn thức bậc ba. (SGK Toán 9 Kết nối tri thức với cuộc sống, Tập 1)', @t1, 3, 1);
SET @tp = SCOPE_IDENTITY();

-- Bài 7
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 7. Căn bậc hai và căn thức bậc hai', N'Căn bậc hai của số thực không âm, tính căn bậc hai bằng máy tính cầm tay, căn thức bậc hai, điều kiện xác định và hằng đẳng thức căn bậc hai của một bình phương.', N'<p><b>1. Căn bậc hai.</b> Căn bậc hai của số thực không âm $a$ là số thực $x$ sao cho $x^2=a$.</p>
<ul>
<li>Số âm không có căn bậc hai.</li>
<li>Số $0$ có một căn bậc hai duy nhất là $0$.</li>
<li>Số dương $a$ có đúng hai căn bậc hai đối nhau là $\sqrt{a}$ (căn bậc hai số học của $a$) và $-\sqrt{a}$.</li>
</ul>
<p><b>Ví dụ 1.</b> Tìm căn bậc hai của 81. Ta có $\sqrt{81}=9$ nên 81 có hai căn bậc hai là $9$ và $-9$.</p>
<p><b>Ví dụ 2 (dùng máy tính cầm tay).</b> Để tính căn bậc hai của $11{,}1$ ta bấm $\sqrt{\ }$, nhập $11{,}1$, bấm $=$ được $3{,}33166625$. Làm tròn đến chữ số thập phân thứ hai: $\sqrt{11{,}1}\approx3{,}33$. Vậy căn bậc hai của $11{,}1$ (làm tròn đến chữ số thập phân thứ hai) là $3{,}33$ và $-3{,}33$.</p>
<p><b>Tính chất.</b> $\sqrt{a^2}=|a|$ với mọi số thực $a$.</p>
<p><b>Ví dụ 3.</b> Không dùng máy tính cầm tay, tính: a) $1-\sqrt{2}+\sqrt{(1+\sqrt{2})^2}$. Ta có $\sqrt{(1+\sqrt{2})^2}=|1+\sqrt{2}|=1+\sqrt{2}$ nên biểu thức bằng $1-\sqrt{2}+1+\sqrt{2}=2$. b) $\sqrt{(-3)^2}+3=|-3|+3=6$.</p>
<p><b>2. Căn thức bậc hai.</b> Căn thức bậc hai là biểu thức có dạng $\sqrt{A}$, trong đó $A$ là một biểu thức đại số; $A$ gọi là biểu thức lấy căn hay biểu thức dưới dấu căn.</p>
<p>$\sqrt{A}$ xác định khi $A$ lấy giá trị không âm, ta viết là $A\ge0$. Đó là <b>điều kiện xác định</b> (hay điều kiện có nghĩa) của $\sqrt{A}$.</p>
<p><b>Ví dụ 4.</b> Căn thức $\sqrt{2x+1}$ có điều kiện xác định $2x+1\ge0$ hay $x\ge-\dfrac{1}{2}$. Tại $x=0$ giá trị là $\sqrt{1}=1$; tại $x=4$ giá trị là $\sqrt{9}=3$.</p>
<p><b>Hằng đẳng thức.</b> Với $A\ge0$ ta có $\sqrt{A}\ge0$ và $(\sqrt{A})^2=A$. Với mọi biểu thức $A$: $\sqrt{A^2}=|A|$.</p>
<p><b>Ví dụ 5.</b> Rút gọn: a) $(\sqrt{1-x})^2$ với $x\lt0$: vì $1-x\gt0$ nên $(\sqrt{1-x})^2=1-x$. b) $\sqrt{1-2x+x^2}$ với $x\gt2$: $\sqrt{(1-x)^2}=|1-x|$; vì $1-x\lt0$ nên $|1-x|=x-1$.</p>
<p><b>Tình huống mở đầu.</b> Quãng đường vật rơi tự do $S=4{,}9t^2$ nên $t=\sqrt{\dfrac{S}{4{,}9}}$. Với $S=122{,}5$ m: $t=\sqrt{25}=5$ giây.</p>', 1, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.1.</b> Tìm căn bậc hai của mỗi số sau (làm tròn đến chữ số thập phân thứ hai):</p>
<ol type="a">
<li>$24{,}5$;</li>
<li>$\dfrac{9}{10}$.</li>
</ol>', N'<p><b>a)</b> Bấm máy: $\sqrt{24{,}5}\approx4{,}9497$, làm tròn $4{,}95$. Căn bậc hai của $24{,}5$ là $4{,}95$ và $-4{,}95$.</p>
<p><b>b)</b> $\dfrac{9}{10}=0{,}9$, $\sqrt{0{,}9}\approx0{,}9487$, làm tròn $0{,}95$. Căn bậc hai của $\dfrac{9}{10}$ là $0{,}95$ và $-0{,}95$.</p>
<p><b>Đáp số:</b> a) $\pm4{,}95$. b) $\pm0{,}95$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.2.</b> Để chuẩn bị trồng cây trên vỉa hè, người ta để lại những ô đất hình tròn có diện tích khoảng $2\ \text{m}^2$. Em hãy ước lượng (với độ chính xác 0,005) đường kính của các ô đất đó khoảng bao nhiêu mét?</p>', N'<p>Gọi $d$ (m) là đường kính, bán kính là $\dfrac{d}{2}$. Diện tích $\pi\left(\dfrac{d}{2}\right)^2=2$ nên $d^2=\dfrac{8}{\pi}$, $d=\sqrt{\dfrac{8}{\pi}}\approx1{,}5958$.</p>
<p>Làm tròn với độ chính xác $0{,}005$ (sai số không quá $0{,}005$): $d\approx1{,}60$ (vì $|1{,}5958-1{,}60|\approx0{,}004\lt0{,}005$).</p>
<p><b>Đáp số:</b> đường kính khoảng $1{,}60$ m.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.3.</b> Tìm điều kiện xác định của $\sqrt{x+10}$ và tính giá trị của căn thức tại $x=-1$.</p>', N'<p>Điều kiện xác định: $x+10\ge0$, tức $x\ge-10$.</p>
<p>Tại $x=-1$ (thỏa mãn điều kiện): $\sqrt{-1+10}=\sqrt{9}=3$.</p>
<p><b>Đáp số:</b> $x\ge-10$; giá trị tại $x=-1$ là $3$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.4.</b> Tính: $\sqrt{5{,}1^2};\quad\sqrt{(-4{,}9)^2};\quad-\sqrt{(-0{,}001)^2}$.</p>', N'<p>Áp dụng $\sqrt{a^2}=|a|$:</p>
<p>$\sqrt{5{,}1^2}=|5{,}1|=5{,}1$; $\sqrt{(-4{,}9)^2}=|-4{,}9|=4{,}9$; $-\sqrt{(-0{,}001)^2}=-|-0{,}001|=-0{,}001$.</p>
<p><b>Đáp số:</b> $5{,}1;\ 4{,}9;\ -0{,}001$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.5.</b> Rút gọn các biểu thức sau:</p>
<ol type="a">
<li>$\sqrt{(2-\sqrt{5})^2}$;</li>
<li>$3\sqrt{x^2}-x+1$ ($x\lt0$);</li>
<li>$\sqrt{x^2-4x+4}$ ($x\lt2$).</li>
</ol>', N'<p><b>a)</b> $\sqrt{(2-\sqrt{5})^2}=|2-\sqrt{5}|$. Vì $\sqrt{5}\gt2$ nên $2-\sqrt{5}\lt0$, suy ra $|2-\sqrt{5}|=\sqrt{5}-2$.</p>
<p><b>b)</b> $3\sqrt{x^2}=3|x|$. Với $x\lt0$ thì $|x|=-x$, nên biểu thức bằng $-3x-x+1=1-4x$.</p>
<p><b>c)</b> $\sqrt{x^2-4x+4}=\sqrt{(x-2)^2}=|x-2|$. Với $x\lt2$ thì $x-2\lt0$ nên $|x-2|=2-x$.</p>
<p><b>Đáp số:</b> a) $\sqrt{5}-2$. b) $1-4x$. c) $2-x$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.6.</b> Không dùng MTCT, chứng tỏ biểu thức $A$ có giá trị là số nguyên: $$A=\sqrt{(1+2\sqrt{2})^2}-\sqrt{(1-2\sqrt{2})^2}.$$</p>', N'<p>$\sqrt{(1+2\sqrt{2})^2}=|1+2\sqrt{2}|=1+2\sqrt{2}$ (vì $1+2\sqrt{2}\gt0$).</p>
<p>$\sqrt{(1-2\sqrt{2})^2}=|1-2\sqrt{2}|$. Vì $2\sqrt{2}=\sqrt{8}\gt1$ nên $1-2\sqrt{2}\lt0$ và $|1-2\sqrt{2}|=2\sqrt{2}-1$.</p>
<p>Do đó $A=(1+2\sqrt{2})-(2\sqrt{2}-1)=2$, là số nguyên.</p>
<p><b>Đáp số:</b> $A=2$.</p>', 2, 0, 1, @t1);

-- Bài 8
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 8. Khai căn bậc hai với phép nhân và phép chia', N'Liên hệ giữa phép khai căn bậc hai với phép nhân và phép chia; nhân, chia các căn bậc hai.', N'<p><b>1. Khai căn bậc hai và phép nhân.</b> Với $A,B$ là các biểu thức không âm ta có $$\sqrt{A}\cdot\sqrt{B}=\sqrt{AB}.$$ Mở rộng: $\sqrt{A}\cdot\sqrt{B}\cdot\sqrt{C}=\sqrt{ABC}$ (với $A,B,C\ge0$). Nếu $A,B,C\ge0$ thì $\sqrt{A^2B^2C^2}=ABC$.</p>
<p><b>Ví dụ 1.</b> a) $\sqrt{27}\cdot\sqrt{3}=\sqrt{81}=9$. b) $\sqrt{5}(\sqrt{125}+\sqrt{5})=\sqrt{625}+\sqrt{25}=25+5=30$.</p>
<p><b>Ví dụ 2.</b> Rút gọn $\sqrt{5x}\cdot\sqrt{20x}$ với $x\ge0$: $\sqrt{100x^2}=\sqrt{(10x)^2}=|10x|=10x$.</p>
<p><b>Ví dụ 3.</b> $\sqrt{2^2\cdot3^2\cdot5^2}=2\cdot3\cdot5=30$.</p>
<p><b>Ví dụ 4.</b> Rút gọn $\sqrt{25a^2b^2}$ với $a\ge0,\ b\lt0$: $\sqrt{25}\cdot\sqrt{a^2}\cdot\sqrt{b^2}=5|a|\cdot|b|=-5ab$.</p>
<p><b>2. Khai căn bậc hai và phép chia.</b> Nếu $A,B$ là các biểu thức với $A\ge0,\ B\gt0$ thì $$\dfrac{\sqrt{A}}{\sqrt{B}}=\sqrt{\dfrac{A}{B}}.$$</p>
<p><b>Ví dụ 5.</b> a) $\sqrt{8}:\sqrt{2}=\sqrt{4}=2$. b) $\sqrt{52a^3}:\sqrt{13a}=\sqrt{4a^2}=|2a|=2a$ (với $a\gt0$).</p>
<p><b>Ví dụ 6.</b> a) $1{,}69=\dfrac{169}{100}=\dfrac{13^2}{10^2}$ nên $\sqrt{1{,}69}=\dfrac{13}{10}=1{,}3$. b) Với $a\gt0$: $a\cdot\sqrt{\dfrac{2}{a^2}}=a\cdot\dfrac{\sqrt{2}}{a}=\sqrt{2}$.</p>
<p><b>Vận dụng.</b> Từ $U=\sqrt{PR}$: nếu $P$ tăng 8 lần, $R$ giảm 2 lần thì $U''=\sqrt{8P\cdot\dfrac{R}{2}}=\sqrt{4PR}=2\sqrt{PR}=2U$. Tỉ số hiệu điện thế là $2$.</p>
<p><b>Tranh luận.</b> Cách làm $\sqrt{(-3)^2\cdot(-12)^2}=\sqrt{(-3)^2}\cdot\sqrt{(-12)^2}=(-3)\cdot(-12)=36$ là sai ở chỗ $\sqrt{(-3)^2}=|-3|=3$ chứ không bằng $-3$. Đúng ra: $3\cdot12=36$ (kết quả cuối trùng nhưng lập luận sai).</p>', 2, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.7.</b> Tính:</p>
<ol type="a">
<li>$\sqrt{12}\cdot(\sqrt{12}+\sqrt{3})$;</li>
<li>$\sqrt{8}\cdot(\sqrt{50}-\sqrt{2})$;</li>
<li>$(\sqrt{3}+\sqrt{2})^2-2\sqrt{6}$.</li>
</ol>', N'<p><b>a)</b> $\sqrt{12}\cdot\sqrt{12}+\sqrt{12}\cdot\sqrt{3}=12+\sqrt{36}=12+6=18$.</p>
<p><b>b)</b> $\sqrt{8}\cdot\sqrt{50}-\sqrt{8}\cdot\sqrt{2}=\sqrt{400}-\sqrt{16}=20-4=16$.</p>
<p><b>c)</b> $(\sqrt{3}+\sqrt{2})^2=3+2\sqrt{6}+2=5+2\sqrt{6}$ nên biểu thức bằng $5+2\sqrt{6}-2\sqrt{6}=5$.</p>
<p><b>Đáp số:</b> a) $18$. b) $16$. c) $5$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.8.</b> Rút gọn biểu thức $\sqrt{2(a^2-b^2)}\cdot\sqrt{\dfrac{3}{a+b}}$ (với $a\ge b\gt0$).</p>', N'<p>Vì $a\ge b\gt0$ nên $a^2-b^2\ge0$ và $a+b\gt0$. Khi đó $$\sqrt{2(a^2-b^2)}\cdot\sqrt{\dfrac{3}{a+b}}=\sqrt{\dfrac{6(a-b)(a+b)}{a+b}}=\sqrt{6(a-b)}.$$</p>
<p><b>Đáp số:</b> $\sqrt{6(a-b)}$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.9.</b> Tính:</p>
<ol type="a">
<li>$\sqrt{99}:\sqrt{11}$;</li>
<li>$\sqrt{7{,}84}$;</li>
<li>$\sqrt{1815}:\sqrt{15}$.</li>
</ol>', N'<p><b>a)</b> $\sqrt{99}:\sqrt{11}=\sqrt{99:11}=\sqrt{9}=3$.</p>
<p><b>b)</b> $7{,}84=\dfrac{784}{100}=\dfrac{28^2}{10^2}$ nên $\sqrt{7{,}84}=\dfrac{28}{10}=2{,}8$.</p>
<p><b>c)</b> $\sqrt{1815}:\sqrt{15}=\sqrt{1815:15}=\sqrt{121}=11$.</p>
<p><b>Đáp số:</b> a) $3$. b) $2{,}8$. c) $11$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.10.</b> Rút gọn $\dfrac{-3\sqrt{16a}+5a\sqrt{16ab^2}}{2\sqrt{a}}$ (với $a\gt0,\ b\gt0$).</p>', N'<p>Ta có $\sqrt{16a}=4\sqrt{a}$ và $\sqrt{16ab^2}=4b\sqrt{a}$ (vì $a,b\gt0$).</p>
<p>Tử số: $-3\cdot4\sqrt{a}+5a\cdot4b\sqrt{a}=\sqrt{a}\,(-12+20ab)$.</p>
<p>Chia cho $2\sqrt{a}$: $\dfrac{\sqrt{a}\,(20ab-12)}{2\sqrt{a}}=10ab-6$.</p>
<p><b>Đáp số:</b> $10ab-6$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.11.</b> Kích thước màn hình ti vi hình chữ nhật được xác định bởi độ dài đường chéo. Một loại ti vi có tỉ lệ hai cạnh màn hình là $4:3$.</p>
<ol type="a">
<li>Gọi $x$ (inch) là chiều rộng của màn hình ti vi. Viết công thức tính độ dài đường chéo của màn hình ti vi theo $x$.</li>
<li>Tính chiều rộng và chiều dài (theo centimét) của màn hình ti vi loại 40 inch.</li>
</ol>', N'<p><b>a)</b> Cạnh $x$ ứng với 4 phần thì cạnh kia bằng $\dfrac{3}{4}x$. Đường chéo $$d=\sqrt{x^2+\left(\dfrac{3}{4}x\right)^2}=\sqrt{\dfrac{25}{16}x^2}=\dfrac{5}{4}x\ \text{(inch)}.$$</p>
<p><b>b)</b> Ti vi 40 inch có $d=40$: $\dfrac{5}{4}x=40$ nên $x=32$ inch, cạnh còn lại $\dfrac{3}{4}\cdot32=24$ inch. Đổi ra centimét (1 inch $=2{,}54$ cm): $32\cdot2{,}54=81{,}28$ cm và $24\cdot2{,}54=60{,}96$ cm.</p>
<p><b>Đáp số:</b> a) $d=\dfrac{5}{4}x$. b) hai cạnh khoảng $81{,}28$ cm và $60{,}96$ cm.</p>', 2, 0, 1, @t1);

-- Luyện tập chung (Bài 7 - Bài 8)
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Luyện tập chung (Bài 7 - Bài 8)', N'Hằng đẳng thức hiệu hai bình phương với căn thức, biểu thức liên hợp và rút gọn biểu thức chứa căn bậc hai.', N'<p><b>Ví dụ 1.</b> Không dùng MTCT, tính $A=\sqrt{(1-\sqrt{3})^2}-\sqrt{3}$. Ta có $A=|1-\sqrt{3}|-\sqrt{3}=(\sqrt{3}-1)-\sqrt{3}=-1$.</p>
<p><b>Ví dụ 2.</b> Dùng hằng đẳng thức hiệu hai bình phương: a) $(2+\sqrt{5})(2-\sqrt{5})=2^2-(\sqrt{5})^2=4-5=-1$. b) $(\sqrt{5}+\sqrt{2})(\sqrt{5}-\sqrt{2})=5-2=3$.</p>
<p><b>Chú ý.</b> Với $A,B$ là hai biểu thức, $B\ge0$: $(A+\sqrt{B})(A-\sqrt{B})=A^2-B$. Với $A,B$ không âm: $(\sqrt{A}+\sqrt{B})(\sqrt{A}-\sqrt{B})=A-B$. Các cặp $A+\sqrt{B}$ và $A-\sqrt{B}$; $\sqrt{A}+\sqrt{B}$ và $\sqrt{A}-\sqrt{B}$ gọi là những cặp <b>biểu thức liên hợp</b>.</p>
<p><b>Ví dụ 3.</b> Cho $P=\dfrac{x\sqrt{x}+1}{x-\sqrt{x}+1}-1$ với $x\ge0$. a) Viết $x\sqrt{x}+1=(\sqrt{x})^3+1^3=(\sqrt{x}+1)(x-\sqrt{x}+1)$ nên $P=(\sqrt{x}+1)-1=\sqrt{x}$. b) Tại $x=100$: $P=\sqrt{100}=10$.</p>', 3, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.12.</b> Rút gọn các biểu thức sau:</p>
<ol type="a">
<li>$\sqrt{(\sqrt{3}-\sqrt{2})^2}+\sqrt{(1-\sqrt{2})^2}$;</li>
<li>$\sqrt{(\sqrt{7}-3)^2}+\sqrt{(\sqrt{7}+3)^2}$.</li>
</ol>', N'<p><b>a)</b> $\sqrt{3}\gt\sqrt{2}$ nên $\sqrt{(\sqrt{3}-\sqrt{2})^2}=\sqrt{3}-\sqrt{2}$; $\sqrt{2}\gt1$ nên $\sqrt{(1-\sqrt{2})^2}=\sqrt{2}-1$. Tổng: $\sqrt{3}-\sqrt{2}+\sqrt{2}-1=\sqrt{3}-1$.</p>
<p><b>b)</b> $\sqrt{7}\lt3$ nên $\sqrt{(\sqrt{7}-3)^2}=3-\sqrt{7}$; $\sqrt{(\sqrt{7}+3)^2}=\sqrt{7}+3$. Tổng: $3-\sqrt{7}+\sqrt{7}+3=6$.</p>
<p><b>Đáp số:</b> a) $\sqrt{3}-1$. b) $6$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.13.</b> Thực hiện phép tính:</p>
<ol type="a">
<li>$\sqrt{3}(\sqrt{192}-\sqrt{75})$;</li>
<li>$\dfrac{-3\sqrt{18}+5\sqrt{50}-\sqrt{128}}{7\sqrt{2}}$.</li>
</ol>', N'<p><b>a)</b> $\sqrt{192}=8\sqrt{3}$, $\sqrt{75}=5\sqrt{3}$ nên $\sqrt{3}(8\sqrt{3}-5\sqrt{3})=\sqrt{3}\cdot3\sqrt{3}=9$.</p>
<p><b>b)</b> $\sqrt{18}=3\sqrt{2}$, $\sqrt{50}=5\sqrt{2}$, $\sqrt{128}=8\sqrt{2}$. Tử số: $-9\sqrt{2}+25\sqrt{2}-8\sqrt{2}=8\sqrt{2}$. Biểu thức bằng $\dfrac{8\sqrt{2}}{7\sqrt{2}}=\dfrac{8}{7}$.</p>
<p><b>Đáp số:</b> a) $9$. b) $\dfrac{8}{7}$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.14.</b> Chứng minh rằng:</p>
<ol type="a">
<li>$(1-\sqrt{2})^2=3-2\sqrt{2}$;</li>
<li>$(\sqrt{3}+\sqrt{2})^2=5+2\sqrt{6}$.</li>
</ol>', N'<p><b>a)</b> $(1-\sqrt{2})^2=1-2\sqrt{2}+(\sqrt{2})^2=1-2\sqrt{2}+2=3-2\sqrt{2}$.</p>
<p><b>b)</b> $(\sqrt{3}+\sqrt{2})^2=3+2\sqrt{3}\cdot\sqrt{2}+2=5+2\sqrt{6}$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.15.</b> Cho căn thức $\sqrt{x^2-4x+4}$.</p>
<ol type="a">
<li>Hãy chứng tỏ rằng căn thức xác định với mọi giá trị của $x$.</li>
<li>Rút gọn căn thức đã cho với $x\ge2$.</li>
<li>Chứng tỏ rằng với mọi $x\ge2$, biểu thức $\sqrt{x-\sqrt{x^2-4x+4}}$ có giá trị không đổi.</li>
</ol>', N'<p><b>a)</b> $x^2-4x+4=(x-2)^2\ge0$ với mọi $x$ nên căn thức xác định với mọi $x$.</p>
<p><b>b)</b> $\sqrt{x^2-4x+4}=\sqrt{(x-2)^2}=|x-2|=x-2$ (vì $x\ge2$).</p>
<p><b>c)</b> $\sqrt{x-\sqrt{x^2-4x+4}}=\sqrt{x-(x-2)}=\sqrt{2}$ với mọi $x\ge2$, là một hằng số.</p>
<p><b>Đáp số:</b> b) $x-2$. c) biểu thức luôn bằng $\sqrt{2}$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.16.</b> Vận tốc (m/s) của một vật đang bay được cho bởi công thức $v=\sqrt{\dfrac{2E}{m}}$, trong đó $E$ là động năng của vật (tính bằng Joule, kí hiệu là J) và $m$ (kg) là khối lượng của vật. Tính vận tốc bay của một vật khi biết vật đó có khối lượng 2,5 kg và động năng 281,25 J.</p>', N'<p>Thay $E=281{,}25$ và $m=2{,}5$: $v=\sqrt{\dfrac{2\cdot281{,}25}{2{,}5}}=\sqrt{\dfrac{562{,}5}{2{,}5}}=\sqrt{225}=15$.</p>
<p><b>Đáp số:</b> $15$ m/s.</p>', 1, 0, 1, @t1);

-- Bài 9
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 9. Biến đổi đơn giản và rút gọn biểu thức chứa căn thức bậc hai', N'Đưa thừa số ra ngoài hoặc vào trong dấu căn, khử mẫu của biểu thức lấy căn, trục căn thức ở mẫu và rút gọn biểu thức chứa căn bậc hai.', N'<p><b>1. Đưa thừa số ra ngoài dấu căn.</b> Nếu $a$ là một số và $b$ là một số không âm thì $$\sqrt{a^2b}=|a|\sqrt{b}.$$ Phép biến đổi này gọi là phép đưa thừa số ra ngoài dấu căn.</p>
<p><b>Ví dụ 1.</b> a) $\sqrt{45}=\sqrt{3^2\cdot5}=3\sqrt{5}$. b) $\sqrt{243a}=\sqrt{9^2\cdot3a}=9\sqrt{3a}$ ($a\ge0$).</p>
<p><b>Khử mẫu của biểu thức lấy căn</b> là biến đổi căn thức thành biểu thức mà trong căn không còn mẫu. <b>Ví dụ 2.</b> $\sqrt{\dfrac{4}{7}}=\sqrt{\dfrac{4\cdot7}{7^2}}=\dfrac{2\sqrt{7}}{7}$.</p>
<p><b>Tranh luận.</b> Cách làm $\sqrt{(-2)^2\cdot5}=-2\sqrt{5}$ là sai vì $\sqrt{(-2)^2\cdot5}=|-2|\sqrt{5}=2\sqrt{5}$.</p>
<p><b>2. Đưa thừa số vào trong dấu căn.</b> Nếu $a,b$ là hai số không âm thì $a\sqrt{b}=\sqrt{a^2b}$. Nếu $a$ là số âm và $b$ không âm thì $a\sqrt{b}=-\sqrt{a^2b}$.</p>
<p><b>Ví dụ 3.</b> a) $5\sqrt{2}=\sqrt{5^2\cdot2}=\sqrt{50}$. b) $-2\sqrt{a}=-\sqrt{2^2a}=-\sqrt{4a}$ ($a\ge0$).</p>
<p><b>Ví dụ 4 (câu hỏi mở đầu).</b> $3\sqrt{2}=\sqrt{18}$ và $2\sqrt{3}=\sqrt{12}$. Vì $\sqrt{12}\lt\sqrt{18}$ nên $2\sqrt{3}\lt3\sqrt{2}$.</p>
<p><b>3. Trục căn thức ở mẫu.</b> Là biến đổi biểu thức thành biểu thức mới không chứa căn ở mẫu.</p>
<ul>
<li>Với $A,B$ và $B\gt0$: $\dfrac{A}{\sqrt{B}}=\dfrac{A\sqrt{B}}{B}$.</li>
<li>Với $A\ge0,\ A\neq B^2$: $\dfrac{C}{\sqrt{A}+B}=\dfrac{C(\sqrt{A}-B)}{A-B^2}$; $\dfrac{C}{\sqrt{A}-B}=\dfrac{C(\sqrt{A}+B)}{A-B^2}$.</li>
<li>Với $A\ge0,\ B\ge0,\ A\neq B$: $\dfrac{C}{\sqrt{A}+\sqrt{B}}=\dfrac{C(\sqrt{A}-\sqrt{B})}{A-B}$; $\dfrac{C}{\sqrt{A}-\sqrt{B}}=\dfrac{C(\sqrt{A}+\sqrt{B})}{A-B}$.</li>
</ul>
<p><b>Ví dụ 5.</b> a) $\dfrac{2}{3\sqrt{5}}=\dfrac{2\sqrt{5}}{3\cdot5}=\dfrac{2\sqrt{5}}{15}$. b) $\dfrac{a}{3-2\sqrt{2}}=\dfrac{a(3+2\sqrt{2})}{9-8}=(3+2\sqrt{2})a$.</p>
<p><b>4. Rút gọn biểu thức chứa căn thức bậc hai.</b> Cần phối hợp các phép tính (cộng, trừ, nhân, chia) và các phép biến đổi đã học (đưa thừa số ra ngoài hoặc vào trong dấu căn; khử mẫu của biểu thức lấy căn; trục căn thức ở mẫu).</p>
<p><b>Ví dụ 6.</b> Rút gọn $A=2\sqrt{3}-\sqrt{75}+\sqrt{(1-\sqrt{3})^2}$. Ta có $\sqrt{75}=5\sqrt{3}$ và $\sqrt{(1-\sqrt{3})^2}=\sqrt{3}-1$ nên $A=2\sqrt{3}-5\sqrt{3}+\sqrt{3}-1=-1-2\sqrt{3}$.</p>
<p><b>Ví dụ 7.</b> Với $x\ge0,\ x\neq1$: $\dfrac{x^2-1}{\sqrt{x}-1}=(x+1)(\sqrt{x}+1)=x\sqrt{x}+\sqrt{x}+x+1$ và $\dfrac{x^2-x}{\sqrt{x}+1}=x(\sqrt{x}-1)=x\sqrt{x}-x$. Từ đó $P=\dfrac{x^2-1}{\sqrt{x}-1}-\dfrac{x^2-x}{\sqrt{x}+1}=2x+\sqrt{x}+1$.</p>
<p><b>Vận dụng.</b> Từ $m=\dfrac{m_0}{\sqrt{1-\dfrac{v^2}{c^2}}}$, trục căn thức ở mẫu: $m=\dfrac{m_0\sqrt{1-\dfrac{v^2}{c^2}}}{1-\dfrac{v^2}{c^2}}$. Khi $v=\dfrac{1}{10}c$: $m=\dfrac{m_0}{\sqrt{0{,}99}}\approx1{,}005\,m_0$.</p>', 4, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.17.</b> Đưa thừa số ra ngoài dấu căn:</p>
<ol type="a">
<li>$\sqrt{52}$;</li>
<li>$\sqrt{27a}$ ($a\ge0$);</li>
<li>$\sqrt{50\sqrt{2}+100}$;</li>
<li>$\sqrt{9\sqrt{5}-18}$.</li>
</ol>', N'<p><b>a)</b> $\sqrt{52}=\sqrt{2^2\cdot13}=2\sqrt{13}$.</p>
<p><b>b)</b> $\sqrt{27a}=\sqrt{3^2\cdot3a}=3\sqrt{3a}$.</p>
<p><b>c)</b> $50\sqrt{2}+100=25(2\sqrt{2}+4)$ nên $\sqrt{50\sqrt{2}+100}=5\sqrt{4+2\sqrt{2}}$.</p>
<p><b>d)</b> $9\sqrt{5}-18=9(\sqrt{5}-2)$, trong đó $\sqrt{5}\gt2$ nên biểu thức dưới căn dương; $\sqrt{9\sqrt{5}-18}=3\sqrt{\sqrt{5}-2}$.</p>
<p><b>Đáp số:</b> a) $2\sqrt{13}$. b) $3\sqrt{3a}$. c) $5\sqrt{4+2\sqrt{2}}$. d) $3\sqrt{\sqrt{5}-2}$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.18.</b> Đưa thừa số vào trong dấu căn:</p>
<ol type="a">
<li>$4\sqrt{3}$;</li>
<li>$-2\sqrt{7}$;</li>
<li>$4\sqrt{\dfrac{15}{2}}$;</li>
<li>$-5\sqrt{\dfrac{16}{5}}$.</li>
</ol>', N'<p><b>a)</b> $4\sqrt{3}=\sqrt{16\cdot3}=\sqrt{48}$.</p>
<p><b>b)</b> $-2\sqrt{7}=-\sqrt{4\cdot7}=-\sqrt{28}$.</p>
<p><b>c)</b> $4\sqrt{\dfrac{15}{2}}=\sqrt{16\cdot\dfrac{15}{2}}=\sqrt{120}$.</p>
<p><b>d)</b> $-5\sqrt{\dfrac{16}{5}}=-\sqrt{25\cdot\dfrac{16}{5}}=-\sqrt{80}$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.19.</b> Khử mẫu trong dấu căn:</p>
<ol type="a">
<li>$2a\cdot\sqrt{\dfrac{3}{5}}$;</li>
<li>$-3x\cdot\sqrt{\dfrac{5}{x}}$ ($x\gt0$);</li>
<li>$-\sqrt{\dfrac{3a}{b}}$ ($a\ge0,\ b\gt0$).</li>
</ol>', N'<p><b>a)</b> $\sqrt{\dfrac{3}{5}}=\sqrt{\dfrac{15}{25}}=\dfrac{\sqrt{15}}{5}$ nên $2a\cdot\sqrt{\dfrac{3}{5}}=\dfrac{2a\sqrt{15}}{5}$.</p>
<p><b>b)</b> $\sqrt{\dfrac{5}{x}}=\sqrt{\dfrac{5x}{x^2}}=\dfrac{\sqrt{5x}}{x}$ (vì $x\gt0$) nên $-3x\cdot\sqrt{\dfrac{5}{x}}=-3\sqrt{5x}$.</p>
<p><b>c)</b> $\sqrt{\dfrac{3a}{b}}=\sqrt{\dfrac{3ab}{b^2}}=\dfrac{\sqrt{3ab}}{b}$ nên $-\sqrt{\dfrac{3a}{b}}=-\dfrac{\sqrt{3ab}}{b}$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.20.</b> Trục căn thức ở mẫu:</p>
<ol type="a">
<li>$\dfrac{4+3\sqrt{5}}{\sqrt{5}}$;</li>
<li>$\dfrac{1}{\sqrt{5}-2}$;</li>
<li>$\dfrac{3+\sqrt{3}}{1-\sqrt{3}}$;</li>
<li>$\dfrac{\sqrt{2}}{\sqrt{3}+\sqrt{2}}$.</li>
</ol>', N'<p><b>a)</b> $\dfrac{(4+3\sqrt{5})\sqrt{5}}{5}=\dfrac{4\sqrt{5}+15}{5}=3+\dfrac{4\sqrt{5}}{5}$.</p>
<p><b>b)</b> $\dfrac{\sqrt{5}+2}{(\sqrt{5}-2)(\sqrt{5}+2)}=\dfrac{\sqrt{5}+2}{5-4}=\sqrt{5}+2$.</p>
<p><b>c)</b> $\dfrac{(3+\sqrt{3})(1+\sqrt{3})}{1-3}=\dfrac{3+3\sqrt{3}+\sqrt{3}+3}{-2}=\dfrac{6+4\sqrt{3}}{-2}=-3-2\sqrt{3}$.</p>
<p><b>d)</b> $\dfrac{\sqrt{2}(\sqrt{3}-\sqrt{2})}{3-2}=\sqrt{6}-2$.</p>
<p><b>Đáp số:</b> a) $3+\dfrac{4\sqrt{5}}{5}$. b) $\sqrt{5}+2$. c) $-3-2\sqrt{3}$. d) $\sqrt{6}-2$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.21.</b> Rút gọn các biểu thức sau:</p>
<ol type="a">
<li>$2\sqrt{\dfrac{2}{3}}-4\sqrt{\dfrac{3}{2}}$;</li>
<li>$\dfrac{5\sqrt{48}-3\sqrt{27}+2\sqrt{12}}{\sqrt{3}}$;</li>
<li>$\dfrac{1}{3+2\sqrt{2}}+\dfrac{4\sqrt{2}-4}{2-\sqrt{2}}$.</li>
</ol>', N'<p><b>a)</b> $\sqrt{\dfrac{2}{3}}=\dfrac{\sqrt{6}}{3}$, $\sqrt{\dfrac{3}{2}}=\dfrac{\sqrt{6}}{2}$ nên biểu thức bằng $\dfrac{2\sqrt{6}}{3}-2\sqrt{6}=\dfrac{2\sqrt{6}-6\sqrt{6}}{3}=-\dfrac{4\sqrt{6}}{3}$.</p>
<p><b>b)</b> $\sqrt{48}=4\sqrt{3}$, $\sqrt{27}=3\sqrt{3}$, $\sqrt{12}=2\sqrt{3}$. Tử số: $20\sqrt{3}-9\sqrt{3}+4\sqrt{3}=15\sqrt{3}$. Biểu thức bằng $15$.</p>
<p><b>c)</b> $\dfrac{1}{3+2\sqrt{2}}=\dfrac{3-2\sqrt{2}}{9-8}=3-2\sqrt{2}$. $\dfrac{4\sqrt{2}-4}{2-\sqrt{2}}=\dfrac{4(\sqrt{2}-1)(2+\sqrt{2})}{4-2}=2(2\sqrt{2}+2-2-\sqrt{2})=2\sqrt{2}$. Tổng: $3-2\sqrt{2}+2\sqrt{2}=3$.</p>
<p><b>Đáp số:</b> a) $-\dfrac{4\sqrt{6}}{3}$. b) $15$. c) $3$.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.22.</b> Rút gọn biểu thức $A=\sqrt{x}\left(\dfrac{1}{\sqrt{x}+3}-\dfrac{1}{3-\sqrt{x}}\right)$ ($x\ge0,\ x\neq9$).</p>', N'<p>$\dfrac{1}{\sqrt{x}+3}-\dfrac{1}{3-\sqrt{x}}=\dfrac{(3-\sqrt{x})-(\sqrt{x}+3)}{(\sqrt{x}+3)(3-\sqrt{x})}=\dfrac{-2\sqrt{x}}{9-x}$.</p>
<p>Do đó $A=\sqrt{x}\cdot\dfrac{-2\sqrt{x}}{9-x}=\dfrac{-2x}{9-x}=\dfrac{2x}{x-9}$.</p>
<p><b>Đáp số:</b> $A=\dfrac{2x}{x-9}$.</p>', 3, 0, 1, @t1);

-- Bài 10
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 10. Căn bậc ba và căn thức bậc ba', N'Khái niệm căn bậc ba của một số thực, tính căn bậc ba bằng máy tính cầm tay, căn thức bậc ba của một biểu thức đại số.', N'<p><b>1. Căn bậc ba.</b> Căn bậc ba của số thực $a$ là số thực $x$ thỏa mãn $x^3=a$.</p>
<p><b>Chú ý.</b> Mỗi số $a$ đều có duy nhất một căn bậc ba, kí hiệu $\sqrt[3]{a}$ (số 3 gọi là chỉ số của căn). Phép tìm căn bậc ba của một số gọi là phép khai căn bậc ba.</p>
<p><b>Ví dụ 1.</b> a) $4^3=64$ nên $\sqrt[3]{64}=4$. b) $0^3=0$ nên $\sqrt[3]{0}=0$; $(-3)^3=-27$ nên $\sqrt[3]{-27}=-3$.</p>
<p><b>Nhận xét.</b> $(\sqrt[3]{a})^3=\sqrt[3]{a^3}=a$ với mọi số thực $a$.</p>
<p><b>Ví dụ 2 (dùng MTCT).</b> Bấm SHIFT, $\sqrt{\ }$, rồi nhập $3{,}25$ được $1{,}481248034$. Vậy $\sqrt[3]{3{,}25}\approx1{,}48$ (làm tròn đến chữ số thập phân thứ hai).</p>
<p><b>2. Căn thức bậc ba.</b> Căn thức bậc ba là biểu thức có dạng $\sqrt[3]{A}$, trong đó $A$ là một biểu thức đại số. Ta có $(\sqrt[3]{A})^3=\sqrt[3]{A^3}=A$.</p>
<p><b>Ví dụ 3.</b> Giá trị của $\sqrt[3]{2x+5}$ tại $x=60$ là $\sqrt[3]{125}=5$; tại $x=-6{,}5$ là $\sqrt[3]{-8}=-2$.</p>
<p><b>Ví dụ 4.</b> Rút gọn $-x+5+\sqrt[3]{x^3+3x^2+3x+1}$. Vì $x^3+3x^2+3x+1=(x+1)^3$ nên biểu thức bằng $-x+5+(x+1)=6$.</p>', 5, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.23.</b> Tính:</p>
<ol type="a">
<li>$\sqrt[3]{216}$;</li>
<li>$\sqrt[3]{-512}$;</li>
<li>$\sqrt[3]{-0{,}001}$;</li>
<li>$\sqrt[3]{1{,}331}$.</li>
</ol>', N'<p><b>a)</b> $6^3=216$ nên $\sqrt[3]{216}=6$.</p>
<p><b>b)</b> $(-8)^3=-512$ nên $\sqrt[3]{-512}=-8$.</p>
<p><b>c)</b> $(-0{,}1)^3=-0{,}001$ nên $\sqrt[3]{-0{,}001}=-0{,}1$.</p>
<p><b>d)</b> $1{,}1^3=1{,}331$ nên $\sqrt[3]{1{,}331}=1{,}1$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.24.</b> Sử dụng MTCT, tính các căn bậc ba sau đây (làm tròn kết quả đến chữ số thập phân thứ hai):</p>
<ol type="a">
<li>$\sqrt[3]{2{,}1}$;</li>
<li>$\sqrt[3]{-18}$;</li>
<li>$\sqrt[3]{-28}$;</li>
<li>$\sqrt[3]{0{,}35}$.</li>
</ol>', N'<p><b>a)</b> $\sqrt[3]{2{,}1}\approx1{,}2806\approx1{,}28$.</p>
<p><b>b)</b> $\sqrt[3]{-18}\approx-2{,}6207\approx-2{,}62$.</p>
<p><b>c)</b> $\sqrt[3]{-28}\approx-3{,}0366\approx-3{,}04$.</p>
<p><b>d)</b> $\sqrt[3]{0{,}35}\approx0{,}7047\approx0{,}70$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.25.</b> Một người thợ muốn làm một thùng tôn hình lập phương có thể tích bằng $730\ \text{dm}^3$. Em hãy ước lượng chiều dài cạnh thùng khoảng bao nhiêu decimét.</p>', N'<p>Gọi $x$ (dm) là độ dài cạnh thùng ($x\gt0$). Thể tích $x^3=730$ nên $x=\sqrt[3]{730}\approx9{,}001$.</p>
<p>(Nhận xét: $9^3=729$ rất gần 730.)</p>
<p><b>Đáp số:</b> cạnh thùng khoảng $9$ dm.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.26.</b> Rút gọn các biểu thức sau:</p>
<ol type="a">
<li>$\sqrt[3]{(1-\sqrt{2})^3}$;</li>
<li>$\sqrt[3]{(2\sqrt{2}+1)^3}$;</li>
<li>$(\sqrt[3]{\sqrt{2}+1})^3$.</li>
</ol>', N'<p>Dùng $\sqrt[3]{A^3}=A$ và $(\sqrt[3]{A})^3=A$:</p>
<p><b>a)</b> $1-\sqrt{2}$. <b>b)</b> $2\sqrt{2}+1$. <b>c)</b> $\sqrt{2}+1$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.27.</b> Rút gọn rồi tính giá trị của biểu thức $\sqrt[3]{27x^3-27x^2+9x-1}$ tại $x=7$.</p>', N'<p>Ta có $27x^3-27x^2+9x-1=(3x-1)^3$ (hằng đẳng thức lập phương của một hiệu).</p>
<p>Do đó $\sqrt[3]{27x^3-27x^2+9x-1}=\sqrt[3]{(3x-1)^3}=3x-1$.</p>
<p>Tại $x=7$: $3\cdot7-1=20$.</p>
<p><b>Đáp số:</b> $3x-1$; giá trị bằng $20$.</p>', 2, 0, 1, @t1);

-- Luyện tập chung (Bài 9 - Bài 10)
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Luyện tập chung (Bài 9 - Bài 10)', N'Rút gọn biểu thức chứa căn bậc hai và căn bậc ba; bài toán thực tế về thể tích hình lập phương.', N'<p><b>Ví dụ 1.</b> Rút gọn $A=\sqrt{(\sqrt{3}+1)^2}-\sqrt{3(\sqrt{3}+1)^2}+\sqrt{4}$. Ta có $A=(\sqrt{3}+1)-\sqrt{3}(\sqrt{3}+1)+2=\sqrt{3}+1-3-\sqrt{3}+2=0$.</p>
<p><b>Ví dụ 2.</b> Cho $P=\dfrac{\sqrt{x}}{\sqrt{x}+1}+\dfrac{\sqrt{x}}{\sqrt{x}-1}$ với $x\ge0,\ x\neq1$. a) Quy đồng: $P=\dfrac{\sqrt{x}(\sqrt{x}-1)+\sqrt{x}(\sqrt{x}+1)}{(\sqrt{x}+1)(\sqrt{x}-1)}=\dfrac{2x}{x-1}$. b) Khi $x=101$: $P=\dfrac{2\cdot101}{100}=2{,}02$.</p>
<p><b>Ví dụ 3.</b> Một thùng hình lập phương bằng bìa cứng không có nắp trên, thể tích $216\ \text{dm}^3$. Gọi $x$ (dm) là độ dài cạnh: $x^3=216$ nên $x=\sqrt[3]{216}=6$. Thùng gồm 4 mặt bên và 1 mặt đáy, mỗi mặt là hình vuông cạnh 6 dm nên diện tích bìa cứng là $S=5\cdot6^2=180\ (\text{dm}^2)$.</p>', 6, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.28.</b> Rút gọn các biểu thức sau:</p>
<ol type="a">
<li>$\dfrac{5+3\sqrt{5}}{\sqrt{5}}-\dfrac{1}{\sqrt{5}-2}$;</li>
<li>$\sqrt{(\sqrt{7}-2)^2}-\sqrt{63}+\dfrac{\sqrt{56}}{\sqrt{2}}$;</li>
<li>$\dfrac{\sqrt{(\sqrt{3}+\sqrt{2})^2}+\sqrt{(\sqrt{3}-\sqrt{2})^2}}{2\sqrt{12}}$;</li>
<li>$\dfrac{\sqrt[3]{(\sqrt{2}+1)^3}-1}{\sqrt{50}}$.</li>
</ol>', N'<p><b>a)</b> $\dfrac{5+3\sqrt{5}}{\sqrt{5}}=\dfrac{5\sqrt{5}+15}{5}=\sqrt{5}+3$; $\dfrac{1}{\sqrt{5}-2}=\sqrt{5}+2$. Hiệu: $(\sqrt{5}+3)-(\sqrt{5}+2)=1$.</p>
<p><b>b)</b> $\sqrt{(\sqrt{7}-2)^2}=\sqrt{7}-2$; $\sqrt{63}=3\sqrt{7}$; $\dfrac{\sqrt{56}}{\sqrt{2}}=\sqrt{28}=2\sqrt{7}$. Tổng: $\sqrt{7}-2-3\sqrt{7}+2\sqrt{7}=-2$.</p>
<p><b>c)</b> Tử số: $(\sqrt{3}+\sqrt{2})+(\sqrt{3}-\sqrt{2})=2\sqrt{3}$ (vì $\sqrt{3}\gt\sqrt{2}$). Mẫu: $2\sqrt{12}=4\sqrt{3}$. Biểu thức bằng $\dfrac{2\sqrt{3}}{4\sqrt{3}}=\dfrac{1}{2}$.</p>
<p><b>d)</b> $\sqrt[3]{(\sqrt{2}+1)^3}=\sqrt{2}+1$ nên tử số bằng $\sqrt{2}$; $\sqrt{50}=5\sqrt{2}$. Biểu thức bằng $\dfrac{1}{5}$.</p>
<p><b>Đáp số:</b> a) $1$. b) $-2$. c) $\dfrac{1}{2}$. d) $\dfrac{1}{5}$.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.29.</b> Tính giá trị của các biểu thức sau:</p>
<ol type="a">
<li>$3\sqrt{45}+\dfrac{5\sqrt{15}}{\sqrt{3}}-2\sqrt{245}$;</li>
<li>$\dfrac{\sqrt{12}-\sqrt{4}}{\sqrt{3}-1}-\dfrac{\sqrt{21}+\sqrt{7}}{\sqrt{3}+1}+\sqrt{7}$;</li>
<li>$\dfrac{3-\sqrt{3}}{1-\sqrt{3}}+\sqrt{3}(2\sqrt{3}-1)+\sqrt{12}$;</li>
<li>$\dfrac{\sqrt{3}-1}{\sqrt{2}}+\dfrac{\sqrt{2}}{\sqrt{3}-1}-\dfrac{6}{\sqrt{6}}$.</li>
</ol>', N'<p><b>a)</b> $3\sqrt{45}=9\sqrt{5}$; $\dfrac{5\sqrt{15}}{\sqrt{3}}=5\sqrt{5}$; $2\sqrt{245}=14\sqrt{5}$. Giá trị: $9\sqrt{5}+5\sqrt{5}-14\sqrt{5}=0$.</p>
<p><b>b)</b> $\dfrac{\sqrt{12}-\sqrt{4}}{\sqrt{3}-1}=\dfrac{2(\sqrt{3}-1)}{\sqrt{3}-1}=2$; $\dfrac{\sqrt{21}+\sqrt{7}}{\sqrt{3}+1}=\dfrac{\sqrt{7}(\sqrt{3}+1)}{\sqrt{3}+1}=\sqrt{7}$. Giá trị: $2-\sqrt{7}+\sqrt{7}=2$.</p>
<p><b>c)</b> $\dfrac{3-\sqrt{3}}{1-\sqrt{3}}=\dfrac{\sqrt{3}(\sqrt{3}-1)}{-(\sqrt{3}-1)}=-\sqrt{3}$; $\sqrt{3}(2\sqrt{3}-1)=6-\sqrt{3}$; $\sqrt{12}=2\sqrt{3}$. Giá trị: $-\sqrt{3}+6-\sqrt{3}+2\sqrt{3}=6$.</p>
<p><b>d)</b> $\dfrac{\sqrt{3}-1}{\sqrt{2}}=\dfrac{\sqrt{6}-\sqrt{2}}{2}$; $\dfrac{\sqrt{2}}{\sqrt{3}-1}=\dfrac{\sqrt{2}(\sqrt{3}+1)}{2}=\dfrac{\sqrt{6}+\sqrt{2}}{2}$; hai số hạng đầu cộng lại bằng $\sqrt{6}$. $\dfrac{6}{\sqrt{6}}=\sqrt{6}$. Giá trị: $\sqrt{6}-\sqrt{6}=0$.</p>
<p><b>Đáp số:</b> a) $0$. b) $2$. c) $6$. d) $0$.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.30.</b> Giả sử lực $F$ của gió khi thổi theo phương vuông góc với bề mặt cánh buồm của một con thuyền tỉ lệ thuận với bình phương tốc độ của gió, hệ số tỉ lệ là 30. Trong đó, lực $F$ được tính bằng N (Newton) và tốc độ được tính bằng m/s.</p>
<ol type="a">
<li>Khi tốc độ của gió là 10 m/s thì lực $F$ là bao nhiêu Newton?</li>
<li>Nếu cánh buồm chỉ có thể chịu được một áp lực tối đa là 12 000 N thì con thuyền đó có thể đi được trong gió với tốc độ gió tối đa là bao nhiêu?</li>
</ol>', N'<p>Gọi $v$ (m/s) là tốc độ gió thì $F=30v^2$.</p>
<p><b>a)</b> Với $v=10$: $F=30\cdot10^2=3000$ N.</p>
<p><b>b)</b> Cần $30v^2\le12000$, tức $v^2\le400$, suy ra $v\le\sqrt{400}=20$ (vì $v\gt0$).</p>
<p><b>Đáp số:</b> a) $3000$ N. b) tốc độ gió tối đa $20$ m/s.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.31.</b> Rút gọn các biểu thức sau:</p>
<ol type="a">
<li>$\sqrt[3]{(-x-1)^3}$;</li>
<li>$\sqrt[3]{8x^3-12x^2+6x-1}$.</li>
</ol>', N'<p><b>a)</b> $\sqrt[3]{(-x-1)^3}=-x-1$.</p>
<p><b>b)</b> $8x^3-12x^2+6x-1=(2x-1)^3$ nên $\sqrt[3]{8x^3-12x^2+6x-1}=2x-1$.</p>
<p><b>Đáp số:</b> a) $-x-1$. b) $2x-1$.</p>', 2, 0, 1, @t1);

-- Bài tập cuối chương III
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài tập cuối chương III', N'Ôn tập chương III: căn bậc hai, căn thức bậc hai, các phép biến đổi và rút gọn biểu thức chứa căn, căn bậc ba.', N'<p><b>Tóm tắt kiến thức chương III.</b></p>
<ul>
<li><b>Căn bậc hai:</b> số dương $a$ có hai căn bậc hai là $\sqrt{a}$ và $-\sqrt{a}$; $\sqrt{A}$ xác định khi $A\ge0$; $\sqrt{A^2}=|A|$.</li>
<li><b>Khai căn với phép nhân, chia:</b> $\sqrt{A}\cdot\sqrt{B}=\sqrt{AB}$ ($A,B\ge0$); $\dfrac{\sqrt{A}}{\sqrt{B}}=\sqrt{\dfrac{A}{B}}$ ($A\ge0,\ B\gt0$).</li>
<li><b>Biến đổi đơn giản:</b> đưa thừa số ra ngoài dấu căn $\sqrt{a^2b}=|a|\sqrt{b}$; đưa thừa số vào trong dấu căn; khử mẫu của biểu thức lấy căn; trục căn thức ở mẫu bằng biểu thức liên hợp.</li>
<li><b>Căn bậc ba:</b> mỗi số thực $a$ có duy nhất một căn bậc ba $\sqrt[3]{a}$; $(\sqrt[3]{A})^3=\sqrt[3]{A^3}=A$.</li>
</ul>', 7, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 3.32.</b> Căn bậc hai của $4$ là</p>', N'<p>Số dương $4$ có hai căn bậc hai đối nhau là $\sqrt{4}=2$ và $-2$. Do đó đáp án đúng là C.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$2$.', 0),
(@q, 'B', N'$-2$.', 0),
(@q, 'C', N'$2$ và $-2$.', 1),
(@q, 'D', N'$\sqrt{2}$ và $-\sqrt{2}$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 3.33.</b> Căn bậc hai số học của $49$ là</p>', N'<p>Căn bậc hai số học của $a\gt0$ là $\sqrt{a}$, tức số không âm. $\sqrt{49}=7$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$7$.', 1),
(@q, 'B', N'$-7$.', 0),
(@q, 'C', N'$7$ và $-7$.', 0),
(@q, 'D', N'$\sqrt{7}$ và $-\sqrt{7}$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 3.34.</b> Rút gọn biểu thức $\sqrt[3]{(4-\sqrt{17})^3}$ ta được</p>', N'<p>Vì $\sqrt[3]{A^3}=A$ với mọi $A$ nên $\sqrt[3]{(4-\sqrt{17})^3}=4-\sqrt{17}$ (giá trị âm vẫn giữ nguyên, khác với căn bậc hai).</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$4+\sqrt{17}$.', 0),
(@q, 'B', N'$4-\sqrt{17}$.', 1),
(@q, 'C', N'$\sqrt{17}-4$.', 0),
(@q, 'D', N'$-4-\sqrt{17}$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 3.35.</b> Độ dài đường kính (mét) của hình tròn có diện tích $4\ \text{m}^2$ sau khi làm tròn kết quả đến chữ số thập phân thứ hai bằng</p>', N'<p>Gọi $d$ là đường kính: $\pi\cdot\dfrac{d^2}{4}=4$ nên $d=\dfrac{4}{\sqrt{\pi}}\approx2{,}2568\approx2{,}26$ (m).</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$2{,}26$.', 1),
(@q, 'B', N'$2{,}50$.', 0),
(@q, 'C', N'$1{,}13$.', 0),
(@q, 'D', N'$1{,}12$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 3.36.</b> Một vật rơi tự do từ độ cao $396{,}9$ m. Biết quãng đường chuyển động $S$ (mét) của vật phụ thuộc vào thời gian $t$ (giây) bởi công thức $S=4{,}9t^2$. Vật chạm đất sau</p>', N'<p>Vật chạm đất khi $S=396{,}9$: $4{,}9t^2=396{,}9$ suy ra $t^2=81$, $t=9$ (giây) (vì $t\gt0$).</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$8$ giây.', 0),
(@q, 'B', N'$5$ giây.', 0),
(@q, 'C', N'$11$ giây.', 0),
(@q, 'D', N'$9$ giây.', 1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.37.</b> Không sử dụng MTCT, tính giá trị của biểu thức $$A=\sqrt{(\sqrt{3}-2)^2}+\sqrt{4(2+\sqrt{3})^2}-\dfrac{1}{2-\sqrt{3}}.$$</p>', N'<p>$\sqrt{(\sqrt{3}-2)^2}=|\sqrt{3}-2|=2-\sqrt{3}$ (vì $\sqrt{3}\lt2$).</p>
<p>$\sqrt{4(2+\sqrt{3})^2}=2|2+\sqrt{3}|=2(2+\sqrt{3})=4+2\sqrt{3}$.</p>
<p>$\dfrac{1}{2-\sqrt{3}}=\dfrac{2+\sqrt{3}}{4-3}=2+\sqrt{3}$.</p>
<p>Do đó $A=(2-\sqrt{3})+(4+2\sqrt{3})-(2+\sqrt{3})=4$.</p>
<p><b>Đáp số:</b> $A=4$.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.38.</b> Cho biểu thức $A=\dfrac{\sqrt{x}+2}{\sqrt{x}-2}-\dfrac{4}{\sqrt{x}+2}$ ($x\ge0$ và $x\neq4$).</p>
<ol type="a">
<li>Rút gọn biểu thức $A$.</li>
<li>Tính giá trị của $A$ tại $x=14$.</li>
</ol>', N'<p><b>a)</b> Mẫu chung $(\sqrt{x}-2)(\sqrt{x}+2)=x-4$. $$A=\dfrac{(\sqrt{x}+2)^2-4(\sqrt{x}-2)}{x-4}=\dfrac{x+4\sqrt{x}+4-4\sqrt{x}+8}{x-4}=\dfrac{x+12}{x-4}.$$</p>
<p><b>b)</b> Tại $x=14$ (thỏa mãn điều kiện): $A=\dfrac{14+12}{14-4}=\dfrac{26}{10}=\dfrac{13}{5}$.</p>
<p><b>Đáp số:</b> a) $A=\dfrac{x+12}{x-4}$. b) $\dfrac{13}{5}$.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 3.39.</b> Biết rằng nhiệt lượng tỏa ra trên dây dẫn được tính bởi công thức $Q=I^2Rt$, trong đó $Q$ là nhiệt lượng tính bằng đơn vị Joule (J), $R$ là điện trở tính bằng đơn vị Ohm ($\Omega$), $I$ là cường độ dòng điện tính bằng đơn vị Ampe (A), $t$ là thời gian tính bằng giây (s). Dòng điện chạy qua một dây dẫn có $R=10\ \Omega$ trong thời gian 5 giây.</p>
<ol type="a">
<li>Thay dấu "?" trong bảng sau bằng các giá trị thích hợp:
<table border="1"><tr><th>$I$ (A)</th><td>1</td><td>1,5</td><td>2</td></tr><tr><th>$Q$ (J)</th><td>?</td><td>?</td><td>?</td></tr></table></li>
<li>Cường độ dòng điện là bao nhiêu Ampe để nhiệt lượng tỏa ra trên dây dẫn đạt 800 J?</li>
</ol>', N'<p>Với $R=10$ và $t=5$: $Q=I^2\cdot10\cdot5=50I^2$.</p>
<p><b>a)</b> $I=1$: $Q=50$; $I=1{,}5$: $Q=50\cdot2{,}25=112{,}5$; $I=2$: $Q=50\cdot4=200$.</p>
<table border="1"><tr><th>$I$ (A)</th><td>1</td><td>1,5</td><td>2</td></tr><tr><th>$Q$ (J)</th><td>50</td><td>112,5</td><td>200</td></tr></table>
<p><b>b)</b> $50I^2=800$ suy ra $I^2=16$, $I=4$ (vì $I\gt0$).</p>
<p><b>Đáp số:</b> a) $50$; $112{,}5$; $200$. b) $4$ A.</p>', 2, 0, 1, @t1);

-- ---------------------------------------------------------------------------------------------------------------------
-- Chương IV. Hệ thức lượng trong tam giác vuông
-- ---------------------------------------------------------------------------------------------------------------------
INSERT INTO Topics (TopicName, [Description], TeacherId, OrderIndex, IsActive) VALUES (N'Chương IV. Hệ thức lượng trong tam giác vuông', N'Tỉ số lượng giác của góc nhọn (sin, côsin, tang, côtang), tỉ số lượng giác của hai góc phụ nhau, sử dụng máy tính cầm tay, các hệ thức giữa cạnh và góc trong tam giác vuông, giải tam giác vuông và ứng dụng thực tiễn. (SGK Toán 9 Kết nối tri thức với cuộc sống, Tập 1)', @t1, 4, 1);
SET @tp = SCOPE_IDENTITY();

-- Bài 11
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 11. Tỉ số lượng giác của góc nhọn', N'Định nghĩa sin, côsin, tang, côtang của góc nhọn; giá trị lượng giác của các góc 30°, 45°, 60°; tỉ số lượng giác của hai góc phụ nhau; dùng máy tính cầm tay.', N'<p><b>1. Khái niệm tỉ số lượng giác của một góc nhọn.</b> Cho tam giác $ABC$ vuông tại $A$. Xét góc nhọn $B$: cạnh $AC$ là <i>cạnh đối</i> của góc $B$, cạnh $AB$ là <i>cạnh kề</i> của góc $B$, cạnh $BC$ là <i>cạnh huyền</i>.</p>
<p>Các tam giác vuông có cùng một góc nhọn $\alpha$ thì đồng dạng với nhau nên các tỉ số giữa hai cạnh của chúng chỉ phụ thuộc vào góc $\alpha$. Cho góc nhọn $\alpha$ và tam giác $ABC$ vuông tại $A$ có $\widehat{B}=\alpha$:</p>
<ul>
<li>$\sin\alpha=\dfrac{\text{cạnh đối}}{\text{cạnh huyền}}$ (sin);</li>
<li>$\cos\alpha=\dfrac{\text{cạnh kề}}{\text{cạnh huyền}}$ (côsin);</li>
<li>$\tan\alpha=\dfrac{\text{cạnh đối}}{\text{cạnh kề}}$ (tang);</li>
<li>$\cot\alpha=\dfrac{\text{cạnh kề}}{\text{cạnh đối}}$ (côtang), và $\cot\alpha=\dfrac{1}{\tan\alpha}$.</li>
</ul>
<p>$\sin\alpha,\ \cos\alpha,\ \tan\alpha,\ \cot\alpha$ gọi là các <b>tỉ số lượng giác</b> của góc nhọn $\alpha$. Vì cạnh huyền dài nhất nên $\sin\alpha$ và $\cos\alpha$ luôn dương và bé hơn 1.</p>
<p><b>Ví dụ 1.</b> Tam giác $ABC$ vuông tại $A$, $AB=3$ cm, $AC=4$ cm, $\alpha=\widehat{B}$. Theo định lí Pythagore $BC=\sqrt{3^2+4^2}=5$ (cm). Do đó $\sin\alpha=\dfrac{AC}{BC}=\dfrac{4}{5}$, $\cos\alpha=\dfrac{AB}{BC}=\dfrac{3}{5}$, $\tan\alpha=\dfrac{AC}{AB}=\dfrac{4}{3}$.</p>
<p><b>Giá trị lượng giác của các góc đặc biệt.</b></p>
<table border="1"><tr><th>$\alpha$</th><th>$30^\circ$</th><th>$45^\circ$</th><th>$60^\circ$</th></tr><tr><th>$\sin\alpha$</th><td>$\dfrac{1}{2}$</td><td>$\dfrac{\sqrt2}{2}$</td><td>$\dfrac{\sqrt3}{2}$</td></tr><tr><th>$\cos\alpha$</th><td>$\dfrac{\sqrt3}{2}$</td><td>$\dfrac{\sqrt2}{2}$</td><td>$\dfrac{1}{2}$</td></tr><tr><th>$\tan\alpha$</th><td>$\dfrac{\sqrt3}{3}$</td><td>$1$</td><td>$\sqrt3$</td></tr><tr><th>$\cot\alpha$</th><td>$\sqrt3$</td><td>$1$</td><td>$\dfrac{\sqrt3}{3}$</td></tr></table>
<p><b>Ví dụ 2.</b> Tam giác $ABC$ vuông tại $A$ có $\widehat{C}=30^\circ$, $BC=a$. Khi đó $AB=BC\cdot\sin C=a\sin30^\circ=\dfrac{a}{2}$ và $AC=BC\cdot\cos C=a\cos30^\circ=\dfrac{a\sqrt3}{2}$.</p>
<p><b>2. Tỉ số lượng giác của hai góc phụ nhau.</b> <i>Định lí:</i> nếu hai góc phụ nhau thì sin góc này bằng côsin góc kia, tang góc này bằng côtang góc kia. Với $\alpha+\beta=90^\circ$: $$\sin\alpha=\cos\beta,\quad\cos\alpha=\sin\beta,\quad\tan\alpha=\cot\beta,\quad\cot\alpha=\tan\beta.$$</p>
<p><b>Ví dụ 3.</b> Viết thành tỉ số lượng giác của góc nhỏ hơn $45^\circ$: $\sin60^\circ=\cos30^\circ$; $\cos75^\circ=\sin15^\circ$; $\sin52^\circ30^{\prime}=\cos37^\circ30^{\prime}$; $\tan80^\circ=\cot10^\circ$; $\cot82^\circ=\tan8^\circ$. (Chú ý $1^\circ=60^{\prime}$.)</p>
<p><b>3. Sử dụng máy tính cầm tay (MTCT).</b> Nhập góc (nút độ-phút-giây) rồi bấm phím sin, cos hoặc tan để tính tỉ số lượng giác; $\cot\alpha=\dfrac{1}{\tan\alpha}$ hoặc $\cot\alpha=\tan(90^\circ-\alpha)$. Ví dụ: $\sin27^\circ\approx0{,}454$; $\cos32^\circ15^{\prime}\approx0{,}846$; $\tan52^\circ12^{\prime}\approx1{,}289$; $\cot35^\circ23^{\prime}\approx1{,}408$.</p>
<p>Ngược lại, biết một tỉ số lượng giác thì tìm góc bằng phím SHIFT: $\sin\alpha_1=0{,}3214\Rightarrow\alpha_1\approx18^\circ45^{\prime}$; $\cos\alpha_2=0{,}4321\Rightarrow\alpha_2\approx64^\circ24^{\prime}$; $\tan\alpha_3=1{,}2742\Rightarrow\alpha_3\approx51^\circ52^{\prime}$. Với $\cot\alpha=m$ thì tìm góc $90^\circ-\alpha$ (vì $\tan(90^\circ-\alpha)=\cot\alpha$) hoặc tính $\tan\alpha=\dfrac{1}{m}$.</p>
<p><b>Vận dụng (tình huống mở đầu).</b> Đoạn dốc dài $4$ m, độ cao đỉnh dốc $0{,}4$ m nên $\sin\alpha=\dfrac{0{,}4}{4}=0{,}1$, $\alpha\approx5^\circ44^{\prime}\lt6^\circ$: đúng tiêu chuẩn dốc cho người đi xe lăn.</p>', 1, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.1.</b> Cho tam giác $ABC$ vuông tại $A$. Tính các tỉ số lượng giác sin, côsin, tang, côtang của các góc nhọn $B$ và $C$ khi biết:</p>
<ol type="a">
<li>$AB=8$ cm, $BC=17$ cm;</li>
<li>$AC=0{,}9$ cm, $AB=1{,}2$ cm.</li>
</ol>', N'<p><b>a)</b> $AC=\sqrt{BC^2-AB^2}=\sqrt{289-64}=15$ (cm). Với góc $B$ (đối $AC$, kề $AB$): $\sin B=\dfrac{15}{17}$, $\cos B=\dfrac{8}{17}$, $\tan B=\dfrac{15}{8}$, $\cot B=\dfrac{8}{15}$. Vì $B$ và $C$ phụ nhau nên $\sin C=\cos B=\dfrac{8}{17}$, $\cos C=\sin B=\dfrac{15}{17}$, $\tan C=\cot B=\dfrac{8}{15}$, $\cot C=\tan B=\dfrac{15}{8}$.</p>
<p><b>b)</b> $BC=\sqrt{0{,}9^2+1{,}2^2}=\sqrt{2{,}25}=1{,}5$ (cm). Với góc $B$ (đối $AC=0{,}9$, kề $AB=1{,}2$): $\sin B=\dfrac{0{,}9}{1{,}5}=\dfrac{3}{5}$, $\cos B=\dfrac{1{,}2}{1{,}5}=\dfrac{4}{5}$, $\tan B=\dfrac{3}{4}$, $\cot B=\dfrac{4}{3}$. Với góc $C$: $\sin C=\dfrac{4}{5}$, $\cos C=\dfrac{3}{5}$, $\tan C=\dfrac{4}{3}$, $\cot C=\dfrac{3}{4}$.</p>
<p><b>Đáp số:</b> a) $\sin B=\dfrac{15}{17}$, $\cos B=\dfrac{8}{17}$, $\tan B=\dfrac{15}{8}$, $\cot B=\dfrac{8}{15}$; $\sin C=\dfrac{8}{17}$, $\cos C=\dfrac{15}{17}$, $\tan C=\dfrac{8}{15}$, $\cot C=\dfrac{15}{8}$. b) $\sin B=\dfrac{3}{5}$, $\cos B=\dfrac{4}{5}$, $\tan B=\dfrac{3}{4}$, $\cot B=\dfrac{4}{3}$; $\sin C=\dfrac{4}{5}$, $\cos C=\dfrac{3}{5}$, $\tan C=\dfrac{4}{3}$, $\cot C=\dfrac{3}{4}$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.2.</b> Cho tam giác vuông có một góc nhọn $60^\circ$ và cạnh kề với góc $60^\circ$ bằng 3 cm. Hãy tính cạnh đối của góc này.</p>', N'<p>Gọi cạnh đối của góc $60^\circ$ là $x$. Ta có $\tan60^\circ=\dfrac{x}{3}$ nên $x=3\tan60^\circ=3\sqrt3$ (cm).</p>
<p><b>Đáp số:</b> $3\sqrt3$ cm (khoảng 5,2 cm).</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.3.</b> Cho tam giác vuông có một góc nhọn bằng $30^\circ$ và cạnh đối với góc này bằng 5 cm. Tính độ dài cạnh huyền của tam giác.</p>', N'<p>Gọi cạnh huyền là $a$. Ta có $\sin30^\circ=\dfrac{5}{a}$ nên $a=\dfrac{5}{\sin30^\circ}=\dfrac{5}{1/2}=10$ (cm).</p>
<p><b>Đáp số:</b> 10 cm.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.4.</b> Cho hình chữ nhật có chiều dài và chiều rộng lần lượt là 3 và $\sqrt3$. Tính góc giữa đường chéo và cạnh ngắn hơn của hình chữ nhật (sử dụng bảng giá trị lượng giác trang 69).</p>', N'<p>Đường chéo chia hình chữ nhật thành hai tam giác vuông có hai cạnh góc vuông là 3 và $\sqrt3$. Gọi $\alpha$ là góc giữa đường chéo và cạnh ngắn $\sqrt3$: cạnh kề là $\sqrt3$, cạnh đối là 3 nên $\tan\alpha=\dfrac{3}{\sqrt3}=\sqrt3$.</p>
<p>Theo bảng giá trị lượng giác, $\tan60^\circ=\sqrt3$ nên $\alpha=60^\circ$.</p>
<p><b>Đáp số:</b> $60^\circ$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.5.</b></p>
<ol type="a">
<li>Viết các tỉ số lượng giác sau thành tỉ số lượng giác của các góc nhỏ hơn $45^\circ$: $\sin55^\circ,\ \cos62^\circ,\ \tan57^\circ,\ \cot64^\circ$.</li>
<li>Tính $\dfrac{\tan25^\circ}{\cot65^\circ}$, $\ \tan34^\circ-\cot56^\circ$.</li>
</ol>', N'<p><b>a)</b> Với hai góc phụ nhau: $\sin55^\circ=\cos35^\circ$; $\cos62^\circ=\sin28^\circ$; $\tan57^\circ=\cot33^\circ$; $\cot64^\circ=\tan26^\circ$.</p>
<p><b>b)</b> Vì $25^\circ+65^\circ=90^\circ$ nên $\cot65^\circ=\tan25^\circ$, suy ra $\dfrac{\tan25^\circ}{\cot65^\circ}=1$. Vì $34^\circ+56^\circ=90^\circ$ nên $\cot56^\circ=\tan34^\circ$, suy ra $\tan34^\circ-\cot56^\circ=0$.</p>
<p><b>Đáp số:</b> a) $\cos35^\circ,\ \sin28^\circ,\ \cot33^\circ,\ \tan26^\circ$. b) $1$ và $0$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.6.</b> Dùng MTCT, tính (làm tròn đến chữ số thập phân thứ ba):</p>
<ol type="a">
<li>$\sin40^\circ12^{\prime}$;</li>
<li>$\cos52^\circ54^{\prime}$;</li>
<li>$\tan63^\circ36^{\prime}$;</li>
<li>$\cot35^\circ20^{\prime}$.</li>
</ol>', N'<p>Bấm máy (chế độ độ) rồi làm tròn đến chữ số thập phân thứ ba; với $\cot$ ta tính $\dfrac{1}{\tan}$.</p>
<p><b>a)</b> $\sin40^\circ12^{\prime}\approx0{,}645$. <b>b)</b> $\cos52^\circ54^{\prime}\approx0{,}603$. <b>c)</b> $\tan63^\circ36^{\prime}\approx2{,}014$. <b>d)</b> $\cot35^\circ20^{\prime}=\dfrac{1}{\tan35^\circ20^{\prime}}\approx1{,}411$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.7.</b> Dùng MTCT, tìm số đo của góc nhọn $x$ (làm tròn đến phút), biết rằng:</p>
<ol type="a">
<li>$\sin x=0{,}2368$;</li>
<li>$\cos x=0{,}6224$;</li>
<li>$\tan x=1{,}236$;</li>
<li>$\cot x=2{,}154$.</li>
</ol>', N'<p>Dùng phím SHIFT (sin, cos, tan) rồi đổi sang độ-phút-giây; với $\cot x=m$ thì tính $\tan x=\dfrac{1}{m}$.</p>
<p><b>a)</b> $x\approx13^\circ41{,}87^{\prime}\approx13^\circ42^{\prime}$. <b>b)</b> $x\approx51^\circ30{,}5^{\prime}\approx51^\circ31^{\prime}$. <b>c)</b> $x\approx51^\circ1{,}5^{\prime}\approx51^\circ2^{\prime}$. <b>d)</b> $\tan x=\dfrac{1}{2{,}154}$ nên $x\approx24^\circ54^{\prime}$.</p>
<p><b>Đáp số:</b> a) $13^\circ42^{\prime}$. b) $51^\circ31^{\prime}$. c) $51^\circ2^{\prime}$. d) $24^\circ54^{\prime}$.</p>', 2, 0, 1, @t1);

-- Bài 12
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 12. Một số hệ thức giữa cạnh, góc trong tam giác vuông và ứng dụng', N'Hệ thức giữa cạnh huyền và cạnh góc vuông, giữa hai cạnh góc vuông; giải tam giác vuông và các bài toán thực tế.', N'<p><b>1. Hệ thức giữa cạnh huyền và cạnh góc vuông.</b> Cho tam giác $ABC$ vuông tại $A$, cạnh huyền $a=BC$, các cạnh góc vuông $b=AC$, $c=AB$.</p>
<p><b>Định lí 1.</b> Trong tam giác vuông, mỗi cạnh góc vuông bằng cạnh huyền nhân với sin góc đối hoặc nhân với côsin góc kề: $$b=a\sin B=a\cos C,\qquad c=a\sin C=a\cos B.$$</p>
<p><b>Ví dụ 1.</b> Máy bay bay lên với vận tốc 500 km/h, đường bay tạo với phương nằm ngang góc $30^\circ$. Sau 1,2 phút $=\dfrac{1}{50}$ giờ, máy bay bay được $AB=500\cdot\dfrac{1}{50}=10$ (km). Độ cao $BH=AB\cdot\sin30^\circ=10\cdot\dfrac{1}{2}=5$ (km).</p>
<p><b>2. Hệ thức giữa hai cạnh góc vuông.</b> <b>Định lí 2.</b> Trong tam giác vuông, mỗi cạnh góc vuông bằng cạnh góc vuông kia nhân với tang góc đối hoặc nhân với côtang góc kề: $$b=c\tan B=c\cot C,\qquad c=b\tan C=b\cot B.$$</p>
<p><b>Ví dụ 2.</b> Tia nắng mặt trời tạo với mặt đất góc xấp xỉ $34^\circ$, bóng của tòa tháp dài $8{,}6$ m. Chiều cao tháp là $h=8{,}6\cdot\tan34^\circ\approx6$ (m).</p>
<p><b>3. Giải tam giác vuông.</b> Trong một tam giác vuông, nếu biết trước hai cạnh (hoặc một góc nhọn và một cạnh) thì ta tìm được tất cả các cạnh và các góc còn lại. Bài toán đó gọi là <b>giải tam giác vuông</b>.</p>
<p><b>Ví dụ 3.</b> Tam giác $ABC$ vuông tại $A$ có $AB=5$, $AC=8$. Theo Pythagore $BC=\sqrt{5^2+8^2}=\sqrt{89}\approx9{,}4$. Ta có $\tan C=\dfrac{AB}{AC}=\dfrac{5}{8}=0{,}625$ nên $\widehat{C}\approx32^\circ$, $\widehat{B}=90^\circ-\widehat{C}\approx58^\circ$.</p>
<p><b>Ví dụ 4.</b> Tam giác $ABC$ vuông tại $A$ có $AB=3$, $\widehat{B}=42^\circ$. Khi đó $\widehat{C}=90^\circ-42^\circ=48^\circ$; $AC=AB\cdot\tan B=3\tan42^\circ\approx2{,}701$; $BC=\dfrac{AB}{\cos B}=\dfrac{3}{\cos42^\circ}\approx4{,}037$.</p>
<p><b>Vận dụng (tình huống mở đầu, đo chiều cao tòa lâu đài).</b> Gọi $h$ là độ cao của đỉnh $P^{\prime}$ so với tầm mắt. Từ hai vị trí cách nhau $20$ m ta có $\dfrac{h}{\tan\beta}-\dfrac{h}{\tan\alpha}=20$, suy ra $h=\dfrac{20}{\cot\beta-\cot\alpha}$; chiều cao tòa lâu đài bằng $h$ cộng chiều cao giác kế $1{,}6$ m.</p>', 2, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.8.</b> Giải tam giác $ABC$ vuông tại $A$ có $BC=a$, $AC=b$, $AB=c$, trong các trường hợp (góc làm tròn đến độ, độ dài cạnh làm tròn đến chữ số hàng đơn vị):</p>
<ol type="a">
<li>$a=21,\ b=18$;</li>
<li>$b=10,\ \widehat{C}=30^\circ$;</li>
<li>$c=5,\ b=3$.</li>
</ol>', N'<p><b>a)</b> $c=\sqrt{21^2-18^2}=\sqrt{117}\approx11$. $\sin B=\dfrac{b}{a}=\dfrac{18}{21}=\dfrac{6}{7}$ nên $\widehat{B}\approx59^\circ$, $\widehat{C}=90^\circ-59^\circ=31^\circ$.</p>
<p><b>b)</b> $\widehat{B}=90^\circ-30^\circ=60^\circ$. $c=AB=b\tan C=10\tan30^\circ\approx5{,}77\approx6$. $a=BC=\dfrac{b}{\cos C}=\dfrac{10}{\cos30^\circ}\approx11{,}55\approx12$.</p>
<p><b>c)</b> $a=\sqrt{5^2+3^2}=\sqrt{34}\approx6$. $\tan B=\dfrac{b}{c}=\dfrac{3}{5}=0{,}6$ nên $\widehat{B}\approx31^\circ$, $\widehat{C}\approx59^\circ$.</p>
<p><b>Đáp số:</b> a) $c\approx11$, $\widehat{B}\approx59^\circ$, $\widehat{C}\approx31^\circ$. b) $c\approx6$, $a\approx12$, $\widehat{B}=60^\circ$. c) $a\approx6$, $\widehat{B}\approx31^\circ$, $\widehat{C}\approx59^\circ$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.9.</b> Tính góc nghiêng $\alpha$ của thùng xe chở rác trong Hình 4.22 (làm tròn đến độ).</p>
<p>(Trong hình, thùng xe dài 4 m, đoạn từ trục quay của thùng đến chân thanh chống nâng thùng trên sàn xe dài 5 m; thùng xe vuông góc với thanh chống nâng; $\alpha$ là góc giữa thùng xe và sàn xe.)</p>
<div><img src="/static/img/sgk9/sgk9-c4-hinh-4-22-4-23.png" alt="Hình 4.22 (thùng xe chở rác) và Hình 4.23 (mái nhà kho) - SGK Toán 9"></div>', N'<p>Thùng xe, thanh chống và sàn xe tạo thành tam giác vuông (vuông tại chỗ thanh chống tựa vào thùng) có cạnh huyền là 5 m và cạnh góc vuông kề góc $\alpha$ là 4 m (thùng xe). Do đó $$\cos\alpha=\dfrac{4}{5}=0{,}8.$$</p>
<p>Dùng MTCT: $\alpha\approx36{,}87^\circ\approx37^\circ$.</p>
<p><b>Đáp số:</b> $\alpha\approx37^\circ$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.10.</b> Tìm góc nghiêng $\alpha$ và chiều rộng $AB$ của mái nhà kho trong Hình 4.23 (góc làm tròn đến độ, độ dài làm tròn đến dm).</p>
<p>(Trong hình, nhà kho có chiều rộng 15 m; mái nhà là mặt phẳng nghiêng, điểm $A$ cao hơn điểm $B$ là 0,9 m; $\alpha$ là góc giữa mái $AB$ và phương nằm ngang. Hình vẽ ở Bài 4.9.)</p>
<div><img src="/static/img/sgk9/sgk9-c4-hinh-4-22-4-23.png" alt="Hình 4.22 (thùng xe chở rác) và Hình 4.23 (mái nhà kho) - SGK Toán 9"></div>', N'<p>Mặt cắt của mái là tam giác vuông có cạnh góc vuông nằm ngang bằng 15 m và cạnh góc vuông thẳng đứng bằng 0,9 m. Do đó $$\tan\alpha=\dfrac{0{,}9}{15}=0{,}06\Rightarrow\alpha\approx3{,}43^\circ\approx3^\circ.$$</p>
<p>Chiều rộng mái: $AB=\sqrt{15^2+0{,}9^2}=\sqrt{225{,}81}\approx15{,}03$ m, làm tròn đến dm là $15{,}0$ m (150 dm).</p>
<p><b>Đáp số:</b> $\alpha\approx3^\circ$; $AB\approx15{,}0$ m.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.11.</b> Tính các góc của hình thoi có hai đường chéo dài $2\sqrt3$ và 2.</p>', N'<p>Hai đường chéo của hình thoi vuông góc và cắt nhau tại trung điểm mỗi đường nên tạo ra bốn tam giác vuông có hai cạnh góc vuông là $\sqrt3$ và $1$. Xét góc $\alpha$ đối diện cạnh góc vuông 1: $\tan\alpha=\dfrac{1}{\sqrt3}$ nên $\alpha=30^\circ$ (đây là nửa góc ở hai đầu đường chéo dài).</p>
<p>Đường chéo là phân giác của các góc hình thoi nên hai góc ở hai đầu đường chéo dài bằng $2\cdot30^\circ=60^\circ$ và hai góc còn lại bằng $180^\circ-60^\circ=120^\circ$.</p>
<p><b>Đáp số:</b> hai góc $60^\circ$ và hai góc $120^\circ$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.12.</b> Cho hình thang $ABCD$ ($AD\parallel BC$) có $AD=16$ cm, $BC=4$ cm và $\widehat{A}=\widehat{B}=\widehat{ACD}=90^\circ$.</p>
<ol type="a">
<li>Kẻ đường cao $CE$ của tam giác $ACD$. Chứng minh $\widehat{ADC}=\widehat{ACE}$. Tính sin của các góc $\widehat{ADC}$, $\widehat{ACE}$ và suy ra $AC^2=AE\cdot AD$. Từ đó tính $AC$.</li>
<li>Tính góc $D$ của hình thang.</li>
</ol>', N'<p><b>a)</b> Tam giác $ACD$ vuông tại $C$ nên $\widehat{ADC}+\widehat{CAD}=90^\circ$. Tam giác $ACE$ vuông tại $E$ nên $\widehat{ACE}+\widehat{CAE}=90^\circ$, mà $\widehat{CAE}=\widehat{CAD}$ nên $\widehat{ADC}=\widehat{ACE}$.</p>
<p>Trong tam giác vuông $ACD$: $\sin\widehat{ADC}=\dfrac{AC}{AD}$. Trong tam giác vuông $ACE$: $\sin\widehat{ACE}=\dfrac{AE}{AC}$. Hai góc bằng nhau nên $\dfrac{AC}{AD}=\dfrac{AE}{AC}$, suy ra $AC^2=AE\cdot AD$.</p>
<p>Tứ giác $ABCE$ có ba góc vuông ($\widehat{A}=\widehat{B}=\widehat{AEC}=90^\circ$) nên là hình chữ nhật, do đó $AE=BC=4$ cm. Vậy $AC^2=4\cdot16=64$, $AC=8$ cm.</p>
<p><b>b)</b> $\sin D=\dfrac{AC}{AD}=\dfrac{8}{16}=\dfrac{1}{2}$ nên $\widehat{D}=30^\circ$.</p>
<p><b>Đáp số:</b> a) $AC=8$ cm. b) $\widehat{D}=30^\circ$.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.13.</b> Một người đứng tại điểm $A$, cách gương phẳng đặt nằm trên mặt đất tại điểm $B$ là 1,2 m, nhìn thấy hình phản chiếu qua gương $B$ của ngọn cây (cây mọc thẳng đứng, có gốc ở tại điểm $C$ cách $B$ là 4,8 m, $B$ nằm giữa $A$ và $C$). Biết khoảng cách từ mặt đất đến mắt người đó là 1,65 m. Tính chiều cao của cây (H.4.24).</p>
<div><img src="/static/img/sgk9/sgk9-c4-hinh-4-24.png" alt="Hình 4.24 - SGK Toán 9"></div>', N'<p>Theo định luật phản xạ, tia tới và tia phản xạ tạo với mặt gương (mặt đất) hai góc bằng nhau; gọi góc đó là $\alpha$.</p>
<p>Ở phía người: tam giác vuông có cạnh kề $AB=1{,}2$ m và cạnh đối (độ cao mắt) $1{,}65$ m nên $\tan\alpha=\dfrac{1{,}65}{1{,}2}$.</p>
<p>Ở phía cây: chiều cao cây $h=BC\cdot\tan\alpha=4{,}8\cdot\dfrac{1{,}65}{1{,}2}=6{,}6$ (m).</p>
<p><b>Đáp số:</b> cây cao 6,6 m.</p>', 2, 0, 1, @t1);

-- Luyện tập chung (Bài 11 - Bài 12)
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Luyện tập chung (Chương IV)', N'Vận dụng tỉ số lượng giác và hệ thức giữa cạnh, góc trong tam giác vuông để giải các bài toán hình học và thực tế.', N'<p><b>Ví dụ 1.</b> Tam giác $ABC$ vuông tại $A$, $AB=5$ cm, $AC=12$ cm. a) Tính các tỉ số lượng giác của góc $B$; b) suy ra các tỉ số lượng giác của góc $C$.</p>
<p><i>Giải.</i> a) $BC=\sqrt{5^2+12^2}=13$ cm. $\sin B=\dfrac{AC}{BC}=\dfrac{12}{13}$, $\cos B=\dfrac{AB}{BC}=\dfrac{5}{13}$, $\tan B=\dfrac{AC}{AB}=\dfrac{12}{5}$, $\cot B=\dfrac{AB}{AC}=\dfrac{5}{12}$. b) Do $\widehat{B}+\widehat{C}=90^\circ$ nên $\sin C=\cos B=\dfrac{5}{13}$, $\cos C=\sin B=\dfrac{12}{13}$, $\tan C=\cot B=\dfrac{5}{12}$, $\cot C=\tan B=\dfrac{12}{5}$.</p>
<p><b>Ví dụ 2.</b> Bức tường đang xây dở dạng hình thang vuông $ABCD$ (vuông ở $A$ và $D$), $AB=1$ m, $CD=4$ m, $AD=6$ m. a) Tính góc $\alpha$ tạo bởi đường thẳng $BC$ và mặt đất $AD$ (làm tròn đến phút); b) tính độ dài cạnh $BC$ (làm tròn đến chữ số thập phân thứ nhất).</p>
<p><i>Giải.</i> a) Kẻ $BE\parallel AD$ cắt $CD$ tại $E$ thì $ABED$ là hình chữ nhật, $BE=AD=6$ m, $EC=CD-ED=4-1=3$ m. Trong tam giác $BCE$ vuông tại $E$: $\tan\alpha=\dfrac{EC}{BE}=\dfrac{3}{6}=\dfrac{1}{2}$, suy ra $\alpha\approx26^\circ34^{\prime}$. b) $BC=\sqrt{BE^2+EC^2}=\sqrt{45}=3\sqrt5\approx6{,}7$ (m).</p>', 3, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.14.</b> Một cuốn sách khổ $17\times24$ cm, tức là chiều rộng 17 cm, chiều dài 24 cm. Gọi $\alpha$ là góc giữa đường chéo và cạnh 17 cm. Tính $\sin\alpha$, $\cos\alpha$ (làm tròn đến chữ số thập phân thứ hai) và tính số đo $\alpha$ (làm tròn đến độ).</p>', N'<p>Đường chéo $d=\sqrt{17^2+24^2}=\sqrt{865}\approx29{,}41$ (cm). Trong tam giác vuông tạo bởi hai cạnh và đường chéo, cạnh kề của $\alpha$ là 17 cm, cạnh đối là 24 cm.</p>
<p>$\cos\alpha=\dfrac{17}{\sqrt{865}}\approx0{,}58$; $\sin\alpha=\dfrac{24}{\sqrt{865}}\approx0{,}82$. Từ $\cos\alpha\approx0{,}578$ suy ra $\alpha\approx54{,}7^\circ\approx55^\circ$.</p>
<p><b>Đáp số:</b> $\sin\alpha\approx0{,}82$, $\cos\alpha\approx0{,}58$, $\alpha\approx55^\circ$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.15.</b> Cho tam giác $ABC$ có chân đường cao $AH$ nằm giữa $B$ và $C$. Biết $HB=3$ cm, $HC=6$ cm, $\widehat{HAC}=60^\circ$. Hãy tính độ dài các cạnh (làm tròn đến cm), số đo các góc của tam giác $ABC$ (làm tròn đến độ).</p>', N'<p>$BC=HB+HC=9$ cm.</p>
<p>Tam giác $AHC$ vuông tại $H$: $\widehat{C}=90^\circ-60^\circ=30^\circ$; $AH=\dfrac{HC}{\tan60^\circ}=\dfrac{6}{\sqrt3}=2\sqrt3\approx3{,}46$ cm; $AC=\dfrac{HC}{\sin60^\circ}=4\sqrt3\approx6{,}93\approx7$ cm.</p>
<p>Tam giác $AHB$ vuông tại $H$: $AB=\sqrt{AH^2+HB^2}=\sqrt{12+9}=\sqrt{21}\approx4{,}58\approx5$ cm; $\tan B=\dfrac{AH}{HB}=\dfrac{2\sqrt3}{3}\approx1{,}155$ nên $\widehat{B}\approx49^\circ$.</p>
<p>$\widehat{BAC}=180^\circ-49^\circ-30^\circ\approx101^\circ$.</p>
<p><b>Đáp số:</b> $AB\approx5$ cm, $AC\approx7$ cm, $BC=9$ cm; $\widehat{A}\approx101^\circ$, $\widehat{B}\approx49^\circ$, $\widehat{C}=30^\circ$.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.16.</b> Tìm chiều rộng $d$ của dòng sông trong Hình 4.27 (làm tròn đến m).</p>
<p>(Trong hình, hai bờ sông song song; một đường thẳng cắt hai bờ tạo với mỗi bờ góc $40^\circ$; hình chiếu của đường thẳng đó trên bờ dưới dài 50 m.)</p>
<div><img src="/static/img/sgk9/sgk9-c4-hinh-4-27.png" alt="Hình 4.27 - SGK Toán 9"></div>', N'<p>Đường vuông góc hạ từ điểm trên bờ trên xuống bờ dưới có độ dài $d$ chính là chiều rộng sông. Tam giác vuông tạo thành có góc nhọn $40^\circ$, cạnh kề là 50 m và cạnh đối là $d$.</p>
<p>$d=50\cdot\tan40^\circ\approx41{,}95\approx42$ (m).</p>
<p><b>Đáp số:</b> $d\approx42$ m.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.17.</b> Tính các số liệu còn thiếu (dấu "?") ở Hình 4.28, với góc làm tròn đến độ, với độ dài làm tròn đến chữ số thập phân thứ nhất.</p>
<div><img src="/static/img/sgk9/sgk9-c4-hinh-4-28.png" alt="Hình 4.28 - SGK Toán 9"></div>
<ol type="a">
<li>Tam giác vuông có góc nhọn $40^\circ$, cạnh góc vuông kề góc đó bằng 3; tính cạnh góc vuông còn lại.</li>
<li>Hình chữ nhật có đường chéo 10, một cạnh bằng 7; tính góc giữa đường chéo và cạnh còn lại (góc đối diện cạnh 7).</li>
<li>Tam giác vuông có hai cạnh góc vuông là 5 và 7; tính góc nhọn đối diện cạnh 7.</li>
<li>Trên một cạnh của góc $35^\circ$ lấy hai điểm cách đỉnh 3 và $3+2=5$ (đơn vị), kẻ từ hai điểm đó các đường vuông góc xuống cạnh còn lại; tính độ dài hai đường vuông góc đó.</li>
</ol>', N'<p><b>a)</b> Cạnh còn lại (đối) $=3\tan40^\circ\approx2{,}5$.</p>
<p><b>b)</b> Gọi $\varphi$ là góc giữa đường chéo và cạnh còn lại: $\sin\varphi=\dfrac{7}{10}=0{,}7$ nên $\varphi\approx44{,}4^\circ\approx44^\circ$.</p>
<p><b>c)</b> $\tan\varphi=\dfrac{7}{5}=1{,}4$ nên $\varphi\approx54{,}5^\circ\approx54^\circ$.</p>
<p><b>d)</b> Đường vuông góc thứ nhất: $3\sin35^\circ\approx1{,}7$. Đường vuông góc thứ hai (điểm cách đỉnh 5): $5\sin35^\circ\approx2{,}9$.</p>
<p><b>Đáp số:</b> a) $\approx2{,}5$. b) $\approx44^\circ$. c) $\approx54^\circ$. d) $\approx1{,}7$ và $\approx2{,}9$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.18.</b> Một bạn muốn tính khoảng cách giữa hai địa điểm $A$, $B$ ở hai bên hồ nước. Biết rằng các khoảng cách từ một điểm $C$ đến $A$ và đến $B$ là $CA=90$ m, $CB=150$ m và $\widehat{ACB}=120^\circ$ (H.4.29). Hãy tính $AB$ giúp bạn.</p>
<div><img src="/static/img/sgk9/sgk9-c4-hinh-4-29.png" alt="Hình 4.29 - SGK Toán 9"></div>', N'<p>Kẻ $AH\perp BC$ tại $H$ ($C$ nằm giữa $B$ và $H$). Vì $\widehat{ACB}=120^\circ$ nên $\widehat{ACH}=180^\circ-120^\circ=60^\circ$.</p>
<p>Trong tam giác vuông $ACH$: $AH=AC\sin60^\circ=90\cdot\dfrac{\sqrt3}{2}=45\sqrt3$ (m); $CH=AC\cos60^\circ=45$ (m).</p>
<p>$BH=BC+CH=150+45=195$ (m). Trong tam giác vuông $ABH$: $AB=\sqrt{AH^2+BH^2}=\sqrt{6075+38025}=\sqrt{44100}=210$ (m).</p>
<p><b>Đáp số:</b> $AB=210$ m.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.19.</b> Mặt cắt ngang của một đập ngăn nước có dạng hình thang $ABCD$ (H.4.30). Chiều rộng mặt trên $AB$ của đập là 3 m. Độ dốc của sườn $AD$, tức là $\tan D=1{,}25$. Độ dốc của sườn $BC$, tức là $\tan C=1{,}5$. Chiều cao của đập là 3,5 m. Hãy tính chiều rộng $CD$ của chân đập, chiều dài của các sườn $AD$ và $BC$ (làm tròn đến dm).</p>
<div><img src="/static/img/sgk9/sgk9-c4-hinh-4-30.png" alt="Hình 4.30 - SGK Toán 9"></div>', N'<p>Kẻ $AH\perp CD$ tại $H$ và $BK\perp CD$ tại $K$; $AH=BK=3{,}5$ m và $HK=AB=3$ m.</p>
<p>Tam giác $AHD$ vuông tại $H$: $DH=\dfrac{AH}{\tan D}=\dfrac{3{,}5}{1{,}25}=2{,}8$ (m); $AD=\sqrt{3{,}5^2+2{,}8^2}=\sqrt{20{,}09}\approx4{,}5$ (m).</p>
<p>Tam giác $BKC$ vuông tại $K$: $KC=\dfrac{BK}{\tan C}=\dfrac{3{,}5}{1{,}5}\approx2{,}33$ (m); $BC=\sqrt{3{,}5^2+2{,}33^2}\approx4{,}2$ (m).</p>
<p>$CD=DH+HK+KC=2{,}8+3+2{,}33\approx8{,}1$ (m).</p>
<p><b>Đáp số:</b> $CD\approx8{,}1$ m, $AD\approx4{,}5$ m, $BC\approx4{,}2$ m.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.20.</b> Trong một buổi tập trận, một tàu ngầm đang ở trên mặt biển bắt đầu di chuyển theo đường thẳng tạo với mặt nước biển một góc $21^\circ$ để lặn xuống (H.4.31).</p>
<ol type="a">
<li>Khi tàu chuyển động theo hướng đó và đi được 200 m thì tàu ở độ sâu bao nhiêu so với mặt nước biển? (làm tròn đến m)</li>
<li>Giả sử tốc độ của tàu là 9 km/h thì sau bao lâu (tính từ lúc bắt đầu lặn) tàu ở độ sâu 200 m (tức là cách mặt nước biển 200 m)?</li>
</ol>
<div><img src="/static/img/sgk9/sgk9-c4-hinh-4-31.png" alt="Hình 4.31 - SGK Toán 9"></div>', N'<p><b>a)</b> Quãng đường đi được $AH=200$ m là cạnh huyền, độ sâu $BH$ là cạnh đối của góc $21^\circ$: $BH=200\sin21^\circ\approx71{,}7\approx72$ (m).</p>
<p><b>b)</b> Để tàu ở độ sâu $BH=200$ m, quãng đường tàu phải đi là $AH=\dfrac{200}{\sin21^\circ}\approx558{,}1$ (m). Tốc độ $9$ km/h $=9000$ m/h nên thời gian là $\dfrac{558{,}1}{9000}\approx0{,}062$ giờ, tức khoảng $3{,}72$ phút (khoảng 3 phút 43 giây).</p>
<p><b>Đáp số:</b> a) khoảng 72 m. b) khoảng 3,7 phút (khoảng 3 phút 43 giây).</p>', 3, 0, 1, @t1);

-- Bài tập cuối chương IV
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài tập cuối chương IV', N'Ôn tập chương IV: tỉ số lượng giác của góc nhọn, hệ thức giữa cạnh và góc trong tam giác vuông, giải tam giác vuông.', N'<p><b>Tóm tắt kiến thức chương IV.</b> Cho tam giác $ABC$ vuông tại $A$ ($a=BC$, $b=AC$, $c=AB$):</p>
<ul>
<li>$\sin B=\dfrac{b}{a}$, $\cos B=\dfrac{c}{a}$, $\tan B=\dfrac{b}{c}$, $\cot B=\dfrac{c}{b}$; $\cot\alpha=\dfrac{1}{\tan\alpha}$.</li>
<li>Hai góc phụ nhau: $\sin\alpha=\cos(90^\circ-\alpha)$, $\tan\alpha=\cot(90^\circ-\alpha)$.</li>
<li>$\sin^2\alpha+\cos^2\alpha=1$ (từ định lí Pythagore).</li>
<li>Hệ thức cạnh và góc: $b=a\sin B=a\cos C=c\tan B=c\cot C$; $c=a\sin C=a\cos B=b\tan C=b\cot B$.</li>
<li>Giải tam giác vuông: biết hai cạnh hoặc một cạnh và một góc nhọn thì tìm được các cạnh và góc còn lại ($\widehat{B}+\widehat{C}=90^\circ$).</li>
<li>Giá trị đặc biệt: $\tan30^\circ=\dfrac{\sqrt3}{3}=\dfrac{1}{\sqrt3}$, $\tan45^\circ=1$, $\tan60^\circ=\sqrt3$.</li>
</ul>', 4, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 4.21.</b> Trong Hình 4.32, $\cos\alpha$ bằng</p>
<p>(Hình 4.32: tam giác vuông có hai cạnh góc vuông bằng 3 và 4, cạnh huyền bằng 5; góc $\alpha$ là góc nhọn nằm giữa cạnh góc vuông 3 và cạnh huyền 5.)</p>', N'<p>Góc $\alpha$ có cạnh kề là cạnh góc vuông 3 và cạnh huyền là 5 nên $\cos\alpha=\dfrac{3}{5}$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$\dfrac{5}{3}$.', 0),
(@q, 'B', N'$\dfrac{3}{4}$.', 0),
(@q, 'C', N'$\dfrac{3}{5}$.', 1),
(@q, 'D', N'$\dfrac{4}{5}$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 4.22.</b> Trong tam giác $MNP$ vuông tại $M$ (H.4.33), $\sin\widehat{MNP}$ bằng</p>', N'<p>Với góc $N$: cạnh đối là $MP$, cạnh huyền là $NP$ (tam giác vuông tại $M$) nên $\sin\widehat{MNP}=\dfrac{MP}{PN}$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$\dfrac{PN}{NM}$.', 0),
(@q, 'B', N'$\dfrac{MP}{PN}$.', 1),
(@q, 'C', N'$\dfrac{MN}{PN}$.', 0),
(@q, 'D', N'$\dfrac{MN}{MP}$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 4.23.</b> Trong tam giác $ABC$ vuông tại $A$ (H.4.34), $\tan B$ bằng</p>', N'<p>Với góc $B$: cạnh đối là $AC$, cạnh kề là $AB$ nên $\tan B=\dfrac{AC}{AB}$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$\dfrac{AB}{AC}$.', 0),
(@q, 'B', N'$\dfrac{AC}{AB}$.', 1),
(@q, 'C', N'$\dfrac{AB}{BC}$.', 0),
(@q, 'D', N'$\dfrac{BC}{AC}$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 4.24.</b> Với mọi góc nhọn $\alpha$, ta có</p>', N'<p>Hai góc $\alpha$ và $90^\circ-\alpha$ phụ nhau nên $\sin(90^\circ-\alpha)=\cos\alpha$ (A đúng). Các phương án còn lại sai: $\tan(90^\circ-\alpha)=\cot\alpha$ (khác $\cos\alpha$); $\cot(90^\circ-\alpha)=\tan\alpha$ (khác $1-\tan\alpha$ và khác $\sin\alpha$).</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$\sin(90^\circ-\alpha)=\cos\alpha$.', 1),
(@q, 'B', N'$\tan(90^\circ-\alpha)=\cos\alpha$.', 0),
(@q, 'C', N'$\cot(90^\circ-\alpha)=1-\tan\alpha$.', 0),
(@q, 'D', N'$\cot(90^\circ-\alpha)=\sin\alpha$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 4.25.</b> Giá trị $\tan30^\circ$ bằng</p>', N'<p>Theo bảng giá trị lượng giác của các góc đặc biệt, $\tan30^\circ=\dfrac{\sqrt3}{3}=\dfrac{1}{\sqrt3}$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$\sqrt3$.', 0),
(@q, 'B', N'$\dfrac{\sqrt3}{2}$.', 0),
(@q, 'C', N'$\dfrac{1}{\sqrt3}$.', 1),
(@q, 'D', N'$1$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.26.</b> Xét các tam giác vuông có một góc nhọn bằng hai lần góc nhọn còn lại. Hỏi các tam giác đó có đồng dạng với nhau không? Tính sin và côsin của góc nhọn lớn hơn.</p>', N'<p>Gọi hai góc nhọn là $\alpha$ và $2\alpha$. Vì tổng hai góc nhọn của tam giác vuông là $90^\circ$ nên $\alpha+2\alpha=90^\circ$, suy ra $\alpha=30^\circ$ và góc lớn là $60^\circ$.</p>
<p>Mọi tam giác vuông như vậy đều có các góc là $90^\circ,\ 30^\circ,\ 60^\circ$ nên chúng đồng dạng với nhau (trường hợp góc - góc).</p>
<p>Góc nhọn lớn hơn là $60^\circ$: $\sin60^\circ=\dfrac{\sqrt3}{2}$, $\cos60^\circ=\dfrac{1}{2}$.</p>
<p><b>Đáp số:</b> đồng dạng; $\sin60^\circ=\dfrac{\sqrt3}{2}$, $\cos60^\circ=\dfrac{1}{2}$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.27.</b> Hình 4.35 là mô hình của một túp lều. Tìm góc $\alpha$ giữa cạnh mái lều và mặt đất (làm tròn kết quả đến phút).</p>
<p>(Mặt cắt của túp lều là tam giác cân có đáy 4,4 m và chiều cao 1,8 m.)</p>
<div><img src="/static/img/sgk9/sgk9-c4-hinh-4-35.png" alt="Hình 4.35 - SGK Toán 9"></div>', N'<p>Mặt cắt là tam giác cân; đường cao chia tam giác thành hai tam giác vuông có cạnh góc vuông là $\dfrac{4{,}4}{2}=2{,}2$ m và $1{,}8$ m.</p>
<p>$\tan\alpha=\dfrac{1{,}8}{2{,}2}=\dfrac{9}{11}\approx0{,}8182$, suy ra $\alpha\approx39^\circ17^{\prime}$.</p>
<p><b>Đáp số:</b> $\alpha\approx39^\circ17^{\prime}$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.28.</b> Một cây cao bị gãy, ngọn cây đổ xuống mặt đất. Ba điểm: gốc cây, điểm gãy, ngọn cây tạo thành một tam giác vuông. Đoạn cây gãy tạo với mặt đất góc $20^\circ$ và chắn ngang lối đi một đoạn 5 m (H.4.36). Hỏi trước khi bị gãy, cây cao khoảng bao nhiêu mét (làm tròn kết quả đến hàng phần mười)?</p>
<div><img src="/static/img/sgk9/sgk9-c4-hinh-4-36.png" alt="Hình 4.36 - SGK Toán 9"></div>', N'<p>Gọi $O$ là gốc cây, $G$ là điểm gãy, $N$ là ngọn cây chạm đất. Tam giác $OGN$ vuông tại $O$, $ON=5$ m, $\widehat{N}=20^\circ$.</p>
<p>Phần cây còn đứng: $OG=ON\cdot\tan20^\circ=5\tan20^\circ\approx1{,}82$ (m). Phần cây gãy: $GN=\dfrac{ON}{\cos20^\circ}=\dfrac{5}{\cos20^\circ}\approx5{,}32$ (m).</p>
<p>Chiều cao ban đầu của cây: $OG+GN\approx1{,}82+5{,}32=7{,}14\approx7{,}1$ (m).</p>
<p><b>Đáp số:</b> khoảng 7,1 m.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.29.</b> Cho tam giác $ABC$ vuông tại $A$, có $\widehat{B}=\alpha$ (H.4.37).</p>
<ol type="a">
<li>Hãy viết các tỉ số lượng giác $\sin\alpha$, $\cos\alpha$.</li>
<li>Sử dụng định lí Pythagore, chứng minh rằng $\sin^2\alpha+\cos^2\alpha=1$.</li>
</ol>', N'<p><b>a)</b> $\sin\alpha=\dfrac{AC}{BC}$, $\cos\alpha=\dfrac{AB}{BC}$.</p>
<p><b>b)</b> $\sin^2\alpha+\cos^2\alpha=\dfrac{AC^2}{BC^2}+\dfrac{AB^2}{BC^2}=\dfrac{AC^2+AB^2}{BC^2}$. Theo định lí Pythagore, $AC^2+AB^2=BC^2$ nên biểu thức bằng $\dfrac{BC^2}{BC^2}=1$. Vậy $\sin^2\alpha+\cos^2\alpha=1$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 4.30. ĐỐ VUI. Chu vi Trái Đất bằng bao nhiêu?</b> Vào khoảng năm 200 trước Công nguyên, Eratosthenes, một nhà toán học và thiên văn học người Hy Lạp, đã ước lượng được "chu vi" của Trái Đất (chu vi của đường Xích Đạo) nhờ hai quan sát sau:</p>
<p>1. Hồi đó, hằng năm cứ vào trưa ngày Hạ chí (21/6), người ta thấy tia sáng mặt trời chiếu thẳng xuống đáy một cái giếng sâu nổi tiếng ở thành phố Syene (Xy-en), tức là tia sáng chiếu thẳng đứng.</p>
<p>2. Cũng vào trưa một ngày Hạ chí, ở thành phố Alexandria (A-lếch-xăng-đri-a) cách Syene 800 km, Eratosthenes thấy một tháp cao 25 m có bóng trên mặt đất dài 3,1 m.</p>
<p>Từ hai quan sát trên, ông có thể tính xấp xỉ "chu vi" của Trái Đất như thế nào? (Trên Hình 4.38, điểm $O$ là tâm Trái Đất, điểm $S$ tượng trưng cho thành phố Syene, điểm $A$ tượng trưng cho thành phố Alexandria, điểm $H$ là đỉnh của tháp, bóng của tháp trên mặt đất được coi là đoạn thẳng $AB$.)</p>
<div><img src="/static/img/sgk9/sgk9-c4-hinh-4-38.png" alt="Hình 4.38 - SGK Toán 9"></div>', N'<p>Gọi $\widehat{AHB}$ là góc giữa tia nắng và tháp tại Alexandria. Tam giác $HAB$ vuông tại $A$ có $AH=25$ m, $AB=3{,}1$ m nên $\tan\widehat{AHB}=\dfrac{3{,}1}{25}=0{,}124$, suy ra $\widehat{AHB}\approx7{,}07^\circ$.</p>
<p>Các tia nắng mặt trời song song, và tia nắng chiếu thẳng đứng tại Syene đi qua tâm $O$ nên góc ở tâm $\widehat{AOS}$ bằng $\widehat{AHB}$ (hai góc đồng vị / so le trong), tức $\widehat{AOS}\approx7{,}07^\circ$.</p>
<p>Cung $AS$ dài 800 km ứng với góc ở tâm $7{,}07^\circ$, còn cả đường Xích Đạo ứng với $360^\circ$ nên chu vi Trái Đất xấp xỉ $$800\cdot\dfrac{360}{7{,}07}\approx40\,700\ \text{(km)}.$$</p>
<p><b>Đáp số:</b> khoảng 40 700 km (thực tế khoảng 40 075 km).</p>', 3, 0, 1, @t1);

-- ---------------------------------------------------------------------------------------------------------------------
-- Chương V. Đường tròn
-- ---------------------------------------------------------------------------------------------------------------------
INSERT INTO Topics (TopicName, [Description], TeacherId, OrderIndex, IsActive) VALUES (N'Chương V. Đường tròn', N'Mở đầu về đường tròn, cung và dây của đường tròn, độ dài cung tròn, diện tích hình quạt tròn và hình vành khuyên, vị trí tương đối của đường thẳng và đường tròn, vị trí tương đối của hai đường tròn. (SGK Toán 9 Kết nối tri thức với cuộc sống, Tập 1)', @t1, 5, 1);
SET @tp = SCOPE_IDENTITY();

-- Bài 13
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 13. Mở đầu về đường tròn', N'Định nghĩa đường tròn, vị trí của một điểm so với đường tròn, tâm đối xứng và trục đối xứng của đường tròn.', N'<p><b>1. Đường tròn.</b> Đường tròn tâm $O$ bán kính $R$ ($R\gt0$), kí hiệu là $(O;R)$, là hình gồm tất cả các điểm cách điểm $O$ một khoảng bằng $R$. Khi không cần để ý đến bán kính, ta kí hiệu đường tròn tâm $O$ là $(O)$. Nếu $A$ là một điểm của đường tròn $(O)$ thì ta viết $A\in(O)$ và nói đường tròn $(O)$ đi qua $A$, hay $A$ nằm trên $(O)$.</p>
<p><b>Vị trí của một điểm đối với đường tròn.</b> Với điểm $M$ và đường tròn $(O;R)$:</p>
<ul>
<li>$M$ nằm trên đường tròn nếu $OM=R$;</li>
<li>$M$ nằm trong đường tròn nếu $OM\lt R$;</li>
<li>$M$ nằm ngoài đường tròn nếu $OM\gt R$.</li>
</ul>
<p><b>Hình tròn</b> tâm $O$ bán kính $R$ là hình gồm các điểm nằm trên và nằm trong đường tròn $(O;R)$.</p>
<p><b>Ví dụ 1.</b> Gọi $O$ là trung điểm của đoạn thẳng $AB$. Chứng minh rằng đường tròn $(O;OA)$ đi qua $B$. Vì $O$ là trung điểm của $AB$ nên $OB=OA$, do đó $B\in(O;OA)$. Khi đó $AB$ là một <b>đường kính</b> và $(O)$ còn gọi là đường tròn đường kính $AB$.</p>
<p><b>2. Tính đối xứng của đường tròn.</b></p>
<ul>
<li>Hai điểm $M$ và $M''$ đối xứng nhau qua điểm $I$ (qua tâm $I$) nếu $I$ là trung điểm của $MM''$.</li>
<li>Hai điểm $M$ và $M''$ đối xứng nhau qua đường thẳng $d$ (qua trục $d$) nếu $d$ là đường trung trực của $MM''$.</li>
</ul>
<p>Nếu một điểm thuộc $(O)$ thì điểm đối xứng với nó qua tâm $O$, hoặc qua một đường thẳng bất kì đi qua $O$, cũng thuộc $(O)$. Vì vậy:</p>
<ul>
<li>Đường tròn là hình có <b>tâm đối xứng</b>; tâm của đường tròn là tâm đối xứng của nó.</li>
<li>Đường tròn là hình có <b>trục đối xứng</b>; mỗi đường thẳng đi qua tâm là một trục đối xứng của nó. Đường tròn có một tâm đối xứng nhưng có vô số trục đối xứng.</li>
</ul>
<p><b>Ví dụ 2.</b> Cho $M$ nằm trên đường tròn $(O)$ đường kính $AB$. Điểm $N$ đối xứng với $M$ qua $O$ là giao điểm (khác $M$) của $(O)$ với đường thẳng $OM$. Điểm $P$ đối xứng với $M$ qua $AB$ là giao điểm (khác $M$) của $(O)$ với đường thẳng đi qua $M$ và vuông góc với $AB$.</p>', 1, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.1.</b> Trong mặt phẳng tọa độ $Oxy$, cho các điểm $M(0;2)$, $N(0;-3)$ và $P(2;-1)$. Vẽ hình và cho biết trong các điểm đã cho, điểm nào nằm trên, điểm nào nằm trong, điểm nào nằm ngoài đường tròn $(O;\sqrt{5})$? Vì sao?</p>', N'<p>Tính khoảng cách từ gốc tọa độ $O$ đến từng điểm và so sánh với $R=\sqrt{5}\approx2{,}24$:</p>
<ul>
<li>$OM=2\lt\sqrt{5}$ nên $M$ nằm <b>trong</b> đường tròn.</li>
<li>$ON=3\gt\sqrt{5}$ nên $N$ nằm <b>ngoài</b> đường tròn.</li>
<li>$OP=\sqrt{2^2+(-1)^2}=\sqrt{5}$ nên $P$ nằm <b>trên</b> đường tròn.</li>
</ul>
<p><b>Đáp số:</b> $P$ nằm trên, $M$ nằm trong, $N$ nằm ngoài đường tròn $(O;\sqrt{5})$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.2.</b> Cho tam giác $ABC$ vuông tại $A$ có $AB=3$ cm, $AC=4$ cm. Chứng minh rằng các điểm $A,\ B,\ C$ thuộc cùng một đường tròn. Tính bán kính của đường tròn đó.</p>', N'<p>Gọi $O$ là trung điểm của cạnh huyền $BC$. Trong tam giác vuông, đường trung tuyến ứng với cạnh huyền bằng nửa cạnh huyền nên $OA=OB=OC=\dfrac{BC}{2}$. Do đó $A,\ B,\ C$ cùng thuộc đường tròn tâm $O$ bán kính $\dfrac{BC}{2}$.</p>
<p>Theo định lí Pythagore: $BC=\sqrt{AB^2+AC^2}=\sqrt{9+16}=5$ (cm). Vậy bán kính $R=\dfrac{5}{2}=2{,}5$ cm.</p>
<p><b>Đáp số:</b> $R=2{,}5$ cm.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.3.</b> Cho đường tròn $(O)$, đường thẳng $d$ đi qua $O$ và điểm $A$ thuộc $(O)$ nhưng không thuộc $d$. Gọi $B$ là điểm đối xứng với $A$ qua $d$; $C$ và $D$ lần lượt là điểm đối xứng với $A$ và $B$ qua $O$.</p>
<ol type="a">
<li>Ba điểm $B,\ C$ và $D$ có thuộc $(O)$ không? Vì sao?</li>
<li>Chứng minh tứ giác $ABCD$ là hình chữ nhật.</li>
<li>Chứng minh rằng $C$ và $D$ đối xứng với nhau qua $d$.</li>
</ol>', N'<p><b>a)</b> Đường tròn đối xứng qua mọi đường thẳng đi qua tâm và đối xứng qua tâm $O$. Vì $A\in(O)$ nên $B$ (đối xứng với $A$ qua $d$, $d$ đi qua $O$) thuộc $(O)$; $C$ (đối xứng với $A$ qua $O$) thuộc $(O)$; $D$ (đối xứng với $B$ qua $O$) thuộc $(O)$. Vậy cả ba điểm $B,\ C,\ D$ đều thuộc $(O)$.</p>
<p><b>b)</b> $O$ là trung điểm của $AC$ và của $BD$ nên $ABCD$ là hình bình hành. Hơn nữa $AC$ và $BD$ đều là đường kính của $(O)$ nên $AC=BD=2R$. Hình bình hành có hai đường chéo bằng nhau là hình chữ nhật.</p>
<p><b>c)</b> Vì $B$ đối xứng với $A$ qua $d$ nên $d$ là đường trung trực của $AB$, suy ra $d\perp AB$. Trong hình chữ nhật $ABCD$ có $CD\parallel AB$ nên $d\perp CD$. Mặt khác $OC=OD$ (cùng bằng $R$) nên tam giác $OCD$ cân tại $O$ và $d$ đi qua $O$, vuông góc với $CD$, do đó $d$ là đường cao và cũng là đường trung trực của $CD$. Vậy $C$ và $D$ đối xứng với nhau qua $d$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.4.</b> Cho hình vuông $ABCD$ có $E$ là giao điểm của hai đường chéo.</p>
<ol type="a">
<li>Chứng minh rằng có một đường tròn đi qua bốn điểm $A,\ B,\ C$ và $D$. Xác định tâm đối xứng và chỉ ra hai trục đối xứng của đường tròn đó.</li>
<li>Tính bán kính của đường tròn ở câu a, biết rằng hình vuông có cạnh bằng 3 cm.</li>
</ol>', N'<p><b>a)</b> Trong hình vuông, hai đường chéo cắt nhau tại trung điểm mỗi đường và bằng nhau nên $EA=EB=EC=ED$. Vậy bốn điểm $A,\ B,\ C,\ D$ cùng thuộc đường tròn tâm $E$. Tâm đối xứng của đường tròn là $E$; hai trục đối xứng có thể chọn là hai đường chéo $AC$ và $BD$ (mỗi đường thẳng đi qua $E$ đều là trục đối xứng).</p>
<p><b>b)</b> Với cạnh bằng 3 cm, đường chéo $AC=3\sqrt{2}$ cm. Bán kính $R=EA=\dfrac{AC}{2}=\dfrac{3\sqrt{2}}{2}\approx2{,}12$ cm.</p>
<p><b>Đáp số:</b> b) $R=\dfrac{3\sqrt{2}}{2}$ cm $\approx2{,}12$ cm.</p>', 1, 0, 1, @t1);

-- Bài 14
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 14. Cung và dây của một đường tròn', N'Dây và đường kính, quan hệ giữa dây và đường kính; góc ở tâm, cung tròn và số đo của một cung.', N'<p><b>1. Dây và đường kính.</b> Đoạn thẳng nối hai điểm tùy ý của một đường tròn gọi là một <b>dây</b> (hay dây cung). Mỗi dây đi qua tâm là một <b>đường kính</b>; đường kính của đường tròn bán kính $R$ có độ dài $2R$.</p>
<p><b>Định lí.</b> Trong một đường tròn, đường kính là dây cung lớn nhất. (Với dây $AB$ không đi qua tâm $O$, tam giác $AOB$ có $AB\lt OA+OB=2R$.)</p>
<p><b>Ví dụ 1.</b> Tứ giác lồi $ABCD$ có $\widehat{BAC}=\widehat{BDC}=90^\circ$. Chứng minh bốn điểm $A,\ B,\ C,\ D$ cùng nằm trên một đường tròn và $AD\lt BC$. Gọi $O$ là trung điểm $BC$. Tam giác $ABC$ vuông tại $A$ nên $OA=OB=OC=\dfrac{BC}{2}$; tương tự với tam giác $DBC$ ta có $OD=\dfrac{BC}{2}$. Vậy bốn điểm cùng thuộc đường tròn đường kính $BC$. Vì $AD$ là một dây không đi qua tâm nên $AD\lt BC$.</p>
<p><b>2. Góc ở tâm, cung và số đo cung.</b> Hai điểm $A$, $B$ thuộc đường tròn chia đường tròn thành hai phần, mỗi phần gọi là một <b>cung tròn</b>; $A$, $B$ là hai mút của cung. <b>Góc ở tâm</b> là góc có đỉnh trùng với tâm đường tròn.</p>
<ul>
<li>Khi góc $AOB$ không bẹt thì cung nằm trong góc $AOB$ gọi là <b>cung nhỏ</b>, cung còn lại gọi là <b>cung lớn</b>. Khi góc $AOB$ bẹt thì mỗi cung gọi là một <b>nửa đường tròn</b>.</li>
<li>Ta nói góc $AOB$ chắn cung $AB$, hay cung $AB$ bị chắn bởi góc $AOB$.</li>
</ul>
<p><b>Số đo của một cung:</b></p>
<ul>
<li>Số đo của nửa đường tròn bằng $180^\circ$.</li>
<li>Số đo của cung nhỏ bằng số đo của góc ở tâm chắn cung đó.</li>
<li>Số đo của cung lớn bằng hiệu giữa $360^\circ$ và số đo của cung nhỏ có chung hai mút.</li>
</ul>
<p>Kí hiệu số đo cung $AB$ là $\mathrm{sđ}\,\overset{\frown}{AB}$. Nếu $\mathrm{sđ}\,\overset{\frown}{AmB}=\widehat{AOB}=\alpha$ ($0^\circ\lt\alpha\le180^\circ$) thì $\mathrm{sđ}\,\overset{\frown}{AnB}=360^\circ-\alpha$. Cả đường tròn là cung $360^\circ$. Hai cung trên một đường tròn bằng nhau nếu chúng có cùng số đo.</p>
<p><b>Nhận xét.</b> Nếu $A$ là một điểm thuộc cung $BAC$ thì $\mathrm{sđ}\,\overset{\frown}{BAC}=\mathrm{sđ}\,\overset{\frown}{BA}+\mathrm{sđ}\,\overset{\frown}{AC}$.</p>
<p><b>Ví dụ 3.</b> Tam giác $ABC$ vuông cân tại $A$ nội tiếp đường tròn tâm $O$ (là trung điểm $BC$). Vì $AO\perp BC$ nên $\widehat{AOB}=\widehat{AOC}=90^\circ$, suy ra $\mathrm{sđ}\,\overset{\frown}{AB}=\mathrm{sđ}\,\overset{\frown}{AC}=90^\circ$; các cung lớn $\mathrm{sđ}\,\overset{\frown}{ACB}=\mathrm{sđ}\,\overset{\frown}{ABC}=360^\circ-90^\circ=270^\circ$; hai nửa đường tròn đường kính $BC$ có số đo $180^\circ$.</p>', 2, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.5.</b> Cho nửa đường tròn đường kính $AB$ và một điểm $M$ tùy ý thuộc nửa đường tròn đó. Chứng minh rằng khoảng cách từ $M$ đến $AB$ không lớn hơn $\dfrac{AB}{2}$.</p>', N'<p>Gọi $O$ là trung điểm của $AB$ và $H$ là chân đường vuông góc hạ từ $M$ xuống $AB$. Khoảng cách từ $M$ đến $AB$ là $MH$.</p>
<p>Vì $M\in(O)$ nên $OM=\dfrac{AB}{2}$. Nếu $H$ trùng $O$ thì $MH=MO$. Nếu $H$ khác $O$, tam giác $MHO$ vuông tại $H$ có $MO$ là cạnh huyền nên $MH\lt MO$. Trong cả hai trường hợp, $MH\le MO=\dfrac{AB}{2}$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.6.</b> Cho đường tròn $(O;5\text{ cm})$ và $AB$ là một dây bất kì của đường tròn đó. Biết $AB=6$ cm.</p>
<ol type="a">
<li>Tính khoảng cách từ $O$ đến đường thẳng $AB$.</li>
<li>Tính $\tan\alpha$ nếu góc ở tâm chắn cung $AB$ bằng $2\alpha$.</li>
</ol>', N'<p><b>a)</b> Gọi $H$ là chân đường vuông góc hạ từ $O$ xuống $AB$. Tam giác $OAB$ cân tại $O$ nên $H$ là trung điểm của $AB$, $AH=3$ cm. Trong tam giác vuông $OHA$: $OH=\sqrt{OA^2-AH^2}=\sqrt{25-9}=4$ (cm).</p>
<p><b>b)</b> Vì $OH$ cũng là đường phân giác của góc $AOB$ nên $\widehat{AOH}=\dfrac{1}{2}\widehat{AOB}=\alpha$. Trong tam giác vuông $OHA$: $\tan\alpha=\dfrac{AH}{OH}=\dfrac{3}{4}=0{,}75$.</p>
<p><b>Đáp số:</b> a) 4 cm. b) $\tan\alpha=\dfrac{3}{4}$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.7.</b> Tâm $O$ của một đường tròn cách dây $AB$ của nó một khoảng 3 cm. Tính bán kính của đường tròn $(O)$, biết rằng cung nhỏ $AB$ có số đo bằng $100^\circ$ (làm tròn kết quả đến hàng phần mười).</p>', N'<p>Gọi $H$ là chân đường vuông góc hạ từ $O$ xuống $AB$, $OH=3$ cm. Vì $\mathrm{sđ}\,\overset{\frown}{AB}=100^\circ$ nên $\widehat{AOB}=100^\circ$. Tam giác $OAB$ cân tại $O$ nên $OH$ là đường phân giác: $\widehat{AOH}=50^\circ$.</p>
<p>Trong tam giác vuông $OHA$: $\cos\widehat{AOH}=\dfrac{OH}{OA}$, suy ra $R=OA=\dfrac{3}{\cos50^\circ}\approx\dfrac{3}{0{,}6428}\approx4{,}67$.</p>
<p><b>Đáp số:</b> $R\approx4{,}7$ cm.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.8.</b> Trên mặt một chiếc đồng hồ có các vạch chia như Hình 5.12 (60 vạch phút, vòng ngoài có 12 số). Hỏi cứ sau mỗi khoảng thời gian 36 phút:</p>
<ol type="a">
<li>Đầu kim phút vạch nên một cung có số đo bằng bao nhiêu độ?</li>
<li>Đầu kim giờ vạch nên một cung có số đo bằng bao nhiêu độ?</li>
</ol>
<div><img src="/static/img/sgk9/sgk9-c5-hinh-5-12.png" alt="Hình 5.12: mặt đồng hồ có các vạch chia"></div>', N'<p><b>a)</b> Kim phút quay một vòng ($360^\circ$) trong 60 phút nên trong 36 phút nó vạch nên cung có số đo $\dfrac{36}{60}\cdot360^\circ=216^\circ$.</p>
<p><b>b)</b> Kim giờ quay một vòng ($360^\circ$) trong 12 giờ, tức mỗi giờ quay $30^\circ$. Đổi 36 phút $=0{,}6$ giờ nên kim giờ vạch nên cung có số đo $0{,}6\cdot30^\circ=18^\circ$.</p>
<p><b>Đáp số:</b> a) $216^\circ$. b) $18^\circ$.</p>', 1, 0, 1, @t1);

-- Bài 15
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 15. Độ dài của cung tròn. Diện tích hình quạt tròn và hình vành khuyên', N'Công thức tính độ dài cung tròn, diện tích hình quạt tròn và diện tích hình vành khuyên.', N'<p><b>1. Độ dài cung tròn.</b> Độ dài $C$ của đường tròn $(O;R)$ có đường kính $d=2R$ là $$C=\pi d=2\pi R.$$ Độ dài $l$ của cung $n^\circ$ trên đường tròn bán kính $R$ là $$l=\dfrac{n}{180}\pi R.$$ Nhận xét: $\dfrac{l}{C}=\dfrac{n}{360}$, tức là tỉ số giữa độ dài cung $n^\circ$ và độ dài đường tròn (cùng bán kính) đúng bằng $\dfrac{n}{360}$.</p>
<p><b>Ví dụ 1.</b> Cho $A$, $B$ thuộc đường tròn $(O;3\text{ cm})$ sao cho $\widehat{AOB}=120^\circ$. Cung nhỏ $AB$ có số đo $120^\circ$, độ dài $l_1=\dfrac{120}{180}\pi\cdot3=2\pi$ (cm). Cung lớn có số đo $360^\circ-120^\circ=240^\circ$, độ dài $l_2=\dfrac{240}{180}\pi\cdot3=4\pi$ (cm).</p>
<p><b>2. Hình quạt tròn và hình vành khuyên.</b></p>
<ul>
<li><b>Hình quạt tròn</b> là phần hình tròn giới hạn bởi một cung tròn và hai bán kính đi qua hai mút của cung đó.</li>
<li><b>Hình vành khuyên</b> (hình vành khăn) là phần nằm giữa hai đường tròn đồng tâm có bán kính khác nhau.</li>
</ul>
<p>Diện tích hình tròn bán kính $R$ là $S=\pi R^2$.</p>
<ul>
<li>Diện tích $S_q$ của hình quạt tròn bán kính $R$ ứng với cung $n^\circ$: $$S_q=\dfrac{n}{360}\pi R^2=\dfrac{l\cdot R}{2}.$$</li>
<li>Diện tích $S_v$ của hình vành khuyên tạo bởi hai đường tròn đồng tâm bán kính $R$ và $r$ ($R\gt r$): $$S_v=\pi(R^2-r^2).$$</li>
</ul>
<p>Nhận xét: $\dfrac{S_q}{S}=\dfrac{n}{360}=\dfrac{l}{C}$.</p>
<p><b>Ví dụ 2.</b> Diện tích hình vành khuyên nằm giữa hai đường tròn đồng tâm bán kính 3 m và 5 m là $S_v=\pi(5^2-3^2)=16\pi$ (m²).</p>
<p><b>Ví dụ 3.</b> Hình quạt tròn bán kính $R=5$ cm có độ dài cung $l=4\pi$ cm có diện tích $S=\dfrac{l\cdot R}{2}=\dfrac{4\pi\cdot5}{2}=10\pi$ (cm²).</p>', 3, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.9.</b> Cho đường tròn $(O;4\text{ cm})$ và ba điểm $A,\ B,\ C$ trên đường tròn đó sao cho tam giác $ABC$ cân tại đỉnh $A$ và số đo của cung nhỏ $BC$ bằng $70^\circ$.</p>
<ol type="a">
<li>Giải thích tại sao hai cung nhỏ $AB$ và $AC$ bằng nhau.</li>
<li>Tính độ dài của các cung $BC$, $AB$ và $AC$ (làm tròn kết quả đến hàng phần mười).</li>
</ol>', N'<p><b>a)</b> Tam giác $ABC$ cân tại $A$ nên $AB=AC$. Hai tam giác $OAB$ và $OAC$ có $OA$ chung, $OB=OC=R$, $AB=AC$ nên bằng nhau (c.c.c), suy ra $\widehat{AOB}=\widehat{AOC}$. Do đó hai cung nhỏ $AB$ và $AC$ có cùng số đo, tức là bằng nhau.</p>
<p><b>b)</b> Cung nhỏ $BC$ có số đo $70^\circ$ nên $l_{BC}=\dfrac{70}{180}\pi\cdot4=\dfrac{14\pi}{9}\approx4{,}9$ (cm).</p>
<p>Điểm $A$ cách đều $B$, $C$ nên nằm trên đường trung trực của $BC$, đường này đi qua $O$ và cắt $(O)$ tại hai điểm là điểm chính giữa của cung nhỏ $BC$ và điểm chính giữa của cung lớn $BC$. Với hình thường gặp, $A$ nằm trên cung lớn $BC$: $\mathrm{sđ}\,\overset{\frown}{AB}=\mathrm{sđ}\,\overset{\frown}{AC}=\dfrac{360^\circ-70^\circ}{2}=145^\circ$ nên $l_{AB}=l_{AC}=\dfrac{145}{180}\pi\cdot4=\dfrac{29\pi}{9}\approx10{,}1$ (cm).</p>
<p>(Nếu $A$ là điểm chính giữa của cung nhỏ $BC$ thì $\mathrm{sđ}\,\overset{\frown}{AB}=\mathrm{sđ}\,\overset{\frown}{AC}=35^\circ$ và $l_{AB}=l_{AC}=\dfrac{35}{180}\pi\cdot4=\dfrac{7\pi}{9}\approx2{,}4$ cm.)</p>
<p><b>Đáp số:</b> $l_{BC}\approx4{,}9$ cm; $l_{AB}=l_{AC}\approx10{,}1$ cm (với $A$ trên cung lớn $BC$).</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.10.</b> Tính diện tích của hình quạt tròn bán kính 4 cm, ứng với cung $36^\circ$.</p>', N'<p>$S_q=\dfrac{n}{360}\pi R^2=\dfrac{36}{360}\pi\cdot4^2=\dfrac{1}{10}\cdot16\pi=1{,}6\pi$ (cm²) $\approx5{,}03$ cm².</p>
<p><b>Đáp số:</b> $1{,}6\pi$ cm² (khoảng $5{,}03$ cm²).</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.11.</b> Tính diện tích hình vành khuyên nằm giữa hai đường tròn đồng tâm có bán kính là 6 cm và 4 cm.</p>', N'<p>$S_v=\pi(R^2-r^2)=\pi(6^2-4^2)=20\pi$ (cm²) $\approx62{,}83$ cm².</p>
<p><b>Đáp số:</b> $20\pi$ cm² (khoảng $62{,}83$ cm²).</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.12.</b> Có hai chiếc bánh pizza hình tròn (Hình 5.18). Chiếc bánh thứ nhất có đường kính 16 cm được cắt thành 6 miếng đều nhau có dạng hình quạt tròn. Chiếc bánh thứ hai có đường kính 18 cm được cắt thành 8 miếng đều nhau có dạng hình quạt tròn. Hãy so sánh diện tích bề mặt của hai miếng bánh cắt ra từ chiếc bánh thứ nhất và thứ hai.</p>', N'<p>Chiếc bánh thứ nhất: $R_1=8$ cm, mỗi miếng ứng với cung $\dfrac{360^\circ}{6}=60^\circ$ nên diện tích mỗi miếng $S_1=\dfrac{1}{6}\pi\cdot8^2=\dfrac{32\pi}{3}\approx33{,}51$ (cm²).</p>
<p>Chiếc bánh thứ hai: $R_2=9$ cm, mỗi miếng ứng với cung $\dfrac{360^\circ}{8}=45^\circ$ nên diện tích mỗi miếng $S_2=\dfrac{1}{8}\pi\cdot9^2=\dfrac{81\pi}{8}\approx31{,}81$ (cm²).</p>
<p>Vì $\dfrac{32}{3}\approx10{,}67\gt\dfrac{81}{8}\approx10{,}13$ nên $S_1\gt S_2$.</p>
<p><b>Đáp số:</b> miếng bánh cắt từ chiếc bánh thứ nhất có diện tích lớn hơn (khoảng $33{,}51$ cm² so với $31{,}81$ cm²).</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.13.</b> Một chiếc quạt giấy khi xòe ra có dạng nửa hình tròn bán kính 2,2 dm như Hình 5.19. Tính diện tích phần giấy của chiếc quạt, biết rằng khi gấp lại, phần giấy có chiều dài khoảng 1,6 dm (làm tròn kết quả đến hàng phần trăm của dm²).</p>
<div><img src="/static/img/sgk9/sgk9-c5-hinh-5-19.png" alt="Hình 5.19: chiếc quạt giấy khi xòe ra"></div>', N'<p>Khi xòe ra, phần giấy là nửa hình vành khuyên: bán kính ngoài $R=2{,}2$ dm, bán kính trong $r=2{,}2-1{,}6=0{,}6$ dm (phần còn lại gần tâm chỉ có các nan quạt).</p>
<p>Diện tích phần giấy: $S=\dfrac{1}{2}\pi(R^2-r^2)=\dfrac{1}{2}\pi(2{,}2^2-0{,}6^2)=\dfrac{1}{2}\pi\cdot4{,}48=2{,}24\pi\approx7{,}04$ (dm²).</p>
<p><b>Đáp số:</b> khoảng $7{,}04$ dm².</p>', 3, 0, 1, @t1);

-- Luyện tập chung (Bài 13 - Bài 15)
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Luyện tập chung (Bài 13 - Bài 15)', N'Rèn luyện chứng minh các điểm cùng thuộc đường tròn, tính số đo cung, độ dài cung và diện tích hình viên phân.', N'<p><b>Ví dụ 1.</b> Cho tam giác nhọn $ABC$ cân tại $A$. Từ $B$ và $C$ kẻ lần lượt hai đường cao $BH$ và $CK$.</p>
<ol type="a">
<li>Chứng minh đường tròn tâm $O$ đường kính $BC$ đi qua $K$ và $H$.</li>
<li>Chứng minh hai cung nhỏ $BH$ và $CK$ bằng nhau.</li>
<li>Tính số đo cung nhỏ $KH$ nếu $\widehat{BAC}=40^\circ$.</li>
</ol>
<p><i>Giải.</i> a) Gọi $O$ là trung điểm $BC$. Trong tam giác vuông $HBC$, $HO$ là trung tuyến ứng với cạnh huyền nên $OH=\dfrac{BC}{2}$; tương tự $OK=\dfrac{BC}{2}$. Vậy $H,K\in(O;\dfrac{BC}{2})$.</p>
<p>b) Hai tam giác vuông $HBC$ và $KCB$ có chung cạnh huyền $BC$ và $\widehat{ABC}=\widehat{ACB}$ nên bằng nhau, suy ra $BH=CK$. Do đó $\triangle BOH=\triangle COK$ (c.c.c), suy ra $\widehat{BOH}=\widehat{COK}$, tức $\mathrm{sđ}\,\overset{\frown}{BH}=\mathrm{sđ}\,\overset{\frown}{CK}$.</p>
<p>c) Các tam giác cân $ABC$, $OCH$, $OBK$ có góc ở đáy bằng nhau nên góc ở đỉnh bằng nhau: $\widehat{BOK}=\widehat{HOC}=\widehat{BAC}=40^\circ$. Suy ra $\widehat{KOH}=180^\circ-40^\circ-40^\circ=100^\circ$, do đó $\mathrm{sđ}\,\overset{\frown}{KH}=100^\circ$.</p>
<p><b>Ví dụ 2 (hình viên phân).</b> Hình giới hạn bởi một cung nhỏ của một đường tròn và dây căng cung đó gọi là <b>hình viên phân</b>. Với cung $90^\circ$ của đường tròn bán kính $R$: $S_q=\dfrac{90}{360}\pi R^2=\dfrac{1}{4}\pi R^2$, $S_{\triangle OAB}=\dfrac{1}{2}R^2$ nên diện tích hình viên phân là $$S=S_q-S_{\triangle OAB}=\dfrac{1}{4}\pi R^2-\dfrac{1}{2}R^2=R^2\left(\dfrac{\pi}{4}-\dfrac{1}{2}\right).$$</p>', 4, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.14.</b> Cho dây $AB$ không qua tâm của đường tròn $(O)$. Gọi $A''$ và $B''$ là hai điểm lần lượt đối xứng với $A$ và $B$ qua $O$. Hỏi đường trung trực của $A''B''$ có phải là trục đối xứng của $(O)$ hay không? Tại sao?</p>', N'<p>Vì $A,B\in(O)$ nên các điểm đối xứng $A'',B''$ của chúng qua tâm $O$ cũng thuộc $(O)$. Do đó $OA''=OB''=R$, tức $O$ cách đều hai đầu đoạn $A''B''$ nên $O$ nằm trên đường trung trực của $A''B''$.</p>
<p>Vậy đường trung trực của $A''B''$ là một đường thẳng đi qua tâm $O$. Mỗi đường thẳng đi qua tâm của đường tròn là một trục đối xứng của đường tròn, nên đường trung trực của $A''B''$ <b>là</b> trục đối xứng của $(O)$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.15.</b> Cho tam giác $ABC$ không là tam giác vuông. Gọi $H$ và $K$ là chân các đường vuông góc lần lượt hạ từ $B$ và $C$ xuống $AC$ và $AB$. Chứng minh rằng:</p>
<ol type="a">
<li>Đường tròn đường kính $BC$ đi qua các điểm $H$ và $K$;</li>
<li>$KH\lt BC$.</li>
</ol>', N'<p><b>a)</b> Gọi $O$ là trung điểm $BC$. Vì tam giác $ABC$ không vuông nên $H$ không trùng $C$ (nếu không $\widehat{C}=90^\circ$) và $K$ không trùng $B$. Tam giác $HBC$ vuông tại $H$ có $HO$ là trung tuyến ứng với cạnh huyền nên $OH=\dfrac{BC}{2}$. Tương tự tam giác $KBC$ vuông tại $K$ nên $OK=\dfrac{BC}{2}$. Vậy $H$, $K$ thuộc đường tròn đường kính $BC$.</p>
<p><b>b)</b> $KH$ là một dây của đường tròn đường kính $BC$ nên $KH\le BC$. Giả sử $KH=BC$, tức $KH$ cũng là một đường kính. Khi đó $B$ nằm trên đường tròn đường kính $KH$ nên $\widehat{KBH}=90^\circ$, tức $BH\perp BA$. Kết hợp $BH\perp AC$ ta được $AB\parallel AC$, vô lí. Vậy $KH\lt BC$.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.16.</b> Có thể xem <i>guồng nước</i> (còn gọi là <i>cọn nước</i>) là một công cụ hay cỗ máy có dạng hình tròn, quay được nhờ sức nước chảy. Guồng nước thường thấy ở các vùng miền núi, dùng để đưa nước lên ruộng cao, giã gạo hoặc làm một số việc khác.</p>
<p>Giả sử ngấn nước ngăn cách giữa phần trên và phần dưới nước của một guồng nước được biểu thị bởi cung ứng với một dây dài 4 m và điểm ngập sâu nhất là 0,5 m (trên Hình 5.22b, điểm ngập sâu nhất là điểm $C$, ta có $AB=4$ m và $HC=0{,}5$ m). Dựa vào đó, em hãy tính bán kính của guồng nước.</p>
<div><img src="/static/img/sgk9/sgk9-c5-hinh-5-22b.png" alt="Hình 5.22b: dây AB, điểm H trên AB, điểm C trên đường tròn"></div>', N'<p>Trên hình, $OC\perp AB$ tại $H$, $H$ là trung điểm của $AB$ nên $AH=2$ m. Gọi $R$ là bán kính: $OC=R$, $OH=OC-HC=R-0{,}5$.</p>
<p>Trong tam giác vuông $OHA$: $OA^2=OH^2+AH^2$, tức $R^2=(R-0{,}5)^2+4$. Khai triển: $R^2=R^2-R+0{,}25+4$, suy ra $R=4{,}25$.</p>
<p><b>Đáp số:</b> bán kính guồng nước là $4{,}25$ m.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.17.</b> Cho đường tròn $(O;5\text{ cm})$.</p>
<ol type="a">
<li>Hãy nêu cách vẽ dây $AB$ sao cho khoảng cách từ điểm $O$ đến dây $AB$ bằng 2,5 cm.</li>
<li>Tính độ dài của dây $AB$ trong câu a (làm tròn đến hàng phần trăm).</li>
<li>Tính số đo và độ dài của cung nhỏ $AB$.</li>
<li>Tính diện tích hình quạt tròn ứng với cung nhỏ $AB$.</li>
</ol>', N'<p><b>a)</b> Lấy một bán kính $OM$ bất kì, xác định trung điểm $H$ của $OM$ (khi đó $OH=2{,}5$ cm). Qua $H$ vẽ đường thẳng vuông góc với $OM$, đường thẳng này cắt $(O)$ tại $A$ và $B$. Khi đó $AB$ là dây cần vẽ.</p>
<p><b>b)</b> $H$ là trung điểm của $AB$, $AH=\sqrt{OA^2-OH^2}=\sqrt{25-6{,}25}=\sqrt{18{,}75}\approx4{,}33$ (cm). Vậy $AB=2AH\approx8{,}66$ cm.</p>
<p><b>c)</b> $\cos\widehat{AOH}=\dfrac{OH}{OA}=\dfrac{2{,}5}{5}=0{,}5$ nên $\widehat{AOH}=60^\circ$, suy ra $\widehat{AOB}=120^\circ$. Cung nhỏ $AB$ có số đo $120^\circ$, độ dài $l=\dfrac{120}{180}\pi\cdot5=\dfrac{10\pi}{3}\approx10{,}47$ (cm).</p>
<p><b>d)</b> $S_q=\dfrac{120}{360}\pi\cdot5^2=\dfrac{25\pi}{3}\approx26{,}18$ (cm²).</p>
<p><b>Đáp số:</b> b) $\approx8{,}66$ cm. c) $120^\circ$; $\approx10{,}47$ cm. d) $\approx26{,}18$ cm².</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.18.</b> Ba bộ phận truyền chuyển động của một chiếc xe đạp gồm một giò đĩa (bánh răng gắn với bàn đạp), một chiếc líp (cũng có dạng bánh răng) gắn với bánh xe và bộ xích (Hình 5.23). Biết rằng giò đĩa có bán kính 15 cm, líp có bán kính 4 cm và bánh xe có đường kính 65 cm. Hỏi khi người đi xe đạp một vòng thì xe chạy được quãng đường dài bao nhiêu mét (làm tròn đến hàng phần chục)?</p>', N'<p>Khi đạp một vòng, giò đĩa quay một vòng, xích dịch chuyển một đoạn bằng chu vi giò đĩa: $2\pi\cdot15=30\pi$ (cm).</p>
<p>Xích kéo líp quay cùng đoạn đường đó, chu vi líp là $2\pi\cdot4=8\pi$ (cm), nên líp (và bánh xe gắn với líp) quay được $\dfrac{30\pi}{8\pi}=3{,}75$ vòng.</p>
<p>Chu vi bánh xe: $\pi\cdot65$ (cm). Quãng đường xe đi được: $3{,}75\cdot65\pi=243{,}75\pi\approx765{,}8$ (cm) $\approx7{,}66$ m.</p>
<p><b>Đáp số:</b> khoảng $7{,}7$ m.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.19.</b> Cho tam giác đều $ABC$ có $AB=2\sqrt{3}$ cm. Nửa đường tròn đường kính $BC$ cắt hai cạnh $AB$ và $AC$ lần lượt tại $D$ và $E$ (khác $B$ và $C$) (Hình 5.24).</p>
<ol type="a">
<li>Chứng tỏ rằng ba cung nhỏ $BD$, $DE$ và $EC$ bằng nhau. Tính số đo mỗi cung ấy.</li>
<li>Tính diện tích của hình viên phân (xem Ví dụ 2) giới hạn bởi dây $BD$ và cung nhỏ $BD$.</li>
</ol>
<div><img src="/static/img/sgk9/sgk9-c5-hinh-5-24.png" alt="Hình 5.24: tam giác đều ABC và nửa đường tròn đường kính BC"></div>', N'<p><b>a)</b> Gọi $O$ là trung điểm $BC$ (tâm nửa đường tròn). Vì $D$ thuộc đường tròn đường kính $BC$ nên $OB=OD$; mà $\widehat{OBD}=\widehat{ABC}=60^\circ$ nên tam giác $OBD$ cân có một góc $60^\circ$, là tam giác đều, suy ra $\widehat{BOD}=60^\circ$. Tương tự $\widehat{COE}=60^\circ$. Do đó $\widehat{DOE}=180^\circ-60^\circ-60^\circ=60^\circ$.</p>
<p>Vậy $\mathrm{sđ}\,\overset{\frown}{BD}=\mathrm{sđ}\,\overset{\frown}{DE}=\mathrm{sđ}\,\overset{\frown}{EC}=60^\circ$ nên ba cung bằng nhau.</p>
<p><b>b)</b> Bán kính $R=\dfrac{BC}{2}=\sqrt{3}$ cm. Diện tích hình quạt ứng với cung $60^\circ$: $S_q=\dfrac{60}{360}\pi\cdot3=\dfrac{\pi}{2}$ (cm²). Tam giác đều $OBD$ cạnh $\sqrt{3}$ có diện tích $\dfrac{\sqrt{3}}{4}\cdot3=\dfrac{3\sqrt{3}}{4}$ (cm²). Diện tích hình viên phân: $$S=\dfrac{\pi}{2}-\dfrac{3\sqrt{3}}{4}\approx1{,}5708-1{,}2990\approx0{,}27\ (\text{cm}^2).$$</p>
<p><b>Đáp số:</b> a) mỗi cung $60^\circ$. b) $\dfrac{\pi}{2}-\dfrac{3\sqrt{3}}{4}\approx0{,}27$ cm².</p>', 3, 0, 1, @t1);

-- Bài 16
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 16. Vị trí tương đối của đường thẳng và đường tròn', N'Ba vị trí tương đối của đường thẳng và đường tròn, dấu hiệu nhận biết tiếp tuyến và tính chất của hai tiếp tuyến cắt nhau.', N'<p><b>1. Vị trí tương đối của đường thẳng và đường tròn.</b></p>
<ul>
<li>Đường thẳng $a$ và đường tròn $(O)$ <b>cắt nhau</b> nếu chúng có đúng hai điểm chung.</li>
<li>Đường thẳng $a$ và đường tròn $(O)$ <b>tiếp xúc nhau</b> nếu chúng có duy nhất một điểm chung $H$. Điểm $H$ gọi là <b>tiếp điểm</b>, đường thẳng $a$ gọi là <b>tiếp tuyến</b> của $(O)$ tại $H$.</li>
<li>Đường thẳng $a$ và đường tròn $(O)$ <b>không giao nhau</b> nếu chúng không có điểm chung.</li>
</ul>
<p><b>Nhận xét.</b> Gọi $d$ là khoảng cách từ $O$ đến đường thẳng $a$. Đường thẳng $a$ và đường tròn $(O;R)$ cắt nhau khi $d\lt R$, tiếp xúc nhau khi $d=R$ và không giao nhau khi $d\gt R$. Nếu $a$ tiếp xúc với $(O)$ tại $H$ thì $OH\perp a$.</p>
<p><b>2. Dấu hiệu nhận biết tiếp tuyến.</b> <i>Định lí 1.</i> Nếu một đường thẳng đi qua một điểm nằm trên một đường tròn và vuông góc với bán kính đi qua điểm đó thì đường thẳng ấy là một tiếp tuyến của đường tròn.</p>
<p><b>Ví dụ 1.</b> $AB$ là một dây không đi qua tâm của $(O)$. Đường thẳng qua $O$ và vuông góc với $AB$ cắt tiếp tuyến tại $A$ của $(O)$ ở $C$. Chứng minh $CB$ là tiếp tuyến của $(O)$. Gọi $D$ là giao điểm của $AB$ và $OC$. Trong tam giác cân $AOB$, đường cao $OD$ cũng là phân giác của góc $O$ nên $\widehat{O_1}=\widehat{O_2}$. Do đó $\triangle AOC=\triangle BOC$ (c.g.c), suy ra $\widehat{OBC}=\widehat{OAC}=90^\circ$, tức $CB\perp OB$ tại $B$. Theo Định lí 1, $CB$ là tiếp tuyến của $(O)$.</p>
<p><b>3. Hai tiếp tuyến cắt nhau.</b> <i>Định lí 2.</i> Nếu hai tiếp tuyến của đường tròn $(O)$ cắt nhau tại điểm $M$ thì:</p>
<ul>
<li>$M$ cách đều hai tiếp điểm;</li>
<li>$MO$ là tia phân giác của góc tạo bởi hai tiếp tuyến;</li>
<li>$OM$ là tia phân giác của góc tạo bởi hai bán kính đi qua hai tiếp điểm.</li>
</ul>
<p><b>Ví dụ 2.</b> Cho hai tiếp tuyến $MA$, $MB$ của $(O;R)$ ($A$, $B$ là hai tiếp điểm). a) Chứng minh $OM\perp AB$: vì $OM$ là phân giác của góc $AOB$ trong tam giác cân $AOB$ nên cũng là đường cao. b) Tính $MA$, $MB$ biết $R=2$ cm, $MO=4$ cm: tam giác $OAM$ vuông tại $A$ nên $AM^2=OM^2-OA^2=16-4=12$, $AM=2\sqrt{3}$ cm và $BM=AM=2\sqrt{3}$ cm.</p>', 5, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.20.</b> Bạn Thanh cắt 4 hình tròn bằng giấy có bán kính lần lượt là 4 cm, 6 cm, 7 cm và 8 cm để dán trang trí trên một mảnh giấy, trên đó có vẽ trước hai đường thẳng $a$ và $b$. Biết rằng $a$ và $b$ là hai đường thẳng song song với nhau và cách nhau một khoảng 6 cm (nghĩa là mọi điểm trên đường thẳng $b$ đều cách $a$ một khoảng 6 cm). Hỏi nếu bạn Thanh dán sao cho tâm của cả 4 hình tròn đều nằm trên đường thẳng $b$ thì hình tròn nào sẽ che khuất một phần của đường thẳng $a$, hình tròn nào sẽ không che khuất một phần của đường thẳng $a$?</p>', N'<p>Tâm mỗi hình tròn nằm trên $b$ nên khoảng cách từ tâm đến $a$ bằng $d=6$ cm. Hình tròn che khuất một phần của $a$ khi đường tròn biên cắt $a$, tức là $R\gt d=6$ cm.</p>
<ul>
<li>$R=4$ cm: $d\gt R$, không giao nhau — không che khuất $a$.</li>
<li>$R=6$ cm: $d=R$, tiếp xúc — chỉ chạm $a$ tại một điểm, không che khuất một phần (đoạn) của $a$.</li>
<li>$R=7$ cm và $R=8$ cm: $d\lt R$, cắt nhau — che khuất một phần của $a$.</li>
</ul>
<p><b>Đáp số:</b> hình tròn bán kính 7 cm và 8 cm che khuất một phần của $a$; hình tròn bán kính 4 cm và 6 cm thì không.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.21.</b> Cho đường tròn $(O)$ đi qua ba đỉnh $A,\ B$ và $C$ của một tam giác cân tại $A$. Chứng minh rằng đường thẳng đi qua $A$ và song song với $BC$ là một tiếp tuyến của $(O)$.</p>', N'<p>Gọi $d$ là đường thẳng qua $A$ song song với $BC$.</p>
<p>Vì $AB=AC$ nên $A$ nằm trên đường trung trực của $BC$; vì $OB=OC$ nên $O$ cũng nằm trên đường trung trực của $BC$. Do đó đường thẳng $OA$ là đường trung trực của $BC$, suy ra $OA\perp BC$.</p>
<p>Vì $d\parallel BC$ nên $OA\perp d$ tại $A$. Mà $A\in(O)$ nên $d$ đi qua một điểm của đường tròn và vuông góc với bán kính $OA$ tại điểm đó. Theo dấu hiệu nhận biết tiếp tuyến, $d$ là một tiếp tuyến của $(O)$ tại $A$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.22.</b> Cho góc $xOy$ với tia phân giác $Ot$ và điểm $A$ trên cạnh $Ox$, điểm $B$ trên cạnh $Oy$ sao cho $OA=OB$. Đường thẳng qua $A$ và vuông góc với $Ox$ cắt $Ot$ tại $M$. Chứng minh rằng $OA$ và $OB$ là hai tiếp tuyến cắt nhau của đường tròn $(M;MA)$.</p>', N'<p>Hai tam giác $OAM$ và $OBM$ có $OA=OB$, $\widehat{AOM}=\widehat{BOM}$ (vì $Ot$ là phân giác) và $OM$ chung nên $\triangle OAM=\triangle OBM$ (c.g.c). Suy ra $MB=MA$ và $\widehat{OBM}=\widehat{OAM}=90^\circ$.</p>
<p>Vì $MB=MA$ nên $B\in(M;MA)$. Ta có $OA\perp MA$ tại $A$ và $OB\perp MB$ tại $B$, với $A,B\in(M;MA)$, nên theo dấu hiệu nhận biết tiếp tuyến, $OA$ và $OB$ là hai tiếp tuyến của $(M;MA)$. Hai tiếp tuyến này cắt nhau tại $O$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.23.</b> Cho $SA$ và $SB$ là hai tiếp tuyến cắt nhau của đường tròn $(O)$ ($A$ và $B$ là hai tiếp điểm). Gọi $M$ là một điểm tùy ý trên cung nhỏ $AB$. Tiếp tuyến của $(O)$ tại $M$ cắt $SA$ tại $E$ và cắt $SB$ tại $F$.</p>
<ol type="a">
<li>Chứng minh rằng chu vi của tam giác $SEF$ bằng $SA+SB$.</li>
<li>Giả sử $M$ là giao điểm của đoạn $SO$ với đường tròn $(O)$. Chứng minh rằng $SE=SF$.</li>
</ol>', N'<p><b>a)</b> $EA$ và $EM$ là hai tiếp tuyến cắt nhau tại $E$ của $(O)$ nên $EA=EM$. Tương tự $FB=FM$. Vì $M$ nằm giữa $E$ và $F$ nên $EF=EM+MF=EA+FB$.</p>
<p>Chu vi tam giác $SEF$: $SE+EF+SF=SE+EA+FB+SF=(SE+EA)+(SF+FB)=SA+SB$.</p>
<p><b>b)</b> Khi $M\in SO$, tiếp tuyến $EF$ tại $M$ vuông góc với bán kính $OM$, tức $EF\perp SO$. Theo tính chất hai tiếp tuyến cắt nhau, $SO$ là tia phân giác của góc $ASB$, tức của góc $ESF$. Tam giác $SEF$ có đường cao $SM$ đồng thời là đường phân giác nên là tam giác cân tại $S$. Vậy $SE=SF$.</p>', 3, 0, 1, @t1);

-- Bài 17
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 17. Vị trí tương đối của hai đường tròn', N'Hai đường tròn cắt nhau, tiếp xúc nhau và không giao nhau; hệ thức giữa đoạn nối tâm và các bán kính.', N'<p><b>1. Hai đường tròn cắt nhau.</b> Nếu hai đường tròn có đúng hai điểm chung thì ta nói đó là hai đường tròn <b>cắt nhau</b>, hai điểm chung gọi là hai giao điểm. Hai đường tròn $(O;R)$ và $(O'';R'')$ ($R\gt R''$) cắt nhau khi $$R-R''\lt OO''\lt R+R''.$$</p>
<p><b>Ví dụ 1.</b> $OO''=5$ cm thì $(O;4\text{ cm})$ và $(O'';3\text{ cm})$ cắt nhau vì $R-R''=1\lt5\lt7=R+R''$.</p>
<p><b>2. Hai đường tròn tiếp xúc nhau.</b> Nếu hai đường tròn có duy nhất một điểm chung thì đó là hai đường tròn <b>tiếp xúc nhau</b>, điểm chung gọi là <b>tiếp điểm</b>. Có hai trường hợp: <i>tiếp xúc ngoài</i> khi $OO''=R+R''$; <i>tiếp xúc trong</i> khi $OO''=R-R''\gt0$ ($R\gt R''$). Nếu hai đường tròn tiếp xúc nhau thì tiếp điểm thẳng hàng với hai tâm.</p>
<p><b>Ví dụ 2.</b> $OO''=5$ cm, $(O;3\text{ cm})$ và $(O'';2\text{ cm})$: $5=3+2=R+R''$ nên hai đường tròn tiếp xúc ngoài.</p>
<p><b>3. Hai đường tròn không giao nhau.</b> Nếu hai đường tròn không có điểm chung thì đó là hai đường tròn <b>không giao nhau</b>:</p>
<ul>
<li>Hai đường tròn <i>ngoài nhau</i> khi $OO''\gt R+R''$.</li>
<li>Đường tròn $(O;R)$ <i>đựng</i> đường tròn $(O'';R'')$ khi $R\gt R''$ và $OO''\lt R-R''$. Đặc biệt khi $O$ trùng $O''$ và $R\neq R''$ ta có hai đường tròn đồng tâm.</li>
</ul>
<p><b>Bảng tổng kết</b> (với $R\ge R''$):</p>
<table border="1"><tr><th>Vị trí tương đối</th><th>Số điểm chung</th><th>Hệ thức giữa $OO''$ với $R$ và $R''$</th></tr>
<tr><td>Hai đường tròn cắt nhau</td><td>2</td><td>$R-R''\lt OO''\lt R+R''$</td></tr>
<tr><td>Tiếp xúc ngoài</td><td>1</td><td>$OO''=R+R''$</td></tr>
<tr><td>Tiếp xúc trong</td><td>1</td><td>$OO''=R-R''\gt0$</td></tr>
<tr><td>Ngoài nhau</td><td>0</td><td>$OO''\gt R+R''$</td></tr>
<tr><td>Đựng nhau</td><td>0</td><td>$OO''\lt R-R''$</td></tr></table>', 6, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.24.</b> Hình 5.37 cho thấy hình ảnh của những đường tròn (là viền ngoài của các sản phẩm) qua cách trình bày một số sản phẩm mây tre đan. Bằng cách đánh số các đường tròn, em hãy chỉ ra một vài cặp đường tròn cắt nhau và vài cặp đường tròn không giao nhau.</p>
<div><img src="/static/img/sgk9/sgk9-c5-hinh-5-37.png" alt="Hình 5.37: các sản phẩm mây tre đan hình tròn"></div>', N'<p>Đề dựa vào hình ảnh nên đáp án phụ thuộc cách đánh số. Cách làm: đánh số các đường tròn (ví dụ từ 1 đến 7), rồi với mỗi cặp quan sát số giao điểm của hai đường biên.</p>
<ul>
<li>Hai đường tròn <b>cắt nhau</b> khi hai viền ngoài chồng lên nhau, có đúng hai điểm chung (ví dụ chiếc đĩa tre nhỏ nằm đè lên mép chiếc mẹt lớn bên cạnh).</li>
<li>Hai đường tròn <b>không giao nhau</b> khi hai viền không có điểm chung: hoặc hai sản phẩm đặt rời nhau (ngoài nhau), hoặc một sản phẩm nằm gọn trong một sản phẩm khác (đường tròn này đựng đường tròn kia).</li>
</ul>
<p>Học sinh chỉ ra ít nhất một cặp cắt nhau và một cặp không giao nhau theo cách đánh số của mình.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.25.</b> Cho hai điểm $O$ và $O''$ cách nhau một khoảng 5 cm. Mỗi đường tròn sau đây có vị trí tương đối như thế nào đối với đường tròn $(O;3\text{ cm})$?</p>
<ol type="a">
<li>Đường tròn $(O'';3\text{ cm})$;</li>
<li>Đường tròn $(O'';1\text{ cm})$;</li>
<li>Đường tròn $(O'';8\text{ cm})$.</li>
</ol>', N'<p>Ta có $OO''=5$ cm và $R=3$ cm.</p>
<p><b>a)</b> $R''=3$: $R-R''=0\lt5\lt6=R+R''$ nên hai đường tròn <b>cắt nhau</b>.</p>
<p><b>b)</b> $R''=1$: $R+R''=4\lt5=OO''$ nên hai đường tròn <b>ngoài nhau</b>.</p>
<p><b>c)</b> $R''=8$: $R''-R=5=OO''$ nên hai đường tròn <b>tiếp xúc trong</b> ($(O;3)$ nằm trong $(O'';8)$, tiếp xúc tại một điểm).</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.26.</b> Cho ba điểm thẳng hàng $O,\ A$ và $O''$. Với mỗi trường hợp sau, hãy viết hệ thức giữa các độ dài $OO''$, $OA$ và $O''A$ rồi xét xem hai đường tròn $(O;OA)$ và $(O'';O''A)$ tiếp xúc trong hay tiếp xúc ngoài với nhau; vẽ hình để khẳng định dự đoán của mình.</p>
<ol type="a">
<li>Điểm $A$ nằm giữa hai điểm $O$ và $O''$;</li>
<li>Điểm $O$ nằm giữa hai điểm $A$ và $O''$;</li>
<li>Điểm $O''$ nằm giữa hai điểm $A$ và $O$.</li>
</ol>', N'<p>Hai đường tròn có chung điểm $A$ và $A$ thẳng hàng với hai tâm.</p>
<p><b>a)</b> $A$ nằm giữa $O$ và $O''$: $OO''=OA+O''A$, tức $OO''=R+R''$. Hai đường tròn <b>tiếp xúc ngoài</b> tại $A$.</p>
<p><b>b)</b> $O$ nằm giữa $A$ và $O''$: $O''A=O''O+OA$, suy ra $OO''=O''A-OA=R''-R$ (và $\gt0$). Hai đường tròn <b>tiếp xúc trong</b> tại $A$ ($(O;OA)$ nằm trong $(O'';O''A)$).</p>
<p><b>c)</b> $O''$ nằm giữa $A$ và $O$: $OA=OO''+O''A$, suy ra $OO''=OA-O''A=R-R''$ (và $\gt0$). Hai đường tròn <b>tiếp xúc trong</b> tại $A$ ($(O'';O''A)$ nằm trong $(O;OA)$).</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.27.</b> Cho hai đường tròn $(O)$ và $(O'')$ tiếp xúc ngoài với nhau tại $A$. Một đường thẳng qua $A$ cắt $(O)$ tại $B$ và cắt $(O'')$ tại $C$. Chứng minh rằng $OB\parallel O''C$.</p>', N'<p>Vì hai đường tròn tiếp xúc ngoài tại $A$ nên $A$ nằm giữa $O$ và $O''$ và hai đường tròn nằm về hai phía của tiếp tuyến chung tại $A$. Do đó $B$ và $C$ nằm về hai phía của $A$ trên đường thẳng $BC$ (tức $A$ nằm giữa $B$ và $C$).</p>
<p>Tam giác $OAB$ cân tại $O$ ($OA=OB$) nên $\widehat{OBA}=\widehat{OAB}$. Tam giác $O''AC$ cân tại $O''$ nên $\widehat{O''CA}=\widehat{O''AC}$. Hai góc $\widehat{OAB}$ và $\widehat{O''AC}$ đối đỉnh nên bằng nhau.</p>
<p>Suy ra $\widehat{OBC}=\widehat{OBA}=\widehat{OAB}=\widehat{O''AC}=\widehat{O''CA}=\widehat{O''CB}$. Hai góc $\widehat{OBC}$ và $\widehat{O''CB}$ ở vị trí so le trong (với cát tuyến $BC$) và bằng nhau, nên $OB\parallel O''C$.</p>', 3, 0, 1, @t1);

-- Luyện tập chung (Bài 16 - Bài 17)
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Luyện tập chung (Bài 16 - Bài 17)', N'Rèn luyện chứng minh tiếp tuyến, đường tròn tiếp xúc nhau và hai tiếp tuyến chung.', N'<p><b>Ví dụ 1.</b> Cho hai đường tròn $(O;R)$ và $(O'';R'')$ cắt nhau tại $A$ và $B$. Gọi $M$ là điểm đối xứng với $A$ qua $O$, $N$ là điểm đối xứng với $A$ qua $O''$. Chứng minh: a) $M\in(O)$, $N\in(O'')$ và ba điểm $M,B,N$ thẳng hàng; b) đường thẳng $MN$ tiếp xúc với đường tròn đường kính $AB$.</p>
<p><i>Giải.</i> a) Do tính đối xứng của $(O)$, từ $A\in(O)$ suy ra $M\in(O)$. Tam giác $ABM$ có trung tuyến $BO=\dfrac{1}{2}AM$ nên vuông tại $B$: $\widehat{ABM}=90^\circ$. Tương tự $N\in(O'')$ và $\widehat{ABN}=90^\circ$. Suy ra $\widehat{MBN}=\widehat{ABM}+\widehat{ABN}=180^\circ$, tức $M,B,N$ thẳng hàng.</p>
<p>b) Từ câu a có $MN\perp AB$ tại $B$, tức $MN$ vuông góc với bán kính (của đường tròn đường kính $AB$) tại $B$, nên $MN$ là tiếp tuyến của đường tròn đường kính $AB$.</p>
<p><b>Ví dụ 2.</b> Cho hai đường tròn ngoài nhau $(O;R)$ và $(O'';R'')$ với $R\gt R''$. Đường thẳng $d$ tiếp xúc với $(O)$ tại $A$, tiếp xúc với $(O'')$ tại $B$ sao cho $O$ và $O''$ cùng phía đối với $d$, $d$ cắt $OO''$ tại $P$. a) Chứng minh $\dfrac{PO}{PO''}=\dfrac{R}{R''}$: vì $OA\perp d$ và $O''B\perp d$ nên $O''B\parallel OA$, suy ra $\triangle POA\backsim\triangle PO''B$ và $\dfrac{PO}{PO''}=\dfrac{OA}{O''B}=\dfrac{R}{R''}$. b) Gọi $A''$ đối xứng với $A$ qua $OO''$. Khi đó đường thẳng $PA''$ tiếp xúc với cả $(O)$ và $(O'')$ (đối xứng của tiếp tuyến $d$ qua đường nối tâm).</p>', 7, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.28.</b> Cho hai đường thẳng $a$ và $b$ song song với nhau, điểm $O$ nằm trong phần mặt phẳng ở giữa hai đường thẳng đó. Biết rằng khoảng cách từ $O$ đến $a$ và $b$ lần lượt bằng 2 cm và 3 cm.</p>
<ol type="a">
<li>Hỏi bán kính $R$ của đường tròn $(O;R)$ phải thỏa mãn điều kiện gì để $(O;R)$ cắt cả hai đường thẳng $a$ và $b$?</li>
<li>Biết rằng đường tròn $(O;R)$ tiếp xúc với đường thẳng $a$. Hãy xác định vị trí tương đối của đường tròn $(O;R)$ và đường thẳng $b$.</li>
</ol>', N'<p><b>a)</b> $(O;R)$ cắt $a$ khi $R\gt2$ và cắt $b$ khi $R\gt3$. Để cắt cả hai đường thẳng thì $R\gt3$ cm.</p>
<p><b>b)</b> $(O;R)$ tiếp xúc với $a$ khi $R=2$ cm. Khoảng cách từ $O$ đến $b$ là $3\gt R=2$ nên đường tròn $(O;R)$ và đường thẳng $b$ <b>không giao nhau</b>.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.29.</b> Khi chuyển động, giả sử đầu mũi kim dài của một chiếc đồng hồ vạch nên một đường tròn, kí hiệu là $(T_1)$, trong khi đầu mũi kim ngắn vạch nên một đường tròn khác, kí hiệu là $(T_2)$.</p>
<ol type="a">
<li>Hai đường tròn $(T_1)$ và $(T_2)$ có vị trí tương đối như thế nào?</li>
<li>Giả sử bán kính của $(T_1)$ và $(T_2)$ lần lượt là $R_1$ và $R_2$. Người ta vẽ trên mặt đồng hồ một họa tiết hình tròn $(T_3)$ có tâm nằm cách điểm trục kim đồng hồ một khoảng bằng $\dfrac{1}{2}R_1$ và có bán kính bằng $\dfrac{1}{2}R_2$. Hãy cho biết vị trí tương đối của đường tròn $(T_3)$ đối với mỗi đường tròn $(T_1)$ và $(T_2)$. Vẽ ba đường tròn đó nếu $R_1=3$ cm và $R_2=2$ cm.</li>
</ol>', N'<p>Gọi $O$ là điểm trục kim; $(T_1)=(O;R_1)$, $(T_2)=(O;R_2)$ với $R_1\gt R_2$ (kim dài hơn kim ngắn).</p>
<p><b>a)</b> $(T_1)$ và $(T_2)$ có cùng tâm $O$ và $R_1\neq R_2$ nên là hai đường tròn <b>đồng tâm</b>, không giao nhau; $(T_1)$ đựng $(T_2)$.</p>
<p><b>b)</b> $(T_3)=(O_3;\tfrac{R_2}{2})$ với $OO_3=\dfrac{R_1}{2}$.</p>
<ul>
<li>Với $(T_1)$: $R_1-\dfrac{R_2}{2}\gt\dfrac{R_1}{2}$ (vì $R_1\gt R_2$) nên $OO_3\lt R_1-\dfrac{R_2}{2}$: $(T_1)$ đựng $(T_3)$ (không giao nhau).</li>
<li>Với $(T_2)$: $R_2-\dfrac{R_2}{2}=\dfrac{R_2}{2}\lt\dfrac{R_1}{2}=OO_3$ nên $(T_2)$ không đựng $(T_3)$, và $(T_3)$ không đựng $(T_2)$. So sánh $OO_3=\dfrac{R_1}{2}$ với $R_2+\dfrac{R_2}{2}=\dfrac{3R_2}{2}$: nếu $R_1\lt3R_2$ thì hai đường tròn cắt nhau; nếu $R_1=3R_2$ tiếp xúc ngoài; nếu $R_1\gt3R_2$ ngoài nhau.</li>
</ul>
<p>Với $R_1=3$ cm, $R_2=2$ cm: $(T_3)$ có tâm cách $O$ một khoảng 1,5 cm, bán kính 1 cm. Với $(T_1)$: $1{,}5\lt3-1=2$ nên $(T_1)$ đựng $(T_3)$. Với $(T_2)$: $R_2-r=1\lt1{,}5\lt3=R_2+r$ nên $(T_3)$ <b>cắt</b> $(T_2)$.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.30.</b> Cho đường tròn $(O)$ đường kính $AB$, tiếp tuyến $xx''$ tại $A$ và tiếp tuyến $yy''$ tại $B$ của $(O)$. Một tiếp tuyến thứ ba của $(O)$ tại điểm $P$ ($P$ khác $A$ và $B$) cắt $xx''$ tại $M$ và cắt $yy''$ tại $N$.</p>
<ol type="a">
<li>Chứng minh rằng $MN=MA+NB$.</li>
<li>Đường thẳng đi qua $O$ và vuông góc với $AB$ cắt $NM$ tại $Q$. Chứng minh rằng $Q$ là trung điểm của đoạn $MN$.</li>
<li>Chứng minh rằng $AB$ tiếp xúc với đường tròn đường kính $MN$.</li>
</ol>', N'<p><b>a)</b> $MA$ và $MP$ là hai tiếp tuyến cắt nhau tại $M$ nên $MA=MP$; $NB$ và $NP$ là hai tiếp tuyến cắt nhau tại $N$ nên $NB=NP$. Vì $P$ nằm giữa $M$ và $N$ nên $MN=MP+PN=MA+NB$.</p>
<p><b>b)</b> $xx''\perp AB$, $yy''\perp AB$ nên $AM\parallel BN$; tứ giác $AMNB$ là hình thang (đáy $AM$, $BN$). Đường thẳng qua $O$ vuông góc với $AB$ song song với hai đáy và đi qua trung điểm $O$ của cạnh bên $AB$ nên cắt cạnh bên $MN$ tại trung điểm. Vậy $Q$ là trung điểm của $MN$ và $OQ=\dfrac{AM+BN}{2}$ (đường trung bình hình thang).</p>
<p><b>c)</b> Đường tròn đường kính $MN$ có tâm $Q$, bán kính $\dfrac{MN}{2}$. Theo câu a và b: $QO=\dfrac{AM+BN}{2}=\dfrac{MN}{2}$, nên $O$ thuộc đường tròn $(Q;\tfrac{MN}{2})$. Vì $QO\perp AB$ tại $O$ nên $AB$ vuông góc với bán kính $QO$ tại điểm $O$ của đường tròn, do đó $AB$ là tiếp tuyến của đường tròn đường kính $MN$ (tiếp xúc tại $O$).</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.31.</b> Cho hai đường tròn $(O)$ và $(O'')$ tiếp xúc ngoài với nhau tại $A$ và cùng tiếp xúc với đường thẳng $d$ tại $B$ và $C$ (khác $A$), trong đó $B\in(O)$, $C\in(O'')$. Tiếp tuyến của $(O)$ tại $A$ cắt $BC$ tại $M$. Chứng minh rằng:</p>
<ol type="a">
<li>Đường thẳng $MA$ tiếp xúc với $(O'')$;</li>
<li>Điểm $M$ là trung điểm của đoạn thẳng $BC$, từ đó suy ra $ABC$ là tam giác vuông.</li>
</ol>', N'<p><b>a)</b> $MA$ là tiếp tuyến của $(O)$ tại $A$ nên $MA\perp OA$. Vì hai đường tròn tiếp xúc ngoài tại $A$ nên $O,\ A,\ O''$ thẳng hàng. Do đó $MA\perp O''A$ tại $A$, mà $A\in(O'')$, nên $MA$ là tiếp tuyến của $(O'')$ tại $A$.</p>
<p><b>b)</b> $MA$ và $MB$ là hai tiếp tuyến cắt nhau tại $M$ của $(O)$ nên $MA=MB$. $MA$ và $MC$ là hai tiếp tuyến cắt nhau tại $M$ của $(O'')$ nên $MA=MC$. Suy ra $MB=MC$, mà $M$ nằm trên $BC$ nên $M$ là trung điểm của $BC$.</p>
<p>Tam giác $ABC$ có trung tuyến $AM=MB=MC=\dfrac{BC}{2}$ nên vuông tại $A$.</p>', 3, 0, 1, @t1);

-- Bài tập cuối chương V
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài tập cuối chương V', N'Ôn tập chương V: đường tròn, cung và dây, độ dài cung, diện tích hình quạt, vị trí tương đối của đường thẳng, đường tròn.', N'<p><b>Tóm tắt kiến thức chương V.</b></p>
<ul>
<li>Điểm $M$ so với $(O;R)$: trên, trong, ngoài khi $OM=R$, $OM\lt R$, $OM\gt R$. Đường tròn có một tâm đối xứng (tâm $O$) và vô số trục đối xứng (mọi đường thẳng qua $O$).</li>
<li>Đường kính là dây lớn nhất. Số đo cung nhỏ bằng số đo góc ở tâm chắn cung đó; số đo cung lớn bằng $360^\circ$ trừ số đo cung nhỏ cùng hai mút.</li>
<li>Độ dài cung $n^\circ$: $l=\dfrac{n}{180}\pi R$. Diện tích hình quạt: $S_q=\dfrac{n}{360}\pi R^2=\dfrac{lR}{2}$. Diện tích hình vành khuyên: $S_v=\pi(R^2-r^2)$.</li>
<li>Đường thẳng và đường tròn $(O;R)$, $d=d(O,a)$: cắt nhau khi $d\lt R$; tiếp xúc khi $d=R$; không giao nhau khi $d\gt R$. Tiếp tuyến vuông góc với bán kính tại tiếp điểm; hai tiếp tuyến cắt nhau tại $M$ thì $M$ cách đều hai tiếp điểm.</li>
<li>Hai đường tròn $(O;R)$, $(O'';R'')$, $R\ge R''$: cắt nhau khi $R-R''\lt OO''\lt R+R''$; tiếp xúc ngoài khi $OO''=R+R''$; tiếp xúc trong khi $OO''=R-R''\gt0$; ngoài nhau khi $OO''\gt R+R''$; đựng nhau khi $OO''\lt R-R''$.</li>
</ul>
<p><b>Em có biết: vẽ chắp nối trơn.</b> Đoạn thẳng được chắp nối trơn với một cung tròn thì đoạn thẳng nằm trên tiếp tuyến của đường tròn chứa cung tại điểm chắp nối; hai cung tròn chắp nối trơn với nhau thì hai đường tròn chứa chúng tiếp xúc nhau tại điểm chắp nối (hai tâm và điểm chắp nối thẳng hàng).</p>', 8, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 5.32.</b> Cho đường tròn $(O;4\text{ cm})$ và hai điểm $A,\ B$. Biết rằng $OA=\sqrt{15}$ cm và $OB=4$ cm. Khi đó:</p>', N'<p>$OA=\sqrt{15}\approx3{,}87\lt4=R$ nên $A$ nằm trong $(O)$. $OB=4=R$ nên $B$ nằm trên $(O)$. Vậy phương án D đúng.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'Điểm $A$ nằm trong $(O)$, điểm $B$ nằm ngoài $(O)$.', 0),
(@q, 'B', N'Điểm $A$ nằm ngoài $(O)$, điểm $B$ nằm trên $(O)$.', 0),
(@q, 'C', N'Điểm $A$ nằm trên $(O)$, điểm $B$ nằm trong $(O)$.', 0),
(@q, 'D', N'Điểm $A$ nằm trong $(O)$, điểm $B$ nằm trên $(O)$.', 1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 5.33.</b> Cho Hình 5.43, trong đó $BD$ là đường kính; $\widehat{AOB}=40^\circ$; $\widehat{BOC}=100^\circ$. Khi đó:</p>
<div><img src="/static/img/sgk9/sgk9-c5-hinh-5-43.png" alt="Hình 5.43: đường tròn tâm O, đường kính BD, các điểm A, C"></div>', N'<p>$BD$ là đường kính nên $\widehat{BOD}=180^\circ$. Do đó $\widehat{DOC}=180^\circ-\widehat{BOC}=80^\circ$ và $\widehat{AOD}=180^\circ-\widehat{AOB}=140^\circ$. Các góc này đều không lớn hơn $180^\circ$ nên $\mathrm{sđ}\,\overset{\frown}{DC}=80^\circ$ và $\mathrm{sđ}\,\overset{\frown}{AD}=140^\circ$. Phương án D đúng.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$\mathrm{sđ}\,\overset{\frown}{DC}=80^\circ$ và $\mathrm{sđ}\,\overset{\frown}{AD}=220^\circ$.', 0),
(@q, 'B', N'$\mathrm{sđ}\,\overset{\frown}{DC}=280^\circ$ và $\mathrm{sđ}\,\overset{\frown}{AD}=220^\circ$.', 0),
(@q, 'C', N'$\mathrm{sđ}\,\overset{\frown}{DC}=280^\circ$ và $\mathrm{sđ}\,\overset{\frown}{AD}=140^\circ$.', 0),
(@q, 'D', N'$\mathrm{sđ}\,\overset{\frown}{DC}=80^\circ$ và $\mathrm{sđ}\,\overset{\frown}{AD}=140^\circ$.', 1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 5.34.</b> Cho hai đường tròn $(A;R_1)$, $(B;R_2)$, trong đó $R_2\lt R_1$. Biết rằng hai đường tròn $(A)$ và $(B)$ cắt nhau (Hình 5.44). Khi đó:</p>', N'<p>Hai đường tròn cắt nhau khi $R_1-R_2\lt AB\lt R_1+R_2$. Phương án B đúng.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$AB\lt R_1-R_2$.', 0),
(@q, 'B', N'$R_1-R_2\lt AB\lt R_1+R_2$.', 1),
(@q, 'C', N'$AB\gt R_1+R_2$.', 0),
(@q, 'D', N'$AB=R_1+R_2$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 5.35.</b> Cho đường tròn $(O;R)$ và hai đường thẳng $a_1$ và $a_2$. Gọi $d_1$, $d_2$ lần lượt là khoảng cách từ điểm $O$ đến $a_1$ và $a_2$. Biết rằng $(O)$ cắt $a_1$ và tiếp xúc với $a_2$ (Hình 5.45). Khi đó:</p>', N'<p>Đường thẳng cắt đường tròn khi khoảng cách từ tâm đến đường thẳng nhỏ hơn bán kính: $d_1\lt R$. Đường thẳng tiếp xúc với đường tròn khi $d_2=R$. Phương án A đúng.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$d_1\lt R$ và $d_2=R$.', 1),
(@q, 'B', N'$d_1=R$ và $d_2\lt R$.', 0),
(@q, 'C', N'$d_1\gt R$ và $d_2=R$.', 0),
(@q, 'D', N'$d_1\lt R$ và $d_2\lt R$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.36.</b> Cho đường tròn $(O)$ đường kính $BC$ và điểm $A$ (khác $B$ và $C$).</p>
<ol type="a">
<li>Chứng minh rằng nếu $A$ nằm trên $(O)$ thì $ABC$ là một tam giác vuông; ngược lại, nếu $ABC$ là tam giác vuông tại $A$ thì $A$ nằm trên $(O)$.</li>
<li>Giả sử $A$ là một trong hai giao điểm của đường tròn $(B;BO)$ với đường tròn $(O)$. Tính các góc của tam giác $ABC$.</li>
<li>Với cùng giả thiết câu b, tính độ dài cung $AC$ và diện tích hình quạt nằm trong $(O)$ giới hạn bởi các bán kính $OA$ và $OC$, biết rằng $BC=6$ cm.</li>
</ol>', N'<p><b>a)</b> Nếu $A\in(O)$ thì $OA=OB=OC=\dfrac{BC}{2}$, tam giác $ABC$ có trung tuyến $AO$ bằng nửa cạnh $BC$ nên vuông tại $A$. Ngược lại, nếu $ABC$ vuông tại $A$ thì trung tuyến $AO$ ứng với cạnh huyền bằng $\dfrac{BC}{2}=R$, nên $A\in(O)$.</p>
<p><b>b)</b> $A\in(B;BO)$ nên $BA=BO$; $A\in(O)$ nên $OA=OB$. Vậy $BA=BO=OA$, tam giác $ABO$ đều, $\widehat{ABO}=60^\circ$. Vì $O$ nằm trên $BC$ nên $\widehat{ABC}=60^\circ$. Theo câu a, tam giác $ABC$ vuông tại $A$ nên $\widehat{BAC}=90^\circ$ và $\widehat{ACB}=90^\circ-60^\circ=30^\circ$.</p>
<p><b>c)</b> $BC=6$ cm nên $R=3$ cm. $\widehat{AOB}=60^\circ$ nên $\widehat{AOC}=180^\circ-60^\circ=120^\circ$, cung nhỏ $AC$ có số đo $120^\circ$. Độ dài cung $AC$: $l=\dfrac{120}{180}\pi\cdot3=2\pi\approx6{,}28$ (cm). Diện tích hình quạt: $S_q=\dfrac{120}{360}\pi\cdot3^2=3\pi\approx9{,}42$ (cm²).</p>
<p><b>Đáp số:</b> b) $\widehat{A}=90^\circ$, $\widehat{B}=60^\circ$, $\widehat{C}=30^\circ$. c) $l=2\pi$ cm; $S_q=3\pi$ cm².</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.37.</b> Cho $AB$ là một dây bất kì (không phải là đường kính) của đường tròn $(O;4\text{ cm})$. Gọi $C$ và $D$ lần lượt là các điểm đối xứng với $A$ và $B$ qua tâm $O$.</p>
<ol type="a">
<li>Hai điểm $C$ và $D$ có nằm trên đường tròn $(O)$ không? Vì sao?</li>
<li>Biết rằng $ABCD$ là một hình vuông. Tính độ dài cung lớn $AB$ và diện tích hình quạt tròn tạo bởi hai bán kính $OA$ và $OB$.</li>
</ol>', N'<p><b>a)</b> Đường tròn đối xứng qua tâm $O$. Vì $A,B\in(O)$ nên các điểm $C$, $D$ đối xứng với $A$, $B$ qua $O$ cũng thuộc $(O)$.</p>
<p><b>b)</b> $ABCD$ là hình vuông có tâm $O$ (giao hai đường chéo) nên hai đường chéo $AC$, $BD$ vuông góc: $\widehat{AOB}=90^\circ$. Cung nhỏ $AB$ có số đo $90^\circ$, cung lớn $AB$ có số đo $360^\circ-90^\circ=270^\circ$.</p>
<p>Độ dài cung lớn $AB$: $l=\dfrac{270}{180}\pi\cdot4=6\pi\approx18{,}85$ (cm).</p>
<p>Hình quạt tròn tạo bởi hai bán kính $OA$, $OB$ (ứng với cung nhỏ $AB$): $S_q=\dfrac{90}{360}\pi\cdot4^2=4\pi\approx12{,}57$ (cm²). (Hình quạt ứng với cung lớn có diện tích $12\pi\approx37{,}70$ cm².)</p>
<p><b>Đáp số:</b> a) có. b) $6\pi$ cm; $4\pi$ cm² (hình quạt ứng với cung nhỏ).</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.38.</b> Cho điểm $B$ nằm giữa hai điểm $A$ và $C$, sao cho $AB=2$ cm và $BC=1$ cm. Vẽ các đường tròn $(A;1{,}5\text{ cm})$, $(B;3\text{ cm})$ và $(C;2\text{ cm})$. Hãy xác định các cặp đường tròn:</p>
<ol type="a">
<li>Cắt nhau;</li>
<li>Không giao nhau;</li>
<li>Tiếp xúc với nhau.</li>
</ol>', N'<p>Ta có $AB=2$ cm, $BC=1$ cm, $AC=AB+BC=3$ cm.</p>
<ul>
<li>$(A;1{,}5)$ và $(B;3)$: $R-R''=3-1{,}5=1{,}5\lt AB=2\lt4{,}5=R+R''$ nên <b>cắt nhau</b>.</li>
<li>$(B;3)$ và $(C;2)$: $R-R''=3-2=1=BC$ nên <b>tiếp xúc trong</b>.</li>
<li>$(A;1{,}5)$ và $(C;2)$: $R-R''=2-1{,}5=0{,}5\lt AC=3\lt3{,}5=R+R''$ nên <b>cắt nhau</b>.</li>
</ul>
<p><b>Đáp số:</b> a) $(A;1{,}5)$ cắt $(B;3)$ và $(A;1{,}5)$ cắt $(C;2)$. b) không có cặp nào không giao nhau. c) $(B;3)$ và $(C;2)$ tiếp xúc trong.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.39.</b> Cho tam giác vuông $ABC$ ($\widehat{A}$ vuông). Vẽ hai đường tròn $(B;BA)$ và $(C;CA)$ cắt nhau tại $A$ và $A''$. Chứng minh rằng:</p>
<ol type="a">
<li>$BA$ và $BA''$ là hai tiếp tuyến cắt nhau của đường tròn $(C;CA)$;</li>
<li>$CA$ và $CA''$ là hai tiếp tuyến cắt nhau của đường tròn $(B;BA)$.</li>
</ol>', N'<p>Hai đường tròn có hai tâm $B$, $C$ nên $A$ và $A''$ đối xứng nhau qua $BC$. Do đó $BA''=BA$, $CA''=CA$, suy ra $\triangle BA''C=\triangle BAC$ (c.c.c) và $\widehat{BA''C}=\widehat{BAC}=90^\circ$.</p>
<p><b>a)</b> $BA\perp CA$ tại $A\in(C;CA)$ nên $BA$ là tiếp tuyến của $(C;CA)$ tại $A$. $BA''\perp CA''$ tại $A''\in(C;CA)$ nên $BA''$ là tiếp tuyến của $(C;CA)$ tại $A''$. Hai tiếp tuyến này cắt nhau tại $B$.</p>
<p><b>b)</b> $CA\perp BA$ tại $A\in(B;BA)$ nên $CA$ là tiếp tuyến của $(B;BA)$; $CA''\perp BA''$ tại $A''\in(B;BA)$ nên $CA''$ là tiếp tuyến của $(B;BA)$. Hai tiếp tuyến này cắt nhau tại $C$.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 5.40.</b> Cho hai đường tròn $(O)$ và $(O'')$ cắt nhau tại $A$ và $B$. Một đường thẳng $d$ đi qua $A$ cắt $(O)$ tại $E$ và cắt $(O'')$ tại $F$ ($E$ và $F$ khác $A$). Biết điểm $A$ nằm trong đoạn $EF$. Gọi $I$ và $K$ lần lượt là trung điểm của $AE$ và $AF$ (Hình 5.46).</p>
<div><img src="/static/img/sgk9/sgk9-c5-hinh-5-46.png" alt="Hình 5.46: hai đường tròn cắt nhau tại A, B; đường thẳng d qua A cắt (O) tại E, cắt (O'') tại F"></div>
<ol type="a">
<li>Chứng minh rằng tứ giác $OO''KI$ là một hình thang vuông.</li>
<li>Chứng minh rằng $IK=\dfrac{1}{2}EF$.</li>
<li>Khi $d$ ở vị trí nào (d vẫn qua $A$) thì $OO''KI$ là một hình chữ nhật?</li>
</ol>', N'<p><b>a)</b> $AE$ là dây của $(O)$ có trung điểm $I$ nên $OI\perp AE$, tức $OI\perp d$. Tương tự $AF$ là dây của $(O'')$ có trung điểm $K$ nên $O''K\perp d$. Do đó $OI\parallel O''K$ và hai góc $\widehat{OIK}=\widehat{O''KI}=90^\circ$. Vậy $OO''KI$ là hình thang vuông (vuông tại $I$ và $K$).</p>
<p><b>b)</b> $A$ nằm giữa $E$ và $F$, $I$ nằm giữa $E$ và $A$, $K$ nằm giữa $A$ và $F$ nên $IK=IA+AK=\dfrac{AE}{2}+\dfrac{AF}{2}=\dfrac{AE+AF}{2}=\dfrac{EF}{2}$.</p>
<p><b>c)</b> Hình thang vuông $OO''KI$ là hình chữ nhật khi và chỉ khi $OO''\parallel IK$, tức $OO''\parallel d$ (khi đó $OI=O''K$). Vậy $d$ là đường thẳng đi qua $A$ và song song với đường nối tâm $OO''$; khi đó $IK=OO''$ và $EF=2OO''$.</p>', 3, 0, 1, @t1);

-- ---------------------------------------------------------------------------------------------------------------------
-- Chương VI. Hàm số y = ax² (a ≠ 0). Phương trình bậc hai một ẩn
-- ---------------------------------------------------------------------------------------------------------------------
INSERT INTO Topics (TopicName, [Description], TeacherId, OrderIndex, IsActive) VALUES (N'Chương VI. Hàm số y = ax² (a ≠ 0). Phương trình bậc hai một ẩn', N'Hàm số y = ax² và đồ thị parabol, phương trình bậc hai một ẩn, công thức nghiệm, định lí Viète và giải bài toán bằng cách lập phương trình. (SGK Toán 9 Kết nối tri thức với cuộc sống, Tập 2)', @t1, 6, 1);
SET @tp = SCOPE_IDENTITY();

-- Bài 18
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 18. Hàm số y = ax² (a ≠ 0)', N'Nhận biết hàm số y = ax², vẽ đồ thị parabol và tính đối xứng của đồ thị.', N'<p><b>Bài toán mở đầu.</b> Cầu treo có hai trụ tháp cao 75 m so với mặt cầu, cách nhau 400 m; dây cáp có dạng đồ thị hàm số $y=ax^2$ với đỉnh $O$ ở chính giữa cầu. Điểm $A(-200;75)$ thuộc đồ thị nên $75=a\cdot200^2$, suy ra $a=\dfrac{3}{1600}$. Điểm $H$ cách $O$ là 100 m nên chiều cao $CH=\dfrac{3}{1600}\cdot100^2=18{,}75$ m.</p>
<p><b>1. Hàm số $y=ax^2$ ($a\neq0$).</b> Các công thức $s=4{,}9t^2$ (quãng đường vật rơi tự do), $S=\pi r^2$ (diện tích hình tròn) biểu thị những hàm số có cùng một dạng, gọi là hàm số $y=ax^2$ ($a\neq0$). Hàm số này xác định với mọi giá trị $x\in\mathbb{R}$.</p>
<p><b>Ví dụ 1.</b> Với $y=\dfrac{3}{2}x^2$ ta có bảng giá trị:</p>
<table border="1"><tr><th>$x$</th><td>$-3$</td><td>$-2$</td><td>$-1$</td><td>$0$</td><td>$1$</td><td>$2$</td><td>$3$</td></tr><tr><th>$y=\dfrac{3}{2}x^2$</th><td>$\dfrac{27}{2}$</td><td>$6$</td><td>$\dfrac{3}{2}$</td><td>$0$</td><td>$\dfrac{3}{2}$</td><td>$6$</td><td>$\dfrac{27}{2}$</td></tr></table>
<p><b>2. Đồ thị hàm số $y=ax^2$ ($a\neq0$).</b> Cách vẽ: lập bảng ghi một số cặp giá trị tương ứng của $x$ và $y$; biểu diễn các điểm $(x;y)$ trong bảng trên mặt phẳng tọa độ $Oxy$ rồi nối chúng lại để được một đường cong, đó là đồ thị của hàm số.</p>
<p><b>Ví dụ 2.</b> Vẽ đồ thị $y=-\dfrac{1}{4}x^2$: lập bảng với $x=-4;-2;-1;0;1;2;4$ thu được $y=-4;-1;-\dfrac{1}{4};0;-\dfrac{1}{4};-1;-4$; biểu diễn các điểm rồi nối lại được một đường cong nằm phía dưới trục hoành.</p>
<p><b>Tính chất của đồ thị.</b> Đồ thị hàm số $y=ax^2$ ($a\neq0$) là một đường cong gọi là <b>parabol</b>, có:</p>
<ul>
<li>Đỉnh là gốc tọa độ $O$;</li>
<li>Trục đối xứng là trục $Oy$ (hai điểm $(x;y)$ và $(-x;y)$ đối xứng nhau qua $Oy$);</li>
<li>Nằm phía trên trục hoành nếu $a\gt0$ và nằm phía dưới trục hoành nếu $a\lt0$.</li>
</ul>
<p><b>Ví dụ 3.</b> Vẽ đồ thị $y=-2x^2$ (bảng: $x=-2;-1;0;1;2$ cho $y=-8;-2;0;-2;-8$). Các điểm có tung độ $-\dfrac{1}{2}$: từ $-2x^2=-\dfrac{1}{2}$ suy ra $x^2=\dfrac{1}{4}$, $x=\pm\dfrac{1}{2}$; hai điểm $\left(\dfrac{1}{2};-\dfrac{1}{2}\right)$ và $\left(-\dfrac{1}{2};-\dfrac{1}{2}\right)$ đối xứng nhau qua trục $Oy$.</p>
<p><b>Nhận xét.</b> Khi vẽ đồ thị cần xác định tối thiểu 5 điểm: gốc tọa độ $O$ và hai cặp điểm đối xứng nhau qua $Oy$.</p>', 1, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.1.</b> Cho hàm số $y=0{,}25x^2$. Hoàn thành bảng giá trị sau:</p>
<table border="1"><tr><th>$x$</th><td>$-3$</td><td>$-2$</td><td>$-1$</td><td>$0$</td><td>$1$</td><td>$2$</td><td>$3$</td></tr><tr><th>$y$</th><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td></tr></table>', N'<p>Thay lần lượt các giá trị $x$ vào $y=0{,}25x^2$:</p>
<table border="1"><tr><th>$x$</th><td>$-3$</td><td>$-2$</td><td>$-1$</td><td>$0$</td><td>$1$</td><td>$2$</td><td>$3$</td></tr><tr><th>$y$</th><td>$2{,}25$</td><td>$1$</td><td>$0{,}25$</td><td>$0$</td><td>$0{,}25$</td><td>$1$</td><td>$2{,}25$</td></tr></table>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.2.</b> Cho hình lăng trụ đứng có đáy là hình vuông cạnh $a$ (cm) và chiều cao 10 cm.</p>
<ol type="a">
<li>Viết công thức tính thể tích $V$ của hình lăng trụ theo $a$ và tính giá trị của $V$ khi $a=2$ cm.</li>
<li>Nếu độ dài cạnh đáy tăng lên hai lần thì thể tích của hình lăng trụ thay đổi thế nào?</li>
</ol>', N'<p><b>a)</b> Diện tích đáy là $a^2$ nên $V=10a^2$ (cm³). Khi $a=2$: $V=10\cdot4=40$ (cm³).</p>
<p><b>b)</b> Khi cạnh đáy là $2a$: $V''=10(2a)^2=40a^2=4\cdot10a^2=4V$. Vậy thể tích tăng lên 4 lần.</p>
<p><b>Đáp số:</b> a) $V=10a^2$; $V=40$ cm³. b) tăng 4 lần.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.3.</b> Diện tích toàn phần $S$ (cm²) của hình lập phương, tức là tổng diện tích xung quanh và diện tích của hai mặt đáy, là một hàm số của độ dài cạnh $a$ (cm).</p>
<ol type="a">
<li>Viết công thức của hàm số này.</li>
<li>Sử dụng công thức nhận được ở câu a để tính độ dài cạnh của một hình lập phương có diện tích toàn phần là 54 cm².</li>
</ol>', N'<p><b>a)</b> Hình lập phương có 6 mặt là các hình vuông cạnh $a$ nên $S=6a^2$.</p>
<p><b>b)</b> $6a^2=54$ suy ra $a^2=9$, $a=3$ (vì $a\gt0$).</p>
<p><b>Đáp số:</b> a) $S=6a^2$. b) cạnh 3 cm.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.4.</b> Vẽ đồ thị của các hàm số sau:</p>
<ol type="a">
<li>$y=3x^2$;</li>
<li>$y=-\dfrac{1}{3}x^2$.</li>
</ol>', N'<p><b>a)</b> Bảng giá trị của $y=3x^2$:</p>
<table border="1"><tr><th>$x$</th><td>$-2$</td><td>$-1$</td><td>$0$</td><td>$1$</td><td>$2$</td></tr><tr><th>$y$</th><td>$12$</td><td>$3$</td><td>$0$</td><td>$3$</td><td>$12$</td></tr></table>
<p>Biểu diễn các điểm $(-2;12),(-1;3),(0;0),(1;3),(2;12)$ rồi nối lại: được parabol đỉnh $O$, mở lên trên, nhận $Oy$ làm trục đối xứng ($a=3\gt0$).</p>
<p><b>b)</b> Bảng giá trị của $y=-\dfrac{1}{3}x^2$:</p>
<table border="1"><tr><th>$x$</th><td>$-3$</td><td>$-1$</td><td>$0$</td><td>$1$</td><td>$3$</td></tr><tr><th>$y$</th><td>$-3$</td><td>$-\dfrac{1}{3}$</td><td>$0$</td><td>$-\dfrac{1}{3}$</td><td>$-3$</td></tr></table>
<p>Biểu diễn các điểm $(-3;-3),\left(-1;-\dfrac{1}{3}\right),(0;0),\left(1;-\dfrac{1}{3}\right),(3;-3)$ rồi nối lại: được parabol đỉnh $O$, mở xuống dưới ($a\lt0$), nhận $Oy$ làm trục đối xứng.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.5.</b> Biết rằng đường cong trong Hình 6.6 là một parabol $y=ax^2$ (đồ thị đi qua các điểm $(-2;2),\ (-1;0{,}5),\ (1;0{,}5),\ (2;2)$).</p>
<div><img src="/static/img/sgk9/sgk9-c6-hinh-6-6.png" alt="Hình 6.6 (SGK Toán 9)"></div>
<ol type="a">
<li>Tìm hệ số $a$.</li>
<li>Tìm tung độ của điểm thuộc parabol có hoành độ $x=-2$.</li>
<li>Tìm các điểm thuộc parabol có tung độ $y=8$.</li>
</ol>', N'<p><b>a)</b> Điểm $(1;0{,}5)$ thuộc parabol nên $0{,}5=a\cdot1^2$, suy ra $a=0{,}5$ (kiểm tra: điểm $(2;2)$ cho $0{,}5\cdot4=2$ đúng).</p>
<p><b>b)</b> Với $x=-2$: $y=0{,}5\cdot(-2)^2=2$.</p>
<p><b>c)</b> $0{,}5x^2=8$ suy ra $x^2=16$, $x=\pm4$. Các điểm là $(4;8)$ và $(-4;8)$.</p>
<p><b>Đáp số:</b> a) $a=\dfrac{1}{2}$. b) $2$. c) $(4;8)$, $(-4;8)$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.6.</b> Trong Hình 6.7 có hai đường cong là đồ thị của hai hàm số $y=-3x^2$ và $y=x^2$. Hãy cho biết đường nào là đồ thị của hàm số $y=-3x^2$. (Hình gồm một parabol màu cam nằm phía trên trục hoành và một parabol màu xanh lá nằm phía dưới trục hoành.)</p>
<div><img src="/static/img/sgk9/sgk9-c6-hinh-6-7.png" alt="Hình 6.7 (SGK Toán 9)"></div>', N'<p>Đồ thị $y=ax^2$ nằm phía trên trục hoành khi $a\gt0$ và nằm phía dưới trục hoành khi $a\lt0$.</p>
<p>Hàm số $y=-3x^2$ có $a=-3\lt0$ nên đồ thị nằm phía dưới trục hoành; hàm số $y=x^2$ có $a=1\gt0$ nên đồ thị nằm phía trên trục hoành.</p>
<p><b>Đáp số:</b> đồ thị của $y=-3x^2$ là đường cong màu xanh lá (nằm phía dưới trục hoành).</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.7.</b> Một cổng vòm được thiết kế dạng parabol $y=ax^2$ như Hình 6.8. Biết chiều rộng của chân cổng là $AB=6$ m và chiều cao của cổng là $OI=4{,}5$ m.</p>
<div><img src="/static/img/sgk9/sgk9-c6-hinh-6-8.png" alt="Hình 6.8 (SGK Toán 9)"></div>
<ol type="a">
<li>Tìm hệ số $a$ dựa vào các dữ kiện trên. Từ đó, tính độ dài đoạn $HK$ biết $H$ cách điểm chính giữa cổng $I$ là 2 m.</li>
<li>Để vận chuyển hàng qua cổng, người ta dự định sử dụng một xe tải có chiều rộng 2 m, chiều cao 3 m. Hỏi xe tải này có thể đi qua được cổng vòm đó hay không?</li>
</ol>', N'<p>Chọn hệ trục như hình: đỉnh $O$ của parabol ở trên, mặt đất là đường thẳng $y=-4{,}5$; $A(-3;-4{,}5)$, $B(3;-4{,}5)$.</p>
<p><b>a)</b> $B$ thuộc parabol nên $-4{,}5=a\cdot3^2$, suy ra $a=-\dfrac{1}{2}$. Điểm $K$ có hoành độ $x=2$ (vì $H$ cách $I$ là 2 m) nên $y_K=-\dfrac{1}{2}\cdot2^2=-2$. Khi đó $HK$ là khoảng cách từ $K$ xuống mặt đất: $HK=-2-(-4{,}5)=2{,}5$ (m).</p>
<p><b>b)</b> Xe rộng 2 m, đi chính giữa cổng nên hai mép xe có hoành độ $x=\pm1$. Tại $x=\pm1$: $y=-\dfrac{1}{2}\cdot1=-\dfrac{1}{2}$, nên chiều cao của cổng tại mép xe là $4{,}5-0{,}5=4$ (m). Vì $4\gt3$ nên xe tải đi qua được cổng.</p>
<p><b>Đáp số:</b> a) $a=-\dfrac{1}{2}$; $HK=2{,}5$ m. b) xe tải đi qua được.</p>', 2, 0, 1, @t1);

-- Bài 19
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 19. Phương trình bậc hai một ẩn', N'Định nghĩa phương trình bậc hai, giải phương trình dạng đặc biệt, công thức nghiệm, công thức nghiệm thu gọn và dùng máy tính cầm tay.', N'<p><b>1. Định nghĩa.</b> Phương trình bậc hai một ẩn (phương trình bậc hai) là phương trình có dạng $$ax^2+bx+c=0,$$ trong đó $x$ là ẩn; $a,b,c$ là những số cho trước gọi là hệ số và $a\neq0$.</p>
<p><b>Ví dụ 1.</b> $2x^2-3x+1=0$ là phương trình bậc hai với $a=2,b=-3,c=1$; $x^2-3=0$ có $a=1,b=0,c=-3$; $-5x^2=0$ có $a=-5,b=0,c=0$; phương trình $\left(\dfrac{1}{x}\right)^2+3\cdot\dfrac{1}{x}+2=0$ không phải phương trình bậc hai ẩn $x$.</p>
<p><b>2. Giải phương trình bậc hai dạng đặc biệt.</b></p>
<ul>
<li>Khuyết $c$ ($ax^2+bx=0$): đặt nhân tử chung $x(ax+b)=0$. Ví dụ $2x^2-4x=0\Leftrightarrow2x(x-2)=0$, nghiệm $x_1=0,\ x_2=2$.</li>
<li>Khuyết $b$ ($ax^2+c=0$) hoặc dạng $(x+m)^2=n$: nếu $A^2=B$ ($B\ge0$) thì $A=\sqrt{B}$ hoặc $A=-\sqrt{B}$. Ví dụ $x^2-9=0$ có $x=\pm3$; $(x+1)^2=3$ có $x=-1\pm\sqrt{3}$.</li>
<li>Dạng $x^2+bx=c$: cộng vào hai vế một số thích hợp để vế trái thành bình phương. Ví dụ $x^2-4x=1\Leftrightarrow(x-2)^2=5$, nghiệm $x=2\pm\sqrt{5}$.</li>
</ul>
<p><b>3. Công thức nghiệm.</b> Xét $ax^2+bx+c=0$ ($a\neq0$), biệt thức $\Delta=b^2-4ac$.</p>
<ul>
<li>Nếu $\Delta\gt0$: phương trình có hai nghiệm phân biệt $x_1=\dfrac{-b+\sqrt{\Delta}}{2a};\ x_2=\dfrac{-b-\sqrt{\Delta}}{2a}$.</li>
<li>Nếu $\Delta=0$: phương trình có nghiệm kép $x_1=x_2=-\dfrac{b}{2a}$.</li>
<li>Nếu $\Delta\lt0$: phương trình vô nghiệm.</li>
</ul>
<p><b>Ví dụ 2.</b> $3x^2+7x-1=0$ có $\Delta=49+12=61\gt0$ nên $x_{1,2}=\dfrac{-7\pm\sqrt{61}}{6}$. $x^2-6x+9=0$ có $\Delta=0$ nên có nghiệm kép $x=3$. $2x^2+3x+5=0$ có $\Delta=-31\lt0$ nên vô nghiệm.</p>
<p><b>Công thức nghiệm thu gọn.</b> Với $b=2b''$ và $\Delta''=b''^2-ac$: nếu $\Delta''\gt0$ thì $x_{1,2}=\dfrac{-b''\pm\sqrt{\Delta''}}{a}$; nếu $\Delta''=0$ thì nghiệm kép $x_1=x_2=-\dfrac{b''}{a}$; nếu $\Delta''\lt0$ thì vô nghiệm. Ví dụ $2x^2+6x+1=0$ có $b''=3$, $\Delta''=9-2=7$, $x_{1,2}=\dfrac{-3\pm\sqrt{7}}{2}$.</p>
<p><b>4. Dùng máy tính cầm tay.</b> Chuyển máy sang chế độ giải phương trình bậc hai (MODE), nhập lần lượt $a,b,c$ rồi bấm = để đọc các nghiệm $x_1,x_2$; nếu máy hiện nghiệm có chữ i (số phức) thì phương trình vô nghiệm thực.</p>
<p><b>Bài toán mở đầu (bể bơi).</b> Mảnh đất $28\ \text{m}\times16\ \text{m}$, bể bơi có đường đi xung quanh rộng $x$ (m) ($0\lt x\lt8$) và diện tích bể là 288 m²: $(28-2x)(16-2x)=288$ hay $x^2-22x+40=0$, $\Delta''=121-40=81$, $x=11\pm9$; chọn $x=2$ (loại $x=20$). Vậy đường đi rộng 2 m.</p>', 2, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.8.</b> Đưa các phương trình sau về dạng $ax^2+bx+c=0$ và xác định các hệ số $a,b,c$ của phương trình đó.</p>
<ol type="a">
<li>$3x^2+2x-1=x^2-x$;</li>
<li>$(2x+1)^2=x^2+1$.</li>
</ol>', N'<p><b>a)</b> $3x^2+2x-1-x^2+x=0$ hay $2x^2+3x-1=0$: $a=2,\ b=3,\ c=-1$.</p>
<p><b>b)</b> $4x^2+4x+1=x^2+1$ hay $3x^2+4x=0$: $a=3,\ b=4,\ c=0$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.9.</b> Giải các phương trình sau:</p>
<ol type="a">
<li>$2x^2+\dfrac{1}{3}x=0$;</li>
<li>$(3x+2)^2=5$.</li>
</ol>', N'<p><b>a)</b> $x\left(2x+\dfrac{1}{3}\right)=0$ suy ra $x=0$ hoặc $2x+\dfrac{1}{3}=0$, tức $x=-\dfrac{1}{6}$.</p>
<p><b>b)</b> $3x+2=\sqrt{5}$ hoặc $3x+2=-\sqrt{5}$, suy ra $x=\dfrac{-2+\sqrt{5}}{3}$ hoặc $x=\dfrac{-2-\sqrt{5}}{3}$.</p>
<p><b>Đáp số:</b> a) $x=0;\ x=-\dfrac{1}{6}$. b) $x=\dfrac{-2\pm\sqrt{5}}{3}$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.10.</b> Không cần giải phương trình, hãy xác định các hệ số $a,b,c$, tính biệt thức $\Delta$ và xác định số nghiệm của mỗi phương trình sau:</p>
<ol type="a">
<li>$11x^2+13x-1=0$;</li>
<li>$9x^2+42x+49=0$;</li>
<li>$x^2-2x+3=0$.</li>
</ol>', N'<p><b>a)</b> $a=11,b=13,c=-1$; $\Delta=169+44=213\gt0$: hai nghiệm phân biệt.</p>
<p><b>b)</b> $a=9,b=42,c=49$; $\Delta=1764-1764=0$: nghiệm kép.</p>
<p><b>c)</b> $a=1,b=-2,c=3$; $\Delta=4-12=-8\lt0$: vô nghiệm.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.11.</b> Áp dụng công thức nghiệm của phương trình bậc hai, giải các phương trình sau:</p>
<ol type="a">
<li>$x^2-2\sqrt{5}x+2=0$;</li>
<li>$4x^2+28x+49=0$;</li>
<li>$3x^2-3\sqrt{2}x+1=0$.</li>
</ol>', N'<p><b>a)</b> $\Delta=(2\sqrt{5})^2-4\cdot2=20-8=12\gt0$, $\sqrt{\Delta}=2\sqrt{3}$: $x=\dfrac{2\sqrt{5}\pm2\sqrt{3}}{2}=\sqrt{5}\pm\sqrt{3}$.</p>
<p><b>b)</b> $\Delta=28^2-4\cdot4\cdot49=784-784=0$: nghiệm kép $x=-\dfrac{28}{8}=-\dfrac{7}{2}$.</p>
<p><b>c)</b> $\Delta=(3\sqrt{2})^2-4\cdot3\cdot1=18-12=6\gt0$: $x=\dfrac{3\sqrt{2}\pm\sqrt{6}}{6}$.</p>
<p><b>Đáp số:</b> a) $x=\sqrt{5}\pm\sqrt{3}$. b) $x=-\dfrac{7}{2}$. c) $x=\dfrac{3\sqrt{2}\pm\sqrt{6}}{6}$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.12.</b> Sử dụng máy tính cầm tay, tìm nghiệm của các phương trình sau:</p>
<ol type="a">
<li>$0{,}1x^2+2{,}5x-0{,}2=0$;</li>
<li>$0{,}01x^2-0{,}05x+0{,}0625=0$;</li>
<li>$1{,}2x^2+0{,}75x+2{,}5=0$.</li>
</ol>', N'<p>Nhập lần lượt các hệ số $a,b,c$ vào chế độ giải phương trình bậc hai của máy tính:</p>
<p><b>a)</b> $a=0{,}1,\ b=2{,}5,\ c=-0{,}2$ (tương đương $x^2+25x-2=0$, $\Delta=633\gt0$): $x=\dfrac{-25\pm\sqrt{633}}{2}$, xấp xỉ $x_1\approx0{,}0797$ và $x_2\approx-25{,}0797$.</p>
<p><b>b)</b> $a=0{,}01,\ b=-0{,}05,\ c=0{,}0625$ (tương đương $x^2-5x+6{,}25=0$, $\Delta=0$): nghiệm kép $x_1=x_2=2{,}5$.</p>
<p><b>c)</b> $a=1{,}2,\ b=0{,}75,\ c=2{,}5$: $\Delta=0{,}5625-12\lt0$, máy hiện nghiệm phức nên phương trình vô nghiệm.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.13.</b> Độ cao $h$ (mét) so với mặt đất của một vật được phóng thẳng đứng lên trên từ mặt đất với vận tốc ban đầu $v_0=19{,}6$ m/s cho bởi công thức $h=19{,}6t-4{,}9t^2$, ở đó $t$ (giây) là thời gian kể từ khi phóng. Hỏi sau bao lâu kể từ khi phóng, vật sẽ rơi trở lại mặt đất?</p>', N'<p>Vật chạm đất khi $h=0$: $19{,}6t-4{,}9t^2=0$ hay $4{,}9t(4-t)=0$, suy ra $t=0$ (lúc phóng) hoặc $t=4$.</p>
<p><b>Đáp số:</b> vật rơi trở lại mặt đất sau 4 giây.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.14.</b> Kích thước màn hình ti vi hình chữ nhật được xác định bằng độ dài đường chéo. Ti vi truyền thống có định dạng 4 : 3, nghĩa là tỉ lệ giữa chiều dài và chiều rộng của màn hình là 4 : 3. Hỏi diện tích của màn hình ti vi truyền thống 37 in là bao nhiêu? Diện tích của màn hình ti vi LCD 37 in có định dạng 16 : 9 là bao nhiêu? Màn hình ti vi nào có diện tích lớn hơn? Ở đây, diện tích của các màn hình được tính bằng inch vuông.</p>', N'<p><b>Ti vi 4 : 3:</b> gọi chiều dài và chiều rộng là $4k$ và $3k$ ($k\gt0$). Đường chéo $\sqrt{(4k)^2+(3k)^2}=5k=37$ nên $k=7{,}4$. Diện tích $12k^2=12\cdot54{,}76=657{,}12$ (in²).</p>
<p><b>Ti vi 16 : 9:</b> chiều dài $16m$, chiều rộng $9m$; đường chéo $m\sqrt{256+81}=m\sqrt{337}=37$ nên $m^2=\dfrac{1369}{337}$. Diện tích $144m^2=\dfrac{144\cdot1369}{337}\approx584{,}97$ (in²).</p>
<p>Vì $657{,}12\gt584{,}97$ nên màn hình ti vi truyền thống có diện tích lớn hơn.</p>
<p><b>Đáp số:</b> khoảng $657{,}12$ in² (4 : 3) và $584{,}97$ in² (16 : 9); ti vi truyền thống có diện tích lớn hơn.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.15.</b> Một mảnh vườn hình chữ nhật có chiều rộng nhỏ hơn chiều dài 6 m và có diện tích bằng 280 m². Tính các kích thước của mảnh vườn đó.</p>', N'<p>Gọi $x$ (m) là chiều rộng ($x\gt0$), chiều dài là $x+6$. Ta có $x(x+6)=280$ hay $x^2+6x-280=0$.</p>
<p>$\Delta''=3^2+280=289$, $\sqrt{\Delta''}=17$: $x=-3+17=14$ (thỏa mãn) hoặc $x=-3-17=-20$ (loại).</p>
<p><b>Đáp số:</b> chiều rộng 14 m, chiều dài 20 m.</p>', 2, 0, 1, @t1);

-- Luyện tập chung (Bài 18 - Bài 19)
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Luyện tập chung (Bài 18 - Bài 19)', N'Vẽ đồ thị hai parabol, tìm điểm thuộc parabol và giải bài toán thực tế bằng phương trình bậc hai.', N'<p><b>Ví dụ 1.</b> Cho hai hàm số $y=\dfrac{3}{2}x^2$ và $y=-x^2$. a) Vẽ đồ thị trên cùng mặt phẳng tọa độ (lập bảng $x=-2;-1;0;1;2$: $y=6;\dfrac{3}{2};0;\dfrac{3}{2};6$ và $y=-4;-1;0;-1;-4$). b) Điểm $A$ thuộc $y=\dfrac{3}{2}x^2$ và điểm $B$ thuộc $y=-x^2$ cùng có hoành độ $x=-\dfrac{3}{2}$: $y_A=\dfrac{3}{2}\cdot\dfrac{9}{4}=\dfrac{27}{8}$, $y_B=-\dfrac{9}{4}$. Vậy $A\left(-\dfrac{3}{2};\dfrac{27}{8}\right)$, $B\left(-\dfrac{3}{2};-\dfrac{9}{4}\right)$.</p>
<p><b>Ví dụ 2.</b> Số cá trong hồ sau $t$ năm kể từ 01-01-2020 được cho bởi $P=50(100+15t-t^2)$, $0\le t\le15$. a) $P=7500$: $t^2-15t+50=0$ cho $t=5$ hoặc $t=10$, tức vào ngày 01-01-2025 hoặc 01-01-2030. b) Ban đầu $P(0)=5000$; $P=5000$ khi $15t-t^2=0$, tức $t=0$ hoặc $t=15$; vậy đến ngày 01-01-2035 số cá trở lại như ban đầu.</p>', 3, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.16.</b> Biết rằng parabol $y=ax^2$ ($a\neq0$) đi qua điểm $A(2;4\sqrt{3})$.</p>
<ol type="a">
<li>Tìm hệ số $a$ và vẽ đồ thị của hàm số $y=ax^2$ với $a$ vừa tìm được.</li>
<li>Tìm tung độ của điểm thuộc parabol có hoành độ $x=-1$.</li>
<li>Tìm các điểm thuộc parabol có tung độ $y=5\sqrt{3}$.</li>
</ol>', N'<p><b>a)</b> $4\sqrt{3}=a\cdot2^2$ suy ra $a=\sqrt{3}$. Đồ thị $y=\sqrt{3}x^2$ là parabol đỉnh $O$, mở lên trên, đi qua các điểm $(0;0),\ (\pm1;\sqrt{3}),\ (\pm2;4\sqrt{3})$.</p>
<p><b>b)</b> Với $x=-1$: $y=\sqrt{3}\cdot1=\sqrt{3}$.</p>
<p><b>c)</b> $\sqrt{3}x^2=5\sqrt{3}$ suy ra $x^2=5$, $x=\pm\sqrt{5}$. Các điểm là $(\sqrt{5};5\sqrt{3})$ và $(-\sqrt{5};5\sqrt{3})$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.17.</b> Công thức $E=\dfrac{1}{2}mv^2$ (J) được dùng để tính động năng của một vật có khối lượng $m$ (kg) khi chuyển động với vận tốc $v$ (m/s).</p>
<ol type="a">
<li>Giả sử một quả bóng có khối lượng 2 kg đang bay với vận tốc 6 m/s. Tính động năng của quả bóng đó.</li>
<li>Giả sử động năng của quả bóng đang bay có khối lượng 1,5 kg là 48 J, hãy tính vận tốc bay của quả bóng đó.</li>
</ol>', N'<p><b>a)</b> $E=\dfrac{1}{2}\cdot2\cdot6^2=36$ (J).</p>
<p><b>b)</b> $48=\dfrac{1}{2}\cdot1{,}5\cdot v^2$ suy ra $v^2=64$, $v=8$ (vì $v\gt0$).</p>
<p><b>Đáp số:</b> a) 36 J. b) 8 m/s.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.18.</b> Cho hình chóp tam giác đều có đáy là tam giác đều cạnh $a$ (cm) và chiều cao 10 cm.</p>
<ol type="a">
<li>Tính diện tích đáy $S$ của hình chóp theo $a$.</li>
<li>Từ kết quả ở câu a, tính thể tích $V$ của hình chóp theo $a$ và tính giá trị của $V$ khi $a=4$ cm.</li>
<li>Nếu độ dài cạnh đáy giảm đi hai lần thì thể tích hình chóp thay đổi thế nào?</li>
</ol>', N'<p><b>a)</b> Tam giác đều cạnh $a$ có diện tích $S=\dfrac{\sqrt{3}}{4}a^2$ (cm²).</p>
<p><b>b)</b> $V=\dfrac{1}{3}\cdot S\cdot10=\dfrac{1}{3}\cdot\dfrac{\sqrt{3}}{4}a^2\cdot10=\dfrac{5\sqrt{3}}{6}a^2$ (cm³). Khi $a=4$: $V=\dfrac{5\sqrt{3}}{6}\cdot16=\dfrac{40\sqrt{3}}{3}\approx23{,}09$ (cm³).</p>
<p><b>c)</b> Cạnh đáy giảm 2 lần thành $\dfrac{a}{2}$: $V''=\dfrac{5\sqrt{3}}{6}\cdot\dfrac{a^2}{4}=\dfrac{V}{4}$. Thể tích giảm đi 4 lần.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.19.</b> Sử dụng công thức nghiệm hoặc công thức nghiệm thu gọn, giải các phương trình sau:</p>
<ol type="a">
<li>$x^2-2\sqrt{5}x+1=0$;</li>
<li>$3x^2-9x+3=0$;</li>
<li>$11x^2-13x+5=0$;</li>
<li>$2x^2+2\sqrt{6}x+3=0$.</li>
</ol>', N'<p><b>a)</b> $b''=-\sqrt{5}$, $\Delta''=5-1=4\gt0$: $x=\sqrt{5}\pm2$.</p>
<p><b>b)</b> Chia hai vế cho 3: $x^2-3x+1=0$, $\Delta=9-4=5\gt0$: $x=\dfrac{3\pm\sqrt{5}}{2}$.</p>
<p><b>c)</b> $\Delta=(-13)^2-4\cdot11\cdot5=169-220=-51\lt0$: vô nghiệm.</p>
<p><b>d)</b> $b''=\sqrt{6}$, $\Delta''=6-2\cdot3=0$: nghiệm kép $x=-\dfrac{\sqrt{6}}{2}$.</p>
<p><b>Đáp số:</b> a) $x=\sqrt{5}\pm2$. b) $x=\dfrac{3\pm\sqrt{5}}{2}$. c) vô nghiệm. d) $x=-\dfrac{\sqrt{6}}{2}$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.20.</b> Sử dụng máy tính cầm tay, tìm nghiệm gần đúng của các phương trình sau (làm tròn kết quả đến chữ số thập phân thứ hai):</p>
<ol type="a">
<li>$\sqrt{2}x^2-\sqrt{5}x-1=0$;</li>
<li>$x^2-(\sqrt{3}-1)x-\sqrt{7}=0$.</li>
</ol>', N'<p><b>a)</b> $a=\sqrt{2},\ b=-\sqrt{5},\ c=-1$: $\Delta=5+4\sqrt{2}\approx10{,}657\gt0$. Máy tính cho $x_1\approx1{,}94$ và $x_2\approx-0{,}36$.</p>
<p><b>b)</b> $a=1,\ b=-(\sqrt{3}-1),\ c=-\sqrt{7}$: $\Delta=(\sqrt{3}-1)^2+4\sqrt{7}\gt0$. Máy tính cho $x_1\approx2{,}03$ và $x_2\approx-1{,}30$.</p>
<p><b>Đáp số:</b> a) $x_1\approx1{,}94;\ x_2\approx-0{,}36$. b) $x_1\approx2{,}03;\ x_2\approx-1{,}30$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.21.</b> Từ một tấm tôn hình vuông, người ta cắt bỏ bốn hình vuông có độ dài cạnh 8 cm ở bốn góc, sau đó gấp thành một chiếc thùng có dạng hình hộp chữ nhật không có nắp và có thể tích bằng 200 cm³. Tính độ dài cạnh của tấm tôn hình vuông ban đầu.</p>', N'<p>Gọi $a$ (cm) là cạnh tấm tôn ($a\gt16$). Chiếc thùng có đáy là hình vuông cạnh $a-16$ và chiều cao 8 cm.</p>
<p>Thể tích: $8(a-16)^2=200$ suy ra $(a-16)^2=25$, $a-16=5$ hoặc $a-16=-5$. Do $a\gt16$ nên $a=21$ (loại $a=11$).</p>
<p><b>Đáp số:</b> cạnh tấm tôn ban đầu là 21 cm.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.22.</b> Giả sử doanh thu (nghìn đồng) của một cửa hàng bán phở trong một ngày có thể mô hình hoá bằng công thức $R(x)=x(220-4x)$ với $30\le x\le50$, trong đó $x$ (nghìn đồng) là giá tiền của một bát phở. Nếu muốn doanh thu trong ngày của cửa hàng đạt 3 triệu đồng thì giá bán của mỗi bát phở phải là bao nhiêu?</p>', N'<p>3 triệu đồng $=3000$ nghìn đồng. Giải $x(220-4x)=3000$ hay $4x^2-220x+3000=0$, tức $x^2-55x+750=0$.</p>
<p>$\Delta=55^2-4\cdot750=3025-3000=25$: $x=\dfrac{55+5}{2}=30$ hoặc $x=\dfrac{55-5}{2}=25$.</p>
<p>Điều kiện $30\le x\le50$ nên chỉ nhận $x=30$ (loại $x=25$).</p>
<p><b>Đáp số:</b> giá mỗi bát phở là 30 nghìn đồng.</p>', 2, 0, 1, @t1);

-- Bài 20
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 20. Định lí Viète và ứng dụng', N'Định lí Viète, tính nhẩm nghiệm của phương trình bậc hai và tìm hai số khi biết tổng và tích.', N'<p><b>1. Định lí Viète.</b> Nếu $x_1,x_2$ là hai nghiệm của phương trình $ax^2+bx+c=0$ ($a\neq0$) thì $$\begin{cases}x_1+x_2=-\dfrac{b}{a}\\ x_1x_2=\dfrac{c}{a}.\end{cases}$$</p>
<p><b>Ví dụ 1.</b> a) $2x^2+11x+7=0$ có $\Delta=121-56=65\gt0$ nên có hai nghiệm phân biệt; $x_1+x_2=-\dfrac{11}{2}$, $x_1x_2=\dfrac{7}{2}$. b) $4x^2-12x+9=0$ có $\Delta''=36-36=0$ nên có hai nghiệm trùng nhau; $x_1+x_2=3$, $x_1x_2=\dfrac{9}{4}$.</p>
<p><b>2. Tính nhẩm nghiệm.</b> Xét $ax^2+bx+c=0$ ($a\neq0$):</p>
<ul>
<li>Nếu $a+b+c=0$ thì phương trình có một nghiệm $x_1=1$, nghiệm kia là $x_2=\dfrac{c}{a}$.</li>
<li>Nếu $a-b+c=0$ thì phương trình có một nghiệm $x_1=-1$, nghiệm kia là $x_2=-\dfrac{c}{a}$.</li>
</ul>
<p><b>Ví dụ 2.</b> $x^2-6x+5=0$ có $a+b+c=0$ nên $x_1=1,\ x_2=5$. $5x^2+14x+9=0$ có $a-b+c=0$ nên $x_1=-1,\ x_2=-\dfrac{9}{5}$.</p>
<p><b>Ví dụ 3.</b> Giải $x^2-7x+12=0$ biết một nghiệm là $x_1=3$. Theo định lí Viète $x_1x_2=12$ nên $x_2=\dfrac{12}{3}=4$.</p>
<p><b>3. Tìm hai số khi biết tổng và tích.</b> Nếu hai số có tổng bằng $S$ và tích bằng $P$ thì hai số đó là hai nghiệm của phương trình $x^2-Sx+P=0$. Điều kiện để có hai số đó là $S^2-4P\ge0$.</p>
<p><b>Ví dụ 4.</b> Tìm hai số có tổng bằng 9 và tích bằng 20: giải $x^2-9x+20=0$, $\Delta=1$, nghiệm $x=4$ và $x=5$.</p>
<p><b>Bài toán mở đầu.</b> Bác An có 40 m hàng rào bao quanh mảnh vườn hình chữ nhật diện tích 96 m²: nửa chu vi là 20, nên chiều dài và chiều rộng là hai nghiệm của $x^2-20x+96=0$, $\Delta''=100-96=4$, $x=10\pm2$. Vậy kích thước là 12 m và 8 m.</p>', 4, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.23.</b> Không giải phương trình, hãy tính tổng và tích các nghiệm (nếu có) của các phương trình sau:</p>
<ol type="a">
<li>$x^2-12x+8=0$;</li>
<li>$2x^2+11x-5=0$;</li>
<li>$3x^2-10=0$;</li>
<li>$x^2-x+3=0$.</li>
</ol>', N'<p>Trước hết kiểm tra điều kiện có nghiệm ($\Delta\ge0$), rồi áp dụng định lí Viète.</p>
<p><b>a)</b> $\Delta''=36-8=28\gt0$: $x_1+x_2=12$; $x_1x_2=8$.</p>
<p><b>b)</b> $\Delta=121+40=161\gt0$: $x_1+x_2=-\dfrac{11}{2}$; $x_1x_2=-\dfrac{5}{2}$.</p>
<p><b>c)</b> $\Delta=0-4\cdot3\cdot(-10)=120\gt0$: $x_1+x_2=0$; $x_1x_2=-\dfrac{10}{3}$.</p>
<p><b>d)</b> $\Delta=1-12=-11\lt0$: phương trình vô nghiệm nên không có tổng và tích các nghiệm.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.24.</b> Tính nhẩm nghiệm của các phương trình sau:</p>
<ol type="a">
<li>$2x^2-9x+7=0$;</li>
<li>$3x^2+11x+8=0$;</li>
<li>$7x^2-15x+2=0$, biết phương trình có một nghiệm $x_1=2$.</li>
</ol>', N'<p><b>a)</b> $a+b+c=2-9+7=0$ nên $x_1=1$, $x_2=\dfrac{c}{a}=\dfrac{7}{2}$.</p>
<p><b>b)</b> $a-b+c=3-11+8=0$ nên $x_1=-1$, $x_2=-\dfrac{c}{a}=-\dfrac{8}{3}$.</p>
<p><b>c)</b> Theo định lí Viète $x_1x_2=\dfrac{2}{7}$ nên $x_2=\dfrac{2}{7\cdot2}=\dfrac{1}{7}$.</p>
<p><b>Đáp số:</b> a) $1;\ \dfrac{7}{2}$. b) $-1;\ -\dfrac{8}{3}$. c) $2;\ \dfrac{1}{7}$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.25.</b> Tìm hai số $u$ và $v$, biết:</p>
<ol type="a">
<li>$u+v=20,\ uv=99$;</li>
<li>$u+v=2,\ uv=15$.</li>
</ol>', N'<p><b>a)</b> $u,v$ là hai nghiệm của $x^2-20x+99=0$. $\Delta''=100-99=1$: $x=10\pm1$, tức $9$ và $11$. Vậy $u=9,v=11$ hoặc $u=11,v=9$.</p>
<p><b>b)</b> $u,v$ là hai nghiệm của $x^2-2x+15=0$. $\Delta''=1-15=-14\lt0$ (hay $S^2-4P=4-60\lt0$) nên không tồn tại hai số $u,v$ thỏa mãn.</p>
<p><b>Đáp số:</b> a) $(9;11)$ hoặc $(11;9)$. b) không tồn tại.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.26.</b> Chứng tỏ rằng nếu phương trình bậc hai $ax^2+bx+c=0$ có hai nghiệm là $x_1$ và $x_2$ thì đa thức $ax^2+bx+c$ phân tích được thành nhân tử như sau: $$ax^2+bx+c=a(x-x_1)(x-x_2).$$ <i>Áp dụng:</i> Phân tích các đa thức sau thành nhân tử:</p>
<ol type="a">
<li>$x^2+11x+18$;</li>
<li>$3x^2+5x-2$.</li>
</ol>', N'<p><b>Chứng minh.</b> Theo định lí Viète $x_1+x_2=-\dfrac{b}{a}$ và $x_1x_2=\dfrac{c}{a}$. Khi đó $$a(x-x_1)(x-x_2)=a\left[x^2-(x_1+x_2)x+x_1x_2\right]=a\left(x^2+\dfrac{b}{a}x+\dfrac{c}{a}\right)=ax^2+bx+c.$$</p>
<p><b>a)</b> $x^2+11x+18=0$ có $\Delta=121-72=49$, nghiệm $x=\dfrac{-11\pm7}{2}$, tức $x_1=-2,\ x_2=-9$. Vậy $x^2+11x+18=(x+2)(x+9)$.</p>
<p><b>b)</b> $3x^2+5x-2=0$ có $\Delta=25+24=49$, nghiệm $x=\dfrac{-5\pm7}{6}$, tức $x_1=\dfrac{1}{3},\ x_2=-2$. Vậy $3x^2+5x-2=3\left(x-\dfrac{1}{3}\right)(x+2)=(3x-1)(x+2)$.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.27.</b> Một bể bơi hình chữ nhật có diện tích 300 m² và chu vi là 74 m. Tính các kích thước của bể bơi này.</p>', N'<p>Nửa chu vi là $74:2=37$ (m). Chiều dài và chiều rộng có tổng bằng 37 và tích bằng 300 nên là hai nghiệm của $x^2-37x+300=0$.</p>
<p>$\Delta=37^2-4\cdot300=1369-1200=169$, $\sqrt{\Delta}=13$: $x=\dfrac{37\pm13}{2}$, tức $25$ và $12$.</p>
<p><b>Đáp số:</b> chiều dài 25 m, chiều rộng 12 m.</p>', 2, 0, 1, @t1);

-- Bài 21
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 21. Giải bài toán bằng cách lập phương trình', N'Các bước giải bài toán bằng cách lập phương trình bậc hai: hình học, chuyển động, lãi kép, năng suất.', N'<p><b>Các bước giải bài toán bằng cách lập phương trình:</b></p>
<ol>
<li><i>Bước 1. Lập phương trình:</i> chọn ẩn số và đặt điều kiện thích hợp cho ẩn số; biểu diễn các đại lượng chưa biết theo ẩn và các đại lượng đã biết; lập phương trình biểu thị mối quan hệ giữa các đại lượng.</li>
<li><i>Bước 2. Giải phương trình.</i></li>
<li><i>Bước 3. Trả lời:</i> kiểm tra xem trong các nghiệm của phương trình, nghiệm nào thỏa mãn điều kiện của ẩn, nghiệm nào không, rồi kết luận.</li>
</ol>
<p><b>Bài toán mở đầu (lãi kép).</b> Bác Lan gửi 100 triệu đồng, kì hạn 12 tháng với lãi suất $x$ (số thập phân). Sau kì thứ nhất có $100(1+x)$ triệu đồng; sau kì thứ hai có $100(1+x)^2=118{,}81$, suy ra $1+x=1{,}09$, $x=0{,}09$. Vậy lãi suất là 9%/năm.</p>
<p><b>Ví dụ 1.</b> Sân bóng đá 7 người có chiều rộng nhỏ hơn chiều dài 30 m và diện tích 1 800 m². Gọi chiều rộng là $x$ (m), $x\gt0$, chiều dài $x+30$: $x(x+30)=1800$ hay $x^2+30x-1800=0$; $\Delta''=225+1800=2025$, $\sqrt{\Delta''}=45$; $x=-15-45=-60$ (loại) hoặc $x=-15+45=30$ (thỏa mãn). Sân dài 60 m, rộng 30 m.</p>
<p><b>Ví dụ 2.</b> Hai bến sông A và B cách nhau 36 km. Tàu du lịch đi từ A đến B, nghỉ 30 phút ở B rồi quay lại A; thời gian cả hành trình là 5,5 giờ; vận tốc dòng nước là 3 km/h. Gọi $x$ (km/h) là vận tốc thực của tàu ($x\gt3$). Phương trình: $\dfrac{36}{x+3}+0{,}5+\dfrac{36}{x-3}=5{,}5$ hay $\dfrac{36}{x+3}+\dfrac{36}{x-3}=5$. Khử mẫu được $5x^2-72x-45=0$; $\Delta''=1296+225=1521$, $\sqrt{\Delta''}=39$; $x=\dfrac{36-39}{5}=-\dfrac{3}{5}$ (loại) hoặc $x=\dfrac{36+39}{5}=15$ (thỏa mãn). Vận tốc thực của tàu là 15 km/h.</p>
<p><b>Luyện tập.</b> Đội xe chở 120 tấn hàng; có hai xe điều đi nơi khác nên mỗi xe phải chở thêm 3 tấn. Gọi $x$ là số xe ($x\gt2$): $\dfrac{120}{x-2}-\dfrac{120}{x}=3$, suy ra $x^2-2x-80=0$, $x=10$ (loại $x=-8$). Đội có 10 xe tải.</p>', 5, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.28.</b> Một mảnh đất hình chữ nhật có diện tích 360 m². Nếu tăng chiều rộng 3 m và giảm chiều dài 4 m thì diện tích mảnh đất không đổi. Tìm các kích thước của mảnh đất đó.</p>', N'<p>Gọi $x$ (m) là chiều rộng, $y$ (m) là chiều dài ($x\gt0$, $y\gt4$). Ta có $xy=360$ và $(x+3)(y-4)=360$.</p>
<p>Khai triển: $xy-4x+3y-12=360$ nên $-4x+3y=12$, suy ra $y=\dfrac{4x+12}{3}$. Thế vào $xy=360$: $x\cdot\dfrac{4x+12}{3}=360$ hay $x^2+3x-270=0$.</p>
<p>$\Delta=9+1080=1089$, $\sqrt{\Delta}=33$: $x=\dfrac{-3+33}{2}=15$ (thỏa mãn) hoặc $x=-18$ (loại). Khi đó $y=\dfrac{4\cdot15+12}{3}=24$.</p>
<p>Kiểm tra: $(15+3)(24-4)=18\cdot20=360$.</p>
<p><b>Đáp số:</b> chiều rộng 15 m, chiều dài 24 m.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.29.</b> Sau hai năm, số dân của một thành phố tăng từ 1 200 000 người lên 1 452 000 người. Hỏi trung bình mỗi năm dân số của thành phố đó tăng bao nhiêu phần trăm?</p>', N'<p>Gọi $x$ là tỉ lệ tăng dân số mỗi năm (số thập phân, $x\gt0$). Sau hai năm: $1200000(1+x)^2=1452000$ suy ra $(1+x)^2=1{,}21$.</p>
<p>Do $1+x\gt0$ nên $1+x=1{,}1$, $x=0{,}1$ (thỏa mãn).</p>
<p><b>Đáp số:</b> trung bình mỗi năm dân số tăng 10%.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.30.</b> Một thanh sô cô la có dạng hình hộp chữ nhật với chiều dài 12 cm, chiều rộng 7 cm và độ dày 3 cm. Do giá nguyên liệu ca cao tăng nhưng vẫn muốn giữ nguyên giá bán nên nhà sản xuất quyết định giảm 10% thể tích của mỗi thanh sô cô la. Để thực hiện việc này, nhà sản xuất dự định làm thanh sô cô la mới có cùng độ dày 3 cm như thanh cũ, nhưng chiều dài và chiều rộng sẽ giảm đi cùng một số centimét. Hỏi kích thước của thanh sô cô la mới là bao nhiêu (làm tròn kết quả đến hàng phần trăm của cm)?</p>', N'<p>Thể tích thanh cũ: $12\cdot7\cdot3=252$ (cm³). Thể tích mới bằng 90%: $0{,}9\cdot252=226{,}8$ (cm³).</p>
<p>Gọi $x$ (cm) là số centimét giảm đi ($0\lt x\lt7$). Ta có $3(12-x)(7-x)=226{,}8$ hay $(12-x)(7-x)=75{,}6$, tức $x^2-19x+8{,}4=0$.</p>
<p>$\Delta=361-33{,}6=327{,}4$, $\sqrt{\Delta}\approx18{,}094$: $x\approx\dfrac{19-18{,}094}{2}\approx0{,}45$ (thỏa mãn) hoặc $x\approx18{,}55$ (loại vì $x\lt7$).</p>
<p>Kích thước mới: chiều dài $12-0{,}45\approx11{,}55$ (cm), chiều rộng $7-0{,}45\approx6{,}55$ (cm), độ dày 3 cm.</p>
<p><b>Đáp số:</b> khoảng $11{,}55\ \text{cm}\times6{,}55\ \text{cm}\times3\ \text{cm}$.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.31.</b> Một máy bay khởi hành từ Hà Nội vào Thành phố Hồ Chí Minh, sau đó nghỉ 96 phút và tiếp tục bay về Hà Nội với vận tốc lớn hơn vận tốc lúc đi là 100 km/h. Tổng thời gian của cả hành trình, kể từ khi xuất phát từ Hà Nội đến khi quay về Hà Nội là 6 giờ. Tính vận tốc của máy bay lúc đi, biết quãng đường bay Hà Nội – Thành phố Hồ Chí Minh dài khoảng 1 200 km.</p>', N'<p>Đổi 96 phút $=1{,}6$ giờ nên thời gian bay là $6-1{,}6=4{,}4$ giờ. Gọi $x$ (km/h) là vận tốc lúc đi ($x\gt0$), vận tốc lúc về là $x+100$.</p>
<p>$\dfrac{1200}{x}+\dfrac{1200}{x+100}=4{,}4$. Khử mẫu: $1200(x+100)+1200x=4{,}4x(x+100)$ hay $4{,}4x^2-1960x-120000=0$, tức $11x^2-4900x-300000=0$.</p>
<p>$\Delta''=2450^2+11\cdot300000=9302500$, $\sqrt{\Delta''}=3050$: $x=\dfrac{2450+3050}{11}=500$ (thỏa mãn) hoặc $x=\dfrac{2450-3050}{11}\lt0$ (loại).</p>
<p>Kiểm tra: $\dfrac{1200}{500}+\dfrac{1200}{600}=2{,}4+2=4{,}4$.</p>
<p><b>Đáp số:</b> vận tốc máy bay lúc đi là 500 km/h.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.32.</b> Một ô tô khách khởi hành từ Hà Nội đi Hải Phòng. Sau đó 30 phút, một ô tô con xuất phát từ cùng địa điểm ở Hà Nội và cũng đi về Hải Phòng trên cùng tuyến đường, với vận tốc lớn hơn vận tốc của ô tô khách là 20 km/h. Hai xe đến cùng một địa điểm ở Hải Phòng tại cùng một thời điểm. Hãy tính vận tốc của mỗi ô tô, biết rằng quãng đường Hà Nội – Hải Phòng dài khoảng 120 km.</p>', N'<p>Gọi $x$ (km/h) là vận tốc của ô tô khách ($x\gt0$), ô tô con đi với vận tốc $x+20$. Ô tô con xuất phát sau 30 phút $=0{,}5$ giờ mà đến cùng lúc nên $\dfrac{120}{x}-\dfrac{120}{x+20}=0{,}5$.</p>
<p>Khử mẫu: $120(x+20)-120x=0{,}5x(x+20)$ hay $2400=0{,}5x^2+10x$, tức $x^2+20x-4800=0$.</p>
<p>$\Delta''=100+4800=4900$, $\sqrt{\Delta''}=70$: $x=-10+70=60$ (thỏa mãn) hoặc $x=-80$ (loại).</p>
<p>Kiểm tra: $\dfrac{120}{60}-\dfrac{120}{80}=2-1{,}5=0{,}5$.</p>
<p><b>Đáp số:</b> ô tô khách 60 km/h, ô tô con 80 km/h.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.33.</b> Một xưởng may phải may 1 500 chiếc áo trong thời gian quy định. Để hoàn thành sớm kế hoạch, mỗi ngày xưởng đã may được nhiều hơn 10 chiếc áo so với số áo phải may trong một ngày theo kế hoạch. Do đó, ba ngày trước khi hết thời hạn, xưởng đã may được 1 320 áo. Hỏi theo kế hoạch, mỗi ngày xưởng đó phải may xong bao nhiêu chiếc áo?</p>', N'<p>Gọi $x$ là số áo phải may mỗi ngày theo kế hoạch ($x\gt0$); thời gian quy định là $\dfrac{1500}{x}$ ngày. Thực tế mỗi ngày may $x+10$ áo.</p>
<p>Ba ngày trước khi hết thời hạn, xưởng đã làm được $\dfrac{1500}{x}-3$ ngày và may được 1 320 áo nên $$\left(\dfrac{1500}{x}-3\right)(x+10)=1320.$$ Khai triển: $1500+\dfrac{15000}{x}-3x-30=1320$ hay $\dfrac{15000}{x}-3x+150=0$. Nhân hai vế với $x$: $-3x^2+150x+15000=0$, tức $x^2-50x-5000=0$.</p>
<p>$\Delta''=625+5000=5625$, $\sqrt{\Delta''}=75$: $x=25+75=100$ (thỏa mãn) hoặc $x=-50$ (loại).</p>
<p>Kiểm tra: thời hạn $1500:100=15$ ngày; sau $12$ ngày may $12\cdot110=1320$ áo.</p>
<p><b>Đáp số:</b> theo kế hoạch mỗi ngày xưởng phải may 100 chiếc áo.</p>', 3, 0, 1, @t1);

-- Luyện tập chung (Bài 20 - Bài 21)
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Luyện tập chung (Bài 20 - Bài 21)', N'Vận dụng định lí Viète để tính biểu thức đối xứng của hai nghiệm và giải bài toán bằng cách lập phương trình.', N'<p><b>Ví dụ 1.</b> Cho phương trình $x^2-7x+5=0$. a) $\Delta=49-20=29\gt0$ nên phương trình có hai nghiệm phân biệt $x_1,x_2$. b) Theo định lí Viète $x_1+x_2=7$, $x_1x_2=5$. Do đó $A=x_1^2+x_2^2=(x_1+x_2)^2-2x_1x_2=49-10=39$.</p>
<p><b>Ví dụ 2.</b> Hai miếng kim loại nặng 600 g và 640 g. Thể tích miếng thứ nhất lớn hơn miếng thứ hai là 120 cm³, nhưng khối lượng riêng miếng thứ nhất nhỏ hơn miếng thứ hai là 5 g/cm³. Gọi $x$ (g/cm³) là khối lượng riêng miếng thứ nhất ($x\gt0$): $\dfrac{600}{x}-\dfrac{640}{x+5}=120$ hay $3x^2+16x-75=0$; $\Delta''=64+225=289$, $x=\dfrac{-8\pm17}{3}$; nhận $x=3$ (loại $x=-\dfrac{25}{3}$). Khối lượng riêng hai miếng là 3 g/cm³ và 8 g/cm³.</p>', 6, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.34.</b> Tính nhẩm nghiệm của các phương trình sau:</p>
<ol type="a">
<li>$\sqrt{2}x^2-(\sqrt{2}+1)x+1=0$;</li>
<li>$2x^2+(\sqrt{3}-1)x-3+\sqrt{3}=0$.</li>
</ol>', N'<p><b>a)</b> $a+b+c=\sqrt{2}-(\sqrt{2}+1)+1=0$ nên $x_1=1$, $x_2=\dfrac{c}{a}=\dfrac{1}{\sqrt{2}}=\dfrac{\sqrt{2}}{2}$.</p>
<p><b>b)</b> $a-b+c=2-(\sqrt{3}-1)+(-3+\sqrt{3})=2-\sqrt{3}+1-3+\sqrt{3}=0$ nên $x_1=-1$, $x_2=-\dfrac{c}{a}=\dfrac{3-\sqrt{3}}{2}$.</p>
<p><b>Đáp số:</b> a) $x=1;\ x=\dfrac{\sqrt{2}}{2}$. b) $x=-1;\ x=\dfrac{3-\sqrt{3}}{2}$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.35.</b> Gọi $x_1,x_2$ là hai nghiệm của phương trình bậc hai $x^2-5x+3=0$. Không giải phương trình, hãy tính:</p>
<ol type="a">
<li>$x_1^2+x_2^2$;</li>
<li>$(x_1-x_2)^2$.</li>
</ol>', N'<p>$\Delta=25-12=13\gt0$ nên phương trình có hai nghiệm; theo định lí Viète $x_1+x_2=5$, $x_1x_2=3$.</p>
<p><b>a)</b> $x_1^2+x_2^2=(x_1+x_2)^2-2x_1x_2=25-6=19$.</p>
<p><b>b)</b> $(x_1-x_2)^2=(x_1+x_2)^2-4x_1x_2=25-12=13$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.36.</b> Tìm hai số $u$ và $v$, biết:</p>
<ol type="a">
<li>$u+v=15,\ uv=56$;</li>
<li>$u^2+v^2=125,\ uv=22$.</li>
</ol>', N'<p><b>a)</b> $u,v$ là hai nghiệm của $x^2-15x+56=0$; $\Delta=225-224=1$: $x=\dfrac{15\pm1}{2}$, tức $8$ và $7$. Vậy $(u;v)=(7;8)$ hoặc $(8;7)$.</p>
<p><b>b)</b> $(u+v)^2=u^2+v^2+2uv=125+44=169$ nên $u+v=13$ hoặc $u+v=-13$.</p>
<p>Với $u+v=13$, $uv=22$: $x^2-13x+22=0$, $\Delta=169-88=81$, $x=\dfrac{13\pm9}{2}$, tức $11$ và $2$.</p>
<p>Với $u+v=-13$, $uv=22$: $x^2+13x+22=0$, nghiệm $-11$ và $-2$.</p>
<p><b>Đáp số:</b> a) $(7;8)$, $(8;7)$. b) $(11;2)$, $(2;11)$, $(-11;-2)$, $(-2;-11)$.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.37.</b> Một chiếc hộp có dạng hình hộp chữ nhật, không có nắp, có đáy là hình vuông, tổng diện tích xung quanh và diện tích đáy là 800 cm². Chiều cao của hộp là 10 cm. Tính độ dài cạnh đáy của chiếc hộp (làm tròn kết quả đến hàng phần mười của cm).</p>', N'<p>Gọi $x$ (cm) là cạnh đáy ($x\gt0$). Diện tích xung quanh là $4\cdot x\cdot10=40x$, diện tích đáy là $x^2$.</p>
<p>Ta có $x^2+40x=800$ hay $x^2+40x-800=0$. $\Delta''=400+800=1200$, $\sqrt{\Delta''}=20\sqrt{3}\approx34{,}64$: $x=-20+34{,}64\approx14{,}64$ (thỏa mãn) hoặc $x\approx-54{,}64$ (loại).</p>
<p><b>Đáp số:</b> cạnh đáy khoảng 14,6 cm.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.38.</b> Nhu cầu của khách hàng đối với một loại áo phông tại một cửa hàng được cho bởi phương trình $p=100-0{,}02x$, trong đó $p$ là giá tiền của mỗi chiếc áo (nghìn đồng) và $x$ là số lượng áo phông bán được. Doanh thu $R$ (nghìn đồng) khi bán được $x$ chiếc áo phông là $R=xp=x(100-0{,}02x)$. Hỏi cần phải bán được bao nhiêu chiếc áo phông để doanh thu đạt 120 triệu đồng?</p>', N'<p>120 triệu đồng $=120000$ nghìn đồng. Giải $x(100-0{,}02x)=120000$ hay $0{,}02x^2-100x+120000=0$, tức $x^2-5000x+6000000=0$.</p>
<p>$\Delta''=2500^2-6000000=250000$, $\sqrt{\Delta''}=500$: $x=2500\pm500$, tức $x=3000$ hoặc $x=2000$.</p>
<p>Cả hai giá trị đều hợp lí vì giá bán $p=100-0{,}02x$ vẫn dương ($p=40$ nghìn đồng khi $x=3000$; $p=60$ nghìn đồng khi $x=2000$).</p>
<p><b>Đáp số:</b> cần bán 2 000 hoặc 3 000 chiếc áo phông.</p>', 3, 0, 1, @t1);

-- Bài tập cuối chương VI
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài tập cuối chương VI', N'Ôn tập chương VI: hàm số y = ax² và đồ thị parabol, phương trình bậc hai, định lí Viète và giải bài toán bằng cách lập phương trình.', N'<p><b>Tóm tắt kiến thức chương VI.</b></p>
<ul>
<li>Hàm số $y=ax^2$ ($a\neq0$) xác định với mọi $x\in\mathbb{R}$; đồ thị là parabol đỉnh $O$, trục đối xứng $Oy$, nằm phía trên trục hoành nếu $a\gt0$ và phía dưới trục hoành nếu $a\lt0$.</li>
<li>Phương trình bậc hai $ax^2+bx+c=0$ ($a\neq0$): $\Delta=b^2-4ac$; $\Delta\gt0$ có hai nghiệm phân biệt $x_{1,2}=\dfrac{-b\pm\sqrt{\Delta}}{2a}$, $\Delta=0$ có nghiệm kép $-\dfrac{b}{2a}$, $\Delta\lt0$ vô nghiệm. Có thể dùng công thức nghiệm thu gọn khi $b=2b''$.</li>
<li>Định lí Viète: $x_1+x_2=-\dfrac{b}{a}$, $x_1x_2=\dfrac{c}{a}$. Nếu $a+b+c=0$ thì $x_1=1,\ x_2=\dfrac{c}{a}$; nếu $a-b+c=0$ thì $x_1=-1,\ x_2=-\dfrac{c}{a}$. Hai số có tổng $S$ và tích $P$ là nghiệm của $x^2-Sx+P=0$ (điều kiện $S^2-4P\ge0$).</li>
<li>Giải bài toán bằng cách lập phương trình: chọn ẩn và đặt điều kiện, lập phương trình, giải, đối chiếu điều kiện rồi kết luận.</li>
</ul>', 7, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 6.39.</b> Điểm nào sau đây thuộc đồ thị của hàm số $y=\dfrac{1}{2}x^2$ ?</p>', N'<p>Thay vào $y=\dfrac{1}{2}x^2$: với $x=1$ thì $y=\dfrac{1}{2}$ nên điểm $\left(1;\dfrac{1}{2}\right)$ thuộc đồ thị. Các điểm còn lại: $(1;2)$ sai; $(2;1)$ cho $y=2\neq1$; $(-1;2)$ cho $y=\dfrac{1}{2}\neq2$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$(1;2)$.', 0),
(@q, 'B', N'$(2;1)$.', 0),
(@q, 'C', N'$(-1;2)$.', 0),
(@q, 'D', N'$\left(1;\dfrac{1}{2}\right)$.', 1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 6.40.</b> Hình 6.11 là hai đường parabol trong mặt phẳng tọa độ $Oxy$: parabol $y=ax^2$ nằm phía trên trục hoành và parabol $y=bx^2$ nằm phía dưới trục hoành. Khẳng định nào sau đây là đúng?</p>
<div><img src="/static/img/sgk9/sgk9-c6-hinh-6-11.png" alt="Hình 6.11 (SGK Toán 9)"></div>', N'<p>Parabol $y=ax^2$ nằm phía trên trục hoành nên $a\gt0$; parabol $y=bx^2$ nằm phía dưới trục hoành nên $b\lt0$. Vậy $a\gt0\gt b$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$a\lt0\lt b$.', 0),
(@q, 'B', N'$a\lt b\lt0$.', 0),
(@q, 'C', N'$a\gt b\gt0$.', 0),
(@q, 'D', N'$a\gt0\gt b$.', 1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 6.41.</b> Các nghiệm của phương trình $x^2+7x+12=0$ là</p>', N'<p>$x^2+7x+12=(x+3)(x+4)=0$ nên $x=-3$ hoặc $x=-4$. (Kiểm tra bằng định lí Viète: tổng $-7$, tích $12$.)</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$x_1=3;\ x_2=4$.', 0),
(@q, 'B', N'$x_1=-3;\ x_2=-4$.', 1),
(@q, 'C', N'$x_1=3;\ x_2=-4$.', 0),
(@q, 'D', N'$x_1=-3;\ x_2=4$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 6.42.</b> Phương trình bậc hai có hai nghiệm $x_1=13$ và $x_2=25$ là</p>', N'<p>Tổng hai nghiệm $S=38$, tích $P=13\cdot25=325$ nên hai số là nghiệm của $x^2-38x+325=0$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$x^2-13x+25=0$.', 0),
(@q, 'B', N'$x^2-25x+13=0$.', 0),
(@q, 'C', N'$x^2-38x+325=0$.', 1),
(@q, 'D', N'$x^2+38x+325=0$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 6.43.</b> Gọi $x_1,x_2$ là hai nghiệm của phương trình $x^2-5x+6=0$. Khi đó, giá trị của biểu thức $A=x_1^2+x_2^2$ là</p>', N'<p>Theo định lí Viète $x_1+x_2=5$, $x_1x_2=6$ nên $A=(x_1+x_2)^2-2x_1x_2=25-12=13$. (Hoặc giải trực tiếp: $x=2$ và $x=3$, $A=4+9=13$.)</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$13$.', 1),
(@q, 'B', N'$19$.', 0),
(@q, 'C', N'$25$.', 0),
(@q, 'D', N'$5$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 6.44.</b> Chiều dài và chiều rộng của hình chữ nhật có chu vi 20 cm và diện tích 24 cm² là</p>', N'<p>Nửa chu vi là 10 cm nên chiều dài và chiều rộng có tổng 10 và tích 24: là nghiệm của $x^2-10x+24=0$, tức $x=6$ và $x=4$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'5 cm và 4 cm.', 0),
(@q, 'B', N'6 cm và 4 cm.', 1),
(@q, 'C', N'8 cm và 3 cm.', 0),
(@q, 'D', N'10 cm và 2 cm.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.45.</b> Vẽ đồ thị của các hàm số $y=\dfrac{5}{2}x^2$ và $y=-\dfrac{5}{2}x^2$ trên cùng một mặt phẳng tọa độ.</p>', N'<p>Lập bảng giá trị:</p>
<table border="1"><tr><th>$x$</th><td>$-2$</td><td>$-1$</td><td>$0$</td><td>$1$</td><td>$2$</td></tr><tr><th>$y=\dfrac{5}{2}x^2$</th><td>$10$</td><td>$\dfrac{5}{2}$</td><td>$0$</td><td>$\dfrac{5}{2}$</td><td>$10$</td></tr><tr><th>$y=-\dfrac{5}{2}x^2$</th><td>$-10$</td><td>$-\dfrac{5}{2}$</td><td>$0$</td><td>$-\dfrac{5}{2}$</td><td>$-10$</td></tr></table>
<p>Biểu diễn các điểm rồi nối lại: đồ thị $y=\dfrac{5}{2}x^2$ là parabol mở lên trên, đồ thị $y=-\dfrac{5}{2}x^2$ là parabol mở xuống dưới; hai parabol cùng đỉnh $O$, cùng nhận $Oy$ làm trục đối xứng và đối xứng với nhau qua trục hoành $Ox$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.46.</b> Cho hàm số $y=ax^2$. Xác định hệ số $a$, biết đồ thị hàm số đi qua điểm $A(3;3)$. Vẽ đồ thị của hàm số trong trường hợp đó.</p>', N'<p>Vì đồ thị đi qua $A(3;3)$ nên $3=a\cdot3^2$, suy ra $a=\dfrac{1}{3}$.</p>
<p>Đồ thị $y=\dfrac{1}{3}x^2$: bảng giá trị</p>
<table border="1"><tr><th>$x$</th><td>$-3$</td><td>$-1$</td><td>$0$</td><td>$1$</td><td>$3$</td></tr><tr><th>$y$</th><td>$3$</td><td>$\dfrac{1}{3}$</td><td>$0$</td><td>$\dfrac{1}{3}$</td><td>$3$</td></tr></table>
<p>Biểu diễn các điểm $(-3;3),\left(-1;\dfrac{1}{3}\right),(0;0),\left(1;\dfrac{1}{3}\right),(3;3)$ rồi nối lại được parabol đỉnh $O$, mở lên trên.</p>
<p><b>Đáp số:</b> $a=\dfrac{1}{3}$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.47.</b> Giải các phương trình sau:</p>
<ol type="a">
<li>$5x^2-6\sqrt{5}x+2=0$;</li>
<li>$2x^2-2\sqrt{6}x+3=0$.</li>
</ol>', N'<p><b>a)</b> $b''=-3\sqrt{5}$, $\Delta''=45-10=35\gt0$: $x=\dfrac{3\sqrt{5}\pm\sqrt{35}}{5}$.</p>
<p><b>b)</b> $b''=-\sqrt{6}$, $\Delta''=6-6=0$: nghiệm kép $x=\dfrac{\sqrt{6}}{2}$.</p>
<p><b>Đáp số:</b> a) $x=\dfrac{3\sqrt{5}\pm\sqrt{35}}{5}$. b) $x=\dfrac{\sqrt{6}}{2}$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.48.</b> Cho phương trình $x^2-11x+30=0$. Gọi $x_1,x_2$ là hai nghiệm của phương trình. Không giải phương trình, hãy tính:</p>
<ol type="a">
<li>$x_1^2+x_2^2$;</li>
<li>$x_1^3+x_2^3$.</li>
</ol>', N'<p>$\Delta=121-120=1\gt0$ nên phương trình có hai nghiệm; theo định lí Viète $x_1+x_2=11$, $x_1x_2=30$.</p>
<p><b>a)</b> $x_1^2+x_2^2=(x_1+x_2)^2-2x_1x_2=121-60=61$.</p>
<p><b>b)</b> $x_1^3+x_2^3=(x_1+x_2)^3-3x_1x_2(x_1+x_2)=1331-3\cdot30\cdot11=1331-990=341$.</p>
<p>Kiểm tra: hai nghiệm là $5$ và $6$: $25+36=61$; $125+216=341$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.49.</b> Tìm hai số $u$ và $v$, biết:</p>
<ol type="a">
<li>$u+v=13$ và $uv=40$;</li>
<li>$u-v=4$ và $uv=77$.</li>
</ol>', N'<p><b>a)</b> $u,v$ là hai nghiệm của $x^2-13x+40=0$; $\Delta=169-160=9$: $x=\dfrac{13\pm3}{2}$, tức $8$ và $5$. Vậy $(u;v)=(8;5)$ hoặc $(5;8)$.</p>
<p><b>b)</b> Đặt $w=-v$: khi đó $u+w=4$ và $uw=-77$ nên $u,w$ là hai nghiệm của $x^2-4x-77=0$. $\Delta''=4+77=81$: $x=2\pm9$, tức $11$ và $-7$.</p>
<p>Với $u=11,\ w=-7$ thì $v=7$; với $u=-7,\ w=11$ thì $v=-11$.</p>
<p><b>Đáp số:</b> a) $(8;5)$, $(5;8)$. b) $(11;7)$, $(-7;-11)$.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.50.</b> Các kĩ sư đảm bảo an toàn của đường cao tốc thường sử dụng công thức $d=0{,}05v^2+1{,}1v$ để ước tính khoảng cách an toàn tối thiểu $d$ (feet) (tức là độ dài quãng đường mà xe đi được kể từ khi đạp phanh đến khi xe dừng lại) đối với một phương tiện di chuyển với tốc độ $v$ (dặm/giờ). Giả sử giới hạn tốc độ trên một đường cao tốc nào đó là 70 dặm/giờ. Nếu một ô tô có thể dừng lại sau 300 feet kể từ khi đạp phanh thì ô tô đó có chạy nhanh hơn giới hạn tốc độ của đường cao tốc này không?</p>', N'<p>Giải $0{,}05v^2+1{,}1v=300$ với $v\gt0$: nhân hai vế với 20 được $v^2+22v-6000=0$.</p>
<p>$\Delta''=121+6000=6121$, $\sqrt{\Delta''}\approx78{,}24$: $v=-11+78{,}24\approx67{,}24$ (thỏa mãn) hoặc $v\approx-89{,}24$ (loại).</p>
<p>Vì $67{,}24\lt70$ nên ô tô không chạy nhanh hơn giới hạn tốc độ. (Kiểm tra: tại $v=70$ thì $d=0{,}05\cdot4900+77=322\gt300$.)</p>
<p><b>Đáp số:</b> ô tô chạy với tốc độ khoảng 67,2 dặm/giờ, không vượt quá giới hạn 70 dặm/giờ.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.51.</b> Bác Hương gửi tiết kiệm ngân hàng 100 triệu đồng với kì hạn 12 tháng. Sau một năm, do chưa có nhu cầu sử dụng nên bác chưa rút sổ tiết kiệm này ra mà gửi tiếp và gửi thêm một sổ tiết kiệm mới với số tiền 50 triệu đồng, cũng với kì hạn 12 tháng. Sau hai năm (kể từ khi gửi lần đầu), bác Hương nhận được số tiền cả vốn lẫn lãi là 176 triệu đồng. Tính lãi suất năm của hình thức gửi tiết kiệm này (giả sử lãi suất không đổi trong suốt quá trình gửi).</p>', N'<p>Gọi $x$ là lãi suất năm (số thập phân, $x\gt0$). Sau năm thứ nhất, sổ thứ nhất có $100(1+x)$ triệu đồng. Gửi thêm 50 triệu thì tổng tiền gửi trong năm thứ hai là $100(1+x)+50$.</p>
<p>Sau năm thứ hai: $\left[100(1+x)+50\right](1+x)=176$. Đặt $t=1+x\gt1$: $100t^2+50t-176=0$ hay $50t^2+25t-88=0$.</p>
<p>$\Delta=625+17600=18225$, $\sqrt{\Delta}=135$: $t=\dfrac{-25+135}{100}=1{,}1$ (thỏa mãn) hoặc $t=\dfrac{-25-135}{100}\lt0$ (loại). Suy ra $x=0{,}1$.</p>
<p>Kiểm tra: $(110+50)\cdot1{,}1=176$.</p>
<p><b>Đáp số:</b> lãi suất 10%/năm.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 6.52.</b> Hai khối học sinh lớp 8 và lớp 9 của một trường trung học cơ sở tham gia lao động. Nếu làm chung thì sẽ hoàn thành công việc sau 1 giờ 12 phút. Nếu mỗi khối lớp làm riêng thì khối lớp 9 làm xong nhanh hơn khối lớp 8 là 1 giờ. Hỏi nếu mỗi khối lớp làm riêng thì sau bao lâu sẽ hoàn thành công việc?</p>', N'<p>Đổi 1 giờ 12 phút $=\dfrac{6}{5}$ giờ. Gọi $x$ (giờ) là thời gian khối lớp 9 làm một mình xong công việc ($x\gt0$); khối lớp 8 làm một mình xong trong $x+1$ giờ.</p>
<p>Mỗi giờ hai khối làm chung được $\dfrac{5}{6}$ công việc: $\dfrac{1}{x}+\dfrac{1}{x+1}=\dfrac{5}{6}$. Khử mẫu: $6(x+1)+6x=5x(x+1)$ hay $5x^2-7x-6=0$.</p>
<p>$\Delta=49+120=169$, $\sqrt{\Delta}=13$: $x=\dfrac{7+13}{10}=2$ (thỏa mãn) hoặc $x=\dfrac{7-13}{10}=-\dfrac{3}{5}$ (loại).</p>
<p>Kiểm tra: $\dfrac{1}{2}+\dfrac{1}{3}=\dfrac{5}{6}$.</p>
<p><b>Đáp số:</b> khối lớp 9 làm một mình trong 2 giờ, khối lớp 8 làm một mình trong 3 giờ.</p>', 3, 0, 1, @t1);

-- ---------------------------------------------------------------------------------------------------------------------
-- Chương VII. Tần số và tần số tương đối
-- ---------------------------------------------------------------------------------------------------------------------
INSERT INTO Topics (TopicName, [Description], TeacherId, OrderIndex, IsActive) VALUES (N'Chương VII. Tần số và tần số tương đối', N'Bảng tần số, biểu đồ tần số, bảng tần số tương đối, biểu đồ tần số tương đối, bảng tần số và tần số tương đối ghép nhóm cùng các biểu đồ tương ứng. (SGK Toán 9 Kết nối tri thức với cuộc sống, Tập 2)', @t1, 7, 1);
SET @tp = SCOPE_IDENTITY();

-- Bài 22
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 22. Bảng tần số và biểu đồ tần số', N'Mẫu dữ liệu, cỡ mẫu, tần số của một giá trị, bảng tần số; biểu đồ tần số dạng cột và dạng đoạn thẳng.', N'<p><b>1. Bảng tần số.</b> Dãy dữ liệu thu được trong khảo sát là một phần của dữ liệu cần tìm hiểu, gọi là <b>mẫu dữ liệu</b>. Số giá trị của mẫu dữ liệu gọi là <b>cỡ mẫu</b>.</p>
<ul>
<li><b>Tần số</b> của một giá trị là số lần xuất hiện giá trị đó trong mẫu dữ liệu.</li>
<li><b>Bảng tần số</b> là bảng thống kê cho biết tần số của các giá trị trong mẫu dữ liệu, có dạng:
<table border="1"><tr><th>Giá trị</th><td>$x_1$</td><td>$x_2$</td><td>$\dots$</td><td>$x_k$</td></tr><tr><th>Tần số</th><td>$m_1$</td><td>$m_2$</td><td>$\dots$</td><td>$m_k$</td></tr></table>
trong đó $m_1$ là tần số của $x_1$, $m_2$ là tần số của $x_2$, $\dots$, $m_k$ là tần số của $x_k$.</li>
</ul>
<p><b>Chú ý.</b> Trong bảng tần số ta chỉ liệt kê các giá trị $x_i$ khác nhau; các giá trị này có thể không là số. Người ta còn cho bảng tần số ở dạng cột (cột thứ nhất ghi các giá trị, cột thứ hai ghi tần số).</p>
<p><b>Ví dụ 1.</b> Cỡ giày của các bạn nam trong lớp: 40, 36, 37, 36, 40, 38, 39, 36, 37, 36, 40, 39, 36, 38, 37, 38, 38, 37, 38, 38, 38, 36. Bảng tần số:</p>
<table border="1"><tr><th>Cỡ giày</th><td>36</td><td>37</td><td>38</td><td>39</td><td>40</td></tr><tr><th>Tần số</th><td>5</td><td>4</td><td>8</td><td>2</td><td>3</td></tr></table>
<p>Giày cỡ 38 phù hợp với nhiều bạn nam trong lớp nhất (tần số lớn nhất).</p>
<p><b>2. Biểu đồ tần số.</b> Biểu đồ biểu diễn bảng tần số gọi là <b>biểu đồ tần số</b>. Thường gặp là biểu đồ tần số dạng cột và biểu đồ tần số dạng đoạn thẳng (còn gọi là đa giác tần số).</p>
<ul>
<li>Biểu đồ tần số dạng cột chính là biểu đồ cột với trục đứng biểu diễn tần số.</li>
<li><b>Vẽ biểu đồ tần số dạng đoạn thẳng:</b> <i>Bước 1.</i> Vẽ trục ngang biểu diễn các giá trị của dãy dữ liệu, trục đứng thể hiện tần số. <i>Bước 2.</i> Với mỗi giá trị trên trục ngang và tần số tương ứng, xác định một điểm rồi nối các điểm liên tiếp với nhau. <i>Bước 3.</i> Ghi chú giải cho các trục, các điểm và tiêu đề của biểu đồ.</li>
</ul>
<p><b>Ví dụ 2.</b> Số anh, chị, em ruột của các bạn trong lớp:</p>
<table border="1"><tr><th>Số anh, chị, em ruột</th><td>0</td><td>1</td><td>2</td><td>3</td></tr><tr><th>Số bạn</th><td>8</td><td>19</td><td>6</td><td>4</td></tr></table>
<p>Biểu đồ dạng cột gồm bốn cột cao 8, 19, 6, 4. Biểu đồ dạng đoạn thẳng đi qua các điểm $(0;8)$, $(1;19)$, $(2;6)$, $(3;4)$ nối liên tiếp với nhau.</p>', 1, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 7.1.</b> Một nhóm học sinh đã khảo sát ý kiến về ý thức giữ gìn vệ sinh công cộng của các bạn trong trường với các mức đánh giá Tốt, Khá, Trung bình, Kém và thu được kết quả như sau:</p>
<p>Tốt, Trung bình, Tốt, Trung bình, Khá, Tốt, Khá, Tốt, Tốt, Khá, Trung bình, Kém, Khá, Tốt, Khá, Tốt, Trung bình, Khá, Tốt, Tốt, Khá, Kém, Trung bình, Tốt, Khá, Tốt, Khá, Tốt, Khá, Khá.</p>
<ol type="a">
<li>Lập bảng tần số cho dãy dữ liệu trên.</li>
<li>Từ bảng tần số, hãy cho biết mức đánh giá nào chiếm ưu thế nhất. Vì sao?</li>
</ol>', N'<p><b>a)</b> Dãy dữ liệu có 30 giá trị. Đếm số lần xuất hiện: Tốt 12 lần, Khá 11 lần, Trung bình 5 lần, Kém 2 lần (tổng $12+11+5+2=30$). Bảng tần số:</p>
<table border="1"><tr><th>Mức đánh giá</th><td>Tốt</td><td>Khá</td><td>Trung bình</td><td>Kém</td></tr><tr><th>Tần số</th><td>12</td><td>11</td><td>5</td><td>2</td></tr></table>
<p><b>b)</b> Mức "Tốt" có tần số lớn nhất (12) nên chiếm ưu thế nhất, vì nó xuất hiện nhiều lần nhất trong mẫu dữ liệu.</p>
<p><b>Đáp số:</b> bảng tần số như trên; mức "Tốt" chiếm ưu thế nhất.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 7.2.</b> Cho biểu đồ tranh biểu diễn số lượng học sinh trong lớp đăng kí tham gia các câu lạc bộ của trường như sau (mỗi biểu tượng người biểu diễn cho 1 học sinh):</p>
<div><img src="/static/img/sgk9/sgk9-c7-bt7-2-bieu-do-tranh.png" alt="Biểu đồ tranh số học sinh đăng kí các câu lạc bộ (SGK, bài 7.2)"></div>
<p>Lập bảng tần số cho dữ liệu được biểu diễn trong biểu đồ tranh trên.</p>', N'<p>Đếm số biểu tượng ở mỗi hàng: câu lạc bộ võ thuật có 6 biểu tượng, câu lạc bộ tiếng Anh có 9 biểu tượng, câu lạc bộ nghệ thuật có 5 biểu tượng. Vì mỗi biểu tượng biểu diễn 1 học sinh nên bảng tần số là:</p>
<table border="1"><tr><th>Câu lạc bộ</th><td>Võ thuật</td><td>Tiếng Anh</td><td>Nghệ thuật</td></tr><tr><th>Số học sinh</th><td>6</td><td>9</td><td>5</td></tr></table>
<p><b>Đáp số:</b> 6, 9 và 5 học sinh (tổng 20 học sinh).</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 7.3.</b> Biểu đồ Hình 7.7 (bên trái) cho biết số ngày sử dụng phương tiện đến trường của bạn Mai trong tháng Chín. Lập bảng tần số cho dữ liệu được biểu diễn trên biểu đồ.</p>
<div><img src="/static/img/sgk9/sgk9-c7-hinh-7-7-7-8.png" alt="Hình 7.7 (phương tiện đến trường của Mai) và Hình 7.8 (số lượng các loại ô tô)"></div>', N'<p>Đọc chiều cao các cột: xe buýt 9 ngày, xe máy 5 ngày, xe đạp 8 ngày. Bảng tần số:</p>
<table border="1"><tr><th>Phương tiện</th><td>Xe buýt</td><td>Xe máy</td><td>Xe đạp</td></tr><tr><th>Số ngày</th><td>9</td><td>5</td><td>8</td></tr></table>
<p><b>Đáp số:</b> 9, 5, 8 ngày (tổng 22 ngày).</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 7.4.</b> Người ta thống kê các loại ô tô chạy qua một trạm thu phí trong 1 giờ và vẽ được biểu đồ tần số như Hình 7.8 (biểu đồ bên phải trong hình dưới).</p>
<div><img src="/static/img/sgk9/sgk9-c7-hinh-7-7-7-8.png" alt="Hình 7.7 (phương tiện đến trường của Mai) và Hình 7.8 (số lượng các loại ô tô)"></div>
<ol type="a">
<li>Lập bảng tần số cho dữ liệu được biểu diễn trên biểu đồ.</li>
<li>Từ bảng tần số, hãy cho biết loại xe nào đi qua trạm thu phí nhiều nhất.</li>
</ol>', N'<p><b>a)</b> Đọc các điểm của biểu đồ đoạn thẳng: xe 4 chỗ có 9 xe, xe 7 chỗ có 14 xe, xe 9 chỗ có 5 xe, xe 16 chỗ trở lên có 3 xe. Bảng tần số:</p>
<table border="1"><tr><th>Loại xe</th><td>Xe 4 chỗ</td><td>Xe 7 chỗ</td><td>Xe 9 chỗ</td><td>Xe 16 chỗ trở lên</td></tr><tr><th>Số xe</th><td>9</td><td>14</td><td>5</td><td>3</td></tr></table>
<p><b>b)</b> Xe 7 chỗ có tần số lớn nhất (14) nên đi qua trạm thu phí nhiều nhất.</p>
<p><b>Đáp số:</b> b) xe 7 chỗ.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 7.5.</b> Bảng thống kê sau cho biết số lượng các thiên tai xảy ra tại Việt Nam giai đoạn 1990 – 2021.</p>
<table border="1"><tr><th>Loại thiên tai</th><td>Hạn hán</td><td>Bệnh dịch</td><td>Lũ lụt</td><td>Sạt lở đất</td><td>Bão</td></tr><tr><th>Số lượng</th><td>6</td><td>9</td><td>71</td><td>6</td><td>94</td></tr></table>
<p>Vẽ biểu đồ tần số dạng cột và biểu đồ tần số dạng đoạn thẳng biểu diễn bảng thống kê trên.</p>', N'<p><b>Biểu đồ dạng cột.</b> Vẽ trục ngang ghi 5 loại thiên tai, trục đứng ghi tần số (chia vạch đến 100). Dựng 5 cột có chiều cao lần lượt: Hạn hán 6; Bệnh dịch 9; Lũ lụt 71; Sạt lở đất 6; Bão 94. Ghi tiêu đề "Số lượng thiên tai tại Việt Nam giai đoạn 1990 – 2021" và chú giải các trục.</p>
<p><b>Biểu đồ dạng đoạn thẳng.</b> Trên trục ngang đặt 5 loại thiên tai, xác định các điểm Hạn hán $(1;6)$, Bệnh dịch $(2;9)$, Lũ lụt $(3;71)$, Sạt lở đất $(4;6)$, Bão $(5;94)$ (hoành độ chỉ là thứ tự các loại) rồi nối các điểm liên tiếp bằng các đoạn thẳng; ghi tần số cạnh mỗi điểm và tiêu đề biểu đồ.</p>
<p><b>Nhận xét.</b> Bão (94) và lũ lụt (71) là hai loại thiên tai xảy ra nhiều nhất.</p>', 2, 0, 1, @t1);

-- Bài 23
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 23. Bảng tần số tương đối và biểu đồ tần số tương đối', N'Tần số tương đối, bảng tần số tương đối; biểu đồ cột và biểu đồ hình quạt tròn biểu diễn tần số tương đối.', N'<p><b>1. Bảng tần số tương đối.</b> Cho $x_1,x_2,\dots,x_k$ là các giá trị khác nhau của mẫu dữ liệu cỡ $n$. <b>Tần số tương đối</b> $f_i$ của giá trị $x_i$ là tỉ số giữa tần số $m_i$ của $x_i$ với $n$: $$f_i=\dfrac{m_i}{n}\cdot100\%,\quad n=m_1+m_2+\dots+m_k.$$ Bảng ghi các giá trị cùng tần số tương đối của chúng gọi là <b>bảng tần số tương đối</b>. Tần số tương đối còn gọi là tần suất.</p>
<p><b>Ví dụ 1.</b> Chất lượng không khí tại một địa điểm trong 30 ngày mùa xuân: M1 (Tốt) 9 ngày, M2 (Trung bình) 12 ngày, M3 (Kém) 6 ngày, M4 (Xấu) 3 ngày. Tần số tương đối: $f_1=\dfrac{9}{30}\cdot100\%=30\%$; $f_2=40\%$; $f_3=20\%$; $f_4=10\%$. Khả năng cao nhất là chất lượng không khí ở mức M2 (Trung bình).</p>
<p><b>Nhận xét.</b> Tần số tương đối của một giá trị là ước lượng cho xác suất xuất hiện giá trị đó.</p>
<p><b>2. Biểu đồ tần số tương đối.</b> Biểu đồ biểu diễn bảng tần số tương đối gọi là <b>biểu đồ tần số tương đối</b>, thường gặp là biểu đồ cột và biểu đồ hình quạt tròn.</p>
<p><b>Vẽ biểu đồ hình quạt tròn:</b></p>
<ol>
<li><i>Bước 1.</i> Xác định số đo cung của các hình quạt biểu diễn tần số tương đối: $360^\circ\cdot f_i$.</li>
<li><i>Bước 2.</i> Vẽ hình tròn và chia thành các hình quạt có số đo cung vừa tính.</li>
<li><i>Bước 3.</i> Định dạng các hình quạt (tô màu), ghi tần số tương đối, chú giải và tiêu đề.</li>
</ol>
<p><b>Ví dụ 2.</b> Loại phim yêu thích của lớp 9A: Hài 50%, Khoa học viễn tưởng 37,5%, Kinh dị 12,5%. Số đo cung: Hài $360^\circ\cdot50\%=180^\circ$; Khoa học viễn tưởng $360^\circ\cdot37{,}5\%=135^\circ$; Kinh dị $360^\circ\cdot12{,}5\%=45^\circ$.</p>', 2, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 7.6.</b> Lớp 9A có 40 bạn, trong đó 20 bạn mặc áo cỡ M, 13 bạn mặc áo cỡ S, 7 bạn mặc áo cỡ L. Hãy lập bảng tần số tương đối cho dữ liệu này.</p>', N'<p>Cỡ mẫu $n=40$. Tần số tương đối: cỡ M $\dfrac{20}{40}\cdot100\%=50\%$; cỡ S $\dfrac{13}{40}\cdot100\%=32{,}5\%$; cỡ L $\dfrac{7}{40}\cdot100\%=17{,}5\%$.</p>
<table border="1"><tr><th>Cỡ áo</th><td>M</td><td>S</td><td>L</td></tr><tr><th>Tần số tương đối</th><td>50%</td><td>32,5%</td><td>17,5%</td></tr></table>
<p><b>Đáp số:</b> 50%; 32,5%; 17,5%.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 7.7.</b> Biểu đồ tranh sau đây biểu diễn số lượng học sinh lớp 9B bình chọn phần mềm học trực tuyến được yêu thích nhất (mỗi biểu tượng người biểu diễn cho 2 học sinh):</p>
<div><img src="/static/img/sgk9/sgk9-c7-bt7-7-bieu-do-tranh.png" alt="Biểu đồ tranh bình chọn phần mềm học trực tuyến: Skype, Zoom, Google Meet (SGK, bài 7.7)"></div>
<p>Lập bảng tần số tương đối cho dữ liệu được biểu diễn trong biểu đồ tranh trên.</p>', N'<p>Đếm biểu tượng: Skype 3, Zoom 11, Google Meet 6. Mỗi biểu tượng là 2 học sinh nên số học sinh là $3\cdot2=6$, $11\cdot2=22$, $6\cdot2=12$.</p>
<p>Cỡ mẫu $n=6+22+12=40$. Tần số tương đối: Skype $\dfrac{6}{40}\cdot100\%=15\%$; Zoom $\dfrac{22}{40}\cdot100\%=55\%$; Google Meet $\dfrac{12}{40}\cdot100\%=30\%$.</p>
<table border="1"><tr><th>Phần mềm</th><td>Skype</td><td>Zoom</td><td>Google Meet</td></tr><tr><th>Tần số tương đối</th><td>15%</td><td>55%</td><td>30%</td></tr></table>
<p><b>Đáp số:</b> 15%; 55%; 30%.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 7.8.</b> Quay 150 lần một tấm bìa hình tròn được chia thành bốn hình quạt với các màu xanh, đỏ, tím, vàng. Quan sát mũi tên chỉ vào hình quạt màu gì và ghi lại, thu được kết quả sau:</p>
<table border="1"><tr><th>Màu</th><td>Xanh</td><td>Đỏ</td><td>Tím</td><td>Vàng</td></tr><tr><th>Số lần</th><td>60</td><td>30</td><td>40</td><td>20</td></tr></table>
<ol type="a">
<li>Lập bảng tần số tương đối cho dữ liệu trên.</li>
<li>Ước lượng các xác suất mũi tên chỉ vào hình quạt màu xanh, màu vàng.</li>
<li>Vẽ biểu đồ hình quạt tròn biểu diễn bảng tần số tương đối thu được ở câu a.</li>
</ol>', N'<p><b>a)</b> Cỡ mẫu $n=150$. Tần số tương đối: xanh $\dfrac{60}{150}\cdot100\%=40\%$; đỏ $\dfrac{30}{150}\cdot100\%=20\%$; tím $\dfrac{40}{150}\cdot100\%\approx26{,}7\%$; vàng $\dfrac{20}{150}\cdot100\%\approx13{,}3\%$.</p>
<table border="1"><tr><th>Màu</th><td>Xanh</td><td>Đỏ</td><td>Tím</td><td>Vàng</td></tr><tr><th>Tần số tương đối</th><td>40%</td><td>20%</td><td>26,7%</td><td>13,3%</td></tr></table>
<p><b>b)</b> Tần số tương đối là ước lượng của xác suất nên xác suất mũi tên chỉ vào màu xanh khoảng $40\%$ (tức $0{,}4$) và màu vàng khoảng $13{,}3\%$ (tức khoảng $0{,}133$).</p>
<p><b>c)</b> Số đo cung các hình quạt: xanh $360^\circ\cdot40\%=144^\circ$; đỏ $360^\circ\cdot20\%=72^\circ$; tím $360^\circ\cdot\dfrac{40}{150}=96^\circ$; vàng $360^\circ\cdot\dfrac{20}{150}=48^\circ$ (tổng $360^\circ$). Vẽ hình tròn, chia thành bốn hình quạt có số đo cung đó, tô màu, ghi tần số tương đối, chú giải và tiêu đề.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 7.9.</b> Theo Tổng cục Thống kê, vào năm 2021 trong số 50,5 triệu lao động Việt Nam từ 15 tuổi trở lên có 13,9 triệu lao động đang làm việc trong lĩnh vực nông nghiệp, lâm nghiệp và thuỷ sản; 16,9 triệu lao động đang làm việc trong lĩnh vực công nghiệp và xây dựng; 19,7 triệu lao động đang làm việc trong lĩnh vực dịch vụ.</p>
<ol type="a">
<li>Lập bảng tần số tương đối cho dữ liệu trên.</li>
<li>Vẽ biểu đồ hình quạt tròn biểu diễn bảng tần số tương đối thu được ở câu a.</li>
<li>Tính tỉ lệ lao động không làm việc trong lĩnh vực nông nghiệp, lâm nghiệp và thuỷ sản.</li>
</ol>', N'<p><b>a)</b> Tổng ba lĩnh vực: $13{,}9+16{,}9+19{,}7=50{,}5$ (triệu), đúng bằng số lao động đã cho. Tần số tương đối: nông, lâm nghiệp và thuỷ sản $\dfrac{13{,}9}{50{,}5}\cdot100\%\approx27{,}5\%$; công nghiệp và xây dựng $\dfrac{16{,}9}{50{,}5}\cdot100\%\approx33{,}5\%$; dịch vụ $\dfrac{19{,}7}{50{,}5}\cdot100\%\approx39{,}0\%$ (tổng $100\%$).</p>
<table border="1"><tr><th>Lĩnh vực</th><td>Nông, lâm nghiệp và thuỷ sản</td><td>Công nghiệp và xây dựng</td><td>Dịch vụ</td></tr><tr><th>Tần số tương đối</th><td>27,5%</td><td>33,5%</td><td>39,0%</td></tr></table>
<p><b>b)</b> Số đo cung: $360^\circ\cdot\dfrac{13{,}9}{50{,}5}\approx99{,}1^\circ$; $360^\circ\cdot\dfrac{16{,}9}{50{,}5}\approx120{,}5^\circ$; $360^\circ\cdot\dfrac{19{,}7}{50{,}5}\approx140{,}4^\circ$ (tổng $360^\circ$). Vẽ hình tròn chia thành ba hình quạt có số đo cung trên, ghi tỉ lệ phần trăm, chú giải và tiêu đề.</p>
<p><b>c)</b> Tỉ lệ lao động không làm việc trong lĩnh vực nông, lâm nghiệp và thuỷ sản là $100\%-27{,}5\%=72{,}5\%$ (hay $\dfrac{16{,}9+19{,}7}{50{,}5}\cdot100\%\approx72{,}5\%$).</p>
<p><b>Đáp số:</b> a) 27,5%; 33,5%; 39,0%. c) khoảng 72,5%.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 7.10.</b> Bảng thống kê sau cho biết tỉ lệ tăng trưởng GDP năm 2022 theo khu vực kinh tế.</p>
<table border="1"><tr><th>Khu vực kinh tế</th><td>Nông nghiệp, lâm nghiệp và thuỷ sản</td><td>Công nghiệp và xây dựng</td><td>Dịch vụ</td></tr><tr><th>Mức tăng trưởng</th><td>3,36%</td><td>7,78%</td><td>9,99%</td></tr></table>
<p>(Theo Tổng cục Thống kê)</p>
<ol type="a">
<li>Bảng thống kê trên có là bảng tần số tương đối hay không?</li>
<li>Lựa chọn loại biểu đồ thích hợp và biểu diễn bảng thống kê trên bằng loại biểu đồ đó.</li>
</ol>', N'<p><b>a)</b> Không. Bảng tần số tương đối cho biết tỉ lệ của mỗi giá trị so với toàn bộ mẫu dữ liệu nên các tỉ lệ phải có tổng bằng $100\%$. Ở đây $3{,}36\%+7{,}78\%+9{,}99\%=21{,}13\%\neq100\%$; đây là mức tăng trưởng của từng khu vực so với năm trước, không phải phần của một tổng thể.</p>
<p><b>b)</b> Vì các số liệu không là các phần của một tổng thể nên không dùng biểu đồ hình quạt tròn. Dùng <b>biểu đồ cột</b>: trục ngang ghi ba khu vực kinh tế, trục đứng ghi mức tăng trưởng (%) chia vạch đến 10; dựng ba cột cao $3{,}36$; $7{,}78$; $9{,}99$, ghi giá trị trên đầu mỗi cột, chú giải các trục và tiêu đề "Mức tăng trưởng GDP năm 2022 theo khu vực kinh tế".</p>', 2, 0, 1, @t1);

-- Luyện tập chung (Bài 22 - Bài 23)
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Luyện tập chung (Chương VII)', N'Lập bảng tần số, bảng tần số tương đối, vẽ biểu đồ đoạn thẳng và biểu đồ hình quạt tròn từ dữ liệu thực tế.', N'<p><b>Ví dụ 1.</b> Một vận động viên bắn 30 viên đạn vào bia. Số lần được 10, 9, 8, 7 điểm tương ứng là 8, 12, 7, 3. Bảng tần số:</p>
<table border="1"><tr><th>Điểm</th><td>10</td><td>9</td><td>8</td><td>7</td></tr><tr><th>Tần số</th><td>8</td><td>12</td><td>7</td><td>3</td></tr></table>
<p>Cỡ mẫu $n=30$. Tần số tương đối: $\dfrac{8}{30}\cdot100\%\approx26{,}7\%$; $\dfrac{12}{30}\cdot100\%=40\%$; $\dfrac{7}{30}\cdot100\%\approx23{,}3\%$; $\dfrac{3}{30}\cdot100\%=10\%$.</p>
<table border="1"><tr><th>Điểm</th><td>10</td><td>9</td><td>8</td><td>7</td></tr><tr><th>Tần số tương đối</th><td>26,7%</td><td>40%</td><td>23,3%</td><td>10%</td></tr></table>
<p>Biểu đồ tần số dạng đoạn thẳng đi qua các điểm $(10;8)$, $(9;12)$, $(8;7)$, $(7;3)$.</p>
<p><b>Ví dụ 2.</b> Số lượt mượn các loại sách trong một tuần tại thư viện: sách giáo khoa 20, sách tham khảo 80, truyện ngắn 70, tiểu thuyết 30. Tổng $20+80+70+30=200$. Tần số tương đối: $10\%$; $40\%$; $35\%$; $15\%$. Số đo cung các hình quạt: $360^\circ\cdot10\%=36^\circ$; $360^\circ\cdot40\%=144^\circ$; $360^\circ\cdot35\%=126^\circ$; $360^\circ\cdot15\%=54^\circ$.</p>', 3, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 7.11.</b> Bảng thống kê sau cho biết số lượng học sinh của lớp 9B theo mức độ cận thị.</p>
<table border="1"><tr><th>Mức độ</th><td>Không cận thị</td><td>Cận thị nhẹ</td><td>Cận thị vừa</td><td>Cận thị nặng</td></tr><tr><th>Số học sinh</th><td>10</td><td>13</td><td>12</td><td>5</td></tr></table>
<ol type="a">
<li>Lập bảng tần số tương đối cho bảng thống kê trên.</li>
<li>Đa số học sinh của lớp 9B cận thị hay không cận thị?</li>
</ol>', N'<p><b>a)</b> Cỡ mẫu $n=10+13+12+5=40$. Tần số tương đối: không cận thị $\dfrac{10}{40}\cdot100\%=25\%$; cận thị nhẹ $\dfrac{13}{40}\cdot100\%=32{,}5\%$; cận thị vừa $\dfrac{12}{40}\cdot100\%=30\%$; cận thị nặng $\dfrac{5}{40}\cdot100\%=12{,}5\%$.</p>
<table border="1"><tr><th>Mức độ</th><td>Không cận thị</td><td>Cận thị nhẹ</td><td>Cận thị vừa</td><td>Cận thị nặng</td></tr><tr><th>Tần số tương đối</th><td>25%</td><td>32,5%</td><td>30%</td><td>12,5%</td></tr></table>
<p><b>b)</b> Số học sinh cận thị là $13+12+5=30$, chiếm $\dfrac{30}{40}\cdot100\%=75\%$ (hay $32{,}5\%+30\%+12{,}5\%=75\%$), lớn hơn $50\%$ nên đa số học sinh lớp 9B bị cận thị.</p>
<p><b>Đáp số:</b> b) đa số học sinh cận thị (75%).</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 7.12.</b> Tỉ lệ bình chọn các tiết mục văn nghệ của các lớp 9A, 9B, 9C, 9D tham gia hội diễn văn nghệ khối lớp 9 như sau:</p>
<table border="1"><tr><th>Lớp</th><td>9A</td><td>9B</td><td>9C</td><td>9D</td></tr><tr><th>Tỉ lệ học sinh bình chọn</th><td>35%</td><td>25%</td><td>30%</td><td>10%</td></tr></table>
<p>Biết rằng có 300 học sinh tham gia bình chọn. Lập bảng tần số biểu diễn số học sinh bình chọn cho tiết mục văn nghệ của mỗi lớp.</p>', N'<p>Số học sinh bình chọn cho mỗi lớp bằng tỉ lệ nhân với 300: lớp 9A $300\cdot35\%=105$; lớp 9B $300\cdot25\%=75$; lớp 9C $300\cdot30\%=90$; lớp 9D $300\cdot10\%=30$ (tổng $105+75+90+30=300$).</p>
<table border="1"><tr><th>Lớp</th><td>9A</td><td>9B</td><td>9C</td><td>9D</td></tr><tr><th>Số học sinh bình chọn</th><td>105</td><td>75</td><td>90</td><td>30</td></tr></table>
<p><b>Đáp số:</b> 105; 75; 90; 30 học sinh.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 7.13.</b> Bạn Hoàng khảo sát ý kiến của các bạn trong tổ về chất lượng phục vụ của căng tin trường thu được kết quả sau:</p>
<p>A, B, C, B, A, A, B, A, B, A,</p>
<p>trong đó A là mức Tốt, B là mức Trung bình, C là mức Kém. Hãy lập bảng tần số và bảng tần số tương đối biểu diễn kết quả bạn Hoàng thu được.</p>', N'<p>Dãy có $n=10$ giá trị. Đếm: A xuất hiện 5 lần, B xuất hiện 4 lần, C xuất hiện 1 lần (tổng 10).</p>
<table border="1"><tr><th>Mức đánh giá</th><td>A (Tốt)</td><td>B (Trung bình)</td><td>C (Kém)</td></tr><tr><th>Tần số</th><td>5</td><td>4</td><td>1</td></tr></table>
<p>Tần số tương đối: A $\dfrac{5}{10}\cdot100\%=50\%$; B $\dfrac{4}{10}\cdot100\%=40\%$; C $\dfrac{1}{10}\cdot100\%=10\%$.</p>
<table border="1"><tr><th>Mức đánh giá</th><td>A (Tốt)</td><td>B (Trung bình)</td><td>C (Kém)</td></tr><tr><th>Tần số tương đối</th><td>50%</td><td>40%</td><td>10%</td></tr></table>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 7.14.</b> Biểu đồ cột Hình 7.16 cho biết cỡ giày của các bạn nam khối lớp 9 trong trường.</p>
<div><img src="/static/img/sgk9/sgk9-c7-hinh-7-16.png" alt="Hình 7.16: biểu đồ cột cỡ giày của các bạn nam khối lớp 9"></div>
<p>Lập bảng tần số và bảng tần số tương đối cho dữ liệu được biểu diễn trên biểu đồ.</p>', N'<p>Đọc chiều cao các cột: cỡ 36 có 28 bạn, cỡ 37 có 37 bạn, cỡ 38 có 30 bạn, cỡ 39 có 10 bạn, cỡ 40 có 15 bạn.</p>
<table border="1"><tr><th>Cỡ giày</th><td>36</td><td>37</td><td>38</td><td>39</td><td>40</td></tr><tr><th>Tần số</th><td>28</td><td>37</td><td>30</td><td>10</td><td>15</td></tr></table>
<p>Cỡ mẫu $n=28+37+30+10+15=120$. Tần số tương đối: cỡ 36 $\dfrac{28}{120}\cdot100\%\approx23{,}3\%$; cỡ 37 $\dfrac{37}{120}\cdot100\%\approx30{,}8\%$; cỡ 38 $\dfrac{30}{120}\cdot100\%=25\%$; cỡ 39 $\dfrac{10}{120}\cdot100\%\approx8{,}3\%$; cỡ 40 $\dfrac{15}{120}\cdot100\%=12{,}5\%$.</p>
<table border="1"><tr><th>Cỡ giày</th><td>36</td><td>37</td><td>38</td><td>39</td><td>40</td></tr><tr><th>Tần số tương đối</th><td>23,3%</td><td>30,8%</td><td>25%</td><td>8,3%</td><td>12,5%</td></tr></table>
<p><i>Chú ý:</i> do làm tròn đến một chữ số thập phân nên tổng các giá trị trên là 99,9%.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 7.15.</b> Cho bảng tần số sau:</p>
<table border="1"><tr><th>Điểm thi môn Toán</th><td>6</td><td>7</td><td>8</td><td>9</td><td>10</td></tr><tr><th>Số học sinh</th><td>5</td><td>8</td><td>12</td><td>10</td><td>4</td></tr></table>
<p>Vẽ biểu đồ tần số dạng đoạn thẳng cho bảng tần số trên.</p>', N'<p>Vẽ trục ngang biểu diễn điểm thi (6, 7, 8, 9, 10), trục đứng biểu diễn số học sinh (chia vạch đến 14). Xác định các điểm $(6;5)$, $(7;8)$, $(8;12)$, $(9;10)$, $(10;4)$ rồi nối các điểm liên tiếp bằng các đoạn thẳng.</p>
<p>Ghi chú giải cho các trục ("Điểm", "Số học sinh"), ghi tần số cạnh mỗi điểm và tiêu đề "Điểm thi môn Toán". Đường gấp khúc tăng dần đến điểm cao nhất tại điểm 8 (12 học sinh) rồi giảm.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 7.16.</b> Theo dõi thời tiết tại một điểm du lịch trong 30 ngày người ta thu được bảng sau:</p>
<table border="1"><tr><th>Thời tiết</th><td>Không mưa</td><td>Mưa nhỏ</td><td>Mưa to</td></tr><tr><th>Số ngày</th><td>10</td><td>8</td><td>12</td></tr></table>
<ol type="a">
<li>Lập bảng tần số tương đối và vẽ biểu đồ hình quạt tròn biểu diễn bảng tần số tương đối thu được.</li>
<li>Ước lượng xác suất để một ngày trời có mưa ở điểm du lịch này.</li>
</ol>', N'<p><b>a)</b> Cỡ mẫu $n=30$. Tần số tương đối: không mưa $\dfrac{10}{30}\cdot100\%\approx33{,}3\%$; mưa nhỏ $\dfrac{8}{30}\cdot100\%\approx26{,}7\%$; mưa to $\dfrac{12}{30}\cdot100\%=40\%$.</p>
<table border="1"><tr><th>Thời tiết</th><td>Không mưa</td><td>Mưa nhỏ</td><td>Mưa to</td></tr><tr><th>Tần số tương đối</th><td>33,3%</td><td>26,7%</td><td>40%</td></tr></table>
<p>Số đo cung: không mưa $360^\circ\cdot\dfrac{10}{30}=120^\circ$; mưa nhỏ $360^\circ\cdot\dfrac{8}{30}=96^\circ$; mưa to $360^\circ\cdot\dfrac{12}{30}=144^\circ$ (tổng $360^\circ$). Vẽ hình tròn chia thành ba hình quạt có số đo cung đó, ghi tỉ lệ phần trăm, chú giải và tiêu đề.</p>
<p><b>b)</b> Số ngày có mưa là $8+12=20$ ngày nên tần số tương đối của ngày có mưa là $\dfrac{20}{30}\cdot100\%\approx66{,}7\%$ (hay $26{,}7\%+40\%$). Do đó xác suất để một ngày có mưa ở điểm du lịch này khoảng $66{,}7\%$ (tức khoảng $\dfrac{2}{3}$).</p>
<p><b>Đáp số:</b> b) khoảng 66,7%.</p>', 2, 0, 1, @t1);

-- Bài 24
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 24. Bảng tần số, tần số tương đối ghép nhóm và biểu đồ', N'Bảng tần số và tần số tương đối ghép nhóm; biểu đồ tần số tương đối ghép nhóm dạng cột và dạng đoạn thẳng.', N'<p><b>1. Bảng tần số, tần số tương đối ghép nhóm.</b> Khi khó biết giá trị chính xác của số liệu mà chỉ biết nó thuộc một nhóm số liệu nào đó, ta dùng các nhóm dạng $[a;b)$, trong đó $a$ là đầu mút trái, $b$ là đầu mút phải; nhóm $[a;b)$ gồm các số liệu lớn hơn hoặc bằng $a$ và nhỏ hơn $b$.</p>
<ul>
<li><b>Bảng tần số ghép nhóm</b> là bảng tần số của các nhóm số liệu $[a_1;a_2),[a_2;a_3),\dots,[a_k;a_{k+1})$ với tần số $m_1,m_2,\dots,m_k$. Tần số $m_i$ của nhóm $[a_i;a_{i+1})$ là số giá trị của mẫu số liệu lớn hơn hoặc bằng $a_i$ và nhỏ hơn $a_{i+1}$.</li>
<li><b>Bảng tần số tương đối ghép nhóm</b> là bảng tần số tương đối của các nhóm số liệu, với $n=m_1+\dots+m_k$ và $f_i=\dfrac{m_i}{n}\cdot100\%$.</li>
</ul>
<p><b>Ví dụ 1.</b> Chiều cao của 40 học sinh lớp 9C theo các nhóm $[150;158)$, $[158;161)$, $[161;164)$, $[164;167)$ có tần số 5, 12, 15, 8. Tần số tương đối: $\dfrac{5}{40}\cdot100\%=12{,}5\%$; $\dfrac{12}{40}\cdot100\%=30\%$; $\dfrac{15}{40}\cdot100\%=37{,}5\%$; $\dfrac{8}{40}\cdot100\%=20\%$.</p>
<p><b>2. Biểu đồ tần số tương đối ghép nhóm dạng cột</b> (còn gọi là tổ chức đồ) gồm các cột liền nhau biểu diễn bảng tần số tương đối ghép nhóm có các nhóm số liệu độ dài bằng nhau. Cách vẽ: <i>Bước 1.</i> Vẽ trục đứng (đơn vị là các tần số tương đối) và trục ngang (các nhóm số liệu). <i>Bước 2.</i> Dựng các cột kề nhau, mỗi cột có chiều cao bằng tần số tương đối của nhóm. <i>Bước 3.</i> Ghi chú giải các trục, các cột và tiêu đề. Nếu chiều cao mỗi cột biểu diễn tần số thì ta được biểu đồ tần số ghép nhóm dạng cột.</p>
<p><b>3. Biểu đồ tần số tương đối ghép nhóm dạng đoạn thẳng.</b></p>
<ol>
<li><i>Bước 1.</i> Chọn giá trị đại diện $x_i=\dfrac{a_i+a_{i+1}}{2}$ cho nhóm $[a_i;a_{i+1})$.</li>
<li><i>Bước 2.</i> Vẽ trục ngang biểu diễn các giá trị đại diện, trục đứng thể hiện tần số tương đối.</li>
<li><i>Bước 3.</i> Với mỗi giá trị đại diện $x_i$ và tần số tương đối $f_i$, xác định điểm $M_i(x_i;f_i)$ và nối các điểm liên tiếp với nhau.</li>
<li><i>Bước 4.</i> Ghi chú giải cho các trục, các điểm và tiêu đề.</li>
</ol>
<p><b>Ví dụ 2.</b> Tuổi thọ bóng đèn theo các nhóm $[1;1{,}5)$, $[1{,}5;2)$, $[2;2{,}5)$, $[2{,}5;3)$, $[3;3{,}5)$ có tần số tương đối 15%, 20%, 30%, 25%, 10%. Giá trị đại diện: $1{,}25$; $1{,}75$; $2{,}25$; $2{,}75$; $3{,}25$. Biểu đồ đoạn thẳng đi qua các điểm $(1{,}25;15)$, $(1{,}75;20)$, $(2{,}25;30)$, $(2{,}75;25)$, $(3{,}25;10)$.</p>
<p><b>Em có biết.</b> Với nhóm $[a_i;a_{i+1})$ có độ dài $l_i=a_{i+1}-a_i$ không bằng nhau, ta dựng các cột có đáy bằng $l_i$ và chiều cao $y_i=\dfrac{f_i}{l_i}$, khi đó diện tích mỗi cột chính bằng tần số tương đối của nhóm.</p>', 4, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 7.17.</b> Một cuộc điều tra về thời gian dùng mạng Internet trong ngày của học sinh lớp 9 tại một thành phố cho kết quả như sau:</p>
<table border="1"><tr><th>Thời gian (giờ)</th><td>$[0;0{,}5)$</td><td>$[0{,}5;1{,}0)$</td><td>$[1{,}0;1{,}5)$</td><td>$[1{,}5;2{,}0)$</td><td>$[2{,}0;2{,}5)$</td></tr><tr><th>Tỉ lệ</th><td>15%</td><td>27%</td><td>23%</td><td>18%</td><td>17%</td></tr></table>
<ol type="a">
<li>Đọc và giải thích bảng thống kê trên.</li>
<li>Để thu được bảng thống kê trên, người ta đã lập phiếu điều tra và thu về tổng cộng 2 000 phiếu trả lời. Lập bảng tần số ghép nhóm cho kết quả thu được.</li>
</ol>', N'<p><b>a)</b> Đây là bảng tần số tương đối ghép nhóm (tổng các tỉ lệ $15+27+23+18+17=100\%$). Chẳng hạn nhóm $[0{,}5;1{,}0)$ với tỉ lệ $27\%$ nghĩa là có $27\%$ số học sinh được hỏi dùng Internet từ 0,5 giờ đến dưới 1 giờ trong ngày.</p>
<p><b>b)</b> Tần số của mỗi nhóm bằng tỉ lệ nhân với 2 000: $2000\cdot15\%=300$; $2000\cdot27\%=540$; $2000\cdot23\%=460$; $2000\cdot18\%=360$; $2000\cdot17\%=340$ (tổng $2000$).</p>
<table border="1"><tr><th>Thời gian (giờ)</th><td>$[0;0{,}5)$</td><td>$[0{,}5;1{,}0)$</td><td>$[1{,}0;1{,}5)$</td><td>$[1{,}5;2{,}0)$</td><td>$[2{,}0;2{,}5)$</td></tr><tr><th>Tần số</th><td>300</td><td>540</td><td>460</td><td>360</td><td>340</td></tr></table>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 7.18.</b> Ghi lại cấp độ động đất của các trận động đất xảy ra tại một vùng trong 10 năm người ta thu được kết quả sau:</p>
<p>I, V, II, III, VI, V, IV, II, III, V, VI, VII, VIII, I, I, II, VI, VII, IV.</p>
<p>Biết rằng theo thang Richter thì trận động đất cấp I có độ lớn từ 1 đến dưới 3; cấp II và III có độ lớn từ 3 đến dưới 4; cấp IV và V có độ lớn từ 4 đến dưới 5; cấp VI và VII có độ lớn từ 5 đến dưới 6; cấp VIII có độ lớn từ 6 đến dưới 6,9.</p>
<p>Lập bảng tần số ghép nhóm cho độ lớn các trận động đất xảy ra ở vùng này theo thang Richter.</p>', N'<p>Dãy có 19 trận. Đếm theo cấp: I có 3, II có 3, III có 2, IV có 2, V có 3, VI có 3, VII có 2, VIII có 1.</p>
<p>Ghép theo nhóm độ lớn: $[1;3)$ (cấp I): 3 trận; $[3;4)$ (cấp II và III): $3+2=5$ trận; $[4;5)$ (cấp IV và V): $2+3=5$ trận; $[5;6)$ (cấp VI và VII): $3+2=5$ trận; $[6;6{,}9)$ (cấp VIII): 1 trận (tổng $3+5+5+5+1=19$).</p>
<table border="1"><tr><th>Độ lớn (thang Richter)</th><td>$[1;3)$</td><td>$[3;4)$</td><td>$[4;5)$</td><td>$[5;6)$</td><td>$[6;6{,}9)$</td></tr><tr><th>Tần số</th><td>3</td><td>5</td><td>5</td><td>5</td><td>1</td></tr></table>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 7.19.</b> Giáo viên ghi lại thời gian chạy cự li 100 mét của các học sinh lớp 9A cho kết quả như sau:</p>
<table border="1"><tr><th>Thời gian (giây)</th><td>$[13;15)$</td><td>$[15;17)$</td><td>$[17;19)$</td><td>$[19;21)$</td></tr><tr><th>Số học sinh</th><td>5</td><td>20</td><td>13</td><td>2</td></tr></table>
<ol type="a">
<li>Nêu các nhóm số liệu và tần số tương ứng.</li>
<li>Lập bảng tần số tương đối ghép nhóm.</li>
</ol>', N'<p><b>a)</b> Các nhóm số liệu và tần số: $[13;15)$ có tần số 5; $[15;17)$ có tần số 20; $[17;19)$ có tần số 13; $[19;21)$ có tần số 2. Chẳng hạn có 20 học sinh chạy 100 m trong thời gian từ 15 giây đến dưới 17 giây.</p>
<p><b>b)</b> Cỡ mẫu $n=5+20+13+2=40$. Tần số tương đối: $\dfrac{5}{40}\cdot100\%=12{,}5\%$; $\dfrac{20}{40}\cdot100\%=50\%$; $\dfrac{13}{40}\cdot100\%=32{,}5\%$; $\dfrac{2}{40}\cdot100\%=5\%$.</p>
<table border="1"><tr><th>Thời gian (giây)</th><td>$[13;15)$</td><td>$[15;17)$</td><td>$[17;19)$</td><td>$[19;21)$</td></tr><tr><th>Tần số tương đối</th><td>12,5%</td><td>50%</td><td>32,5%</td><td>5%</td></tr></table>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 7.20.</b> Người ta trồng cà rốt và thử nghiệm một loại phân bón mới. Khi thu hoạch người ta đo chiều dài các củ cà rốt thu được kết quả sau:</p>
<table border="1"><tr><th>Chiều dài (cm)</th><td>$[15;16)$</td><td>$[16;17)$</td><td>$[17;18)$</td><td>$[18;19)$</td><td>$[19;20)$</td><td>$[20;21)$</td></tr><tr><th>Số củ cà rốt</th><td>8</td><td>17</td><td>30</td><td>28</td><td>12</td><td>5</td></tr></table>
<p>Vẽ biểu đồ tần số tương đối ghép nhóm dạng cột cho bảng thống kê trên.</p>', N'<p>Cỡ mẫu $n=8+17+30+28+12+5=100$ nên tần số tương đối của mỗi nhóm bằng đúng tần số: $8\%$; $17\%$; $30\%$; $28\%$; $12\%$; $5\%$ (tổng $100\%$).</p>
<table border="1"><tr><th>Chiều dài (cm)</th><td>$[15;16)$</td><td>$[16;17)$</td><td>$[17;18)$</td><td>$[18;19)$</td><td>$[19;20)$</td><td>$[20;21)$</td></tr><tr><th>Tần số tương đối</th><td>8%</td><td>17%</td><td>30%</td><td>28%</td><td>12%</td><td>5%</td></tr></table>
<p>Vẽ trục ngang chia các điểm 15, 16, 17, 18, 19, 20, 21; trục đứng chia vạch đến 30% (hoặc 35%). Dựng sáu cột liền kề, mỗi cột có đáy là một nhóm (rộng 1 cm) và chiều cao lần lượt 8, 17, 30, 28, 12, 5 (đơn vị %). Ghi chú giải các trục, giá trị trên đầu mỗi cột và tiêu đề "Chiều dài các củ cà rốt".</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 7.21.</b> Thời gian chờ mua vé xem bóng đá của một số cổ động viên được cho như sau:</p>
<table border="1"><tr><th>Thời gian (phút)</th><td>$[0;5)$</td><td>$[5;10)$</td><td>$[10;15)$</td><td>$[15;20)$</td><td>$[20;25)$</td><td>$[25;30)$</td></tr><tr><th>Số cổ động viên</th><td>15</td><td>38</td><td>50</td><td>27</td><td>20</td><td>10</td></tr></table>
<ol type="a">
<li>Lập bảng tần số tương đối ghép nhóm.</li>
<li>Vẽ biểu đồ tần số tương đối ghép nhóm dạng đoạn thẳng cho bảng thống kê thu được ở câu a.</li>
</ol>', N'<p><b>a)</b> Cỡ mẫu $n=15+38+50+27+20+10=160$. Tần số tương đối: $\dfrac{15}{160}\cdot100\%=9{,}375\%$; $\dfrac{38}{160}\cdot100\%=23{,}75\%$; $\dfrac{50}{160}\cdot100\%=31{,}25\%$; $\dfrac{27}{160}\cdot100\%=16{,}875\%$; $\dfrac{20}{160}\cdot100\%=12{,}5\%$; $\dfrac{10}{160}\cdot100\%=6{,}25\%$.</p>
<table border="1"><tr><th>Thời gian (phút)</th><td>$[0;5)$</td><td>$[5;10)$</td><td>$[10;15)$</td><td>$[15;20)$</td><td>$[20;25)$</td><td>$[25;30)$</td></tr><tr><th>Tần số tương đối</th><td>9,375%</td><td>23,75%</td><td>31,25%</td><td>16,875%</td><td>12,5%</td><td>6,25%</td></tr></table>
<p>(Nếu làm tròn đến một chữ số thập phân: 9,4%; 23,8%; 31,3%; 16,9%; 12,5%; 6,3%.)</p>
<p><b>b)</b> Giá trị đại diện của các nhóm: $2{,}5$; $7{,}5$; $12{,}5$; $17{,}5$; $22{,}5$; $27{,}5$. Xác định các điểm $(2{,}5;9{,}4)$, $(7{,}5;23{,}8)$, $(12{,}5;31{,}3)$, $(17{,}5;16{,}9)$, $(22{,}5;12{,}5)$, $(27{,}5;6{,}3)$ (đơn vị trục đứng là %) rồi nối các điểm liên tiếp bằng các đoạn thẳng. Ghi chú giải các trục, các điểm và tiêu đề của biểu đồ.</p>', 2, 0, 1, @t1);

-- Bài tập cuối chương VII
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài tập cuối chương VII', N'Ôn tập chương VII: tần số, tần số tương đối, dữ liệu ghép nhóm và các loại biểu đồ.', N'<p><b>Tóm tắt kiến thức chương VII.</b></p>
<ul>
<li><b>Tần số</b> $m_i$ của giá trị $x_i$ là số lần $x_i$ xuất hiện trong mẫu dữ liệu cỡ $n$; <b>tần số tương đối</b> $f_i=\dfrac{m_i}{n}\cdot100\%$ (tổng các tần số tương đối bằng $100\%$). Tần số tương đối là ước lượng cho xác suất xuất hiện giá trị đó.</li>
<li><b>Biểu đồ tần số:</b> dạng cột, dạng đoạn thẳng. <b>Biểu đồ tần số tương đối:</b> dạng cột, hình quạt tròn (số đo cung $=360^\circ\cdot f_i$).</li>
<li><b>Dữ liệu ghép nhóm:</b> nhóm $[a_i;a_{i+1})$ có giá trị đại diện $x_i=\dfrac{a_i+a_{i+1}}{2}$; biểu đồ tần số tương đối ghép nhóm dạng cột (các cột liền kề) hoặc dạng đoạn thẳng (nối các điểm $(x_i;f_i)$).</li>
</ul>
<p><b>Chọn loại biểu đồ.</b> Biểu đồ hình quạt tròn dùng cho các phần của một tổng thể (tần số tương đối có tổng $100\%$); biểu đồ cột dùng để so sánh các giá trị; biểu đồ đoạn thẳng thể hiện xu hướng thay đổi.</p>', 5, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 7.22.</b> Sử dụng dữ liệu sau để trả lời các bài tập từ 7.22 đến 7.24. Gieo một con xúc xắc 50 lần cho kết quả như sau:</p>
<table border="1"><tr><th>Số chấm xuất hiện</th><td>1</td><td>2</td><td>3</td><td>4</td><td>5</td><td>6</td></tr><tr><th>Tần số</th><td>8</td><td>7</td><td>?</td><td>8</td><td>6</td><td>11</td></tr></table>
<p>Tần số xuất hiện của mặt 3 chấm là</p>', N'<p>Tổng các tần số bằng cỡ mẫu 50 nên tần số của mặt 3 chấm là $50-(8+7+8+6+11)=50-40=10$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'9.', 0),
(@q, 'B', N'10.', 1),
(@q, 'C', N'11.', 0),
(@q, 'D', N'12.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 7.23.</b> (Dữ liệu gieo xúc xắc 50 lần ở bài 7.22: tần số các mặt 1, 2, 3, 4, 5, 6 lần lượt là 8, 7, ?, 8, 6, 11.) Tần số tương đối xuất hiện của mặt 5 chấm là</p>', N'<p>Mặt 5 chấm có tần số 6 trong 50 lần gieo nên tần số tương đối là $\dfrac{6}{50}\cdot100\%=12\%$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'6%.', 0),
(@q, 'B', N'8%.', 0),
(@q, 'C', N'12%.', 1),
(@q, 'D', N'14%.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 7.24.</b> (Dữ liệu gieo xúc xắc 50 lần ở bài 7.22.) Để biểu diễn bảng thống kê trên, <b>không thể</b> dùng loại biểu đồ nào sau đây?</p>', N'<p>Bảng thống kê trên chỉ có một dãy số liệu (tần số của từng mặt) nên có thể biểu diễn bằng biểu đồ tranh, biểu đồ tần số dạng cột hoặc dạng đoạn thẳng. Biểu đồ cột kép dùng để so sánh hai dãy số liệu cùng lúc nên không dùng được cho bảng này.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'Biểu đồ tranh.', 0),
(@q, 'B', N'Biểu đồ tần số dạng cột.', 0),
(@q, 'C', N'Biểu đồ tần số dạng đoạn thẳng.', 0),
(@q, 'D', N'Biểu đồ cột kép.', 1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 7.25.</b> Cho bảng tần số tương đối ghép nhóm về thời gian đi từ nhà đến trường của học sinh lớp 9A như sau:</p>
<table border="1"><tr><th>Thời gian đến trường (phút)</th><td>$[0;10)$</td><td>$[10;20)$</td><td>$[20;30)$</td></tr><tr><th>Tần số tương đối</th><td>20%</td><td>55%</td><td>25%</td></tr></table>
<p>Để vẽ biểu đồ tần số tương đối ghép nhóm dạng đoạn thẳng, ta dùng giá trị nào đại diện cho nhóm số liệu $[10;20)$?</p>', N'<p>Giá trị đại diện của nhóm $[a_i;a_{i+1})$ là $x_i=\dfrac{a_i+a_{i+1}}{2}$. Với nhóm $[10;20)$: $x=\dfrac{10+20}{2}=15$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'10.', 0),
(@q, 'B', N'15.', 1),
(@q, 'C', N'20.', 0),
(@q, 'D', N'30.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 7.26.</b> Biểu đồ tần số tương đối ghép nhóm Hình 7.22 cho biết tỉ lệ chiều cao của các cây keo giống do một kĩ sư lâm nghiệp đã trồng trong nhà kính.</p>
<div><img src="/static/img/sgk9/sgk9-c7-hinh-7-22.png" alt="Hình 7.22: tỉ lệ chiều cao các cây keo giống trồng trong nhà kính"></div>
<p>Lập bảng tần số tương đối ghép nhóm cho dữ liệu được biểu diễn trên biểu đồ.</p>', N'<p>Trục ngang chia các điểm 0, 10, 20, 30, 40 nên có bốn nhóm $[0;10)$, $[10;20)$, $[20;30)$, $[30;40)$. Chiều cao các cột lần lượt là $10\%$, $20\%$, $40\%$, $30\%$ (tổng $100\%$).</p>
<table border="1"><tr><th>Chiều cao (cm)</th><td>$[0;10)$</td><td>$[10;20)$</td><td>$[20;30)$</td><td>$[30;40)$</td></tr><tr><th>Tần số tương đối</th><td>10%</td><td>20%</td><td>40%</td><td>30%</td></tr></table>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 7.27.</b> Kĩ sư lâm nghiệp trên cũng trồng một số cây keo giống khác ngoài trời và thu được kết quả như sau:</p>
<table border="1"><tr><th>Chiều cao (cm)</th><td>$[0;10)$</td><td>$[10;20)$</td><td>$[20;30)$</td><td>$[30;40)$</td></tr><tr><th>Số cây</th><td>5</td><td>9</td><td>4</td><td>2</td></tr></table>
<ol type="a">
<li>Vẽ biểu đồ tần số tương đối ghép nhóm dạng cột cho bảng thống kê trên.</li>
<li>Từ biểu đồ vừa vẽ và biểu đồ cho trong bài tập 7.26, hãy so sánh chiều cao của các cây keo giống được trồng trong nhà kính và trồng ngoài trời.</li>
</ol>', N'<p><b>a)</b> Cỡ mẫu $n=5+9+4+2=20$. Tần số tương đối: $\dfrac{5}{20}\cdot100\%=25\%$; $\dfrac{9}{20}\cdot100\%=45\%$; $\dfrac{4}{20}\cdot100\%=20\%$; $\dfrac{2}{20}\cdot100\%=10\%$.</p>
<table border="1"><tr><th>Chiều cao (cm)</th><td>$[0;10)$</td><td>$[10;20)$</td><td>$[20;30)$</td><td>$[30;40)$</td></tr><tr><th>Tần số tương đối</th><td>25%</td><td>45%</td><td>20%</td><td>10%</td></tr></table>
<p>Vẽ trục ngang chia các điểm 0, 10, 20, 30, 40, trục đứng chia vạch đến 50%; dựng bốn cột liền kề có chiều cao 25, 45, 20, 10 (đơn vị %), ghi chú giải các trục, giá trị trên đầu cột và tiêu đề.</p>
<p><b>b)</b> Trong nhà kính: $40\%+30\%=70\%$ số cây cao từ 20 cm trở lên, chỉ $30\%$ số cây cao dưới 20 cm. Ngoài trời: $20\%+10\%=30\%$ số cây cao từ 20 cm trở lên, còn $25\%+45\%=70\%$ số cây cao dưới 20 cm. Vậy cây keo giống trồng trong nhà kính nhìn chung cao hơn cây trồng ngoài trời.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 7.28.</b> Tỉ lệ học sinh bình chọn cho danh hiệu cầu thủ xuất sắc nhất trong giải bóng đá của trường được cho trong bảng sau:</p>
<table border="1"><tr><th>Cầu thủ</th><td>Huy</td><td>Minh</td><td>An</td><td>Thảo</td></tr><tr><th>Tỉ lệ học sinh bình chọn</th><td>30%</td><td>25%</td><td>10%</td><td>35%</td></tr></table>
<p>Biết rằng có 500 học sinh tham gia bình chọn.</p>
<ol type="a">
<li>Vẽ biểu đồ hình quạt tròn biểu diễn bảng tần số tương đối trên.</li>
<li>Lập bảng tần số biểu diễn số học sinh bình chọn cho danh hiệu cầu thủ xuất sắc nhất trong giải bóng đá của trường.</li>
</ol>', N'<p><b>a)</b> Số đo cung: Huy $360^\circ\cdot30\%=108^\circ$; Minh $360^\circ\cdot25\%=90^\circ$; An $360^\circ\cdot10\%=36^\circ$; Thảo $360^\circ\cdot35\%=126^\circ$ (tổng $360^\circ$). Vẽ hình tròn chia thành bốn hình quạt có số đo cung trên, tô màu, ghi tỉ lệ phần trăm, chú giải và tiêu đề.</p>
<p><b>b)</b> Số học sinh bình chọn: Huy $500\cdot30\%=150$; Minh $500\cdot25\%=125$; An $500\cdot10\%=50$; Thảo $500\cdot35\%=175$ (tổng $500$).</p>
<table border="1"><tr><th>Cầu thủ</th><td>Huy</td><td>Minh</td><td>An</td><td>Thảo</td></tr><tr><th>Số học sinh bình chọn</th><td>150</td><td>125</td><td>50</td><td>175</td></tr></table>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 7.29.</b> Qua đợt khám mắt, lớp 9A có 20 học sinh bị cận thị trong đó có 10 học sinh cận thị nhẹ, 8 học sinh cận thị vừa và 2 học sinh cận thị nặng. Biết rằng cận thị có số đo từ 0,25 đến dưới 3,25 dioptre là cận thị nhẹ; từ 3,25 đến dưới 6,25 dioptre là cận thị vừa; từ 6,25 đến dưới 10,25 dioptre là cận thị nặng.</p>
<ol type="a">
<li>Lập bảng tần số và bảng tần số tương đối ghép nhóm theo độ cận thị của các học sinh này.</li>
<li>Vẽ biểu đồ tần số tương đối ghép nhóm dạng đoạn thẳng cho bảng tần số tương đối ghép nhóm thu được ở câu a.</li>
</ol>', N'<p><b>a)</b> Các nhóm theo độ cận: $[0{,}25;3{,}25)$ (cận nhẹ) có 10 học sinh; $[3{,}25;6{,}25)$ (cận vừa) có 8 học sinh; $[6{,}25;10{,}25)$ (cận nặng) có 2 học sinh.</p>
<table border="1"><tr><th>Độ cận (dioptre)</th><td>$[0{,}25;3{,}25)$</td><td>$[3{,}25;6{,}25)$</td><td>$[6{,}25;10{,}25)$</td></tr><tr><th>Tần số</th><td>10</td><td>8</td><td>2</td></tr></table>
<p>Cỡ mẫu $n=20$. Tần số tương đối: $\dfrac{10}{20}\cdot100\%=50\%$; $\dfrac{8}{20}\cdot100\%=40\%$; $\dfrac{2}{20}\cdot100\%=10\%$.</p>
<table border="1"><tr><th>Độ cận (dioptre)</th><td>$[0{,}25;3{,}25)$</td><td>$[3{,}25;6{,}25)$</td><td>$[6{,}25;10{,}25)$</td></tr><tr><th>Tần số tương đối</th><td>50%</td><td>40%</td><td>10%</td></tr></table>
<p><b>b)</b> Giá trị đại diện: $\dfrac{0{,}25+3{,}25}{2}=1{,}75$; $\dfrac{3{,}25+6{,}25}{2}=4{,}75$; $\dfrac{6{,}25+10{,}25}{2}=8{,}25$. Xác định các điểm $(1{,}75;50)$, $(4{,}75;40)$, $(8{,}25;10)$ (đơn vị trục đứng là %) rồi nối các điểm liên tiếp bằng các đoạn thẳng; ghi chú giải các trục, các điểm và tiêu đề.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 7.30.</b> Lương của các công nhân một nhà máy được cho trong bảng sau:</p>
<table border="1"><tr><th>Lương (triệu đồng)</th><td>$[5;7)$</td><td>$[7;9)$</td><td>$[9;11)$</td><td>$[11;13)$</td><td>$[13;15)$</td></tr><tr><th>Số công nhân</th><td>20</td><td>50</td><td>70</td><td>40</td><td>20</td></tr></table>
<ol type="a">
<li>Nêu các nhóm số liệu và tần số. Giải thích ý nghĩa cho một nhóm số liệu và tần số của nó.</li>
<li>Vẽ biểu đồ tần số tương đối ghép nhóm dạng cột cho bảng thống kê trên.</li>
</ol>', N'<p><b>a)</b> Các nhóm số liệu: $[5;7)$, $[7;9)$, $[9;11)$, $[11;13)$, $[13;15)$ với tần số tương ứng 20, 50, 70, 40, 20. Chẳng hạn nhóm $[9;11)$ có tần số 70 nghĩa là có 70 công nhân có mức lương từ 9 triệu đồng đến dưới 11 triệu đồng.</p>
<p><b>b)</b> Cỡ mẫu $n=20+50+70+40+20=200$. Tần số tương đối: $\dfrac{20}{200}\cdot100\%=10\%$; $\dfrac{50}{200}\cdot100\%=25\%$; $\dfrac{70}{200}\cdot100\%=35\%$; $\dfrac{40}{200}\cdot100\%=20\%$; $\dfrac{20}{200}\cdot100\%=10\%$.</p>
<table border="1"><tr><th>Lương (triệu đồng)</th><td>$[5;7)$</td><td>$[7;9)$</td><td>$[9;11)$</td><td>$[11;13)$</td><td>$[13;15)$</td></tr><tr><th>Tần số tương đối</th><td>10%</td><td>25%</td><td>35%</td><td>20%</td><td>10%</td></tr></table>
<p>Vẽ trục ngang chia các điểm 5, 7, 9, 11, 13, 15 và trục đứng chia vạch đến 40%; dựng năm cột liền kề (đáy rộng 2 triệu đồng) có chiều cao 10, 25, 35, 20, 10 (đơn vị %). Ghi chú giải các trục, giá trị trên đầu cột và tiêu đề "Lương của công nhân nhà máy".</p>', 2, 0, 1, @t1);

-- ---------------------------------------------------------------------------------------------------------------------
-- Chương VIII. Xác suất của biến cố trong một số mô hình xác suất đơn giản
-- ---------------------------------------------------------------------------------------------------------------------
INSERT INTO Topics (TopicName, [Description], TeacherId, OrderIndex, IsActive) VALUES (N'Chương VIII. Xác suất của biến cố trong một số mô hình xác suất đơn giản', N'Phép thử ngẫu nhiên và không gian mẫu; xác suất của biến cố liên quan tới phép thử gồm một hoặc hai hành động, thực nghiệm đơn giản tiến hành liên tiếp hay đồng thời. (SGK Toán 9 Kết nối tri thức với cuộc sống, Tập 2)', @t1, 8, 1);
SET @tp = SCOPE_IDENTITY();

-- Bài 25
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 25. Phép thử ngẫu nhiên và không gian mẫu', N'Nhận biết phép thử ngẫu nhiên và mô tả không gian mẫu của phép thử gồm một hoặc hai hành động.', N'<p><b>1. Phép thử ngẫu nhiên.</b> Một hoặc một số hành động, thực nghiệm được tiến hành liên tiếp hay đồng thời mà kết quả của chúng không thể biết được trước khi thực hiện nhưng có thể liệt kê được tất cả các kết quả có thể xảy ra, được gọi là một <b>phép thử ngẫu nhiên</b>, gọi tắt là <b>phép thử</b>.</p>
<p><b>2. Không gian mẫu.</b> Tập hợp tất cả các kết quả có thể xảy ra của phép thử được gọi là <b>không gian mẫu</b> của phép thử, kí hiệu là $\Omega$.</p>
<p><b>Ví dụ 1.</b> Bạn Lan gieo một con xúc xắc và bạn Hoà gieo một đồng xu. Quan sát số chấm xuất hiện trên con xúc xắc và mặt xuất hiện của đồng xu (mặt sấp S, mặt ngửa N). Kết quả của phép thử là cặp (số chấm; mặt đồng xu). Lập bảng 2 hàng (S, N) và 6 cột (1, 2, ..., 6) ta được 12 kết quả: $$\Omega=\{(1;S);(2;S);(3;S);(4;S);(5;S);(6;S);(1;N);(2;N);(3;N);(4;N);(5;N);(6;N)\}.$$ Không gian mẫu có 12 phần tử.</p>
<p><b>Ví dụ 2.</b> Một hộp kín đựng 4 quả bóng cùng khối lượng và kích thước, đánh số 1; 2; 3; 4. Lấy ngẫu nhiên lần lượt hai quả bóng từ hộp, quả bóng lấy ra lần đầu không trả lại vào hộp. Kết quả của phép thử là một cặp số $(a;b)$, trong đó $a$ và $b$ là số ghi trên quả bóng lấy ra ở lần thứ nhất và lần thứ hai. Vì không trả lại nên $a\neq b$, do đó phải xoá 4 ô $(1;1),(2;2),(3;3),(4;4)$ của bảng $4\times4$. Không gian mẫu có $16-4=12$ phần tử: $$\Omega=\{(1;2);(1;3);(1;4);(2;1);(2;3);(2;4);(3;1);(3;2);(3;4);(4;1);(4;2);(4;3)\}.$$</p>
<p><b>Tình huống mở đầu.</b> Cửa hàng rút thăm ngẫu nhiên lần lượt hai lá phiếu (không trả lại) từ 4 lá phiếu ghi tên 4 khách hàng $A,B,C,D$. Mỗi kết quả là cặp có thứ tự $(a;b)$ với $a\neq b$, nên có 12 kết quả có thể xảy ra.</p>
<p><b>Cách mô tả không gian mẫu.</b> Với phép thử gồm hai hành động, ta thường lập bảng (hàng ứng với hành động thứ nhất, cột ứng với hành động thứ hai) rồi liệt kê các ô là kết quả có thể xảy ra; chú ý loại các ô không thể xảy ra (chẳng hạn khi lấy không hoàn lại).</p>', 1, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 8.1.</b> Chọn ngẫu nhiên một gia đình có hai con và quan sát giới tính của hai người con đó.</p>
<ol type="a">
<li>Phép thử và kết quả của phép thử là gì?</li>
<li>Mô tả không gian mẫu của phép thử.</li>
</ol>', N'<p><b>a)</b> Phép thử là chọn ngẫu nhiên một gia đình có hai con và quan sát giới tính của hai người con (theo thứ tự con thứ nhất, con thứ hai). Kết quả của phép thử là một cặp $(a;b)$, trong đó $a$ và $b$ là giới tính của con thứ nhất và con thứ hai ($T$: con trai, $G$: con gái).</p>
<p><b>b)</b> Không gian mẫu: $\Omega=\{(T;T);(T;G);(G;T);(G;G)\}$ (gồm 4 phần tử).</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 8.2.</b> Một hộp đựng 5 tấm thẻ ghi các số 1; 2; 3; 4; 5. Rút ngẫu nhiên lần lượt hai tấm thẻ từ hộp, tấm thẻ rút ra lần đầu không trả lại vào hộp.</p>
<ol type="a">
<li>Phép thử và kết quả của phép thử là gì?</li>
<li>Mô tả không gian mẫu của phép thử. Không gian mẫu có bao nhiêu phần tử?</li>
</ol>', N'<p><b>a)</b> Phép thử là rút ngẫu nhiên lần lượt hai tấm thẻ từ hộp, thẻ rút lần đầu không trả lại. Kết quả của phép thử là một cặp số $(a;b)$, trong đó $a$ và $b$ là số ghi trên thẻ rút ra ở lần thứ nhất và lần thứ hai, $a\neq b$.</p>
<p><b>b)</b> Lập bảng $5\times5$ rồi xoá 5 ô $(a;a)$. Không gian mẫu: $$\Omega=\{(1;2);(1;3);(1;4);(1;5);(2;1);(2;3);(2;4);(2;5);(3;1);(3;2);(3;4);(3;5);(4;1);(4;2);(4;3);(4;5);(5;1);(5;2);(5;3);(5;4)\}.$$</p>
<p><b>Đáp số:</b> không gian mẫu có $25-5=20$ phần tử.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 8.3.</b> Có hai nhóm học sinh: Nhóm I có ba học sinh nam là Huy, Sơn, Tùng; nhóm II có ba học sinh nữ là Hồng, Phương, Linh. Giáo viên chọn ngẫu nhiên một học sinh từ mỗi nhóm.</p>
<ol type="a">
<li>Phép thử và kết quả của phép thử là gì?</li>
<li>Mô tả không gian mẫu của phép thử. Không gian mẫu có bao nhiêu phần tử?</li>
</ol>', N'<p><b>a)</b> Phép thử là chọn ngẫu nhiên một học sinh từ mỗi nhóm. Kết quả của phép thử là một cặp (học sinh nhóm I; học sinh nhóm II).</p>
<p><b>b)</b> Lập bảng 3 hàng (Huy, Sơn, Tùng) và 3 cột (Hồng, Phương, Linh): $$\Omega=\{(\text{Huy};\text{Hồng});(\text{Huy};\text{Phương});(\text{Huy};\text{Linh});(\text{Sơn};\text{Hồng});(\text{Sơn};\text{Phương});(\text{Sơn};\text{Linh});(\text{Tùng};\text{Hồng});(\text{Tùng};\text{Phương});(\text{Tùng};\text{Linh})\}.$$</p>
<p><b>Đáp số:</b> không gian mẫu có $3\cdot3=9$ phần tử.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 8.4.</b> Xếp ngẫu nhiên ba bạn Mai, Việt, Lan trên một chiếc ghế dài.</p>
<ol type="a">
<li>Phép thử và kết quả của phép thử là gì?</li>
<li>Mô tả không gian mẫu của phép thử. Không gian mẫu có bao nhiêu phần tử?</li>
</ol>', N'<p><b>a)</b> Phép thử là xếp ngẫu nhiên ba bạn trên một ghế dài. Kết quả của phép thử là một cách sắp xếp thứ tự ba bạn (từ trái sang phải).</p>
<p><b>b)</b> Kí hiệu Mai, Việt, Lan lần lượt là $M,V,L$: $$\Omega=\{MVL;\ MLV;\ VML;\ VLM;\ LMV;\ LVM\}.$$</p>
<p><b>Đáp số:</b> không gian mẫu có $3\cdot2\cdot1=6$ phần tử.</p>', 1, 0, 1, @t1);

-- Bài 26
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 26. Xác suất của biến cố liên quan tới phép thử', N'Kết quả thuận lợi cho một biến cố và cách tính xác suất khi các kết quả của phép thử đồng khả năng.', N'<p><b>1. Kết quả thuận lợi cho một biến cố.</b> Cho phép thử $T$. Xét biến cố $E$ mà việc xảy ra hay không xảy ra của $E$ tuỳ thuộc vào kết quả của phép thử $T$. Kết quả của phép thử $T$ làm cho biến cố $E$ xảy ra gọi là <b>kết quả thuận lợi</b> cho $E$.</p>
<p><b>Ví dụ 1.</b> Bạn Tuấn quay một tấm bìa hình tròn chia làm 4 hình quạt bằng nhau đánh số 1; 2; 3; 4 hai lần, ghi lại số của hình quạt mà mũi tên chỉ vào. Không gian mẫu gồm 16 cặp $(a;b)$ với $a,b\in\{1;2;3;4\}$. Với biến cố $E$: "Tổng hai số bằng 5", các kết quả thuận lợi là $(1;4);(2;3);(3;2);(4;1)$. Với biến cố $F$: "Tích hai số bằng 4", các kết quả thuận lợi là $(1;4);(2;2);(4;1)$.</p>
<p><b>2. Tính xác suất khi các kết quả đồng khả năng.</b> Giả sử các kết quả có thể của phép thử $T$ là đồng khả năng. Khi đó xác suất của biến cố $E$ là $$P(E)=\dfrac{n(E)}{n(\Omega)},$$ trong đó $n(E)$ là số kết quả thuận lợi cho $E$ và $n(\Omega)$ là số phần tử của không gian mẫu $\Omega$.</p>
<p><b>Cách tính xác suất của một biến cố $E$:</b></p>
<ol>
<li><i>Bước 1.</i> Mô tả không gian mẫu của phép thử; xác định số phần tử của $\Omega$.</li>
<li><i>Bước 2.</i> Chứng tỏ các kết quả có thể của phép thử là đồng khả năng.</li>
<li><i>Bước 3.</i> Mô tả các kết quả thuận lợi cho $E$; xác định số kết quả thuận lợi.</li>
<li><i>Bước 4.</i> Lập tỉ số giữa số kết quả thuận lợi cho $E$ với số phần tử của $\Omega$.</li>
</ol>
<p><b>Ví dụ 2.</b> Ba bạn Bảo, Châu, Dương được xếp ngẫu nhiên ngồi trên một hàng ghế có ba chỗ ngồi. Không gian mẫu $\Omega=\{BCD;BDC;CBD;DBC;CDB;DCB\}$ có 6 phần tử, các kết quả đồng khả năng. Biến cố $E$: "Bảo không ngồi ngoài cùng bên phải" có 4 kết quả thuận lợi (BCD, BDC, CBD, DBC) nên $P(E)=\dfrac{4}{6}=\dfrac{2}{3}$. Biến cố $F$: "Châu và Dương không ngồi cạnh nhau" có 2 kết quả thuận lợi (CBD, DBC) nên $P(F)=\dfrac{2}{6}=\dfrac{1}{3}$.</p>
<p><b>Ví dụ 3 (di truyền ở đậu Hà Lan).</b> Cây bố có kiểu gene $(AA,Bb)$, cây mẹ có kiểu gene $(Aa,Bb)$. Không gian mẫu gồm 8 kết quả đồng khả năng: $(AA,BB);(AA,Bb);(AA,bB);(AA,bb);(Aa,BB);(Aa,Bb);(Aa,bB);(Aa,bb)$. Biến cố $M$: "Cây con có hạt vàng và trơn" (có ít nhất một allele trội $A$ và ít nhất một allele trội $B$) có 6 kết quả thuận lợi nên $P(M)=\dfrac{6}{8}=\dfrac{3}{4}$.</p>', 2, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 8.5.</b> Chọn ngẫu nhiên một gia đình có hai con. Giả thiết rằng biến cố "Sinh con trai" và biến cố "Sinh con gái" là đồng khả năng. Tính xác suất của các biến cố sau:</p>
<p>$A$: "Gia đình đó có cả con trai và con gái";</p>
<p>$B$: "Gia đình đó có con trai".</p>', N'<p>Không gian mẫu $\Omega=\{(T;T);(T;G);(G;T);(G;G)\}$ có 4 phần tử, các kết quả đồng khả năng.</p>
<p>Biến cố $A$ có 2 kết quả thuận lợi là $(T;G);(G;T)$ nên $P(A)=\dfrac{2}{4}=\dfrac{1}{2}$.</p>
<p>Biến cố $B$ có 3 kết quả thuận lợi là $(T;T);(T;G);(G;T)$ nên $P(B)=\dfrac{3}{4}$.</p>
<p><b>Đáp số:</b> $P(A)=\dfrac{1}{2}$; $P(B)=\dfrac{3}{4}$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 8.6.</b> Gieo đồng thời hai con xúc xắc cân đối, đồng chất I và II. Tính xác suất các biến cố sau:</p>
<p>$E$: "Có đúng một con xúc xắc xuất hiện mặt 6 chấm";</p>
<p>$F$: "Có ít nhất một con xúc xắc xuất hiện mặt 6 chấm";</p>
<p>$G$: "Tích của hai số chấm xuất hiện trên hai con xúc xắc nhỏ hơn hoặc bằng 6".</p>', N'<p>Không gian mẫu gồm các cặp $(a;b)$ với $a,b\in\{1;2;\dots;6\}$, có $6\cdot6=36$ phần tử, các kết quả đồng khả năng.</p>
<p><b>Biến cố $E$:</b> con I là 6 và con II khác 6 (5 kết quả) hoặc con II là 6 và con I khác 6 (5 kết quả); có 10 kết quả thuận lợi. $P(E)=\dfrac{10}{36}=\dfrac{5}{18}$.</p>
<p><b>Biến cố $F$:</b> số kết quả không có mặt 6 chấm là $5\cdot5=25$ nên có $36-25=11$ kết quả thuận lợi. $P(F)=\dfrac{11}{36}$.</p>
<p><b>Biến cố $G$:</b> với $a=1$: $b=1,\dots,6$ (6 kết quả); $a=2$: $b=1,2,3$ (3); $a=3$: $b=1,2$ (2); $a=4$: $b=1$ (1); $a=5$: $b=1$ (1); $a=6$: $b=1$ (1). Tổng cộng $6+3+2+1+1+1=14$ kết quả. $P(G)=\dfrac{14}{36}=\dfrac{7}{18}$.</p>
<p><b>Đáp số:</b> $P(E)=\dfrac{5}{18}$; $P(F)=\dfrac{11}{36}$; $P(G)=\dfrac{7}{18}$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 8.7.</b> Bạn An gieo một đồng xu cân đối và bạn Bình rút ngẫu nhiên một tấm thẻ từ hộp chứa 5 tấm thẻ ghi các số 1; 2; 3; 4; 5. Tính xác suất của các biến cố sau:</p>
<p>$E$: "Rút được tấm thẻ ghi số lẻ";</p>
<p>$F$: "Rút được tấm thẻ ghi số chẵn và đồng xu xuất hiện mặt sấp";</p>
<p>$G$: "Rút được tấm thẻ ghi số 5 hoặc đồng xu xuất hiện mặt ngửa".</p>', N'<p>Kết quả của phép thử là cặp (mặt đồng xu; số trên thẻ). Không gian mẫu có $2\cdot5=10$ phần tử, các kết quả đồng khả năng: $$\Omega=\{(S;1);(S;2);(S;3);(S;4);(S;5);(N;1);(N;2);(N;3);(N;4);(N;5)\}.$$</p>
<p><b>$E$:</b> thẻ ghi số lẻ (1, 3 hoặc 5) với mặt đồng xu bất kì: $3\cdot2=6$ kết quả. $P(E)=\dfrac{6}{10}=\dfrac{3}{5}$.</p>
<p><b>$F$:</b> thẻ chẵn và mặt sấp: $(S;2);(S;4)$, có 2 kết quả. $P(F)=\dfrac{2}{10}=\dfrac{1}{5}$.</p>
<p><b>$G$:</b> có 5 kết quả mặt ngửa $(N;1),\dots,(N;5)$ và thêm kết quả $(S;5)$ (thẻ 5, mặt sấp), tổng cộng 6 kết quả. $P(G)=\dfrac{6}{10}=\dfrac{3}{5}$.</p>
<p><b>Đáp số:</b> $P(E)=\dfrac{3}{5}$; $P(F)=\dfrac{1}{5}$; $P(G)=\dfrac{3}{5}$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 8.8.</b> Có hai túi I và II mỗi túi chứa 4 tấm thẻ được đánh số 1; 2; 3; 4. Rút ngẫu nhiên từ mỗi túi ra một tấm thẻ và nhân hai số ghi trên hai tấm thẻ với nhau. Tính xác suất của các biến cố sau:</p>
<p>$A$: "Kết quả là một số lẻ";</p>
<p>$B$: "Kết quả là 1 hoặc một số nguyên tố".</p>', N'<p>Kết quả của phép thử là cặp $(a;b)$ với $a,b\in\{1;2;3;4\}$ ($a$ từ túi I, $b$ từ túi II). Không gian mẫu có $4\cdot4=16$ phần tử, các kết quả đồng khả năng.</p>
<p><b>$A$:</b> tích $ab$ lẻ khi cả $a$ và $b$ đều lẻ: $a,b\in\{1;3\}$, có $2\cdot2=4$ kết quả $(1;1);(1;3);(3;1);(3;3)$. $P(A)=\dfrac{4}{16}=\dfrac{1}{4}$.</p>
<p><b>$B$:</b> $ab=1$: $(1;1)$. $ab=2$ (nguyên tố): $(1;2);(2;1)$. $ab=3$ (nguyên tố): $(1;3);(3;1)$. Các tích còn lại $4,6,8,9,12,\dots$ không là số nguyên tố ($ab=5$ hoặc $7$ không xảy ra). Có $1+2+2=5$ kết quả thuận lợi. $P(B)=\dfrac{5}{16}$.</p>
<p><b>Đáp số:</b> $P(A)=\dfrac{1}{4}$; $P(B)=\dfrac{5}{16}$.</p>', 2, 0, 1, @t1);

-- Luyện tập chung (Bài 25 - Bài 26)
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Luyện tập chung (Chương VIII)', N'Rèn luyện mô tả không gian mẫu và tính xác suất của biến cố trong phép thử gồm hai hành động.', N'<p><b>Ví dụ.</b> Tấm bìa cứng A hình tròn được chia thành 3 hình quạt có diện tích bằng nhau, đánh số 1; 2; 3 và tấm bìa cứng B hình tròn được chia thành 5 hình quạt có diện tích bằng nhau, đánh số 1; 2; 3; 4; 5. Trục quay của A và B được gắn mũi tên ở tâm. Bạn Nam quay tấm bìa A, bạn Bình quay tấm bìa B. Quan sát xem mũi tên dừng ở hình quạt nào trên hai tấm bìa.</p>
<p><b>a)</b> Phép thử là bạn Nam quay tấm bìa A, bạn Bình quay tấm bìa B.</p>
<p><b>b)</b> Lập bảng (hàng: tấm bìa B với các số 1 đến 5; cột: tấm bìa A với các số 1, 2, 3) ta được 15 kết quả đồng khả năng: $$\Omega=\{(1;1);(1;2);(1;3);(2;1);(2;2);(2;3);(3;1);(3;2);(3;3);(4;1);(4;2);(4;3);(5;1);(5;2);(5;3)\}.$$ (cặp ghi theo thứ tự (số ở tấm bìa B; số ở tấm bìa A)).</p>
<p><b>c)</b> $E$: "Tích hai số bằng 6": có 2 kết quả thuận lợi $(3;2);(2;3)$, $P(E)=\dfrac{2}{15}$. $F$: "Tích hai số nhỏ hơn 5": có 7 kết quả thuận lợi $(1;1);(1;2);(2;1);(1;3);(3;1);(2;2);(4;1)$, $P(F)=\dfrac{7}{15}$. $G$: "Tích hai số là số chẵn" (tích chẵn khi có ít nhất một số chẵn): có 9 kết quả thuận lợi, $P(G)=\dfrac{9}{15}=\dfrac{3}{5}$.</p>', 3, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 8.9.</b> Có hai túi đựng các tấm thẻ. Túi I đựng 4 tấm thẻ ghi các chữ cái TT, TH, HT và HH. Túi II đựng 2 tấm thẻ ghi các chữ cái T và H. Từ mỗi túi rút ngẫu nhiên một tấm thẻ rồi ghép hai thẻ lại với nhau để được ba chữ cái, trong đó thẻ hai chữ cái đặt trước, chẳng hạn tấm thẻ TT ghép với tấm thẻ H được ba chữ cái TTH. Tính xác suất của các biến cố sau:</p>
<ol type="a">
<li>$E$: "Trong ba chữ cái, có hai chữ H và một chữ T";</li>
<li>$F$: "Trong ba chữ cái, có nhiều nhất hai chữ T".</li>
</ol>', N'<p>Không gian mẫu có $4\cdot2=8$ phần tử, các kết quả đồng khả năng: $$\Omega=\{TTT;TTH;THT;THH;HTT;HTH;HHT;HHH\}.$$</p>
<p><b>a)</b> Các kết quả có đúng hai chữ H và một chữ T: $THH;HTH;HHT$ (3 kết quả). $P(E)=\dfrac{3}{8}$.</p>
<p><b>b)</b> Biến cố đối "có ba chữ T" chỉ có một kết quả $TTT$, nên có $8-1=7$ kết quả thuận lợi cho $F$. $P(F)=\dfrac{7}{8}$.</p>
<p><b>Đáp số:</b> a) $\dfrac{3}{8}$. b) $\dfrac{7}{8}$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 8.10.</b> Gieo đồng thời hai con xúc xắc cân đối và đồng chất I và II. Tính xác suất của các biến cố sau:</p>
<p>$G$: "Không có con xúc xắc nào xuất hiện mặt 6 chấm";</p>
<p>$H$: "Số chấm xuất hiện trên con xúc xắc I là số lẻ và số chấm xuất hiện trên con xúc xắc II lớn hơn 4";</p>
<p>$K$: "Số chấm xuất hiện trên cả hai con xúc xắc lớn hơn 2".</p>', N'<p>Không gian mẫu gồm 36 cặp $(a;b)$, $a,b\in\{1;\dots;6\}$, các kết quả đồng khả năng.</p>
<p><b>$G$:</b> cả hai con đều xuất hiện mặt từ 1 đến 5: $5\cdot5=25$ kết quả. $P(G)=\dfrac{25}{36}$.</p>
<p><b>$H$:</b> $a\in\{1;3;5\}$ (3 cách) và $b\in\{5;6\}$ (2 cách): $3\cdot2=6$ kết quả. $P(H)=\dfrac{6}{36}=\dfrac{1}{6}$.</p>
<p><b>$K$:</b> $a,b\in\{3;4;5;6\}$: $4\cdot4=16$ kết quả. $P(K)=\dfrac{16}{36}=\dfrac{4}{9}$.</p>
<p><b>Đáp số:</b> $P(G)=\dfrac{25}{36}$; $P(H)=\dfrac{1}{6}$; $P(K)=\dfrac{4}{9}$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 8.11.</b> Trên một dãy phố có ba quán ăn A, B, C. Hai bạn Văn và Hải mỗi người chọn ngẫu nhiên một quán ăn để ăn trưa.</p>
<ol type="a">
<li>Mô tả không gian mẫu của phép thử.</li>
<li>Tính xác suất của các biến cố sau:
<p>$E$: "Hai bạn cùng vào một quán";</p>
<p>$F$: "Cả hai bạn không chọn quán C";</p>
<p>$G$: "Có ít nhất một bạn chọn quán B".</p></li>
</ol>', N'<p><b>a)</b> Kết quả của phép thử là cặp (quán của Văn; quán của Hải): $$\Omega=\{(A;A);(A;B);(A;C);(B;A);(B;B);(B;C);(C;A);(C;B);(C;C)\}.$$ Không gian mẫu có $3\cdot3=9$ phần tử, các kết quả đồng khả năng.</p>
<p><b>b)</b> $E$: $(A;A);(B;B);(C;C)$, có 3 kết quả. $P(E)=\dfrac{3}{9}=\dfrac{1}{3}$.</p>
<p>$F$: cả hai chọn A hoặc B, có $2\cdot2=4$ kết quả. $P(F)=\dfrac{4}{9}$.</p>
<p>$G$: số kết quả không có bạn nào chọn B là $2\cdot2=4$, nên có $9-4=5$ kết quả thuận lợi $(A;B);(B;A);(B;B);(B;C);(C;B)$. $P(G)=\dfrac{5}{9}$.</p>
<p><b>Đáp số:</b> $P(E)=\dfrac{1}{3}$; $P(F)=\dfrac{4}{9}$; $P(G)=\dfrac{5}{9}$.</p>', 2, 0, 1, @t1);

-- Bài tập cuối chương VIII
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài tập cuối chương VIII', N'Ôn tập chương VIII: không gian mẫu, kết quả thuận lợi và xác suất của biến cố.', N'<p><b>Tóm tắt kiến thức chương VIII.</b></p>
<ul>
<li><b>Phép thử ngẫu nhiên</b> là hành động, thực nghiệm mà kết quả không thể biết trước nhưng liệt kê được tất cả các kết quả có thể. Tập hợp các kết quả có thể là <b>không gian mẫu</b> $\Omega$.</li>
<li>Với phép thử gồm hai hành động, lập <b>bảng</b> để liệt kê không gian mẫu; chú ý các trường hợp lấy không hoàn lại ($a\neq b$) và hoán vị.</li>
<li><b>Kết quả thuận lợi</b> cho biến cố $E$ là kết quả của phép thử làm cho $E$ xảy ra.</li>
<li>Nếu các kết quả của phép thử đồng khả năng thì $$P(E)=\dfrac{n(E)}{n(\Omega)}.$$ Luôn có $0\le P(E)\le1$.</li>
<li>Khi đếm số kết quả thuận lợi cho biến cố "có ít nhất ...", có thể đếm phần bù (không có ...) rồi lấy $n(\Omega)$ trừ đi.</li>
</ul>', 4, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 8.12.</b> Gieo đồng thời hai con xúc xắc cân đối, đồng chất. Xác suất để "Tổng số chấm xuất hiện trên hai con xúc xắc lớn hơn hoặc bằng 10" là</p>', N'<p>Không gian mẫu có 36 phần tử. Các kết quả có tổng $\ge10$: $(4;6);(5;5);(6;4);(5;6);(6;5);(6;6)$, tức 6 kết quả. Xác suất là $\dfrac{6}{36}=\dfrac{1}{6}$.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$\dfrac{7}{36}$.', 0),
(@q, 'B', N'$\dfrac{2}{9}$.', 0),
(@q, 'C', N'$\dfrac{1}{6}$.', 1),
(@q, 'D', N'$\dfrac{5}{36}$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 8.13.</b> Có hai túi I và II. Túi I chứa 4 tấm thẻ, đánh số 1; 2; 3; 4. Túi II chứa 5 tấm thẻ, đánh số 1; 2; 3; 4; 5. Rút ngẫu nhiên một tấm thẻ từ mỗi túi I và II. Xác suất để cả hai tấm thẻ rút ra đều ghi số chẵn là</p>', N'<p>Không gian mẫu có $4\cdot5=20$ phần tử. Túi I có 2 thẻ chẵn (2; 4), túi II có 2 thẻ chẵn (2; 4) nên có $2\cdot2=4$ kết quả thuận lợi. Xác suất là $\dfrac{4}{20}=\dfrac{1}{5}$.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$\dfrac{1}{5}$.', 1),
(@q, 'B', N'$\dfrac{3}{20}$.', 0),
(@q, 'C', N'$\dfrac{1}{4}$.', 0),
(@q, 'D', N'$\dfrac{4}{21}$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 8.14.</b> Một túi đựng 4 viên bi có cùng khối lượng và kích thước, được đánh số 1; 2; 3; 4. Lấy ngẫu nhiên hai viên bi từ trong túi. Xác suất để tích hai số ghi trên hai viên bi lớn hơn 3 là</p>', N'<p>Lấy hai viên bi cùng lúc: các kết quả (không kể thứ tự) là $\{1;2\},\{1;3\},\{1;4\},\{2;3\},\{2;4\},\{3;4\}$, gồm 6 phần tử, đồng khả năng. Tích tương ứng: 2; 3; 4; 6; 8; 12. Có 4 kết quả có tích lớn hơn 3. Xác suất là $\dfrac{4}{6}=\dfrac{2}{3}$.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$\dfrac{5}{7}$.', 0),
(@q, 'B', N'$\dfrac{2}{3}$.', 1),
(@q, 'C', N'$\dfrac{3}{4}$.', 0),
(@q, 'D', N'$\dfrac{5}{6}$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 8.15.</b> Có hai túi I và II. Túi I chứa 3 tấm thẻ, đánh số 2; 3; 4. Túi II chứa 2 tấm thẻ, đánh số 5; 6. Từ mỗi túi I và II, rút ngẫu nhiên một tấm thẻ. Tính xác suất của các biến cố sau:</p>
<p>$A$: "Hai số ghi trên hai tấm thẻ chênh nhau 2 đơn vị";</p>
<p>$B$: "Hai số ghi trên hai tấm thẻ chênh nhau lớn hơn 2 đơn vị";</p>
<p>$C$: "Tích hai số ghi trên hai tấm thẻ là một số chẵn";</p>
<p>$D$: "Tổng hai số ghi trên hai tấm thẻ là một số nguyên tố".</p>', N'<p>Kết quả là cặp (số túi I; số túi II). Không gian mẫu có $3\cdot2=6$ phần tử, đồng khả năng: $$\Omega=\{(2;5);(2;6);(3;5);(3;6);(4;5);(4;6)\}.$$</p>
<p><b>$A$:</b> chênh nhau 2: $(3;5);(4;6)$ nên $P(A)=\dfrac{2}{6}=\dfrac{1}{3}$.</p>
<p><b>$B$:</b> chênh nhau lớn hơn 2: $(2;5)$ (chênh 3); $(2;6)$ (chênh 4); $(3;6)$ (chênh 3) nên $P(B)=\dfrac{3}{6}=\dfrac{1}{2}$.</p>
<p><b>$C$:</b> các tích: $10;12;15;18;20;24$; chỉ $15$ là số lẻ nên có 5 kết quả thuận lợi. $P(C)=\dfrac{5}{6}$.</p>
<p><b>$D$:</b> các tổng: $7;8;8;9;9;10$; chỉ $7$ là số nguyên tố nên có 1 kết quả thuận lợi $(2;5)$. $P(D)=\dfrac{1}{6}$.</p>
<p><b>Đáp số:</b> $P(A)=\dfrac{1}{3}$; $P(B)=\dfrac{1}{2}$; $P(C)=\dfrac{5}{6}$; $P(D)=\dfrac{1}{6}$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 8.16.</b> Gieo đồng thời hai con xúc xắc cân đối, đồng chất I và II. Tính xác suất của các biến cố sau:</p>
<p>$E$: "Tổng số chấm xuất hiện trên hai con xúc xắc bằng 11";</p>
<p>$F$: "Tổng số chấm xuất hiện trên hai con xúc xắc bằng 8 hoặc 9";</p>
<p>$G$: "Tổng số chấm xuất hiện trên hai con xúc xắc nhỏ hơn 6".</p>', N'<p>Không gian mẫu có 36 phần tử, các kết quả đồng khả năng.</p>
<p><b>$E$:</b> tổng bằng 11: $(5;6);(6;5)$ nên $P(E)=\dfrac{2}{36}=\dfrac{1}{18}$.</p>
<p><b>$F$:</b> tổng bằng 8: $(2;6);(3;5);(4;4);(5;3);(6;2)$ (5 kết quả); tổng bằng 9: $(3;6);(4;5);(5;4);(6;3)$ (4 kết quả). Có 9 kết quả thuận lợi. $P(F)=\dfrac{9}{36}=\dfrac{1}{4}$.</p>
<p><b>$G$:</b> tổng bằng 2, 3, 4, 5 lần lượt có 1, 2, 3, 4 kết quả. Có $1+2+3+4=10$ kết quả thuận lợi. $P(G)=\dfrac{10}{36}=\dfrac{5}{18}$.</p>
<p><b>Đáp số:</b> $P(E)=\dfrac{1}{18}$; $P(F)=\dfrac{1}{4}$; $P(G)=\dfrac{5}{18}$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 8.17.</b> Hai bạn Minh và Huy chơi một trò chơi như sau: Minh chọn ngẫu nhiên một số trong tập hợp $\{5;6;7;8;9;10\}$; Huy chọn ngẫu nhiên một số trong tập hợp $\{4;5;7;8;9;11\}$. Bạn nào chọn được số lớn hơn sẽ là người thắng cuộc. Nếu hai số chọn được bằng nhau thì kết quả là hoà. Tính xác suất của các biến cố sau:</p>
<ol type="a">
<li>$A$: "Bạn Minh thắng";</li>
<li>$B$: "Bạn Huy thắng".</li>
</ol>', N'<p>Kết quả là cặp $(m;h)$ ($m$ là số Minh chọn, $h$ là số Huy chọn). Không gian mẫu có $6\cdot6=36$ phần tử, đồng khả năng.</p>
<p>Với mỗi số $m$ của Minh, đếm số giá trị $h\in\{4;5;7;8;9;11\}$:</p>
<table border="1"><tr><th>$m$</th><td>5</td><td>6</td><td>7</td><td>8</td><td>9</td><td>10</td></tr><tr><th>Số $h$ nhỏ hơn $m$ (Minh thắng)</th><td>1</td><td>2</td><td>2</td><td>3</td><td>4</td><td>5</td></tr><tr><th>Số $h$ bằng $m$ (hoà)</th><td>1</td><td>0</td><td>1</td><td>1</td><td>1</td><td>0</td></tr><tr><th>Số $h$ lớn hơn $m$ (Huy thắng)</th><td>4</td><td>4</td><td>3</td><td>2</td><td>1</td><td>1</td></tr></table>
<p><b>a)</b> Minh thắng: $1+2+2+3+4+5=17$ kết quả. $P(A)=\dfrac{17}{36}$.</p>
<p><b>b)</b> Huy thắng: $4+4+3+2+1+1=15$ kết quả. $P(B)=\dfrac{15}{36}=\dfrac{5}{12}$.</p>
<p>(Kiểm tra: số kết quả hoà là $4$ và $17+15+4=36$.)</p>
<p><b>Đáp số:</b> a) $\dfrac{17}{36}$. b) $\dfrac{5}{12}$.</p>', 3, 0, 1, @t1);

-- ---------------------------------------------------------------------------------------------------------------------
-- Chương IX. Đường tròn ngoại tiếp và đường tròn nội tiếp
-- ---------------------------------------------------------------------------------------------------------------------
INSERT INTO Topics (TopicName, [Description], TeacherId, OrderIndex, IsActive) VALUES (N'Chương IX. Đường tròn ngoại tiếp và đường tròn nội tiếp', N'Góc nội tiếp, đường tròn ngoại tiếp và nội tiếp tam giác, tứ giác nội tiếp, đa giác đều và phép quay. (SGK Toán 9 Kết nối tri thức với cuộc sống, Tập 2)', @t1, 9, 1);
SET @tp = SCOPE_IDENTITY();

-- Bài 27
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 27. Góc nội tiếp', N'Khái niệm góc nội tiếp, cung bị chắn và mối liên hệ giữa số đo góc nội tiếp với số đo cung bị chắn.', N'<p><b>1. Góc nội tiếp và cung bị chắn.</b> <b>Góc nội tiếp</b> của đường tròn là góc có đỉnh nằm trên đường tròn và hai cạnh chứa hai dây cung của đường tròn đó. Cung nằm bên trong góc được gọi là <b>cung bị chắn</b>.</p>
<p><b>Ví dụ 1.</b> Trong bốn góc $A,B,C,D$ ở Hình 9.3: góc $A$ và góc $C$ không phải góc nội tiếp vì đỉnh không nằm trên đường tròn; góc $D$ có một cạnh không chứa dây cung của đường tròn nên cũng không phải; góc $B$ có đỉnh nằm trên đường tròn và hai cạnh chứa hai dây cung nên là góc nội tiếp.</p>
<p><b>2. Định lí.</b> Trong một đường tròn, số đo của góc nội tiếp bằng nửa số đo của cung bị chắn: nếu $A,B,C\in(O)$ thì $$\widehat{ACB}=\dfrac{1}{2}\ \text{sđ}\ \overset{\frown}{AB}\quad(\text{cung }AB\text{ không chứa }C).$$</p>
<p><i>Chứng minh (tóm tắt).</i> Trường hợp 1: tâm $O$ nằm trên một cạnh của góc $ACB$, chẳng hạn $O\in CB$. Tam giác $OAC$ cân tại $O$ nên $2\widehat{ACB}=\widehat{ACO}+\widehat{CAO}=180^\circ-\widehat{AOC}=\widehat{AOB}$; mà $\widehat{AOB}=\text{sđ}\ \overset{\frown}{AB}$ nên $\widehat{ACB}=\dfrac{1}{2}\text{sđ}\ \overset{\frown}{AB}$. Trường hợp 2: tâm $O$ nằm bên trong góc: vẽ đường kính $CD$ rồi cộng hai góc $\widehat{ACD}$ và $\widehat{DCB}$. Trường hợp 3: tâm $O$ nằm ngoài góc: vẽ đường kính $CD$ rồi lấy hiệu hai góc $\widehat{ACD}$ và $\widehat{BCD}$.</p>
<p><b>Nhận xét.</b> Đối với các góc nội tiếp của một đường tròn hoặc của hai đường tròn bằng nhau:</p>
<ul>
<li>Các góc nội tiếp bằng nhau chắn các cung bằng nhau.</li>
<li>Các góc nội tiếp cùng chắn một cung hoặc chắn các cung bằng nhau thì bằng nhau.</li>
<li>Góc nội tiếp chắn cung nhỏ có số đo bằng nửa số đo của góc ở tâm chắn cùng một cung.</li>
<li>Góc nội tiếp chắn nửa đường tròn là góc vuông.</li>
</ul>
<p><b>Ví dụ 2.</b> Cho $A,B,C,D\in(O)$ và $\widehat{BAC}=60^\circ$. Hai góc nội tiếp $\widehat{BDC}$ và $\widehat{BAC}$ cùng chắn cung nhỏ $BC$ nên $\widehat{BDC}=\widehat{BAC}=60^\circ$. Góc nội tiếp $\widehat{BAC}$ và góc ở tâm $\widehat{BOC}$ cùng chắn cung nhỏ $BC$ nên $\widehat{BOC}=2\widehat{BAC}=120^\circ$.</p>
<p><b>Ví dụ 3 (Luyện tập).</b> Cho hai dây cung $AB,CD$ của $(O)$ cắt nhau tại $X$ nằm trong đường tròn. Chứng minh $\triangle AXC\backsim\triangle DXB$. Ta có $\widehat{ACX}=\widehat{ACD}=\widehat{ABD}=\widehat{DBX}$ (hai góc nội tiếp cùng chắn cung $AD$) và $\widehat{AXC}=\widehat{DXB}$ (đối đỉnh). Suy ra $\triangle AXC\backsim\triangle DXB$ (g.g).</p>
<p><b>Vận dụng (tình huống mở đầu).</b> Cho đường tròn bán kính 2 cm và dây cung $BC=2\sqrt{2}$ cm. Vì $OB^2+OC^2=4+4=8=BC^2$ nên tam giác $BOC$ vuông tại $O$, suy ra $\widehat{BOC}=90^\circ$ và $\widehat{BAC}=\dfrac{1}{2}\widehat{BOC}=45^\circ$.</p>', 1, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.1.</b> Những khẳng định nào sau đây là đúng?</p>
<ol type="a">
<li>Hai góc nội tiếp bằng nhau thì chắn cùng một cung.</li>
<li>Góc nội tiếp nhỏ hơn $90^\circ$ có số đo bằng nửa số đo của góc ở tâm chắn cùng một cung.</li>
<li>Góc nội tiếp chắn cung nhỏ có số đo bằng số đo của góc ở tâm chắn cùng một cung.</li>
<li>Hai góc nội tiếp bằng nhau thì chắn hai cung bằng nhau.</li>
</ol>', N'<p><b>a)</b> Sai. Hai góc nội tiếp bằng nhau chắn hai cung <i>bằng nhau</i> chứ chưa chắc là cùng một cung (hai cung khác nhau nhưng có cùng số đo).</p>
<p><b>b)</b> Đúng. Góc nội tiếp nhỏ hơn $90^\circ$ chắn cung nhỏ, nên số đo bằng nửa số đo góc ở tâm chắn cùng cung đó.</p>
<p><b>c)</b> Sai. Góc nội tiếp chắn cung nhỏ có số đo bằng <i>một nửa</i> số đo góc ở tâm chắn cùng một cung.</p>
<p><b>d)</b> Đúng. Theo nhận xét: các góc nội tiếp bằng nhau chắn các cung bằng nhau.</p>
<p><b>Đáp số:</b> các khẳng định b) và d) đúng.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.2.</b> Cho các điểm như Hình 9.7. Tính số đo các góc của tam giác $ABC$, biết rằng $\widehat{AOB}=120^\circ$, $\widehat{BOC}=80^\circ$.</p>
<div><img src="/static/img/sgk9/sgk9-c9-h9-7.png" alt="Hình 9.7: tam giác ABC nội tiếp đường tròn tâm O với góc AOB bằng 120 độ và góc BOC bằng 80 độ"></div>
<p><i>(Hình 9.7: tam giác $ABC$ nội tiếp đường tròn $(O)$, tâm $O$ nằm trong tam giác.)</i></p>', N'<p>Vì $O$ nằm trong tam giác nên ba góc ở tâm $\widehat{AOB},\widehat{BOC},\widehat{COA}$ có tổng bằng $360^\circ$: $\widehat{AOC}=360^\circ-120^\circ-80^\circ=160^\circ$.</p>
<p>Mỗi góc của tam giác là góc nội tiếp, bằng nửa góc ở tâm chắn cùng cung:</p>
<ul>
<li>$\widehat{ACB}=\dfrac{1}{2}\widehat{AOB}=60^\circ$;</li>
<li>$\widehat{BAC}=\dfrac{1}{2}\widehat{BOC}=40^\circ$;</li>
<li>$\widehat{ABC}=\dfrac{1}{2}\widehat{AOC}=80^\circ$.</li>
</ul>
<p>Kiểm tra: $60^\circ+40^\circ+80^\circ=180^\circ$.</p>
<p><b>Đáp số:</b> $\widehat{A}=40^\circ$, $\widehat{B}=80^\circ$, $\widehat{C}=60^\circ$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.3.</b> Cho đường tròn $(O)$ và hai dây cung $AC,BD$ cắt nhau tại $X$ (H.9.8). Tính số đo góc $AXB$ biết rằng $\widehat{ADB}=30^\circ$ và $\widehat{DBC}=50^\circ$.</p>
<div><img src="/static/img/sgk9/sgk9-c9-h9-8.png" alt="Hình 9.8: hai dây cung AC và BD cắt nhau tại X trong đường tròn tâm O, góc ADB bằng 30 độ, góc DBC bằng 50 độ"></div>', N'<p>Góc $AXB$ là góc ngoài tại đỉnh $X$ của tam giác $XBC$ (vì $A,X,C$ thẳng hàng) nên $$\widehat{AXB}=\widehat{XBC}+\widehat{XCB}=\widehat{DBC}+\widehat{ACB}.$$</p>
<p>Hai góc nội tiếp $\widehat{ACB}$ và $\widehat{ADB}$ cùng chắn cung $AB$ nên $\widehat{ACB}=\widehat{ADB}=30^\circ$.</p>
<p>Suy ra $\widehat{AXB}=50^\circ+30^\circ=80^\circ$.</p>
<p><b>Đáp số:</b> $\widehat{AXB}=80^\circ$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.4.</b> Cho đường tròn $(O)$ và hai dây cung $AB,CD$ cắt nhau tại điểm $I$ nằm trong $(O)$ (H.9.9).</p>
<div><img src="/static/img/sgk9/sgk9-c9-h9-9.png" alt="Hình 9.9: hai dây cung AB và CD cắt nhau tại I trong đường tròn tâm O, góc AOC bằng 60 độ, góc BOD bằng 80 độ"></div>
<ol type="a">
<li>Biết rằng $\widehat{AOC}=60^\circ$, $\widehat{BOD}=80^\circ$. Tính số đo của góc $AID$.</li>
<li>Chứng minh rằng $IA\cdot IB=IC\cdot ID$.</li>
</ol>', N'<p><b>a)</b> Góc $AIC$ là góc ngoài tại đỉnh $I$ của tam giác $IBC$ (vì $A,I,B$ thẳng hàng) nên $\widehat{AIC}=\widehat{IBC}+\widehat{ICB}=\widehat{ABC}+\widehat{DCB}$.</p>
<p>Góc nội tiếp $\widehat{ABC}$ chắn cung $AC$ nên $\widehat{ABC}=\dfrac{1}{2}\widehat{AOC}=30^\circ$. Góc nội tiếp $\widehat{DCB}$ chắn cung $DB$ nên $\widehat{DCB}=\dfrac{1}{2}\widehat{BOD}=40^\circ$.</p>
<p>Suy ra $\widehat{AIC}=30^\circ+40^\circ=70^\circ$, do đó $\widehat{AID}=180^\circ-\widehat{AIC}=110^\circ$ (hai góc kề bù).</p>
<p><b>b)</b> Xét $\triangle IAC$ và $\triangle IDB$: $\widehat{AIC}=\widehat{DIB}$ (đối đỉnh) và $\widehat{IAC}=\widehat{BAC}=\widehat{BDC}=\widehat{IDB}$ (hai góc nội tiếp cùng chắn cung $BC$). Do đó $\triangle IAC\backsim\triangle IDB$ (g.g), suy ra $\dfrac{IA}{ID}=\dfrac{IC}{IB}$ hay $IA\cdot IB=IC\cdot ID$.</p>
<p><b>Đáp số:</b> a) $\widehat{AID}=110^\circ$. b) chứng minh như trên.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.5.</b> Cho đường tròn $(O)$, đường kính $AB$ và điểm $S$ nằm ngoài $(O)$. Cho hai đường thẳng $SA,SB$ lần lượt cắt $(O)$ tại $M$ (khác $A$) và $N$ (khác $B$). Gọi $P$ là giao điểm của $BM$ và $AN$ (H.9.10). Chứng minh rằng $SP$ vuông góc với $AB$.</p>
<div><img src="/static/img/sgk9/sgk9-c9-h9-10.png" alt="Hình 9.10: đường tròn đường kính AB, điểm S ngoài đường tròn, SA cắt đường tròn tại M, SB cắt tại N, BM cắt AN tại P"></div>', N'<p>Các góc $\widehat{AMB}$ và $\widehat{ANB}$ là góc nội tiếp chắn nửa đường tròn đường kính $AB$ nên $\widehat{AMB}=\widehat{ANB}=90^\circ$.</p>
<p>Do đó $BM\perp SA$ và $AN\perp SB$, tức $BM$ và $AN$ là hai đường cao của tam giác $SAB$ (đường cao kẻ từ $B$ và từ $A$).</p>
<p>Hai đường cao này cắt nhau tại $P$ nên $P$ là trực tâm của tam giác $SAB$. Vậy đường thẳng $SP$ là đường cao thứ ba, kẻ từ $S$, nên $SP\perp AB$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.6.</b> Trên sân bóng, khi quả bóng được đặt tại điểm phạt đền thì có góc sút bằng $36^\circ$ và quả bóng cách mỗi cọc gôn 11,6 m (H.9.11). Hỏi khi quả bóng đặt ở vị trí cách điểm phạt đền 11,6 m thì góc sút bằng bao nhiêu?</p>
<p><i>(Góc sút là góc tạo bởi hai đường thẳng nối vị trí quả bóng với hai cọc gôn.)</i></p>', N'<p>Gọi $P$ là điểm phạt đền, $A,B$ là hai cọc gôn. Theo đề, $PA=PB=11{,}6$ m và $\widehat{APB}=36^\circ$. Do đó $A,B$ nằm trên đường tròn tâm $P$ bán kính $11{,}6$ m.</p>
<p>Một vị trí $Q$ cách điểm phạt đền $11{,}6$ m thì $PQ=11{,}6$ m, nghĩa là $Q$ cũng nằm trên đường tròn $(P;11{,}6)$ (và ở phía trong sân, tức trên cung lớn $AB$).</p>
<p>Góc sút tại $Q$ là góc nội tiếp $\widehat{AQB}$ chắn cung nhỏ $AB$ của đường tròn $(P)$, còn $\widehat{APB}$ là góc ở tâm chắn cùng cung đó. Do đó $$\widehat{AQB}=\dfrac{1}{2}\widehat{APB}=\dfrac{1}{2}\cdot36^\circ=18^\circ.$$</p>
<p><b>Đáp số:</b> góc sút bằng $18^\circ$.</p>', 3, 0, 1, @t1);

-- Bài 28
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 28. Đường tròn ngoại tiếp và đường tròn nội tiếp của một tam giác', N'Đường tròn ngoại tiếp, nội tiếp tam giác; tâm và bán kính đối với tam giác vuông và tam giác đều.', N'<p><b>1. Đường tròn ngoại tiếp tam giác.</b> Đường tròn đi qua ba đỉnh của một tam giác gọi là <b>đường tròn ngoại tiếp</b> tam giác đó; khi đó tam giác nội tiếp đường tròn. Tâm $O$ là giao điểm của ba đường trung trực của tam giác (vì điểm trên đường trung trực của $AB$ cách đều $A,B$).</p>
<p><b>Tam giác vuông.</b> Đường tròn ngoại tiếp tam giác vuông có tâm là trung điểm của cạnh huyền và bán kính bằng một nửa cạnh huyền: $R=\dfrac{BC}{2}$.</p>
<p><b>Ví dụ 1.</b> Tam giác $ABC$ vuông tại $A$, $AB=2$ cm, $AC=4$ cm. Theo định lí Pythagore $BC^2=4+16=20$ nên $BC=2\sqrt{5}$ cm. Vậy $R=\dfrac{BC}{2}=\sqrt{5}$ cm. <i>(Luyện tập 1: tam giác có cạnh 3 cm, 4 cm, 5 cm là tam giác vuông có cạnh huyền 5 cm nên $R=2{,}5$ cm.)</i></p>
<p><b>Tam giác đều.</b> Đường tròn ngoại tiếp tam giác đều cạnh $a$ có tâm là trọng tâm của tam giác và bán kính $R=\dfrac{\sqrt{3}}{3}a$.</p>
<p><b>Ví dụ 2.</b> Tam giác đều cạnh 3 cm có $R=\dfrac{\sqrt{3}}{3}\cdot3=\sqrt{3}$ cm. <i>(Luyện tập 2: tam giác đều nội tiếp đường tròn bán kính 4 cm có cạnh $a=\sqrt{3}R=4\sqrt{3}$ cm.)</i></p>
<p><b>2. Đường tròn nội tiếp tam giác.</b> Đường tròn tiếp xúc với ba cạnh của tam giác gọi là <b>đường tròn nội tiếp</b> tam giác; khi đó tam giác ngoại tiếp đường tròn. Tâm đường tròn nội tiếp là giao điểm của ba đường phân giác của tam giác. Mỗi tam giác có duy nhất một đường tròn nội tiếp, nhưng có nhiều tam giác cùng ngoại tiếp một đường tròn.</p>
<p><b>Tam giác đều.</b> Đường tròn nội tiếp tam giác đều cạnh $a$ có tâm là trọng tâm của tam giác và bán kính $r=\dfrac{\sqrt{3}}{6}a$, bằng một nửa bán kính đường tròn ngoại tiếp.</p>
<p><b>Ví dụ 3.</b> Tam giác $ABC$ ngoại tiếp $(I)$ có $\widehat{A}=40^\circ$, $\widehat{B}=60^\circ$. Khi đó $\widehat{C}=80^\circ$. Vì $I$ là giao điểm các đường phân giác nên $\widehat{IAB}=20^\circ$, $\widehat{IBA}=30^\circ$, $\widehat{ICB}=40^\circ$. Suy ra $\widehat{BIC}=180^\circ-30^\circ-40^\circ=110^\circ$, $\widehat{CIA}=180^\circ-40^\circ-20^\circ=120^\circ$, $\widehat{AIB}=180^\circ-30^\circ-20^\circ=130^\circ$.</p>
<p><i>Luyện tập 3:</i> tam giác đều $ABC$ có $BC=4$ cm thì $r=\dfrac{\sqrt{3}}{6}\cdot4=\dfrac{2\sqrt{3}}{3}$ cm.</p>
<p><b>Thực hành (vẽ đường tròn nội tiếp).</b> Vẽ hai tia phân giác của hai góc của tam giác bằng thước và compa; hai tia cắt nhau tại $I$. Kẻ $ID$ vuông góc với $BC$ ($D$ thuộc $BC$) rồi vẽ đường tròn $(I;ID)$.</p>
<p><b>Em có biết: đường tròn bàng tiếp.</b> Đường tròn bàng tiếp của tam giác $ABC$ trong góc $A$ là đường tròn tiếp xúc với cạnh $BC$ và tiếp xúc với các tia đối của tia $BA$ và tia $CA$. Tâm $I_a$ là giao điểm của hai đường phân giác ngoài của góc $B$ và góc $C$; $I_a$ nằm ngoài tam giác và cách đều ba đường thẳng $AB,BC,CA$. Mỗi tam giác có ba đường tròn bàng tiếp.</p>', 2, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.7.</b> Cho đường tròn $(O)$ ngoại tiếp tam giác $ABC$. Tính bán kính của $(O)$, biết rằng $ABC$ là tam giác vuông cân tại $A$ và có độ dài cạnh bên bằng $2\sqrt{2}$ cm.</p>', N'<p>Tam giác $ABC$ vuông cân tại $A$ có $AB=AC=2\sqrt{2}$ cm. Theo định lí Pythagore: $BC^2=AB^2+AC^2=8+8=16$ nên $BC=4$ cm.</p>
<p>Đường tròn ngoại tiếp tam giác vuông có bán kính bằng nửa cạnh huyền: $R=\dfrac{BC}{2}=2$ cm.</p>
<p><b>Đáp số:</b> $R=2$ cm.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.8.</b> Cho tam giác đều $ABC$ nội tiếp đường tròn $(O)$. Biết rằng đường tròn $(O)$ có bán kính bằng 3 cm. Tính diện tích tam giác $ABC$.</p>', N'<p>Tam giác đều cạnh $a$ có bán kính đường tròn ngoại tiếp $R=\dfrac{\sqrt{3}}{3}a$, suy ra $a=\sqrt{3}R=3\sqrt{3}$ cm.</p>
<p>Diện tích tam giác đều cạnh $a$ là $S=\dfrac{\sqrt{3}}{4}a^2=\dfrac{\sqrt{3}}{4}\cdot27=\dfrac{27\sqrt{3}}{4}\ (\text{cm}^2)\approx11{,}69\ \text{cm}^2$.</p>
<p><b>Đáp số:</b> $S=\dfrac{27\sqrt{3}}{4}\ \text{cm}^2$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.9.</b> Cho tam giác $ABC$ nội tiếp đường tròn $(O)$. Gọi $H$ là trực tâm của tam giác $ABC$. Chứng minh rằng $\widehat{BAH}=\widehat{OAC}$.</p>
<p><i>(Xét tam giác $ABC$ nhọn, khi đó $O$ và $H$ nằm trong tam giác.)</i></p>', N'<p>Gọi $D$ là chân đường cao kẻ từ $A$, tức $D$ thuộc $BC$ và $AH\perp BC$ tại $D$. Trong tam giác $ABD$ vuông tại $D$: $$\widehat{BAH}=\widehat{BAD}=90^\circ-\widehat{ABC}.$$</p>
<p>Góc ở tâm $\widehat{AOC}$ và góc nội tiếp $\widehat{ABC}$ cùng chắn cung nhỏ $AC$ nên $\widehat{AOC}=2\widehat{ABC}$. Tam giác $OAC$ cân tại $O$ (vì $OA=OC$) nên $$\widehat{OAC}=\dfrac{180^\circ-\widehat{AOC}}{2}=90^\circ-\widehat{ABC}.$$</p>
<p>Vậy $\widehat{BAH}=\widehat{OAC}$.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.10.</b> Cho đường tròn $(I)$ nội tiếp tam giác $ABC$ với các tiếp điểm trên các cạnh $AB,AC$ lần lượt là $E,F$. Chứng minh rằng $\widehat{EIF}+\widehat{BAC}=180^\circ$.</p>', N'<p>Vì $(I)$ tiếp xúc với $AB$ tại $E$ và tiếp xúc với $AC$ tại $F$ nên $IE\perp AB$ và $IF\perp AC$, tức $\widehat{AEI}=\widehat{AFI}=90^\circ$.</p>
<p>Xét tứ giác $AEIF$ có tổng các góc bằng $360^\circ$: $$\widehat{EAF}+\widehat{EIF}=360^\circ-\widehat{AEI}-\widehat{AFI}=360^\circ-90^\circ-90^\circ=180^\circ.$$</p>
<p>Mà $\widehat{EAF}=\widehat{BAC}$ nên $\widehat{EIF}+\widehat{BAC}=180^\circ$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.11.</b> Cho tam giác đều $ABC$ ngoại tiếp đường tròn $(I)$. Tính độ dài các cạnh của tam giác $ABC$ biết rằng bán kính của $(I)$ bằng 1 cm.</p>', N'<p>Tam giác đều cạnh $a$ có bán kính đường tròn nội tiếp $r=\dfrac{\sqrt{3}}{6}a$.</p>
<p>Suy ra $a=\dfrac{6r}{\sqrt{3}}=2\sqrt{3}\,r=2\sqrt{3}$ cm (với $r=1$ cm).</p>
<p><b>Đáp số:</b> mỗi cạnh của tam giác $ABC$ dài $2\sqrt{3}$ cm (khoảng 3,46 cm).</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.12.</b> Người ta muốn làm một khung gỗ hình tam giác đều để đặt vừa khít một chiếc đồng hồ hình tròn có đường kính 30 cm (H.9.23). Hỏi độ dài các cạnh (phía bên trong) của khung gỗ phải bằng bao nhiêu?</p>
<p><i>(Đồng hồ hình tròn tiếp xúc với cả ba cạnh của khung tam giác đều.)</i></p>', N'<p>Đồng hồ đặt vừa khít trong khung nên đường tròn của đồng hồ là đường tròn nội tiếp tam giác đều tạo bởi khung. Bán kính $r=\dfrac{30}{2}=15$ cm.</p>
<p>Với tam giác đều cạnh $a$: $r=\dfrac{\sqrt{3}}{6}a$, suy ra $a=\dfrac{6r}{\sqrt{3}}=2\sqrt{3}\,r=2\sqrt{3}\cdot15=30\sqrt{3}\ (\text{cm})\approx51{,}96\ \text{cm}$.</p>
<p><b>Đáp số:</b> mỗi cạnh phía bên trong của khung gỗ dài $30\sqrt{3}$ cm, khoảng 52 cm.</p>', 2, 0, 1, @t1);

-- Luyện tập chung (Bài 27 - Bài 28)
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Luyện tập chung (Bài 27 - Bài 28)', N'Vận dụng góc nội tiếp, đường tròn ngoại tiếp và nội tiếp tam giác để tính góc, bán kính, chu vi và diện tích.', N'<p><b>Ví dụ 1.</b> Tam giác $ABC$ nội tiếp đường tròn $(O)$, biết $\widehat{OAB}=30^\circ$, $\widehat{OAC}=40^\circ$. Tính $\widehat{ABC}$ và $\widehat{ACB}$.</p>
<p>Tam giác $OAB$ cân tại $O$ nên $\widehat{OBA}=\widehat{OAB}=30^\circ$ và $\widehat{AOB}=180^\circ-30^\circ-30^\circ=120^\circ$. Tam giác $OAC$ cân tại $O$ nên $\widehat{OCA}=40^\circ$ và $\widehat{AOC}=180^\circ-40^\circ-40^\circ=100^\circ$. Góc nội tiếp bằng nửa góc ở tâm chắn cùng cung nhỏ nên $\widehat{ABC}=\dfrac{1}{2}\widehat{AOC}=50^\circ$ và $\widehat{ACB}=\dfrac{1}{2}\widehat{AOB}=60^\circ$.</p>
<p><b>Ví dụ 2.</b> Tam giác $ABC$ có diện tích $S$ và ngoại tiếp đường tròn $(I;r)$. Chứng minh $S=\dfrac{1}{2}r(BC+CA+AB)$.</p>
<p>Gọi $D,E,F$ là các tiếp điểm của $(I)$ với $BC,CA,AB$. Khi đó $ID=IE=IF=r$ và các đoạn này vuông góc với cạnh tương ứng. Ta có $$S=S_{BIC}+S_{CIA}+S_{AIB}=\dfrac{1}{2}ID\cdot BC+\dfrac{1}{2}IE\cdot CA+\dfrac{1}{2}IF\cdot AB=\dfrac{1}{2}r(BC+CA+AB).$$ Nếu gọi $p$ là nửa chu vi thì $S=p\cdot r$.</p>', 3, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.13.</b> Cho tam giác $ABC$ nội tiếp đường tròn $(O)$. Biết rằng $\widehat{BOC}=120^\circ$ và $\widehat{OCA}=20^\circ$. Tính số đo các góc của tam giác $ABC$.</p>
<p><i>(Xét tam giác $ABC$ nhọn, khi đó $O$ nằm trong tam giác.)</i></p>', N'<p>Góc nội tiếp $\widehat{BAC}$ và góc ở tâm $\widehat{BOC}$ cùng chắn cung $BC$ nên $\widehat{BAC}=\dfrac{1}{2}\widehat{BOC}=60^\circ$.</p>
<p>Tam giác $OAC$ cân tại $O$ nên $\widehat{OAC}=\widehat{OCA}=20^\circ$, do đó $\widehat{AOC}=180^\circ-20^\circ-20^\circ=140^\circ$. Suy ra $\widehat{ABC}=\dfrac{1}{2}\widehat{AOC}=70^\circ$.</p>
<p>Khi đó $\widehat{ACB}=180^\circ-60^\circ-70^\circ=50^\circ$.</p>
<p>Kiểm tra: $\widehat{AOB}=360^\circ-120^\circ-140^\circ=100^\circ=2\widehat{ACB}$.</p>
<p><b>Đáp số:</b> $\widehat{A}=60^\circ$, $\widehat{B}=70^\circ$, $\widehat{C}=50^\circ$.</p>
<p><i>Chú ý:</i> nếu không giả thiết tam giác nhọn thì còn trường hợp tam giác tù tại $B$ với $\widehat{A}=60^\circ$, $\widehat{B}=110^\circ$, $\widehat{C}=10^\circ$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.14.</b> Cho tam giác đều $ABC$ có độ dài cạnh bằng 4 cm. Tính bán kính đường tròn ngoại tiếp và bán kính đường tròn nội tiếp tam giác $ABC$.</p>', N'<p>Tam giác đều cạnh $a=4$ cm có:</p>
<ul>
<li>bán kính đường tròn ngoại tiếp $R=\dfrac{\sqrt{3}}{3}a=\dfrac{4\sqrt{3}}{3}$ cm $\approx2{,}31$ cm;</li>
<li>bán kính đường tròn nội tiếp $r=\dfrac{\sqrt{3}}{6}a=\dfrac{2\sqrt{3}}{3}$ cm $\approx1{,}15$ cm (bằng $\dfrac{R}{2}$).</li>
</ul>
<p><b>Đáp số:</b> $R=\dfrac{4\sqrt{3}}{3}$ cm; $r=\dfrac{2\sqrt{3}}{3}$ cm.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.15.</b> Cho tam giác đều $ABC$ có độ dài cạnh bằng 3 cm và nội tiếp đường tròn $(O)$ như Hình 9.26.</p>
<div><img src="/static/img/sgk9/sgk9-c9-h9-26.png" alt="Hình 9.26: tam giác đều ABC nội tiếp đường tròn tâm O, phần hình viên phân giới hạn bởi dây BC và cung nhỏ BC được tô màu"></div>
<ol type="a">
<li>Tính bán kính $R$ của đường tròn $(O)$.</li>
<li>Tính diện tích hình viên phân giới hạn bởi dây cung $BC$ và cung nhỏ $BC$.</li>
</ol>', N'<p><b>a)</b> $R=\dfrac{\sqrt{3}}{3}\cdot3=\sqrt{3}$ cm.</p>
<p><b>b)</b> Góc ở tâm $\widehat{BOC}=2\widehat{BAC}=120^\circ$.</p>
<ul>
<li>Diện tích hình quạt tròn $BOC$ (góc $120^\circ$): $S_{quạt}=\dfrac{120}{360}\pi R^2=\dfrac{1}{3}\pi\cdot3=\pi\ (\text{cm}^2)$.</li>
<li>Diện tích tam giác $BOC$: $S_{BOC}=\dfrac{1}{2}R^2\sin120^\circ=\dfrac{1}{2}\cdot3\cdot\dfrac{\sqrt{3}}{2}=\dfrac{3\sqrt{3}}{4}\ (\text{cm}^2)$ (cũng bằng $\dfrac{1}{3}$ diện tích tam giác $ABC$).</li>
</ul>
<p>Diện tích hình viên phân $=S_{quạt}-S_{BOC}=\pi-\dfrac{3\sqrt{3}}{4}\approx1{,}84\ \text{cm}^2$.</p>
<p><b>Đáp số:</b> a) $R=\sqrt{3}$ cm. b) $\pi-\dfrac{3\sqrt{3}}{4}\ \text{cm}^2\approx1{,}84\ \text{cm}^2$.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.16.</b> Trong một khu vui chơi có dạng hình tam giác đều với độ dài cạnh bằng 60 m, người ta muốn tìm một vị trí đặt bộ phát sóng wifi sao cho ở chỗ nào trong khu vui chơi đó đều có thể bắt được sóng. Biết rằng bộ phát sóng đó có tầm phát sóng tối đa là 50 m, hỏi có thể tìm được vị trí để đặt bộ phát sóng như vậy hay không?</p>', N'<p>Đặt bộ phát sóng tại tâm $O$ của tam giác đều (tâm đường tròn ngoại tiếp). Khoảng cách từ $O$ tới ba đỉnh đều bằng bán kính đường tròn ngoại tiếp $$R=\dfrac{\sqrt{3}}{3}\cdot60=20\sqrt{3}\approx34{,}64\ \text{m}.$$</p>
<p>Mọi điểm của khu vui chơi (tam giác) đều nằm trong đường tròn ngoại tiếp $(O;R)$, nên cách $O$ không quá $R\approx34{,}64$ m. Vì $34{,}64\lt50$ nên mọi điểm trong khu vui chơi đều nằm trong tầm phát sóng.</p>
<p><b>Đáp số:</b> có; đặt bộ phát sóng tại tâm của tam giác đều (giao ba đường trung tuyến).</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.17.</b> Người ta vẽ bản quy hoạch của một khu dân cư được bao xung quanh bởi ba con đường thẳng lập thành một tam giác với độ dài các cạnh là 900 m, 1 200 m và 1 500 m (H.9.27).</p>
<ol type="a">
<li>Tính chu vi và diện tích của phần đất giới hạn bởi tam giác trên.</li>
<li>Họ muốn xây dựng một khách sạn bên trong khu dân cư cách đều cả ba con đường đó. Hỏi khi đó khách sạn sẽ cách mỗi con đường một khoảng là bao nhiêu?</li>
</ol>', N'<p><b>a)</b> Chu vi: $900+1200+1500=3600$ m.</p>
<p>Vì $900^2+1200^2=810000+1440000=2250000=1500^2$ nên tam giác vuông (cạnh huyền 1 500 m). Diện tích $S=\dfrac{1}{2}\cdot900\cdot1200=540000\ \text{m}^2$.</p>
<p><b>b)</b> Điểm cách đều ba con đường (ba cạnh) là tâm đường tròn nội tiếp tam giác, khoảng cách tới mỗi cạnh là bán kính $r$. Nửa chu vi $p=1800$ m, áp dụng $S=p\cdot r$: $$r=\dfrac{S}{p}=\dfrac{540000}{1800}=300\ \text{m}.$$</p>
<p><b>Đáp số:</b> a) chu vi 3 600 m, diện tích $540\,000\ \text{m}^2$. b) 300 m.</p>', 2, 0, 1, @t1);

-- Bài 29
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 29. Tứ giác nội tiếp', N'Tứ giác nội tiếp, tổng hai góc đối bằng 180 độ; đường tròn ngoại tiếp hình chữ nhật và hình vuông.', N'<p><b>1. Đường tròn ngoại tiếp một tứ giác.</b> Tứ giác có bốn đỉnh nằm trên một đường tròn gọi là <b>tứ giác nội tiếp</b> đường tròn (hay tứ giác nội tiếp); đường tròn đó gọi là <b>đường tròn ngoại tiếp</b> tứ giác.</p>
<p>Không phải tứ giác nào cũng nội tiếp được đường tròn: ba đỉnh luôn nằm trên một đường tròn, nhưng đỉnh còn lại có thể không nằm trên đường tròn đó. Tứ giác $ABCD$ có $\widehat{A}=\widehat{C}=90^\circ$ thì bốn đỉnh nằm trên đường tròn đường kính $BD$.</p>
<p><b>Định lí.</b> Trong một tứ giác nội tiếp, tổng số đo hai góc đối nhau bằng $180^\circ$: nếu $ABCD$ nội tiếp $(O)$ thì $\widehat{A}+\widehat{C}=180^\circ$ và $\widehat{B}+\widehat{D}=180^\circ$.</p>
<p><i>Chứng minh.</i> Hai điểm $B,D$ chia đường tròn thành hai cung $BCD$ và $BAD$ có tổng số đo $360^\circ$. Các góc nội tiếp $\widehat{A}$, $\widehat{C}$ lần lượt chắn cung $BCD$ và $BAD$ nên $\widehat{A}+\widehat{C}=\dfrac{1}{2}\text{sđ}\ \overset{\frown}{BCD}+\dfrac{1}{2}\text{sđ}\ \overset{\frown}{BAD}=180^\circ$. Tương tự $\widehat{B}+\widehat{D}=180^\circ$.</p>
<p><b>Ví dụ 1.</b> Tứ giác nội tiếp đường tròn khi và chỉ khi bốn đỉnh đều nằm trên đường tròn; hình có ba đỉnh trên đường tròn và một đỉnh ngoài (hoặc trong) đường tròn thì không phải tứ giác nội tiếp.</p>
<p><b>Ví dụ 2.</b> Tứ giác $ABCD$ nội tiếp $(O)$, $AB$ cắt $DC$ tại $X$, $\widehat{DAB}=70^\circ$, $\widehat{ABC}=130^\circ$. Khi đó $\widehat{BCD}=180^\circ-70^\circ=110^\circ$ và $\widehat{CDA}=180^\circ-130^\circ=50^\circ$. Trong tam giác $AXD$: $\widehat{BXC}=\widehat{AXD}=180^\circ-70^\circ-50^\circ=60^\circ$.</p>
<p><b>Luyện tập 1.</b> Tam giác $ABC$ có các đường cao $BE,CF$; $\widehat{B}=60^\circ$, $\widehat{C}=80^\circ$. a) Vì $\widehat{BEC}=\widehat{BFC}=90^\circ$ nên $E,F$ nằm trên đường tròn đường kính $BC$, tức tứ giác $BCEF$ nội tiếp đường tròn tâm là trung điểm của $BC$. b) $\widehat{BFE}=180^\circ-\widehat{BCE}=180^\circ-80^\circ=100^\circ$ và $\widehat{CEF}=180^\circ-\widehat{CBF}=180^\circ-60^\circ=120^\circ$.</p>
<p><b>Thử thách nhỏ 1.</b> Nếu các đường trung trực của $AB,AC,AD$ đồng quy tại $O$ thì $OA=OB=OC=OD$, nên $A,B,C,D$ cùng nằm trên đường tròn $(O;OA)$, tức $ABCD$ nội tiếp.</p>
<p><b>2. Đường tròn ngoại tiếp hình chữ nhật và hình vuông.</b> Hình chữ nhật và hình vuông là các tứ giác nội tiếp. Đường tròn ngoại tiếp của chúng có <b>tâm là giao điểm của hai đường chéo</b> và <b>bán kính bằng một nửa độ dài đường chéo</b>.</p>
<p><b>Ví dụ 3.</b> Hình chữ nhật $ABCD$ có $AB=3$ cm, $AD=4$ cm. Đường chéo $BD^2=3^2+4^2=25$ nên $BD=5$ cm và $R=\dfrac{BD}{2}=2{,}5$ cm.</p>
<p><b>Luyện tập 2.</b> Hình thoi $ABCD$ cạnh 3 cm, $M,N,P,Q$ là trung điểm $AB,BC,CD,DA$. Ta có $MN\parallel AC\parallel QP$ và $NP\parallel BD\parallel MQ$ nên $MNPQ$ là hình bình hành; vì $AC\perp BD$ nên $MN\perp NP$, do đó $MNPQ$ là hình chữ nhật. Đường chéo $MP$ nối trung điểm hai cạnh đối nên $MP=AD=3$ cm, bán kính đường tròn ngoại tiếp là $\dfrac{MP}{2}=1{,}5$ cm.</p>
<p><b>Thử thách nhỏ 2.</b> Hai hình chữ nhật có chung một đường chéo $AC$ thì tâm đường tròn ngoại tiếp của chúng đều là trung điểm của $AC$ và bán kính đều bằng $\dfrac{AC}{2}$, nên tám đỉnh (của cả hai hình) cùng nằm trên đường tròn đường kính $AC$.</p>', 4, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.18.</b> Cho $ABCD$ là tứ giác nội tiếp. Tính số đo của các góc còn lại của tứ giác trong mỗi trường hợp sau:</p>
<ol type="a">
<li>$\widehat{A}=60^\circ$, $\widehat{B}=80^\circ$;</li>
<li>$\widehat{B}=70^\circ$, $\widehat{C}=90^\circ$;</li>
<li>$\widehat{C}=100^\circ$, $\widehat{D}=60^\circ$;</li>
<li>$\widehat{D}=110^\circ$, $\widehat{A}=80^\circ$.</li>
</ol>', N'<p>Trong tứ giác nội tiếp, hai góc đối có tổng bằng $180^\circ$: $\widehat{A}+\widehat{C}=180^\circ$ và $\widehat{B}+\widehat{D}=180^\circ$.</p>
<p><b>a)</b> $\widehat{C}=180^\circ-60^\circ=120^\circ$; $\widehat{D}=180^\circ-80^\circ=100^\circ$.</p>
<p><b>b)</b> $\widehat{D}=180^\circ-70^\circ=110^\circ$; $\widehat{A}=180^\circ-90^\circ=90^\circ$.</p>
<p><b>c)</b> $\widehat{A}=180^\circ-100^\circ=80^\circ$; $\widehat{B}=180^\circ-60^\circ=120^\circ$.</p>
<p><b>d)</b> $\widehat{B}=180^\circ-110^\circ=70^\circ$; $\widehat{C}=180^\circ-80^\circ=100^\circ$.</p>
<p><b>Đáp số:</b> a) $\widehat{C}=120^\circ$, $\widehat{D}=100^\circ$. b) $\widehat{A}=90^\circ$, $\widehat{D}=110^\circ$. c) $\widehat{A}=80^\circ$, $\widehat{B}=120^\circ$. d) $\widehat{B}=70^\circ$, $\widehat{C}=100^\circ$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.19.</b> Cho điểm $I$ nằm ngoài đường tròn $(O)$. Qua $I$ kẻ hai đường thẳng lần lượt cắt $(O)$ tại bốn điểm $A,B$ và $C,D$ sao cho $A$ nằm giữa $B$ và $I$, $C$ nằm giữa $D$ và $I$. Chứng minh rằng $\widehat{IBD}=\widehat{ICA}$, $\widehat{IAC}=\widehat{IDB}$ và $IA\cdot IB=IC\cdot ID$.</p>', N'<p>Bốn điểm $A,B,D,C$ nằm trên $(O)$ nên $ABDC$ là tứ giác nội tiếp (thứ tự các đỉnh trên đường tròn là $A,B,D,C$), có các cặp góc đối là $\widehat{B},\widehat{C}$ và $\widehat{A},\widehat{D}$.</p>
<p>Vì $C$ nằm giữa $D$ và $I$ nên $\widehat{ICA}=180^\circ-\widehat{ACD}$. Do $\widehat{ABD}+\widehat{ACD}=180^\circ$ nên $\widehat{ABD}=180^\circ-\widehat{ACD}=\widehat{ICA}$. Mà $\widehat{ABD}=\widehat{IBD}$ (vì $A$ nằm trên tia $BI$) nên $\widehat{IBD}=\widehat{ICA}$.</p>
<p>Tương tự, $A$ nằm giữa $B$ và $I$ nên $\widehat{IAC}=180^\circ-\widehat{BAC}$; do $\widehat{BAC}+\widehat{BDC}=180^\circ$ nên $\widehat{IAC}=\widehat{BDC}=\widehat{IDB}$.</p>
<p>Từ hai đẳng thức góc trên và góc $\widehat{I}$ chung, $\triangle IAC\backsim\triangle IDB$ (g.g), suy ra $\dfrac{IA}{ID}=\dfrac{IC}{IB}$, tức $IA\cdot IB=IC\cdot ID$.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.20.</b> Cho hình bình hành $ABCD$ nội tiếp đường tròn $(O)$. Chứng minh rằng $ABCD$ là hình chữ nhật.</p>', N'<p>Vì $ABCD$ nội tiếp $(O)$ nên hai góc đối có tổng $\widehat{A}+\widehat{C}=180^\circ$.</p>
<p>Vì $ABCD$ là hình bình hành nên hai góc đối bằng nhau: $\widehat{A}=\widehat{C}$.</p>
<p>Suy ra $2\widehat{A}=180^\circ$, tức $\widehat{A}=90^\circ$. Hình bình hành có một góc vuông là hình chữ nhật.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.21.</b> Cho hình thang $ABCD$ ($AB$ song song với $CD$) nội tiếp đường tròn $(O)$. Chứng minh rằng $ABCD$ là hình thang cân.</p>', N'<p>Vì $AB\parallel CD$ nên hai góc trong cùng phía bù nhau: $\widehat{A}+\widehat{D}=180^\circ$ (1).</p>
<p>Vì $ABCD$ nội tiếp $(O)$ nên $\widehat{A}+\widehat{C}=180^\circ$ (2).</p>
<p>Từ (1) và (2) suy ra $\widehat{C}=\widehat{D}$. Hình thang có hai góc ở đáy $CD$ bằng nhau là hình thang cân.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.22.</b> Tính diện tích của một hình chữ nhật, biết rằng hình chữ nhật đó có chiều dài gấp hai lần chiều rộng và bán kính đường tròn ngoại tiếp bằng 2,5 cm.</p>', N'<p>Bán kính đường tròn ngoại tiếp hình chữ nhật bằng một nửa đường chéo nên đường chéo dài $2\cdot2{,}5=5$ cm.</p>
<p>Gọi chiều rộng là $x$ (cm, $x\gt0$) thì chiều dài là $2x$. Theo định lí Pythagore: $x^2+(2x)^2=5^2$ hay $5x^2=25$, suy ra $x^2=5$.</p>
<p>Diện tích $S=x\cdot2x=2x^2=10\ \text{cm}^2$ (với $x=\sqrt{5}$ cm, chiều dài $2\sqrt{5}$ cm).</p>
<p><b>Đáp số:</b> $10\ \text{cm}^2$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.23.</b> Người ta muốn dựng một khung cổng hình chữ nhật rộng 4 m và cao 3 m, bên ngoài khung cổng được bao bởi một khung thép dạng nửa đường tròn như Hình 9.37. Tính chiều dài của đoạn thép làm khung nửa đường tròn đó.</p>
<div><img src="/static/img/sgk9/sgk9-c9-h9-37.png" alt="Hình 9.37: khung cổng hình chữ nhật rộng 4 m cao 3 m, hai đỉnh trên nằm trên nửa đường tròn có đường kính nằm trên cạnh đáy"></div>', N'<p>Nửa đường tròn có đường kính nằm trên đường thẳng chứa cạnh đáy của khung cổng, tâm $O$ là trung điểm của cạnh đáy hình chữ nhật. Hai đỉnh phía trên của hình chữ nhật nằm trên nửa đường tròn.</p>
<p>Gọi $A$ là một đỉnh phía trên: $A$ cách $O$ theo phương ngang $\dfrac{4}{2}=2$ m và theo phương thẳng đứng $3$ m. Bán kính $$R=OA=\sqrt{2^2+3^2}=\sqrt{13}\ \text{m}.$$</p>
<p>Chiều dài đoạn thép bằng nửa chu vi đường tròn: $\pi R=\pi\sqrt{13}\approx11{,}33$ m.</p>
<p><b>Đáp số:</b> $\pi\sqrt{13}\approx11{,}33$ m.</p>', 2, 0, 1, @t1);

-- Bài 30
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 30. Đa giác đều', N'Khái niệm đa giác, đa giác đều, đường tròn ngoại tiếp đa giác đều và phép quay giữ nguyên đa giác đều.', N'<p><b>1. Đa giác đều.</b> Đa giác $ABCDE$ là hình gồm năm đoạn thẳng $AB,BC,CD,DE,EA$, trong đó bất kì hai đoạn thẳng nào có một điểm chung cũng không cùng nằm trên một đường thẳng. Các điểm $A,B,C,D,E$ là các đỉnh, các đoạn thẳng là các cạnh, các góc $\widehat{EAB},\widehat{ABC},\ldots$ là các góc của đa giác. Nếu với một cạnh bất kì, các đỉnh không thuộc cạnh đó nằm về một phía đối với đường thẳng chứa cạnh thì đa giác gọi là <b>đa giác lồi</b>.</p>
<p><b>Định nghĩa.</b> <b>Đa giác đều</b> là một đa giác lồi có các cạnh bằng nhau và các góc bằng nhau.</p>
<p>Các đỉnh của mỗi đa giác đều luôn cùng nằm trên một đường tròn (đường tròn ngoại tiếp đa giác); tâm đường tròn là tâm của đa giác. Chẳng hạn, lấy $n$ điểm chia đường tròn thành $n$ cung bằng nhau thì được đa giác đều $n$ cạnh; với ngũ giác đều mỗi cung có số đo $\dfrac{360^\circ}{5}=72^\circ$.</p>
<p><b>Lục giác đều</b> nội tiếp đường tròn bán kính $R$ có cạnh bằng $R$ (vì các tam giác $OAB,\ldots$ đều) và mỗi góc bằng $120^\circ$. <b>Bát giác đều</b> có mỗi góc bằng $135^\circ$.</p>
<p><b>Ví dụ 1.</b> Các đa giác đều thường gặp: tam giác đều, hình vuông, ngũ giác đều, lục giác đều, bát giác đều. Trong nghệ thuật, kiến trúc, công nghệ chế tạo và thế giới tự nhiên có nhiều hình có dạng đa giác đều (gạch lát hình vuông, mặt bàn hình bát giác, mặt đế đinh ốc, lỗ tổ ong,...).</p>
<p><b>Ví dụ 2.</b> Trong bốn hình: hình a (hình chữ L) không phải đa giác lồi; hình b là hình thoi có các góc không bằng nhau; hình c là bát giác có các cạnh không bằng nhau; hình d là hình vuông. Chỉ hình d có dạng đa giác đều.</p>
<p><b>Ví dụ 3.</b> Tam giác đều $ABC$ cạnh 6 cm; các điểm $M,N$ trên $AB$, $P,Q$ trên $BC$, $E,F$ trên $CA$ sao cho $AM=MN=NB=BP=PQ=QC=CE=EF=FA=2$ cm. Vì $\dfrac{AM}{AB}=\dfrac{AF}{AC}=\dfrac{1}{3}$ nên $MF\parallel BC$ và $MF=\dfrac{BC}{3}=2$ cm; tương tự $NP=QE=2$ cm, nên $MNPQEF$ có tất cả các cạnh bằng 2 cm. Tam giác $AMF$ đều nên $\widehat{FMA}=60^\circ$ và $\widehat{FMN}=120^\circ$; các góc ở $N,P,Q,E,F$ cũng bằng $120^\circ$. Vậy $MNPQEF$ là lục giác đều.</p>
<p><b>Luyện tập 1.</b> $M,N,P,Q,K$ là trung điểm các cạnh $AB,BC,CD,DE,EA$ của ngũ giác đều $ABCDE$. Năm tam giác $AMK,BMN,\ldots$ là các tam giác cân bằng nhau (c.g.c) nên $MN=NP=PQ=QK=KM$; mỗi góc của ngũ giác $MNPQK$ bằng $180^\circ-2\cdot\dfrac{180^\circ-108^\circ}{2}=108^\circ$. Vậy $MNPQK$ là ngũ giác đều.</p>
<p><b>2. Phép quay.</b> Phép quay thuận chiều $\alpha^\circ$ ($0^\circ\lt\alpha^\circ\lt360^\circ$) tâm $O$ giữ nguyên điểm $O$ và biến điểm $A$ khác $O$ thành điểm $B$ thuộc đường tròn $(O;OA)$ sao cho tia $OA$ quay thuận chiều quay của kim đồng hồ đến tia $OB$ thì điểm $A$ tạo nên cung $AB$ có số đo $\alpha^\circ$. Phép quay ngược chiều $\alpha^\circ$ được định nghĩa tương tự. Phép quay $0^\circ$ và $360^\circ$ giữ nguyên mọi điểm. Phép quay ngược chiều $\alpha^\circ$ biến $A$ thành $B$ thì phép quay thuận chiều $\alpha^\circ$ biến $B$ thành $A$.</p>
<p><b>Ví dụ 4.</b> Tam giác đều $ABC$ nội tiếp $(O)$ ($A,B,C$ theo chiều ngược kim đồng hồ). Các phép quay ngược chiều $120^\circ,240^\circ,360^\circ$ tâm $O$ biến $A,B,C$ thành: $120^\circ$: $B,C,A$; $240^\circ$: $C,A,B$; $360^\circ$: $A,B,C$. Ba phép quay này giữ nguyên tam giác đều $ABC$.</p>
<p>Một phép quay gọi là <b>giữ nguyên</b> một đa giác đều nếu nó biến mỗi điểm của đa giác thành một điểm của đa giác; một phép quay biến các đỉnh của đa giác đều thành các đỉnh của nó thì giữ nguyên đa giác đó.</p>
<p><b>Luyện tập 2.</b> Hình vuông $ABCD$ nội tiếp $(O)$ ($A,B,C,D$ theo chiều kim đồng hồ). Phép quay thuận chiều $90^\circ$ tâm $O$ biến $A,B,C,D$ thành $B,C,D,A$, nên giữ nguyên hình vuông. Ba phép quay thuận chiều khác giữ nguyên hình vuông là $180^\circ$, $270^\circ$ và $360^\circ$.</p>
<p><b>Thử thách nhỏ 2.</b> Sáu phép quay giữ nguyên lục giác đều nội tiếp $(O)$ là các phép quay thuận chiều $60^\circ,120^\circ,180^\circ,240^\circ,300^\circ,360^\circ$ tâm $O$.</p>', 5, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.24.</b> Trong các hình phẳng sau (H.9.52), hình nào là hình phẳng có dạng đa giác đều?</p>
<div><img src="/static/img/sgk9/sgk9-c9-h9-52.png" alt="Hình 9.52: năm hình phẳng gồm a) ngôi sao sáu cánh, b) hình vuông, c) hình dấu cộng, d) hình lục giác, e) ngôi sao năm cánh"></div>
<p><i>(Hình a: ngôi sao sáu cánh; hình b: hình vuông; hình c: hình dấu cộng; hình d: lục giác; hình e: ngôi sao năm cánh.)</i></p>', N'<p>Đa giác đều phải là đa giác lồi có các cạnh bằng nhau và các góc bằng nhau.</p>
<ul>
<li>Hình a (ngôi sao sáu cánh), hình c (dấu cộng) và hình e (ngôi sao năm cánh) có các đỉnh lõm vào trong nên không phải đa giác lồi.</li>
<li>Hình b là hình vuông: lồi, bốn cạnh bằng nhau, bốn góc vuông.</li>
<li>Hình d là lục giác lồi có các cạnh bằng nhau và các góc bằng nhau.</li>
</ul>
<p><b>Đáp số:</b> hình b (hình vuông) và hình d (lục giác đều).</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.25.</b> Trong các hình dưới đây (H.9.53), hình nào vẽ hai điểm $M$ và $N$ thoả mãn phép quay thuận chiều $60^\circ$ tâm $O$ biến điểm $M$ thành điểm $N$?</p>
<div><img src="/static/img/sgk9/sgk9-c9-h9-53.png" alt="Hình 9.53: bốn hình a, b, c, d vẽ hai điểm M, N và tâm O với góc 60 độ hoặc 50 độ"></div>', N'<p>Để phép quay thuận chiều $60^\circ$ tâm $O$ biến $M$ thành $N$ thì phải có hai điều kiện: $OM=ON$ và tia $OM$ quay <i>thuận chiều kim đồng hồ</i> một góc $60^\circ$ thì trùng tia $ON$.</p>
<ul>
<li>Hình a: $OM$ và $ON$ không được đánh dấu bằng nhau nên chưa có $OM=ON$ — không thoả mãn.</li>
<li>Hình b: $OM=ON$ và $\widehat{MON}=60^\circ$ nhưng từ $OM$ sang $ON$ là quay <i>ngược</i> chiều kim đồng hồ — đây là phép quay ngược chiều $60^\circ$, không thoả mãn.</li>
<li>Hình c: góc bằng $50^\circ$ — không thoả mãn.</li>
<li>Hình d: $OM=ON$, $\widehat{MON}=60^\circ$ và từ $OM$ (hướng lên) quay xuống $ON$ (nằm ngang bên phải) là thuận chiều kim đồng hồ — thoả mãn.</li>
</ul>
<p><b>Đáp số:</b> hình d.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.26.</b> Cho tam giác đều $ABC$ nội tiếp đường tròn $(O)$ bán kính 2 cm. Tính độ dài các cạnh của tam giác $ABC$.</p>', N'<p>Tam giác đều cạnh $a$ nội tiếp đường tròn bán kính $R=\dfrac{\sqrt{3}}{3}a$, suy ra $a=\sqrt{3}R=2\sqrt{3}$ cm.</p>
<p><b>Đáp số:</b> $AB=BC=CA=2\sqrt{3}$ cm (khoảng 3,46 cm).</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.27.</b> Cho hình thoi $ABCD$ có $\widehat{A}=60^\circ$. Gọi $M,N,P,Q$ lần lượt là trung điểm của $AB,BC,CD,DA$. Chứng minh rằng $MBNPDQ$ là lục giác đều.</p>', N'<p>Gọi cạnh hình thoi là $a$. Hình thoi có $\widehat{A}=\widehat{C}=60^\circ$ và $\widehat{B}=\widehat{D}=120^\circ$.</p>
<p><b>Các cạnh bằng nhau.</b> $MB=BN=PD=DQ=\dfrac{a}{2}$ (các điểm là trung điểm). Tam giác $CNP$ có $CN=CP=\dfrac{a}{2}$ và $\widehat{C}=60^\circ$ nên là tam giác đều, suy ra $NP=\dfrac{a}{2}$ và $\widehat{CNP}=\widehat{CPN}=60^\circ$. Tương tự tam giác $AMQ$ đều nên $MQ=\dfrac{a}{2}$ và $\widehat{AMQ}=\widehat{AQM}=60^\circ$. Vậy sáu cạnh $MB,BN,NP,PD,DQ,QM$ đều bằng $\dfrac{a}{2}$.</p>
<p><b>Các góc bằng nhau.</b> Tại $B$: $\widehat{MBN}=\widehat{ABC}=120^\circ$. Tại $D$: $\widehat{PDQ}=\widehat{CDA}=120^\circ$. Tại $N$: $\widehat{BNP}=180^\circ-\widehat{CNP}=120^\circ$. Tại $P$: $\widehat{NPD}=180^\circ-\widehat{CPN}=120^\circ$. Tại $Q$: $\widehat{DQM}=180^\circ-\widehat{AQM}=120^\circ$. Tại $M$: $\widehat{QMB}=180^\circ-\widehat{AMQ}=120^\circ$.</p>
<p>Lục giác $MBNPDQ$ lồi (các góc đều nhỏ hơn $180^\circ$), có các cạnh bằng nhau và các góc bằng nhau nên là lục giác đều.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.28.</b> Cho tam giác đều $ABC$ nội tiếp đường tròn $(O)$ như Hình 9.54. Phép quay ngược chiều $60^\circ$ tâm $O$ biến các điểm $A,B,C$ lần lượt thành các điểm $D,E,F$. Chứng minh rằng $ADBECF$ là một lục giác đều.</p>
<div><img src="/static/img/sgk9/sgk9-c9-h9-54.png" alt="Hình 9.54: tam giác đều ABC nội tiếp đường tròn tâm O, A ở trên cùng, B ở dưới bên trái, C ở bên phải"></div>', N'<p>Tam giác đều $ABC$ nội tiếp $(O)$ nên $\widehat{AOB}=\widehat{BOC}=\widehat{COA}=120^\circ$; các điểm $A,B,C$ theo thứ tự ngược chiều kim đồng hồ (theo hình vẽ).</p>
<p>Phép quay ngược chiều $60^\circ$ tâm $O$ biến $A,B,C$ thành $D,E,F$ nên $\widehat{AOD}=\widehat{BOE}=\widehat{COF}=60^\circ$ và $D,E,F$ lần lượt nằm trên các cung $AB$, $BC$, $CA$ (mỗi cung $120^\circ$), tại điểm chính giữa của cung đó. Khi đó $\widehat{DOB}=120^\circ-60^\circ=60^\circ$, và tương tự $\widehat{EOC}=\widehat{FOA}=60^\circ$.</p>
<p>Vậy sáu điểm $A,D,B,E,C,F$ chia đường tròn $(O)$ thành sáu cung bằng nhau, mỗi cung $60^\circ$. Mỗi tam giác $OAD,ODB,\ldots$ cân có góc ở đỉnh $O$ bằng $60^\circ$ nên đều, do đó các cạnh $AD,DB,BE,EC,CF,FA$ đều bằng $R$. Mỗi góc của lục giác là góc nội tiếp chắn cung $240^\circ$ nên bằng $120^\circ$.</p>
<p>Lục giác $ADBECF$ lồi, có các cạnh bằng nhau và các góc bằng nhau nên là lục giác đều.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.29.</b> Liệt kê năm phép quay giữ nguyên một ngũ giác đều nội tiếp một đường tròn tâm $O$.</p>', N'<p>Ngũ giác đều có 5 đỉnh chia đường tròn thành 5 cung bằng nhau, mỗi cung $\dfrac{360^\circ}{5}=72^\circ$. Các phép quay tâm $O$ biến mỗi đỉnh thành một đỉnh của ngũ giác (nên giữ nguyên ngũ giác) là các phép quay có góc là bội của $72^\circ$.</p>
<p><b>Đáp số:</b> năm phép quay thuận chiều tâm $O$ với góc $72^\circ$, $144^\circ$, $216^\circ$, $288^\circ$ và $360^\circ$ (cũng có thể dùng các phép quay ngược chiều với cùng các góc đó).</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.30.</b> Cho vòng quay mặt trời gồm tám cabin như Hình 9.55. Hỏi để cabin $A$ di chuyển đến vị trí cao nhất thì vòng quay phải quay thuận chiều quay của kim đồng hồ quanh tâm bao nhiêu độ?</p>
<div><img src="/static/img/sgk9/sgk9-c9-h9-55.png" alt="Hình 9.55: vòng quay mặt trời gồm tám cabin, cabin A ở phía dưới bên trái, vị trí cao nhất ở trên cùng"></div>', N'<p>Tám cabin được gắn cách đều trên vòng quay nên hai cabin liên tiếp cách nhau góc ở tâm $\dfrac{360^\circ}{8}=45^\circ$.</p>
<p>Theo hình, cabin $A$ nằm ở phía dưới bên trái. Đi theo chiều kim đồng hồ từ $A$: qua cabin bên trái, rồi cabin phía trên bên trái, rồi tới vị trí cao nhất, tức cần qua 3 vị trí liên tiếp, mỗi vị trí $45^\circ$.</p>
<p>Góc cần quay là $3\cdot45^\circ=135^\circ$.</p>
<p><b>Đáp số:</b> $135^\circ$.</p>', 2, 0, 1, @t1);

-- Luyện tập chung (Bài 29 - Bài 30)
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Luyện tập chung (Bài 29 - Bài 30)', N'Vận dụng tứ giác nội tiếp, đa giác đều và phép quay để tính góc và chứng minh.', N'<p><b>Ví dụ 1.</b> Tứ giác $ABCD$ nội tiếp $(O)$, biết $\widehat{AOB}=120^\circ$, $\widehat{BOC}=40^\circ$, $\widehat{COD}=80^\circ$. Tính các góc của tứ giác $ABCD$.</p>
<p>Các góc nội tiếp bằng nửa góc ở tâm chắn cùng cung: $\widehat{ADB}=\dfrac{1}{2}\widehat{AOB}=60^\circ$; $\widehat{BAC}=\widehat{BDC}=\dfrac{1}{2}\widehat{BOC}=20^\circ$; $\widehat{CAD}=\dfrac{1}{2}\widehat{COD}=40^\circ$. Suy ra $\widehat{BAD}=\widehat{BAC}+\widehat{CAD}=60^\circ$ và $\widehat{ADC}=\widehat{ADB}+\widehat{BDC}=80^\circ$. Vì tổng hai góc đối bằng $180^\circ$ nên $\widehat{ABC}=180^\circ-80^\circ=100^\circ$ và $\widehat{BCD}=180^\circ-60^\circ=120^\circ$.</p>
<p><b>Ví dụ 2.</b> Cho lục giác đều $ABCDEF$. a) Lục giác đều có các góc bằng $120^\circ$ và nội tiếp một đường tròn $(O)$ nên các tứ giác $ABCF,ABDF,ADEF$ nội tiếp $(O)$. Do đó $\widehat{BCF}=180^\circ-\widehat{BAF}=60^\circ$; tương tự $\widehat{BDF}=\widehat{BEF}=60^\circ$. b) Tam giác $ACE$ có các góc bằng $60^\circ$ nên đều và nội tiếp $(O)$; ba phép quay tâm $O$ giữ nguyên tam giác $ACE$ là các phép quay thuận chiều $120^\circ,240^\circ,360^\circ$.</p>', 6, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.31.</b> Cho tam giác $ABC$ có các đường cao $AD,BE,CF$. Chứng minh rằng $BCEF$, $CAFD$, $ABDE$ là những tứ giác nội tiếp.</p>', N'<p>Vì $BE\perp AC$ và $CF\perp AB$ nên $\widehat{BEC}=\widehat{BFC}=90^\circ$. Hai điểm $E,F$ cùng nhìn đoạn $BC$ dưới góc vuông nên nằm trên đường tròn đường kính $BC$. Vậy bốn điểm $B,C,E,F$ cùng nằm trên một đường tròn, tức $BCEF$ nội tiếp.</p>
<p>Vì $AD\perp BC$ và $CF\perp AB$ nên $\widehat{ADC}=\widehat{AFC}=90^\circ$: $D,F$ nằm trên đường tròn đường kính $AC$, nên $CAFD$ nội tiếp.</p>
<p>Vì $AD\perp BC$ và $BE\perp AC$ nên $\widehat{ADB}=\widehat{AEB}=90^\circ$: $D,E$ nằm trên đường tròn đường kính $AB$, nên $ABDE$ nội tiếp.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.32.</b> Cho tứ giác $ABCD$ nội tiếp đường tròn $(O)$, $AB$ cắt $CD$ tại $E$, $AD$ cắt $BC$ tại $F$ như Hình 9.58. Biết $\widehat{BEC}=40^\circ$ và $\widehat{DFC}=20^\circ$, tính số đo các góc của tứ giác $ABCD$.</p>
<div><img src="/static/img/sgk9/sgk9-c9-h9-58.png" alt="Hình 9.58: tứ giác ABCD nội tiếp đường tròn tâm O, AB và CD cắt nhau tại E, AD và BC cắt nhau tại F, góc BEC bằng 40 độ và góc DFC bằng 20 độ"></div>', N'<p>Gọi các góc của tứ giác là $\widehat{A},\widehat{B},\widehat{C},\widehat{D}$. Vì $ABCD$ nội tiếp nên $\widehat{A}+\widehat{C}=180^\circ$ và $\widehat{B}+\widehat{D}=180^\circ$.</p>
<p>Xét tam giác $EBC$: $B$ nằm giữa $A$ và $E$ nên $\widehat{EBC}=180^\circ-\widehat{B}$; $C$ nằm giữa $D$ và $E$ nên $\widehat{ECB}=180^\circ-\widehat{C}$. Tổng ba góc bằng $180^\circ$: $40^\circ+(180^\circ-\widehat{B})+(180^\circ-\widehat{C})=180^\circ$, suy ra $\widehat{B}+\widehat{C}=220^\circ$. (1)</p>
<p>Xét tam giác $FDC$: $D$ nằm giữa $A$ và $F$ nên $\widehat{FDC}=180^\circ-\widehat{D}$; $C$ nằm giữa $B$ và $F$ nên $\widehat{FCD}=180^\circ-\widehat{C}$. Do đó $20^\circ+(180^\circ-\widehat{D})+(180^\circ-\widehat{C})=180^\circ$, suy ra $\widehat{C}+\widehat{D}=200^\circ$. (2)</p>
<p>Lấy (1) trừ (2): $\widehat{B}-\widehat{D}=20^\circ$. Kết hợp $\widehat{B}+\widehat{D}=180^\circ$ được $\widehat{B}=100^\circ$, $\widehat{D}=80^\circ$. Từ (1): $\widehat{C}=120^\circ$; từ $\widehat{A}+\widehat{C}=180^\circ$: $\widehat{A}=60^\circ$.</p>
<p>Kiểm tra: $60^\circ+100^\circ+120^\circ+80^\circ=360^\circ$.</p>
<p><b>Đáp số:</b> $\widehat{A}=60^\circ$, $\widehat{B}=100^\circ$, $\widehat{C}=120^\circ$, $\widehat{D}=80^\circ$.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.33.</b> Cho hình vuông $ABCD$ có cạnh bằng 4 cm. Tính chu vi, diện tích của các đường tròn nội tiếp và ngoại tiếp hình vuông $ABCD$.</p>', N'<p><b>Đường tròn ngoại tiếp.</b> Đường chéo hình vuông $AC=4\sqrt{2}$ cm, bán kính $R=\dfrac{AC}{2}=2\sqrt{2}$ cm. Chu vi $C=2\pi R=4\sqrt{2}\,\pi\approx17{,}77$ cm; diện tích $S=\pi R^2=8\pi\approx25{,}13\ \text{cm}^2$.</p>
<p><b>Đường tròn nội tiếp.</b> Có tâm là tâm hình vuông và tiếp xúc với bốn cạnh nên bán kính bằng nửa cạnh: $r=\dfrac{4}{2}=2$ cm. Chu vi $C=2\pi r=4\pi\approx12{,}57$ cm; diện tích $S=\pi r^2=4\pi\approx12{,}57\ \text{cm}^2$.</p>
<p><b>Đáp số:</b> đường tròn ngoại tiếp: chu vi $4\sqrt{2}\,\pi$ cm, diện tích $8\pi\ \text{cm}^2$; đường tròn nội tiếp: chu vi $4\pi$ cm, diện tích $4\pi\ \text{cm}^2$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.34.</b> Biết rằng bốn đỉnh $A,B,C,D$ của một hình vuông cùng nằm trên một đường tròn $(O)$ theo thứ tự ngược chiều quay của kim đồng hồ. Phép quay thuận chiều $45^\circ$ biến các điểm $A,B,C,D$ lần lượt thành các điểm $E,F,G,H$.</p>
<ol type="a">
<li>Vẽ đa giác $EAFBGCHD$.</li>
<li>Đa giác $EAFBGCHD$ có phải là một bát giác đều hay không? Vì sao?</li>
</ol>', N'<p><b>a)</b> Vẽ đường tròn $(O)$ và hình vuông $ABCD$ nội tiếp, các đỉnh $A,B,C,D$ theo chiều ngược chiều kim đồng hồ. Quay thuận chiều $45^\circ$ tâm $O$: $E,F,G,H$ lần lượt là điểm chính giữa của các cung $DA$, $AB$, $BC$, $CD$ (mỗi cung $90^\circ$). Nối lần lượt tám điểm theo thứ tự $E,A,F,B,G,C,H,D$ trên đường tròn ta được đa giác $EAFBGCHD$.</p>
<p><b>b)</b> Có. Tám điểm $E,A,F,B,G,C,H,D$ nằm trên đường tròn $(O)$ và chia đường tròn thành tám cung bằng nhau, mỗi cung $45^\circ$ (vì $\widehat{AOB}=90^\circ$, $\widehat{AOF}=45^\circ$ nên $\widehat{FOB}=45^\circ$, tương tự các cung còn lại). Các dây căng các cung bằng nhau thì bằng nhau, nên tám cạnh bằng nhau; mỗi góc của đa giác là góc nội tiếp chắn cung $360^\circ-90^\circ=270^\circ$ nên bằng $135^\circ$, tức các góc bằng nhau. Đa giác lồi có các cạnh bằng nhau và các góc bằng nhau nên là bát giác đều.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.35.</b> Cho ngũ giác đều $ABCDE$ nội tiếp đường tròn $(O)$ như Hình 9.59.</p>
<div><img src="/static/img/sgk9/sgk9-c9-h9-59.png" alt="Hình 9.59: ngũ giác đều ABCDE nội tiếp đường tròn tâm O, A ở trên bên trái, E ở trên bên phải, D ở bên phải, C ở dưới cùng, B ở bên trái"></div>
<ol type="a">
<li>Hãy tìm một phép quay thuận chiều tâm $O$ biến điểm $A$ thành điểm $C$.</li>
<li>Phép quay trên sẽ biến các điểm $B,C,D,E$ lần lượt thành những điểm nào? Phép quay này có giữ nguyên ngũ giác đều $ABCDE$ không?</li>
</ol>', N'<p><b>a)</b> Các đỉnh $A,B,C,D,E$ chia đường tròn thành 5 cung bằng nhau, mỗi cung $72^\circ$; theo hình vẽ các đỉnh $A,B,C,D,E$ nằm theo chiều ngược chiều kim đồng hồ. Từ $A$ đi ngược chiều kim đồng hồ tới $C$ qua hai cung (tức $144^\circ$), nên đi thuận chiều kim đồng hồ từ $A$ tới $C$ phải qua $360^\circ-144^\circ=216^\circ$.</p>
<p>Vậy phép quay thuận chiều $216^\circ$ tâm $O$ biến $A$ thành $C$.</p>
<p><b>b)</b> Phép quay này quay mỗi đỉnh một góc $216^\circ$ thuận chiều (tức bằng ba cung, cùng chiều kim đồng hồ), nên biến $B$ thành $D$, $C$ thành $E$, $D$ thành $A$ và $E$ thành $B$.</p>
<p>Phép quay biến các đỉnh của ngũ giác đều thành các đỉnh của nó nên giữ nguyên ngũ giác đều $ABCDE$.</p>
<p><b>Đáp số:</b> a) phép quay thuận chiều $216^\circ$. b) $B\to D$, $C\to E$, $D\to A$, $E\to B$; có giữ nguyên ngũ giác đều.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.36.</b> Người ta muốn làm một khay đựng bánh kẹo hình lục giác đều có cạnh 10 cm và chia thành 7 ngăn gồm một lục giác đều nhỏ và 6 hình thang cân như Hình 9.60. Hỏi lục giác đều nhỏ phải có cạnh bằng bao nhiêu để nó có diện tích bằng hai lần diện tích mỗi hình thang?</p>
<div><img src="/static/img/sgk9/sgk9-c9-h9-60.png" alt="Hình 9.60: khay đựng bánh kẹo hình lục giác đều chia thành một lục giác đều nhỏ ở giữa và sáu hình thang cân xung quanh"></div>', N'<p>Diện tích lục giác đều cạnh $a$ là $S=\dfrac{3\sqrt{3}}{2}a^2$ (gồm 6 tam giác đều cạnh $a$). Diện tích khay: $S_1=\dfrac{3\sqrt{3}}{2}\cdot10^2=150\sqrt{3}\ (\text{cm}^2)$.</p>
<p>Gọi cạnh lục giác nhỏ là $x$ (cm, $0\lt x\lt10$), diện tích $S_2=\dfrac{3\sqrt{3}}{2}x^2$. Sáu hình thang cân bằng nhau, mỗi hình có diện tích $T$; theo đề $S_2=2T$, tức $T=\dfrac{S_2}{2}$.</p>
<p>Khay gồm lục giác nhỏ và 6 hình thang: $S_1=S_2+6T=S_2+3S_2=4S_2$. Suy ra $S_2=\dfrac{S_1}{4}=\dfrac{150\sqrt{3}}{4}$, tức $\dfrac{3\sqrt{3}}{2}x^2=\dfrac{150\sqrt{3}}{4}$, hay $x^2=\dfrac{150}{4}\cdot\dfrac{2}{3}=25$.</p>
<p>Vì $x\gt0$ nên $x=5$ (cm).</p>
<p><b>Đáp số:</b> lục giác đều nhỏ có cạnh 5 cm (bằng nửa cạnh khay).</p>', 3, 0, 1, @t1);

-- Bài tập cuối chương IX
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài tập cuối chương IX', N'Ôn tập chương IX: góc nội tiếp, đường tròn ngoại tiếp và nội tiếp, tứ giác nội tiếp, đa giác đều và phép quay.', N'<p><b>Tóm tắt kiến thức chương IX.</b></p>
<ul>
<li><b>Góc nội tiếp:</b> số đo bằng nửa số đo cung bị chắn; các góc nội tiếp cùng chắn một cung thì bằng nhau; góc nội tiếp chắn nửa đường tròn là góc vuông.</li>
<li><b>Đường tròn ngoại tiếp tam giác</b> có tâm là giao ba đường trung trực; tam giác vuông: tâm là trung điểm cạnh huyền, $R=\dfrac{BC}{2}$; tam giác đều cạnh $a$: $R=\dfrac{\sqrt{3}}{3}a$.</li>
<li><b>Đường tròn nội tiếp tam giác</b> có tâm là giao ba đường phân giác; $S=p\cdot r$ ($p$ là nửa chu vi); tam giác đều cạnh $a$: $r=\dfrac{\sqrt{3}}{6}a$.</li>
<li><b>Tứ giác nội tiếp:</b> tổng hai góc đối bằng $180^\circ$; hình chữ nhật và hình vuông nội tiếp đường tròn tâm là giao hai đường chéo.</li>
<li><b>Đa giác đều</b> là đa giác lồi có các cạnh bằng nhau và các góc bằng nhau; mọi đa giác đều nội tiếp một đường tròn. Lục giác đều cạnh $a$ nội tiếp đường tròn bán kính $R=a$ và có diện tích $\dfrac{3\sqrt{3}}{2}a^2$.</li>
<li><b>Phép quay</b> thuận chiều (ngược chiều) $\alpha^\circ$ tâm $O$ biến $A$ thành $B$ thuộc $(O;OA)$ với cung $AB$ có số đo $\alpha^\circ$. Đa giác đều $n$ cạnh có $n$ phép quay giữ nguyên, với các góc là bội của $\dfrac{360^\circ}{n}$.</li>
</ul>', 7, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 9.37.</b> Khẳng định nào sau đây là đúng?</p>', N'<p>Theo định lí, góc nội tiếp có số đo bằng <b>một nửa</b> số đo cung bị chắn nên C đúng. A sai (không phải bằng số đo cung). B sai: góc nội tiếp phải có đỉnh nằm trên đường tròn. D sai: góc có đỉnh trên đường tròn nhưng cạnh không chứa dây cung thì không phải góc nội tiếp.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'Góc nội tiếp có số đo bằng số đo cung bị chắn.', 0),
(@q, 'B', N'Góc có hai cạnh chứa các dây cung của đường tròn là góc nội tiếp đường tròn đó.', 0),
(@q, 'C', N'Góc nội tiếp có số đo bằng một nửa số đo cung bị chắn.', 1),
(@q, 'D', N'Góc có đỉnh nằm trên đường tròn là góc nội tiếp đường tròn đó.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 9.38.</b> Cho tứ giác $ABCD$ nội tiếp một đường tròn có $\widehat{A}-\widehat{C}=100^\circ$. Khẳng định nào sau đây là đúng?</p>', N'<p>Tứ giác nội tiếp nên $\widehat{A}+\widehat{C}=180^\circ$. Kết hợp $\widehat{A}-\widehat{C}=100^\circ$: cộng hai vế được $2\widehat{A}=280^\circ$, suy ra $\widehat{A}=140^\circ$ và $\widehat{C}=40^\circ$. Vậy D đúng; A, B sai; $\widehat{B}+\widehat{D}=180^\circ$ nên C sai.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$\widehat{A}=80^\circ$.', 0),
(@q, 'B', N'$\widehat{C}=80^\circ$.', 0),
(@q, 'C', N'$\widehat{B}+\widehat{D}=100^\circ$.', 0),
(@q, 'D', N'$\widehat{A}=140^\circ$.', 1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 9.39.</b> Đa giác nào dưới đây <b>không</b> nội tiếp một đường tròn?</p>', N'<p>Đa giác đều, hình chữ nhật và mọi tam giác đều nội tiếp được đường tròn. Hình bình hành (không phải hình chữ nhật) có hai góc đối bằng nhau nhưng không bù nhau nên tổng hai góc đối khác $180^\circ$, do đó không nội tiếp được đường tròn. Đáp án C.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'Đa giác đều.', 0),
(@q, 'B', N'Hình chữ nhật.', 0),
(@q, 'C', N'Hình bình hành.', 1),
(@q, 'D', N'Tam giác.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.40.</b> Cho tam giác $ABC$ có các đường cao $BE,CF$ cắt nhau tại $H$. Gọi $M$ là trung điểm của $BC$ và $I$ là trung điểm của $AH$. Chứng minh rằng:</p>
<ol type="a">
<li>Tứ giác $AEHF$ nội tiếp một đường tròn tâm $I$;</li>
<li>$ME,MF$ tiếp xúc với đường tròn ngoại tiếp tứ giác $AEHF$.</li>
</ol>
<p><i>(Xét tam giác $ABC$ nhọn, khi đó $H$ nằm trong tam giác.)</i></p>', N'<p><b>a)</b> Vì $BE\perp AC$ và $CF\perp AB$ nên $\widehat{AEH}=\widehat{AFH}=90^\circ$. Hai điểm $E,F$ cùng nhìn đoạn $AH$ dưới góc vuông nên nằm trên đường tròn đường kính $AH$, có tâm là trung điểm $I$ của $AH$. Vậy $AEHF$ nội tiếp đường tròn tâm $I$.</p>
<p><b>b)</b> Ta chứng minh $ME\perp IE$ (với $E$ thuộc $(I)$) rồi suy ra $ME$ là tiếp tuyến; chứng minh $MF$ tương tự.</p>
<ul>
<li>Tam giác $BEC$ vuông tại $E$ có $M$ là trung điểm cạnh huyền $BC$ nên $ME=MB$, suy ra $\widehat{MEB}=\widehat{MBE}$.</li>
<li>Tam giác $IEH$ cân tại $I$ ($IE=IH$ là bán kính) nên $\widehat{IEH}=\widehat{IHE}$.</li>
<li>Gọi $D$ là chân đường cao kẻ từ $A$; $A,H,D$ thẳng hàng. Hai góc $\widehat{IHE}=\widehat{AHE}$ và $\widehat{BHD}$ đối đỉnh nên bằng nhau. Trong tam giác $BHD$ vuông tại $D$: $\widehat{BHD}+\widehat{HBD}=90^\circ$, mà $\widehat{HBD}=\widehat{EBC}=\widehat{MBE}$. Do đó $\widehat{IEH}+\widehat{MBE}=90^\circ$.</li>
</ul>
<p>Vì $H$ nằm giữa $B$ và $E$ nên $\widehat{HEM}=\widehat{BEM}=\widehat{MBE}$. Suy ra $$\widehat{IEM}=\widehat{IEH}+\widehat{HEM}=\widehat{IEH}+\widehat{MBE}=90^\circ.$$ Vậy $ME\perp IE$ tại $E\in(I)$, nên $ME$ tiếp xúc với đường tròn $(I)$. Hoàn toàn tương tự, $MF$ cũng tiếp xúc với $(I)$.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.41.</b> Cho tam giác $ABC$ nội tiếp đường tròn $(O)$. Gọi $M,N,P$ lần lượt là trung điểm của các cạnh $BC,CA,AB$. Chứng minh rằng các tứ giác $ANOP$, $BPOM$, $CMON$ là các tứ giác nội tiếp.</p>', N'<p>Vì $P$ là trung điểm của dây $AB$ của đường tròn $(O)$ nên $OP\perp AB$ (đường kính đi qua trung điểm của dây không đi qua tâm thì vuông góc với dây; nếu $AB$ là đường kính thì $P$ trùng $O$). Tương tự $ON\perp AC$.</p>
<p>Do đó $\widehat{APO}=\widehat{ANO}=90^\circ$, nên $P,N$ cùng nằm trên đường tròn đường kính $AO$. Vậy $A,N,O,P$ cùng nằm trên một đường tròn, tức $ANOP$ nội tiếp. (Cách khác: $\widehat{APO}+\widehat{ANO}=180^\circ$.)</p>
<p>Tương tự, $OP\perp AB$ và $OM\perp BC$ nên $\widehat{BPO}=\widehat{BMO}=90^\circ$: $BPOM$ nội tiếp đường tròn đường kính $BO$. Và $OM\perp BC$, $ON\perp AC$ nên $\widehat{CMO}=\widehat{CNO}=90^\circ$: $CMON$ nội tiếp đường tròn đường kính $CO$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.42.</b> Cho một hình lục giác đều và một hình vuông cùng nội tiếp một đường tròn. Biết rằng hình vuông có cạnh bằng 3 cm. Tính chu vi và diện tích của hình lục giác đều đã cho.</p>', N'<p>Hình vuông cạnh 3 cm có đường chéo $3\sqrt{2}$ cm nên bán kính đường tròn ngoại tiếp $R=\dfrac{3\sqrt{2}}{2}$ cm, $R^2=\dfrac{9}{2}$.</p>
<p>Lục giác đều nội tiếp đường tròn bán kính $R$ có cạnh bằng $R=\dfrac{3\sqrt{2}}{2}$ cm.</p>
<ul>
<li>Chu vi: $6R=9\sqrt{2}\ \text{cm}\approx12{,}73$ cm.</li>
<li>Diện tích: $6\cdot\dfrac{\sqrt{3}}{4}R^2=\dfrac{3\sqrt{3}}{2}\cdot\dfrac{9}{2}=\dfrac{27\sqrt{3}}{4}\ \text{cm}^2\approx11{,}69\ \text{cm}^2$.</li>
</ul>
<p><b>Đáp số:</b> chu vi $9\sqrt{2}$ cm; diện tích $\dfrac{27\sqrt{3}}{4}\ \text{cm}^2$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.43.</b> a) Cho hình vuông $ABCD$ nội tiếp đường tròn tâm $O$ (H.9.61). Phép quay thuận chiều $45^\circ$ tâm $O$ biến các điểm $A,B,C,D$ lần lượt thành các điểm $A'',B'',C'',D''$. Hãy vẽ tứ giác $A''B''C''D''$.</p>
<div><img src="/static/img/sgk9/sgk9-c9-h9-61.png" alt="Hình 9.61: hình vuông ABCD nội tiếp đường tròn tâm O trên lưới ô vuông, A ở trên bên trái, D ở trên bên phải, B ở dưới bên trái, C ở dưới bên phải"></div>
<p>b) Phép quay trong câu a biến các điểm $A'',B'',C'',D''$ thành những điểm nào?</p>', N'<p><b>a)</b> Đặt toạ độ cực với $O$ là gốc: $A,D,C,B$ lần lượt ở các hướng $135^\circ,45^\circ,-45^\circ,-135^\circ$ (tính từ tia $Ox$ nằm ngang sang phải, ngược chiều kim đồng hồ). Quay thuận chiều kim đồng hồ $45^\circ$, mỗi điểm giảm $45^\circ$: $A''$ ở hướng $90^\circ$ (điểm trên cùng của đường tròn), $D''$ ở hướng $0^\circ$ (điểm ngoài cùng bên phải), $C''$ ở hướng $-90^\circ$ (điểm dưới cùng), $B''$ ở hướng $-180^\circ$ (điểm ngoài cùng bên trái). Vậy $A'',D'',C'',B''$ là bốn điểm chính giữa các cung $AD$, $DC$, $CB$, $BA$; nối lần lượt $A'',B'',C'',D''$ ta được hình vuông nội tiếp $(O)$ có các đường chéo nằm ngang và thẳng đứng (hình vuông $ABCD$ xoay đi $45^\circ$).</p>
<p><b>b)</b> Quay thêm $45^\circ$ thuận chiều: $A''$ (hướng $90^\circ$) thành hướng $45^\circ$, tức điểm $D$; $B''$ (hướng $180^\circ$) thành hướng $135^\circ$, tức điểm $A$; $C''$ (hướng $-90^\circ$) thành hướng $-135^\circ$, tức điểm $B$; $D''$ (hướng $0^\circ$) thành hướng $-45^\circ$, tức điểm $C$.</p>
<p><b>Đáp số:</b> b) $A''\to D$, $B''\to A$, $C''\to B$, $D''\to C$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 9.44.</b> Bạn Lan muốn cắt hình ngôi sao có dạng như Hình 9.62 (trong đó $ABCDE$ là một ngũ giác đều). Lan gấp đôi tờ giấy, vẽ một nửa ngôi sao và cắt theo nét vẽ. Hỏi góc tạo bởi lưỡi kéo và nếp gấp lúc đầu bằng bao nhiêu độ?</p>
<div><img src="/static/img/sgk9/sgk9-c9-h9-62.png" alt="Hình 9.62: ngôi sao năm cánh có ngũ giác đều ABCDE ở giữa và tờ giấy gấp đôi với một nửa ngôi sao được vẽ, kéo ở góc trên"></div>', N'<p>Nếp gấp là trục đối xứng của ngôi sao, đi qua một đỉnh nhọn (một "cánh") của ngôi sao. Đường cắt xuất phát từ đỉnh nhọn đó, đi theo một cạnh của cánh sao.</p>
<p>Xét cánh sao nằm trên cạnh $AB$ của ngũ giác đều: mỗi góc của ngũ giác đều bằng $\dfrac{(5-2)\cdot180^\circ}{5}=108^\circ$, nên hai góc ở đáy của tam giác cánh sao (kề bù với góc ngũ giác) bằng $180^\circ-108^\circ=72^\circ$. Góc ở đỉnh nhọn của cánh sao là $180^\circ-2\cdot72^\circ=36^\circ$.</p>
<p>Nếp gấp chính là đường phân giác của góc đỉnh nhọn này, nên góc giữa đường cắt (cạnh của cánh sao) và nếp gấp bằng một nửa: $\dfrac{36^\circ}{2}=18^\circ$.</p>
<p><b>Đáp số:</b> $18^\circ$.</p>', 3, 0, 1, @t1);

-- ---------------------------------------------------------------------------------------------------------------------
-- Chương X. Một số hình khối trong thực tiễn
-- ---------------------------------------------------------------------------------------------------------------------
INSERT INTO Topics (TopicName, [Description], TeacherId, OrderIndex, IsActive) VALUES (N'Chương X. Một số hình khối trong thực tiễn', N'Hình trụ, hình nón, hình cầu: các yếu tố, diện tích xung quanh, diện tích mặt cầu, thể tích và các bài toán thực tiễn. (SGK Toán 9 Kết nối tri thức với cuộc sống, Tập 2)', @t1, 10, 1);
SET @tp = SCOPE_IDENTITY();

-- Bài 31
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 31. Hình trụ và hình nón', N'Nhận biết hình trụ, hình nón; công thức diện tích xung quanh và thể tích của hình trụ, hình nón.', N'<p><b>1. Hình trụ.</b> Khi quay hình chữ nhật $O''ABO$ một vòng quanh cạnh $OO''$ cố định thì ta được một <b>hình trụ</b>, trong đó:</p>
<ul>
<li>Hai <b>đáy</b> của hình trụ là hai hình tròn bằng nhau $(O'';O''A)$ và $(O;OB)$.</li>
<li>Mỗi <b>đường sinh</b> là một vị trí của $AB$ khi quay; hình trụ có vô số đường sinh, các đường sinh bằng nhau và bằng $OO''$. $R=O''A=OB$ gọi là <b>bán kính đáy</b>.</li>
<li>Độ dài đoạn $OO''$ gọi là <b>chiều cao</b> $h$ của hình trụ.</li>
</ul>
<p><b>Ví dụ 1.</b> Với hình trụ có hai đáy là các hình tròn tâm $O''$ và $O$, $O''M$ là một bán kính đáy, $EF$ là một đường sinh, chiều cao $O''O=10$ cm.</p>
<p><b>Chú ý.</b> Cắt rời hai đáy và cắt theo một đường sinh rồi trải phẳng ra, ta được hình khai triển của hình trụ gồm hai hình tròn và một hình chữ nhật có một kích thước bằng chu vi đáy $2\pi R$, kích thước còn lại bằng chiều cao $h$.</p>
<p><b>Diện tích xung quanh và thể tích của hình trụ.</b> Với $R$ là bán kính đáy, $h$ là chiều cao: $$S_{xq}=2\pi Rh,\qquad V=S_{\text{đáy}}\cdot h=\pi R^2h.$$</p>
<p><b>Ví dụ 2.</b> Thùng rác hình trụ có $R=11$ cm, $h=30$ cm (sơn mặt ngoài và một đáy). Diện tích cần sơn: $S=S_{xq}+S_{\text{đáy}}=2\pi\cdot11\cdot30+\pi\cdot11^2=660\pi+121\pi=781\pi\ (\text{cm}^2)$. Thể tích: $V=121\pi\cdot30=3630\pi\approx11404\ (\text{cm}^3)$.</p>
<p><b>2. Hình nón.</b> Khi quay tam giác vuông $SOA$ (vuông ở $O$) một vòng quanh cạnh $SO$ cố định thì ta được một <b>hình nón</b> đỉnh $S$, trong đó:</p>
<ul>
<li><b>Đáy</b> của hình nón là hình tròn $(O;OA)$, $R=OA$ gọi là bán kính đáy.</li>
<li>Mỗi <b>đường sinh</b> là một vị trí của $SA$ khi quay; hình nón có vô số đường sinh dài bằng nhau, độ dài $l=SA$.</li>
<li>$SO$ gọi là <b>đường cao</b> của hình nón; độ dài $SO$ là <b>chiều cao</b> $h$.</li>
</ul>
<p>Giữa ba yếu tố có hệ thức (định lí Pythagore trong tam giác vuông $SOA$): $l^2=h^2+r^2$.</p>
<p><b>Chú ý.</b> Cắt rời đáy và cắt mặt xung quanh theo đường sinh $SA$ rồi trải phẳng ra, ta được hình khai triển của hình nón gồm một hình tròn (đáy) và một hình quạt tròn (bán kính $l$, độ dài cung bằng chu vi đáy $2\pi r$).</p>
<p><b>Diện tích xung quanh và thể tích của hình nón.</b> Với $r$ là bán kính đáy, $l$ là độ dài đường sinh, $h$ là chiều cao: $$S_{xq}=\pi rl,\qquad V=\dfrac{1}{3}S_{\text{đáy}}\cdot h=\dfrac{1}{3}\pi r^2h.$$</p>
<p><b>Ví dụ 4.</b> Hình nón có $l=10$ cm, $r=6$ cm. a) $S_{xq}=\pi\cdot6\cdot10=60\pi\ (\text{cm}^2)$. b) Chiều cao $h=\sqrt{10^2-6^2}=8$ cm nên $V=\dfrac{1}{3}\pi\cdot6^2\cdot8=96\pi\ (\text{cm}^3)$.</p>
<p><b>Vận dụng.</b> Đống muối hình nón cao khoảng 0,9 m, đường kính đáy khoảng 1,6 m (bán kính $0{,}8$ m $=8$ dm, chiều cao $9$ dm): $V=\dfrac{1}{3}\pi\cdot8^2\cdot9=192\pi\approx603\ (\text{dm}^3)$.</p>', 1, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 10.1.</b> Thay dấu "?" bằng giá trị thích hợp và hoàn thành bảng sau vào vở (hình trụ có bán kính đáy $R$, chiều cao $h$):</p>
<table border="1"><tr><th>Bán kính đáy (cm)</th><th>Chiều cao (cm)</th><th>Diện tích xung quanh (cm²)</th><th>Thể tích (cm³)</th></tr>
<tr><td>4</td><td>6</td><td>?</td><td>?</td></tr>
<tr><td>3</td><td>5</td><td>?</td><td>?</td></tr>
<tr><td>?</td><td>10</td><td>?</td><td>$50\pi$</td></tr>
<tr><td>8</td><td>?</td><td>$192\pi$</td><td>?</td></tr></table>', N'<p><b>Dòng 1:</b> $S_{xq}=2\pi\cdot4\cdot6=48\pi$; $V=\pi\cdot4^2\cdot6=96\pi$.</p>
<p><b>Dòng 2:</b> $S_{xq}=2\pi\cdot3\cdot5=30\pi$; $V=\pi\cdot3^2\cdot5=45\pi$.</p>
<p><b>Dòng 3:</b> $V=\pi R^2\cdot10=50\pi$ nên $R^2=5$, $R=\sqrt{5}$ cm; $S_{xq}=2\pi\sqrt{5}\cdot10=20\sqrt{5}\,\pi$.</p>
<p><b>Dòng 4:</b> $S_{xq}=2\pi\cdot8\cdot h=192\pi$ nên $16h=192$, $h=12$ cm; $V=\pi\cdot8^2\cdot12=768\pi$.</p>
<table border="1"><tr><th>Bán kính đáy (cm)</th><th>Chiều cao (cm)</th><th>Diện tích xung quanh (cm²)</th><th>Thể tích (cm³)</th></tr>
<tr><td>4</td><td>6</td><td>$48\pi$</td><td>$96\pi$</td></tr>
<tr><td>3</td><td>5</td><td>$30\pi$</td><td>$45\pi$</td></tr>
<tr><td>$\sqrt{5}$</td><td>10</td><td>$20\sqrt{5}\,\pi$</td><td>$50\pi$</td></tr>
<tr><td>8</td><td>12</td><td>$192\pi$</td><td>$768\pi$</td></tr></table>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 10.2.</b> Cho hình chữ nhật $ABCD$ có $AB=3$ cm, $BC=4$ cm. Quay hình chữ nhật quanh cạnh $AB$ một vòng, ta được một hình trụ. Tính diện tích xung quanh và thể tích của hình trụ tạo thành.</p>', N'<p>Quay quanh cạnh $AB$ thì $AB$ là trục: chiều cao $h=AB=3$ cm; bán kính đáy $R=BC=4$ cm.</p>
<p>$S_{xq}=2\pi Rh=2\pi\cdot4\cdot3=24\pi\ (\text{cm}^2)$; $V=\pi R^2h=\pi\cdot4^2\cdot3=48\pi\ (\text{cm}^3)$.</p>
<p><b>Đáp số:</b> $S_{xq}=24\pi\ \text{cm}^2\approx75{,}4\ \text{cm}^2$; $V=48\pi\ \text{cm}^3\approx150{,}8\ \text{cm}^3$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 10.3.</b> Khi cho tam giác $SOA$ vuông tại $O$ quay quanh cạnh $SO$ một vòng, ta được một hình nón. Biết $OA=8$ cm, $SA=17$ cm (H.10.14).</p>
<ol type="a">
<li>Tính diện tích xung quanh của hình nón.</li>
<li>Tính thể tích của hình nón.</li>
</ol>', N'<p>Bán kính đáy $r=OA=8$ cm, đường sinh $l=SA=17$ cm.</p>
<p><b>a)</b> $S_{xq}=\pi rl=\pi\cdot8\cdot17=136\pi\ (\text{cm}^2)$.</p>
<p><b>b)</b> Chiều cao $h=SO=\sqrt{SA^2-OA^2}=\sqrt{17^2-8^2}=\sqrt{225}=15$ cm. $V=\dfrac{1}{3}\pi r^2h=\dfrac{1}{3}\pi\cdot8^2\cdot15=320\pi\ (\text{cm}^3)$.</p>
<p><b>Đáp số:</b> a) $136\pi\ \text{cm}^2$. b) $320\pi\ \text{cm}^3$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 10.4.</b> Một bóng đèn huỳnh quang có dạng hình trụ được đặt khít vào một hộp giấy cứng có dạng hình hộp chữ nhật (H.10.15). Hộp giấy có chiều dài bằng 0,6 m, đáy là hình vuông cạnh 4 cm. Tính diện tích xung quanh và thể tích của bóng đèn (giả sử bề dày của hộp giấy không đáng kể).</p>', N'<p>Bóng đèn đặt khít trong hộp có đáy vuông cạnh 4 cm nên đáy của hình trụ là hình tròn nội tiếp hình vuông: đường kính 4 cm, bán kính $R=2$ cm. Chiều cao (chiều dài đèn) $h=0{,}6$ m $=60$ cm.</p>
<p>$S_{xq}=2\pi Rh=2\pi\cdot2\cdot60=240\pi\ (\text{cm}^2)$; $V=\pi R^2h=\pi\cdot2^2\cdot60=240\pi\ (\text{cm}^3)$.</p>
<p><b>Đáp số:</b> $S_{xq}=240\pi\ \text{cm}^2\approx754\ \text{cm}^2$; $V=240\pi\ \text{cm}^3\approx754\ \text{cm}^3$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 10.5.</b> Một dụng cụ gồm một phần có dạng hình trụ và một phần có dạng hình nón với các kích thước như Hình 10.16 (hình trụ cao 100 cm, bán kính đáy 40 cm; hình nón có cùng đáy với hình trụ, cao 50 cm, đặt phía trên).</p>
<div><img src="/static/img/sgk9/sgk9-c10-hinh-10-16.png" alt="Hình 10.16: dụng cụ gồm hình trụ và hình nón"></div>
<ol type="a">
<li>Tính thể tích của dụng cụ này.</li>
<li>Tính diện tích mặt ngoài của dụng cụ (không tính đáy của dụng cụ).</li>
</ol>', N'<p>Hình trụ: $R=40$ cm, $h_1=100$ cm. Hình nón: $r=40$ cm, $h_2=50$ cm.</p>
<p><b>a)</b> $V=\pi R^2h_1+\dfrac{1}{3}\pi r^2h_2=\pi\cdot40^2\cdot100+\dfrac{1}{3}\pi\cdot40^2\cdot50=160000\pi+\dfrac{80000\pi}{3}=\dfrac{560000\pi}{3}\ (\text{cm}^3)\approx586431\ (\text{cm}^3)$.</p>
<p><b>b)</b> Mặt ngoài (không tính đáy dưới) gồm mặt xung quanh hình trụ và mặt xung quanh hình nón. Đường sinh hình nón: $l=\sqrt{40^2+50^2}=\sqrt{4100}=10\sqrt{41}$ cm.</p>
<p>$S=2\pi\cdot40\cdot100+\pi\cdot40\cdot10\sqrt{41}=8000\pi+400\sqrt{41}\,\pi\ (\text{cm}^2)\approx33179\ (\text{cm}^2)$.</p>
<p><b>Đáp số:</b> a) $\dfrac{560000\pi}{3}\ \text{cm}^3\approx586431\ \text{cm}^3$. b) $(8000+400\sqrt{41})\pi\ \text{cm}^2\approx33179\ \text{cm}^2$.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 10.6.</b> Tính thể tích của hình tạo thành khi cho hình $ABCD$ quay quanh $AD$ một vòng (H.10.17). Biết $AB=4$ cm, $DC=8$ cm, $AB$ và $DC$ cùng vuông góc với $AD$; đoạn $BC$ cắt $AD$ tại một điểm cách $A$ là 3 cm và cách $D$ là 6 cm.</p>
<div><img src="/static/img/sgk9/sgk9-c10-hinh-10-17.png" alt="Hình 10.17: hình ABCD quay quanh AD"></div>', N'<p>Gọi $I$ là giao điểm của $BC$ và $AD$; $AI=3$ cm, $ID=6$ cm. Khi quay quanh $AD$, hình tạo thành gồm hai hình nón chung đỉnh $I$:</p>
<ul>
<li>Hình nón thứ nhất: đỉnh $I$, bán kính đáy $AB=4$ cm, chiều cao $AI=3$ cm: $V_1=\dfrac{1}{3}\pi\cdot4^2\cdot3=16\pi$.</li>
<li>Hình nón thứ hai: đỉnh $I$, bán kính đáy $DC=8$ cm, chiều cao $ID=6$ cm: $V_2=\dfrac{1}{3}\pi\cdot8^2\cdot6=128\pi$.</li>
</ul>
<p>$V=V_1+V_2=16\pi+128\pi=144\pi\ (\text{cm}^3)$.</p>
<p><b>Đáp số:</b> $144\pi\ \text{cm}^3\approx452{,}4\ \text{cm}^3$.</p>', 3, 0, 1, @t1);

-- Bài 32
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài 32. Hình cầu', N'Nhận biết mặt cầu, hình cầu; mặt cắt của hình cầu; công thức diện tích mặt cầu và thể tích hình cầu.', N'<p><b>1. Mặt cầu và hình cầu.</b></p>
<ul>
<li>Khi quay <i>nửa đường tròn</i> quanh đường kính $AB$ cố định của nó, ta được một <b>mặt cầu</b>.</li>
<li>Khi quay <i>nửa hình tròn</i> quanh đường kính $AB$ cố định của nó, ta được một <b>hình cầu</b>.</li>
<li>Tâm và bán kính của nửa đường tròn (hình tròn) cũng là tâm và bán kính của mặt cầu (hình cầu).</li>
</ul>
<p><b>Ví dụ 1.</b> Trong mặt cầu tâm $O$ có các điểm $M,N,P$ trên mặt cầu: tâm mặt cầu là $O$, một bán kính là $OP$ (các bán kính còn lại là $OM$, $ON$).</p>
<p><b>2. Cắt mặt cầu, hình cầu bởi một mặt phẳng.</b></p>
<ul>
<li>Nếu cắt một hình cầu bởi một mặt phẳng thì phần chung của mặt phẳng và hình cầu (mặt cắt) là một <b>hình tròn</b>.</li>
<li>Nếu cắt một mặt cầu bán kính $R$ bởi một mặt phẳng thì phần chung của mặt phẳng và mặt cầu là một <b>đường tròn</b>. Khi mặt phẳng đi qua tâm thì đường tròn đó có bán kính $R$ và gọi là <b>đường tròn lớn</b>; khi mặt phẳng không đi qua tâm thì đường tròn có bán kính nhỏ hơn $R$.</li>
</ul>
<p><b>Ví dụ 2.</b> Đường Xích đạo là một đường tròn lớn của Trái Đất, dài khoảng 40 075 km. Nếu $R$ là bán kính Trái Đất thì $2\pi R\approx40075$ nên đường kính Trái Đất là $2R\approx40075:\pi\approx12756{,}27$ (km).</p>
<p><b>3. Diện tích mặt cầu và thể tích hình cầu.</b> Với $R$ là bán kính: $$S=4\pi R^2,\qquad V=\dfrac{4}{3}\pi R^3.$$</p>
<p><b>Ví dụ 3.</b> Mặt cầu bán kính 10 cm: $S=4\pi\cdot10^2=400\pi\ (\text{cm}^2)$; $V=\dfrac{4}{3}\pi\cdot10^3=\dfrac{4000\pi}{3}\ (\text{cm}^3)$.</p>
<p><b>Vận dụng 1 (tình huống mở đầu).</b> Quả bóng đá đường kính 22 cm có $R=11$ cm: $V=\dfrac{4}{3}\pi\cdot11^3=\dfrac{5324\pi}{3}\approx5575\ (\text{cm}^3)$.</p>
<p><b>Ví dụ 4.</b> Bể cá là một phần hình cầu đường kính 20 cm ($R=10$ cm). Nước đổ vào bằng $\dfrac{2}{3}$ thể tích hình cầu: $\dfrac{2}{3}\cdot\dfrac{4000\pi}{3}=\dfrac{8000\pi}{9}\approx2793\ (\text{cm}^3)$.</p>
<p><b>Vận dụng 2.</b> Khinh khí cầu hình cầu đường kính 11 m: $S=4\pi\cdot5{,}5^2=121\pi\approx380\ (\text{m}^2)$.</p>', 2, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 10.7.</b> Thay dấu "?" bằng giá trị thích hợp và hoàn thành bảng sau vào vở:</p>
<table border="1"><tr><th>Bán kính (cm)</th><th>Diện tích mặt cầu (cm²)</th><th>Thể tích hình cầu (cm³)</th></tr>
<tr><td>3</td><td>?</td><td>?</td></tr>
<tr><td>?</td><td>$100\pi$</td><td>?</td></tr>
<tr><td>?</td><td>?</td><td>$972\pi$</td></tr></table>', N'<p><b>Dòng 1:</b> $R=3$: $S=4\pi\cdot3^2=36\pi$; $V=\dfrac{4}{3}\pi\cdot3^3=36\pi$.</p>
<p><b>Dòng 2:</b> $S=4\pi R^2=100\pi$ nên $R^2=25$, $R=5$ cm; $V=\dfrac{4}{3}\pi\cdot5^3=\dfrac{500\pi}{3}$.</p>
<p><b>Dòng 3:</b> $V=\dfrac{4}{3}\pi R^3=972\pi$ nên $R^3=729$, $R=9$ cm; $S=4\pi\cdot9^2=324\pi$.</p>
<table border="1"><tr><th>Bán kính (cm)</th><th>Diện tích mặt cầu (cm²)</th><th>Thể tích hình cầu (cm³)</th></tr>
<tr><td>3</td><td>$36\pi$</td><td>$36\pi$</td></tr>
<tr><td>5</td><td>$100\pi$</td><td>$\dfrac{500\pi}{3}$</td></tr>
<tr><td>9</td><td>$324\pi$</td><td>$972\pi$</td></tr></table>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 10.8.</b> Một cốc đựng ba viên kem có dạng hình cầu, mỗi viên đều có bán kính bằng 3 cm. Tính thể tích của kem đựng trong cốc (làm tròn kết quả đến hàng đơn vị của cm³).</p>', N'<p>Thể tích một viên kem: $V_1=\dfrac{4}{3}\pi\cdot3^3=36\pi\ (\text{cm}^3)$.</p>
<p>Thể tích ba viên: $V=3\cdot36\pi=108\pi\approx339\ (\text{cm}^3)$.</p>
<p><b>Đáp số:</b> khoảng $339\ \text{cm}^3$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 10.9.</b> Một quả bóng đá có chu vi của đường tròn lớn bằng 68,5 cm. Quả bóng được ghép nối bởi các miếng da hình lục giác đều màu trắng và đen, mỗi miếng có diện tích bằng 49,83 cm². Hỏi cần ít nhất bao nhiêu miếng da để làm quả bóng trên? (Coi phần mép khâu không đáng kể).</p>', N'<p>Gọi $R$ là bán kính quả bóng; đường tròn lớn có chu vi $2\pi R=68{,}5$ nên $R=\dfrac{68{,}5}{2\pi}\approx10{,}9$ cm.</p>
<p>Diện tích mặt cầu: $S=4\pi R^2=4\pi\cdot\dfrac{68{,}5^2}{4\pi^2}=\dfrac{68{,}5^2}{\pi}=\dfrac{4692{,}25}{\pi}\approx1493{,}6\ (\text{cm}^2)$.</p>
<p>Số miếng da cần dùng: $1493{,}6:49{,}83\approx29{,}97$. Vì số miếng da là số nguyên và phải phủ kín mặt bóng nên cần ít nhất 30 miếng.</p>
<p><b>Đáp số:</b> 30 miếng da.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 10.10.</b> Hằng năm cứ dịp Tết đến Xuân về, dân làng Thuỵ Lĩnh, phường Lĩnh Nam, Hà Nội lại tổ chức lễ hội vật cầu truyền thống. Trong lễ hội có sử dụng một quả cầu được tiện bằng gỗ, đường kính khoảng 35 cm, sơn đỏ mặt ngoài. Tính diện tích mặt ngoài của quả cầu gỗ nói trên.</p>', N'<p>Bán kính $R=35:2=17{,}5$ cm.</p>
<p>$S=4\pi R^2=4\pi\cdot17{,}5^2=1225\pi\approx3848\ (\text{cm}^2)$.</p>
<p><b>Đáp số:</b> $1225\pi\ \text{cm}^2\approx3848\ \text{cm}^2$.</p>', 1, 0, 1, @t1);

-- Luyện tập chung (Bài 31 - Bài 32)
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Luyện tập chung (Chương X)', N'Tính thể tích các vật ghép từ hình trụ, hình nón, hình cầu và giải các bài toán thực tiễn.', N'<p><b>Công thức cần nhớ.</b> Hình trụ: $S_{xq}=2\pi Rh$, $V=\pi R^2h$. Hình nón: $S_{xq}=\pi rl$, $V=\dfrac{1}{3}\pi r^2h$, $l^2=h^2+r^2$. Hình cầu: $S=4\pi R^2$, $V=\dfrac{4}{3}\pi R^3$.</p>
<p><b>Ví dụ 1.</b> Hình trụ có bán kính đáy 1 cm, chiều cao 2 cm; người ta khoan đi một phần có dạng hình nón (cùng đáy với hình trụ, cùng chiều cao). Thể tích hình trụ: $V_1=\pi\cdot1^2\cdot2=2\pi$. Thể tích phần bị khoan: $V_2=\dfrac{1}{3}\pi\cdot1^2\cdot2=\dfrac{2\pi}{3}$. Thể tích phần còn lại: $V=V_1-V_2=2\pi-\dfrac{2\pi}{3}=\dfrac{4\pi}{3}\ (\text{cm}^3)$.</p>
<p><b>Ví dụ 2.</b> Hộp đựng bóng tennis hình trụ chứa vừa khít ba quả bóng hình cầu đường kính 6,4 cm xếp theo chiều dọc.</p>
<p>a) Chiều cao hộp $h=6{,}4\cdot3=19{,}2$ cm, bán kính đáy $R=3{,}2$ cm: $V=\pi\cdot3{,}2^2\cdot19{,}2\approx618\ (\text{cm}^3)$.</p>
<p>b) Thể tích ba quả bóng: $V''=3\cdot\dfrac{4}{3}\pi\cdot3{,}2^3\approx412\ (\text{cm}^3)$. Thể tích phần trống trong hộp: $618-412=206\ (\text{cm}^3)$.</p>', 3, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 10.11.</b> Cho một hình trụ có đường kính của đáy bằng với chiều cao và có thể tích bằng $2\pi\ \text{cm}^3$.</p>
<ol type="a">
<li>Tính chiều cao của hình trụ.</li>
<li>Diện tích toàn phần của hình trụ bằng tổng diện tích xung quanh và diện tích hai đáy hình trụ. Tính diện tích toàn phần của hình trụ trên.</li>
</ol>', N'<p><b>a)</b> Đường kính đáy bằng chiều cao: $h=2R$. Thể tích $V=\pi R^2h=\pi R^2\cdot2R=2\pi R^3=2\pi$ nên $R^3=1$, $R=1$ cm. Chiều cao $h=2R=2$ cm.</p>
<p><b>b)</b> $S_{xq}=2\pi Rh=2\pi\cdot1\cdot2=4\pi$; diện tích hai đáy: $2\pi R^2=2\pi$. Diện tích toàn phần $S_{tp}=4\pi+2\pi=6\pi\ (\text{cm}^2)$.</p>
<p><b>Đáp số:</b> a) $2$ cm. b) $6\pi\ \text{cm}^2$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 10.12.</b> Một vòng bi bằng thép (phần thép giữa hai hình trụ) có hình dạng và kích thước như Hình 10.30 (chiều cao 10 cm; bán kính hình trụ ngoài 7 cm, bán kính hình trụ trong 5 cm). Tính thể tích của vòng bi đó.</p>
<div><img src="/static/img/sgk9/sgk9-c10-hinh-10-30.png" alt="Hình 10.30: vòng bi thép"></div>', N'<p>Thể tích vòng bi bằng thể tích hình trụ ngoài trừ thể tích hình trụ trong (cùng chiều cao $h=10$ cm).</p>
<p>$V=\pi\cdot7^2\cdot10-\pi\cdot5^2\cdot10=490\pi-250\pi=240\pi\ (\text{cm}^3)\approx754\ (\text{cm}^3)$.</p>
<p><b>Đáp số:</b> $240\pi\ \text{cm}^3\approx754\ \text{cm}^3$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 10.13.</b> Chiếc mũ của chú hề với các kích thước như Hình 10.31 (phần thân mũ hình nón có độ dài đường sinh 30 cm; vành mũ là hình vành khuyên có đường kính ngoài 35 cm, rộng 10 cm tính từ mép ngoài vào chân thân mũ). Hãy tính tổng diện tích vải cần để làm chiếc mũ (coi mép khâu không đáng kể và làm tròn kết quả đến hàng phần mười của cm²).</p>
<div><img src="/static/img/sgk9/sgk9-c10-hinh-10-31.png" alt="Hình 10.31: chiếc mũ của chú hề"></div>', N'<p>Bán kính ngoài của vành mũ: $35:2=17{,}5$ cm. Vành rộng 10 cm nên bán kính đáy của thân mũ (hình nón) là $r=17{,}5-10=7{,}5$ cm.</p>
<p>Diện tích xung quanh hình nón (thân mũ): $S_1=\pi rl=\pi\cdot7{,}5\cdot30=225\pi\ (\text{cm}^2)$.</p>
<p>Diện tích vành mũ (hình vành khuyên): $S_2=\pi\cdot17{,}5^2-\pi\cdot7{,}5^2=\pi(306{,}25-56{,}25)=250\pi\ (\text{cm}^2)$.</p>
<p>Tổng diện tích vải: $S=S_1+S_2=475\pi\approx1492{,}3\ (\text{cm}^2)$.</p>
<p><b>Đáp số:</b> khoảng $1492{,}3\ \text{cm}^2$.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 10.14.</b> Người ta nhấn chìm hoàn toàn 5 viên bi có dạng hình cầu vào một chiếc cốc hình trụ đựng đầy nước, mỗi viên bi có đường kính 2 cm. Tính lượng nước tràn ra khỏi cốc.</p>', N'<p>Lượng nước tràn ra bằng tổng thể tích 5 viên bi. Bán kính mỗi viên bi $R=2:2=1$ cm.</p>
<p>$V=5\cdot\dfrac{4}{3}\pi\cdot1^3=\dfrac{20\pi}{3}\approx20{,}9\ (\text{cm}^3)$.</p>
<p><b>Đáp số:</b> $\dfrac{20\pi}{3}\ \text{cm}^3\approx20{,}9\ \text{cm}^3$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 10.15.</b> Một bồn chứa xăng gồm hai nửa hình cầu có đường kính bằng 1,8 m và một hình trụ có chiều cao bằng 3,6 m (H.10.32). Tính thể tích của bồn chứa xăng (làm tròn kết quả đến hàng phần trăm của m³).</p>
<div><img src="/static/img/sgk9/sgk9-c10-hinh-10-32.png" alt="Hình 10.32: bồn chứa xăng"></div>', N'<p>Bán kính $R=1{,}8:2=0{,}9$ m.</p>
<p>Hai nửa hình cầu ghép lại thành một hình cầu: $V_1=\dfrac{4}{3}\pi\cdot0{,}9^3=0{,}972\pi\ (\text{m}^3)$.</p>
<p>Hình trụ: $V_2=\pi\cdot0{,}9^2\cdot3{,}6=2{,}916\pi\ (\text{m}^3)$.</p>
<p>Thể tích bồn: $V=V_1+V_2=3{,}888\pi\approx12{,}21\ (\text{m}^3)$.</p>
<p><b>Đáp số:</b> khoảng $12{,}21\ \text{m}^3$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 10.16.</b> Từ một tấm tôn hình chữ nhật có kích thước 50 cm × 240 cm, người ta làm mặt xung quanh của các thùng đựng nước hình trụ có chiều cao bằng 50 cm, theo hai cách sau (H.10.33):</p>
<ul>
<li><i>Cách 1:</i> Gò tấm tôn ban đầu thành mặt xung quanh của thùng nước hình trụ.</li>
<li><i>Cách 2:</i> Cắt tấm tôn ban đầu thành hai tấm hình chữ nhật bằng nhau, rồi gò mỗi tấm đó thành mặt xung quanh của một thùng.</li>
</ul>
<p>Kí hiệu $V_1$ là thể tích của thùng gò được theo Cách 1 và $V_2$ là tổng thể tích của hai thùng gò được theo Cách 2. Tính tỉ số $\dfrac{V_1}{V_2}$ (giả sử các mối hàn là không đáng kể).</p>', N'<p>Chiều cao mỗi thùng là $h=50$ cm, cạnh 240 cm (hoặc 120 cm) của tấm tôn là chu vi đáy.</p>
<p><b>Cách 1:</b> chu vi đáy $2\pi R_1=240$ nên $R_1=\dfrac{120}{\pi}$ cm. $V_1=\pi R_1^2h=\pi\cdot\dfrac{14400}{\pi^2}\cdot50=\dfrac{720000}{\pi}$.</p>
<p><b>Cách 2:</b> mỗi tấm kích thước $50\times120$ nên $2\pi R_2=120$, $R_2=\dfrac{60}{\pi}$ cm. Thể tích một thùng: $\pi R_2^2h=\pi\cdot\dfrac{3600}{\pi^2}\cdot50=\dfrac{180000}{\pi}$. Tổng hai thùng: $V_2=\dfrac{360000}{\pi}$.</p>
<p>Tỉ số $\dfrac{V_1}{V_2}=\dfrac{720000}{360000}=2$.</p>
<p><b>Đáp số:</b> $\dfrac{V_1}{V_2}=2$.</p>', 3, 0, 1, @t1);

-- Bài tập cuối chương X
INSERT INTO Lessons (TopicId, Title, Summary, Content, DisplayOrder, IsActive, CreatedBy) VALUES (@tp, N'Bài tập cuối chương X', N'Ôn tập chương X: hình trụ, hình nón, hình cầu và các bài toán thực tiễn.', N'<p><b>Tóm tắt kiến thức chương X.</b></p>
<table border="1"><tr><th>Hình</th><th>Yếu tố</th><th>Diện tích</th><th>Thể tích</th></tr>
<tr><td>Hình trụ</td><td>bán kính đáy $R$, chiều cao $h$</td><td>$S_{xq}=2\pi Rh$</td><td>$V=\pi R^2h$</td></tr>
<tr><td>Hình nón</td><td>bán kính đáy $r$, đường sinh $l$, chiều cao $h$, $l^2=h^2+r^2$</td><td>$S_{xq}=\pi rl$</td><td>$V=\dfrac{1}{3}\pi r^2h$</td></tr>
<tr><td>Hình cầu</td><td>bán kính $R$</td><td>$S=4\pi R^2$</td><td>$V=\dfrac{4}{3}\pi R^3$</td></tr></table>
<p><b>Lưu ý.</b> Diện tích toàn phần của hình trụ (hình nón) bằng diện tích xung quanh cộng diện tích các đáy. Thể tích hình nón bằng $\dfrac{1}{3}$ thể tích hình trụ cùng đáy và cùng chiều cao. Mặt cắt của hình cầu bởi một mặt phẳng đi qua tâm là hình tròn bán kính $R$.</p>', 4, 1, @t1);
SET @l = SCOPE_IDENTITY();
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 10.17.</b> Khi quay hình chữ nhật $ABCD$ một vòng quanh cạnh $AB$ ta được một hình trụ có bán kính đáy bằng độ dài đoạn thẳng</p>', N'<p>Trục quay là $AB$ nên $AB$ là chiều cao; các cạnh vuông góc với trục là $AD$ và $BC$ vạch nên hai đáy, do đó bán kính đáy bằng $AD$ ($=BC$).</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$AB$.', 0),
(@q, 'B', N'$CD$.', 0),
(@q, 'C', N'$AD$.', 1),
(@q, 'D', N'$AC$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 10.18.</b> Cho tam giác $ABC$ vuông tại $A$ có $AB=4$ cm, $BC=5$ cm. Khi quay tam giác $ABC$ một vòng quanh cạnh $AC$ ta được một hình nón có chiều cao bằng</p>', N'<p>Theo định lí Pythagore, $AC=\sqrt{BC^2-AB^2}=\sqrt{25-16}=3$ cm. Quay quanh $AC$ thì $AC$ là trục nên chiều cao hình nón bằng $AC=3$ cm (bán kính đáy $AB=4$ cm).</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$4$ cm.', 0),
(@q, 'B', N'$3$ cm.', 1),
(@q, 'C', N'$5$ cm.', 0),
(@q, 'D', N'$9$ cm.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 10.19.</b> Diện tích mặt cầu có đường kính 10 cm là</p>', N'<p>Bán kính $R=5$ cm nên $S=4\pi R^2=4\pi\cdot25=100\pi\ (\text{cm}^2)$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$10\pi\ \text{cm}^2$.', 0),
(@q, 'B', N'$400\pi\ \text{cm}^2$.', 0),
(@q, 'C', N'$50\pi\ \text{cm}^2$.', 0),
(@q, 'D', N'$100\pi\ \text{cm}^2$.', 1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 10.20.</b> Cho hình nón có bán kính đáy $R=2$ cm, độ dài đường sinh $l=5$ cm. Diện tích xung quanh của hình nón đã cho bằng</p>', N'<p>$S_{xq}=\pi Rl=\pi\cdot2\cdot5=10\pi\ (\text{cm}^2)$.</p>', 1, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$\dfrac{10\pi}{3}\ \text{cm}^2$.', 0),
(@q, 'B', N'$\dfrac{50\pi}{3}\ \text{cm}^2$.', 0),
(@q, 'C', N'$20\pi\ \text{cm}^2$.', 0),
(@q, 'D', N'$10\pi\ \text{cm}^2$.', 1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'MCQ', N'<p><b>Bài 10.21.</b> Một mặt phẳng đi qua tâm hình cầu, cắt hình cầu theo một hình tròn có diện tích $9\pi\ \text{cm}^2$. Thể tích của hình cầu bằng</p>', N'<p>Mặt phẳng đi qua tâm cắt hình cầu theo hình tròn bán kính $R$ nên $\pi R^2=9\pi$, $R=3$ cm. Thể tích $V=\dfrac{4}{3}\pi\cdot3^3=36\pi\ (\text{cm}^3)$.</p>', 2, 0, 1, @t1);
SET @q = SCOPE_IDENTITY();
INSERT INTO QuestionOptions (QuestionId, OptionLetter, Content, IsCorrect) VALUES
(@q, 'A', N'$972\pi\ \text{cm}^3$.', 0),
(@q, 'B', N'$36\pi\ \text{cm}^3$.', 1),
(@q, 'C', N'$6\pi\ \text{cm}^3$.', 0),
(@q, 'D', N'$81\pi\ \text{cm}^3$.', 0);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 10.22.</b> Cho hình trụ có bán kính đáy bằng 20 cm, chiều cao bằng 30 cm.</p>
<ol type="a">
<li>Tính diện tích xung quanh của hình trụ.</li>
<li>Tính thể tích của hình trụ.</li>
</ol>', N'<p><b>a)</b> $S_{xq}=2\pi Rh=2\pi\cdot20\cdot30=1200\pi\ (\text{cm}^2)$.</p>
<p><b>b)</b> $V=\pi R^2h=\pi\cdot20^2\cdot30=12000\pi\ (\text{cm}^3)$.</p>
<p><b>Đáp số:</b> a) $1200\pi\ \text{cm}^2$. b) $12000\pi\ \text{cm}^3$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 10.23.</b> Cho hình nón có bán kính đáy bằng 9 cm, độ dài đường sinh bằng 15 cm (H.10.34).</p>
<ol type="a">
<li>Tính diện tích xung quanh của hình nón.</li>
<li>Tính thể tích của hình nón.</li>
<li>Diện tích toàn phần của hình nón bằng tổng diện tích xung quanh và diện tích đáy. Tính diện tích toàn phần của hình nón đã cho.</li>
</ol>', N'<p>$r=9$ cm, $l=15$ cm.</p>
<p><b>a)</b> $S_{xq}=\pi rl=\pi\cdot9\cdot15=135\pi\ (\text{cm}^2)$.</p>
<p><b>b)</b> Chiều cao $h=\sqrt{l^2-r^2}=\sqrt{225-81}=12$ cm. $V=\dfrac{1}{3}\pi r^2h=\dfrac{1}{3}\pi\cdot81\cdot12=324\pi\ (\text{cm}^3)$.</p>
<p><b>c)</b> $S_{tp}=S_{xq}+\pi r^2=135\pi+81\pi=216\pi\ (\text{cm}^2)$.</p>
<p><b>Đáp số:</b> a) $135\pi\ \text{cm}^2$. b) $324\pi\ \text{cm}^3$. c) $216\pi\ \text{cm}^2$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 10.24.</b> Quả bóng rổ sử dụng trong thi đấu có dạng hình cầu với đường kính bằng 24 cm (H.10.35). Hãy tính:</p>
<ol type="a">
<li>Diện tích bề mặt quả bóng.</li>
<li>Thể tích của quả bóng.</li>
</ol>', N'<p>Bán kính $R=24:2=12$ cm.</p>
<p><b>a)</b> $S=4\pi R^2=4\pi\cdot144=576\pi\ (\text{cm}^2)\approx1809\ (\text{cm}^2)$.</p>
<p><b>b)</b> $V=\dfrac{4}{3}\pi R^3=\dfrac{4}{3}\pi\cdot1728=2304\pi\ (\text{cm}^3)\approx7238\ (\text{cm}^3)$.</p>
<p><b>Đáp số:</b> a) $576\pi\ \text{cm}^2$. b) $2304\pi\ \text{cm}^3$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 10.25.</b> Đèn trời có dạng hình trụ không có một đáy với đường kính đáy bằng 0,8 m và thân đèn cao 1 m (H.10.36). Tính diện tích giấy dán bên ngoài đèn trời (coi các mép dán không đáng kể).</p>', N'<p>Giấy dán bên ngoài gồm mặt xung quanh và một đáy (đèn không có một đáy). Bán kính đáy $R=0{,}8:2=0{,}4$ m, chiều cao $h=1$ m.</p>
<p>$S_{xq}=2\pi Rh=2\pi\cdot0{,}4\cdot1=0{,}8\pi\ (\text{m}^2)$; $S_{\text{đáy}}=\pi R^2=0{,}16\pi\ (\text{m}^2)$.</p>
<p>$S=0{,}8\pi+0{,}16\pi=0{,}96\pi\approx3{,}02\ (\text{m}^2)$.</p>
<p><b>Đáp số:</b> $0{,}96\pi\ \text{m}^2\approx3{,}02\ \text{m}^2$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 10.26.</b> Các hình dưới đây (H.10.37) được tạo thành từ các nửa hình cầu, hình trụ và hình nón (có cùng bán kính đáy). Tính thể tích của các hình đó theo kích thước đã cho.</p>
<div><img src="/static/img/sgk9/sgk9-c10-hinh-10-37.png" alt="Hình 10.37: ba vật ghép từ nửa hình cầu, hình trụ, hình nón"></div>
<p>Hình a): nửa hình cầu đặt trên hình trụ cao 6 cm, đường kính đáy 8 cm. Hình b): nửa hình cầu đặt trên hình nón cao 10 cm, bán kính đáy 4 cm. Hình c): nửa hình cầu cao 1 cm đặt trên hình trụ cao 5 cm, phía dưới hình trụ là hình nón cao 5 cm.</p>', N'<p><b>a)</b> Bán kính $R=8:2=4$ cm. Hình trụ: $V_1=\pi\cdot4^2\cdot6=96\pi$. Nửa hình cầu: $V_2=\dfrac{1}{2}\cdot\dfrac{4}{3}\pi\cdot4^3=\dfrac{128\pi}{3}$. Thể tích: $V=96\pi+\dfrac{128\pi}{3}=\dfrac{416\pi}{3}\approx435{,}6\ (\text{cm}^3)$.</p>
<p><b>b)</b> Bán kính $R=4$ cm. Hình nón: $V_1=\dfrac{1}{3}\pi\cdot4^2\cdot10=\dfrac{160\pi}{3}$. Nửa hình cầu: $V_2=\dfrac{2}{3}\pi\cdot4^3=\dfrac{128\pi}{3}$. Thể tích: $V=\dfrac{288\pi}{3}=96\pi\approx301{,}6\ (\text{cm}^3)$.</p>
<p><b>c)</b> Nửa hình cầu cao 1 cm nên bán kính chung $R=1$ cm. Hình trụ: $V_1=\pi\cdot1^2\cdot5=5\pi$; hình nón: $V_2=\dfrac{1}{3}\pi\cdot1^2\cdot5=\dfrac{5\pi}{3}$; nửa hình cầu: $V_3=\dfrac{2}{3}\pi\cdot1^3=\dfrac{2\pi}{3}$. Thể tích: $V=5\pi+\dfrac{5\pi}{3}+\dfrac{2\pi}{3}=\dfrac{22\pi}{3}\approx23{,}0\ (\text{cm}^3)$.</p>
<p><b>Đáp số:</b> a) $\dfrac{416\pi}{3}\ \text{cm}^3$. b) $96\pi\ \text{cm}^3$. c) $\dfrac{22\pi}{3}\ \text{cm}^3$.</p>', 3, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 10.27.</b> Cho hình lập phương $ABCD.A''B''C''D''$ cạnh $a$. Tính thể tích của hình nón có đỉnh là tâm $O$ của hình vuông $ABCD$ và đáy là hình tròn tiếp xúc với các cạnh của hình vuông $A''B''C''D''$ (H.10.38).</p>
<div><img src="/static/img/sgk9/sgk9-c10-hinh-10-38.png" alt="Hình 10.38: hình nón trong hình lập phương"></div>', N'<p>Đáy hình nón là hình tròn nội tiếp hình vuông $A''B''C''D''$ cạnh $a$ nên bán kính đáy $r=\dfrac{a}{2}$.</p>
<p>Đỉnh $O$ nằm trên mặt $ABCD$, đáy nằm trên mặt $A''B''C''D''$ nên chiều cao hình nón bằng cạnh hình lập phương: $h=a$.</p>
<p>$V=\dfrac{1}{3}\pi r^2h=\dfrac{1}{3}\pi\cdot\dfrac{a^2}{4}\cdot a=\dfrac{\pi a^3}{12}$.</p>
<p><b>Đáp số:</b> $V=\dfrac{\pi a^3}{12}$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 10.28.</b> Bạn Khôi cho một hòn đá cảnh vào một bể nuôi cá hình trụ có đường kính đáy bằng 20 cm thì nước trong bể dâng lên 3 cm. Hỏi hòn đá cảnh đó có thể tích bằng bao nhiêu?</p>', N'<p>Thể tích hòn đá bằng thể tích phần nước dâng lên, là hình trụ có bán kính đáy $R=20:2=10$ cm và chiều cao $h=3$ cm.</p>
<p>$V=\pi R^2h=\pi\cdot10^2\cdot3=300\pi\approx942{,}5\ (\text{cm}^3)$.</p>
<p><b>Đáp số:</b> $300\pi\ \text{cm}^3\approx942{,}5\ \text{cm}^3$.</p>', 1, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 10.29.</b> Một chiếc kem ốc quế gồm hai phần: phần phía dưới dạng hình nón có chiều cao gấp đôi bán kính đáy, phần trên là nửa hình cầu có đường kính bằng đường kính đáy của hình nón phía dưới (H.10.39). Thể tích phần kem phía trên bằng $200\ \text{cm}^3$. Tính thể tích của cả chiếc kem.</p>', N'<p>Gọi $R$ là bán kính đáy hình nón, cũng là bán kính nửa hình cầu. Chiều cao hình nón $h=2R$.</p>
<p>Thể tích nửa hình cầu: $V_1=\dfrac{2}{3}\pi R^3=200\ (\text{cm}^3)$.</p>
<p>Thể tích hình nón: $V_2=\dfrac{1}{3}\pi R^2\cdot2R=\dfrac{2}{3}\pi R^3=200\ (\text{cm}^3)$.</p>
<p>Thể tích cả chiếc kem: $V=V_1+V_2=400\ (\text{cm}^3)$.</p>
<p><b>Đáp số:</b> $400\ \text{cm}^3$.</p>', 2, 0, 1, @t1);
INSERT INTO Questions (LessonId, QuestionType, Content, ExplanationLatex, [Level], IsAiGenerated, IsActive, TeacherId) VALUES (@l, 'ESSAY', N'<p><b>Bài 10.30.</b> Mái nhà hát Cao Văn Lầu và Trung tâm triển lãm Văn hoá Nghệ thuật tỉnh Cà Mau có hình dáng ba chiếc nón lá lớn nhất Việt Nam (H.10.40). Tính diện tích một mái nhà hình nón có đường kính bằng 45 m và chiều cao bằng 24 m (làm tròn kết quả đến hàng đơn vị của m²).</p>', N'<p>Bán kính đáy $r=45:2=22{,}5$ m, chiều cao $h=24$ m.</p>
<p>Độ dài đường sinh: $l=\sqrt{r^2+h^2}=\sqrt{22{,}5^2+24^2}=\sqrt{506{,}25+576}=\sqrt{1082{,}25}\approx32{,}9$ m.</p>
<p>Diện tích mái (diện tích xung quanh hình nón): $S_{xq}=\pi rl=\pi\cdot22{,}5\cdot32{,}9\approx2325\ (\text{m}^2)$.</p>
<p><b>Đáp số:</b> khoảng $2325\ \text{m}^2$.</p>', 2, 0, 1, @t1);


COMMIT TRANSACTION;

SELECT t.TopicName, COUNT(DISTINCT l.LessonId) AS Lessons, COUNT(q.QuestionId) AS Questions
FROM Topics t LEFT JOIN Lessons l ON l.TopicId = t.TopicId LEFT JOIN Questions q ON q.LessonId = l.LessonId
GROUP BY t.TopicId, t.TopicName, t.OrderIndex ORDER BY t.OrderIndex;
GO
