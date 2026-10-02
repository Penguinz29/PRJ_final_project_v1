# AGENTS.md — Quy tắc cho AI khi code EduTutor Math 12

> Đặt file này ở **thư mục gốc dự án**. Nếu dùng Claude Code, đổi tên thành `CLAUDE.md` (nội dung giữ nguyên).
> Tài liệu nguồn (đặt trong thư mục `docs/`): `EduTutor_SRS.md`, `EduTutor_FRS.md`, `EduTutor_Database.sql`, `PRJ30x_Project_Evaluation_Rubric.docx` (tiêu chí chấm 100 điểm — xem **mục 8**).
> **Khi có mâu thuẫn:** SQL là nguồn sự thật về cấu trúc dữ liệu → FRS là nguồn sự thật về hành vi → SRS là nguồn sự thật về yêu cầu/phạm vi. Nếu thấy tài liệu thiếu hoặc mâu thuẫn, **dừng lại và hỏi**, đừng tự đoán.
> **Môi trường của người dùng:** Spring MVC 6 · Jakarta JSTL · SQL Server · **JPA (Hibernate)** · Tomcat 10.1 · NetBeans 17 · JDK 17.

---

## 1. Quyết định công nghệ (cố định, không đổi)

| Hạng mục | Quyết định |
|---|---|
| Ngôn ngữ | Java 17 |
| Framework | **Spring MVC 6.2.x thuần — KHÔNG dùng Spring Boot**, cấu hình bằng Java (không XML, không `web.xml`) |
| Server | Apache **Tomcat 10.1** (Jakarta Servlet 6.0, JSP 3.1). Không dùng Spring 7 (cần Tomcat 11) |
| Namespace | `jakarta.*` — **tuyệt đối không dùng `javax.*`** (kể cả `javax.persistence`, `javax.validation`) |
| View | JSP + **Jakarta JSTL 3.0** (URI `jakarta.tags.*`) + Spring form tag (`<form:form>`) |
| UI | Bootstrap 5.3 (framework UI duy nhất) + Bootstrap Icons + KaTeX |
| CSDL | **SQL Server 2022**, driver `mssql-jdbc` |
| Truy cập dữ liệu | **Spring Data JPA 3.5.x + Hibernate ORM 6.6.x** (Jakarta Persistence 3.1), HikariCP. Repository là `interface extends JpaRepository`. **Không dùng `JdbcTemplate`** trong code ứng dụng |
| Giao dịch | `JpaTransactionManager` + `@Transactional` ở tầng Service |
| Validation | **Jakarta Bean Validation** (Hibernate Validator 8.0.x) cho Form/DTO + kiểm tra nghiệp vụ ở Service (xem FRS 1.6) |
| JSON | Jackson |
| Băm mật khẩu | `BCryptPasswordEncoder` (`spring-security-crypto`, không kéo Spring Security) |
| Sanitize HTML | JSoup |
| Test | JUnit 5 + `spring-test` (scope `test`) |
| Build | Maven, đóng gói **WAR** (`edututor.war`, context path `/edututor`) |
| AI | Google Gemini REST qua `java.net.http.HttpClient` (không dùng SDK) |
| Log | SLF4J + Logback |

### 1.1. Thay đổi `pom.xml` so với bản mẫu cũ (JdbcTemplate → JPA)

`pom.xml` mẫu cũ phải được cập nhật. Chỉ thêm đúng các thư viện sau (lý do ghi trong ngoặc), không thêm gì khác nếu không thật cần:

