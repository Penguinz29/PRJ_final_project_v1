package com.edututor;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.edututor.ai.AiJsonParser;
import com.edututor.ai.PromptBuilder;
import com.edututor.ai.RateLimiter;
import com.edututor.config.MessageSourceMessageInterpolator;
import com.edututor.dto.ApiResponse;
import com.edututor.dto.QuestionGenerationDTO;
import com.edututor.dto.QuizAnswerResponse;
import com.edututor.dto.RegisterForm;
import com.edututor.dto.SessionUser;
import com.edututor.dto.TutorAiResult;
import com.edututor.dto.TutorStepResponse;
import com.edututor.service.AiTutorService;
import com.edututor.exception.AiRateLimitException;
import com.edututor.interceptor.AuthInterceptor;
import com.edututor.interceptor.CsrfInterceptor;
import com.edututor.repository.UserRepository;
import com.edututor.util.HtmlSanitizer;
import com.edututor.util.ImageValidator;
import com.edututor.util.Pager;
import com.edututor.util.ScoreUtil;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.lang.reflect.Proxy;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;
import org.hibernate.validator.messageinterpolation.ParameterMessageInterpolator;
import org.junit.jupiter.api.Test;
import org.springframework.context.support.ReloadableResourceBundleMessageSource;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.validation.beanvalidation.LocalValidatorFactoryBean;

/** Kiểm thử đơn vị: không cần SQL Server, không cần mạng. Chạy trong {@code mvn package}. */
class UnitTests {

    private final ObjectMapper mapper = new ObjectMapper();

    // ---------- AiJsonParser ----------

    @Test
    void extractJsonStripsMarkdownFenceAndChatter() {
        assertEquals("[{\"a\":1}]", AiJsonParser.extractJson("```json\n[{\"a\":1}]\n```"));
        assertEquals("{\"a\":1}", AiJsonParser.extractJson("Đây là kết quả: {\"a\":1} cảm ơn"));
        assertEquals("[1,2]", AiJsonParser.extractJson("  [1,2]  "));
    }

    /** Giá trị chuỗi "k" sau khi vá rồi parse JSON thật bằng Jackson. */
    private String repairedValue(String rawJson) throws Exception {
        return mapper.readTree(AiJsonParser.repairLatexEscapes(rawJson)).get("k").asText();
    }

    @Test
    void repairLatexEscapesFixesInvalidEscapes() throws Exception {
        // \L, \s, \( không phải escape JSON: trước khi vá sẽ ném "Unrecognized character escape"
        assertEquals("a \\Leftrightarrow b", repairedValue("{\"k\":\"a \\Leftrightarrow b\"}"));
        assertEquals("\\sqrt{2} \\(x\\)", repairedValue("{\"k\":\"\\sqrt{2} \\(x\\)\"}"));
    }

    @Test
    void repairLatexEscapesKeepsLatexThatLooksLikeJsonEscape() throws Exception {
        // \f \t \n \b \r là escape hợp lệ: không vá thì \frac thành form-feed, \times thành tab (hỏng âm thầm)
        assertEquals("\\frac{1}{2} \\times 3 \\neq 4 \\beta \\right)",
                repairedValue("{\"k\":\"\\frac{1}{2} \\times 3 \\neq 4 \\beta \\right)\"}"));
        assertEquals("\\text{abc} \\to \\theta", repairedValue("{\"k\":\"\\text{abc} \\to \\theta\"}"));
    }

    @Test
    void repairLatexEscapesLeavesValidJsonUntouched() throws Exception {
        assertEquals("dòng 1\ndòng 2\ttab \"q\" \\ / é",
                repairedValue("{\"k\":\"dòng 1\\ndòng 2\\ttab \\\"q\\\" \\\\ \\/ \\u00e9\"}"));
        // AI đã nhân đôi đúng: giữ nguyên
        assertEquals("\\frac{1}{2}", repairedValue("{\"k\":\"\\\\frac{1}{2}\"}"));
        // xuống dòng thật + từ tiếng Việt bắt đầu bằng n: không bị nhầm thành lệnh \nu
        assertEquals("bước 1:\nnuôi", repairedValue("{\"k\":\"bước 1:\\nnuôi\"}"));
        // không có dấu \ nào, hoặc null
        assertEquals("{\"k\":1}", AiJsonParser.repairLatexEscapes("{\"k\":1}"));
        assertNull(AiJsonParser.repairLatexEscapes(null));
    }

