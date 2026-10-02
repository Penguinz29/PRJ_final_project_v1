# MathTutor 12 - Đặc tả Frontend (dùng để sinh code bằng AI)

> **Cách dùng:** lưu file này vào project tại `docs/FRONTEND_SPEC.md` (ngoài `src/`, không bị deploy).
> Mở **thư mục project Maven** làm workspace trong Antigravity, rồi dán lần lượt các **Prompt ở Mục 9**.
> Mỗi prompt chỉ tham chiếu mục tương ứng của file này. Sau mỗi prompt: quay lại NetBeans → **Clean and Build** → **Run** → đối chiếu **Tiêu chí nghiệm thu**.

---

## 1. Ràng buộc môi trường (BẮT BUỘC, AI không được vi phạm)

### 1.1. Nền tảng
| Hạng mục | Giá trị |
|---|---|
| IDE | NetBeans 17, project **Maven → Web Application** |
| JDK | 17 |
| Server | Apache Tomcat **10.1.x** (Jakarta EE 10, namespace `jakarta.*`) - đã xác nhận |
| Mô hình | MVC2: Servlet = Controller, JSP = View, JavaBean + DAO = Model |
| Root web | `src/main/webapp` |
| View | `src/main/webapp/WEB-INF/views/**` (JSP không truy cập trực tiếp được) |
| Static | `src/main/webapp/assets/{css,js,img}` |
| Package Java | `com.mathtutor.*` |
| Encoding | UTF-8 mọi nơi |

### 1.2. Điều CẤM
1. **Cấm** dùng `javax.servlet.*` (phải là `jakarta.servlet.*`).
2. **Cấm** scriptlet `<% ... %>` và `<%= ... %>` trong JSP. Chỉ dùng **EL + JSTL**. Duy nhất được phép: directive `<%@ page %>` và `<%@ taglib %>`.
3. **Cấm** SQL, JDBC, `new XxxDAO()` trong JSP.
4. **Cấm** framework cần build: React, Vue, Angular, Vite, Webpack, npm, Tailwind CLI, SASS. Chỉ **HTML + Bootstrap 5.3 (CDN) + CSS thuần + JavaScript thuần**.
5. **Cấm** chạy lệnh terminal (`npm`, `mvn`, chạy server). AI chỉ **tạo / sửa file**. Việc build và chạy do người dùng làm trong NetBeans.
6. **Cấm** sửa `pom.xml`, `web.xml`, các Servlet / DAO / Filter có sẵn, trừ khi prompt yêu cầu rõ.
7. **Cấm** lưu dữ liệu bằng `localStorage` cho nghiệp vụ. Dữ liệu thật luôn do server.
8. **Cấm** hard-code đường dẫn gốc như `/MathTutor/...`. Luôn dùng `${pageContext.request.contextPath}`.

### 1.3. Taglib và phiên bản (ĐÃ CHỐT: Tomcat 10.1.x + Jakarta EE 10 + JSTL 3.0)
Khai báo taglib như sau, không dùng URI cũ `http://java.sun.com/jsp/jstl/...`:
```jsp
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
```
> Lưu ý: URI `jakarta.tags.*` chỉ hoạt động với JSTL 3.0 (Tomcat 10.1). Nếu sau này đổi sang Tomcat 10.0.x thì toàn bộ JSP phải đổi lại URI cũ, nên **không đổi phiên bản Tomcat giữa chừng**.

### 1.4. Quy tắc viết JSP
- Dòng đầu mọi JSP: `<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>`.
- **Mọi** dữ liệu từ server đưa ra HTML phải qua `<c:out value="${...}"/>` (chống XSS). Công thức LaTeX trong đề bài cũng dùng `<c:out>`, KaTeX sẽ render phía client.
- Trong **text tĩnh** của JSP, tránh chuỗi `${` (EL sẽ cố tính toán). Nếu cần viết LaTeX tĩnh có dạng `$` liền `{`, viết `\${`.
- Form POST luôn: `method="post"`, `action="${pageContext.request.contextPath}/..."`, `class="needs-validation" novalidate`.
- Nút xóa luôn qua **modal xác nhận** và gửi bằng **POST** (không dùng link GET để xóa).
- Mỗi trang có đúng **một** `<h1>` (tiêu đề trang, trong `.page-header`).
- Không đặt `id` trùng nhau trong một trang.

### 1.5. Thư viện CDN (đặt version cố định)
| Thư viện | URL |
|---|---|
| Bootstrap CSS/JS | `https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/` |
| Bootstrap Icons | `https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css` |
| KaTeX | `https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/` (`katex.min.css`, `katex.min.js`, `contrib/auto-render.min.js`) |
| Font | Google Fonts `Be Vietnam Pro` (400, 500, 600, 700) |

---

## 2. Hệ thống thiết kế (Design System)

### 2.1. Biến màu (khai báo trong `style.css`, `:root`)
| Biến | Giá trị | Dùng cho |
|---|---|---|
| `--primary` | `#2563EB` | Nút chính, link, mục sidebar đang chọn |
| `--primary-dark` | `#1D4ED8` | Hover |
| `--primary-soft` | `#EFF6FF` | Nền mục sidebar active, nền highlight |
| `--bg` | `#F8FAFC` | Nền trang |
| `--surface` | `#FFFFFF` | Card |
| `--text` | `#0F172A` | Chữ chính |
| `--muted` | `#64748B` | Chữ phụ |
| `--border` | `#E2E8F0` | Viền |
| `--success` | `#16A34A` | Đúng, thành công |
| `--danger` | `#DC2626` | Sai, lỗi, xóa |
| `--warning` | `#F59E0B` | Nháp (DRAFT), cảnh báo |
| `--ai` | `#7C3AED` | Mọi thứ liên quan AI (badge, bong bóng chat) |
| `--radius` | `12px` | Bo góc card |

### 2.2. Kích thước và bố cục chung
- Font: `'Be Vietnam Pro', system-ui, sans-serif`, cỡ chữ gốc 15px.
- Navbar cố định trên, cao **56px**. Sidebar rộng **240px**. Từ `< 992px` sidebar thành **offcanvas** mở bằng nút hamburger ở navbar.
- Nội dung chính: `max-width: 1200px`, padding `1.5rem`.
- Khoảng cách theo thang Bootstrap (`mb-3`, `mb-4`, `gap-3`). Card: không viền, `box-shadow: 0 1px 3px rgba(15,23,42,.08)`.
- Bảng dùng `table table-hover align-middle` bọc trong `.table-responsive`, đặt trong card.

### 2.3. Bộ class tùy biến (bắt buộc đặt đúng tên để các trang đồng nhất)
| Class | Mô tả |
|---|---|
| `.app-shell` | Khung chứa sidebar + main (flex) |
| `.app-sidebar`, `.sidebar-link`, `.sidebar-link.active` | Sidebar và mục menu |
| `.app-main` | Vùng nội dung |
| `.page-header` | Hàng đầu trang: `h1` bên trái, nút hành động bên phải |
| `.stat-card` | Thẻ thống kê: icon tròn màu, số lớn, nhãn |
| `.table-card` | Card bọc bảng, có header chứa ô tìm kiếm / bộ lọc |
| `.badge-draft` | Vàng - trạng thái DRAFT |
| `.badge-approved` | Xanh lá - APPROVED |
| `.badge-ai` | Tím - nguồn AI |
| `.badge-level-1/2/3` | Độ khó Dễ / Vừa / Khó (xanh lá / vàng / đỏ nhạt) |
| `.question-card` | Card một câu hỏi |
| `.option-item` | Một đáp án (nhãn A-D tròn + nội dung), hover nổi nhẹ |
| `.option-item.selected` | Đáp án được chọn (viền primary) |
| `.option-item.correct` / `.option-item.wrong` | Kết quả (xanh lá / đỏ) |
| `.quiz-progress`, `.quiz-dot`, `.quiz-dot.answered`, `.quiz-dot.current` | Thanh tiến độ và chấm điều hướng câu |
| `.dropzone` | Khung kéo-thả ảnh |
| `.chat-box`, `.chat-msg`, `.chat-msg.user`, `.chat-msg.ai` | Khung chat và bong bóng |
| `.empty-state` | Trạng thái rỗng (icon lớn + câu + nút) |
| `.auth-wrapper`, `.auth-hero`, `.auth-form-side`, `.auth-card` | Trang đăng nhập |

