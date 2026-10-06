# Giải thích cơ sở dữ liệu MathTutorDB (EduTutor Math 12)

> Nguồn sự thật: `document/sql/01_schema.sql` (cấu trúc) và `document/sql/02_data.sql` (dữ liệu mẫu). Hibernate chạy với `hbm2ddl.auto = none` nên script SQL quyết định cấu trúc; mỗi bảng ánh xạ một Entity trong `com.edututor.model`. Sơ đồ ERD: xem `document/ERD.md`.

## 1. Tổng quan

- **Hệ quản trị:** SQL Server 2022, tên CSDL `MathTutorDB`.
- **Quy ước đặt tên:** bảng và cột dùng PascalCase (`Questions.IsActive`); SRS/FRS dùng snake_case (`questions.is_active`) cho cùng ý nghĩa.
- **10 bảng**, chia làm hai nhóm:
  - **6 bảng lõi:** `Users`, `Topics`, `Lessons`, `Questions`, `Submissions`, `TutorSessions`.
  - **4 bảng phụ (do chuẩn hóa):** `LessonMaterials`, `QuestionOptions`, `TutorMessages` (thuộc tính đa trị 1–N tách khỏi bảng cha), `AiConfigs` (cấu hình hệ thống).
- **Luồng dữ liệu chính:** Giáo viên tạo `Topics` → `Lessons` → `LessonMaterials` / `Questions` (+ `QuestionOptions`) → học sinh làm bài tạo `Submissions` → AI/giáo viên chấm → học sinh hỏi gia sư AI qua `TutorSessions` / `TutorMessages`. Admin quản lý `Users` và `AiConfigs`.

```
Users ─< Topics ─< Lessons ─┬─< LessonMaterials
                             └─< Questions ─┬─< QuestionOptions
                                            └─< Submissions >─ Users(học sinh)
Users ─< TutorSessions ─< TutorMessages        AiConfigs >─ Users(người sửa)
```

## 2. Mô tả từng bảng

### 2.1. Users — tài khoản người dùng
Lưu tài khoản của 3 vai trò: quản trị viên, giáo viên, học sinh.

| Cột | Kiểu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| UserId | INT IDENTITY | PK | Mã người dùng |
| Username | VARCHAR(50) | NOT NULL, UNIQUE | Tên đăng nhập (không đổi sau khi tạo) |
| PasswordHash | VARCHAR(64) | NOT NULL | Mật khẩu băm BCrypt (60 ký tự) |
| FullName | NVARCHAR(100) | NOT NULL | Họ tên |
| Email | VARCHAR(100) | NULL, UNIQUE | Email |
| Role | VARCHAR(20) | NOT NULL, CHECK | `ADMIN` / `TEACHER` / `STUDENT` |
| Status | VARCHAR(20) | NOT NULL, CHECK, mặc định `ACTIVE` | `ACTIVE` hoạt động · `SUSPENDED` khóa tạm · `INACTIVE` xóa mềm (Admin khôi phục được) |
| IsActive | BIT | NULL, mặc định 1 | Cột cũ, ứng dụng giữ đồng bộ: `1` khi và chỉ khi `Status = 'ACTIVE'` |
| TeacherId | INT | NULL, FK → Users | Giáo viên phụ trách (chỉ có nghĩa với STUDENT) |
| CreatedAt / UpdatedAt | DATETIME | | Thời điểm tạo / cập nhật |

Quan hệ: tự tham chiếu (`TeacherId` → `Users.UserId`); là cha của hầu hết các bảng khác (người tạo, người nộp bài, người duyệt, người cập nhật cấu hình).

### 2.2. Topics — chủ đề / chuyên đề
Cấp trên của bài học (ví dụ "Đạo hàm", "Tích phân").

| Cột | Kiểu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| TopicId | INT IDENTITY | PK | |
| TopicName | NVARCHAR(255) | NOT NULL | Tên chủ đề |
| Description | NVARCHAR(MAX) | NULL | Mô tả |
| TeacherId | INT | NOT NULL, FK → Users | Giáo viên tạo (BR-03: chỉ người tạo/Admin được sửa, xóa) |
| OrderIndex | INT | NOT NULL, mặc định 1 | Thứ tự hiển thị |
| IsActive | BIT | NOT NULL, mặc định 1 | **Xóa mềm**: `0` = ẩn (kể cả với học sinh) |
| CreatedAt / UpdatedAt | DATETIME | | |