    // ---------- ScoreUtil: thang 10, làm tròn 0.25 (BR-07) ----------

    @Test
    void scoreRoundsToQuarterAndClamps() {
        assertEquals(7.5, ScoreUtil.roundQuarter(7.4));
        assertEquals(7.25, ScoreUtil.roundQuarter(7.3));
        assertEquals(10.0, ScoreUtil.roundQuarter(12.0));
        assertEquals(0.0, ScoreUtil.roundQuarter(-3.0));
        assertEquals(6.75, ScoreUtil.roundQuarter(6.8));
        assertTrue(ScoreUtil.isQuarterStep(8.75));
        assertFalse(ScoreUtil.isQuarterStep(8.3));
    }

    @Test
    void pagerNormalizesPageAndSize() {
        assertEquals(0, Pager.pageRequest(0, 10, org.springframework.data.domain.Sort.by("id")).getPageNumber());
        assertEquals(10, Pager.pageRequest(1, 7, org.springframework.data.domain.Sort.by("id")).getPageSize());
        assertEquals(50, Pager.pageRequest(3, 50, org.springframework.data.domain.Sort.by("id")).getPageSize());
        assertEquals(2, Pager.pageRequest(3, 20, org.springframework.data.domain.Sort.by("id")).getPageNumber());
    }

    // ---------- JSON contract ----------

    @Test
    void tutorStepResponseUsesDocumentedJsonKeys() throws Exception {
        TutorStepResponse r = new TutorStepResponse(7, 2, 4, true, "Giỏi!", "Bước 2: ...", false, null, "ACTIVE", null);
        JsonNode n = mapper.readTree(mapper.writeValueAsString(r));
        for (String key : new String[]{"sessionId", "currentStep", "totalSteps", "isStepCorrect", "feedbackToStudent",
                "nextPromptOrQuestion", "needsStudentInput", "inputRequestHint", "status", "finalSummary",
                "isSessionCompleted"}) {
            assertTrue(n.has(key), "UC-TUT-02: thiếu khóa " + key);
        }
        assertFalse(n.has("stepCorrect"), "không được xuất hiện khóa phụ stepCorrect");
        assertEquals(2, n.get("currentStep").asInt());
        assertFalse(n.get("isSessionCompleted").asBoolean());

        TutorAiResult parsed = mapper.readValue(
                "{\"isStepCorrect\":null,\"currentStep\":1,\"totalSteps\":4,\"feedbackToStudent\":\"a\","
                        + "\"nextPromptOrQuestion\":\"b\",\"needsStudentInput\":true,\"inputRequestHint\":\"Nhập a, b, c\","
                        + "\"isSessionCompleted\":false,\"thua\":1}",
                TutorAiResult.class);
        assertNull(parsed.isStepCorrect());
        assertTrue(parsed.needsStudentInput());
        assertEquals(4, parsed.totalSteps());
    }

    private static TutorAiResult ai(Boolean correct, int total, boolean needsInput, boolean completed) {
        return new TutorAiResult(correct, 9, total, "Nhận xét", "Câu hỏi", needsInput,
                needsInput ? "Nhập các hệ số a, b, c" : null, completed, completed ? "Đáp số $x=1$" : null);
    }