---

## 3. Layout dùng chung (Fragment JSP)

Tất cả nằm ở `WEB-INF/views/common/`. Mọi trang sau đăng nhập dùng **đúng** khung dưới đây.

### 3.1. Khung trang chuẩn
```jsp
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/common/head.jsp">
  <jsp:param name="title" value="Quản lý giáo viên"/>
</jsp:include>
<body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<div class="app-shell">
  <jsp:include page="/WEB-INF/views/common/sidebar.jsp">
    <jsp:param name="active" value="admin-teachers"/>
  </jsp:include>
  <main class="app-main">
    <jsp:include page="/WEB-INF/views/common/flash.jsp"/>
    <div class="page-header"> <h1>...</h1> ... </div>
    <!-- nội dung -->
  </main>
</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
```
(`head.jsp` mở `<html>` ... đóng `</head>`; `footer.jsp` nạp script và đóng `</body></html>`.)

### 3.2. Từng fragment
| File | Đầu vào | Nội dung |
|---|---|---|
| `head.jsp` | `param.title` | `<head>`, CDN, font, KaTeX CSS, `style.css`. Tiêu đề: `<title>{title} \| MathTutor 12</title>` |
| `navbar.jsp` | session `currentUser` | Trái: nút hamburger (chỉ `< 992px`) + logo "MathTutor 12". Phải: avatar chữ cái đầu của `fullName`, tên, badge vai trò (ADMIN đỏ / TEACHER xanh dương / STUDENT xanh lá), dropdown có "Đăng xuất" (link tới `/logout`) |
| `sidebar.jsp` | `param.active` | Menu theo `currentUser.role`, dùng `c:choose`. Mục có `value == param.active` thêm class `active` |
| `flash.jsp` | session `flash` | Alert thành công, tự xóa khỏi session sau khi hiển thị (`c:remove`). Hỗ trợ thêm `requestScope.error` (alert đỏ) |
| `pagination.jsp` | attr `page`, `totalPages`; param `baseUrl` | Xem 3.3 |
| `footer.jsp` | - | Bootstrap bundle, KaTeX, auto-render, `app.js`, đóng body/html |
| `error.jsp` | `pageContext.errorData` | `isErrorPage="true"`. 403 / 404 / còn lại. Không in stack trace. Nút "Về trang chủ" |
| `confirm-modal.jsp` | - | Modal xác nhận xóa dùng chung (xem 7.3) |

### 3.3. `pagination.jsp`
- Dùng Bootstrap `pagination pagination-sm justify-content-center`.
- Ẩn hoàn toàn nếu `totalPages <= 1`.
- Hiển thị: Trước, cửa sổ tối đa **5 số trang** quanh trang hiện tại, Sau; trang đầu / cuối kèm dấu `...` khi cần. Trang hiện tại `active`; Trước / Sau `disabled` ở biên.
- Cách ghép URL: nhận `baseUrl` (đã gồm các tham số lọc), tự chọn dấu nối:
```jsp
<c:set var="sep" value="${fn:contains(param.baseUrl, '?') ? '&' : '?'}"/>
<a class="page-link" href="${param.baseUrl}${sep}page=${i}">${i}</a>
```
- Trang gọi tạo `baseUrl` bằng `c:url` + `c:param` (tự mã hóa ký tự đặc biệt, vẫn giữ bộ lọc):
```jsp
<c:url var="baseUrl" value="/teacher/questions">
  <c:param name="topicId" value="${param.topicId}"/>
  <c:param name="type" value="${param.type}"/>
  <c:param name="q" value="${param.q}"/>
</c:url>
<jsp:include page="/WEB-INF/views/common/pagination.jsp">
  <jsp:param name="baseUrl" value="${baseUrl}"/>
</jsp:include>
```
(`c:url` với đường dẫn bắt đầu bằng `/` tự thêm context path.)

### 3.4. Menu sidebar theo vai trò
| Role | Mục (nhãn - URL - icon - `active` key) |
|---|---|
| ADMIN | Tổng quan `/admin/dashboard` `bi-speedometer2` `admin-dashboard` · Giáo viên `/admin/teachers` `bi-person-workspace` `admin-teachers` · Học sinh `/admin/students` `bi-mortarboard` `admin-students` · Chủ đề `/admin/topics` `bi-folder2` `admin-topics` · Bài giảng `/admin/lessons` `bi-journal-text` `admin-lessons` · Câu hỏi `/admin/questions` `bi-patch-question` `admin-questions` |
| TEACHER | Tổng quan `/teacher/dashboard` `teacher-dashboard` · Chủ đề `/teacher/topics` `bi-folder2` `teacher-topics` · Bài giảng `/teacher/lessons` `bi-journal-text` `teacher-lessons` · Câu hỏi `/teacher/questions` `bi-patch-question` `teacher-questions` · AI sinh câu hỏi `/teacher/ai/generate` `bi-stars` `teacher-ai` · Học sinh của tôi `/teacher/students` `bi-people` `teacher-students` · Bài tự luận `/teacher/submissions` `bi-pencil-square` `teacher-submissions` |
| STUDENT | Tổng quan `/student/dashboard` `student-dashboard` · Chủ đề & bài giảng `/student/topics` `bi-book` `student-topics` · Hỏi AI từng bước `/student/ai-tutor` `bi-chat-dots` `student-ai` · Làm tự luận `/student/essay` `bi-camera` `student-essay` · Lịch sử làm bài `/student/history` `bi-clock-history` `student-history` |

Sidebar của Admin có 2 nhóm tiêu đề nhỏ: "Người dùng" (Giáo viên, Học sinh) và "Nội dung" (Chủ đề, Bài giảng, Câu hỏi). Có thêm nhóm tiêu đề nhỏ trong sidebar của Teacher: "Nội dung" (Chủ đề, Bài giảng, Câu hỏi, AI), "Lớp học" (Học sinh, Bài tự luận).

---

## 4. Hợp đồng dữ liệu (tên property và attribute mà JSP được phép dùng)

JSP chỉ đọc các tên dưới đây. Nếu Backend đổi tên, **cập nhật mục này trước**.

### 4.1. JavaBean (`com.mathtutor.model`) - truy cập bằng EL
| Bean | Property |
|---|---|
| `User` | `userId, username, fullName, email, phone, role, createdBy, active (boolean), createdAt` |
| `Topic` | `topicId, topicName, description, createdBy, creatorName, lessonCount, questionCount` |
| `Lesson` | `lessonId, topicId, topicName, creatorName, title, contentText, youtubeUrl, youtubeEmbedUrl, published (boolean), createdBy, createdAt` |
| `Question` | `questionId, topicId, topicName, creatorName, lessonId, type ("MCQ"/"ESSAY"), content, difficulty (1-3), solution, source ("MANUAL"/"AI"), status ("DRAFT"/"APPROVED"), createdBy, options (List<QuestionOption>)` |
| `QuestionOption` | `optionId, questionId, label ("A".."D"), text, correct (boolean)` |
| `Submission` | `submissionId, studentId, studentName, questionId, selectedOptionId, essayText, imagePath, correct (Boolean), aiFeedback, aiScore (Double), attemptCode, submittedAt` |
| `AttemptResult` | `attemptCode, correctCount, total, score10, submittedAt, topicName, items (List<ResultItem>)` |
| `ResultItem` | `question (Question, có options và solution), selectedOptionId, correct (boolean)` |
| `ChatMessage` | `role ("STUDENT"/"AI"), message, status ("WAIT_STUDENT"/"STEP_OK"/"DONE")` |
| `AiQuestionDraft` | `type, content, options (List<QuestionOption>), correctLabel, solution, difficulty` |

Ghi chú:
- Property boolean `active` truy cập `${u.active}`; `published` → `${l.published}`.
- Ngày giờ: dùng `<fmt:formatDate>` nếu bean trả `java.util.Date`; nếu trả `LocalDateTime` thì Backend nên cung cấp thêm property chuỗi `createdAtText` (định dạng `dd/MM/yyyy HH:mm`) vì JSTL không format trực tiếp `LocalDateTime`. **Quy ước dùng `createdAtText`, `submittedAtText`** để tránh lỗi.
- **Quan trọng cho trắc nghiệm:** khi làm bài, Backend **không** được đưa `correct` và `solution` vào dữ liệu gửi cho trang làm bài. JSP làm bài không được hiển thị chúng. Chỉ trang kết quả mới có.

