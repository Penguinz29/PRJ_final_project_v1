<%-- pagination.tag: phân trang Bootstrap dùng lại cho mọi danh sách.
     baseUrl giữ nguyên các tham số lọc hiện có (chỉ nối thêm page=...). --%>
<%@ tag language="java" pageEncoding="UTF-8" body-content="empty" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ attribute name="baseUrl" required="true" type="java.lang.String" %>
<%@ attribute name="page" required="true" type="java.lang.Integer" %>
<%@ attribute name="totalPages" required="true" type="java.lang.Integer" %>

<c:if test="${totalPages > 1}">
    <c:set var="sep" value="${fn:contains(baseUrl, '?') ? '&amp;' : '?'}" />
    <nav aria-label="Phân trang" class="mt-3">
        <ul class="pagination pagination-sm justify-content-center mb-0">

            <%-- Nút Trước --%>
            <li class="page-item ${page <= 1 ? 'disabled' : ''}">
                <a class="page-link" href="${page > 1 ? baseUrl.concat(sep).concat('page=').concat(page - 1) : '#'}">
                    <i class="bi bi-chevron-left"></i>
                </a>
            </li>

            <%-- Trang đầu + dấu ... --%>
            <c:if test="${page > 3}">
                <li class="page-item"><a class="page-link" href="${baseUrl}${sep}page=1">1</a></li>
                <c:if test="${page > 4}">
                    <li class="page-item disabled"><span class="page-link">…</span></li>
                </c:if>
            </c:if>

            <%-- Cửa sổ 5 trang --%>
            <c:set var="start" value="${page - 2 > 1 ? page - 2 : 1}" />
            <c:set var="end" value="${page + 2 < totalPages ? page + 2 : totalPages}" />
            <c:forEach var="i" begin="${start}" end="${end}">
                <li class="page-item ${i == page ? 'active' : ''}">
                    <a class="page-link" href="${baseUrl}${sep}page=${i}">${i}</a>
                </li>
            </c:forEach>

            <%-- Dấu ... + Trang cuối --%>
            <c:if test="${page < totalPages - 2}">
                <c:if test="${page < totalPages - 3}">
                    <li class="page-item disabled"><span class="page-link">…</span></li>
                </c:if>
                <li class="page-item"><a class="page-link" href="${baseUrl}${sep}page=${totalPages}">${totalPages}</a></li>
            </c:if>

            <%-- Nút Sau --%>
            <li class="page-item ${page >= totalPages ? 'disabled' : ''}">
                <a class="page-link"
                    href="${page < totalPages ? baseUrl.concat(sep).concat('page=').concat(page + 1) : '#'}">
                    <i class="bi bi-chevron-right"></i>
                </a>
            </li>
        </ul>
    </nav>
</c:if>
