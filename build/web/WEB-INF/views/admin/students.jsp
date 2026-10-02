<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <jsp:include page="../common/head.jsp">
                <jsp:param name="title" value="Quản lý Học sinh" />
            </jsp:include>

            <body data-ctx="${pageContext.request.contextPath}">
                <jsp:include page="../common/navbar.jsp" />
                <div class="app-shell">
                    <jsp:include page="../common/sidebar.jsp">
                        <jsp:param name="active" value="admin-students" />
                    </jsp:include>
                    <main class="app-main">
                        <div class="page-header">
                            <h1><i class="bi bi-mortarboard me-2 text-primary"></i>Danh sách Học sinh
                                <span class="badge bg-secondary ms-2">${totalRecords}</span>
                            </h1>
                        </div>

                        <div class="card table-card mb-3">
                            <div class="table-responsive">
                                <table class="table table-hover mb-0">
                                    <thead>
                                        <tr>
                                            <th>#</th>
                                            <th>Họ tên</th>
                                            <th>Tên đăng nhập / Email</th>
                                            <th>Vai trò</th>
                                            <th>Ngày tạo</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="s" items="${students}" varStatus="vs">
                                            <tr>
                                                <td class="text-muted">
                                                    <c:out value="${(page-1)*10 + vs.count}" />
                                                </td>
                                                <td class="fw-semibold">
                                                    <c:out value="${s.fullName}" />
                                                </td>
                                                <td>
                                                    <c:out value="${s.username}" />
                                                </td>
                                                <td><span class="badge bg-secondary">
                                                        <c:out value="${s.role}" />
                                                    </span></td>
                                                <td class="text-muted">
                                                    <fmt:formatDate value="${s.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        <c:if test="${empty students}">
                                            <tr>
                                                <td colspan="5" class="text-center py-4 text-muted">Chưa có dữ liệu học
                                                    sinh.</td>
                                            </tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <jsp:include page="../common/pagination.jsp">
                            <jsp:param name="baseUrl" value="${pageContext.request.contextPath}/admin/students" />
                        </jsp:include>
                    </main>
                </div>
                <jsp:include page="../common/footer.jsp" />
            </body>

            </html>