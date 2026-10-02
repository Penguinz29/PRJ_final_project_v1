<%-- pagination.jsp: phân trang Bootstrap. Param: baseUrl, page (attr), totalPages (attr) --%>
    <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
        <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
            <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

                <c:if test="${totalPages > 1}">
                    <nav aria-label="Phân trang" class="mt-3">
                        <ul class="pagination pagination-sm justify-content-center mb-0">

                            <%-- Nút Trước --%>
                                <li class="page-item ${page <= 1 ? 'disabled' : ''}">
                                    <c:set var="sep" value="${fn:contains(param.baseUrl, '?') ? '&amp;' : '?'}" />
                                    <a class="page-link"
                                        href="${page > 1 ? param.baseUrl.concat(sep).concat('page=').concat(page - 1) : '#'}">
                                        <i class="bi bi-chevron-left"></i>
                                    </a>
                                </li>

                                <%-- Trang đầu + dấu ... --%>
                                    <c:if test="${page > 3}">
                                        <li class="page-item">
                                            <c:set var="sep2"
                                                value="${fn:contains(param.baseUrl, '?') ? '&amp;' : '?'}" />
                                            <a class="page-link" href="${param.baseUrl}${sep2}page=1">1</a>
                                        </li>
                                        <c:if test="${page > 4}">
                                            <li class="page-item disabled"><span class="page-link">…</span></li>
                                        </c:if>
                                    </c:if>

                                    <%-- Cửa sổ 5 trang --%>
                                        <c:set var="start" value="${page - 2 > 1 ? page - 2 : 1}" />
                                        <c:set var="end" value="${page + 2 < totalPages ? page + 2 : totalPages}" />
                                        <c:forEach var="i" begin="${start}" end="${end}">
                                            <c:set var="sep3"
                                                value="${fn:contains(param.baseUrl, '?') ? '&amp;' : '?'}" />
                                            <li class="page-item ${i == page ? 'active' : ''}">
                                                <a class="page-link" href="${param.baseUrl}${sep3}page=${i}">${i}</a>
                                            </li>
                                        </c:forEach>

                                        <%-- Dấu ... + Trang cuối --%>
                                            <c:if test="${page < totalPages - 2}">
                                                <c:if test="${page < totalPages - 3}">
                                                    <li class="page-item disabled"><span class="page-link">…</span></li>
                                                </c:if>
                                                <c:set var="sep4"
                                                    value="${fn:contains(param.baseUrl, '?') ? '&amp;' : '?'}" />
                                                <li class="page-item">
                                                    <a class="page-link"
                                                        href="${param.baseUrl}${sep4}page=${totalPages}">${totalPages}</a>
                                                </li>
                                            </c:if>

                                            <%-- Nút Sau --%>
                                                <li class="page-item ${page >= totalPages ? 'disabled' : ''}">
                                                    <c:set var="sep5"
                                                        value="${fn:contains(param.baseUrl, '?') ? '&amp;' : '?'}" />
                                                    <a class="page-link"
                                                        href="${page < totalPages ? param.baseUrl.concat(sep5).concat('page=').concat(page + 1) : '#'}">
                                                        <i class="bi bi-chevron-right"></i>
                                                    </a>
                                                </li>
                        </ul>
                    </nav>
                </c:if>