    /** Bảng chuẩn hóa UC-TUT-02 / BR-12 / BR-15: server quyết định bước, không tin AI tuyệt đối. */
    @Test
    void tutorNormalizationFollowsServerRules() {
        AiTutorService.TurnKind start = AiTutorService.TurnKind.START;
        AiTutorService.TurnKind answer = AiTutorService.TurnKind.ANSWER;
        AiTutorService.TurnKind data = AiTutorService.TurnKind.DATA;

        // Khởi đầu: bước 1, isStepCorrect = null, tổng số bước ép vào [min, max]
        TutorStepResponse s = AiTutorService.normalize(ai(true, 20, false, false), start, 1, 0, 3, 6);
        assertEquals(1, s.currentStep());
        assertEquals(6, s.totalSteps());
        assertNull(s.isStepCorrect());
        assertEquals("ACTIVE", s.status());

        // Sai: giữ bước; AI đổi totalSteps giữa chừng bị bỏ qua
        s = AiTutorService.normalize(ai(false, 9, false, false), answer, 2, 4, 3, 6);
        assertEquals(2, s.currentStep());
        assertEquals(4, s.totalSteps());
        assertEquals(Boolean.FALSE, s.isStepCorrect());

        // Đúng: +1; AI báo hoàn thành khi chưa qua bước cuối → bỏ qua cờ, không lộ finalSummary
        s = AiTutorService.normalize(ai(true, 4, false, true), answer, 2, 4, 3, 6);
        assertEquals(3, s.currentStep());
        assertEquals("ACTIVE", s.status());
        assertNull(s.finalSummary());

        // Đúng ở bước cuối → hoàn thành, có tổng kết
        s = AiTutorService.normalize(ai(true, 4, false, true), answer, 4, 4, 3, 6);
        assertEquals("COMPLETED", s.status());
        assertTrue(s.isSessionCompleted());
        assertEquals("Đáp số $x=1$", s.finalSummary());

        // AI yêu cầu dữ liệu: giữ bước, không chấm, lưu gợi ý
        s = AiTutorService.normalize(ai(true, 4, true, false), answer, 2, 4, 3, 6);
        assertEquals(2, s.currentStep());
        assertNull(s.isStepCorrect());
        assertTrue(s.needsStudentInput());
        assertEquals("Nhập các hệ số a, b, c", s.inputRequestHint());

        // Lượt học sinh cung cấp dữ liệu: không chấm, không chuyển bước dù AI báo đúng/sai; hết chờ dữ liệu
        s = AiTutorService.normalize(ai(false, 4, false, false), data, 2, 4, 3, 6);
        assertEquals(2, s.currentStep());
        assertNull(s.isStepCorrect());
        assertFalse(s.needsStudentInput());
        assertNull(s.inputRequestHint());
        s = AiTutorService.normalize(ai(true, 4, false, true), data, 4, 4, 3, 6);
        assertEquals("ACTIVE", s.status(), "lượt dữ liệu không được kết thúc phiên");
    }

    @Test
    void quizAnswerResponseJsonMatchesFrs() throws Exception {
        JsonNode n = mapper.readTree(mapper.writeValueAsString(
                new QuizAnswerResponse(false, 407, "B", "Lời giải $x$", 0.0, true)));
        // UC-STU-04 bước 5: đúng các khóa FRS
        assertFalse(n.get("isCorrect").asBoolean());
        assertEquals(407, n.get("correctOptionId").asInt());
        assertEquals("B", n.get("correctOptionLabel").asText());
        assertEquals("Lời giải $x$", n.get("explanationLatex").asText());
        assertEquals(0.0, n.get("score").asDouble());
        assertTrue(n.get("canAskTutor").asBoolean());
        assertFalse(n.has("correct"));
    }

    @Test
    void apiResponseEnvelopeHasFourFields() throws Exception {
        JsonNode ok = mapper.readTree(mapper.writeValueAsString(ApiResponse.ok("xong", 5)));
        assertTrue(ok.get("success").asBoolean());
        assertEquals("xong", ok.get("message").asText());
        assertEquals(5, ok.get("data").asInt());
        assertTrue(ok.has("errors") && ok.get("errors").isNull());

        JsonNode bad = mapper.readTree(mapper.writeValueAsString(ApiResponse.fail("Lỗi",
                List.of(new ApiResponse.FieldError("count", "Số câu phải từ 1 đến 10")))));
        assertFalse(bad.get("success").asBoolean());
        assertTrue(bad.get("data").isNull());
        assertEquals("count", bad.get("errors").get(0).get("field").asText());
    }