### 4.2. Attribute theo trang (request scope trừ khi ghi khác)
| Trang | Attribute |
|---|---|
| Mọi trang đã đăng nhập | session: `currentUser (User)`, `flash (String, dùng một lần)` |
| Mọi trang có form | `errors (Map<String,String>)` theo tên field, `error (String)` lỗi chung |
| Mọi trang có phân trang | `page (int)`, `totalPages (int)`, `total (int)`, `q (String)` |
| `/login` | `error`, `username` |
| `/admin/dashboard` | `teacherCount, studentCount, questionCount, submissionCount` |
| `/admin/teachers`, `/admin/students` | `users (List<User>)` |
| `/admin/topics` | `topics (List<Topic>, kèm creatorName)`, `createdBy`, `teachers (List<User> cho bộ lọc người tạo)` |
| `/admin/lessons` | `lessons (List<Lesson>, kèm creatorName)`, `topics`, `teachers`, `topicId`, `createdBy`, `published` |
| `/admin/questions` | `questions (List<Question>, kèm creatorName)`, `topics`, `teachers`, `topicId`, `createdBy`, `type`, `status` |
| `/teacher/dashboard` | `topicCount, lessonCount, questionCount, studentCount, recentEssays (List<Submission>)` |
| `/teacher/topics` | `topics (List<Topic>)` |
| `/teacher/lessons` | `lessons (List<Lesson>)`, `topics (List<Topic>)` (cho bộ lọc), `topicId` |
| `/teacher/lessons/form` | `lesson (Lesson, khi sửa)`, `topics` |
| `/teacher/questions` | `questions (List<Question>)`, `topics`, `topicId, type, difficulty, status` |
| `/teacher/questions/form` | `question (khi sửa)`, `topics`, `lessons (List<Lesson> theo topic)` |
| `/teacher/ai/generate` | `topics`, `drafts (List<AiQuestionDraft>, sau khi sinh)`, `topicId, type, difficulty, count` |
| `/teacher/students` | `users (List<User>)` |
| `/teacher/submissions` | `submissions (List<Submission>)` |
| `/student/dashboard` | `topics (gợi ý, List<Topic>)`, `recentAttempts (List<AttemptResult>)` |
| `/student/topics` | `topics (List<Topic>)`, `lessonsByTopic (Map<Integer, List<Lesson>>)` |
| `/student/lesson` | `lesson (Lesson)` |
| `/student/quiz` | `questions (List<Question>, KHÔNG có đáp án đúng)`, `topic (Topic)`, `lesson (Lesson, tùy chọn)`, `attemptCode` |
| `/student/result` | `result (AttemptResult)` |
| `/student/history` | `attempts (List<AttemptResult>)` |
| `/student/essay` | Chế độ danh sách: `essayQuestions (List<Question>)`, `topics`, `topicId`. Chế độ làm bài (`?questionId=`): `question (Question)`, `submission (Submission, sau khi nộp)` |
| `/student/ai-tutor` | `topics`, `tutorQuestions (List<Question> ESSAY/MCQ để chọn đề)`, `question (khi có ?questionId)`, `history (List<ChatMessage>)` |

### 4.3. Tham số form và URL
| Hành động | URL / Method | Field |
|---|---|---|
| Đăng nhập | `/login` POST | `username, password` |
| Thêm giáo viên / học sinh | `/admin/teachers`, `/admin/students`, `/teacher/students` POST | `username, password, fullName, email, phone` |
| Khóa / mở khóa | `/admin/users/toggle` POST | `userId` |
| Sửa người dùng | `/admin/users/update` POST | `userId, fullName, email, phone` |
| Đặt lại mật khẩu | `/admin/users/reset-password` POST | `userId, newPassword, confirmPassword` |
| Thao tác nội dung (Admin) | `/admin/topics`, `/admin/lessons`, `/admin/questions` POST | `action` (`delete` / `hide` / `show` / `approve` / `draft`), `id` |
| Lưu topic | `/teacher/topics` POST | `action (create/update/delete), topicId, topicName, description` |
| Lưu bài giảng | `/teacher/lessons/form` POST | `lessonId, topicId, title, contentText, youtubeUrl, published (checkbox)` |
| Xóa bài giảng | `/teacher/lessons/delete` POST | `lessonId` |
| Lưu câu hỏi | `/teacher/questions/form` POST | `questionId, topicId, lessonId, type, content, difficulty, solution, optA, optB, optC, optD, correct (A-D)` |
| Duyệt / xóa câu hỏi | `/teacher/questions/approve`, `/teacher/questions/delete` POST | `questionId` |
| Sinh câu hỏi AI | `/teacher/ai/generate` POST | `topicId, type, difficulty, count` |
| Lưu câu AI | `/teacher/ai/save` POST | `topicId, status (DRAFT/APPROVED), idx (nhiều giá trị)` và với mỗi idx `i`: `type_i, content_i, optA_i..optD_i, correct_i, solution_i, difficulty_i` |
| Bắt đầu trắc nghiệm | `/student/quiz` GET | `topicId, lessonId (tùy chọn), count (5/10/15)` |
| Nộp trắc nghiệm | `/student/quiz` POST | `attemptCode`, `answer_{questionId}` = `optionId` |
| Xem kết quả | `/student/result` GET | `attempt` |
| Nộp tự luận | `/student/essay` POST (multipart) | `questionId, essayText, image` |
| Chấm lại tay (giáo viên) | `/teacher/submissions/review` POST | `submissionId, score, comment` |
| Chat AI | `/student/ai-tutor/chat` POST (`application/x-www-form-urlencoded`) | `questionId` hoặc `customQuestion`, `message` → trả JSON `{status, message, ask}` |
| Xem ảnh bài làm | `/files/essay-image?submissionId=` GET | - (Backend kiểm tra quyền; Admin, giáo viên sở hữu câu hỏi, học sinh chủ bài) |

---

## 5. Đặc tả từng trang

Quy ước mỗi trang: **File** · **URL** · **Role** · **`active`** · **Dữ liệu** · **Giao diện** · **Trạng thái đặc biệt** · **JS**. "Trạng thái rỗng" luôn dùng `.empty-state`.

### 5.1. Đăng nhập
- **File:** `WEB-INF/views/login.jsp` · **URL:** `/login` · **Role:** công khai.
- **Dữ liệu:** `error`, `username`.
- **Giao diện:** `.auth-wrapper` hai cột. Trái (`.auth-hero`, ẩn `< 992px`): nền gradient `#1E3A8A → #2563EB`, icon máy tính, tiêu đề "MathTutor 12", câu "Gia sư Toán lớp 12 có AI đồng hành", 3 dòng tính năng có icon. Phải (`.auth-form-side`): `.auth-card` max-width 400px: tiêu đề "Đăng nhập", phụ đề, alert lỗi (nếu có `error`), form 2 trường, nút "Đăng nhập".
- **Trường:**
  - `username`: input-group icon `bi-person`, `required minlength=4 maxlength=30 autofocus autocomplete=username`, giữ lại giá trị bằng `<c:out value='${username}'/>`. Lỗi: "Vui lòng nhập tài khoản (4-30 ký tự)."
  - `password`: icon `bi-lock`, `required minlength=6 maxlength=50 autocomplete=current-password`, nút con mắt `data-toggle-password="#password"`. Lỗi: "Vui lòng nhập mật khẩu (tối thiểu 6 ký tự)."
- **Dòng cuối:** chữ nhỏ muted "Chưa có tài khoản? Vui lòng liên hệ quản trị viên hoặc giáo viên của bạn." (**không** có nút đăng ký, **không** có đăng nhập Google).
- **Khối tài khoản demo:** hộp nhỏ liệt kê `admin / teacher1 / student1 - mật khẩu 123456`, bọc trong comment `<%-- DEMO: xóa khi nộp bài --%>` để dễ xóa.
- **JS:** validate + vô hiệu hóa nút sau khi gửi (`needs-validation`).

### 5.2. Trang lỗi
- **File:** `common/error.jsp` · 403 (icon `bi-shield-lock`, vàng), 404 (`bi-compass`, xanh), mặc định 500 (`bi-exclamation-octagon`, đỏ). Căn giữa màn hình, nút "Về trang chủ" tới `/login` (Backend sẽ tự chuyển theo role nếu đã đăng nhập). Không in `exception`.

