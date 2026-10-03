package com.edututor.service;

import com.edututor.ai.GeminiClient.Part;
import com.edututor.ai.GeminiClient.Turn;
import com.edututor.ai.PromptBuilder;
import com.edututor.ai.RateLimiter;
import com.edututor.dto.EssayGradingResult;
import com.edututor.dto.EssayOcrResponse;
import com.edututor.model.Question;
import com.edututor.model.QuestionType;
import com.edututor.repository.QuestionRepository;
import com.edututor.exception.AiServiceException;
import com.edututor.util.HtmlSanitizer;
import com.edututor.util.ImageValidator;
import com.edututor.util.ScoreUtil;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

/**
 * UC-OCR-01 / FR-OCR-01..03: chấm bài tự luận viết tay bằng Gemini Vision.
 * Ảnh -> kiểm tra định dạng/dung lượng -> Base64 -> Gemini (VISION_MODEL) -> điểm thang 10 (làm tròn 0.25)
 * -> lưu Submissions (giáo viên có thể duyệt/chỉnh điểm sau).
 */
@Service
public class EssayGradingService {

    /** Cấu trúc phản hồi do ứng dụng quy định; phần nhiệm vụ chấm đọc từ GRADING_PROMPT. */
    private static final String JSON_FORMAT = String.join("\n",
            "CẤU TRÚC PHẢN HỒI BẮT BUỘC: trả về MỘT JSON object:",
            "{\"legible\": boolean, \"extractedText\": string (nội dung bài làm đã chép lại), "
                    + "\"score\": number (thang 10), \"detailedFeedback\": string (nhận xét chung), "
                    + "\"errors\": [{\"location\": string (dòng / bước), \"description\": string}], "
                    + "\"suggestedCorrection\": string (lời giải đúng)}",
            "- legible = false khi ảnh mờ, không đọc được hoặc không phải bài giải toán: khi đó KHÔNG chấm điểm "
                    + "(score = 0), detailedFeedback nêu lý do ngắn gọn.",
            "- errors liệt kê từng chỗ sai (rỗng nếu bài làm đúng hoàn toàn).");

    static final String ILLEGIBLE_MESSAGE = "Không đọc được bài làm, vui lòng chụp lại rõ nét hơn.";

    private static final String NO_REFERENCE = "(Không có đáp án tham khảo, hãy tự giải để đối chiếu.)";

    private final GeminiService gemini;
    private final AiConfigService config;
    private final QuestionRepository questionRepository;
    private final SubmissionService submissionService;
    private final FileStorageService storage;
    private final ObjectMapper mapper;
    private final RateLimiter rateLimiter;
    private final long maxFileSize;

    public EssayGradingService(GeminiService gemini, AiConfigService config, QuestionRepository questionRepository,
                               SubmissionService submissionService, FileStorageService storage,
                               ObjectMapper mapper, RateLimiter rateLimiter,
                               @Value("${app.upload.max-bytes:5242880}") long maxFileSize) {
        this.rateLimiter = rateLimiter;
        this.gemini = gemini;
        this.config = config;
        this.questionRepository = questionRepository;
        this.submissionService = submissionService;
        this.storage = storage;
        this.mapper = mapper;
        this.maxFileSize = maxFileSize;
    }

