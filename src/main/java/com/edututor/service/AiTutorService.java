package com.edututor.service;

import com.edututor.ai.GeminiClient.Turn;
import com.edututor.dto.TutorInteractionRequest;
import com.edututor.dto.TutorMessageView;
import com.edututor.dto.TutorSessionView;
import com.edututor.dto.TutorStepResponse;
import com.edututor.exception.ConflictException;
import com.edututor.model.SenderType;
import com.edututor.model.TutorStatus;
import com.edututor.service.TutorPersistence.ContextMessage;
import com.edututor.service.TutorPersistence.SessionContext;
import com.edututor.util.HtmlSanitizer;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.ArrayList;
import java.util.List;
import org.springframework.stereotype.Service;

/**
 * Gia sư AI sư phạm step-by-step.
 * Thuật toán: nạp phiên → dựng ngữ cảnh → gọi Gemini (NGOÀI transaction) → chuẩn hóa bước theo quy tắc phía
 * server (không tin hoàn toàn vào AI) → lưu 2 tin nhắn + cập nhật phiên bằng {@link TutorPersistence}.
 * Bước hiện tại luôn lấy từ CSDL (tin nhắn AI gần nhất), mọi {@code currentStep} do client gửi đều bị bỏ qua.
 */
@Service
public class AiTutorService {

    private static final int MIN_STEPS = 3;
    private static final int MAX_STEPS = 6;

    private static final String SYSTEM_INSTRUCTION = String.join("\n",
            "Bạn là gia sư Toán lớp 12 (chương trình GDPT 2018), dạy theo phương pháp sư phạm từng bước (gợi mở).",
            "QUY TẮC BẮT BUỘC:",
            "- TUYỆT ĐỐI KHÔNG giải tắt hoặc đưa lời giải trọn vẹn / đáp số cuối cùng ngay từ bước đầu tiên.",
            "- Phân tích bài toán thành chuỗi từ 3 đến 6 bước logic sư phạm; totalSteps giữ nguyên trong cả phiên.",
            "- Mỗi bước gồm: tóm tắt ngắn lý thuyết cần dùng và MỘT câu hỏi gợi mở yêu cầu học sinh tự biến đổi/tính toán.",
            "- Khi học sinh trả lời bước hiện tại:",
            "  + ĐÚNG: khen ngắn gọn rồi đưa câu hỏi cho bước kế tiếp (currentStep tăng thêm 1). "
                    + "Nếu đó là bước cuối đã đúng thì tổng kết và đặt isSessionCompleted = true.",
            "  + SAI: chỉ ra điểm nhầm lẫn một cách xây dựng, đưa gợi ý (hint) và yêu cầu làm lại ĐÚNG bước hiện tại "
                    + "(currentStep giữ nguyên, isStepCorrect = false). Không tiết lộ đáp án của bước đó.",
            "- Lượt đầu tiên (học sinh vừa nêu bài toán): isStepCorrect = true, currentStep = 1, "
                    + "feedbackToStudent = lời chào và nhận định ngắn về hướng giải (KHÔNG giải), "
                    + "nextPromptOrQuestion = câu hỏi của bước 1, isSessionCompleted = false.",
            "- Mọi công thức toán đặt trong $...$ (inline) hoặc $$...$$ (khối), cú pháp KaTeX. Trả lời bằng tiếng Việt.",
            "- Chỉ trả về MỘT JSON object, không markdown, đúng schema:",
            "{\"isStepCorrect\": boolean, \"currentStep\": number, \"totalSteps\": number, "
                    + "\"feedbackToStudent\": string, \"nextPromptOrQuestion\": string, \"isSessionCompleted\": boolean}");

    private final TutorPersistence persistence;
    private final GeminiService gemini;
    private final ObjectMapper mapper;

    public AiTutorService(TutorPersistence persistence, GeminiService gemini, ObjectMapper mapper) {
        this.persistence = persistence;
        this.gemini = gemini;
        this.mapper = mapper;
    }