### 5.3. `index.jsp`
- `<c:redirect url="/login"/>`.

### 5.4. Admin - Tổng quan
- **File:** `admin/dashboard.jsp` · `/admin/dashboard` · `admin-dashboard`.
- **Dữ liệu:** `teacherCount, studentCount, questionCount, submissionCount`.
- **Giao diện:** lời chào "Xin chào, {fullName}". Hàng 4 `.stat-card` (`row row-cols-1 row-cols-sm-2 row-cols-xl-4 g-3`): Giáo viên (`bi-person-workspace`, xanh dương), Học sinh (`bi-mortarboard`, xanh lá), Câu hỏi (`bi-patch-question`, tím), Bài làm (`bi-check2-square`, cam). Dưới là card "Thao tác nhanh" với 2 nút: "Thêm giáo viên", "Thêm học sinh" (link tới trang tương ứng kèm `?add=1` để tự mở modal).

### 5.5. Admin - Giáo viên / Học sinh (hai trang cùng mẫu)
- **File:** `admin/teachers.jsp`, `admin/students.jsp` · `/admin/teachers`, `/admin/students` · `admin-teachers`, `admin-students`.
- **Dữ liệu:** `users, page, totalPages, total, q, errors`.
- **Giao diện:**
  - `.page-header`: h1 "Quản lý giáo viên" (hoặc "học sinh"), nút "Thêm giáo viên" mở modal `#addUserModal`.
  - `.table-card` header: form tìm kiếm GET (`q`, nút kính lúp) và dòng "Tổng: {total}".
  - Bảng cột: `#` (số thứ tự theo trang: `(page-1)*5 + loop.count`), Họ tên, Tài khoản, Email, Điện thoại, Trạng thái (badge "Hoạt động" xanh / "Đã khóa" xám), Ngày tạo, Thao tác.
  - Thao tác: nút **Khóa / Mở khóa** (form POST `/admin/users/toggle`, input hidden `userId`, mở confirm-modal) — đổi nhãn và màu theo `active`.
  - Phân trang bằng `pagination.jsp` với `baseUrl` giữ `q`.
- **Modal thêm** (`#addUserModal`, form POST về chính URL, `needs-validation`): trường `fullName, username, email, phone (tùy chọn), password`. Mỗi trường hiện lỗi từ `errors['tenField']` bằng `is-invalid` + `invalid-feedback`; giữ lại giá trị đã nhập (`<c:out value="${param.xxx}"/>`).
- **Cột Thao tác bổ sung (Admin):** nút **Sửa** mở modal `#editUserModal` (điền sẵn `fullName, email, phone` bằng `data-*`, `username` chỉ đọc, POST `/admin/users/update` kèm hidden `userId`); nút **Đặt lại mật khẩu** mở modal `#resetPwdModal` (`newPassword` 6-50 ký tự, `confirmPassword` phải khớp - JS báo ngay, server kiểm tra lại; POST `/admin/users/reset-password`). Lỗi từ server hiện trong đúng modal và modal tự mở lại.
- **Rỗng:** `.empty-state` "Chưa có giáo viên nào" khi `users` rỗng.
- **JS:** nếu `errors` không rỗng thì **tự mở lại modal** (đặt `data-open-on-load="true"` lên modal); nếu URL có `?add=1` cũng tự mở.
- **Validation client:** username `pattern="[A-Za-z0-9_]{4,30}"`, password `minlength=6 maxlength=50`, email `type=email maxlength=100`, phone `pattern="0[0-9]{9}"`.

### 5.6. Teacher - Tổng quan
- **File:** `teacher/dashboard.jsp` · `teacher-dashboard`.
- **Dữ liệu:** `topicCount, lessonCount, questionCount, studentCount, recentEssays`.
- **Giao diện:** 4 `.stat-card` (Chủ đề, Bài giảng, Câu hỏi, Học sinh). Card "Bài tự luận mới nhất" (bảng 5 dòng: học sinh, câu hỏi cắt 60 ký tự, thời gian, nút "Xem" tới `/teacher/submissions`). Card "Bắt đầu nhanh": nút "Thêm câu hỏi", "AI sinh câu hỏi", "Thêm bài giảng".

### 5.7. Teacher - Chủ đề
- **File:** `teacher/topics.jsp` · `/teacher/topics` · `teacher-topics`.
- **Dữ liệu:** `topics, page, totalPages, q, errors`.
- **Giao diện:** page-header + nút "Thêm chủ đề". Tìm kiếm theo tên. Bảng: `#`, Tên chủ đề, Mô tả (cắt 80 ký tự), Số bài giảng, Số câu hỏi, Thao tác (Sửa, Xóa). Phân trang.
- **Modal Thêm/Sửa** dùng chung (`#topicModal`): `topicName` (required, 2-150), `description` (textarea, tối đa 500). Nút Sửa điền sẵn dữ liệu qua `data-*` bằng JS và đặt `action=update` + `topicId`. Nút Xóa dùng confirm-modal, gửi `action=delete`.
- **Lỗi:** thông báo trùng tên hiện ở `errors.topicName`; lỗi xóa (đang được dùng) hiện bằng alert đỏ từ `error`.

### 5.8. Teacher - Bài giảng (danh sách)
- **File:** `teacher/lessons.jsp` · `teacher-lessons`.
- **Dữ liệu:** `lessons, topics, topicId, page, totalPages, q`.
- **Giao diện:** page-header + nút "Thêm bài giảng" (link `/teacher/lessons/form`). Bộ lọc: select Chủ đề (có "Tất cả") + ô tìm kiếm, gửi GET. Bảng: Tiêu đề, Chủ đề, Video (icon `bi-youtube` đỏ nếu có `youtubeUrl`), Trạng thái (badge "Đã đăng" xanh / "Nháp" vàng), Ngày tạo, Thao tác (Sửa, Xóa qua confirm-modal gửi `/teacher/lessons/delete`). Phân trang giữ `topicId`, `q`.

### 5.9. Teacher - Form bài giảng
- **File:** `teacher/lesson-form.jsp` · `/teacher/lessons/form` · `teacher-lessons`.
- **Dữ liệu:** `lesson` (rỗng = thêm mới), `topics`, `errors`.
- **Giao diện:** 2 cột (`col-lg-8` / `col-lg-4`).
  - Cột trái, card "Nội dung": `title` (required 2-200), `topicId` (select required), `contentText` (textarea 12 dòng, gợi ý "Có thể dùng LaTeX: $x^2$"), bên dưới là **khung xem trước KaTeX** (cập nhật khi gõ, debounce 300ms).
  - Cột phải: card "Video YouTube": ô `youtubeUrl` + vùng preview `iframe` trong `div.ratio.ratio-16x9`; card "Xuất bản": công tắc `form-check form-switch` `published` (mặc định bật); nút "Lưu" và "Hủy".
- **JS:** hàm `youtubeToEmbed(url)` nhận `watch?v=ID`, `youtu.be/ID`, `shorts/ID` và trả `https://www.youtube.com/embed/ID`; link không hợp lệ thì hiện `is-invalid` "Link YouTube không hợp lệ" và ẩn preview. Preview chỉ là xem trước, server vẫn kiểm tra lại.

### 5.10. Teacher - Ngân hàng câu hỏi
- **File:** `teacher/questions.jsp` · `teacher-questions`.
- **Dữ liệu:** `questions, topics, topicId, type, difficulty, status, q, page, totalPages`.
- **Giao diện:** page-header: nút "Thêm câu hỏi" (`/teacher/questions/form`) và nút "AI sinh câu hỏi" (viền tím, `/teacher/ai/generate`). Hàng bộ lọc (GET): Chủ đề, Loại (MCQ/ESSAY), Độ khó (1-3), Trạng thái (DRAFT/APPROVED), ô tìm nội dung, nút "Lọc" và "Xóa lọc".
- Bảng: `#`, Nội dung (cắt 90 ký tự, render KaTeX), Chủ đề, Loại (badge), Độ khó (`.badge-level-n`), Nguồn (`.badge-ai` "AI" nếu `source=='AI'`), Trạng thái (`.badge-draft`/`.badge-approved`), Thao tác: Xem, Sửa, **Duyệt** (chỉ hiện khi DRAFT, POST `/teacher/questions/approve`), Xóa (confirm-modal).
- Nút **Xem** mở modal chi tiết (JS, lấy từ `data-*` hoặc render sẵn ẩn): nội dung, 4 đáp án với đáp án đúng tô xanh, lời giải. Nội dung render KaTeX khi modal mở.
- Phân trang giữ toàn bộ bộ lọc bằng `c:url`.

