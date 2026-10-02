# **ĐẶC TẢ YÊU CẦU CHỨC NĂNG CHI TIẾT (FRS)**

# **HỆ THỐNG GIA SƯ VÀ LUYỆN THI TOÁN 12 TÍCH HỢP TRÍ TUỆ NHÂN TẠO (EDUTUTOR MATH 12\)**

Dự án: Đồ án PRJ301 (Spring MVC 6 \+ JdbcTemplate \+ SQL Server \+ Gemini API)  
Tài liệu: Functional Requirements Specification (FRS) \- Hướng dẫn chi tiết triển khai mã nguồn  
Phiên bản: 1.0.0

---

# **1\. QUY ƯỚC KIẾN TRÚC VÀ THƯ VIỆN CHUẨN KHI CODE**

## **1.1. Tầng Controller**

* **Xử lý điều hướng view JSP:** Sử dụng annotation `org.springframework.stereotype.Controller`, trả về chuỗi tên View chuẩn dạng `/WEB-INF/views/{name}.jsp`.  
* **Xử lý API AJAX/Fetch:** Sử dụng `org.springframework.web.bind.annotation.RestController` hoặc đánh dấu `@ResponseBody`, đảm bảo trao đổi dữ liệu hoàn toàn dưới dạng JSON.

## **1.2. Tầng Service**

* Đánh dấu annotation `@Service`.  
* Chịu trách nhiệm xử lý toàn bộ logic nghiệp vụ, giao tiếp với Google Gemini REST API và kết nối dữ liệu qua các Repository.

## **1.3. Tầng Data Access (Repository)**

* Đánh dấu annotation `@Repository`.  
* Sử dụng thư viện `org.springframework.jdbc.core.JdbcTemplate`.  
* **Quy định bắt buộc:** 100% truy vấn phải dùng `PreparedStatement` (ký tự `?`), map dữ liệu bằng `RowMapper`. Tuyệt đối không thực hiện nối chuỗi SQL dưới mọi hình thức để tránh lỗ hổng SQL Injection.

## **1.4. Tầng DTO và Model**

* Phân tách rạch ròi giữa Entity (các đối tượng ánh xạ trực tiếp bảng CSDL) và các Request/Response DTO (Data Transfer Object).

---

# **2\. MODULE 1: AUTHENTICATION VÀ AUTHORIZATION (XÁC THỰC VÀ PHÂN QUYỀN)**

## **2.1. UC-AUTH-01: Đăng nhập hệ thống**

| Thông tin | Chi tiết |
| :---- | :---- |
| **URL & Method** | `GET /login` (Hiển thị giao diện), `POST /login` (Xử lý xác thực) |
| **Request Params** | `username` (String), `password` (String) |

**Luồng xử lý:**

1. `LoginController` tiếp nhận thông tin `username` và `password` từ form đăng nhập.  
2. `UserService` gọi phương thức `UserRepository.findByUsername(username)`.  
3. Kiểm tra và so khớp mật khẩu truyền vào với mật khẩu đã băm trong CSDL.  
4. **Nếu thông tin hợp lệ:**  
   * Thêm người dùng vào session: `session.setAttribute("LOGGED_IN_USER", user)`.  
   * Điều hướng dựa trên vai trò:  
     * `ADMIN`: Redirect tới `/admin/dashboard`  
     * `TEACHER`: Redirect tới `/teacher/dashboard`  
     * `STUDENT`: Redirect tới `/student/dashboard`  
5. **Nếu thông tin không hợp lệ:**  
   * Thêm thông báo lỗi `Model.addAttribute("error", "Tên đăng nhập hoặc mật khẩu không chính xác")`.  
   * Trả về giao diện `login.jsp`.

## **2.2. UC-AUTH-02: Đăng ký tài khoản học sinh**

