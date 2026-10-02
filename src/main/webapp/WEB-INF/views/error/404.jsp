<%-- 404: không tìm thấy trang / tài nguyên. --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<ui:error-card code="404" color="primary" icon="bi-compass" title="Trang không tồn tại">
    Trang bạn tìm kiếm không được tìm thấy.
</ui:error-card>
