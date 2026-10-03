<%-- File: WEB-INF/views/teacher/lessons.jsp Servlet: TeacherLessonServlet (/teacher/lessons) Attributes:
    lessons(List<Lesson>), topics(List<Topic>), page(int), totalPages(int),
        totalRecords(int), selectedTopicId(Integer)
        --%>
        <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
            <%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
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
                            <ui:flash />
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
                                                    <th>Câu hỏi</th>
                                                    <th style="width:120px">Thao tác</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:choose>
                                                    <c:when test="${empty lessons}">
                                                        <tr>
                                                            <td colspan="5">
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
                                                                <td class="text-muted">${vs.count}</td>
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
                                                                    <a href="${pageContext.request.contextPath}/teacher/questions?lessonId=${l.lessonId}"
                                                                        class="badge bg-primary-subtle text-primary text-decoration-none">
                                                                        ${l.questionCount} câu
                                                                    </a>
                                                                </td>
                                                                <td>
                                                                    <a href="${pageContext.request.contextPath}/teacher/lessons/${l.lessonId}/materials"
                                                                        class="btn btn-sm btn-outline-secondary me-1"
                                                                        title="Quản lý bài giảng (video, link, văn bản)"><i
                                                                            class="bi bi-collection-play"></i></a>
                                                                    <a href="${pageContext.request.contextPath}/teacher/lessons?action=edit&id=${l.lessonId}"
                                                                        class="btn btn-sm btn-outline-primary me-1"><i
                                                                            class="bi bi-pencil"></i></a>
                                                                    <form class="d-inline" id="delL${l.lessonId}"
                                                                        action="${pageContext.request.contextPath}/teacher/lessons"
                                                                        method="post">
<input type="hidden" name="_csrf" value="${sessionScope.CSRF_TOKEN}">
                                                                        <input type="hidden" name="action"
                                                                            value="delete">
                                                                        <input type="hidden" name="id"
                                                                            value="${l.lessonId}">
                                                                    </form>
                                                                    <ui:delete-button form="#delL${l.lessonId}" mode="${l.deleteMode}"
                                                                        question="Xóa bài học '${l.title}'?"
                                                                        softNote="Bài học đã có học sinh làm bài nên chỉ được ẩn khỏi trang quản lý (xóa mềm); học sinh vẫn ôn tập được, lịch sử giữ nguyên."
                                                                        blockedReason="Không thể xóa: bài học còn ${l.questionCount} câu hỏi. Hãy xóa các câu hỏi trước." />
                                                                </td>
                                                            </tr>
                                                        </c:forEach>
                                                    </c:otherwise>
                                                </c:choose>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                                <ui:pagination baseUrl="${pageContext.request.contextPath}/teacher/lessons${not empty selectedTopicId ? '?topicId='.concat(selectedTopicId) : ''}" page="${page}" totalPages="${totalPages}" />
                        </main>
                    </div>
                    <jsp:include page="../common/confirm-modal.jsp" />
                    <jsp:include page="../common/footer.jsp" />
                </body>

                </html>