# 🎓 EduTutor Math 9

**Nền tảng học tập và ôn thi Toán 9 tích hợp AI (Google Gemini)**

> Đồ án môn **PRJ301 – Java Web Application**, FPT University
> Phiên bản **2.1.0** · nhánh `project-v2`

EduTutor Math 9 là website gia sư Toán lớp 9 (SGK Kết nối tri thức với cuộc sống, Tập 1 + Tập 2: 10 chương, 56 bài học, kèm video bài giảng VietJack) cho 3 nhóm người dùng: **Admin, Giáo viên, Học sinh**. Hệ thống kết hợp quản lý học tập (bài giảng, ngân hàng câu hỏi, luyện trắc nghiệm) với 3 tính năng AI chạy thật:

| Tính năng AI | Mô tả |
|---|---|
| **Sinh đề** | Giáo viên chọn chủ đề, AI sinh câu hỏi kèm đáp án và lời giải; xem trước rồi lưu hàng loạt |
| **Gia sư từng bước** | Học sinh làm sai thì AI hướng dẫn từng bước; trạng thái bước do **server** điều khiển |
| **Chấm tự luận bằng ảnh** | Học sinh chụp bài giải viết tay, AI nhận diện (OCR), chấm và nhận xét; giáo viên duyệt lại điểm |

Khóa API, model, nhiệt độ… do Admin cấu hình trên giao diện (bảng `ai_configs`), không cần sửa code.

---

## 🧰 1. Framework và công nghệ sử dụng

### Backend

| Thành phần | Công nghệ | Vai trò |
|---|---|---|
| Ngôn ngữ | **Java 17** | LTS |
| Web framework | **Spring MVC 6.2** (không dùng Spring Boot) | Controller, Service, `@ControllerAdvice`, interceptor; cấu hình hoàn toàn bằng Java (`WebAppInitializer`, `RootConfig`, `WebConfig`), không có `web.xml` |
| Servlet container | **Apache Tomcat 10.1** (Jakarta Servlet 6.0, JSP 3.1) | Namespace `jakarta.*` |
| ORM / truy cập dữ liệu | **Spring Data JPA 3.5** + **Hibernate ORM 6.6** (Jakarta Persistence 3.1) | `JpaRepository`, `Specification`, `@EntityGraph`, projection; **không dùng JdbcTemplate** |
| Connection pool | **HikariCP** | Pool kết nối |
| Cơ sở dữ liệu | **Microsoft SQL Server** + driver `mssql-jdbc` | 10 bảng, script SQL là nguồn sự thật (`hbm2ddl.auto=none`) |
| Validation | **Jakarta Bean Validation** (Hibernate Validator 8) | Thông báo tiếng Việt trong `messages.properties` |
| Bảo mật | **spring-security-crypto** (BCrypt), `AuthInterceptor`, `CsrfInterceptor` | Chỉ dùng module crypto, không kéo cả Spring Security |
| JSON | **Jackson** | Serialize `ApiResponse` và parse JSON từ AI |
| Làm sạch HTML | **jsoup** | Sanitize nội dung AI trả về (chống XSS) |
| Log | **SLF4J + Logback** | Không log khóa API, mật khẩu |
| AI | **Google Gemini REST API** qua `java.net.http.HttpClient` | Không dùng SDK; gọi bất đồng bộ bằng `CompletableFuture` + thread pool riêng |

### Giao diện

| Thành phần | Công nghệ |
|---|---|
| View | **JSP + Jakarta JSTL 3.0** (`jakarta.tags.*`) + Spring form tag + tag file dùng lại |
| UI framework | **Bootstrap 5.3.3** + **Bootstrap Icons 1.11.3** (nạp qua CDN jsDelivr) |
| Công thức toán | **KaTeX 0.16.9** (auto-render `$…$`, `$$…$$`) |
| Script | JavaScript thuần (`app.js`: `csrfFetch`, `renderMath`, …), Fetch/AJAX |
| Font | Be Vietnam Pro (Google Fonts) |

### Build và kiểm thử

