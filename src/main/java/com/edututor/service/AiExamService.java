package com.edututor.service;

import com.edututor.ai.GeminiClient.Turn;
import com.edututor.dto.GenerateQuestionsRequest;
import com.edututor.dto.QuestionGenerationDTO;
import com.edututor.dto.LessonView;
import com.edututor.util.HtmlSanitizer;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import org.springframework.stereotype.Service;

/**
 * UC-TEA-02 / FR-TEA-03: sinh đề trắc nghiệm bằng Gemini theo chương trình GDPT 2018 Toán 12.
 * Cấu hình (API key, model...) đọc từ bảng AiConfigs qua GeminiService.
 */
@Service
public class AiExamService {

    public static final int MAX_QUESTIONS = 10;

    private static final String SYSTEM_INSTRUCTION = String.join("\n",
            "Bạn là chuyên gia sư phạm Toán lớp 12, soạn đề theo Chương trình Giáo dục Phổ thông 2018 (GDPT 2018).",
            "QUY ĐỊNH BẮT BUỘC:",
            "1. Nội dung bám sát chương trình Toán 12 GDPT 2018 và định dạng đề thi THPT Quốc gia.",
            "2. 100% công thức, ký hiệu toán học phải nằm trong cặp dấu LaTeX $...$ (inline) hoặc $$...$$ (khối), "
                    + "viết theo cú pháp KaTeX.",
            "3. Mỗi câu có đúng 4 phương án A, B, C, D và chỉ DUY NHẤT 1 phương án đúng.",
            "4. Có lời giải chi tiết, từng bước, tường minh.",
            "5. Chỉ trả về MỘT JSON Array hợp lệ, không thêm lời dẫn, không dùng markdown. Mỗi phần tử có schema:",
            "{\"content\": string, \"level\": 1|2|3, \"explanation\": string, \"options\": "
                    + "[{\"letter\": \"A\", \"content\": string, \"isCorrect\": boolean}, ... đủ 4 phần tử A-D]}");

    private final GeminiService gemini;
    private final LessonService lessonService;
    private final ObjectMapper mapper;

    public AiExamService(GeminiService gemini, LessonService lessonService, ObjectMapper mapper) {
        this.gemini = gemini;
        this.lessonService = lessonService;
        this.mapper = mapper;
    }

    /**
     * Sinh danh sách câu hỏi.
     *
     * @throws IllegalArgumentException tham số không hợp lệ
     * @throws com.edututor.exception.AiServiceException khi gọi AI thất bại
     */
    public List<QuestionGenerationDTO> generateQuestions(GenerateQuestionsRequest req) {
        // Tên chuyên đề / bài học luôn tra từ lessonId trong CSDL, không tin tên do client gửi
        LessonView lesson = lessonService.getLessonById(req.lessonId());
        if (lesson == null) {
            throw new IllegalArgumentException("Bài học không tồn tại.");
        }
        String lessonName = lesson.getTitle();
        String topicName = lesson.getTopicName();
        int level = parseLevel(req.difficultyLevel());
        int count = (req.count() == null) ? 3 : Math.min(MAX_QUESTIONS, Math.max(1, req.count()));

        String prompt = "Hãy tạo đúng " + count + " câu hỏi trắc nghiệm.\n"
                + "- Chuyên đề: " + (isBlank(topicName) ? "Toán 12" : topicName.trim()) + "\n"
                + "- Bài học: " + (isBlank(lessonName) ? "Kiến thức trọng tâm" : lessonName.trim()) + "\n"
                + "- Mức độ: " + describeLevel(level) + " (trường \"level\" = " + level + ")";

        // 700 token cho mỗi câu (kèm lời giải) để không bị cắt cụt JSON
        int minTokens = Math.min(8192, 700 * count + 512);
        return gemini.generateJson(SYSTEM_INSTRUCTION, List.of(Turn.user(prompt)), false, minTokens,
                node -> parse(node, level));
    }

    private List<QuestionGenerationDTO> parse(JsonNode root, int defaultLevel) {
        JsonNode array = root;
        if (root.isObject()) {
            array = root.has("questions") ? root.get("questions") : root.elements().next();
        }
        if (array == null || !array.isArray() || array.isEmpty()) {
            throw new IllegalArgumentException("Không có câu hỏi nào trong phản hồi.");
        }
        List<QuestionGenerationDTO> result = new ArrayList<>();
        for (JsonNode item : array) {
            QuestionGenerationDTO dto = mapper.convertValue(item, QuestionGenerationDTO.class);
            result.add(validateAndClean(dto, defaultLevel));
            if (result.size() >= MAX_QUESTIONS) {
                break;
            }
        }
        return result;
    }

    private QuestionGenerationDTO validateAndClean(QuestionGenerationDTO dto, int defaultLevel) {
        if (dto.content() == null || dto.content().isBlank()) {
            throw new IllegalArgumentException("Câu hỏi thiếu nội dung.");
        }
        if (dto.options() == null || dto.options().size() != 4) {
            throw new IllegalArgumentException("Câu hỏi phải có đúng 4 phương án.");
        }
        List<QuestionGenerationDTO.Option> sorted = new ArrayList<>();
        int correct = 0;
        for (QuestionGenerationDTO.Option o : dto.options()) {
            if (o.letter() == null || o.content() == null || o.content().isBlank()) {
                throw new IllegalArgumentException("Phương án thiếu ký hiệu hoặc nội dung.");
            }
            boolean ok = Boolean.TRUE.equals(o.isCorrect());
            if (ok) {
                correct++;
            }
            sorted.add(new QuestionGenerationDTO.Option(o.letter().trim().toUpperCase(),
                    HtmlSanitizer.clean(o.content().trim()), ok));
        }
        sorted.sort(Comparator.comparing(QuestionGenerationDTO.Option::letter));
        String letters = sorted.stream().map(QuestionGenerationDTO.Option::letter).reduce("", String::concat);
        if (!"ABCD".equals(letters) || correct != 1) {
            throw new IllegalArgumentException("Phương án phải là A-B-C-D và có đúng một đáp án đúng.");
        }
        Integer lv = dto.level();
        int level = (lv != null && lv >= 1 && lv <= 3) ? lv : defaultLevel;
        return new QuestionGenerationDTO(HtmlSanitizer.clean(dto.content().trim()), level,
                HtmlSanitizer.clean(dto.explanation() == null ? "" : dto.explanation().trim()), sorted);
    }

    /** Chấp nhận 1|2|3 hoặc EASY|MEDIUM|HARD|ADVANCED; để trống nghĩa là mức 1. */
    private int parseLevel(String raw) {
        if (raw == null || raw.isBlank()) {
            return 1;
        }
        String v = raw.trim().toUpperCase();
        switch (v) {
            case "1": case "EASY":
                return 1;
            case "2": case "MEDIUM":
                return 2;
            case "3": case "HARD": case "ADVANCED":
                return 3;
            default:
                throw new IllegalArgumentException("Mức độ phải là 1 (Dễ), 2 (Trung bình) hoặc 3 (Khó).");
        }
    }

    private String describeLevel(int level) {
        return switch (level) {
            case 1 -> "1 - Nhận biết/Thông hiểu (Dễ)";
            case 2 -> "2 - Vận dụng (Trung bình)";
            default -> "3 - Vận dụng cao (Khó)";
        };
    }

    private boolean isBlank(String s) {
        return s == null || s.isBlank();
    }
}