```xml
<properties>
    <maven.compiler.release>17</maven.compiler.release>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <hibernate.version>6.6.x.Final</hibernate.version>   <!-- dùng bản vá mới nhất của nhánh 6.6 -->
</properties>

<dependencyManagement>
  <dependencies>
    <dependency>                                   <!-- BOM quản lý version Spring Data tương thích Spring 6.2 -->
      <groupId>org.springframework.data</groupId>
      <artifactId>spring-data-bom</artifactId>
      <version>2025.0.x</version>                  <!-- bản vá mới nhất của train 2025.0 -->
      <type>pom</type><scope>import</scope>
    </dependency>
  </dependencies>
</dependencyManagement>

<dependencies>
  <dependency><groupId>org.springframework.data</groupId><artifactId>spring-data-jpa</artifactId></dependency>   <!-- kéo theo spring-orm, spring-jdbc -->
  <dependency><groupId>org.hibernate.orm</groupId><artifactId>hibernate-core</artifactId><version>${hibernate.version}</version></dependency>
  <dependency><groupId>org.hibernate.validator</groupId><artifactId>hibernate-validator</artifactId><version>8.0.x.Final</version></dependency>
  <!-- giữ nguyên: spring-webmvc, jakarta.servlet-api (provided), JSTL 3.0, mssql-jdbc, HikariCP, jackson, spring-security-crypto, jsoup, slf4j/logback -->
</dependencies>

<build>
  <plugins>
    <plugin>
      <artifactId>maven-war-plugin</artifactId>
      <configuration><failOnMissingWebXml>false</failOnMissingWebXml></configuration>   <!-- bắt buộc vì không có web.xml -->
    </plugin>
  </plugins>
</build>
```
`spring-jdbc` vẫn nằm trong classpath (do `spring-orm` cần) nhưng **không dùng `JdbcTemplate`**.

---

## 2. Cấu trúc dự án

```
edututor/
├── pom.xml
├── docs/                 SRS, FRS, SQL, rubric, báo cáo, ERD, kịch bản demo
└── src/main
    ├── java/com/edututor/   (package theo FRS mục 1.1)
    │   ├── config/  interceptor/  controller/(api/)  service/  ai/  repository/(spec/)
    │   ├── model/  dto/  exception/  util/
    ├── resources/  application.properties, messages.properties (UTF-8), logback.xml
    └── webapp/
        ├── META-INF/context.xml
        ├── WEB-INF/views/   layout/ auth/ admin/ teacher/ student/ error/ (file .jsp)
        ├── WEB-INF/tags/    pagination.tag, flash.tag, math.tag … (thành phần dùng lại)
        └── static/          css/ js/ vendor/(bootstrap, katex, icons — lưu cục bộ để demo không cần mạng) img/
```

Không có `web.xml`. Không đặt JSP ngoài `WEB-INF/views`. `model/` chứa **Entity JPA** (`@Entity`), `repository/` chứa **interface Spring Data**, `repository/spec/` chứa các `Specification`.

---

## 3. Khung cấu hình bắt buộc

### 3.1. `WebAppInitializer` (thay web.xml)

```java
public class WebAppInitializer extends AbstractAnnotationConfigDispatcherServletInitializer {
    @Override protected Class<?>[] getRootConfigClasses()    { return new Class<?>[]{ RootConfig.class }; }
    @Override protected Class<?>[] getServletConfigClasses() { return new Class<?>[]{ WebConfig.class }; }
    @Override protected String[] getServletMappings()        { return new String[]{ "/" }; }

    @Override protected Filter[] getServletFilters() {
        return new Filter[]{ new CharacterEncodingFilter("UTF-8", true) };   // PHẢI có, nếu không tiếng Việt lỗi font
    }
    @Override protected void customizeRegistration(ServletRegistration.Dynamic reg) {
        reg.setMultipartConfig(new MultipartConfigElement(
            System.getProperty("java.io.tmpdir"), 5 * 1024 * 1024, 6 * 1024 * 1024, 0));
    }
    @Override public void onStartup(ServletContext ctx) throws ServletException {
        super.onStartup(ctx);
        ctx.setSessionTimeout(30);                                   // phút
        ctx.getSessionCookieConfig().setHttpOnly(true);
        ctx.getSessionCookieConfig().setAttribute("SameSite", "Lax");  // Servlet 6.0
    }
}
```
(`DispatcherServlet` và filter đăng ký qua lớp cha đã hỗ trợ async mặc định.)

### 3.2. `RootConfig` (Service, Repository, JPA, hạ tầng)

