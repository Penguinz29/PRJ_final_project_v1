<%-- File: WEB-INF/views/teacher/dashboard.jsp Servlet: TeacherDashboardServlet Attributes: myTopics(int),
    myLessons(int), myStudents(int), myQuestions(int), pendingSubmissions(int), recentSubmissions(List<Submission>)
    --%>
    <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
        <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
            <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
                <jsp:include page="../common/head.jsp">
                    <jsp:param name="title" value="Tổng quan Giáo viên" />
                </jsp:include>

                <body data-ctx="${pageContext.request.contextPath}">

                    <jsp:include page="../common/navbar.jsp" />

                    <div class="app-shell">
                        <jsp:include page="../common/sidebar.jsp">
                            <jsp:param name="active" value="teacher-dashboard" />
                        </jsp:include>

                        <main class="app-main">
                            <jsp:include page="../common/flash.jsp" />

                            <div class="page-header">
                                <h1><i class="bi bi-speedometer2 me-2 text-primary"></i>Tổng quan giáo viên</h1>
                                <span class="text-muted" style="font-size:.85rem;">
                                    Xin chào, <strong>
                                        <c:out value="${sessionScope.currentUser.fullName}" />
                                    </strong>
                                </span>
                            </div>

                            <%-- Stat cards --%>
                                <div class="row g-3 mb-4">
                                    <div class="col-sm-6 col-xl-3">
                                        <div class="stat-card">
                                            <div class="stat-icon blue"><i class="bi bi-folder2"></i></div>
                                            <div>
                                                <div class="stat-number">${myTopics}</div>
                                                <div class="stat-label">Chủ đề của tôi</div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-sm-6 col-xl-3">
                                        <div class="stat-card">
                                            <div class="stat-icon orange"><i class="bi bi-journal-text"></i></div>
                                            <div>
                                                <div class="stat-number">${myLessons}</div>
                                                <div class="stat-label">Bài giảng</div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-sm-6 col-xl-3">
                                        <div class="stat-card">
                                            <div class="stat-icon green"><i class="bi bi-people"></i></div>
                                            <div>
                                                <div class="stat-number">${myStudents}</div>
                                                <div class="stat-label">Học sinh quản lý</div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-sm-6 col-xl-3">
                                        <div class="stat-card">
                                            <div class="stat-icon purple"><i class="bi bi-pencil-square"></i></div>
                                            <div>
                                                <div class="stat-number text-warning">${pendingSubmissions}</div>
                                                <div class="stat-label">Bài chờ chấm</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <%-- Shortcuts --%>
                                    <div class="row g-3 mb-4">
                                        <div class="col-12">
                                            <div class="card">
                                                <div class="card-header"><i
                                                        class="bi bi-lightning-fill me-2 text-warning"></i>Thao tác
                                                    nhanh</div>
                                                <div class="card-body d-flex flex-wrap gap-2">
                                                    <a href="${pageContext.request.contextPath}/teacher/lessons?action=create"
                                                        class="btn btn-primary btn-sm">
                                                        <i class="bi bi-plus-lg me-1"></i>Thêm bài giảng
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/teacher/questions?action=create"
                                                        class="btn btn-outline-primary btn-sm">
                                                        <i class="bi bi-plus-lg me-1"></i>Thêm câu hỏi
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/teacher/ai/generate"
                                                        class="btn btn-ai btn-sm">
                                                        <i class="bi bi-stars me-1"></i>AI sinh câu hỏi
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/teacher/submissions"
                                                        class="btn btn-outline-warning btn-sm">
                                                        <i class="bi bi-pencil-square me-1"></i>Chấm bài tự luận
                                                        <c:if test="${pendingSubmissions > 0}">
                                                            <span
                                                                class="badge bg-warning text-dark ms-1">${pendingSubmissions}</span>
                                                        </c:if>
                                                    </a>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <%-- Bài tự luận gần đây cần chấm --%>
                                        <div class="card">
                                            <div class="card-header">
                                                <i class="bi bi-pencil-square me-2 text-primary"></i>Bài tự luận gần đây
                                                <a href="${pageContext.request.contextPath}/teacher/submissions"
                                                    class="btn btn-sm btn-outline-primary ms-auto">Xem tất cả</a>
                                            </div>
                                            <div class="table-responsive">
                                                <table class="table table-hover table-card mb-0">
                                                    <thead>
                                                        <tr>
                                                            <th>Học sinh</th>
                                                            <th>Câu hỏi</th>
                                                            <th>Trạng thái</th>
                                                            <th></th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <c:choose>
                                                            <c:when test="${empty recentSubmissions}">
                                                                <tr>
                                                                    <td colspan="4" class="text-center text-muted py-4">
                                                                        <i
                                                                            class="bi bi-inbox d-block fs-1 mb-2 opacity-25"></i>Chưa
                                                                        có bài nào
                                                                    </td>
                                                                </tr>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <c:forEach var="sub" items="${recentSubmissions}">
                                                                    <tr>
                                                                        <td class="fw-semibold">
                                                                            <c:out value="${sub.studentName}" />
                                                                        </td>
                                                                        <td>
                                                                            <c:out value="${sub.questionTitle}" />
                                                                        </td>
                                                                        <td>
                                                                            <c:choose>
                                                                                <c:when test="${sub.reviewed}">
                                                                                    <span class="badge-approved">Đã
                                                                                        chấm</span>
                                                                                </c:when>
                                                                                <c:otherwise>
                                                                                    <span class="badge-draft">Chờ
                                                                                        chấm</span>
                                                                                </c:otherwise>
                                                                            </c:choose>
                                                                        </td>
                                                                        <td>
                                                                            <a href="${pageContext.request.contextPath}/teacher/submissions?id=${sub.submissionId}"
                                                                                class="btn btn-sm btn-outline-primary">Xem</a>
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