| Thành phần | Công nghệ |
|---|---|
| Build | **Apache Maven**, đóng gói WAR (`edututor.war`, context path `/edututor`) |
| Test | **JUnit 5** + **spring-test** (unit test chạy trong `mvn package`) |
| Test tích hợp | **Tomcat nhúng** + SQL Server thật, chạy riêng bằng `maven-failsafe-plugin` (profile `integration`) |
| IDE khuyến nghị | **Apache NetBeans 17** (Maven Web Application) |

---

## 👥 2. Chức năng theo vai trò

### 🛡️ Admin
- Thống kê tổng quan: số học sinh, giáo viên, chủ đề, câu hỏi.
- Quản lý người dùng: tìm kiếm, lọc theo vai trò/trạng thái, phân trang; tạo, sửa, đổi vai trò, khóa/mở khóa, xóa, đặt lại mật khẩu.
- **Cấu hình AI**: API key, model, tham số, prompt; nút **Test kết nối**.
- Quản trị toàn bộ chủ đề, bài học, bài giảng, ngân hàng câu hỏi.

### 👨‍🏫 Giáo viên
- Quản lý chủ đề → bài học → bài giảng (video, YouTube, văn bản, liên kết).
- Ngân hàng câu hỏi trắc nghiệm (MCQ) và tự luận (ESSAY), 3 mức độ khó.
- **Nhập câu hỏi từ tệp**: tải đề bài (PDF / Word `.docx` / ảnh) thay vì gõ tay; tệp đáp án là tùy chọn, không có thì AI tự giải và sinh đáp án + lời giải. Kết quả điền vào form để giáo viên xem lại trước khi lưu.
- **Sinh đề bằng AI**, xem trước bằng KaTeX, lưu hàng loạt.
- **Duyệt bài tự luận**: xem tệp bài làm (ảnh / PDF / Word), văn bản AI đọc được; sửa điểm (điểm AI gốc `ai_score` được giữ nguyên) và gửi nhận xét.
- Theo dõi tiến độ và lịch sử làm bài của học sinh.

### 🎓 Học sinh
- Tự đăng ký, đăng nhập; xem bài giảng.
- Luyện trắc nghiệm ngẫu nhiên, chấm từng câu tức thì, xem lời giải; làm sai thì **gia sư AI** hướng dẫn từng bước.
- Hỏi gia sư AI bất kỳ bài toán phổ thông nào.
- Nộp bài giải tự luận bằng ảnh, PDF hoặc Word (.docx) để AI chấm.
- Xem tiến độ, chuỗi ngày học và lịch sử làm bài.

> Chủ đề và bài học đã xóa mềm bị ẩn với cả học sinh; chỉ người tạo hoặc Admin được xóa.

---

## 🔒 3. Bảo mật

- Phân quyền theo URL (cả `/api/**`) bằng `AuthInterceptor`; mật khẩu băm **BCrypt**; đổi session ID sau đăng nhập; cookie `HttpOnly` + `SameSite=Lax`.
- **CSRF**: mọi POST có `_csrf`; `fetch` dùng `csrfFetch()` (header `X-CSRF-TOKEN`).
- Chống SQL injection (truy vấn tham số hóa), XSS (jsoup + `fn:escapeXml`); tệp upload (ảnh / PDF / Word) kiểm tra magic-bytes, giải nén Word có giới hạn dung lượng, và chỉ phục vụ đúng người.
- Không trả Entity ra view/JSON (dùng DTO); không lộ đáp án và lời giải trước khi nộp.
- Validation 4 lớp: HTML5/JS → Bean Validation → nghiệp vụ ở Service → ràng buộc DB.

---

## 📁 4. Cấu trúc dự án

