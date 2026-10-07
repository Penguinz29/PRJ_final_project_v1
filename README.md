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
| **Bảo mật** | `AuthInterceptor` phân quyền ADMIN/TEACHER/STUDENT theo URL (cả `/api/**`), `CsrfInterceptor` (token CSRF cho mọi POST), mật khẩu **BCrypt**, đổi session ID sau đăng nhập, Jsoup làm sạch nội dung AI, ảnh upload kiểm tra magic-bytes và chỉ phục vụ cho đúng người | Chống SQL Injection / XSS / CSRF / session fixation |
| **Trí tuệ nhân tạo** | Google Gemini API qua `java.net.http.HttpClient` (model, khóa API, nhiệt độ... cấu hình trong bảng `AiConfigs`) | Sinh đề, Gia sư AI step-by-step, chấm tự luận OCR; chạy bất đồng bộ (`CompletableFuture` + thread pool riêng), tự thử lại tối đa 3 lần, tự chuyển model dự phòng khi model chính quá tải (503/504), tự vá dấu `\` của LaTeX trong JSON AI trả về, ghi log thời lượng từng lần gọi |
| **Giao diện (Frontend)** | HTML5, CSS3, Bootstrap 5, Bootstrap Icons, AJAX/Fetch | Responsive |
| **Hiển thị Toán học** | KaTeX (Auto-render) | Công thức LaTeX |
| **Log** | SLF4J + Logback | Không log khóa API, mật khẩu |
| **Build** | **Apache Maven** (cấu trúc chuẩn `src/main/java`, `src/main/webapp`; đóng gói `edututor.war`, context path `/edututor`) | Mở trực tiếp bằng **Apache NetBeans 17** (Maven Web Application) |

---

## 👥 3. Phân hệ chức năng theo Vai trò

### 🛡️ Quản trị viên (Admin)
- **Tổng quan hệ thống:** Thống kê số lượng học sinh, giáo viên, chủ đề và câu hỏi.
- **Quản lý người dùng:** Tìm kiếm, lọc theo vai trò/trạng thái, phân trang; tạo, sửa, đổi vai trò, khóa/mở khóa, xóa (cứng hoặc mềm) và đặt lại mật khẩu.
- **Cấu hình AI (FR-ADM-01/02):** Tùy chỉnh Gemini API Key, Provider, Model (mặc định `gemini-3.5-flash`, đổi được trên giao diện) và nút **Test kết nối** kiểm tra kết nối Google AI trực tiếp.
- **Quản lý dữ liệu gốc:** Toàn quyền quản trị Chủ đề, Bài giảng và Ngân hàng câu hỏi.

### 👨‍🏫 Giáo viên (Teacher)
- **Quản lý chuyên đề & bài giảng:** Tạo mới, chỉnh sửa chuyên đề Toán 12, nhúng video bài giảng YouTube.
- **Ngân hàng câu hỏi:** Quản lý câu hỏi trắc nghiệm (MCQ) và tự luận (ESSAY) với 3 mức độ (1 - Dễ, 2 - Trung bình, 3 - Khó; CSDL hiện giới hạn `Level` ∈ {1,2,3}, xem FRS mục 10).
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
│   ├── docs/                              # DATABASE.md (từ điển dữ liệu), ERD.md, ERD + đặc tả ràng buộc (.docx)
│   └── sql/                               # Kịch bản SQL Server
│       ├── 01_schema.sql                  # Tạo CSDL MathTutorDB, 10 bảng + toàn bộ ràng buộc (XÓA CSDL cũ cùng tên)
│       ├── 02_data.sql                    # Dữ liệu mẫu phong phú (mật khẩu BCrypt của EduTutor@123, 15 khóa cấu hình AI)
│       └── 03_data_gdpt2018.sql           # (Tùy chọn) bổ sung chuyên đề / bài học / câu hỏi theo Toán 12 GDPT 2018; chạy lại không nhân đôi
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
    │           └── tags/                  # Tag file dùng lại: pagination.tag, flash.tag, delete-button.tag, config-field.tag, error-card.tag
    └── test/java/com/edututor/            # UnitTests (chạy trong mvn package) + EduTutorIT, QueryCountIT (cần SQL Server)
```

---

## 🚀 5. Hướng dẫn Cài đặt & Khởi chạy

### Bước 1: Chuẩn bị môi trường
- **JDK 17**, **Apache NetBeans 17**, **Apache Tomcat 10.1** (Jakarta Servlet 6.0), **SQL Server** (bật TCP/IP cổng `1433`).
- Maven đi kèm NetBeans (hoặc Maven 3.9+ độc lập).

### Bước 2: Thiết lập Cơ sở Dữ liệu
**Cài mới:** chạy trong SSMS 2 file trong `document/sql/`: `01_schema.sql` (tạo CSDL `MathTutorDB`, 10 bảng và ràng buộc — **xóa và tạo lại** nếu CSDL đã tồn tại) rồi `02_data.sql` (dữ liệu mẫu, mật khẩu mọi tài khoản `EduTutor@123`).