### 5.11. Teacher - Form câu hỏi
- **File:** `teacher/question-form.jsp` · `/teacher/questions/form` · `teacher-questions`.
- **Dữ liệu:** `question` (khi sửa), `topics`, `lessons`, `errors`.
- **Giao diện:**
  - Hàng chọn: `type` (hai nút radio dạng toggle "Trắc nghiệm" / "Tự luận"; khóa không cho đổi khi sửa), `topicId`, `lessonId` (tùy chọn, "Không gắn bài"), `difficulty` (1 Dễ, 2 Vừa, 3 Khó).
  - `content` (textarea 5 dòng) + **preview KaTeX** ngay bên dưới.
  - **Khối MCQ** (hiện khi type = MCQ): 4 hàng `A, B, C, D`, mỗi hàng gồm radio `correct` (value A-D), nhãn tròn, input `optA..optD` (required khi MCQ). Có chú thích "Chọn nút tròn bên trái để đánh dấu đáp án đúng".
  - **Khối lời giải**: `solution` (textarea), nhãn "Lời giải chuẩn (chỉ giáo viên và AI thấy)"; bắt buộc với ESSAY.
  - Nút "Lưu" và "Hủy".
- **JS:** đổi type thì ẩn / hiện khối MCQ và bật / tắt `required` tương ứng (field bị ẩn phải `disabled` để không bị gửi lên). Validate: MCQ cần đủ 4 đáp án khác nhau và đã chọn đúng một đáp án, nếu không hiện lỗi đỏ "Cần 4 đáp án và 1 đáp án đúng".
- **Giữ giá trị** khi server trả lỗi.

### 5.12. Teacher - AI sinh câu hỏi
- **File:** `teacher/ai-generate.jsp` · `/teacher/ai/generate` · `teacher-ai`.
- **Dữ liệu:** `topics`, `drafts`, `error`, giá trị đã chọn.
- **Giao diện:**
  - Card "Thiết lập": `topicId`, `type`, `difficulty`, `count` (1-10, mặc định 5), nút "Sinh câu hỏi" (màu `--ai`, icon `bi-stars`). Khi bấm: nút thành spinner "AI đang soạn câu hỏi...", toàn form bị vô hiệu (AI có thể mất 10-30 giây).
  - Nếu `error` không rỗng: alert đỏ "AI đang bận, vui lòng thử lại" kèm nút "Thử lại".
  - Nếu có `drafts`: card "Xem trước" (`form` POST `/teacher/ai/save`) gồm một `.question-card` cho mỗi câu, có:
    - checkbox chọn `idx` (mặc định tích), nhãn "Câu {n}", badge loại và độ khó;
    - các input **có thể sửa**: `content_i` (textarea), `optA_i..optD_i` + radio `correct_i` (nếu MCQ), `solution_i`, hidden `type_i`, `difficulty_i`;
    - preview KaTeX cho nội dung.
  - Thanh dưới cố định (sticky): "Đã chọn X / N câu", select `status` ("Lưu nháp" = DRAFT mặc định, "Lưu và duyệt luôn" = APPROVED), nút "Lưu các câu đã chọn", hidden `topicId`.
  - Alert vàng cố định phía trên: "AI có thể giải sai. Hãy kiểm tra từng câu trước khi duyệt."
- **JS:** đếm số câu đã chọn; vô hiệu nút Lưu khi chọn 0 câu; spinner khi submit.

### 5.13. Teacher - Học sinh của tôi
- **File:** `teacher/students.jsp` · `teacher-students` · giống 5.5 (không có cột thao tác khóa / sửa / đặt lại mật khẩu, chỉ thêm; chỉ hiện học sinh do giáo viên này tạo). Tiêu đề "Học sinh của tôi", modal "Thêm học sinh". Cột: Họ tên, Tài khoản, Email, Điện thoại, Trạng thái, Ngày tạo.

### 5.14. Teacher - Bài tự luận
- Chỉ hiển thị bài làm trên **câu hỏi do giáo viên này tạo**.
- **File:** `teacher/submissions.jsp` · `teacher-submissions`.
- **Dữ liệu:** `submissions, page, totalPages`.
- **Giao diện:** danh sách dạng card (mỗi bài một card, 1 cột): đầu card: tên học sinh, thời gian, đề bài (KaTeX). Thân card 2 cột: trái là ảnh bài làm (thumbnail `max-height:200px`, bấm để mở modal ảnh lớn; ảnh lấy từ `/files/essay-image?submissionId=`; nếu không có ảnh hiện text `essayText`); phải là khối "Nhận xét AI" (nền tím nhạt, hiển thị `aiFeedback`, điểm gợi ý `aiScore`/10 dạng badge; nếu `aiFeedback` rỗng hiện "AI chưa nhận xét"). Chân card: form "Chấm lại" (`score` 0-10 bước 0.5, `comment` textarea), POST `/teacher/submissions/review`.
- Phân trang. Rỗng: "Chưa có bài tự luận nào".

### 5.15. Student - Tổng quan
- **File:** `student/dashboard.jsp` · `student-dashboard`.
- **Dữ liệu:** `topics, recentAttempts`.
- **Giao diện:** banner chào "Chào {fullName}, hôm nay luyện gì nào?". Lưới card "Chủ đề gợi ý" (tối đa 4, mỗi card icon, tên, số câu hỏi, nút "Luyện tập" và "Xem bài giảng"). Card "Kết quả gần đây" (5 dòng: chủ đề, điểm /10 với màu theo mức, thời gian, link "Xem lại" tới `/student/result?attempt=`). Card nổi bật tím "Hỏi gia sư AI" với nút tới `/student/ai-tutor`.

### 5.16. Student - Chủ đề và bài giảng
- **File:** `student/topics.jsp` · `student-topics`.
- **Dữ liệu:** `topics, lessonsByTopic`.
- **Giao diện:** `accordion` Bootstrap, mỗi chủ đề là một mục (tên, mô tả, số câu hỏi). Mở ra: danh sách bài giảng (tiêu đề, icon video nếu có, link tới `/student/lesson?id=`), cuối mục có nút **"Luyện tập chủ đề này"** mở modal chọn số câu (5/10/15) rồi GET `/student/quiz?topicId=&count=`. Mỗi bài giảng cũng có nút nhỏ "Luyện bài này" gửi thêm `lessonId`.
- **Rỗng:** `.empty-state` "Chưa có chủ đề nào".

### 5.17. Student - Xem bài giảng
- **File:** `student/lesson.jsp` · `student-topics`.
- **Giao diện:** breadcrumb Chủ đề › Bài giảng. Tiêu đề, badge chủ đề. Nếu `youtubeEmbedUrl` có: `div.ratio.ratio-16x9` chứa `iframe` (`allowfullscreen`, `loading="lazy"`, `referrerpolicy="strict-origin-when-cross-origin"`). Nội dung `contentText` trong card, `white-space: pre-line`, render KaTeX. Cuối: nút "Luyện tập bài này" (modal chọn số câu) và "Quay lại".

### 5.18. Student - Làm trắc nghiệm
- **File:** `student/quiz.jsp` · `/student/quiz` GET · `student-topics`.
- **Dữ liệu:** `questions, topic, lesson, attemptCode`.
- **Giao diện:** thanh trên: tên chủ đề (và bài), "Câu x/N", `.quiz-progress` (progress bar). Một `form` POST `/student/quiz` chứa hidden `attemptCode` và **tất cả** câu hỏi dưới dạng `.question-card` (mỗi câu chứa 4 `radio` tên `answer_{questionId}`, giá trị `optionId`, hiển thị dạng `.option-item` có nhãn tròn A-D). JS chỉ **hiện một câu mỗi lần**. Dưới: nút "Câu trước", "Câu tiếp", nút "Nộp bài" (chỉ hiện ở câu cuối và luôn có ở thanh phụ). Dải `.quiz-dot` (số thứ tự) bên phải hoặc dưới: xanh khi đã trả lời, viền đậm cho câu hiện tại, bấm để nhảy câu.
- **Nộp bài:** mở confirm-modal "Bạn còn X câu chưa trả lời. Vẫn nộp bài?" (nếu 0 câu thì "Xác nhận nộp bài?"). Sau khi nộp, vô hiệu nút.
- **Không JS:** nếu JS tắt, tất cả câu hiển thị liền nhau (progressive enhancement, thêm class `js` lên `<html>` bằng JS để chỉ ẩn câu khi JS chạy).
- **Chống thoát nhầm:** `beforeunload` cảnh báo khi đã chọn ít nhất 1 đáp án và chưa nộp.
- **Rỗng:** nếu `questions` rỗng: `.empty-state` "Chủ đề này chưa có câu hỏi" kèm nút quay lại.
- **Tuyệt đối không** hiển thị đáp án đúng hay lời giải ở trang này.

