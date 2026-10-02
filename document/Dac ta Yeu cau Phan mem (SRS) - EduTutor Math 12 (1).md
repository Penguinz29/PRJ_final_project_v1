# **ĐẶC TẢ YÊU CẦU PHẦN MỀM (SRS)**

# **HỆ THỐNG GIA SƯ & LUYỆN THI TOÁN 12 TÍCH HỢP TRÍ TUỆ NHÂN TẠO (EDUTUTOR MATH 12\)**

* **Dự án:** Đồ án môn học PRJ301 (Java Web Application)  
* **Kiến trúc:** Spring MVC 6, Jakarta Servlet 6.0, Spring JDBC (JdbcTemplate), SQL Server  
* **Tích hợp:** Google Gemini API (gemini-1.5-pro / flash)  
* **Phiên bản:** 1.0.0

---

# **1\. GIỚI THIỆU (INTRODUCTION)**

## **1.1. Mục đích tài liệu (Purpose)**

Tài liệu Đặc tả Yêu cầu Phần mềm (SRS) này mô tả chi tiết, toàn diện các yêu cầu chức năng (Functional Requirements), phi chức năng (Non-Functional Requirements), thiết kế cơ sở dữ liệu, kiến trúc hệ thống và giao diện bên ngoài của hệ thống EduTutor Math 12\. Tài liệu đóng vai trò làm chuẩn tham chiếu cho việc phát triển, kiểm thử, tích hợp và bảo vệ đồ án trước Hội đồng chấm thi môn PRJ301.

## **1.2. Phạm vi sản phẩm (Product Scope)**

EduTutor Math 12 là nền tảng web ứng dụng Trí tuệ Nhân tạo (Generative AI & Multimodal Vision) hỗ trợ học tập, ôn luyện và kiểm tra đánh giá chuyên sâu môn Toán lớp 12 theo Chương trình Giáo dục Phổ thông 2018 (GDPT 2018). Hệ thống đáp ứng đầy đủ yêu cầu kĩ thuật của môn học PRJ301 với 3 nhóm người dùng chính: Admin, Teacher, và Student.

Hệ thống bao phủ 4 chuyên đề trọng tâm theo chương trình mới:

1. **Ứng dụng Đạo hàm để khảo sát và vẽ đồ thị hàm số:** Tính đơn điệu, cực trị, giá trị lớn nhất \- nhỏ nhất, đường tiệm cận và đồ thị hàm số.  
2. **Nguyên hàm – Tích phân và Ứng dụng:** Nguyên hàm của các hàm số cơ bản, tích phân xác định, tính diện tích hình phẳng và thể tích khối tròn xoay.  
3. **Phương pháp tọa độ trong không gian (Oxyz):** Vectơ, tọa độ điểm, phương trình mặt phẳng, đường thẳng và mặt cầu.  
4. **Xác suất & Thống kê hiện đại:** Xác suất có điều kiện, công thức xác suất toàn phần và công thức Bayes.

## **1.3. Định nghĩa và Từ viết tắt (Definitions & Acronyms)**

* **SRS:** Software Requirements Specification.  
* **IoC / DI:** Inversion of Control / Dependency Injection.  
* **MVC:** Model \- View \- Controller.  
* **OCR:** Optical Character Recognition.  
* **LaTeX / KaTeX:** Ngôn ngữ và thư viện kết xuất công thức toán học hiển thị trên web.  
* **Prompt:** Câu lệnh/chỉ dẫn ngữ cảnh điều khiển mô hình ngôn ngữ lớn (LLM).

---

# **2\. MÔ TẢ TỔNG QUAN (OVERALL DESCRIPTION)**

## **2.1. Phân loại tác nhân người dùng (User Classes & Roles)**

### **1\. Admin (Quản trị viên)**

* Quản lý tài khoản người dùng, phân quyền truy cập.  
* Quản lý các tham số cấu hình AI (API Key, Model ID, Temperature, Giới hạn Token).  
* Giám sát hiệu năng và trạng thái kết nối các dịch vụ bên ngoài.

### **2\. Teacher (Giáo viên)**

* Quản lý chủ đề (Topics) và bài học (Lessons).  
* Quản lý ngân hàng câu hỏi (Tạo thủ công hoặc sử dụng AI Prompt để sinh đề trắc nghiệm/tự luận chuẩn THPT Quốc gia).  
* Giám sát bài làm, kết quả tự luyện của học sinh và xác nhận/hiệu chỉnh điểm chấm tự luận từ AI.

### **3\. Student (Học sinh)**

