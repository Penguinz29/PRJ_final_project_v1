package com.edututor.service;

import com.edututor.ai.GeminiClient.Turn;
import com.edututor.ai.PromptBuilder;
import com.edututor.dto.TutorAiResult;
import com.edututor.dto.TutorInteractionRequest;
import com.edututor.dto.TutorMessageView;
import com.edututor.dto.TutorSessionView;
import com.edututor.dto.TutorStartRequest;
import com.edututor.dto.TutorStepResponse;
import com.edututor.exception.ConflictException;
import com.edututor.model.SenderType;
import com.edututor.model.TutorStatus;
import com.edututor.service.TutorPersistence.ContextMessage;
import com.edututor.service.TutorPersistence.SessionContext;
import com.edututor.service.TutorPersistence.StartContext;
import com.edututor.service.TutorPersistence.StartMode;
import com.edututor.util.HtmlSanitizer;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import org.springframework.stereotype.Service;

/**
 * Gia sư AI sư phạm từng bước (UC-TUT-01..04).
 * Thuật toán: nạp phiên → dựng prompt (prompt cấu hình + khối TRẠNG THÁI + cấu trúc JSON + quy tắc cố định) →
 * gọi Gemini (NGOÀI transaction) → chuẩn hóa theo quy tắc phía server (không tin hoàn toàn vào AI) → lưu 2 tin nhắn
 * + cập nhật phiên bằng {@link TutorPersistence}. Bước hiện tại, tổng số bước và trạng thái chờ dữ liệu
 * ({@code awaiting_input}) luôn lấy từ CSDL; mọi {@code currentStep} do client gửi đều bị bỏ qua.
 */
@Service
public class AiTutorService {

    /** Loại lượt đang xử lý. */
    public enum TurnKind {
        /** Lượt khởi đầu: AI đặt tổng số bước và hỏi bước 1. */
        START,
        /** Học sinh trả lời bước hiện tại: được chấm đúng / sai. */
        ANSWER,
        /** Học sinh cung cấp dữ liệu AI yêu cầu (awaiting_input = 1): không chấm, không chuyển bước (BR-15). */
        DATA
    }

    /**
     * Cấu trúc phản hồi do ứng dụng quy định (không nằm trong prompt Admin sửa được), vì server dựa vào các trường
     * này để chuẩn hóa bước. Phần sư phạm đọc từ TUTOR_SYSTEM_PROMPT.
     */
    private static final String JSON_FORMAT = String.join("\n",
            "CẤU TRÚC PHẢN HỒI BẮT BUỘC:",
            "- Lượt KHỞI ĐẦU: isStepCorrect = null, currentStep = 1, đặt totalSteps; feedbackToStudent = lời chào và "
                    + "nhận định ngắn về hướng giải (KHÔNG giải), nextPromptOrQuestion = câu hỏi của bước 1, "
                    + "isSessionCompleted = false.",
            "- Lượt HỌC SINH TRẢ LỜI: đúng thì isStepCorrect = true và hỏi bước kế tiếp; sai thì isStepCorrect = false, "
                    + "feedbackToStudent BẮT BUỘC chỉ ra lỗi và gợi ý, nextPromptOrQuestion yêu cầu làm lại đúng bước đó.",
            "- Khi bước hiện tại cần số liệu / dữ kiện mà đề chưa có, hoặc cần học sinh tự chọn một giá trị: "
                    + "needsStudentInput = true, inputRequestHint = mô tả ngắn cần nhập gì, isStepCorrect = null. "
                    + "KHÔNG tự bịa số liệu.",
            "- Lượt HỌC SINH CUNG CẤP DỮ LIỆU: dùng dữ liệu đó để tiếp tục bước hiện tại, không chấm đúng/sai "
                    + "(isStepCorrect = null); nếu vẫn thiếu dữ kiện thì needsStudentInput = true.",
            "- Chỉ khi bước cuối đã đúng: isSessionCompleted = true và finalSummary = tóm tắt cách giải và kết luận "
                    + "(lần đầu tiên được nêu đáp án cuối). Các lượt khác finalSummary = null.",
            "- totalSteps giữ nguyên trong cả phiên. Trả về MỘT JSON object đúng schema:",
            "{\"isStepCorrect\": boolean|null, \"currentStep\": number, \"totalSteps\": number, "
                    + "\"feedbackToStudent\": string, \"nextPromptOrQuestion\": string, \"needsStudentInput\": boolean, "
                    + "\"inputRequestHint\": string|null, \"isSessionCompleted\": boolean, \"finalSummary\": string|null}");

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
     * UC-TUT-01: tạo phiên từ bài toán tự do, bài học, câu trắc nghiệm vừa sai hoặc bài tự luận vừa chấm.
     * Phiên chỉ được ghi vào CSDL SAU khi AI trả lời thành công.
     *
     * @throws IllegalArgumentException dữ liệu không hợp lệ
     * @throws com.edututor.exception.ForbiddenException câu hỏi chưa làm sai / bài làm của người khác
     * @throws com.edututor.exception.AiServiceException khi gọi AI thất bại (không ghi gì vào CSDL)
     */
    public TutorStepResponse start(int studentId, TutorStartRequest req) {
        StartMode mode = parseMode(req.mode());
        StartContext ctx = persistence.prepareStart(studentId, mode, req.problemText(), req.lessonId(),
                req.questionId(), req.selectedOptionId(), req.submissionId());

        final int minSteps = config.getTutorMinSteps();
        final int maxSteps = config.getTutorMaxSteps();
        String system = buildSystem(ctx.lessonTitle(), ctx.problemText(), ctx.reference(), 1, 0,
                "KHỞI ĐẦU", minSteps, maxSteps);
        TutorAiResult raw = callAi(system, List.of(Turn.user(ctx.openingText())), TurnKind.START);

        TutorStepResponse step = normalize(raw, TurnKind.START, 1, 0, minSteps, maxSteps);
        int sessionId = persistence.startSession(studentId, ctx, aiText(step), step);
        return step.withSessionId(sessionId);
    }