### 5.19. Student - Kết quả
- **File:** `student/result.jsp` · `/student/result?attempt=` · `student-history`.
- **Dữ liệu:** `result`.
- **Giao diện:** card tóm tắt: vòng tròn điểm lớn "{score10}/10" (xanh ≥ 8, vàng 5-7.9, đỏ < 5), "Đúng {correctCount}/{total} câu", chủ đề, thời gian. Danh sách `.question-card` cho mỗi `ResultItem`: tiêu đề "Câu n" với icon đúng (xanh) / sai (đỏ); nội dung; 4 `.option-item` trong đó đáp án đúng có class `correct`, đáp án học sinh chọn sai có class `wrong`, đáp án học sinh chọn có thêm nhãn "Bạn chọn"; khối "Lời giải" thu gọn (collapse) hiển thị `solution`. Nút cuối: "Làm lại chủ đề này", "Hỏi AI về câu sai" (link tới `/student/ai-tutor?questionId=` cho từng câu sai), "Về trang chủ".

### 5.20. Student - Lịch sử
- **File:** `student/history.jsp` · `student-history`.
- **Dữ liệu:** `attempts, page, totalPages`.
- **Giao diện:** bảng: `#`, Thời gian, Chủ đề, Số câu, Đúng, Điểm (badge màu), nút "Xem lại". Phân trang. Rỗng: "Bạn chưa làm bài nào" + nút "Bắt đầu luyện tập".

### 5.21. Student - Làm tự luận
- **File:** `student/essay.jsp` · `/student/essay` · `student-essay`. Hai chế độ theo có `question` hay không.
- **Chế độ A - chọn đề** (`essayQuestions`): bộ lọc chủ đề, danh sách card đề (nội dung cắt, chủ đề, độ khó, nút "Làm bài" tới `?questionId=`), phân trang.
- **Chế độ B - làm bài** (`question`): hai cột.
  - Trái: card đề bài (KaTeX, badge độ khó), `textarea essayText` (6 dòng, tùy chọn, "Có thể gõ bài giải hoặc chỉ gửi ảnh").
  - Phải: `.dropzone` (kéo-thả hoặc bấm chọn, `input type=file name=image accept="image/jpeg,image/png,image/webp"`), preview ảnh, nút "Chọn ảnh khác / Xóa ảnh", chú thích "JPG, PNG, WEBP, tối đa 5MB". Trên điện thoại cho phép chụp ảnh trực tiếp (`capture` không bắt buộc).
  - Form `enctype="multipart/form-data"`, nút "Nộp bài và nhờ AI nhận xét" (màu `--ai`).
  - Yêu cầu: phải có ít nhất text hoặc ảnh, nếu cả hai rỗng hiện lỗi.
- **Sau khi nộp** (`submission` có): thay form bằng card "Bài đã nộp" (ảnh / text) và card **"Nhận xét của AI"** (nền tím nhạt, `aiFeedback`, badge điểm gợi ý `aiScore/10`, ghi chú "Điểm AI chỉ mang tính tham khảo, giáo viên có thể chấm lại"). Nếu `aiFeedback` rỗng: "AI chưa nhận xét được. Bạn có thể thử lại sau." Nút "Làm đề khác".
- **JS:** kiểm tra client đuôi file và dung lượng ≤ 5MB, sai thì hiện lỗi đỏ và xóa lựa chọn; preview bằng `URL.createObjectURL`; khi submit hiện spinner "Đang nộp và chờ AI nhận xét (có thể mất vài chục giây)...".

### 5.22. Student - Hỏi AI từng bước
- **File:** `student/ai-tutor.jsp` · `/student/ai-tutor` · `student-ai`.
- **Dữ liệu:** `topics, tutorQuestions, question, history`.
- **Giao diện:**
  - Nếu chưa có đề (`question` rỗng và không có `customQuestion` trong phiên): card chọn đề với 2 tab: **"Chọn đề có sẵn"** (select chủ đề → select câu hỏi từ `tutorQuestions`, nút "Bắt đầu") và **"Nhập đề của bạn"** (textarea, preview KaTeX, nút "Bắt đầu").
  - Khi đã có đề: header hiển thị đề (KaTeX, thu gọn được) + nút "Đổi đề". Dưới là `.chat-box` (chiều cao `calc(100vh - 320px)`, cuộn): bong bóng AI bên trái (nền tím nhạt, avatar `bi-robot`), học sinh bên phải (nền primary, chữ trắng). `history` ban đầu được render sẵn.
  - Thanh nhập cuối: `textarea` 2 dòng (Enter gửi, Shift+Enter xuống dòng), nút "Gửi" (`bi-send`). Dòng gợi ý nhỏ: "Hãy viết bước làm của bạn. AI sẽ gợi ý chứ không đưa đáp án ngay."
- **Trạng thái trả về `status`:**
  - `WAIT_STUDENT`: hiện `message` và nếu có `ask` thì in đậm ở dòng riêng.
  - `STEP_OK`: bong bóng AI có icon tick xanh `bi-check-circle-fill`.
  - `DONE`: bong bóng chúc mừng nền xanh lá, khóa ô nhập, hiện nút "Làm đề khác".
- **JS (xem 7.5):** gửi bằng `fetch` POST form-encoded; thêm bong bóng học sinh ngay, hiện "AI đang suy nghĩ..." (3 chấm nhấp nháy), vô hiệu ô nhập khi chờ; lỗi mạng / HTTP khác 200 thì hiện bong bóng đỏ "Không kết nối được AI, vui lòng thử lại" và mở lại ô nhập; tự cuộn xuống cuối; render KaTeX cho bong bóng mới; **escape HTML** trước khi chèn (`textContent`, không dùng `innerHTML` với dữ liệu thô).

### 5.23. Admin - Chủ đề (quản lý nội dung)
- **File:** `admin/topics.jsp` · `/admin/topics` · `admin-topics`.
- **Dữ liệu:** `topics, teachers, createdBy, q, page, totalPages`.
- **Giao diện:** h1 "Quản lý chủ đề". Bộ lọc GET: select Người tạo (từ `teachers`, có "Tất cả"), ô tìm theo tên. Bảng: `#`, Tên chủ đề, Mô tả (cắt 80 ký tự), Người tạo (`creatorName`), Số bài giảng, Số câu hỏi, Thao tác: nút **Xóa** (đỏ, qua confirm-modal, POST `action=delete` + `id`). Nếu `lessonCount + questionCount > 0` thì nút Xóa bị `disabled` kèm tooltip "Chủ đề đang có dữ liệu". Admin **không** sửa nội dung chủ đề (việc của giáo viên). Phân trang giữ `createdBy`, `q`.

### 5.24. Admin - Bài giảng (quản lý nội dung)
- **File:** `admin/lessons.jsp` · `/admin/lessons` · `admin-lessons`.
- **Dữ liệu:** `lessons, topics, teachers, topicId, createdBy, published, q, page, totalPages`.
- **Giao diện:** h1 "Quản lý bài giảng". Bộ lọc: Chủ đề, Người tạo, Trạng thái (Đã đăng / Ẩn), ô tìm tiêu đề. Bảng: Tiêu đề (bấm mở modal xem trước nội dung KaTeX + video), Chủ đề, Người tạo, Video (icon), Trạng thái (badge), Ngày tạo, Thao tác: công tắc **Ẩn / Hiện** (form POST `action=hide|show` + `id`, đổi ngay nhãn theo `published`), nút Xóa (confirm-modal, POST `action=delete`). Phân trang giữ toàn bộ bộ lọc.

