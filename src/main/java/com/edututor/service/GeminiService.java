package com.edututor.service;

import com.edututor.ai.AiJsonParser;
import com.edututor.ai.GeminiClient;
import com.edututor.ai.GeminiClient.Settings;
import com.edututor.ai.GeminiClient.Turn;
import com.edututor.exception.AiParseException;
import com.edututor.exception.AiServiceException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.IOException;
import java.time.Duration;
import java.util.List;
import java.util.function.Function;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

/**
 * Cổng gọi AI dùng chung: nạp cấu hình từ CSDL (AiConfigService), gọi Gemini và tự động thử lại tối đa 3 lần
 * khi JSON trả về sai cú pháp / sai schema hoặc khi gặp lỗi tạm thời (NFR-04, FRS 8.2).
 */
@Service
public class GeminiService {

    private static final Logger log = LoggerFactory.getLogger(GeminiService.class);

    /** Tổng thời gian tối đa cho một yêu cầu AI kể cả các lần thử lại (FRS 4.3). */
    private static final Duration TOTAL_BUDGET = Duration.ofSeconds(90);
    /** Không bắt đầu lần thử lại nếu còn ít hơn số giây này. */
    private static final long MIN_ATTEMPT_SECONDS = 5;

    private final GeminiClient client;
    private final AiConfigService config;
    private final ObjectMapper mapper;
    private final int maxAttempts;

    public GeminiService(GeminiClient client, AiConfigService config, ObjectMapper mapper,
                         @Value("${gemini.maxParseRetries:3}") int maxAttempts) {
        this.client = client;
        this.config = config;
        this.mapper = mapper;
        this.maxAttempts = Math.max(1, maxAttempts);
    }

    /**
     * Gọi Gemini ở chế độ JSON và chuyển kết quả bằng {@code parser}.
     *
     * @param vision      true: dùng VISION_MODEL (đa phương thức) và thời gian chờ gấp đôi, false: DEFAULT_MODEL
     * @param temperature nhiệt độ của chức năng gọi (TUTOR_/QUIZ_/GRADING_TEMPERATURE)
     * @param minTokens số token đầu ra tối thiểu (lấy max với MAX_OUTPUT_TOKENS trong CSDL)
     * @param parser    chuyển JsonNode sang kết quả; ném exception nếu sai schema để kích hoạt thử lại
     */
    public <T> T generateJson(String systemInstruction, List<Turn> turns, boolean vision, double temperature,
                              int minTokens, Function<JsonNode, T> parser) {
        int timeout = config.getTimeoutSeconds();
        Settings settings = new Settings(
                config.getApiKey(),
                vision ? config.getVisionModel() : config.getDefaultModel(),
                temperature,
                Math.max(config.getMaxOutputTokens(), minTokens),
                vision ? timeout * 2 : timeout);

        // FRS 4.3: tổng thời gian chờ của một yêu cầu <= 90 giây (nhỏ hơn timeout async 100 giây của WebConfig),
        // để luồng AI không còn chạy và ghi CSDL sau khi client đã nhận lỗi.
        long deadline = System.nanoTime() + TOTAL_BUDGET.toNanos();
        Exception last = null;
        for (int attempt = 1; attempt <= maxAttempts; attempt++) {
            long remainingSeconds = (deadline - System.nanoTime()) / 1_000_000_000L;
            if (attempt > 1 && remainingSeconds < MIN_ATTEMPT_SECONDS) {
                log.warn("Hết ngân sách thời gian {} giây, dừng thử lại ở lần {}/{}", TOTAL_BUDGET.toSeconds(),
                        attempt - 1, maxAttempts);
                break;
            }
            Settings attemptSettings = new Settings(settings.apiKey(), settings.model(), settings.temperature(),
                    settings.maxOutputTokens(),
                    (int) Math.max(1, Math.min(settings.timeoutSeconds(), remainingSeconds)));
            try {
                String raw = client.generate(attemptSettings, systemInstruction, turns, true);
                return parser.apply(mapper.readTree(AiJsonParser.extractJson(raw)));
            } catch (AiServiceException e) {
                // Chưa cấu hình / HTTP 4xx (trừ 429): thử lại cũng vô ích
                if (!e.isTransient()) {
                    throw e;
                }
                last = e;
                log.warn("Gọi Gemini lần {}/{} thất bại: {}", attempt, maxAttempts, e.getMessage());
            } catch (IOException | RuntimeException e) {
                // JSON sai cú pháp hoặc sai schema
                last = e;
                log.warn("JSON từ Gemini không hợp lệ (lần {}/{}): {}", attempt, maxAttempts, e.getMessage());
            }
            if (attempt < maxAttempts) {
                sleep(700L * attempt);
            }
        }
        if (last instanceof AiServiceException ase) {
            throw ase;
        }
        throw new AiParseException("AI không trả về dữ liệu đúng định dạng sau " + maxAttempts + " lần thử. "
                + "Vui lòng thử lại.", last);
    }

    private void sleep(long ms) {
        try {
            Thread.sleep(ms);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}
