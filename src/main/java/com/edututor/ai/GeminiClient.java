package com.edututor.ai;

import com.edututor.exception.AiServiceException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.net.http.HttpTimeoutException;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.List;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * Client HTTP thuần cho Google Gemini REST API (generateContent).
 * Không biết gì về cấu hình trong CSDL: mọi tham số được truyền vào qua {@link Settings}.
 * API key gửi qua header x-goog-api-key (không đặt trên URL để không lọt vào log).
 */
@Component
public class GeminiClient {

    /** Tham số một lần gọi. */
    public record Settings(String apiKey, String model, double temperature, int maxOutputTokens) {
    }

    /** Một phần nội dung: văn bản hoặc ảnh inline (Base64). */
    public record Part(String text, String mimeType, String base64Data) {
        public static Part text(String text) {
            return new Part(text, null, null);
        }

        public static Part image(String mimeType, String base64Data) {
            return new Part(null, mimeType, base64Data);
        }
    }

    /** Một lượt hội thoại. role = "user" hoặc "model". */
    public record Turn(String role, List<Part> parts) {
        public static Turn user(String text) {
            return new Turn("user", List.of(Part.text(text)));
        }

        public static Turn model(String text) {
            return new Turn("model", List.of(Part.text(text)));
        }
    }

    private final ObjectMapper mapper;
    private final HttpClient http;
    private final String baseUrl;
    private final Duration requestTimeout;

    public GeminiClient(ObjectMapper mapper,
                        @Value("${gemini.baseUrl}") String baseUrl,
                        @Value("${gemini.connectTimeoutSeconds:15}") int connectTimeoutSeconds,
                        @Value("${gemini.requestTimeoutSeconds:60}") int requestTimeoutSeconds) {
        this.mapper = mapper;
        this.baseUrl = baseUrl.endsWith("/") ? baseUrl.substring(0, baseUrl.length() - 1) : baseUrl;
        this.requestTimeout = Duration.ofSeconds(requestTimeoutSeconds);
        // FRS 8.2: connection timeout tối đa 15 giây
        this.http = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(Math.min(connectTimeoutSeconds, 15)))
                .build();
    }

    /**
     * Gọi generateContent và trả về văn bản của ứng viên đầu tiên.
     *
     * @param json true: ép Gemini trả JSON bằng response_mime_type = application/json
     */
    public String generate(Settings s, String systemInstruction, List<Turn> turns, boolean json) {
        if (s.apiKey() == null || s.apiKey().isBlank()) {
            throw new AiServiceException("Chưa cấu hình GEMINI_API_KEY. Vui lòng vào Quản trị > Cấu hình AI để cập nhật.");
        }
        String body = buildBody(s, systemInstruction, turns, json);
        JsonNode root = post(s.apiKey(), s.model(), body);

        JsonNode candidate = root.path("candidates").path(0);
        StringBuilder sb = new StringBuilder();
        for (JsonNode part : candidate.path("content").path("parts")) {
            if (part.hasNonNull("text")) {
                sb.append(part.get("text").asText());
            }
        }
        if (sb.length() == 0) {
            String reason = candidate.path("finishReason").asText(root.path("promptFeedback").path("blockReason").asText("UNKNOWN"));
            throw new AiServiceException("Gemini không trả về nội dung (lý do: " + reason + ").");
        }
        return sb.toString();
    }

    /** FR-ADM-02: gửi prompt "Ping"; ném {@link AiServiceException} nếu không thành công. */
    public void ping(String apiKey, String model) {
        ObjectNode body = mapper.createObjectNode();
        ArrayNode contents = body.putArray("contents");
        contents.addObject().putArray("parts").addObject().put("text", "Ping. Reply with: Pong");
        body.putObject("generationConfig").put("maxOutputTokens", 50);
        try {
            post(apiKey, model, mapper.writeValueAsString(body));
        } catch (IOException e) {
            throw new AiServiceException("Không tạo được yêu cầu ping: " + e.getMessage(), e);
        }
    }

    private String buildBody(Settings s, String systemInstruction, List<Turn> turns, boolean json) {
        ObjectNode root = mapper.createObjectNode();
        if (systemInstruction != null && !systemInstruction.isBlank()) {
            root.putObject("system_instruction").putArray("parts").addObject().put("text", systemInstruction);
        }
        ArrayNode contents = root.putArray("contents");
        for (Turn t : turns) {
            ObjectNode c = contents.addObject();
            c.put("role", t.role());
            ArrayNode parts = c.putArray("parts");
            for (Part p : t.parts()) {
                ObjectNode part = parts.addObject();
                if (p.text() != null) {
                    part.put("text", p.text());
                } else {
                    ObjectNode inline = part.putObject("inline_data");
                    inline.put("mime_type", p.mimeType());
                    inline.put("data", p.base64Data());
                }
            }
        }
        ObjectNode gen = root.putObject("generationConfig");
        gen.put("temperature", s.temperature());
        gen.put("maxOutputTokens", s.maxOutputTokens());
        if (json) {
            gen.put("response_mime_type", "application/json");
        }
        try {
            return mapper.writeValueAsString(root);
        } catch (IOException e) {
            throw new AiServiceException("Không tạo được yêu cầu gửi Gemini: " + e.getMessage(), e);
        }
    }

    private JsonNode post(String apiKey, String model, String body) {
        if (model == null || model.isBlank()) {
            throw new AiServiceException("Chưa cấu hình model Gemini. Vui lòng vào Quản trị > Cấu hình AI để cập nhật.");
        }
        String m = model.trim();
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(baseUrl + "/models/" + m + ":generateContent"))
                .timeout(requestTimeout)
                .header("Content-Type", "application/json; charset=UTF-8")
                .header("x-goog-api-key", apiKey)
                .POST(HttpRequest.BodyPublishers.ofString(body, StandardCharsets.UTF_8))
                .build();
        try {
            HttpResponse<String> resp = http.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
            if (resp.statusCode() == 200) {
                return mapper.readTree(resp.body());
            }
            throw new AiServiceException("Gemini API lỗi HTTP " + resp.statusCode() + ": "
                    + extractErrorMessage(resp.body()), null, resp.statusCode());
        } catch (HttpTimeoutException e) {
            throw new AiServiceException("Gemini API không phản hồi kịp thời gian cho phép.", e, 504);
        } catch (IOException e) {
            throw new AiServiceException("Lỗi kết nối tới Gemini API: " + e.getMessage(), e, 502);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new AiServiceException("Yêu cầu tới Gemini API bị gián đoạn.", e);
        }
    }

    private String extractErrorMessage(String body) {
        try {
            String msg = mapper.readTree(body).path("error").path("message").asText("");
            if (!msg.isEmpty()) {
                return msg.length() > 300 ? msg.substring(0, 300) + "..." : msg;
            }
        } catch (IOException ignored) {
            // thân phản hồi không phải JSON
        }
        String raw = body == null ? "" : body.replaceAll("\\s+", " ");
        return raw.length() > 300 ? raw.substring(0, 300) + "..." : raw;
    }
}
