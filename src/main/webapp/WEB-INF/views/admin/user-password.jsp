<%-- File: WEB-INF/views/admin/user-password.jsp
     Hiển thị MỘT lần mật khẩu mới sau khi Admin đặt lại (UC-ADM-05). Attributes: target (UserView), newPassword --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="../common/head.jsp">
    <jsp:param name="title" value="Mật khẩu mới" />
</jsp:include>

<body data-ctx="${pageContext.request.contextPath}">
    <jsp:include page="../common/navbar.jsp" />
    <div class="app-shell">
        <jsp:include page="../common/sidebar.jsp">
            <jsp:param name="active" value="admin-users" />
        </jsp:include>
        <main class="app-main">
            <div class="page-header">
                <h1><i class="bi bi-key me-2 text-primary"></i>Đã đặt lại mật khẩu</h1>
            </div>
            <div class="card" style="max-width:560px;">
                <div class="card-body">
                    <p>Mật khẩu mới của tài khoản <strong><c:out value="${target.username}" /></strong>
                        (<c:out value="${target.fullName}" />):</p>
                    <div class="input-group mb-3">
                        <input type="text" class="form-control form-control-lg font-monospace" id="newPassword"
                            value="<c:out value='${newPassword}'/>" readonly>
                        <button class="btn btn-outline-secondary" type="button" id="copyBtn">
                            <i class="bi bi-clipboard me-1"></i>Sao chép
                        </button>
                    </div>
                    <div class="alert alert-warning small mb-3">
                        <i class="bi bi-exclamation-triangle me-1"></i>
                        Mật khẩu này <strong>chỉ hiển thị một lần</strong> và không được lưu ở dạng đọc được. Hãy gửi cho người dùng
                        và nhắc họ đổi mật khẩu sau khi đăng nhập.
                    </div>
                    <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-primary">
                        <i class="bi bi-arrow-left me-1"></i>Về danh sách người dùng
                    </a>
                </div>
            </div>
        </main>
    </div>
    <jsp:include page="../common/footer.jsp" />
    <script>
        document.getElementById('copyBtn').addEventListener('click', function () {
            var input = document.getElementById('newPassword');
            input.select();
            if (navigator.clipboard) { navigator.clipboard.writeText(input.value); }
            else { document.execCommand('copy'); }
            this.innerHTML = '<i class="bi bi-check2 me-1"></i>Đã sao chép';
        });
    </script>
</body>

</html>
