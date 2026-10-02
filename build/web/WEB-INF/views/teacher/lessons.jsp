<%-- File: WEB-INF/views/teacher/lessons.jsp Servlet: TeacherLessonServlet (/teacher/lessons) Attributes:
    lessons(List<Lesson>), topics(List<Topic>), page(int), totalPages(int),
        totalRecords(int), selectedTopicId(Integer)
        --%>
        <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
            <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
                <jsp:include page="../common/head.jsp">
                    <jsp:param name="title" value="Bài giảng" />
                </jsp:include>

                <body data-ctx="${pageContext.request.contextPath}">
                    <jsp:include page="../common/navbar.jsp" />
                    <div class="app-shell">
                        <jsp:include page="../common/sidebar.jsp">
                            <jsp:param name="active" value="teacher-lessons" />
                        </jsp:include>
                        <main class="app-main">
                            <jsp:include page="../common/flash.jsp" />
                            <div class="page-header">
                                <h1><i class="bi bi-journal-text me-2 text-primary"></i>Bài giảng
                                    <span class="badge bg-secondary ms-2">${totalRecords}</span>
                                </h1>
                                <a href="${pageContext.request.contextPath}/teacher/lessons?action=create"
                                    class="btn btn-primary btn-sm">
                                    <i class="bi bi-plus-lg me-1"></i>Thêm bài giảng
                                </a>
                            </div>

                            <%-- Lọc theo chủ đề --%>
                                <div class="card mb-3">
                                    <div class="card-body py-2">
                                        <form action="${pageContext.request.contextPath}/teacher/lessons" method="get"
                                            class="d-flex gap-2 align-items-center">
                                            <label class="text-muted fw-semibold"
                                                style="font-size:.85rem;white-space:nowrap">Lọc chủ đề:</label>
                                            <select class="form-select form-select-sm" name="topicId"
                                                onchange="this.form.submit()">
                                                <option value="">-- Tất cả --</option>
                                                <c:forEach var="t" items="${topics}">
                                                    <option value="${t.topicId}" ${selectedTopicId==t.topicId
                                                        ? 'selected' : '' }>
                                                        <c:out value="${t.topicName}" />
                                                    </option>
                                                </c:forEach>
                                            </select>
                                        </form>
                                    </div>
                                </div>

                                <div class="card table-card">
                                    <div class="table-responsive">
                                        <table class="table table-hover mb-0">
                                            <thead>
                                                <tr>
                                                    <th>#</th>
                                                    <th>Tiêu đề</th>
                                                    <th>Chủ đề</th>
                                                    <th>Video</th>
                                                    <th>Câu hỏi</th>
                                                    <th style="width:120px">Thao tác</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:choose>
                                                    <c:when test="${empty lessons}">
                                                        <tr>
                                                            <td colspan="6">
                                                                <div class="empty-state">
                                                                    <i class="bi bi-journal empty-icon"></i>
                                                                    <p>Chưa có bài giảng nào.</p>
                                                                    <a href="${pageContext.request.contextPath}/teacher/lessons?action=create"
                                                                        class="btn btn-primary btn-sm"><i
                                                                            class="bi bi-plus-lg me-1"></i>Tạo bài
                                                                        giảng</a>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <c:forEach var="l" items="${lessons}" varStatus="vs">
                                                            <tr>
                                                                <td class="text-muted">${(page-1)*10 + vs.count}</td>
                                                                <td>
                                                                    <div class="fw-semibold">
                                                                        <c:out value="${l.title}" />
                                                                    </div>
                                                                    <div class="text-muted"
                                                                        style="font-size:.78rem;max-width:280px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">
                                                                        <c:out value="${l.summary}" />
                                                                    </div>
                                                                </td>
                                                                <td><span
                                                                        class="badge bg-secondary-subtle text-secondary">
                                                                        <c:out value="${l.topicName}" />
                                                                    </span></td>
                                                                <td>
                                                                    <c:choose>
                                                                        <c:when test="${not empty l.youtubeUrl}">
                                                                            <i
                                                                                class="bi bi-play-btn-fill text-danger"></i>
                                                                        </c:when>
                                                                        <c:otherwise><span class="text-muted">—</span>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </td>
                                                                <td>
                                                                    <a href="${pageContext.request.contextPath}/teacher/questions?lessonId=${l.lessonId}"
                                                                        class="badge bg-primary-subtle text-primary text-decoration-none">
                                                                        ${l.questionCount} câu
                                                                    </a>
                                                                </td>
                                                                <td>
                                                                    <a href="${pageContext.request.contextPath}/teacher/lessons?action=edit&id=${l.lessonId}"
                                                                        class="btn btn-sm btn-outline-primary me-1"><i
                                                                            class="bi bi-pencil"></i></a>
                                                                    <form class="d-inline" id="delL${l.lessonId}"
                                                                        action="${pageContext.request.contextPath}/teacher/lessons"
                                                                        method="post">
                                                                        <input type="hidden" name="action"
                                                                            value="delete">
                                                                        <input type="hidden" name="id"
                                                                            value="${l.lessonId}">
                                                                    </form>
                                                                    <button class="btn btn-sm btn-outline-danger"
                                                                        data-confirm="true"
                                                                        data-form="#delL${l.lessonId}"
                                                                        data-confirm-message="Xóa bài giảng '${l.title}'?">
                                                                        <i class="bi bi-trash3"></i>
                                                                    </button>
                                                                </td>
                                                            </tr>
                                                        </c:forEach>
                                                    </c:otherwise>
                                                </c:choose>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                                <jsp:include page="../common/pagination.jsp">
                                    <jsp:param name="baseUrl"
                                        value="${pageContext.request.contextPath}/teacher/lessons${not empty selectedTopicId ? '?topicId='.concat(selectedTopicId) : ''}" />
                                </jsp:include>
                        </main>
                    </div>
                    <jsp:include page="../common/confirm-modal.jsp" />
                    <jsp:include page="../common/footer.jsp" />
                </body>

                </html>