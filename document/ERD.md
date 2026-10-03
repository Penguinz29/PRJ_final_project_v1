# ERD — CSDL MathTutorDB (EduTutor Math 12)

> Nguồn sự thật: `document/sql/01_schema.sql` (10 bảng). Sơ đồ dùng cú pháp Mermaid — xem trực tiếp trên GitHub, VS Code (extension Markdown Preview Mermaid) hoặc dán vào https://mermaid.live để xuất PNG/SVG.

## 1. Sơ đồ quan hệ thực thể

```mermaid
erDiagram
    Users {
        int UserId PK
        varchar Username UK
        varchar PasswordHash
        nvarchar FullName
        varchar Email UK
        varchar Role "ADMIN | TEACHER | STUDENT"
        varchar Status "ACTIVE | SUSPENDED | INACTIVE"
        bit IsActive
        int TeacherId FK "GV phụ trách (STUDENT)"
        datetime CreatedAt
        datetime UpdatedAt
    }

    Topics {
        int TopicId PK
        nvarchar TopicName
        nvarchar Description
        int TeacherId FK "người tạo"
        int OrderIndex
        bit IsActive "xóa mềm"
        datetime CreatedAt
        datetime UpdatedAt
    }

    Lessons {
        int LessonId PK
        int TopicId FK
        nvarchar Title
        nvarchar Summary
        nvarchar Content "lý thuyết LaTeX"
        int DisplayOrder
        bit IsActive "xóa mềm"
        int CreatedBy FK
        datetime CreatedAt
        datetime UpdatedAt
    }

    LessonMaterials {
        int MaterialId PK
        int LessonId FK
        varchar MaterialType "VIDEO | YOUTUBE | LINK | TEXT"
        nvarchar Title
        varchar Url
        nvarchar ContentText
        int OrderIndex
        int CreatedBy FK
        datetime CreatedAt
        datetime UpdatedAt
    }

    Questions {
        int QuestionId PK
        int LessonId FK
        varchar QuestionType "MCQ | ESSAY"
        nvarchar Content
        nvarchar ExplanationLatex
        int Level "1 Dễ, 2 TB, 3 Khó"
        bit IsAiGenerated
        bit IsActive "xóa mềm"
        int TeacherId FK "người tạo"
        datetime CreatedAt
        datetime UpdatedAt
    }

    QuestionOptions {
        int OptionId PK
        int QuestionId FK
        char OptionLetter "UK cùng QuestionId"
        nvarchar Content
        bit IsCorrect
        datetime CreatedAt
        datetime UpdatedAt
    }

    Submissions {
        int SubmissionId PK
        int StudentId FK
        int LessonId "không có FK"
        int QuestionId FK
        varchar QuestionType
        nvarchar StudentAnswer
        varchar EssayImagePath
        bit IsCorrect
        decimal AiScore "0-10, không bị ghi đè"
        decimal FinalScore "0-10"
        nvarchar AiFeedback
        nvarchar SuggestedCorrection
        nvarchar TeacherFeedback
        varchar Status "GRADED | AI_GRADED | REVIEWED"
        bit IsReviewed
        int ReviewedBy FK
        datetime ReviewedAt
        datetime SubmittedAt
        datetime UpdatedAt
    }

    TutorSessions {
        int SessionId PK
        int StudentId FK
        int LessonId FK "ON DELETE SET NULL"
        int QuestionId FK
        nvarchar Title
        nvarchar ProblemText
        int CurrentStep
        int TotalSteps
        varchar Status "ACTIVE | COMPLETED | ABANDONED"
        bit AwaitingInput
        nvarchar InputHint
        datetime CreatedAt
        datetime UpdatedAt
    }

    TutorMessages {
        int MessageId PK
        int SessionId FK
        varchar SenderType "USER | AI"
        int StepNumber
        nvarchar ContentText
        bit IsStepCompleted
        datetime CreatedAt
        datetime UpdatedAt
    }

    AiConfigs {
        int ConfigId PK
        varchar ConfigKey UK
        nvarchar ConfigValue
        nvarchar Description
        bit IsSecret
        int UpdatedBy FK
        datetime CreatedAt
        datetime UpdatedAt
    }

    Users ||--o{ Users : "phụ trách (TeacherId)"
    Users ||--o{ Topics : "tạo (TeacherId)"
    Users ||--o{ Lessons : "tạo (CreatedBy)"
    Users ||--o{ LessonMaterials : "tạo (CreatedBy)"
    Users ||--o{ Questions : "tạo (TeacherId)"
    Users ||--o{ Submissions : "nộp bài (StudentId)"
    Users |o--o{ Submissions : "duyệt (ReviewedBy)"
    Users ||--o{ TutorSessions : "học với gia sư (StudentId)"
    Users |o--o{ AiConfigs : "cập nhật (UpdatedBy)"

    Topics ||--o{ Lessons : "gồm (CASCADE)"
    Lessons ||--o{ LessonMaterials : "có (CASCADE)"
    Lessons ||--o{ Questions : "có (CASCADE)"
    Lessons |o--o{ TutorSessions : "ngữ cảnh (SET NULL)"

    Questions ||--o{ QuestionOptions : "có phương án (CASCADE)"
    Questions ||--o{ Submissions : "được nộp"
    Questions |o--o{ TutorSessions : "mở từ câu hỏi"

    TutorSessions ||--o{ TutorMessages : "hội thoại (CASCADE)"
```

## 2. Danh sách khóa ngoại

| Bảng con | Cột | Bảng cha | Khi xóa cha |
|---|---|---|---|
| Users | TeacherId | Users | NO ACTION |
| Topics | TeacherId | Users | NO ACTION |
| Lessons | TopicId | Topics | CASCADE |
| Lessons | CreatedBy | Users | NO ACTION |
| LessonMaterials | LessonId | Lessons | CASCADE |
| LessonMaterials | CreatedBy | Users | NO ACTION |
| Questions | LessonId | Lessons | CASCADE |
| Questions | TeacherId | Users | NO ACTION |
| QuestionOptions | QuestionId | Questions | CASCADE |
| Submissions | StudentId | Users | NO ACTION |
| Submissions | QuestionId | Questions | NO ACTION |
| Submissions | ReviewedBy | Users | NO ACTION |
| AiConfigs | UpdatedBy | Users | NO ACTION |
| TutorSessions | StudentId | Users | NO ACTION |
| TutorSessions | LessonId | Lessons | SET NULL |
| TutorSessions | QuestionId | Questions | NO ACTION |
| TutorMessages | SessionId | TutorSessions | CASCADE |

## 3. Ghi chú

- **6 bảng lõi:** Users, Topics, Lessons, Questions, Submissions, TutorSessions.
- **4 bảng phụ (chuẩn hóa):** LessonMaterials, QuestionOptions, TutorMessages (thuộc tính đa trị 1–N), AiConfigs (cấu hình).
- `Submissions.LessonId` là cột thường, **không có FK** (chỉ lưu để thống kê tiến độ).
- Ràng buộc UNIQUE: `Users(Username)`, `Users(Email)`, `QuestionOptions(QuestionId, OptionLetter)`, `AiConfigs(ConfigKey)`.
- Index: `LessonMaterials(LessonId, OrderIndex)`, `Questions(LessonId, IsActive)`, `Submissions(StudentId, SubmittedAt DESC)`, `TutorSessions(StudentId, CreatedAt DESC)`, `TutorMessages(SessionId, MessageId)`.
- Xóa mềm bằng `IsActive` (Topics, Lessons, Questions) và `Status = 'INACTIVE'` (Users).