    @Test
    void questionGenerationDtoParsesAiSchema() throws Exception {
        String json = "[{\"content\":\"$x$?\",\"level\":2,\"explanation\":\"e\",\"options\":["
                + "{\"letter\":\"A\",\"content\":\"1\",\"isCorrect\":false},"
                + "{\"letter\":\"B\",\"content\":\"2\",\"isCorrect\":true}]}]";
        List<QuestionGenerationDTO> list = mapper.readValue(json,
                mapper.getTypeFactory().constructCollectionType(List.class, QuestionGenerationDTO.class));
        assertEquals(1, list.size());
        assertTrue(list.get(0).options().get(1).isCorrect());
        JsonNode out = mapper.readTree(mapper.writeValueAsString(list)).get(0).get("options").get(1);
        assertTrue(out.has("isCorrect"));
        assertFalse(out.has("correct"));
    }

    // ---------- Sanitize ----------

    @Test
    void sanitizerKeepsMathButRemovesDangerousHtml() {
        assertEquals("Cho $a<b$ và $x>2$", HtmlSanitizer.clean("Cho $a<b$ và $x>2$"));
        String cleaned = HtmlSanitizer.clean("Xin chào <script>alert(1)</script><img src=x onerror=alert(2)> $x$");
        assertFalse(cleaned.contains("<script"));
        assertFalse(cleaned.contains("<img"));
        assertTrue(cleaned.contains("$x$"));
        assertNull(HtmlSanitizer.clean(null));
    }

    // ---------- Bean Validation + thông báo tiếng Việt (VAL-01…04, TC-VAL-01) ----------

    private LocalValidatorFactoryBean validator() {
        ReloadableResourceBundleMessageSource ms = new ReloadableResourceBundleMessageSource();
        ms.setBasename("classpath:messages");
        ms.setDefaultEncoding("UTF-8");
        LocalValidatorFactoryBean v = new LocalValidatorFactoryBean();
        v.setMessageInterpolator(new MessageSourceMessageInterpolator(ms, new ParameterMessageInterpolator()));
        v.afterPropertiesSet();
        return v;
    }

    private RegisterForm validForm() {
        RegisterForm f = new RegisterForm();
        f.setUsername("hoc.sinh_1");
        f.setPassword("matkhau123");
        f.setConfirmPassword("matkhau123");
        f.setFullName("Nguyễn Văn A");
        f.setEmail("a@example.com");
        return f;
    }

    @Test
    void registerFormAcceptsValidData() {
        assertTrue(validator().validate(validForm()).isEmpty());
    }

    @Test
    void registerFormReportsVietnameseMessagePerField() {
        RegisterForm f = validForm();
        f.setUsername("ab");
        f.setPassword("123");
        f.setConfirmPassword("");
        f.setFullName("<b>x</b>");
        f.setEmail("khong-hop-le");
        var violations = validator().validate(f);
        Set<String> fields = violations.stream().map(v -> v.getPropertyPath().toString()).collect(Collectors.toSet());
        assertEquals(Set.of("username", "password", "confirmPassword", "fullName", "email"), fields);
        String all = violations.stream().map(v -> v.getMessage()).collect(Collectors.joining("|"));
        assertTrue(all.contains("Tên đăng nhập phải từ 4-30 ký tự"), all);
        assertTrue(all.contains("Mật khẩu phải từ 8 đến 64 ký tự"), all);
        assertTrue(all.contains("Địa chỉ email không đúng định dạng"), all);
        assertFalse(all.contains("{"), "không còn placeholder chưa được thay: " + all);
    }

    @Test
    void passwordNeedsLetterAndDigit() {
        RegisterForm f = validForm();
        f.setPassword("abcdefgh");
        f.setConfirmPassword("abcdefgh");
        assertEquals(1, validator().validateProperty(f, "password").size());
        f.setPassword("12345678");
        assertEquals(1, validator().validateProperty(f, "password").size());
    }

