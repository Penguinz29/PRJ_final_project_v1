<%-- File: WEB-INF/views/teacher/dashboard.jsp Controller: TeacherDashboardServlet Attributes: myTopics(int),
    myLessons(int), myStudents(int), myQuestions(int), pendingSubmissions(int), recentSubmissions(List<Submission>)
    --%>
    <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
        <%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
            <%@ taglib prefix="c" uri="jakarta.tags.core" %>
                <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

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
                                <ui:flash />

                                <%-- Page header --%>
                                    <div class="page-header">
                                        <h1><i class="bi bi-speedometer2 me-2 text-primary"></i>Tổng quan giáo viên</h1>
                                    </div>

                                    <div class="row g-4">

                                        <%-- ════ LEFT COL (col-lg-8) ════ --%>
                                            <div class="col-lg-8">

                                                <%-- Hero --%>
                                                    <div class="hero-banner mb-4">
                                                        <div class="hero-label">Bảng điều khiển giảng dạy</div>
                                                        <h2>Xin chào,
                                                            <c:out value="${sessionScope.LOGGED_IN_USER.fullName}" />!
                                                        </h2>
                                                        <p>Quản lý nội dung, theo dõi học sinh và chấm bài tự luận tại
                                                            đây.</p>
                                                    </div>

                                                    <%-- 4 Stat cards --%>
                                                        <div class="row g-3 mb-4">
                                                            <div class="col-6 col-xl-3">
                                                                <div class="stat-card">
                                                                    <div class="stat-icon blue"><i
                                                                            class="bi bi-folder2"></i></div>
                                                                    <div>
                                                                        <div class="stat-number">${myTopics}</div>
                                                                        <div class="stat-label">Chủ đề của tôi</div>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <div class="col-6 col-xl-3">
                                                                <div class="stat-card">
                                                                    <div class="stat-icon orange"><i
                                                                            class="bi bi-journal-text"></i></div>
                                                                    <div>
                                                                        <div class="stat-number">${myLessons}</div>
                                                                        <div class="stat-label">Bài giảng</div>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <div class="col-6 col-xl-3">
                                                                <div class="stat-card">
                                                                    <div class="stat-icon green"><i
                                                                            class="bi bi-people"></i></div>
                                                                    <div>
                                                                        <div class="stat-number">${myStudents}</div>
                                                                        <div class="stat-label">Học sinh quản lý</div>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <div class="col-6 col-xl-3">
                                                                <div class="stat-card">
                                                                    <div class="stat-icon rose"><i
                                                                            class="bi bi-pencil-square"></i></div>
                                                                    <div>
                                                                        <div class="stat-number"
                                                                            style="color:var(--danger);">
                                                                            ${pendingSubmissions}</div>
                                                                        <div class="stat-label">Bài chờ chấm</div>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </div>

                                                        <%-- Quick actions --%>
                                                            <div class="card mb-4">
                                                                <div class="card-header">
                                                                    <i
                                                                        class="bi bi-lightning-fill text-warning"></i>Thao
                                                                    tác nhanh
                                                                </div>
                                                                <div class="card-body">
                                                                    <div class="row g-3">
                                                                        <div class="col-6 col-md-3">
                                                                            <a href="${pageContext.request.contextPath}/teacher/lessons?action=create"
                                                                                class="qa-card">
                                                                                <div class="qa-icon"><i
                                                                                        class="bi bi-journal-plus"></i>
                                                                                </div>
                                                                                Thêm bài giảng
                                                                            </a>
                                                                        </div>
                                                                        <div class="col-6 col-md-3">
                                                                            <a href="${pageContext.request.contextPath}/teacher/questions?action=create"
                                                                                class="qa-card">
                                                                                <div class="qa-icon"><i
                                                                                        class="bi bi-patch-plus"></i>
                                                                                </div>
                                                                                Thêm câu hỏi
                                                                            </a>
                                                                        </div>
                                                                        <div class="col-6 col-md-3">
                                                                            <a href="${pageContext.request.contextPath}/teacher/ai/generate"
                                                                                class="qa-card qa-ai">
                                                                                <div class="qa-icon"><i
                                                                                        class="bi bi-stars"></i></div>
                                                                                AI sinh câu hỏi
                                                                            </a>
                                                                        </div>
                                                                        <div class="col-6 col-md-3">
                                                                            <a href="${pageContext.request.contextPath}/teacher/submissions"
                                                                                class="qa-card qa-warn"
                                                                                style="position:relative;">
                                                                                <div class="qa-icon"><i
                                                                                        class="bi bi-pencil-square"></i>
                                                                                </div>
                                                                                Chấm bài tự luận
                                                                                <c:if test="${pendingSubmissions > 0}">
                                                                                    <span
                                                                                        class="badge bg-danger rounded-pill"
                                                                                        style="position:absolute;top:8px;right:10px;font-size:.65rem;">
                                                                                        ${pendingSubmissions}
                                                                                    </span>
                                                                                </c:if>
                                                                            </a>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </div>

                                                            <%-- Bài tự luận gần đây --%>
                                                                <div class="card">
                                                                    <div class="card-header">
                                                                        <i
                                                                            class="bi bi-pencil-square text-primary"></i>Bài
                                                                        tự luận gần đây
                                                                        <a href="${pageContext.request.contextPath}/teacher/submissions"
                                                                            class="btn btn-sm btn-outline-primary ms-auto">Xem
                                                                            tất cả</a>
                                                                    </div>
                                                                    <div class="table-responsive">
                                                                        <table class="table table-hover mb-0">
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
                                                                                    <c:when
                                                                                        test="${empty recentSubmissions}">
                                                                                        <tr>
                                                                                            <td colspan="4"
                                                                                                class="text-center py-5">
                                                                                                <i
                                                                                                    class="bi bi-inbox d-block fs-1 mb-2 opacity-25"></i>
                                                                                                Chưa có bài nào
                                                                                            </td>
                                                                                        </tr>
                                                                                    </c:when>
                                                                                    <c:otherwise>
                                                                                        <c:forEach var="sub"
                                                                                            items="${recentSubmissions}">
                                                                                            <tr>
                                                                                                <td class="fw-semibold">
                                                                                                    <c:out
                                                                                                        value="${sub.studentName}" />
                                                                                                </td>
                                                                                                <td>
                                                                                                    <c:out
                                                                                                        value="${sub.questionTitle}" />
                                                                                                </td>
                                                                                                <td>
                                                                                                    <c:choose>
                                                                                                        <c:when
                                                                                                            test="${sub.reviewed}">
                                                                                                            <span
                                                                                                                class="badge-approved">Đã
                                                                                                                chấm</span>
                                                                                                        </c:when>
                                                                                                        <c:otherwise>
                                                                                                            <span
                                                                                                                class="badge-draft">Chờ
                                                                                                                chấm</span>
                                                                                                        </c:otherwise>
                                                                                                    </c:choose>
                                                                                                </td>
                                                                                                <td>
                                                                                                    <a href="${pageContext.request.contextPath}/teacher/submissions?id=${sub.submissionId}"
                                                                                                        class="btn btn-sm btn-outline-primary">
                                                                                                        <i
                                                                                                            class="bi bi-eye me-1"></i>Xem
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

                                            </div><%-- /col-lg-8 --%>

                                                <%-- ════ RIGHT COL (col-lg-4) ════ --%>
                                                    <div class="col-lg-4">
                                                        <div class="card p-3">
                                                            <div class="section-title mb-3"><i
                                                                    class="bi bi-link-45deg me-1 text-primary"></i>Truy
                                                                cập nhanh</div>
                                                            <div class="d-flex flex-column gap-2">
                                                                <a href="${pageContext.request.contextPath}/teacher/ai/generate"
                                                                    class="shortcut-card">
                                                                    <div class="sc-icon"
                                                                        style="background:var(--ai-soft);color:var(--ai);">
                                                                        <i class="bi bi-stars"></i>
                                                                    </div>
                                                                    AI sinh câu hỏi
                                                                </a>
                                                                <a href="${pageContext.request.contextPath}/teacher/submissions"
                                                                    class="shortcut-card">
                                                                    <div class="sc-icon"
                                                                        style="background:var(--warning-soft);color:var(--warning);">
                                                                        <i class="bi bi-pencil-square"></i>
                                                                    </div>
                                                                    Bài tự luận
                                                                </a>
                                                                <a href="${pageContext.request.contextPath}/teacher/results"
                                                                    class="shortcut-card">
                                                                    <div class="sc-icon"><i
                                                                            class="bi bi-bar-chart-line"></i></div>
                                                                    Kết quả học sinh
                                                                </a>
                                                                <a href="${pageContext.request.contextPath}/teacher/students"
                                                                    class="shortcut-card">
                                                                    <div class="sc-icon"><i class="bi bi-people"></i>
                                                                    </div>
                                                                    Học sinh của tôi
                                                                </a>
                                                            </div>
                                                        </div>
                                                    </div><%-- /col-lg-4 --%>

                                    </div><%-- /row --%>
                            </main>
                        </div>

                        <jsp:include page="../common/footer.jsp" />
                    </body>

                    </html>