<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
    <jsp:include page="../common/head.jsp">
        <jsp:param name="title" value="Chức năng Admin" />
    </jsp:include>

    <body data-ctx="${pageContext.request.contextPath}">
        <jsp:include page="../common/navbar.jsp" />
        <div class="app-shell">
            <jsp:include page="../common/sidebar.jsp">
                <jsp:param name="active" value="admin-dashboard" />
            </jsp:include>
            <main class="app-main d-flex justify-content-center align-items-center flex-column py-5">
                <h1 class="display-1 text-muted mb-4"><i class="bi bi-tools"></i></h1>
                <h2>Trang này đang được phát triển</h2>
                <p class="text-muted text-center" style="max-width: 500px;">
                    Cấu trúc cho phần Admin đã được chuẩn bị, nhưng các chức năng chi tiết và CRUD đang được triển khai.
                    Vui lòng quay lại Dashboard để tiếp tục.
                </p>
                <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-primary mt-3">
                    <i class="bi bi-house me-2"></i>Về Trang quản trị
                </a>
            </main>
        </div>
        <jsp:include page="../common/footer.jsp" />
    </body>

    </html>