    // ---------- AuthInterceptor (FR-AUTH-06) ----------

    /** UserRepository giả: mọi tài khoản đều đang hoạt động, trừ userId 99 (bị khóa). */
    private UserRepository userRepository() {
        return (UserRepository) Proxy.newProxyInstance(getClass().getClassLoader(),
                new Class<?>[]{UserRepository.class}, (proxy, method, args) -> {
                    if (method.getName().equals("findActiveById")) {
                        return !Integer.valueOf(99).equals(args[0]);
                    }
                    throw new UnsupportedOperationException(method.getName());
                });
    }

    private int run(String path, String role) throws Exception {
        return run(path, role, 1);
    }

    private int run(String path, String role, int userId) throws Exception {
        AuthInterceptor interceptor = new AuthInterceptor(userRepository(), mapper);
        MockHttpServletRequest req = new MockHttpServletRequest("GET", "/edututor" + path);
        req.setContextPath("/edututor");
        req.setServletPath(path);
        MockHttpServletResponse res = new MockHttpServletResponse();
        if (role != null) {
            req.getSession(true).setAttribute(AuthInterceptor.SESSION_USER,
                    new SessionUser(userId, "u", "Người dùng", role));
        }
        boolean ok = interceptor.preHandle(req, res, new Object());
        return ok ? 200 : (res.getStatus() == 200 ? 302 : res.getStatus());
    }

    @Test
    void interceptorRedirectsAnonymousAndProtectsRoles() throws Exception {
        assertEquals(200, run("/login", null));
        assertEquals(200, run("/register", null));
        assertEquals(200, run("/static/css/style.css", null));
        assertEquals(302, run("/student/dashboard", null));
        assertEquals(401, run("/api/tutor/next-step", null));

        assertEquals(403, run("/admin/dashboard", "TEACHER"));
        assertEquals(403, run("/admin/ai-config", "STUDENT"));
        assertEquals(403, run("/api/admin/ai-config/test-connection", "TEACHER"));
        assertEquals(200, run("/admin/dashboard", "ADMIN"));

        assertEquals(403, run("/teacher/questions", "STUDENT"));
        assertEquals(403, run("/api/teacher/generate-questions", "STUDENT")); // TC-SEC-01
        assertEquals(200, run("/teacher/questions", "TEACHER"));
        assertEquals(200, run("/teacher/questions", "ADMIN"));
        assertEquals(200, run("/api/teacher/generate-questions", "ADMIN"));

        assertEquals(200, run("/student/quiz", "STUDENT"));
        assertEquals(200, run("/api/tutor/next-step", "STUDENT"));
        assertEquals(403, run("/api/student/submit-quiz-answer", "TEACHER"));
        assertEquals(403, run("/student/dashboard", "ADMIN"));

        assertEquals(200, run("/", "STUDENT"));
        assertEquals(200, run("/profile", "TEACHER"));
        assertEquals(200, run("/uploads/abc.png", "TEACHER"));
        assertEquals(404, run("/khong-ton-tai", "STUDENT"));
    }

    @Test
    void interceptorBlocksLockedAccountOnNextRequest() throws Exception {
        assertEquals(302, run("/student/dashboard", "STUDENT", 99)); // BR-01: redirect /login?locked=1
        assertEquals(401, run("/api/tutor/next-step", "STUDENT", 99));
    }

    @Test
    void interceptorCannotBeBypassedWithLookalikePaths() throws Exception {
        assertEquals(302, run("/student/history/login", null));
        assertEquals(302, run("/admin/x/register", null));
        assertEquals(403, run("/admin/login", "STUDENT"));
    }

    // ---------- CsrfInterceptor (TC-SEC-06) ----------

