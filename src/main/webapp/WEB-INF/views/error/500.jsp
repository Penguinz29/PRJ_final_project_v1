<%-- 500: lỗi hệ thống. Chỉ hiện mã tham chiếu ERR-yyyyMMdd-xxxx, không bao giờ hiện stack trace hay câu SQL. --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<ui:error-card code="500" color="danger" icon="bi-exclamation-octagon" title="Lỗi hệ thống">
    Đã xảy ra lỗi. Vui lòng thử lại sau hoặc liên hệ quản trị viên.
    <c:if test="${not empty errorRef}"><br>Mã tham chiếu: <strong><c:out value="${errorRef}" /></strong></c:if>
</ui:error-card>
