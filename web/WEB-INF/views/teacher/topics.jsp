<%-- File: WEB-INF/views/teacher/topics.jsp Servlet: TeacherTopicServlet (/teacher/topics) Attributes:
    topics(List<Topic>), page(int), totalPages(int), totalRecords(int)
    --%>
    <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
        <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
            <jsp:include page="../common/head.jsp">
                <jsp:param name="title" value="Chủ đề của tôi" />
            </jsp:include>

            <body data-ctx="${pageContext.request.contextPath}">
                <jsp:include page="../common/navbar.jsp" />
                <div class="app-shell">
                    <jsp:include page="../common/sidebar.jsp">
                        <jsp:param name="active" value="teacher-topics" />
                    </jsp:include>
                    <main class="app-main">
                        <jsp:include page="../common/flash.jsp" />
                        <div class="page-header">
                            <h1><i class="bi bi-folder2 me-2 text-primary"></i>Chủ đề của tôi
                                <span class="badge bg-secondary ms-2">${totalRecords}</span>
                            </h1>
                            <button class="btn btn-primary btn-sm" data-action="add-topic" data-bs-toggle="modal"
                                data-bs-target="#topicModal">
                                <i class="bi bi-plus-lg me-1"></i>Thêm chủ đề
                            </button>
                        </div>

                        <div class="card table-card">
                            <div class="table-responsive">
                                <table class="table table-hover mb-0">
                                    <thead>
                                        <tr>
                                            <th>#</th>
                                            <th>Tên chủ đề</th>
                                            <th>Mô tả</th>
                                            <th>Bài giảng</th>
                                            <th style="width:120px">Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${empty topics}">
                                                <tr>
                                                    <td colspan="5">
                                                        <div class="empty-state">
                                                            <i class="bi bi-folder empty-icon"></i>
                                                            <p>Bạn chưa có chủ đề nào.</p>
                                                            <button class="btn btn-primary btn-sm"
                                                                data-action="add-topic" data-bs-toggle="modal"
                                                                data-bs-target="#topicModal">
                                                                <i class="bi bi-plus-lg me-1"></i>Tạo chủ đề đầu tiên
                                                            </button>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:when>
                                            <c:otherwise>
                                                <c:forEach var="t" items="${topics}" varStatus="vs">
                                                    <tr>
                                                        <td class="text-muted">${vs.count}</td>
                                                        <td class="fw-semibold">
                                                            <c:out value="${t.topicName}" />
                                                        </td>
                                                        <td class="text-muted"
                                                            style="max-width:260px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">
                                                            <c:out value="${t.description}" />
                                                        </td>
                                                        <td>
                                                            <a href="${pageContext.request.contextPath}/teacher/lessons?topicId=${t.topicId}"
                                                                class="badge bg-primary-subtle text-primary text-decoration-none">
                                                                ${t.lessonCount} bài
                                                            </a>
                                                        </td>
                                                        <td>
                                                            <button class="btn btn-sm btn-outline-primary me-1"
                                                                data-action="edit-topic" data-bs-toggle="modal"
                                                                data-bs-target="#topicModal"
                                                                data-topic-id="${t.topicId}"
                                                                data-topic-name="<c:out value='${t.topicName}'/>"
                                                                data-description="<c:out value='${t.description}'/>">
                                                                <i class="bi bi-pencil"></i>
                                                            </button>
                                                            <form class="d-inline" id="delT${t.topicId}"
                                                                action="${pageContext.request.contextPath}/teacher/topics"
                                                                method="post">
                                                                <input type="hidden" name="action" value="delete">
                                                                <input type="hidden" name="id" value="${t.topicId}">
                                                            </form>
                                                            <button class="btn btn-sm btn-outline-danger"
                                                                data-confirm="true" data-form="#delT${t.topicId}"
                                                                data-confirm-message="Xóa chủ đề '${t.topicName}'?">
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
                            <jsp:param name="baseUrl" value="${pageContext.request.contextPath}/teacher/topics" />
                        </jsp:include>
                    </main>
                </div>

                <%-- Modal Thêm/Sửa chủ đề --%>
                    <div class="modal fade" id="topicModal" tabindex="-1" aria-hidden="true">
                        <div class="modal-dialog modal-dialog-centered">
                            <div class="modal-content border-0 shadow">
                                <div class="modal-header border-0">
                                    <h5 class="modal-title">Chủ đề</h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                </div>
                                <form action="${pageContext.request.contextPath}/teacher/topics" method="post"
                                    class="needs-validation" novalidate>
                                    <input type="hidden" name="action" value="create">
                                    <input type="hidden" name="topicId">
                                    <div class="modal-body">
                                        <div class="mb-3">
                                            <label class="form-label fw-semibold" for="topicName">Tên chủ đề <span
                                                    class="text-danger">*</span></label>
                                            <input type="text" class="form-control" id="topicName" name="topicName"
                                                maxlength="150" required placeholder="VD: Hàm số và đồ thị">
                                            <div class="invalid-feedback">Vui lòng nhập tên chủ đề.</div>
                                        </div>
                                        <div class="mb-0">
                                            <label class="form-label fw-semibold" for="topicDesc">Mô tả</label>
                                            <textarea class="form-control" id="topicDesc" name="description" rows="3"
                                                maxlength="500"></textarea>
                                        </div>
                                    </div>
                                    <div class="modal-footer border-0">
                                        <button type="button" class="btn btn-outline-secondary"
                                            data-bs-dismiss="modal">Hủy</button>
                                        <button type="submit" class="btn btn-primary"><i
                                                class="bi bi-check-lg me-1"></i>Lưu</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                    <jsp:include page="../common/confirm-modal.jsp" />
                    <jsp:include page="../common/footer.jsp" />
            </body>

            </html>