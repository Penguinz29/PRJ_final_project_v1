package com.edututor.service;

import com.edututor.ai.GeminiClient.Part;
import com.edututor.ai.GeminiClient.Turn;
import com.edututor.dto.EssayGradingResult;
import com.edututor.dto.EssayOcrResponse;
import com.edututor.model.Question;
import com.edututor.model.QuestionType;
import com.edututor.repository.QuestionRepository;
import com.edututor.util.HtmlSanitizer;
import com.edututor.util.ScoreUtil;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

/**
 * UC-OCR-01 / FR-OCR-01..03: chấm bài tự luận viết tay bằng Gemini Vision.
 * Ảnh -> kiểm tra định dạng/dung lượng -> Base64 -> Gemini (VISION_MODEL) -> điểm thang 10 (làm tròn 0.25)
 * -> lưu Submissions (giáo viên có thể duyệt/chỉnh điểm sau).
 */
@Service
public class EssayGradingService {

    private static final String SYSTEM_INSTRUCTION = String.join("\n",
            "Bạn là giám khảo chấm thi THPT Quốc gia môn Toán (chương trình GDPT 2018).",
            "Nhiệm vụ:",
            "1. Nếu có ảnh: đọc chính xác nội dung toán học viết tay (OCR) và chuyển sang LaTeX trong $...$ "
                    + "-> trường extractedText. Nếu học sinh nhập văn bản: chép lại nguyên văn.",
            "2. Kiểm tra logic từng bước biến đổi, cận tích phân, dấu và các phép toán so với đề bài.",
            "3. Chấm điểm theo thang 10.0, làm tròn đến 0.25.",
            "4. detailedFeedback: nêu rõ VỊ TRÍ sai sót (bước/dòng nào, sai gì) và điểm đã làm tốt.",
            "5. suggestedCorrection: lời giải đúng, đầy đủ, trình bày bằng LaTeX.",
            "6. Nếu ảnh không đọc được hoặc không phải bài giải toán: score = 0 và giải thích trong detailedFeedback.",
            "Mọi công thức đặt trong $...$ hoặc $$...$$ (KaTeX). Trả lời bằng tiếng Việt.",
            "Chỉ trả về MỘT JSON object, không markdown: "
                    + "{\"extractedText\": string, \"score\": number, \"detailedFeedback\": string, "
                    + "\"suggestedCorrection\": string}");

    private final GeminiService gemini;
    private final QuestionRepository questionRepository;
    private final SubmissionService submissionService;
    private final FileStorageService storage;
    private final ObjectMapper mapper;
    private final long maxFileSize;

    public EssayGradingService(GeminiService gemini, QuestionRepository questionRepository,
                               SubmissionService submissionService, FileStorageService storage,
                               ObjectMapper mapper, @Value("${app.upload.max-bytes:5242880}") long maxFileSize) {
        this.gemini = gemini;
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

        String mime = null;
        String ext = null;
        if (hasImage) {
            if (imageBytes.length > maxFileSize) {
                throw new IllegalArgumentException("Ảnh vượt quá dung lượng tối đa 5MB.");
            }
            if (isPng(imageBytes)) {
                mime = "image/png";
                ext = "png";
            } else if (isJpeg(imageBytes)) {
                mime = "image/jpeg";
                ext = "jpg";
            } else {
                throw new IllegalArgumentException("Chỉ chấp nhận ảnh định dạng PNG hoặc JPG.");
            }
        }

        // Payload đa phương thức: [Ảnh Base64] + [System prompt chấm thi + đề bài gốc]
        StringBuilder prompt = new StringBuilder("ĐỀ BÀI GỐC:\n").append(question.getContent());
        if (hasText) {
            prompt.append("\n\nLỜI GIẢI HỌC SINH NHẬP BẰNG VĂN BẢN:\n").append(textAnswer.trim());
        }
        List<Part> parts = new ArrayList<>();
        if (hasImage) {
            parts.add(Part.image(mime, Base64.getEncoder().encodeToString(imageBytes)));
            prompt.append("\n\n(Ảnh đính kèm là bài làm viết tay của học sinh.)");
        }
        parts.add(Part.text(prompt.toString()));

        EssayGradingResult result = gemini.generateJson(SYSTEM_INSTRUCTION, List.of(new Turn("user", parts)),
                hasImage, 4096, node -> {
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

        double score = ScoreUtil.roundQuarter(result.score());
        String extracted = HtmlSanitizer.clean(nullToEmpty(result.extractedText()));
        String feedback = HtmlSanitizer.clean(nullToEmpty(result.detailedFeedback()));
        String correction = HtmlSanitizer.clean(nullToEmpty(result.suggestedCorrection()));

        // Chỉ lưu tệp sau khi AI đã đọc được bài; nếu ghi CSDL lỗi thì xóa tệp vừa lưu
        String imageUrl = hasImage ? storage.store(imageBytes, ext) : null;
        String answer = !extracted.isBlank() ? extracted : (hasText ? textAnswer.trim() : "");
        String aiFeedback = correction.isBlank() ? feedback : feedback + "\n\nLời giải gợi ý:\n" + correction;
        int id;
        try {
            id = submissionService.saveEssaySubmission(studentId, questionId, answer, imageUrl, score, aiFeedback);
        } catch (RuntimeException e) {
            storage.deleteQuietly(imageUrl);
            throw e;
        }
        return new EssayOcrResponse(id, extracted, score, feedback, correction, imageUrl);
    }

    private static boolean isPng(byte[] b) {
        return b.length > 8 && (b[0] & 0xFF) == 0x89 && b[1] == 'P' && b[2] == 'N' && b[3] == 'G';
    }

    private static boolean isJpeg(byte[] b) {
        return b.length > 3 && (b[0] & 0xFF) == 0xFF && (b[1] & 0xFF) == 0xD8 && (b[2] & 0xFF) == 0xFF;
    }

    private static String nullToEmpty(String s) {
        return s == null ? "" : s.trim();
    }
}