**Đã có CSDL cũ** (ví dụ từ bản Ant): chạy lại 2 file trên để tạo CSDL mới đúng cấu trúc hiện tại (**dữ liệu cũ sẽ bị xóa**, thay bằng dữ liệu mẫu). Stop Tomcat trước khi chạy; sau đó vào **Cấu hình AI** nhập lại khóa Gemini **và kiểm tra lại model** (mọi cấu hình AI, kể cả model đã đổi trên giao diện, bị đặt lại về giá trị mẫu — xem mục 8 nếu AI phản hồi chậm).

**Dữ liệu bổ sung (tùy chọn):** chạy thêm `03_data_gdpt2018.sql` (sau 2 file trên) để có đủ 6 chương Toán 12 GDPT 2018 (thêm 4 chủ đề, 13 bài học, 73 câu trắc nghiệm, 5 tự luận). Chạy lại lần 2 sẽ tự bỏ qua, không nhân đôi.

**Dữ liệu mẫu** trong `02_data.sql` đủ để xem hết các màn hình: 3 giáo viên, 12 học sinh (có tài khoản bị khóa, xóa mềm), 7 chủ đề / 15 bài học (có mục đã ẩn và bài học còn trống), bài giảng đủ 4 loại, 46 câu hỏi, ~150 bài làm trải 14 ngày (có làm lại cùng câu), bài tự luận chờ duyệt / đã duyệt và các phiên gia sư. Ảnh bài tự luận là URL minh họa `placehold.co` (cần mạng), URL video là ví dụ.

> Nếu chạy bằng `sqlcmd`, thêm cờ `-x` (tắt thay thế biến) vì dữ liệu mẫu chứa ký tự `$(`: `sqlcmd -S localhost -U sa -P 123 -C -x -f 65001 -i 02_data.sql`.

### Bước 3: Cấu hình kết nối
Sửa `src/main/resources/application.properties` (`db.url`, `db.username`, `db.password`) **hoặc** đặt biến môi trường / `-D` `DB_URL`, `DB_USER`, `DB_PASS` (ưu tiên cao hơn). Ảnh bài làm tự luận lưu ở `app.upload-dir` (mặc định `C:/edututor/uploads`, đổi bằng `UPLOAD_DIR`).

Khóa Gemini API, model, temperature, số token **không** nằm trong file này: Admin nhập tại trang **Cấu hình AI** (lưu trong bảng `AiConfigs`, có hiệu lực ngay, không cần khởi động lại). Tên model Gemini thay đổi theo thời gian — hãy kiểm tra tên còn được hỗ trợ rồi bấm **Test kết nối**.

### Bước 4: Chạy trên NetBeans 17
1. *File > Open Project* chọn thư mục dự án (nhận dạng là **Maven Web Application**).
2. Thêm server nếu chưa có: *Services > Servers > Add Server > Apache Tomcat or TomEE*, trỏ tới thư mục **Tomcat 10.1**. Trong *Project Properties > Run* chọn server này.
3. Bấm **Clean and Build**, rồi **Run**, mở `http://localhost:8080/edututor/login`.
4. Khi sửa **Entity**, lớp cấu hình (`WebAppInitializer`, `RootConfig`, `WebConfig`), `pom.xml` hoặc `application.properties`: **Stop Tomcat -> Clean and Build -> Run** lại (Hibernate chỉ quét Entity lúc khởi động).

Hoặc dòng lệnh: `mvn clean package` rồi chép `target/edututor.war` vào `webapps/` của Tomcat 10.1.

> Trình biên dịch phải bật `-parameters` (đã cấu hình sẵn trong `pom.xml`).