- `@Configuration @EnableTransactionManagement @PropertySource("classpath:application.properties")`
- `@EnableJpaRepositories(basePackages = "com.edututor.repository")`
- `@ComponentScan({"com.edututor.service","com.edututor.ai","com.edututor.util"})`
- Beans: `static PropertySourcesPlaceholderConfigurer`; `HikariDataSource` (driver `com.microsoft.sqlserver.jdbc.SQLServerDriver`, `db.url/db.username/db.password/db.pool.max-size`); **`LocalContainerEntityManagerFactoryBean`**; **`JpaTransactionManager`**; `BCryptPasswordEncoder`; `ObjectMapper` (`FAIL_ON_UNKNOWN_PROPERTIES=false`); `ThreadPoolTaskExecutor aiExecutor` (core/max/queue theo `app.ai.executor.*`, `RejectedExecutionHandler` → ném lỗi để trả 503).

```java
@Bean
public LocalContainerEntityManagerFactoryBean entityManagerFactory(DataSource ds, Environment env) {
    LocalContainerEntityManagerFactoryBean emf = new LocalContainerEntityManagerFactoryBean();
    emf.setDataSource(ds);
    emf.setPackagesToScan("com.edututor.model");              // không cần persistence.xml
    emf.setJpaVendorAdapter(new HibernateJpaVendorAdapter());
    Properties p = new Properties();
    for (String k : new String[]{ "hibernate.hbm2ddl.auto", "hibernate.show_sql", "hibernate.format_sql",
            "hibernate.jdbc.batch_size", "hibernate.order_inserts", "hibernate.default_batch_fetch_size" }) {
        String v = env.getProperty(k);
        if (v != null) p.setProperty(k, v);
    }
    emf.setJpaProperties(p);                                  // Hibernate 6 tự nhận dialect SQL Server
    return emf;
}

@Bean
public JpaTransactionManager transactionManager(EntityManagerFactory emf) {
    return new JpaTransactionManager(emf);
}
```

`application.properties` (khóa `db.*` và `hibernate.*`; **không** dùng khóa `spring.datasource.*` vì không có Spring Boot):
```properties
db.url=jdbc:sqlserver://localhost:1433;databaseName=EduTutorMath12;encrypt=true;trustServerCertificate=true
db.username=...
db.password=...
db.pool.max-size=10
hibernate.hbm2ddl.auto=none          # SQL script là nguồn sự thật, Hibernate KHÔNG được tự tạo/sửa bảng
hibernate.show_sql=false             # chỉ bật khi dev để soi N+1
hibernate.format_sql=true
hibernate.jdbc.batch_size=20
hibernate.order_inserts=true
hibernate.default_batch_fetch_size=16   # giảm N+1 khi truy cập quan hệ LAZY theo lô
app.upload-dir=C:/edututor/uploads
app.upload.max-bytes=5242880
app.ai.executor.core=4
app.ai.executor.max=8
app.ai.executor.queue=50
```

### 3.3. `WebConfig` (MVC)

- `@Configuration @EnableWebMvc implements WebMvcConfigurer`
- `@ComponentScan({"com.edututor.controller","com.edututor.exception","com.edututor.interceptor"})`
- `configureViewResolvers`: `registry.jsp("/WEB-INF/views/", ".jsp")`
- `addResourceHandlers`: `/static/**` → `/static/`
- `addInterceptors`: **thứ tự** `AuthInterceptor` rồi `CsrfInterceptor`, áp dụng `/**`, loại trừ `/static/**`
- Bean `StandardServletMultipartResolver` (tên `multipartResolver`)
- `configureAsyncSupport`: `setTaskExecutor(aiExecutor)`, `setDefaultTimeout(100_000)`
- **Validation tiếng Việt:** bean `MessageSource` (`ReloadableResourceBundleMessageSource`, `classpath:messages`, `setDefaultEncoding("UTF-8")`) và override `getValidator()` trả `LocalValidatorFactoryBean` với `setValidationMessageSource(messageSource)` và `setMessageInterpolator(new ParameterMessageInterpolator())` (không phụ thuộc EL → chạy ổn trên Tomcat/NetBeans).
- **Không** đăng ký `OpenEntityManagerInViewInterceptor` (xem 4.1).

---

## 4. Quy tắc code (BẮT BUỘC)

### 4.1. Được làm / Cấm làm

