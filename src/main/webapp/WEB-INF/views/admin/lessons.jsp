<%-- File: WEB-INF/views/admin/lessons.jsp. Controller: AdminContentController (/admin/lessons). Attributes: lessons(List<Lesson>) --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <jsp:include page="../common/head.jsp">
                <jsp:param name="title" value="Quản lý Bài học" />
            </jsp:include>

            <body data-ctx="${pageContext.request.contextPath}">
                <jsp:include page="../common/navbar.jsp" />
                <div class="app-shell">
                    <jsp:include page="../common/sidebar.jsp">
                        <jsp:param name="active" value="admin-lessons" />
                    </jsp:include>
                    <main class="app-main">
                        <ui:flash />
                        <div class="page-header">
                            <h1><i class="bi bi-journal-richtext me-2 text-primary"></i>Danh sách Bài học
                                <span class="badge bg-secondary ms-2">${lessons.size()}</span>
                            </h1>
                        </div>

                        <div class="card table-card mb-3">
                            <div class="table-responsive">
                                <table class="table table-hover mb-0">
                                    <thead>
                                        <tr>
                                            <th>#</th>
                                            <th>Tiêu đề</th>
                                            <th>Chủ đề</th>
                                            <th>Số câu hỏi</th>
                                            <th>Ngày tạo</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="l" items="${lessons}" varStatus="vs">
                                            <tr>
                                                <td class="text-muted">${vs.count}</td>
                                                <td class="fw-semibold">
                                                    <c:out value="${l.title}" />
                                                </td>
                                                <td>
                                                    <span class="badge bg-info text-dark">
                                                        <c:out value="${l.topicName}" />
                                                    </span>
                                                </td>
                                                <td>
                                                    <span class="badge bg-primary-subtle text-primary">${l.questionCount} câu</span>
                                                </td>
                                                <td class="text-muted">
                                                    <fmt:formatDate value="${l.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        <c:if test="${empty lessons}">
                                            <tr>
                                                <td colspan="5" class="text-center py-4 text-muted">Chưa có bài học nào.</td>
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
