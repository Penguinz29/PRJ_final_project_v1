package com.edututor.service;

import com.edututor.ai.GeminiClient.Turn;
import com.edututor.ai.PromptBuilder;
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
import java.util.Map;
import org.springframework.stereotype.Service;

/**
 * Gia sư AI sư phạm step-by-step.
 * Thuật toán: nạp phiên → dựng ngữ cảnh → gọi Gemini (NGOÀI transaction) → chuẩn hóa bước theo quy tắc phía
 * server (không tin hoàn toàn vào AI) → lưu 2 tin nhắn + cập nhật phiên bằng {@link TutorPersistence}.
 * Bước hiện tại luôn lấy từ CSDL (tin nhắn AI gần nhất), mọi {@code currentStep} do client gửi đều bị bỏ qua.
 */
@Service
public class AiTutorService {

    /**
     * Cấu trúc phản hồi do ứng dụng quy định (không nằm trong prompt Admin sửa được), vì server dựa vào các trường
     * này để chuẩn hóa bước. Phần sư phạm đọc từ TUTOR_SYSTEM_PROMPT.
     */
    private static final String JSON_FORMAT = String.join("\n",
            "CẤU TRÚC PHẢN HỒI BẮT BUỘC:",
            "- Lượt đầu tiên (học sinh vừa nêu bài toán): isStepCorrect = true, currentStep = 1, "
                    + "feedbackToStudent = lời chào và nhận định ngắn về hướng giải (KHÔNG giải), "
                    + "nextPromptOrQuestion = câu hỏi của bước 1, isSessionCompleted = false.",
            "- Học sinh trả lời đúng: isStepCorrect = true, currentStep tăng thêm 1; "
                    + "nếu bước cuối đã đúng thì isSessionCompleted = true.",
            "- Học sinh trả lời sai: isStepCorrect = false, currentStep giữ nguyên.",
            "- totalSteps giữ nguyên trong cả phiên.",
            "Trả về MỘT JSON object đúng schema:",
            "{\"isStepCorrect\": boolean, \"currentStep\": number, \"totalSteps\": number, "
                    + "\"feedbackToStudent\": string, \"nextPromptOrQuestion\": string, \"isSessionCompleted\": boolean}");

    private final TutorPersistence persistence;
    private final GeminiService gemini;
    private final AiConfigService config;
    private final ObjectMapper mapper;

    public AiTutorService(TutorPersistence persistence, GeminiService gemini, AiConfigService config,
                          ObjectMapper mapper) {
        this.persistence = persistence;
        this.gemini = gemini;
        this.config = config;
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
        final int minSteps = config.getTutorMinSteps();
        final int maxSteps = config.getTutorMaxSteps();
        String prompt = config.getPrompt(AiConfigService.KEY_TUTOR_PROMPT);
        if (lessonTitle != null) {
            prompt += "\nBài học liên quan: " + lessonTitle + ".";
        }
        String system = PromptBuilder.system(prompt,
                Map.of("MIN_STEPS", String.valueOf(minSteps), "MAX_STEPS", String.valueOf(maxSteps)), JSON_FORMAT);
        TutorStepResponse raw = gemini.generateJson(system, turns, false, config.getTemperature(), 2048, node -> {
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
        TutorStepResponse step = normalize(raw, first, prevStep, minSteps, maxSteps);
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

    private TutorStepResponse normalize(TutorStepResponse r, boolean firstTurn, int prevStep,
                                        int minSteps, int maxSteps) {
        int total = Math.min(maxSteps, Math.max(minSteps, r.totalSteps()));
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