| ❌ Cấm | ✅ Thay bằng |
|---|---|
| Nối chuỗi JPQL/SQL với dữ liệu người dùng | Derived query, `Specification`, hoặc `@Query` với **tham số có tên** (`:kw`). Cột sắp xếp lấy từ **whitelist** rồi mới đưa vào `Sort` |
| Dùng `JdbcTemplate`, `EntityManager.createNativeQuery("..."+x)` | Repository Spring Data; native query chỉ khi cần (xem 4.3) và vẫn dùng `:param` |
| Trả **Entity** ra JSON/JSP, bind request thẳng vào Entity | DTO/Form/projection riêng; không bao giờ lộ `password_hash`, `is_correct`, `explanation_latex`, `reference_solution` trước khi được phép |
| Bật Open-Session-In-View / để Entity LAZY lọt ra View | Map sang DTO **bên trong** `@Transactional` của Service |
| `FetchType.EAGER`; `CascadeType.REMOVE/ALL` bừa bãi | Mọi quan hệ `LAZY`; cascade chỉ `PERSIST/MERGE` ở quan hệ cha-sở-hữu-con (Question → options). Xóa dây chuyền dựa vào `ON DELETE CASCADE` trong script SQL |
| `hibernate.hbm2ddl.auto = create/update/create-drop` | `none` |
| `findAll()` rồi lọc/phân trang trong Java | `Pageable` + `Specification` (phân trang ở DB) |
| `JOIN FETCH` một collection kèm `Pageable` (Hibernate phân trang trong RAM) | Truy vấn 2 bước: lấy trang ID/đối tượng cha, rồi nạp collection bằng một truy vấn `IN` |
| Tin dữ liệu client về vai trò, `studentId`, bước hiện tại của tutor, đáp án đúng | Lấy từ **session** hoặc **CSDL** |
| Hard-code tên model Gemini, prompt, khóa API | Đọc qua `AiConfigService` (bảng `ai_configs`) |
| `System.out.println`, `e.printStackTrace()` | SLF4J |
| Log khóa API, mật khẩu, nội dung bài làm | Che hoặc không log |
| `innerHTML` với dữ liệu chưa sanitize | `textContent`, hoặc server đã sanitize rồi mới render KaTeX |
| Giữ transaction trong lúc chờ Gemini | Gọi AI **ngoài** transaction (FRS 6.2) |
| Đổi cấu trúc DB ngầm | Sửa `EduTutor_Database.sql` **và** nêu trong báo cáo thay đổi |
| `javax.*`, `spring-boot-*` (kể cả `spring-boot-starter-data-jpa`), Lombok | `jakarta.*`, Spring MVC thuần; getter/setter viết tay (NetBeans có *Insert Code*) |

### 4.2. Quy ước đặt tên
- Java: `camelCase` / `PascalCase`; bảng/cột SQL: `snake_case` (khớp script SQL). Entity khai báo **tường minh** `@Table(name="...")`, `@Column(name="...")` (Hibernate 6 mặc định không đổi camelCase → snake_case).
- Kiểu khóa theo SQL: `INT IDENTITY` → `Integer` + `@GeneratedValue(strategy = GenerationType.IDENTITY)`.
- Repository: `XxxRepository extends JpaRepository<Xxx, Integer>` (+ `JpaSpecificationExecutor<Xxx>` cho màn hình tìm kiếm); tên method `findByXxx`, `existsByXxx`, `countByXxx`; tìm kiếm động dùng `XxxSpecs.search(filter)` + `Pageable`.
- Controller trang: trả tên view; POST xong **redirect** (PRG) + `RedirectAttributes.addFlashAttribute("msg"/"error", …)`.
- Controller API: `@RestController`, mọi phản hồi dùng `ApiResponse<T>` (FRS 1.2).
- Ngôn ngữ: **tên biến/lớp bằng tiếng Anh; thông báo hiển thị cho người dùng bằng tiếng Việt** (đặt trong `messages.properties`, UTF-8), nhất quán với FRS.

