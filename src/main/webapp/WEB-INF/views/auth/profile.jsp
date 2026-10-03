<%-- File: WEB-INF/views/auth/profile.jsp
     Controller: ProfileController (GET /profile, /profile/password; POST /profile, /profile/password)
     Attributes: me (UserView), profileForm (ProfileForm), passwordForm (PasswordChangeForm), passwordTab (Boolean)
     Lỗi Bean Validation / nghiệp vụ hiển thị tại từng trường bằng <form:errors>. --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>

<jsp:include page="../common/head.jsp">
    <jsp:param name="title" value="Hồ sơ cá nhân" />
</jsp:include>

<body data-ctx="${pageContext.request.contextPath}">
<jsp:include page="../common/navbar.jsp" />

<div class="app-shell">
    <jsp:include page="../common/sidebar.jsp">
        <jsp:param name="active" value="profile" />
    </jsp:include>

    <main class="app-main">
        <ui:flash />

        <div class="page-header">
            <h1><i class="bi bi-person-circle me-2 text-primary"></i>Hồ sơ cá nhân</h1>
        </div>

        <div class="row g-3">
            <%-- UC-AUTH-04: thông tin cá nhân --%>
            <div class="col-lg-6">
                <div class="card h-100">
                    <div class="card-header"><i class="bi bi-person-vcard me-2 text-primary"></i>Thông tin tài khoản</div>
                    <div class="card-body">
                        <dl class="row small mb-3">
                            <dt class="col-sm-4">Tên đăng nhập</dt>
                            <dd class="col-sm-8"><c:out value="${me.username}" /></dd>
                            <dt class="col-sm-4">Vai trò</dt>
                            <dd class="col-sm-8">
                                <c:choose>
                                    <c:when test="${me.role == 'ADMIN'}">Quản trị viên</c:when>
                                    <c:when test="${me.role == 'TEACHER'}">Giáo viên</c:when>
                                    <c:otherwise>Học sinh</c:otherwise>
                                </c:choose>
                            </dd>
                            <dt class="col-sm-4">Ngày tạo</dt>
                            <dd class="col-sm-8"><fmt:formatDate value="${me.createdAt}" pattern="dd/MM/yyyy" /></dd>
                        </dl>
                        <p class="text-muted small">Tên đăng nhập và vai trò không thể tự thay đổi. Liên hệ quản trị viên nếu cần.</p>

                        <form:form modelAttribute="profileForm" action="${pageContext.request.contextPath}/profile" method="post">
                            <input type="hidden" name="_csrf" value="${sessionScope.CSRF_TOKEN}">
                            <div class="mb-3">
                                <label for="fullName" class="form-label fw-semibold">Họ và tên</label>
                                <form:input path="fullName" cssClass="form-control" cssErrorClass="form-control is-invalid"
                                            required="required" minlength="2" maxlength="100" />
                                <form:errors path="fullName" element="div" cssClass="invalid-feedback d-block" />
                            </div>
                            <div class="mb-3">
                                <label for="email" class="form-label fw-semibold">Email</label>
                                <form:input path="email" type="email" cssClass="form-control" cssErrorClass="form-control is-invalid"
                                            required="required" maxlength="100" />
                                <form:errors path="email" element="div" cssClass="invalid-feedback d-block" />
                            </div>
                            <button type="submit" class="btn btn-primary">
                                <i class="bi bi-check-lg me-1"></i>Lưu thông tin
                            </button>
                        </form:form>
                    </div>
                </div>
            </div>

            <%-- UC-AUTH-05: đổi mật khẩu --%>
            <div class="col-lg-6" id="password">
                <div class="card h-100 ${passwordTab ? 'border-primary' : ''}">
                    <div class="card-header"><i class="bi bi-key me-2 text-primary"></i>Đổi mật khẩu</div>
                    <div class="card-body">
                        <form:form modelAttribute="passwordForm" action="${pageContext.request.contextPath}/profile/password"
                                   method="post" autocomplete="off">
                            <input type="hidden" name="_csrf" value="${sessionScope.CSRF_TOKEN}">
                            <div class="mb-3">
                                <label for="currentPassword" class="form-label fw-semibold">Mật khẩu hiện tại</label>
                                <form:password path="currentPassword" cssClass="form-control"
                                               cssErrorClass="form-control is-invalid" required="required"
                                               autocomplete="current-password" />
                                <form:errors path="currentPassword" element="div" cssClass="invalid-feedback d-block" />
                            </div>
                            <div class="mb-3">
                                <label for="newPassword" class="form-label fw-semibold">Mật khẩu mới</label>
                                <form:password path="newPassword" cssClass="form-control" cssErrorClass="form-control is-invalid"
                                               required="required" minlength="8" maxlength="64" autocomplete="new-password" />
                                <form:errors path="newPassword" element="div" cssClass="invalid-feedback d-block" />
                                <div class="form-text">8–64 ký tự, có cả chữ cái và chữ số; khác mật khẩu hiện tại.</div>
                            </div>
                            <div class="mb-3">
                                <label for="confirmPassword" class="form-label fw-semibold">Nhập lại mật khẩu mới</label>
                                <form:password path="confirmPassword" cssClass="form-control"
                                               cssErrorClass="form-control is-invalid" required="required"
                                               autocomplete="new-password" />
                                <form:errors path="confirmPassword" element="div" cssClass="invalid-feedback d-block" />
                            </div>
                            <button type="submit" class="btn btn-outline-primary">
                                <i class="bi bi-shield-lock me-1"></i>Đổi mật khẩu
                            </button>
                        </form:form>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>

<jsp:include page="../common/footer.jsp" />
<c:if test="${passwordTab}">
    <script>document.addEventListener('DOMContentLoaded', () => {
        const el = document.getElementById('currentPassword');
        document.getElementById('password').scrollIntoView({ block: 'start' });
        if (el) el.focus();
    });</script>
</c:if>
</body>
</html>