    /**
     * Xử lý một lượt tương tác của học sinh.
     *
     * @throws IllegalArgumentException dữ liệu không hợp lệ
     * @throws com.edututor.exception.ForbiddenException phiên không thuộc học sinh (BR-14)
     * @throws com.edututor.exception.AiServiceException khi gọi AI thất bại (không ghi gì vào CSDL)
     */
    public TutorStepResponse nextStep(int studentId, TutorInteractionRequest req) {
        String input = req.studentInput() == null ? "" : req.studentInput().trim();
        if (input.isEmpty()) {
            throw new IllegalArgumentException("Vui lòng nhập bài toán hoặc câu trả lời của bạn.");
        }
        if (input.length() > 2000) {
            throw new IllegalArgumentException("Nội dung quá dài (tối đa 2000 ký tự).");
        }

        // 1. Nạp phiên (transaction ngắn, chỉ đọc)
        final boolean first = req.sessionId() == null;
        SessionContext ctx = null;
        if (!first) {
            ctx = persistence.loadContext(studentId, req.sessionId());
            if (ctx.status() != TutorStatus.ACTIVE) {
                throw new ConflictException("Phiên này đã kết thúc. Hãy bắt đầu một bài toán mới.");
            }
        }
        String lessonTitle = first ? persistence.lessonTitle(req.lessonId()) : ctx.lessonTitle();
        List<ContextMessage> history = first ? List.of() : ctx.messages();
        final int prevStep = lastAiStep(history);

        // 2. Dựng ngữ cảnh hội thoại
        List<Turn> turns = new ArrayList<>();
        for (ContextMessage m : history) {
            turns.add(m.sender() == SenderType.USER ? Turn.user(m.text()) : Turn.model(m.text()));
        }
        turns.add(Turn.user(first
                ? "Bài toán của học sinh: " + input
                : "Câu trả lời của học sinh cho bước " + prevStep + ": " + input));

        // 3. Gọi AI — nằm NGOÀI mọi transaction để không giữ kết nối DB trong lúc chờ mạng
        String system = SYSTEM_INSTRUCTION;
        if (lessonTitle != null) {
            system += "\nBài học liên quan: " + lessonTitle + ".";
        }
        TutorStepResponse raw = gemini.generateJson(system, turns, false, 2048, node -> {
            try {
                TutorStepResponse r = mapper.treeToValue(node, TutorStepResponse.class);
                if (r.feedbackToStudent() == null && r.nextPromptOrQuestion() == null) {
                    throw new IllegalArgumentException("Phản hồi thiếu nội dung.");
                }
                if (first && r.isSessionCompleted()) {
                    throw new IllegalArgumentException("Không được kết thúc ngay ở lượt đầu tiên.");
                }
                return r;
            } catch (JsonProcessingException e) {
                throw new IllegalArgumentException("Sai schema: " + e.getOriginalMessage(), e);
            }
        });

        // 4. Chuẩn hóa theo quy tắc phía server
        TutorStepResponse step = normalize(raw, first, prevStep);
        String aiText = joinText(step.feedbackToStudent(), step.nextPromptOrQuestion());

        // 5. Lưu kết quả (transaction ngắn ở bean riêng)
        int sessionId;
        if (first) {
            String title = input.length() > 200 ? input.substring(0, 200) : input;
            sessionId = persistence.startSession(studentId, req.lessonId(), title, input, aiText, step);
        } else {
            sessionId = ctx.sessionId();
            persistence.saveTurn(sessionId, prevStep, input, aiText, step);
        }
        return step.withSessionId(sessionId);
    }

    /** Bước hiện tại = bước của tin nhắn AI gần nhất (nguồn tin cậy là CSDL); chưa có thì là bước 1. */
    private int lastAiStep(List<ContextMessage> history) {
        for (int i = history.size() - 1; i >= 0; i--) {
            if (history.get(i).sender() == SenderType.AI) {
                return Math.max(1, history.get(i).step());
            }
        }
        return 1;
    }

    private TutorStepResponse normalize(TutorStepResponse r, boolean firstTurn, int prevStep) {
        int total = Math.min(MAX_STEPS, Math.max(MIN_STEPS, r.totalSteps()));
        boolean correct = firstTurn || r.isStepCorrect();
        boolean completed;
        int current;
        if (firstTurn) {
            current = 1;
            completed = false;
        } else if (correct) {
            if (r.isSessionCompleted() || prevStep >= total) {
                completed = true;
                current = total;
            } else {
                completed = false;
                current = prevStep + 1;
            }
        } else {
            completed = false;
            current = Math.min(prevStep, total);
        }
        return new TutorStepResponse(null, correct, current, total,
                HtmlSanitizer.clean(nullToEmpty(r.feedbackToStudent())),
                HtmlSanitizer.clean(nullToEmpty(r.nextPromptOrQuestion())), completed);
    }

    private String joinText(String a, String b) {
        if (a.isBlank()) {
            return b;
        }
        return b.isBlank() ? a : a + "\n\n" + b;
    }

    private String nullToEmpty(String s) {
        return s == null ? "" : s.trim();
    }

    // ---------- Truy vấn cho giao diện ----------

    public List<TutorSessionView> getRecentSessions(int studentId) {
        return persistence.recentSessions(studentId, 15);
    }

    public List<TutorMessageView> getMessages(int studentId, int sessionId) {
        return persistence.getMessages(studentId, sessionId);
    }

    public TutorSessionView getSession(int studentId, int sessionId) {
        return persistence.getSession(studentId, sessionId);
    }
}
