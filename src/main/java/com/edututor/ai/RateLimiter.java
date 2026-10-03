package com.edututor.ai;

import com.edututor.exception.AiRateLimitException;
import com.edututor.service.AiConfigService;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayDeque;
import java.util.Deque;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.function.ToIntFunction;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * Giới hạn lượt gọi AI theo (userId, nhóm hành động), cửa sổ trượt 60 phút (FRS 4.5, BR-13, NFR-06).
 * Hạn mức đọc từ ai_configs mỗi lần kiểm tra nên Admin đổi là có hiệu lực ngay. Bộ đếm nằm trong RAM
 * (reset khi khởi động lại) nên KHÔNG dùng làm số liệu thống kê. Test kết nối của Admin không đi qua lớp này.
 */
@Component
public class RateLimiter {

    /** Nhóm hành động: học sinh dùng chung một hạn mức cho gia sư + chấm ảnh; giáo viên có hạn mức sinh đề riêng. */
    public enum Action {
        STUDENT_AI, QUIZ_GEN
    }

    private record RateKey(int userId, Action action) {
    }

    static final Duration WINDOW = Duration.ofHours(1);

    private final Map<RateKey, Deque<Instant>> calls = new ConcurrentHashMap<>();
    private final ToIntFunction<Action> limits;
    private final Clock clock;

    @Autowired
    public RateLimiter(AiConfigService config) {
        this(a -> a == Action.QUIZ_GEN ? config.getTeacherRateLimit() : config.getStudentRateLimit(),
                Clock.systemUTC());
    }

    /** Dùng cho kiểm thử đơn vị: hạn mức và đồng hồ tự cung cấp. */
    public RateLimiter(ToIntFunction<Action> limits, Clock clock) {
        this.limits = limits;
        this.clock = clock;
    }

    /**
     * Ghi nhận một lượt gọi AI nếu còn hạn mức.
     *
     * @throws AiRateLimitException khi đã dùng hết lượt trong 60 phút gần nhất
     */
    public void check(int userId, Action action) {
        Instant now = clock.instant();
        Instant windowStart = now.minus(WINDOW);
        int limit = limits.applyAsInt(action);
        Deque<Instant> deque = calls.computeIfAbsent(new RateKey(userId, action), k -> new ArrayDeque<>());
        synchronized (deque) {
            while (!deque.isEmpty() && !deque.peekFirst().isAfter(windowStart)) {
                deque.pollFirst();
            }
            if (deque.size() >= limit) {
                // Lượt cũ nhất hết hạn sau (cũ nhất + 60 phút): làm tròn lên theo phút, tối thiểu 1
                long seconds = Duration.between(now, deque.peekFirst().plus(WINDOW)).getSeconds();
                throw new AiRateLimitException(Math.max(1, (seconds + 59) / 60));
            }
            deque.addLast(now);
        }
    }
}
