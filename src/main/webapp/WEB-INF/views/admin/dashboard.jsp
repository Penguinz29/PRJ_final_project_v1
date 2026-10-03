<%-- File: WEB-INF/views/admin/dashboard.jsp Servlet: AdminDashboardServlet Attributes: totalTeachers(int),
    totalStudents(int), totalTopics(int), totalQuestions(int), recentUsers(List<User>)
    --%>
    <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
        <%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
            <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
                <jsp:include page="../common/head.jsp">
                    <jsp:param name="title" value="Tổng quan Admin" />
                </jsp:include>

                <body data-ctx="${pageContext.request.contextPath}">

                    <jsp:include page="../common/navbar.jsp" />

                    <div class="app-shell">
                        <jsp:include page="../common/sidebar.jsp">
                            <jsp:param name="active" value="admin-dashboard" />
                        </jsp:include>

                        <main class="app-main">
                            <ui:flash />

                            <div class="page-header">
                                <h1><i class="bi bi-speedometer2 me-2 text-primary"></i>Tổng quan hệ thống</h1>
                                <span class="text-muted" style="font-size:.85rem;">
                                    <i class="bi bi-person-fill me-1"></i>Xin chào,
                                    <strong>
                                        <c:out value="${sessionScope.LOGGED_IN_USER.fullName}" />
                                    </strong>
                                </span>
                            </div>

                            <%-- Stat cards --%>
                                <div class="row g-3 mb-4">
                                    <div class="col-sm-6 col-xl-3">
                                        <div class="stat-card">
                                            <div class="stat-icon blue"><i class="bi bi-person-workspace"></i></div>
                                            <div>
                                                <div class="stat-number">${totalTeachers}</div>
                                                <div class="stat-label">Giáo viên</div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-sm-6 col-xl-3">
                                        <div class="stat-card">
                                            <div class="stat-icon green"><i class="bi bi-mortarboard"></i></div>
                                            <div>
                                                <div class="stat-number">${totalStudents}</div>
                                                <div class="stat-label">Học sinh</div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-sm-6 col-xl-3">
                                        <div class="stat-card">
                                            <div class="stat-icon orange"><i class="bi bi-folder2"></i></div>
                                            <div>
                                                <div class="stat-number">${totalTopics}</div>
                                                <div class="stat-label">Chủ đề</div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-sm-6 col-xl-3">
                                        <div class="stat-card">
                                            <div class="stat-icon purple"><i class="bi bi-patch-question"></i></div>
                                            <div>
                                                <div class="stat-number">${totalQuestions}</div>
                                                <div class="stat-label">Câu hỏi</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <%-- Bảng người dùng mới --%>
                                    <div class="card">
                                        <div class="card-header">
                                            <i class="bi bi-clock-history me-2 text-primary"></i>Người dùng mới tạo gần
                                            đây
                                            <a href="${pageContext.request.contextPath}/admin/users?role=STUDENT"
                                                class="btn btn-sm btn-outline-primary ms-auto">Xem tất cả</a>
                                        </div>
                                        <div class="table-responsive">
                                            <table class="table table-hover table-card mb-0">
                                                <thead>
                                                    <tr>
                                                        <th>#</th>
                                                        <th>Họ tên</th>
                                                        <th>Username</th>
                                                        <th>Role</th>
                                                        <th>Trạng thái</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:choose>
                                                        <c:when test="${empty recentUsers}">
                                                            <tr>
                                                                <td colspan="5" class="text-center text-muted py-4">
                                                                    <i
                                                                        class="bi bi-inbox d-block fs-1 mb-2 opacity-25"></i>
                                                                    Chưa có dữ liệu
                                                                </td>
                                                            </tr>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <c:forEach var="u" items="${recentUsers}" varStatus="vs">
                                                                <tr>
                                                                    <td class="text-muted">${vs.count}</td>
                                                                    <td class="fw-semibold">
                                                                        <c:out value="${u.fullName}" />
                                                                    </td>
                                                                    <td><code><c:out value="${u.username}"/></code></td>
                                                                    <td>
                                                                        <c:choose>
                                                                            <c:when test="${u.role == 'ADMIN'}">
                                                                                <span
                                                                                    class="badge bg-danger">Admin</span>
                                                                            </c:when>
                                                                            <c:when test="${u.role == 'TEACHER'}">
                                                                                <span class="badge bg-primary">Giáo
                                                                                    viên</span>
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <span class="badge bg-success">Học
                                                                                    sinh</span>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </td>
                                                                    <td>
                                                                        <c:choose>
                                                                            <c:when test="${u.active}">
                                                                                <span
                                                                                    class="badge bg-success-subtle text-success">Hoạt
                                                                                    động</span>
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <span
                                                                                    class="badge bg-secondary-subtle text-secondary">Khóa</span>
                                                                            </c:otherwise>
                                                                        </c:choose>
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

                    <jsp:include page="../common/footer.jsp" />
                </body>

                </html>