### 4.3. Lưu ý cho SQL Server + JPA/Hibernate
- Giữ mặc định `sendStringParametersAsUnicode=true`; cột `NVARCHAR` khai báo `@Nationalized` (hoặc `columnDefinition`) để Hibernate biết là Unicode. Cột `NVARCHAR(MAX)`: `@Nationalized @Column(columnDefinition = "NVARCHAR(MAX)")`.
- Kiểu: `BIT` → `boolean`/`Boolean` (cho NULL → `Boolean`); `DATETIME2` → `LocalDateTime`; `DECIMAL(4,2)` → `BigDecimal`; cột `role/status/type/difficulty` → `enum` + `@Enumerated(EnumType.STRING)` (tên enum **trùng** giá trị trong CHECK của SQL).
- Cột do DB điền (`created_at`, `updated_at`): `@CreationTimestamp` / `@UpdateTimestamp`. Cột **không được sửa**: `@Column(updatable = false)` cho `username`, **`ai_score`** (thực thi BR-09 ngay ở tầng ORM).
- Phân trang: `PageRequest.of(page - 1, size, sort)` — luôn có `Sort` (Hibernate 6 sinh `OFFSET … FETCH NEXT …`, SQL Server bắt buộc `ORDER BY`). `size ∈ {10,20,50}`.
- Lấy khóa tự tăng: sau `save()` Hibernate gán id (IDENTITY) — không dùng `KeyHolder`.
- **Native query chỉ dành cho** thứ JPQL không làm được: `ORDER BY NEWID()` (random câu hỏi), CTE `ROW_NUMBER()` (tiến độ), thống kê gộp phức tạp. Trả về **interface projection**. Giữ các truy vấn này làm "bằng chứng logic SQL" khi bảo vệ.
- Chống N+1: quan hệ `LAZY`; danh sách nhiều bảng dùng `@EntityGraph`/`JOIN FETCH` cho quan hệ *to-one*; collection nạp bằng một truy vấn `IN`; đo bằng log `org.hibernate.SQL` (DEBUG) khi dev.
- Truy vấn chỉ đọc: `@Transactional(readOnly = true)`.
- Chuỗi kết nối: `encrypt=true;trustServerCertificate=true`; trên máy cần bật TCP/IP cổng 1433 trong SQL Server Configuration Manager.

