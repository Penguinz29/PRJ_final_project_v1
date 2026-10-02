<%-- File: WEB-INF/views/admin/ai-config.jsp
     Controller: AdminAiConfigController (GET /admin/ai-config, POST /admin/ai-config/update)
     Attributes: configs (List<AiConfigView>) --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

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

        <%-- Form cập nhật cấu hình --%>
        <div class="card">
            <div class="card-header">
                <i class="bi bi-sliders me-2 text-primary"></i>Tham số cấu hình
            </div>
            <div class="card-body">
                <form action="${pageContext.request.contextPath}/admin/ai-config/update" method="post">
<input type="hidden" name="_csrf" value="${sessionScope.CSRF_TOKEN}">
                    <c:forEach var="cfg" items="${configs}">
                        <div class="mb-3 row align-items-center">
                            <label for="cfg_${cfg.configKey}" class="col-md-3 col-form-label fw-semibold">
                                <code>${cfg.configKey}</code>
                                <c:if test="${not empty cfg.description}">
                                    <br><small class="text-muted fw-normal">${cfg.description}</small>
                                </c:if>
                            </label>
                            <div class="col-md-6">
                                <c:choose>
                                    <c:when test="${cfg.configKey == 'GEMINI_API_KEY'}">
                                        <div class="input-group">
                                            <input type="password" class="form-control" id="cfg_${cfg.configKey}"
                                                   name="${cfg.configKey}" value="" autocomplete="new-password"
                                                   placeholder="${not empty cfg.configValue ? 'Đã cấu hình. Để trống nếu giữ nguyên, hoặc nhập key mới' : 'Nhập API Key từ Google AI Studio'}">
                                            <button class="btn btn-outline-secondary" type="button"
                                                    onclick="toggleApiKey(this)">
                                                <i class="bi bi-eye"></i>
                                            </button>
                                        </div>
                                    </c:when>
                                    <c:when test="${cfg.configKey == 'DEFAULT_MODEL' || cfg.configKey == 'VISION_MODEL'}">
                                        <%-- Tên model không hard-code: nhập tự do (gợi ý bằng datalist), Admin đổi khi model bị ngừng --%>
                                        <input type="text" class="form-control" id="cfg_${cfg.configKey}"
                                               name="${cfg.configKey}" list="modelSuggestions" pattern="[a-z0-9.-]+"
                                               value="<c:out value='${cfg.configValue}'/>" required>
                                    </c:when>
                                    <c:when test="${cfg.configKey == 'TUTOR_TEMPERATURE'}">
                                        <div class="d-flex align-items-center gap-2">
                                            <input type="range" class="form-range flex-grow-1" id="cfg_${cfg.configKey}"
                                                   name="${cfg.configKey}" min="0" max="1" step="0.1"
                                                   value="${cfg.configValue}"
                                                   oninput="document.getElementById('tempVal').textContent=this.value">
                                            <span id="tempVal" class="badge bg-primary" style="min-width:36px">${cfg.configValue}</span>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <input type="text" class="form-control" id="cfg_${cfg.configKey}"
                                               name="${cfg.configKey}" value="<c:out value='${cfg.configValue}'/>">
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="col-md-3 text-muted" style="font-size:.78rem">
                                <c:if test="${not empty cfg.updatedByName}">
                                    <i class="bi bi-person me-1"></i>${cfg.updatedByName}<br>
                                </c:if>
                                <c:if test="${not empty cfg.updatedAt}">
                                    <i class="bi bi-clock me-1"></i><fmt:formatDate value="${cfg.updatedAt}" pattern="dd/MM/yyyy HH:mm" />
                                </c:if>
                            </div>
                        </div>
                    </c:forEach>

                    <datalist id="modelSuggestions">
                        <option value="gemini-2.5-flash"></option>
                        <option value="gemini-2.5-pro"></option>
                        <option value="gemini-3.5-flash"></option>
                    </datalist>

                    <hr>
                    <div class="d-flex justify-content-end">
                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-check-lg me-1"></i> Lưu cấu hình
                        </button>
                    </div>
                </form>
            </div>
        </div>

    </main>
</div>

<jsp:include page="../common/footer.jsp" />

<script>
    // Toggle hiện/ẩn API Key
    function toggleApiKey(btn) {
        const input = btn.parentElement.querySelector('input');
        const icon = btn.querySelector('i');
        if (input.type === 'password') {
            input.type = 'text';
            icon.className = 'bi bi-eye-slash';
        } else {
            input.type = 'password';
            icon.className = 'bi bi-eye';
        }
    }

    // Test Connection - AJAX
    document.getElementById('btnTestConnection').addEventListener('click', function () {
        const btn = this;
        const resultDiv = document.getElementById('testResult');

        btn.disabled = true;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span> Đang kiểm tra...';
        resultDiv.className = 'alert d-none mb-3';

        const apiKeyInput = document.getElementById('cfg_GEMINI_API_KEY');
        const modelSelect = document.getElementById('cfg_DEFAULT_MODEL');
        const params = new URLSearchParams();
        if (apiKeyInput && apiKeyInput.value) params.append('GEMINI_API_KEY', apiKeyInput.value.trim());
        if (modelSelect && modelSelect.value) params.append('DEFAULT_MODEL', modelSelect.value.trim());

        csrfFetch(document.body.dataset.ctx + '/api/admin/ai-config/test-connection', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded', 'Accept': 'application/json'},
            body: params.toString()
        })
        .then(res => res.json())
        .then(data => {
            resultDiv.classList.remove('d-none');
            if (data.success) {
                resultDiv.className = 'alert alert-success mb-3';
                resultDiv.innerHTML = '<i class="bi bi-check-circle-fill me-2"></i>';
                resultDiv.appendChild(document.createTextNode(data.message));
            } else {
                resultDiv.className = 'alert alert-danger mb-3';
                resultDiv.innerHTML = '<i class="bi bi-x-circle-fill me-2"></i>';
                resultDiv.appendChild(document.createTextNode(data.message));
            }
        })
        .catch(err => {
            resultDiv.classList.remove('d-none');
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