* Đăng ký tài khoản, đăng nhập, quản lý hồ sơ cá nhân.  
* Tham gia luyện thi trắc nghiệm theo bài học/chuyên đề với phản hồi giải thích chi tiết bằng KaTeX.  
* Học tập cùng Gia sư AI sư phạm (Pedagogical Step-by-step Tutor).  
* Nộp ảnh bài làm tự luận viết tay để nhận phản hồi nhận diện OCR và chấm lỗi sai chi tiết.

## **2.2. Khung công nghệ & Môi trường vận hành**

* **Môi trường Server:** JDK 17 LTS, Apache Tomcat 10+ (Jakarta Servlet 6.0).  
* **Web Framework:** Spring MVC 6 (`DispatcherServlet`, Annotation-driven: `@Controller`, `@Service`, `@Repository`, `@RestController`, `@ControllerAdvice`).  
* **Tầng Data Access:** Spring JDBC với `JdbcTemplate` kết hợp HikariCP Connection Pool (100% PreparedStatement chống SQL Injection).  
* **Cơ sở dữ liệu:** Microsoft SQL Server (Chuẩn hóa 3NF, 9 bảng).  
* **Frontend & UI:** JSP (JavaServer Pages), JSTL, Bootstrap 5.3, Bootstrap Icons, KaTeX Engine, AJAX/Fetch API.  
* **Tích hợp AI:** Google Gemini REST API (`gemini-1.5-pro` cho Vision OCR, `gemini-1.5-flash` cho Tutor & Quiz).

---

# **3\. THIẾT KẾ CƠ SỞ DỮ LIỆU (DATABASE SCHEMA)**

Hệ thống gồm 9 bảng chuẩn hóa 3NF:

| Tên Bảng | Khóa Chính (PK) | Khóa Ngoại (FK) | Mô Tả Trường Dữ Liệu |
| :---- | :---- | :---- | :---- |
| `users` | `user_id` | \- | `username`, `password_hash`, `full_name`, `email`, `role` (ADMIN, TEACHER, STUDENT), `status` (ACTIVE, INACTIVE, SUSPENDED), `created_at` |
| `topics` | `topic_id` | \- | `topic_name`, `description`, `order_index` |
| `lessons` | `lesson_id` | `topic_id` | `lesson_name`, `content_summary`, `order_index` |
| `questions` | `question_id` | `lesson_id, created_by` | `question_text`, `question_type` (MULTIPLE\_CHOICE, ESSAY), `difficulty_level` (EASY, MEDIUM, HARD, ADVANCED), `explanation_latex`, `is_ai_generated`, `created_at` |
| `question_options` | `option_id` | `question_id` | `option_label` (A, B, C, D), `option_text`, `is_correct` |
| `submissions` | `submission_id` | `student_id, question_id, selected_option_id` | `essay_answer_text`, `essay_image_url`, `score`, `ai_feedback`, `submitted_at` |
| `ai_configs` | `config_id` | `updated_by` | `config_key`, `config_value`, `model_name`, `temperature`, `updated_at` |
| `tutor_sessions` | `session_id` | `student_id, lesson_id` | `title`, `status` (ACTIVE, COMPLETED, ABANDONED), `created_at` |
| `tutor_messages` | `message_id` | `session_id` | `sender_type` (USER, AI), `step_number`, `content_text`, `is_step_completed`, `created_at` |

---

# **4\. ĐẶC TẢ YÊU CẦU CHỨC NĂNG (FUNCTIONAL REQUIREMENTS)**

## **Phân hệ 1: Xác thực & Phân quyền**

* **FR-AUTH-01:** Đăng ký tài khoản người dùng với vai trò mặc định là STUDENT, kiểm tra tính duy nhất của `username` và `email`.  
* **FR-AUTH-02:** Đăng nhập/Đăng xuất, lưu trữ thông tin phiên làm việc trong `HttpSession` (`LOGGED_IN_USER`).  
* **FR-AUTH-03:** Bộ lọc `AuthInterceptor` chặn các truy cập trái phép: chuyển hướng đến trang login nếu chưa xác thực; yêu cầu quyền ADMIN đối với URL `/admin/**`; yêu cầu quyền TEACHER hoặc ADMIN đối với URL `/teacher/**`.

## **Phân hệ 2: Quản trị Hệ thống & Cấu hình AI (Admin)**

* **FR-ADM-01:** Xem và điều chỉnh các tham số cấu hình AI (`GEMINI_API_KEY`, `DEFAULT_MODEL`, `VISION_MODEL`, `TUTOR_TEMPERATURE`, `MAX_OUTPUT_TOKENS`) trực tiếp trong CSDL mà không cần khởi động lại ứng dụng.  
* **FR-ADM-02:** Kiểm tra kết nối AI Console (Test API Connection) gửi ping payload để kiểm tra tính sẵn sàng của Gemini API.  
* **FR-ADM-03:** Quản trị tài khoản người dùng, thay đổi trạng thái kích hoạt hoặc khóa tài khoản.

