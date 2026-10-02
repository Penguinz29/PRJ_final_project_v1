<%-- File: WEB-INF/views/teacher/students.jsp Servlet: TeacherStudentServlet (/teacher/students) Attributes:
    students(List<User>), page(int), totalPages(int), totalRecords(int), keyword(String)
    --%>
    <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
        <%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
            <jsp:include page="../common/head.jsp">
                <jsp:param name="title" value="Học sinh của tôi" />
            </jsp:include>

            <body data-ctx="${pageContext.request.contextPath}">
                <jsp:include page="../common/navbar.jsp" />
                <div class="app-shell">
                    <jsp:include page="../common/sidebar.jsp">
                        <jsp:param name="active" value="teacher-students" />
                    </jsp:include>

                    <main class="app-main">
                        <ui:flash />

                        <div class="page-header">
                            <h1><i class="bi bi-people me-2 text-primary"></i>Học sinh phụ trách
                                <span class="badge bg-secondary ms-2">${totalRecords}</span>
                            </h1>
                        </div>

                        <div class="card mb-3">
                            <div class="card-body py-2">
                                <form action="${pageContext.request.contextPath}/teacher/students" method="get"
                                    class="d-flex gap-2">
                                    <input type="text" class="form-control form-control-sm" name="keyword"
                                        placeholder="Tìm theo họ tên, username..." value="<c:out value='${keyword}'/>">
                                    <button class="btn btn-sm btn-primary"><i class="bi bi-search"></i></button>
                                    <c:if test="${not empty keyword}">
                                        <a href="${pageContext.request.contextPath}/teacher/students"
                                            class="btn btn-sm btn-outline-secondary">
                                            <i class="bi bi-x-lg"></i>
                                        </a>
                                    </c:if>
                                </form>
                            </div>
                        </div>

                        <div class="card table-card">
                            <div class="table-responsive">
                                <table class="table table-hover mb-0">
                                    <thead>
                                        <tr>
                                            <th>#</th>
                                            <th>Họ tên</th>
                                            <th>Username</th>
                                            <th>Email</th>
                                            <th>Lần cuối thao tác</th>
                                            <th>Trạng thái</th>
                                            <th>Lịch sử học</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${empty students}">
                                                <tr>
                                                    <td colspan="7">
                                                        <div class="empty-state">
                                                            <i class="bi bi-people empty-icon"></i>
                                                            <p>Bạn chưa phụ trách học sinh nào.</p>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:when>
                                            <c:otherwise>
                                                <c:forEach var="u" items="${students}" varStatus="vs">
                                                    <tr>
                                                        <td class="text-muted">${(page-1)*10 + vs.count}</td>
                                                        <td class="fw-semibold">
                                                            <c:out value="${u.fullName}" />
                                                        </td>
                                                        <td><code><c:out value="${u.username}"/></code></td>
                                                        <td class="text-muted">
                                                            <c:out value="${u.email}" />
                                                        </td>
                                                        <td class="text-muted" style="font-size:.85rem;">[Chưa tính]
                                                        </td> <%-- Future feature --%>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${u.active}">
                                                                        <span
                                                                            class="badge bg-success-subtle text-success">Hoạt
                                                                            động</span>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span
                                                                            class="badge bg-secondary-subtle text-secondary">Bị
                                                                            khóa</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td>
                                                                <a href="${pageContext.request.contextPath}/teacher/students/history?studentId=${u.userId}"
                                                                    class="btn btn-sm btn-outline-primary">
                                                                    <i class="bi bi-clock-history me-1"></i>Xem
                                                                </a>
                                                            </td>
                                                    </tr>
                                                </c:forEach>
                                            </c:otherwise>
                                        </c:choose>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                        <ui:pagination baseUrl="${pageContext.request.contextPath}/teacher/students${not empty keyword ? '?keyword='.concat(keyword) : ''}" page="${page}" totalPages="${totalPages}" />
                    </main>
                </div>
                <jsp:include page="../common/footer.jsp" />
            </body>

            </html>