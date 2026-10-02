<%-- flash.tag: thông báo thành công / lỗi dùng lại cho mọi trang.
     Giá trị đến từ RedirectAttributes (flash attribute) hoặc model của request: flash, errorFlash, error. --%>
<%@ tag language="java" pageEncoding="UTF-8" body-content="empty" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:if test="${not empty flash}">
    <div class="alert alert-success alert-dismissible fade show flash-alert" role="alert">
        <i class="bi bi-check-circle-fill me-2"></i>
        <c:out value="${flash}" />
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>

<c:if test="${not empty errorFlash}">
    <div class="alert alert-danger alert-dismissible fade show flash-alert" role="alert">
        <i class="bi bi-exclamation-triangle-fill me-2"></i>
        <c:out value="${errorFlash}" />
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>

<c:if test="${not empty error}">
    <div class="alert alert-danger alert-dismissible fade show flash-alert" role="alert">
        <i class="bi bi-exclamation-circle-fill me-2"></i>
        <c:out value="${error}" />
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>
