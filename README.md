# 🎓 EduTutor Math 12 — Nền tảng Học tập & Ôn thi Toán 12 Tích hợp AI

> **Dự án Môn học:** PRJ301 (Java Web Application) — FPT University  
> **Phiên bản:** 2.0 (Branch: `project-v2`)  
> **Kiến trúc:** Mô hình MVC (Model - View - Controller) chuẩn với Jakarta EE 10 / Servlet 6.0  

---

## 📖 1. Giới thiệu tổng quan

**EduTutor Math 12** là hệ thống web hỗ trợ học tập, ôn luyện và kiểm tra đánh giá môn **Toán lớp 12** theo chương trình THPT Quốc gia. Nền tảng kết hợp giữa quản lý học tập truyền thống (LMS) với các tính năng đột phá từ **Trí tuệ nhân tạo (Google Gemini AI)** nhằm hỗ trợ cả Học sinh, Giáo viên và Quản trị viên:
- **Học sinh:** Ôn tập lý thuyết, luyện trắc nghiệm bấm giờ, xem giải thích chi tiết, nộp bài viết tay và theo dõi lịch sử học tập.
- **Giáo viên:** Soạn giáo án, quản lý ngân hàng câu hỏi, sinh đề trắc nghiệm tự động bằng AI, duyệt và điều chỉnh điểm bài tự luận viết tay của học sinh.
- **Quản trị viên:** Quản lý tài khoản người dùng (khóa/mở khóa), theo dõi số liệu toàn trường và quản lý cấu hình kết nối AI.

---

## 🛠️ 2. Công nghệ sử dụng (Tech Stack)

| Thành phần | Công nghệ / Thư viện | Ghi chú |
|------------|----------------------|---------|
| **Ngôn ngữ** | Java 17 (OpenJDK 17 Temurin) | Chuẩn LTS hiện đại |
| **Web Framework** | Jakarta Servlet 6.0, JSP, JSTL 2.0 | Chạy trên Tomcat 10.1 |
| **Cơ sở dữ liệu** | Microsoft SQL Server 2016+ | Kết nối qua `sqljdbc42.jar` |
| **Bảo mật** | Jakarta Filter (`AuthFilter`, `EncodingFilter`), BCrypt / SHA-256 | Phân quyền RBAC, chống SQL Injection với `PreparedStatement` |
| **Trí tuệ nhân tạo** | Google Gemini API (`gemini-1.5-flash`, `gemini-2.0-flash`) | Gọi REST API qua Java `HttpClient` native |
| **Giao diện (Frontend)** | HTML5, CSS3, Bootstrap 5, Bootstrap Icons | Giao diện Responsive hiện đại |
| **Hiển thị Toán học** | KaTeX (Auto-render extension) | Hiển thị công thức toán LaTeX cực nhanh và sắc nét |
| **IDE & Build** | NetBeans IDE 17, Apache Ant | Hỗ trợ cấu hình UTF-8 toàn diện |

---

## 👥 3. Phân hệ chức năng theo Vai trò