## **Phân hệ 3: Quản lý Nội dung & Ngân hàng Đề thi (Teacher)**

* **FR-TEA-01:** Quản lý danh mục chuyên đề (Topics) và bài học (Lessons).  
* **FR-TEA-02:** Quản lý ngân hàng câu hỏi thủ công (soạn thảo đề, phương án A-B-C-D, lời giải LaTeX).  
* **FR-TEA-03:** Sinh đề thi thông minh qua Gemini API theo cấu trúc GDPT 2018 (chọn chủ đề, độ khó, số lượng câu), kiểm tra render KaTeX và lưu vào CSDL với cờ `is_ai_generated = 1`.  
* **FR-TEA-04:** Theo dõi và duyệt/điều chỉnh điểm số bài tự luận viết tay do AI chấm.

## **Phân hệ 4: Luyện thi Trắc nghiệm (Student)**

* **FR-STU-01:** Lựa chọn bài luyện tập theo từng chuyên đề/bài học với công thức toán kết xuất chuẩn qua KaTeX.  
* **FR-STU-02:** Nộp đáp án trắc nghiệm, tự động chấm điểm tức thì và hiển thị giải thích chi tiết nếu chọn sai.  
* **FR-STU-03:** Xem lịch sử làm bài và tiến độ ôn tập cá nhân.

## **Phân hệ 5: Gia sư AI Sư phạm Step-by-step (Student)**

* **FR-TUT-01:** Khởi tạo phiên hỏi đáp gia sư 1-on-1 theo bài toán cụ thể.  
* **FR-TUT-02:** AI dẫn dắt theo phương pháp sư phạm: không cung cấp lời giải trọn vẹn ngay mà chia bài toán thành 3-6 bước nhỏ. Mỗi bước đưa lý thuyết tóm tắt và câu hỏi gợi mở yêu cầu học sinh biến đổi/tính toán.  
* **FR-TUT-03:** Xử lý tương tác vòng lặp: Nếu học sinh giải đúng, AI khen và chuyển sang bước tiếp theo; nếu sai, AI chỉ ra điểm nhầm lẫn, gợi ý (hint) và yêu cầu làm lại bước hiện tại.

## **Phân hệ 6: Chấm bài Tự luận Đa phương thức OCR (Student & Teacher)**

* **FR-OCR-01:** Học sinh tải ảnh bài làm tự luận viết tay cho câu hỏi được giao.  
* **FR-OCR-02:** Gemini Vision API (`gemini-1.5-pro`) trích xuất nội dung toán học viết tay, kiểm tra logic từng bước biến đổi, cận tích phân, dấu và phép toán.  
* **FR-OCR-03:** Chấm điểm trên thang 10.0 (làm tròn đến 0.25), chỉ rõ vị trí sai sót, cung cấp lời giải đúng bằng LaTeX và đồng bộ dữ liệu vào bảng `submissions`.

---

# **5\. ĐẶC TẢ YÊU CẦU PHI CHỨC NĂNG (NON-FUNCTIONAL REQUIREMENTS)**

* **NFR-01 (Hiệu năng):** Thời gian phản hồi cho các thao tác CSDL dưới 1.0 giây nhờ tối ưu HikariCP và PreparedStatement.  
* **NFR-02 (Xử lý bất đồng bộ AI):** Áp dụng Asynchronous AJAX/Fetch API kết hợp hiệu ứng loading indicator ở client và `CompletableFuture` / `DeferredResult` ở server để xử lý các cuộc gọi AI (thời gian xử lý 3-5 giây) mà không chặn luồng Tomcat.  
* **NFR-03 (Bảo mật \- Chống SQL Injection & XSS):** Sử dụng 100% PreparedStatement qua JdbcTemplate, mã hóa HTML bằng JSTL `<c:out>` và sanitize bằng JSoup trước khi hiển thị qua KaTeX.  
* **NFR-04 (Độ tin cậy):** Xử lý ngoại lệ tập trung qua `@ControllerAdvice` (`GlobalExceptionHandler`). Kiểm soát định dạng JSON trả về từ AI với `response_mime_type: application/json` và cơ chế tự động thử lại (retry tối đa 3 lần) bằng Jackson ObjectMapper.  
* **NFR-05 (Giao diện & Tương thích):** Giao diện Responsive trên nền Bootstrap 5.3, hỗ trợ đầy đủ ký hiệu toán học GDPT 2018 bằng KaTeX.

