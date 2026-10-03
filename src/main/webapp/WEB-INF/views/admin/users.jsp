<%-- File: WEB-INF/views/admin/users.jsp
     Controller: AdminUserController (GET /admin/users)
     Attributes: users(List<UserView>), page, size, totalPages, totalRecords, keyword, role, status, baseUrl, returnUrl --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="../common/head.jsp">
    <jsp:param name="title" value="Quản lý Người dùng" />
</jsp:include>

<body data-ctx="${pageContext.request.contextPath}">
    <jsp:include page="../common/navbar.jsp" />
    <div class="app-shell">
        <jsp:include page="../common/sidebar.jsp">
            <jsp:param name="active" value="admin-users" />
        </jsp:include>
        <main class="app-main">
            <ui:flash />

            <div class="page-header">
                <h1><i class="bi bi-people me-2 text-primary"></i>Quản lý Người dùng
                    <span class="badge bg-secondary ms-2">${totalRecords}</span>
                </h1>
                <a href="${pageContext.request.contextPath}/admin/users/new" class="btn btn-primary btn-sm">
                    <i class="bi bi-person-plus me-1"></i>Tạo tài khoản
                </a>
            </div>

            <%-- Tìm kiếm + lọc --%>
            <form action="${pageContext.request.contextPath}/admin/users" method="get" class="card card-body mb-3">
                <div class="row g-2 align-items-end">
                    <div class="col-md-4">
                        <label class="form-label small fw-semibold mb-1" for="keyword">Tìm kiếm</label>
                        <input type="text" class="form-control" id="keyword" name="keyword" maxlength="100"
                            value="<c:out value='${keyword}'/>" placeholder="Họ tên, tên đăng nhập hoặc email">
                    </div>
                    <div class="col-md-2">
                        <label class="form-label small fw-semibold mb-1" for="role">Vai trò</label>
                        <select class="form-select" id="role" name="role">
                            <option value="">Tất cả</option>
                            <option value="ADMIN" ${role == 'ADMIN' ? 'selected' : ''}>Admin</option>
                            <option value="TEACHER" ${role == 'TEACHER' ? 'selected' : ''}>Giáo viên</option>
                            <option value="STUDENT" ${role == 'STUDENT' ? 'selected' : ''}>Học sinh</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label small fw-semibold mb-1" for="status">Trạng thái</label>
                        <select class="form-select" id="status" name="status">
                            <option value="">Tất cả</option>
                            <option value="ACTIVE" ${status == 'ACTIVE' ? 'selected' : ''}>Hoạt động</option>
                            <option value="SUSPENDED" ${status == 'SUSPENDED' ? 'selected' : ''}>Bị khóa</option>
                            <option value="INACTIVE" ${status == 'INACTIVE' ? 'selected' : ''}>Đã xóa</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label small fw-semibold mb-1" for="size">Hiển thị</label>
                        <select class="form-select" id="size" name="size">
                            <option value="10" ${size == 10 ? 'selected' : ''}>10 / trang</option>
                            <option value="20" ${size == 20 ? 'selected' : ''}>20 / trang</option>
                            <option value="50" ${size == 50 ? 'selected' : ''}>50 / trang</option>
                        </select>
                    </div>
                    <div class="col-md-2 d-flex gap-2">
                        <button type="submit" class="btn btn-primary flex-grow-1"><i class="bi bi-search me-1"></i>Lọc</button>
                        <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-outline-secondary" title="Xóa bộ lọc">
                            <i class="bi bi-x-lg"></i>
                        </a>
                    </div>
                </div>
            </form>

            <div class="card table-card mb-3">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Họ tên</th>
                                <th>Tên đăng nhập / Email</th>
                                <th>Vai trò</th>
                                <th>Trạng thái</th>
                                <th>Ngày tạo</th>
                                <th class="text-end" style="min-width:230px">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="u" items="${users}" varStatus="vs">
                                <c:set var="isSelf" value="${sessionScope.LOGGED_IN_USER.userId == u.userId}" />
                                <tr>
                                    <td class="text-muted">${(page - 1) * size + vs.count}</td>
                                    <td class="fw-semibold"><c:out value="${u.fullName}" /></td>
                                    <td>
                                        <c:out value="${u.username}" /><br>
                                        <small class="text-muted"><c:out value="${u.email}" /></small>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${u.role == 'ADMIN'}"><span class="badge bg-danger">Admin</span></c:when>
                                            <c:when test="${u.role == 'TEACHER'}"><span class="badge bg-primary">Giáo viên</span></c:when>
                                            <c:otherwise><span class="badge bg-success">Học sinh</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${u.status == 'ACTIVE'}"><span class="badge bg-success"><i class="bi bi-check-circle me-1"></i>Hoạt động</span></c:when>
                                            <c:when test="${u.status == 'SUSPENDED'}"><span class="badge bg-warning text-dark"><i class="bi bi-lock-fill me-1"></i>Bị khóa</span></c:when>
                                            <c:otherwise><span class="badge bg-secondary"><i class="bi bi-trash3 me-1"></i>Đã xóa</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-muted"><fmt:formatDate value="${u.createdAt}" pattern="dd/MM/yyyy HH:mm" /></td>
                                    <td class="text-end">
                                        <c:choose>
                                            <c:when test="${u.status == 'INACTIVE'}">
                                                <form class="d-inline" id="restore${u.userId}" method="post"
                                                    action="${pageContext.request.contextPath}/admin/users/${u.userId}/restore">
                                                    <input type="hidden" name="_csrf" value="${sessionScope.CSRF_TOKEN}">
                                                    <input type="hidden" name="returnUrl" value="<c:out value='${returnUrl}'/>">
                                                </form>
                                                <button type="button" class="btn btn-sm btn-outline-success" data-confirm="true"
                                                    data-form="#restore${u.userId}" title="Khôi phục tài khoản"
                                                    data-confirm-message="Khôi phục tài khoản '${fn:escapeXml(u.username)}'? Tài khoản sẽ hoạt động trở lại.">
                                                    <i class="bi bi-arrow-counterclockwise me-1"></i>Khôi phục
                                                </button>
                                            </c:when>
                                            <c:otherwise>
                                                <a href="${pageContext.request.contextPath}/admin/users/${u.userId}/edit"
                                                    class="btn btn-sm btn-outline-primary" title="Sửa"><i class="bi bi-pencil"></i></a>

                                                <form class="d-inline" id="reset${u.userId}" method="post"
                                                    action="${pageContext.request.contextPath}/admin/users/${u.userId}/reset-password">
                                                    <input type="hidden" name="_csrf" value="${sessionScope.CSRF_TOKEN}">
                                                </form>
                                                <button type="button" class="btn btn-sm btn-outline-secondary" data-confirm="true"
                                                    data-form="#reset${u.userId}" title="Đặt lại mật khẩu"
                                                    data-confirm-message="Đặt lại mật khẩu của '${fn:escapeXml(u.username)}'? Mật khẩu mới chỉ hiển thị một lần.">
                                                    <i class="bi bi-key"></i>
                                                </button>

                                                <c:if test="${not isSelf}">
                                                    <form class="d-inline" id="status${u.userId}" method="post"
                                                        action="${pageContext.request.contextPath}/admin/users/${u.userId}/status">
                                                        <input type="hidden" name="_csrf" value="${sessionScope.CSRF_TOKEN}">
                                                        <input type="hidden" name="status" value="${u.status == 'ACTIVE' ? 'SUSPENDED' : 'ACTIVE'}">
                                                        <input type="hidden" name="returnUrl" value="<c:out value='${returnUrl}'/>">
                                                    </form>
                                                    <c:choose>
                                                        <c:when test="${u.status == 'ACTIVE'}">
                                                            <button type="button" class="btn btn-sm btn-outline-warning" data-confirm="true"
                                                                data-form="#status${u.userId}" title="Khóa tài khoản"
                                                                data-confirm-message="Khóa tài khoản '${fn:escapeXml(u.username)}'?">
                                                                <i class="bi bi-lock"></i>
                                                            </button>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <button type="button" class="btn btn-sm btn-outline-success" data-confirm="true"
                                                                data-form="#status${u.userId}" title="Mở khóa tài khoản"
                                                                data-confirm-message="Mở khóa tài khoản '${fn:escapeXml(u.username)}'?">
                                                                <i class="bi bi-unlock"></i>
                                                            </button>
                                                        </c:otherwise>
                                                    </c:choose>

                                                    <form class="d-inline" id="del${u.userId}" method="post"
                                                        action="${pageContext.request.contextPath}/admin/users/${u.userId}/delete">
                                                        <input type="hidden" name="_csrf" value="${sessionScope.CSRF_TOKEN}">
                                                        <input type="hidden" name="returnUrl" value="<c:out value='${returnUrl}'/>">
                                                    </form>
                                                    <button type="button" class="btn btn-sm btn-outline-danger" data-confirm="true"
                                                        data-form="#del${u.userId}" title="Xóa tài khoản"
                                                        data-confirm-message="Xóa tài khoản '${fn:escapeXml(u.username)}'? Nếu đã có dữ liệu liên quan, tài khoản chỉ bị chuyển sang trạng thái đã xóa.">
                                                        <i class="bi bi-trash3"></i>
                                                    </button>
                                                </c:if>
                                                <c:if test="${isSelf}">
                                                    <span class="badge bg-light text-muted border ms-1">Tài khoản hiện tại</span>
                                                </c:if>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty users}">
                                <tr>
                                    <td colspan="7" class="text-center py-4 text-muted">Không có người dùng nào phù hợp.</td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

            <ui:pagination baseUrl="${baseUrl}" page="${page}" totalPages="${totalPages}" />
        </main>
    </div>
    <jsp:include page="../common/confirm-modal.jsp" />
    <jsp:include page="../common/footer.jsp" />
</body>

</html>