### 2.3. Lessons — bài học
| Cột | Kiểu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| LessonId | INT IDENTITY | PK | |
| TopicId | INT | NOT NULL, FK → Topics, **ON DELETE CASCADE** | Chủ đề chứa bài học |
| Title | NVARCHAR(255) | NOT NULL | Tiêu đề |
| Summary | NVARCHAR(500) | NULL | Tóm tắt |
| Content | NVARCHAR(MAX) | NULL | Nội dung lý thuyết (LaTeX) |
| DisplayOrder | INT | NULL, mặc định 0 | Thứ tự trong chủ đề |
| IsActive | BIT | NOT NULL, mặc định 1 | Xóa mềm |
| CreatedBy | INT | NOT NULL, FK → Users | Người tạo |
| CreatedAt / UpdatedAt | DATETIME | | |

### 2.4. LessonMaterials — bài giảng đính kèm bài học
Mỗi bài học có nhiều tài liệu (video, YouTube, liên kết, văn bản).

| Cột | Kiểu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| MaterialId | INT IDENTITY | PK | |
| LessonId | INT | NOT NULL, FK → Lessons, CASCADE | |
| MaterialType | VARCHAR(10) | NOT NULL, CHECK | `VIDEO` / `YOUTUBE` / `LINK` / `TEXT` |
| Title | NVARCHAR(200) | NOT NULL | |
| Url | VARCHAR(500) | NULL | Dùng cho VIDEO, YOUTUBE, LINK |
| ContentText | NVARCHAR(MAX) | NULL | Dùng cho TEXT |
| OrderIndex | INT | NOT NULL, mặc định 1 | |
| CreatedBy | INT | NOT NULL, FK → Users | |
| CreatedAt / UpdatedAt | DATETIME | | |

Ràng buộc `CK_Material_Content`: `TEXT` bắt buộc có `ContentText`; các loại còn lại bắt buộc có `Url`. Index `IX_LessonMaterials_Lesson (LessonId, OrderIndex)`.

### 2.5. Questions — ngân hàng câu hỏi
| Cột | Kiểu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| QuestionId | INT IDENTITY | PK | |
| LessonId | INT | NOT NULL, FK → Lessons, CASCADE | Bài học chứa câu hỏi |
| QuestionType | VARCHAR(10) | NOT NULL, CHECK | `MCQ` trắc nghiệm / `ESSAY` tự luận |
| Content | NVARCHAR(MAX) | NOT NULL | Đề bài (LaTeX) |
| ExplanationLatex | NVARCHAR(MAX) | NULL | Lời giải; chỉ gửi học sinh **sau khi nộp bài** (BR-11) |
| Level | INT | NOT NULL, CHECK (1,2,3) | 1 Dễ · 2 Trung bình · 3 Khó |
| IsAiGenerated | BIT | NULL, mặc định 0 | Câu hỏi do AI sinh |
| IsActive | BIT | NOT NULL, mặc định 1 | Xóa mềm |
| TeacherId | INT | NOT NULL, FK → Users | Người tạo |
| CreatedAt / UpdatedAt | DATETIME | | |

Index `IX_Questions_Lesson_Active (LessonId, IsActive)`.

### 2.6. QuestionOptions — phương án trắc nghiệm
| Cột | Kiểu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| OptionId | INT IDENTITY | PK | |
| QuestionId | INT | NOT NULL, FK → Questions, CASCADE | |
| OptionLetter | CHAR(1) | NOT NULL, CHECK (A–F) | Chữ cái phương án |
| Content | NVARCHAR(MAX) | NOT NULL | Nội dung phương án |
| IsCorrect | BIT | NULL, mặc định 0 | Là đáp án đúng |
| CreatedAt / UpdatedAt | DATETIME | | |

`UNIQUE (QuestionId, OptionLetter)`: một câu không có hai phương án trùng chữ cái. Quy tắc nghiệp vụ BR-04 (đúng 4 phương án A–D, đúng 1 đáp án đúng) kiểm tra ở tầng Service, không phải ở DB.

### 2.7. Submissions — bài làm của học sinh
Gộp cả trắc nghiệm và tự luận, điểm thang 10.

