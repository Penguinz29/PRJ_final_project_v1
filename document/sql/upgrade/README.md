# Script nâng cấp CSDL cũ (không dùng khi cài mới)

**Cài mới** chỉ cần 2 file ở thư mục cha, chạy theo thứ tự:

1. `../01_schema.sql` — tạo CSDL `MathTutorDB`, 10 bảng và toàn bộ ràng buộc (**xóa CSDL cũ cùng tên nếu có**).
2. `../02_data.sql` — dữ liệu mẫu (tài khoản mật khẩu `EduTutor@123`, chủ đề, bài học, bài giảng, câu hỏi, 15 khóa cấu hình AI).

Thư mục này chỉ dùng để **nâng cấp một CSDL cũ đang có dữ liệu** (ví dụ CSDL tạo từ bản Ant trước đây, hoặc tạo bằng
bộ script cũ `01_schema` + `02_seed`) lên đúng cấu trúc mà mã nguồn hiện tại cần, **không mất dữ liệu**.

## Cách dùng

Chạy lần lượt `03` → `10` trên CSDL `MathTutorDB` cần nâng cấp. Mọi script đều kiểm tra trước khi sửa nên **chạy lại
nhiều lần không lỗi** — CSDL đã có sẵn phần nào thì script tự bỏ qua phần đó.

| Script | Nội dung |
|---|---|
| `03_ai_configs.sql` | Bảng `AiConfigs` + 5 khóa cấu hình AI đầu tiên |
| `04_update_submissions.sql` | Cột `Submissions.Score`, `AiFeedback` |
| `05_tutor_and_explanation.sql` | `Questions.ExplanationLatex`; bảng `TutorSessions`, `TutorMessages` |
| `06_target_schema_additions.sql` | `IsActive` (xóa mềm), `Topics.OrderIndex`, trạng thái bài làm, `AwaitingInput`, `UpdatedAt`, bảng `LessonMaterials`, `Users.Status`; chuyển `Lessons.YoutubeUrl` thành bài giảng |
| `07_ai_configs_full.sql` | `ConfigValue` → `NVARCHAR(MAX)`, cột `IsSecret`, đủ 15 khóa AI và 3 prompt |
| `08_tutor_session_state.sql` | `TutorSessions.QuestionId`, `ProblemText`, `CurrentStep`, `TotalSteps` |
| `09_submission_scores.sql` | Đổi `Score` → `FinalScore`, thêm `AiScore` (BR-09) |
| `10_lesson_created_by.sql` | `Lessons.CreatedBy` (BR-03) |

Bằng SSMS: mở từng file rồi bấm **Execute**. Bằng dòng lệnh (cờ `-x` bắt buộc vì dữ liệu chứa chuỗi `$(`):

```
sqlcmd -S localhost -U sa -P <mật khẩu> -C -f 65001 -x -i 03_ai_configs.sql
... (lần lượt tới 10_lesson_created_by.sql)
```

Kiểm tra CSDL còn thiếu cột nào (không trả về dòng nào = đã đủ):

```sql
SELECT v.tbl + '.' + v.col AS thieu_cot, v.script AS can_chay
FROM (VALUES ('Lessons','IsActive','06'), ('Topics','OrderIndex','06'), ('Submissions','Status','06'),
             ('AiConfigs','IsSecret','07'), ('TutorSessions','CurrentStep','08'),
             ('Submissions','AiScore','09'), ('Submissions','FinalScore','09'),
             ('Lessons','CreatedBy','10')) v(tbl, col, script)
WHERE COL_LENGTH(v.tbl, v.col) IS NULL;
```

Khác biệt duy nhất so với CSDL cài mới: CSDL nâng cấp còn cột `Lessons.YoutubeUrl` (không còn dùng, vô hại — script
06 đã chuyển link video sang bảng `LessonMaterials`).
