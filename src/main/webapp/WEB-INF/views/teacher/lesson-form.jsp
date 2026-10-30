<%-- File: WEB-INF/views/teacher/lesson-form.jsp Servlet: TeacherLessonServlet (GET ?action=create|edit) Attributes:
    lesson(Lesson - null nếu create), topics(List<Topic>), isEdit(boolean)
    POST fields: title, topicId, summary, content, action(create|update), id
    --%>
    <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
        <%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
            <jsp:include page="../common/head.jsp">
                <jsp:param name="title" value="${isEdit ? 'Sửa bài giảng' : 'Thêm bài giảng'}" />
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
                            <h1>
                                <i class="bi bi-journal-plus me-2 text-primary"></i>
                                ${isEdit ? 'Sửa bài giảng' : 'Thêm bài giảng mới'}
                            </h1>
                            <a href="${pageContext.request.contextPath}${base}/lessons"
                                class="btn btn-sm btn-outline-secondary">
                                <i class="bi bi-arrow-left me-1"></i>Quay lại
                            </a>
                        </div>

                        <div class="row g-4">
                            <div class="col-lg-8">
                                <form action="${pageContext.request.contextPath}${base}/lessons" method="post"
                                    class="needs-validation" novalidate id="lessonForm">
<input type="hidden" name="_csrf" value="${sessionScope.CSRF_TOKEN}">
                                    <input type="hidden" name="action" value="${isEdit ? 'update' : 'create'}">
                                    <c:if test="${isEdit}">
                                        <input type="hidden" name="id" value="${lesson.lessonId}">
                                    </c:if>

                                    <div class="card">
                                        <div class="card-header"><i class="bi bi-info-circle me-2"></i>Thông tin cơ bản
                                        </div>
                                        <div class="card-body">
                                            <div class="mb-3">
                                                <label class="form-label fw-semibold" for="lessonTitle">Tiêu đề <span
                                                        class="text-danger">*</span></label>
                                                <input type="text" class="form-control" id="lessonTitle" name="title"
                                                    value="<c:out value='${lesson.title}'/>" maxlength="200" required
                                                    placeholder="VD: Giới hạn hàm số tại một điểm">
                                                <div class="invalid-feedback">Vui lòng nhập tiêu đề.</div>
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label fw-semibold" for="lessonTopic">Chủ đề <span
                                                        class="text-danger">*</span></label>
                                                <select class="form-select" id="lessonTopic" name="topicId" required>
                                                    <option value="">-- Chọn chủ đề --</option>
                                                    <c:forEach var="t" items="${topics}">
                                                        <option value="${t.topicId}" ${lesson.topicId==t.topicId
                                                            ? 'selected' : '' }>
                                                            <c:out value="${t.topicName}" />
                                                        </option>
                                                    </c:forEach>
                                                </select>
                                                <div class="invalid-feedback">Vui lòng chọn chủ đề.</div>
                                            </div>
                                            <div class="mb-0">
                                                <label class="form-label fw-semibold" for="lessonSummary">Tóm
                                                    tắt</label>
                                                <textarea class="form-control" id="lessonSummary" name="summary"
                                                    rows="2" maxlength="500"
                                                    placeholder="Tóm tắt ngắn về nội dung bài giảng..."><c:out value="${lesson.summary}"/></textarea>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="card mt-3">
                                        <div class="card-header"><i class="bi bi-file-text me-2"></i>Nội dung bài giảng
                                        </div>
                                        <div class="card-body">
                                            <div class="mb-2">
                                                <small class="text-muted">Sử dụng LaTeX: <code>\$x^2\$</code> hoặc
                                                    <code>\$\$\frac{a}{b}\$\$</code> cho công thức</small>
                                            </div>
                                            <textarea class="form-control font-monospace" id="lessonContent"
                                                name="content" rows="14"
                                                placeholder="Nhập nội dung bài giảng...&#10;Ví dụ: Định nghĩa giới hạn $\lim_{x \to a} f(x) = L$"
                                                data-latex-preview="#previewContent"><c:out value="${lesson.content}"/></textarea>
                                        </div>
                                    </div>

                                    <div class="alert alert-info mt-3 mb-0 small">
                                        <i class="bi bi-collection-play me-1"></i>
                                        Video YouTube, video tệp, liên kết website và bài giảng dạng văn bản được quản lý riêng:
                                        <c:choose>
                                            <c:when test="${isEdit}">
                                                <a href="${pageContext.request.contextPath}${base}/lessons/${lesson.lessonId}/materials"
                                                    class="alert-link">mở trang Bài giảng của bài học này</a>.
                                            </c:when>
                                            <c:otherwise>lưu bài học trước, rồi bấm nút <strong>Bài giảng</strong> ở danh sách bài học.</c:otherwise>
                                        </c:choose>
                                    </div>

                                    <div class="d-flex gap-2 mt-3">
                                        <button type="submit" class="btn btn-primary">
                                            <i class="bi bi-check-lg me-1"></i>${isEdit ? 'Lưu thay đổi' : 'Tạo bài
                                            giảng'}
                                        </button>
                                        <a href="${pageContext.request.contextPath}${base}/lessons"
                                            class="btn btn-outline-secondary">Hủy</a>
                                    </div>
                                </form>
                            </div>

                            <%-- Preview LaTeX --%>
                                <div class="col-lg-4">
                                    <div class="card" style="position:sticky;top:calc(var(--navbar-h) + 1rem);">
                                        <div class="card-header"><i class="bi bi-eye me-2"></i>Preview nội dung</div>
                                        <div class="card-body latex-content" id="previewContent"
                                            style="min-height:200px;font-size:.9rem;line-height:1.7;">
                                            <span class="text-muted">Nhập nội dung bên trái để xem preview...</span>
                                        </div>
                                    </div>
                                </div>
                        </div>
                    </main>
                </div>
                <jsp:include page="../common/footer.jsp" />
            </body>

            </html>