| Cột | Kiểu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| SubmissionId | INT IDENTITY | PK | |
| StudentId | INT | NOT NULL, FK → Users | Học sinh nộp |
| LessonId | INT | NULL, FK → Lessons (NO ACTION) | Bài học của câu hỏi (sao chép từ câu hỏi), dùng thống kê tiến độ theo bài |
| QuestionId | INT | NOT NULL, FK → Questions | Câu hỏi được nộp |
| QuestionType | VARCHAR(10) | NOT NULL, CHECK | `MCQ` / `ESSAY` (sao chép từ câu hỏi) |
| StudentAnswer | NVARCHAR(MAX) | NULL | MCQ: chữ cái đã chọn; ESSAY: nội dung nhận diện/gõ tay |
| EssayImagePath | VARCHAR(255) | NULL | Đường dẫn ảnh bài tự luận `/uploads/essays/{studentId}/{uuid}.{ext}` |
| IsCorrect | BIT | NULL | Kết quả đúng/sai (MCQ) |
| AiScore | DECIMAL(4,2) | NULL, CHECK 0–10 | Điểm AI đề xuất — **không bao giờ bị ghi đè** (BR-09; Entity khai báo `updatable = false`) |
| FinalScore | DECIMAL(4,2) | NULL, CHECK 0–10 | Điểm chính thức (MCQ: 10 hoặc 0; ESSAY: điểm giáo viên duyệt) |
| AiFeedback | NVARCHAR(MAX) | NULL | Nhận xét của AI |
| SuggestedCorrection | NVARCHAR(MAX) | NULL | Gợi ý sửa của AI |
| TeacherFeedback | NVARCHAR(MAX) | NULL | Nhận xét của giáo viên |
| Status | VARCHAR(20) | NOT NULL, CHECK, mặc định `GRADED` | `GRADED` MCQ tự chấm · `AI_GRADED` tự luận AI đã chấm, chờ duyệt · `REVIEWED` giáo viên đã duyệt |
| IsReviewed | BIT | NULL, mặc định 0 | Cột cũ, giữ đồng bộ: `0` khi và chỉ khi `Status = 'AI_GRADED'` |
| ReviewedBy | INT | NULL, FK → Users | Giáo viên duyệt |
| ReviewedAt | DATETIME | NULL | Thời điểm duyệt |
| SubmittedAt | DATETIME | NULL, mặc định GETDATE() | Thời điểm nộp |
| UpdatedAt | DATETIME | NULL | |

Index `IX_Submissions_Student (StudentId, SubmittedAt DESC)` cho lịch sử làm bài.

### 2.8. AiConfigs — cấu hình AI
Admin sửa trên giao diện (khóa API, tên model, prompt…); code không hard-code các giá trị này.

| Cột | Kiểu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| ConfigId | INT IDENTITY | PK | |
| ConfigKey | VARCHAR(50) | NOT NULL, UNIQUE | Khóa cấu hình (không đổi) |
| ConfigValue | NVARCHAR(MAX) | NOT NULL | Giá trị (prompt tới 8.000 ký tự) |
| Description | NVARCHAR(255) | NULL | Mô tả |
| IsSecret | BIT | NOT NULL, mặc định 0 | `1` = chỉ hiển thị dạng che (khóa API) |
| UpdatedBy | INT | NULL, FK → Users | Admin sửa gần nhất |
| CreatedAt / UpdatedAt | DATETIME | | |

### 2.9. TutorSessions — phiên gia sư AI
Một phiên = một bài toán học sinh được AI hướng dẫn từng bước. Server là nguồn sự thật về bước hiện tại.

| Cột | Kiểu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| SessionId | INT IDENTITY | PK | |
| StudentId | INT | NOT NULL, FK → Users | Học sinh |
| LessonId | INT | NULL, FK → Lessons, **ON DELETE SET NULL** | Bài học làm ngữ cảnh; xóa bài học thì phiên vẫn giữ |
| QuestionId | INT | NULL, FK → Questions (NO ACTION) | Câu hỏi mà phiên được mở từ đó (câu sai / bài tự luận vừa chấm) |
| Title | NVARCHAR(255) | NOT NULL | Tiêu đề phiên |
| ProblemText | NVARCHAR(MAX) | NULL | Đề bài |
| CurrentStep | INT | NOT NULL, mặc định 1, CHECK ≥ 1 | Bước hiện tại |
| TotalSteps | INT | NOT NULL, mặc định 0, CHECK ≥ 0 | Tổng số bước (`0` = chưa xác định) |
| Status | VARCHAR(20) | NOT NULL, CHECK, mặc định `ACTIVE` | `ACTIVE` / `COMPLETED` / `ABANDONED` |
| AwaitingInput | BIT | NOT NULL, mặc định 0 | `1` = AI đang chờ học sinh nhập số liệu |
| InputHint | NVARCHAR(255) | NULL | Gợi ý cần nhập gì |
| CreatedAt / UpdatedAt | DATETIME | | |

Index `IX_TutorSessions_Student (StudentId, CreatedAt DESC)`. `QuestionId` dùng NO ACTION để tránh nhiều đường cascade (Lessons → Questions → TutorSessions và Lessons → TutorSessions).

### 2.10. TutorMessages — hội thoại trong phiên gia sư
| Cột | Kiểu | Ràng buộc | Ý nghĩa |
|---|---|---|---|
| MessageId | INT IDENTITY | PK | |
| SessionId | INT | NOT NULL, FK → TutorSessions, CASCADE | |
| SenderType | VARCHAR(10) | NOT NULL, CHECK | `USER` học sinh / `AI` gia sư |
| StepNumber | INT | NOT NULL, mặc định 1 | Bước mà tin nhắn thuộc về |
| ContentText | NVARCHAR(MAX) | NOT NULL | Nội dung |
| IsStepCompleted | BIT | NOT NULL, mặc định 0 | Tin nhắn này đã hoàn tất bước |
| CreatedAt / UpdatedAt | DATETIME | | |