### 4.4. Lưu ý Tomcat 10.1 / Jakarta / JSTL
- **Taglib URI mới:** `<%@ taglib prefix="c" uri="jakarta.tags.core" %>`, `fmt` → `jakarta.tags.fmt`, `fn` → `jakarta.tags.functions`. Dùng URI cũ `http://java.sun.com/jsp/jstl/core` sẽ lỗi. Taglib **Spring** (`form`, `spring`) giữ URI `http://www.springframework.org/tags/form`, `http://www.springframework.org/tags`.
- Đầu mỗi JSP: `<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>`. Không dùng scriptlet `<% %>`; dùng EL/JSTL.
- Form dùng `<form:form modelAttribute="...">` + `<form:errors path="...">` để hiện lỗi validation theo trường, và luôn thêm `<input type="hidden" name="_csrf" value="${sessionScope.CSRF_TOKEN}">`.
- Mọi liên kết/tài nguyên dùng `${pageContext.request.contextPath}` hoặc `<c:url>`; không viết cứng `/edututor`.
- Truy cập session trong luồng bất đồng bộ không an toàn: **đọc `SessionUser` ở controller trước**, rồi truyền vào service/CompletableFuture. Truyền **ID/DTO** giữa các luồng, không truyền Entity hoặc `EntityManager`.
- `@Transactional` không hiệu lực khi gọi method cùng class (self-invocation); tách sang bean khác (ví dụ `TutorPersistence` cho phần ghi DB của gia sư).
- JSON chứa LaTeX có `\`: luôn để Jackson serialize, không tự ghép chuỗi JSON.

### 4.5. Giao diện (rubric: User-friendly + điều hướng mượt + thành phần dùng lại)
- Một layout chung `layout/layout.jsp` (navbar, sidebar theo vai trò, **breadcrumb**, vùng nội dung, flash message), các trang dùng `<jsp:include>` hoặc tag file.
- **Thành phần dùng lại** trong `WEB-INF/tags/`: `pagination.tag` (giữ nguyên bộ lọc khi chuyển trang), `flash.tag`, `field-error.tag`, `math.tag`, `confirm-delete` (modal Bootstrap). Không copy-paste khối HTML giữa các trang.
- Điều hướng: menu theo vai trò có mục đang chọn; nút "Quay lại" ở mọi trang chi tiết/biểu mẫu; sau POST luôn về trang hợp lý (PRG); trạng thái rỗng ("Chưa có dữ liệu") và trạng thái đang tải cho mọi danh sách.
- `static/js/app.js` cung cấp tối thiểu: `csrfFetch(url, options)` (tự gắn header `X-CSRF-TOKEN` từ `<meta name="csrf-token">`), `renderMath(element)` (KaTeX auto-render với `$…$`, `$$…$$`), `setLoading(button, bool)`, `showToast(msg, type)`.
- Mọi lời gọi AI: bật spinner, khóa nút, có `AbortController` timeout 100 giây, hiển thị lỗi thân thiện theo mã HTTP (FRS 1.2).
- Responsive (≥ 360 px); trang nộp ảnh dùng `<input type="file" accept="image/*" capture="environment">`.

---

## 5. Thứ tự xây dựng và tiêu chí hoàn thành

Làm **từng bước một**; chỉ sang bước sau khi bước trước build được và qua test. Mỗi bước chỉ sửa trong phạm vi bước đó.

| # | Bước | Nội dung (FRS) | Hoàn thành khi |
|---|---|---|---|
| 1 | Khung dự án | Mục 3 của file này (gồm JPA + Validator + MessageSource); `GET /login` hiển thị | WAR chạy trên Tomcat 10.1, trang login tiếng Việt đúng, `EntityManagerFactory` khởi tạo không lỗi mapping, kết nối được DB |
| 2 | Entity + Repository | 10 Entity JPA khớp script SQL (FRS 1.6), Repository Spring Data, Specification | Test tích hợp `*IT` đọc được dữ liệu mẫu; `hbm2ddl=none` mà không lỗi; `mvn clean package` vẫn xanh khi không có DB |
| 3 | Auth + bảo mật | FRS 1.4, mục 2, UC-AUTH-01…05 | TC-SEC-03, 04, 05, 06; TC-VAL-01; đăng nhập 3 vai trò chuyển đúng dashboard |
| 4 | Admin người dùng | UC-ADM-01…05, 08 | TC-ADM-01; tạo được giáo viên |
| 5 | Teacher nội dung | UC-TEA-01…04 (chủ đề → bài học → bài giảng → câu hỏi) | TC-TEA-01, 02; học sinh sau này xem được bài giảng |
| 6 | Student học + trắc nghiệm | UC-STU-01…04, 06, 07 (không AI) | TC-SEC-08; TC-DB-03 (không N+1); chấm tức thì; tiến độ đúng |
| 7 | Lớp AI nền | UC-ADM-06, 07; mục 4 FRS (`GeminiClient`, `AiConfigService`, `RateLimiter`) | TC-AI-01, 06, 07, 08 |
| 8 | Sinh đề AI | UC-TEA-05, 06 | TC-AI-02, TC-TEA-02 với dữ liệu AI |
| 9 | Gia sư AI | UC-TUT-01…04, UC-STU-05 | TC-AI-03, 04, 05; TC-SEC-07 |
| 10 | Tự luận OCR + duyệt điểm | UC-OCR-01…04, UC-TEA-07 | TC-OCR-01, 02, 03; giáo viên sửa điểm không mất `ai_score` |
| 11 | Hoàn thiện | Dashboard, lỗi toàn cục, rà soát bảo mật | Chạy trọn kịch bản demo SRS 9.1 và bộ test SRS 9.2 |
| 12 | Hồ sơ nộp + chuẩn bị bảo vệ | Mục 8 file này: báo cáo, ERD, use-case, kịch bản demo, Q&A | Mọi dòng trong bảng rubric (mục 8) có bằng chứng cụ thể |

### Mẫu yêu cầu cho từng bước
> Đọc `AGENTS.md`. Thực hiện **bước N** theo `docs/EduTutor_FRS.md` mục [..] và schema trong `docs/EduTutor_Database.sql`. Chỉ sửa trong phạm vi bước này. Cuối cùng: (1) chạy `mvn clean package`, (2) liệt kê file đã tạo/sửa, (3) nêu chỗ tài liệu còn thiếu hoặc bạn đã phải giả định, (4) hướng dẫn tôi tự kiểm tra các test của bước này, (5) nêu các Entity/quan hệ/truy vấn `@Query` mới và lý do.

---

## 6. Trước khi báo "xong" một bước, AI phải tự kiểm tra
- [ ] `mvn clean package` thành công (không cần DB), không còn cảnh báo `javax.*`.
- [ ] Không có JPQL/SQL nối chuỗi với dữ liệu người dùng (tìm `"+` trong Repository và `@Query`).
- [ ] Không có Entity/`password_hash`/`is_correct` bị trả ra client; không có `FetchType.EAGER`, không có `open-in-view`.
- [ ] Mọi list có phân trang ở DB và `Sort` từ whitelist; không có N+1 (đã soi log `org.hibernate.SQL` một lần).
- [ ] Mọi URL mới đã nằm trong bảng quy tắc `AuthInterceptor` (FRS mục 2.1).
- [ ] Mọi form/POST có CSRF **và** Bean Validation; mọi thông báo người dùng bằng tiếng Việt.
- [ ] Không hard-code model, prompt, khóa API.
- [ ] Nêu rõ những gì **chưa** làm hoặc **giả định**.