```
PRJ_final_project_v1/
├── pom.xml
├── document/
│   ├── SRS.md, FRS.md, Claude.md          # Đặc tả yêu cầu, đặc tả chức năng, quy tắc kỹ thuật
│   ├── docs/                              # DATABASE.md, ERD.md, ERD + đặc tả ràng buộc (.docx)
│   └── sql/
│       └── MathTutorDB.sql                # Tạo CSDL MathTutorDB + 10 bảng (XÓA CSDL cũ cùng tên) và nạp toàn bộ dữ liệu mẫu
└── src/
    ├── main/
    │   ├── java/
    │   │   ├── config/        # WebAppInitializer, RootConfig, WebConfig, AuthInterceptor, CsrfInterceptor
    │   │   ├── controller/    # Trả JSP: auth, admin, teacher, student; api/ trả JSON
    │   │   ├── service/       # Nghiệp vụ + gọi AI; TutorPersistence ghi DB của gia sư
    │   │   ├── ai/            # GeminiClient, RateLimiter, PromptBuilder
    │   │   ├── repository/    # Spring Data JPA + Specification
    │   │   ├── model/         # Entity JPA + enum
    │   │   ├── dto/           # form/ (Form), view/ (View, PageResult), api/ (Request/Response/Result)
    │   │   ├── exception/     # GlobalExceptionHandler + exception nghiệp vụ
    │   │   └── util/          # HtmlSanitizer, LatexNormalizer, ScoreUtil, YoutubeUtil…
    │   ├── resources/         # application.properties, messages.properties, logback.xml
    │   └── webapp/
    │       ├── static/        # css, js, img (ảnh hình vẽ SGK Toán 9 ở img/sgk9)
    │       └── WEB-INF/       # views/ (JSP), tags/ (tag file dùng lại)
    └── test/                  # UnitTests (không cần DB) + *IT (cần SQL Server)
```

---

## 🚀 5. Cài đặt và chạy

### Yêu cầu
JDK 17 · Maven 3.9+ (hoặc Maven đi kèm NetBeans) · Tomcat 10.1 · SQL Server (bật TCP/IP cổng 1433).

### Bước 1 – Tạo cơ sở dữ liệu
Chạy trong SSMS một file duy nhất `document/sql/MathTutorDB.sql`. Script **xóa và tạo lại** `MathTutorDB` nếu đã tồn tại, tạo 10 bảng rồi nạp toàn bộ dữ liệu: người dùng, cấu hình AI, nội dung SGK Toán 9 (10 chủ đề, 56 bài học, mỗi bài từ Bài 1 đến Bài 32 có 10 câu trắc nghiệm), video bài giảng VietJack và lịch sử bài làm mẫu. Muốn nạp lại dữ liệu sạch thì chạy lại chính file này.

> Dùng `sqlcmd` thì thêm cờ `-x` vì dữ liệu chứa ký tự `$(`:
> `sqlcmd -S localhost -U sa -P <mật khẩu> -C -x -f 65001 -i MathTutorDB.sql`

### Bước 2 – Cấu hình kết nối
Sửa `src/main/resources/application.properties` (`db.url`, `db.username`, `db.password`) hoặc đặt biến môi trường `DB_URL`, `DB_USER`, `DB_PASS` (ưu tiên cao hơn). Ảnh bài làm tự luận lưu ở `app.upload-dir` (mặc định `C:/edututor/uploads`, đổi bằng `UPLOAD_DIR`).

### Bước 3 – Cấu hình AI
Đăng nhập Admin → **Cấu hình AI** → nhập khóa Gemini, chọn model → **Test kết nối**. Có hiệu lực ngay, không cần khởi động lại. Tạo lại CSDL sẽ đặt lại cấu hình này về giá trị mẫu.

### Bước 4 – Chạy
**NetBeans 17:** *File → Open Project* → chọn Tomcat 10.1 trong *Project Properties → Run* → **Clean and Build** → **Run** → mở `http://localhost:8080/edututor/login`.

**Dòng lệnh:** `mvn clean package`, rồi chép `target/edututor.war` vào `webapps/` của Tomcat 10.1.

> Khi sửa Entity, lớp cấu hình, `pom.xml` hoặc `application.properties`: **Stop Tomcat → Clean and Build → Run** lại.

