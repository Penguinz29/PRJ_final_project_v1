<%-- File: WEB-INF/views/admin/ai-config.jsp
     Controller: AdminAiConfigController (GET /admin/ai-config, POST /admin/ai-config/update)
     Attributes: cfg (Map<String, AiConfigView>), fieldErrors / formValues (flash khi lưu lỗi) --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../common/head.jsp">
    <jsp:param name="title" value="Cấu hình AI" />
</jsp:include>

<body data-ctx="${pageContext.request.contextPath}">

<jsp:include page="../common/navbar.jsp" />

<div class="app-shell">
    <jsp:include page="../common/sidebar.jsp">
        <jsp:param name="active" value="admin-ai-config" />
    </jsp:include>

    <main class="app-main">
        <ui:flash />

        <div class="page-header">
            <h1><i class="bi bi-gear-wide-connected me-2 text-primary"></i>Cấu hình AI (Gemini API)</h1>
            <button type="button" class="btn btn-outline-primary btn-sm" id="btnTestConnection">
                <i class="bi bi-plug me-1"></i> Test Connection
            </button>
        </div>

        <%-- Kết quả test connection --%>
        <div id="testResult" class="alert d-none mb-3" role="alert"></div>

        <form action="${pageContext.request.contextPath}/admin/ai-config/update" method="post">
            <input type="hidden" name="_csrf" value="${sessionScope.CSRF_TOKEN}">

            <div class="row g-3">
                <%-- Khối 1: Kết nối & model --%>
                <div class="col-lg-6">
                    <div class="card h-100">
                        <div class="card-header"><i class="bi bi-plug me-2 text-primary"></i>Kết nối &amp; model</div>
                        <div class="card-body">
                            <ui:config-field key="GEMINI_API_KEY" label="Khóa API" type="password"
                                             hint="Lấy tại Google AI Studio. Khóa chỉ hiển thị dạng che." />
                            <ui:config-field key="DEFAULT_MODEL" label="Model mặc định" type="model"
                                             hint="Dùng cho gia sư và sinh câu hỏi." />
                            <ui:config-field key="VISION_MODEL" label="Model đọc ảnh" type="model"
                                             hint="Dùng chấm bài tự luận qua ảnh; phải hỗ trợ ảnh." />
                            <ui:config-field key="AI_TIMEOUT_SECONDS" label="Thời gian chờ (giây)" type="number"
                                             min="5" max="120" step="1" hint="5 - 120 giây; chấm ảnh dùng gấp đôi." />
                        </div>
                    </div>
                </div>

                <%-- Khối 2: Tham số --%>
                <div class="col-lg-6">
                    <div class="card h-100">
                        <div class="card-header"><i class="bi bi-sliders me-2 text-primary"></i>Tham số</div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-sm-4">
                                    <ui:config-field key="TUTOR_TEMPERATURE" label="Nhiệt độ gia sư" type="number"
                                                     min="0" max="1" step="0.1" hint="0.0 - 1.0" />
                                </div>
                                <div class="col-sm-4">
                                    <ui:config-field key="QUIZ_TEMPERATURE" label="Nhiệt độ sinh đề" type="number"
                                                     min="0" max="1" step="0.1" hint="0.0 - 1.0" />
                                </div>
                                <div class="col-sm-4">
                                    <ui:config-field key="GRADING_TEMPERATURE" label="Nhiệt độ chấm bài" type="number"
                                                     min="0" max="1" step="0.1" hint="0.0 - 1.0" />
                                </div>
                            </div>
                            <ui:config-field key="MAX_OUTPUT_TOKENS" label="Số token đầu ra tối đa" type="number"
                                             min="256" max="8192" step="1" hint="256 - 8192" />
                            <div class="row">
                                <div class="col-sm-6">
                                    <ui:config-field key="TUTOR_MIN_STEPS" label="Số bước tối thiểu" type="number"
                                                     min="2" max="10" step="1" hint="2 - 10" />
                                </div>
                                <div class="col-sm-6">
                                    <ui:config-field key="TUTOR_MAX_STEPS" label="Số bước tối đa" type="number"
                                                     min="2" max="10" step="1" hint="2 - 10, không nhỏ hơn số bước tối thiểu" />
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-sm-6">
                                    <ui:config-field key="AI_RATE_LIMIT_PER_HOUR" label="Lượt AI/giờ của học sinh"
                                                     type="number" min="1" max="1000" step="1"
                                                     hint="Gia sư + chấm ảnh (1 - 1000)" />
                                </div>
                                <div class="col-sm-6">
                                    <ui:config-field key="AI_RATE_LIMIT_TEACHER_PER_HOUR" label="Lượt sinh đề/giờ của giáo viên"
                                                     type="number" min="1" max="5000" step="1" hint="1 - 5000" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <%-- Khối 3: Prompt --%>
                <div class="col-12">
                    <div class="card">
                        <div class="card-header"><i class="bi bi-chat-square-text me-2 text-primary"></i>Prompt</div>
                        <div class="card-body">
                            <div class="alert alert-info small">
                                Prompt chỉ gồm phần nội dung sư phạm (tối đa 8.000 ký tự). Hệ thống tự thay các placeholder
                                <code>{{...}}</code> và tự nối thêm cấu trúc JSON bắt buộc cùng các quy tắc an toàn cố định,
                                nên không cần (và không thể) sửa các phần đó ở đây.
                            </div>
                            <ui:config-field key="TUTOR_SYSTEM_PROMPT" label="Prompt gia sư AI" type="textarea"
                                             hint="Bắt buộc giữ {{MIN_STEPS}}, {{MAX_STEPS}}." />
                            <ui:config-field key="QUIZ_GEN_PROMPT" label="Prompt sinh câu hỏi" type="textarea"
                                             hint="Bắt buộc giữ {{COUNT}}, {{TOPIC}}, {{LESSON}}, {{DIFFICULTY}}." />
                            <ui:config-field key="GRADING_PROMPT" label="Prompt chấm bài tự luận" type="textarea"
                                             hint="Bắt buộc giữ {{QUESTION}}, {{REFERENCE}}." />
                        </div>
                    </div>
                </div>
            </div>

            <datalist id="modelSuggestions">
                <option value="gemini-2.5-flash"></option>
                <option value="gemini-2.5-pro"></option>
                <option value="gemini-3.5-flash"></option>
            </datalist>

            <div class="d-flex justify-content-end my-3">
                <button type="submit" class="btn btn-primary">
                    <i class="bi bi-check-lg me-1"></i> Lưu cấu hình
                </button>
            </div>
        </form>

    </main>
