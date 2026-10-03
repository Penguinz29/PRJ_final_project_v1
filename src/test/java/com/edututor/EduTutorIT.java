package com.edututor;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.sun.net.httpserver.HttpServer;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.net.CookieManager;
import java.net.InetSocketAddress;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayDeque;
import java.util.Deque;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import org.apache.catalina.Context;
import org.apache.catalina.startup.Tomcat;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;
import org.junit.jupiter.api.condition.EnabledIfSystemProperty;

/**
 * Kiểm thử tích hợp end-to-end (tên *IT: không chạy trong {@code mvn package}): Tomcat nhúng + toàn bộ Spring MVC +
 * Spring Data JPA/Hibernate + SQL Server thật + Gemini giả (mock HTTP).
 * Cần một CSDL RIÊNG đã nạp document/sql/01_schema.sql + 02_data.sql (đổi tên MathTutorDB trong 2 file, vd.
 * thành MathTutorDB_verify);
 * chạy riêng:
 * <pre>
 * mvn verify -Pintegration -Dit.db.url="jdbc:sqlserver://localhost:1433;databaseName=MathTutorDB_verify;encrypt=true;trustServerCertificate=true"
 *            -Dit.db.user=sa -Dit.db.pass=123
 * </pre>
 * Lưu ý: bài kiểm thử XÓA bài làm / phiên gia sư trong CSDL được trỏ tới.
 */
