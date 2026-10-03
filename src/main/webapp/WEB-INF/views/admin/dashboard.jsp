<%-- File: WEB-INF/views/admin/dashboard.jsp Controller: AdminDashboardController (GET /admin/dashboard) Attributes
    (StatsService.adminStats, FR-ADM-08): totalUsers, totalTeachers, totalStudents, userRows (vai trò × trạng thái),
    totalTopics, totalQuestions, aiQuestions, tutorSessions, aiGradedEssays, pendingEssays, weekDays, weekTotal,
    recentUsers(List<UserView>)
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

                                <%-- Page header --%>
                                    <div class="page-header">
                                        <h1><i class="bi bi-speedometer2 me-2 text-primary"></i>Tổng quan hệ thống</h1>
                                        <span class="text-muted" style="font-size:.85rem;">
                                            <i class="bi bi-person-fill me-1"></i>Xin chào,
                                            <strong>
                                                <c:out value="${sessionScope.LOGGED_IN_USER.fullName}" />
                                            </strong>
                                        </span>
                                    </div>

                                    <%-- ════ TOP STAT GROUPS: 3 nhóm ════ --%>
                                        <%-- FR-ADM-08: mọi số liệu từ CSDL --%>

                                            <%-- Nhóm: Người dùng --%>
                                                <div class="section-title mb-2">
                                                    <i class="bi bi-people me-1"></i>Người dùng
                                                </div>
                                                <div class="row g-3 mb-4">
                                                    <div class="col-sm-4">
                                                        <div class="stat-card">
                                                            <div class="stat-icon blue"><i class="bi bi-people"></i>
                                                            </div>
                                                            <div>
                                                                <div class="stat-number">${totalUsers}</div>
                                                                <div class="stat-label">Tổng người dùng</div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="col-sm-4">
                                                        <div class="stat-card">
                                                            <div class="stat-icon orange"><i
                                                                    class="bi bi-person-badge"></i></div>
                                                            <div>
                                                                <div class="stat-number">${totalTeachers}</div>
                                                                <div class="stat-label">Giáo viên</div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="col-sm-4">
                                                        <div class="stat-card">
                                                            <div class="stat-icon green"><i
                                                                    class="bi bi-mortarboard"></i></div>
                                                            <div>
                                                                <div class="stat-number">${totalStudents}</div>
                                                                <div class="stat-label">Học sinh</div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>

                                                <%-- Nhóm: Nội dung --%>
                                                    <div class="section-title mb-2">
                                                        <i class="bi bi-folder2-open me-1"></i>Nội dung
                                                    </div>
                                                    <div class="row g-3 mb-4">
                                                        <div class="col-sm-4">
                                                            <div class="stat-card">
                                                                <div class="stat-icon teal"><i
                                                                        class="bi bi-folder2"></i></div>
                                                                <div>
                                                                    <div class="stat-number">${totalTopics}</div>
                                                                    <div class="stat-label">Chủ đề</div>
                                                                </div>
                                                            </div>
                                                        </div>
                                                        <div class="col-sm-4">
                                                            <div class="stat-card">
                                                                <div class="stat-icon purple"><i
                                                                        class="bi bi-patch-question"></i></div>
                                                                <div>
                                                                    <div class="stat-number">${totalQuestions}</div>
                                                                    <div class="stat-label">Câu hỏi · ${aiQuestions} do
                                                                        AI sinh</div>
                                                                </div>
                                                            </div>
                                                        </div>
                                                        <div class="col-sm-4">
                                                            <div class="stat-card">
                                                                <div class="stat-icon rose"><i
                                                                        class="bi bi-pencil-square"></i></div>
                                                                <div>
                                                                    <div class="stat-number">${pendingEssays}</div>
                                                                    <div class="stat-label">Bài tự luận chờ duyệt</div>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>

                                                    <%-- Nhóm: AI --%>
                                                        <div class="section-title mb-2">
                                                            <i class="bi bi-robot me-1"></i>AI
                                                        </div>
                                                        <div class="row g-3 mb-4">
                                                            <div class="col-sm-6">
                                                                <div class="stat-card">
                                                                    <div class="stat-icon purple"><i
                                                                            class="bi bi-robot"></i></div>
                                                                    <div>
                                                                        <div class="stat-number">${tutorSessions}</div>
                                                                        <div class="stat-label">Phiên gia sư AI đã tạo
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <div class="col-sm-6">
                                                                <div class="stat-card">
                                                                    <div class="stat-icon green"><i
                                                                            class="bi bi-check2-circle"></i></div>
                                                                    <div>
                                                                        <div class="stat-number">${aiGradedEssays}</div>
                                                                        <div class="stat-label">Bài tự luận chấm qua AI
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </div>

                                                        <%-- ════ 2-COL ROW: User table + Bar chart ════ --%>
                                                            <div class="row g-4 mb-4">

                                                                <%-- Bảng user theo vai trò × trạng thái --%>
                                                                    <div class="col-lg-6">
                                                                        <div class="card h-100">
                                                                            <div class="card-header">
                                                                                <i
                                                                                    class="bi bi-person-lines-fill text-primary"></i>
                                                                                Người dùng theo vai trò &amp; trạng thái
                                                                            </div>
                                                                            <div class="table-responsive">
                                                                                <table
                                                                                    class="table table-sm mb-0 align-middle"
                                                                                    id="userStatusTable">
                                                                                    <thead>
                                                                                        <tr>
                                                                                            <th>Vai trò</th>
                                                                                            <th class="text-end">Hoạt
                                                                                                động</th>
                                                                                            <th class="text-end">Bị khóa
                                                                                            </th>
                                                                                            <th class="text-end">Đã xóa
                                                                                            </th>
                                                                                            <th class="text-end">Tổng
                                                                                            </th>
                                                                                        </tr>
                                                                                    </thead>
                                                                                    <tbody>
                                                                                        <c:forEach var="r"
                                                                                            items="${userRows}">
                                                                                            <tr>
                                                                                                <td>
                                                                                                    <c:choose>
                                                                                                        <c:when
                                                                                                            test="${r.role == 'ADMIN'}">
                                                                                                            <span
                                                                                                                class="badge bg-danger-subtle text-danger fw-semibold">Quản
                                                                                                                trị
                                                                                                                viên</span>
                                                                                                        </c:when>
                                                                                                        <c:when
                                                                                                            test="${r.role == 'TEACHER'}">
                                                                                                            <span
                                                                                                                class="badge bg-primary-subtle text-primary fw-semibold">Giáo
                                                                                                                viên</span>
                                                                                                        </c:when>
                                                                                                        <c:otherwise>
                                                                                                            <span
                                                                                                                class="badge bg-success-subtle text-success fw-semibold">Học
                                                                                                                sinh</span>
                                                                                                        </c:otherwise>
                                                                                                    </c:choose>
                                                                                                </td>
                                                                                                <td class="text-end">
                                                                                                    <span
                                                                                                        class="us-active">${r.ACTIVE}</span>
                                                                                                </td>
                                                                                                <td class="text-end">
                                                                                                    <span
                                                                                                        class="us-suspended">${r.SUSPENDED}</span>
                                                                                                </td>
                                                                                                <td class="text-end">
                                                                                                    <span
                                                                                                        class="us-inactive">${r.INACTIVE}</span>
                                                                                                </td>
                                                                                                <td
                                                                                                    class="text-end fw-bold">
                                                                                                    ${r.total}</td>
                                                                                            </tr>
                                                                                        </c:forEach>
                                                                                    </tbody>
                                                                                </table>
                                                                            </div>
                                                                        </div>
                                                                    </div>

                                                                    <%-- Biểu đồ lượt làm bài 7 ngày --%>
                                                                        <div class="col-lg-6">
                                                                            <div class="card h-100">
                                                                                <div class="card-header">
                                                                                    <span><i
                                                                                            class="bi bi-bar-chart me-1 text-primary"></i>Lượt
                                                                                        làm bài 7 ngày gần nhất</span>
                                                                                    <span
                                                                                        class="ms-auto text-muted fw-normal"
                                                                                        style="font-size:.8rem;">
                                                                                        Tổng: <strong
                                                                                            class="text-body">${weekTotal}</strong>
                                                                                    </span>
                                                                                </div>
                                                                                <div class="card-body">
                                                                                    <div class="week-chart" role="img"
                                                                                        aria-label="Lượt làm bài 7 ngày gần nhất, tổng ${weekTotal}">
                                                                                        <c:forEach var="d"
                                                                                            items="${weekDays}">
                                                                                            <div class="week-col"
                                                                                                title="${d.label}: ${d.total} lượt">
                                                                                                <div
                                                                                                    class="week-bar-wrap">
                                                                                                    <div class="week-bar"
                                                                                                        style="height:${d.total == 0 ? 0 : (d.pct < 3 ? 3 : d.pct)}%">
                                                                                                    </div>
                                                                                                </div>
                                                                                                <div class="week-label">
                                                                                                    ${d.label}</div>
                                                                                            </div>
                                                                                        </c:forEach>
                                                                                    </div>
                                                                                    <%-- Accessible hidden table for
                                                                                        screen readers --%>
                                                                                        <table class="visually-hidden">
                                                                                            <caption>Lượt làm bài theo
                                                                                                ngày</caption>
                                                                                            <c:forEach var="d"
                                                                                                items="${weekDays}">
                                                                                                <tr>
                                                                                                    <th>${d.label}</th>
                                                                                                    <td>${d.total}</td>
                                                                                                </tr>
                                                                                            </c:forEach>
                                                                                        </table>
                                                                                </div>
                                                                            </div>
                                                                        </div>

                                                            </div><%-- /row --%>

                                                                <%-- Bảng người dùng mới tạo gần đây --%>
                                                                    <div class="card">
                                                                        <div class="card-header">
                                                                            <i
                                                                                class="bi bi-clock-history text-primary"></i>Người
                                                                            dùng mới tạo gần đây
                                                                            <a href="${pageContext.request.contextPath}/admin/users?role=STUDENT"
                                                                                class="btn btn-sm btn-outline-primary ms-auto">Xem
                                                                                tất cả</a>
                                                                        </div>
                                                                        <div class="table-responsive">
                                                                            <table class="table table-hover mb-0">
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
                                                                                        <c:when
                                                                                            test="${empty recentUsers}">
                                                                                            <tr>
                                                                                                <td colspan="5"
                                                                                                    class="text-center py-5">
                                                                                                    <i
                                                                                                        class="bi bi-inbox d-block fs-1 mb-2 opacity-25"></i>
                                                                                                    Chưa có dữ liệu
                                                                                                </td>
                                                                                            </tr>
                                                                                        </c:when>
                                                                                        <c:otherwise>
                                                                                            <c:forEach var="u"
                                                                                                items="${recentUsers}"
                                                                                                varStatus="vs">
                                                                                                <tr>
                                                                                                    <td
                                                                                                        class="text-muted">
                                                                                                        ${vs.count}</td>
                                                                                                    <td
                                                                                                        class="fw-semibold">
                                                                                                        <c:out
                                                                                                            value="${u.fullName}" />
                                                                                                    </td>
                                                                                                    <td><code><c:out value="${u.username}" /></code>
                                                                                                    </td>
                                                                                                    <td>
                                                                                                        <c:choose>
                                                                                                            <c:when
                                                                                                                test="${u.role == 'ADMIN'}">
                                                                                                                <span
                                                                                                                    class="badge bg-danger">Admin</span>
                                                                                                            </c:when>
                                                                                                            <c:when
                                                                                                                test="${u.role == 'TEACHER'}">
                                                                                                                <span
                                                                                                                    class="badge bg-primary">Giáo
                                                                                                                    viên</span>
                                                                                                            </c:when>
                                                                                                            <c:otherwise>
                                                                                                                <span
                                                                                                                    class="badge bg-success">Học
                                                                                                                    sinh</span>
                                                                                                            </c:otherwise>
                                                                                                        </c:choose>
                                                                                                    </td>
                                                                                                    <td>
                                                                                                        <c:choose>
                                                                                                            <c:when
                                                                                                                test="${u.active}">
                                                                                                                <span
                                                                                                                    class="us-active">Hoạt
                                                                                                                    động</span>
                                                                                                            </c:when>
                                                                                                            <c:otherwise>
                                                                                                                <span
                                                                                                                    class="us-inactive">Bị
                                                                                                                    khóa</span>
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