    /**
     * UC-TUT-02 / UC-TUT-03: xử lý một lượt của học sinh trong phiên đang học.
     * sessionId = null: tương thích giao diện cũ, coi như tạo phiên FREE với nội dung học sinh nhập.
     *
     * @throws IllegalArgumentException dữ liệu không hợp lệ
     * @throws com.edututor.exception.ForbiddenException phiên không thuộc học sinh (BR-14)
     * @throws ConflictException phiên đã kết thúc
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
        if (req.sessionId() == null) {
            return start(studentId, new TutorStartRequest("FREE", input, req.lessonId(), null, null, null));
        }

        // 1. Nạp phiên và trạng thái do server lưu (transaction ngắn, chỉ đọc)
        SessionContext ctx = persistence.loadContext(studentId, req.sessionId());
        if (ctx.status() != TutorStatus.ACTIVE) {
            throw new ConflictException("Phiên này đã kết thúc. Hãy bắt đầu một bài toán mới.");
        }
        final int prevStep = ctx.currentStep();
        final TurnKind kind = ctx.awaitingInput() ? TurnKind.DATA : TurnKind.ANSWER;

        // 2. Dựng ngữ cảnh hội thoại: 20 tin nhắn gần nhất + lượt mới có gắn nhãn theo trạng thái
        List<Turn> turns = new ArrayList<>();
        for (ContextMessage m : ctx.messages()) {
            turns.add(m.sender() == SenderType.USER ? Turn.user(m.text()) : Turn.model(m.text()));
        }
        String label = kind == TurnKind.DATA
                ? "Dữ liệu học sinh cung cấp cho bước " + prevStep + " (theo yêu cầu: " + nullToEmpty(ctx.inputHint()) + "): "
                : "Câu trả lời của học sinh cho bước " + prevStep + ": ";
        turns.add(Turn.user(label + input));

        // 3. Gọi AI — nằm NGOÀI mọi transaction để không giữ kết nối DB trong lúc chờ mạng
        final int minSteps = config.getTutorMinSteps();
        final int maxSteps = config.getTutorMaxSteps();
        String turnLabel = kind == TurnKind.DATA
                ? "HỌC SINH CUNG CẤP DỮ LIỆU CHO BƯỚC " + prevStep
                : "HỌC SINH TRẢ LỜI BƯỚC " + prevStep;
        String system = buildSystem(ctx.lessonTitle(), ctx.problemText(), ctx.reference(), prevStep,
                ctx.totalSteps(), turnLabel, minSteps, maxSteps);
        TutorAiResult raw = callAi(system, turns, kind);

        // 4. Chuẩn hóa theo quy tắc phía server, 5. lưu (transaction ngắn ở bean riêng)
        TutorStepResponse step = normalize(raw, kind, prevStep, ctx.totalSteps(), minSteps, maxSteps);
        persistence.saveTurn(ctx.sessionId(), prevStep, input, aiText(step), step);
        return step.withSessionId(ctx.sessionId());
    }

    /** UC-TUT-04: học sinh kết thúc phiên sớm. */
    public void abandon(int studentId, int sessionId) {
        persistence.abandon(studentId, sessionId);
    }

    private TutorAiResult callAi(String system, List<Turn> turns, TurnKind kind) {
        return gemini.generateJson(system, turns, false, config.getTemperature(), 2048, node -> {
            try {
                TutorAiResult r = mapper.treeToValue(node, TutorAiResult.class);
                if (isBlank(r.feedbackToStudent()) && isBlank(r.nextPromptOrQuestion())) {
                    throw new IllegalArgumentException("Phản hồi thiếu nội dung.");
                }
                if (kind == TurnKind.START && Boolean.TRUE.equals(r.isSessionCompleted())) {
                    throw new IllegalArgumentException("Không được kết thúc ngay ở lượt đầu tiên.");
                }
                if (kind == TurnKind.ANSWER && Boolean.FALSE.equals(r.isStepCorrect())
                        && !Boolean.TRUE.equals(r.needsStudentInput()) && isBlank(r.feedbackToStudent())) {
                    throw new IllegalArgumentException("Trả lời sai nhưng thiếu gợi ý.");
                }
                return r;
            } catch (JsonProcessingException e) {
                throw new IllegalArgumentException("Sai schema: " + e.getOriginalMessage(), e);
            }
        });
    }

