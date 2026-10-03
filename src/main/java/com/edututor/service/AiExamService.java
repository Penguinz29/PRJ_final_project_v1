package com.edututor.service;

import com.edututor.ai.GeminiClient.Turn;
import com.edututor.ai.PromptBuilder;
import com.edututor.dto.GenerateQuestionsRequest;
import com.edututor.dto.QuestionGenerationDTO;
import com.edututor.dto.LessonView;
import com.edututor.util.HtmlSanitizer;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

/**
 * UC-TEA-02 / FR-TEA-03: sinh đề trắc nghiệm bằng Gemini theo chương trình GDPT 2018 Toán 12.
 * Cấu hình (API key, model...) đọc từ bảng AiConfigs qua GeminiService.
 */
@Service
public class AiExamService {

    private static final Logger log = LoggerFactory.getLogger(AiExamService.class);

    public static final int MAX_QUESTIONS = 10;

    /** Cấu trúc phản hồi do ứng dụng quy định; phần nội dung sư phạm đọc từ QUIZ_GEN_PROMPT. */
    private static final String JSON_FORMAT = String.join("\n",
            "CẤU TRÚC PHẢN HỒI BẮT BUỘC: trả về MỘT JSON Array, mỗi phần tử có schema:",
            "{\"content\": string, \"level\": 1|2|3, \"explanation\": string, \"options\": "
                    + "[{\"letter\": \"A\", \"content\": string, \"isCorrect\": boolean}, ... đủ 4 phần tử A-D]}");

    private final GeminiService gemini;
    private final LessonService lessonService;
    private final AiConfigService config;
    private final ObjectMapper mapper;

    public AiExamService(GeminiService gemini, LessonService lessonService, AiConfigService config,
                         ObjectMapper mapper) {
        this.gemini = gemini;
        this.lessonService = lessonService;
        this.config = config;
        this.mapper = mapper;
    }

    /**
     * Sinh danh sách câu hỏi.
     *
     * @throws IllegalArgumentException tham số không hợp lệ
     * @throws com.edututor.exception.AiServiceException khi gọi AI thất bại
     */
    public Result generateQuestions(GenerateQuestionsRequest req) {
        // Tên chuyên đề / bài học luôn tra từ lessonId trong CSDL, không tin tên do client gửi
        LessonView lesson = lessonService.getLessonById(req.lessonId());
        if (lesson == null) {
            throw new IllegalArgumentException("Bài học không tồn tại.");
        }
        String lessonName = lesson.getTitle();
        String topicName = lesson.getTopicName();
        int level = parseLevel(req.difficultyLevel());
        int count = (req.count() == null) ? 3 : Math.min(MAX_QUESTIONS, Math.max(1, req.count()));

        String system = PromptBuilder.system(config.getPrompt(AiConfigService.KEY_QUIZ_PROMPT), Map.of(
                "COUNT", String.valueOf(count),
                "TOPIC", isBlank(topicName) ? "Toán 12" : topicName.trim(),
                "LESSON", isBlank(lessonName) ? "Kiến thức trọng tâm" : lessonName.trim(),
                "DIFFICULTY", describeLevel(level) + " (trường \"level\" = " + level + ")"), JSON_FORMAT);
        String request = "Hãy soạn đúng " + count + " câu hỏi trắc nghiệm theo yêu cầu.";

        // 700 token cho mỗi câu (kèm lời giải) để không bị cắt cụt JSON
        int minTokens = Math.min(8192, 700 * count + 512);
        List<QuestionGenerationDTO> questions = gemini.generateJson(system, List.of(Turn.user(request)), false,
                config.getQuizTemperature(), minTokens, node -> parse(node, level, count));
        String warning = questions.size() < count
                ? "AI chỉ sinh được " + questions.size() + "/" + count + " câu hợp lệ."
                : null;
        return new Result(questions, warning);
    }

    /** Kết quả sinh đề: các câu hợp lệ và cảnh báo (null nếu đủ số câu yêu cầu). */
    public record Result(List<QuestionGenerationDTO> questions, String warning) {
    }

    /**
     * UC-TEA-05 bước 7: kiểm tra từng câu phía server. Câu không hợp lệ hoặc trùng nội dung bị loại; chỉ khi không
     * còn câu nào mới ném lỗi để GeminiService thử lại. Số câu trả về không vượt quá {@code count}.
     */
    private List<QuestionGenerationDTO> parse(JsonNode root, int level, int count) {
        JsonNode array = root;
        if (root.isObject()) {
            array = root.has("questions") ? root.get("questions") : root.elements().next();
        }
        if (array == null || !array.isArray() || array.isEmpty()) {
            throw new IllegalArgumentException("Không có câu hỏi nào trong phản hồi.");
        }
        List<QuestionGenerationDTO> result = new ArrayList<>();
        Set<String> seen = new HashSet<>();
        for (JsonNode item : array) {
            if (result.size() >= count) {
                break;
            }
            try {
                QuestionGenerationDTO dto = validateAndClean(mapper.convertValue(item, QuestionGenerationDTO.class),
                        level);
                String key = dto.content().replaceAll("\\s+", " ").toLowerCase();
                if (seen.add(key)) {
                    result.add(dto);
                }
            } catch (IllegalArgumentException e) {
                log.warn("Loại một câu AI sinh không hợp lệ: {}", e.getMessage());
            }
        }
        if (result.isEmpty()) {
            throw new IllegalArgumentException("Không có câu hỏi hợp lệ trong phản hồi.");
        }
        return result;
    }

    private QuestionGenerationDTO validateAndClean(QuestionGenerationDTO dto, int level) {
        if (dto == null || dto.content() == null || dto.content().isBlank()) {
            throw new IllegalArgumentException("Câu hỏi thiếu nội dung.");
        }
        if (dto.explanation() == null || dto.explanation().isBlank()) {
            throw new IllegalArgumentException("Câu hỏi thiếu lời giải.");
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
        // Mức độ luôn là mức giáo viên yêu cầu, không để AI ghi đè
        return new QuestionGenerationDTO(HtmlSanitizer.clean(dto.content().trim()), level,
                HtmlSanitizer.clean(dto.explanation().trim()), sorted);
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
