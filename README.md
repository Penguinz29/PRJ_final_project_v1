# 🎓 EduTutor Math 12 — Nền tảng Học tập & Ôn thi Toán 12 Tích hợp AI

> **Dự án Môn học:** PRJ301 (Java Web Application) — FPT University  
> **Phiên bản:** 2.1 (Branch: `project-v2`)  
> **Kiến trúc:** Spring MVC 6.2 thuần (không Spring Boot) + Spring Data JPA / Hibernate 6.6 + HikariCP trên Jakarta EE 10 / Servlet 6.0 (Tomcat 10.1), SQL Server, Google Gemini API  

---

## 📖 1. Giới thiệu tổng quan

**EduTutor Math 12** là hệ thống web hỗ trợ học tập, ôn luyện và kiểm tra đánh giá môn **Toán lớp 12** theo chương trình THPT Quốc gia. Nền tảng kết hợp giữa quản lý học tập truyền thống (LMS) với các tính năng đột phá từ **Trí tuệ nhân tạo (Google Gemini AI)** nhằm hỗ trợ cả Học sinh, Giáo viên và Quản trị viên:
- **Học sinh:** Ôn tập lý thuyết, xem bài giảng (YouTube, video, liên kết, văn bản), luyện trắc nghiệm bấm giờ, xem giải thích chi tiết, nộp bài viết tay và theo dõi lịch sử học tập.
- **Giáo viên:** Soạn giáo án, quản lý ngân hàng câu hỏi, sinh đề trắc nghiệm tự động bằng AI, duyệt và điều chỉnh điểm bài tự luận viết tay của học sinh.
- **Quản trị viên:** Quản lý tài khoản người dùng (khóa/mở khóa), theo dõi số liệu toàn trường và quản lý cấu hình kết nối AI.

---

## 🛠️ 2. Công nghệ sử dụng (Tech Stack)

| Thành phần | Công nghệ / Thư viện | Ghi chú |
|------------|----------------------|---------|
| **Ngôn ngữ** | Java 17 (build được bằng JDK 17 hoặc 21) | Chuẩn LTS |
| **Web Framework** | **Spring MVC 6.2** (`@Controller`, `@RestController`, `@Service`, `@ControllerAdvice`), JSP + **Jakarta JSTL 3.0** (`jakarta.tags.*`) + Spring form tag | Chạy trên Tomcat 10.1 (Jakarta Servlet 6.0). Cấu hình **hoàn toàn bằng Java** (`WebAppInitializer`, `RootConfig`, `WebConfig`), không `applicationContext.xml` |
| **Truy cập dữ liệu** | **Spring Data JPA 3.5 + Hibernate ORM 6.6** (Jakarta Persistence 3.1) + **HikariCP** | Repository là `interface extends JpaRepository`; `Specification` cho lọc động; `@EntityGraph` + truy vấn `IN` chống N+1; `@Transactional` ở tầng Service; `hbm2ddl.auto=none` (script SQL là nguồn sự thật) |
| **Cơ sở dữ liệu** | Microsoft SQL Server 2016+ | Driver `mssql-jdbc` |
| **Validation** | **Jakarta Bean Validation** (Hibernate Validator 8) | Thông báo tiếng Việt trong `messages.properties` (UTF-8), hiển thị tại từng trường bằng `<form:errors>`; ràng buộc nghiệp vụ ở Service; ràng buộc `UNIQUE/CHECK/FK` ở CSDL |
| **Bảo mật** | `AuthInterceptor` phân quyền ADMIN/TEACHER/STUDENT theo URL (cả `/api/**`), `CsrfInterceptor` (token CSRF cho mọi POST), mật khẩu **BCrypt** (tự nâng cấp từ SHA-256 cũ), đổi session ID sau đăng nhập, Jsoup làm sạch nội dung AI, ảnh upload kiểm tra magic-bytes và chỉ phục vụ cho đúng người | Chống SQL Injection / XSS / CSRF / session fixation |
| **Trí tuệ nhân tạo** | Google Gemini API qua `java.net.http.HttpClient` (model, khóa API, nhiệt độ... cấu hình trong bảng `AiConfigs`) | Sinh đề, Gia sư AI step-by-step, chấm tự luận OCR; chạy bất đồng bộ (`CompletableFuture` + thread pool riêng), tự thử lại tối đa 3 lần |
| **Giao diện (Frontend)** | HTML5, CSS3, Bootstrap 5, Bootstrap Icons, AJAX/Fetch | Responsive |
| **Hiển thị Toán học** | KaTeX (Auto-render) | Công thức LaTeX |
| **Log** | SLF4J + Logback | Không log khóa API, mật khẩu |
| **Build** | **Apache Maven** (cấu trúc chuẩn `src/main/java`, `src/main/webapp`; đóng gói `edututor.war`, context path `/edututor`) | Mở trực tiếp bằng **Apache NetBeans 17** (Maven Web Application) |

