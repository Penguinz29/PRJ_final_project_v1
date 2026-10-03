package com.edututor;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.edututor.ai.AiJsonParser;
import com.edututor.config.MessageSourceMessageInterpolator;
import com.edututor.dto.ApiResponse;
import com.edututor.dto.QuestionGenerationDTO;
import com.edututor.dto.QuizAnswerResponse;
import com.edututor.dto.RegisterForm;
import com.edututor.dto.SessionUser;
import com.edututor.dto.TutorStepResponse;
import com.edututor.interceptor.AuthInterceptor;
import com.edututor.interceptor.CsrfInterceptor;
import com.edututor.repository.UserRepository;
import com.edututor.util.HtmlSanitizer;
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
        TutorStepResponse r = new TutorStepResponse(7, true, 2, 4, "Giỏi!", "Bước 2: ...", false);
        JsonNode n = mapper.readTree(mapper.writeValueAsString(r));
        assertTrue(n.has("isStepCorrect"));
        assertTrue(n.has("isSessionCompleted"));
        assertFalse(n.has("stepCorrect"), "không được xuất hiện khóa phụ stepCorrect");
        assertEquals(2, n.get("currentStep").asInt());

        TutorStepResponse parsed = mapper.readValue(
                "{\"isStepCorrect\":true,\"currentStep\":1,\"totalSteps\":4,\"feedbackToStudent\":\"a\","
                        + "\"nextPromptOrQuestion\":\"b\",\"isSessionCompleted\":false,\"thua\":1}",
                TutorStepResponse.class);
        assertTrue(parsed.isStepCorrect());
        assertEquals(4, parsed.totalSteps());
    }

    @Test
    void quizAnswerResponseJsonMatchesFrs() throws Exception {
        JsonNode n = mapper.readTree(mapper.writeValueAsString(
                new QuizAnswerResponse(true, "B", "Lời giải $x$", 10.0)));
        assertTrue(n.get("isCorrect").asBoolean());
        assertEquals("B", n.get("correctOptionLabel").asText());
        assertFalse(n.has("correct"));
        assertEquals(10.0, n.get("score").asDouble());
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
}
