package com.mathtutor.service;

import com.mathtutor.dao.AiConfigDAO;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

/**
 * FR-TEA-03: Dịch vụ sinh đề thi trắc nghiệm thông minh qua Gemini AI
 * Bám sát chuẩn kiến thức GDPT 2018 Toán 12
 */
public class AiExamService {

    private AiConfigDAO aiConfigDAO = new AiConfigDAO();

    /**
     * Sinh danh sách câu hỏi trắc nghiệm dưới dạng JSON Array
     *
     * @param topicName Tên chuyên đề
     * @param lessonName Tên bài học
     * @param level Mức độ (1: Nhận biết, 2: Vận dụng, 3: Vận dụng cao)
     * @param count Số lượng câu hỏi cần sinh (3 - 10)
     * @return Chuỗi JSON Array chứa danh sách câu hỏi
     */
    public String generateQuestions(String topicName, String lessonName, int level, int count) throws Exception {
        String apiKey = aiConfigDAO.getValue("GEMINI_API_KEY");
        String model = aiConfigDAO.getValue("DEFAULT_MODEL");

        if (apiKey == null || apiKey.trim().isEmpty()) {
            throw new IllegalStateException("Chưa cấu hình GEMINI_API_KEY trong hệ thống. Vui lòng vào trang Quản trị -> Cấu hình AI để cập nhật API Key.");
        }

        if (model == null || model.trim().isEmpty()) {
            model = "gemini-1.5-flash";
        }

        String levelDesc = (level == 1) ? "1 (Nhận biết/Thông hiểu - Dễ)"
                : (level == 2) ? "2 (Vận dụng - Trung bình)"
                : "3 (Vận dụng cao - Khó)";

        String prompt = buildPrompt(topicName, lessonName, levelDesc, level, count);

        // Cơ chế Retry tối đa 3 lần theo FRS 8.2 & NFR-04
        int maxRetries = 3;
        Exception lastException = null;

        for (int attempt = 1; attempt <= maxRetries; attempt++) {
            try {
                String rawResponse = callGeminiApi(apiKey, model, prompt);
                String extractedJson = extractJsonText(rawResponse);
                if (extractedJson != null && extractedJson.trim().startsWith("[") && extractedJson.trim().endsWith("]")) {
                    return extractedJson.trim();
                } else if (extractedJson != null && extractedJson.contains("[") && extractedJson.contains("]")) {
                    // Cắt lấy phần JSON array
                    int start = extractedJson.indexOf('[');
                    int end = extractedJson.lastIndexOf(']') + 1;
                    return extractedJson.substring(start, end);
                }
            } catch (Exception e) {
                lastException = e;
                if (attempt < maxRetries) {
                    try { Thread.sleep(1000L * attempt); } catch (InterruptedException ignored) {}
                }
            }
        }

        if (lastException != null) {
            throw lastException;
        }
        throw new IOException("Không nhận được định dạng JSON câu hỏi hợp lệ từ Gemini AI sau 3 lần thử.");
    }