Index `IX_TutorMessages_Session (SessionId, MessageId)` để nạp hội thoại theo thứ tự.

## 3. Quan hệ và hành vi khi xóa

| Quan hệ | Loại | Khi xóa cha |
|---|---|---|
| Users → Users (TeacherId) | 1–N, tùy chọn | NO ACTION |
| Users → Topics / Lessons / LessonMaterials / Questions (người tạo) | 1–N | NO ACTION |
| Users → Submissions (StudentId, ReviewedBy) | 1–N | NO ACTION |
| Users → TutorSessions (StudentId); Users → AiConfigs (UpdatedBy) | 1–N | NO ACTION |
| Topics → Lessons | 1–N | **CASCADE** |
| Lessons → LessonMaterials; Lessons → Questions | 1–N | **CASCADE** |
| Questions → QuestionOptions | 1–N | **CASCADE** |
| Questions → Submissions; Questions → TutorSessions; Lessons → Submissions | 1–N | NO ACTION (câu đã có bài nộp không bị xóa cứng) |
| Lessons → TutorSessions | 1–N, tùy chọn | **SET NULL** |
| TutorSessions → TutorMessages | 1–N | **CASCADE** |

Ứng dụng chủ yếu dùng **xóa mềm** (`IsActive = 0` cho Topics/Lessons/Questions, `Status = 'INACTIVE'` cho Users), nên các cascade chỉ phát huy khi xóa cứng.

## 4. Ràng buộc và chỉ mục

- **UNIQUE:** `Users(Username)`, `Users(Email)`, `QuestionOptions(QuestionId, OptionLetter)`, `AiConfigs(ConfigKey)`.
- **CHECK:** vai trò/trạng thái người dùng, loại tài liệu, loại câu hỏi, mức độ 1–3, chữ cái phương án, trạng thái bài nộp, điểm 0–10, trạng thái và bước của phiên gia sư, người gửi tin nhắn, và quy tắc `Url`/`ContentText` của `LessonMaterials`.
- **INDEX:** `LessonMaterials(LessonId, OrderIndex)`, `Questions(LessonId, IsActive)`, `Submissions(StudentId, SubmittedAt DESC)`, `TutorSessions(StudentId, CreatedAt DESC)`, `TutorMessages(SessionId, MessageId)`.

## 5. Lưu ý khi đối chiếu với code

- `Users.IsActive` và `Submissions.IsReviewed` là cột cũ, luôn phải đồng bộ với `Status` ở tầng ứng dụng; nguồn sự thật là `Status`.
- Quy tắc BR-04 (4 phương án, 1 đáp án đúng) và BR-03 (chỉ người tạo/Admin được sửa, xóa) không có ở tầng DB mà kiểm tra ở Service.
- `Users.Email` cho phép NULL, nhưng đã UNIQUE: SQL Server chỉ cho **một** dòng có Email NULL. Cần lưu ý nếu tạo nhiều tài khoản không có email.

## 6. Dữ liệu mẫu (`02_data.sql`)

Script nạp dữ liệu cho kịch bản demo: người dùng 3 vai trò, chủ đề và bài học, tài liệu bài giảng, ngân hàng câu hỏi kèm phương án, bài nộp trắc nghiệm/tự luận ở các trạng thái, và vài phiên gia sư kèm tin nhắn. Chạy `01_schema.sql` trước, rồi `02_data.sql`.

`03_data_gdpt2018.sql` bổ sung dữ liệu theo **Toán 12 chương trình mới (GDPT 2018)**: 4 chủ đề (Vectơ và hệ trục tọa độ, Mẫu số liệu ghép nhóm, Phương pháp tọa độ trong không gian, Xác suất có điều kiện) và 2 bài vào chủ đề cũ (Ứng dụng đạo hàm thực tế, Ứng dụng hình học của tích phân); tổng 13 bài học, 26 bài giảng (liên kết tìm kiếm YouTube + tóm tắt văn bản), 73 câu trắc nghiệm đủ 3 mức độ, 5 tự luận, 154 bài làm và 2 phiên gia sư. Chạy sau `02_data.sql`; chạy lại lần hai tự bỏ qua. Khi chạy bằng `sqlcmd` cần thêm `-x` (LaTeX có chuỗi `$(` bị hiểu là biến sqlcmd); SSMS không bị. **Cảnh báo:** `01_schema.sql` xóa CSDL `MathTutorDB` cũ rồi tạo lại.