---

## 👥 3. Phân hệ chức năng theo Vai trò

### 🛡️ Quản trị viên (Admin)
- **Tổng quan hệ thống:** Thống kê số lượng học sinh, giáo viên, chủ đề và câu hỏi.
- **Quản lý người dùng:** Tìm kiếm, lọc theo vai trò/trạng thái, phân trang; tạo, sửa, đổi vai trò, khóa/mở khóa, xóa (cứng hoặc mềm) và đặt lại mật khẩu.
- **Cấu hình AI (FR-ADM-01/02):** Tùy chỉnh Gemini API Key, Provider, Model (`gemini-1.5-flash`) và nút **Ping Test** kiểm tra kết nối Google AI trực tiếp.
- **Quản lý dữ liệu gốc:** Toàn quyền quản trị Chủ đề, Bài giảng và Ngân hàng câu hỏi.

### 👨‍🏫 Giáo viên (Teacher)
- **Quản lý chuyên đề & bài giảng:** Tạo mới, chỉnh sửa chuyên đề Toán 12, nhúng video bài giảng YouTube.
- **Ngân hàng câu hỏi:** Quản lý câu hỏi trắc nghiệm (MCQ) và tự luận (ESSAY) với 4 mức độ (Dễ, Trung bình, Khó, Vận dụng cao).
- **Sinh đề AI thông minh (FR-TEA-03):** Giáo viên chọn chủ đề và số lượng câu hỏi, Gemini AI tự động sinh đề kèm đáp án và lời giải chi tiết, xem trước qua KaTeX và lưu hàng loạt vào DB.
- **Chấm bài tự luận (FR-TEA-04):** Xem ảnh bài làm viết tay của học sinh, xem văn bản nhận diện OCR từ AI, chấm điểm thang 10.0 và gửi nhận xét phản hồi.
- **Theo dõi học sinh:** Xem tiến độ và lịch sử làm bài chi tiết của từng học sinh.

### 🎓 Học sinh (Student)
- **Đăng ký / Đăng nhập:** Học sinh tự đăng ký tài khoản với tính năng kiểm tra trùng lặp email.
- **Học lý thuyết:** Xem nội dung tóm tắt, công thức và video bài giảng minh họa.
- **Luyện thi trắc nghiệm (FR-STU-01/02):** Làm bài thi trắc nghiệm bấm giờ, chấm điểm tự động tức thì, xem lời giải chi tiết từng câu và **lưu kết quả vào CSDL `Submissions`**.
- **Nộp bài tự luận:** Chụp ảnh bài giải viết tay và tải lên hệ thống.
- **Lịch sử làm bài:** Xem lại toàn bộ các bài thi đã làm, kết quả Đúng/Sai, đáp án đã chọn và điểm số được giáo viên chấm.

---

## 📁 4. Cấu trúc Dự án (Project Directory)

```
PRJ_final_project_v1/
├── pom.xml                                # Maven (WAR, Spring 6.2, Spring Data JPA, Hibernate 6.6, Hikari, Jackson, Jsoup...)
├── nb-configuration.xml                   # Gợi ý server Tomcat cho NetBeans
├── document/                              # SRS, FRS, Claude.md (quy tắc kỹ thuật)
│   └── sql/                               # Kịch bản SQL Server (chạy theo thứ tự)
│       ├── 01_schema.sql                  # Tạo CSDL MathTutorDB và các bảng gốc
│       ├── 02_seed.sql                    # Dữ liệu mẫu (mật khẩu BCrypt của EduTutor@123)
│       ├── 03_ai_configs.sql              # Bảng cấu hình AI
│       ├── 04_update_submissions.sql      # Cột Score & AiFeedback
│       └── 05_tutor_and_explanation.sql   # TutorSessions, TutorMessages, Questions.ExplanationLatex
│       └── 06_target_schema_additions.sql # Cột/bảng bổ sung theo SRS/FRS (IsActive, trạng thái bài làm, AwaitingInput, LessonMaterials...) - idempotent
└── src/
    ├── main/
    │   ├── java/com/edututor/
    │   │   ├── config/                    # WebAppInitializer (thay web.xml), RootConfig (DataSource, JPA, Transaction, Async), WebConfig (MVC, Validator, MessageSource)
    │   │   ├── interceptor/               # AuthInterceptor (phân quyền), CsrfInterceptor
    │   │   ├── controller/                # @Controller trả JSP: auth/, admin/, student/, teacher/, FileController
    │   │   │   └── api/                   # @RestController trả JSON (ApiResponse): Admin/Teacher/Student/Tutor
    │   │   ├── service/                   # @Service: nghiệp vụ + gọi AI; map Entity -> DTO trong @Transactional; TutorPersistence (ghi DB của gia sư)
    │   │   ├── ai/                        # GeminiClient (HTTP), AiJsonParser
    │   │   ├── repository/                # Spring Data JPA (JpaRepository) + spec/ (Specification)
    │   │   ├── model/                     # Entity JPA (@Entity) + enum Role, QuestionType, ...
    │   │   ├── dto/                       # Form (Bean Validation), View, Request/Response, ApiResponse, PageResult
    │   │   ├── exception/                 # GlobalExceptionHandler (@ControllerAdvice) + các exception nghiệp vụ
    │   │   └── util/                      # HtmlSanitizer, Pager, ScoreUtil, YoutubeUtil, WebUtil, FormErrors
    │   ├── resources/                     # application.properties, messages.properties (UTF-8), logback.xml
    │   └── webapp/                        # = "Web Pages" trong NetBeans
    │       ├── META-INF/context.xml       # Context path /edututor (NetBeans cần file này)
    │       ├── static/                    # css/, js/ (app.js: csrfFetch, renderMath, ...)
    │       └── WEB-INF/
    │           ├── views/                 # JSP: admin, auth, common, error, student, teacher
    │           └── tags/                  # Tag file dùng lại: pagination.tag, flash.tag, error-card.tag
    └── test/java/com/edututor/            # UnitTests (chạy trong mvn package) + EduTutorIT, QueryCountIT (cần SQL Server)
```

