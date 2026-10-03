<%-- config-field.tag: một ô nhập của trang Cấu hình AI (admin/ai-config.jsp).
     Đọc từ request: cfg (Map khóa → AiConfigView), fieldErrors / formValues (flash khi lưu lỗi).
     type: text | model | number | password | textarea --%>
<%@ tag language="java" pageEncoding="UTF-8" body-content="empty" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ attribute name="key" required="true" type="java.lang.String" %>
<%@ attribute name="label" required="true" type="java.lang.String" %>
<%@ attribute name="type" type="java.lang.String" %>
<%@ attribute name="min" type="java.lang.String" %>
<%@ attribute name="max" type="java.lang.String" %>
<%@ attribute name="step" type="java.lang.String" %>
<%@ attribute name="hint" type="java.lang.String" %>

<c:set var="item" value="${requestScope.cfg[key]}" />
<c:set var="err" value="${requestScope.fieldErrors[key]}" />
<c:set var="val" value="${requestScope.formValues[key] ne null ? requestScope.formValues[key] : item.configValue}" />
<c:set var="inputType" value="${empty type ? 'text' : type}" />

<div class="mb-3">
    <label for="cfg_${key}" class="form-label fw-semibold mb-1">
        <c:out value="${label}" /> <code class="small fw-normal">${key}</code>
    </label>
    <c:choose>
        <c:when test="${empty item}">
            <div class="alert alert-warning py-2 mb-0 small">
                Khóa này chưa có trong CSDL. Hãy chạy <code>document/sql/02_data.sql</code>.
            </div>
        </c:when>
        <c:when test="${inputType == 'password'}">
            <div class="input-group has-validation">
                <input type="password" class="form-control ${not empty err ? 'is-invalid' : ''}" id="cfg_${key}"
                       name="${key}" value="" autocomplete="new-password"
                       placeholder="${fn:escapeXml(not empty item.configValue ? 'Hiện tại: '.concat(item.configValue).concat(' — để trống nếu giữ nguyên') : 'Nhập API Key từ Google AI Studio')}">
                <button class="btn btn-outline-secondary" type="button" data-toggle-secret="cfg_${key}"
                        aria-label="Hiện / ẩn khóa"><i class="bi bi-eye"></i></button>
                <c:if test="${not empty err}"><div class="invalid-feedback"><c:out value="${err}" /></div></c:if>
            </div>
        </c:when>
        <c:when test="${inputType == 'textarea'}">
            <textarea class="form-control font-monospace small ${not empty err ? 'is-invalid' : ''}" id="cfg_${key}"
                      name="${key}" rows="10" maxlength="8000" required><c:out value="${val}" /></textarea>
            <c:if test="${not empty err}"><div class="invalid-feedback"><c:out value="${err}" /></div></c:if>
        </c:when>
        <c:when test="${inputType == 'model'}">
            <%-- Tên model không hard-code: nhập tự do (gợi ý bằng datalist), Admin đổi khi model bị ngừng --%>
            <input type="text" class="form-control ${not empty err ? 'is-invalid' : ''}" id="cfg_${key}"
                   name="${key}" list="modelSuggestions" pattern="[a-z0-9.\-]+" required
                   value="<c:out value='${val}'/>">
            <c:if test="${not empty err}"><div class="invalid-feedback"><c:out value="${err}" /></div></c:if>
        </c:when>
        <c:otherwise>
            <input type="${inputType}" class="form-control ${not empty err ? 'is-invalid' : ''}" id="cfg_${key}"
                   name="${key}" required value="<c:out value='${val}'/>"
                   <c:if test="${not empty min}">min="${min}"</c:if>
                   <c:if test="${not empty max}">max="${max}"</c:if>
                   <c:if test="${not empty step}">step="${step}"</c:if>>
            <c:if test="${not empty err}"><div class="invalid-feedback"><c:out value="${err}" /></div></c:if>
        </c:otherwise>
    </c:choose>
    <div class="form-text">
        <c:if test="${not empty hint}"><c:out value="${hint}" /></c:if>
        <c:if test="${not empty item.updatedByName}">
            <span class="ms-1"><i class="bi bi-person"></i> <c:out value="${item.updatedByName}" /></span>
        </c:if>
        <c:if test="${not empty item.updatedAt}">
            <span class="ms-1"><i class="bi bi-clock"></i> <fmt:formatDate value="${item.updatedAt}" pattern="dd/MM/yyyy HH:mm" /></span>
        </c:if>
    </div>
</div>