    /**
     * @param imageBytes ảnh bài làm (có thể null nếu học sinh chỉ nhập văn bản)
     * @param textAnswer lời giải dạng văn bản (có thể null)
     * @throws IllegalArgumentException dữ liệu đầu vào không hợp lệ
     * @throws com.edututor.exception.AiServiceException khi AI không chấm được
     */
    public EssayOcrResponse gradeAndSave(int studentId, int questionId, byte[] imageBytes, String textAnswer) {
        boolean hasImage = imageBytes != null && imageBytes.length > 0;
        boolean hasText = textAnswer != null && !textAnswer.isBlank();
        if (!hasImage && !hasText) {
            throw new IllegalArgumentException("Vui lòng tải ảnh bài làm hoặc nhập lời giải.");
        }
        if (hasText && textAnswer.length() > 20000) {
            throw new IllegalArgumentException("Lời giải nhập tay quá dài.");
        }

        Question question = questionRepository.findById(questionId).orElse(null);
        if (question == null || question.getQuestionType() != QuestionType.ESSAY) {
            throw new IllegalArgumentException("Câu hỏi tự luận không tồn tại.");
        }

        // VAL-18: ≤ 5MB, JPG / PNG / WebP theo magic bytes, đọc được và ≤ 4096×4096 px
        ImageValidator.ImageInfo image = null;
        if (hasImage) {
            if (imageBytes.length > maxFileSize) {
                throw new IllegalArgumentException("Ảnh vượt quá dung lượng tối đa 5MB.");
            }
            image = ImageValidator.validate(imageBytes);
        }
        // BR-13: dùng chung hạn mức học sinh với gia sư; chỉ trừ lượt sau khi dữ liệu và ảnh đã hợp lệ (UC-OCR-01)
        rateLimiter.check(studentId, RateLimiter.Action.STUDENT_AI);

        // System instruction = GRADING_PROMPT (đề + đáp án tham khảo) + cấu trúc JSON + phần chốt cố định
        String reference = question.getExplanationLatex();
        String system = PromptBuilder.system(config.getPrompt(AiConfigService.KEY_GRADING_PROMPT), Map.of(
                "QUESTION", question.getContent(),
                "REFERENCE", (reference == null || reference.isBlank()) ? NO_REFERENCE : reference), JSON_FORMAT);

        // Payload đa phương thức: [Ảnh Base64] + [bài làm học sinh]
        StringBuilder prompt = new StringBuilder("Hãy chấm bài làm của học sinh.");
        if (hasText) {
            prompt.append("\n\nLỜI GIẢI HỌC SINH NHẬP BẰNG VĂN BẢN:\n").append(textAnswer.trim());
        }
        List<Part> parts = new ArrayList<>();
        if (hasImage) {
            parts.add(Part.image(image.mimeType(), Base64.getEncoder().encodeToString(imageBytes)));
            prompt.append("\n\n(Ảnh đính kèm là bài làm viết tay của học sinh.)");
        }
        parts.add(Part.text(prompt.toString()));

        EssayGradingResult result = gemini.generateJson(system, List.of(new Turn("user", parts)),
                hasImage, config.getGradingTemperature(), 4096, node -> {
                    try {
                        EssayGradingResult r = mapper.treeToValue(node, EssayGradingResult.class);
                        if (r.score() == null || r.score().isNaN()) {
                            throw new IllegalArgumentException("Thiếu điểm số.");
                        }
                        return r;
                    } catch (JsonProcessingException e) {
                        throw new IllegalArgumentException("Sai schema: " + e.getOriginalMessage(), e);
                    }
                });

        // TC-OCR-03: không đọc được bài → 422, KHÔNG lưu ảnh, KHÔNG lưu điểm
        if (Boolean.FALSE.equals(result.legible())) {
            throw new AiServiceException(ILLEGIBLE_MESSAGE, null, 422);
        }

        double score = ScoreUtil.roundQuarter(result.score());
        String extracted = HtmlSanitizer.clean(nullToEmpty(result.extractedText()));
        String feedback = HtmlSanitizer.clean(nullToEmpty(result.detailedFeedback()));
        String correction = HtmlSanitizer.clean(nullToEmpty(result.suggestedCorrection()));
        List<EssayGradingResult.ErrorItem> errors = new ArrayList<>();
        if (result.errors() != null) {
            for (EssayGradingResult.ErrorItem e : result.errors()) {
                if (e != null && !nullToEmpty(e.description()).isEmpty()) {
                    errors.add(new EssayGradingResult.ErrorItem(HtmlSanitizer.clean(nullToEmpty(e.location())),
                            HtmlSanitizer.clean(nullToEmpty(e.description()))));
                }
            }
        }

        // Chỉ lưu tệp sau khi AI đã đọc được bài; nếu ghi CSDL lỗi thì xóa tệp vừa lưu
        String imageUrl = hasImage ? storage.storeEssay(studentId, imageBytes, image.extension()) : null;
        String answer = !extracted.isBlank() ? extracted : (hasText ? textAnswer.trim() : "");
        int id;
        try {
            id = submissionService.saveEssaySubmission(studentId, questionId, answer, imageUrl, score,
                    aiFeedbackText(feedback, errors), correction);
        } catch (RuntimeException e) {
            storage.deleteQuietly(imageUrl);
            throw e;
        }
        return new EssayOcrResponse(id, extracted, score, feedback, errors, correction, imageUrl, "AI_GRADED",
                !errors.isEmpty() || score < 10.0);
    }

    /** ai_feedback = nhận xét chung + danh sách lỗi sai (UC-OCR-02 bước 6). */
    private static String aiFeedbackText(String feedback, List<EssayGradingResult.ErrorItem> errors) {
        StringBuilder sb = new StringBuilder(feedback);
        if (!errors.isEmpty()) {
            sb.append(sb.length() > 0 ? "\n\n" : "").append("Các lỗi sai:");
            for (EssayGradingResult.ErrorItem e : errors) {
                sb.append("\n- ");
                if (!e.location().isEmpty()) {
                    sb.append(e.location()).append(": ");
                }
                sb.append(e.description());
            }
        }
        return sb.toString();
    }

    private static String nullToEmpty(String s) {
        return s == null ? "" : s.trim();
    }
}