| Thông tin | Chi tiết |
| :---- | :---- |
| **URL & Method** | `GET /register` (Hiển thị trang đăng ký), `POST /register` (Xử lý đăng ký) |
| **Request Params** | `username`, `password`, `confirmPassword`, `fullName`, `email` |

**Validation & Luồng xử lý:**

1. Kiểm tra trường `password` khớp với `confirmPassword`, đảm bảo `email` tuân thủ đúng định dạng Regex.  
2. `UserRepository` kiểm tra sự tồn tại tài khoản thông qua `existsByUsername` và `existsByEmail`. Nếu đã tồn tại, lập tức trả về thông báo lỗi tương ứng.  
3. Tiến hành băm mật khẩu, thiết lập mặc định `role = 'STUDENT'` và `status = 'ACTIVE'`.  
4. Thực thi truy vấn lưu tài khoản:INSERT INTO users (username, password\_hash, full\_name, email, role, status)   
     
   VALUES (?, ?, ?, ?, 'STUDENT', 'ACTIVE')  
     
5. Điều hướng người dùng về trang `/login` kèm thông báo đăng ký thành công.

## **2.3. UC-AUTH-03: Bộ lọc bảo mật AuthInterceptor**

| Thông tin | Chi tiết |
| :---- | :---- |
| **Class đại diện** | `com.edututor.interceptor.AuthInterceptor` (implements `HandlerInterceptor`) |

**Luồng xử lý `preHandle`:**

1. Trích xuất đối tượng người dùng từ bộ nhớ session: `session.getAttribute("LOGGED_IN_USER")`.  
2. Nếu đối tượng `user` bị `null` và đường dẫn URI không nằm trong danh sách whitelist (`/login`, `/register`, `/static/**`), chuyển hướng về `/login` và trả về `false`.  
3. Nếu URI bắt đầu bằng `/admin/` nhưng `user.getRole()` khác `ADMIN`: Gọi `sendError(403, "Access Denied")` và trả về `false`.  
4. Nếu URI bắt đầu bằng `/teacher/` nhưng `user.getRole()` không phải `TEACHER` hoặc `ADMIN`: Gọi `sendError(403)` và trả về `false`.  
5. Các truy vấn hợp lệ khác cho phép tiếp tục xử lý bằng cách trả về `true`.

---

# **3\. MODULE 2: QUẢN TRỊ CẤU HÌNH AI VÀ HỆ THỐNG (ADMIN)**

## **3.1. UC-ADM-01: Cập nhật cấu hình AI (AiConfig)**

| Thông tin | Chi tiết |
| :---- | :---- |
| **URL & Method** | `GET /admin/ai-config` (Xem danh sách), `POST /admin/ai-config/update` (Cập nhật) |
| **Controller** | `AdminAiConfigController` |

**Các khóa cấu hình trong bảng `ai_configs`:**

* `GEMINI_API_KEY`: Khóa truy cập Google AI Studio API.  
* `DEFAULT_MODEL`: Mô hình AI chuẩn (Mặc định: `gemini-1.5-flash`).  
* `VISION_MODEL`: Mô hình xử lý hình ảnh (Mặc định: `gemini-1.5-pro`).  
* `TUTOR_TEMPERATURE`: Độ ngẫu nhiên phản hồi, nhận giá trị Float từ `0.0` đến `1.0` (Mặc định: `0.2`).  
* `MAX_OUTPUT_TOKENS`: Giới hạn dung lượng token đầu ra (Mặc định: `2048`).

**Truy vấn Repository:**UPDATE ai\_configs 

SET config\_value \= ?, model\_name \= ?, temperature \= ?, updated\_by \= ?, updated\_at \= CURRENT\_TIMESTAMP 

WHERE config\_key \= ?

## **3.2. UC-ADM-02: Test API Connection (Ping AI)**

| Thông tin | Chi tiết |
| :---- | :---- |
| **URL & Method** | `POST /admin/ai-config/test-connection` |
| **Kiểu truyền/nhận** | JSON \-\> `ResponseEntity` |