### 🛡️ Quản trị viên (Admin)
- **Tổng quan hệ thống:** Thống kê số lượng học sinh, giáo viên, chủ đề và câu hỏi.
- **Quản lý người dùng:** Danh sách, tìm kiếm, phân trang và **khóa/mở khóa trạng thái tài khoản** (`IsActive`).
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
├── src/
│   ├── conf/                              # Kịch bản SQL Server CSDL
│   │   ├── 01_schema.sql                  # Tạo cấu trúc bảng CSDL
│   │   ├── 02_seed.sql                    # Dữ liệu mẫu (Users, Topics, Lessons, Questions)
│   │   ├── 03_ai_configs.sql              # Bảng cấu hình AI Gemini
│   │   └── 04_update_submissions.sql      # Bổ sung cột Score & AiFeedback
│   └── java/com/mathtutor/
│       ├── controller/                    # Tầng Servlet Điều hướng
│       │   ├── admin/                     # Dashboard, User Toggle, AI Config...
│       │   ├── auth/                      # Login, Logout, Register...
│       │   ├── student/                   # Quiz, Essay, History, Lesson...
│       │   └── teacher/                   # AI Exam Generator, Submissions Review...
│       ├── dao/                           # Tầng Truy cập Dữ liệu (JDBC PreparedStatement)
│       │   ├── AiConfigDAO.java
│       │   ├── LessonDAO.java
│       │   ├── QuestionDAO.java
│       │   ├── SubmissionDAO.java
│       │   ├── TopicDAO.java
│       │   └── UserDAO.java
│       ├── filter/                        # Bộ lọc Request
│       │   ├── AuthFilter.java            # Kiểm soát quyền truy cập theo Role
│       │   └── EncodingFilter.java        # Ép kiểu UTF-8
│       ├── model/                         # Java POJO Entities
│       ├── service/                       # Tầng Dịch vụ (Gemini AI REST Service)
│       └── util/                          # Tiện ích: DBContext, PasswordUtil, Pager...
├── web/
│   ├── assets/                            # CSS, JS, hình ảnh
│   ├── WEB-INF/
│   │   ├── web.xml                        # Cấu hình Web Application
│   │   └── views/                         # Giao diện JSP (Modular View)
│   │       ├── admin/
│   │       ├── auth/
│   │       ├── common/                    # Navbar, Sidebar, Flash, Modal...
│   │       ├── student/
│   │       └── teacher/
│   └── login.jsp
└── README.md
```

---

## 🚀 5. Hướng dẫn Cài đặt & Khởi chạy

### Bước 1: Chuẩn bị môi trường
- Cài đặt **JDK 17** (Eclipse Adoptium Temurin 17 khuyên dùng).
- Cài đặt **Apache Tomcat 10.1** (hỗ trợ Jakarta Servlet 6.0).
- Cài đặt **SQL Server** (2016 trở lên) và kích hoạt cổng `1433`.
- Cài đặt **NetBeans IDE 17**.

### Bước 2: Thiết lập Cơ sở Dữ liệu
Mở SQL Server Management Studio (SSMS) và thực thi lần lượt các file script trong thư mục `src/conf/`:
1. [01_schema.sql](file:///c:/Users/Ngô%20Diệu%20Linh/OneDrive/Desktop/PRJ301-prj/PRJ_final_project_v1/src/conf/01_schema.sql) — Tạo cơ sở dữ liệu `MathTutorDB` và các bảng.
2. [02_seed.sql](file:///c:/Users/Ngô%20Diệu%20Linh/OneDrive/Desktop/PRJ301-prj/PRJ_final_project_v1/src/conf/02_seed.sql) — Nạp dữ liệu mẫu ban đầu.
3. [03_ai_configs.sql](file:///c:/Users/Ngô%20Diệu%20Linh/OneDrive/Desktop/PRJ301-prj/PRJ_final_project_v1/src/conf/03_ai_configs.sql) — Nạp cấu hình AI.
4. [04_update_submissions.sql](file:///c:/Users/Ngô%20Diệu%20Linh/OneDrive/Desktop/PRJ301-prj/PRJ_final_project_v1/src/conf/04_update_submissions.sql) — Cập nhật cấu trúc bảng chấm bài.

### Bước 3: Cấu hình kết nối CSDL
Kiểm tra thông tin tài khoản SQL Server trong file [DBContext.java](file:///c:/Users/Ngô%20Diệu%20Linh/OneDrive/Desktop/PRJ301-prj/PRJ_final_project_v1/src/java/com/mathtutor/util/DBContext.java):
```java
private static final String SERVER_NAME = "localhost";
private static final String PORT_NUMBER = "1433";
private static final String DATABASE_NAME = "MathTutorDB";
private static final String USER_ID = "sa";
private static final String PASSWORD = "123";
```

### Bước 4: Mở dự án và Chạy trong NetBeans
1. Mở **NetBeans IDE 17** -> Chọn **File** -> **Open Project** -> Chọn thư mục `PRJ_final_project_v1`.
2. Chuột phải vào tên dự án `FINAL_prj_v1` -> Chọn **Properties** -> Mục **Run**:
   - Server: Chọn **Apache Tomcat 10.1**.
   - Java Platform: Chọn **JDK 17**.
3. Chuột phải vào dự án -> Chọn **Clean and Build** (Báo `BUILD SUCCESSFUL`).
4. Chuột phải vào dự án -> Chọn **Run** (Trình duyệt sẽ tự động mở trang đăng nhập).

---

## 🔑 6. Tài khoản Thử nghiệm (Demo Accounts)

Tất cả các tài khoản mặc định có mật khẩu là: **`123456`**

| Vai trò | Tên đăng nhập | Email | Mục đích kiểm thử |
|---------|---------------|-------|-------------------|
| **Admin** | `admin` | `admin@mathtutor.com` | Quản trị hệ thống, bật/tắt tài khoản, cấu hình AI |
| **Giáo viên** | `teacher1` | `huong@mathtutor.com` | Quản lý chuyên đề, sinh đề AI, duyệt điểm tự luận |
| **Giáo viên** | `teacher2` | `quang@mathtutor.com` | Quản lý bài tập, theo dõi học sinh |
| **Học sinh** | `student1` | `st1@example.com` | Làm bài trắc nghiệm, xem lịch sử làm bài |
| **Học sinh** | `student2` | `st2@example.com` | Nộp bài tự luận viết tay |

---

## ⚙️ 7. Lưu ý Kỹ thuật quan trọng (Encoding & Ant Build)
- Do đường dẫn thư mục người dùng trên Windows có thể chứa dấu Tiếng Việt (`Ngô Diệu Linh`), hệ thống đã được tối ưu hóa toàn diện với thiết lập:
  - `ANT_OPTS = -Dfile.encoding=UTF-8`
  - `JAVA_TOOL_OPTIONS = -Dfile.encoding=UTF-8`
  - `netbeans.conf` trỏ trực tiếp đến JDK 17 (`netbeans_jdkhome="C:\Program Files\Eclipse Adoptium\jdk-17.0.20.101-hotspot"`).
- Đảm bảo biên dịch và đóng gói `.war` mượt mà 100% không gặp lỗi xung đột bảng mã ký tự.