### Kiểm thử
```bash
mvn clean package        # build WAR + unit test, không cần CSDL

# Kiểm thử tích hợp (cần SQL Server, dùng CSDL riêng vì test XÓA bài làm và đặt lại mật khẩu seed)
mvn clean verify -Pintegration \
  -Dit.db.url="jdbc:sqlserver://localhost:1433;databaseName=MathTutorDB_test;encrypt=true;trustServerCertificate=true" \
  -Dit.db.user=sa -Dit.db.pass=<mật khẩu>
```

---

## 🔑 6. Tài khoản thử nghiệm

Mật khẩu chung: **`EduTutor@123`**

| Vai trò | Tên đăng nhập | Mục đích |
|---|---|---|
| Admin | `admin` | Quản trị, cấu hình AI |
| Giáo viên | `teacher1` | Sở hữu toàn bộ nội dung SGK Toán 9, sinh đề AI, duyệt tự luận |
| Giáo viên | `teacher2` | Quản lý bài tập, theo dõi học sinh |
| Học sinh | `student1`, `student2` | Làm bài trắc nghiệm, nộp tự luận, xem lịch sử |

---

## ⚙️ 7. Lưu ý kỹ thuật

- **Tầng dữ liệu:** Entity ánh xạ 1-1 với 10 bảng; mọi quan hệ `LAZY`; Service map Entity → DTO trong `@Transactional`; không bật Open-Session-In-View.
- **AI ngoài transaction:** lời gọi Gemini nằm ngoài transaction; các endpoint AI trả `CompletableFuture` chạy trên thread pool `aiExecutor`, không chặn luồng Tomcat.
- **Phản hồi API thống nhất:** `/api/**` trả `{success, message, data, errors}`; `GlobalExceptionHandler` ánh xạ lỗi sang mã HTTP (400, 401, 403, 404, 409, 422, 502/503/504, 500 kèm mã tham chiếu).
- **Độ bền của AI:** tự thử lại tối đa 3 lần, chuyển model dự phòng khi 503/504, tự vá dấu `\` của LaTeX trong JSON, chuẩn hóa LaTeX để KaTeX hiển thị được; lỗi 429 báo ngay.
- **Hình trong đề:** ảnh SGK nhúng bằng `<img src="/static/img/sgk9/...">`; bộ sanitize chỉ cho phép ảnh có `src` bắt đầu bằng `/static/img/`.
- **Tiếng Việt:** mọi file lưu UTF-8; `CharacterEncodingFilter` được đăng ký trong `WebAppInitializer`.

---

## 🩺 8. Xử lý sự cố AI

Mỗi lần gọi Gemini ghi một dòng log kèm thời lượng (`model`, `attempt`, `took`, `status`).

| Dấu hiệu | Nguyên nhân thường gặp | Cách xử lý |
|---|---|---|
| `status=503` | Model chính quá tải | Đặt `DEFAULT_MODEL` sang model nhẹ hơn trong **Cấu hình AI** |
| `status=504` / `took` rất lớn | Model chậm hoặc timeout | Dùng model nhẹ hơn, giảm `AI_TIMEOUT_SECONDS` |
| `status=429` | Hết hạn mức miễn phí | Chờ khoảng 1 phút hoặc đổi khóa API |
| AI chậm sau khi tạo lại CSDL | Cấu hình AI bị đặt về mẫu, mất khóa | Nhập lại khóa, chọn lại model, **Test kết nối** |
| "Không đọc được bài làm" | Ảnh mờ (`legible=false`), không phải lỗi hệ thống | Chụp rõ, đủ sáng; thử `VISION_MODEL` mạnh hơn |

---

## 📚 9. Tài liệu đi kèm

| File | Nội dung |
|---|---|
| `document/SRS.md` | Yêu cầu, phạm vi, nghiệm thu, đối chiếu đề bài |
| `document/FRS.md` | Use case, luồng xử lý, phân quyền, luồng AI |
| `document/Claude.md` | Quy tắc kỹ thuật và lộ trình xây dựng |
| `document/docs/DATABASE.md`, `ERD.md` | Từ điển dữ liệu, sơ đồ ERD |
