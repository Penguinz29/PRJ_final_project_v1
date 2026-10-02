<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <jsp:include page="../common/head.jsp">
                <jsp:param name="title" value="Quản lý Câu hỏi" />
            </jsp:include>

            <body data-ctx="${pageContext.request.contextPath}">
                <jsp:include page="../common/navbar.jsp" />
                <div class="app-shell">
                    <jsp:include page="../common/sidebar.jsp">
                        <jsp:param name="active" value="admin-questions" />
                    </jsp:include>
                    <main class="app-main">
                        <ui:flash />
                        <div class="page-header">
                            <h1><i class="bi bi-patch-question me-2 text-primary"></i>Danh sách Câu hỏi</h1>
                        </div>

                        <div class="card table-card mb-3">
                            <div class="table-responsive">
                                <table class="table table-hover mb-0">
                                    <thead>
                                        <tr>
                                            <th>#</th>
                                            <th>Nội dung</th>
                                            <th>Loại</th>
                                            <th>Thuộc bài giảng</th>
                                            <th>Ngày tạo</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="q" items="${questions}" varStatus="vs">
                                            <tr>
                                                <td class="text-muted">
                                                    <c:out value="${(page - 1) * 10 + vs.count}" />
                                                </td>
                                                <td class="fw-semibold"
                                                    style="max-width:300px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">
                                                    <c:out value="${q.content}" />
                                                </td>
                                                <td>
                                                    <span class="badge ${q.questionType=='MCQ'?'bg-primary':'bg-info'}">
                                                        <c:out value="${q.questionType}" />
                                                    </span>
                                                </td>
                                                <td><span class="badge bg-secondary">
                                                        <c:out value="${q.lessonTitle}" />
                                                    </span></td>
                                                <td class="text-muted">
                                                    <fmt:formatDate value="${q.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        <c:if test="${empty questions}">
                                            <tr>
                                                <td colspan="5" class="text-center py-4 text-muted">Chưa có câu hỏi nào.
                                                </td>
                                            </tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                        <ui:pagination baseUrl="${pageContext.request.contextPath}/admin/questions" page="${page}" totalPages="${totalPages}" />
                    </main>
                </div>
                <jsp:include page="../common/footer.jsp" />
            </body>

            </html>