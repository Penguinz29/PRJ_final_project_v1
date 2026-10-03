<%-- File: WEB-INF/views/admin/user-form.jsp
     Controller: AdminUserController (GET /admin/users/new, GET /admin/users/{id}/edit)
     Tạo: modelAttribute userCreateForm • Sửa: modelAttribute userEditForm + target (UserView) --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<c:set var="isEdit" value="${not empty target}" />
<jsp:include page="../common/head.jsp">
    <jsp:param name="title" value="${isEdit ? 'Sửa người dùng' : 'Tạo tài khoản'}" />
</jsp:include>

<body data-ctx="${pageContext.request.contextPath}">
    <jsp:include page="../common/navbar.jsp" />
    <div class="app-shell">
        <jsp:include page="../common/sidebar.jsp">
            <jsp:param name="active" value="admin-users" />
        </jsp:include>
        <main class="app-main">
            <ui:flash />

            <nav aria-label="breadcrumb">
                <ol class="breadcrumb mb-1" style="font-size:.85rem;">
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/users"
                            class="text-decoration-none">Người dùng</a></li>
                    <li class="breadcrumb-item active" aria-current="page">${isEdit ? 'Sửa' : 'Tạo mới'}</li>
                </ol>
            </nav>
            <div class="page-header">
                <h1><i class="bi ${isEdit ? 'bi-person-gear' : 'bi-person-plus'} me-2 text-primary"></i>
                    ${isEdit ? 'Sửa người dùng' : 'Tạo tài khoản'}</h1>
            </div>

            <div class="card" style="max-width:640px;">
                <div class="card-body">
                    <c:choose>
                        <%-- ===== SỬA ===== --%>
                        <c:when test="${isEdit}">
                            <form:form modelAttribute="userEditForm" method="post" cssClass="needs-validation" novalidate="novalidate"
                                action="${pageContext.request.contextPath}/admin/users/${target.userId}">
                                <input type="hidden" name="_csrf" value="${sessionScope.CSRF_TOKEN}">
                                <div class="mb-3">
                                    <label class="form-label fw-semibold">Tên đăng nhập</label>
                                    <input type="text" class="form-control" value="<c:out value='${target.username}'/>" disabled>
                                    <div class="form-text">Tên đăng nhập không thể thay đổi.</div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label fw-semibold" for="fullName">Họ tên <span class="text-danger">*</span></label>
                                    <form:input path="fullName" cssClass="form-control" maxlength="100" required="required" />
                                    <form:errors path="fullName" element="div" cssClass="text-danger small mt-1" />
                                </div>
                                <div class="mb-3">
                                    <label class="form-label fw-semibold" for="email">Email <span class="text-danger">*</span></label>
                                    <form:input path="email" type="email" cssClass="form-control" maxlength="100" required="required" />
                                    <form:errors path="email" element="div" cssClass="text-danger small mt-1" />
                                </div>
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-semibold" for="role">Vai trò</label>
                                        <form:select path="role" cssClass="form-select">
                                            <form:option value="ADMIN" label="Admin" />
                                            <form:option value="TEACHER" label="Giáo viên" />
                                            <form:option value="STUDENT" label="Học sinh" />
                                        </form:select>
                                        <form:errors path="role" element="div" cssClass="text-danger small mt-1" />
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-semibold" for="status">Trạng thái</label>
                                        <form:select path="status" cssClass="form-select">
                                            <form:option value="ACTIVE" label="Hoạt động" />
                                            <form:option value="SUSPENDED" label="Bị khóa" />
                                        </form:select>
                                        <form:errors path="status" element="div" cssClass="text-danger small mt-1" />
                                    </div>
                                </div>
                                <div class="d-flex gap-2">
                                    <button type="submit" class="btn btn-primary"><i class="bi bi-check-lg me-1"></i>Lưu thay đổi</button>
                                    <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-outline-secondary">Hủy</a>
                                </div>
                            </form:form>
                        </c:when>

                        <%-- ===== TẠO ===== --%>
                        <c:otherwise>
                            <form:form modelAttribute="userCreateForm" method="post" cssClass="needs-validation" novalidate="novalidate"
                                action="${pageContext.request.contextPath}/admin/users">
                                <input type="hidden" name="_csrf" value="${sessionScope.CSRF_TOKEN}">
                                <div class="mb-3">
                                    <label class="form-label fw-semibold" for="username">Tên đăng nhập <span class="text-danger">*</span></label>
                                    <form:input path="username" cssClass="form-control" minlength="4" maxlength="30"
                                        pattern="[A-Za-z0-9_.]{4,30}" required="required" autocomplete="off" />
                                    <div class="form-text">4–30 ký tự: chữ, số, dấu gạch dưới hoặc dấu chấm.</div>
                                    <form:errors path="username" element="div" cssClass="text-danger small mt-1" />
                                </div>
                                <div class="mb-3">
                                    <label class="form-label fw-semibold" for="password">Mật khẩu <span class="text-danger">*</span></label>
                                    <form:password path="password" cssClass="form-control" minlength="8" maxlength="64"
                                        required="required" autocomplete="new-password" />
                                    <div class="form-text">8–64 ký tự, có cả chữ và số.</div>
                                    <form:errors path="password" element="div" cssClass="text-danger small mt-1" />
                                </div>
                                <div class="mb-3">
                                    <label class="form-label fw-semibold" for="fullName">Họ tên <span class="text-danger">*</span></label>
                                    <form:input path="fullName" cssClass="form-control" maxlength="100" required="required" />
                                    <form:errors path="fullName" element="div" cssClass="text-danger small mt-1" />
                                </div>
                                <div class="mb-3">
                                    <label class="form-label fw-semibold" for="email">Email <span class="text-danger">*</span></label>
                                    <form:input path="email" type="email" cssClass="form-control" maxlength="100" required="required" />
                                    <form:errors path="email" element="div" cssClass="text-danger small mt-1" />
                                </div>
                                <div class="mb-3">
                                    <label class="form-label fw-semibold" for="role">Vai trò</label>
                                    <form:select path="role" cssClass="form-select">
                                        <form:option value="TEACHER" label="Giáo viên" />
                                        <form:option value="STUDENT" label="Học sinh" />
                                        <form:option value="ADMIN" label="Admin" />
                                    </form:select>
                                    <form:errors path="role" element="div" cssClass="text-danger small mt-1" />
                                </div>
                                <div class="d-flex gap-2">
                                    <button type="submit" class="btn btn-primary"><i class="bi bi-person-plus me-1"></i>Tạo tài khoản</button>
                                    <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-outline-secondary">Hủy</a>
                                </div>
                            </form:form>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </main>
    </div>
    <jsp:include page="../common/footer.jsp" />
</body>

</html>