</div>

<jsp:include page="../common/footer.jsp" />

<script>
    // Hiện / ẩn API Key
    document.querySelectorAll('[data-toggle-secret]').forEach(function (btn) {
        btn.addEventListener('click', function () {
            const input = document.getElementById(btn.dataset.toggleSecret);
            const icon = btn.querySelector('i');
            const show = input.type === 'password';
            input.type = show ? 'text' : 'password';
            icon.className = show ? 'bi bi-eye-slash' : 'bi bi-eye';
        });
    });

    // Test Connection - AJAX
    document.getElementById('btnTestConnection').addEventListener('click', function () {
        const btn = this;
        const resultDiv = document.getElementById('testResult');

        btn.disabled = true;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span> Đang kiểm tra...';
        resultDiv.className = 'alert d-none mb-3';

        const apiKeyInput = document.getElementById('cfg_GEMINI_API_KEY');
        const modelInput = document.getElementById('cfg_DEFAULT_MODEL');
        const params = new URLSearchParams();
        if (apiKeyInput && apiKeyInput.value) params.append('GEMINI_API_KEY', apiKeyInput.value.trim());
        if (modelInput && modelInput.value) params.append('DEFAULT_MODEL', modelInput.value.trim());

        csrfFetch(document.body.dataset.ctx + '/api/admin/ai-config/test-connection', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded', 'Accept': 'application/json'},
            body: params.toString()
        })
        .then(res => res.json())
        .then(data => {
            resultDiv.className = 'alert mb-3 ' + (data.success ? 'alert-success' : 'alert-danger');
            resultDiv.innerHTML = data.success
                ? '<i class="bi bi-check-circle-fill me-2"></i>'
                : '<i class="bi bi-x-circle-fill me-2"></i>';
            resultDiv.appendChild(document.createTextNode(data.message));
        })
        .catch(err => {
            resultDiv.className = 'alert alert-danger mb-3';
            resultDiv.innerHTML = '<i class="bi bi-x-circle-fill me-2"></i>';
            resultDiv.appendChild(document.createTextNode('Lỗi kết nối server: ' + err.message));
        })
        .finally(() => {
            btn.disabled = false;
            btn.innerHTML = '<i class="bi bi-plug me-1"></i> Test Connection';
        });
    });
</script>

</body>
</html>