**Luồng xử lý:**

1. `AiConfigService` đọc cấu hình `GEMINI_API_KEY` và `DEFAULT_MODEL` hiện hành từ CSDL.  
2. Thực hiện gọi một HTTP REST POST request tới Google Gemini API endpoint với nội dung prompt thử nghiệm đơn giản ("Ping").  
3. **Nếu phản hồi trả về HTTP Status 200 OK:** Trả về JSON `{ "success": true, "message": "Kết nối Gemini API thành công" }`.  
4. **Nếu xảy ra sự cố:** Trả về JSON `{ "success": false, "message": "Chi tiết lỗi..." }`.

---

# **4\. MODULE 3: QUẢN LÝ NGÂN HÀNG ĐỀ VÀ SINH ĐỀ AI (TEACHER)**

## **4.1. UC-TEA-01: Quản lý Câu hỏi trắc nghiệm và tự luận**

| Thông tin | Chi tiết |
| :---- | :---- |
| **URL & Method** | `GET /teacher/questions` (Danh sách có phân trang & lọc theo `topic_id`, `lesson_id`, `difficulty_level`)`POST /teacher/questions/create` (Tạo câu hỏi mới) |

**Lưu trữ dữ liệu:**

1. **Transaction 1:**INSERT INTO questions (lesson\_id, created\_by, question\_text, question\_type, difficulty\_level, explanation\_latex, is\_ai\_generated)   
     
   VALUES (?, ?, ?, ?, ?, ?, 0\)  
     
   *Lấy về `question_id` vừa được khởi tạo tự động.*  
     
2. **Nếu loại câu hỏi là `MULTIPLE_CHOICE`:**  
   Duyệt danh sách 4 lựa chọn A, B, C, D để lưu dữ liệu:INSERT INTO question\_options (question\_id, option\_label, option\_text, is\_correct)   
     
   VALUES (?, ?, ?, ?)

## **4.2. UC-TEA-02: Sinh câu hỏi tự động bằng Gemini AI (Smart Exam Generator)**

| Thông tin | Chi tiết |
| :---- | :---- |
| **URL & Method** | `POST /api/teacher/generate-questions` |
| **Request Body** | JSON: `{ "topicName": "...", "lessonName": "...", "difficultyLevel": "...", "count": 5 }` |

**Luồng xử lý tại `AiExamService`:**

1. Trích xuất `API Key` và `Model` từ bảng cấu hình `ai_configs`.  
2. Xây dựng **System Instruction**:  
   * Yêu cầu nội dung bám sát Chương trình GDPT 2018 Môn Toán Lớp 12\.  
   * Các công thức toán học bắt buộc bao đóng trong cú pháp LaTeX `$ ... $` hoặc `$$ ... $$`.  
   * Định dạng đầu ra phải là một JSON Array tuân thủ đúng cấu trúc Schema quy định.  
3. Gọi tới Google Gemini API kèm cấu hình `generationConfig: { "response_mime_type": "application/json" }`.  
4. Chuyển đổi (Parse) chuỗi JSON kết quả sang danh sách `QuestionGenerationDTO` bằng `Jackson ObjectMapper`.  
5. Trả dữ liệu JSON thu được về Client để hiển thị trên Modal xem trước.

*Lưu ý xử lý phía Client:* Khi giáo viên xác nhận lưu, ứng dụng gọi `POST /teacher/questions/batch-save` để lưu toàn bộ danh sách câu hỏi do AI tạo vào CSDL (đánh dấu trường is\_ai\_generated \= 1).

---

# **5\. MODULE 4: LUYỆN THI TRẮC NGHIỆM VÀ RENDER KATEX (STUDENT)**

## **5.1. UC-STU-01: Lấy đề thi trắc nghiệm theo bài học**

| Thông tin | Chi tiết |
| :---- | :---- |
| **URL & Method** | `GET /student/quiz?lessonId={lessonId}` |

