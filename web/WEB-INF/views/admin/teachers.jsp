<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <jsp:include page="../common/head.jsp">
                <jsp:param name="title" value="Quản lý Giáo viên" />
            </jsp:include>

            <body data-ctx="${pageContext.request.contextPath}">
                <jsp:include page="../common/navbar.jsp" />
                <div class="app-shell">
                    <jsp:include page="../common/sidebar.jsp">
                        <jsp:param name="active" value="admin-teachers" />
                    </jsp:include>
                    <main class="app-main">
                        <jsp:include page="../common/flash.jsp" />

                        <div class="page-header">
                            <h1><i class="bi bi-person-workspace me-2 text-primary"></i>Danh sách Giáo viên
                                <span class="badge bg-secondary ms-2">${totalRecords}</span>
                            </h1>
                        </div>

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
                                            <th class="text-end">Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="t" items="${teachers}" varStatus="vs">
                                            <tr>
                                                <td class="text-muted">
                                                    <c:out value="${(page-1)*10 + vs.count}" />
                                                </td>
                                                <td class="fw-semibold">
                                                    <c:out value="${t.fullName}" />
                                                </td>
                                                <td>
                                                    <c:out value="${t.username}" /><br>
                                                    <small class="text-muted"><c:out value="${t.email}" /></small>
                                                </td>
                                                <td><span class="badge bg-primary">
                                                        <c:out value="${t.role}" />
                                                    </span></td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${t.active}">
                                                            <span class="badge bg-success"><i class="bi bi-check-circle me-1"></i>Hoạt động</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-danger"><i class="bi bi-lock-fill me-1"></i>Bị khóa</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="text-muted">
                                                    <fmt:formatDate value="${t.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                                </td>
                                                <td class="text-end">
                                                    <c:choose>
                                                        <c:when test="${sessionScope.currentUser.userId == t.userId}">
                                                            <span class="badge bg-light text-muted border">Tài khoản hiện tại</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <form action="${pageContext.request.contextPath}/admin/users/toggle-status" method="post" class="d-inline"
                                                                  onsubmit="return confirm('${t.active ? 'Bạn có chắc muốn KHÓA tài khoản giáo viên này?' : 'Bạn có chắc muốn KÍCH HOẠT lại tài khoản này?'}');">
                                                                <input type="hidden" name="userId" value="${t.userId}">
                                                                <input type="hidden" name="returnUrl" value="${pageContext.request.contextPath}/admin/teachers?page=${page}">
                                                                <c:choose>
                                                                    <c:when test="${t.active}">
                                                                        <button type="submit" class="btn btn-sm btn-outline-danger" title="Khóa tài khoản">
                                                                            <i class="bi bi-lock me-1"></i>Khóa
                                                                        </button>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <button type="submit" class="btn btn-sm btn-outline-success" title="Mở khóa tài khoản">
                                                                            <i class="bi bi-unlock me-1"></i>Mở khóa
                                                                        </button>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </form>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        <c:if test="${empty teachers}">
                                            <tr>
                                                <td colspan="7" class="text-center py-4 text-muted">Chưa có dữ liệu giáo viên.</td>
                                            </tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <jsp:include page="../common/pagination.jsp">
                            <jsp:param name="baseUrl" value="${pageContext.request.contextPath}/admin/teachers" />
                        </jsp:include>
                    </main>
                </div>
                <jsp:include page="../common/footer.jsp" />
            </body>

            </html>