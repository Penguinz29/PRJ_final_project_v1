<%-- 403: sai vai trò, sai chủ sở hữu hoặc sai mã CSRF. Được GlobalExceptionHandler / AuthInterceptor forward tới. --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<ui:error-card code="403" color="warning" icon="bi-shield-lock" title="Không có quyền truy cập">
    Bạn không có quyền truy cập trang này. Vui lòng liên hệ quản trị viên.
</ui:error-card>