---

## 7. Môi trường phát triển của người dùng: NetBeans 17

Người dùng chạy dự án bằng **Apache NetBeans 17** (Maven Web Application, **Tomcat 10.1**, **JDK 17**). Vì vậy:

- Dự án là **Maven chuẩn** (`src/main/java`, `src/main/resources`, `src/main/webapp`). Không tạo lớp `main`, không dùng Spring Boot, không tạo script chạy riêng (Docker, shell…).
- **Không xóa** `src/main/webapp/META-INF/context.xml` (NetBeans cần để tích hợp Tomcat); giữ `<Context path="/edututor"/>`.
- `pom.xml` phải có `maven.compiler.release=17` và `<failOnMissingWebXml>false</failOnMissingWebXml>` (xem 1.1). Trong *Project Properties → Run*, chọn Server **Apache Tomcat 10.1** (nếu NetBeans chưa liệt kê, thêm qua *Services → Servers → Add Server → Apache Tomcat or TomEE* và trỏ tới thư mục Tomcat 10.1).
- AI **không chạy được NetBeans**: sau mỗi bước chỉ cần bảo đảm `mvn clean package` thành công, rồi hướng dẫn người dùng bấm *Clean and Build → Run* và mở `http://localhost:8080/edututor/login`.
- Khi thêm/sửa **Entity**, lớp cấu hình (`WebAppInitializer`, `RootConfig`, `WebConfig`), `pom.xml` hoặc `application.properties`, **nhắc người dùng Stop Tomcat → Clean and Build → Run lại** (Deploy on Save không áp dụng các thay đổi này đáng tin cậy; Hibernate chỉ quét Entity lúc khởi động).
- **Kiểm thử không được làm hỏng `mvn clean package`:** test cần SQL Server đặt tên `*IT` (chạy riêng, ví dụ `mvn verify -Pintegration`); test thuần (`ScoreUtil`, `YoutubeUtil`, `AiJsonParser`, `HtmlSanitizer`, `RateLimiter`, validator) chạy trong `package`.
- Tên thư mục `Web Pages` trong NetBeans chính là `src/main/webapp`.
- Mọi file dự án lưu **UTF-8** (kể cả `messages.properties`); JSP luôn có `pageEncoding="UTF-8"`.
- Hướng dẫn cài đặt đầy đủ: `docs/HUONG_DAN_NETBEANS.md`.

---

## 8. Đối chiếu rubric PRJ301 — checklist để đạt điểm tối đa

Rubric là tiêu chí chấm thật. Ở mỗi bước, AI giữ cho dòng liên quan trong bảng dưới **luôn đúng**; ở bước 12 AI tạo hồ sơ nộp.