### 5.25. Admin - Câu hỏi (quản lý nội dung)
- **File:** `admin/questions.jsp` · `/admin/questions` · `admin-questions`.
- **Dữ liệu:** `questions, topics, teachers, topicId, createdBy, type, status, q, page, totalPages`.
- **Giao diện:** h1 "Quản lý câu hỏi". Bộ lọc: Chủ đề, Người tạo, Loại, Trạng thái, ô tìm nội dung. Bảng: `#`, Nội dung (cắt 90 ký tự, KaTeX), Chủ đề, Người tạo, Loại, Độ khó, Nguồn (`.badge-ai`), Trạng thái, Thao tác: **Xem** (modal đủ đáp án, đáp án đúng tô xanh, lời giải), **Duyệt** (chỉ khi DRAFT, POST `action=approve`), **Về nháp** (chỉ khi APPROVED, POST `action=draft`, để ẩn câu khỏi học sinh), **Xóa** (confirm-modal; nút `disabled` nếu câu đã có bài làm - Backend sẽ báo lỗi nếu vẫn bị gửi). Admin **không** sửa nội dung câu hỏi. Phân trang giữ toàn bộ bộ lọc.

---

## 6. Trạng thái giao diện bắt buộc cho MỌI trang
| Trạng thái | Cách thể hiện |
|---|---|
| Rỗng | `.empty-state`: icon lớn muted, câu mô tả, nút hành động chính |
| Lỗi validate | Từng field: `is-invalid` + `invalid-feedback`; giữ lại dữ liệu đã nhập |
| Lỗi hệ thống | Alert đỏ trên đầu `main` (từ `error`) |
| Thành công | Flash alert xanh (một lần) |
| Đang xử lý | Nút gửi → spinner + vô hiệu; thao tác AI hiện thêm câu "AI đang xử lý..." |
| Xóa | Luôn qua confirm-modal |
| Responsive | Kiểm tra ở 375px, 768px, 1280px: bảng cuộn ngang, sidebar thành offcanvas, form xếp 1 cột |

---

## 7. JavaScript - `assets/js/app.js`

Một file, viết dạng module hàm, khởi tạo trong `DOMContentLoaded`. Không phụ thuộc jQuery. Mỗi tính năng chỉ chạy khi tìm thấy phần tử tương ứng.

| # | Tính năng | Selector / hợp đồng |
|---|---|---|
| 7.1 | Validate form + chống gửi trùng | `form.needs-validation`: `checkValidity`, thêm `was-validated`, vô hiệu nút submit và đổi nhãn "Đang xử lý..." (lưu nhãn gốc trong `data-label`). Khôi phục khi `pageshow` (bấm Back) |
| 7.2 | Hiện / ẩn mật khẩu | `[data-toggle-password="#id"]` |
| 7.3 | Confirm-modal xóa | Nút `[data-confirm]` với `data-confirm-message`, `data-form="#formId"` → mở `#confirmModal`, nút "Xác nhận" submit form đó |
| 7.4 | Tự mở modal | `[data-open-on-load="true"]` mở khi tải trang; `?add=1` mở `#addUserModal` |
| 7.5 | Chat AI | `#chatForm`, `#chatInput`, `#chatBox`; `fetch(ctx + '/student/ai-tutor/chat', {method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body: new URLSearchParams({...})})`; đọc JSON `{status, message, ask}` |
| 7.6 | Quiz điều hướng | `#quizForm`: ẩn / hiện `.question-card` theo chỉ số, cập nhật `.quiz-progress`, `.quiz-dot`, đếm chưa trả lời |
| 7.7 | Dropzone ảnh | `.dropzone` + `input[type=file]`: kéo-thả, preview, validate đuôi và dung lượng |
| 7.8 | YouTube preview | `#youtubeUrl` → `#youtubePreview` |
| 7.9 | KaTeX động | Hàm `renderMath(el)` gọi `renderMathInElement(el, {delimiters:[{left:'$$',right:'$$',display:true},{left:'$',right:'$',display:false}], throwOnError:false})`; dùng cho preview, modal, bong bóng chat |
| 7.10 | Chuyển MCQ / ESSAY | `#questionType`: ẩn / hiện `#mcqBlock`, bật / tắt `disabled` |
| 7.11 | Đếm câu AI đã chọn | `#aiPreviewForm` |

Quy tắc JS: dùng `const/let`, không `var`; không gắn `onclick` inline (dùng `addEventListener`); mọi chuỗi chèn vào DOM từ server hay từ AI phải qua `textContent` hoặc hàm `escapeHtml`; `fetch` luôn có `try/catch`.

---

## 8. CSS - `assets/css/style.css`
Một file, có chú thích theo khối: Variables · Base · Layout (shell, navbar, sidebar) · Components (card, table, badge, stat-card, empty-state) · Auth · Quiz · Dropzone · Chat · Utilities · Responsive. Ưu tiên biến CSS, không dùng `!important` trừ khi ghi đè Bootstrap thật sự cần. Sidebar: nền trắng, mục active nền `--primary-soft`, chữ `--primary`, thanh vạch trái 3px.

---

## 9. Chuỗi Prompt cho Antigravity

> **Mẹo:** dán **Prompt 0** làm tin nhắn đầu tiên / quy tắc cố định của workspace. Sau đó dán từng prompt theo thứ tự, mỗi lần chỉ một prompt. Kiểm tra bằng NetBeans giữa các prompt.

### Prompt 0 - Quy tắc chung (luôn áp dụng)
```
Bạn là lập trình viên Java Web. Dự án là website MathTutor 12, Maven Web Application chạy trong NetBeans 17, JDK 17, Tomcat 10 (Jakarta EE, namespace jakarta.*), mô hình MVC2.
Hãy đọc kỹ file docs/FRONTEND_SPEC.md, đặc biệt Mục 1 (ràng buộc), Mục 2 (design system), Mục 3 (layout), Mục 4 (hợp đồng dữ liệu).
QUY TẮC CỨNG:
- Chỉ TẠO / SỬA FILE trong src/main/webapp (JSP, CSS, JS) trừ khi prompt nói khác. KHÔNG chạy lệnh terminal, KHÔNG npm, KHÔNG build, KHÔNG chạy server.
- Không scriptlet trong JSP, chỉ EL + JSTL. Dùng đúng taglib jakarta.tags.* như Mục 1.3. Mọi dữ liệu in ra qua <c:out>.
- Không dùng javax.*, không React/Vue/Tailwind CLI. Chỉ Bootstrap 5.3.3 CDN + Bootstrap Icons + KaTeX + CSS/JS thuần.
- Đường dẫn luôn dùng ${pageContext.request.contextPath}. Tiếng Việt có dấu, UTF-8.
- Chỉ dùng tên property và attribute đã khai trong Mục 4. Nếu thiếu gì, DỪNG và hỏi lại, không tự bịa.
- Không sửa pom.xml, web.xml, Servlet, DAO, Filter có sẵn.
Xác nhận bạn đã hiểu và tóm tắt lại 5 quy tắc quan trọng nhất trước khi làm.
```

### Prompt 1 - Nền tảng giao diện
```
Theo docs/FRONTEND_SPEC.md Mục 2, 3, 7, 8, hãy tạo:
- src/main/webapp/assets/css/style.css (đủ các biến và class ở Mục 2.1, 2.3)
- src/main/webapp/assets/js/app.js (các tính năng 7.1, 7.2, 7.3, 7.4, 7.9 trước; các phần còn lại để khung hàm rỗng có chú thích TODO)
- WEB-INF/views/common/: head.jsp, navbar.jsp, sidebar.jsp, flash.jsp, pagination.jsp, footer.jsp, confirm-modal.jsp, error.jsp
Tuân thủ đúng khung trang ở Mục 3.1 và menu ở Mục 3.4.
Tiêu chí nghiệm thu: các fragment được include không lỗi; sidebar đổi theo currentUser.role; pagination ẩn khi totalPages <= 1 và giữ tham số lọc.
```