    private String buildPrompt(String topicName, String lessonName, String levelDesc, int levelNum, int count) {
        return "Bạn là chuyên gia sư phạm Toán 12 theo Chương trình Giáo dục Phổ thông 2018 (GDPT 2018).\\n"
                + "Hãy tạo đúng " + count + " câu hỏi trắc nghiệm 4 lựa chọn (A, B, C, D) cho:\\n"
                + "- Chuyên đề: " + (topicName != null ? topicName : "Toán 12") + "\\n"
                + "- Bài học: " + (lessonName != null ? lessonName : "Kiến thức trọng tâm") + "\\n"
                + "- Mức độ: " + levelDesc + "\\n\\n"
                + "QUY ĐỊNH BẮT BUỘC:\\n"
                + "1. 100% công thức, ký hiệu toán học PHẢI được bao đóng trong cặp dấu $...$ (inline) hoặc $$...$$ (block) chuẩn KaTeX.\\n"
                + "2. Mỗi câu hỏi chỉ có DUY NHẤT 1 đáp án đúng trong 4 phương án.\\n"
                + "3. Cung cấp lời giải chi tiết, sư phạm, tường minh từng bước.\\n"
                + "4. Chỉ trả về DUY NHẤT một JSON Array tuân thủ đúng schema sau:\\n"
                + "[\\n"
                + "  {\\n"
                + "    \\\"content\\\": \\\"Nội dung đề bài có công thức $...$\\\",\\n"
                + "    \\\"level\\\": " + levelNum + ",\\n"
                + "    \\\"explanation\\\": \\\"Lời giải chi tiết ngắn gọn có công thức $...$\\\",\\n"
                + "    \\\"options\\\": [\\n"
                + "      {\\\"letter\\\": \\\"A\\\", \\\"content\\\": \\\"Phương án A\\\", \\\"isCorrect\\\": false},\\n"
                + "      {\\\"letter\\\": \\\"B\\\", \\\"content\\\": \\\"Phương án B\\\", \\\"isCorrect\\\": true},\\n"
                + "      {\\\"letter\\\": \\\"C\\\", \\\"content\\\": \\\"Phương án C\\\", \\\"isCorrect\\\": false},\\n"
                + "      {\\\"letter\\\": \\\"D\\\", \\\"content\\\": \\\"Phương án D\\\", \\\"isCorrect\\\": false}\\n"
                + "    ]\\n"
                + "  }\\n"
                + "]\\n"
                + "TUYỆT ĐỐI KHÔNG viết bất kỳ lời dẫn hay ký tự nào ngoài JSON Array.";
    }

    private String callGeminiApi(String apiKey, String model, String prompt) throws IOException {
        String endpoint = "https://generativelanguage.googleapis.com/v1beta/models/"
                + model + ":generateContent?key=" + apiKey;

        String payload = "{\"contents\":[{\"parts\":[{\"text\":\"" + prompt + "\"}]}],"
                + "\"generationConfig\":{\"response_mime_type\":\"application/json\",\"temperature\":0.2,\"maxOutputTokens\":4096}}";

        URL url = new URL(endpoint);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json;charset=UTF-8");
        conn.setConnectTimeout(15000); // 15 giây theo FRS 8.2 & NFR-02
        conn.setReadTimeout(25000);
        conn.setDoOutput(true);

        try (OutputStream os = conn.getOutputStream()) {
            os.write(payload.getBytes(StandardCharsets.UTF_8));
        }

        int statusCode = conn.getResponseCode();
        if (statusCode == 200) {
            try (InputStream is = conn.getInputStream()) {
                return new String(is.readAllBytes(), StandardCharsets.UTF_8);
            }
        } else {
            String errorMsg;
            try (InputStream es = conn.getErrorStream()) {
                errorMsg = (es != null) ? new String(es.readAllBytes(), StandardCharsets.UTF_8) : "HTTP Error " + statusCode;
            }
            throw new IOException("Gemini API Error (" + statusCode + "): " + errorMsg);
        }
    }

    /**
     * Trích xuất chuỗi text từ JSON response của Gemini
     */
    private String extractJsonText(String response) {
        if (response == null) return null;
        int textIdx = response.indexOf("\"text\":");
        if (textIdx == -1) return null;
        int firstQuote = response.indexOf("\"", textIdx + 7);
        if (firstQuote == -1) return null;

        StringBuilder sb = new StringBuilder();
        boolean escaped = false;
        for (int i = firstQuote + 1; i < response.length(); i++) {
            char c = response.charAt(i);
            if (escaped) {
                if (c == '"') sb.append('"');
                else if (c == '\\') sb.append('\\');
                else if (c == 'n') sb.append('\n');
                else if (c == 'r') sb.append('\r');
                else if (c == 't') sb.append('\t');
                else if (c == 'u' && i + 4 < response.length()) {
                    try {
                        String hex = response.substring(i + 1, i + 5);
                        sb.append((char) Integer.parseInt(hex, 16));
                        i += 4;
                    } catch (Exception ex) {
                        sb.append(c);
                    }
                } else {
                    sb.append(c);
                }
                escaped = false;
            } else if (c == '\\') {
                escaped = true;
            } else if (c == '"') {
                break;
            } else {
                sb.append(c);
            }
        }
        return sb.toString();
    }
}
