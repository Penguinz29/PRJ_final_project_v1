package service;

import ai.DocumentParts;
import ai.GeminiClient.Part;
import ai.GeminiClient.Turn;
import ai.PromptBuilder;
import dto.api.QuestionExtractResult;
import util.DocumentValidator;
import util.HtmlSanitizer;
import util.LatexNormalizer;
import com.fasterxml.jackson.databind.JsonNode;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Service;

/**
 * Nhập câu hỏi từ tệp (PDF / Word / ảnh): AI đọc đề bài, và đọc đáp án nếu giáo viên tải tệp đáp án;
 * không có tệp đáp án thì AI tự giải. Kết quả CHƯA ghi CSDL, giáo viên xem lại trong form rồi mới lưu.
 */
@Service
public class QuestionImportService {

    private static final String BASE = String.join("\n",
            "Bạn là trợ lý số hóa đề Toán THPT (chương trình GDPT 2018, lớp 12).",
            "Người dùng gửi TỆP ĐỀ BÀI (và có thể có TỆP ĐÁP ÁN). Nếu tệp chứa nhiều câu, chỉ lấy CÂU ĐẦU TIÊN.",
            "- Chép NGUYÊN VĂN đề bài, không tự sửa số liệu. Mọi công thức toán PHẢI nằm trong $...$ (LaTeX), "
                    + "ví dụ $\\frac{x+1}{x-2}$; không để lệnh LaTeX trần ngoài dấu $.",
            "- GIỮ NGUYÊN CÁCH XUỐNG DÒNG của tệp: mỗi ý / mỗi dòng riêng (a), b), c), 1., 2., các dòng của giả thiết...) "
                    + "nằm trên một dòng riêng, ngăn cách bằng đúng một ký tự xuống dòng (\\n trong chuỗi JSON); "
                    + "không gộp thành một đoạn. Đoạn cách nhau bởi dòng trống thì giữ nguyên dòng trống.",
            "- Nếu có TỆP ĐÁP ÁN: lấy đáp án và lời giải từ tệp đó, answerSource = \"FILE\".",
            "- Nếu KHÔNG có tệp đáp án (hoặc tệp đáp án không có lời giải): tự giải cẩn thận từng bước, "
                    + "answerSource = \"AI\".");

    private static final String MCQ_FORMAT = String.join("\n",
            "Đây là câu TRẮC NGHIỆM 4 phương án. Trả về MỘT JSON object:",
            "{\"content\": string (đề bài, không kèm các phương án), "
                    + "\"options\": [{\"letter\": \"A\", \"content\": string}, ... đủ 4 phần tử A-D], "
                    + "\"correctOption\": \"A\"|\"B\"|\"C\"|\"D\", "
                    + "\"explanation\": string (lời giải chi tiết), \"answerSource\": \"FILE\"|\"AI\"}");

    private static final String ESSAY_FORMAT = String.join("\n",
            "Đây là câu TỰ LUẬN. Trả về MỘT JSON object:",
            "{\"content\": string (đề bài), \"explanation\": string (lời giải mẫu chi tiết từng bước), "
                    + "\"answerSource\": \"FILE\"|\"AI\"}");

    private final GeminiService gemini;
    private final AiConfigService config;

    public QuestionImportService(GeminiService gemini, AiConfigService config) {
        this.gemini = gemini;
        this.config = config;
    }

    /**
     * @param questionFile bắt buộc
     * @param answerFile   tùy chọn (null nếu giáo viên không tải lên)
     * @param type         MCQ hoặc ESSAY
     */
    public QuestionExtractResult extract(byte[] questionFile, byte[] answerFile, String type) {
        boolean mcq = "MCQ".equals(type);
        if (!mcq && !"ESSAY".equals(type)) {
            throw new IllegalArgumentException("Loại câu hỏi không hợp lệ.");
        }
        DocumentValidator.Info q = DocumentValidator.validate(questionFile);
        boolean hasAnswer = answerFile != null && answerFile.length > 0;
        DocumentValidator.Info a = hasAnswer ? DocumentValidator.validate(answerFile) : null;

        List<Part> parts = new ArrayList<>();
        parts.add(Part.text("=== TỆP ĐỀ BÀI ==="));
        parts.addAll(DocumentParts.of(q, questionFile));
        if (hasAnswer) {
            parts.add(Part.text("=== TỆP ĐÁP ÁN ==="));
            parts.addAll(DocumentParts.of(a, answerFile));
        } else {
            parts.add(Part.text("=== KHÔNG CÓ TỆP ĐÁP ÁN: hãy tự giải. ==="));
        }

        String system = PromptBuilder.system(BASE, Map.of(), mcq ? MCQ_FORMAT : ESSAY_FORMAT);
        boolean vision = q.kind() != DocumentValidator.Kind.DOCX || !q.images().isEmpty()
                || (a != null && (a.kind() != DocumentValidator.Kind.DOCX || !a.images().isEmpty()));
        int minTokens = mcq ? 3072 : 4096;
        return gemini.generateJson(system, List.of(new Turn("user", parts)), vision, config.getQuizTemperature(),
                minTokens, node -> parse(node, mcq, hasAnswer));
    }

    private QuestionExtractResult parse(JsonNode root, boolean mcq, boolean hasAnswer) {
        String content = clean(root.path("content").asText(""));
        if (content.isBlank()) {
            throw new IllegalArgumentException("Không đọc được đề bài.");
        }
        String explanation = clean(root.path("explanation").asText(""));
        // Giáo viên không tải đáp án nhưng AI vẫn ghi FILE: luôn tin vào việc có tệp hay không
        String source = hasAnswer && "FILE".equalsIgnoreCase(root.path("answerSource").asText("")) ? "FILE" : "AI";
        if (!mcq) {
            return new QuestionExtractResult("ESSAY", content, Map.of(), "", explanation, source);
        }

        Map<String, String> options = new LinkedHashMap<>();
        for (JsonNode o : root.path("options")) {
            String letter = o.path("letter").asText("").trim().toUpperCase();
            String text = clean(o.path("content").asText(""));
            if (letter.matches("[A-D]") && !text.isBlank()) {
                options.put(letter, text);
            }
        }
        for (String letter : List.of("A", "B", "C", "D")) {
            if (!options.containsKey(letter)) {
                throw new IllegalArgumentException("Thiếu phương án " + letter + ".");
            }
        }
        Map<String, String> sorted = new LinkedHashMap<>();
        for (String letter : List.of("A", "B", "C", "D")) {
            sorted.put(letter, options.get(letter));
        }
        String correct = root.path("correctOption").asText("").trim().toUpperCase();
        if (!correct.matches("[A-D]")) {
            throw new IllegalArgumentException("Không xác định được đáp án đúng.");
        }
        return new QuestionExtractResult("MCQ", content, sorted, correct, explanation, source);
    }

    private static String clean(String s) {
        return HtmlSanitizer.clean(LatexNormalizer.wrapBareMath(LatexNormalizer.normalize(s.trim())));
    }
}
