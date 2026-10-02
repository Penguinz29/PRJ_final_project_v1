<%-- flash.jsp: hiển thị flash message thành công + error request --%>
    <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
        <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

            <c:if test="${not empty sessionScope.flash}">
                <div class="alert alert-success alert-dismissible fade show flash-alert" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i>
                    <c:out value="${sessionScope.flash}" />
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <c:remove var="flash" scope="session" />
            </c:if>

            <c:if test="${not empty sessionScope.errorFlash}">
                <div class="alert alert-danger alert-dismissible fade show flash-alert" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i>
                    <c:out value="${sessionScope.errorFlash}" />
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <c:remove var="errorFlash" scope="session" />
            </c:if>

            <c:if test="${not empty requestScope.error}">
                <div class="alert alert-danger alert-dismissible fade show flash-alert" role="alert">
                    <i class="bi bi-exclamation-circle-fill me-2"></i>
                    <c:out value="${requestScope.error}" />
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>