---

## 🚀 5. Hướng dẫn Cài đặt & Khởi chạy

### Bước 1: Chuẩn bị môi trường
- **JDK 17**, **Apache NetBeans 17**, **Apache Tomcat 10.1** (Jakarta Servlet 6.0), **SQL Server** (bật TCP/IP cổng `1433`).
- Maven đi kèm NetBeans (hoặc Maven 3.9+ độc lập).

### Bước 2: Thiết lập Cơ sở Dữ liệu
Chạy lần lượt trong SSMS các file trong `document/sql/`: `01_schema.sql` -> `02_seed.sql` -> `03_ai_configs.sql` -> `04_update_submissions.sql` -> `05_tutor_and_explanation.sql` -> `06_target_schema_additions.sql` (tạo bảng `LessonMaterials`, chuyển "video hướng dẫn" cũ `Lessons.YoutubeUrl` thành bài giảng, và các cột bổ sung theo thiết kế chuẩn 10 bảng; **bắt buộc chạy**: thêm cột `Users.Status` (trạng thái tài khoản ACTIVE/SUSPENDED/INACTIVE) mà ứng dụng dùng khi đăng nhập; thiếu script này ứng dụng sẽ lỗi). (`01_schema.sql` **xóa và tạo lại** CSDL `MathTutorDB`.)

> Nếu chạy bằng `sqlcmd`, thêm cờ `-x` (tắt thay thế biến) vì dữ liệu mẫu chứa ký tự `$(`: `sqlcmd -S localhost -U sa -P 123 -C -x -f 65001 -i 02_seed.sql`.

### Bước 3: Cấu hình kết nối
Sửa `src/main/resources/application.properties` (`db.url`, `db.username`, `db.password`) **hoặc** đặt biến môi trường / `-D` `DB_URL`, `DB_USER`, `DB_PASS` (ưu tiên cao hơn). Ảnh bài làm tự luận lưu ở `app.upload-dir` (mặc định `C:/edututor/uploads`, đổi bằng `UPLOAD_DIR`).

Khóa Gemini API, model, temperature, số token **không** nằm trong file này: Admin nhập tại trang **Cấu hình AI** (lưu trong bảng `AiConfigs`, có hiệu lực ngay, không cần khởi động lại). Tên model Gemini thay đổi theo thời gian — hãy kiểm tra tên còn được hỗ trợ rồi bấm **Test Connection**.

### Bước 4: Chạy trên NetBeans 17
1. *File > Open Project* chọn thư mục dự án (nhận dạng là **Maven Web Application**).
2. Thêm server nếu chưa có: *Services > Servers > Add Server > Apache Tomcat or TomEE*, trỏ tới thư mục **Tomcat 10.1**. Trong *Project Properties > Run* chọn server này.
3. Bấm **Clean and Build**, rồi **Run**, mở `http://localhost:8080/edututor/login`.
4. Khi sửa **Entity**, lớp cấu hình (`WebAppInitializer`, `RootConfig`, `WebConfig`), `pom.xml` hoặc `application.properties`: **Stop Tomcat -> Clean and Build -> Run** lại (Hibernate chỉ quét Entity lúc khởi động).

