<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <jsp:include page="../common/head.jsp">
                <jsp:param name="title" value="Quản lý Chủ đề" />
            </jsp:include>

            <body data-ctx="${pageContext.request.contextPath}">
                <jsp:include page="../common/navbar.jsp" />
                <div class="app-shell">
                    <jsp:include page="../common/sidebar.jsp">
                        <jsp:param name="active" value="admin-topics" />
                    </jsp:include>
                    <main class="app-main">
                        <ui:flash />
                        <div class="page-header">
                            <h1><i class="bi bi-folder2 me-2 text-primary"></i>Danh sách Chủ đề</h1>
                        </div>

                        <div class="card table-card mb-3">
                            <div class="table-responsive">
                                <table class="table table-hover mb-0">
                                    <thead>
                                        <tr>
                                            <th>#</th>
                                            <th>Tên chủ đề</th>
                                            <th>Mô tả</th>
                                            <th>Bài giảng</th>
                                            <th>Người tạo</th>
                                            <th>Ngày tạo</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="t" items="${topics}" varStatus="vs">
                                            <tr>
                                                <td class="text-muted">
                                                    <c:out value="${vs.count}" />
                                                </td>
                                                <td class="fw-semibold">
                                                    <c:out value="${t.topicName}" />
                                                </td>
                                                <td
                                                    style="max-width:300px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">
                                                    <c:out value="${t.description}" />
                                                </td>
                                                <td>
                                                    <a href="${pageContext.request.contextPath}/teacher/lessons?topicId=${t.topicId}"
                                                        class="badge bg-primary-subtle text-primary text-decoration-none">
                                                        ${t.lessonCount} bài
                                                    </a>
                                                </td>
                                                <td>
                                                    <span class="badge bg-info text-dark"><i
                                                            class="bi bi-person me-1"></i>
                                                        <c:out value="${t.teacherName}" />
                                                    </span>
                                                </td>
                                                <td class="text-muted">
                                                    <fmt:formatDate value="${t.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        <c:if test="${empty topics}">
                                            <tr>
                                                <td colspan="6" class="text-center py-4 text-muted">Chưa có chủ đề nào.
                                                </td>
                                            </tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </main>
                </div>
                <jsp:include page="../common/footer.jsp" />
            </body>

            </html>