**Luồng xử lý:**

1. `QuestionRepository` thực thi truy vấn lấy danh sách câu hỏi kèm theo 4 phương án lựa chọn chi tiết của từng câu.  
2. Chuyển giao dữ liệu sang giao diện `quiz.jsp`.  
3. Tích hợp thư viện **KaTeX** trên giao diện: Gọi `katex.render` hoặc sử dụng các đoạn script tự động để hiển thị chuẩn xác các công thức toán học.

## **5.2. UC-STU-02: Nộp đáp án và nhận giải thích chi tiết**

| Thông tin | Chi tiết |
| :---- | :---- |
| **URL & Method** | `POST /api/student/submit-quiz-answer` |
| **Request Body** | JSON: `{ "questionId": 102, "selectedOptionId": 408 }` |

**Luồng xử lý:**

1. Xử lý kiểm tra lựa chọn `option_id` xem có chứa `is_correct = 1` hay không.  
2. Lưu chi tiết lượt làm bài của học sinh vào bảng `submissions`:INSERT INTO submissions (student\_id, question\_id, selected\_option\_id, score, submitted\_at)   
     
   VALUES (?, ?, ?, ?, CURRENT\_TIMESTAMP)  
     
3. Trả về cấu trúc JSON:{  
     
     "isCorrect": true,  
     
     "correctOptionLabel": "B",  
     
     "explanationLatex": "Lời giải chi tiết dạng LaTeX...",  
     
     "score": 1.0  
     
   }

---

# **6\. MODULE 5: GIA SƯ AI SƯ PHẠM STEP-BY-STEP (STUDENT)**

## **6.1. Thiết kế API**

* **Controller:** `TutorSessionController`  
* **Endpoint chính:** `POST /api/tutor/next-step`  
* **Request DTO (`TutorInteractionRequest`):** `sessionId`, `lessonId`, `studentInput`, `currentStep`

## **6.2. Thuật toán xử lý tại AiTutorService**

1. **Khởi tạo:** Nếu `sessionId` nhận vào là `null`, tiến hành tạo một phiên làm việc mới trong `tutor_sessions` với các thông tin (`student_id`, `lesson_id`, `title = studentInput`, `status = 'ACTIVE'`) và lấy về `sessionId`.  
2. **Nạp ngữ cảnh:** Đọc toàn bộ lịch sử trò chuyện trong bảng `tutor_messages` dựa theo `sessionId` nhằm tái lập ngữ cảnh hội thoại đầy đủ cho Gemini API.  
3. **Thiết lập System Instruction bắt buộc:**  
   * **TUYỆT ĐỐI KHÔNG** giải tắt hoặc cung cấp kết quả cuối cùng ngay từ bước đầu tiên.  
   * Yêu cầu phân tích bài toán thành chuỗi từ **3 đến 6 bước logic sư phạm**.  
   * Nếu học sinh trả lời **đúng** ở bước trước: Phản hồi khen ngợi ngắn gọn và đưa ra câu hỏi tính toán cho bước tiếp theo.  
   * Nếu học sinh trả lời **sai**: Cung cấp gợi ý, chỉ ra lỗi sai mang tính xây dựng và yêu cầu thực hiện lại bước hiện tại.  
   * Trả về định dạng JSON Schema:{  
       
       "isStepCorrect": boolean,  
       
       "currentStep": number,  
       
       "totalSteps": number,  
       
       "feedbackToStudent": "string",  
       
       "nextPromptOrQuestion": "string",  
       
       "isSessionCompleted": boolean  
       
     }

     
4. **Lưu trữ:** Ghi nhận 2 bản ghi tin nhắn mới vào bảng `tutor_messages` (gồm câu trả lời của học sinh và phản hồi tương ứng từ AI).  
5. **Cập nhật:** Nếu `isSessionCompleted = true`, thực hiện cập nhật trạng thái phiên trong `tutor_sessions` thành `COMPLETED`.  
6. **Đầu ra:** Trả kết quả `TutorStepResponse` về cho Client để render dữ liệu toán học KaTeX theo thời gian thực.