Hoặc dòng lệnh: `mvn clean package` rồi chép `target/edututor.war` vào `webapps/` của Tomcat 10.1.

> Trình biên dịch phải bật `-parameters` (đã cấu hình sẵn trong `pom.xml`).

### Bước 5 (tùy chọn): Chạy kiểm thử
```bash
mvn clean package            # build WAR + 17 unit test, không cần CSDL
# Kiểm thử tích hợp (Tomcat nhúng + SQL Server thật + Gemini giả + đếm số câu SQL chống N+1). Dùng CSDL riêng đã nạp 01..05:
mvn clean verify -Pintegration -Dit.db.url="jdbc:sqlserver://localhost:1433;databaseName=MathTutorDB_test;encrypt=true;trustServerCertificate=true" -Dit.db.user=sa -Dit.db.pass=123
```
Bộ kiểm thử tích hợp **xóa bài làm, phiên gia sư và đặt lại mật khẩu seed** của CSDL được trỏ tới, vì vậy đừng chạy trên dữ liệu thật.

---


## 🔑 6. Tài khoản Thử nghiệm (Demo Accounts)

Tất cả các tài khoản mặc định có mật khẩu là: **`EduTutor@123`**

| Vai trò | Tên đăng nhập | Email | Mục đích kiểm thử |
|---------|---------------|-------|-------------------|
| **Admin** | `admin` | `admin@mathtutor.com` | Quản trị hệ thống, bật/tắt tài khoản, cấu hình AI |
| **Giáo viên** | `teacher1` | `huong@mathtutor.com` | Quản lý chuyên đề, sinh đề AI, duyệt điểm tự luận |
| **Giáo viên** | `teacher2` | `quang@mathtutor.com` | Quản lý bài tập, theo dõi học sinh |
| **Học sinh** | `student1` | `st1@example.com` | Làm bài trắc nghiệm, xem lịch sử làm bài |
| **Học sinh** | `student2` | `st2@example.com` | Nộp bài tự luận viết tay |

---

## ⚙️ 7. Lưu ý Kỹ thuật quan trọng
- **Mật khẩu:** tài khoản seed dùng BCrypt (`EduTutor@123`). Tài khoản cũ còn băm SHA-256 vẫn đăng nhập được và tự được băm lại bằng BCrypt ở lần đăng nhập thành công đầu tiên.
- **Tầng dữ liệu:** Entity JPA ánh xạ **1-1 với 10 bảng** (9 bảng gốc + `LessonMaterials` do script 06 tạo). Mọi quan hệ `LAZY`; Service map Entity sang DTO bên trong `@Transactional`; không bật Open-Session-In-View; câu hỏi làm bài chỉ chọn cột được phép (không lộ đáp án/lời giải trước khi nộp).
- **Giao dịch & AI:** các lời gọi Gemini nằm **ngoài** transaction; phần ghi DB của gia sư AI nằm ở bean riêng `TutorPersistence`. Các endpoint `/api/tutor/next-step`, `/api/teacher/generate-questions`, `/api/student/submit-essay-ocr`, `/api/admin/ai-config/test-connection` trả `CompletableFuture`, chạy trên thread pool `aiExecutor` nên không chặn luồng Tomcat.
- **Phản hồi API thống nhất:** mọi `/api/**` trả `{"success", "message", "data", "errors"}`; `GlobalExceptionHandler` ánh xạ lỗi sang mã HTTP (400 dữ liệu sai, 401, 403, 404, 409 xung đột, 422 AI trả dữ liệu không dùng được, 502/503/504 lỗi AI, 500 kèm mã tham chiếu `ERR-yyyyMMdd-xxxx`) và chuyển về trang trước kèm thông báo cho trang thường.
- **CSRF:** mọi form POST có trường ẩn `_csrf`; `fetch` dùng `csrfFetch()` (header `X-CSRF-TOKEN` lấy từ `<meta name="csrf-token">`). Đăng xuất là `POST /logout`.
- **Cấu hình bằng Java, không cần `web.xml`** (tệp `WEB-INF/web.xml` còn sót chỉ lặp lại cấu hình session/trang lỗi và có thể xóa): `WebAppInitializer` đăng ký DispatcherServlet, UTF-8 filter, multipart, session timeout 30 phút, cookie `HttpOnly` + `SameSite=Lax`. Trang lỗi nằm ở `WEB-INF/views/error/`.
- **Phiên bản trước (Servlet thuần, JDBC thủ công; rồi JdbcTemplate)** đã được thay thế hoàn toàn; không còn `DBContext`, `*DAO`, `JdbcTemplate`, `@WebServlet`, `build.xml`/`nbproject` (Ant).