### Bước 5 (tùy chọn): Chạy kiểm thử
```bash
mvn clean package            # build WAR + 24 unit test, không cần CSDL
# Kiểm thử tích hợp (Tomcat nhúng + SQL Server thật + Gemini giả + đếm số câu SQL chống N+1).
# Dùng CSDL riêng: chạy 01_schema.sql + 02_data.sql sau khi đổi tên MathTutorDB thành MathTutorDB_test:
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
- **Mật khẩu:** tài khoản seed dùng BCrypt (`EduTutor@123`). Chỉ chấp nhận mã băm BCrypt; mã băm SHA-256 của bản cũ bị từ chối (chạy lại `01_schema.sql` + `02_data.sql` để có dữ liệu BCrypt).
- **Tầng dữ liệu:** Entity JPA ánh xạ **1-1 với 10 bảng** (tất cả do `01_schema.sql` tạo). Mọi quan hệ `LAZY`; Service map Entity sang DTO bên trong `@Transactional`; không bật Open-Session-In-View; câu hỏi làm bài chỉ chọn cột được phép (không lộ đáp án/lời giải trước khi nộp).
- **Giao dịch & AI:** các lời gọi Gemini nằm **ngoài** transaction; phần ghi DB của gia sư AI nằm ở bean riêng `TutorPersistence`. Các endpoint `/api/tutor/next-step`, `/api/teacher/generate-questions`, `/api/student/submit-essay-ocr`, `/api/admin/ai-config/test-connection` trả `CompletableFuture`, chạy trên thread pool `aiExecutor` nên không chặn luồng Tomcat.
- **Phản hồi API thống nhất:** mọi `/api/**` trả `{"success", "message", "data", "errors"}`; `GlobalExceptionHandler` ánh xạ lỗi sang mã HTTP (400 dữ liệu sai, 401, 403, 404, 409 xung đột, 422 AI trả dữ liệu không dùng được, 502/503/504 lỗi AI, 500 kèm mã tham chiếu `ERR-yyyyMMdd-xxxx`) và chuyển về trang trước kèm thông báo cho trang thường.
- **CSRF:** mọi form POST có trường ẩn `_csrf`; `fetch` dùng `csrfFetch()` (header `X-CSRF-TOKEN` lấy từ `<meta name="csrf-token">`). Đăng xuất là `POST /logout`.
- **Cấu hình bằng Java, không cần `web.xml`** (dự án không có `web.xml`): `WebAppInitializer` đăng ký DispatcherServlet, UTF-8 filter, multipart, session timeout 30 phút, cookie `HttpOnly` + `SameSite=Lax`. Trang lỗi nằm ở `WEB-INF/views/error/`.
- **JSON từ AI chứa LaTeX:** AI hay quên nhân đôi dấu `\` (`\Leftrightarrow` làm JSON sai cú pháp; `\frac`, `\times` bị hiểu thành ký tự điều khiển). `AiJsonParser.repairLatexEscapes` tự sửa trước khi parse (chỉ trong chuỗi `"..."`, giữ nguyên escape JSON thật); lệnh LaTeX ngoài danh sách `LATEX_AFTER_BACKSLASH` có thể cần bổ sung.
- **Model dự phòng:** khi model chính trả 503/504, `GeminiService` chuyển sang `gemini.fallbackModel` và **giữ model đó** cho các lần thử còn lại của cùng yêu cầu (không quay lại model chính đang quá tải). Lỗi 429 (hết hạn mức miễn phí) báo ngay, không thử lại.
- **Phiên bản trước (Servlet thuần, JDBC thủ công; rồi JdbcTemplate)** đã được thay thế hoàn toàn; không còn `DBContext`, `*DAO`, `JdbcTemplate`, `@WebServlet`, `build.xml`/`nbproject` (Ant).

---

## 🩺 8. Xử lý sự cố: AI phản hồi chậm hoặc lỗi

Mỗi lần gọi Gemini ghi một dòng log kèm thời lượng (xem cửa sổ log Tomcat / console):

```
INFO  GeminiService - Gemini ok:   model=gemini-3.5-flash-lite attempt=1/3 took=1423ms
WARN  GeminiService - Gemini loi:  model=gemini-3.5-flash attempt=1/3 took=1373ms status=503
```

| Dấu hiệu trong log | Nguyên nhân thường gặp | Cách xử lý |
|---|---|---|
| `status=503` ("high demand") | Model chính của Google đang quá tải; mỗi lần lỗi tốn vài giây trước khi chuyển sang model dự phòng | Vào **Cấu hình AI**, đặt `DEFAULT_MODEL` (và `VISION_MODEL` nếu ảnh vẫn đọc tốt) sang model nhẹ như `gemini-3.5-flash-lite` |
| `status=504` hoặc `took` ≥ 14000ms ở lần 1 | Model mạnh xử lý chậm (đặc biệt chấm ảnh) hoặc timeout 35 giây/lần | Dùng model nhẹ hơn; giảm `AI_TIMEOUT_SECONDS` |
| `status=429` | Hết hạn mức miễn phí của Gemini | Chờ khoảng 1 phút hoặc dùng khóa API khác |
| Sau khi tạo lại CSDL mà AI chậm hơn trước | `01_schema.sql` + `02_data.sql` đặt lại bảng `AiConfigs` về model mẫu và xóa khóa API | Nhập lại khóa và chọn lại model trong **Cấu hình AI**, bấm **Test kết nối** |
| "Không đọc được bài làm" khi chấm tự luận | AI đánh giá ảnh không đọc được (`legible=false`), không phải lỗi hệ thống | Chụp rõ nét, đủ sáng, chữ to; nếu ảnh rõ vẫn báo lỗi, thử `VISION_MODEL = gemini-3.5-flash` |

Thông số tham khảo đo được với `gemini-3.5-flash-lite`: gia sư AI và sinh đề thường mất 1–3 giây mỗi lượt. Chất lượng giải thích của model nhẹ có thể kém hơn model mạnh, nên thử một vài bài toán trước khi demo.

> `gemini.thinkingBudget=0` (`application.properties`) chỉ có tác dụng với model `gemini-2.5-*` (không phải bản `pro`); model dòng 3.x bỏ qua tham số này.