| Tiêu chí (điểm) | Cần có để đạt tối đa | AI phải làm / giao nộp |
|---|---|---|
| **Database Design (10)** | Bảng chuẩn hóa; SQL Server có dữ liệu mẫu; ERD | Script SQL đủ PK/FK/UK/CHECK/INDEX + dữ liệu mẫu cho kịch bản demo. ERD Mermaid (SRS 6.1) **xuất thành ảnh** `docs/ERD.png`. Báo cáo giải thích: **6 bảng lõi** (`users, topics, lessons, questions, submissions, tutor_sessions`) + **4 bảng phụ tách ra do chuẩn hóa** (`lesson_materials`, `question_options`, `tutor_messages` là thuộc tính đa trị 1–N; `ai_configs` là cấu hình). Entity JPA khớp 1–1 với bảng |
| **Business Logic (10)** | Use-case/flow rõ; input validation | Use-case + luồng nghiệp vụ (SRS 4.1, 4.2) xuất ảnh vào báo cáo. Validation **4 lớp**: HTML5/JS → Bean Validation (VAL-01…22) → quy tắc nghiệp vụ ở Service (BR-01…14) → ràng buộc DB. Lỗi hiện **tại từng trường** bằng tiếng Việt |
| **User Interface (10)** | Thân thiện; điều hướng mượt | Mục 4.5: layout chung, breadcrumb, flash, xác nhận xóa, phân trang giữ bộ lọc, responsive 360 px, trạng thái rỗng/đang tải, KaTeX |
| **Contents (25)** | Hệ thống hoàn chỉnh, kiến trúc MVC, tích hợp AI, tài liệu rõ | Controller–Service–Repository–Entity/DTO rõ ràng; chạy trọn 8 bước demo (SRS 9.1); SRS + FRS + SQL + báo cáo nhất quán |
| **Application (25)** | Session, phân trang, xử lý lỗi, validation, bảo mật, **truy vấn tối ưu, thành phần dùng lại**, giải thích được khi demo | `HttpSession` + `AuthInterceptor`; phân trang DB; `@ControllerAdvice`; BCrypt, CSRF, XSS, upload an toàn; JPA: `LAZY`, `@EntityGraph`, projection, truy vấn `IN` (không N+1), `Specification`, native query cho CTE/NEWID, `@Transactional` đúng chỗ; tag file, `ApiResponse`, `PageResult`, `Specs` dùng lại |
| **AI Integration (10)** | AI chạy thật + giải thích logic | 3 tính năng thật (sinh đề, gia sư từng bước, chấm ảnh) + cấu hình AI từ giao diện. Giải thích: prompt (FRS 5.1), state machine tutor do **server** điều khiển, JSON schema, retry/timeout, rate limit, 3 sơ đồ tuần tự (FRS 5.4) |
| **Report & Documentation (5)** | Báo cáo đủ: yêu cầu, thiết kế DB, chức năng, AI | `docs/BAO_CAO.md`: 1 Giới thiệu & yêu cầu · 2 Kiến trúc (MVC, JPA) · 3 Thiết kế DB (ERD, từ điển dữ liệu) · 4 Use-case & chức năng (kèm ảnh chụp màn hình) · 5 Tích hợp AI (prompt, thuật toán, sơ đồ) · 6 Bảo mật & validation · 7 Kiểm thử (bảng TC) · 8 Hướng dẫn cài đặt · 9 Hạn chế & hướng phát triển |
| **Demo & Q&A (5)** | Demo trơn tru, trả lời tự tin | `docs/DEMO_SCRIPT.md` (8 bước SRS 9.1, thời gian từng bước); dữ liệu mẫu + 2 ảnh tự luận + khóa API chuẩn bị sẵn; thư viện giao diện lưu cục bộ (không cần mạng, trừ AI); `docs/QA_BAO_VE.md` dựa trên SRS Phụ lục B |

> Lưu ý trung thực: bảng trên bảo đảm hồ sơ và mã nguồn **có đủ bằng chứng cho từng tiêu chí**; điểm cuối cùng còn phụ thuộc việc ứng dụng chạy ổn định và buổi demo. Đừng tuyên bố tính năng chưa làm xong.