    private int csrf(String method, String headerToken, String paramToken) throws Exception {
        CsrfInterceptor interceptor = new CsrfInterceptor(mapper);
        MockHttpServletRequest first = new MockHttpServletRequest("GET", "/edututor/login");
        first.setServletPath("/login");
        interceptor.preHandle(first, new MockHttpServletResponse(), new Object());
        String token = (String) first.getSession().getAttribute(CsrfInterceptor.SESSION_TOKEN);
        assertNotNull(token);
        assertEquals(64, token.length());

        MockHttpServletRequest req = new MockHttpServletRequest(method, "/edututor/teacher/topics");
        req.setServletPath("/teacher/topics");
        req.setSession(first.getSession());
        if (headerToken != null) {
            req.addHeader(CsrfInterceptor.HEADER_NAME, headerToken.equals("OK") ? token : headerToken);
        }
        if (paramToken != null) {
            req.setParameter(CsrfInterceptor.PARAM_NAME, paramToken.equals("OK") ? token : paramToken);
        }
        MockHttpServletResponse res = new MockHttpServletResponse();
        return interceptor.preHandle(req, res, new Object()) ? 200 : res.getStatus();
    }

    @Test
    void csrfRejectsStateChangingRequestsWithoutValidToken() throws Exception {
        assertEquals(200, csrf("GET", null, null));
        assertEquals(403, csrf("POST", null, null));
        assertEquals(403, csrf("POST", "sai-token", null));
        assertEquals(403, csrf("POST", null, "sai-token"));
        assertEquals(200, csrf("POST", "OK", null));
        assertEquals(200, csrf("POST", null, "OK"));
        assertEquals(403, csrf("DELETE", null, null));
    }

    // ---------- Bài giảng (VAL-08) ----------

    private void invalid(com.edututor.model.MaterialType t, String url, String text, String expectedPart) {
        IllegalArgumentException e = org.junit.jupiter.api.Assertions.assertThrows(IllegalArgumentException.class,
                () -> com.edututor.service.MaterialService.validateContent(t, url, text));
        assertTrue(e.getMessage().contains(expectedPart), e.getMessage());
    }

    @Test
    void materialRulesFollowVal08() {
        var y = com.edututor.model.MaterialType.YOUTUBE;
        var v = com.edututor.model.MaterialType.VIDEO;
        var l = com.edututor.model.MaterialType.LINK;
        var tx = com.edututor.model.MaterialType.TEXT;
        com.edututor.service.MaterialService.validateContent(y, "https://www.youtube.com/watch?v=zSnMIO2D4oE", null);
        com.edututor.service.MaterialService.validateContent(y, "https://youtu.be/zSnMIO2D4oE", null);
        com.edututor.service.MaterialService.validateContent(y, "https://www.youtube.com/embed/zSnMIO2D4oE?si=x", null);
        com.edututor.service.MaterialService.validateContent(v, "https://cdn.example.com/a/b.MP4?token=1", null);
        com.edututor.service.MaterialService.validateContent(l, "http://example.com/trang", null);
        com.edututor.service.MaterialService.validateContent(tx, null, "Cho $x^2$");
        invalid(y, "https://example.com/watch?v=zSnMIO2D4oE", null, "YouTube");
        invalid(y, "ftp://youtube.com/watch?v=zSnMIO2D4oE", null, "http");
        invalid(v, "https://example.com/a.exe", null, ".mp4");
        invalid(l, "javascript:alert(1)", null, "http");
        invalid(l, "data:text/html,<script>1</script>", null, "http");
        invalid(l, "", null, "URL");
        invalid(tx, null, "  ", "nội dung");
        invalid(tx, null, "x".repeat(20001), "20.000");
    }