@EnabledIfSystemProperty(named = "it.db.url", matches = ".+")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class EduTutorIT {

    // ---------------------------------------------------------------- hạ tầng

    record Resp(int status, String body, String location, String contentType) {
        boolean has(String s) {
            return body != null && body.contains(s);
        }
    }

    static final ObjectMapper JSON = new ObjectMapper();
    static Tomcat tomcat;
    static String base;
    static HttpServer gemini;
    static Path uploadDir;
    static final Deque<String[]> script = new ArrayDeque<>(); // {status, text}
    static volatile String lastRequestBody = "";
    static volatile String lastApiKey = "";
    static volatile String lastUri = "";
    static volatile int geminiCalls = 0;

    static final java.util.regex.Pattern CSRF_META =
            java.util.regex.Pattern.compile("name=\"csrf-token\" content=\"([0-9a-f]{64})\"");
    static final java.util.regex.Pattern CSRF_INPUT =
            java.util.regex.Pattern.compile("name=\"_csrf\" value=\"([0-9a-f]{64})\"");

    static class Client {
        final HttpClient http = HttpClient.newBuilder().cookieHandler(new CookieManager())
                .followRedirects(HttpClient.Redirect.NEVER).build();
        /** Mã CSRF hiện hành của phiên (lấy từ trang HTML gần nhất). */
        String csrf;
        /** Đặt true để cố ý gửi request KHÔNG kèm mã CSRF (TC-SEC-06). */
        boolean omitCsrf;

        Resp send(HttpRequest.Builder b) throws Exception {
            HttpResponse<String> r = http.send(b.build(), HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
            String body = r.body();
            if (body != null && r.headers().firstValue("Content-Type").orElse("").contains("text/html")) {
                java.util.regex.Matcher m = CSRF_META.matcher(body);
                if (m.find()) {
                    csrf = m.group(1);
                } else if ((m = CSRF_INPUT.matcher(body)).find()) {
                    csrf = m.group(1);
                }
            }
            return new Resp(r.statusCode(), body, r.headers().firstValue("Location").orElse(null),
                    r.headers().firstValue("Content-Type").orElse(""));
        }

        /** Đảm bảo đã có mã CSRF: tải trang đăng nhập nếu chưa có. */
        void ensureCsrf() throws Exception {
            if (csrf == null) {
                get("/login");
            }
        }

        HttpRequest.Builder withCsrf(HttpRequest.Builder b) throws Exception {
            if (!omitCsrf) {
                ensureCsrf();
                if (csrf != null) {
                    b.header("X-CSRF-TOKEN", csrf);
                }
            }
            return b;
        }

        Resp get(String path) throws Exception {
            return send(HttpRequest.newBuilder(URI.create(base + path)).GET());
        }

        Resp getAjax(String path) throws Exception {
            return send(HttpRequest.newBuilder(URI.create(base + path)).header("Accept", "application/json").GET());
        }

        Resp form(String path, Map<String, String> params) throws Exception {
            params = new LinkedHashMap<>(params);
            if (!omitCsrf) {
                ensureCsrf();
                if (csrf != null) {
                    params.put("_csrf", csrf);
                }
            }
            StringBuilder sb = new StringBuilder();
            params.forEach((k, v) -> {
                if (sb.length() > 0) {
                    sb.append('&');
                }
                sb.append(URLEncoder.encode(k, StandardCharsets.UTF_8)).append('=')
                        .append(URLEncoder.encode(v, StandardCharsets.UTF_8));
            });
            return send(HttpRequest.newBuilder(URI.create(base + path))
                    .header("Content-Type", "application/x-www-form-urlencoded")
                    .POST(HttpRequest.BodyPublishers.ofString(sb.toString())));
        }

        Resp json(String path, String body) throws Exception {
            return send(withCsrf(HttpRequest.newBuilder(URI.create(base + path))
                    .header("Content-Type", "application/json").header("Accept", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(body, StandardCharsets.UTF_8))));
        }

        Resp multipart(String path, Map<String, String> fields, String fileField, String fileName, String mime,
                       byte[] file) throws Exception {
            String boundary = "----b" + UUID.randomUUID();
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            for (Map.Entry<String, String> e : fields.entrySet()) {
                out.write(("--" + boundary + "\r\nContent-Disposition: form-data; name=\"" + e.getKey()
                        + "\"\r\n\r\n" + e.getValue() + "\r\n").getBytes(StandardCharsets.UTF_8));
            }
            if (file != null) {
                out.write(("--" + boundary + "\r\nContent-Disposition: form-data; name=\"" + fileField
                        + "\"; filename=\"" + fileName + "\"\r\nContent-Type: " + mime + "\r\n\r\n")
                        .getBytes(StandardCharsets.UTF_8));
                out.write(file);
                out.write("\r\n".getBytes(StandardCharsets.UTF_8));
            }
            out.write(("--" + boundary + "--\r\n").getBytes(StandardCharsets.UTF_8));
            return send(withCsrf(HttpRequest.newBuilder(URI.create(base + path))
                    .header("Content-Type", "multipart/form-data; boundary=" + boundary)
                    .header("Accept", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofByteArray(out.toByteArray()))));
        }

        Resp login(String user, String pass) throws Exception {
            Resp r = form("/login", Map.of("username", user, "password", pass));
            if (r.status() == 302 && r.location() != null) {
                // Sau đăng nhập server cấp session ID + mã CSRF mới: tải trang đích để lấy mã mới
                get(r.location().substring(r.location().indexOf("/edututor") + "/edututor".length()));
            }
            return r;
        }
    }

    static Connection db() throws Exception {
        return DriverManager.getConnection(System.getProperty("it.db.url"),
                System.getProperty("it.db.user", "sa"), System.getProperty("it.db.pass", "123"));
    }

    static Object scalar(String sql, Object... args) throws Exception {
        try (Connection c = db(); PreparedStatement ps = c.prepareStatement(sql)) {
            for (int i = 0; i < args.length; i++) {
                ps.setObject(i + 1, args[i]);
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getObject(1) : null;
            }
        }
    }

    static int count(String sql, Object... args) throws Exception {
        Object o = scalar(sql, args);
        return o == null ? 0 : ((Number) o).intValue();
    }

    static void exec(String sql, Object... args) throws Exception {
        try (Connection c = db(); PreparedStatement ps = c.prepareStatement(sql)) {
            for (int i = 0; i < args.length; i++) {
                ps.setObject(i + 1, args[i]);
            }
            ps.executeUpdate();
        }
    }

    static String envelope(String text) throws Exception {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("candidates", java.util.List.of(Map.of("content", Map.of("parts", java.util.List.of(Map.of("text", text))))));
        return JSON.writeValueAsString(m);
    }

    static final String EXAM_JSON = "[{\"content\":\"Tính $\\\\int_0^1 x\\\\,dx$\",\"level\":1,\"explanation\":\"$=1/2$\","
            + "\"options\":[{\"letter\":\"B\",\"content\":\"$1/2$\",\"isCorrect\":true},"
            + "{\"letter\":\"A\",\"content\":\"$1$\",\"isCorrect\":false},"
            + "{\"letter\":\"C\",\"content\":\"$2$\",\"isCorrect\":false},"
            + "{\"letter\":\"D\",\"content\":\"$0$\",\"isCorrect\":false}]},"
            + "{\"content\":\"Cho $a<b$ thì ...\",\"level\":3,\"explanation\":\"e\","
            + "\"options\":[{\"letter\":\"A\",\"content\":\"x\",\"isCorrect\":true},{\"letter\":\"B\",\"content\":\"y\","
            + "\"isCorrect\":false},{\"letter\":\"C\",\"content\":\"z\",\"isCorrect\":false},{\"letter\":\"D\","
            + "\"content\":\"w\",\"isCorrect\":false}]}]";

    static String tutorJson(boolean correct, int step, int total, boolean done) {
        return "{\"isStepCorrect\":" + correct + ",\"currentStep\":" + step + ",\"totalSteps\":" + total
                + ",\"feedbackToStudent\":\"Nhận xét bước\",\"nextPromptOrQuestion\":\"Câu hỏi bước " + step
                + " $x^2$\",\"isSessionCompleted\":" + done + "}";
    }

    /** Phản hồi gia sư đầy đủ (có needsStudentInput / finalSummary). correct = null → JSON null. */
    static String tutorJsonFull(Boolean correct, int step, int total, boolean done, boolean needsInput, String hint) {
        return "{\"isStepCorrect\":" + correct + ",\"currentStep\":" + step + ",\"totalSteps\":" + total
                + ",\"feedbackToStudent\":\"Nhận xét bước\",\"nextPromptOrQuestion\":\"Câu hỏi bước " + step + "\""
                + ",\"needsStudentInput\":" + needsInput + ",\"inputRequestHint\":" + (hint == null ? "null" : "\"" + hint + "\"")
                + ",\"isSessionCompleted\":" + done + ",\"finalSummary\":" + (done ? "\"Kết luận $x=2$\"" : "null") + "}";
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

    static final byte[] PNG = java.util.Base64.getDecoder().decode(
            "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==");

    @BeforeAll
    static void startAll() throws Exception {
        uploadDir = Files.createTempDirectory("edututor-uploads");
        if (System.getProperty("it.debug") != null) {
            java.util.logging.Logger l = java.util.logging.Logger.getLogger("org.springframework.web");
            l.setLevel(java.util.logging.Level.FINE);
            java.util.logging.ConsoleHandler h = new java.util.logging.ConsoleHandler();
            h.setLevel(java.util.logging.Level.FINE);
            l.addHandler(h);
        }

        gemini = HttpServer.create(new InetSocketAddress("127.0.0.1", 0), 0);
        gemini.createContext("/v1beta/models/", ex -> {
            byte[] in = ex.getRequestBody().readAllBytes();
            lastRequestBody = new String(in, StandardCharsets.UTF_8);
            lastApiKey = ex.getRequestHeaders().getFirst("x-goog-api-key");
            lastUri = ex.getRequestURI().toString();
            geminiCalls++;
            int status = 200;
            String text;
            String[] scripted;
            synchronized (script) {
                scripted = script.poll();
            }
            try {
                if (scripted != null) {
                    status = Integer.parseInt(scripted[0]);
                    text = scripted[1];
                } else {
                    JsonNode req = JSON.readTree(lastRequestBody);
                    String sys = req.path("system_instruction").path("parts").path(0).path("text").asText("");
                    if (sys.isEmpty()) {
                        text = "Pong";
                    } else if (sys.contains("giám khảo")) {
                        text = "{\"extractedText\":\"$y=x^2$\",\"score\":7.4,\"detailedFeedback\":\"Sai dấu ở dòng 2\","
                                + "\"suggestedCorrection\":\"$x=1$\"}";
                    } else if (sys.contains("từng bước")) {
                        text = tutorJson(true, 1, 3, false);
                    } else {
                        text = EXAM_JSON;
                    }
                }
                byte[] out = (status == 200 ? envelope(text) : "{\"error\":{\"message\":\"" + text + "\"}}")
                        .getBytes(StandardCharsets.UTF_8);
                ex.getResponseHeaders().add("Content-Type", "application/json");
                ex.sendResponseHeaders(status, out.length);
                ex.getResponseBody().write(out);
            } catch (Exception e) {
                ex.sendResponseHeaders(500, -1);
            } finally {
                ex.close();
            }
        });
        gemini.start();

        System.setProperty("DB_URL", System.getProperty("it.db.url"));
        System.setProperty("DB_USER", System.getProperty("it.db.user", "sa"));
        System.setProperty("DB_PASS", System.getProperty("it.db.pass", "123"));
        System.setProperty("UPLOAD_DIR", uploadDir.toString());
        System.setProperty("gemini.baseUrl", "http://127.0.0.1:" + gemini.getAddress().getPort() + "/v1beta");
        // Test sửa AiConfigs trực tiếp bằng SQL nên tắt cache cấu hình (mặc định 60 giây)
        System.setProperty("ai.config.cacheTtlSeconds", "0");

        tomcat = new Tomcat();
        tomcat.setBaseDir(Files.createTempDirectory("tomcat").toString());
        tomcat.setPort(0);
        tomcat.getConnector();
        Context ctx = tomcat.addWebapp("/edututor", new File("src/main/webapp").getAbsolutePath());
        ctx.setParentClassLoader(EduTutorIT.class.getClassLoader());
        // Tomcat nhúng gắn sẵn DefaultServlet vào "/"; gỡ ra để DispatcherServlet của Spring nhận "/" như khi chạy Tomcat thật
        ctx.removeServletMapping("/");
        tomcat.start();
        base = "http://127.0.0.1:" + tomcat.getConnector().getLocalPort() + "/edututor";

        // dọn dữ liệu của các lần chạy trước
        resetDatabase();
    }

    /** Đưa CSDL về trạng thái seed để chạy lại được nhiều lần. */
    static void resetDatabase() throws Exception {
        exec("DELETE FROM LessonMaterials WHERE Title LIKE N'it[_]%'");
        exec("DELETE FROM TutorMessages");
        exec("DELETE FROM TutorSessions");
        exec("DELETE FROM Submissions");
        exec("DELETE FROM Questions WHERE Content LIKE N'it[_]%'");
        exec("DELETE FROM Lessons WHERE Title LIKE N'it[_]%'");
        exec("DELETE FROM Topics WHERE TopicName LIKE N'it[_]%'");
        exec("DELETE FROM Users WHERE Username LIKE 'it[_]%'");
        exec("UPDATE Questions SET ExplanationLatex = NULL");
        exec("UPDATE Questions SET IsActive = 1");
        exec("UPDATE Lessons SET IsActive = 1");
        exec("UPDATE Topics SET IsActive = 1");
        // mật khẩu seed '123456' dạng SHA-256 và tài khoản đang hoạt động
        exec("UPDATE Users SET PasswordHash = '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', "
                + "IsActive = 1, [Status] = 'ACTIVE'");
        exec("UPDATE AiConfigs SET ConfigValue = 'test-key-123', UpdatedBy = NULL WHERE ConfigKey = 'GEMINI_API_KEY'");
        exec("UPDATE AiConfigs SET ConfigValue = 'gemini-1.5-flash' WHERE ConfigKey = 'DEFAULT_MODEL'");
        exec("UPDATE AiConfigs SET ConfigValue = 'gemini-1.5-pro' WHERE ConfigKey = 'VISION_MODEL'");
        exec("UPDATE AiConfigs SET ConfigValue = '0.2' WHERE ConfigKey = 'TUTOR_TEMPERATURE'");
        exec("UPDATE AiConfigs SET ConfigValue = '2048' WHERE ConfigKey = 'MAX_OUTPUT_TOKENS'");
        exec("UPDATE AiConfigs SET ConfigValue = '3' WHERE ConfigKey = 'TUTOR_MIN_STEPS'");
        exec("UPDATE AiConfigs SET ConfigValue = '6' WHERE ConfigKey = 'TUTOR_MAX_STEPS'");
        exec("UPDATE AiConfigs SET ConfigValue = '60' WHERE ConfigKey = 'AI_RATE_LIMIT_PER_HOUR'");
        exec("UPDATE AiConfigs SET ConfigValue = '300' WHERE ConfigKey = 'AI_RATE_LIMIT_TEACHER_PER_HOUR'");
    }

    @AfterAll
    static void stopAll() throws Exception {
        if (tomcat != null) {
            tomcat.stop();
            tomcat.destroy();
        }
        if (gemini != null) {
            gemini.stop(0);
        }
    }

    // ---------------------------------------------------------------- AUTH

    @Test
    @Order(1)
    void anonymousIsRedirectedAndLoginPageRenders() throws Exception {
        Client c = new Client();
        Resp root = c.get("/");
        assertEquals(302, root.status());
        assertTrue(root.location().contains("/login"), root.location());

        Resp login = c.get("/login");
        assertEquals(200, login.status());
        assertTrue(login.has("Đăng nhập"));

        assertEquals(302, c.get("/student/dashboard").status());
        assertEquals(302, c.get("/teacher/questions").status());
        Resp api = c.json("/api/tutor/next-step", "{}");
        assertEquals(401, api.status());
        assertTrue(api.has("\"success\":false"));
        // URL không ánh xạ tới controller nào luôn là 404
        assertEquals(404, c.get("/khong-ton-tai").status());
        // tài nguyên tĩnh công khai
        assertEquals(200, c.get("/static/css/style.css").status());
        // TC-SEC-06: POST không có mã CSRF -> 403
        Client noToken = new Client();
        noToken.omitCsrf = true;
        assertEquals(403, noToken.form("/login", Map.of("username", "student1", "password", "123456")).status());
    }

    @Test
    @Order(2)
    void loginUpgradesLegacySha256ToBcryptAndRejectsBadPassword() throws Exception {
        Client c = new Client();
        Resp bad = c.login("student1", "sai-mat-khau");
        assertEquals(200, bad.status(), bad.location() + " " + bad.body());
        assertTrue(bad.has("sai"));

        String before = (String) scalar("SELECT PasswordHash FROM Users WHERE Username = 'student1'");
        assertFalse(before.startsWith("$2"), "seed vẫn là SHA-256");

        Resp ok = c.login("student1", "123456");
        assertEquals(302, ok.status());
        assertTrue(ok.location().contains("/student/dashboard"), ok.location());
        String after = (String) scalar("SELECT PasswordHash FROM Users WHERE Username = 'student1'");
        assertTrue(after.startsWith("$2"), "đã nâng cấp BCrypt");

        Client again = new Client();
        assertEquals(302, again.login("student1", "123456").status());
        assertEquals(200, c.get("/student/dashboard").status());

        // đăng xuất
        assertEquals(302, c.form("/logout", Map.of()).status());
        assertEquals(302, c.get("/student/dashboard").status());

        assertTrue(new Client().login("admin", "123456").location().contains("/admin/dashboard"));
        assertTrue(new Client().login("teacher1", "123456").location().contains("/teacher/dashboard"));
    }

    @Test
    @Order(3)
    void registerValidatesAndCreatesStudent() throws Exception {
        Client c = new Client();
        Resp registerPage = c.get("/register");
        assertTrue(registerPage.has("Đăng ký"));
        assertTrue(registerPage.has("name=\"_csrf\""), "form đăng ký có trường CSRF");
        assertTrue(registerPage.has("novalidate"), "thuộc tính HTML5 truyền qua <form:form>");
        assertTrue(registerPage.has("type=\"email\""));
        assertFalse(registerPage.has("name=\"role\""), "form đăng ký không có trường role");
        Map<String, String> p = new LinkedHashMap<>();
        p.put("username", "it_user1");
        p.put("password", "abc12345");
        p.put("confirmPassword", "khac");
        p.put("fullName", "Người Dùng Thử");
        p.put("email", "it_user1@example.com");
        Resp r1 = c.form("/register", p);
        assertEquals(200, r1.status());
        assertTrue(r1.has("không khớp"));

        p.put("confirmPassword", "abc12345");
        p.put("email", "khong-hop-le");
        assertTrue(c.form("/register", p).has("không đúng định dạng"));

        // TC-VAL-01: lỗi tiếng Việt tại từng trường, không ghi CSDL
        int usersBefore = count("SELECT COUNT(*) FROM Users");
        Map<String, String> weak = new LinkedHashMap<>();
        weak.put("username", "ab");
        weak.put("password", "123");
        weak.put("confirmPassword", "123");
        weak.put("fullName", "Người Dùng Thử");
        weak.put("email", "it_weak@example.com");
        Resp rv = c.form("/register", weak);
        assertEquals(200, rv.status());
        assertTrue(rv.has("Tên đăng nhập phải từ 4-30 ký tự"), rv.body());
        assertTrue(rv.has("Mật khẩu phải từ 8 đến 64 ký tự"), rv.body());
        assertEquals(usersBefore, count("SELECT COUNT(*) FROM Users"));

        p.put("email", "it_user1@example.com");
        p.put("username", "student1"); // trùng
        assertTrue(c.form("/register", p).has("đã được sử dụng"));

        p.put("username", "it_user1");
        Resp ok = c.form("/register", p);
        assertEquals(302, ok.status());
        assertTrue(ok.location().contains("/login"));
        assertTrue(c.get("/login").has("Đăng ký thành công"), "flash message hiển thị trên trang login");

        assertEquals("STUDENT", scalar("SELECT [Role] FROM Users WHERE Username = 'it_user1'"));
        // TC-VAL-02: role do client gửi bị bỏ qua
        Map<String, String> evil = new LinkedHashMap<>(p);
        evil.put("username", "it_user3");
        evil.put("email", "it_user3@example.com");
        evil.put("role", "ADMIN");
        assertEquals(302, c.form("/register", evil).status());
        assertEquals("STUDENT", scalar("SELECT [Role] FROM Users WHERE Username = 'it_user3'"));
        String hash = (String) scalar("SELECT PasswordHash FROM Users WHERE Username = 'it_user1'");
        assertTrue(hash.startsWith("$2"));

        p.put("username", "it_user2"); // email trùng
        assertTrue(c.form("/register", p).has("Email đã được đăng ký"));

        assertEquals(302, new Client().login("it_user1", "abc12345").status());
    }

    // ---------------------------------------------------------------- STUDENT

    @Test
    @Order(10)
    void studentPagesRender() throws Exception {
        Client c = new Client();
        c.login("student1", "123456");
        for (String path : new String[]{"/student/dashboard", "/student/topics", "/student/lesson?id=1",
                "/student/quiz?lessonId=1", "/student/essay?lessonId=2", "/student/history", "/student/ai-tutor"}) {
            Resp r = c.get(path);
            assertEquals(200, r.status(), path + " -> " + r.body());
        }
        assertTrue(c.get("/student/quiz?lessonId=1").has("data-qid=\"1\""));
        assertTrue(c.get("/student/essay?lessonId=2").has("essayForm"));
        // trang không tồn tại / id sai chuyển về danh sách
        assertEquals(302, c.get("/student/lesson?id=9999").status());
        assertEquals(404, c.get("/khong-ton-tai").status());
        // học sinh không vào được khu vực Admin / Teacher
        assertEquals(403, c.get("/admin/dashboard").status());
        assertEquals(403, c.get("/teacher/questions").status());
        assertEquals(403, c.json("/api/teacher/generate-questions", "{}").status());
    }

    /** UC-STU-03: đề ngẫu nhiên (ORDER BY NEWID()), lọc mức độ, số câu 5–30; không còn nộp cả bài. */
    @Test
    @Order(11)
    void quizPageFiltersAndShufflesQuestions() throws Exception {
        Client c = new Client();
        c.login("student2", "123456");
        // Lọc mức độ: bài 1 có câu 1 (mức 2, x^3 - 3x) và câu 2 (mức 1, e^x)
        Resp easy = c.get("/student/quiz?lessonId=1&difficulty=1");
        assertTrue(easy.has("e^x") && !easy.has("x^3 - 3x"), "chỉ còn câu mức Dễ");
        Resp medium = c.get("/student/quiz?lessonId=1&difficulty=MEDIUM");
        assertTrue(medium.has("x^3 - 3x") && !medium.has("e^x"));
        assertTrue(c.get("/student/quiz?lessonId=1&difficulty=3").has("chưa có câu hỏi trắc nghiệm ở mức độ đã chọn"));

        // Xáo trộn: thứ tự câu thay đổi giữa các lần tải (xác suất trùng 20 lần liên tiếp ~ 1/2^19)
        java.util.Set<String> orders = new java.util.HashSet<>();
        java.util.regex.Pattern qid = java.util.regex.Pattern.compile("data-qid=\"(\\d+)\"");
        for (int i = 0; i < 20 && orders.size() < 2; i++) {
            java.util.regex.Matcher m = qid.matcher(c.get("/student/quiz?lessonId=1").body());
            StringBuilder order = new StringBuilder();
            while (m.find()) {
                order.append(m.group(1)).append(',');
            }
            orders.add(order.toString());
        }
        assertEquals(2, orders.size(), "thứ tự câu được xáo trộn: " + orders);

        // Số câu ép vào 5–30
        assertTrue(c.get("/student/quiz?lessonId=1&limit=1").has("<option value=\"5\" selected"));
        assertTrue(c.get("/student/quiz?lessonId=1&limit=99").has("<option value=\"30\" selected"));

        // Luồng nộp cả bài cũ đã gỡ (chấm từng câu qua API)
        int old = c.form("/student/quizSubmit", Map.of("lessonId", "1", "question_1", "A")).status();
        assertTrue(old == 404 || old == 405, "không còn /student/quizSubmit: " + old);

        // Lịch sử vẫn ghi từng câu đã nộp qua API
        assertEquals(200, c.json("/api/student/submit-quiz-answer", "{\"questionId\":2,\"selectedOptionId\":5}").status());
        assertTrue(c.get("/student/history?type=MCQ").has("e^x"));
    }

    @Test
    @Order(12)
    void quizAnswerApiReturnsExplanation() throws Exception {
        exec("UPDATE Questions SET ExplanationLatex = N'Lời giải $y''=3x^2-3$' WHERE QuestionId = 1");
        Client c = new Client();
        c.login("student3", "123456");
        // TC-SEC-08: trang làm bài không chứa lời giải / cờ đúng-sai (BR-11)
        Resp quizPage = c.get("/student/quiz?lessonId=1");
        assertFalse(quizPage.has("3x^2-3"), "chưa nộp thì không có nội dung lời giải (BR-11)");
        assertFalse(quizPage.has("correctOptionId\":"), "không có đáp án đúng nhúng sẵn trong trang");
        assertFalse(quizPage.has("IsCorrect"));
        Resp wrong = c.json("/api/student/submit-quiz-answer", "{\"questionId\":1,\"selectedOptionId\":2}");
        assertEquals(200, wrong.status(), wrong.body());
        JsonNode j = JSON.readTree(wrong.body());
        assertTrue(j.get("success").asBoolean());
        j = j.get("data");
        assertFalse(j.get("isCorrect").asBoolean());
        assertEquals("A", j.get("correctOptionLabel").asText());
        assertEquals(1, j.get("correctOptionId").asInt(), "id phương án đúng để tô xanh");
        assertTrue(j.get("explanationLatex").asText().contains("Lời giải"));
        assertEquals(0.0, j.get("score").asDouble());
        assertTrue(j.get("canAskTutor").asBoolean(), "sai → hiện nút Hỏi gia sư AI");

        Resp right = c.json("/api/student/submit-quiz-answer", "{\"questionId\":1,\"selectedOptionId\":1}");
        assertTrue(JSON.readTree(right.body()).get("data").get("isCorrect").asBoolean());
        assertFalse(JSON.readTree(right.body()).get("data").get("canAskTutor").asBoolean());
        assertEquals(10.0, JSON.readTree(right.body()).get("data").get("score").asDouble(), "đúng = 10 điểm (BR-07)");
        assertEquals(2, count("SELECT COUNT(*) FROM Submissions WHERE StudentId = 6 AND QuestionId = 1"));

        Resp mismatch = c.json("/api/student/submit-quiz-answer", "{\"questionId\":1,\"selectedOptionId\":5}");
        assertEquals(400, mismatch.status());
        assertTrue(JSON.readTree(mismatch.body()).get("message").asText().contains("không thuộc"));
        assertEquals(400, c.json("/api/student/submit-quiz-answer", "{\"questionId\":1}").status());
        assertEquals(400, c.json("/api/student/submit-quiz-answer", "{\"questionId\":999,\"selectedOptionId\":1}").status());
        // câu tự luận không chấm bằng API trắc nghiệm
        assertEquals(400, c.json("/api/student/submit-quiz-answer", "{\"questionId\":3,\"selectedOptionId\":1}").status());
    }

    @Test
    @Order(19)
    void missingApiKeyGivesFriendlyErrorWithoutCallingGemini() throws Exception {
        exec("UPDATE AiConfigs SET ConfigValue = '' WHERE ConfigKey = 'GEMINI_API_KEY'");
        try {
            Client c = new Client();
            c.login("student1", "123456");
            int before = geminiCalls;
            Resp r = c.json("/api/tutor/next-step", "{\"studentInput\":\"bài toán\"}");
            assertEquals(502, r.status(), r.body());
            assertTrue(JSON.readTree(r.body()).get("message").asText().contains("GEMINI_API_KEY"));
            assertEquals(before, geminiCalls, "không gọi Gemini khi chưa có key");
        } finally {
            exec("UPDATE AiConfigs SET ConfigValue = 'test-key-123' WHERE ConfigKey = 'GEMINI_API_KEY'");
        }
    }

    @Test
    @Order(20)
    void tutorWalksThroughStepsAndEnforcesPedagogy() throws Exception {
        Client c = new Client();
        c.login("student1", "123456");
        script.clear();
        // Lượt 1: AI "lỡ" trả completed=true ngay từ đầu -> bị từ chối, retry lấy bản hợp lệ
        script.add(new String[]{"200", tutorJson(true, 1, 3, true)});
        script.add(new String[]{"200", tutorJson(true, 1, 3, false)});
        int callsBefore = geminiCalls;
        Resp r1 = c.json("/api/tutor/next-step",
                "{\"sessionId\":null,\"lessonId\":1,\"studentInput\":\"Tính $\\\\int_0^1 x\\\\,dx$\",\"currentStep\":0}");
        assertEquals(200, r1.status(), r1.body());
        assertEquals(2, geminiCalls - callsBefore, "retry khi AI vi phạm quy tắc");
        JsonNode j1 = JSON.readTree(r1.body()).get("data");
        int sid = j1.get("sessionId").asInt();
        assertEquals(1, j1.get("currentStep").asInt());
        assertFalse(j1.get("isSessionCompleted").asBoolean());
        assertEquals(2, count("SELECT COUNT(*) FROM TutorMessages WHERE SessionId = ?", sid));
        assertEquals("ACTIVE", scalar("SELECT [Status] FROM TutorSessions WHERE SessionId = ?", sid));
        assertTrue(lastApiKey == null || lastApiKey.isEmpty() || !lastUri.contains("key="), "API key không nằm trên URL");

        // Lượt 2: trả lời SAI, AI cố nhảy sang bước 3 -> server giữ nguyên bước 1
        script.add(new String[]{"200", tutorJson(false, 3, 3, false)});
        Resp r2 = c.json("/api/tutor/next-step", "{\"sessionId\":" + sid + ",\"studentInput\":\"sai\",\"currentStep\":1}");
        JsonNode j2 = JSON.readTree(r2.body()).get("data");
        assertFalse(j2.get("isStepCorrect").asBoolean());
        assertEquals(1, j2.get("currentStep").asInt());
        // lịch sử được nạp làm ngữ cảnh cho Gemini (3 lượt trước + lượt mới)
        assertTrue(JSON.readTree(lastRequestBody).get("contents").size() >= 3);

        // Lượt 3: đúng -> bước 2
        script.add(new String[]{"200", tutorJson(true, 2, 3, false)});
        JsonNode j3 = JSON.readTree(c.json("/api/tutor/next-step",
                "{\"sessionId\":" + sid + ",\"studentInput\":\"đúng 1\",\"currentStep\":1}").body()).get("data");
        assertEquals(2, j3.get("currentStep").asInt());

        // Lượt 4: đúng -> bước 3; Lượt 5: đúng bước cuối -> hoàn thành
        script.add(new String[]{"200", tutorJson(true, 3, 3, false)});
        assertEquals(3, JSON.readTree(c.json("/api/tutor/next-step",
                "{\"sessionId\":" + sid + ",\"studentInput\":\"đúng 2\",\"currentStep\":2}").body()).get("data").get("currentStep").asInt());
        script.add(new String[]{"200", tutorJson(true, 3, 3, true)});
        JsonNode j5 = JSON.readTree(c.json("/api/tutor/next-step",
                "{\"sessionId\":" + sid + ",\"studentInput\":\"đúng 3\",\"currentStep\":3}").body()).get("data");
        assertTrue(j5.get("isSessionCompleted").asBoolean());
        assertEquals("COMPLETED", scalar("SELECT [Status] FROM TutorSessions WHERE SessionId = ?", sid));
        assertEquals(10, count("SELECT COUNT(*) FROM TutorMessages WHERE SessionId = ?", sid));

        // phiên đã kết thúc -> 409
        Resp r6 = c.json("/api/tutor/next-step", "{\"sessionId\":" + sid + ",\"studentInput\":\"nữa\",\"currentStep\":3}");
        assertEquals(409, r6.status());

        // xem lại phiên cũ trên trang
        Resp page = c.get("/student/ai-tutor?sessionId=" + sid);
        assertEquals(200, page.status());
        assertTrue(page.has("Nhận xét bước"));

        // TC-SEC-07 / BR-14: học sinh khác không truy cập được phiên này -> 403
        Client other = new Client();
        other.login("student2", "123456");
        assertEquals(403, other.json("/api/tutor/next-step",
                "{\"sessionId\":" + sid + ",\"studentInput\":\"x\",\"currentStep\":1}").status());
        assertEquals(403, other.get("/student/ai-tutor?sessionId=" + sid).status());
        // input rỗng
        assertEquals(400, c.json("/api/tutor/next-step", "{\"studentInput\":\"  \"}").status());
    }

    @Test
    @Order(21)
    void tutorFirstTurnFailureLeavesNoSession() throws Exception {
        Client c = new Client();
        c.login("student1", "123456");
        script.clear();
        for (int i = 0; i < 3; i++) {
            script.add(new String[]{"200", "khong phai json"});
        }
        int sessionsBefore = count("SELECT COUNT(*) FROM TutorSessions WHERE StudentId = 4");
        Resp r = c.json("/api/tutor/next-step", "{\"studentInput\":\"bài toán\"}");
        assertEquals(422, r.status(), r.body());
        assertTrue(JSON.readTree(r.body()).get("message").asText().contains("3 lần"));
        // Phiên chỉ được tạo SAU khi AI trả lời thành công nên không để lại phiên rỗng
        assertEquals(sessionsBefore, count("SELECT COUNT(*) FROM TutorSessions WHERE StudentId = 4"));
        script.clear();
    }

    /** FR-TUT-04 / BR-15 / TC-AI-05: AI dừng chờ dữ liệu; trạng thái lưu ở CSDL; lượt dữ liệu không bị chấm. */
    @Test
    @Order(22)
    void tutorWaitsForStudentDataAndKeepsServerState() throws Exception {
        Client c = new Client();
        c.login("student1", "123456");
        script.clear();
        // Lượt khởi đầu: đề thiếu hệ số → AI yêu cầu dữ liệu ngay
        script.add(new String[]{"200", tutorJsonFull(null, 1, 3, false, true, "Nhập các hệ số a, b, c")});
        Resp r1 = c.json("/api/tutor/start", "{\"mode\":\"FREE\",\"problemText\":\"Giải phương trình bậc hai\"}");
        assertEquals(200, r1.status(), r1.body());
        JsonNode j1 = JSON.readTree(r1.body()).get("data");
        int sid = j1.get("sessionId").asInt();
        assertTrue(j1.get("needsStudentInput").asBoolean());
        assertTrue(j1.get("isStepCorrect").isNull());
        assertEquals(1, count("SELECT CAST(AwaitingInput AS INT) FROM TutorSessions WHERE SessionId = ?", sid));
        assertEquals("Nhập các hệ số a, b, c", scalar("SELECT InputHint FROM TutorSessions WHERE SessionId = ?", sid));
        assertEquals(3, count("SELECT TotalSteps FROM TutorSessions WHERE SessionId = ?", sid));
        assertEquals("Giải phương trình bậc hai", scalar("SELECT ProblemText FROM TutorSessions WHERE SessionId = ?", sid));
        String sys = JSON.readTree(lastRequestBody).path("system_instruction").path("parts").path(0).path("text").asText();
        assertTrue(sys.contains("TRẠNG THÁI PHIÊN") && sys.contains("KHỞI ĐẦU"), sys);

        // Mở lại phiên: giao diện dựng lại đúng trạng thái chờ dữ liệu từ CSDL
        Resp page = c.get("/student/ai-tutor?sessionId=" + sid);
        assertTrue(page.has("Gia sư cần bạn cung cấp dữ liệu") && page.has("Nhập các hệ số a, b, c"));

        // Lượt dữ liệu: AI (sai sót) báo "sai" và nhảy bước → server KHÔNG chấm, KHÔNG chuyển bước, hết chờ dữ liệu
        script.add(new String[]{"200", tutorJsonFull(false, 3, 5, false, false, null)});
        JsonNode j2 = JSON.readTree(c.json("/api/tutor/next-step",
                "{\"sessionId\":" + sid + ",\"studentInput\":\"a=1, b=-3, c=2\",\"currentStep\":3}").body()).get("data");
        assertTrue(lastRequestBody.contains("Dữ liệu học sinh cung cấp cho bước 1"), "lượt mới gắn nhãn dữ liệu");
        assertTrue(j2.get("isStepCorrect").isNull());
        assertEquals(1, j2.get("currentStep").asInt());
        assertEquals(3, j2.get("totalSteps").asInt(), "tổng số bước giữ nguyên");
        assertEquals(0, count("SELECT CAST(AwaitingInput AS INT) FROM TutorSessions WHERE SessionId = ?", sid));
        assertNull(scalar("SELECT InputHint FROM TutorSessions WHERE SessionId = ?", sid));

        // Lượt trả lời đúng → bước 2; AI báo hoàn thành sớm → bị bỏ qua
        script.add(new String[]{"200", tutorJsonFull(true, 2, 3, true, false, null)});
        JsonNode j3 = JSON.readTree(c.json("/api/tutor/next-step",
                "{\"sessionId\":" + sid + ",\"studentInput\":\"Delta = 1\"}").body()).get("data");
        assertTrue(lastRequestBody.contains("Câu trả lời của học sinh cho bước 1"));
        assertEquals(2, j3.get("currentStep").asInt());
        assertEquals("ACTIVE", j3.get("status").asText());
        assertTrue(j3.get("finalSummary").isNull(), "chưa được nêu đáp án cuối");
        assertEquals(2, count("SELECT CurrentStep FROM TutorSessions WHERE SessionId = ?", sid));

        // UC-TUT-04: học sinh khác không kết thúc được; chủ phiên kết thúc → ABANDONED, không trả lời tiếp được
        Client other = new Client();
        other.login("student2", "123456");
        assertEquals(403, other.json("/api/tutor/" + sid + "/abandon", "{}").status());
        Resp ab = c.json("/api/tutor/" + sid + "/abandon", "{}");
        assertEquals(200, ab.status(), ab.body());
        assertEquals("ABANDONED", scalar("SELECT [Status] FROM TutorSessions WHERE SessionId = ?", sid));
        assertEquals(409, c.json("/api/tutor/" + sid + "/abandon", "{}").status());
        assertEquals(409, c.json("/api/tutor/next-step", "{\"sessionId\":" + sid + ",\"studentInput\":\"x\"}").status());
        script.clear();
    }

    /** FR-STU-05 / FR-TUT-01 (c): mở gia sư từ câu trắc nghiệm vừa làm sai; chưa làm sai thì 403. */
    @Test
    @Order(23)
    void tutorStartsFromWrongMultipleChoiceQuestion() throws Exception {
        Client c = new Client();
        c.login("student2", "123456");
        int studentId = count("SELECT UserId FROM Users WHERE Username = 'student2'");
        exec("DELETE FROM Submissions WHERE StudentId = ? AND QuestionId = 1", studentId);
        exec("UPDATE Questions SET ExplanationLatex = N'Lời giải nội bộ it' WHERE QuestionId = 1");
        script.clear();
        try {
            assertEquals(403, c.json("/api/tutor/start", "{\"mode\":\"QUESTION\",\"questionId\":1}").status(),
                    "chưa có bài nộp sai câu này");
            assertEquals(200, c.json("/api/student/submit-quiz-answer", "{\"questionId\":1,\"selectedOptionId\":2}").status());
            script.add(new String[]{"200", tutorJsonFull(null, 1, 4, false, false, null)});
            Resp r = c.json("/api/tutor/start", "{\"mode\":\"QUESTION\",\"questionId\":1}");
            assertEquals(200, r.status(), r.body());
            int sid = JSON.readTree(r.body()).get("data").get("sessionId").asInt();
            assertEquals(1, count("SELECT QuestionId FROM TutorSessions WHERE SessionId = ?", sid));
            assertTrue(((String) scalar("SELECT ProblemText FROM TutorSessions WHERE SessionId = ?", sid))
                    .contains("Học sinh đã chọn: B."), "đề kèm phương án học sinh đã chọn");
            String sys = JSON.readTree(lastRequestBody).path("system_instruction").path("parts").path(0).path("text").asText();
            assertTrue(sys.contains("Lời giải nội bộ it") && sys.contains("KHÔNG tiết lộ"), "lời giải là tài liệu nội bộ");
            // Trang kết quả có nút mở gia sư cho câu sai
            assertTrue(c.get("/student/ai-tutor?mode=QUESTION&questionId=1").has("pendingStart = {"));
        } finally {
            exec("UPDATE Questions SET ExplanationLatex = NULL WHERE QuestionId = 1");
            script.clear();
        }
    }

    @Test
    @Order(30)
    void essayOcrGradesImageAndStoresSubmission() throws Exception {
        exec("UPDATE AiConfigs SET ConfigValue = 'test-key-123' WHERE ConfigKey = 'GEMINI_API_KEY'");
        Client c = new Client();
        c.login("student1", "123456");
        script.clear();

        Resp r = c.multipart("/api/student/submit-essay-ocr", Map.of("questionId", "3"), "essayImage", "bai.png",
                "image/png", PNG);
        assertEquals(200, r.status(), r.body());
        JsonNode envelope = JSON.readTree(r.body());
        assertTrue(envelope.get("success").asBoolean());
        JsonNode j = envelope.get("data");
        assertEquals(7.5, j.get("score").asDouble(), "7.4 làm tròn tới 0.25");
        assertEquals("$y=x^2$", j.get("extractedText").asText());
        String url = j.get("imageUrl").asText();
        assertTrue(url.startsWith("/uploads/") && url.endsWith(".png"), url);
        assertTrue(Files.exists(uploadDir.resolve(url.substring("/uploads/".length()))));
        // SRS 6.3: ảnh lưu theo thư mục học sinh essays/{studentId}/{uuid}.{ext}
        int studentId = count("SELECT UserId FROM Users WHERE Username = 'student1'");
        assertTrue(url.startsWith("/uploads/essays/" + studentId + "/"), url);
        // UC-OCR-02: trả trạng thái chờ duyệt và cờ gia sư; lời giải gợi ý lưu ở cột riêng
        assertEquals("AI_GRADED", j.get("status").asText());
        assertTrue(j.has("errors") && j.has("canAskTutor"));
        assertEquals("$x=1$", scalar("SELECT SuggestedCorrection FROM Submissions WHERE SubmissionId = ?",
                j.get("submissionId").asInt()));

        // Payload gửi Gemini: ảnh Base64 + đề bài, dùng VISION_MODEL, key ở header
        JsonNode sent = JSON.readTree(lastRequestBody);
        assertTrue(sent.toString().contains("inline_data"));
        assertTrue(sent.toString().contains("image/png"));
        assertTrue(lastUri.contains("gemini-1.5-pro"), lastUri);
        assertEquals("test-key-123", lastApiKey);
        assertEquals("application/json", sent.get("generationConfig").get("response_mime_type").asText());
        assertEquals(2048, Math.min(2048, sent.get("generationConfig").get("maxOutputTokens").asInt()));

        // Lưu Submissions
        int sid = j.get("submissionId").asInt();
        assertEquals("ESSAY", scalar("SELECT QuestionType FROM Submissions WHERE SubmissionId = ?", sid));
        assertEquals(url, scalar("SELECT EssayImagePath FROM Submissions WHERE SubmissionId = ?", sid));
        assertTrue(((String) scalar("SELECT AiFeedback FROM Submissions WHERE SubmissionId = ?", sid)).contains("Sai dấu"));
        assertEquals(0, count("SELECT CAST(IsReviewed AS INT) FROM Submissions WHERE SubmissionId = ?", sid));
        assertEquals(7.5, ((Number) scalar("SELECT AiScore FROM Submissions WHERE SubmissionId = ?", sid)).doubleValue());
        assertEquals(7.5, ((Number) scalar("SELECT FinalScore FROM Submissions WHERE SubmissionId = ?", sid)).doubleValue(),
                "final_score ban đầu = ai_score");
        assertEquals("AI_GRADED", scalar("SELECT [Status] FROM Submissions WHERE SubmissionId = ?", sid));

        // Ảnh chỉ phục vụ cho chủ bài / giáo viên / admin (TC-SEC-07); người ẩn danh bị chuyển về /login
        Resp img = c.get(url);
        assertEquals(200, img.status());
        assertEquals(404, c.get("/uploads/essays/" + studentId + "/khong-co.png").status());

        // TC-OCR-03: AI báo không đọc được → 422, KHÔNG lưu bài làm, KHÔNG lưu ảnh
        int subsBefore = count("SELECT COUNT(*) FROM Submissions WHERE StudentId = ?", studentId);
        long filesBefore;
        try (java.util.stream.Stream<java.nio.file.Path> f = Files.walk(uploadDir)) {
            filesBefore = f.filter(Files::isRegularFile).count();
        }
        script.add(new String[]{"200", "{\"legible\":false,\"extractedText\":\"\",\"score\":0,"
                + "\"detailedFeedback\":\"Ảnh mờ\",\"errors\":[],\"suggestedCorrection\":\"\"}"});
        Resp blurry = c.multipart("/api/student/submit-essay-ocr", Map.of("questionId", "3"), "essayImage", "mo.png",
                "image/png", PNG);
        assertEquals(422, blurry.status(), blurry.body());
        assertTrue(blurry.has("Không đọc được bài làm"), blurry.body());
        assertEquals(subsBefore, count("SELECT COUNT(*) FROM Submissions WHERE StudentId = ?", studentId));
        try (java.util.stream.Stream<java.nio.file.Path> f = Files.walk(uploadDir)) {
            assertEquals(filesBefore, f.filter(Files::isRegularFile).count(), "không lưu ảnh khi không đọc được");
        }

        // VAL-18: WebP được chấp nhận, lưu đuôi .webp, phục vụ đúng Content-Type
        Resp webp = c.multipart("/api/student/submit-essay-ocr", Map.of("questionId", "3"), "essayImage", "bai.webp",
                "image/webp", webpLossless(800, 600));
        assertEquals(200, webp.status(), webp.body());
        String webpUrl = JSON.readTree(webp.body()).get("data").get("imageUrl").asText();
        assertTrue(webpUrl.startsWith("/uploads/essays/" + studentId + "/") && webpUrl.endsWith(".webp"), webpUrl);
        assertTrue(lastRequestBody.contains("image/webp"), "gửi Gemini đúng MIME");
        Resp webpImg = c.get(webpUrl);
        assertEquals(200, webpImg.status());
        assertTrue(webpImg.contentType().startsWith("image/webp"), webpImg.contentType());
        // VAL-18: ảnh vượt 4096×4096 bị từ chối trước khi gọi AI
        int callsBefore = geminiCalls;
        Resp huge = c.multipart("/api/student/submit-essay-ocr", Map.of("questionId", "3"), "essayImage", "to.png",
                "image/png", image("png", 4097, 10));
        assertEquals(400, huge.status(), huge.body());
        assertTrue(huge.has("4096"), huge.body());
        assertEquals(callsBefore, geminiCalls, "không gọi AI với ảnh không hợp lệ");
        assertEquals(302, new Client().get(url).status());
        Client otherStudent = new Client();
        otherStudent.login("student2", "123456");
        assertEquals(403, otherStudent.get(url).status());
        Client teacher = new Client();
        teacher.login("teacher1", "123456");
        assertEquals(200, teacher.get(url).status());
        assertEquals(404, c.get("/uploads/khong-co-anh.png").status());

        // Đầu vào không hợp lệ
        assertEquals(400, c.multipart("/api/student/submit-essay-ocr", Map.of("questionId", "3"), "essayImage",
                "a.png", "image/png", "day khong phai anh".getBytes(StandardCharsets.UTF_8)).status());
        assertEquals(400, c.multipart("/api/student/submit-essay-ocr", Map.of("questionId", "3"), "x", "y", "z",
                null).status());
        byte[] big = new byte[5 * 1024 * 1024 + 10];
        System.arraycopy(PNG, 0, big, 0, PNG.length);
        Resp tooBig = c.multipart("/api/student/submit-essay-ocr", Map.of("questionId", "3"), "essayImage", "b.png",
                "image/png", big);
        assertEquals(400, tooBig.status(), tooBig.body());
        assertTrue(tooBig.has("5MB"));
        // câu hỏi trắc nghiệm không dùng API tự luận
        assertEquals(400, c.multipart("/api/student/submit-essay-ocr", Map.of("questionId", "1"), "essayImage", "a.png",
                "image/png", PNG).status());

        // Chỉ nhập văn bản (không ảnh) vẫn chấm được
        script.add(new String[]{"200", "{\"extractedText\":\"x\",\"score\":\"9\",\"detailedFeedback\":\"tốt\","
                + "\"suggestedCorrection\":\"\"}"});
        Resp t = c.multipart("/api/student/submit-essay-ocr", Map.of("questionId", "3", "studentAnswer", "Lời giải $x$"),
                "x", "y", "z", null);
        assertEquals(200, t.status(), t.body());
        assertTrue(JSON.readTree(t.body()).get("data").get("imageUrl").isNull());
        assertTrue(lastUri.contains("gemini-1.5-flash"), "không ảnh dùng DEFAULT_MODEL: " + lastUri);
    }

    @Test
    @Order(31)
    void aiHttpErrorsAreTranslatedAndTransientOnesRetried() throws Exception {
        Client c = new Client();
        c.login("student1", "123456");
        // 400 từ Gemini: không retry
        script.clear();
        script.add(new String[]{"400", "API key not valid"});
        int before = geminiCalls;
        Resp bad = c.json("/api/tutor/next-step", "{\"studentInput\":\"x\"}");
        assertEquals(502, bad.status());
        assertTrue(bad.has("API key not valid"));
        assertEquals(1, geminiCalls - before);
        // 503 rồi thành công: retry
        script.clear();
        script.add(new String[]{"503", "overloaded"});
        script.add(new String[]{"200", tutorJson(true, 1, 4, false)});
        before = geminiCalls;
        Resp ok = c.json("/api/tutor/next-step", "{\"studentInput\":\"bài mới\"}");
        assertEquals(200, ok.status(), ok.body());
        assertEquals(2, geminiCalls - before);
        script.clear();
    }

    /** FR-OCR-04 / FR-TUT-01 (d): mở gia sư từ bài tự luận vừa chấm; bài của người khác → 403. */
    @Test
    @Order(31)
    void tutorStartsFromGradedEssaySubmission() throws Exception {
        int essayId = count("SELECT TOP 1 s.SubmissionId FROM Submissions s JOIN Users u ON u.UserId = s.StudentId "
                + "WHERE u.Username = 'student1' AND s.QuestionType = 'ESSAY' ORDER BY s.SubmissionId DESC");
        assertTrue(essayId > 0, "cần bài tự luận từ bài test chấm OCR");
        Client other = new Client();
        other.login("student2", "123456");
        assertEquals(403, other.json("/api/tutor/start",
                "{\"mode\":\"SUBMISSION\",\"submissionId\":" + essayId + "}").status());

        Client c = new Client();
        c.login("student1", "123456");
        script.clear();
        script.add(new String[]{"200", tutorJsonFull(null, 1, 3, false, false, null)});
        Resp r = c.json("/api/tutor/start", "{\"mode\":\"SUBMISSION\",\"submissionId\":" + essayId + "}");
        assertEquals(200, r.status(), r.body());
        int sid = JSON.readTree(r.body()).get("data").get("sessionId").asInt();
        String problem = (String) scalar("SELECT ProblemText FROM TutorSessions WHERE SessionId = ?", sid);
        assertTrue(problem.contains("Bài làm của học sinh") && problem.contains("Nhận xét khi chấm bài"), problem);
        assertTrue(count("SELECT QuestionId FROM TutorSessions WHERE SessionId = ?", sid) > 0);
        // Chế độ không hợp lệ / thiếu dữ liệu → 400
        assertEquals(400, c.json("/api/tutor/start", "{\"mode\":\"HACK\",\"problemText\":\"x\"}").status());
        assertEquals(400, c.json("/api/tutor/start", "{\"mode\":\"FREE\"}").status());
        script.clear();
    }

    // ---------------------------------------------------------------- ADMIN

    @Test
    @Order(40)
    void adminPagesAndAiConfig() throws Exception {
        Client c = new Client();
        assertEquals(302, c.login("admin", "123456").status());
        for (String p : new String[]{"/admin/dashboard", "/admin/users", "/admin/users/new", "/admin/users/4/edit", "/admin/topics",
                "/admin/lessons", "/admin/questions", "/admin/ai-config"}) {
            Resp r = c.get(p);
            assertEquals(200, r.status(), p + " -> " + r.body());
        }
        // FR-ADM-08: dashboard có đủ các nhóm số liệu
        Resp dash = c.get("/admin/dashboard");
        for (String label : new String[]{"Người dùng theo vai trò và trạng thái", "do AI sinh", "Phiên gia sư AI đã tạo",
                "Bài tự luận chấm qua AI", "chờ duyệt", "Lượt làm bài 7 ngày gần nhất"}) {
            assertTrue(dash.has(label), "dashboard thiếu: " + label);
        }
        assertEquals(7, dash.body().split("class=\"week-col\"", -1).length - 1, "đủ 7 cột ngày");

        Resp cfg = c.get("/admin/ai-config");
        assertFalse(cfg.has("test-key-123"), "không in API key ra HTML");
        assertTrue(cfg.has("test****-123"), "NFR-05: khóa hiển thị dạng che");
        for (String key : new String[]{"QUIZ_TEMPERATURE", "GRADING_TEMPERATURE", "TUTOR_MIN_STEPS", "TUTOR_MAX_STEPS",
                "AI_TIMEOUT_SECONDS", "AI_RATE_LIMIT_PER_HOUR", "AI_RATE_LIMIT_TEACHER_PER_HOUR",
                "TUTOR_SYSTEM_PROMPT", "QUIZ_GEN_PROMPT", "GRADING_PROMPT"}) {
            assertTrue(cfg.has("name=\"" + key + "\""), "FR-ADM-06: form có ô " + key);
        }

        // Cập nhật: để trống API key => giữ nguyên; temperature hợp lệ => lưu
        Resp up = c.form("/admin/ai-config/update", Map.of("GEMINI_API_KEY", "", "DEFAULT_MODEL", "gemini-2.0-flash",
                "VISION_MODEL", "gemini-1.5-pro", "TUTOR_TEMPERATURE", "0.5", "MAX_OUTPUT_TOKENS", "3000"));
        assertEquals(302, up.status());
        assertEquals("test-key-123", scalar("SELECT ConfigValue FROM AiConfigs WHERE ConfigKey = 'GEMINI_API_KEY'"));
        assertEquals("gemini-2.0-flash", scalar("SELECT ConfigValue FROM AiConfigs WHERE ConfigKey = 'DEFAULT_MODEL'"));
        assertEquals("0.5", scalar("SELECT ConfigValue FROM AiConfigs WHERE ConfigKey = 'TUTOR_TEMPERATURE'"));
        assertEquals(1, scalar("SELECT UpdatedBy FROM AiConfigs WHERE ConfigKey = 'DEFAULT_MODEL'"));
        assertTrue(c.get("/admin/ai-config").has("Cập nhật cấu hình AI thành công"));

        // Cấu hình mới có hiệu lực ngay (không restart): model + temperature + maxTokens đi vào request Gemini
        script.clear();
        Client st = new Client();
        st.login("student1", "123456");
        st.json("/api/tutor/next-step", "{\"studentInput\":\"kiểm tra cấu hình\"}");
        assertTrue(lastUri.contains("gemini-2.0-flash"), lastUri);
        JsonNode gen = JSON.readTree(lastRequestBody).get("generationConfig");
        assertEquals(0.5, gen.get("temperature").asDouble());
        assertEquals(3000, gen.get("maxOutputTokens").asInt());

        // Giá trị sai bị từ chối, DB không đổi
        c.form("/admin/ai-config/update", Map.of("TUTOR_TEMPERATURE", "5"));
        assertEquals("0.5", scalar("SELECT ConfigValue FROM AiConfigs WHERE ConfigKey = 'TUTOR_TEMPERATURE'"));
        assertTrue(c.get("/admin/ai-config").has("0.0 đến 1.0"));
        // khóa lạ bị bỏ qua
        c.form("/admin/ai-config/update", Map.of("EVIL_KEY", "x"));
        c.get("/admin/ai-config"); // đọc flash của lần lưu trên để không lẫn với lần sau

        // VAL-15: số bước tối thiểu > tối đa bị từ chối; VAL-17: prompt thiếu placeholder bị từ chối
        c.form("/admin/ai-config/update", Map.of("TUTOR_MIN_STEPS", "8", "TUTOR_MAX_STEPS", "4"));
        assertEquals("3", scalar("SELECT ConfigValue FROM AiConfigs WHERE ConfigKey = 'TUTOR_MIN_STEPS'"));
        assertTrue(c.get("/admin/ai-config").has("không được lớn hơn"));
        String oldPrompt = (String) scalar("SELECT ConfigValue FROM AiConfigs WHERE ConfigKey = 'TUTOR_SYSTEM_PROMPT'");
        c.form("/admin/ai-config/update", Map.of("TUTOR_SYSTEM_PROMPT", "Gia sư từng bước, không có placeholder"));
        assertEquals(oldPrompt, scalar("SELECT ConfigValue FROM AiConfigs WHERE ConfigKey = 'TUTOR_SYSTEM_PROMPT'"));
        Resp afterBad = c.get("/admin/ai-config");
        assertTrue(afterBad.has("thiếu placeholder"), "lỗi hiện tại trường prompt");
        assertTrue(afterBad.has("không có placeholder"), "giữ lại nội dung vừa nhập để sửa");

        // Prompt + số bước + nhiệt độ cấu hình được và đi vào request Gemini; phần chốt cố định luôn được nối
        String custom = "PROMPT_IT gia sư từng bước, chia {{MIN_STEPS}}-{{MAX_STEPS}} bước";
        Resp savedPrompt = c.form("/admin/ai-config/update",
                Map.of("TUTOR_SYSTEM_PROMPT", custom, "TUTOR_MIN_STEPS", "2", "TUTOR_MAX_STEPS", "4"));
        assertEquals(302, savedPrompt.status());
        script.clear();
        st.json("/api/tutor/next-step", "{\"studentInput\":\"kiểm tra prompt\"}");
        String sys = JSON.readTree(lastRequestBody).path("system_instruction").path("parts").path(0).path("text").asText();
        assertTrue(sys.contains("PROMPT_IT gia sư từng bước, chia 2-4 bước"), sys);
        assertTrue(sys.contains("QUY TẮC CỐ ĐỊNH"), "FRS 4.4: phần chốt cố định");
        assertTrue(sys.contains("isStepCorrect"), "cấu trúc JSON do ứng dụng nối vào");
        exec("UPDATE AiConfigs SET ConfigValue = ? WHERE ConfigKey = 'TUTOR_SYSTEM_PROMPT'", oldPrompt);
        exec("UPDATE AiConfigs SET ConfigValue = '3' WHERE ConfigKey = 'TUTOR_MIN_STEPS'");
        exec("UPDATE AiConfigs SET ConfigValue = '6' WHERE ConfigKey = 'TUTOR_MAX_STEPS'");

        // Test connection (UC-ADM-07)
        Resp ping2 = c.form("/api/admin/ai-config/test-connection", Map.of("DEFAULT_MODEL", "gemini-1.5-flash"));
        assertEquals(200, ping2.status(), ping2.body());
        assertTrue(JSON.readTree(ping2.body()).get("success").asBoolean(), ping2.body());
        assertTrue(lastRequestBody.contains("Ping"));
        script.add(new String[]{"403", "Permission denied"});
        Resp fail = c.form("/api/admin/ai-config/test-connection", Map.of("GEMINI_API_KEY", "sai"));
        assertFalse(JSON.readTree(fail.body()).get("success").asBoolean());
        assertTrue(fail.has("không hợp lệ"), fail.body());
        // giáo viên không được test kết nối / vào cấu hình AI -> 403 (TC-SEC-02)
        Client tch = new Client();
        tch.login("teacher1", "123456");
        assertEquals(403, tch.form("/api/admin/ai-config/test-connection", Map.of()).status());
        assertEquals(403, tch.get("/admin/ai-config").status());
        exec("UPDATE AiConfigs SET ConfigValue = 'gemini-1.5-flash' WHERE ConfigKey = 'DEFAULT_MODEL'");
        exec("UPDATE AiConfigs SET ConfigValue = '0.2' WHERE ConfigKey = 'TUTOR_TEMPERATURE'");
        exec("UPDATE AiConfigs SET ConfigValue = '2048' WHERE ConfigKey = 'MAX_OUTPUT_TOKENS'");
    }

    @Test
    @Order(41)
    void adminLocksAndUnlocksAccounts() throws Exception {
        Client c = new Client();
        c.login("admin", "123456");
        // đường dẫn cũ chuyển sang danh sách chung đã lọc
        Resp oldUrl = c.get("/admin/students");
        assertEquals(302, oldUrl.status());
        assertTrue(oldUrl.location().contains("/admin/users?role=STUDENT"), oldUrl.location());

        assertEquals(1, count("SELECT CAST(IsActive AS INT) FROM Users WHERE Username = 'student5'"));
        Client victim = new Client();
        victim.login("student5", "123456");
        assertEquals(200, victim.get("/student/dashboard").status());

        Resp t = c.form("/admin/users/8/status", Map.of("status", "SUSPENDED", "returnUrl", "/edututor/admin/users?role=STUDENT&page=1"));
        assertEquals(302, t.status());
        assertTrue(t.location().contains("/admin/users?role=STUDENT"), t.location());
        assertEquals(0, count("SELECT CAST(IsActive AS INT) FROM Users WHERE Username = 'student5'"));
        assertEquals("SUSPENDED", scalar("SELECT [Status] FROM Users WHERE Username = 'student5'"));
        assertTrue(c.get("/admin/users?role=STUDENT&page=1").has("Đã khóa tài khoản student5"));
        // BR-01: tài khoản đang đăng nhập bị chặn ngay ở request kế tiếp
        Resp locked = victim.get("/student/dashboard");
        assertEquals(302, locked.status());
        assertTrue(locked.location().contains("locked=1"), locked.location());
        assertTrue(new Client().login("student5", "123456").has("khóa"));

        c.form("/admin/users/8/status", Map.of("status", "ACTIVE"));
        assertEquals("ACTIVE", scalar("SELECT [Status] FROM Users WHERE Username = 'student5'"));
        assertEquals(1, count("SELECT CAST(IsActive AS INT) FROM Users WHERE Username = 'student5'"));
        c.get("/admin/users"); // tiêu thụ flash

        // không tự khóa chính mình (BR-02)
        Resp self = c.form("/admin/users/1/status", Map.of("status", "SUSPENDED"));
        assertEquals(302, self.status());
        assertEquals("ACTIVE", scalar("SELECT [Status] FROM Users WHERE Username = 'admin'"));
        assertTrue(c.get("/admin/users").has("không thể tự khóa"));
        // returnUrl bên ngoài bị bỏ qua (chống open redirect)
        Resp evil = c.form("/admin/users/8/status", Map.of("status", "ACTIVE", "returnUrl", "https://evil.com/"));
        assertTrue(evil.location().endsWith("/admin/users"), evil.location());
        c.get("/admin/users");
        // trạng thái lạ bị từ chối
        c.form("/admin/users/8/status", Map.of("status", "INACTIVE"));
        assertEquals("ACTIVE", scalar("SELECT [Status] FROM Users WHERE Username = 'student5'"));
        c.get("/admin/users");
        // giáo viên không được khóa (TC-SEC)
        Client t1 = new Client();
        t1.login("teacher1", "123456");
        assertEquals(403, t1.form("/admin/users/8/status", Map.of("status", "SUSPENDED")).status());
        assertEquals(403, t1.get("/admin/users").status());
    }

    @Test
    @Order(42)
    void adminManagesUsersSearchCreateEditDeleteResetPassword() throws Exception {
        Client c = new Client();
        c.login("admin", "123456");

        // UC-ADM-01: tìm kiếm / lọc / phân trang
        Resp all = c.get("/admin/users");
        assertEquals(200, all.status());
        assertTrue(all.has("student1") && all.has("teacher1"));
        Resp byKeyword = c.get("/admin/users?keyword=ho%C3%A0ng");
        assertTrue(byKeyword.has("student5") && !byKeyword.has("teacher1"), "tìm theo họ tên không phân biệt hoa thường");
        assertTrue(c.get("/admin/users?keyword=st3%40example").has("student3"), "tìm theo email");
        Resp teachers = c.get("/admin/users?role=TEACHER");
        assertTrue(teachers.has("teacher1") && teachers.has("teacher2") && !teachers.has("student1"));
        assertFalse(c.get("/admin/users?status=SUSPENDED").has("student1"));
        // ký tự đặc biệt của LIKE được thoát, không làm lỗi và không khớp mọi dòng
        Resp wildcard = c.get("/admin/users?keyword=%25_%5B");
        assertEquals(200, wildcard.status());
        assertFalse(wildcard.has("student1"));
        Resp paged = c.get("/admin/users?size=10&page=1");
        assertEquals(200, paged.status());
        assertEquals(200, c.get("/admin/users?size=7&page=-3").status(), "tham số phân trang sai dùng mặc định");

        // UC-ADM-02: tạo tài khoản — validation tại từng trường
        int before = count("SELECT COUNT(*) FROM Users");
        Resp bad = c.form("/admin/users", Map.of("username", "ab", "password", "123", "fullName", "x",
                "email", "sai", "role", "TEACHER"));
        assertEquals(200, bad.status());
        assertTrue(bad.has("Tên đăng nhập phải từ 4-30 ký tự") && bad.has("Mật khẩu phải từ 8 đến 64 ký tự"), bad.body());
        assertEquals(before, count("SELECT COUNT(*) FROM Users"));
        assertTrue(c.form("/admin/users", Map.of("username", "student1", "password", "Abcdef12",
                "fullName", "Trùng tên", "email", "it_dup@example.com", "role", "TEACHER")).has("đã được sử dụng"));
        assertTrue(c.form("/admin/users", Map.of("username", "it_gv1", "password", "Abcdef12",
                "fullName", "Trùng email", "email", "st1@example.com", "role", "TEACHER")).has("Email đã được đăng ký"));
        assertEquals(200, c.form("/admin/users", Map.of("username", "it_gv1", "password", "Abcdef12",
                "fullName", "Vai trò lạ", "email", "it_gv1@example.com", "role", "SUPERMAN")).status());
        assertEquals(before, count("SELECT COUNT(*) FROM Users"));

        assertEquals(302, c.form("/admin/users", Map.of("username", "it_gv1", "password", "Abcdef12",
                "fullName", "Giáo viên thử", "email", "it_gv1@example.com", "role", "TEACHER")).status());
        assertEquals("TEACHER", scalar("SELECT [Role] FROM Users WHERE Username = 'it_gv1'"));
        assertEquals("ACTIVE", scalar("SELECT [Status] FROM Users WHERE Username = 'it_gv1'"));
        assertTrue(((String) scalar("SELECT PasswordHash FROM Users WHERE Username = 'it_gv1'")).startsWith("$2"));
        assertTrue(c.get("/admin/users").has("Đã tạo tài khoản it_gv1"));
        Client newTeacher = new Client();
        assertEquals(302, newTeacher.login("it_gv1", "Abcdef12").status());
        assertTrue(newTeacher.get("/teacher/dashboard").status() == 200);
        int gv1 = count("SELECT UserId FROM Users WHERE Username = 'it_gv1'");

        // UC-ADM-03: sửa
        assertEquals(200, c.get("/admin/users/" + gv1 + "/edit").status());
        assertEquals(404, c.get("/admin/users/99999/edit").status());
        assertEquals(302, c.form("/admin/users/" + gv1, Map.of("fullName", "Giáo viên đã sửa",
                "email", "it_gv1_new@example.com", "role", "STUDENT", "status", "ACTIVE")).status());
        assertEquals("STUDENT", scalar("SELECT [Role] FROM Users WHERE UserId = ?", gv1));
        assertEquals("it_gv1_new@example.com", scalar("SELECT Email FROM Users WHERE UserId = ?", gv1));
        assertEquals("it_gv1", scalar("SELECT Username FROM Users WHERE UserId = ?", gv1), "username bất biến");
        c.get("/admin/users");
        Resp dupEmail = c.form("/admin/users/" + gv1, Map.of("fullName", "A B", "email", "st2@example.com",
                "role", "STUDENT", "status", "ACTIVE"));
        assertEquals(200, dupEmail.status());
        assertTrue(dupEmail.has("Email đã được đăng ký"));
        assertEquals(200, c.form("/admin/users/" + gv1, Map.of("fullName", "A B", "email", "ok@example.com",
                "role", "STUDENT", "status", "INACTIVE")).status(), "không chọn được INACTIVE khi sửa");
        // BR-02: không tự đổi vai trò / tự khóa mình
        c.form("/admin/users/1", Map.of("fullName", "System Admin", "email", "admin@mathtutor.com",
                "role", "STUDENT", "status", "ACTIVE"));
        assertEquals("ADMIN", scalar("SELECT [Role] FROM Users WHERE UserId = 1"));
        c.get("/admin/users");

        // UC-ADM-05: đặt lại mật khẩu — hiển thị một lần
        Resp reset = c.form("/admin/users/" + gv1 + "/reset-password", Map.of());
        assertEquals(200, reset.status());
        java.util.regex.Matcher m = java.util.regex.Pattern.compile("id=\"newPassword\"\\s+value=\"([A-Za-z0-9]{10})\"").matcher(reset.body());
        assertTrue(m.find(), "mật khẩu mới 10 ký tự hiển thị trên trang kết quả");
        String newPassword = m.group(1);
        assertTrue(newPassword.matches(".*[A-Za-z].*") && newPassword.matches(".*\\d.*"), "có cả chữ và số (VAL-02)");
        assertFalse(c.get("/admin/users/" + gv1 + "/edit").has(newPassword), "không hiển thị lại");
        assertTrue(new Client().login("it_gv1", "Abcdef12").has("sai"), "mật khẩu cũ không còn dùng được");
        assertEquals(302, new Client().login("it_gv1", newPassword).status());
        assertEquals(404, c.form("/admin/users/99999/reset-password", Map.of()).status());

        // UC-ADM-04: xóa — cứng khi chưa có dữ liệu, mềm khi đã có
        assertEquals(302, c.form("/admin/users/" + gv1 + "/delete", Map.of()).status());
        assertEquals(0, count("SELECT COUNT(*) FROM Users WHERE UserId = ?", gv1), "xóa cứng");
        assertTrue(c.get("/admin/users").has("Đã xóa tài khoản"));

        int s4 = count("SELECT UserId FROM Users WHERE Username = 'student4'");
        exec("INSERT INTO Submissions (StudentId, LessonId, QuestionId, QuestionType, StudentAnswer, IsCorrect, FinalScore, IsReviewed) "
                + "VALUES (?, 1, 1, 'MCQ', 'A', 1, 10, 1)", s4);
        assertEquals(302, c.form("/admin/users/" + s4 + "/delete", Map.of()).status());
        assertEquals("INACTIVE", scalar("SELECT [Status] FROM Users WHERE UserId = ?", s4), "xóa mềm vì đã có bài làm");
        assertEquals(0, count("SELECT CAST(IsActive AS INT) FROM Users WHERE UserId = ?", s4));
        assertTrue(c.get("/admin/users?status=INACTIVE").has("student4"));
        assertTrue(new Client().login("student4", "123456").has("khóa"), "INACTIVE không đăng nhập được");
        // INACTIVE: không mở khóa / sửa / đặt lại mật khẩu / xóa lại được (TC-ADM-02)
        c.form("/admin/users/" + s4 + "/status", Map.of("status", "ACTIVE"));
        assertEquals("INACTIVE", scalar("SELECT [Status] FROM Users WHERE UserId = ?", s4));
        assertTrue(c.get("/admin/users").has("không thể thực hiện thao tác này"));
        c.form("/admin/users/" + s4 + "/reset-password", Map.of());
        assertEquals("INACTIVE", scalar("SELECT [Status] FROM Users WHERE UserId = ?", s4));
        c.get("/admin/users");
        c.form("/admin/users/" + s4, Map.of("fullName", "Sửa", "email", "x@example.com", "role", "STUDENT", "status", "ACTIVE"));
        assertEquals("INACTIVE", scalar("SELECT [Status] FROM Users WHERE UserId = ?", s4));
        c.get("/admin/users");
        // Khôi phục tài khoản đã xóa mềm: INACTIVE -> ACTIVE, dữ liệu cũ còn nguyên, đăng nhập lại được
        assertTrue(c.get("/admin/users?status=INACTIVE").has("/restore"), "có nút Khôi phục");
        assertEquals(302, c.form("/admin/users/" + s4 + "/restore", Map.of()).status());
        assertEquals("ACTIVE", scalar("SELECT [Status] FROM Users WHERE UserId = ?", s4));
        assertEquals(1, count("SELECT CAST(IsActive AS INT) FROM Users WHERE UserId = ?", s4));
        assertEquals(1, count("SELECT COUNT(*) FROM Submissions WHERE StudentId = ?", s4), "lịch sử làm bài còn nguyên");
        assertTrue(c.get("/admin/users").has("Đã khôi phục tài khoản student4"));
        assertEquals(302, new Client().login("student4", "123456").status(), "đăng nhập lại được sau khi khôi phục");
        // khôi phục tài khoản chưa bị xóa -> báo lỗi; giáo viên không được khôi phục
        c.form("/admin/users/" + s4 + "/restore", Map.of());
        assertTrue(c.get("/admin/users").has("chưa bị xóa"));
        Client tchr = new Client();
        tchr.login("teacher1", "123456");
        assertEquals(403, tchr.form("/admin/users/" + s4 + "/restore", Map.of()).status());
        // không tự xóa mình
        c.form("/admin/users/1/delete", Map.of());
        assertEquals(1, count("SELECT COUNT(*) FROM Users WHERE UserId = 1"));
        assertTrue(c.get("/admin/users").has("không thể tự xóa"));

        // TC-ADM-01 / BR-02: thêm một Admin rồi chỉ còn Admin duy nhất đang hoạt động thì không bị hạ quyền / khóa
        assertEquals(302, c.form("/admin/users", Map.of("username", "it_admin2", "password", "Abcdef12",
                "fullName", "Admin hai", "email", "it_admin2@example.com", "role", "ADMIN")).status());
        int admin2 = count("SELECT UserId FROM Users WHERE Username = 'it_admin2'");
        Client a2 = new Client();
        a2.login("it_admin2", "Abcdef12");
        assertEquals(200, a2.get("/admin/users").status());
        assertEquals(302, a2.form("/admin/users/1/status", Map.of("status", "SUSPENDED")).status());
        assertEquals("SUSPENDED", scalar("SELECT [Status] FROM Users WHERE UserId = 1"), "còn admin2 nên khóa được admin");
        // admin (đã bị khóa) không còn thao tác được; admin2 là Admin hoạt động cuối cùng và không tự khóa/xóa/hạ quyền được
        a2.form("/admin/users/" + admin2 + "/status", Map.of("status", "SUSPENDED"));
        a2.form("/admin/users/" + admin2 + "/delete", Map.of());
        assertEquals("ACTIVE", scalar("SELECT [Status] FROM Users WHERE UserId = ?", admin2));
        assertEquals(1, count("SELECT COUNT(*) FROM Users WHERE UserId = ?", admin2));
        a2.form("/admin/users/1/status", Map.of("status", "ACTIVE"));
        assertEquals("ACTIVE", scalar("SELECT [Status] FROM Users WHERE UserId = 1"));

        // khôi phục dữ liệu mẫu
        exec("DELETE FROM Submissions WHERE StudentId = ?", s4);
        exec("UPDATE Users SET IsActive = 1, [Status] = 'ACTIVE' WHERE UserId = ?", s4);
        exec("DELETE FROM Users WHERE Username LIKE 'it[_]%'");
    }

    // ---------------------------------------------------------------- TEACHER

    /** FR-AUTH-04 / FR-AUTH-05: hồ sơ cá nhân và tự đổi mật khẩu cho mọi vai trò. */
    @Test
    @Order(45)
    void userEditsProfileAndChangesPassword() throws Exception {
        assertEquals(302, new Client().get("/profile").status(), "chưa đăng nhập → /login");
        for (String u : new String[]{"admin", "teacher1", "student1"}) {
            Client any = new Client();
            any.login(u, "123456");
            Resp page = any.get("/profile");
            assertEquals(200, page.status(), u + " -> " + page.body());
            assertTrue(page.has(u), "hiện tên đăng nhập");
            assertEquals(200, any.get("/profile/password").status());
        }

        int uid = count("SELECT UserId FROM Users WHERE Username = 'student5'");
        String oldName = (String) scalar("SELECT FullName FROM Users WHERE UserId = ?", uid);
        String oldEmail = (String) scalar("SELECT Email FROM Users WHERE UserId = ?", uid);
        String oldHash = (String) scalar("SELECT PasswordHash FROM Users WHERE UserId = ?", uid);
        Client c = new Client();
        assertEquals(302, c.login("student5", "123456").status());
        try {
            // UC-AUTH-04: sửa họ tên, email; username / role gửi kèm bị bỏ qua
            Resp ok = c.form("/profile", Map.of("fullName", "it Học Sinh Năm", "email", "it_hs5@example.com",
                    "username", "hacker", "role", "ADMIN"));
            assertEquals(302, ok.status(), ok.body());
            assertEquals("it Học Sinh Năm", scalar("SELECT FullName FROM Users WHERE UserId = ?", uid));
            assertEquals("it_hs5@example.com", scalar("SELECT Email FROM Users WHERE UserId = ?", uid));
            assertEquals("student5", scalar("SELECT Username FROM Users WHERE UserId = ?", uid));
            assertEquals("STUDENT", scalar("SELECT [Role] FROM Users WHERE UserId = ?", uid));
            Resp after = c.get("/profile");
            assertTrue(after.has("Đã cập nhật hồ sơ cá nhân"));
            assertTrue(after.has("it Học Sinh Năm"), "tên mới hiện ngay (session đã cập nhật)");

            // Email trùng người khác / họ tên chứa thẻ HTML → lỗi tại trường, CSDL không đổi
            String takenEmail = (String) scalar("SELECT Email FROM Users WHERE Username = 'student1'");
            Resp dup = c.form("/profile", Map.of("fullName", "it Tên khác", "email", takenEmail));
            assertEquals(200, dup.status());
            assertTrue(dup.has("Email đã được sử dụng"), dup.body());
            assertEquals("it Học Sinh Năm", scalar("SELECT FullName FROM Users WHERE UserId = ?", uid));
            Resp html = c.form("/profile", Map.of("fullName", "<b>x</b>", "email", "it_hs5@example.com"));
            assertTrue(html.has("không được chứa ký tự"), html.body());

            // UC-AUTH-05: sai mật khẩu cũ / xác nhận không khớp / yếu / trùng mật khẩu cũ → báo lỗi, không đổi
            Resp wrong = c.form("/profile/password", Map.of("currentPassword", "sai-mat-khau",
                    "newPassword", "MatKhauMoi1", "confirmPassword", "MatKhauMoi1"));
            assertTrue(wrong.has("Mật khẩu hiện tại không đúng"), wrong.body());
            assertTrue(c.form("/profile/password", Map.of("currentPassword", "123456",
                    "newPassword", "MatKhauMoi1", "confirmPassword", "KhacNhau1")).has("không khớp"));
            assertTrue(c.form("/profile/password", Map.of("currentPassword", "123456",
                    "newPassword", "abc", "confirmPassword", "abc")).has("từ 8 đến 64"));
            assertEquals(oldHash, scalar("SELECT PasswordHash FROM Users WHERE UserId = ?", uid));

            Resp changed = c.form("/profile/password", Map.of("currentPassword", "123456",
                    "newPassword", "MatKhauMoi1", "confirmPassword", "MatKhauMoi1"));
            assertEquals(302, changed.status(), changed.body());
            assertTrue(((String) scalar("SELECT PasswordHash FROM Users WHERE UserId = ?", uid)).startsWith("$2"),
                    "lưu BCrypt");
            assertTrue(c.form("/profile/password", Map.of("currentPassword", "MatKhauMoi1",
                    "newPassword", "MatKhauMoi1", "confirmPassword", "MatKhauMoi1")).has("phải khác mật khẩu hiện tại"));
            assertEquals(302, new Client().login("student5", "MatKhauMoi1").status(), "đăng nhập bằng mật khẩu mới");
            assertEquals(200, new Client().login("student5", "123456").status(), "mật khẩu cũ không còn dùng được");
        } finally {
            exec("UPDATE Users SET FullName = ?, Email = ?, PasswordHash = ? WHERE UserId = ?", oldName, oldEmail, oldHash, uid);
        }
    }

    @Test
    @Order(50)
    void teacherManagesTopicsAndLessons() throws Exception {
        Client c = new Client();
        c.login("teacher1", "123456");
        for (String p : new String[]{"/teacher/dashboard", "/teacher/topics", "/teacher/lessons",
                "/teacher/lessons?topicId=1", "/teacher/lessons?action=create", "/teacher/lessons?action=edit&id=1",
                "/teacher/students", "/teacher/students/history?studentId=4", "/teacher/submissions"}) {
            Resp r = c.get(p);
            assertEquals(200, r.status(), p + " -> " + r.body());
        }
        assertTrue(c.get("/teacher/dashboard").has("stat-number"));

        assertEquals(302, c.form("/teacher/topics", Map.of("action", "create", "topicName", "it_Chủ đề thử",
                "description", "mô tả")).status());
        // Modal dùng chung tạo/sửa gửi trường ẩn topicId="" và id="" khi tạo mới: không được gây lỗi chuyển kiểu
        assertEquals(302, c.form("/teacher/topics", Map.of("action", "create", "topicId", "", "id", "",
                "topicName", "it_Chủ đề id rỗng", "description", "")).status());
        assertEquals(1, count("SELECT COUNT(*) FROM Topics WHERE TopicName = N'it_Chủ đề id rỗng'"));
        exec("DELETE FROM Topics WHERE TopicName = N'it_Chủ đề id rỗng'");
        int topicId = count("SELECT TopicId FROM Topics WHERE TopicName = N'it_Chủ đề thử'");
        assertTrue(topicId > 0);
        c.form("/teacher/topics", Map.of("action", "update", "topicId", "" + topicId, "topicName", "it_Chủ đề sửa",
                "description", "d2"));
        assertEquals("it_Chủ đề sửa", scalar("SELECT TopicName FROM Topics WHERE TopicId = ?", topicId));
        // tên rỗng bị chặn
        c.form("/teacher/topics", Map.of("action", "create", "topicName", " "));
        assertTrue(c.get("/teacher/topics").has("không được để trống"));

        c.form("/teacher/lessons", Map.of("action", "create", "topicId", "" + topicId, "title", "it_Bài học thử",
                "summary", "s", "content", "nội dung", "youtubeUrl", ""));
        int lessonId = count("SELECT LessonId FROM Lessons WHERE Title = N'it_Bài học thử'");
        assertTrue(lessonId > 0);
        c.form("/teacher/lessons", Map.of("action", "update", "id", "" + lessonId, "topicId", "" + topicId,
                "title", "it_Bài học sửa", "summary", "s", "content", "c", "youtubeUrl", ""));
        assertEquals("it_Bài học sửa", scalar("SELECT Title FROM Lessons WHERE LessonId = ?", lessonId));
        c.form("/teacher/lessons", Map.of("action", "delete", "id", "" + lessonId));
        assertEquals(0, count("SELECT COUNT(*) FROM Lessons WHERE LessonId = ?", lessonId));

        // teacher2 không sửa/xóa được chủ đề của teacher1
        Client t2 = new Client();
        t2.login("teacher2", "123456");
        assertEquals(403, t2.form("/teacher/topics", Map.of("action", "delete", "id", "" + topicId)).status());
        assertEquals(1, count("SELECT COUNT(*) FROM Topics WHERE TopicId = ?", topicId));

        // BR-03 / TC-TEA-04 cho bài học: chỉ người tạo hoặc Admin được sửa / xóa
        c.form("/teacher/lessons", Map.of("action", "create", "topicId", "" + topicId, "title", "it_Bài của GV1",
                "summary", "s", "content", "c", "youtubeUrl", ""));
        int ownLesson = count("SELECT LessonId FROM Lessons WHERE Title = N'it_Bài của GV1'");
        int teacher1Id = count("SELECT UserId FROM Users WHERE Username = 'teacher1'");
        assertEquals(teacher1Id, count("SELECT CreatedBy FROM Lessons WHERE LessonId = ?", ownLesson), "ghi người tạo");
        assertEquals(403, t2.get("/teacher/lessons?action=edit&id=" + ownLesson).status(), "GV2 không mở form sửa");
        assertEquals(403, t2.form("/teacher/lessons", Map.of("action", "update", "id", "" + ownLesson,
                "topicId", "" + topicId, "title", "it_GV2 sửa trộm", "summary", "s", "content", "c")).status());
        assertEquals("it_Bài của GV1", scalar("SELECT Title FROM Lessons WHERE LessonId = ?", ownLesson));
        assertEquals(403, t2.form("/teacher/lessons", Map.of("action", "delete", "id", "" + ownLesson)).status());
        assertEquals(1, count("SELECT COUNT(*) FROM Lessons WHERE LessonId = ?", ownLesson));
        // GV2 không được thêm bài học vào chủ đề của GV1
        assertEquals(403, t2.form("/teacher/lessons", Map.of("action", "create", "topicId", "" + topicId,
                "title", "it_GV2 chen bai", "summary", "s", "content", "c")).status());
        assertEquals(0, count("SELECT COUNT(*) FROM Lessons WHERE Title = N'it_GV2 chen bai'"));
        // GV2 không thấy nút Sửa / Xóa bài học của GV1 trong danh sách
        assertFalse(t2.get("/teacher/lessons?topicId=" + topicId).has("action=edit&id=" + ownLesson));
        assertTrue(c.get("/teacher/lessons?topicId=" + topicId).has("action=edit&id=" + ownLesson));
        // Admin có toàn quyền
        Client adm = new Client();
        adm.login("admin", "123456");
        assertEquals(302, adm.form("/teacher/lessons", Map.of("action", "update", "id", "" + ownLesson,
                "topicId", "" + topicId, "title", "it_Admin sửa", "summary", "s", "content", "c")).status());
        assertEquals("it_Admin sửa", scalar("SELECT Title FROM Lessons WHERE LessonId = ?", ownLesson));
        assertEquals(teacher1Id, count("SELECT CreatedBy FROM Lessons WHERE LessonId = ?", ownLesson),
                "Admin sửa không đổi người tạo");
        assertEquals(302, adm.form("/teacher/lessons", Map.of("action", "delete", "id", "" + ownLesson)).status());
        assertEquals(0, count("SELECT COUNT(*) FROM Lessons WHERE LessonId = ?", ownLesson));
        for (int i = 0; i < 3; i++) {
            c.get("/teacher/lessons?topicId=" + topicId); // đọc flash còn tồn đọng
        }

        // BR-05: không xóa chủ đề còn bài học (TC-TEA-01)
        c.form("/teacher/lessons", Map.of("action", "create", "topicId", "" + topicId, "title", "it_Bài học giữ lại",
                "summary", "s", "content", "c", "youtubeUrl", ""));
        c.form("/teacher/topics", Map.of("action", "delete", "id", "" + topicId));
        assertEquals(1, count("SELECT COUNT(*) FROM Topics WHERE TopicId = ?", topicId));
        assertTrue(c.get("/teacher/topics").has("còn bài học"));
        exec("DELETE FROM Lessons WHERE Title = N'it_Bài học giữ lại'");

        // Bean Validation: tên bài học quá ngắn bị chặn, báo lỗi tiếng Việt
        for (int i = 0; i < 3; i++) {
            c.get("/teacher/lessons?topicId=" + topicId); // tiêu thụ các flash thành công còn tồn đọng
        }
        c.form("/teacher/lessons", Map.of("action", "create", "topicId", "" + topicId, "title", "ab"));
        assertEquals(0, count("SELECT COUNT(*) FROM Lessons WHERE Title = N'ab'"));
        assertTrue(c.get("/teacher/lessons?topicId=" + topicId).has("phải từ 3 đến 200 ký tự"));

        c.form("/teacher/topics", Map.of("action", "delete", "id", "" + topicId));
        assertEquals(0, count("SELECT COUNT(*) FROM Topics WHERE TopicId = ?", topicId));
    }

    @Test
    @Order(51)
    void teacherQuestionBankCrudFilterAndPaging() throws Exception {
        Client c = new Client();
        c.login("teacher1", "123456");
        for (String p : new String[]{"/teacher/questions", "/teacher/questions?topicId=1&lessonId=1&type=MCQ&level=2&page=1",
                "/teacher/questions?action=create", "/teacher/questions?action=edit&id=1", "/teacher/questions?page=99",
                "/teacher/ai/generate"}) {
            Resp r = c.get(p);
            assertTrue(r.status() == 200 || r.status() == 302, p + " -> " + r.status() + r.body());
        }
        Resp filtered = c.get("/teacher/questions?lessonId=1&type=MCQ&level=1");
        assertTrue(filtered.has("e^x"), "chỉ còn câu mức 1 của bài 1");
        assertFalse(filtered.has("x^3 - 3x"));
        assertTrue(c.get("/teacher/questions?type=ESSAY").has("Tìm giá trị lớn nhất"));

        Map<String, String> q = new LinkedHashMap<>();
        q.put("action", "create");
        q.put("lessonId", "1");
        q.put("type", "MCQ");
        q.put("level", "2");
        q.put("content", "it_Câu hỏi thử $x^2$");
        q.put("explanation", "it_lời giải");
        q.put("correctOption", "C");
        q.put("opt_A", "a");
        q.put("opt_B", "b");
        q.put("opt_C", "c");
        q.put("opt_D", "d");
        assertEquals(302, c.form("/teacher/questions", q).status());
        int qid = count("SELECT QuestionId FROM Questions WHERE Content LIKE N'it[_]Câu hỏi thử%'");
        assertTrue(qid > 0);
        assertEquals("it_lời giải", scalar("SELECT ExplanationLatex FROM Questions WHERE QuestionId = ?", qid));
        assertEquals(0, count("SELECT CAST(IsAiGenerated AS INT) FROM Questions WHERE QuestionId = ?", qid));
        assertEquals(4, count("SELECT COUNT(*) FROM QuestionOptions WHERE QuestionId = ?", qid));
        assertEquals("C", scalar("SELECT OptionLetter FROM QuestionOptions WHERE QuestionId = ? AND IsCorrect = 1", qid));

        // form sửa hiển thị dữ liệu
        Resp edit = c.get("/teacher/questions?action=edit&id=" + qid);
        assertEquals(200, edit.status());
        assertTrue(edit.has("it_lời giải"));

        // bí danh theo FRS: POST /teacher/questions/create
        q.put("content", "it_Câu hỏi thử qua create");
        assertEquals(302, c.form("/teacher/questions/create", q).status());
        assertEquals(1, count("SELECT COUNT(*) FROM Questions WHERE Content LIKE N'it[_]Câu hỏi thử qua create%'"));
        q.put("content", "it_Câu hỏi thử");

        // sửa: đổi đáp án đúng
        q.put("action", "update");
        q.put("id", "" + qid);
        q.put("correctOption", "B");
        q.put("content", "it_Câu hỏi thử đã sửa");
        c.form("/teacher/questions", q);
        assertEquals("B", scalar("SELECT OptionLetter FROM QuestionOptions WHERE QuestionId = ? AND IsCorrect = 1", qid));
        assertEquals(4, count("SELECT COUNT(*) FROM QuestionOptions WHERE QuestionId = ?", qid));

        // dữ liệu sai: thiếu đáp án đúng / phương án trống
        Map<String, String> bad = new LinkedHashMap<>(q);
        bad.put("action", "create");
        bad.put("correctOption", "");
        int total = count("SELECT COUNT(*) FROM Questions");
        c.form("/teacher/questions", bad);
        assertEquals(total, count("SELECT COUNT(*) FROM Questions"));
        assertTrue(c.get("/teacher/questions?action=create").has("đáp án đúng"));

        // xóa câu chưa có bài làm
        c.form("/teacher/questions", Map.of("action", "delete", "id", "" + qid));
        assertEquals(0, count("SELECT COUNT(*) FROM Questions WHERE QuestionId = ?", qid));
        assertEquals(0, count("SELECT COUNT(*) FROM QuestionOptions WHERE QuestionId = ?", qid));
        // BR-05: câu đã có bài làm → xóa mềm (giữ bản ghi + lịch sử), ẩn khỏi trang quản lý của giáo viên
        c.get("/teacher/questions"); // đọc flash còn tồn đọng
        c.form("/teacher/questions", Map.of("action", "delete", "id", "1"));
        assertEquals(1, count("SELECT COUNT(*) FROM Questions WHERE QuestionId = 1"));
        assertEquals(0, count("SELECT CAST(IsActive AS INT) FROM Questions WHERE QuestionId = 1"));
        assertTrue(count("SELECT COUNT(*) FROM Submissions WHERE QuestionId = 1") > 0, "lịch sử còn nguyên");
        assertTrue(c.get("/teacher/questions").has("xóa mềm"));
        assertFalse(c.get("/teacher/questions?lessonId=1&type=MCQ").has("x^3 - 3x"), "câu đã xóa mềm bị ẩn");
        Resp editDeleted = c.get("/teacher/questions?action=edit&id=1");
        assertFalse(editDeleted.status() == 200 && editDeleted.has("x^3 - 3x"), "không mở form sửa câu đã xóa mềm");
        Client st = new Client();
        st.login("student1", "123456");
        assertEquals(200, st.json("/api/student/submit-quiz-answer", "{\"questionId\":1,\"selectedOptionId\":1}").status(),
                "học sinh vẫn ôn tập được câu đã xóa mềm");
        assertTrue(st.get("/student/quiz?lessonId=1").has("x^3 - 3x"), "câu đã xóa mềm vẫn có trong đề ôn tập");
        exec("UPDATE Questions SET IsActive = 1 WHERE QuestionId = 1");

        // phân trang: tạo thêm nhiều câu hỏi tự luận
        for (int i = 0; i < 11; i++) {
            c.form("/teacher/questions", Map.of("action", "create", "lessonId", "2", "type", "ESSAY", "level", "1",
                    "content", "it_essay " + i));
        }
        Resp p2 = c.get("/teacher/questions?type=ESSAY&page=2");
        assertEquals(200, p2.status());
        assertTrue(p2.has("page-link"));
        exec("DELETE FROM Questions WHERE Content LIKE N'it[_]%'");
    }

    /**
     * BR-05 / TC-TEA-01 / TC-TEA-03: chặn khi còn bản ghi đang hoạt động; còn lịch sử thì xóa mềm và ẩn khỏi trang
     * quản lý của giáo viên. Học sinh vẫn xem / ôn tập được nội dung đã xóa mềm (quyết định của nhóm, lệch BR-05).
     */
    @Test
    @Order(56)
    void softDeleteKeepsHistoryAndHidesRecords() throws Exception {
        Client t = new Client();
        t.login("teacher1", "123456");
        t.form("/teacher/topics", Map.of("action", "create", "topicName", "it_Chủ đề xóa mềm", "description", ""));
        int topicId = count("SELECT TopicId FROM Topics WHERE TopicName = N'it_Chủ đề xóa mềm'");
        t.form("/teacher/lessons", Map.of("action", "create", "topicId", "" + topicId, "title", "it_Bài xóa mềm",
                "summary", "s", "content", "c", "youtubeUrl", ""));
        int lessonId = count("SELECT LessonId FROM Lessons WHERE Title = N'it_Bài xóa mềm'");
        Map<String, String> q = new LinkedHashMap<>();
        q.put("action", "create");
        q.put("lessonId", "" + lessonId);
        q.put("type", "MCQ");
        q.put("level", "1");
        q.put("content", "it_Câu xóa mềm");
        q.put("explanation", "g");
        q.put("correctOption", "A");
        for (String l : new String[]{"A", "B", "C", "D"}) {
            q.put("opt_" + l, "pa " + l);
        }
        t.form("/teacher/questions", q);
        int qid = count("SELECT QuestionId FROM Questions WHERE Content = N'it_Câu xóa mềm'");
        int wrongOpt = count("SELECT OptionId FROM QuestionOptions WHERE QuestionId = ? AND OptionLetter = 'B'", qid);

        // Học sinh làm sai câu này → có lịch sử
        Client st = new Client();
        st.login("student1", "123456");
        assertEquals(200, st.json("/api/student/submit-quiz-answer",
                "{\"questionId\":" + qid + ",\"selectedOptionId\":" + wrongOpt + "}").status());

        // đọc các flash thành công còn tồn đọng (flash gắn với đúng URL đích của lần redirect)
        t.get("/teacher/topics");
        t.get("/teacher/lessons?topicId=" + topicId);
        t.get("/teacher/questions");
        // Trang quản lý báo trước kết quả nút Xóa (giáo viên vẫn là người quyết định có xóa hay không)
        assertTrue(t.get("/teacher/topics").has("Không thể xóa: chủ đề còn 1 bài học"), "chủ đề: nút xóa bị khóa, nêu lý do");
        assertTrue(t.get("/teacher/lessons?topicId=" + topicId).has("Không thể xóa: bài học còn 1 câu hỏi"));
        assertTrue(t.get("/teacher/questions?lessonId=" + lessonId).has("chỉ được ẩn khỏi trang quản lý"),
                "câu đã có bài làm: báo trước là xóa mềm");
        // TC-TEA-03 (1): bài học còn câu hỏi đang hoạt động → chặn
        t.form("/teacher/lessons", Map.of("action", "delete", "id", "" + lessonId));
        assertEquals(1, count("SELECT CAST(IsActive AS INT) FROM Lessons WHERE LessonId = ?", lessonId));
        assertTrue(t.get("/teacher/lessons").has("câu hỏi đang hoạt động"));
        // TC-TEA-01: chủ đề còn bài học đang hoạt động → chặn
        t.form("/teacher/topics", Map.of("action", "delete", "id", "" + topicId));
        assertEquals(1, count("SELECT CAST(IsActive AS INT) FROM Topics WHERE TopicId = ?", topicId));
        t.get("/teacher/topics");

        // Câu hỏi có bài nộp → xóa mềm
        t.form("/teacher/questions", Map.of("action", "delete", "id", "" + qid));
        assertEquals(0, count("SELECT CAST(IsActive AS INT) FROM Questions WHERE QuestionId = ?", qid));
        t.get("/teacher/questions");
        // TC-TEA-03 (2): chỉ còn câu đã xóa mềm → được xóa; còn bài nộp nên bài học bị xóa mềm
        t.form("/teacher/lessons", Map.of("action", "delete", "id", "" + lessonId));
        assertEquals(0, count("SELECT CAST(IsActive AS INT) FROM Lessons WHERE LessonId = ?", lessonId));
        assertTrue(t.get("/teacher/lessons").has("xóa mềm"));
        assertFalse(t.get("/teacher/lessons").has("it_Bài xóa mềm"), "bài học đã xóa mềm bị ẩn");
        assertTrue(st.get("/student/topics").has("it_Bài xóa mềm"), "học sinh vẫn thấy bài đã xóa mềm để ôn tập");
        assertEquals(200, st.get("/student/lesson?id=" + lessonId).status(), "học sinh vẫn mở được bài đã xóa mềm");
        assertTrue(st.get("/student/quiz?lessonId=" + lessonId).has("it_Câu xóa mềm"), "vẫn luyện lại được");
        // Chủ đề chỉ còn bài học đã xóa mềm → xóa mềm chủ đề
        t.form("/teacher/topics", Map.of("action", "delete", "id", "" + topicId));
        assertEquals(0, count("SELECT CAST(IsActive AS INT) FROM Topics WHERE TopicId = ?", topicId));
        assertFalse(t.get("/teacher/topics").has("it_Chủ đề xóa mềm"));
        assertTrue(st.get("/student/topics").has("it_Chủ đề xóa mềm"), "học sinh vẫn thấy chủ đề đã xóa mềm");
        // Lịch sử của học sinh vẫn còn
        assertEquals(1, count("SELECT COUNT(*) FROM Submissions WHERE QuestionId = ?", qid));
        // Tên chuyên đề đã xóa mềm được dùng lại
        assertEquals(302, t.form("/teacher/topics", Map.of("action", "create", "topicName", "it_Chủ đề xóa mềm",
                "description", "")).status());
        assertEquals(2, count("SELECT COUNT(*) FROM Topics WHERE TopicName = N'it_Chủ đề xóa mềm'"));

        // Không còn lịch sử → xóa cứng
        int topic2 = count("SELECT TopicId FROM Topics WHERE TopicName = N'it_Chủ đề xóa mềm' AND IsActive = 1");
        t.form("/teacher/lessons", Map.of("action", "create", "topicId", "" + topic2, "title", "it_Bài xóa cứng",
                "summary", "s", "content", "c", "youtubeUrl", ""));
        assertTrue(t.get("/teacher/lessons?topicId=" + topic2).has("sẽ bị xóa hẳn và không hoàn tác được"),
                "chưa có học sinh làm: báo trước là xóa hẳn");
        int lesson2 = count("SELECT LessonId FROM Lessons WHERE Title = N'it_Bài xóa cứng'");
        t.form("/teacher/lessons", Map.of("action", "delete", "id", "" + lesson2));
        assertEquals(0, count("SELECT COUNT(*) FROM Lessons WHERE LessonId = ?", lesson2));
        t.form("/teacher/topics", Map.of("action", "delete", "id", "" + topic2));
        assertEquals(0, count("SELECT COUNT(*) FROM Topics WHERE TopicId = ?", topic2));

        // TC-SEC-05: tên chủ đề chứa dấu nháy không phá được thuộc tính HTML của nút xóa
        t.form("/teacher/topics", Map.of("action", "create", "topicName", "it_x\" onmouseover=\"alert(1)", "description", ""));
        Resp xss = t.get("/teacher/topics");
        assertTrue(count("SELECT COUNT(*) FROM Topics WHERE TopicName LIKE N'it[_]x%'") == 0
                || xss.has("it_x&#034; onmouseover=&#034;alert(1)"), "tên được escape trong thuộc tính");
        assertFalse(xss.has("it_x\" onmouseover=\"alert(1)"), "không có thuộc tính onmouseover lọt ra HTML");
        exec("DELETE FROM Topics WHERE TopicName LIKE N'it[_]x%'");

        // Dọn dữ liệu thử
        exec("DELETE FROM Submissions WHERE QuestionId = ?", qid);
        exec("DELETE FROM Questions WHERE QuestionId = ?", qid);
        exec("DELETE FROM Lessons WHERE LessonId = ?", lessonId);
        exec("DELETE FROM Topics WHERE TopicId = ?", topicId);
    }

    @Test
    @Order(52)
    void teacherGeneratesAndBatchSavesAiQuestions() throws Exception {
        Client c = new Client();
        c.login("teacher1", "123456");
        script.clear();
        // lần 1: 503, lần 2: JSON hỏng, lần 3: hợp lệ => vẫn thành công (tối đa 3 lần)
        script.add(new String[]{"503", "busy"});
        script.add(new String[]{"200", "```json\n{ hỏng"});
        script.add(new String[]{"200", "```json\n" + EXAM_JSON + "\n```"});
        int before = geminiCalls;
        Resp r = c.json("/api/teacher/generate-questions",
                "{\"lessonId\":1,\"difficultyLevel\":1,\"count\":2}");
        assertEquals(200, r.status(), r.body());
        assertEquals(3, geminiCalls - before);
        JsonNode j = JSON.readTree(r.body());
        assertTrue(j.get("success").asBoolean());
        assertEquals(2, j.get("data").size());
        JsonNode q0 = j.get("data").get(0);
        assertEquals("A", q0.get("options").get(0).get("letter").asText(), "đã sắp xếp A-D");
        assertTrue(q0.get("options").get(1).get("isCorrect").asBoolean());
        assertTrue(lastRequestBody.contains("system_instruction"));
        assertTrue(lastRequestBody.contains("GDPT 2018"));
        assertEquals("application/json", JSON.readTree(lastRequestBody).get("generationConfig")
                .get("response_mime_type").asText());

        // schema sai (thiếu đáp án đúng) -> retry rồi báo lỗi 422 (AI trả dữ liệu không dùng được)
        script.clear();
        String noCorrect = "[{\"content\":\"c\",\"options\":[{\"letter\":\"A\",\"content\":\"1\",\"isCorrect\":false},"
                + "{\"letter\":\"B\",\"content\":\"2\",\"isCorrect\":false},{\"letter\":\"C\",\"content\":\"3\","
                + "\"isCorrect\":false},{\"letter\":\"D\",\"content\":\"4\",\"isCorrect\":false}]}]";
        for (int i = 0; i < 3; i++) {
            script.add(new String[]{"200", noCorrect});
        }
        Resp bad = c.json("/api/teacher/generate-questions", "{\"lessonId\":1,\"difficultyLevel\":1,\"count\":2}");
        assertEquals(422, bad.status());
        script.clear();
        assertEquals(400, c.json("/api/teacher/generate-questions", "{\"difficultyLevel\":9,\"lessonId\":1}").status());
        script.add(new String[]{"200", EXAM_JSON});
        Resp hard = c.json("/api/teacher/generate-questions",
                "{\"lessonId\":2,\"difficultyLevel\":\"HARD\",\"count\":5}");
        assertEquals(200, hard.status(), hard.body());
        assertTrue(lastRequestBody.contains("Vận dụng cao"), "HARD ứng với mức 3");
        assertTrue(lastRequestBody.contains("Cực trị"), "tên bài học tra từ lessonId trong CSDL");
        script.clear();
        // VAL-12: thiếu lessonId / count ngoài 1..10 -> 400 kèm lỗi theo trường
        assertEquals(400, c.json("/api/teacher/generate-questions", "{}").status());
        Resp tooMany = c.json("/api/teacher/generate-questions", "{\"lessonId\":1,\"count\":11}");
        assertEquals(400, tooMany.status());
        assertEquals("count", JSON.readTree(tooMany.body()).get("errors").get(0).get("field").asText());

        // XSS: nội dung AI chứa HTML nguy hiểm bị loại bỏ trước khi lưu
        String body = "{\"lessonId\":1,\"questions\":[{\"content\":\"it_ai <script>alert(1)</script> $x$\",\"level\":2,"
                + "\"explanation\":\"gt\",\"options\":[{\"letter\":\"A\",\"content\":\"<img src=x onerror=alert(1)> a\","
                + "\"isCorrect\":false},{\"letter\":\"B\",\"content\":\"b\",\"isCorrect\":true},{\"letter\":\"C\","
                + "\"content\":\"c\",\"isCorrect\":false},{\"letter\":\"D\",\"content\":\"d\",\"isCorrect\":false}]}]}";
        Resp save = c.json("/api/teacher/questions/batch-save", body);
        assertEquals(200, save.status(), save.body());
        assertEquals(1, JSON.readTree(save.body()).get("data").get("saved").asInt());
        int qid = count("SELECT QuestionId FROM Questions WHERE Content LIKE N'it[_]ai%'");
        assertEquals(1, count("SELECT CAST(IsAiGenerated AS INT) FROM Questions WHERE QuestionId = ?", qid));
        String content = (String) scalar("SELECT Content FROM Questions WHERE QuestionId = ?", qid);
        assertFalse(content.contains("<script"), content);
        assertTrue(content.contains("$x$"));
        assertFalse(((String) scalar("SELECT Content FROM QuestionOptions WHERE QuestionId = ? AND OptionLetter = 'A'", qid))
                .contains("<img"));
        assertEquals("B", scalar("SELECT OptionLetter FROM QuestionOptions WHERE QuestionId = ? AND IsCorrect = 1", qid));

        // batch-save lỗi: bài học sai / danh sách rỗng / không đủ phương án => transaction không lưu gì
        int total = count("SELECT COUNT(*) FROM Questions");
        assertEquals(400, c.json("/api/teacher/questions/batch-save", "{\"lessonId\":999,\"questions\":[]}").status());
        assertEquals(400, c.json("/api/teacher/questions/batch-save", "{\"lessonId\":1,\"questions\":[]}").status());
        String broken = "{\"lessonId\":1,\"questions\":[" + "{\"content\":\"it_ok\",\"options\":["
                + "{\"letter\":\"A\",\"content\":\"1\",\"isCorrect\":true},{\"letter\":\"B\",\"content\":\"2\"},"
                + "{\"letter\":\"C\",\"content\":\"3\"},{\"letter\":\"D\",\"content\":\"4\"}]},"
                + "{\"content\":\"it_broken\",\"options\":[{\"letter\":\"A\",\"content\":\"1\",\"isCorrect\":true}]}]}";
        assertEquals(400, c.json("/api/teacher/questions/batch-save", broken).status());
        assertEquals(total, count("SELECT COUNT(*) FROM Questions"), "rollback toàn bộ batch");

        // lessons-by-topic
        Resp l = c.getAjax("/api/teacher/lessons-by-topic?topicId=1");
        assertEquals(200, l.status());
        assertEquals(2, JSON.readTree(l.body()).get("data").size());
        exec("DELETE FROM Questions WHERE Content LIKE N'it[_]%'");
    }

    @Test
    @Order(53)
    void teacherReviewsEssayAndAdjustsScore() throws Exception {
        Client c = new Client();
        c.login("teacher1", "123456");
        int sid = count("SELECT TOP 1 SubmissionId FROM Submissions WHERE QuestionType = 'ESSAY' AND EssayImagePath IS NOT NULL");
        assertTrue(sid > 0, "cần bài tự luận từ test OCR");
        Resp list = c.get("/teacher/submissions?status=pending");
        assertEquals(200, list.status());
        assertTrue(list.has("Nguyễn Văn A"));
        Resp detail = c.get("/teacher/submissions?id=" + sid);
        assertEquals(200, detail.status(), detail.body());
        assertTrue(detail.has("/uploads/"), "hiển thị ảnh bài làm");
        assertTrue(detail.has("Sai dấu"), "hiển thị nhận xét AI");
        assertTrue(detail.has("Điểm AI đề xuất") && detail.has("Duyệt giữ nguyên điểm AI"));
        exec("UPDATE Submissions SET [Status] = 'AI_GRADED', IsReviewed = 0, ReviewedBy = NULL, ReviewedAt = NULL "
                + "WHERE SubmissionId = ?", sid);
        double aiScore = ((Number) scalar("SELECT AiScore FROM Submissions WHERE SubmissionId = ?", sid)).doubleValue();

        // Học sinh thấy điểm AI là điểm tạm thời trong lúc chờ duyệt (FR-OCR-03)
        Client pending = new Client();
        pending.login("student1", "123456");
        assertTrue(pending.get("/student/history?type=ESSAY").has("Điểm tạm thời"));

        Resp post = c.form("/teacher/submissions", Map.of("submissionId", "" + sid, "score", "8,5", "isCorrect", "true",
                "teacherFeedback", "Cô chấm lại"));
        assertEquals(302, post.status());
        assertEquals(8.5, ((Number) scalar("SELECT FinalScore FROM Submissions WHERE SubmissionId = ?", sid)).doubleValue());
        // BR-09: ai_score giữ nguyên; trạng thái REVIEWED kèm người duyệt và thời điểm duyệt
        assertEquals(aiScore, ((Number) scalar("SELECT AiScore FROM Submissions WHERE SubmissionId = ?", sid)).doubleValue());
        assertEquals("REVIEWED", scalar("SELECT [Status] FROM Submissions WHERE SubmissionId = ?", sid));
        assertEquals(count("SELECT UserId FROM Users WHERE Username = 'teacher1'"),
                count("SELECT ReviewedBy FROM Submissions WHERE SubmissionId = ?", sid));
        assertNotNull(scalar("SELECT ReviewedAt FROM Submissions WHERE SubmissionId = ?", sid));
        assertEquals(1, count("SELECT CAST(IsReviewed AS INT) FROM Submissions WHERE SubmissionId = ?", sid));
        assertEquals("Cô chấm lại", scalar("SELECT TeacherFeedback FROM Submissions WHERE SubmissionId = ?", sid));
        assertTrue(c.get("/teacher/submissions?status=reviewed").has("Nguyễn Văn A"));

        c.get("/teacher/submissions?id=" + sid); // tiêu thụ flash thành công
        // VAL-20: điểm ngoài 0..10 hoặc không theo bước 0.25 bị từ chối, điểm cũ giữ nguyên
        c.form("/teacher/submissions", Map.of("submissionId", "" + sid, "score", "15"));
        assertTrue(c.get("/teacher/submissions?id=" + sid).has("từ 0 đến 10"));
        c.form("/teacher/submissions", Map.of("submissionId", "" + sid, "score", "7.3"));
        c.get("/teacher/submissions?id=" + sid);
        assertEquals(8.5, ((Number) scalar("SELECT FinalScore FROM Submissions WHERE SubmissionId = ?", sid)).doubleValue());
        // Bỏ trống điểm mà không chọn "Duyệt giữ nguyên điểm AI" → báo lỗi, điểm giữ nguyên
        c.form("/teacher/submissions", Map.of("submissionId", "" + sid, "score", ""));
        assertTrue(c.get("/teacher/submissions?id=" + sid).has("Vui lòng nhập điểm"));
        assertEquals(8.5, ((Number) scalar("SELECT FinalScore FROM Submissions WHERE SubmissionId = ?", sid)).doubleValue());
        c.form("/teacher/submissions", Map.of("submissionId", "" + sid, "score", "abc"));
        assertTrue(c.get("/teacher/submissions?id=" + sid).has("từ 0 đến 10"));
        assertEquals(302, c.get("/teacher/submissions?id=99999").status());
        // không chấm được bài trắc nghiệm qua màn hình tự luận
        int mcq = count("SELECT TOP 1 SubmissionId FROM Submissions WHERE QuestionType = 'MCQ'");
        c.form("/teacher/submissions", Map.of("submissionId", "" + mcq, "score", "3"));
        assertNotNull(scalar("SELECT 1 WHERE NOT EXISTS (SELECT 1 FROM Submissions WHERE SubmissionId = " + mcq
                + " AND TeacherFeedback IS NOT NULL)"));

        // học sinh xem điểm đã chấm trong lịch sử
        Client st = new Client();
        st.login("student1", "123456");
        Resp hist = st.get("/student/history?type=ESSAY");
        assertEquals(200, hist.status());
        assertTrue(hist.has("8.5"), hist.body());

        // "Duyệt giữ nguyên điểm AI": final_score = ai_score, ai_score vẫn không đổi
        c.form("/teacher/submissions", Map.of("submissionId", "" + sid, "keepAiScore", "true", "score", "3"));
        assertEquals(aiScore, ((Number) scalar("SELECT FinalScore FROM Submissions WHERE SubmissionId = ?", sid)).doubleValue());
        assertEquals(aiScore, ((Number) scalar("SELECT AiScore FROM Submissions WHERE SubmissionId = ?", sid)).doubleValue());
        assertEquals("REVIEWED", scalar("SELECT [Status] FROM Submissions WHERE SubmissionId = ?", sid));
    }

    @Test
    @Order(54)
    void teacherManagesLessonMaterialsAndStudentSeesThem() throws Exception {
        Client t1 = new Client();
        t1.login("teacher1", "123456");
        assertEquals(200, t1.get("/teacher/lessons/1/materials").status());
        assertEquals(404, t1.get("/teacher/lessons/9999/materials").status());
        assertTrue(t1.get("/teacher/lessons").has("/teacher/lessons/1/materials"), "có nút Bài giảng ở danh sách bài học");

        String base = "/teacher/lessons/1/materials";
        // 4 loại hợp lệ; không nhập thứ tự -> tự xếp cuối
        assertEquals(302, t1.form(base, Map.of("materialType", "YOUTUBE", "title", "it_Video YouTube",
                "url", "https://www.youtube.com/watch?v=zSnMIO2D4oE&si=abc")).status());
        assertEquals(302, t1.form(base, Map.of("materialType", "VIDEO", "title", "it_Video mp4",
                "url", "https://example.com/media/bai1.mp4?x=1")).status());
        assertEquals(302, t1.form(base, Map.of("materialType", "LINK", "title", "it_Trang web",
                "url", "https://vi.wikipedia.org/wiki/Luy_thua")).status());
        assertEquals(302, t1.form(base, Map.of("materialType", "TEXT", "title", "it_Văn bản",
                "contentText", "Công thức $a^m$ <script>alert(1)</script>")).status());
        assertEquals(4, count("SELECT COUNT(*) FROM LessonMaterials WHERE Title LIKE N'it[_]%'"));
        assertEquals(3, count("SELECT MAX(OrderIndex) - MIN(OrderIndex) FROM LessonMaterials "
                + "WHERE LessonId = 1 AND Title LIKE N'it[_]%'"), "thứ tự tự tăng dần");
        assertTrue(t1.get(base).has("it_Video YouTube"));

        // VAL-08: dữ liệu sai bị chặn, báo lỗi tiếng Việt, không ghi CSDL
        t1.form(base, Map.of("materialType", "YOUTUBE", "title", "it_sai1", "url", "https://example.com/video"));
        assertTrue(t1.get(base).has("Link YouTube không hợp lệ"));
        t1.form(base, Map.of("materialType", "LINK", "title", "it_sai2", "url", "javascript:alert(1)"));
        assertTrue(t1.get(base).has("http://"));
        t1.form(base, Map.of("materialType", "VIDEO", "title", "it_sai3", "url", "https://example.com/a.exe"));
        assertTrue(t1.get(base).has(".mp4"));
        t1.form(base, Map.of("materialType", "TEXT", "title", "it_sai4", "contentText", "   "));
        assertTrue(t1.get(base).has("phải có nội dung"));
        t1.form(base, Map.of("materialType", "KHAC", "title", "it_sai5", "url", "https://a.com"));
        t1.get(base);
        assertEquals(0, count("SELECT COUNT(*) FROM LessonMaterials WHERE Title LIKE N'it[_]sai%'"));

        // Học sinh xem trong trang bài học: YouTube nhúng, video, link mở tab mới, văn bản được làm sạch
        Client st = new Client();
        st.login("student1", "123456");
        Resp lesson = st.get("/student/lesson?id=1");
        assertEquals(200, lesson.status());
        assertTrue(lesson.has("youtube-nocookie.com/embed/zSnMIO2D4oE"), "iframe YouTube");
        assertTrue(lesson.has("id=\"tab-materials\"") && lesson.has("id=\"lessonToc\""), "tab Bài giảng và mục lục");
        assertTrue(lesson.has("href=\"#material-"), "mục lục trỏ tới từng bài giảng");
        assertTrue(lesson.has("<video controls"));
        assertTrue(lesson.has("bai1.mp4"));
        assertTrue(lesson.has("rel=\"noopener noreferrer\""));
        assertTrue(lesson.has("it_Văn bản") && lesson.has("a^m"));
        assertFalse(lesson.has("<script>alert(1)"), "văn bản được escape");
        // Học sinh không được quản lý bài giảng
        assertEquals(403, st.get(base).status());
        assertEquals(403, st.form(base, Map.of("materialType", "LINK", "title", "it_hs", "url", "https://a.com")).status());

        // BR-03: giáo viên khác không sửa / xóa được; người tạo thì được
        int mid = count("SELECT MaterialId FROM LessonMaterials WHERE Title = N'it_Trang web'");
        Client t2 = new Client();
        t2.login("teacher2", "123456");
        assertEquals(403, t2.form("/teacher/materials/" + mid + "/update", Map.of("materialType", "LINK",
                "title", "it_hack", "url", "https://a.com", "lessonId", "1")).status());
        assertEquals(403, t2.form("/teacher/materials/" + mid + "/delete", Map.of()).status());
        assertEquals("it_Trang web", scalar("SELECT Title FROM LessonMaterials WHERE MaterialId = ?", mid));

        assertEquals(302, t1.form("/teacher/materials/" + mid + "/update", Map.of("materialType", "LINK",
                "title", "it_Trang web sửa", "url", "https://vi.wikipedia.org", "orderIndex", "9", "lessonId", "1")).status());
        assertEquals("it_Trang web sửa", scalar("SELECT Title FROM LessonMaterials WHERE MaterialId = ?", mid));
        assertEquals(9, count("SELECT OrderIndex FROM LessonMaterials WHERE MaterialId = ?", mid));
        // Admin có toàn quyền
        Client admin = new Client();
        admin.login("admin", "123456");
        assertEquals(302, admin.form("/teacher/materials/" + mid + "/delete", Map.of()).status());
        assertEquals(0, count("SELECT COUNT(*) FROM LessonMaterials WHERE MaterialId = ?", mid));
        assertEquals(404, t1.form("/teacher/materials/" + mid + "/delete", Map.of()).status());

        exec("DELETE FROM LessonMaterials WHERE Title LIKE N'it[_]%'");
    }

    /** FR-TEA-08: kết quả theo câu hỏi — số lượt làm, tỉ lệ đúng và điểm TB thang 10 hiển thị song song. */
    @Test
    @Order(57)
    void teacherSeesResultsPerQuestion() throws Exception {
        Client t = new Client();
        t.login("teacher1", "123456");
        int teacher1 = count("SELECT UserId FROM Users WHERE Username = 'teacher1'");
        int topicId = count("SELECT TOP 1 TopicId FROM Topics WHERE TeacherId = ? AND IsActive = 1 ORDER BY TopicId", teacher1);
        t.form("/teacher/lessons", Map.of("action", "create", "topicId", "" + topicId, "title", "it_Bài thống kê",
                "summary", "s", "content", "c", "youtubeUrl", ""));
        int lessonId = count("SELECT LessonId FROM Lessons WHERE Title = N'it_Bài thống kê'");
        for (String content : new String[]{"it_Câu khó", "it_Câu chưa ai làm"}) {
            Map<String, String> q = new LinkedHashMap<>();
            q.put("action", "create");
            q.put("lessonId", "" + lessonId);
            q.put("type", "MCQ");
            q.put("level", "2");
            q.put("content", content);
            q.put("explanation", "g");
            q.put("correctOption", "A");
            for (String l : new String[]{"A", "B", "C", "D"}) {
                q.put("opt_" + l, "pa " + l);
            }
            t.form("/teacher/questions", q);
        }
        int hard = count("SELECT QuestionId FROM Questions WHERE Content = N'it_Câu khó'");
        int right = count("SELECT OptionId FROM QuestionOptions WHERE QuestionId = ? AND OptionLetter = 'A'", hard);
        int wrong = count("SELECT OptionId FROM QuestionOptions WHERE QuestionId = ? AND OptionLetter = 'B'", hard);
        try {
            // 3 lượt (2 học sinh): 1 đúng, 2 sai → tỉ lệ đúng 33.3%, điểm TB 3.33
            Client s1 = new Client();
            s1.login("student1", "123456");
            Client s2 = new Client();
            s2.login("student2", "123456");
            s1.json("/api/student/submit-quiz-answer", "{\"questionId\":" + hard + ",\"selectedOptionId\":" + right + "}");
            s1.json("/api/student/submit-quiz-answer", "{\"questionId\":" + hard + ",\"selectedOptionId\":" + wrong + "}");
            s2.json("/api/student/submit-quiz-answer", "{\"questionId\":" + hard + ",\"selectedOptionId\":" + wrong + "}");

            assertEquals(200, t.get("/teacher/results").status(), "mặc định chọn bài học đầu tiên");
            Resp page = t.get("/teacher/results?lessonId=" + lessonId);
            assertEquals(200, page.status(), page.body());
            String html = page.body();
            assertTrue(html.contains("33.3%"), "tỉ lệ đúng");
            assertTrue(html.contains("3.33"), "điểm TB thang 10 = tỉ lệ đúng / 10");
            assertTrue(html.contains("Chưa có lượt làm"), "câu chưa ai làm");
            assertTrue(html.indexOf("it_Câu khó") < html.indexOf("it_Câu chưa ai làm"), "tỉ lệ đúng thấp nhất lên đầu");
            assertTrue(html.contains("3 / 2"), "tổng hợp: 3 lượt / 2 học sinh");

            // Câu đã xóa mềm không còn trong thống kê quản lý
            exec("UPDATE Questions SET IsActive = 0 WHERE QuestionId = ?", hard);
            assertFalse(t.get("/teacher/results?lessonId=" + lessonId).has("it_Câu khó"));

            // Phân quyền: Admin xem được, học sinh bị 403
            Client adm = new Client();
            adm.login("admin", "123456");
            assertEquals(200, adm.get("/teacher/results?lessonId=" + lessonId).status());
            assertEquals(403, s1.get("/teacher/results").status());
            // Tham số phân trang ngoài {10,20,50} / lessonId lạ không gây lỗi
            assertEquals(200, t.get("/teacher/results?lessonId=999999&size=7&page=-3").status());
        } finally {
            exec("DELETE FROM Submissions WHERE QuestionId IN (SELECT QuestionId FROM Questions WHERE LessonId = ?)", lessonId);
            exec("DELETE FROM Questions WHERE LessonId = ?", lessonId);
            exec("DELETE FROM Lessons WHERE LessonId = ?", lessonId);
        }
    }

    /** FR-STU-06 / BR-10: tiến độ theo chủ đề và theo bài học, tính theo lần làm GẦN NHẤT của mỗi câu. */
    @Test
    @Order(58)
    void studentProgressUsesLatestAttempt() throws Exception {
        Client t = new Client();
        t.login("teacher1", "123456");
        int teacher1 = count("SELECT UserId FROM Users WHERE Username = 'teacher1'");
        int topicId = count("SELECT TOP 1 TopicId FROM Topics WHERE TeacherId = ? AND IsActive = 1 ORDER BY TopicId", teacher1);
        String topicName = (String) scalar("SELECT TopicName FROM Topics WHERE TopicId = ?", topicId);
        t.form("/teacher/lessons", Map.of("action", "create", "topicId", "" + topicId, "title", "it_Bài tiến độ",
                "summary", "s", "content", "c", "youtubeUrl", ""));
        int lessonId = count("SELECT LessonId FROM Lessons WHERE Title = N'it_Bài tiến độ'");
        int[] qid = new int[2];
        for (int i = 0; i < 2; i++) {
            Map<String, String> q = new LinkedHashMap<>();
            q.put("action", "create");
            q.put("lessonId", "" + lessonId);
            q.put("type", "MCQ");
            q.put("level", "1");
            q.put("content", "it_Câu tiến độ " + (i + 1));
            q.put("explanation", "g");
            q.put("correctOption", "A");
            for (String l : new String[]{"A", "B", "C", "D"}) {
                q.put("opt_" + l, "pa " + l);
            }
            t.form("/teacher/questions", q);
            qid[i] = count("SELECT QuestionId FROM Questions WHERE Content = ?", "it_Câu tiến độ " + (i + 1));
        }
        try {
            Client st = new Client();
            st.login("student3", "123456");
            int right1 = count("SELECT OptionId FROM QuestionOptions WHERE QuestionId = ? AND OptionLetter = 'A'", qid[0]);
            int wrong1 = count("SELECT OptionId FROM QuestionOptions WHERE QuestionId = ? AND OptionLetter = 'B'", qid[0]);
            int wrong2 = count("SELECT OptionId FROM QuestionOptions WHERE QuestionId = ? AND OptionLetter = 'C'", qid[1]);
            // Câu 1: sai rồi làm lại đúng → lần gần nhất ĐÚNG; câu 2: sai
            st.json("/api/student/submit-quiz-answer", "{\"questionId\":" + qid[0] + ",\"selectedOptionId\":" + wrong1 + "}");
            st.json("/api/student/submit-quiz-answer", "{\"questionId\":" + qid[0] + ",\"selectedOptionId\":" + right1 + "}");
            st.json("/api/student/submit-quiz-answer", "{\"questionId\":" + qid[1] + ",\"selectedOptionId\":" + wrong2 + "}");
            assertEquals(3, count("SELECT COUNT(*) FROM Submissions s JOIN Users u ON u.UserId = s.StudentId "
                    + "WHERE u.Username = 'student3' AND s.QuestionId IN (?, ?)", qid[0], qid[1]), "3 lượt làm");

            // Dashboard: tiến độ theo chủ đề, có liên kết tới trang chi tiết
            Resp dash = st.get("/student/dashboard");
            assertEquals(200, dash.status(), dash.body());
            assertTrue(dash.has("Tiến độ theo chủ đề") && dash.has(topicName));
            assertTrue(dash.has("/student/topics/" + topicId + "/progress"));

            // Trang tiến độ theo bài học: 2/2 câu đã làm, đúng 1 (50%) — KHÔNG phải 1/3 lượt
            Resp prog = st.get("/student/topics/" + topicId + "/progress");
            assertEquals(200, prog.status(), prog.body());
            String html = prog.body();
            int row = html.indexOf("it_Bài tiến độ");
            assertTrue(row > 0, "có dòng bài học");
            String rowHtml = html.substring(row, html.indexOf("</tr>", row));
            assertTrue(rowHtml.contains("2/2"), rowHtml);
            assertTrue(rowHtml.contains("(50%)"), "tỉ lệ đúng theo lần làm gần nhất: " + rowHtml);
            assertTrue(rowHtml.contains("/student/history?lessonId=" + lessonId));

            // Lịch sử lọc theo bài học: chỉ các lượt của bài này
            Resp hist = st.get("/student/history?lessonId=" + lessonId);
            assertEquals(200, hist.status());
            assertTrue(hist.has("Bài học: <strong>it_Bài tiến độ"), "hiện bộ lọc bài học");
            assertTrue(hist.has("it_Câu tiến độ 1") && hist.has("it_Câu tiến độ 2"));
            assertFalse(hist.has("x^3 - 3x"), "không lẫn câu của bài khác");
            assertTrue(st.get("/student/history?type=MCQ&lessonId=" + lessonId).has("it_Câu tiến độ 2"));

            // Chủ đề không tồn tại → 404; giáo viên không vào trang tiến độ của học sinh
            assertEquals(404, st.get("/student/topics/999999/progress").status());
            assertEquals(403, t.get("/student/topics/" + topicId + "/progress").status());
        } finally {
            exec("DELETE FROM Submissions WHERE QuestionId IN (?, ?)", qid[0], qid[1]);
            exec("DELETE FROM Questions WHERE LessonId = ?", lessonId);
            exec("DELETE FROM Lessons WHERE LessonId = ?", lessonId);
        }
    }

    /** BR-13 / NFR-06 / TC-AI-08: vượt hạn mức gọi AI → 429; hạn mức học sinh và giáo viên độc lập; ping không bị giới hạn. */
    @Test
    @Order(55)
    void aiRateLimitReturns429() throws Exception {
        Client tch = new Client();
        tch.login("teacher1", "123456");
        Client st = new Client();
        st.login("student1", "123456");
        script.clear();
        try {
            // Giáo viên đã sinh đề ở các bài trước => hạn mức 1 lượt/giờ đã hết
            exec("UPDATE AiConfigs SET ConfigValue = '1' WHERE ConfigKey = 'AI_RATE_LIMIT_TEACHER_PER_HOUR'");
            int before = geminiCalls;
            Resp limited = tch.json("/api/teacher/generate-questions", "{\"lessonId\":1,\"difficultyLevel\":1,\"count\":2}");
            assertEquals(429, limited.status(), limited.body());
            assertTrue(limited.has("hết lượt AI"), limited.body());
            assertEquals(before, geminiCalls, "không gọi Gemini khi đã vượt hạn mức");
            // Hạn mức học sinh độc lập: học sinh vẫn dùng gia sư được
            Resp tutor = st.json("/api/tutor/next-step", "{\"studentInput\":\"bài toán hạn mức\"}");
            assertEquals(200, tutor.status(), tutor.body());

            // Học sinh: gia sư + chấm ảnh dùng chung một hạn mức
            exec("UPDATE AiConfigs SET ConfigValue = '1' WHERE ConfigKey = 'AI_RATE_LIMIT_PER_HOUR'");
            assertEquals(429, st.json("/api/tutor/next-step", "{\"studentInput\":\"thêm một bài\"}").status());

            // Admin test kết nối không bị giới hạn
            Client admin = new Client();
            admin.login("admin", "123456");
            Resp ping = admin.form("/api/admin/ai-config/test-connection", Map.of());
            assertEquals(200, ping.status(), ping.body());
            assertTrue(JSON.readTree(ping.body()).get("success").asBoolean(), ping.body());
        } finally {
            exec("UPDATE AiConfigs SET ConfigValue = '60' WHERE ConfigKey = 'AI_RATE_LIMIT_PER_HOUR'");
            exec("UPDATE AiConfigs SET ConfigValue = '300' WHERE ConfigKey = 'AI_RATE_LIMIT_TEACHER_PER_HOUR'");
        }
    }

    @Test
    @Order(60)
    void sqlInjectionAttemptsAreHarmless() throws Exception {
        Client c = new Client();
        Resp r = c.login("admin' OR '1'='1", "x' OR '1'='1");
        assertEquals(200, r.status());
        assertTrue(r.has("sai"));
        c.login("teacher1", "123456");
        Resp q = c.get("/teacher/questions?type=MCQ'%20OR%20'1'='1&lessonId=1;DROP%20TABLE%20Questions");
        assertTrue(q.status() == 200 || q.status() == 302 || q.status() == 400, "" + q.status());
        assertTrue(count("SELECT COUNT(*) FROM Questions") > 0);
        assertEquals(1, count("SELECT COUNT(*) FROM Users WHERE Username = 'admin'"));
    }
}