    /** System instruction = TUTOR_SYSTEM_PROMPT + khối TRẠNG THÁI (FRS 5.1) + cấu trúc JSON + phần chốt cố định. */
    private String buildSystem(String lessonTitle, String problem, String reference, int currentStep, int totalSteps,
                               String turnLabel, int minSteps, int maxSteps) {
        StringBuilder prompt = new StringBuilder(config.getPrompt(AiConfigService.KEY_TUTOR_PROMPT));
        if (lessonTitle != null) {
            prompt.append("\nBài học liên quan: ").append(lessonTitle).append('.');
        }
        prompt.append("\n\n=== TRẠNG THÁI PHIÊN (do hệ thống cung cấp) ===")
                .append("\nĐề bài: ").append(problem);
        if (!isBlank(reference)) {
            prompt.append("\nTài liệu tham khảo nội bộ (KHÔNG tiết lộ kết quả cuối cho học sinh): ").append(reference);
        }
        prompt.append("\nBước hiện tại: ").append(currentStep).append(" / Tổng số bước: ")
                .append(totalSteps > 0 ? String.valueOf(totalSteps)
                        : "CHƯA XÁC ĐỊNH — hãy đặt trong khoảng " + minSteps + " đến " + maxSteps)
                .append("\nLượt này: ").append(turnLabel);
        return PromptBuilder.system(prompt.toString(),
                Map.of("MIN_STEPS", String.valueOf(minSteps), "MAX_STEPS", String.valueOf(maxSteps)), JSON_FORMAT);
    }

    /**
     * Chuẩn hóa kết quả AI theo bảng UC-TUT-02 (server quyết định bước, không tin AI tuyệt đối).
     *
     * @param prevStep    bước hiện tại đã lưu trước lượt này
     * @param storedTotal tổng số bước đã lưu (0 = chưa xác định → lấy của AI, ép vào [min, max])
     */
    public static TutorStepResponse normalize(TutorAiResult r, TurnKind kind, int prevStep, int storedTotal,
                                              int minSteps, int maxSteps) {
        int aiTotal = r.totalSteps() == null ? minSteps : r.totalSteps();
        int total = storedTotal > 0 ? storedTotal : Math.min(maxSteps, Math.max(minSteps, aiTotal));
        boolean needsInput = Boolean.TRUE.equals(r.needsStudentInput());
        Boolean correct;
        int current;
        boolean completed = false;
        if (kind == TurnKind.START) {
            correct = null;
            current = 1;
        } else if (kind == TurnKind.DATA || needsInput) {
            // Lượt nhận dữ liệu hoặc AI đang yêu cầu dữ liệu: không chấm, không chuyển bước
            correct = null;
            current = Math.min(prevStep, total);
        } else if (Boolean.TRUE.equals(r.isStepCorrect())) {
            correct = true;
            if (prevStep + 1 > total) {
                completed = true;
                current = total;
            } else {
                current = prevStep + 1;   // isSessionCompleted của AI bị bỏ qua nếu chưa qua bước cuối
            }
        } else {
            correct = false;
            current = Math.min(prevStep, total);
        }
        String hint = needsInput ? HtmlSanitizer.clean(nullToEmpty(r.inputRequestHint())) : null;
        if (needsInput && hint.isEmpty()) {
            hint = "Nhập dữ liệu còn thiếu để tiếp tục.";
        }
        String summary = completed && !isBlank(r.finalSummary()) ? HtmlSanitizer.clean(r.finalSummary().trim()) : null;
        return new TutorStepResponse(null, current, total, correct,
                HtmlSanitizer.clean(nullToEmpty(r.feedbackToStudent())),
                HtmlSanitizer.clean(nullToEmpty(r.nextPromptOrQuestion())),
                needsInput, hint, completed ? "COMPLETED" : "ACTIVE", summary);
    }

    /** Nội dung tin nhắn AI được lưu: nhận xét + câu hỏi tiếp theo (+ tổng kết khi hoàn thành). */
    private String aiText(TutorStepResponse s) {
        StringBuilder sb = new StringBuilder();
        for (String part : new String[]{s.feedbackToStudent(), s.nextPromptOrQuestion(), s.finalSummary()}) {
            if (!isBlank(part)) {
                if (sb.length() > 0) {
                    sb.append("\n\n");
                }
                sb.append(part);
            }
        }
        return sb.toString();
    }

    private StartMode parseMode(String raw) {
        if (raw == null || raw.isBlank()) {
            return StartMode.FREE;
        }
        try {
            return StartMode.valueOf(raw.trim().toUpperCase(Locale.ROOT));
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Chế độ phải là FREE, LESSON, QUESTION hoặc SUBMISSION.");
        }
    }

    private static boolean isBlank(String s) {
        return s == null || s.isBlank();
    }

    private static String nullToEmpty(String s) {
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