    @Test
    void youtubeUtilExtractsIdFromAllLinkForms() {
        assertEquals("zSnMIO2D4oE", com.edututor.util.YoutubeUtil.extractId("https://www.youtube.com/watch?v=zSnMIO2D4oE&t=5"));
        assertEquals("zSnMIO2D4oE", com.edututor.util.YoutubeUtil.extractId("https://youtu.be/zSnMIO2D4oE?si=abc"));
        assertEquals("zSnMIO2D4oE", com.edututor.util.YoutubeUtil.extractId("https://www.youtube.com/embed/zSnMIO2D4oE?si=62w8J9"));
        assertEquals("zSnMIO2D4oE", com.edututor.util.YoutubeUtil.extractId("https://www.youtube.com/shorts/zSnMIO2D4oE"));
        assertNull(com.edututor.util.YoutubeUtil.extractId("https://example.com/video"));
        assertNull(com.edututor.util.YoutubeUtil.extractId(null));
        assertEquals("https://www.youtube.com/embed/zSnMIO2D4oE",
                com.edututor.util.YoutubeUtil.getEmbedUrl("https://youtu.be/zSnMIO2D4oE"));
    }

    /** BR-13 / NFR-06: cửa sổ trượt 60 phút theo (userId, nhóm hành động); hạn mức học sinh và giáo viên độc lập. */
    @Test
    void rateLimiterUsesSlidingWindowPerUserAndAction() {
        java.util.concurrent.atomic.AtomicReference<java.time.Instant> now =
                new java.util.concurrent.atomic.AtomicReference<>(java.time.Instant.parse("2026-10-03T08:00:00Z"));
        java.time.Clock clock = new java.time.Clock() {
            @Override public java.time.ZoneId getZone() { return java.time.ZoneOffset.UTC; }
            @Override public java.time.Clock withZone(java.time.ZoneId zone) { return this; }
            @Override public java.time.Instant instant() { return now.get(); }
        };
        RateLimiter limiter = new RateLimiter(a -> a == RateLimiter.Action.QUIZ_GEN ? 3 : 2, clock);

        limiter.check(1, RateLimiter.Action.STUDENT_AI);
        now.set(now.get().plusSeconds(600));
        limiter.check(1, RateLimiter.Action.STUDENT_AI);
        AiRateLimitException ex = org.junit.jupiter.api.Assertions.assertThrows(AiRateLimitException.class,
                () -> limiter.check(1, RateLimiter.Action.STUDENT_AI));
        assertEquals(50, ex.getRetryAfterMinutes(), "lượt đầu hết hạn sau 50 phút nữa");
        assertTrue(ex.getMessage().contains("50 phút"));

        // Người khác và nhóm hành động khác không bị ảnh hưởng
        limiter.check(2, RateLimiter.Action.STUDENT_AI);
        limiter.check(1, RateLimiter.Action.QUIZ_GEN);

        // Sau 60 phút kể từ lượt đầu, lượt đó rời cửa sổ
        now.set(java.time.Instant.parse("2026-10-03T09:00:01Z"));
        limiter.check(1, RateLimiter.Action.STUDENT_AI);
    }

    /** FRS 4.4 / VAL-17: thay placeholder, nối cấu trúc JSON + phần chốt cố định, phát hiện placeholder bị xóa. */
    @Test
    void promptBuilderFillsPlaceholdersAndAppendsFixedRules() {
        String sys = PromptBuilder.system("Chia {{MIN_STEPS}} đến {{MAX_STEPS}} bước.",
                java.util.Map.of("MIN_STEPS", "3", "MAX_STEPS", "6"), "JSON: {...}");
        assertTrue(sys.startsWith("Chia 3 đến 6 bước."), sys);
        assertTrue(sys.indexOf("JSON: {...}") < sys.indexOf("QUY TẮC CỐ ĐỊNH"), "phần chốt luôn nằm cuối");
        assertTrue(sys.endsWith(PromptBuilder.FIXED_RULES));

        assertTrue(PromptBuilder.missingPlaceholders("QUIZ_GEN_PROMPT",
                "{{COUNT}} {{TOPIC}} {{LESSON}} {{DIFFICULTY}}").isEmpty());
        assertEquals(List.of("{{REFERENCE}}"), PromptBuilder.missingPlaceholders("GRADING_PROMPT", "Đề: {{QUESTION}}"));
    }

