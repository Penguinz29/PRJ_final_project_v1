<%-- File: WEB-INF/views/teacher/materials.jsp
     Controller: TeacherMaterialController (GET /teacher/lessons/{lessonId}/materials)
     Attributes: lesson (LessonView), materials (List<MaterialView>) --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
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

            <nav aria-label="breadcrumb">
                <ol class="breadcrumb mb-1" style="font-size:.85rem;">
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/teacher/lessons"
                            class="text-decoration-none">Bài học</a></li>
                    <li class="breadcrumb-item active" aria-current="page">
                        <c:out value="${lesson.title}" />
                    </li>
                </ol>
            </nav>
            <div class="page-header">
                <h1><i class="bi bi-collection-play me-2 text-primary"></i>Bài giảng
                    <span class="badge bg-secondary ms-2">${fn:length(materials)}</span>
                </h1>
                <div class="d-flex gap-2">
                    <a href="${pageContext.request.contextPath}/teacher/lessons" class="btn btn-outline-secondary btn-sm">
                        <i class="bi bi-arrow-left me-1"></i>Quay lại
                    </a>
                    <button class="btn btn-primary btn-sm" data-action="add-material" data-bs-toggle="modal"
                        data-bs-target="#materialModal">
                        <i class="bi bi-plus-lg me-1"></i>Thêm bài giảng
                    </button>
                </div>
            </div>
            <p class="text-muted">Bài học: <strong><c:out value="${lesson.title}" /></strong>
                (<c:out value="${lesson.topicName}" />)</p>

            <div class="card table-card">
                <div class="table-responsive">
                    <table class="table table-hover mb-0 align-middle">
                        <thead>
                            <tr>
                                <th style="width:60px">Thứ tự</th>
                                <th style="width:110px">Loại</th>
                                <th>Tiêu đề</th>
                                <th>Nội dung / Đường dẫn</th>
                                <th>Người tạo</th>
                                <th style="width:120px">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty materials}">
                                    <tr>
                                        <td colspan="6">
                                            <div class="empty-state">
                                                <i class="bi bi-collection-play empty-icon"></i>
                                                <p>Bài học này chưa có bài giảng nào.</p>
                                                <button class="btn btn-primary btn-sm" data-action="add-material"
                                                    data-bs-toggle="modal" data-bs-target="#materialModal">
                                                    <i class="bi bi-plus-lg me-1"></i>Thêm bài giảng đầu tiên
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="m" items="${materials}">
                                        <c:set var="canEdit"
                                            value="${m.createdBy == sessionScope.LOGGED_IN_USER.userId or sessionScope.LOGGED_IN_USER.role == 'ADMIN'}" />
                                        <tr>
                                            <td class="text-muted">${m.orderIndex}</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${m.materialType == 'YOUTUBE'}"><span class="badge bg-danger"><i class="bi bi-youtube me-1"></i>YouTube</span></c:when>
                                                    <c:when test="${m.materialType == 'VIDEO'}"><span class="badge bg-dark"><i class="bi bi-film me-1"></i>Video</span></c:when>
                                                    <c:when test="${m.materialType == 'LINK'}"><span class="badge bg-info text-dark"><i class="bi bi-link-45deg me-1"></i>Liên kết</span></c:when>
                                                    <c:otherwise><span class="badge bg-success"><i class="bi bi-text-paragraph me-1"></i>Văn bản</span></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="fw-semibold"><c:out value="${m.title}" /></td>
                                            <td class="text-muted"
                                                style="max-width:320px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">
                                                <c:choose>
                                                    <c:when test="${m.materialType == 'TEXT'}"><ui:rich-text value="${m.contentText}" /></c:when>
                                                    <c:otherwise><c:out value="${m.url}" /></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-muted"><c:out value="${m.createdByName}" /></td>
                                            <td>
                                                <c:if test="${canEdit}">
                                                    <button class="btn btn-sm btn-outline-primary me-1" data-action="edit-material"
                                                        data-bs-toggle="modal" data-bs-target="#materialModal"
                                                        data-material-id="${m.materialId}"
                                                        data-type="${m.materialType}"
                                                        data-title="<c:out value='${m.title}'/>"
                                                        data-url="<c:out value='${m.url}'/>"
                                                        data-content="<c:out value='${m.contentText}'/>"
                                                        data-order="${m.orderIndex}">
                                                        <i class="bi bi-pencil"></i>
                                                    </button>
                                                    <form class="d-inline" id="delM${m.materialId}"
                                                        action="${pageContext.request.contextPath}/teacher/materials/${m.materialId}/delete"
                                                        method="post">
                                                        <input type="hidden" name="_csrf" value="${sessionScope.CSRF_TOKEN}">
                                                    </form>
                                                    <button class="btn btn-sm btn-outline-danger" data-confirm="true"
                                                        data-form="#delM${m.materialId}"
                                                        data-confirm-message="Xóa bài giảng '${fn:escapeXml(m.title)}'?">
                                                        <i class="bi bi-trash3"></i>
                                                    </button>
                                                </c:if>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>

    <%-- Modal Thêm/Sửa bài giảng --%>
    <div class="modal fade" id="materialModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content border-0 shadow">
                <div class="modal-header border-0">
                    <h5 class="modal-title" id="materialModalTitle">Thêm bài giảng</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form id="materialForm" action="${pageContext.request.contextPath}/teacher/lessons/${lesson.lessonId}/materials"
                    method="post" class="needs-validation" novalidate>
                    <input type="hidden" name="_csrf" value="${sessionScope.CSRF_TOKEN}">
                    <input type="hidden" name="lessonId" value="${lesson.lessonId}">
                    <div class="modal-body">
                        <div class="row g-3">
                            <div class="col-md-4">
                                <label class="form-label fw-semibold" for="materialType">Loại <span class="text-danger">*</span></label>
                                <select class="form-select" id="materialType" name="materialType" required>
                                    <option value="YOUTUBE">YouTube</option>
                                    <option value="VIDEO">Video (.mp4 / .webm / .ogg)</option>
                                    <option value="LINK">Liên kết website</option>
                                    <option value="TEXT">Văn bản (có công thức LaTeX)</option>
                                </select>
                            </div>
                            <div class="col-md-8">
                                <label class="form-label fw-semibold" for="materialTitle">Tiêu đề <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" id="materialTitle" name="title" maxlength="200" required
                                    placeholder="VD: Video bài giảng Lũy thừa">
                                <div class="invalid-feedback">Vui lòng nhập tiêu đề.</div>
                            </div>
                            <div class="col-12" id="urlGroup">
                                <label class="form-label fw-semibold" for="materialUrl">Đường dẫn (URL) <span class="text-danger">*</span></label>
                                <input type="url" class="form-control" id="materialUrl" name="url" maxlength="500"
                                    placeholder="https://www.youtube.com/watch?v=...">
                                <div class="form-text" id="urlHelp"></div>
                            </div>
                            <div class="col-12 d-none" id="textGroup">
                                <label class="form-label fw-semibold" for="materialContent">Nội dung <span class="text-danger">*</span></label>
                                <textarea class="form-control" id="materialContent" name="contentText" rows="8" maxlength="20000"
                                    placeholder="Nội dung bài giảng, công thức dùng $...$ hoặc $$...$$"></textarea>
                                <div class="form-text">Tối đa 20.000 ký tự.</div>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-semibold" for="materialOrder">Thứ tự hiển thị</label>
                                <input type="number" class="form-control" id="materialOrder" name="orderIndex" min="1" max="9999"
                                    placeholder="Tự động (cuối danh sách)">
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer border-0">
                        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-primary"><i class="bi bi-check-lg me-1"></i>Lưu</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    <jsp:include page="../common/confirm-modal.jsp" />
    <jsp:include page="../common/footer.jsp" />
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var ctx = document.body.dataset.ctx;
            var form = document.getElementById('materialForm');
            var type = document.getElementById('materialType');
            var urlGroup = document.getElementById('urlGroup');
            var textGroup = document.getElementById('textGroup');
            var url = document.getElementById('materialUrl');
            var content = document.getElementById('materialContent');
            var help = document.getElementById('urlHelp');
            var title = document.getElementById('materialModalTitle');
            var createAction = form.getAttribute('action');
            var HELP = {
                YOUTUBE: 'Dán link YouTube (youtube.com/watch?v=..., youtu.be/... hoặc youtube.com/embed/...).',
                VIDEO: 'Link trực tiếp tới tệp video .mp4, .webm hoặc .ogg.',
                LINK: 'Link website bắt đầu bằng http:// hoặc https://. Học sinh mở ở tab mới.'
            };

            function toggle() {
                var isText = type.value === 'TEXT';
                urlGroup.classList.toggle('d-none', isText);
                textGroup.classList.toggle('d-none', !isText);
                url.required = !isText;
                content.required = isText;
                help.textContent = HELP[type.value] || '';
            }
            type.addEventListener('change', toggle);

            document.querySelectorAll('[data-action="add-material"]').forEach(function (btn) {
                btn.addEventListener('click', function () {
                    form.reset();
                    form.setAttribute('action', createAction);
                    title.textContent = 'Thêm bài giảng';
                    toggle();
                });
            });
            document.querySelectorAll('[data-action="edit-material"]').forEach(function (btn) {
                btn.addEventListener('click', function () {
                    form.setAttribute('action', ctx + '/teacher/materials/' + btn.dataset.materialId + '/update');
                    title.textContent = 'Sửa bài giảng';
                    type.value = btn.dataset.type;
                    document.getElementById('materialTitle').value = btn.dataset.title || '';
                    url.value = btn.dataset.url || '';
                    content.value = btn.dataset.content || '';
                    document.getElementById('materialOrder').value = btn.dataset.order || '';
                    toggle();
                });
            });
            toggle();
        });
    </script>
</body>

</html>