### Prompt 2 - Đăng nhập, lỗi, trang xem trước dữ liệu giả
```
Theo Mục 5.1, 5.2, 5.3: tạo WEB-INF/views/login.jsp, index.jsp (redirect /login), và hoàn thiện error.jsp.
Sau đó tạo class com.mathtutor.dev.DevPreviewServlet (@WebServlet("/dev/*")) CHỈ để xem giao diện: nhận /dev/{tên-trang}?role=ADMIN|TEACHER|STUDENT, tạo User giả đưa vào session (currentUser), set các attribute giả theo Mục 4.2 cho trang đó, rồi forward tới JSP tương ứng. Nếu các JavaBean ở Mục 4.1 chưa tồn tại trong com.mathtutor.model thì tạo chúng (constructor rỗng, getter/setter, Serializable).
Ghi chú đầu file DevPreviewServlet: "XÓA TRƯỚC KHI NỘP BÀI". Hướng dẫn tôi cách thêm /dev/* vào danh sách cho phép của AuthFilter (chỉ nêu, đừng tự sửa file filter).
Tiêu chí: mở /login hiển thị 2 cột, validate client hoạt động, nút con mắt hoạt động, trang 404 hiển thị trang lỗi riêng.
```

### Prompt 3 - Ba Dashboard
```
Theo Mục 5.4, 5.6, 5.15: tạo admin/dashboard.jsp, teacher/dashboard.jsp, student/dashboard.jsp. Mở rộng DevPreviewServlet để xem được 3 trang này với dữ liệu giả.
```

### Prompt 4 - Admin: người dùng
```
Theo Mục 5.5: tạo admin/teachers.jsp và admin/students.jsp (cùng mẫu), có bảng, tìm kiếm, phân trang, modal Thêm / Sửa / Đặt lại mật khẩu (tự mở lại khi có errors), nút khóa / mở khóa qua confirm-modal. Bổ sung dữ liệu giả cho DevPreviewServlet (12 người dùng, PAGE_SIZE 5 để thấy 3 trang).
```

### Prompt 4b - Admin: quản lý nội dung
```
Theo Mục 5.23, 5.24, 5.25: tạo admin/topics.jsp, admin/lessons.jsp, admin/questions.jsp. Mọi thao tác thay đổi dữ liệu là form POST có hidden `action` và `id`; xóa qua confirm-modal. Cập nhật sidebar.jsp cho ADMIN theo Mục 3.4 (nhóm "Người dùng" và "Nội dung"). Bổ sung dữ liệu giả có nhiều giáo viên khác nhau để thấy cột Người tạo và bộ lọc.
```

### Prompt 5 - Teacher: chủ đề và bài giảng
```
Theo Mục 5.7, 5.8, 5.9: tạo teacher/topics.jsp, teacher/lessons.jsp, teacher/lesson-form.jsp, kèm JS 7.8 (YouTube preview) và preview KaTeX cho contentText. Bổ sung dữ liệu giả.
```

### Prompt 6 - Teacher: câu hỏi và AI
```
Theo Mục 5.10, 5.11, 5.12: tạo teacher/questions.jsp, teacher/question-form.jsp, teacher/ai-generate.jsp, kèm JS 7.10, 7.11. Giữ bộ lọc khi phân trang bằng c:url + c:param. Trong dữ liệu giả cho ai-generate, tạo 3 AiQuestionDraft (2 MCQ, 1 ESSAY) có LaTeX.
```

### Prompt 7 - Teacher: học sinh và bài tự luận
```
Theo Mục 5.13, 5.14: tạo teacher/students.jsp và teacher/submissions.jsp (modal xem ảnh lớn, form chấm lại).
```

### Prompt 8 - Student: học và trắc nghiệm
```
Theo Mục 5.16 đến 5.20: tạo student/topics.jsp, lesson.jsp, quiz.jsp, result.jsp, history.jsp, kèm JS 7.6. Trang quiz.jsp tuyệt đối không hiển thị đáp án đúng hay lời giải.
```

### Prompt 9 - Student: tự luận và AI từng bước
```
Theo Mục 5.21, 5.22: tạo student/essay.jsp (2 chế độ) và student/ai-tutor.jsp, kèm JS 7.5 và 7.7. Với chat AI, tạm thời khi chưa có Backend, cho DevPreviewServlet xử lý /dev/ai-chat trả JSON giả {status, message, ask} xoay vòng 3 trạng thái để thử giao diện.
```

### Prompt 10 - Rà soát cuối
```
Rà soát toàn bộ JSP trong WEB-INF/views theo checklist: (1) không scriptlet, (2) mọi dữ liệu in qua c:out, (3) không đường dẫn tuyệt đối cứng, (4) mỗi trang đúng một h1, (5) không id trùng, (6) mọi form POST có needs-validation và nút xóa dùng confirm-modal, (7) tên attribute khớp Mục 4. Liệt kê vi phạm và sửa. Không sửa file ngoài src/main/webapp.
```

---

## 10. Quy trình kiểm tra trong NetBeans sau mỗi prompt
1. Chuột phải project → **Clean and Build** (phải `BUILD SUCCESS`).
2. **Run** (Tomcat 10 khởi động). Mở `http://localhost:8080/<tên-project>/login` hoặc `/dev/...`.
3. Nhấn **Ctrl + F5** để bỏ cache CSS / JS.
4. Mở F12 → Console: không có lỗi đỏ; tab Network: không file nào 404.
5. Thử ở 375px (chế độ điện thoại) và 1280px.
6. Đối chiếu **Tiêu chí nghiệm thu** của prompt.

### Lỗi thường gặp
| Triệu chứng | Nguyên nhân | Cách xử lý |
|---|---|---|
| `The absolute uri: jakarta.tags.core cannot be resolved` | Thiếu dependency JSTL 3.0, hoặc dùng Tomcat 10.0.x | Xem Mục 1.3; kiểm tra `pom.xml` |
| `ClassNotFoundException: javax.servlet...` | AI sinh nhầm `javax` | Đổi toàn bộ thành `jakarta.servlet` |
| Giao diện trơ trụi, mất CSS | Sai đường dẫn assets, hoặc `/assets/*` bị AuthFilter chặn | Dùng `contextPath`; kiểm tra filter cho phép `/assets/` |
| Chữ `???` / lỗi font | Thiếu `pageEncoding` hoặc file không lưu UTF-8 | Thêm directive; NetBeans → Project Properties → Encoding = UTF-8 |
| Sửa JSP không thấy đổi | Tomcat cache | Clean and Build, rồi Run lại |
| `EL ... Illegal syntax` ở trang có LaTeX | Chuỗi `${` trong text tĩnh | Viết `\${` hoặc đưa vào `<c:out>` |
| Form POST báo 403 | Sai tiền tố URL so với role | Kiểm tra URL bắt đầu `/admin`, `/teacher`, `/student` |
| Chat AI không phản hồi | Servlet chưa có hoặc trả không phải JSON | Xem tab Network, response phải là JSON `{status, message, ask}` |

---

## 11. Điểm cần thống nhất với Backend (liên quan trực tiếp tới Frontend)
Đã chốt: Tomcat 10.1.x (taglib `jakarta.tags.*`); không có đăng ký công khai và không có đăng nhập Google; Admin quản lý người dùng + nội dung giáo viên đăng.

1. Bean trả ngày giờ dạng chuỗi `createdAtText`, `submittedAtText` (Mục 4.1); Topic / Lesson / Question có thêm `creatorName` cho các trang Admin.
2. `AttemptResult.items` gồm `question` + `selectedOptionId` + `correct` (trang kết quả).
3. Đường dẫn xem ảnh `/files/essay-image` (ngoài `/student/*`); AuthFilter cho mọi người dùng đã đăng nhập, Servlet tự kiểm tra quyền (học sinh chủ bài, giáo viên sở hữu câu hỏi, Admin).
4. URL bổ sung so với bản tài liệu Word cũ: `/admin/users/update`, `/admin/users/reset-password`, `/admin/topics`, `/admin/lessons`, `/admin/questions`, `/teacher/lessons/delete`, `/teacher/questions/delete`, `/teacher/submissions/review`, `/student/essay?questionId=`, `/files/essay-image` (đã cập nhật trong tài liệu Word v1.1).
5. Trang làm trắc nghiệm không nhận `correct`, `solution`.
6. Chat AI dùng `application/x-www-form-urlencoded`, trả JSON `{status, message, ask}`.
7. Giáo viên chỉ thấy bài tự luận làm trên câu hỏi do mình tạo; chủ đề dùng chung, chỉ người tạo (hoặc Admin) xóa.
8. Luyện trắc nghiệm theo bài học: `/student/quiz?topicId=&lessonId=&count=`.