---

# **7\. MODULE 6: CHẤM BÀI TỰ LUẬN VIẾT TAY ĐA PHƯƠNG THỨC OCR (STUDENT VÀ TEACHER)**

## **7.1. UC-OCR-01: Học sinh nộp ảnh bài làm tự luận**

| Thông tin | Chi tiết |
| :---- | :---- |
| **URL & Method** | `POST /api/student/submit-essay-ocr` |
| **Request Type** | `multipart/form-data` (`questionId`, `essayImage`) |

**Luồng xử lý:**

1. Server tiếp nhận tệp tin ảnh, thực hiện kiểm tra định dạng hợp lệ và dung lượng không quá 5MB.  
2. Mã hóa dữ liệu tệp tin ảnh thành chuỗi mã hóa **Base64**.  
3. Lấy thông tin đề bài gốc chi tiết từ bảng `questions` dựa theo `questionId`.  
4. Khởi tạo và gửi **Multimodal Payload** tới Gemini Vision API (`VISION_MODEL` từ `ai_configs`, mặc định: `gemini-1.5-pro`):  
   * *Payload bao gồm:* `[Ảnh Base64]` \+ `[System Prompt Chấm thi THPT QG Môn Toán + Đề bài gốc]`.  
5. **Nhận diện và Đánh giá AI OCR:**  
   * Phân tích nét chữ viết tay, kiểm tra từng biến đổi đại số, cận tích phân, dấu câu và công thức toán.  
   * Thực hiện chấm điểm theo thang điểm 10.0 (làm tròn tới 0.25).  
   * Trả về dữ liệu dạng JSON: `extractedText`, `score`, `detailedFeedback`, `suggestedCorrection`.  
6. Lưu thông tin vào bảng `submissions` (`student_id`, `question_id`, `essay_image_url`, `score`, `ai_feedback`).  
7. Trả toàn bộ cấu trúc kết quả JSON về cho học sinh theo dõi lập tức.

## **7.2. UC-OCR-02: Giáo viên kiểm tra và điều chỉnh điểm số**

| Thông tin | Chi tiết |
| :---- | :---- |
| **URL & Method** | `GET /teacher/submissions/essay` |

* **Chức năng:** Trình bày danh sách bài làm tự luận của học sinh, hiển thị trực quan ảnh chụp bài làm, kết quả nhận dạng OCR, điểm số AI đề xuất và bài nhận xét chi tiết.  
* **Quyền hạn:** Giáo viên có thẩm quyền xem xét và điều chỉnh lại giá trị tại trường `score` trong bảng `submissions` nếu cần thiết.

---

# **8\. XỬ LÝ LỖI TOÀN CỤC VÀ TÍNH NĂNG CHỐNG CRASH HỆ THỐNG**

## **8.1. Global Exception Handler (`@ControllerAdvice`)**

* **Xử lý `IllegalArgumentException`:** Bắt ngoại lệ và trả về HTTP Status `400 Bad Request` kèm theo phản hồi JSON mô tả chi tiết lỗi.  
* **Xử lý `Exception` hệ thống chung:** Ghi nhận thông tin lỗi chi tiết vào Server Log, trả về HTTP Status `500 Internal Server Error` kèm thông báo thân thiện tới người dùng.

## **8.2. Cơ chế Phôi phục & Chống nghẽn AI (AI Resilience)**

* **Timeout:** Thiết lập ngưỡng thời gian chờ HTTP Connection Timeout tối đa **15 giây** khi thực hiện gọi tới Gemini API.  
* **Tự động thử lại (Retry Mechanism):** Hệ thống tự động thực hiện thử lại tối đa **3 lần** nếu việc parse dữ liệu JSON từ câu phản hồi của AI gặp sự cố không đúng cú pháp.