    /** Ảnh PNG / JPEG thật kích thước w×h (tạo trong bộ nhớ). */
    static byte[] image(String format, int w, int h) throws Exception {
        java.awt.image.BufferedImage img = new java.awt.image.BufferedImage(w, h, java.awt.image.BufferedImage.TYPE_INT_RGB);
        java.io.ByteArrayOutputStream out = new java.io.ByteArrayOutputStream();
        javax.imageio.ImageIO.write(img, format, out);
        return out.toByteArray();
    }

    /** Header WebP lossless (VP8L) w×h: đủ để kiểm tra magic bytes và kích thước. */
    static byte[] webpLossless(int w, int h) {
        byte[] b = new byte[40];
        System.arraycopy("RIFF".getBytes(), 0, b, 0, 4);
        b[4] = 32;
        System.arraycopy("WEBPVP8L".getBytes(), 0, b, 8, 8);
        b[16] = 20;
        b[20] = 0x2F;
        int bits = (w - 1) | (h - 1) << 14;
        b[21] = (byte) bits;
        b[22] = (byte) (bits >> 8);
        b[23] = (byte) (bits >> 16);
        b[24] = (byte) (bits >> 24);
        return b;
    }

    /** Header WebP mở rộng (VP8X) với kích thước canvas w×h. */
    static byte[] webpExtended(int w, int h) {
        byte[] b = new byte[40];
        System.arraycopy("RIFF".getBytes(), 0, b, 0, 4);
        b[4] = 32;
        System.arraycopy("WEBPVP8X".getBytes(), 0, b, 8, 8);
        b[16] = 10;
        int cw = w - 1;
        int ch = h - 1;
        b[24] = (byte) cw;
        b[25] = (byte) (cw >> 8);
        b[26] = (byte) (cw >> 16);
        b[27] = (byte) ch;
        b[28] = (byte) (ch >> 8);
        b[29] = (byte) (ch >> 16);
        return b;
    }

    /** VAL-18 / TC-OCR-01: magic bytes, đọc được, tối đa 4096×4096; WebP đọc kích thước từ header. */
    @Test
    void imageValidatorChecksFormatAndDimensions() throws Exception {
        ImageValidator.ImageInfo png = ImageValidator.validate(image("png", 640, 480));
        assertEquals("image/png", png.mimeType());
        assertEquals("png", png.extension());
        assertEquals(640, png.width());
        assertEquals(480, png.height());
        assertEquals("jpg", ImageValidator.validate(image("jpg", 100, 50)).extension());
        assertEquals(4096, ImageValidator.validate(image("png", 4096, 1)).width(), "đúng giới hạn vẫn hợp lệ");

        ImageValidator.ImageInfo webp = ImageValidator.validate(webpLossless(1200, 900));
        assertEquals("image/webp", webp.mimeType());
        assertEquals("webp", webp.extension());
        assertEquals(1200, webp.width());
        assertEquals(900, webp.height());
        assertEquals(3000, ImageValidator.validate(webpExtended(3000, 2000)).width());

        // Quá 4096 px (PNG thật và WebP), tệp .exe đổi đuôi, tệp hỏng → từ chối với thông báo tiếng Việt
        IllegalArgumentException big = org.junit.jupiter.api.Assertions.assertThrows(IllegalArgumentException.class,
                () -> ImageValidator.validate(image("png", 4097, 1)));
        assertTrue(big.getMessage().contains("4096"), big.getMessage());
        org.junit.jupiter.api.Assertions.assertThrows(IllegalArgumentException.class,
                () -> ImageValidator.validate(webpExtended(5000, 10)));
        IllegalArgumentException exe = org.junit.jupiter.api.Assertions.assertThrows(IllegalArgumentException.class,
                () -> ImageValidator.validate("MZ\u0090\u0000 day la tep exe".getBytes()));
        assertTrue(exe.getMessage().contains("JPG, PNG hoặc WebP"));
        byte[] broken = java.util.Arrays.copyOf(image("png", 10, 10), 12); // chỉ còn chữ ký PNG
        org.junit.jupiter.api.Assertions.assertThrows(IllegalArgumentException.class, () -> ImageValidator.validate(broken));
    }
}
